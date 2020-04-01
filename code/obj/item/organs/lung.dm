/*=========================*/
/*----------Lungs----------*/
/*=========================*/

/obj/item/organ/lung
	name = "lungs"
	organ_name = "lung"
	desc = "Inflating meat airsacks that pass breathed oxygen into a person's blood and expels carbon dioxide back out. Hopefully whoever used to have these doesn't need them anymore."
	icon_state = "lung_R"
	failure_disease = /datum/ailment/disease/respiratory_failure

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

		if (H.organHolder.chest && H.organHolder.chest.op_stage == 2.0)
			if (user.find_in_hand(src) == user.r_hand && !H.organHolder.right_lung)
				var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

				H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right lung socket!</span>",\
				user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] right lung socket!</span>",\
				H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right lung socket!</span>")

				user.u_equip(src)
				H.organHolder.receive_organ(src, "right_lung", 2.0)
				H.update_body()

			else if (user.find_in_hand(src) == user.l_hand && !H.organHolder.left_lung)
				var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

				H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left lung socket!</span>",\
				user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] left lung socket!</span>",\
				H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left lung socket!</span>")

				user.u_equip(src)
				H.organHolder.receive_organ(src, "left_lung", 2.0)
				H.update_body()

		else
			..()
		return

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (body_side == L_ORGAN)
			if (src.holder.left_lung && src.holder.left_lung.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		else 
			if (src.holder.right_lung && src.holder.right_lung.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1
		
	// on_broken()
	// 	if (body_side == L_ORGAN)
	// 		if (src.holder.left_lung && src.holder.left_lung.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
	// 			donor.contract_disease(failure_disease,null,null,1)
	// 	else 
	// 		if (src.holder.right_lung && src.holder.right_lung.get_damage() > FAIL_DAMAGE && prob(src.get_damage() * 0.2))
	// 			donor.contract_disease(failure_disease,null,null,1)


	disposing()
		if (holder)
			if (holder.left_lung == src)
				holder.left_lung = null
			if (holder.right_lung == src)
				holder.right_lung = null
		..()

/obj/item/organ/lung/left
	name = "left lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_L"
	icon_state = "lung_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/right
	name = "right lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_R"
	icon_state = "lung_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right

/obj/item/organ/lung/cyber
	name = "cyberlungs"
	desc = "Fancy robotic lungs!"
	icon_state = "cyber-lungs_L"
	robotic = 1
	edible = 0
	mats = 6

/obj/item/organ/lung/cyber/left
	name = "left lung"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "cyber_lung_L"
	icon_state = "cyber-lung-L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/cyber/right
	name = "right lung"
	organ_name = "cyber_lung_R"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	icon_state = "cyber-lung-R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right
