/*=========================*/
/*----------Lungs----------*/
/*=========================*/

/obj/item/organ/lung
	name = "lungs"
	organ_name = "lung"
	desc = "Inflating meat airsacks that pass breathed oxygen into a person's blood and expels carbon dioxide back out. Hopefully whoever used to have these doesn't need them anymore."
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 2.0
	icon_state = "lung_R"
	failure_disease = /datum/ailment/disease/respiratory_failure
	var/temp_tolerance = T0C+66

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

	on_transplant(var/mob/M as mob)
		..()
		if (src.robotic)
			APPLY_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, icon_state, 2)
			src.donor.add_stam_mod_max(icon_state, 10)
		return

	on_removal()
		..()
		if (donor)
			if (src.robotic)
				REMOVE_MOB_PROPERTY(src.donor, PROP_STAMINA_REGEN_BONUS, icon_state)
				src.donor.remove_stam_mod_max(icon_state)
		return

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

	attach_organ(var/mob/living/carbon/M as mob, var/mob/user as mob)
		/* Overrides parent function to handle special case for attaching lungs. */
		var/mob/living/carbon/human/H = M
		if (!src.can_attach_organ(H, user))
			return 0

		if (H.organHolder.chest && H.organHolder.chest.op_stage == 2.0)
			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")
			var/target_organ_location = null

			if (user.find_in_hand(src, "right"))
				target_organ_location = "right"
			else if (user.find_in_hand(src, "left"))
				target_organ_location = "left"
			else if (!user.find_in_hand(src))
				// Organ is not in the attackers hand. This was likely a drag and drop. If you're just tossing an organ at a body, where it lands will be imprecise
				target_organ_location = pick("right", "left")

			if (target_organ_location == "right" && !H.organHolder.right_lung)
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right lung socket!</span>",\
				user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] right lung socket!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your right lung socket!</span>")

				if (user.find_in_hand(src))
					user.u_equip(src)
				H.organHolder.receive_organ(src, "right_lung", 2.0)
				H.update_body()
			else if (target_organ_location == "left" && !H.organHolder.left_lung)
				H.tri_message("<span class='alert'><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] left lung socket!</span>",\
				user, "<span class='alert'>You [fluff] [src] into [user == H ? "your" : "[H]'s"] left lung socket!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your left lung socket!</span>")

				if (user.find_in_hand(src))
					user.u_equip(src)
				H.organHolder.receive_organ(src, "left_lung", 2.0)
				H.update_body()
			else
				H.tri_message("<span class='alert'><b>[user]</b> tries to [fluff] the [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] right lung socket!<br>But there's something already there!</span>",\
				user, "<span class='alert'>You try to [fluff] the [src] into [user == H ? "your" : "[H]'s"] right lung socket!<br>But there's something already there!</span>",\
				H, "<span class='alert'>[H == user ? "You" : "<b>[user]</b>"] [H == user ? "try" : "tries"] to [fluff] the [src] into your right lung socket!<br>But there's something already there!</span>")
				return 0

			return 1
		return 0

/obj/item/organ/lung/left
	name = "left lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_L"
	organ_holder_name = "left_lung"
	icon_state = "lung_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/right
	name = "right lung"
	desc = "Inflating meat airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "lung_R"
	organ_holder_name = "right_lung"
	icon_state = "lung_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right

/obj/item/organ/lung/cyber
	name = "cyberlungs"
	desc = "Fancy robotic lungs!"
	icon_state = "cyber-lungs_L"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6
	temp_tolerance = T0C+500
	var/overloading = 0

/obj/item/organ/lung/synth
	name = "synthlungs"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream."
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure
	var/overloading = 0
	New()
		..()
		src.icon_state = pick("plant_lung_t", "plant_lung_t_bloom")

	add_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/rebreather) || !aholder)
			return ..()
		var/datum/targetable/organAbility/rebreather/OA = aholder.getAbility(abil)//addAbility(abil)
		if (istype(OA)) // already has an emagged lung. You need both for the ability to function
			OA.linked_organ = list(OA.linked_organ, src)
		else
			OA = aholder.addAbility(abil)
			if (istype(OA))
				OA.linked_organ = src

	remove_ability(var/datum/abilityHolder/aholder, var/abil)
		if (!ispath(abil, /datum/targetable/organAbility/rebreather) || !aholder)
			return ..()
		var/datum/targetable/organAbility/rebreather/OA = aholder.getAbility(abil)
		if (!OA) // what??
			return
		if (islist(OA.linked_organ)) // two emagged lungs, just remove us :3
			var/list/lorgans = OA.linked_organ
			if(OA.is_on)
				OA.handleCast() //turn it off - we only have one left!
			lorgans -= src // remove us from the list so only the other lung is left and thus will be lorgans[1]
			OA.linked_organ = lorgans[1]
		else // just us!
			aholder.removeAbility(abil)

	on_life(var/mult = 1)
		if(!..())
			return 0

		if(overloading)
			src.take_damage(0, 1 * mult)
		return 1

	disposing()
		if(donor)
			REMOVE_MOB_PROPERTY(donor, PROP_REBREATHING, "cyberlungs")
		..()

	emag_act(mob/user, obj/item/card/emag/E)
		..()
		organ_abilities = list(/datum/targetable/organAbility/rebreather)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)

/obj/item/organ/lung/synth/left
	name = "left lung"
	organ_name = "synthlung_L"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure
	New()
		..()
		src.icon_state = pick("plant_lung_L", "plant_lung_L_bloom")

/obj/item/organ/lung/synth/right
	name = "right lung"
	organ_name = "synthlung_R"
	icon_state = "plant"
	desc = "Surprisingly, doesn't produce its own oxygen. Luckily, it works just as well at moving oxygen to the bloodstream. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	synthetic = 1
	failure_disease = /datum/ailment/disease/respiratory_failure
	New()
		..()
		src.icon_state = pick("plant_lung_R", "plant_lung_R_bloom")

/obj/item/organ/lung/cyber/left
	name = "left lung"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a left lung, since it has three lobes. Hopefully whoever used to have this one doesn't need it anymore."
	organ_name = "cyber_lung_L"
	organ_holder_name = "left_lung"
	icon_state = "cyber-lung-L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/left

/obj/item/organ/lung/cyber/right
	name = "right lung"
	organ_name = "cyber_lung_R"
	desc = "Inflating robotic airsack that passes breathed oxygen into a person's blood and expels carbon dioxide back out. This is a right lung, since it has two lobes and a cardiac notch, where the heart would be. Hopefully whoever used to have this one doesn't need it anymore."
	organ_holder_name = "right_lung"
	icon_state = "cyber-lung-R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/respiratory_failure/right
