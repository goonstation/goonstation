// pick strings from cache-- code/procs/string_cache.dm
#define pick_string(filename, key) pick(strings(filename, key))
#define pick_string_autokey(filename) pick(strings(filename, null))

/// strip html from a string
#define CLEAN(x) html_encode("[x]")

#define JOHN_PICK(WHAT) pick_string("johnbill.txt", WHAT)
#define SPACER_PICK(WHAT) pick_string("spacers.txt", WHAT)

/// Takes an input string like "A" and turns it into a macro A
#define TEXT_TO_MACRO(Y) if(#Y) return Y
