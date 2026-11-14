/// Macro shorthand for constructing a record field datum for a database record.
#define BUILD_FIELD(KEY, PATH, NAME, ARGS...) KEY = new PATH(src, KEY, NAME, ##ARGS)
