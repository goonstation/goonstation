/obj/item/organ/appendix
	name = "appendix"
	organ_name = "appendix"
	icon_state = "appendix"
	failure_disease = /datum/ailment/disease/appendicitis

	attack(var/mob/living/carbon/M as mob, var/mob/user as mob)
		if (!ismob(M))
			return

		src.add_fingerprint(user)

		if (user.zone_sel.selecting != "chest")
			return ..()
		if (!surgeryCheck(M, user))
			return ..()

		var/mob/living/carbon/human/H = M
		if (!H.organHolder)
			return ..()

		if (!H.organHolder.appendix && H.organHolder.chest && H.organHolder.chest.op_stage == 3.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "appendix", 3.0)
			H.update_body()

		else
			..()
		return

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
			donor.contract_disease(failure_disease,null,null,1)
		return 1

/obj/item/organ/appendix/cyber
	name = "cyberappendix"
	desc = "A fancy robotic appendix to replace one that someone's lost!"
	icon_state = "cyber-appendix"
	// item_state = "cyber-"
	robotic = 1
	edible = 0
	mats = 6

	//A bad version of the robutsec... For now.
	on_life()
		if (src.health < FAIL_DAMAGE && prob(10))
			donor.reagents.add_reagent(pick("saline", "salbutamol", "salicylic_acid", "charcoal"), 4)
