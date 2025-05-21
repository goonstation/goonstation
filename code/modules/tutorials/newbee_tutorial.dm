//TODO: Current/Total step counter?

/// How long before auto-continuing for timed steps. Matches the related tutorial timer animation duration.
#define NEWBEE_TUTORIAL_TIMER_DURATION 10.2 SECONDS
/// Use a large target marker, good for turfs
#define NEWBEE_TUTORIAL_TARGETING_MARKER 0
/// Use a point marker, good for items
#define NEWBEE_TUTORIAL_TARGETING_POINT 1

/area/tutorial/newbee
	name = "Newbee Tutorial Zone"
	icon_state = "green"
	sound_group = "newbee"

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

	// room 2 - grey floor, yellow border (ID-locked Doors)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/id_card)
	src.AddStep(/datum/tutorialStep/newbee/wear_id_card)
	src.AddStep(/datum/tutorialStep/newbee/move_to/id_locked_doors)

	// room 3 - grey floor, green border (Unpowered Doors)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/crowbar)
	src.AddStep(/datum/tutorialStep/newbee/move_to/unpowered_doors)

	// room 4 - grey floor, red border (Basic Combat)
	src.AddStep(/datum/tutorialStep/newbee/basic_combat)
	src.AddStep(/datum/tutorialStep/newbee/timer/intents)
	src.AddStep(/datum/tutorialStep/newbee/drop_item)
	src.AddStep(/datum/tutorialStep/newbee/move_to/health)

	// room 5 - white floor, blue border (Healing)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/first_aid)
	src.AddStep(/datum/tutorialStep/newbee/storage_inhands)
	src.AddStep(/datum/tutorialStep/newbee/hand_swap)
	src.AddStep(/datum/tutorialStep/newbee/timer/apply_patch)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_healing)

	// room 6 - white floor, black border (Girder Decon)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/toolbox)
	src.AddStep(/datum/tutorialStep/newbee/examining)
	src.AddStep(/datum/tutorialStep/newbee/move_to/deconstructing_girder)

	// room 7 - white floor, dark blue border (Active Items)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/flashlight)
	src.AddStep(/datum/tutorialStep/newbee/activating_items)
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_maints)

	// room 8 - maints (Dark Areas)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_maints)

	// room 9 - green/blue checker floor (Space Prep)
	src.AddStep(/datum/tutorialStep/newbee/opening_closets)
	src.AddStep(/datum/tutorialStep/newbee/equipping_spacesuit)
	src.AddStep(/datum/tutorialStep/newbee/oxygen)
	src.AddStep(/datum/tutorialStep/newbee/move_to/enter_space)

	// room 10 - space (Space Traversal)
	src.AddStep(/datum/tutorialStep/newbee/move_to/traversing_space)

	// room 11 - black floor, green border (Storage)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/backpack)
	src.AddStep(/datum/tutorialStep/newbee/equip_backpack)
	src.AddStep(/datum/tutorialStep/newbee/unequipping_worn_items)
	src.AddStep(/datum/tutorialStep/newbee/backpack_storage)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_storage)

	// room 12 - black floor, dark purple border (Wall Decon)
	src.AddStep(/datum/tutorialStep/newbee/item_pickup/welding_mask)
	src.AddStep(/datum/tutorialStep/newbee/equip_welding_mask)
	// using welder in-hand?
	src.AddStep(/datum/tutorialStep/newbee/move_to/decon_wall)
	// tell them how to decon girder again?

	// room 13 - black floor, dark blue border (Rules)
	src.AddStep(/datum/tutorialStep/newbee/timer/following_rules)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_rules)

	// room 14 - blue/dark blue checker (Help)
	src.AddStep(/datum/tutorialStep/newbee/timer/getting_help)
	src.AddStep(/datum/tutorialStep/newbee/move_to/exit_help)

	// room 15 - hallway (Pulling)
	src.AddStep(/datum/tutorialStep/newbee/pull)
	src.AddStep(/datum/tutorialStep/newbee/move_to/final_room)

	// room 16 - escape (Combat 2)
	src.AddStep(/datum/tutorialStep/newbee/murder)
	src.AddStep(/datum/tutorialStep/newbee/timer/finished)

/datum/tutorialStep/newbee
	var/static/image/destination_marker = null
	var/static/image/point_marker = null
	var/datum/tutorial_base/regional/newbee/newbee_tutorial
	var/datum/allocated_region/region
	var/datum/keymap/keymap


	New(datum/tutorial_base/regional/newbee/tutorial)
		src.newbee_tutorial = tutorial
		src.region = tutorial.region
		src.keymap = tutorial.keymap
		if (!src.destination_marker)
			src.destination_marker = image('icons/effects/VR.dmi', "lightning_marker", EFFECTS_LAYER_1)
			src.destination_marker.alpha = 100
			src.destination_marker.plane = PLANE_HUD
			src.destination_marker.filters = filter(type="outline", size=1)
		if (!src.point_marker) // TODO: animate point from your character to target like manual pointing
			src.point_marker = image('icons/mob/screen1.dmi', "arrow", EFFECTS_LAYER_1, pixel_y=8)
			src.point_marker.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
			src.point_marker.plane = PLANE_HUD
		..()

// subtypes with common behavior

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
		src.newbee_tutorial.tutorial_hud.stop_timer()

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

/datum/tutorialStep/newbee/move_to/powered_doors
	name = "Powered Doors"
	instructions = "Powered doors will open when you walk into them.<br>Head into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS


/obj/landmark/newbee/pickup_id_card
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD

/datum/tutorialStep/newbee/item_pickup/id_card
	name = "Picking Up Items"
	instructions = "Pick up items by left-clicking them.<br>Pick up <b>the ID card</b> to continue."
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
	var/obj/item/card/id/engineering/tutorial/target_card

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("equip")
		src.instructions = "Some items can be worn. Press <b>[equip ? equip : "V"]</b> to equip the ID card."

	SetUp()
		. = ..()
		src.target_card = locate(/obj/item/card/id/engineering/tutorial) in src.tutorial.owner
		RegisterSignal(src.target_card, COMSIG_ITEM_EQUIPPED, PROC_REF(check_equip))

	proc/check_equip(datum/source, mob/equipper, slot)
		src.tutorial.PerformAction("equipped-id_card")

	PerformAction(action, context)
		. = ..()
		if (action == "equipped-id_card")
			src.finished = TRUE

	TearDown()
		. = ..()
		UnregisterSignal(src.target_card, COMSIG_ITEM_EQUIPPED)

/obj/landmark/newbee/idlock_doors
	name = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS

/datum/tutorialStep/newbee/move_to/id_locked_doors
	name = "ID-Locked Doors"
	instructions = "Some doors require a valid ID to use.<br>Head into the next room to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS

/obj/landmark/newbee/pickup_crowbar
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR

/datum/tutorialStep/newbee/item_pickup/crowbar
	name = "Usable Items"
	instructions = "Some items are useful tools during dangerous situations.<br>Pick up the crowbar to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	item_path = /obj/item/crowbar

/obj/landmark/newbee/unpowered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS

/datum/tutorialStep/newbee/move_to/unpowered_doors
	name = "Unpowered Doors"
	instructions = "Unpowered doors can be opened with crowbars.<br>Open this unpowered door and head into the next room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

/obj/landmark/newbee/mouse_one
	name = LANDMARK_TUTORIAL_NEWBEE_MOUSE_ONE

/obj/landmark/newbee/mouse_two
	name = LANDMARK_TUTORIAL_NEWBEE_MOUSE_TWO

/datum/tutorialStep/newbee/basic_combat
	name = "Basic Combat"
	instructions = "Uh oh, attack of the angry mice!<br>Switch to harm intent by pressing <b>4</b> and click on the mice to fight back!"
	var/mob/living/critter/small_animal/mouse/mad/mouse_one
	var/mob/living/critter/small_animal/mouse/mad/mouse_two

	New()
		. = ..()
		var/harm = src.keymap.action_to_keybind("harm")
		src.instructions = "Uh oh, attack of the angry mice!<br>Switch to harm intent by pressing <b>[harm ? harm : 4]</b> and click on the mice to fight back!"

	SetUp()
		. = ..()
		for(var/turf/T1 in landmarks[LANDMARK_TUTORIAL_NEWBEE_MOUSE_ONE])
			if(src.region.turf_in_region(T1))
				src.mouse_one = new /mob/living/critter/small_animal/mouse/mad(T1)
				break
		RegisterSignal(src.mouse_one, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))
		src.mouse_one.UpdateOverlays(src.point_marker, "marker")

		for(var/turf/T2 in landmarks[LANDMARK_TUTORIAL_NEWBEE_MOUSE_ONE])
			if(src.region.turf_in_region(T2))
				src.mouse_two = new /mob/living/critter/small_animal/mouse/mad(T2)
				break
		RegisterSignal(src.mouse_two, COMSIG_MOB_DEATH, PROC_REF(check_mob_death))
		src.mouse_two.UpdateOverlays(src.point_marker, "marker")

	proc/check_mob_death()
		if (isdead(src.mouse_one) && isdead(src.mouse_two))
			src.tutorial.PerformAction("death-mice")

	PerformAction(action, context)
		. = ..()
		if (action == "death-mice")
			src.finished = TRUE

	TearDown()
		. = ..()
		src.mouse_one.UpdateOverlays(null, "marker")
		src.mouse_two.UpdateOverlays(null, "marker")
		UnregisterSignal(src.mouse_one, COMSIG_MOB_DEATH)
		UnregisterSignal(src.mouse_two, COMSIG_MOB_DEATH)

/datum/tutorialStep/newbee/timer/intents
	name = "Intents"
	instructions = "You have four intents: Help, Disarm, Grab, and Harm.<br>You can swap between them by pressing <b>1</b>, <b>2</b>, <b>3</b>, or <b>4</b> respectively on your number row."

	New()
		. = ..()
		var/help = src.keymap.action_to_keybind("help")
		var/disarm = src.keymap.action_to_keybind("disarm")
		var/grab = src.keymap.action_to_keybind("grab")
		var/harm = src.keymap.action_to_keybind("harm")
		src.instructions = "You have four intents: Help, Disarm, Grab, and Harm.<br>You can swap between them by pressing <b>[help ? help : 1]</b>, <b>[disarm ? disarm : 2]</b>, <b>[grab ? grab : 3]</b>, or <b>[harm ? harm : 4]</b> respectively on your number row."


/datum/tutorialStep/newbee/drop_item
	name = "Dropping Items"
	instructions = "Drop the item in your active hand by pressing <b>Q</b>."

	New()
		. = ..()
		var/drop_item = src.keymap.action_to_keybind("drop")
		src.instructions = "Drop the item in your active hand by pressing <b>[drop_item]</b>."

	SetUp()
		. = ..()
		// COMSIG_ITEM_DROPPED

/obj/landmark/newbee/get_health
	name = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH

/datum/tutorialStep/newbee/move_to/health
	name = "Healing Up"
	instructions = "Your overall health is displayed in the top-right corner.<br>Head into the next room to patch yourself up."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_GET_HEALTH

/obj/landmark/newbee/pickup_first_aid
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID

/datum/tutorialStep/newbee/item_pickup/first_aid
	name = "First Aid Kits"
	instructions = "You can heal yourself by using supplies from first aid kits.<br>Pick up the first aid kit to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRST_AID
	item_path = /obj/item/storage/firstaid/brute

/datum/tutorialStep/newbee/storage_inhands
	name = "Opening Storage"
	instructions = "With the first aid kit in-hand, press <b>C</b> to open it."
	var/obj/item/storage/firstaid/brute/target_firstaid

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("attackself")
		src.instructions = "With the first aid kit in-hand, press <b>[equip ? equip : "C"]</b> to open it."

	SetUp()
		. = ..()
		src.target_firstaid = locate(/obj/item/storage/firstaid/brute) in src.tutorial.owner
		RegisterSignal(src.target_firstaid)

	proc/check_storage()

	PerformAction(action, context)
		. = ..()

	TearDown()
		. = ..()

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
	instructions = "Grab a patch out of the first aid kit, and apply it to yourself by left-clicking.<br>You can also press <b>C</b> to self-apply the patch."

/obj/landmark/newbee/exit_healing
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING

/datum/tutorialStep/newbee/move_to/exit_healing
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALING

/obj/landmark/newbee/pickup_toolbox
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX

/datum/tutorialStep/newbee/item_pickup/toolbox
	name = "Toolboxes"
	instructions = "Toolboxes contain up to seven small items, usually tools.<br>Pick up the toolbox to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	item_path = /obj/item/storage/toolbox/mechanical

// TODO: This step
/datum/tutorialStep/newbee/examining
	name = "Examining Things"
	instructions = "Examine things by holding <b>ALT</b> and left-clicking them - text in blue boxes are usage hints.<br>Examine the girder to continue."

	New()
		. = ..()
		// examine keybind in instructions

	SetUp()
		. = ..()
		// COMSIG_ATOM_EXAMINE

/obj/landmark/newbee/decon_girder
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER

/datum/tutorialStep/newbee/move_to/deconstructing_girder
	name = "Deconstructing a Girder"
	instructions = "Examining the girder shows how to deconstruct it - we need a wrench.<br>Grab a wrench from the toolbox, and use it on the girder."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	targeting_type = NEWBEE_TUTORIAL_TARGETING_POINT

/obj/landmark/newbee/pickup_flashlight
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT

/datum/tutorialStep/newbee/item_pickup/flashlight
	name = "Exploring Darkness"
	instructions = "The next area has no lights. Pick up a <b>flashlight</b> to help you navigate."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	item_path = /obj/item/device/light/flashlight

// TODO: This step
/datum/tutorialStep/newbee/activating_items
	name = "Activating Items"
	instructions = "Some items require using in-hand to activate. Press <b>C</b> when the flashlight is in your hand to activate it."

	New()
		. = ..()
		var/equip = src.keymap.action_to_keybind("attackself")
		src.instructions = "Some items require using in-hand to activate. Press press <b>[equip ? equip : "C"]</b>  when the flashlight is in your hand to activate it."

	SetUp()
		. = ..()
		// ITEM PICKUP

/obj/landmark/newbee/enter_maints
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS

/datum/tutorialStep/newbee/move_to/enter_maints
	name = "Entering Maintenance"
	instructions = "Enter the maintenance tunnel."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS

/obj/landmark/newbee/traverse_maints
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS

/datum/tutorialStep/newbee/move_to/traversing_maints
	name = "Traversing Maintenance"
	instructions = "Head through the maintenance tunnel to get to the next area."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS

/obj/landmark/newbee/emergency_supply_closet
	name = LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET

// TODO: This step
/datum/tutorialStep/newbee/opening_closets
	name = "Emergency Closets"
	instructions = "Closets often contain specialized gear.<br>Open the emergency supply closet to continue."

	SetUp()
		. = ..()

	TearDown()
		. = ..()

// TODO: This step
/datum/tutorialStep/newbee/equipping_spacesuit
	name = "Equipping Space Gear"
	instructions = "You can equip clothing items by pressing 'V'.<br>Equip the space suit, helmet, and breath mask."

	New()
		. = ..()
		// equip item keybind in instructions

	SetUp()
		. = ..()
		// EQUIP

// TODO: This step
/datum/tutorialStep/newbee/oxygen
	name = "Keep Breathing"
	instructions = "Pick up an oxygen tank, then click the 'internals' button on the top left to turn on internals."

/obj/landmark/newbee/enter_space
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE

/datum/tutorialStep/newbee/move_to/enter_space
	name = "Entering Space"
	instructions = "Head through the airlock into space!"
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE

/obj/landmark/newbee/traverse_space
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE

/datum/tutorialStep/newbee/move_to/traversing_space
	name = "Traversing Space"
	instructions = "Behold, space! You slowly drift in space - good thing you're suited up!<br>Head to the airlock on the other side to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE

/obj/landmark/newbee/pickup_backpack
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK

/datum/tutorialStep/newbee/item_pickup/backpack
	name = "Backpack Storage"
	instructions = "Backpacks allow you to keep multiple items close at hand.<br>Pick up the backpack to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	item_path = /obj/item/storage/backpack/empty

// TODO: this step
/datum/tutorialStep/newbee/equip_backpack
	name = "Wearing a Backpack"
	instructions = "Just like your ID and space suit, you can wear a backpack by pressing <b>V</b>"

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		// keymap lookup

	SetUp()
		. = ..()
		// signal

	proc/check_equip()

	PerformAction(action, context)
		. = ..()
		// next

	TearDown()
		. = ..()


// TODO: This step
/datum/tutorialStep/newbee/unequipping_worn_items
	name = "Unequipping Items"
	instructions = "Space suits and helmets slow you down on solid ground.<br>Take off your space gear by clicking on them with an empty hand."

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

// TODO: This step
/datum/tutorialStep/newbee/backpack_storage
	name = "Backpack Storage"
	instructions = "You can store items in your backpack. With an item in your active hand, click on your backpack to store it. Backpacks can store <b>7 items</b>, including air tanks, boxes, and space suits. Small items like tools can fit in boxes."

/obj/landmark/newbee/exit_storage
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE

/datum/tutorialStep/newbee/move_to/exit_storage
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE

/obj/landmark/newbee/pickup_welding_mask
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK

/datum/tutorialStep/newbee/item_pickup/welding_mask
	name = "Workplace Safety #1"
	instructions = "Welding without proper eyewear is a bad idea. Pick up a welding mask to continue."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	item_path = /obj/item/clothing/head/helmet/welding

// TODO: This step
/datum/tutorialStep/newbee/equip_welding_mask
	name = "Workplace Safety #2"
	instructions = "Now equip the welding mask with 'V' and flip it down by clicking the icon in the top-left corner.<br>Wearing a space helmet or welding mask will prevent eye damage from welds!"

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		// TODO: keymap

/obj/landmark/newbee/decon_wall
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL

/datum/tutorialStep/newbee/move_to/decon_wall
	name = "Deconstructing a Wall"
	instructions = "There's a wall blocking your way. From the toolbox, pick up a welding tool, activate it by pressing 'C', then click on the wall to begin removing it."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL

	New(datum/tutorial_base/regional/newbee/tutorial)
		. = ..()
		// TODO: keymap

/datum/tutorialStep/newbee/timer/following_rules
	name = "Following Rules"
	instructions = "You can view the rules by going to the Commands tab top-right and selecting the 'Rules' command.<br>On our RP servers, you must also follow the RP Rules, viewed the same way."

/obj/landmark/newbee/exit_rules
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_RULES

/datum/tutorialStep/newbee/move_to/exit_rules
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_RULES

/datum/tutorialStep/newbee/timer/getting_help
	name = "Getting Help"
	instructions = "If you have gameplay questions, press 'F3' to ask our mentors.<br>If you have rules questions, press 'F1' to ask our administrators."

/obj/landmark/newbee/exit_help
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_HELP

/datum/tutorialStep/newbee/move_to/exit_help
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_EXIT_HELP

// TODO: This Step
/datum/tutorialStep/newbee/pull
	name = "Pulling Objects"
	instructions = "The water tank is in your way. Hold 'Control' and left-click on it to begin pulling it, then walk to the right to move it out of the way."

	New()
		. = ..()
		// pull item keybind in instructions

/obj/landmark/newbee/final_room
	name  = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM

/datum/tutorialStep/newbee/move_to/final_room
	instructions = "Head into the final room."
	target_landmark = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM

/obj/landmark/newbee/clown_murder
	name = LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER

/datum/tutorialStep/newbee/murder
	name = "Advanced Combat"
	instructions = "Some items have <b>special attacks</b>. You can activate a special attack by being in <b>Disarm</b> or <b>Harm</b> intent and clicking a far-away tile. Kill the clown to complete the tutorial."
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

/datum/tutorialStep/newbee/timer/finished
	name = "Tutorial Complete!"
	instructions = "Congratulations on completing the basic tutorial!<br>There is a lot more to learn and do, so enjoy the game!<br>Returning to the main menu shortly..."

	SetUp()
		..()
		// TODO: Give medal?
		playsound(src.tutorial.owner, pick(20;'sound/misc/openlootcrate.ogg',100;'sound/misc/openlootcrate2.ogg'), 60, 0)
		// playsound(src.tutorial.owner, 'sound/voice/heavenly3.ogg', 50, 0) // TODO: too long but maybe better?
		// we could rapture the mob on TearDown instead?

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

// tutorial mobs

/// Newbee Tutorial mob; no headset or PDA, does not spawn via jobs
/mob/living/carbon/human/tutorial
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/rank/assistant, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)

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

	death(gibbed)
		. = ..()
		// TODO: easter egg ending for feeding a living clown to the queen clownspider

/mob/living/carbon/human/tutorial/verb/stop_newbee_tutorial()
	set name = "Stop Tutorial"
	if (!src.client.tutorial)
		boutput(src, SPAN_ALERT("You're not in a tutorial. It's real. IT'S ALL REAL."))
		return
	src.client.tutorial.Finish()
	src.client.tutorial = null

// tutorial objects

/obj/item/card/id/engineering/tutorial
	name = ""
	access = list(access_engineering)

/// Guaranteed to contain everything needed for a space walk
/obj/storage/closet/emergency_tutorial
	name = "emergency supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with emergency equipment."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergency-open"

	make_my_stuff()
		if(..())
			new /obj/item/clothing/suit/space/emerg(src)
			new /obj/item/clothing/head/emerg(src)

			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/gas/emergency(src)

			new /obj/item/tank/oxygen(src)
			new /obj/item/tank/pocket/oxygen(src)
			new /obj/item/tank/mini/oxygen(src)
