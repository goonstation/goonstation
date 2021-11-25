// this file has macro stuff for bitflags

/// checks if a flags variable (x) has a specific bitflag (if `flag` contains multiple flags it checks if all of them are set)
#define HAS_FLAG(x, flag) ((x & flag) == flag)

/// checks if a flags variable (x) has a specific bitflag
#define HAS_ANY_FLAGS(x, flags) (x & flag)

/// adds a flag to a flags variable (x). if the flag is already added, nothing happens
#define ADD_FLAG(x, flag) (x |= flag)

/// removes a flag from a flags variable (x). if the flag is not in the flags variable, nothing happens
#define REMOVE_FLAG(x, flag) (x &= ~flag)

/// toggles a flag in a flags variable (x)
#define TOGGLE_FLAG(x, flag) (x ^= flag)
