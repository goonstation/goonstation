//debug stuff (used for if something is being hard deleted thru debug commands)
#define DELETE_STOP 0
#define DELETE_RUNNING 1
#define DELETE_CHECK 2

//admin levels
#define LEVEL_HOST 6
#define LEVEL_CODER 5
#define LEVEL_ADMIN 4
#define LEVEL_PA 3
#define LEVEL_IA 2
#define LEVEL_SA 1
#define LEVEL_MOD 0
#define LEVEL_BABBY -1

// verb categories
#define ADMIN_CAT_PREFIX "🇦"

#define ADMIN_CAT_PLAYERS "Players"
#define ADMIN_CAT_SERVER "Server"
#define ADMIN_CAT_SELF "Self"
#define ADMIN_CAT_ATOM "Atom"
#define ADMIN_CAT_SERVER_TOGGLES "Server Toggles"
#define ADMIN_CAT_FUN "Fun"
#define ADMIN_CAT_DEBUG "Debug"
#define ADMIN_CAT_UNUSED "You Should Never See This" // note that the verb might still be used as a proc, don't delete those
#define ADMIN_CAT_NONE null // not in the tabs

#define SET_ADMIN_CAT(CAT) set category = CAT ? ADMIN_CAT_PREFIX + CAT : null

var/global/list/toggleable_admin_verb_categories = list(
	ADMIN_CAT_PLAYERS,
	ADMIN_CAT_SERVER,
	// not ADMIN_CAT_SELF because it contains Change Admin Preferences
	ADMIN_CAT_ATOM,
	ADMIN_CAT_SERVER_TOGGLES,
	ADMIN_CAT_FUN,
	ADMIN_CAT_DEBUG
)

//Auditing

/// Whether or not a potentially suspicious action gets denied by the code.
#define AUDIT_ACCESS_DENIED (0 << 1)
/// Logged whenever you try to View Variables a thing
#define AUDIT_VIEW_VARIABLES (1 << 1)

/// for audible and dectalk PM's
#define PM_NO_ALERT 0
#define PM_AUDIBLE_ALERT 1
#define PM_DECTALK_ALERT 2
