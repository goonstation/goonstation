// i love enums
#define FINGERPRINT_PLANT 0
#define FINGERPRINT_READ 1
#define FINGERPRINT_SCAN 2
#define FINGERPRINT_SEARCH 3

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
	var/mode = FINGERPRINT_SCAN
	var/list/datum/contextAction/contexts = list()
	HELP_MESSAGE_OVERRIDE({"Toggle modes by using the fingerprinter in hand.
							While on <b>"Read"</b> mode, use the tool on someone or something that has prints on it to add all the prints to the tool's print database.
							While on <b>"Plant"</b> mode, use the tool on anything to add any prints from the database on it.
							While on <b>"Scan"</b> mode, use the tool on anything to detect forensic evidence.
							While on <b>"Search"</b> mode, enter evidence to search the security database with."})

	New()
		var/datum/contextLayout/experimentalcircle/layout = new /datum/contextLayout/experimentalcircle
		layout.start_angle = 157.5
		layout.total_angle = 135
		contextLayout = layout

		. = ..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby)) // use this instead of afterattack so we're silent
		src.create_inventory_counter()
		src.update_text()
		for(var/actionType in childrentypesof(/datum/contextAction/fingerprinter))
			var/datum/contextAction/fingerprinter/action = new actionType()
			src.contexts += action

	attack_self(var/mob/user)
		. = ..()
		if(src.contexts)
			user.showContextActions(src.contexts, src, src.contextLayout)

	mouse_drop(atom/over_object)
		. = ..()
		if (can_act(usr) && (src in usr.equipped_list()) && BOUNDS_DIST(usr, over_object) <= 0)
			over_object.storage?.storage_item_attack_by(src, usr)

	dropped(var/mob/user)
		. = ..()
		user.closeContextActions()

	proc/change_mode(var/new_mode, var/mob/holder)
		src.mode = new_mode
		if(new_mode == FINGERPRINT_SEARCH)
			src.update_text()
			forensic_search(holder);
			src.mode = FINGERPRINT_READ
		src.update_text()
		holder.playsound_local(src.loc, 'sound/machines/keypress.ogg', 8, 1, pitch = 2)

	proc/update_text()
		if (src.mode == FINGERPRINT_READ)
			src.inventory_counter.update_text("<span style='color:#00ff00;font-size:0.7em;-dm-text-outline: 1px #000000'>READ</span>")
		else if(src.mode == FINGERPRINT_PLANT)
			src.inventory_counter.update_text("<span style='color:#fab6a7;font-size:0.7em;-dm-text-outline: 1px #000000'>PLANT</span>")
		else if(src.mode == FINGERPRINT_SCAN)
			src.inventory_counter.update_text("<span style='color:#f6ff36;font-size:0.7em;-dm-text-outline: 1px #000000'>SCAN</span>")
		else
			src.inventory_counter.update_text("<span style='color:#00ffff;font-size:0.7em;-dm-text-outline: 1px #000000'>SEARCH</search>")

	proc/pre_attackby(obj/item/source, atom/target, mob/user)
		if (src.mode == FINGERPRINT_READ)
			src.read_prints(user, target)
		else if(src.mode == FINGERPRINT_PLANT)
			src.plant_print(user, target)
		else
			src.scan_prints(user, target);
		return TRUE // suppress attackby

	proc/forensic_search(mob/user as mob)
		var/holder = src.loc
		var/search = tgui_input_text(user, "Enter name, full/partial fingerprint, or blood DNA.", "Find record")
		if (src.loc != holder || !search || user.stat)
			return
		search = copytext(sanitize(search), 1, 200)
		boutput(user, data_core.general.forensic_search(search))
		return

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
		var/datum/forensic_scan/scan = new(null)
		scan.add_effect("effect_silver_nitrate")
		for(var/datum/forensic_data/fingerprint/fprint in fprint_list)
			options_list[strip_html_tags(fprint.get_text(scan))] = fprint

		var/selected = tgui_input_list(user, "Select a print to plant:", "Fingerprinter", options_list, capitalize = FALSE)
		if (!selected)
			return
		var/datum/forensic_data/fingerprint/fprint = options_list[selected]
		if(!istype(fprint))
			return
		var/datum/forensic_data/fingerprint/planted_print = fprint.get_copy()
		ADD_FLAG(planted_print.flags, FORENSIC_REMOVE_CLEANING)
		planted_print.time_start = TIME // Don't carry over the original time of the scanned fingerprint
		planted_print.time_end = TIME
		target.add_evidence(planted_print, FORENSIC_GROUP_FINGERPRINTS)
		boutput(user, "[src] planted \"[SPAN_ALERT(planted_print.get_text(scan))]\" on [target].")

	proc/read_prints(mob/user, atom/target)
		if (target.flags & NOFPRINT)
			boutput(user, SPAN_ALERT("That doesn't look like something you can read prints off of."))
			return
		var/datum/forensic_scan/scan = new(null)
		scan.add_effect("effect_silver_nitrate")

		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/datum/forensic_data/fingerprint/fprint_right = H.get_fingerprint(force_hand = RIGHT_HAND)
			var/datum/forensic_data/fingerprint/fprint_left = H.get_fingerprint(force_hand = LEFT_HAND)
			src.scanned_evidence.add_evidence(fprint_right, FORENSIC_GROUP_FINGERPRINTS)
			src.scanned_evidence.add_evidence(fprint_left, FORENSIC_GROUP_FINGERPRINTS)
			if(fprint_right && fprint_left)
				var/text_right = fprint_right.get_text(scan)
				var/text_left = fprint_left.get_text(scan)
				if(text_right != text_left)
					boutput(user, "[src] read \"[SPAN_SUCCESS(text_right)]\" and \"[SPAN_SUCCESS(text_left)]\" from [target].")
				else
					boutput(user, "[src] read \"[SPAN_SUCCESS(text_right)]\" from [target].")
			else if(fprint_right)
				boutput(user, "[src] read \"[SPAN_SUCCESS(fprint_right.get_text(scan))]\" from [target].")
			else if(fprint_left)
				boutput(user, "[src] read \"[SPAN_SUCCESS(fprint_left.get_text(scan))]\" from [target].")
			else
				boutput(user, SPAN_ALERT("No prints on [target] to scan."))
			return

		var/datum/forensic_group/fingerprints/fp_group = target.forensic_holder.get_group(FORENSIC_GROUP_FINGERPRINTS)
		if(!istype(fp_group) || !fp_group.evidence_list)
			boutput(user, SPAN_ALERT("No prints on [target] to scan."))
			return
		var/options_list = list()
		var/list/datum/forensic_data/fingerprint/fprint_list = fp_group.evidence_list
		for(var/datum/forensic_data/fingerprint/fprint in fprint_list)
			options_list[strip_html_tags(fprint.get_text(scan))] = fprint

		var/selected = tgui_input_list(user, "Select a print to read:", "Fingerprinter", options_list, capitalize = FALSE)
		if (!selected)
			return
		var/datum/forensic_data/fingerprint/fprint = options_list[selected]
		if(!istype(fprint))
			return
		src.scanned_evidence.add_evidence(fprint.get_copy(), FORENSIC_GROUP_FINGERPRINTS)
		// target.forensic_holder.copy_to(src.scanned_evidence, null)
		boutput(user, "[src] read \"[SPAN_SUCCESS(fprint.get_text(scan))]\" from [target].")

	proc/scan_prints(mob/user, atom/target)
		var/datum/forensic_scan/scan = scan_forensic(target, visible = FALSE)
		scan.add_effect("effect_silver_nitrate")
		var/scan_output = scan.build_report(compress = TRUE)
		boutput(user, scan_output)

/datum/contextAction/fingerprinter
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "yellow"
	var/mode = FINGERPRINT_SCAN

	execute(var/obj/item/device/fingerprinter/fingerprinter, var/mob/user)
		if (!istype(fingerprinter))
			return
		fingerprinter.change_mode(src.mode, user)

	checkRequirements(var/obj/item/device/fingerprinter/fingerprinter, var/mob/user)
		if(!can_act(user) || !in_interact_range(fingerprinter, user))
			return FALSE
		return fingerprinter in user

	scan
		name = "Scan"
		icon_state = "fingerprint_scan"
		mode = FINGERPRINT_SCAN
	read
		name = "Read"
		icon_state = "fingerprint_read"
		mode = FINGERPRINT_READ
	plant
		name = "Plant"
		icon_state = "fingerprint_plant"
		mode = FINGERPRINT_PLANT
	search
		name = "Search"
		icon_state = "fingerprint_search"
		mode = FINGERPRINT_SEARCH

#undef FINGERPRINT_PLANT
#undef FINGERPRINT_READ
#undef FINGERPRINT_SCAN
#undef FINGERPRINT_SEARCH
