// pick strings from cache-- code/procs/string_cache.dm
#define pick_string(filename, key) pick(strings(filename, key))
#define pick_string_autokey(filename) pick(strings(filename, null))

#define __red(x) text("<span class='alert'>[]</span>", x)  //deprecated for some reason
#define __blue(x) text("<span class='notice'>[]</span>", x) //deprecated for some reason

/// strip html from a string
#define CLEAN(x) html_encode("[x]")

#define JOHN_PICK(WHAT) pick_string("johnbill.txt", WHAT)
#define SPACER_PICK(WHAT) pick_string("spacers.txt", WHAT)
