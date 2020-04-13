/*
 * This file is intended to hold the following keybind-related data:
 * datum/keybind_style - Preset keybinding data for players to use as a template.
 * list/keybind_styles - Global list holding all of these for access
 */

//Global list holding all of the keybind style datums
var/global/list/datum/keybind_style/keybind_styles = null
//TODO: Set this to be typesof() somewhere early in init

//The data you get from get_keybind... will be merged with existing keybind datum on the client in layers
//base -> base_wasd -> human -> human_wasd for example
//If you switch to a different mobtype, such as a robot,
//You would subtract the human_base and human_wasd and apply robot_base and robot_wasd(last one is fictional)


///List on each client containing the styles we've applied so we don't double-apply.
/client/var/list/applied_keybind_styles = list()


/** get_keybind_style_datum: Given the string name of a style, finds the keybind_style with the matching name.
 *
 *	Called by apply_keybind to fetch our datum.
 */
/client/proc/get_keybind_style_datum(var/style_name)

	if (!keybind_styles)
		keybind_styles = childrentypesof(/datum/keybind_style/)

	for (var/datum/keybind_style/s in keybind_styles)
		if (s.name == "[style_name]")
			return s


/** apply_keys: Takes a keybind_style to apply to the src client
 *
 *	Merges the given keybind_style onto the client. Also adds it to the client's tracking list.
 */
/client/proc/apply_keys(var/datum/keybind_style/S)
	if (applied_keybind_styles.Find("[S.name]")) //Already added
		logTheThing("debug", null, null, "<B>ZeWaka/Keybinds:</B> Attempted to add [S.name] to [src] when already present.")
		return
	applied_keybind_styles.Add(S.name)
	keymap.merge(S.changed_keys)


//Applies a given style onto the client after getting the datum
/** apply_keybind: Takes a given string style, and finds the datum, then applies it.
 *
 *	This is what external stuff should be calling when applying their additive styles.
 */
/client/proc/apply_keybind(var/style)
	apply_keys(get_keybind_style_datum(style))



//Dummy used to find old code - What should be done is successive calls of apply_keybind(name) going down the tree of mob/human/monkey/wasd etc.
/client/proc/get_default_keymap(name)
	message_admins("OLD CALLER BAD BAD BAD: [name]")
	return


///
///	BASE MOB KEYBINDS
///

/datum/keybind_style
	var/name = "base"
	var/changed_keys = list(
	"W" = KEY_FORWARD,
	"A" = KEY_BACKWARD,
	"S" = KEY_LEFT,
	"D" = KEY_RIGHT,
	"B" = KEY_POINT,
	"T" = "say",
	"Y" = "say_radio",
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
	"P" = "pickup"
	)

/datum/keybind_style/azerty
	name = "base_azerty"
	changed_keys = list(
		"Z" = KEY_FORWARD,
		"S" = KEY_BACKWARD,
		"Q" = KEY_LEFT,
		"D" = KEY_RIGHT
	)

/datum/keybind_style/tg
	name = "base_tg"
	changed_keys = list(
		"DELETE" = "stop_pull"
	)

/datum/keybind_style/arrow
	name = "base_arrow"
	changed_keys = list(
		"NORTH" = KEY_FORWARD,
		"SOUTH" = KEY_BACKWARD,
		"WEST" = KEY_LEFT,
		"EAST" = KEY_RIGHT,
	)

/datum/keybind_style/wasd
	name = "base_wasd"
	changed_keys = list(
		"W" = KEY_FORWARD,
		"S" = KEY_BACKWARD,
		"A" = KEY_LEFT,
		"D" = KEY_RIGHT
	)


///
///	HUMAN-SPECIFIC KEYBINDS
///

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
		"E" = "swaphand",
		"C" = "attackself",
		"Q" = "drop",
		"DELETE" = "togglethrow"
	)

/datum/keybind_style/human/azerty
	name = "human_azerty"
	changed_keys = list(
		"A" = "drop"
	)

/datum/keybind_style/human/wasd
	name = "human_wasd"
	changed_keys = list(
		"Q" = "drop"
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
	"Q" = "drop"
	)


///
///	ROBOT-SPECIFIC KEYBINDS
///

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

/datum/keybind_style/robot/azerty
	name = "human_azerty"
	changed_keys = list(
		"A" = "unequip"
	)

/datum/keybind_style/robot/arrow
	name = "human_arrow"
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

///
///	DRONE-SPECIFIC KEYBINDS
///

/datum/keybind_style/drone
	name = "drone"
	changed_keys = list(
		"B" = KEY_POINT,
		"C" = "attackself",
		"Q" = "unequip"
	)

/datum/keybind_style/drone/azerty
	name = "drone_azerty"
	changed_keys = list(
		"A" = "unequip"
	)

/datum/keybind_style/drone/tg
	name = "drone_tg"
	changed_keys = list(
		"Z" = "attackself",
	)

/datum/keybind_style/drone/arrow
	name = "drone_arrow"
	changed_keys = list(
		"SOUTHEAST" = "attackself", /*PGDN*/
		"NORTHWEST" = "unequip" /*HOME*/
	)

///
///	MISC-SPECIFIC KEYBINDS
///

/datum/keybind_style/pod
	name = "pod"
	changed_keys = list(
		"SPACE" = "fire"
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

/datum/keybind_style/artillery
	name = "art"
	changed_keys = list(
		"SPACE" = "fire",
		"Q" = "cycle"
	)

/datum/keybind_style/torpedo
	name = "torp"
	changed_keys = list(
		"SPACE" = "fire",
		"E" = "exit",
		"Q" = "exit"
	)
