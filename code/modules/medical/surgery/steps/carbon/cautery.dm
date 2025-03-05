/datum/surgery_step/cauterize
	proc/is_quick_surgery(mob/surgeon,obj/item/tool)
		var/mob/living/carbon/human/patient = parent_surgery.patient
		if (!patient)
			return FALSE
		if (!ishuman(patient)) // is the patient not a human?
			return FALSE
		// is the patient on an optable and lying?
		if (locate(/obj/machinery/optable, patient.loc))
			if(patient.lying || patient == surgeon)
				return TRUE
		// is the patient on a table and paralyzed or dead?
		else if ((locate(/obj/stool/bed, patient.loc) || locate(/obj/table, patient.loc)) && (patient.getStatusDuration("unconscious") || patient.stat))
			return TRUE
		// is the patient really drunk and also the surgeon?
		else if (patient.reagents && (patient.reagents.get_reagent_amount("ethanol") > 40 || patient.reagents.get_reagent_amount("morphine") > 5) && (patient == surgeon || (locate(/obj/stool/bed, patient.loc) && patient.lying)))
			return TRUE
		return FALSE



	head
		name = "Cauterize"
		desc = "Cauterize the head shut."
		icon_state = "cauterize"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CAUTERY

		do_surgery_step(mob/living/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			if (patient.is_heat_resistant())
				surgeon.visible_message(SPAN_ALERT("<b>Nothing happens!</b>"))
				return FALSE

			var/damage = rand(5, 15)

			if (istype(tool, /obj/item/match))
				damage = 5
			else if (istype(tool, /obj/item/device/light/zippo))
				damage = 10
			else if (istype(tool, /obj/item/device/igniter) || istype(tool, /obj/item/tool/omnitool) ||  istype(tool, /obj/item/weldingtool))
				damage = 15

			if (is_quick_surgery(surgeon, tool))
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [tool]."))

				return TRUE

			else
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your neck closed with [tool]."))

				if (do_mob(surgeon, patient, max(100 - (damage * 2)), 0))
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
						SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
						SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [tool]."))
					if (patient.bleeding)
						repair_bleeding_damage(patient, 50, rand(1,3))
					return TRUE

				else
					surgeon.show_text("<b>You were interrupted!</b>", "red")
					return TRUE


	bleeding
		name = "Cauterize"
		desc = "Cauterize bleeding."
		icon_state = "cauterize"
		success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
		flags_required = TOOL_CAUTERY


		on_complete(mob/user, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			user.tri_message(patient, SPAN_ALERT("<b>[user]</b> cauterizes [patient == user ? "[his_or_her(patient)]" : "[patient]'s"] wounds with [tool]!"),\
				SPAN_ALERT("You cauterize [user == patient ? "your" : "[patient]'s"] wounds with [tool]!"),\
				SPAN_ALERT("[patient == user ? "You cauterize" : "<b>[user]</b> cauterizes"] your wounds with [tool]!"))
			if (patient.bleeding)
				repair_bleeding_damage(patient, 50, rand(1,3))

		do_surgery_step(mob/living/surgeon, obj/item/tool)
			var/mob/living/carbon/human/patient = parent_surgery.patient
			if (patient.is_heat_resistant())
				surgeon.visible_message(SPAN_ALERT("<b>Nothing happens!</b>"))
				return FALSE

			var/damage = rand(5, 15)

			if (istype(tool, /obj/item/match))
				damage = 5
			else if (istype(tool, /obj/item/device/light/zippo))
				damage = 10
			else if (istype(tool, /obj/item/device/igniter) || istype(tool, /obj/item/tool/omnitool) ||  istype(tool, /obj/item/weldingtool))
				damage = 15

			if (is_quick_surgery(surgeon, tool))
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [tool]."))

				return TRUE

			else
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> begins cauterizing the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("You begin cauterizing the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
					SPAN_NOTICE("[patient == surgeon ? "You begin" : "<b>[surgeon]</b> begins"] cauterizing incision on your neck closed with [tool]."))

				if (do_mob(patient, surgeon, max(100 - (damage * 2)), 0))
					surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> cauterizes the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] neck closed with [tool]."),\
						SPAN_NOTICE("You cauterize the incision on [surgeon == patient ? "your" : "[patient]'s"] neck closed with [tool]."),\
						SPAN_NOTICE("[patient == surgeon ? "You cauterize" : "<b>[surgeon]</b> cauterizes"] the incision on your neck closed with [tool]."))
					return TRUE

				else
					surgeon.show_text("<b>You were interrupted!</b>", "red")
					return TRUE
