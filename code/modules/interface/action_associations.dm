var/list/action_names = list(
	"refocus" = "Focus Chat",
	"say" = "Say",
	"say_radio" = "Say Radio",

	"drop" = "drop",
	"attackself" = "Use in-hand",
	"togglethrow" = "Throw (Toggle)",
	"swaphand" = "Swap Hand",
	"equip" = "Equip",

	"fart" = "Fart",
	"flip" = "Flip",

	"help" = "Help Intent",
	"disarm" = "Disarm Intent",
	"grab" = "Grab Intent",
	"harm" = "Harm Intent",

	"look_n" = "Look North",
	"look_s" = "Look South",
	"look_w" = "Look West",
	"look_e" = "Look East",

	"head" = "Target Head",
	"chest" = "Target Chest",
	"l_arm" = "Target Left Arm",
	"r_arm" = "Target Right Arm",
	"l_leg" = "Target Left Leg",
	"r_leg" = "Target Right Leg",

	"walk" = "Walk (Toggle)",
	"rest" = "Rest (Toggle)",

	"module1" = "Module 1",
	"module2" = "Module 2",
	"module3" = "Module 3",
	"module4" = "Module 4",

	"unequip" = "Unequip",

	"fire" = "Fire",
	"fire_secondary" = "Fire Secondary",
	"cycle" = "Cycle Shell",
	"exit" = "Exit",

	"refocus"   = "Refocus Window",
	"mainfocus" = "Focus Main Window",

	"admin_interact" = "Admin Interact"
)

///Used for literal input of actions, but also convient for display in most cases.
var/list/action_verbs = list(
	"say" = "say",
	"say_radio" = "say_radio",
	"emote" = "say *customv",
	"salute" = "say *salute",
	"burp" = "say *burp",
	"dab" = "say *dab",
	"dance" = "say *dance",
	"eyebrow" = "say *eyebrow",
	"fart" = "say *fart",
	"flip" = "say *flip",
	"gasp" = "say *gasp",
	"raisehand" = "say *raisehand",
	"laugh" = "say *laugh",
	"nod" = "say *nod",
	"wave" = "say *wave",
	"flip" = "say *flip",
	"scream" = "say *scream",
	"whisper" = "whisper",
	"wink" = "say *wink",
	"flex" = "say *flex",
	"yawn" = "say *yawn",
	"snap" = "say *snap",
	"pickup" = "pick-up",
	"ooc" = "ooc",
	"looc" = "looc",
	"dsay" = "dsay",
	"asay" = "asay",
	"adminhelp" = "adminhelp",
	"mentorhelp" = "mentorhelp",
	"options" = ".options",
	"autoscreenshot" = ".autoscreenshot",
	"screenshot" = ".screenshot",
	"togglepoint" = ".action togglepoint",
	"refocus"   = ".winset \\\"mainwindow.input.focus=true;mainwindow.input.text=\\\"\\\"\\\"",
	"mainfocus" = ".winset \"mainwindow.input.focus=false;mapwindow.map.focus=true;mainwindow.input.text=\"\"\"",
	//"lazyfocus" = ".winset \\\"mainwindow.input.focus=true\\\"",
	"Admin Interact" = "admin_interact"
)

var/list/key_names = list(
	"[KEY_FORWARD]" = "Up",
	"[KEY_BACKWARD]" = "Down",
	"[KEY_LEFT]" = "Left",
	"[KEY_RIGHT]" = "Right",
	"[KEY_RUN]" = "Run",
	"[KEY_THROW]" = "Throw (Hold)",
	"[KEY_POINT]" = "Point",
	"[KEY_EXAMINE]" = "Examine",
	"[KEY_PULL]" = "Pull",
	"[KEY_OPEN]" = "Open",
	"[KEY_BOLT]" = "Bolt",
	"[KEY_SHOCK]" = "Electrify"
)
