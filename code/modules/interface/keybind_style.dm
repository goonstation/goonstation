/**
 * This file is intended to hold all data pertaining to keybind_style datums and related functionality
 *
 * To add a new keybind:
 *	Add it in the right keybind_style below.
 *	Then, you need to update action_names to allow the menu to translate into human-readable format.
 *	Depending on what you're adding, you might need to update action_verbs as well.
 */

///Global list holding all of the keybind style datums
var/global/list/datum/keybind_style/keybind_styles = null

//The data you get from get_keybind... will be merged with existing keybind datum on the client in layers
//base -> base_wasd -> human -> human_arrow for example
//If you switch to a different mobtype, such as a robot, you would reset the keymap, and successive calls of build_keymap will apply_keybind
//A more optimized solution would be to rebuild only what is needed, but you can code that.

///List on each client containing the styles we've applied so we don't double-apply.
/client/var/list/applied_keybind_styles = list()


/** get_keybind_style_datum: Given the string name of a style, finds the keybind_style with the matching name.
 *	Internal use only.
 *	Called by apply_keybind to fetch our datum.
 */
/client/proc/get_keybind_style_datum(style_name)
	PROTECTED_PROC(TRUE)

	if (!keybind_styles)
		keybind_styles = new
		keybind_styles.Add(/datum/keybind_style) //So the base is at the top, and not the bottom.
		keybind_styles.Add(childrentypesof(/datum/keybind_style))

	for (var/datum/keybind_style/found_style as anything in keybind_styles)
		if (initial(found_style.name) == style_name)
			return found_style
	logTheThing(LOG_DEBUG, null, "<B>ZeWaka/Keybinds:</B> No keybind style found with the name [style_name].")

/** apply_keys: Takes a keybind_style to apply to the src client
 *	Internal use only.
 *	Merges the given keybind_style onto the client. Also adds it to the client's tracking list.
 */
/client/proc/apply_keys(datum/keybind_style/style)
	PROTECTED_PROC(TRUE)

	if (initial(style.name) in applied_keybind_styles)
		logTheThing(LOG_DEBUG, null, "<B>ZeWaka/Keybinds:</B> Attempted to apply [initial(style.name)] to [src] when already present.")
		return
	src.applied_keybind_styles.Add(initial(style.name))
	var/datum/keybind_style/init_style = new style //Can't do static referencing for merge, press F to pay respekts
	var/datum/keymap/init_keymap = new /datum/keymap(init_style.changed_keys)
	src.keymap.merge(init_keymap)
	src.keymap.on_update(src)

/** apply_keybind: Takes a given string style, and finds the datum, then applies it.
 *	External use only.
 *	This is what external stuff should be calling when applying their additive styles.
 */
/client/proc/apply_keybind(style_str)
	apply_keys(get_keybind_style_datum(style_str))



// Keybinds are sub-sorted in order of most common, since then it'll be further up the global list of styles. Micro-optimizations whoo!
// Currently: base -> arrow -> tg -> azerty

//
//	BASE MOB KEYBINDS
//

/datum/keybind_style
	var/name = "base"
	var/changed_keys = list(
	"W" = KEY_FORWARD,
	"A" = KEY_LEFT,
	"S" = KEY_BACKWARD,
	"D" = KEY_RIGHT,
	"NORTH" = KEY_FORWARD,
	"SOUTH" = KEY_BACKWARD,
	"WEST" = KEY_LEFT,
	"EAST" = KEY_RIGHT,
	"B" = KEY_POINT,
	"T" = "say",
	";" = "say_main_radio",
	"Y" = "say_radio",
	"ALT+W" = "whisper",
	"O" = "ooc",
	"ALT+L" = "looc",
	"ALT+T" = "dsay",
	"CTRL+T" = "asay",
	"Z" = "resist",
	"F" = "fart",
	"R" = "flip",
	"CTRL+A" = "salute",
	"CTRL+B" = "burp",
	"CTRL+D" = "dance",
	"CTRL+E" = "eyebrow",
	"CTRL+F" = "fart",
	"CTRL+G" = "gasp",
	"CTRL+H" = "raisehand",
	"CTRL+L" = "laugh",
	"CTRL+N" = "nod",
	"CTRL+Q" = "wave",
	"CTRL+R" = "flip",
	"CTRL+I" = "twirl",
	"CTRL+S" = "scream",
	"CTRL+W" = "wink",
	"CTRL+X" = "flex",
	"CTRL+Y" = "yawn",
	"CTRL+Z" = "snap",
	"M" = "emote",
	"I" = "look_n",
	"K" = "look_s",
	"J" = "look_w",
	"L" = "look_e",
	"P" = "pickup",
	"F1" = "adminhelp",
	"F3" = "mentorhelp",
	"CTRL+P" = "togglepoint",
	"F2" = "autoscreenshot",
	"SHIFT+F2" = "screenshot",
	"G" = "refocus",
	"ESCAPE" = "mainfocus",
	"RETURN" = "mainfocus",
	"`" = "admin_interact",
	"~" = "admin_interact"
	)

/datum/keybind_style/tg
	name = "base_tg"
	changed_keys = list(
		"DELETE" = "stop_pull"
	)

/datum/keybind_style/azerty
	name = "base_azerty"
	changed_keys = list(
		"Z" = KEY_FORWARD,
		"S" = KEY_BACKWARD,
		"Q" = KEY_LEFT,
		"D" = KEY_RIGHT,
		"W" = "resist"
	)

//
//	HUMAN-SPECIFIC KEYBINDS
//

/datum/keybind_style/human
	name = "human"
	changed_keys = list(
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
		"Q" = "drop",
		"E" = "swaphand",
		"C" = "attackself",
		"DELETE" = "togglethrow"
	)

/datum/keybind_style/human/arrow
	name = "human_arrow"
	changed_keys = list(
		"NORTHEAST" = "swaphand",
		"SOUTHEAST" = "attackself",
		"NORTHWEST" = "drop",
		"SOUTHWEST" = "togglethrow"
	)

/datum/keybind_style/human/tg
	name = "human_tg"
	changed_keys = list(
	"SPACE" = KEY_RUN,
	"SHIFT" = KEY_EXAMINE,
	"R" = KEY_THROW,
	"E" = "equip",
	"X" = "swaphand",
	"Z" = "attackself",
	"Q" = "drop",
	"C" = "resist"
	)

/datum/keybind_style/human/tg/azerty
	name = "human_tg_azerty"
	changed_keys = list(
		"W" = "attackself"
	)

/datum/keybind_style/human/azerty
	name = "human_azerty"
	changed_keys = list(
		"&" = "help",
		"é" = "disarm",
		"\"" = "grab",
		"'" = "harm",
		"(" = "head",
		"-" = "chest",
		"è" = "l_arm",
		"_" = "r_arm",
		"ç" = "l_leg",
		"à" = "r_leg",
		")" = "walk",
		"A" = "drop",
		"Q" = KEY_LEFT
	)

//
//	ROBOT-SPECIFIC KEYBINDS
//

/datum/keybind_style/robot
	name = "robot"
	changed_keys = list(
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
	)

/datum/keybind_style/robot/arrow
	name = "robot_arrow"
	changed_keys = list(
		"NORTHEAST" = "swaphand",
		"SOUTHEAST" = "attackself",
		"NORTHWEST" = "unequip"
	)

/datum/keybind_style/robot/tg
	name = "robot_tg"
	changed_keys = list(
		"CTRL" = KEY_BOLT,
		"SHIFT" = KEY_OPEN,
		"ALT" = KEY_SHOCK,
		"SPACE" = KEY_EXAMINE,
		"X" = "swaphand",
		"Z" = "attackself",
	)

/datum/keybind_style/robot/tg/azerty
	name = "robot_tg_azerty"
	changed_keys = list(
		"W" = "attackself"
	)

/datum/keybind_style/robot/azerty
	name = "robot_azerty"
	changed_keys = list(
		"&" = "module1",
		"é" = "module2",
		"\"" = "module3",
		"'" = "module4",
		"A" = "unequip",
		"Q" = KEY_LEFT
	)

//
//	DRONE-SPECIFIC KEYBINDS
//

/datum/keybind_style/drone
	name = "drone"
	changed_keys = list(
		"B" = KEY_POINT,
		"C" = "attackself",
		"Q" = "unequip"
	)

/datum/keybind_style/drone/arrow
	name = "drone_arrow"
	changed_keys = list(
		"SOUTHEAST" = "attackself", /*PGDN*/
		"NORTHWEST" = "unequip" /*HOME*/
	)

/datum/keybind_style/drone/tg
	name = "drone_tg"
	changed_keys = list(
		"Z" = "attackself",
	)

/datum/keybind_style/drone/azerty
	name = "drone_azerty"
	changed_keys = list(
		"A" = "unequip",
		"Q" = KEY_LEFT
	)

//
//	MISC-SPECIFIC KEYBINDS
//

/datum/keybind_style/instrument_keyboard
	name = "instrument_keyboard"
	changed_keys = list(
		"1" = "",
		"2" = "",
		"3" = "",
		"4" = "",
		"5" = "",
		"6" = "",
		"7" = "",
		"8" = "",
		"9" = "",
		"0" = "",
		"Q" = "",
		"W" = "",
		"E" = "",
		"R" = "",
		"T" = "",
		"Y" = "",
		"U" = "",
		"O" = "",
		"P" = "",
		"A" = "",
		"S" = "",
		"D" = "",
		"F" = "",
		"G" = "",
		"H" = "",
		"J" = "",
		"K" = "",
		"L" = "",
		"Z" = "",
		"X" = "",
		"C" = "",
		"V" = "",
		"B" = "",
		"N" = "",
		"M" = "",
	)

/datum/keybind_style/pod
	name = "pod"
	changed_keys = list(
		"SPACE" = KEY_SHOCK
	)

/datum/keybind_style/torpedo
	name = "torpedo"
	changed_keys = list(
		"SPACE" = "fire",
		"E" = "exit",
		"Q" = "exit"
	)

/datum/keybind_style/col_putt
	name = "colputt"
	changed_keys = list(
		"SPACE" = "fire",
		"Q" = "stop",
		"E" = "alt_fire"
	)

/datum/keybind_style/col_putt/arrow
	name = "colputt_arrow"
	changed_keys = list(
		"SOUTHEAST" = "fire", /*PGDN*/
		"NORTHWEST" = "stop", /*HOME*/
		"NORTHEAST" = "alt_fire" /*PGUP*/
	)

/datum/keybind_style/exit
	name = "just exit"
	changed_keys = list(
		"Q" = "exit",
		"E" = "exit"
	)

/datum/keybind_style/artillery
	name = "art"
	changed_keys = list(
		"SPACE" = "fire",
		"Q" = "cycle"
	)
