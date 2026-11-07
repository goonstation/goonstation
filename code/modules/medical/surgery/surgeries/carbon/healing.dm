/datum/surgery/carbon
	generate_cancel_steps()
		add_cancel_step(new/datum/surgery_step/suture/cancel(src))


/datum/surgery/carbon/heal_generic
	id = "heal_generic"
	name = "First Aid"
	desc = "Heal BRUTE or BURN damage with surgery."
	affected_zone = "chest"
	default_sub_surgeries = list(/datum/surgery/carbon/heal_brute,	/datum/surgery/carbon/heal_burn)

/datum/surgery/carbon/heal_brute
	id = "heal_brute"
	name = "Tend wounds"
	desc = "Heal BRUTE damage."
	affected_zone = "chest"

	generate_surgery_steps()
		if(prob(50))
			src.add_next_step(new /datum/surgery_step/fluff/cut(src))
		else
			src.add_next_step(new /datum/surgery_step/fluff/snip(src))
		src.add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, obj/item/tool)
		patient.HealDamage("All", 15, 0)
		regenerate_surgery_steps()

	surgery_possible(mob/living/surgeon)
		if (patient.get_brute_damage() > 0)
			return TRUE
		return FALSE


/datum/surgery/carbon/heal_burn
	id = "heal_burn"
	name = "Tend burns"
	desc = "Heal BURN damage with bandages."
	affected_zone = "chest"

	generate_surgery_steps()
		src.add_next_step(new /datum/surgery_step/fluff/bandage(src))
		src.add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, obj/item/tool)
		..()
		surgeon.HealDamage("All", 0, 15)
		regenerate_surgery_steps()
	surgery_possible(mob/living/surgeon)
		if (patient.get_burn_damage() > 0)
			return TRUE
		return FALSE

/datum/surgery/carbon/cauterize
	id = "cauterize"
	visible = FALSE
	implicit = TRUE
	cancel_possible()
		return FALSE
	surgery_conditions_met(mob/living/surgeon, obj/item/tool)
		return TRUE
	on_complete(mob/living/surgeon, obj/item/tool)
		if (patient.bleeding)
			repair_bleeding_damage(patient, 50, rand(1,3))
	head
		name = "Cauterize - Head"
		desc = "Undo head surgery with a cautery."

		check_surgery_stage()
			surgery_steps[1].completed = (patient.surgeryHolder.get_surgery_progress("brain_surgery") == 0)
			..()

		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head" || !patient.organHolder || !patient.organHolder?.head || patient.surgeryHolder.get_surgery_progress("brain_surgery") == 0)
				return FALSE
			. = ..()

		generate_surgery_steps()
			src.add_next_step( new/datum/surgery_step/cauterize/head(src))

		on_complete(mob/living/surgeon, obj/item/tool)
			patient.surgeryHolder.cancel_all_in_zone("head", surgeon, tool)
			..()

	bleeding
		name = "Cauterize Bleeding"
		desc = "Remove bleeding with a cautery."
		check_surgery_stage()
			surgery_steps[1].completed = (patient.bleeding == 0)
			..()

		generate_surgery_steps()
			src.add_next_step( new/datum/surgery_step/cauterize/bleeding(src))


/datum/surgery/carbon/category/sutures
	id = "suture_category"
	name = "Suture"
	desc = "Suture wounds on the head, torso, legs, or arms."
	default_sub_surgeries = list(/datum/surgery/carbon/suture/head, /datum/surgery/carbon/suture/torso, /datum/surgery/carbon/suture/r_leg, /datum/surgery/carbon/suture/l_leg, /datum/surgery/carbon/suture/r_arm, /datum/surgery/carbon/suture/l_arm, /datum/surgery/carbon/suture/bleeding)
	sub_surgeries_always_accessible = TRUE
	cancel_possible()
		return FALSE
	implicit = TRUE
	visible = FALSE



/datum/surgery/carbon/suture
	id = "suture"
	name = "Suture"
	icon_state = "suture"
	implicit = TRUE
	visible = FALSE

	cancel_possible()
		return FALSE

	surgery_possible(mob/living/surgeon)
		if (surgeon.zone_sel.selecting != affected_zone)
			return FALSE
		var/list/datum/surgery/carbon/surgeries = holder.get_surgeries_by_zone(affected_zone)
		for (var/datum/surgery/carbon/surgery in surgeries)
			if (surgery.cancel_possible())
				return TRUE
		return FALSE

	head
		id = "suture_head"
		desc = "Suture the head shut."
		affected_zone = "head"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/head(src))
	torso
		id = "suture_torso"
		desc = "Suture the torso shut."
		affected_zone = "chest"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/torso(src))
	r_leg
		id = "suture_r_leg"
		desc = "Suture the right leg shut."
		affected_zone = "r_leg"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/r_leg(src))
	l_leg
		id = "suture_l_leg"
		desc = "Suture the left leg shut."
		affected_zone = "l_leg"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/l_leg(src))
	r_arm
		id = "suture_r_arm"
		desc = "Suture the right arm shut."
		affected_zone = "r_arm"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/r_arm(src))
	l_arm
		id = "suture_l_arm"
		desc = "Suture the left arm shut."
		affected_zone = "l_arm"
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/l_arm(src))
	bleeding
		id = "suture_bleeding"
		desc = "Suture a bleeding wound."
		surgery_conditions_met(mob/surgeon, obj/item/tool)
			if (!patient)
				return FALSE
			if (!ishuman(patient))
				return FALSE
			return TRUE
		generate_surgery_steps()
			src.add_next_step(new /datum/surgery_step/suture/bleeding(src))

		surgery_possible(mob/living/surgeon)
			return (patient.bleeding > 0)
