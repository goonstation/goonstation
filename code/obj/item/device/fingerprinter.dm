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
	/// List of prints currently scanned into the device. Each print maps to the name of the owner.
	var/list/current_prints
	var/mode = FINGERPRINT_READ
	HELP_MESSAGE_OVERRIDE({"Toggle modes by using the fingerprinter in hand.
							While on <b>"Read"</b> mode, use the tool on someone or something that has prints on it to add all the prints to the tool's print database.
							While on <b>"Plant"</b> mode, use the tool on anything to add any prints from the database on it."})

	New()
		. = ..()
		src.current_prints = list()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby)) // use this instead of afterattack so we're silent
		src.create_inventory_counter()
		src.update_text()

	attack_self(mob/user)
		. = ..()
		src.toggle_mode(user)

	proc/update_text()
		if (src.mode == FINGERPRINT_READ)
			src.inventory_counter.update_text("<span style='color:#00ff00;font-size:0.7em;-dm-text-outline: 1px #000000'>READ</span>")
		else
			src.inventory_counter.update_text("<span style='color:#ff0000;font-size:0.7em;-dm-text-outline: 1px #000000'>PLANT</span>")

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
		if (!(target.flags & FPRINT))
			boutput(user, "<span class='alert'>You can't plant a fingerprint onto that.</span>")
			return
		if (!length(current_prints))
			boutput(user, "<span class='alert'>You don't have any fingerprints saved! Set [src] to the <span class='success'>READ</span> mode and scan some things!")
			return

		// List mapping readable options to literal prints
		var/optionslist = list()
		for (var/print in src.current_prints)
			var/txt = print
			if (src.current_prints[print])
				txt += " ([src.current_prints[print]])"
			optionslist[txt] = print // map to the print so we can get the actual print to plant

		var/selected = tgui_input_list(user, "Select a print to plant:", "Fingerprinter", optionslist)
		if (!selected)
			return

		target.add_fingerprint_direct(optionslist[selected])

	// TODO maybe handle dupe glove prints more gracefully? if we see the same glove ID on 2 different people, list both names? idk
	proc/read_prints(mob/user, atom/target)
		// Yes, this currently lets you get the name of people through glove IDs. It's a traitor item so I think it's fine. Gnarly if sec finds one though.
		if (!(target.flags & FPRINT))
			boutput(user, "<span class='alert'>That doesn't look like something you can read prints off of.</span>")
			return
		if (!target.fingerprints && !ishuman(target))
			boutput(user, "<span class='alert'>There's no fingerprints to read off of that.</span>")
			return

		// This is gross and theoretically slow but we index full-prints by time, and the fingerprints list will only have 6 entries at max so
		// the time complexity doesn't really matter.
		var/found_new_print = FALSE
		for (var/print in target.fingerprints)
			if (!src.current_prints[print])
				found_new_print = TRUE
				for (var/timestamp in target.fingerprints_full)
					var/fullprint = target.fingerprints_full[timestamp]
					if (fullprint["seen_print"] == print)
						src.current_prints[print] = fullprint["real_name"]
						break
				if (!src.current_prints[print])
					src.current_prints[print] = "???"

		if (found_new_print)
			boutput(user, "<span class='success'>You read the prints on [target] into [src].</span>")
		else
			boutput(user, "<span class='alert'>You've already scanned all the prints on [target].</span>")

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.gloves)
				src.current_prints[H.gloves.distort_prints(H.bioHolder.fingerprints, TRUE)] = H.real_name // yes this sees through disguises. traitor item!!!! i wring my hands self-absolvingly
			else
				src.current_prints[H.bioHolder.fingerprints] = H.real_name
			boutput(user, "<span class='success'>You read [H.gloves ? "the prints of [H]'s gloves" : "[H]'s prints"] into [src].</span>")

#undef FINGERPRINT_PLANT
#undef FINGERPRINT_READ
