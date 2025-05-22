/// How long before auto-continuing for timed steps. Matches the related tutorial timer animation duration.
#define NEWBEE_TUTORIAL_TIMER_DURATION 10 SECONDS
/// Use a large target marker, good for turfs
#define NEWBEE_TUTORIAL_TARGETING_MARKER 0
/// Use a point marker, good for items
#define NEWBEE_TUTORIAL_TARGETING_POINT 1

/area/tutorial/newbee
	name = "Newbee Tutorial Zone"
	icon_state = "green"
	sound_group = "newbee"

/area/tutorial/newbee/unpowered
	icon_state = "red"
	requires_power = TRUE

/mob/new_player/verb/play_tutorial()
	set name = "Play Tutorial"
	set desc = "Launch the in-game tutorial!"
	set category = "Commands"
	set hidden = TRUE

	if (global.current_state < GAME_STATE_SETTING_UP)
		boutput(usr, SPAN_ALERT("The tutorial will launch when the game starts."))
		src.ready_tutorial = TRUE
		src.update_joinmenu()
	else if (global.current_state <= GAME_STATE_PLAYING)
		if (src.tutorial_loading)
			boutput(usr, SPAN_ALERT("The tutorial is loading, please be patient!"))
			return
		src.tutorial_loading = TRUE
		boutput(usr, SPAN_ALERT("Launching the tutorial!"))
		src.client?.tutorial = new(src)
		src.client?.tutorial.Start()
	else
		boutput(usr, SPAN_ALERT("It's too late to start the tutorial! Please try next round."))

/datum/tutorial_base/regional/newbee
	name = "Newbee tutorial"
	var/mob/living/carbon/human/tutorial/newbee = null
	var/mob/new_player/origin_mob
	var/datum/hud/tutorial/tutorial_hud
	var/datum/keymap/keymap
	var/checkpoint_landmark = LANDMARK_TUTORIAL_START
	region_type = /datum/mapPrefab/allocated/newbee_tutorial

	New(mob/M)
		..()
		src.exit_point = pick_landmark(LANDMARK_NEW_PLAYER)
		src.origin_mob = M
		src.origin_mob.close_spawn_windows()
		src.keymap = src.origin_mob.client.keymap
		src.newbee = new(src.initial_turf, src.origin_mob.client.preferences.AH, src.origin_mob.client.preferences, TRUE)
		src.owner = src.newbee
		src.AddNewbeeSteps() // need the keymap in place before adding steps for reading player custom binds

	Start()
		src.tutorial_hud = new()
		src.origin_mob.mind.transfer_to(src.newbee)
		src.tutorial_hud.add_client(src.newbee.client)
		src.newbee.addAbility(/datum/targetable/newbee/exit)
		src.newbee.addAbility(/datum/targetable/newbee/previous)
		src.newbee.addAbility(/datum/targetable/newbee/next)
		. = ..()

	ShowStep()
		. = ..()
		var/datum/tutorialStep/T = src.steps[src.current_step]
		src.tutorial_hud.update_step(T.name)
		src.tutorial_hud.update_text(T.instructions)

	Finish()
		if(..())
			src.tutorial_hud.remove_client(src.newbee.client)
			var/mob/new_player/M = new()
			src.newbee.mind.transfer_to(M)
			qdel(src.newbee)
			src.newbee = null
			qdel(src.region)
			src.region = null
			qdel(src.tutorial_hud)
			src.tutorial_hud = null
			qdel(src)

/datum/tutorial_base/regional/newbee/proc/AddNewbeeSteps()
	// room 1 - Arrivals (Movement)
	src.AddStep(/datum/tutorialStep/newbee/timer/welcome)
	src.AddStep(/datum/tutorialStep/newbee/move_to/basic_movement)
	src.AddStep(/datum/tutorialStep/newbee/move_to/powered_doors)

	// room 2 - grey floor, green border (ID-locked Doors)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/id_card)
	src.AddStep(/datum/tutorialStep/newbee/wear_id_card)
	src.AddStep(/datum/tutorialStep/newbee/move_to/id_locked_doors)

	// room 3 - grey floor, yellow border (Unpowered Doors)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/crowbar)
	src.AddStep(/datum/tutorialStep/newbee/move_to/unpowered_doors)

	// room 4 - grey floor, red border (Intents/Combat)
	src.AddStep(/datum/tutorialStep/newbee/drop_item)
	src.AddStep(/datum/tutorialStep/newbee/intent_help)
	src.AddStep(/datum/tutorialStep/newbee/intent_disarm)
	src.AddStep(/datum/tutorialStep/newbee/intent_grab)
	src.AddStep(/datum/tutorialStep/newbee/intent_harm)
	src.AddStep(/datum/tutorialStep/newbee/basic_combat)
	src.AddStep(/datum/tutorialStep/newbee/move_to/health)

	// room 5 - white floor, blue border (Healing)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/first_aid)
	src.AddStep(/datum/tutorialStep/newbee/storage_inhands)
	src.AddStep(/datum/tutorialStep/newbee/hand_swap)
	src.AddStep(/datum/tutorialStep/newbee/timer/apply_patch)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_healing)

	// room 6 - white floor, black border (Girder Decon)
	src.AddStep(/datum/tutorialStep/newbee/examining)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/toolbox)
	src.AddStep(/datum/tutorialStep/newbee/move_to/deconstructing_girder)

	// room 7 - white floor, dark blue border (Active Items)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/flashlight)
	src.AddStep(/datum/tutorialStep/newbee/activating_items)
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_maints)

	// room 8 - maints (Dark Areas)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_maints)

	// room 9 - green/blue checker floor (Space Prep)
	src.AddStep(/datum/tutorialStep/newbee/opening_closets)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_suit)
	src.AddStep(/datum/tutorialStep/newbee/equip_breath_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_space_helmet)
	src.AddStep(/datum/tutorialStep/newbee/oxygen)
	src.AddStep(/datum/tutorialStep/newbee/internals)
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_space)

	// room 10 - space (Space Traversal)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_space)

	// room 11 - black floor, green border (Storage)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/backpack)
	src.AddStep(/datum/tutorialStep/newbee/equip_backpack)
	src.AddStep(/datum/tutorialStep/newbee/unequipping_worn_items)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_storage)

	// room 12 - black floor, dark purple border (Wall Decon)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/welding_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_welding_mask)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/weldingtool)
	src.AddStep(/datum/tutorialStep/newbee/using_welder)
	src.AddStep(/datum/tutorialStep/newbee/move_to/decon_wall)
	src.AddStep(/datum/tutorialStep/newbee/move_to/decon_wall_girder)

	// room 13 - yellow-white checker (Advanced Movement)
	src.AddStep(/datum/tutorialStep/newbee/move_to/laying_down)
	src.AddStep(/datum/tutorialStep/newbee/move_to/sprinting)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_movement)

	// room 14 - blue/dark blue checker (Talking / Radio)
	src.AddStep(/datum/tutorialStep/newbee/say)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/headset)
	src.AddStep(/datum/tutorialStep/newbee/equip_headset)
	src.AddStep(/datum/tutorialStep/newbee/using_headset)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_radio)

	// room 15 - hallway (Pulling)
	src.AddStep(/datum/tutorialStep/newbee/pull_start)
	src.AddStep(/datum/tutorialStep/newbee/move_to/pull_target)
	src.AddStep(/datum/tutorialStep/newbee/pull_end)
	src.AddStep(/datum/tutorialStep/newbee/move_to/final_room)

	// room 16 - escape (Advanced Combat)
	src.AddStep(/datum/tutorialStep/newbee/murder)
	src.AddStep(/datum/tutorialStep/newbee/timer/following_rules)
	src.AddStep(/datum/tutorialStep/newbee/timer/getting_help)
	src.AddStep(/datum/tutorialStep/newbee/timer/finished)

/datum/tutorialStep/newbee
	var/static/image/destination_marker = null
	var/static/image/point_marker = null
	var/static/image/box_marker = null
	var/datum/tutorial_base/regional/newbee/newbee_tutorial
	var/datum/allocated_region/region
	var/datum/keymap/keymap


	New(datum/tutorial_base/regional/newbee/tutorial)
		src.newbee_tutorial = tutorial
		src.region = tutorial.region
		src.keymap = tutorial.keymap
		if (!src.destination_marker)
			src.destination_marker = image('icons/effects/VR.dmi', "lightning_marker", HUD_LAYER_3)
			src.destination_marker.alpha = 100
			src.destination_marker.plane = PLANE_HUD
			src.destination_marker.filters = filter(type="outline", size=1)
		if (!src.point_marker)
			src.point_marker = image('icons/mob/screen1.dmi', "arrow", HUD_LAYER_3, pixel_y=8)
			src.point_marker.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
			src.point_marker.plane = PLANE_HUD
			src.point_marker.color = "#33cccc"
		if (!src.box_marker)
			src.box_marker = image('icons/mob/tutorial_ui.dmi', "inventory", HUD_LAYER_3)
			src.box_marker.plane = PLANE_HUD
		..()

// tutorial step subtypes with common behavior

/// Steps that direct the player to move to a location
/datum/tutorialStep/newbee/move_to
	name = "Moving on..."
	instructions = "Head into the next room to continue."
	var/target_landmark
	var/targeting_type = NEWBEE_TUTORIAL_TARGETING_MARKER

	var/turf/_target_destination

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[src.target_landmark])
			if(src.region.turf_in_region(T))
				src._target_destination = T
				break
		if (src.targeting_type == NEWBEE_TUTORIAL_TARGETING_MARKER)
			src._target_destination.UpdateOverlays(src.destination_marker, "marker")
		else if (src.targeting_type == NEWBEE_TUTORIAL_TARGETING_POINT)
			src._target_destination.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == src.target_landmark)
			src.finished = TRUE

	TearDown()
		. = ..()
		src._target_destination.UpdateOverlays(null, "marker")
		src.newbee_tutorial.checkpoint_landmark = src.target_landmark

/// Show countdown clock and move to the next step after `NEWBEE_TUTORIAL_TIMER_DURATION`
/datum/tutorialStep/newbee/timer
	SetUp()
		. = ..()
		src.newbee_tutorial.tutorial_hud.flick_timer()
		SPAWN (NEWBEE_TUTORIAL_TIMER_DURATION)
			if (src.tutorial.steps[src.tutorial.current_step] == src)
				src.tutorial.Advance()

	TearDown()
		. = ..()
		src.newbee_tutorial.tutorial_hud?.stop_timer()

/// Spawn an item of the given type at given landmark, and continue when picked up
/datum/tutorialStep/newbee/item_pickup
	var/target_landmark
	var/item_path

	var/obj/item/_target_item

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[target_landmark])
			if(src.region.turf_in_region(T))
				src._target_item = new item_path(T)
				break
		src._target_item.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src._target_item, COMSIG_ITEM_PICKUP, PROC_REF(check_item))

	proc/check_item(atom/source, mob/user)
		src.tutorial.PerformAction("item_pickup", item_path)

	PerformAction(action, context)
		if (action == "item_pickup" && context == item_path)
			src.finished = TRUE
		. = ..()

	TearDown()
		. = ..()
		src._target_item.UpdateOverlays(null, "marker")
		UnregisterSignal(src._target_item, COMSIG_ITEM_PICKUP)

// actual tutorial steps

//
// room 1 - Arrivals (Movement)
//

/datum/tutorialStep/newbee/timer/welcome
	name = "Welcome to Space Station 13!"
	instructions = "This tutorial covers the basics of the game.<br>The top left buttons allow you to exit the tutorial, go back a step, or advance to the next step."

/obj/landmark/newbee
	deleted_on_start = FALSE

	Crossed(atom/movable/AM)
		..()
		if (!ismob(AM))
			return
		var/mob/M = AM
		if (!M.client)
			return
		if (!M.client.tutorial)
			return
		M.client.tutorial.PerformSilentAction(src.name)

	disposing()
		. = ..()
		landmarks[name] -= src.loc

/obj/landmark/newbee/basic_movement
	name = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/basic_movement
	name = "Basic Movement"
	instructions = "Use W/A/S/D to move around.<br>Move to the marker to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT

	New()
		. = ..()
		var/up = src.keymap.action_to_keybind(KEY_FORWARD)
		var/left = src.keymap.action_to_keybind(KEY_LEFT)
		var/down = src.keymap.action_to_keybind(KEY_BACKWARD)
		var/right = src.keymap.action_to_keybind(KEY_RIGHT)
		src.instructions = "Use [up ? up : "W"]/[left ? left : "A"]/[down ? down : "S"]/[right ? right : "D"] to move around.<br>Move to the marker to continue."

/obj/landmark/newbee/powered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/powered_doors
	name = "Powered Doors"
	instructions = "Powered doors will open when you walk into them.<br>Head into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS

//
// room 2 - grey floor, yellow border (ID-locked Doors)
//

/obj/landmark/newbee/pickup_id_card
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	icon = 'icons/obj/items/card.dmi'
	icon_state = "id_eng"

/datum/tutorialStep/newbee/item_pickup/id_card
	name = "Picking Up Items"
	instructions = "Pick up items by left-clicking them.<br>Pick up the ID card to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	item_path = /obj/item/card/id/engineering/tutorial

	SetUp()
		. = ..()
		if (istype(src._target_item, /obj/item/card/id/engineering/tutorial))
			var/obj/item/card/id/engineering/tutorial/tutorial_card = src._target_item
			tutorial_card.registered = src.tutorial.owner.name
			tutorial_card.assignment = "Engineer"
			tutorial_card.update_name()

/datum/tutorialStep/newbee/wear_id_card
	name = "Equipping Items"
	instructions = "Some items can be worn. Press <b>V</b> to equip the ID card to continue."
	var/obj/item/card/id/engineering/tutorial/target_item
	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Some items can be worn.<br>Press <b>[equip ? equip : "V"]</b> to equip the ID card."

	SetUp()
		. = ..()
		src.target_item = locate(/obj/item/card/id/engineering/tutorial) in src.tutorial.owner
		RegisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "id")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "id_card")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "id_card")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED)

/obj/landmark/newbee/idlock_doors
	name = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/id_locked_doors
	name = "ID-Locked Doors"
	instructions = "Some doors require a valid ID to use.<br>Head into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS

//
// room 3 - grey floor, green border (Unpowered Doors)
//


/obj/landmark/newbee/pickup_crowbar
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	icon = 'icons/obj/items/tools/crowbar.dmi'
	icon_state = "crowbar"

/datum/tutorialStep/newbee/item_pickup/crowbar
	name = "Usable Items"
	instructions = "Some items are useful tools during dangerous situations.<br>Pick up the crowbar to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	item_path = /obj/item/crowbar

/obj/landmark/newbee/unpowered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/unpowered_doors
	name = "Unpowered Doors"
	instructions = "Unpowered doors can be opened with crowbars.<br>Open this unpowered door and head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

//
// room 4 - grey floor, red border (Intents/Combat)
//

/datum/tutorialStep/newbee/

/datum/tutorialStep/newbee/intent_help
	name = "Help Intent"
	instructions = "The <span color=\"#349E00\" font-weight=\"bold\">Help</span> intent will help people up, or give critical people CPR.<br>Press <b>1</b> to switch to the <span color=\"#349E00\" font-weight=\"bold\">Help</span> intent."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/help = src.keymap.action_to_keybind("help")
		src.instructions = "The <span color=\"#349E00\" font-weight=\"bold\">Help</span> intent will help people up, or give critical people CPR.<br>Press <b>[help ? help : "1"]</b> to switch to the <span color=\"#349E00\" font-weight=\"bold\">Help</span> intent."

	SetUp()
		. = ..()
		if (src.tutorial.owner.intent == INTENT_HELP || src.tutorial.owner.intent == null)
			src.tutorial.owner.set_a_intent(INTENT_HARM)
		RegisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HELP)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HELP)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT)

/datum/tutorialStep/newbee/intent_disarm
	name = "Disarm Intent"
	instructions = "The <span color=\"#EAC300\" font-weight=\"bold\">Disarm</span> intent will knock someone's item out of their hands or push them to the ground.<br>Press <b>2</b> to switch to the <span color=\"#EAC300\" font-weight=\"bold\">Disarm</span> intent."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/disarm = src.keymap.action_to_keybind("disarm")
		src.instructions = "The <span color=\"#EAC300\" font-weight=\"bold\">Disarm</span> intent will knock someone's item out of their hands or push them to the ground.<br>Press <b>[disarm ? disarm : "2"]</b> to switch to the <span color=\"#EAC300\" font-weight=\"bold\">Disarm</span> intent."

	SetUp()
		. = ..()
		if (src.tutorial.owner.intent == INTENT_DISARM)
			src.tutorial.owner.set_a_intent(INTENT_HELP)
		RegisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_DISARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_DISARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT)


/datum/tutorialStep/newbee/intent_grab
	name = "Grab Intent"
	instructions = "The <span color=\"#FF6A00\" font-weight=\"bold\">Grab</span> intent will grab someone. Click again or press <b>C</b> to strengthen your grip.<br>Press <b>3</b> to switch to the <span color=\"#FF6A00\" font-weight=\"bold\">Grab</span> intent."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/grab = src.keymap.action_to_keybind("grab")
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "The <span color=\"#FF6A00\" font-weight=\"bold\">Grab</span> intent will grab someone. Click again or press <b>[attackself ? attackself : "C"]</b> to strengthen your grip.<br>Press <b>[grab ? grab : "3"]</b> to switch to the <span color=\"#FF6A00\" font-weight=\"bold\">Grab</span> intent."

	SetUp()
		. = ..()
		if (src.tutorial.owner.intent == INTENT_GRAB)
			src.tutorial.owner.set_a_intent(INTENT_DISARM)
		RegisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_GRAB)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_GRAB)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT)


/datum/tutorialStep/newbee/intent_harm
	name = "Harm Intent"
	instructions = "The <span color=\"#B51214\" font-weight=\"bold\">Harm</span> intent will attack people, either by punching them or hitting them with what's in your hand. Press <b>4</b> to switch to the <span font-color='red'>Harm</span> intent."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/harm = src.keymap.action_to_keybind("harm")
		src.instructions = "The <span color=\"#B51214\" font-weight=\"bold\">Harm</span> intent will attack people, either by punching them or hitting them with what's in your hand. Press <b>[harm ? harm : "4"]</b> to switch to the <span color=\"#B51214\" font-weight=\"bold\">Harm</span> intent."

	SetUp()
		. = ..()
		if (src.tutorial.owner.intent == INTENT_HARM)
			src.tutorial.owner.set_a_intent(INTENT_GRAB)
		RegisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT, PROC_REF(check_intent))

	proc/check_intent(datum/source, intent)
		if (intent == INTENT_HARM)
			src.tutorial.PerformAction("set_a_intent", intent)

	PerformAction(action, context)
		. = ..()
		if (action == "set_a_intent" && context == INTENT_HARM)
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_MOB_SET_A_INTENT)

/obj/landmark/newbee/mouse
	name = LANDMARK_TUTORIAL_NEWBEE_MOUSE
	icon = 'icons/misc/critter.dmi'
	icon_state = "mouse_white"

/datum/tutorialStep/newbee/basic_combat
	name = "Basic Combat"
	instructions = "Uh oh, attack of the angry mouse!<br>Defend yourself with your fists or nearby items to continue!"

	var/mob/living/critter/small_animal/mouse/mad/mouse

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_MOUSE])
			if(src.region.turf_in_region(T))
				src.mouse = new /mob/living/critter/small_animal/mouse/mad(T)
				break
		RegisterSignal(src.mouse, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))
		src.mouse.UpdateOverlays(src.point_marker, "marker")

	proc/check_mob_death()
		if (isdead(src.mouse))
			src.tutorial.PerformAction("mob_death", "mouse")

	PerformAction(action, context)
		. = ..()
		if (action == "mob_death" && context == "mouse")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.mouse.UpdateOverlays(null, "marker")
		UnregisterSignal(src.mouse, COMSIG_MOB_DEATH)

/datum/tutorialStep/newbee/drop_item
	name = "Dropping Items"
	instructions = "Drop the item in your active hand by pressing <b>Q</b>."

	var/obj/item/held_item

	New()
		. = ..()
		var/drop_item = src.keymap.action_to_keybind("drop")
		src.instructions = "Drop the item in your active hand by pressing <b>[drop_item ? drop_item : "Q"]</b>."

	SetUp()
		. = ..()
		src.held_item = src.tutorial.owner.equipped()
		src.held_item.UpdateOverlays(src.point_marker, "marker")
		RegisterSignal(src.held_item, COMSIG_ITEM_DROPPED, PROC_REF(check_item_dropped))

	proc/check_item_dropped(item, mob/user)
		src.tutorial.PerformAction("item_dropped", "held_item")

	PerformAction(action, context)
		. = ..()
		if (action == "item_dropped" && context == "held_item")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.held_item.UpdateOverlays(null, "marker")
		UnregisterSignal(src.held_item, COMSIG_ITEM_DROPPED)

/obj/landmark/newbee/get_health
	name = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/health
	name = "Healing Up"
	instructions = "Your overall health is displayed in the top-right corner.<br>Head into the next room to patch yourself up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH

/obj/landmark/newbee/pickup_first_aid
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "brute1"

/datum/tutorialStep/newbee/item_pickup/first_aid
	name = "First Aid Kits"
	instructions = "You can heal yourself by using supplies from first aid kits.<br>Pick up the first aid kit to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID
	item_path = /obj/item/storage/firstaid/brute/tutorial

/datum/tutorialStep/newbee/storage_inhands
	name = "Opening Storage"
	instructions = "With the first aid kit in-hand, press <b>C</b> to open it."

	var/obj/item/storage/firstaid/brute/tutorial/target_firstaid

	New()
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "With the first aid kit in-hand, press <b>[attackself ? attackself : "C"]</b> to open it."

	SetUp()
		. = ..()
		src.target_firstaid = locate(/obj/item/storage/firstaid/brute/tutorial) in src.tutorial.owner
		src.target_firstaid?.UpdateOverlays(src.point_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "first_aid")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.target_firstaid?.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/hand_swap
	name = "Swapping Hands"
	instructions = "You can swap which hand is active by pressing <b>E</b>.<br>Swap to your open hand to continue."
	var/obj/item/storage/firstaid/brute/target_firstaid

	New()
		. = ..()
		var/swaphand = src.keymap.action_to_keybind("swaphand")
		src.instructions = "You can swap which hand is active by pressing <b>[swaphand ? swaphand : "E"]</b>.<br>Swap to your open hand to continue."

	SetUp()
		. = ..()
		src.target_firstaid = locate(/obj/item/storage/firstaid/brute) in src.tutorial.owner
		RegisterSignal(src.target_firstaid, COMSIG_ITEM_SWAP_AWAY, PROC_REF(check_swap))

	proc/check_swap()
		src.tutorial.PerformAction("swapped-hands")

	PerformAction(action, context)
		. = ..()
		if (action == "swapped-hands")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.target_firstaid, COMSIG_ITEM_SWAP_AWAY)

/datum/tutorialStep/newbee/timer/apply_patch
	name = "Applying Patches"
	instructions = "Grab a patch out of the first aid kit, and apply it by left-clicking yourself.<br>You can also press <b>C</b> to self-apply the patch."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Grab a patch out of the first aid kit, and apply it by left-clicking yourself.<br>You can also press <b>[attackself ? attackself : "C"]</b> to self-apply the patch."

/obj/landmark/newbee/exit_healing
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_healing
	instructions = "Now that you're patched up, head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING

/obj/landmark/newbee/decon_girder
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/examining
	name = "Examining Things"
	instructions = "Examine things by holding <b>ALT</b> and left-clicking them - text in blue boxes are usage hints.<br>Examine the girder to continue."

	// TODO: Keymap?

	var/obj/structure/girder/target_girder

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

/obj/landmark/newbee/pickup_toolbox
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "blue"

/datum/tutorialStep/newbee/item_pickup/toolbox
	name = "Toolboxes"
	instructions = "Toolboxes contain up to seven small items, usually tools.<br>Pick up the toolbox to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	item_path = /obj/item/storage/toolbox/mechanical

/datum/tutorialStep/newbee/move_to/deconstructing_girder
	name = "Deconstructing a Girder"
	instructions = "Examining the girder shows how to deconstruct it - we need a wrench.<br>Grab a wrench from the toolbox, and use it on the girder."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

	SetUp()
		. = ..()
		var/turf/target_turf
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER])
			if(src.region.turf_in_region(T))
				target_turf = T
				break

		var/obj/structure/girder/target_girder = locate(/obj/structure/girder) in target_turf
		if (!target_girder)
			new /obj/structure/girder(target_turf)

/obj/landmark/newbee/pickup_flashlight
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	icon = 'icons/obj/items/device.dmi'
	icon_state = "flight0"

/datum/tutorialStep/newbee/item_pickup/flashlight
	name = "Exploring Darkness"
	instructions = "The next area has no lights. Pick up the flashlight to help you navigate."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	item_path = /obj/item/device/light/flashlight/tutorial

/datum/tutorialStep/newbee/activating_items
	name = "Activating Items"
	instructions = "Some items require being used in-hand to function. Press <b>C</b> to use the flashlight in-hand.<br>Activate the flashlight to continue."

	New()
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Some items require being used in-hand to function. Press <b>[attackself ? attackself : "C"]</b> to use the flashlight in-hand.<br>Activate the flashlight to continue."

	PerformAction(action, context)
		. = ..() // custom item sends action
		if (action == "use_item" && context == "flashlight")
			src.finished = TRUE

/obj/landmark/newbee/enter_maints
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/enter_maints
	name = "Entering Maintenance"
	instructions = "Enter the maintenance tunnel."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS

/obj/landmark/newbee/traverse_maints
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/traversing_maints
	name = "Traversing Maintenance"
	instructions = "Head through the maintenance tunnel to get to the next area."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS

/obj/landmark/newbee/emergency_supply_closet
	name = LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET

/datum/tutorialStep/newbee/opening_closets
	name = "Emergency Closets"
	instructions = "Closets often contain specialized gear. Open closets by <b>left-clicking</b> on them with an open hand.<br>Open the emergency supply closet to continue."
	var/obj/storage/closet/emergency_tutorial/target_closet

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET])
			if(src.region.turf_in_region(T))
				src.target_closet = new(T)
				break
		src.newbee_tutorial.newbee.hud.show_inventory = TRUE

	PerformAction(action, context)
		. = ..()
		if (action == "open_storage" && context == "emergency_tutorial")
			src.finished = TRUE

	TearDown()
		. = ..()

/datum/tutorialStep/newbee/equip_space_suit
	name = "Space Suits"
	instructions = "Space suits help protect against the vacuum of space. Equip clothing by pressing <b>V</b>.<br>Equip the space suit to continue."

	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Space suits help protect against the vacuum of space. Equip clothing by pressing <b>[equip ? equip : "V"]</b>.<br>Equip the space suit to continue."

	SetUp()
		. = ..()
		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "suit")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/suit/space/emerg))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/equip_breath_mask
	name = "Breath Masks"
	instructions = "To breathe in space, you need a breath mask. Equip clothing by pressing <b>V</b>.<br>Equip the breath mask to continue."

	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "To breathe in space, you need a breath mask. Equip clothing by pressing <b>[equip ? equip : "V"]</b>.<br>Equip the breath mask to continue."

	SetUp()
		. = ..()

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "mask")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/mask/breath))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/equip_space_helmet
	name = "Space Helmets"
	instructions = "Space helmets complete your protection against space. Equip clothing by pressing <b>V</b>.<br>Equip the space helmet to continue."

	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Space helmets complete your protection against space. Equip clothing by pressing <b>[equip ? equip : "V"]</b>.<br>Equip the space helmet to continue."

	SetUp()
		. = ..()
		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "head")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && istype(context, /obj/item/clothing/head/emerg))
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")

/datum/tutorialStep/newbee/oxygen
	name = "Keep Breathing"
	instructions = "You need oxygen to breathe in areas without air, like space. Oxygen slowly depletes as you breathe.<br>Pick up an oxygen tank to continue."

	PerformAction(action, context)
		. = ..()
		if (action == "item_pickup" && istype(context, /obj/item/tank/oxygen))
			src.finished = TRUE

/datum/tutorialStep/newbee/internals
	name = "Using Internals"
	instructions = "You can get air from your oxygen tank by clicking the 'Toggle Tank Valve' button in the top-left corner.<br>Turn on your internals to continue."

	//TODO: Detection

/obj/landmark/newbee/enter_space
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/enter_space
	name = "Entering Space"
	instructions = "Now that you're ready, head through the airlock into space!"
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE

/obj/landmark/newbee/traverse_space
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/traversing_space
	name = "Traversing Space"
	instructions = "Behold, space! You slowly drift without solid ground under you.<br>Head to the airlock on the other side to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE

/obj/landmark/newbee/pickup_backpack
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK

/datum/tutorialStep/newbee/item_pickup/backpack
	name = "Backpack Storage"
	instructions = "Backpacks allow you to keep multiple items close at hand.<br>Pick up the backpack to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	item_path = /obj/item/storage/backpack/empty

/datum/tutorialStep/newbee/equip_backpack
	name = "Wearing a Backpack"
	instructions = "Just like your ID and space suit, you can wear a backpack by pressing <b>V</b>.<br>Equip the backpack to continue."

	var/obj/item/storage/backpack/empty/target_item
	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Just like your ID and space suit, you can wear a backpack by pressing <b>[equip ? equip : "V"]</b>.<br>Equip the backpack to continue."

	SetUp()
		. = ..()
		src.target_item = locate(/obj/item/storage/backpack/empty) in src.tutorial.owner
		RegisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "back")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "backpack")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "backpack")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/unequipping_worn_items
	name = "Storing Items"
	instructions = "With an item in your active hand, click on your backpack to store it.<br>Take off your space gear and put them in your backpack."

	//TODO: Detection

	SetUp()
		. = ..()

		// locate space suit
		// locate space helmet
		// log signal unequip

	proc/check_unequip()
		// validate both are unequipped?

	PerformAction(action, context)
		. = ..()

	TearDown()
		. = ..()
		// remove signals

/obj/landmark/newbee/exit_storage
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_storage
	name = "Backpack Storage"
	instructions = "Backpacks can store 7 items, including air tanks, boxes, and space suits.<br>Head into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE

//
// room 12 - black floor, dark purple border (Wall Decon)
//

/obj/landmark/newbee/pickup_welding_mask
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK

/datum/tutorialStep/newbee/item_pickup/welding_mask
	name = "Welding Masks"
	instructions = "Welding without proper eyewear is a bad idea. Pick up a welding mask to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	item_path = /obj/item/clothing/head/helmet/welding

	SetUp()
		. = ..()
		var/obj/item/clothing/head/helmet/welding/welding_mask = src._target_item
		welding_mask.flip_up(silent=TRUE)

/datum/tutorialStep/newbee/equip_welding_mask
	name = "Welding Masks"
	instructions = "Equip the welding mask and flip it down by clicking the icon in the top-left corner.<br>You can equip clothing with with <b>V</b>."
	var/obj/item/clothing/head/helmet/welding/target_item
	var/atom/movable/screen/hud/equipment_slot

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Equip the welding mask and flip it down by clicking the icon in the top-left corner.<br>You can equip clothing with with <b>[equip ? equip : "V"]</b>."

	SetUp()
		. = ..()
		src.target_item = locate(/obj/item/clothing/head/helmet/welding) in src.tutorial.owner
		RegisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "head")
				src.equipment_slot = hud_element
		src.equipment_slot.UpdateOverlays(src.box_marker, "marker")

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformSilentAction("item_equipped", "welding_mask")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "welding_mask")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.equipment_slot.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_item, COMSIG_ITEM_EQUIPPED)

/obj/landmark/newbee/pickup_weldingtool
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL

/datum/tutorialStep/newbee/item_pickup/weldingtool
	name = "Welding Tools"
	instructions = "Deconstructing walls requires a welding tool.<br>Pick up the welding tool to continue."

	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL
	item_path = /obj/item/weldingtool/tutorial

/datum/tutorialStep/newbee/using_welder
	name = "Using Welding Tools"
	instructions = "Light the welding too by pressing <b>C</b>. While lit, welding fuels will slowly use up fuel."

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		var/attackself = src.keymap.action_to_keybind("attackself")
		src.instructions = "Light the welding too by pressing <b>[attackself ? attackself : "C"]</b>. While lit, welding fuels will slowly use up fuel."

	PerformAction(action, context)
		. = ..()
		if (action == "use_item" && context == "weldingtool")
			src.finished = TRUE

/obj/landmark/newbee/decon_wall
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/decon_wall
	name = "Deconstructing a Wall"
	instructions = "Use the lit welding tool on the wall to slice off the outer cover."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

	SetUp()
		. = ..()
		RegisterSignal(src._target_destination, COMSIG_TURF_REPLACED, PROC_REF(check_turf_replaced))

	proc/check_turf_replaced(turf/replaced, turf/new_turf)
		src.tutorial.PerformSilentAction("turf_replaced")

	PerformAction(action, context)
		. = ..()
		if (action == "turf_replaced")
			src.finished = TRUE

	TearDown()
		UnregisterSignal(src._target_destination, COMSIG_TURF_REPLACED)
		. = ..()

/datum/tutorialStep/newbee/move_to/decon_wall_girder
	name = "Removing the Girder"
	instructions = "Now that the wall is gone, you can remove the girder with a wrench.<br>Proceed into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

//
// room 13 - yellow-white checker (Advanced Movement)
//

/obj/landmark/newbee/laying_down
	name = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/laying_down
	name = "Laying Down"
	instructions = "You can press <b>=</b> to lay down. Laying down will drop any items in your hands.<br>Crawl under the flaps to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN

	// TODO: Keymap
	// TODO: Highlight STAND button

/obj/landmark/newbee/sprinting
	name = LANDMARK_TUTORIAL_NEWBEE_SPRINTING
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/sprinting
	name = "Sprinting"
	instructions = "Hold <b>SHIFT</b> to sprint. Sprinting takes stamina, represented by a lightning bolt in the top right.<br>Sprint across these conveyors to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_SPRINTING

/obj/landmark/newbee/exit_movement
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/exit_movement
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT

//
// 	room 14 - blue/dark blue checker (Talking / Radio)
//

/datum/tutorialStep/newbee/say
	name = "Talking"
	instructions = "Talking is a great way to communicate! You can talk by pressing <b>T</b><br>Say something out loud to continue."

	SetUp()
		. = ..()
		RegisterSignal(src.tutorial.owner, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_ATOM_SAY)

/obj/landmark/newbee/pickup_headset
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	icon = 'icons/obj/clothing/item_ears.dmi'
	icon_state = "headset"

/datum/tutorialStep/newbee/item_pickup/headset
	name = "Headsets"
	instructions = "Headsets let you speak over radio channels.<br>Pick up the headset to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	item_path = /obj/item/device/radio/headset/tutorial

/datum/tutorialStep/newbee/equip_headset
	name = "Equipping Headsets"
	instructions = "Headsets go on your ear.<br>Equip the headset by pressing <b>V</b> or clicking the ear slot in your HUD."
	var/obj/item/device/radio/headset/tutorial/target_headset
	var/atom/movable/screen/hud/ears_slot

	SetUp()
		. = ..()
		src.target_headset = locate(/obj/item/device/radio/headset/tutorial) in src.tutorial.owner
		RegisterSignal(src.target_headset, COMSIG_ITEM_EQUIPPED, PROC_REF(check_item_equipped))

		for (var/atom/movable/screen/hud/hud_element in src.newbee_tutorial.newbee.hud.objects)
			if (hud_element.id == "ears")
				src.ears_slot = hud_element
		src.ears_slot.UpdateOverlays(src.box_marker, "marker")

	proc/check_item_equipped(datum/source, mob/equipper, slot)
		src.tutorial.PerformAction("item_equipped", "headset")

	PerformAction(action, context)
		. = ..()
		if (action == "item_equipped" && context == "headset")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.ears_slot.UpdateOverlays(null, "marker")
		UnregisterSignal(src.target_headset, COMSIG_ITEM_EQUIPPED)

/datum/tutorialStep/newbee/using_headset
	name = "Using the Radio"
	instructions = "Press <b>Y</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."

	New()
		. = ..()
		var/say_over_channel = src.keymap.action_to_keybind("say_over_channel")
		src.instructions = "Press <b>[say_over_channel ? say_over_channel : "Y"]</b> to get a list of radio channels, and press <b>ENTER</b> to select one.<br>Say something over the radio to continue."

	SetUp()
		. = ..()
		RegisterSignal(src.tutorial.owner, COMSIG_ATOM_SAY, PROC_REF(check_say))

	proc/check_say(source, datum/say_message/message)
		if (message.prefix)
			src.tutorial.PerformAction("atom_say", "say")

	PerformAction(action, context)
		. = ..()
		if (action == "atom_say" && context == "say")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.tutorial.owner, COMSIG_ATOM_SAY)

/obj/landmark/newbee/exit_radio
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO

/datum/tutorialStep/newbee/move_to/exit_radio
	name = "Radio Channels"
	instructions = "Each department has their own dedicated radio channel.<br>Move into the next room to learn about pulling objects."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO

//
// room 15 - hallway (Pulling)
//

/datum/tutorialStep/newbee/pull_start
	name = "Pulling Objects"
	instructions = "You can pull objects (and people!) by holding <b>CTRL</b> and left-clicking.<br>Start pulling the water tank to continue."

	// TODO: Keymap
	// TODO: Detection

	proc/check_pull()
		src.tutorial.PerformAction("pull", "water_tank")

	PerformAction(action, context)
		. = ..()
		if (action == "pull" && context == "water_tank")
			src.finished = TRUE

	TearDown()
		. = ..()

/obj/landmark/newbee/pull_target
	name = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/pull_target
	name = "Pull the Tank"
	instructions = "Walk to the marker while pulling the water tank to move it out of your way."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET

/datum/tutorialStep/newbee/pull_end
	name = "Stop Pulling"
	instructions = "Press <b>CTRL</b> and left-click far away to stop pulling the water tank.<br>You can also press the PULL button in your hud to stop pulling."

	// TODO: Keymap
	// TODO: Highlight PULL button
	// TODO: Detection

/obj/landmark/newbee/final_room
	name  = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/datum/tutorialStep/newbee/move_to/final_room
	name = "Almost Done!"
	instructions = "You're almost a fully functioning space-farer! There's just one more thing to learn...<br>Head into the final room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM

//
// room 16 - escape (Advanced Combat)
//

/obj/landmark/newbee/clown_murder
	name = LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER

/datum/tutorialStep/newbee/murder
	name = "Advanced Combat"
	instructions = "To activate the special attack of some items, left-click far away and use <span color=\"#EAC300\"><b>Disarm</b></span> or <span color=\"#B51214\"><b>Harm</b></span> intent.<br><span color=\"#962121\" font-weight=\"bold\">Kill the clown</span> to complete the tutorial."
	var/turf/target_location
	var/mob/living/carbon/human/tutorial_clown/tutorial_clown

	SetUp()
		. = ..()
		for(var/turf/T in landmarks[LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER])
			if(src.region.turf_in_region(T))
				src.tutorial_clown = new(T)
				break
		src.tutorial_clown.UpdateOverlays(src.point_marker, "marker")
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
		src.tutorial_clown.UpdateOverlays(null, "marker")
		UnregisterSignal(src.tutorial_clown, COMSIG_MOB_DEATH)
		if (src.tutorial_clown)
			src.tutorial_clown.gib()

/datum/tutorialStep/newbee/timer/following_rules
	name = "Server Rules"
	instructions = "The 'Rules' verb is located in the Commands tab above the chat top-right.<br>The 'RP Rules' verb is in the same tab.<br><b>Not knowing the rules isn't an excuse for breaking 'em!</b>"

/datum/tutorialStep/newbee/timer/getting_help
	name = "Getting Help"
	instructions = "The <a href=\"https://wiki.ss13.co/\">Wiki</a> has detailed guides and information.<br>If you have gameplay questions in-game, press <b>F3</b> to ask mentors.<br>If you have rules questions in-game, press <b>F1</b> to ask administrators."

	// TODO: Keymap

/datum/tutorialStep/newbee/timer/finished
	name = "Tutorial Complete!"
	instructions = "Congratulations on completing the basic tutorial!<br>There is a lot more to learn and do, so enjoy the game!<br>Returning to the main menu..."

	SetUp()
		..()
		// src.newbee_tutorial.newbee.unlock_medal("NT Certified") // TODO: Implement Medal
		playsound(src.tutorial.owner, pick(20;'sound/misc/openlootcrate.ogg',100;'sound/misc/openlootcrate2.ogg'), 60, 0)

// Tutorial UI Buttons

/datum/abilityHolder/newbee
	usesPoints = FALSE
	tabName = "Tutorial"
/datum/targetable/newbee
	icon = 'icons/mob/tutorial_ui.dmi'
	icon_state = "frame"
	targeted = 0
	do_logs = FALSE

/datum/targetable/newbee/exit
	name = "Exit Tutorial"
	desc = "Exit the tutorial and go to the main menu."
	icon_state = "exit"

	cast(atom/target)
		. = ..()
		src.holder.owner.client?.tutorial.Finish()

/datum/targetable/newbee/previous
	name = "Previous Step"
	desc = "Go back one step in the tutorial."
	icon_state = "previous"

	cast(atom/target)
		. = ..()
		var/datum/tutorial_base/tutorial = src.holder.owner.client?.tutorial
		if (tutorial.current_step <= 1)
			boutput(src.holder.owner, SPAN_ALERT("You're already at the first step!"))
			return
		var/datum/tutorialStep/current_step = tutorial.steps[tutorial.current_step]
		current_step.TearDown()
		tutorial.current_step -= 1
		var/datum/tutorialStep/previous_step = tutorial.steps[tutorial.current_step]
		tutorial.ShowStep()
		previous_step.SetUp()

/datum/targetable/newbee/next
	name = "Next Step"
	desc = "Go forward one step in the tutorial."
	icon_state = "next"

	cast(atom/target)
		. = ..()
		src.holder.owner.client?.tutorial?.Advance()

//
// tutorial mobs
//

/// Newbee Tutorial mob; no headset or PDA, does not spawn via jobs
/mob/living/carbon/human/tutorial
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/rank/assistant, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)

	gib(give_medal, include_ejectables)
		if (src.client?.tutorial)
			src.death(TRUE) // don't actually blow us up, thanks
		else
			. = ..(give_medal, include_ejectables)

	ghostize()
		if (src.client?.tutorial)
			src.death()
			return null
		else
			. = ..()

	death(gibbed)
		if (src.client?.tutorial)
			var/datum/tutorial_base/regional/newbee/current_tutorial = src.client.tutorial
			for(var/turf/T in landmarks[current_tutorial.checkpoint_landmark])
				if(current_tutorial.region.turf_in_region(T))
					src.set_loc(T)
					showswirl(T)
					break

			src.full_heal()
			boutput(src, SPAN_ALERT("Whoa, you almost died! Let's try that again..."))
		else
			. = ..(gibbed)

/// Newbee Tutorial mob; the clown you kill to Win the Tutorial
/mob/living/carbon/human/tutorial_clown
	New()
		. = ..()
		src.equip_new_if_possible(/obj/item/clothing/mask/clown_hat, SLOT_WEAR_MASK)
		src.equip_new_if_possible(/obj/item/clothing/under/misc/clown, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/clown_shoes, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/storage/fanny/funny, SLOT_BELT)
		src.equip_new_if_possible(/obj/item/instrument/bikehorn, SLOT_L_HAND)
		src.equip_new_if_possible(/obj/item/bananapeel, SLOT_R_HAND)
		var/obj/item/card/id/clown/clown_id = new()
		clown_id.registered = "The Clown You Kill To End the Tutorial"
		clown_id.assignment = "Clown"
		src.equip_if_possible(clown_id, SLOT_WEAR_ID)

/mob/living/carbon/human/tutorial/verb/stop_newbee_tutorial()
	set name = "Stop Tutorial"
	if (!src.client.tutorial)
		boutput(src, SPAN_ALERT("You're not in a tutorial. It's real. IT'S ALL REAL."))
		return
	src.client.tutorial.Finish()
	src.client.tutorial = null

//
// tutorial objects
//

/obj/item/card/id/engineering/tutorial
	name = ""
	access = list(access_engineering_power)

/obj/item/storage/firstaid/brute/tutorial
	attack_self(mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("open_storage", "first_aid")

/obj/item/device/light/flashlight/tutorial
	toggle(mob/user, activated_inhand)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("use_item", "flashlight")

/obj/item/weldingtool/tutorial
	fuel_capacity = 999

	attack_self(mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("use_item", "weldingtool")

/// Guaranteed to contain everything needed for a space walk
/obj/storage/closet/emergency_tutorial
	name = "emergency supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with emergency equipment."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergency-open"

	make_my_stuff()
		if(..())
			var/obj/item/clothing/suit/space/emerg/emergency_suit = new(src)
			emergency_suit.layer = OBJ_LAYER + 0.04
			RegisterSignal(emergency_suit, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
			RegisterSignal(emergency_suit, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))

			var/obj/item/clothing/mask/breath/breath_mask = new(src)
			breath_mask.layer = OBJ_LAYER + 0.03
			RegisterSignal(breath_mask, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
			RegisterSignal(breath_mask, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))

			var/obj/item/clothing/head/emerg/emergency_helmet = new(src)
			emergency_helmet.layer = OBJ_LAYER + 0.02
			RegisterSignal(emergency_helmet, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
			RegisterSignal(emergency_helmet, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))

			var/obj/item/tank/oxygen/oxygen_tank = new(src)
			oxygen_tank.layer = OBJ_LAYER + 0.01
			RegisterSignal(oxygen_tank, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))

	proc/pickup_tutorial_item(datum/source, mob/user)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_pickup", source)

	proc/equip_tutorial_item(datum/source, mob/equipper, slot)
		if (equipper.client?.tutorial)
			equipper.client.tutorial.PerformSilentAction("item_equipped", source)

	open(entangleLogic, mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("open_storage", "emergency_tutorial")

/obj/machinery/crusher/slow/tutorial
	finish_crushing(atom/movable/AM)
		if (istype(AM, /mob/living/carbon/human/tutorial))
			var/mob/M = AM
			M.gib() // don't qdel the tutorial mob
			return
		else
			. = ..()

/obj/item/device/radio/headset/tutorial
	hardened = TRUE // needs to always work
	protected_radio = TRUE
	locked_frequency = TRUE

	var/radio_freq_alpha
	var/radio_freq_beta

/obj/item/device/radio/headset/tutorial/New()
	. = ..()
	src.radio_freq_alpha = src.pick_randomized_freq()
	global.protected_frequencies += src.radio_freq_alpha

	src.radio_freq_beta = src.pick_randomized_freq()
	global.protected_frequencies += src.radio_freq_beta

	src.bricked = FALSE // always. work.

	src.secure_frequencies = list(
		"a" = src.radio_freq_alpha,
		"b" = src.radio_freq_beta,
	)
	src.secure_classes = list(
		"a" = RADIOCL_ENGINEERING,
		"b" = RADIOCL_RESEARCH,
	)

	SPAWN(1 SECOND)
		src.frequency = src.radio_freq_alpha

/obj/item/device/radio/headset/tutorial/proc/pick_randomized_freq()
	var/list/blacklisted = list(FREQ_SIGNALER)
	blacklisted.Add(R_FREQ_BLACKLIST)
	blacklisted += global.protected_frequencies

	do
		. = rand(1352, 1439)
	while (blacklisted.Find(.))

/obj/item/device/radio/headset/tutorial/disposing()
	. = ..()
	global.protected_frequencies -= src.radio_freq_alpha
	global.protected_frequencies -= src.radio_freq_beta
