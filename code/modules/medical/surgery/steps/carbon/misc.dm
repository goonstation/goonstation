
/datum/surgery_step/item
	insert
		name = "Insert"
		desc = "Insert the item."
		icon_state = "in"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		tool_requirement(mob/surgeon, obj/item/tool)
			if(tool.w_class > W_CLASS_NORMAL && !(tool.type in chestitem_whitelist))
				boutput(surgeon, SPAN_ALERT("[tool] is too big to fit into [parent_surgery.patient]'s chest cavity."))
				return FALSE
			return TRUE

		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			playsound(patient, 'sound/impact_sounds/Slimy_Cut_1.ogg', 50, TRUE)
			surgeon.drop_item(tool)
			tool.set_loc(patient)
			patient.chest_item = tool
			logTheThing(LOG_COMBAT, patient, "received a surgical chest item implant of \the [tool] ([tool.type]) by [constructTarget(surgeon,"combat")]")

			if(surgeon.find_type_in_hand(/obj/item/suture))
				patient.chest_item_sewn = TRUE
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> shoves [tool] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest and sutures it up."),\
					SPAN_NOTICE("You shove [tool] into [surgeon == patient ? "your" : "[patient]'s"] chest and suture it up."),\
					SPAN_NOTICE("[patient == surgeon ? "You shove [tool] into your chest and suture it up" : "<b>[surgeon]</b> shoves [tool] into your chest and sutures it up"]."))
				patient.TakeDamage("chest", rand(5, 15), 0)
			else
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> shoves [tool] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest."),\
					SPAN_NOTICE("You shove [tool] into [surgeon == patient ? "your" : "[patient]'s"] chest."),\
					SPAN_NOTICE("[patient == surgeon ? "You shove" : "<b>[surgeon]</b> shoves"] [tool] into your chest."))

	secure
		name = "Secure"
		desc = "Secure the item."
		icon_state = "suture"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		tools_required = list(/obj/item/suture)
		optional = TRUE
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			patient.chest_item_sewn = TRUE
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the [patient.chest_item] into [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity with [src]."),\
				SPAN_NOTICE("You sew the [patient.chest_item] securely into [surgeon == patient ? "your" : "[patient]'s"] chest cavity with [src]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the [patient.chest_item] into your chest cavity with [src]."))
	remove
		name = "Remove"
		desc = "Remove the item."
		icon_state = "out"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CUTTING
		optional = TRUE
		on_complete(mob/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> removes the [patient.chest_item] from [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] chest cavity."),\
				SPAN_NOTICE("You remove the [patient.chest_item] from [surgeon == patient ? "your" : "[patient]'s"] chest cavity."),\
				SPAN_NOTICE("[patient == surgeon ? "You remove" : "<b>[surgeon]</b> removes"] the [patient.chest_item] from your chest cavity."))
			logTheThing(LOG_COMBAT, patient, "had their [patient.chest_item] removed by [constructTarget(surgeon,"combat")]")
			patient.chest_item.set_loc(get_turf(patient))
			patient.chest_item = null
/datum/surgery_step/parasite
	name = "Remove"
	desc = "Remove the parasite."
	icon_state = "scalpel"
	success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
	flags_required = TOOL_CUTTING
	optional = TRUE

	on_complete(mob/surgeon, obj/item/tool)
		var/mob/living/carbon/human/patient = parent_surgery.patient
		var/any_successes = FALSE
		for (var/datum/ailment_data/an_ailment in patient.ailments)
			if (an_ailment.cure_flags & CURE_SURGERY)
				var/success = an_ailment.surgery(surgeon, patient)
				any_successes = any_successes || success
				if (success)
					patient.cure_disease(an_ailment) // surgeon.cure_disease(an_ailment) no, doctor, DO NOT HEAL THYSELF, HEAL THY PATIENT
				else
					break
		if (any_successes)
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts out a parasite from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [tool]!"),\
				SPAN_ALERT("You cut out a parasite from [surgeon == patient ? "yourself" : "[patient]"] with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out a parasite from you with [tool]!"))
