// ==================== Cargo Pad Manager ====================

var/global/datum/cargo_pad_manager/cargo_pad_manager

/// Basically a list wrapper that removes and adds cargo pads to a global list when it receives the respective signals
/datum/cargo_pad_manager
	var/list/obj/submachine/cargopad/pads = list()

	New()
		..()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_ENABLED, PROC_REF(add_pad))
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, PROC_REF(remove_pad))

	/// Add a pad to the global pads list. Do nothing if the pad is already in the pads list.
	proc/add_pad(datum/holder, obj/submachine/cargopad/pad)
		if (!istype(pad)) //wuh?
			return
		src.pads |= pad
		update_pad_lights(pad.tele_name)

	/// Remove a pad from the global pads list. Do nothing if the pad is already in the pads list.
	proc/remove_pad(datum/holder, obj/submachine/cargopad/pad)
		if (!istype(pad)) //wuh!
			return
		src.pads -= pad
		update_pad_lights(pad.tele_name)

	proc/update_pad_lights(var/pad_name)
		var/list/obj/submachine/cargopad/dup_list = new()
		for(var/obj/submachine/cargopad/pad in src.pads)
			if(pad.tele_name == pad_name)
				dup_list += pad
		var/is_duplicate = length(dup_list) > 1
		for(var/obj/submachine/cargopad/pad in dup_list)
			pad.update_lights(is_duplicate)

	proc/transport(var/mob/user, var/obj/target, var/target_name)
		// Find cargo pad(s) with the target name.
		var/list/obj/submachine/cargopad/target_list = new()
		for(var/obj/submachine/cargopad/pad in src.pads)
			if(pad.tele_name == target_name)
				target_list += pad
		if(length(target_list) == 0)
			boutput(user, SPAN_ALERT("No destination \"[target_name]\" found."))
			return

		if(istype(target, /obj/storage))
			var/obj/storage/S = target
			if(length(target_list) <= 1 || !S.can_open())
				var/obj/submachine/cargopad/main_target = pick(target_list)
				target.set_loc(get_turf(main_target))
				if(length(target_list) >= 2)
					ThrowRandom(S, dist = rand(1,3))
				main_target.receive_cargo()
				var/mob_teled = FALSE
				for (var/mob/M in S.contents)
					if(!M)
						continue
					mob_teled = TRUE
					logTheThing(LOG_STATION, user, "uses a cargo transporter to send [S.name]\
						[S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
						with [constructTarget(M,"station")] inside to [log_loc(target_name)].")
				if(!mob_teled)
					logTheThing(LOG_STATION, user, "uses a cargo transporter to send [S.name]\
						[S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
						([S.type]) to [log_loc(target_name)].")
			else
				mishap_crate(user, S, target_list)
				for(var/obj/submachine/cargopad/pad in target_list)
					pad.receive_cargo()
		else if(isitem(target))
			var/obj/item/I = target
			if(length(target_list) >= 2 && I.storage)
				mishap_item_storage(I, target_list)
			target.set_loc(get_turf(pick(target_list)))
			ThrowRandom(target, dist = rand(0,3))

	// Crate's contents thrown out from a transport accident
	proc/mishap_crate(var/user, var/obj/storage/S, var/list/obj/submachine/cargopad/target_list)
		// Crate might not have been opened yet
		if(S.spawn_contents && S.make_my_stuff())
			S.spawn_contents = null
		// Contents go brrrr...
		var/mob_teled = FALSE
		var/obj/submachine/cargopad/main_pad = pick(target_list)
		var/pad_index = pick(1, length(target_list)) // Fling an even number of items between pads
		for(var/atom/movable/AM in S.contents)
			var/obj/submachine/cargopad/tele_pad = target_list[pad_index]
			if(++pad_index > length(target_list))
				pad_index = 1
			if(ismob(AM))
				var/mob/M = AM
				mishap_mob(M, target_list)
				mob_teled = TRUE
				logTheThing(LOG_STATION, user, "uses a cargo transporter to send \
				[S.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
				with [constructTarget(M,"station")] inside to [log_loc(tele_pad)]. \
				This cause a transport accident.")
				spawn(0.25 SECONDS) M.emote("scream") // Don't scream until after mob is teled
			else if(isitem(AM))
				var/obj/item/I = AM
				if(I.storage)
					mishap_item_storage(I, target_list)
			AM.set_loc(get_turf(tele_pad))
			ThrowRandom(AM, dist = rand(0,3))
		if(!mob_teled)
			logTheThing(LOG_STATION, user, "uses a cargo transporter to send \
			[S.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
			([S.type]) to [log_loc(main_pad)].")
		S.set_loc(get_turf(main_pad))
		S.open()
		ThrowRandom(S, dist = rand(1,3))

	// Similar, but for storage items
	proc/mishap_item_storage(var/obj/item/S, var/list/obj/submachine/cargopad/target_list)
		var/obj/submachine/cargopad/main_pad = pick(target_list)
		var/pad_index = pick(1, length(target_list)) // Fling an even number of items between pads
		for(var/atom/movable/AM in S.contents)
			var/obj/submachine/cargopad/tele_pad = target_list[pad_index]
			if (tele_pad != main_pad || prob(50))
				AM.set_loc(get_turf(tele_pad))
				ThrowRandom(AM, dist = rand(0,5))
				if(++pad_index > length(target_list))
					pad_index = 1

	// Transport accident where mobs can lose items and organs
	proc/mishap_mob(var/mob/M, var/list/obj/submachine/cargopad/target_list)
		if(isnull(M))
			return
		var/pad_index = pick(1, length(target_list)) // Transport objects evenly between pads
		// Chance to lose items
		var/chance_item = (1 - (0.8 ** length(target_list))) * 100
		var/list/equipped_list = M.get_equipped_items(TRUE)
		for(var/obj/item/I in equipped_list)
			if(I.storage)
				mishap_item_storage(I, target_list)
			if(prob(chance_item))
				var/obj/submachine/cargopad/tele_pad = target_list[pad_index]
				M.drop_item(I)
				I.set_loc(get_turf(tele_pad))
				ThrowRandom(I, dist = rand(0,4))
				if(++pad_index > length(target_list))
					pad_index = 1

		// Lose one organ/limb per cargo pad
		if(!isliving(M))
			return
		var/mob/living/L = M
		if(!L.organHolder)
			return
		var/list/organ_list = non_vital_organ_strings + list("tail", "butt", "left_eye", "right_eye")
		organ_list -= L.organHolder.get_missing_organs()
		var/list/obj/item/parts/limb_list = null
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			limb_list = H.limbs?.get_limb_list()
		for(var/obj/submachine/cargopad/pad in target_list)
			if(!organ_list && !limb_list)
				continue
			var/pick_list = rand(1, length(organ_list) + length(limb_list))
			if(pick_list <= length(organ_list))
				var/organ = pick(organ_list)
				L.organHolder.drop_and_throw_organ(organ, get_turf(pad), alldirs, rand(0,3))
				organ_list -= organ
			else
				var/obj/item/parts/limb = pick(limb_list)
				limb.remove()
				limb.set_loc(get_turf(pad))
				ThrowRandom(limb, dist = rand(0,3))
				limb_list -= limb


// ==================== Cargo Pad ====================

TYPEINFO(/obj/submachine/cargopad)
	mats = list("telecrystal" = 10,
				"conductive" = 15,
				"metal" = 10)

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects directed by a cargo transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = ANCHORED
	plane = PLANE_FLOOR
	deconstruct_flags = DECON_SCREWDRIVER | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/tele_name = null // Name of the pad for receiving objects. Just in case src.name changes unexpectedly for whatever reason.
	var/group
	/// The mailgroup to send notifications to
	var/mailgroup = null
	var/image/lights = null

	var/active = TRUE
	var/is_duplicate = FALSE // Used for the pad's warning lights
	var/labelling = FALSE // Is this pad currently being renamed by a player?

	get_desc()
		. = ..()
		if(src.is_duplicate)
			. += " The warning lights indicate a probable guidance malfunction."

	New()
		..()
		// Do not spawn with a duplicate name
		if (src.name == "Cargo Pad")
			src.name += " ([rand(100,999)])"
		else
			for(var/obj/submachine/cargopad/pad in global.cargo_pad_manager.pads)
				if(pad.tele_name == src.name)
					src.name += " ([rand(100,999)])"
					break
		src.tele_name = src.name

		//sadly maps often don't use the subtypes, so we do this instead
		if (!src.mailgroup)
			var/area/area = get_area(src)
			if (istype(area, /area/station/hydroponics) || istype(area, /area/station/storage/hydroponics) || istype(area, /area/station/ranch))
				src.mailgroup = MGD_BOTANY
			else if (istype(area, /area/station/medical))
				src.mailgroup = MGD_MEDRESEACH
			else if (istype(area, /area/station/science) || istype(area, /area/research_outpost))
				src.mailgroup = MGD_SCIENCE
			else if (istype(area, /area/station/engine))
				src.mailgroup = MGO_ENGINEER
			else if (istype(area, /area/station/mining) || istype(area, /area/station/quartermaster/refinery) || istype(area, /area/mining))
				src.mailgroup = MGD_MINING
			else if (istype(area, /area/station/quartermaster))
				src.mailgroup = MGD_CARGO

		src.lights = image('icons/obj/objects.dmi', "cpad-rec")
		if(src.active) //in case of map edits etc
			AddOverlays(src.lights, "lights")
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)

	disposing()
		SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		..()

	was_deconstructed_to_frame(mob/user)
		if(src.active)
			src.toggle(user)
		..()

	was_built_from_frame(mob/user, newly_built)
		if(src.active)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)
		..()

	attackby(obj/item/I, mob/user)
		..()
		if(ispulsingtool(I) && !src.labelling)
			// Use a multitool to rename the cargo pad
			if(src.active)
				boutput(user, SPAN_ALERT("You need to turn the receiver off before you can rename the [src]."))
				return
			src.labelling = TRUE
			var/new_name = tgui_input_text(user, "What do you want to name this cargo pad?", null, null, max_length = 50)
			src.labelling = FALSE
			new_name = sanitize(html_encode(new_name))
			if(!new_name || !in_interact_range(src, user) || src.active)
				return
			if(!findtext(new_name, "pad"))
				new_name += " Pad"
			for(var/obj/submachine/cargopad/pad in global.cargo_pad_manager.pads)
				if(pad.tele_name == new_name)
					boutput(user, SPAN_ALERT("The [src] detected another pad called \"[new_name]\" and has canceled your input."))
					return
			boutput(user, SPAN_NOTICE("You rename the [src.name] to \"[new_name]\"."))
			src.name = new_name
			src.tele_name = new_name
			return

	attack_hand(var/mob/user)
		toggle(user)

	attack_ai(mob/user)
		. = ..()
		toggle(user)

	proc/toggle(mob/user)
		if (src.active == 1)
			boutput(user, SPAN_NOTICE("You switch the receiver off."))
			ClearSpecificOverlays("lights")
			src.active = FALSE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_DISABLED, src)
		else
			boutput(user, SPAN_NOTICE("You switch the receiver on."))
			AddOverlays(src.lights, "lights")
			src.active = TRUE
			SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_CARGO_PAD_ENABLED, src)

	// Pad manager tells it if it is currently sharing a name with another pad
	proc/update_lights(var/duplicate = FALSE)
		src.is_duplicate = duplicate
		switch(src.lights.icon_state)
			if("cpad-received")
				return
			if("cpad-rec")
				if(!duplicate)
					return
				src.lights.icon_state = "cpad-warning"
				src.UpdateOverlays(src.lights, "lights")
			if("cpad-warning")
				if(duplicate)
					return
				src.lights.icon_state = "cpad-rec"
				src.UpdateOverlays(src.lights, "lights")

	proc/receive_cargo()
		playsound(src.loc, 'sound/machines/click.ogg', 70, 1, pitch = 0.5)
		if(src.lights.icon_state != "cpad-received")
			src.lights.icon_state = "cpad-received"
			src.UpdateOverlays(src.lights, "lights")
			spawn(3 SECONDS) receive_cargo_end()
		if (!src.mailgroup)
			return
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(src.mailgroup), "sender"="00000000", "message"="Notification: Incoming delivery to [src.name].")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

	proc/receive_cargo_end()
		if(src.active)
			if(is_duplicate)
				src.lights.icon_state = "cpad-warning"
			else
				src.lights.icon_state = "cpad-rec"
			src.UpdateOverlays(src.lights, "lights")

	podbay
		name = "Pod Bay Pad"
	hydroponic
		mailgroup = MGD_BOTANY
		name = "Hydroponics Pad"
	robotics
		mailgroup = MGD_MEDRESEACH
		name = "Robotics Pad"
	artlab
		mailgroup = MGD_SCIENCE
		name = "Artifact Lab Pad"
	engineering
		mailgroup = MGO_ENGINEER
		name = "Engineering Pad"
	mechanics
		mailgroup = MGO_ENGINEER
		name = "Mechanics Pad"
	magnet
		mailgroup = MGD_MINING
		name = "Mineral Magnet Pad"
	miningoutpost
		mailgroup = MGD_MINING
		name = "Mining Outpost Pad"
	qm
		mailgroup = MGD_CARGO
		name = "QM Pad"
	qm2
		mailgroup = MGD_CARGO
		name = "QM Pad 2"
	researchoutpost
		mailgroup = MGD_SCIENCE
		name = "Research Outpost Pad"
	radio
		name = "Radio Station Pad"

// ==================== Cargo Transporter ====================

/// Multiplier for power usage if the user is a silicon and the charge is coming from their internal cell
#define SILICON_POWER_COST_MOD 10

TYPEINFO(/obj/item/cargotele)
	mats = list("telecrystal" = 5,
				"conductive" = 5,
				"reflective" = 2)

/obj/item/cargotele
	name = "cargo transporter"
	desc = "A device for teleporting crated goods."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "cargotele"
	/// Power cost per teleport
	var/cost = 25
	/// Length of action bar before teleport completes
	var/teleport_delay = 3 SECONDS
	// The name of the target pad. Pads that share names will be chosen at random.
	var/target_name = ""
	/// Type of cell used in this
	var/cell_type = /obj/item/ammo/power_cell/med_power
	/// List of types that cargo teles are allowed to send. Built in New, shared across all teles
	var/static/list/allowed_types = list()
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | SUPPRESSATTACK
	c_flags = ONBELT

	New()
		. = ..()
		var/list/allowed_supertypes = list(/obj/machinery/portable_atmospherics/canister, /obj/reagent_dispensers, /obj/storage, /obj/geode)
		for (var/supertype in allowed_supertypes)
			for (var/subtype in typesof(supertype))
				allowed_types[subtype] = 1
		allowed_types -= /obj/storage/closet/flock

		var/cell = new cell_type
		AddComponent(/datum/component/cell_holder, cell, swappable = FALSE)
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_CARGO_PAD_DISABLED, PROC_REF(maybe_reset_target)) //make sure cargo pads can GC

	proc/maybe_reset_target(datum/dummy, var/obj/submachine/cargopad/pad)
		if (src.target_name == pad.tele_name)
			src.target_name = ""

	examine(mob/user)
		. = ..()
		if(src.target_name)
			. += "It's currently set to [src.target_name]."
		else
			. += "No destination has been selected."
		if (isrobot(user))
			. += "Each use of the cargo teleporter will consume [cost * SILICON_POWER_COST_MOD]PU."
		else
			var/list/ret = list()
			if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST))
				. += SPAN_ALERT("No power cell installed.")
			else
				. += "There are [ret["charge"]]/[ret["max_charge"]] PUs left! Each use will consume [cost]PU."

	attack_self(mob/user) // Fixed --melon
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return
		if (!length(global.cargo_pad_manager.pads))
			boutput(user, SPAN_ALERT("No receivers available."))
		else
			var/mob/holder = src.loc
			var/obj/submachine/cargopad/selection = tgui_input_list(user, "Select Cargo Pad Location:", "Cargo Pads", global.cargo_pad_manager.pads, 15 SECONDS)
			if (src.loc != holder || !istype(selection))
				return
			src.target_name = selection.tele_name //blammo! works!
			boutput(user, "Target set to [src.target_name].")

	afterattack(var/obj/O, mob/user)
		if (!istype(O))
			return ..()
		if (O.artifact || src.allowed_types[O.type])
			if (O.anchored)
				boutput(user, SPAN_ALERT("You can't teleport [O] while it is anchored!"))
				return
			src.try_teleport(O, user)

	proc/can_teleport(var/obj/cargo, var/mob/user)
		if (!src.target_name)
			boutput(user, SPAN_ALERT("You need to set a target first!"))
			return FALSE
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return FALSE
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			if (R.cell.charge < src.cost * SILICON_POWER_COST_MOD)
				boutput(user, SPAN_ALERT("There is not enough charge left in your cell to use this."))
				return FALSE

		return TRUE

	proc/try_teleport(var/obj/cargo, var/mob/user)
		// Why didn't you implement checks for these in the first place, sigh (Convair880).
		if (cargo.loc == user && issilicon(user))
			user.show_text("The [cargo.name] is securely bolted to your chassis.", "red")
			return FALSE

		if (!src.can_teleport(cargo, user))
			return FALSE

		boutput(user, SPAN_NOTICE("Teleporting [cargo] to [src.target_name]..."))
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
		var/datum/action/bar/private/icon/callback/teleport = new(user, cargo, src.teleport_delay, PROC_REF(finish_teleport), list(cargo, user), null, null, null, null, src)
		actions.start(teleport, user)
		return TRUE

	proc/finish_teleport(var/obj/cargo, var/mob/user)
		if (ismob(cargo.loc) && cargo.loc == user)
			user.u_equip(cargo)
		if (istype(cargo, /obj/item))
			var/obj/item/I = cargo
			I.stored?.transfer_stored_item(I, get_turf(I), user = user)

		var/obj/storage/S = cargo
		ENSURE_TYPE(S)
		global.cargo_pad_manager.transport(user, cargo, src.target_name)

		// Transport finished
		elecflash(src)
		if (isrobot(user))
			var/mob/living/silicon/robot/R = user
			R.cell.charge -= cost * SILICON_POWER_COST_MOD
		else
			var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
			if (ret & CELL_INSUFFICIENT_CHARGE)
				boutput(user, SPAN_ALERT("Transfer successful. The transporter is now out of charge."))
			else
				boutput(user, SPAN_NOTICE("Transfer successful."))

#undef SILICON_POWER_COST_MOD

/obj/item/cargotele/efficient
	name = "Hedron cargo transporter"
	desc = "A device for teleporting crated goods. It's modified a bit from the standard design, and boasts improved efficiency and transport speed."
	cost = 20
	teleport_delay = 2 SECONDS
	icon_state = "cargotelegreen"

/obj/item/cargotele/traitor
	cost = 15
	///The account to credit for sales
	var/datum/db_record/account = null
	///The total amount earned from selling/stealing
	var/total_earned = 0

	attack_self() // Fixed --melon
		return

	can_teleport(obj/cargo, mob/user)
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE))
			boutput(user, SPAN_ALERT("The transporter is out of charge."))
			return FALSE
		return TRUE

	try_teleport(obj/cargo, mob/user)
		if(..() && istype(cargo, /obj/storage))
			var/obj/storage/store = cargo
			store.weld(TRUE, user)

	finish_teleport(var/obj/cargo, var/mob/user)
		var/rand_loc = random_space_turf() || random_nonrestrictedz_turf()
		boutput(user, SPAN_NOTICE("Teleporting [cargo]..."))
		playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
		var/value = shippingmarket.appraise_value(cargo.contents, sell = FALSE)
		// Logs for good measure (Convair880).
		for (var/atom/A in cargo.contents)
			if (ismob(A))
				var/mob/M = A
				logTheThing(LOG_STATION, user, "uses a Syndicate cargo transporter to send [cargo.name] with [constructTarget(M,"station")] inside to [log_loc(rand_loc)].")
				var/datum/job/job = find_job_in_controller_by_string(M.job)
				value += job?.wages * 5
			else
				cargo.contents -= A
				qdel(A)
		if (length(cargo.contents)) //if there's a mob left inside chuck it somewhere in space
			cargo.set_loc(rand_loc)
		else
			qdel(cargo)
		src.total_earned += value
		logTheThing(LOG_STATION, user, "uses a Syndicate cargo transporter to sell shit for [value] credits.")
		elecflash(src)
		var/ret = SEND_SIGNAL(src, COMSIG_CELL_USE, cost)
		boutput(user, "[bicon(src)] *beep*")
		if (src.account)
			account?["current_money"] += value
			boutput(user, "[bicon(src)] The [src.name] beeps: transfer successful, [value] credits have been deposited into your bank account. You have [src.account["current_money"]] credits total.")
		else
			boutput(user, "[bicon(src)] The [src.name] beeps: transfer successful, no account registered.")
		if (ret & CELL_INSUFFICIENT_CHARGE)
			boutput(user, SPAN_ALERT("[src] is now out of charge."))

	attackby(obj/item/item, mob/user)
		var/owner_name = null
		if (istype(item, /obj/item/device/pda2))
			var/obj/item/device/pda2/pda = item
			owner_name = pda.registered
		else if (istype(item, /obj/item/clothing/lanyard))
			var/obj/item/clothing/lanyard/lanyard = item
			owner_name = lanyard.registered
		else if (istype(item, /obj/item/card/id))
			var/obj/item/card/id/card = item
			owner_name = card.registered
		if (owner_name)
			boutput(user, SPAN_NOTICE("You set [src]'s payout account."))
			src.account = data_core.bank.find_record("name", owner_name)
			return
		..()

	get_desc()
		. = ..()
		if (src.total_earned)
			. += "<br>There is a little counter on the side, it says: Total amount earned: [src.total_earned] credits.<br>"
