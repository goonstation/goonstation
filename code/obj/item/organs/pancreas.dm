/obj/item/organ/pancreas
	name = "pancreas"
	organ_name = "pancreas"
	icon_state = "pancreas"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/pancreatitis

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

		if (!H.organHolder.pancreas && H.organHolder.chest && H.organHolder.chest.op_stage == 6.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "pancreas", 3.0)
			H.update_body()

		else
			..()
		return

	on_life(var/mult = 1)
		if (!..())
			return 0

		if (donor.reagents && donor.reagents.get_reagent_amount("sugar") > 80)	
			if (prob(50))
				donor.reagents.add_reagent("insulin", 1 * mult)
				src.take_damage(0, 0, 10)
			else if (prob(50))
				if (donor.reagents.get_reagent_amount("sugar") > 200)	
					donor.reagents.add_reagent("insulin", 2 * mult)
					src.take_damage(0, 0, 40)

			if (src.get_damage() >= 65 && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1
		
	disposing()
		if (holder)
			if (holder.pancreas == src)
				holder.pancreas = null
		..()

/obj/item/organ/pancreas/cyber
	name = "cyberpancreas"
	desc = "A fancy robotic pancreas to replace one that someone's lost!"
	icon_state = "cyber-pancreas"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6
