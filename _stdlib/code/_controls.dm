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

// move this somewhere saner when there's a bind manager
/client/proc/get_keymap(name)
	if (src.preferences.use_wasd)
		switch (name)
			if ("general")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"Z" = KEY_FORWARD,
							"S" = KEY_BACKWARD,
							"Q" = KEY_LEFT,
							"D" = KEY_RIGHT,
							"B" = KEY_POINT,
							"T" = "say",
							"Y" = "say_radio",
							"W" = "resist",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"O" = "ooc",
							"M" = "emote",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup",
							"`" = "admin_interact",
							"~" = "admin_interact"
						))
				else
					return new /datum/keymap(list(
							"W" = KEY_FORWARD,
							"S" = KEY_BACKWARD,
							"A" = KEY_LEFT,
							"D" = KEY_RIGHT,
							"B" = KEY_POINT,
							"NORTH" = KEY_FORWARD,
							"SOUTH" = KEY_BACKWARD,
							"WEST" = KEY_LEFT,
							"EAST" = KEY_RIGHT,
							"T" = "say",
							"Y" = "say_radio",
							"Z" = "resist",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"O" = "ooc",
							"M" = "emote",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup",
							"`" = "admin_interact",
							"~" = "admin_interact"
						))
			if ("human")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"V" = "equip",
							"E" = "swaphand",
							"C" = "attackself",
							"A" = "drop"
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"SPACE" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"SHIFT" = KEY_EXAMINE,
							"R" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"E" = "equip",
							"X" = "swaphand",
							"Z" = "attackself",
							"C" = "resist",
							"Q" = "drop"
						))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"B" = KEY_POINT,
							"V" = "equip",
							"E" = "swaphand",
							"C" = "attackself",
							"Q" = "drop"
						))
			if ("robot")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"SPACE" = KEY_SHOCK,
							"ALT" = KEY_EXAMINE,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"E" = "swaphand",
							"C" = "attackself",
							"A" = "unequip"
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"CTRL" = KEY_BOLT,
							"SHIFT" = KEY_OPEN,
							"ALT" = KEY_SHOCK,
							"SPACE" = KEY_EXAMINE,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"X" = "swaphand",
							"Z" = "attackself",
							"C" = "resist",
							"Q" = "unequip"
						))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_SHOCK,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"B" = KEY_POINT,
							"E" = "swaphand",
							"C" = "attackself",
							"Q" = "unequip"
						))
			if ("drone")
				if (src.preferences.use_azerty)
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"ALT" = KEY_EXAMINE,
							"CTRL" = KEY_PULL,
							"C" = "attackself",
							"A" = "unequip",
						))
				else if (src.tg_controls)
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"SHIFT" = KEY_EXAMINE,
							"CTRL" = KEY_PULL,
							"Z" = "attackself",
							"Q" = "unequip",
						))
				else
					return new /datum/keymap(list(
							"B" = KEY_POINT,
							"ALT" = KEY_EXAMINE,
							"CTRL" = KEY_PULL,
							"C" = "attackself",
							"Q" = "unequip",
						))
			if ("pod")
				return new /datum/keymap(list(
						"SPACE" = "fire"
					))
			if("colosseum_putt")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "stop",
						"E" = "alt_fire",
						))
			if ("artillery")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "cycle"
					))
			if ("torpedo")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"E" = "exit",
						"Q" = "exit"
					))
	else
		switch (name)
			if ("general")
				if(src.tg_controls)
					return new /datum/keymap(list(
						"NORTH" = KEY_FORWARD,
						"SOUTH" = KEY_BACKWARD,
						"WEST" = KEY_LEFT,
						"EAST" = KEY_RIGHT,
						"T" = "say",
						"Y" = "say_radio",
						"C" = "resist",
						"G" = "refocus",
						"F" = "fart",
						"R" = "flip",
						"ESCAPE" = "mainfocus",
						"RETURN" = "mainfocus",
						"CTRL+A" = "attackself",
						"CTRL+B" = "burp",
						"ALT+C" = "ooc",
						"CTRL+D" = "drop",
						"CTRL+E" = "eyebrow",
						"CTRL+F" = "fart",
						"CTRL+G" = "gasp",
						"CTRL+H" = "raisehand",
						"ALT+L" = "looc",
						"CTRL+L" = "laugh",
						"CTRL+N" = "nod",
						"CTRL+P" = "togglepoint",
						"CTRL+Q" = "wave",
						"CTRL+R" = "flip",
						"CTRL+S" = "swaphand",
						"ALT+T" = "dsay",
						"CTRL+T" = "asay",
						"ALT+W" = "whisper",
						"CTRL+W" = "togglethrow",
						"CTRL+X" = "flex",
						"CTRL+Y" = "yawn",
						"CTRL+Z" = "snap",
						"F1" = "adminhelp",
						"CTRL+SHIFT+F1" = "options",
						"F2" = "autoscreenshot",
						"SHIFT+F2" = "screenshot",
						"F3" = "mentorhelp",
						"I" = "look_n",
						"K" = "look_s",
						"J" = "look_w",
						"L" = "look_e",
						"P" = "pickup",
						"DELETE" = "stop_pull",
						"`" = "admin_interact",
						"~" = "admin_interact"
					))
				else
					return new /datum/keymap(list(
							"NORTH" = KEY_FORWARD,
							"SOUTH" = KEY_BACKWARD,
							"WEST" = KEY_LEFT,
							"EAST" = KEY_RIGHT,
							"T" = "say",
							"Y" = "say_radio",
							"Z" = "resist",
							"G" = "refocus",
							"F" = "fart",
							"R" = "flip",
							"ESCAPE" = "mainfocus",
							"RETURN" = "mainfocus",
							"CTRL+A" = "salute",
							"CTRL+B" = "burp",
							"ALT+C" = "ooc",
							"CTRL+D" = "dance",
							"CTRL+E" = "eyebrow",
							"CTRL+F" = "fart",
							"CTRL+G" = "gasp",
							"CTRL+H" = "raisehand",
							"ALT+L" = "looc",
							"CTRL+L" = "laugh",
							"CTRL+N" = "nod",
							"CTRL+P" = "togglepoint",
							"CTRL+Q" = "wave",
							"CTRL+R" = "flip",
							"CTRL+S" = "scream",
							"ALT+T" = "dsay",
							"CTRL+T" = "asay",
							"ALT+W" = "whisper",
							"CTRL+W" = "wink",
							"CTRL+X" = "flex",
							"CTRL+Y" = "yawn",
							"CTRL+Z" = "snap",
							"F1" = "adminhelp",
							"CTRL+SHIFT+F1" = "options",
							"F2" = "autoscreenshot",
							"SHIFT+F2" = "screenshot",
							"F3" = "mentorhelp",
							"I" = "look_n",
							"K" = "look_s",
							"J" = "look_w",
							"L" = "look_e",
							"P" = "pickup",
							"`" = "admin_interact",
							"~" = "admin_interact"
						))
			if ("human")
				if(src.tg_controls)
					return new /datum/keymap(list(
							"SPACE" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"SHIFT" = KEY_EXAMINE,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"V" = "equip",
							"NORTHWEST" = "drop", /*HOME*/
							"SOUTHWEST" = "togglethrow", /*END*/
							"NORTHEAST" = "swaphand", /*PGUP*/
							"SOUTHEAST" = "attackself" /*PGDN*/
						))


				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_RUN,
							"CTRL" = KEY_PULL,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_THROW,
							"1" = "help",
							"2" = "disarm",
							"3" = "grab",
							"4" = "harm",
							"5" = "head",
							"6" = "chest",
							"7" = "l_arm",
							"8" = "r_arm",
							"9" = "l_leg",
							"0" = "r_leg",
							"-" = "walk",
							"=" = "rest",
							"V" = "equip",
							"NORTHEAST" = "swaphand",
							"SOUTHEAST" = "attackself",
							"NORTHWEST" = "drop",
							"DELETE" = "togglethrow"
						))

			if ("robot")
				if(src.tg_controls)
					return new /datum/keymap(list(
						"CTRL" = KEY_BOLT,
						"SHIFT" = KEY_OPEN,
						"ALT" = KEY_SHOCK,
						"SPACE" = KEY_EXAMINE,
						"1" = "module1",
						"2" = "module2",
						"3" = "module3",
						"4" = "module4",
						"B" = KEY_POINT,
						"X" = "swaphand",
						"Z" = "attackself",
						"C" = "resist",
						"Q" = "unequip"
					))
				else
					return new /datum/keymap(list(
							"SHIFT" = KEY_BOLT,
							"CTRL" = KEY_OPEN,
							"ALT" = KEY_EXAMINE,
							"SPACE" = KEY_SHOCK,
							"1" = "module1",
							"2" = "module2",
							"3" = "module3",
							"4" = "module4",
							"NORTHEAST" = "swaphand",
							"SOUTHEAST" = "attackself",
							"NORTHWEST" = "unequip"
					))
			if ("drone")
				return new /datum/keymap(list(
						"SOUTHEAST" = "attackself",
						"NORTHWEST" = "unequip"
					))
			if ("pod")
				return new /datum/keymap(list(
						"SPACE" = "fire",

					))
			if("colosseum_putt")
				return new /datum/keymap(list(
						"SOUTHEAST" = "fire",
						"NORTHWEST" = "stop",
						"NORTHEAST" = "alt_fire",
						))
			if ("artillery")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"Q" = "cycle"
					))
			if ("torpedo")
				return new /datum/keymap(list(
						"SPACE" = "fire",
						"E" = "exit",
						"Q" = "exit"
					))
