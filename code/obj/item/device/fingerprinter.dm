// i love enums
#define FINGERPRINT_PLANT 0
#define FINGERPRINT_READ 1

// TODO make this cost 2 TC
/obj/item/device/fingerprinter
	name = "fingerprinter"
	desc = "A grey-market tool used for scanning fingerprints on things and putting them onto other things. \
			Hooks into the station database for information about fingerprint owners." // (this is a lie)
	icon_state = "reagentscan" // slightly sneaky. slightly.
	is_syndicate = TRUE
	w_class = W_CLASS_TINY
	/// List of prints currently scanned into the device.
	var/datum/forensic_holder/scanned_evidence = new()
	var/mode = FINGERPRINT_READ
	HELP_MESSAGE_OVERRIDE({"Toggle modes by using the fingerprinter in hand.
							While on <b>"Read"</b> mode, use the tool on someone or something that has prints on it to add all the prints to the tool's print database.
							While on <b>"Plant"</b> mode, use the tool on anything to add any prints from the database on it."})

	New()
		. = ..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby)) // use this instead of afterattack so we're silent
		src.create_inventory_counter()
		src.update_text()

	attack_self(mob/user)
		. = ..()
		src.toggle_mode(user)

	mouse_drop(atom/over_object)
		. = ..()
		if (can_act(usr) && (src in usr.equipped_list()) && BOUNDS_DIST(usr, over_object) <= 0)
			over_object.storage?.storage_item_attack_by(src, usr)

	proc/update_text()
		if (src.mode == FINGERPRINT_READ)
			src.inventory_counter.update_text("<span style='color:#00ff00;font-size:0.7em;-dm-text-outline: 1px #000000'>READ</span>")
		else
			src.inventory_counter.update_text("<span stywle='color:#ff0000;font-size:0.7em;-dm-text-outline: 1px #000000'>PLANT</span>")

	proc/pre_attackby(obj/item/source, atom/target, mob/user)
		if (src.mode == FINGERPRINT_READ)
			src.read_prints(user, target)
		else
			src.plant_print(user, target)
		return TRUE // suppress attackby

	proc/toggle_mode(mob/user)
		if (src.mode == FINGERPRINT_READ)
			src.mode = FINGERPRINT_PLANT
		else
			src.mode = FINGERPRINT_READ
		src.update_text()

	proc/plant_print(mob/user, atom/target)
		if (target.flags & NOFPRINT)
			boutput(user, SPAN_ALERT("You can't plant a fingerprint onto that."))
			return

		var/datum/forensic_group/fingerprints/fp_scan_group = src.scanned_evidence.get_group(FORENSIC_GROUP_FINGERPRINTS)
		if(!istype(fp_scan_group) || !fp_scan_group.evidence_list)
			boutput(user, SPAN_ALERT("You don't have any fingerprints saved! Set [src] to the [SPAN_ALERT("READ")] mode and scan some things!"))
			return
		var/options_list = list()
		var/list/datum/forensic_data/fingerprint/fprint_list = fp_scan_group.evidence_list
		for(var/datum/forensic_data/fingerprint/fprint in fprint_list)
			options_list[fprint.get_text()] = fprint

		var/selected = tgui_input_list(user, "Select a print to plant:", "Fingerprinter", options_list)
		if (!selected)
			return
		var/datum/forensic_data/fingerprint/fprint = options_list[selected]
		if(!istype(fprint))
			return
		var/datum/forensic_data/fingerprint/planted_print = fprint.get_copy()
		planted_print.time_start = TIME // Don't carry over the time of the scanned fingerprint
		planted_print.time_end = TIME
		target.add_evidence(planted_print, FORENSIC_GROUP_FINGERPRINTS)


		/*
		if (!length(current_prints))
			boutput(user, SPAN_ALERT("You don't have any fingerprints saved! Set [src] to the [SPAN_ALERT("READ")] mode and scan some things!"))
			return

		// List mapping readable options to literal prints
		var/list/datum/forensic_data/fingerprint/optionslist = list()
		for (var/list/datum/forensic_data/fingerprint/print in src.current_prints)
			var/txt = print.get_text()
			optionslist[txt] = print // map to the print so we can get the actual print to plant

		var/selected = tgui_input_list(user, "Select a print to plant:", "Fingerprinter", optionslist)
		if (!selected)
			return

		target.add_evidence(optionslist[selected].get_copy(), FORENSIC_GROUP_FINGERPRINTS)
		*/

	// TODO maybe handle dupe glove prints more gracefully? if we see the same glove ID on 2 different people, list both names? idk
	proc/read_prints(mob/user, atom/target)
		// Yes, this currently lets you get the name of people through glove IDs. It's a traitor item so I think it's fine. Gnarly if sec finds one though.
		if (target.flags & NOFPRINT)
			boutput(user, SPAN_ALERT("That doesn't look like something you can read prints off of."))
			return
		var/read_prints = FALSE
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/datum/forensic_data/fingerprint/fprint_right = H.get_fingerprint(force_hand = RIGHT_HAND)
			var/datum/forensic_data/fingerprint/fprint_left = H.get_fingerprint(force_hand = LEFT_HAND)
			src.scanned_evidence.add_evidence(fprint_right, FORENSIC_GROUP_FINGERPRINTS)
			src.scanned_evidence.add_evidence(fprint_left, FORENSIC_GROUP_FINGERPRINTS)
			read_prints = TRUE

		var/datum/forensic_group/fingerprints/fp_group = target.forensic_holder.get_group(FORENSIC_GROUP_FINGERPRINTS)
		if (!istype(fp_group))
			if(read_prints)
				boutput(user, SPAN_SUCCESS("You read the prints on [target] into [src]."))
			else
				boutput(user, SPAN_ALERT("No prints on [target] to scan."))

		target.forensic_holder.copy_to(src.scanned_evidence, null)
		boutput(user, SPAN_SUCCESS("You read the prints on [target] into [src]."))
		// boutput(user, SPAN_ALERT("You've already scanned all the prints on [target]."))

#undef FINGERPRINT_PLANT
#undef FINGERPRINT_READ
