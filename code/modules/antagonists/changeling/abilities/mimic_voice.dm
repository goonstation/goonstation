/datum/targetable/changeling/mimic_voice
	name = "Mimic Voice"
	desc = "Sound like someone else!"
	icon_state = "mimicvoice"
	cooldown = 0
	targeted = 0
	target_anything = 0
	human_only = 1
	can_use_in_container = 1
	interrupt_action_bars = 0
	do_logs = FALSE
	interrupt_action_bars = FALSE
	var/last_mimiced_name = ""
	var/mimicable_headsets = list( // List of mimicable headsets
		// Command
		/obj/item/device/radio/headset/command/captain,
		/obj/item/device/radio/headset/command/hop,
		/obj/item/device/radio/headset/command/hos,
		/obj/item/device/radio/headset/command/rd,
		/obj/item/device/radio/headset/command/md,
		/obj/item/device/radio/headset/command/ce,
		/obj/item/device/radio/headset/command,

		// Security
		/obj/item/device/radio/headset/command/nt/consultant,
		/obj/item/device/radio/headset/security,
		/obj/item/device/radio/headset/detective,

		// Research
		/obj/item/device/radio/headset/research,

		// Medical
		/obj/item/device/radio/headset/medical,
		/obj/item/device/radio/headset/medical/genetics,
		/obj/item/device/radio/headset/medical/robotics,
		/obj/item/device/radio/headset/pharmacist,

		// Engineering
		/obj/item/device/radio/headset/engineer,
		/obj/item/device/radio/headset/shipping,
		/obj/item/device/radio/headset/miner,

		// Civilian
		/obj/item/device/radio/headset/civilian,
		/obj/item/device/radio/headset/civilian/chaplain,
		/obj/item/device/radio/headset/civilian/hydroponics,
		/obj/item/device/radio/headset/civilian/catering,
		/obj/item/device/radio/headset/civilian/janitor,
		/obj/item/device/radio/headset/command/radio_show_host,
		/obj/item/device/radio/headset/mail,
		/obj/item/device/radio/headset/clown,

		// Special roles
		/obj/item/device/radio/headset/clown/blue,
		/obj/item/device/radio/headset/command/inspector,
		/obj/item/device/radio/headset/ghost_buster)

	cast(atom/target)
		if (..())
			return 1
		var/mimic_name = html_encode(input("Choose a name to mimic:","Mimic Target.",last_mimiced_name) as null|text)

		if (!mimic_name)
			return 1
		if(mimic_name != last_mimiced_name)
			phrase_log.log_phrase("voice-mimic", mimic_name, no_duplicates=TRUE)
		last_mimiced_name = mimic_name //A little qol, probably.

		var/mimic_message = html_encode(input("Choose something to say:","Mimic Message.","") as null|text)

		if (!mimic_message)
			return 1

		var/mob/living/carbon/human/H = 0
		if (ishuman(holder.owner))
			H = holder.owner

		var/headset_was_comic = FALSE
		if (H?.ears && istype(H.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override && findtext(mimic_message,";") || findtext(mimic_message,":"))
				var/list/headset_options = list()
				for(var/obj/item/device/radio/headset/headset_type as anything in src.mimicable_headsets)
					headset_options |= list("[headset_type.icon_tooltip]" = "[headset_type.icon_override]")

				var/radio_tooltip = tgui_input_list(src.holder.owner, "Select a radio to disguise as...", "Mimic Radio Selection", headset_options)
				if (radio_tooltip)
					headset.icon_override = headset_options[radio_tooltip]
					headset.icon_tooltip = radio_tooltip
					headset_was_comic = headset.ensure_listen_tree().GetModifierByID(LISTEN_MODIFIER_COMIC_SANS)
					//This is heavily jank but I'm not aware of anything better without a complete refactor of this ability
					if((radio_tooltip == "Clown" || radio_tooltip == "Blue Clown") && !headset_was_comic)
						headset.ensure_listen_tree().AddListenModifier(LISTEN_MODIFIER_COMIC_SANS)
					else if(headset_was_comic)
						headset.ensure_listen_tree().RemoveListenModifier(LISTEN_MODIFIER_COMIC_SANS)
						headset_was_comic = TRUE

		logTheThing(LOG_SAY, holder.owner, "[mimic_message] (<b>Mimicing ([constructTarget(mimic_name,"say")])</b>)")
		var/original_name = holder.owner.real_name
		holder.owner.real_name = copytext(mimic_name, 1, MOB_NAME_MAX_LENGTH)
		holder.owner.say(mimic_message)
		holder.owner.real_name = original_name

		if (H?.ears && istype(H.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override)
				headset.icon_override = initial(headset.icon_override)
				headset.icon_tooltip = initial(headset.icon_tooltip)
				if(!headset_was_comic)
					headset.ensure_listen_tree().RemoveListenModifier(LISTEN_MODIFIER_COMIC_SANS)
				else
					headset.ensure_listen_tree().AddListenModifier(LISTEN_MODIFIER_COMIC_SANS)

		return 0
