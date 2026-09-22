---
name: sync
description: Sync the dotfiles repo with origin, pulling remote changes, committing local ones and pushing.
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git pull:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(./check.sh:*)
---

Sync this repo with `origin/master`. Run everything from the repo root.

1. **Check the branch.** Run `git status`. If the branch isn't `master`, stop and ask
   before going further.

2. **Pull.** Run `git pull --rebase --autostash`. If it stops on a conflict, don't
   resolve it yourself: report the conflicting files and stop.

3. **Commit local changes**, if there are any. Skip this step on a clean tree.
   - Read the full diff (`git diff`, plus `git status` for untracked files) before
     staging anything.
   - Don't commit secrets: private keys, tokens, passwords, WireGuard `PrivateKey`
     lines. Don't commit runtime junk that `.gitignore` missed (Caelestia `.bak`
     files, caches, history). If you find either, leave it out and say so.
   - Run `./check.sh`. If it fails, stop and show the failure instead of committing.
   - Split unrelated changes into separate commits. Stage files by name, never
     `git add -A`.
   - Write subjects in the repo's Conventional Commits style (`feat:`, `fix:`,
     `perf:`, `chore:`), lowercase and in the imperative, like `git log --format=%s -10`.

4. **Push.** Run `git push`. If it's rejected because origin moved, pull again
   (step 2) and retry once.

5. **Report**, briefly: what was pulled (commit count, or "already up to date"), each
   commit made (hash and subject), and whether the push succeeded. Mention anything
   left uncommitted and why.
