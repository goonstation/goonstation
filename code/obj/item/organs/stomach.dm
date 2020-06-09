/obj/item/organ/stomach
	name = "stomach"
	organ_name = "stomach"
	desc = "A little meat sack containing acid for the digestion of food. Like most things that come out of living creatures, you can probably eat it."
	icon_state = "stomach"
	FAIL_DAMAGE = 100

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
		..()
		//Add stomach contents on mob to this object for transplants
		if (iscarbon(src.donor))
			src.contents = src.donor.stomach_process
			src.donor.stomach_process = list()

	on_life(var/mult = 1)
		if (!..())
			return 0
		donor.handle_digestion(mult)

		// if (src.get_damage() >= FAIL_DAMAGE && prob(src.get_damage() * 0.2))
		// 	donor.contract_disease(failure_disease,null,null,1)
		return 1


	disposing()
		if (holder)
			if (holder.stomach == src)
				holder.stomach = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		..()
		if (src.contents && src.contents.len > 0 && istype(W, /obj/item/device/analyzer/healthanalyzer))
			var/output = ""
			var/list/L = list()
			for (var/obj/O in src.contents)
				L[O.name] ++

			for (var/S in L)
				output += "[S] = [L[S]]\n"
			boutput(user, "<br><span style='color:purple'><b>[src]</b> contains:\n [output]</span>")

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

		if (!H.organHolder.stomach && H.organHolder.chest && H.organHolder.chest.op_stage == 4.0)

			var/fluff = pick("insert", "shove", "place", "drop", "smoosh", "squish")

			H.tri_message("<span style=\"color:red\"><b>[user]</b> [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into [H == user ? "[his_or_her(H)]" : "[H]'s"] chest!</span>",\
			user, "<span style=\"color:red\">You [fluff] [src] into [user == H ? "your" : "[H]'s"] chest!</span>",\
			H, "<span style=\"color:red\">[H == user ? "You" : "<b>[user]</b>"] [fluff][fluff == "smoosh" || fluff == "squish" ? "es" : "s"] [src] into your chest!</span>")

			user.u_equip(src)
			H.organHolder.receive_organ(src, "stomach", 3.0)
			H.update_body()

		else
			..()
		return

/obj/item/organ/stomach/cyber
	name = "cyberstomach"
	desc = "A fancy robotic stomach to replace one that someone's lost!"
	icon_state = "cyber-stomach"
	// item_state = "heart_robo1"
	robotic = 1
	edible = 0
	mats = 6

