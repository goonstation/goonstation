/obj/item/organ/kidney
	name = "kidneys"
	organ_name = "kidney_t"
	desc = "Bean shaped, but not actually beans. You can still eat them, though!"
	organ_holder_location = "chest"
	organ_holder_name = "kidney"
	either_side = TRUE
	icon = 'icons/obj/items/organs/kidney.dmi'
	icon_state = "kidneys"
	failure_disease = /datum/ailment/disease/kidney_failure
	surgery_flags = SURGERY_SNIPPING | SURGERY_CUTTING
	region = FLANKS
	var/chem_metabolism_modifier = 1
	// this is just used for setting them, so I will use the *100 values
	var/min_chem_metabolism_modifier = 100
	var/max_chem_metabolism_modifier = 100

	on_life(var/mult = 1)
		if (!..())
			return 0
		if (body_side == L_ORGAN)
			if (src.holder.left_kidney && src.holder.left_kidney.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		else
			if (src.holder.right_kidney && src.holder.right_kidney.get_damage() > fail_damage && prob(src.get_damage() * 0.2))
				donor.contract_disease(failure_disease,null,null,1)
		return 1

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			APPLY_ATOM_PROPERTY(M, PROP_MOB_METABOLIC_RATE, src, chem_metabolism_modifier)

	on_removal()
		REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_METABOLIC_RATE, src)
		. = ..()

	unbreakme()
		if(..() && donor)
			APPLY_ATOM_PROPERTY(src.donor, PROP_MOB_METABOLIC_RATE, src, chem_metabolism_modifier)

	breakme()
		if(..() && donor)
			REMOVE_ATOM_PROPERTY(src.donor, PROP_MOB_METABOLIC_RATE, src)

	on_broken(var/mult = 1)
		if (!holder.get_working_kidney_amt() && !donor.hasStatus("dialysis"))
			donor.take_toxin_damage(2*mult, 1)

	disposing()
		if (holder)
			if (holder.left_kidney == src)
				holder.left_kidney = null
			if (holder.right_kidney == src)
				holder.right_kidney = null
		..()

	/// sets the chem_metabolism_modifier for this kidney, clamping it to the min and max value and dividing it by 100
	proc/set_chem_metabolism_modifier(var/new_modifier)
		src.chem_metabolism_modifier = clamp(new_modifier, src.min_chem_metabolism_modifier, src.max_chem_metabolism_modifier)/100

	/// randomizes the kidneys chem_metabolism_modifier to a value between its min and max
	proc/randomize_modifier()
		src.set_chem_metabolism_modifier(rand(src.min_chem_metabolism_modifier, src.max_chem_metabolism_modifier))

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

/obj/item/organ/kidney/synth
	name = "synthkidney"
	organ_name = "synthkidney"
	icon_state = "plant"
	desc = "A bean based kidney!"
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_appendix", "plant_appendix_bloom")

TYPEINFO(/obj/item/organ/kidney/cyber)
	mats = 6

/obj/item/organ/kidney/cyber
	name = "cyberkidney"
	desc = "A fancy robotic kidney to replace one that someone's lost!"
	icon_state = "cyber-kidney-L"
	// item_state = "heart_robo1"
	organ_name = "cyber_kidney"
	default_material = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	min_chem_metabolism_modifier = 75
	max_chem_metabolism_modifier = 150

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
			var/new_modifier = input(user, \
			"Enter a percentage to clock the cyberkidney at, from [src.min_chem_metabolism_modifier] to [src.max_chem_metabolism_modifier].",\
			 "Organ clocking", src.chem_metabolism_modifier*100) as num
			src.set_chem_metabolism_modifier(new_modifier)
		else
			. = ..()

/obj/item/organ/kidney/synth/left
	name = "left kidney"
	desc = "A bean based kidney! It's the left kidney!"
	synthetic = 1
	icon_state = "plant"
	organ_name = "synthkidney_L"
	organ_holder_name = "left_kidney"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left
	New()
		..()
		src.icon_state = pick("plant_kidney_L", "plant_kidney_L_bloom")

/obj/item/organ/kidney/synth/right
	name = "right kidney"
	desc = "A bean based kidney! It's the right kidney!"
	synthetic = 1
	icon_state = "plant"
	organ_name = "synthkidney_R"
	organ_holder_name = "right_kidney"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right
	New()
		..()
		src.icon_state = pick("plant_kidney_R", "plant_kidney_R_bloom")

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

/obj/item/organ/kidney/amphibian
	name = "amphibian kidney"
	desc = "Oh, look, it's got... nodules..."
	icon_state = "amphibian_kidney_L"
	organ_name = "amphibian_kidney"

/obj/item/organ/kidney/amphibian/left
	name = "left kidney"
	desc = "Oh, look, it's got... nodules... It's the left kidney."
	organ_name = "amphibian_kidney_L"
	organ_holder_name = "left_kidney"
	icon_state = "amphibian_kidney_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left

/obj/item/organ/kidney/amphibian/right
	name = "right kidney"
	desc = "Oh, look, it's got... nodules... It's the right kidney."
	organ_name = "amphibian_kidney_R"
	organ_holder_name = "right_kidney"
	icon_state = "amphibian_kidney_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right

/obj/item/organ/kidney/skeleton
	name = "right kidney"
	desc = "Christ, this thing has teeth attached."
	organ_name = "skele_kidney"
	icon_state = "skele_kidney_L"
	default_material = "bone"
	blood_reagent = "calcium"

/obj/item/organ/kidney/skeleton/right
	name = "right kidney"
	desc = "Christ, this thing has teeth attached. It's the right kidney."
	organ_name = "skele_kidney_R"
	organ_holder_name = "right_kidney"
	icon_state = "skele_kidney_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right
	default_material = "bone"
	blood_reagent = "calcium"

/obj/item/organ/kidney/skeleton/left
	name = "left kidney"
	desc = "Christ, this thing has teeth attached. It's the left kidney."
	organ_name = "skele_kidney_L"
	organ_holder_name = "left_kidney"
	icon_state = "skele_kidney_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left
	default_material = "bone"
	blood_reagent = "calcium"

/obj/item/organ/kidney/martian
	name = "right soft chunk"
	desc = "Some sort of waste filtration... analogue."
	organ_name = "martian_kidney_R"
	organ_holder_name = "right_kidney"
	icon_state = "martian_kidney"
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"

/obj/item/organ/kidney/martian/right
	name = "right soft chunk"
	desc = "Some sort of waste filtration... analogue. It's the right 'kidney'."
	organ_name = "martian_kidney"
	icon_state = "martian_kidney_R"
	body_side = R_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/right
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"

/obj/item/organ/kidney/martian/left
	name = "left soft chunk"
	desc = "Some sort of waste filtration... analogue. It's the left 'kidney'."
	organ_name = "martian_kidney_L"
	organ_holder_name = "right_kidney"
	icon_state = "martian_kidney_L"
	body_side = L_ORGAN
	failure_disease = /datum/ailment/disease/kidney_failure/left
	created_decal = /obj/decal/cleanable/martian_viscera/fluid
	default_material = "viscerite"
