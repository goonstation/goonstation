
//
// tutorial objects
//

/obj/item/card/id/engineering/tutorial
	name = ""
	access = list(access_engineering_power)

/obj/machinery/door/airlock/pyro/classic/tutorial
	var/mob/tutorial_user

	attackby(obj/item/C, mob/user)
		if (ispryingtool(C))
			src.tutorial_user = user
		. = ..()


	open(manual_activation, surpress_send)
		. = ..()
		if (manual_activation)
			src.tutorial_user?.mind?.get_player()?.tutorial?.PerformSilentAction("door", "manual_open")

/obj/item/storage/firstaid/brute/tutorial
	spawn_contents = list(/obj/item/reagent_containers/patch/mini/bruise=5)
	attack_self(mob/user)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("open_storage", "brute_first_aid")

/obj/item/storage/firstaid/fire/tutorial
	spawn_contents = list(/obj/item/reagent_containers/patch/mini/burn=5)

	attack_self(mob/user)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("open_storage", "fire_first_aid")


/obj/item/device/light/flashlight/tutorial
	toggle(mob/user, activated_inhand)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("use_item", "flashlight")

/obj/item/clothing/head/helmet/welding/tutorial
	flip_up(mob/living/carbon/human/user, silent)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("welding_mask", "flip_up")
	flip_down(mob/living/carbon/human/user, silent)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("welding_mask", "flip_down")

/obj/item/weldingtool/tutorial
	fuel_capacity = 999

	attack_self(mob/user)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("use_item", "weldingtool")

/// Guaranteed to contain everything needed for a space walk
/obj/storage/closet/emergency_tutorial
	name = "emergency supplies closet"
	desc = "It's a closet! This one can be opened AND closed. Comes prestocked with emergency equipment."
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergency-open"

	var/obj/item/clothing/suit/space/emerg/emergency_suit
	var/obj/item/clothing/mask/breath/breath_mask
	var/obj/item/clothing/head/emerg/emergency_hood

	proc/reset(turf/move_to)
		src.set_loc(move_to)
		src.close()

		if (!src.emergency_suit || QDELETED(src.emergency_suit))
			src.make_emergency_suit()
		if (ismob(src.emergency_suit.loc))
			var/mob/M = src.emergency_suit.loc
			M.drop_item(src.emergency_suit)
		src.emergency_suit.set_loc(src)
		src.emergency_suit.pixel_x = -8
		src.emergency_suit.pixel_y = 8

		if (!src.breath_mask || QDELETED(src.breath_mask))
			src.make_breath_mask()
		if (ismob(src.breath_mask.loc))
			var/mob/M = src.breath_mask.loc
			M.drop_item(src.breath_mask)
		src.breath_mask.set_loc(src)
		src.breath_mask.pixel_x = 8
		src.breath_mask.pixel_y = 8

		if (!src.emergency_hood || QDELETED(src.emergency_hood))
			src.make_emergency_hood()
		if (ismob(src.emergency_hood.loc))
			var/mob/M = src.emergency_hood.loc
			M.drop_item(src.emergency_hood)
		src.emergency_hood.set_loc(src)
		src.emergency_hood.pixel_x = -8
		src.emergency_hood.pixel_y = -8

	proc/make_emergency_suit()
		src.emergency_suit = new(src)
		src.emergency_suit.layer = OBJ_LAYER + 0.04

	proc/make_breath_mask()
		src.breath_mask = new(src)
		src.breath_mask.layer = OBJ_LAYER + 0.03

	proc/make_emergency_hood()
		src.emergency_hood = new(src)
		src.emergency_hood.layer = OBJ_LAYER + 0.02

	make_my_stuff()
		if(..())
			src.make_emergency_suit()
			src.emergency_suit.pixel_x = -8
			src.emergency_suit.pixel_y = 8
			src.make_breath_mask()
			src.breath_mask.pixel_x = 8
			src.breath_mask.pixel_y = 8
			src.make_emergency_hood()
			src.emergency_hood.pixel_x = -8
			src.emergency_hood.pixel_y = -8
			return 1

	open(entangleLogic, mob/user)
		. = ..()
		user?.mind?.get_player()?.tutorial?.PerformSilentAction("open_storage", "emergency_tutorial")

/// mechanical toolbox that tracks its contents
/obj/item/storage/toolbox/tutorial
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox-blue"
	desc = "A metal container designed to hold various tools. This variety holds standard construction tools."

	var/obj/item/screwdriver/screwdriver
	var/obj/item/wrench/wrench
	var/obj/item/weldingtool/weldingtool
	var/obj/item/crowbar/crowbar
	var/obj/item/wirecutters/wirecutters
	var/obj/item/device/analyzer/atmospheric/atmos_scanner

	proc/reset(turf/move_to)
		if (isnull(move_to))
			return
		if (ismob(src.loc))
			var/mob/M = src.loc
			M.drop_item(src)
		src.set_loc(move_to)
		src.pixel_x = 0
		src.pixel_y = 0

		if (!src.screwdriver || QDELETED(src.screwdriver))
			src.screwdriver = new(src)
		src.ensure_item_in_storage(src.screwdriver)

		if (!src.wrench || QDELETED(src.wrench))
			src.wrench = new(src)
		src.ensure_item_in_storage(src.wrench)

		if (!src.weldingtool || QDELETED(src.weldingtool))
			src.weldingtool = new(src)
		src.weldingtool.reagents.add_reagent("fuel", src.weldingtool.fuel_capacity)
		src.ensure_item_in_storage(src.weldingtool)

		if (!src.crowbar || QDELETED(src.crowbar))
			src.crowbar = new(src)
		src.ensure_item_in_storage(src.crowbar)

		if (!src.wirecutters || QDELETED(src.wirecutters))
			src.wirecutters = new(src)
		src.ensure_item_in_storage(src.wirecutters)

		if (!src.atmos_scanner || QDELETED(src.atmos_scanner))
			src.atmos_scanner = new(src)
		src.ensure_item_in_storage(src.atmos_scanner)

	proc/ensure_item_in_storage(obj/item)
		if (ismob(item.loc))
			var/mob/M = item.loc
			M.drop_item(item)
		if (!(item in src.storage.stored_items))
			src.storage.add_contents(item, visible=FALSE)

	make_my_stuff()
		if(..())
			src.reset(get_turf(src))
			return TRUE

/// Sends an action on toggling the valve on
/obj/item/tank/oxygen/tutorial
	toggle_valve()
		var/mob/living/carbon/M = src.loc
		if (istype(M) && M.mind?.get_player()?.tutorial)
			if (..())
				if (M.internal == src)
					M.mind?.get_player()?.tutorial.PerformSilentAction("action_button", "internals_on")
			else
				M.mind?.get_player()?.tutorial.PerformSilentAction("action_button", "internals_off")

		else
			..()

/// Crusher that doesn't qdel the tutorial mob
/obj/machinery/crusher/slow/tutorial
	start_crushing(atom/movable/AM)
		. = ..()
		if (istype(AM, /mob/living/carbon/human/tutorial))
			var/mob/M = AM
			boutput(M, SPAN_ALERT("<b>Uh oh, that was a bad idea... good thing this is all a simulation, right?</b>"))
			APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "tutorial_crusher")

	finish_crushing(atom/movable/AM)
		if (istype(AM, /mob/living/carbon/human/tutorial))
			var/mob/M = AM
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "tutorial_crusher")
			M.temp_flags &= ~BEING_CRUSHERED
			M.gib() // don't qdel the tutorial mob
			return
		else
			. = ..()

/// Sends actions on thrown items/flushing
/obj/machinery/disposal/tutorial
	hitby(atom/movable/MO, datum/thrown_thing/thr)
		. = ..()
		var/mob/M = thr.thrown_by
		M.mind?.get_player()?.tutorial?.PerformSilentAction("throw_item", MO)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (action == "toggleHandle")
			var/mob/M = ui.user
			if (istype(M))
				M.mind?.get_player()?.tutorial?.PerformSilentAction("flush", "disposals")

/// Send action on removal
/obj/structure/girder/tutorial
	name = "girder"

	attackby(obj/item/I, mob/user)
		if (ispryingtool(I) && user?.mind?.get_player()?.tutorial)
			boutput(user, SPAN_ALERT("This girder refuses to dislodge from the floor! You need to use a <b>wrench</b>!"))
			return
		. = ..()
		if (iswrenchingtool(I))
			user?.mind?.get_player()?.tutorial?.PerformSilentAction("deconstruct", "girder")

/// On decon, send action and turn into a tutorial girder
/turf/simulated/wall/auto/supernorn/tutorial
	var/mob/who_unwelded_me

	attackby(obj/item/W, mob/user, params)
		if (user?.mind?.get_player()?.tutorial)
			src.who_unwelded_me = user
		. = ..()

	dismantle_wall(devastated=0, keep_material = 1)
		var/datum/material/defaultMaterial = getMaterial("steel")
		var/atom/A = new /obj/structure/girder/tutorial(src)
		var/atom/B = new /obj/item/sheet( src )
		var/atom/C = new /obj/item/sheet( src )

		A.setMaterial(src.girdermaterial ? src.girdermaterial : defaultMaterial)
		B.setMaterial(src.material ? src.material : defaultMaterial)
		C.setMaterial(src.material ? src.material : defaultMaterial)

		src.who_unwelded_me.mind?.get_player()?.tutorial?.PerformSilentAction("deconstruct", "wall")

		var/atom/D = ReplaceWithFloor()

		if (src.material && keep_material)
			D.setMaterial(src.material)
		else
			D.setMaterial(getMaterial("steel"))

TYPEINFO(/obj/item/device/radio/headset/tutorial)
	start_listen_effects = list(LISTEN_EFFECT_RADIO_TUTORIAL)

/obj/item/device/radio/headset/tutorial
	hardened = TRUE // needs to always work
	locked_frequency = TRUE

	secure_frequencies = list(
		"e" = R_FREQ_ENGINEERING,
		"c" = R_FREQ_CIVILIAN)

/obj/item/device/radio/headset/tutorial/receive_signal()
	return


/obj/health_scanner/floor/tutorial
	crit_alert(mob/living/carbon/human/H)
		return // don't alert station to tutorial crit users
