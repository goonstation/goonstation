/obj/item/organ/kidney
	name = "kidneys"
	organ_name = "kidney_t"
	desc = "Bean shaped, but not actually beans. You can still eat them, though!"
	icon_state = "kidneys"
	failure_disease = /datum/ailment/disease/kidney_failure

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

		if (H.organHolder.chest && H.organHolder.chest.op_stage == 7.0)
			if (user.find_in_hand(src) == user.r_hand && !H.organHolder.right_kidney)
				var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

				H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right kidney socket!</span>",\
				user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] right kidney socket!</span>",\
				H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right kidney socket!</span>")

				user.u_equip(src)
				H.organHolder.receive_organ(src, "right_kidney", 2.0)
				H.update_body()

			else if (user.find_in_hand(src) == user.l_hand && !H.organHolder.left_kidney)
				var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

				H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left kidney socket!</span>",\
				user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] left kidney socket!</span>",\
				H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left kidney socket!</span>")

				user.u_equip(src)
				H.organHolder.receive_organ(src, "left_kidney", 2.0)
				H.update_body()

		else
			..()
		return

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (body_side == L_ORGAN)
			if (src.holder.left_kidney && src.holder.left_kidney.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		else 
			if (src.holder.right_kidney && src.holder.right_kidney.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1
		
	on_broken(var/mult = 1)
		if (!holder.get_working_kidney_amt())
			donor.take_toxin_damage(2*mult, 1)

	disposing()
		if (holder)
			if (holder.left_kidney == src)
				holder.left_kidney = null
			if (holder.right_kidney == src)
				holder.right_kidney = null
		..()

/obj/item/organ/kidney/left
	name = "left kidney"
	organ_name = "kidney_L"
	icon_state = "kidney_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left

/obj/item/organ/kidney/right
	name = "right kidney"
	organ_name = "kidney_R"
	icon_state = "kidney_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right

/obj/item/organ/kidney/cyber
	name = "cyberkidney"
	desc = "A fancy robotic kidney to replace one that someone's lost!"
	icon_state = "cyber-kidney-L"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6

/obj/item/organ/kidney/cyber/left
	name = "left kidney"
	desc = "A fancy robotic kidney to replace one that someone's lost! It's the left kidney!"
	organ_name = "cyber_kidney_L"
	icon_state = "cyber-kidney-L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left

/obj/item/organ/kidney/cyber/right
	name = "right kidney"
	desc = "A fancy robotic kidney to replace one that someone's lost! It's the right kidney!"
	organ_name = "cyber_kidney_R"
	icon_state = "cyber-kidney-R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right

