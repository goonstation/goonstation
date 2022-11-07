//eventually move this to some sort of _std/procs folder

/// Returns true if A has the given variable, false if not. Null if A doesn't exist.
#define hasvar(D, var_name) (D?.vars?.Find(var_name))

/// Istype, but exact. Thing must be a datum.
#define istype_exact(thing, given_typepath) (thing.type == given_typepath)
