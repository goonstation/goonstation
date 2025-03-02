
/datum/surgery/heal_generic
	name = "First Aid"
	desc = "Heal BRUTE, BURN, or bleeding damage with surgery."
	default_sub_surgeries = list(/datum/surgery/heal_brute,	/datum/surgery/heal_burn, /datum/surgery/tend_bleeding)

/datum/surgery/heal_brute
	name = "Tend wounds"
	desc = "Heal BRUTE damage."

	generate_surgery_steps(mob/living/surgeon, mob/user)
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

	generate_surgery_steps(mob/living/surgeon, mob/user)
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

	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/fluff/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		patient.bleeding = 0
		regenerate_surgery_steps()

	surgery_possible(mob/living/surgeon)
		if (patient.bleeding > 0)
			return TRUE
		return FALSE
