/** Package name to a short reason it is installed. */
export type Group = Record<string, string>;

/** Group name to its packages. Files export one of these as default. */
export type PackageList = Record<string, Group>;
