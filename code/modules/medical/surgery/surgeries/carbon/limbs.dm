/datum/surgery/limb_surgery
	name = "Limb Surgery"
	desc = "Modify the patients' limbs."
	default_sub_surgeries = list()
	generate_surgery_steps(mob/living/surgeon, mob/user)
		add_next_step(new /datum/surgery_step/cut(src))
		add_next_step(new /datum/surgery_step/snip(src))
