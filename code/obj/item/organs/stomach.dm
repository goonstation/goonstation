/obj/item/organ/stomach
	name = "stomach"
	organ_name = "stomach"
	desc = "A little meat sack containing acid for the digestion of food. Like most things that come out of living creatures, you can probably eat it."
	organ_holder_name = "stomach"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 4
	icon_state = "stomach"
	fail_damage = 100

	//Do something with this when you figure out what the guy who made digestion and handle stomach was doing with stomach_contents and stomach_process - kyle
	// on_transplant()
	// 	..()
	// 	if (iscarbon(src.donor))
	// 		src.donor.stomach_contents = src.contents
	// 		src.contents = null //Probably don't need to do this, will undo if I ever remove the var off of mob and into stomach completely -kyle
	// on_removal()
	// 	..()
	// 	//Add stomach contents on mob to this object for transplants
	// 	if (iscarbon(src.donor))
	// 		src.contents = src.donor.stomach_contents
	// 		src.donor.stomach_contents = src.donor.stomach_contents.Cut()

//
	on_transplant()
		..()
		if (iscarbon(src.donor))
			src.donor.stomach_process = src.contents
			src.contents = list() //Probably don't need to do this, will undo if I ever remove the var off of mob and into stomach completely -kyle
		// if (src.donor)
			// for (var/datum/ailment_data/disease in src.donor.ailments)
			// 	if (disease.cure == "Stomach Transplant")
			// 		src.donor.cure_disease(disease)
			// return
	on_removal()
		//Add stomach contents on mob to this object for transplants
		if (iscarbon(src.donor))
			src.contents = src.donor.stomach_process
			src.donor.stomach_process = list()
		..()

	on_life(var/mult = 1)
		if (!..())
			return 0
		donor.handle_digestion(mult)

		// if (src.get_damage() >= fail_damage && prob(src.get_damage() * 0.2))
		// 	donor.contract_disease(failure_disease,null,null,1)
		return 1


	disposing()
		if (holder)
			if (holder.stomach == src)
				holder.stomach = null
		..()

	attackby(obj/item/W, mob/user)
		..()
		if (src.contents && src.contents.len > 0 && istype(W, /obj/item/device/analyzer/healthanalyzer))
			var/output = ""
			var/list/L = list()
			for (var/obj/O in src.contents)
				L[O.name] ++

			for (var/S in L)
				output += "[S] = [L[S]]\n"
			boutput(user, "<br><span style='color:purple'><b>[src]</b> contains:\n [output]</span>")

/obj/item/organ/stomach/synth
	name = "synthstomach"
	organ_name = "synthstomach"
	icon_state = "plant"
	desc = "Nearly functionally identical to a pitcher plant... weird."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_stomach", "plant_stomach_bloom")

/obj/item/organ/stomach/cyber
	name = "cyberstomach"
	desc = "A fancy robotic stomach to replace one that someone's lost!"
	icon_state = "cyber-stomach"
	// item_state = "heart_robo1"
	made_from = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	mats = 6

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			ADD_STATUS_LIMIT(M, "Food", 6)

	on_removal()
		REMOVE_STATUS_LIMIT(src.donor, "Food")
		. = ..()

	unbreakme()
		if(..() && donor)
			ADD_STATUS_LIMIT(src.donor, "Food", 6)

	breakme()
		if(..() && donor)
			REMOVE_STATUS_LIMIT(src.donor, "Food")

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/projectilevomit)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)
