/datum/surgery_step/suture
	name = "Suture"
	icon_state = "suture"
	success_sound = 'sound/impact_sounds/Slimy_Cut_1.ogg'
	tool_types_required = list(/obj/item/suture, /obj/item/staple_gun, /obj/item/bandage)
	repeatable = TRUE
	var/loc = ""
	success_damage = 0
	can_fail = FALSE // matching old behaviour. this could be changed in future... :getin:

	proc/mark_stupid_thing_as_used(obj/item/tool)
		if (istype(tool, /obj/item/suture))
			var/obj/item/suture/suture = tool
			suture.in_use = 1
		if (istype(tool, /obj/item/bandage))
			var/obj/item/bandage/bandage = tool
			bandage.in_use = 1

	// Suture step for cancelling all surgeries in a zone.
	do_surgery_step(mob/living/surgeon, obj/item/tool)
		var/mob/living/patient = parent_surgery.patient
		var/list/datum/surgery/surgeries = parent_surgery.holder.get_surgeries_by_zone(loc)
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.cancel_possible())
				surgery.cancel(surgeon, tool)
				if (patient.bleeding)
					repair_bleeding_damage(patient, 50, rand(1,3))
				return TRUE

	cancel // Generic 'Cancel' step for surgeries
		desc = "Suture or staple the patient and cancel this surgery."
		repeatable = FALSE
		optional = TRUE
		success_sound = FALSE
		can_operate(mob/living/surgeon, obj/item/tool, quiet)
			if (!istype(tool, /obj/item/suture) && !istype(tool, /obj/item/staple_gun))
				if (!quiet)
					boutput(surgeon, SPAN_ALERT("You need a suture or staple gun to cancel surgery!"))
				return FALSE
			if (!can_use_stapler_bandage_shitfuck(surgeon, tool))
				return FALSE
		do_surgery_step(mob/living/surgeon, obj/item/tool)
			var/mob/living/patient = parent_surgery.patient
			if (istype(tool, /obj/item/staple_gun))
				playsound(patient, "sound/items/med_staple.ogg", 50, TRUE)
			else
				playsound(patient, "sound/impact_sounds/Slimy_Cut_1.ogg", 50, TRUE)
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
		desc = "Suture a bleeding wound."
		can_operate(mob/living/surgeon, obj/item/tool, quiet)
			if (!can_use_stapler_bandage_shitfuck(surgeon, tool, quiet))
				return FALSE
		do_surgery_step(mob/living/surgeon, obj/item/tool)
			var/patient = parent_surgery.patient
			mark_stupid_thing_as_used(tool)
			var/brute_heal = 0
			var/burn_heal = 0
			if (istype(tool, /obj/item/bandage))
				var/obj/item/bandage/bandage = tool
				brute_heal = bandage.brute_heal
				burn_heal = bandage.burn_heal
			actions.start(new /datum/action/bar/icon/medical_suture_bandage(patient, tool, 15, 0,0, 5, brute_heal, burn_heal, Vrb = "sutur"), surgeon)
