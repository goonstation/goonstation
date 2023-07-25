
///Used to translate internal action names to human-readable names.
var/list/action_names = list(

	"attackself" = "Use in-hand",
	"togglethrow" = "Throw (Toggle)",
	"swaphand" = "Swap Hand",
	"equip" = "Equip",
	"resist" = "Resist",

	"fart" = "Fart",
	"flip" = "Flip",
	"twirl" = "Twirl",
	"eyebrow" = "Raise Eyebrow",
	"gasp" = "Gasp",
	"raisehand" = "Raise Hand",
	"dance" = "Dance",
	"laugh" = "Laugh",
	"nod" = "Nod",
	"wave" = "Wave",
	"wink" = "Wink",
	"flex" = "Flex",
	"yawn" = "Yawn",
	"snap" = "Snap",
	"scream" = "Scream",
	"salute" = "Salute",
	"burp" = "Burp",

	"help" = "Help Intent",
	"disarm" = "Disarm Intent",
	"grab" = "Grab Intent",
	"harm" = "Harm Intent",

	"look_n" = "Look North",
	"look_s" = "Look South",
	"look_w" = "Look West",
	"look_e" = "Look East",

	"say" = "Say",
	"say_radio" = "Say Radio",
	"say_main_radio" = "Say Main Radio",
	"dsay" = "Dead Say",
	"asay" = "Admin Say",
	"whisper" = "Whisper",
	"ooc" = "OOC",
	"looc" = "LOOC",
	"emote" = "Custom Emote",

	"screenshot" = "Screenshot",
	"autoscreenshot" = "Auto Screenshot",

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

	"unequip" = "Unequip (Silicon)",
	"pickup" = "Pick Up",
	"drop" = "Drop",
	"stop_pull" = "Stop Pulling",

	"fire" = "Fire",
	"fire_secondary" = "Fire Secondary",
	"stop" = "Stop",
	"alt_fire" = "Alternate Fire",
	"cycle" = "Cycle Shell",
	"exit" = "Exit",

	"mentorhelp" = "Mentor Help",
	"adminhelp" = "Admin Help",

	"togglepoint" = "Toggle Pointing",
	"refocus"   = "Refocus Window",
	"mainfocus" = "Focus Main Window",

	"admin_interact" = "Admin Interact",

	"module1" = "Module 1",
	"module2" = "Module 2",
	"module3" = "Module 3",
	"module4" = "Module 4"
)

///Used for literal input of actions
var/list/action_verbs = list(
	"say_radio" = "say_radio",
	"salute" = "me_hotkey salute",
	"burp" = "me_hotkey burp",
	"dab" = "me_hotkey dab",
	"dance" = "me_hotkey dance",
	"eyebrow" = "me_hotkey eyebrow",
	"fart" = "me_hotkey fart",
	"flip" = "me_hotkey flip",
	"twirl" = "me_hotkey twirl",
	"gasp" = "me_hotkey gasp",
	"raisehand" = "me_hotkey raisehand",
	"laugh" = "me_hotkey laugh",
	"nod" = "me_hotkey nod",
	"wave" = "me_hotkey wave",
	"flip" = "me_hotkey flip",
	"scream" = "me_hotkey scream",
	"wink" = "me_hotkey wink",
	"flex" = "me_hotkey flex",
	"yawn" = "me_hotkey yawn",
	"snap" = "me_hotkey snap",
	"pickup" = "pick-up",
	"adminhelp" = "adminhelp",
	"mentorhelp" = "mentorhelp",
	"autoscreenshot" = ".xscreenshot auto",
	"screenshot" = ".xscreenshot",
	"togglepoint" = "togglepoint",
	"refocus"   = ".winset \\\"mainwindow.input.focus=true;mainwindow.input.text=\\\"\\\"\\\"",
	"mainfocus" = ".winset \"mainwindow.input.focus=false;mapwindow.map.focus=true;mainwindow.input.text=\"\"\"",
	//"lazyfocus" = ".winset \\\"mainwindow.input.focus=true\\\"",
	"Admin Interact" = "admin_interact"
)

var/list/action_macros = list(
	"asay" = "asaymacro",
	"dsay" = "dsaymacro",
	"say" = "startsay",
	"emote-h" = "startemote-h",
	"emote-v" = "startemote-v",
	"say_main_radio" = "radiosay",
	"ooc" = "ooc",
	"looc" = "looc",
	"whisper" = "whisper",
)

///Used to translate bitflags of hotkeys into human-readable names
var/list/key_names = list(
	"[KEY_FORWARD]" = "Up",
	"[KEY_BACKWARD]" = "Down",
	"[KEY_LEFT]" = "Left",
	"[KEY_RIGHT]" = "Right",
	"[KEY_RUN]" = "Run",
	"[KEY_THROW]" = "Throw",
	"[KEY_POINT]" = "Point",
	"[KEY_EXAMINE]" = "Examine",
	"[KEY_PULL]" = "Pull",
	"[KEY_OPEN]" = "Open",
	"[KEY_BOLT]" = "Bolt",
	"[KEY_SHOCK]" = "Electrify"
)
