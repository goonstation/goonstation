/datum/surgery_step/suture
	name = "Suture"
	icon_state = "suture"
	success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
	tools_required = list(/obj/item/suture)
	repeatable = TRUE
	var/loc = ""

	do_surgery_step(mob/living/surgeon, obj/item/tool)
		var/list/datum/surgery/surgeries = parent_surgery.holder.get_surgeries_by_zone(loc)
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.get_surgery_progress() > 0)
				var/mob/living/patient = parent_surgery.patient
				surgery.cancel_surgery(surgeon, tool)
				surgeon.tri_message(patient, SPAN_NOTICE("<b>[surgeon]</b> sews the incision on [patient == surgeon ? "[his_or_her(patient)]" : "[patient]'s"] [loc] closed with [tool], cancelling their [surgery.name]."),\
				SPAN_NOTICE("You sew the incision on [surgeon == patient ? "your" : "[patient]'s"] [loc] closed with [tool], cancelling [surgeon == patient ? "your" : "their"] [surgery.name]."),\
				SPAN_NOTICE("[patient == surgeon ? "You sew" : "<b>[surgeon]</b> sews"] the incision on your [loc] closed with [tool], cancelling your [surgery.name]."))
				return TRUE

	head
		desc = "Suture the head shut."
		loc = "head"
	torso
		desc = "Suture the torso shut."
		loc = "torso"
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
