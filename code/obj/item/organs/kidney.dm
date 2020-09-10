/obj/item/organ/kidney
	name = "kidneys"
	organ_name = "kidney_t"
	desc = "Bean shaped, but not actually beans. You can still eat them, though!"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 7.0
	icon_state = "kidneys"
	failure_disease = /datum/ailment/disease/kidney_failure
	var/chem_metabolism_modifier = 1

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

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			APPLY_MOB_PROPERTY(M, PROP_METABOLIC_RATE, src, chem_metabolism_modifier)

	on_removal()
		. = ..()
		REMOVE_MOB_PROPERTY(src.donor, PROP_METABOLIC_RATE, src)

	unbreakme()
		..()
		if(donor)
			APPLY_MOB_PROPERTY(src.donor, PROP_METABOLIC_RATE, src, chem_metabolism_modifier)

	breakme()
		..()
		if(donor)
			REMOVE_MOB_PROPERTY(src.donor, PROP_METABOLIC_RATE, src)

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

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for attaching kidneys. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		if (H.organHolder.chest && H.organHolder.chest.op_stage == 7.0)
			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")
			var/target_organ_location = null

			if (user.find_in_hand(src, "right"))
				target_organ_location = "right"
			else if (user.find_in_hand(src, "left"))
				target_organ_location = "left"
			else if (!user.find_in_hand(src))
				// Organ is not in the attackers hand. This was likely a drag and drop. If you're just tossing an organ at a body, where it lands will be imprecise
				target_organ_location = pick("right", "left")

			if (target_organ_location == "right" && !H.organHolder.right_kidney)
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right kidney socket!</span>",\
				user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] right kidney socket!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right kidney socket!</span>")

				if (user.find_in_hand(src))
					user.u_equip(src)
				H.organHolder.receive_organ(src, "right_kidney", 2.0)
				H.update_body()
			else if (target_organ_location == "left" && !H.organHolder.left_kidney)
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left kidney socket!</span>",\
				user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] left kidney socket!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left kidney socket!</span>")

				if (user.find_in_hand(src))
					user.u_equip(src)
				H.organHolder.receive_organ(src, "left_kidney", 2.0)
				H.update_body()
			else
				H.tri_message("<span class='alert'><b>[user]</b> tries to [fluff] the [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right kidney socket!<br>But there's something already there!</span>",\
				user, "<span class='alert'>You try to [fluff] the [src] into [user == H ? "your" : "[H]'s"] right kidney socket!<br>But there's something already there!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [H == user ? "try" : "tries"] to [fluff] the [src] into your right kidney socket!<br>But there's something already there!</span>")
				return 0

			return 1
		else
			return 0

/obj/item/organ/kidney/left
	name = "left kidney"
	organ_name = "kidney_L"
	organ_holder_name = "left_kidney"
	icon_state = "kidney_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left

/obj/item/organ/kidney/right
	name = "right kidney"
	organ_name = "kidney_R"
	organ_holder_name = "right_kidney"
	icon_state = "kidney_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right

/obj/item/organ/kidney/cyber
	name = "cyberkidney"
	desc = "A fancy robotic kidney to replace one that someone's lost!"
	icon_state = "cyber-kidney-L"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	edible = 0
	mats = 6

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/kidneypurge)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)


	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/kidneypurge) || !aholder)
			return ..()
		var/datum/targetable/organAbility/kidneypurge/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has an emagged kidney. having 2 makes it safer (damage is split between kidneys) and a little stronger
			OA.linked_organ = list(OA.linked_organ, src)
			OA.power = 9
		else
			OA = aholder.addAbility(abil)
			OA.power = 6
			if (istype(OA))
				OA.linked_organ = src

	remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/kidneypurge) || !aholder)
			return ..()
		var/datum/targetable/organAbility/kidneypurge/OA = aholder.getAbility(abil)
		if (!OA) // what??
			return
		OA.cancel_purge()
		if (islist(OA.linked_organ)) // two emagged kidneys, just remove us :3
			var/list/lorgans = OA.linked_organ
			lorgans -= src // remove us from the list so only the other kidney is left and thus will be lorgans[1]
			OA.linked_organ = lorgans[1]
			OA.power = 6
		else // just us!
			aholder.removeAbility(abil)

	attackby(obj/item/W, mob/user)
		if(ispulsingtool(W)) //TODO kyle's robotics configuration console/machine/thing
			chem_metabolism_modifier = input(user, "Enter a percentage to clock the cyberkidney at, from 75 to 150.", "Organ clocking", "100") as num
			chem_metabolism_modifier = clamp(chem_metabolism_modifier, 75, 150) / 100
		else
			. = ..()

/obj/item/organ/kidney/cyber/left
	name = "left kidney"
	desc = "A fancy robotic kidney to replace one that someone's lost! It's the left kidney!"
	organ_name = "cyber_kidney_L"
	organ_holder_name = "left_kidney"
	icon_state = "cyber-kidney-L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left

/obj/item/organ/kidney/cyber/right
	name = "right kidney"
	desc = "A fancy robotic kidney to replace one that someone's lost! It's the right kidney!"
	organ_name = "cyber_kidney_R"
	organ_holder_name = "right_kidney"
	icon_state = "cyber-kidney-R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right
