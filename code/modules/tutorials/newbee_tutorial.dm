/area/tutorial/newbee
	name = "Newbee Tutorial Zone"
	icon_state = "green"
	sound_group = "newbee"

/obj/landmark/tutorial_clown
	name = "The Clown You Kill To End The Tutorial"
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/mob/new_player/verb/play_tutorial()
	set name = "Play Tutorial"
	set desc = "Launch the in-game tutorial!"
	set category = "Commands"

	if (global.current_state < GAME_STATE_PLAYING)
		boutput(usr, "You can only begin the tutorial after the game has started!")

	src.client?.tutorial = new(src)
	src.client?.tutorial.Start()

/datum/tutorial_base/regional/newbee
	name = "Newbee tutorial"
	var/mob/living/carbon/human/tutorial/newbee = null
	var/mob/new_player/origin_mob
	region_type = /datum/mapPrefab/allocated/newbee_tutorial

	New(mob/M)
		..()
		src.AddNewbeeSteps()
		src.exit_point = pick_landmark(LANDMARK_NEW_PLAYER)
		src.origin_mob = M
		src.newbee = new(src.initial_turf, M.client.preferences.AH, M.client.preferences, TRUE)
		src.owner = src.newbee

	Start()
		if (..())
			src.origin_mob.close_spawn_windows()
			src.origin_mob.mind.transfer_to(src.newbee)
			src.newbee.addAbility(/datum/targetable/newbee_tutorial_exit)

	Finish()
		if(..())
			var/mob/new_player/M = new()
			src.newbee.mind.transfer_to(M)
			qdel(src)

/datum/tutorial_base/regional/newbee/proc/AddNewbeeSteps()
	src.AddStep(/datum/tutorialStep/newbee/murder)
	src.AddStep(/datum/tutorialStep/newbee/finished)

/datum/tutorialStep/newbee
	var/static/image/marker = null

	New()
		..()
		if (!marker)
			marker = image('icons/effects/VR.dmi', "lightning_marker")
			marker.filters= filter(type="outline", size=1)

/datum/tutorialStep/newbee/welcome
	name = "Welcome to Space Station 13!"
	instructions = "This tutorial will get you familiar with the basics of the game. If at any point you get stuck or want to restart the tutorial, use the 'emergency tutorial stop' verb in the <b>Commands</b> tab, top right."

/datum/tutorialStep/newbee/movement
	name = "Movement"
	instructions = "Use 'W'/'A'/'S'/'D' to move around. Move north to the marker to continue."

/datum/tutorialStep/newbee/powered_doors
	name = "Doors"
	instructions = "Powered doors will open when you walk into them. Bump into the door to open it, and head into the next room."

/datum/tutorialStep/newbee/items
	name = "Items"
	instructions = "You can pick up items by left-clicking on them with an open hand. Pick up the crowbar to continue."

/datum/tutorialStep/newbee/unpowered_doors
	name = "Unpowered Doors"
	instructions = "This door is unpowered. Click on the door with a crowbar to open it and head into the next room."

/datum/tutorialStep/newbee/hand_swap
	name = "Swapping Hands"
	instructions = "You can swap whether your left or right hand is active with 'E'. You can only pick up items with an empty hand."

/datum/tutorialStep/newbee/storge_clickdrag
	name = "Toolboxes"
	instructions = "You can look through storage items by standing next to them and <b>click-dragging</b> it to your character. Retreieve the <b>wrench</b> from the toolbox below."

/datum/tutorialStep/newbee/examining
	name = "Examining Things"
	instructions = "You can hold 'ALT' and left-click something to <b>examine</b> it. Text in blue boxes are <i>Hints</i> that let you know special interactions or uses."

/datum/tutorialStep/newbee/deconstructing_girder
	name = "Deconstructing a Girder"
	instructions = "Examining the <b>Girder</b> reveals we need the <b>wrench</b> to deconstruct it. Use the wrench on the girder."

/datum/tutorialStep/newbee/basic_combat
	name = "Basic Combat"
	instructions = "Uh oh, attack of the angry mice! Defend yourself by clicking on the mouse with your crowbar or wrench!"

/datum/tutorialStep/newbee/drop_item
	name = "Dropping Items"
	instructions = "Phew, you made it - let's get you back up to full health! You can free up a hand by pressing 'Q' to drop your active item. "

/datum/tutorialStep/newbee/healing
	name = "Healing Up"
	instructions = "Keep an eye on your health in the top-right corner. Get a <b>patch</b> from the first aid kits, then click on yourself to apply it."

/datum/tutorialStep/newbee/activating_items
	name = "Using Items"
	instructions = "The next area is dark. Pick up a flashlight to help you navigate, and press 'C' when the flashlight is in your hand to activate it."

/datum/tutorialStep/newbee/traversing_maints
	name = "Traversing Maintenance"
	instructions = "Head through the maintenance tunnel to get to the next area."

/datum/tutorialStep/newbee/equipping_spacesuit
	name = "Equipping Gear"
	instructions = "You need EVA gear to survive in the cold depths of space. You can equip clothing items by pressing 'V'. Equip the space suit, helmet, and breath mask."

/datum/tutorialStep/newbee/oxygen
	name = "Keep Breathing"
	instructions = "Pick up an oxygen tank and left-click the button on the top left to turn on internals."

/datum/tutorialStep/newbee/traversing_space
	name = "Traversing Space"
	instructions = "While in space, you will slowly drift between solid footing. Get through this space area to the other side by heading south-west."

/datum/tutorialStep/newbee/unequipping_worn_items
	name = "Unequipping Items"
	instructions = "EVA suits are safe, but they make you move considerably slower on foot! Take off your space suit and helmet by clicking on them with an empty hand."

/datum/tutorialStep/newbee/backpack_storage
	name = "Backpack Storage"
	instructions = "You can store items in your backpack. With an item in your active hand, click on your backpack to store it. Backpacks can store <b>7 items</b>, including air tanks, boxes, and space suits. Small items like tools can fit in boxes."

/datum/tutorialStep/newbee/welding
	name = "Deconstructing a Wall"
	instructions = "There's a wall blocking your way. Pick up a <b>welding tool</b>, activate it by pressing 'C', then click on the wall to begin removing it. Wearing a space helmet or welding mask will prevent eye damage from welds!"

/datum/tutorialStep/newbee/pull
	name = "Pulling Objects"
	instructions = "The <b>water tank</b> is in your way. Hold 'Control' and left-click on it to begin pulling it, then walk to the right to move it out of the way."

/datum/tutorialStep/newbee/intents
	name = "Intents"
	instructions = "You have four <b>intents</b>: Help, Disarm, Grab, and Harm. You can swap between them by pressing '1', '2', '3', or '4' respectively on your number row. Swap to the <b>Harm</b> intent now."

/datum/tutorialStep/newbee/murder
	name = "Advanced Combat"
	instructions = "Some items have <b>special attacks</b>. You can activate a special attack by being in <b>Disarm</b> or <b>Harm</b> intent and clicking a far-away tile. Kill the clown to complete the tutorial."
	var/mob/living/carbon/human/tutorial_clown/tutorial_clown

	SetUp()
		. = ..()
		var/datum/tutorial_base/regional/blob/MT = tutorial
		var/tx = MT.initial_turf.x
		var/ty = MT.initial_turf.y - 12
		var/tz = MT.initial_turf.z
		// var/turf/T = locate(tx, ty, tz)
		// target = locate() in T
		// target.UpdateOverlays(marker,"marker")
		src.tutorial_clown = new(locate(tx, ty, tz))

	TearDown()
		. = ..()
		if (src.tutorial_clown)
			src.tutorial_clown.gib()

	MayAdvance()
		if (!src.tutorial_clown)
			return TRUE
		if (isdead(src.tutorial_clown))
			return TRUE


/datum/tutorialStep/newbee/finished
	name = "Finish up"
	instructions = "Congratulations! You have completed the basic tutorial. You will now be returned to the main menu."

	SetUp()
		..()
		sleep(5 SECONDS)
		tutorial.Advance()


// TODO: Leave button
/datum/targetable/newbee_tutorial_exit
	name = "Exit Tutorial"
	desc = "Exit the tutorial and go to the main menu."
	icon = 'icons/mob/blob_ui.dmi'
	icon_state = "blob-exit"
	targeted = 0
	special_screen_loc = "SOUTH,EAST-1"

/// Newbee Tutorial mob; no headset or PDA, does not spawn via jobs
/mob/living/carbon/human/tutorial
	New()
		..()
		src.equip_new_if_possible(/obj/item/clothing/under/rank/assistant, SLOT_W_UNIFORM)
		src.equip_new_if_possible(/obj/item/clothing/shoes/black, SLOT_SHOES)
		src.equip_new_if_possible(/obj/item/storage/backpack, SLOT_BACK)

	death(gibbed)
		. = ..()
		if (src.client?.tutorial)
			src.client.tutorial.Finish()

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

	death(gibbed)
		. = ..()
		if (istype(src.lastattacker?.deref(), /mob/living/carbon/human/tutorial))
			var/mob/living/carbon/human/tutorial/tutorial_owner = src.lastattacker.deref()
			tutorial_owner.client.tutorial.Finish()

/mob/living/carbon/human/tutorial/verb/emergency_tutorial_stop()
	set name = "EMERGENCY TUTORIAL STOP"
	if (!src.client.tutorial)
		boutput(src, SPAN_ALERT("You're not in a tutorial. It's real. IT'S ALL REAL."))
		return
	src.client.tutorial.Finish()
	src.client.tutorial = null

