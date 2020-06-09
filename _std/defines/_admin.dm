// verb categories
#define ADMIN_CAT_PREFIX "🇦 "

#define ADMIN_CAT_PLAYERS "Players"
#define ADMIN_CAT_SERVER "Server"
#define ADMIN_CAT_SELF "Self"
#define ADMIN_CAT_ATOM "Atom"
#define ADMIN_CAT_SERVER_TOGGLES "Server Toggles"
#define ADMIN_CAT_FUN "Fun"
#define ADMIN_CAT_DEBUG "Debug"
#define ADMIN_CAT_UNUSED "You Should Never See This" // note that the verb might still be used as a proc, don't delete those
#define ADMIN_CAT_NONE null

#define SET_ADMIN_CAT(CAT) set category = CAT ? ADMIN_CAT_PREFIX + CAT : null
