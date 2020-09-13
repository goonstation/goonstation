/**
 * tgui state: silicon_state
 *
 * Checks that the user is an AI/borg.
 */
var/global/datum/ui_state/tgui_silicon_state/tgui_silicon_state = new /datum/ui_state/tgui_silicon_state

/datum/ui_state/tgui_silicon_state/can_use_topic(src_object, mob/user)
	return user.silicon_can_use_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/silicon_can_use_topic(src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/silicon_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc)
		. = min(., loc.contents_ui_distance(src_object, src)) // Check the distance...

/mob/living/silicon/robot/silicon_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything they can see.
	if(get_dist(src, src_object) <= SQUARE_TILE_WIDTH / 2)
		return UI_INTERACTIVE

	// AI Borgs can recieve updates from anything that the AI can see.
	if (src.connected_ai)
		return UI_UPDATE

	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/hivebot/eyebot/silicon_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything they can see.
	if(get_dist(src, src_object) <= (SQUARE_TILE_WIDTH / 2))
		return UI_INTERACTIVE

	return UI_UPDATE // AI eyebots can recieve updates from anything that the AI can see.

/mob/dead/aieye/silicon_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see.
	return UI_INTERACTIVE

/mob/living/silicon/ai/silicon_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see.
	return UI_INTERACTIVE
