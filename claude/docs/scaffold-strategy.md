# Scaffold Strategy

Default stack and conventions for new projects. Two shapes: **monorepo** (default for
anything with more than one deployable) and **single app** (one Next.js app, no workspaces).
Pick single app unless there is a second deployable or a package genuinely shared across apps.

## Runtime and tooling (both shapes)

- **bun** as runtime and package manager. Never npm/yarn/pnpm.
- **biome** as formatter and linter. Root `biome.jsonc`, double quotes, space indent,
  `organizeImports` on as an assist action, `vcs.useIgnoreFile: true`.
  Exclude `**/*.css` from the linter when using tailwind v4, its at-rules confuse the CSS parser.
- **lefthook** pre-commit running `bunx biome check --write --no-errors-on-unmatched
  --files-ignore-unknown=true {staged_files}` with `stage_fixed: true`.
- **TypeScript** everywhere, type hints always.
- Env validated per package with `@t3-oss/env-nextjs` + zod. One `env-*.ts` per concern
  (`env-db.ts`, `env-auth.ts`, `env-client.ts`, `env-server.ts`), each exporting a named
  const (`envDb`, `envAuth`). `SKIP_ENV_VALIDATION=1` bypasses in CI.

## Monorepo shape

Turborepo + bun workspaces. `workspaces.packages: ["apps/*", "packages/*"]`.

- `apps/*` deployables (Next.js).
- `packages/db` drizzle schema, client, migrations, seeds.
- `packages/auth` better-auth: drizzle adapter, plugins, `permissions.ts` for access control.
- `packages/api` tRPC router, context, handler, react/server glue. Keep `TRPC_ENDPOINT` in a
  server-free `config.ts` so client components never pull the db in.
- `packages/ui` shadcn/ui (`new-york`, neutral, cssVariables), tailwind v4 via
  `@tailwindcss/postcss`, shared `globals.css`.
- `packages/commons` shared consts, utils, zod schemas. Minimal dependencies.
- `packages/typescript-config` `base.json`, `react-library.json`, `nextjs.json`.
- `services/*` for non-JS or separately-deployed services (scrapers, workers).

Naming: `@workspace/*`, deps as `workspace:*`. Pin shared versions in bun
`workspaces.catalog` and reference as `"catalog:"`.

`turbo.json`: `ui: "tui"`. Declare every env var prefix in `globalEnv` or turbo will
cache across differing environments. All `db:*` and `dev*` tasks get
`cache: false` and `persistent: true`. `build` gets `dependsOn: ["^build"]`,
`inputs: ["$TURBO_DEFAULT$", ".env*"]`, `outputs: [".next/**", "!.next/cache/**"]`.

Root scripts proxy to turbo (`"db:migrate": "turbo db:migrate"`). Package-level db scripts
load the root env explicitly: `bun --env-file='../../.env' drizzle-kit generate`.

## Single app shape

Flat Next.js app. `db/` at the root instead of `packages/db`, same internals and same
naming rules. `env.ts` + `env-client.ts` at root. Path alias `@/*`. No turbo, no catalog.

## Database

drizzle-orm + Postgres. Neon in production. Local dev via docker-compose postgres.

Driver choice, in order of preference:

1. **`postgres-js` everywhere including prod**, against Neon's pooled connection string.
   Correct default whenever prod runs on a Node runtime. Real interactive transactions,
   one driver in both environments, no proxy container.
2. **`neon-serverless` (WebSocket) everywhere**, with `ghcr.io/timowilhelm/local-neon-http-proxy`
   in compose for local. Only when prod is Edge/Workers and transactions are needed.
   Costs a container, a `db.localtest.me` + `api.localtest.me` hosts entry, and the image's
   bundled TLS cert has expired before.
3. **`neon-http`**. `drizzle-orm/neon-http` throws `No transactions support in neon-http driver`
   on every `.transaction()` call at any nesting depth. It only has `.batch()`. better-auth wraps
   user creation in a transaction, so this combination breaks signup. Avoid unless the app
   provably never needs an interactive transaction.

`neondatabase/neon_local` is Neon's official image but it proxies to a **real cloud branch**
(requires `NEON_API_KEY` + `NEON_PROJECT_ID`), it is not a local emulator. Use it only if you
want ephemeral cloud branch-per-git-branch, and note it does not remove the need for a driver decision.

### Table and column naming

Physical names are snake_case and prefixed twice: tables by domain, columns by a short
per-table abbreviation. This makes every column globally unique, which keeps raw SQL,
joins, and query logs unambiguous with no aliasing.

Define once in `schema/_db-schemas.ts`:

```ts
export function colNameGenerator<T extends string>(tableName: T) {
  return <TT extends string>(colName: TT): `${T}_${TT}` => `${tableName}_${colName}`;
}

export const authPgTable = pgTableCreator((name) => `auth_${name}`);
export const appPgTable  = pgTableCreator((name) => `app_${name}`);   // domain prefix
export const aggPgTable  = pgTableCreator((name) => `_app_${name}`);  // derived/aggregate
```

Same file exports constraint helpers that derive their own names, so no constraint is ever
named by hand: `fk`, `pk`, `idx`, `uqIdx`, `uq`, built on a shared `namer(indexType,
tablePrefix, ...columns)`. Produces `idx_affl_status`, `uq_idx_user_email`,
`fk_link_affiliate_uuid`.

Watch the underscore: `colNameGenerator("prof")("")` returns `"prof_"`, already trailing an
underscore. Strip it before joining the name parts, or every constraint comes out as
`fk_prof__user_id` with a doubled underscore. Pass the prefix *function* into the helpers and
strip inside, rather than passing a prefix string around.

Per-table usage:

```ts
const colName = colNameGenerator("affl");

export const affiliateTable = appPgTable(
  "affiliate",
  {
    uuid: uuid(colName("uuid")).primaryKey().default(sql`uuidv7()`),
    status: text(colName("status"), { enum: ["active", "banned"] })
      .$type<AffiliateStatus>().notNull().default("active"),
    createdAt: timestamp(colName("created_at")).notNull().defaultNow(),
    updatedAt: timestamp(colName("updated_at")).notNull().defaultNow()
      .$onUpdateFn(() => new Date()),
  },
  (col) => [fk(colName, col.managerId, userTable.id), idx(colName, col.status)],
).enableRLS();

export type Affiliate = typeof affiliateTable.$inferSelect;
export type NewAffiliate = typeof affiliateTable.$inferInsert;
```

Rules:

- TS property names are camelCase, physical names snake_case via `colName()`.
- Exported table consts end in `Table`. Export `$inferSelect` / `$inferInsert` types beside them.
- **No `pgEnum`.** Use `text(col, { enum: [...] }).$type<T>()`. Union type lives in the shared
  commons package. Adding a value is a code change, not a migration with an `ALTER TYPE`.
- Primary keys: `uuid` defaulted to `sql\`uuidv7()\`` for domain tables, `serial` for small
  lookup tables. Foreign key columns are named `<thing>Uuid`, except where an adapter
  dictates otherwise (better-auth names its user PK `id`, so FKs onto it stay `userId`).
  `uuidv7()` is a Postgres 18 builtin, so create the Neon project on 18. Where an adapter
  generates ids itself (better-auth), give it `generateId: () => v7()` instead.
- Every table gets `createdAt` / `updatedAt` with `defaultNow()` and `$onUpdateFn`.
- `metadata: jsonb().$type<Record<string, unknown>>().notNull().default({})` as the escape hatch.
- Case-insensitive uniqueness via a generated column plus a unique index, not a functional index:
  `nameLower: text(colName("name_lower")).notNull().generatedAlwaysAs(sql.raw(...))`.
- `.enableRLS()` on every table. The app connects as the table owner, and owners bypass RLS
  unless `FORCE ROW LEVEL SECURITY` is set, so this costs the app nothing while denying any
  role that later gets a stray `GRANT`. Verified: a non-superuser owner reads and writes
  normally, an outsider holding `GRANT SELECT` sees zero rows.
- One file per table, named `<domain>-<table>.ts`. Shared helpers prefixed `_`.
  Relations live in `_relations_*.ts`, not inline.
- Aggregate/rollup column groups are factored into a `commonXAggColumns(colName)` helper
  that a table spreads into itself.

### db package internals

`db.ts` exports the client factory and re-exports `drizzle-orm`. `utils.ts` holds query
helpers, notably `buildConflictUpdateColumns(table, cols)` and
`buildConflictIncrementColumns(table, cols)` for upserts. Separate `seed.ts` and
`seed-dev.ts`, a `reset.ts`, and `triggers/` + `procedures/` with their own `_migrate.ts`
runners for anything drizzle-kit cannot express.

### Redis and query caching

Upstash Redis over HTTP, used as the drizzle query cache and as a general KV store. The
same `@upstash/redis` client talks to `hiett/serverless-redis-http` locally and to Upstash
in prod, so there is one client and one code path in every environment. No `ioredis`, no
second client for local.

`env-db.ts` validates `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN`. `redis.ts` is only a
factory, so nothing imports a live connection at module scope:

```ts
import { Redis } from "@upstash/redis";
import { envDb } from "./env-db";

export function createRedisClient() {
  return new Redis({
    url: envDb.UPSTASH_REDIS_REST_URL,
    token: envDb.UPSTASH_REDIS_REST_TOKEN,
  });
}

export type RedisClient = ReturnType<typeof createRedisClient>;
```

#### Key naming

**Every key is prefixed with the project name, then the environment, then a namespace.**
Project first, because one Upstash database often serves several projects and a `SCAN` or a
flush for one must never reach another. Environment second, so dev, staging and prod can
share a database without colliding.

Keys are never built inline at a call site. One `RedisKey` const in the shared commons
package owns every key shape, so the whole keyspace is greppable in one file:

```ts
const PROJECT = "myapp";

function redisKey(key: string) {
  return `${PROJECT}:${envCommons.NEXT_PUBLIC_ENV}:${key}`;
}

export const RedisKey = {
  CategoriesAll: redisKey("categories:all"),
  Shortlink: (idOrSlug: string) => redisKey(`link:${idOrSlug}`),
  Drizzle: (key: string) => redisKey(`drizzle:${key}`),
  Auth: (key: string) => redisKey(`auth:${key}`),
  Dynamic: (key: string) => redisKey(key),
} as const;
export type RedisKey = (typeof RedisKey)[keyof typeof RedisKey];
```

Static keys are values, parameterised keys are functions. `Dynamic` is the escape hatch and
should stay rare. The cache adapter below takes its prefix function as a constructor field,
so it never knows the project name itself.

#### Drizzle cache adapter

drizzle exposes a `Cache` base class at `drizzle-orm/cache/core/cache`. Subclass it, hand
the instance to `drizzle({ cache })`, and every select routes through it.

```ts
import { getTableName, is, Table } from "drizzle-orm";
import { Cache } from "drizzle-orm/cache/core/cache";
import type { CacheConfig } from "drizzle-orm/cache/core/types";

export class RedisCache extends Cache {
  private defaultTtl: number;
  private prefix: (str: string) => string;

  constructor(private redis: RedisClient, options?: { defaultTtl?: number }) {
    super();
    this.defaultTtl = options?.defaultTtl ?? 60;
    this.prefix = RedisKey.Drizzle;
  }

  override strategy(): "explicit" {
    return "explicit";
  }

  override async get<T = unknown>(key: string): Promise<T[] | undefined> {
    const cached = await this.redis.get<T[]>(this.prefix(key));
    return cached ?? undefined;
  }

  override async put(
    hashedQuery: string,
    response: unknown,
    tables: string[],
    _isTag: boolean,
    config?: CacheConfig,
  ): Promise<void> {
    const ttl = config?.ex ?? this.defaultTtl;
    const prefixedKey = this.prefix(hashedQuery);

    const pipeline = this.redis.pipeline();
    pipeline.set(prefixedKey, response, { ex: ttl });
    for (const table of tables) {
      const setKey = this.prefix(`table:${table}`);
      pipeline.sadd(setKey, prefixedKey);
      pipeline.expire(setKey, ttl, "NX"); // seed
      pipeline.expire(setKey, ttl, "GT"); // extend
    }
    await pipeline.exec();
  }

  override async onMutate(params: {
    tags?: string | string[];
    tables?: string | string[] | Table | Table[];
  }): Promise<void> {
    // normalise tags/tables to arrays, then:
    const tableNames = tables.map((t) => (is(t, Table) ? getTableName(t) : t));
    const keysToDelete = tags.map((t) => this.prefix(t));

    if (tableNames.length > 0) {
      const fetch = this.redis.pipeline();
      for (const name of tableNames) fetch.smembers(this.prefix(`table:${name}`));
      for (const keys of await fetch.exec<string[][]>()) keysToDelete.push(...keys);
    }

    const del = this.redis.pipeline();
    for (const name of tableNames) del.del(this.prefix(`table:${name}`));
    for (const key of keysToDelete) del.del(key);
    await del.exec();
  }
}
```

The invalidation index is the whole trick: `put` writes the query result under its hashed
key *and* adds that key to a set per table it touched. `onMutate` reads those sets to find
every cached query involving a mutated table, deletes the queries, then deletes the sets.

Wire it in once and share the instance across both driver factories:

```ts
const cache = new RedisCache(createRedisClient(), { defaultTtl: 60 });

export function createDbInstance() {
  return drizzle({ connection: connectionString, cache, logger: LOGGER });
}
```

Notes and traps:

- **`strategy(): "explicit"` is the default. Always.** `"all"` makes staleness the default
  too, and the queries where that is wrong do not announce themselves at the call site. Opt
  in per query with `.$withCache()`.
- What to opt in: list and detail reads behind an admin screen, anything read on nearly every
  request (the current user's profile), and lookup tables. What to leave alone: **any query
  whose `where` clause reads the clock**, such as `gt(expiresAt, new Date())`. The cached row
  was computed against an older `now()`, so an expired row keeps reading as live until the TTL
  lapses. Invite gates, token checks and rate limits all fall in here, and they are exactly
  the queries where being wrong matters most. Invalidation cannot save you, since nothing
  mutated.
- Give the per-table key sets a TTL of their own. A join registers its query key under every
  table it touched, so invalidating one table leaves the *other* tables' sets holding a key
  that no longer exists, and those sets otherwise live forever. Issue `EXPIRE` twice: `NX` to
  seed a set that has no TTL, `GT` to extend one that does. `GT` alone silently does nothing
  on a fresh set, because Redis reads a missing TTL as infinite and refuses to lower it.
- Invalidation only fires for mutations that go **through drizzle**. Raw SQL, a psql session,
  triggers and stored procedures all bypass `onMutate` and leave stale keys until the TTL.
  Keep `defaultTtl` short (60s) so that stays a blip.
- **Invalidation races the write.** drizzle runs `Promise.all([query(), cache.onMutate(...)])`,
  so the `DEL` is concurrent with the statement, not after it. A read landing in that window
  repopulates pre-mutation rows and holds them for the full TTL. Fix it at the call site: have
  mutating actions invalidate again once their writes have resolved.
- **`db.$cache.invalidate` is a no-op.** In 0.45.2 its body is empty (`invalidate: async
  (_params) => {}`) while its type says otherwise, so a manual invalidation through it silently
  does nothing. Keep a reference to your own `Cache` instance and call `onMutate` on it.
- **Match drizzle's table naming, or invalidation silently misses.** drizzle keys cached
  queries by `Table.Symbol.BaseName`, the name *before* a `pgTableCreator` prefix, so `profile`
  and not `frnd_profile`. `getTableName()` returns the prefixed name and will never match. Use
  `extractUsedTable` from `drizzle-orm/pg-core`, which is drizzle's own resolver and public, so
  the two sides cannot drift.
- The Upstash client serialises to JSON itself. Do not `JSON.stringify` before `set`, or
  you get double-encoded values back.
- `{ ex: ttl }` is seconds.
- `pipeline.exec<T>()` needs its type argument to be the array of per-command results,
  hence `exec<string[][]>()` for a pipeline of `smembers`.
- Dates come back as strings, since it is JSON on the wire. Anything that round-trips a
  `timestamp` column through the cache needs revival at the edge of the query layer.
- A failed mutation still invalidates. drizzle calls `onMutate` whether or not the statement
  succeeded, so a rejected insert flushes the cache for that table. Conservative, not wrong.
- **Nothing in the db package may `import "server-only"`.** The seed, migrate and reset
  scripts import the db client under plain bun, where that package throws
  `This module cannot be imported from a Client Component module`. It only no-ops under the
  `react-server` export condition. Mark the query layer server-only, never the client or the
  cache adapter.

#### better-auth on the same Redis

Session lookups run on nearly every request, so hand better-auth a `secondaryStorage` backed
by the same client. Namespace its keys `auth:` through the same `RedisKey` const, so
invalidating drizzle query keys can never drop a session.

```ts
export const secondaryStorage = redis
  ? {
      get: async (key: string) => asString(await redis.get(RedisKey.Auth(key))),
      getAndDelete: async (key: string) => asString(await redis.getdel(RedisKey.Auth(key))),
      increment: async (key: string) => redis.incr(RedisKey.Auth(key)),
      set: async (key: string, value: string, ttl?: number) =>
        void (await redis.set(RedisKey.Auth(key), value, ttl ? { ex: ttl } : undefined)),
      delete: async (key: string) => void (await redis.del(RedisKey.Auth(key))),
    }
  : undefined;
```

Four things bite here:

- **Set `session.storeSessionInDatabase: true`, and `verification.storeInDatabase: true`
  alongside it.** Verification values take the same path as sessions, so at the defaults a
  magic-link token lives in Redis alone and an eviction between sending the link and clicking
  it breaks that sign-in. Configuring a database adapter does *not* change this. Left at its default, better-auth writes
  sessions to secondary storage *only* and `findSession` returns null instead of falling back
  to the row, so a Redis flush or eviction signs every user out. With these set, the rows are
  the durable copy and Redis is a read cache in front of them.
- **`get` must return a string.** better-auth runs `safeJSONParse` on whatever comes back, but
  the Upstash client JSON-decodes on the way out, so a stored session returns as an object and
  parsing fails. Re-stringify anything that is not already a string.
- **`getAndDelete` must be one operation** (`GETDEL`), not a read followed by a delete. Magic
  links and other single-use verification values are consumed through it, and two operations
  leave a window to replay the link.
- The interface also requires `increment`. It is `INCR`, and it is easy to miss because the
  types are bundled and will not grep.

## Data layer in apps

TanStack query / table / form / charts. zod for schemas. tRPC when there is more than one
consumer, plain server actions when there is one.

## Email

resend + react-email. Templates in their own package or `emails/` dir, with the react-email
preview server wired to a `dev:email` task. In local dev do not send, log the link or payload
to the console instead.

## Local infra

docker-compose for stateful services only. Application code runs on the host.
postgres:18-alpine with a healthcheck, redis:8-alpine when needed, plus
`hiett/serverless-redis-http` as an Upstash-compatible proxy so the same redis client works
locally and in prod.

### Emulating Upstash locally

`@upstash/redis` speaks HTTP, not RESP, so a plain redis container is not enough on its own.
`hiett/serverless-redis-http` (SRH) sits in front of it and serves the Upstash REST API, so
the client, the key names and the cache adapter are byte-identical in local and prod.

```yaml
  redis:
    image: redis:8-alpine
    container_name: redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  serverless-redis-http:
    image: hiett/serverless-redis-http:latest
    ports:
      - "8079:80"
    environment:
      SRH_MODE: env
      SRH_TOKEN: local_dev_token
      SRH_CONNECTION_STRING: "redis://redis:6379"
    depends_on:
      redis:
        condition: service_healthy

  redisinsight:
    image: redis/redisinsight:latest
    container_name: redisinsight
    restart: unless-stopped
    ports:
      - "5540:5540"
    volumes:
      - redisinsight_data:/data
    depends_on:
      redis:
        condition: service_healthy
```

Local env then points at the proxy, not the redis port:

```
UPSTASH_REDIS_REST_URL=http://localhost:8079
UPSTASH_REDIS_REST_TOKEN=local_dev_token
```

`SRH_TOKEN` is whatever you put in `UPSTASH_REDIS_REST_TOKEN`; the two must match or every call
returns 401. SRH listens on **port 80 inside the container**, so the mapping is `8079:80`,
not `8079:8079`. Point the app at `localhost:6379` by mistake and the client fails with a
parse error rather than a connection error, because it gets RESP where it expected JSON.

Pick host ports per project rather than taking 6379 and 8079 by default. Every project
using this stack wants the same two, and compose fails with `Bind for 0.0.0.0:6379 failed:
port is already allocated` the moment a second one is up. Check with `docker ps` first. The
container-internal `redis:6379` in `SRH_CONNECTION_STRING` never changes, only the host side.

SRH serves the JSON-body API that `@upstash/redis` uses, not the path-style REST API. A
`curl http://localhost:8079/get/key` returns `SRH: Endpoint not found`, which looks like a
broken proxy but is not. Smoke-test with the real client, not curl.

redisinsight on :5540 is optional but worth having, since inspecting the drizzle cache means
reading `table:*` sets by hand and a CLI makes that tedious.
