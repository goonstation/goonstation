/datum/surgery/implant
	id = "implant_surgery"
	name = "Implant Surgery"
	desc = "Remove an implant from the patients' body."
	icon_state = "implant"
	cancel_possible()
		return FALSE

	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		var/mob/living/carbon/human/C = patient
		if (length(C.implant) == 0)
			return FALSE
		return TRUE

	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/fluff/cut(src))

	infer_surgery_stage()
		var/mob/living/carbon/human/C = patient
		surgery_steps[1].finished = (length(C.implant) == 0)

	on_complete(mob/surgeon, obj/item/tool)
		for (var/obj/item/implant/projectile/I in patient.implant)
			surgeon.tri_message(patient, SPAN_ALERT("<b>[surgeon]</b> cuts out \an [I] from [patient == surgeon ? "[him_or_her(patient)]self" : "[patient]"] with [tool]!"),\
				SPAN_ALERT("You cut out \an [I] from [surgeon == patient ? "yourself" : "[patient]"] with [tool]!"),\
				SPAN_ALERT("[patient == surgeon ? "You cut" : "<b>[surgeon]</b> cuts"] out \an [I] from you with [tool]!"))

			I.on_remove(patient)
			patient.implant.Remove(I)
			I.set_loc(patient.loc)
			// offset approximately around chest area, based on cutting over operating table
			I.pixel_x = rand(-2, 5)
			I.pixel_y = rand(-6, 1)
			return ..()

/datum/surgery/parasite
	name = "Parasite Surgery"
	desc = "Cut out one or multiple parasites."
	icon_state = "parasite"
	visible = FALSE
	implicit = TRUE

	surgery_possible(mob/living/surgeon)
		if (!iscarbon(patient))
			return FALSE
		for (var/datum/ailment_data/an_ailment in patient.ailments)
			if (an_ailment.cure_flags & CURE_SURGERY)
				return TRUE
		return FALSE
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new/datum/surgery_step/parasite(src))






