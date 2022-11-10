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
	var/last_mimiced_name = ""
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


		if (H?.ears && istype(H.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override && findtext(mimic_message,";") || findtext(mimic_message,":"))
				var/radio_override = input("Select a radio frequency to disguise as...", "Mimic Radio Message.", null, null) as null|anything in list("head","sec","eng","sci","med","qm","civ","cap","rd","md","ce","hop","hos","clown")
				if (radio_override)
					headset.icon_override = radio_override

		logTheThing(LOG_SAY, holder.owner, "[mimic_message] (<b>Mimicing ([constructTarget(mimic_name,"say")])</b>)")
		var/original_name = holder.owner.real_name
		holder.owner.real_name = copytext(mimic_name, 1, MOB_NAME_MAX_LENGTH)
		holder.owner.say(mimic_message)
		holder.owner.real_name = original_name

		if (H?.ears && istype(H.ears,/obj/item/device/radio/headset))
			var/obj/item/device/radio/headset/headset = H.ears
			if (headset.icon_override)
				headset.icon_override = initial(headset.icon_override)

		return 0
