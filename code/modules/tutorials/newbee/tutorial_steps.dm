//
// room 1 - Arrivals / Movement
//

/datum/tutorialStep/newbee/timer/welcome
	name = "Welcome to Space Station 13!"
	instructions = "This tutorial covers basic game controls and concepts.<br>The top-left buttons let you exit, go back a step, or skip a step."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY
	step_area = /area/tutorial/newbee/room_1

/datum/tutorialStep/newbee/timer/custom_controls
	name = "Customizing Controls"
	instructions = "Customize kebyinds via the top-most menu bar under Game > Interface > Modify Keybinds.<br>Options for TG-style controls or HUD are in the same menu."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY
	step_area = /area/tutorial/newbee/room_1

/datum/tutorialStep/newbee/move_to/basic_movement
	name = "Basic Movement"
	instructions = "Use <b>W</b>/<b>A</b>/<b>S</b>/<b>D</b> to move your character.<br>Walk to the marker to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_1

	update_instructions()
		var/up = src.keymap.action_to_keybind(KEY_FORWARD)
		var/left = src.keymap.action_to_keybind(KEY_LEFT)
		var/down = src.keymap.action_to_keybind(KEY_BACKWARD)
		var/right = src.keymap.action_to_keybind(KEY_RIGHT)
		src.instructions = "Use <b>[up]</b>/<b>[left]</b>/<b>[down]</b>/<b>[right]</b> to move your character.<br>Walk to the marker to continue."
		..()

/datum/tutorialStep/newbee/move_to/powered_doors
	name = "Powered Doors"
	instructions = "Powered doors will open when you walk into them.<br>Head through the doorway into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_1
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 2 - ID-locked Doors
//

/datum/tutorialStep/newbee/item_pickup/id_card
	name = "Picking Up Items"
	instructions = "You can <b>click</b> on items to pick them up.<br><b>Click</b> the ID card to pick it up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	item_path = /obj/item/card/id/engineering/tutorial
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_2

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/card/id/engineering/tutorial))
			var/obj/item/card/id/engineering/tutorial/tutorial_card = src._target_item
			tutorial_card.registered = src.newbee_tutorial.newbee.name
			tutorial_card.assignment = "Engineer"
			tutorial_card.update_name()

/datum/tutorialStep/newbee/wear_id_card
	name = "Worn Items"
	instructions = "Some items can be worn. Press <b>V</b> to wear the ID card, or <b>click</b> the ID card slot in your HUD."
	highlight_hud_element = "id"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/card/id/engineering/tutorial
	step_area = /area/tutorial/newbee/room_2

	update_instructions()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Some items can be worn.<br>Press <b>[equip]</b> to wear the ID card, or <b>click</b> the ID card slot in your HUD."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "id_card")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "id_card")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/move_to/id_locked_doors
	name = "ID-Locked Doors"
	instructions = "Some doors require a valid ID to open.<br>With your worn ID, you can head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/card/id/engineering/tutorial
	step_area = /area/tutorial/newbee/room_2
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS


	SetUp()
		. = ..()
		// setup the railings for the next room before we enter the room so they don't pop in
		var/obj/railing/guard/railing_s
		var/obj/railing/guard/railing_e
		var/obj/railing/guard/railing_w
		var/obj/machinery/disposal/tutorial/disposal_unit
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				disposal_unit = locate(/obj/machinery/disposal/tutorial) in T
				if (!disposal_unit || QDELETED(disposal_unit))
					disposal_unit = new(T)
				railing_s = new(T)
				railing_s.dir = SOUTH
				railing_e = new(T)
				railing_e.dir = EAST
				railing_w = new(T)
				railing_w.dir = WEST
				break


	TearDown()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				for (var/obj/railing/guard/fence in T)
					qdel(fence)
				break

//
// room 3 - Items & Unpowered Doors
//

/datum/tutorialStep/newbee/item_pickup/can
	name = "Pick Up That Can"
	instructions = "<b>Click</b> on the crushed can with an empty hand to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CAN
	item_path = /obj/item/canned_laughter/crushed
	step_area = /area/tutorial/newbee/room_3

	SetUp()
		. = ..()
		var/obj/railing/guard/railing_s
		var/obj/railing/guard/railing_e
		var/obj/railing/guard/railing_w
		var/obj/machinery/disposal/tutorial/disposal_unit
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				disposal_unit = locate(/obj/machinery/disposal/tutorial) in T
				if (!disposal_unit || QDELETED(disposal_unit))
					disposal_unit = new(T)
				railing_s = new(T)
				railing_s.dir = SOUTH
				railing_e = new(T)
				railing_e.dir = EAST
				railing_w = new(T)
				railing_w.dir = WEST
				break

	TearDown()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				for (var/obj/railing/guard/fence in T)
					qdel(fence)
				break

/datum/tutorialStep/newbee/can_throw
	name = "Put It In The Trash Can"
	instructions = "Throw items by holding <b>SPACE</b> or toggling throw mode with <b>DELETE</b>, then <b>clicking</b>.<br>Throw the crushed can into the disposals unit."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	step_area = /area/tutorial/newbee/room_3
	needed_item_path = /obj/item/canned_laughter/crushed
	highlight_hud_element = "throw"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF

	var/obj/machinery/disposal/tutorial/disposal_unit

	update_instructions()
		var/key_throw = src.keymap.action_to_keybind(KEY_THROW)
		var/toggle_throw = src.keymap.action_to_keybind("togglethrow")
		src.instructions = "Throw items by holding <b>[key_throw]</b> or toggling throw mode with <b>[toggle_throw]</b>, then <b>clicking</b>.<br>Throw the crushed can into the disposals unit."
		..()

	SetUp()
		. = ..()
		var/obj/railing/guard/railing_s
		var/obj/railing/guard/railing_e
		var/obj/railing/guard/railing_w

		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				src.disposal_unit = locate(/obj/machinery/disposal/tutorial) in T
				if (!src.disposal_unit || QDELETED(src.disposal_unit))
					src.disposal_unit = new(T)
				railing_s = new(T)
				railing_s.dir = SOUTH
				railing_e = new(T)
				railing_e.dir = EAST
				railing_w = new(T)
				railing_w.dir = WEST
				break
		src.disposal_unit.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "throw_item" && istype(context, /obj/item/canned_laughter/crushed))
			src.finished = TRUE

	TearDown()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				for (var/obj/railing/guard/fence in T)
					qdel(fence)
				break
		if (src.disposal_unit && !QDELETED(src.disposal_unit))
			src.disposal_unit.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/flush_disposals
	name = "Object Interation"
	instructions = "With an empty hand, <b>Click</b> the disposals unit to open up its UI.<br>Then, <b>click</b> the Flush button to dispose of the can."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	step_area = /area/tutorial/newbee/room_3

	var/obj/machinery/disposal/tutorial/disposal_unit

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CAN_THROW])
			if(src.region.turf_in_region(T))
				src.disposal_unit = locate(/obj/machinery/disposal/tutorial) in T
				if (!src.disposal_unit || QDELETED(src.disposal_unit))
					src.disposal_unit = new(T)
		src.disposal_unit.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "flush" && context == "disposals")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.disposal_unit && !QDELETED(src.disposal_unit))
			src.disposal_unit.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/item_pickup/crowbar
	name = "Usable Items"
	instructions = "Some items can interact with the world.<br><b>Click</b> the crowbar to pick it up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	item_path = /obj/item/crowbar
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_3

/datum/tutorialStep/newbee/open_unpowered_door
	name = "Unpowered Doors"
	instructions = "Unpowered doors can be opened with crowbars.<br><b>Click</b> the door with the crowbar, and head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/crowbar
	step_area = /area/tutorial/newbee/room_3

	var/obj/machinery/door/airlock/pyro/classic/tutorial/tutorial_door

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS])
			if(src.region.turf_in_region(T))
				src.tutorial_door = locate(/obj/machinery/door/airlock/pyro/classic/tutorial) in T
				if (!src.tutorial_door || QDELETED(src.tutorial_door))
					src.tutorial_door = new(T)
					src.tutorial_door.dir = EAST
		src.tutorial_door.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "door" && context == "manual_open")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.tutorial_door.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/exit_items
	name = "Intents"
	instructions = "The next room will teach you about the four intents:<br>Help, Disarm, Grab, and Harm."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_3
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	update_instructions()
		src.instructions = "The next room will teach you about the four intents:<br>[TEXT_INTENT_HELP], [TEXT_INTENT_DISARM], [TEXT_INTENT_GRAB], and [TEXT_INTENT_HARM]."
		..()

//
// room 4 - Intents & Combat
//

/datum/tutorialStep/newbee/drop_item
	name = "Dropping Items"
	instructions = "You'll need to free your hands up for the next lesson.<br>Drop the crowbar in your active hand by pressing <b>Q</b> or <b>clicking</b> the Drop Item HUD button."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "throw"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF
	needed_item_path = /obj/item/crowbar
	step_area = /area/tutorial/newbee/room_4

	update_instructions()
		var/drop = src.keymap.action_to_keybind("drop")
		src.instructions = "You'll need to free your hands up for the next lesson.<br>Drop the crowbar in your active hand by pressing <b>[drop]</b> or <b>clicking</b> the Drop Item HUD button."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_DROPPED, PROC_REF(check_item_dropped))

	proc/check_item_dropped(item, mob/user)
		src.tutorial.PerformAction("item_dropped", "held_item")

	PerformAction(action, context)
		. = ..()
		if (action == "item_dropped" && context == "held_item")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_DROPPED)

/datum/tutorialStep/newbee/intent_help
	name = "Help Intent"
	instructions = "The Help intent will help people up, or give critical people CPR.<br>Press <b>1</b> to switch to the Help intent."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HELP
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	update_instructions()
		var/help = src.keymap.action_to_keybind("help")
		src.instructions = "The [TEXT_INTENT_HELP] intent will help people up, or give critical people CPR.<br>Press <b>[help]</b> to switch to the [TEXT_INTENT_HELP] intent."
		..()

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_HELP || src.newbee_tutorial.newbee.intent == null)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_HARM)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HELP)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HELP)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/datum/tutorialStep/newbee/help_person
	name = "Helping People"
	instructions = "Stand next to the clown and <b>click</b> them while on Help intent.<br>Help the clown stand up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_help/target_mob

	update_instructions()
		src.instructions = "Stand next to the clown and <b>click</b> them while on [TEXT_INTENT_HELP] intent.<br>Help the clown stand up."
		..()

	SetUp()
		. = ..()

		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_HELP_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.setStatus("resting", INFINITE_STATUS)
		src.target_mob.force_laydown_standup()
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_mob, COMSIG_MOB_LAYDOWN_STANDUP, PROC_REF(check_mob_laydown_standup), TRUE)

	proc/check_mob_laydown_standup(source, lying)
		if (!lying)
			src.tutorial.PerformSilentAction("mob_standup", source)

	PerformAction(action, context)
		. = ..()
		if (action == "mob_standup" && context == src.target_mob)
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_LAYDOWN_STANDUP)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/intent_disarm
	name = "Disarm Intent"
	instructions = "The Disarm intent will knock items out of someone's hands or push them to the ground.<br>Press <b>2</b> to switch to the Disarm intent."
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_DISARM
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	update_instructions()
		var/disarm = src.keymap.action_to_keybind("disarm")
		src.instructions = "The [TEXT_INTENT_DISARM] intent will knock items out of someone's hands or push them to the ground.<br>Press <b>[disarm]</b> to switch to the [TEXT_INTENT_DISARM] intent."
		..()

	SetUp()
		. = ..()

		if (src.newbee_tutorial.newbee.intent == INTENT_DISARM)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_HELP)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_DISARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_DISARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/datum/tutorialStep/newbee/disarm_person
	name = "Disarming People"
	instructions = "Stand next to the clown and <b>click</b> them while on Disarm intent.<br>Knock the bike horn out of the clown's hands - it may take a few tries!"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_disarm/target_mob
	var/obj/item/target_item_left

	update_instructions()
		src.instructions = "Stand next to the clown and <b>click</b> them while on [TEXT_INTENT_DISARM] intent.<br>Knock the bike horn out of the clown's hands - it may take a few tries!"
		..()

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DISARM_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		src.target_item_left = src.target_mob.l_hand
		RegisterSignal(src.target_item_left, COMSIG_ITEM_DROPPED, PROC_REF(check_item_dropped))

	proc/check_item_dropped()
		src.tutorial.PerformAction("item_dropped", "disarm_clown")

	PerformAction(action, context)
		. = ..()
		if (action == "item_dropped" && context == "disarm_clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_ITEM_DROPPED)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/intent_grab
	name = "Grab Intent"
	instructions = "The Grab intent will grab someone.<br>Press <b>3</b> to switch to the Grab intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_GRAB
	step_area = /area/tutorial/newbee/room_4

	update_instructions()
		var/grab = src.keymap.action_to_keybind("grab")
		src.instructions = "The [TEXT_INTENT_GRAB] intent will grab someone.<br>Press <b>[grab]</b> to switch to the [TEXT_INTENT_GRAB] intent."
		..()

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_GRAB)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_DISARM)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_GRAB)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_GRAB)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/datum/tutorialStep/newbee/grab_person
	name = "Grabbing People"
	instructions = "Stand next to the clown and <b>click</b> them while on Grab intent.<br> <b>Click</b> them again or press <b>C</b> to get the clown in an aggressive grab."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/carbon/human/normal/tutorial_grab/target_mob

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Stand next to the clown and <b>click</b> them while on [TEXT_INTENT_GRAB] intent.<br><b>Click</b> them again or press <b>[attackself]</b> to get the clown in an aggressive grab."
		..()

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_GRAB_PERSON])
			if(src.region.turf_in_region(T))
				if (src.target_mob)
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		src.target_mob.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_mob, COMSIG_MOB_GRABBED, PROC_REF(check_mob_grabbed))

	proc/check_mob_grabbed(source, obj/item/grab/grab)
		if (grab.state >= GRAB_AGGRESSIVE)
			src.tutorial.PerformAction("mob_grabbed", "grab_clown")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_grabbed" && context == "grab_clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_GRABBED)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/intent_harm
	name = "Harm Intent"
	instructions = "The Harm intent will attack people by punching them or hitting them with items.<br>Press <b>4</b> to switch to the Harm intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "intent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INTENT_HARM
	step_area = /area/tutorial/newbee/room_4

	update_instructions()
		var/harm = src.keymap.action_to_keybind("harm")
		src.instructions = "The [TEXT_INTENT_HARM] intent will attack people by punching them or hitting them with items.<br>Press <b>[harm]</b> to switch to the [TEXT_INTENT_HARM] intent."
		..()

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.intent == INTENT_HARM)
			src.newbee_tutorial.newbee.set_a_intent(INTENT_GRAB)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_SET_A_INTENT)

/datum/tutorialStep/newbee/basic_combat
	name = "Basic Combat"
	instructions = "Oh no! Attack of the angry mouse!<br>Defeat the mouse by <b>clicking</b> on them while using the Harm intent."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_4

	var/mob/living/critter/small_animal/mouse/mad/target_mob

	update_instructions()
		src.instructions = "Oh no! Attack of the angry mouse!<br>Defeat the mouse by <b>clicking</b> on them while using the [TEXT_INTENT_HARM] intent."
		..()

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_MOUSE])
			if(src.region.turf_in_region(T))
				if (src.target_mob && isalive(src.target_mob))
					src.target_mob.set_loc(T)
				else
					src.target_mob = new(T)
				break
		// make it look like an admin mouse
		src.target_mob.icon_state = "mouse-admin"
		src.target_mob.icon_state_dead = "mouse-admin-dead"
		src.target_mob.use_custom_color = FALSE
		src.target_mob.ClearAllOverlays()
		src.target_mob.dir = WEST

		RegisterSignal(src.target_mob, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))
		src.target_mob.UpdateOverlays(src.point_marker, "marker")

		SPAWN (0.5 SECONDS)
			// squeak!
			if (src.target_mob && !QDELETED(src.target_mob))
				playsound(src.target_mob, 'sound/voice/animal/mouse_squeak.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)

	proc/check_mob_death()
		if (isdead(src.target_mob))
			src.tutorial.PerformAction("mob_death", "mouse")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_death" && context == "mouse")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (!src.target_mob)
			return
		src.target_mob.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_mob, COMSIG_MOB_DEATH)
		var/mob/M = src.target_mob
		src.target_mob = null
		SPAWN(4 SECONDS)
			animate_teleport(M)
			showswirl_out(M)
			if (length(M.grabbed_by))
				for(var/obj/item/grab/G in M.grabbed_by)
					qdel(G)
			SPAWN (1.5 SECONDS)
				if (M)
					qdel(M)

/datum/tutorialStep/newbee/resisting
	name = "Resisting"
	instructions = "That mouse was a protected species! You've been handcuffed for your horrible crime...<br>Resisting will block attacks, stop grabs, and start removing handcuffs.<br>Press <b>Z</b> or <b>click</b> the Resist HUD button and stand still to break free."
	step_area = /area/tutorial/newbee/room_4
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "resist"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF

	var/obj/item/handcuffs/guardbot/target_handcuffs

	update_instructions()
		var/resist = src.keymap.action_to_keybind("resist")
		src.instructions = "That mouse was a protected species! You've been handcuffed for your horrible crime...<br>Resisting will block attacks, stop grabs, and start removing handcuffs.<br>Press <b>[resist]</b> or <b>click</b> the Resist HUD button and stand still to break free."
		. = ..()

	SetUp(manually_selected)
		. = ..()
		if(!src.target_handcuffs || QDELETED(src.target_handcuffs))
			src.target_handcuffs = new /obj/item/handcuffs/guardbot
		src.target_handcuffs.cuff(src.newbee_tutorial.newbee)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_RESIST, PROC_REF(check_handcuffs))

	proc/check_handcuffs(mob/living/parent)
		if (src.newbee_tutorial.newbee.hasStatus("handcuffed"))
			SPAWN (0.5 SECONDS)
				src.check_handcuffs(parent)
		else
			src.newbee_tutorial.PerformSilentAction("break_handcuffs")

	PerformAction(action, context)
		. = ..()
		if (action == "break_handcuffs")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.target_handcuffs = null
		if (src.newbee_tutorial.newbee.hasStatus("handcuffed"))
			src.newbee_tutorial.newbee.handcuffs.destroy_handcuffs(src.newbee_tutorial.newbee)
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_RESIST)


/datum/tutorialStep/newbee/move_to/exit_intents
	name = "Healing Up"
	instructions = "Your health is displayed in the top-right corner - you've taken some damage!<br>Head into the next room to patch yourself up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_4
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_INTENTS

	SetUp()
		. = ..()
		if (src.newbee_tutorial.newbee.bruteloss < 5)
			src.newbee_tutorial.newbee.TakeDamage("All", 5)

//
// room 5 - Healing
//

/datum/tutorialStep/newbee/move_to/damage_types
	name = "Damage Types"
	instructions = "Your total health is the sum of four damage types: Brute, Burn, Toxin, and Oxygen.<br>Floor health scanners will display how much damage you've taken in each category."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_HEALTH
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_CHECK_HEALTH
	step_area = /area/tutorial/newbee/room_5

	update_instructions()
		src.instructions = "Your total health is the sum of four damage types: [TEXT_HEALTH_BRUTE], [TEXT_HEALTH_BURN], [TEXT_HEALTH_TOXIN], and [TEXT_HEALTH_OXY].<br>Floor health scanners will display how much damage you've taken in each category."
		..()

/datum/tutorialStep/newbee/item_pickup/brute_first_aid
	name = "First Aid Kits"
	instructions = "You can heal yourself by using supplies from first aid kits.<br><b>Click</b> the first aid kit to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_HEALTH
	step_area = /area/tutorial/newbee/room_5

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BRUTE_FIRST_AID
	item_path = /obj/item/storage/firstaid/brute/tutorial

	SetUp()
		. = ..()
		var/patch_count = 0
		for (var/obj/item/reagent_containers/patch/mini/bruise/patch in src._target_item.contents)
			patch_count++
		if (patch_count < 1)
			src._target_item.storage.add_contents(new /obj/item/reagent_containers/patch/mini/bruise)

/datum/tutorialStep/newbee/storage_inhands
	name = "Opening Storage"
	instructions = "With the first aid kit in-hand, press <b>C</b> to open it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/storage/firstaid/brute/tutorial
	step_area = /area/tutorial/newbee/room_5

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "With the first aid kit in-hand, press <b>[attackself]</b> to open it."
		..()

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "brute_first_aid")
			src.finished = TRUE

/datum/tutorialStep/newbee/hand_swap
	name = "Swapping Hands"
	instructions = "Only one hand can be active at a time. You need an empty hand to take items from storage.<br>Press <b>E</b> to swap hands."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/storage/firstaid/brute/tutorial
	step_area = /area/tutorial/newbee/room_5

	update_instructions()
		var/swaphand = src.keymap.action_to_keybind("swaphand")
		src.instructions = "Only one hand can be active at a time. You need an empty hand to take items from storage.<br>Press <b>[swaphand]</b> swap hands."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_SWAP_AWAY, PROC_REF(check_swap))

	proc/check_swap()
		src.tutorial.PerformAction("swapped-hands")

	PerformAction(action, context)
		. = ..()
		if (action == "swapped-hands")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_SWAP_AWAY)

/datum/tutorialStep/newbee/apply_brute_patch
	name = "Applying Patches"
	instructions = "Grab a brute patch out of the brute first aid kit, and apply it by <b>clicking</b> yourself.<br>You can also press <b>C</b> to self-apply the patch."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_5
	needed_item_path = /obj/item/storage/firstaid/brute/tutorial

	var/obj/item/reagent_containers/patch/mini/bruise/patch_to_apply

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Grab a [TEXT_HEALTH_BRUTE] patch out of the brute first aid kit, and apply it by <b>clicking</b> yourself.<br>You can also press <b>[attackself]</b> to self-apply the patch."
		..()

	SetUp()
		. = ..()
		var/patch_count = 0
		for (var/obj/item/reagent_containers/patch/mini/bruise/patch in src._needed_item.contents)
			src.patch_to_apply = patch
			patch_count++
		if (patch_count < 1)
			src.patch_to_apply = new /obj/item/reagent_containers/patch/mini/bruise
			src._needed_item.storage.add_contents(src.patch_to_apply)

		src.patch_to_apply.UpdateOverlays(src.point_marker, "marker")
		var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, src.patch_to_apply.screen_loc)
		hud_point_loop(src.newbee_tutorial.current_step, hud_x_y_offset[1] + 16, hud_x_y_offset[2] + 30)

		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY, PROC_REF(check_attackby))

	proc/check_attackby(source, obj/item/I, mob/user, params, is_special)
		if (istype(I, /obj/item/reagent_containers/patch/mini/bruise))
			src.tutorial.PerformAction("attackby", "bruise_patch")

	PerformAction(action, context)
		. = ..()
		if (action == "attackby" && context == "bruise_patch")
			src.finished = TRUE

	TearDown()
		. = ..()
		patch_to_apply?.UpdateOverlays(null, "marker")
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY)

/datum/tutorialStep/newbee/on_fire
	name = "Putting Out Fire"
	instructions = "You've been set on fire - stop, drop, and roll to put it out!<br>Press <b>Z</b> or <b>=</b> to begin rolling on the floor.<br>"
	step_area = /area/tutorial/newbee/room_5
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS

	update_instructions()
		var/resist = src.keymap.action_to_keybind("resist")
		var/rest = src.keymap.action_to_keybind("rest")
		src.instructions = "You've been set on fire - stop, drop, and roll to put it out!<br>Press <b>[resist]</b> or <b>[rest]</b> to begin rolling on the floor."
		..()

	SetUp()
		. = ..()
		src.newbee_tutorial.newbee.set_burning(10)
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_RESIST, PROC_REF(check_fire))
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_LAYDOWN_STANDUP, PROC_REF(check_fire))

	proc/check_fire(mob/living/parent)
		if (parent.hasStatus("burning"))
			SPAWN (0.5 SECONDS)
				src.check_fire(parent)
		else
			src.newbee_tutorial.PerformSilentAction("fire_out")

	PerformAction(action, context)
		. = ..()
		if (action == "fire_out")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.newbee_tutorial.newbee.delStatus("burning")
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_RESIST)
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_LAYDOWN_STANDUP)

/datum/tutorialStep/newbee/standing_up
	name = "Standing Up"
	instructions = "Now that the fire is out, it's time to stand upright.<br>Press <b>=</b> or <b>click</b> the Stand/Rest button in the HUD to stand up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "rest"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF
	step_area = /area/tutorial/newbee/room_5

	update_instructions()
		var/rest = src.keymap.action_to_keybind("rest")
		src.instructions = "Now that the fire is out, it's time to stand upright.<br>Press <b>[rest]</b> or <b>click</b> the Stand/Rest button in the HUD to stand up."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_LAYDOWN_STANDUP, PROC_REF(check_mob_laydown_standup))

	proc/check_mob_laydown_standup(source, lying)
		if (!lying)
			src.tutorial.PerformSilentAction("mob_standup", source)

	PerformAction(action, context)
		. = ..()
		if (action == "mob_standup" && context == src.newbee_tutorial.newbee)
			src.finished = TRUE

	TearDown()
		. = ..()
		src.newbee_tutorial.newbee.delStatus("burning")
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_MOB_LAYDOWN_STANDUP)

/datum/tutorialStep/newbee/item_pickup/fire_first_aid
	name = "Fire First Aid"
	instructions = "Burn patches from fire first aid kits will heal burn damage.<br>"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "health"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_5

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRE_FIRST_AID
	item_path = /obj/item/storage/firstaid/fire/tutorial

	update_instructions()
		src.instructions = "[TEXT_HEALTH_BURN] patches in fire first aid kits will heal [TEXT_HEALTH_BURN] damage.<br>Pick up the fire first aid kit."
		..()

	SetUp()
		. = ..()
		var/patch_count = 0
		for (var/obj/item/reagent_containers/patch/mini/burn/patch in src._target_item.contents)
			patch_count++
		if (patch_count < 1)
			src._target_item.storage.add_contents(new /obj/item/reagent_containers/patch/mini/burn)

/datum/tutorialStep/newbee/apply_fire_patch
	name = "Applying Patches"
	instructions = "Just like brute patches, apply a burn patch from the first aid kit.<br>You can <b>click</b> yourself or press <b>C</b> with a patch in hand to self-apply the patch."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_5
	needed_item_path = /obj/item/storage/firstaid/fire/tutorial

	var/obj/item/reagent_containers/patch/mini/burn/patch_to_apply

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Just like [TEXT_HEALTH_BRUTE] patches, apply a [TEXT_HEALTH_BURN] patch from the first aid kit.<br>You can <b>click</b> yourself or press <b>[attackself]</b> with a patch in hand to self-apply the patch."
		..()

	SetUp()
		. = ..()
		var/patch_count = 0
		for (var/obj/item/reagent_containers/patch/mini/burn/patch in src._needed_item.contents)
			patch_count++
			src.patch_to_apply = patch
		if (patch_count < 1)
			src.patch_to_apply = new /obj/item/reagent_containers/patch/mini/burn
			src._needed_item.storage.add_contents(src.patch_to_apply)

		src.patch_to_apply.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY, PROC_REF(check_attackby))

	proc/check_attackby(source, obj/item/I, mob/user, params, is_special)
		if (istype(I, /obj/item/reagent_containers/patch/mini/burn))
			src.tutorial.PerformAction("attackby", "patch_burn")

	PerformAction(action, context)
		. = ..()
		if (action == "attackby" && context == "patch_burn")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.patch_to_apply?.UpdateOverlays(null, "marker")
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATTACKBY)

/datum/tutorialStep/newbee/move_to/exit_healing
	name = "All Better!"
	instructions = "Now that you're patched up, let's learn some deconstruction.<br>Head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALTH
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_HEALTH
	step_area = /area/tutorial/newbee/room_5
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 6 - Girder Deconstruction
//

/datum/tutorialStep/newbee/examining
	name = "Taking a Closer Look"
	instructions = "Holding <b>ALT</b> and <b>clicking</b> something shows more info in the right-side chat box.<br>Examine the girder to find out how to deconstruct it from the light-blue text in chat."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	step_area = /area/tutorial/newbee/room_6

	var/obj/structure/girder/target_girder

	update_instructions()
		var/examine = src.keymap.action_to_keybind(KEY_EXAMINE)
		src.instructions = "Holding <b>[examine]</b> and <b>clicking</b> something shows more info in the right-side chat box.<br>Examine the girder to find out how to deconstruct it from the light-blue text in chat."
		..()

	SetUp()
		. = ..()
		var/turf/target_turf
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER])
			if(src.region.turf_in_region(T))
				target_turf = T
				break
		src.target_girder = locate(/obj/structure/girder) in target_turf
		if (!src.target_girder)
			src.target_girder = new(target_turf)

		src.target_girder.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.target_girder, COMSIG_ATOM_EXAMINE, PROC_REF(check_examine))

	proc/check_examine(mob/owner, mob/examiner, list/lines)
		src.tutorial.PerformSilentAction("examine", "girder")

	PerformAction(action, context)
		. = ..()
		if (action == "examine" && context == "girder")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_girder)
			UnregisterSignal(src.target_girder, COMSIG_ATOM_EXAMINE)
			src.target_girder.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/item_pickup/toolbox
	name = "Toolboxes"
	instructions = "Toolboxes contain up to 7 objects. This one has a set of tools.<br><b>Click</b> the toolbox to pick it up, then press <b>C</b> to open it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_6

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	item_path = /obj/item/storage/toolbox/tutorial

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Toolboxes contain up to 7 small objects. This one has a set of tools.<br><b>Click</b> the toolbox to pick it up, then press <b>[attackself]</b> to open it."
		..()

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/storage/toolbox/tutorial))
			var/obj/item/storage/toolbox/tutorial/tutorial_box = src._target_item
			for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX])
				if(src.region.turf_in_region(T))
					tutorial_box.reset(T)
					break

/datum/tutorialStep/newbee/deconstructing_girder
	name = "Girder Deconstruction"
	instructions = "To deconstruct the girder, you need a wrench from the toolbox.<br><b>Click</b> the girder with a wrench in-hand."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_6

	var/obj/structure/girder/tutorial/target_girder

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER])
			if(src.region.turf_in_region(T))
				for (var/obj/structure/girder/tutorial/girder in T)
					src.target_girder = girder
					break
				if (!src.target_girder || QDELETED(src.target_girder))
					src.target_girder = new(T)

		src.target_girder.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "deconstruct" && context == "girder")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_girder && !QDELETED(src.target_girder))
			src.target_girder.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/exit_girder
	name = "Activatable Items"
	instructions = "You don't need the toolbox, so feel free to drop it with <b>Q</b>.<br>Head to the next room to learn about activatable items."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	step_area = /area/tutorial/newbee/room_6
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	update_instructions()
		var/drop = src.keymap.action_to_keybind("drop")
		src.instructions = "You don't need the toolbox, so feel free to drop it with <b>[drop]</b>.<br>Head to the next room to learn about activatable items."
		..()

//
// room 7 - Active Items
//

/datum/tutorialStep/newbee/item_pickup/flashlight
	name = "Exploring Darkness"
	instructions = "The maintenance tunnel ahead has no lights.<br>Pick up the flashlight with an empty hand to help you navigate."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_7

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	item_path = /obj/item/device/light/flashlight/tutorial

/datum/tutorialStep/newbee/activating_items
	name = "Activating Items"
	instructions = "Some items do something when used in-hand.<br>Press <b>C</b> to activate the flashlight."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_7
	needed_item_path = /obj/item/device/light/flashlight/tutorial

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Some items do something when used in-hand.<Br>Press <b>[attackself]</b> to activate the flashlight."
		..()

	PerformAction(action, context)
		. = ..() // custom item sends action
		if (action == "use_item" && context == "flashlight")
			src.finished = TRUE

/datum/tutorialStep/newbee/move_to/enter_maints
	name = "Maintenance Tunnels"
	instructions = "Time to enter the maintenance tunnel. Don't dawdle..."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_7
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS

//
// room 8 - Maints
//

/datum/tutorialStep/newbee/move_to/traversing_maints
	name = "Traversing Maintenance"
	instructions = "Head through the maintenance tunnel to get to the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_8
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS

//
// room 9 - Space Prep
//

/datum/tutorialStep/newbee/timer/spaceworthy
	name = "Becoming Spaceworthy"
	instructions = "To survive in space you need a space suit and air tank.<br>Make sure you're fully prepared before risking space travel!"
	step_area = /area/tutorial/newbee/room_9

/datum/tutorialStep/newbee/opening_closets
	name = "Emergency Closets"
	instructions = "Closets contain specialized gear; this one contains a space suit.<br>Open the emergency supply closet by <b>clicking</b> on it with an empty hand."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_9

	var/obj/storage/closet/emergency_tutorial/target_closet

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET])
			if(src.region.turf_in_region(T))
				if (src.target_closet)
					src.target_closet.reset(T)
				else
					src.target_closet = new(T)
				break
		src.target_closet.UpdateOverlays(src.point_marker, "marker")
		src.newbee_tutorial.newbee.hud.show_inventory = TRUE
		src.newbee_tutorial.newbee.hud.update_inventory()

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "emergency_tutorial")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.target_closet.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/equipping_space_gear
	name = "Space Gear"
	instructions = "A space suit, helmet, and breath mask are needed to survive in the vacuum of space.<br><b>Click</b> each piece of space gear to pick it up, then press <b>V</b> or <b>click</b> the item slot to equip it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_9

	var/obj/item/clothing/head/emerg/worn_head
	var/obj/item/clothing/suit/space/emerg/worn_suit
	var/obj/item/clothing/mask/breath/worn_mask

	SetUp()
		var/obj/storage/closet/emergency_tutorial/closet = locate(/obj/storage/closet/emergency_tutorial) in REGION_TILES(src.region)
		closet?.open()
		. = ..()

		src.worn_head = src.highlight_needed_item(/obj/item/clothing/head/emerg)
		RegisterSignal(src.worn_head, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item), TRUE)

		src.worn_suit = src.highlight_needed_item(/obj/item/clothing/suit/space/emerg/)
		RegisterSignal(src.worn_suit, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item), TRUE)

		src.worn_mask = src.highlight_needed_item(/obj/item/clothing/mask/breath/)
		RegisterSignal(src.worn_mask, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item), TRUE)

	proc/equip_tutorial_item(datum/source, mob/user)
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("item_equipped", source)

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped")
			if (context == src.worn_head)
				src.worn_head.UpdateOverlays(null, "marker")
				src.worn_head = null
			else if (context == src.worn_suit)
				src.worn_suit.UpdateOverlays(null, "marker")
				src.worn_suit = null
			else if (context == src.worn_mask)
				src.worn_mask.UpdateOverlays(null, "marker")
				src.worn_mask = null

		if (isnull(src.worn_head) && isnull(src.worn_suit) && isnull(src.worn_mask))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.worn_head?.UpdateOverlays(null, "marker")
		src.worn_head = null
		src.worn_suit?.UpdateOverlays(null, "marker")
		src.worn_suit = null
		src.worn_mask?.UpdateOverlays(null, "marker")
		src.worn_mask = null

/datum/tutorialStep/newbee/item_pickup/oxygen
	name = "Oxygen Required"
	instructions = "You need oxygen to breathe in areas without air, like space.<br><b>Click</b> the oxygen tank to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_9

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET
	item_path = /obj/item/tank/oxygen/tutorial

/datum/tutorialStep/newbee/internals_on
	name = "Using Internals"
	instructions = "Make sure you are breathing from your oxygen tank before heading into space.<br><b>Click</b> the 'Toggle Tank Valve' button in the top-left corner to turn on your internals."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/tank/oxygen/tutorial
	step_area = /area/tutorial/newbee/room_9

	SetUp()
		. = ..()
		for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
			tank_ability.UpdateOverlays(src.inventory_marker, "marker")
			var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, tank_ability.screen_loc)
			src.hud_point_loop(src.newbee_tutorial.current_step, hud_x_y_offset[1] + 16, hud_x_y_offset[2] + 30)

	PerformAction(action, context)
		. = ..()
		if (action == "action_button" && context == "internals_on")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
				tank_ability.UpdateOverlays(null, "marker")

// TODO: detection ?
/datum/tutorialStep/newbee/timer/stats_after
	name = "Suited Up"
	instructions = "<b>Click</b> the STAT button in the HUD to show your current stats.<br>Full space gear provides 100% cold resistance."
	step_area = /area/tutorial/newbee/room_9
	highlight_hud_element = "stats"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_STATS

/datum/tutorialStep/newbee/move_to/enter_space
	name = "Entering Space"
	instructions = "With your suit on and internals set, you're ready to go into space.<br>Head through the airlock!"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_9
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE

//
// room 10 - Space Traversal
//

/datum/tutorialStep/newbee/move_to/traversing_space
	name = "Traversing Space"
	instructions = "You slowly float in space without solid ground under you.<br>Drift to the airlock on the other side."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MOVEMENT
	step_area = /area/tutorial/newbee/room_10
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE

//
// room 11 - Storage
//

/datum/tutorialStep/newbee/internals_off
	name = "Disabling Internals"
	instructions = "Keeping internals on while in a place with atmosphere will waste precious oxygen.<br><b>Click</b> the 'Toggle Tank Valve' button in the top-left corner to turn off your internals."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/tank/oxygen/tutorial
	step_area = /area/tutorial/newbee/room_11

	SetUp()
		. = ..()
		for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
			tank_ability.UpdateOverlays(src.inventory_marker, "marker")
			var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, tank_ability.screen_loc)
			src.hud_point_loop(src.newbee_tutorial.current_step, hud_x_y_offset[1] + 16, hud_x_y_offset[2] + 30)

	PerformAction(action, context)
		. = ..()
		if (action == "action_button" && context == "internals_off")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/tank_valve_toggle/tank_ability in src._needed_item.ability_buttons)
				tank_ability.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/item_pickup/backpack
	name = "Backpack Storage"
	instructions = "Backpacks allow you to store items for later use.<br><b>Click</b> the backpack with an empty hand to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	item_path = /obj/item/storage/backpack/empty

/datum/tutorialStep/newbee/equip_backpack
	name = "Wearing a Backpack"
	instructions = "Backpacks can be worn on your back.<br>Equip the backpack with <b>V</b> or <b>click</b> the back slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "back"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/storage/backpack/empty
	step_area = /area/tutorial/newbee/room_11

	update_instructions()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Backpacks can be worn on your back.<br>Equip the backpack with <b>[equip]</b> or <b>click</b> the back slot in your HUD."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "backpack")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "backpack")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/unequipping_worn_items
	name = "Storing Items"
	instructions = "Space suits slow you down on solid ground. You can keep the gear in your backpack, instead.<br><b>Click</b> a piece of space gear to take it off, and then <b>click</b> your backpack to store it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11

	var/obj/item/clothing/head/worn_head
	var/obj/item/clothing/suit/worn_suit
	var/obj/item/clothing/mask/worn_mask

	SetUp()
		. = ..()
		src.worn_head = src.highlight_needed_item(/obj/item/clothing/head/emerg)
		RegisterSignal(src.worn_head, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item), TRUE)

		src.worn_suit = src.highlight_needed_item(/obj/item/clothing/suit/space/emerg/)
		RegisterSignal(src.worn_suit, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item), TRUE)

		src.worn_mask = src.highlight_needed_item(/obj/item/clothing/mask/breath/)
		RegisterSignal(src.worn_mask, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item), TRUE)

	proc/unequip_tutorial_item(datum/source, mob/user)
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("item_unequipped", source)

	PerformAction(action, context)
		. = ..()
		if (action == "item_unequipped")
			if (context == src.worn_head)
				src.worn_head.UpdateOverlays(null, "marker")
				src.worn_head = null
			else if (context == src.worn_suit)
				src.worn_suit.UpdateOverlays(null, "marker")
				src.worn_suit = null
			else if (context == src.worn_mask)
				src.worn_mask.UpdateOverlays(null, "marker")
				src.worn_mask = null

		if (isnull(src.worn_head) && isnull(src.worn_suit) && isnull(src.worn_mask))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.worn_head?.UpdateOverlays(null, "marker")
		src.worn_head = null
		src.worn_suit?.UpdateOverlays(null, "marker")
		src.worn_suit = null
		src.worn_mask?.UpdateOverlays(null, "marker")
		src.worn_mask = null

/datum/tutorialStep/newbee/move_to/exit_storage
	name = "Backpack Storage"
	instructions = "You can <b>Click</b> on your backpack to open it. Backpacks can store 7 normal-sized objects.<br>Head into the next room."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_11
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE

//
// room 12 - Wall Deconstruction
//

/datum/tutorialStep/newbee/item_pickup/welding_mask
	name = "Space OSHA Reminder"
	instructions = "Welding without proper eyewear is a bad idea!<br><b>Click</b> the welding mask to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	item_path = /obj/item/clothing/head/helmet/welding/tutorial

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/clothing/head/helmet/welding/tutorial))
			var/obj/item/clothing/head/helmet/welding/tutorial/welding_mask = src._target_item
			welding_mask.flip_up(silent=TRUE)
			for(var/obj/ability_button/mask_toggle/toggle in welding_mask.ability_buttons)
				toggle.icon_state = "welddown" // manually set the ability button state

/datum/tutorialStep/newbee/equip_welding_mask
	name = "Welding Masks"
	instructions = "You need to wear the welding mask before it will protect your eyes.<br>Equip the welding mask with <b>V</b> or by <b>clicking</b> the head slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	highlight_hud_element = "head"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	update_instructions()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "You need to wear the welding mask before it will protect your eyes.<br>Equip the welding mask with <b>[equip]</b> or by <b>clicking</b> the head slot in your HUD."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "welding_mask")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "welding_mask")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/flip_welding_mask_down
	name = "Eye Protection"
	instructions = "Flipping a welding mask down will protect your eyes, but obscure your sight.<br><b>Click</b> the icon in the top-left corner to lower the mask."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	SetUp()
		. = ..()
		for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
			toggle.UpdateOverlays(src.inventory_marker, "marker")
			var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, toggle.screen_loc)
			src.hud_point_loop(src.newbee_tutorial.current_step, hud_x_y_offset[1] + 16, hud_x_y_offset[2] + 30)

	PerformAction(action, context)
		. = ..()
		if (action == "welding_mask" && context == "flip_down")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
				toggle.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/item_pickup/weldingtool
	name = "Welding Tools"
	instructions = "Deconstructing walls requires a welding tool.<br><b>Click</b> the welding tool to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL
	item_path = /obj/item/weldingtool/tutorial

	SetUp()
		. = ..()
		var/obj/item/weldingtool/tutorial/welding_tool = src._target_item
		welding_tool.set_state(FALSE)
		welding_tool.reagents.add_reagent("fuel", welding_tool.fuel_capacity)

/datum/tutorialStep/newbee/using_welder
	name = "Using Welding Tools"
	instructions = "Welding tools can be used in-hand to light them. Lit welding tools slowly use up fuel.<br>Turn on the welding tool with <b>C</b>."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/weldingtool/tutorial
	step_area = /area/tutorial/newbee/room_12

	update_instructions()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Welding tools can be used in-hand to light them. Lit welding tools slowly use up fuel.<br>Turn on the welding tool with <b>[attackself]</b>."
		..()

	PerformAction(action, context)
		. = ..()
		if (action == "use_item" && context == "weldingtool")
			src.finished = TRUE

/datum/tutorialStep/newbee/decon_wall
	name = "Deconstructing a Wall"
	instructions = "Regular walls can be deconstructed with lit welding tools.<br><b>Click</b> the wall with the lit welding tool and wait for the action bar to finish."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/weldingtool/tutorial
	step_area = /area/tutorial/newbee/room_12

	var/turf/target_wall

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_WALL])
			if(src.region.turf_in_region(T))
				src.target_wall = T
		if (!istype(src.target_wall, /turf/simulated/wall/auto/supernorn/tutorial))
			src.target_wall = src.target_wall.ReplaceWith(/turf/simulated/wall/auto/supernorn/tutorial)

		var/obj/structure/girder/girder = locate(/obj/structure/girder) in src.target_wall
		if (istype(girder))
			qdel(girder)

		src.target_wall.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "deconstruct" && context == "wall")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_wall && !QDELETED(src.target_wall))
			src.target_wall.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/flip_welding_mask_up
	name = "Raising the Mask"
	instructions = "With the welding done, flip the welding mask back up to see better.<br><b>Click</b> the icon in the top-left corner to raise the mask."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	needed_item_path = /obj/item/clothing/head/helmet/welding/tutorial
	step_area = /area/tutorial/newbee/room_12

	SetUp()
		. = ..()
		for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
			toggle.UpdateOverlays(src.inventory_marker, "marker")
			var/hud_x_y_offset = screen_loc_to_pixel_offset(src.newbee_tutorial.newbee.client, toggle.screen_loc)
			src.hud_point_loop(src.newbee_tutorial.current_step, hud_x_y_offset[1] + 16, hud_x_y_offset[2] + 30)

	PerformAction(action, context)
		. = ..()
		if (action == "welding_mask" && context == "flip_up")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			for(var/obj/ability_button/mask_toggle/toggle in src._needed_item.ability_buttons)
				toggle.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/item_pickup/wrench
	name = "Removing the Girder"
	instructions = "With the wall sliced open, all that remains is a girder. As before, you'll need a wrench.<br><b>Click</b> the wrench with an empty hand to pick it up."
	step_area = /area/tutorial/newbee/room_12

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WRENCH
	item_path = /obj/item/wrench

/datum/tutorialStep/newbee/decon_wall_girder
	name = "Finishing Deconstruction"
	instructions = "<b>Click</b> the girder with a wrench to finish deconstructing it."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ITEMS
	step_area = /area/tutorial/newbee/room_12
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	var/obj/structure/girder/tutorial/target_girder

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_WALL])
			if(src.region.turf_in_region(T))
				for (var/obj/structure/girder/tutorial/girder in T)
					src.target_girder = girder
					break
				if (!src.target_girder || QDELETED(src.target_girder))
					src.target_girder = new(T)

		src.target_girder.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "deconstruct" && context == "girder")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_girder && !QDELETED(src.target_girder))
			src.target_girder.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/exit_decon_wall
	name = "Movement Actions"
	instructions = "Let's learn some movement actions by heading into the next room."
	step_area = /area/tutorial/newbee/room_12
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL

//
// room 13 - Advanced Movement
//

/datum/tutorialStep/newbee/move_to/laying_down
	name = "Laying Down"
	instructions = "Laying down drops all items in your hands and lets you pass under some objects.<br>Press <b>=</b> or <b>click</b> the Stand/Rest button in the HUD to crawl under the flaps."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "rest"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_LOWER_HALF
	step_area = /area/tutorial/newbee/room_13

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN

	update_instructions()
		var/rest = src.keymap.action_to_keybind("rest")
		src.instructions = "Laying down drops all items in your hands and lets you pass under some objects.<br>Press <b>[rest]</b> or <b>click</b> the Stand/Rest button in the HUD to crawl under the flaps."
		..()

/datum/tutorialStep/newbee/move_to/sprinting
	name = "Sprinting"
	instructions = "Sprint to move faster. Sprinting takes stamina, displayed in the top-right corner.<br>Hold <b>SHIFT</b> to sprint across the conveyors."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	highlight_hud_element = "stamina"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	step_area = /area/tutorial/newbee/room_13

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_SPRINTING

	update_instructions()
		var/sprint = src.keymap.action_to_keybind(KEY_RUN)
		src.instructions = "Sprint to move faster. Sprinting takes stamina, displayed in the top-right corner.<br>Hold <b>[sprint]</b> to sprint across the conveyors."
		..()

	SetUp()
		. = ..()
		src.newbee_tutorial.newbee.full_heal() // full health/stamina to ensure they can sprint through the next part

/datum/tutorialStep/newbee/walking
	name = "Whoa, Careful!"
	instructions = "Some things on the ground can make you slip while running, like that banana peel!<br>Press <b>-</b> or <b>click</b> the Run/Walk HUD button to walk and past the banana peel."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	step_area = /area/tutorial/newbee/room_13
	highlight_hud_element = "mintent"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF

	var/obj/item/bananapeel/target_peel

	update_instructions()
		var/walk = src.keymap.action_to_keybind("walk")
		src.instructions = "Some things on the ground can make you slip while running, like that banana peel!<br>Press <b>[walk]</b> or <b>click</b> the Run/Walk HUD button to walk past the banana peel."
		..()

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_WALKING])
			if(src.region.turf_in_region(T))
				if (!src.target_peel || QDELETED(src.target_peel))
					src.target_peel = new /obj/item/bananapeel(T)
				if (ismob(src.target_peel.loc))
					var/mob/M = src.target_peel.loc
					M.drop_item(src.target_peel)
				src.target_peel.set_loc(T)
				break
		src.target_peel.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "m_intent" && context == "walk")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src.target_peel && !QDELETED(src.target_peel))
			src.target_peel.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/exit_movement
	name = "Communication"
	instructions = "Head into the next room to learn how to talk and use the radio.<br>Both talking and radio appear in the right-side chat panel."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_ACTIONS
	step_area = /area/tutorial/newbee/room_13
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT

//
// room 14 - Talking / Radio
//

/datum/tutorialStep/newbee/say
	name = "Talking"
	instructions = "Talking is a great way to communicate with nearby crewmates!<br>Press <b>T</b> to open the talk dialog and press <b>ENTER</b> to say something."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14

	update_instructions()
		var/say = src.keymap.action_to_keybind("say")
		src.instructions = "Talking is a great way to communicate with nearby crewmates!<br>Press <b>[say]</b> to open the talk dialog and press <b>ENTER</b> to say something."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY)

/datum/tutorialStep/newbee/item_pickup/headset
	name = "Headsets"
	instructions = "Headsets let you speak over the radio to the entire station.<br><b>Click</b> the headset to pick it up."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	item_path = /obj/item/device/radio/headset/tutorial

/datum/tutorialStep/newbee/equip_headset
	name = "Equipping Headsets"
	instructions = "Headsets go on your ears.<br>Equip the headset by pressing <b>V</b> or <b>clicking</b> the ears slot in your HUD."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	highlight_hud_element = "ears"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_INVENTORY
	needed_item_path = /obj/item/device/radio/headset/tutorial
	step_area = /area/tutorial/newbee/room_14

	SetUp()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		instructions = "Headsets go on your ear.<br>Equip the headset by pressing <b>[equip]</b> or <b>clicking</b> the ear slot in your HUD."

		RegisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformAction("item_equipped", "headset")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "headset")
			src.finished = TRUE

	TearDown()
		. = ..()
		if (src._needed_item)
			UnregisterSignal(src._needed_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/using_headset
	name = "Using the Radio"
	instructions = "Press <b>Y</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	needed_item_path = /obj/item/device/radio/headset/tutorial
	step_area = /area/tutorial/newbee/room_14

	update_instructions()
		var/say_over_channel = src.keymap.action_to_keybind("say_over_channel")
		src.instructions = "Press <b>[say_over_channel]</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."
		..()

	SetUp()
		. = ..()
		RegisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		if (message.prefix)
			src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.newbee_tutorial.newbee, COMSIG_ATOM_SAY)

/datum/tutorialStep/newbee/move_to/exit_radio
	name = "Radio Channels"
	instructions = "Each department has their own dedicated radio channel.<br>Move into the next room to learn about pulling objects."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_COMMUNICATION
	step_area = /area/tutorial/newbee/room_14
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO

//
// room 15 - hallway (Pulling)
//

/datum/tutorialStep/newbee/pull_start
	name = "Pulling Objects"
	instructions = "You can pull objects (and people!) by holding <b>CTRL</b> and <b>clicking</b> them.<br>Start pulling the water tank."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	highlight_hud_element = "pull"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF
	step_area = /area/tutorial/newbee/room_15

	var/obj/reagent_dispensers/watertank/target_object

	update_instructions()
		var/pull = src.keymap.action_to_keybind(KEY_PULL)
		src.instructions = "You can pull objects (and people!) by holding <b>[pull]</b> and <b>clicking</b> them.<br>Start pulling the water tank."
		..()

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_WATER_TANK])
			if(src.region.turf_in_region(T))
				if(src.target_object)
					src.target_object.set_loc(T)
				else
					src.target_object = new(T)
				break
		src.target_object.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "set_pulling" && istype(context, /obj/reagent_dispensers/watertank))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.target_object.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/move_to/pull_target
	name = "Pull the Tank"
	instructions = "Walk to the previous room while pulling the water tank to move it out of your way.<br>Drag the water tank to the marker."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	step_area = /area/tutorial/newbee/room_15

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET

/datum/tutorialStep/newbee/pull_end
	name = "Stop Pulling"
	instructions = "Press <b>CTRL</b> and <b>click</b> far away to stop pulling the water tank.<br>You can also press the PULL button in your hud to stop pulling."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_MODIFIERS
	highlight_hud_element = "pull"
	highlight_hud_marker = NEWBEE_TUTORIAL_MARKER_HUD_UPPER_HALF
	step_area = /area/tutorial/newbee/room_15

	update_instructions()
		var/pull = src.keymap.action_to_keybind(KEY_PULL)
		src.instructions = "Press <b>[pull]</b> and <b>click</b> far away to stop pulling the water tank.<br>You can also press the PULL button in your hud to stop pulling."
		..()

	PerformAction(action, context)
		. = ..()
		if (action == "remove_pulling" && istype(context, /obj/reagent_dispensers/watertank))
			src.finished = TRUE

/datum/tutorialStep/newbee/move_to/final_room
	name = "Almost Done!"
	instructions = "You're almost a fully functioning spacefarer! There's just one more thing to learn...<br>Head through the hallway into the final room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM
	step_area = /area/tutorial/newbee/room_15
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

//
// room 16 - escape (Advanced Combat)
//

/datum/tutorialStep/newbee/murder
	name = "Advanced Combat"
	instructions = "To activate the special attack of some items, use the Disarm or Harm intent and <b>click</b> far away.<br><span style='color:#962121; font-weight:bold'>Kill the clown</span> to complete the tutorial. Their robustness may surprise you!"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_INTENTS
	step_area = /area/tutorial/newbee/room_16

	var/mob/living/carbon/human/normal/tutorial_kill/tutorial_clown
	var/gibbed = FALSE

	SetUp()
		. = ..()
		src.instructions ="To activate the special attack of some items, use the [TEXT_INTENT_DISARM] or [TEXT_INTENT_HARM] intent and <b>click</b> far away.<br><span style='color:#962121; font-weight:bold'>Kill the clown</span> to complete the tutorial. Their robustness may surprise you!"

		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER])
			if(src.region.turf_in_region(T))
				if (!src.tutorial_clown || QDELETED(src.tutorial_clown))
					src.tutorial_clown = new(T)
				src.tutorial_clown.set_loc(T)
				break
		src.tutorial_clown.tutorial_owner = src.newbee_tutorial.newbee
		RegisterSignal(src.tutorial_clown, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))

	proc/check_mob_death()
		if (isdead(src.tutorial_clown))
			src.tutorial.PerformAction("mob_death", "clown")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_death" && context == "clown")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial_clown, COMSIG_MOB_DEATH)
		if (src.tutorial_clown)
			if (!src.gibbed)
				gibbed = TRUE
				src.tutorial_clown.gib()
			else
				src.tutorial_clown.implode()

/datum/tutorialStep/newbee/timer/following_rules
	name = "Server Rules"
	instructions = "The 'Rules' verb is located in the Commands tab above the chat top-right.<br>On the RP servers, the 'Rules - RP' verb is in the same tab.<br><b>Not knowing the rules isn't an excuse for breaking 'em!</b>"
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_META
	step_area = /area/tutorial/newbee/room_16

/datum/tutorialStep/newbee/timer/getting_help
	name = "Getting Help"
	instructions = "The <a href=\"https://wiki.ss13.co/\" style='color:#0099cc;text-decoration: underline;'>wiki</a> has detailed guides and information.<br>Ask our mentors gameplay questions in-game by pressing <b>F3</b>.<br>Ask our admins rules questions in-game by pressing <b>F1</b>."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_META
	step_area = /area/tutorial/newbee/room_16

	update_instructions()
		var/adminhelp = src.keymap.action_to_keybind("adminhelp")
		var/mentorhelp = src.keymap.action_to_keybind("mentorhelp")
		src.instructions = "The <a href=\"https://wiki.ss13.co/\" style='color:#0099cc;text-decoration: underline;'>wiki</a> has detailed guides and information.<br>Ask our mentors gameplay questions in-game by pressing <b>[mentorhelp]</b>.<br>Ask our admins rules questions in-game by pressing <b>[adminhelp]</b>."
		..()

/datum/tutorialStep/newbee/timer/finished
	name = "Tutorial Complete"
	instructions = "There's more to learn and discover, but you can confidently take your first space-steps!<br>Returning to the main menu..."
	sidebar = NEWBEE_TUTORIAL_SIDEBAR_EMPTY
	step_area = /area/tutorial/newbee/room_16
	custom_advance_sound = 'sound/misc/tutorial-bleep.ogg'

	SetUp()
		..()
		src.newbee_tutorial.newbee.unlock_medal("On My Own Two (Space) Legs", TRUE)
		playsound(src.newbee_tutorial.newbee, pick(20;'sound/misc/openlootcrate.ogg',100;'sound/misc/openlootcrate2.ogg'), 60, 0)
