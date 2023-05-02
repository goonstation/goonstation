/datum/targetable/changeling/mimic_voice
	name = "Mimic Voice"
	desc = "Sound like someone else!"
	icon_state = "mimicvoice"
	human_only = TRUE
	lock_holder = FALSE
	ignore_holder_lock = TRUE
	interrupt_action_bars = FALSE
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED // stunned is fine, unconcious isn't (can't talk)
	var/last_mimiced_name = ""
	/// List for what changelings can mimic over radio, key refers to headset.icon_tooltip and is used in the selection menu and value refers to
	/// associated headset.icon_override, check headsets.dm
	var/headset_icon_labels = list(
		"Captain" = "cap",
		"Head of Personnel" = "hop",
		"Head of Security" = "hos",
		"Head of Staff" = "head",
		"Research Director" = "rd",
		"Medical Director" = "md",
		"Chief Engineer" = "ce",
		"Nanotrasen Security Consultant" = "nt",
		"Security" = "sec",
		"Detective" = "det",
		"Scientist" = "sci",
		"Medical" = "med",
		"Engineer" = "eng",
		"Quartermaster" = "qm",
		"Miner" = "Min",
		"Civilian" = "civ",
		"Radio Show Host" = "rh",
		"Mailman" = "mail",
		"Clown" = "clown")

	cast(atom/target)
		. = ..()
		var/mimic_name = html_encode(input("Choose a name to mimic:", "Mimic Target.", last_mimiced_name) as null|text)

		if (!mimic_name)
			return TRUE
		if(mimic_name != last_mimiced_name)
			phrase_log.log_phrase("voice-mimic", mimic_name, no_duplicates=TRUE)
		last_mimiced_name = mimic_name //A little qol, probably.

		var/mimic_message = html_encode(input("Choose something to say:", "Mimic Message.", "") as null|text)

		if (!mimic_message)
			return TRUE

		var/mob/living/carbon/human/H
		if (ishuman(holder.owner))
			H = holder.owner

		if (istype(H?.ears, /obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override && findtext(mimic_message,";") || findtext(mimic_message,":"))
				var/radio_tooltip = input("Select a radio frequency to disguise as...", "Mimic Radio Message.", null, null) as null|anything in headset_icon_labels
				if (radio_tooltip)
					var/radio_override = headset_icon_labels[radio_tooltip]
					headset.icon_override = radio_override
					headset.icon_tooltip = radio_tooltip

		logTheThing(LOG_SAY, holder.owner, "[mimic_message] (<b>Mimicing ([constructTarget(mimic_name,"say")])</b>)")
		var/original_name = holder.owner.real_name
		src.holder.owner.real_name = copytext(mimic_name, 1, MOB_NAME_MAX_LENGTH)
		src.holder.owner.say(mimic_message)
		src.holder.owner.real_name = original_name

		if (istype(H?.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override)
				headset.icon_override = initial(headset.icon_override)
				headset.icon_tooltip = initial(headset.icon_tooltip)
