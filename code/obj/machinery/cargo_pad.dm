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

	/// Actually move an object to the pad
	proc/move_obj(var/atom/movable/target, var/obj/submachine/cargopad/pad, var/atom/transporter, var/throw_range = 0)
		var/turf/T = get_turf(pad)
		var/offset = 0
		if(target.material?.getID() == "telecrystal")
			offset += 2
		if(pad.material?.getID() == "telecrystal")
			offset += 2
		if(transporter?.material?.getID() == "telecrystal")
			offset += 2
		if(offset)
			var/turf/newT = get_offset_target_turf(T, rand(-offset, offset), rand(-offset, offset))
			if(newT.Cross(target))
				T = newT

		target.set_loc(T)
		if(throw_range)
			ThrowRandom(target, dist = throw_range)

	proc/transport(mob/user, obj/target, target_name, atom/transporter = null)
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
				var/throw_range = 0
				if(length(target_list) >= 2)
					throw_range = rand(1,3)
				move_obj(target, main_target, transporter, throw_range)
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
			if(length(target_list) >= 2)
				if(I.storage)
					mishap_item_storage(I, target_list)
				move_obj(I, pick(target_list), transporter, rand(0,3))
			else
				move_obj(I, pick(target_list), transporter)

	// Crate's contents thrown out from a transport accident
	proc/mishap_crate(mob/user, obj/storage/S, list/obj/submachine/cargopad/target_list, atom/transporter)
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
				mishap_mob(M, target_list, transporter)
				mob_teled = TRUE
				logTheThing(LOG_STATION, user, "uses a cargo transporter to send \
					[S.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
					with [constructTarget(M,"station")] inside to [log_loc(tele_pad)]. \
					This cause a transport accident.")
				spawn(0.25 SECONDS) M.emote("scream") // Don't scream until after mob is teled
			else if(isitem(AM))
				var/obj/item/I = AM
				if(I.storage)
					mishap_item_storage(I, target_list, transporter)
			move_obj(AM, tele_pad, transporter, rand(0,3))
		if(!mob_teled)
			logTheThing(LOG_STATION, user, "uses a cargo transporter to send \
				[S.name][S && S.locked ? " (locked)" : ""][S && S.welded ? " (welded)" : ""] \
				([S.type]) to [log_loc(main_pad)].")
		move_obj(S, main_pad, transporter, rand(1,3))
		S.open()

	// Similar, but for storage items
	proc/mishap_item_storage(obj/item/S, list/obj/submachine/cargopad/target_list, atom/transporter)
		var/obj/submachine/cargopad/main_pad = pick(target_list)
		var/pad_index = pick(1, length(target_list)) // Fling an even number of items between pads
		for(var/atom/movable/AM in S.contents)
			var/obj/submachine/cargopad/tele_pad = target_list[pad_index]
			if (tele_pad != main_pad || prob(50))
				move_obj(AM, tele_pad, transporter, rand(0,3))
				if(++pad_index > length(target_list))
					pad_index = 1

	// Transport accident where mobs can lose items and organs
	proc/mishap_mob(mob/M, list/obj/submachine/cargopad/target_list, atom/transporter)
		if(isnull(M))
			return
		var/pad_index = pick(1, length(target_list)) // Transport objects evenly between pads
		// Chance to lose items
		var/chance_item = (1 - (0.8 ** length(target_list))) * 100
		var/list/equipped_list = M.get_equipped_items(TRUE)
		for(var/obj/item/I in equipped_list)
			if(I.storage)
				mishap_item_storage(I, target_list, transporter)
			if(prob(chance_item))
				var/obj/submachine/cargopad/tele_pad = target_list[pad_index]
				M.drop_item(I)
				move_obj(I, tele_pad, transporter, rand(0,3))
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
				move_obj(limb, pad, transporter, TRUE)
				limb_list -= limb


// ==================== Cargo Pad ====================

TYPEINFO(/obj/submachine/cargopad)
	mats = list("telecrystal" = 10,
				"conductive" = 15,
				"metal" = 10)

/obj/submachine/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects directed by a cargo transporter."
	icon = 'icons/obj/machines/cargo_pad.dmi'
	icon_state = "cargo_pad"
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

		src.lights = image('icons/obj/machines/cargo_pad.dmi', "lights-receiver")
		src.lights.appearance_flags = RESET_COLOR | RESET_ALPHA
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
			if("lights-transported")
				return
			if("lights-receiver")
				if(!duplicate)
					return
				src.lights.icon_state = "lights-warning"
				src.UpdateOverlays(src.lights, "lights")
			if("lights-warning")
				if(duplicate)
					return
				src.lights.icon_state = "lights-receiver"
				src.UpdateOverlays(src.lights, "lights")

	proc/receive_cargo()
		playsound(src.loc, 'sound/machines/click.ogg', 70, 1, pitch = 0.5)
		if(src.lights.icon_state != "lights-transported")
			src.lights.icon_state = "lights-transported"
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
				src.lights.icon_state = "lights-warning"
			else
				src.lights.icon_state = "lights-receiver"
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
