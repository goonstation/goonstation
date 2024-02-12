/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans and view for robots.
 */
var/global/datum/ui_state/tgui_default_state/tgui_default_state = new /datum/ui_state/tgui_default_state

/datum/ui_state/tgui_default_state/can_use_topic(src_object, mob/user)
	return user.default_can_use_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/default_can_use_topic(src_object)
	return UI_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_topic(obj/src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE && loc)
		. = min(., loc.contents_ui_distance(src_object, src)) // Check the distance...
	if(. == UI_INTERACTIVE) // Non-human living mobs can only look, not touch.
		// Permit ghost drone access to ghost critter permitted UIs
		if (!(isghostdrone(src) && !HAS_FLAG(src_object.object_flags, NO_GHOSTCRITTER)))
			return UI_UPDATE

/mob/living/carbon/human/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) // Check the distance...

/mob/living/silicon/robot/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything on the z-level
	if(get_z(src_object) == get_z(src))
		return UI_INTERACTIVE

	return UI_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/hivebot/eyebot/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. <= UI_DISABLED)
		return

	// Robots can interact with anything on the z-level
	if(get_z(src_object) == get_z(src))
		return UI_INTERACTIVE

	return UI_UPDATE // AI eyebots can receive updates from anything that the AI can see.

/mob/living/intangible/aieye/default_can_use_topic(obj/src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	if((src.mainframe.z == src_object.z) || (inunrestrictedz(src_object) && inonstationz(mainframe)))
		return UI_INTERACTIVE
	else
		return UI_UPDATE

	// The AI can interact with anything it can see.

/mob/living/silicon/ai/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. < UI_INTERACTIVE)
		return

	// The AI can interact with anything it can see.
	return UI_INTERACTIVE

/mob/living/critter/default_can_use_topic(src_object)
	. = shared_ui_interaction(src_object)
	if(. > UI_CLOSE)
		. = min(., shared_living_ui_distance(src_object)) //critters can only use things they're near.

/mob/dead/target_observer/default_can_use_topic(src_object)
	. = ..()
	return UI_UPDATE
