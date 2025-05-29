
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
		if (manual_activation && src.tutorial_user?.client?.tutorial)
			src.tutorial_user.client.tutorial.PerformSilentAction("door", "manual_open")

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

/obj/item/clothing/head/helmet/welding/tutorial
	flip_up(mob/living/carbon/human/user, silent)
		. = ..()
		if (user?.client?.tutorial)
			user.client.tutorial.PerformSilentAction("welding_mask", "flip_up")
	flip_down(mob/living/carbon/human/user, silent)
		. = ..()
		if (user?.client?.tutorial)
			user.client.tutorial.PerformSilentAction("welding_mask", "flip_down")

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

	var/obj/item/clothing/suit/space/emerg/emergency_suit
	var/obj/item/clothing/mask/breath/breath_mask
	var/obj/item/clothing/head/emerg/emergency_hood
	var/obj/item/tank/oxygen/tutorial/oxygen_tank

	proc/reset(turf/move_to)
		src.set_loc(move_to)
		src.close()

		if (!src.emergency_suit || QDELETED(src.emergency_suit))
			src.make_emergency_suit()
		if (ismob(src.emergency_suit.loc))
			var/mob/M = src.emergency_suit.loc
			M.drop_item(src.emergency_suit)
		src.emergency_suit.set_loc(src)

		if (!src.breath_mask || QDELETED(src.breath_mask))
			src.make_breath_mask()
		if (ismob(src.breath_mask.loc))
			var/mob/M = src.breath_mask.loc
			M.drop_item(src.breath_mask)
		src.breath_mask.set_loc(src)

		if (!src.emergency_hood || QDELETED(src.emergency_hood))
			src.make_emergency_hood()
		if (ismob(src.emergency_hood.loc))
			var/mob/M = src.emergency_hood.loc
			M.drop_item(src.emergency_hood)
		src.emergency_hood.set_loc(src)

		if (!src.oxygen_tank || QDELETED(src.oxygen_tank))
			src.make_oxygen_tank()
		if (ismob(src.oxygen_tank.loc))
			var/mob/M = src.oxygen_tank.loc
			M.drop_item(src.oxygen_tank)
		src.oxygen_tank.set_loc(src)

	proc/make_emergency_suit()
		src.emergency_suit = new(src)
		src.emergency_suit.layer = OBJ_LAYER + 0.04
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.emergency_suit, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_breath_mask()
		src.breath_mask = new(src)
		src.breath_mask.layer = OBJ_LAYER + 0.03
		RegisterSignal(src.breath_mask, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.breath_mask, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.breath_mask, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_emergency_hood()
		src.emergency_hood = new(src)
		src.emergency_hood.layer = OBJ_LAYER + 0.02
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_tutorial_item))
		RegisterSignal(src.emergency_hood, COMSIG_ITEM_UNEQUIPPED, PROC_REF(unequip_tutorial_item))

	proc/make_oxygen_tank()
		src.oxygen_tank = new(src)
		src.oxygen_tank.layer = OBJ_LAYER + 0.01
		RegisterSignal(oxygen_tank, COMSIG_ITEM_PICKUP, PROC_REF(pickup_tutorial_item))

	make_my_stuff()
		if(..())
			src.make_emergency_suit()
			src.make_breath_mask()
			src.make_emergency_hood()
			src.make_oxygen_tank()
			return 1

	proc/pickup_tutorial_item(datum/source, mob/user)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_pickup", source)

	proc/equip_tutorial_item(datum/source, mob/user, slot)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_equipped", source)

	proc/unequip_tutorial_item(datum/source, mob/user)
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("item_unequipped", source)

	open(entangleLogic, mob/user)
		. = ..()
		if (user.client?.tutorial)
			user.client.tutorial.PerformSilentAction("open_storage", "emergency_tutorial")

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
		if (..())
			var/mob/living/carbon/M = src.loc
			if (istype(M) && M.client?.tutorial)
				if (M.internal == src)
					M.client.tutorial.PerformSilentAction("action_button", "internals")

/// Crusher that doesn't qdel the tutorial mob
/obj/machinery/crusher/slow/tutorial
	finish_crushing(atom/movable/AM)
		if (istype(AM, /mob/living/carbon/human/tutorial))
			var/mob/M = AM
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
		if (M.client?.tutorial)
			M.client.tutorial.PerformSilentAction("throw_item", MO)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (action == "toggleHandle")
			var/mob/M = ui.user
			if (istype(M))
				if (M.client?.tutorial)
					M.client.tutorial.PerformSilentAction("flush", "disposals")

/// Send action on wrenching
/obj/structure/girder/tutorial
	name = "girder"

	attackby(obj/item/I, mob/user)
		. = ..()
		if (iswrenchingtool(I) && user?.client?.tutorial)
			user.client.tutorial.PerformSilentAction("deconstruct", "girder")

/// On decon, send action and turn into a tutorial girder
/turf/simulated/wall/auto/supernorn/tutorial
	var/mob/who_unwelded_me

	attackby(obj/item/W, mob/user, params)
		if (user?.client?.tutorial)
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

		src.who_unwelded_me.client?.tutorial?.PerformSilentAction("deconstruct", "wall")

		var/atom/D = ReplaceWithFloor()

		if (src.material && keep_material)
			D.setMaterial(src.material)
		else
			D.setMaterial(getMaterial("steel"))

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

	src.set_secure_frequencies()

	// SPAWN(1 SECOND)
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
