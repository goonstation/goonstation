/datum/surgery/heal_brute
	name = "Tend wounds"
	desc = "Heal BRUTE damage."
	restart_when_finished = TRUE

	///Create the surgery steps for this surgery - These will be removed when completed
	generate_surgery_steps(mob/living/surgeon, mob/user)
		var/coin_toss = prob(50)
		if(coin_toss)
			surgery_steps += new /datum/surgery_step/cut(src)
		else
			surgery_steps += new /datum/surgery_step/snip(src)
		surgery_steps += new /datum/surgery_step/suture(src)

	on_complete(mob/living/surgeon, mob/user)
		patient.HealDamage("All", 15, 0)

/datum/surgery/heal_burn
	name = "Tend burns"
	desc = "Heal BURN damage with bandages."
	restart_when_finished = TRUE

	generate_surgery_steps(mob/living/surgeon, mob/user)
		surgery_steps += list(new /datum/surgery_step/bandage(src),
		new /datum/surgery_step/suture(src))

	on_complete(mob/living/surgeon, mob/user)
		..()
		surgeon.HealDamage("All", 0, 15)


/datum/surgery/heal_generic
	name = "Tend wounds"
	desc = "Heal BRUTE or BURN damage with surgery."
	default_sub_surgeries = list(/datum/surgery/heal_brute,	/datum/surgery/heal_burn)
