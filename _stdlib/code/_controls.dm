// haha hope you never need more than 16 of these
#define KEY_FORWARD   0x0001
#define KEY_BACKWARD  0x0002
#define KEY_LEFT      0x0004
#define KEY_RIGHT     0x0008
#define KEY_RUN       0x0010
#define KEY_THROW     0x0020
#define KEY_POINT     0x0040
#define KEY_EXAMINE   0x0080
#define KEY_PULL      0x0100
#define KEY_OPEN      0x0200
#define KEY_BOLT      0x0400
#define KEY_SHOCK     0x0800

var/datum/bind_set
	binds_general = new /datum/bind_set {
		name = "General";
		keys = KEY_FORWARD|KEY_BACKWARD|KEY_LEFT|KEY_RIGHT;
		actions = list("refocus", "say", "fart", "flip")
	}

	binds_human = new /datum/bind_set {
		name = "Human";
		keys = KEY_RUN | KEY_THROW | KEY_POINT;
		actions = list("drop", "attackself", "togglethrow", "swaphand", "equip", "help", "disarm", "grab", "harm")
	}

	binds_robot = new /datum/bind_set {
		name = "Robot";
		keys = KEY_RUN | KEY_POINT | KEY_OPEN | KEY_BOLT | KEY_SHOCK;
		actions = list("attackself", "swaphand", "help", "harm", "module1", "module2", "module3", "module4")
	}

	binds_pod = new /datum/bind_set {
		name = "Pod";
		keys = 0;
		actions = list("fire", "fire_secondary")
	}

	binds_artillery = new /datum/bind_set {
		name = "Flak Cannon";
		keys = 0;
		actions = list("fire", "cycle")
	}

var/list/bindsets = list(binds_general, binds_human, binds_robot, binds_pod, binds_artillery)

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

	"admin_interact" = "Admin Interact"
)

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
