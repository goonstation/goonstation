
/obj/landmark/newbee
	deleted_on_start = FALSE

/obj/landmark/newbee/Crossed(atom/movable/AM)
	..()
	if (!ismob(AM) || !isliving(AM))
		return
	var/mob/M = AM
	if (istype(M))
		M.mind?.get_player()?.tutorial?.PerformSilentAction(src.name)

/obj/landmark/newbee/disposing()
	landmarks[name] -= src.loc
	. = ..()

/obj/landmark/newbee/basic_movement
	name = LANDMARK_TUTORIAL_NEWBEE_BASIC_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/powered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_POWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_id_card
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_ID_CARD
	icon = 'icons/obj/items/card.dmi'
	icon_state = "id_eng"

/obj/landmark/newbee/idlock_doors
	name = LANDMARK_TUTORIAL_NEWBEE_IDLOCK_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_can
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CAN
	icon = 'icons/obj/foodNdrink/can.dmi'
	icon_state = "crushed-5"

/obj/landmark/newbee/can_throw
	name = LANDMARK_TUTORIAL_NEWBEE_CAN_THROW
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_crowbar
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_CROWBAR
	icon = 'icons/obj/items/tools/crowbar.dmi'
	icon_state = "crowbar"

/obj/landmark/newbee/unpowered_doors
	name = LANDMARK_TUTORIAL_NEWBEE_UNPOWERED_DOORS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/help_person
	name = LANDMARK_TUTORIAL_NEWBEE_HELP_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/obj/landmark/newbee/disarm_person
	name = LANDMARK_TUTORIAL_NEWBEE_DISARM_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/obj/landmark/newbee/grab_person
	name = LANDMARK_TUTORIAL_NEWBEE_GRAB_PERSON
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"

/obj/landmark/newbee/mouse
	name = LANDMARK_TUTORIAL_NEWBEE_MOUSE
	icon = 'icons/misc/critter.dmi'
	icon_state = "mouse_white"

/obj/landmark/newbee/exit_intents
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_INTENTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/check_health
	name = LANDMARK_TUTORIAL_NEWBEE_CHECK_HEALTH
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_brute_first_aid
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BRUTE_FIRST_AID
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "brute1"

/obj/landmark/newbee/pickup_fire_first_aid
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FIRE_FIRST_AID
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "burn1"

/obj/landmark/newbee/exit_health
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_HEALTH
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/decon_girder
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_GIRDER
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_toolbox
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_TOOLBOX
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "blue"

/obj/landmark/newbee/pickup_flashlight
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_FLASHLIGHT
	icon = 'icons/obj/items/device.dmi'
	icon_state = "flight0"

/obj/landmark/newbee/enter_maints
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/traverse_maints
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_MAINTS
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/emergency_supply_closet
	name = LANDMARK_TUTORIAL_NEWBEE_EMERGENCY_SUPPLY_CLOSET
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "emergency"

/obj/landmark/newbee/enter_space
	name = LANDMARK_TUTORIAL_NEWBEE_ENTER_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/traverse_space
	name = LANDMARK_TUTORIAL_NEWBEE_TRAVERSE_SPACE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_backpack
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_BACKPACK
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "backpack"

/obj/landmark/newbee/exit_storage
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_STORAGE
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_welding_mask
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDING_MASK
	icon = 'icons/obj/clothing/item_hats.dmi'
	icon_state = "welding"

/obj/landmark/newbee/pickup_weldingtool
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WELDINGTOOL
	icon = 'icons/obj/items/tools/weldingtool.dmi'
	icon_state = "weldingtool-off"

/obj/landmark/newbee/decon_wall
	name = LANDMARK_TUTORIAL_NEWBEE_DECON_WALL
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_wrench
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_WRENCH
	icon = 'icons/obj/items/tools/wrench.dmi'
	icon_state = "wrench"

/obj/landmark/newbee/laying_down
	name = LANDMARK_TUTORIAL_NEWBEE_LAYING_DOWN
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/sprinting
	name = LANDMARK_TUTORIAL_NEWBEE_SPRINTING
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/walking
	name = LANDMARK_TUTORIAL_NEWBEE_WALKING
	icon = 'icons/obj/foodNdrink/food_produce.dmi'
	icon_state = "banana-peel"

/obj/landmark/newbee/exit_movement
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_MOVEMENT
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/pickup_headset
	name = LANDMARK_TUTORIAL_NEWBEE_PICKUP_HEADSET
	icon = 'icons/obj/clothing/item_ears.dmi'
	icon_state = "headset"

/obj/landmark/newbee/exit_radio
	name = LANDMARK_TUTORIAL_NEWBEE_EXIT_RADIO
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/water_tank
	name = LANDMARK_TUTORIAL_NEWBEE_WATER_TANK
	icon = 'icons/obj/objects.dmi'
	icon_state = "watertank"

/obj/landmark/newbee/pull_target
	name = LANDMARK_TUTORIAL_NEWBEE_PULL_TARGET
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/final_room
	name = LANDMARK_TUTORIAL_NEWBEE_FINAL_ROOM
	icon = 'icons/effects/VR.dmi'
	icon_state = "lightning_marker"

/obj/landmark/newbee/clown_murder
	name = LANDMARK_TUTORIAL_NEWBEE_CLOWN_MURDER
	icon = 'icons/map-editing/job_start.dmi'
	icon_state = "clown"
