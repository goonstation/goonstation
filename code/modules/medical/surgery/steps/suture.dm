/datum/surgery_step/suture
	name = "Suture"
	icon_state = "suture"
	success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
	tools_required = list(/obj/item/suture)
	repeatable = TRUE
	var/loc = ""
	success_damage = 0
	do_surgery_step(mob/living/surgeon, obj/item/tool)
		var/mob/living/patient = parent_surgery.patient
		var/list/datum/surgery/surgeries = parent_surgery.holder.get_surgeries_by_zone(loc)
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.cancel_possible(surgeon, tool))
				surgery.cancel_surgery(surgeon, tool, quiet = FALSE)
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return TRUE

	head
		desc = "Suture the head shut."
		loc = "head"
	torso
		desc = "Suture the torso shut."
		loc = "chest"
	r_leg
		desc = "Suture the right leg shut."
		loc = "r_leg"
	l_leg
		desc = "Suture the left leg shut."
		loc = "l_leg"
	r_arm
		desc = "Suture the right arm shut."
		loc = "r_arm"
	l_arm
		desc = "Suture the left arm shut."
		loc = "l_arm"
	bleeding
		do_surgery_step(mob/living/surgeon, obj/item/tool)
			surgeon.tri_message(parent_surgery.patient, SPAN_NOTICE("<b>[surgeon]</b> sews [parent_surgery.patient == surgeon ? "[his_or_her(parent_surgery.patient)]" : "[parent_surgery.patient]'s"] wounds closed with [tool]."),\
			"You sew [surgeon == parent_surgery.patient ? "your" : "[parent_surgery.patient]'s"] wounds closed with [tool].",\
			SPAN_NOTICE("[parent_surgery.patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] your wounds closed with [tool]."))
			repair_bleeding_damage(parent_surgery.patient, 100, 10)
		desc = "Suture a bleeding wound."
		loc = "bleeding"
