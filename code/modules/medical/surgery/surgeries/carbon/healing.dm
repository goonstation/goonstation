
/datum/surgery/heal_generic
	name = "First Aid"
	desc = "Heal BRUTE, BURN, or bleeding damage with surgery."
	default_sub_surgeries = list(/datum/surgery/heal_brute,	/datum/surgery/heal_burn, /datum/surgery/tend_bleeding)

/datum/surgery/heal_brute
	name = "Tend wounds"
	desc = "Heal BRUTE damage."

	generate_surgery_steps()
		var/coin_toss = prob(50)
		if(coin_toss)
			add_next_step(new /datum/surgery_step/fluff/cut(src))
		else
			add_next_step(new /datum/surgery_step/fluff/snip(src))
		add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		patient.HealDamage("All", 15, 0)
		regenerate_surgery_steps()

	surgery_possible(mob/living/surgeon)
		if (patient.get_brute_damage() > 0)
			return TRUE
		return FALSE


/datum/surgery/heal_burn
	name = "Tend burns"
	desc = "Heal BURN damage with bandages."

	generate_surgery_steps()
		add_next_step(new /datum/surgery_step/fluff/bandage(src))
		add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		..()
		surgeon.HealDamage("All", 0, 15)
		regenerate_surgery_steps()
	surgery_possible(mob/living/surgeon)
		if (patient.get_burn_damage() > 0)
			return TRUE
		return FALSE

/datum/surgery/tend_bleeding
	name = "Tend bleeding"
	desc = "Heal BLEED damage with a suture."

	infer_surgery_stage()
		surgery_steps[1].finished = (patient.bleeding == 0)

	generate_surgery_steps()
		add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		patient.bleeding = 0

	surgery_possible(mob/living/surgeon)
		if (patient.bleeding > 0)
			return TRUE
		return FALSE

/datum/surgery/cauterize
	visible = FALSE
	implicit = TRUE
	cancel_possible()
		return FALSE
	surgery_conditions_met(mob/living/surgeon, obj/item/tool)
		return TRUE
	on_complete(mob/living/surgeon, mob/user)
		if (patient.bleeding)
			repair_bleeding_damage(patient, 50, rand(1,3))
	head
		name = "Cauterize - Head"
		desc = "Undo head surgery with a cautery."

		infer_surgery_stage()
			surgery_steps[1].finished = (patient.surgeryHolder.get_surgery_progress("brain_surgery") == 0)

		surgery_possible(mob/living/surgeon)
			if (surgeon.zone_sel.selecting != "head" || !patient.organHolder || !patient.organHolder?.head || patient.surgeryHolder.get_surgery_progress("brain_surgery") == 0)
				return FALSE
			. = ..()

		generate_surgery_steps()
			add_next_step( new/datum/surgery_step/cauterize/head(src))

		on_complete(mob/living/surgeon, mob/user)
			patient.surgeryHolder.cancel_surgery("brain_surgery", surgeon, user)
			..()

	bleeding
		name = "Cauterize Bleeding"
		desc = "Remove bleeding with a cautery."
		infer_surgery_stage()
			surgery_steps[1].finished = (patient.bleeding == 0)

		generate_surgery_steps()
			add_next_step( new/datum/surgery_step/cauterize/bleeding(src))


/datum/surgery/sutures
	default_sub_surgeries = list(/datum/surgery/suture/head, /datum/surgery/suture/torso, /datum/surgery/suture/r_leg, /datum/surgery/suture/l_leg, /datum/surgery/suture/r_arm, /datum/surgery/suture/l_arm, /datum/surgery/suture/bleeding)
	name = "Suture"
	desc = "Suture the head, torso, legs, or arms shut."
	cancel_possible()
		return FALSE
	implicit = TRUE
	visible = FALSE



/datum/surgery/suture
	name = "Suture"
	icon_state = "suture"
	implicit = TRUE
	visible = FALSE

	cancel_possible()
		return FALSE

	surgery_possible(mob/living/surgeon)
		if (surgeon.zone_sel.selecting != affected_zone)
			return FALSE
		var/list/datum/surgery/surgeries = holder.get_surgeries_by_zone(affected_zone)
		for (var/datum/surgery/surgery in surgeries)
			if (surgery.cancel_possible())
				return TRUE

	head
		desc = "Suture the head shut."
		affected_zone = "head"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/head(src))
	torso
		desc = "Suture the torso shut."
		affected_zone = "chest"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/torso(src))
	r_leg
		desc = "Suture the right leg shut."
		affected_zone = "r_leg"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/r_leg(src))
	l_leg
		desc = "Suture the left leg shut."
		affected_zone = "l_leg"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/l_leg(src))
	r_arm
		desc = "Suture the right arm shut."
		affected_zone = "r_arm"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/r_arm(src))
	l_arm
		desc = "Suture the left arm shut."
		affected_zone = "l_arm"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/l_arm(src))
	bleeding
		desc = "Suture a bleeding wound."
		affected_zone = "bleeding"
		generate_surgery_steps()
			add_next_step(new /datum/surgery_step/suture/bleeding(src))

		surgery_possible(mob/living/surgeon)
			return (patient.bleeding > 0)
