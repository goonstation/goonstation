/datum/surgery/heal_brute
	name = "Tend wounds"
	desc = "Heal BRUTE damage."

	///Create the surgery steps for this surgery - These will be removed when completed
	generate_surgery_steps(mob/living/target, mob/user)
		var/coin_toss = prob(50)
		if(coin_toss)
			surgery_steps += new /datum/surgery_step/cut(src)
		else
			surgery_steps += new /datum/surgery_step/snip(src)
		surgery_steps += new /datum/surgery_step/suture(src)

	complete_surgery(mob/living/target, mob/user)
		target.HealDamage("All", 15, 0)

/datum/surgery/heal_burn
	name = "Tend burns"
	desc = "Heal BURN damage with bandages."

	generate_surgery_steps(mob/living/target, mob/user)
		surgery_steps += list(new /datum/surgery_step/bandage(src),
		new /datum/surgery_step/suture(src))

	complete_surgery(mob/living/target, mob/user)
		..()
		target.HealDamage("All", 0, 15)


/datum/surgery/heal_generic
	name = "Tend wounds"
	desc = "Heal BRUTE or BURN damage with surgery."


/datum/surgery/brainsurg
	name = "GOOD SURGERY"
	desc = "HEALS GOOD."
	icon_state = "happy_face"
	generate_surgery_steps(mob/living/target, mob/user)
		surgery_steps += list(new /datum/surgery_step/cut(src),
		new /datum/surgery_step/saw(src),
		new /datum/surgery_step/smack(src),
		new /datum/surgery_step/screw(src),
		new /datum/surgery_step/gun(src),
		new /datum/surgery_step/whack(src),
		new /datum/surgery_step/suture(src))

	complete_surgery(mob/living/target, mob/user)
		target.HealDamage("All", 0, 15)
