#define L_ORGAN 1
#define R_ORGAN 2

/datum/organHolder // you ever play fallout 3?  you know those like sacks of gibs that were around?  yeah
	var/mob/living/donor = null

	var/obj/item/organ/head/head = null
	var/obj/item/skull/skull = null
	var/obj/item/organ/brain/brain = null
	var/obj/item/organ/eye/left_eye = null
	var/obj/item/organ/eye/right_eye = null
	var/obj/item/organ/chest/chest = null
	var/obj/item/organ/heart/heart = null
	var/obj/item/organ/lung/left_lung = null
	var/obj/item/organ/lung/right_lung = null
	var/obj/item/clothing/head/butt/butt = null
	var/obj/item/organ/kidney/left_kidney = null
	var/obj/item/organ/kidney/right_kidney = null
	var/obj/item/organ/liver = null
	var/obj/item/organ/spleen = null
	var/obj/item/organ/pancreas = null
	var/obj/item/organ/stomach = null
	var/obj/item/organ/intestines = null
	var/obj/item/organ/appendix = null
	var/obj/item/organ/tail = null
	var/lungs_changed = 2				//for changing lung stamina debuffs if it has changed since last cycle. starts at 2 for having 2 working lungs

	var/list/organ_list = list("all", "head", "skull", "brain", "left_eye", "right_eye", "chest", "heart", "left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")

	var/list/organ_type_list = list(
		"head"="/obj/item/organ/head",
		"skull"="/obj/item/skull",
		"brain"="/obj/item/organ/brain",
		"left_eye"="/obj/item/organ/eye",
		"right_eye"="/obj/item/organ/eye",
		"chest"="/obj/item/organ/chest",
		"heart"="/obj/item/organ/heart",
		"left_lung"="/obj/item/organ/lung/left",
		"right_lung"="/obj/item/organ/lung/right",
		"left_kidney"="/obj/item/organ/kidney/left",
		"right_kidney"="/obj/item/organ/kidney/right",
		"liver"="/obj/item/organ/liver",
		"spleen"="/obj/item/organ/spleen",
		"pancreas"="/obj/item/organ/pancreas",
		"stomach"="/obj/item/organ/stomach",
		"intestines"="/obj/item/organ/intestines",
		"appendix"="/obj/item/organ/appendix",
		"butt"="/obj/item/clothing/head/butt",
		"tail"="/obj/item/organ/tail")

	New(var/mob/living/L, var/ling)
		..()
		if (!ishuman(L))
			return
		if (istype(L))
			src.donor = L
		if (src.donor && !ling) // so changers just get the datum and not a metric fuckton of organs
			src.create_organs()

	disposing()
		src.organ_list.len = 0
		src.organ_list = null

		if (head)
			head.donor = null
			chest?.bones?.donor = null
			head.holder = null
		if (skull)
			skull.donor = null
			skull.holder = null
		if (brain)
			brain.donor = null
			brain.holder = null
		if (left_eye)
			left_eye.donor = null
			left_eye.holder = null
		if (right_eye)
			right_eye.donor = null
			right_eye.holder = null
		if (chest)
			chest.donor = null
			chest?.bones?.donor = null
			chest.holder = null
		if (heart)
			heart.donor = null
			heart.holder = null
		if (left_lung)
			left_lung.donor = null
			left_lung.holder = null
		if (right_lung)
			right_lung.donor = null
			right_lung.holder = null
		if (butt)
			butt.donor = null
			butt.holder = null
		if (left_kidney)
			left_kidney.donor = null
			left_kidney.holder = null
		if (right_kidney)
			right_kidney.donor = null
			right_kidney.holder = null
		if (liver)
			liver.donor = null
			liver.holder = null
		if (stomach)
			stomach.donor = null
			stomach.holder = null
		if (intestines)
			intestines.donor = null
			intestines.holder = null
		if (spleen)
			spleen.donor = null
			spleen.holder = null
		if (pancreas)
			pancreas.donor = null
			pancreas.holder = null
		if (appendix)
			appendix.donor = null
			appendix.holder = null
		if (tail)
			tail.donor = null
			tail.holder = null

		head = null
		skull = null
		brain = null
		left_eye = null
		right_eye = null
		chest = null
		heart = null
		left_lung = null
		right_lung = null
		butt = null
		left_kidney = null
		right_kidney = null
		liver = null
		stomach = null
		intestines = null
		spleen = null
		pancreas = null
		appendix = null
		tail = null

		donor = null
		..()

	proc/handle_organs(var/mult = 1)
		for(var/thing in src.organ_list)
			if(thing == "all")
				continue
			var/obj/item/organ/O = organ_list[thing]
			//Organ needs to be inside someone for it to function.
			if(istype(O) && O.donor)
				//in obj/item/organ/proc/on_life, It should return 1 on success and 0 on fail. And it will fail if the organ is damaged beyond repair or is broken. So...
				if (!O.on_life(mult))
					O.on_broken(mult)
			else	//The organ for this slot is missing. For our purposes here at least. Do bad effects, depending.
				handle_missing(thing, mult)

		handle_lungs_stamina(mult)

	//What should happen on every tick when an organ is missing. Should be called above in /datum/organHolder/proc/handle_organs().
	proc/handle_missing(var/organ_name as text, var/mult = 1)
		switch (organ_name)
			if ("liver")
				donor.take_toxin_damage(2*mult, 1)
			if ("spleen")
				if (ishuman(donor))
					var/mob/living/carbon/human/H = donor
					H.blood_volume -= 2 * mult
			if ("left_kidney")					//I'm lazy... Not making this better right now -kyle
				if (!get_working_kidney_amt())
					donor.take_toxin_damage(2, 1)
			if ("right_kidney")
				if (!get_working_kidney_amt())
					donor.take_toxin_damage(2, 1)
			if ("tail")
				if(ischangeling(donor) || src.donor?.reagents?.get_reagent_amount("ethanol") > 50) // drunkenness prevents tail-clumsiness
					return
				if (donor.mob_flags & SHOULD_HAVE_A_TAIL) // Only become clumsy if you should have a tail and are not a shapeshifting alien
					donor.bioHolder?.AddEffect("clumsy", 0, 0, 0, 1)
			//Missing lungs is handled in it's own proc right now. I'll probably move it here eventually, but that's how I did it originally before I thought of a thing for handling missing organs in the organholder and I'm not rewriting such a tedious thing now.



	//loops through organ_list.  returns a list of names of all missing organs instead, but I'm tired
	proc/get_missing_organs()
		RETURN_TYPE(/list)
		var/list/organs = list()
		// if (islist(organ_list))
		for (var/i in organ_list)
			if (!organ_list[i])
				organs += i
		return organs
	//(damage|heal)_organs used for effecting a lot of organs at once just by supplying a list and a damage amount.

	//probability, num 0-100 for whether or not to damage an organ found
	//organs, list of organs to damage. give it individual organs like "left_lung", not "lungs"
	proc/damage_organs(var/brute, var/burn, var/tox, var/list/organs, var/probability = 100)
		if(check_target_immunity(donor))
			return 0

		for (var/organ in organs)
			if (probability == 100 || prob(probability))
				damage_organ(brute, burn, tox, organ)

	proc/heal_organs(var/brute, var/burn, var/tox, var/list/organs, var/probability = 100)
		for (var/organ in organs)
			if (probability == 100 || prob(probability))
				heal_organ(brute, burn, tox, organ)


	//calls take_damage on the specified Organ attached to this organHolder
	proc/damage_organ(var/brute, var/burn, var/tox, var/organ as text)
		if(check_target_immunity(donor))
			return 0

		if (islist(src.organ_list))
			var/obj/item/organ/O = src.organ_list[organ]
			if (istype(O))
				O.take_damage(brute, burn, tox)
				return 1
		return 0

	//calls heal_damage on the specified Organ attached to this organHolder
	proc/heal_organ(var/brute, var/burn, var/tox, var/organ as text)
		if (islist(src.organ_list))
			var/obj/item/organ/O = src.organ_list[organ]
			if (istype(O))
				O.heal_damage(brute, burn, tox)
				return 1
		return 0


	//organs should not perform their functions if they have 100 damage
	proc/get_working_kidney_amt()
		var/count = 0
		if (left_kidney && (!left_kidney.broken && left_kidney.get_damage() <= left_kidney.FAIL_DAMAGE))
			count++
		if (right_kidney && (!right_kidney.broken && right_kidney.get_damage() <= right_kidney.FAIL_DAMAGE))
			count++
		return count

	proc/get_working_lung_amt()
		var/count = 0
		if (left_lung && (!left_lung.broken && left_lung.get_damage() <= left_lung.FAIL_DAMAGE))
			count++
		if (right_lung && (!right_lung.broken && right_lung.get_damage() <= right_lung.FAIL_DAMAGE))
			count++
		return count

	proc/create_organs()
		if (!src.donor)
			return // vOv

		if (!src.head)
			src.head = new /obj/item/organ/head(src.donor, src)
			organ_list["head"] = head

		if (!src.skull)
			src.skull = new /obj/item/skull(src.donor, src)
			organ_list["skull"] = skull

			// For variety and hunters (Convair880).
			SPAWN_DBG(2.5 SECONDS) // Don't remove.
				if (src.donor && src.donor.organHolder && src.donor.organHolder.skull)
					src.donor.assign_gimmick_skull()

		var/all_synth = (prob(1) && prob(1))

		if (!src.brain)
			if (prob(2) || all_synth)
				src.brain = new /obj/item/organ/brain/synth(src.donor, src)
			else
				src.brain = new /obj/item/organ/brain(src.donor, src)
			src.brain.setOwner(src.donor.mind)
			organ_list["brain"] = brain
			SPAWN_DBG(2 SECONDS)
				if (src.brain && src.donor)
					src.brain.name = "[src.donor.real_name]'s [initial(src.brain.name)]"
					if (src.donor.mind)
						src.brain.setOwner(src.donor.mind)

		if (!src.left_eye)
			if (prob(2) || all_synth)
				src.left_eye = new /obj/item/organ/eye/synth(src.donor, src)
			else
				src.left_eye = new /obj/item/organ/eye/left(src.donor, src)
			organ_list["left_eye"] = left_eye
		if (!src.right_eye)
			if (prob(2) || all_synth)
				src.right_eye = new /obj/item/organ/eye/synth(src.donor, src)
			else
				src.right_eye = new /obj/item/organ/eye/right(src.donor, src)
			organ_list["right_eye"] = right_eye

		if (!src.chest)
			src.chest = new /obj/item/organ/chest(src.donor, src)
			organ_list["chest"] = chest

		if (!src.heart)
			if (prob(2) || all_synth)
				src.heart = new /obj/item/organ/heart/synth(src.donor, src)
			else
				src.heart = new /obj/item/organ/heart(src.donor, src)
			organ_list["heart"] = heart

		if (!src.left_lung)
			src.left_lung = new /obj/item/organ/lung/left(src.donor, src)
			organ_list["left_lung"] = left_lung
		if (!src.right_lung)
			src.right_lung = new /obj/item/organ/lung/right(src.donor, src)
			organ_list["right_lung"] = right_lung

		if (!src.butt)
			src.butt = new /obj/item/clothing/head/butt(src.donor, src)
			organ_list["butt"] = butt
			src.donor.butt_op_stage = 0.0
			src.donor.update_body()

		if (!src.left_kidney)
			src.left_kidney = new /obj/item/organ/kidney/left(src.donor, src)
			organ_list["left_kidney"] = left_kidney
		if (!src.right_kidney)
			src.right_kidney = new /obj/item/organ/kidney/right(src.donor, src)
			organ_list["right_kidney"] = right_kidney
		if (!src.liver)
			src.liver = new /obj/item/organ/liver(src.donor, src)
			organ_list["liver"] = liver
		if (!src.stomach)
			src.stomach = new /obj/item/organ/stomach(src.donor, src)
			organ_list["stomach"] = stomach
		if (!src.intestines)
			src.intestines = new /obj/item/organ/intestines(src.donor, src)
			organ_list["intestines"] = intestines
		if (!src.spleen)
			src.spleen = new /obj/item/organ/spleen(src.donor, src)
			organ_list["spleen"] = spleen
		if (!src.pancreas)
			src.pancreas = new /obj/item/organ/pancreas(src.donor, src)
			organ_list["pancreas"] = pancreas
		if (!src.appendix)
			src.appendix = new /obj/item/organ/appendix(src.donor, src)
			organ_list["appendix"] = appendix
		if (!src.tail)
			src.tail = null	// Humans dont have tailbones, fun fact
			organ_list["tail"] = tail

	//input organ = string value of organ_list assoc list
	proc/get_organ(var/organ)
		RETURN_TYPE(/obj/item)
		if (!organ)
			return 0
		var/obj/item/return_organ = organ_list[organ]
		if (istype(return_organ))
			return return_organ
		return 0

	proc/drop_organ(var/organ, var/location)
		if (!src.donor || !organ)
			return

		if (!location)
			location = src.donor.loc

		if(!istext(organ) && istype(organ, /obj/item))
			// the organ is passed as a reference instead of a text description
			if(organ == head)
				organ = "head"
			else if(organ == skull)
				organ = "skull"
			else if(organ == brain)
				organ = "brain"
			else if(organ == left_eye)
				organ = "left_eye"
			else if(organ == right_eye)
				organ = "right_eye"
			else if(organ == chest)
				organ = "chest"
			else if(organ == heart)
				organ = "heart"
			else if(organ == left_lung)
				organ = "left_lung"
			else if(organ == right_lung)
				organ = "right_lung"
			else if(organ == butt)
				organ = "butt"
			else if(organ == left_kidney)
				organ = "left_kidney"
			else if(organ == right_kidney)
				organ = "right_kidney"
			else if(organ == liver)
				organ = "liver"
			else if(organ == stomach)
				organ = "stomach"
			else if(organ == intestines)
				organ = "intestines"
			else if(organ == spleen)
				organ = "spleen"
			else if(organ == pancreas)
				organ = "pancreas"
			else if(organ == appendix)
				organ = "appendix"
			else if(organ == tail)
				organ = "tail"
			else
				return 0 // what the fuck are you trying to remove

		switch (lowertext(organ))

			if ("all")
				if (islist(src.organ_list))
					for (var/thing in src.organ_list)
						if (!src.organ_list[thing])
							continue
						src.drop_organ(thing, location)
					return 1
				/*src.drop_organ("brain", location)
				src.drop_organ("head", location)
				src.drop_organ("skull", location)
				src.drop_organ("right_eye", location)
				src.drop_organ("left_eye", location)
				src.drop_organ("chest", location)
				src.drop_organ("heart", location)
				src.drop_organ("right_lung", location)
				src.drop_organ("left_lung", location)
				src.drop_organ("butt", location)
				return 1*/

			if ("head")
				if (!src.head)
					return 0
				var/obj/item/organ/head/myHead = src.head
				if (src.brain)
					myHead.brain = src.drop_organ("brain", myHead)
				if (src.skull)
					myHead.skull = src.drop_organ("skull", myHead)
				if (src.right_eye)
					myHead.right_eye = src.drop_organ("right_eye", myHead)
				if (src.left_eye)
					myHead.left_eye = src.drop_organ("left_eye", myHead)
				if (ishuman(src.donor))
					var/mob/living/carbon/human/H = src.donor
					if (H.glasses)
						var/obj/item/W = H.glasses
						H.u_equip(W)
						W.set_loc(myHead)
						myHead.glasses = W
					if (H.head)
						var/obj/item/W = H.head
						H.u_equip(W)
						W.set_loc(myHead)
						myHead.head = W // blehhhh
					if (H.ears)
						var/obj/item/W = H.ears
						H.u_equip(W)
						W.set_loc(myHead)
						myHead.ears = W
					if (H.wear_mask)
						var/obj/item/W = H.wear_mask
						H.u_equip(W)
						W.set_loc(myHead)
						myHead.wear_mask = W
				myHead.set_loc(location)
				myHead.update_head_image()
				myHead.on_removal()
				myHead.holder = null
				src.head = null
				src.organ_list["head"] = null
				src.donor.update_body()
				src.donor.UpdateDamageIcon()
				src.donor.update_clothing()
				return myHead

			if ("skull")
				if (!src.skull)
					return 0
				var/obj/item/skull/mySkull = src.skull
				mySkull.set_loc(location)
				mySkull.holder = null
				src.skull = null
				src.organ_list["skull"] = null
				src.head.skull = null
				return mySkull

			if ("brain")
				if (!src.brain)
					return 0
				var/obj/item/organ/brain/myBrain = src.brain
				if (!myBrain.owner) //Oh no, they have no mind!
					if (src.donor.ghost)
						if (src.donor.ghost.mind)
							logTheThing("debug", null, null, "<b>Mind</b> drop_organ forced to retrieve mind for key \[[src.donor.key]] from ghost.")
							myBrain.setOwner(src.donor.ghost.mind)
						else if (src.donor.ghost.key)
							logTheThing("debug", null, null, "<b>Mind</b> drop_organ forced to create new mind for key \[[src.donor.key]] from ghost.")
							var/datum/mind/newmind = new
							newmind.ckey = src.donor.ghost.ckey
							newmind.key = src.donor.ghost.key
							newmind.current = src.donor.ghost
							src.donor.ghost.mind = newmind
							myBrain.setOwner(newmind)
					else if (src.donor.key)
						logTheThing("debug", null, null, "<b>Mind</b> drop_organ forced to create new mind for key \[[src.donor.key]]")
						var/datum/mind/newmind = new
						newmind.ckey = src.donor.ckey
						newmind.key = src.donor.key
						newmind.current = src.donor
						src.donor.mind = newmind
						myBrain.setOwner(newmind)
				myBrain.set_loc(location)
				myBrain.on_removal()
				myBrain.holder = null
				src.brain = null
				src.organ_list["brain"] = null
				src.head?.brain = null
				return myBrain

			if ("left_eye")
				if (!src.left_eye)
					return 0
				var/obj/item/organ/eye/myLeftEye = src.left_eye
				myLeftEye.set_loc(location)
				myLeftEye.on_removal()
				myLeftEye.holder = null
				src.left_eye = null
				src.organ_list["left_eye"] = null
				src.head.left_eye = null
				return myLeftEye

			if ("right_eye")
				if (!src.right_eye)
					return 0
				var/obj/item/organ/eye/myRightEye = src.right_eye
				myRightEye.set_loc(location)
				myRightEye.on_removal()
				myRightEye.holder = null
				src.right_eye = null
				src.organ_list["right_eye"] = null
				src.head.right_eye = null
				return myRightEye

			if ("chest")
				if (!src.chest)
					return 0
				var/obj/item/organ/chest/myChest = src.chest
				myChest.set_loc(location)
				myChest.on_removal()
				myChest.holder = null
				src.chest = null
				src.organ_list["chest"] = null
				return myChest

			if ("heart")
				if (!src.heart)
					return 0
				var/obj/item/organ/heart/myHeart = src.heart
				//Commented this out for some reason I forget. I'm sure I'll remember what it is one day. -kyle
				// if (src.heart.robotic)
				// 	src.donor.remove_stam_mod_regen("heart")
				// 	src.donor.remove_stam_mod_max("heart")
				myHeart.set_loc(location)
				myHeart.on_removal()
				myHeart.holder = null
				src.heart = null
				src.donor.update_body()
				src.organ_list["heart"] = null
				return myHeart

			if ("left_lung")
				if (!src.left_lung)
					return 0
				var/obj/item/organ/lung/left/myLeftLung = src.left_lung
				myLeftLung.set_loc(location)
				myLeftLung.on_removal()
				myLeftLung.holder = null
				src.left_lung = null
				src.organ_list["left_lung"] = null
				src.donor.update_body()
				handle_lungs_stamina()
				return myLeftLung

			if ("right_lung")
				if (!src.right_lung)
					return 0
				var/obj/item/organ/lung/right/myRightLung = src.right_lung
				myRightLung.set_loc(location)
				myRightLung.on_removal()
				myRightLung.holder = null
				src.right_lung = null
				src.organ_list["right_lung"] = null
				src.donor.update_body()
				handle_lungs_stamina()
				return myRightLung

			if ("butt")
				if (!src.butt)
					return 0
				var/obj/item/clothing/head/butt/myButt = src.butt
				myButt.set_loc(location)
				myButt.holder = null
				src.butt = null
				src.donor.butt_op_stage = 4.0
				src.donor.update_body()
				src.organ_list["butt"] = null
				return myButt

			if ("left_kidney")
				if (!src.left_kidney)
					return 0
				var/obj/item/organ/kidney/left/myleft_kidney = src.left_kidney
				myleft_kidney.set_loc(location)
				myleft_kidney.on_removal()
				myleft_kidney.holder = null
				src.left_kidney = null
				src.donor.update_body()
				src.organ_list["left_kidney"] = null
				return myleft_kidney

			if ("right_kidney")
				if (!src.right_kidney)
					return 0
				var/obj/item/organ/kidney/right/myright_kidney = src.right_kidney
				myright_kidney.set_loc(location)
				myright_kidney.on_removal()
				myright_kidney.holder = null
				src.right_kidney = null
				src.donor.update_body()
				src.organ_list["right_kidney"] = null
				return myright_kidney

			if ("liver")
				if (!src.liver)
					return 0
				var/obj/item/organ/liver/myliver = src.liver
				myliver.set_loc(location)
				myliver.on_removal()
				myliver.holder = null
				src.liver = null
				src.donor.update_body()
				src.organ_list["liver"] = null
				return myliver

			if ("stomach")
				if (!src.stomach)
					return 0
				var/obj/item/organ/stomach/mystomach = src.stomach
				mystomach.set_loc(location)
				mystomach.on_removal()
				mystomach.holder = null
				src.stomach = null
				src.donor.update_body()
				src.organ_list["stomach"] = null
				return mystomach

			if ("intestines")
				if (!src.intestines)
					return 0
				var/obj/item/organ/intestines/myintestines = src.intestines
				myintestines.set_loc(location)
				myintestines.on_removal()
				myintestines.holder = null
				src.intestines = null
				src.donor.update_body()
				src.organ_list["intestines"] = null
				return myintestines

			if ("spleen")
				if (!src.spleen)
					return 0
				var/obj/item/organ/spleen/myspleen = src.spleen
				myspleen.set_loc(location)
				myspleen.on_removal()
				myspleen.holder = null
				src.spleen = null
				src.donor.update_body()
				src.organ_list["spleen"] = null
				return myspleen

			if ("pancreas")
				if (!src.pancreas)
					return 0
				var/obj/item/organ/pancreas/mypancreas = src.pancreas
				mypancreas.set_loc(location)
				mypancreas.on_removal()
				mypancreas.holder = null
				src.pancreas = null
				src.donor.update_body()
				src.organ_list["pancreas"] = null
				return mypancreas

			if ("appendix")
				if (!src.appendix)
					return 0
				var/obj/item/organ/appendix/myappendix = src.appendix
				myappendix.set_loc(location)
				myappendix.on_removal()
				myappendix.holder = null
				src.appendix = null
				src.donor.update_body()
				src.organ_list["appendix"] = null
				return myappendix

			if ("tail")
				if (!src.tail)
					return 0
				var/obj/item/organ/tail/mytail = src.tail
				mytail.set_loc(location)
				mytail.on_removal()
				mytail.holder = null
				src.tail = null
				src.donor.update_body()
				src.organ_list["tail"] = null
				return mytail

	proc/receive_organ(var/obj/item/I, var/organ, var/op_stage = 0.0, var/force = 0)
		if (!src.donor || !I || !organ)
			return 0

		var/success = 0

		switch (lowertext(organ))

			if ("head")
				if (src.head)
					if (force)
						qdel(src.head)
					else
						return 0
				var/obj/item/organ/head/newHead = I
				if (src.donor.client)
					src.donor.client.mob = new /mob/dead/observer(src)
				if (newHead.brain && newHead.brain.owner)
					newHead.brain.owner.transfer_to(src.donor)
				newHead.op_stage = op_stage
				src.head = newHead
				newHead.set_loc(src.donor)
				newHead.holder = src
				if (newHead.skull)
					if (src.skull) // how
						src.drop_organ("skull") // I mean really, how
					src.receive_organ(newHead.skull, "skull", newHead.skull.op_stage)
				if (newHead.brain)
					if (src.brain) // ???
						src.drop_organ("brain") // god idfk
					src.receive_organ(newHead.brain, "brain", newHead.brain.op_stage)
				if (newHead.right_eye)
					if (src.right_eye)
						src.drop_organ("right_eye")
					src.receive_organ(newHead.right_eye, "right_eye", newHead.right_eye.op_stage)
				if (newHead.left_eye)
					if (src.left_eye)
						src.drop_organ("left_eye")
					src.receive_organ(newHead.left_eye, "left_eye", newHead.left_eye.op_stage)
				if (ishuman(src.donor))
					var/mob/living/carbon/human/H = src.donor
					if (newHead.glasses)
						if (H.glasses)
							H.glasses.set_loc(get_turf(H))
							H.u_equip(H.glasses)
						H.glasses = newHead.glasses
						newHead.glasses.set_loc(H)
						newHead.glasses = null
					if (newHead.head)
						if (H.head)
							H.head.set_loc(get_turf(H))
							H.u_equip(H.head)
						H.head = newHead.head
						newHead.head.set_loc(H)
						newHead.head = null
					if (newHead.ears)
						if (H.ears)
							H.ears.set_loc(get_turf(H))
							H.u_equip(H.ears)
						H.ears = newHead.ears
						newHead.ears.set_loc(H)
						newHead.ears = null
					if (newHead.wear_mask)
						if (H.wear_mask)
							H.wear_mask.set_loc(get_turf(H))
							H.u_equip(H.wear_mask)
						H.wear_mask = newHead.wear_mask
						newHead.wear_mask.set_loc(H)
						newHead.wear_mask = null

				src.donor.update_body()
				src.donor.UpdateDamageIcon()
				src.donor.update_clothing()
				organ_list["head"] = newHead
				success = 1

			if ("skull")
				if (src.skull)
					if (force)
						qdel(src.skull)
					else
						return 0
				if (!src.head)
					return 0
				var/obj/item/skull/newSkull = I
				newSkull.op_stage = op_stage
				src.skull = newSkull
				src.head.skull = newSkull
				newSkull.set_loc(src.donor)
				newSkull.holder = src
				organ_list["skull"] = newSkull
				success = 1

			if ("brain")
				if (src.brain)
					if (force)
						qdel(src.brain)
					else
						return 0
				if (!src.skull)
					return 0
				var/obj/item/organ/brain/newBrain = I
				if (src.donor.client)
					src.donor.client.mob = new /mob/dead/observer(src)
				if (newBrain.owner)
					newBrain.owner.transfer_to(src.donor)
				newBrain.op_stage = op_stage
				src.brain = newBrain
				src.head.brain = newBrain
				newBrain.set_loc(src.donor)
				newBrain.holder = src
				organ_list["brain"] = newBrain
				success = 1

			if ("left_eye")
				if (src.left_eye)
					if (force)
						qdel(src.left_eye)
					else
						return 0
				if (!src.head)
					return 0
				var/obj/item/organ/eye/newLeftEye = I
				newLeftEye.op_stage = op_stage
				src.left_eye = newLeftEye
				src.head.left_eye = newLeftEye
				newLeftEye.body_side = L_ORGAN
				newLeftEye.set_loc(src.donor)
				newLeftEye.holder = src
				organ_list["left_eye"] = newLeftEye
				success = 1

			if ("right_eye")
				if (src.right_eye)
					if (force)
						qdel(src.right_eye)
					else
						return 0
				if (!src.head)
					return 0
				var/obj/item/organ/eye/newRightEye = I
				newRightEye.op_stage = op_stage
				src.right_eye = newRightEye
				src.head.right_eye = newRightEye
				newRightEye.body_side = R_ORGAN
				newRightEye.set_loc(src.donor)
				newRightEye.holder = src
				organ_list["right_eye"] = newRightEye
				success = 1

			if ("chest") // should never be this but vOv
				if (src.chest)
					if (force)
						qdel(src.chest)
					else
						return 0
				var/obj/item/organ/chest/newChest = I
				newChest.op_stage = op_stage
				src.chest = newChest
				newChest.set_loc(src.donor)
				newChest.holder = src
				organ_list["chest"] = newChest
				success = 1

			if ("heart")
				if (src.heart)
					if (force)
						qdel(src.heart)
					else
						return 0
				var/obj/item/organ/heart/newHeart = I
				if (newHeart.robotic)
					if (src.donor.bioHolder.HasEffect("elecres"))
						newHeart.breakme()
					if (newHeart.broken || src.donor.bioHolder.HasEffect("elecres"))
						src.donor.show_text("Something is wrong with [newHeart], it fails to start beating!", "red")
						src.donor.contract_disease(/datum/ailment/malady/flatline,null,null,1)
					//Like above, I commented this out for a reason I cannot remember. might just be because I changed how that stamina modifier works, I dunno.
					// if (newHeart.emagged)
					// 	src.donor.add_stam_mod_regen("heart", 20)
					// 	src.donor.add_stam_mod_max("heart", 100)
					// else
					// 	src.donor.add_stam_mod_regen("heart", 10)
					// 	src.donor.add_stam_mod_max("heart", 50)
				newHeart.op_stage = op_stage
				src.heart = newHeart
				newHeart.set_loc(src.donor)
				newHeart.holder = src
				organ_list["heart"] = newHeart
				success = 1

			if ("left_lung")
				if (src.left_lung)
					if (force)
						qdel(src.left_lung)
					else
						return 0
				var/obj/item/organ/lung/newLeftLung = I
				newLeftLung.op_stage = op_stage
				src.left_lung = newLeftLung
				newLeftLung.body_side = L_ORGAN
				newLeftLung.set_loc(src.donor)
				newLeftLung.holder = src
				organ_list["left_lung"] = newLeftLung
				handle_lungs_stamina()
				success = 1

			if ("right_lung")
				if (src.right_lung)
					if (force)
						qdel(src.right_lung)
					else
						return 0
				var/obj/item/organ/lung/newRightLung = I
				newRightLung.op_stage = op_stage
				src.right_lung = newRightLung
				newRightLung.body_side = R_ORGAN
				newRightLung.set_loc(src.donor)
				newRightLung.holder = src
				organ_list["right_lung"] = newRightLung
				handle_lungs_stamina()
				success = 1

			if ("butt")
				if (src.butt)
					if (force)
						qdel(src.butt)
					else
						return 0
				var/obj/item/clothing/head/butt/newButt = I
				newButt.op_stage = op_stage
				src.butt = newButt
				newButt.set_loc(src.donor)
				newButt.holder = src
				organ_list["butt"] = newButt
				success = 1

			if ("left_kidney")
				if (src.left_kidney)
					if (force)
						qdel(src.left_kidney)
					else
						return 0
				var/obj/item/organ/kidney/left/newleft_kidney = I
				newleft_kidney.op_stage = op_stage
				src.left_kidney = newleft_kidney
				newleft_kidney.set_loc(src.donor)
				newleft_kidney.holder = src
				organ_list["left_kidney"] = newleft_kidney
				success = 1

			if ("right_kidney")
				if (src.right_kidney)
					if (force)
						qdel(src.right_kidney)
					else
						return 0
				var/obj/item/organ/kidney/right/newright_kidney = I
				newright_kidney.op_stage = op_stage
				src.right_kidney = newright_kidney
				newright_kidney.set_loc(src.donor)
				newright_kidney.holder = src
				organ_list["right_kidney"] = newright_kidney
				success = 1

			if ("liver")
				if (src.liver)
					if (force)
						qdel(src.liver)
					else
						return 0
				var/obj/item/organ/liver/newliver = I
				newliver.op_stage = op_stage
				src.liver = newliver
				newliver.set_loc(src.donor)
				newliver.holder = src
				organ_list["liver"] = newliver
				success = 1

			if ("stomach")
				if (src.stomach)
					if (force)
						qdel(src.stomach)
					else
						return 0
				var/obj/item/organ/stomach/newstomach = I
				newstomach.op_stage = op_stage
				src.stomach = newstomach
				newstomach.set_loc(src.donor)
				newstomach.holder = src
				organ_list["stomach"] = newstomach
				success = 1

			if ("intestines")
				if (src.intestines)
					if (force)
						qdel(src.intestines)
					else
						return 0
				var/obj/item/organ/intestines/newintestines = I
				newintestines.op_stage = op_stage
				src.intestines = newintestines
				newintestines.set_loc(src.donor)
				newintestines.holder = src
				organ_list["intestines"] = newintestines
				success = 1

			if ("spleen")
				if (src.spleen)
					if (force)
						qdel(src.spleen)
					else
						return 0
				var/obj/item/organ/spleen/newspleen = I
				newspleen.op_stage = op_stage
				src.spleen = newspleen
				newspleen.set_loc(src.donor)
				newspleen.holder = src
				organ_list["spleen"] = newspleen
				success = 1

			if ("pancreas")
				if (src.pancreas)
					if (force)
						qdel(src.pancreas)
					else
						return 0
				var/obj/item/organ/pancreas/newpancreas = I
				newpancreas.op_stage = op_stage
				src.pancreas = newpancreas
				newpancreas.set_loc(src.donor)
				newpancreas.holder = src
				organ_list["pancreas"] = newpancreas
				success = 1

			if ("appendix")
				if (src.appendix)
					if (force)
						qdel(src.appendix)
					else
						return 0
				var/obj/item/organ/appendix/newappendix = I
				newappendix.op_stage = op_stage
				src.appendix = newappendix
				newappendix.set_loc(src.donor)
				newappendix.holder = src
				organ_list["appendix"] = newappendix
				success = 1

			if ("tail")
				if (src.tail)
					if (force)
						qdel(src.tail)
					else
						return 0
				var/obj/item/organ/tail/newtail = I
				newtail.op_stage = op_stage
				src.tail = newtail
				newtail.set_loc(src.donor)
				newtail.holder = src
				organ_list["tail"] = newtail
				src.donor.update_body()
				success = 1

		if (success)
			if (istype(I, /obj/item/organ))
				var/obj/item/organ/O = I
				O.on_transplant(src.donor)
			if (is_full_robotic())
				donor.unlock_medal("Spaceship of Theseus", 1)
			return 1

	//checks if this organholder has all cyberorgans instead of meat ones.
	proc/is_full_robotic()
		if (islist(organ_list))
			for (var/i in organ_list)
				//ignore these things which can't be robotic for a regular human atm. And butts cause they aren't real organs, plus removing butts is a crime.
				if (i =="all" || i == "head" || i == "skull" || i == "brain" || i == "chest" || i == "butt")
					continue
				var/obj/item/organ/O = organ_list[i]
				//if it's not robotic we're done, return 0
				if (istype(O) && !O.robotic)
					return 0

			//moved out of for loop and just continue past "butt". I think this is slightly more efficient.
			var/obj/item/clothing/head/butt/cyberbutt/B = organ_list["butt"]
			//if it's not robotic we're done, return 0
			if (istype(B))
				return 1
			return 0
		return 0

	//OK you're probably thinking why this in needed at all. It seemed the simplest way, to add and remove stamina based on the amount of lungs.
	//Because I have it so that an organ can stop working when it hits 100+ damage, we need to check if we have to make stamina changes often.

	//change stamina modifies based on amount of working lungs. lungs w/ health > 0
	//lungs_changed works like this: if lungs_changed is != the num of working lungs, then apply the stamina modifier
	proc/handle_lungs_stamina(var/mult = 1)
		var/working_lungs = src.get_working_lung_amt()
		switch (working_lungs)
			if (0)
				if (working_lungs != lungs_changed)
					donor.remove_stam_mod_regen("single_lung_removal")
					donor.remove_stam_mod_max("single_lung_removal")
					donor.add_stam_mod_regen("double_lung_removal", -6)
					donor.add_stam_mod_max("double_lung_removal", -150)
					lungs_changed = 0

				donor.take_oxygen_deprivation(5 * mult)
				donor.losebreath+=rand(1,5) * mult
			if (1)
				if (working_lungs != lungs_changed)
					donor.remove_stam_mod_regen("double_lung_removal")
					donor.remove_stam_mod_max("double_lung_removal")
					donor.add_stam_mod_regen("single_lung_removal", -3)
					donor.add_stam_mod_max("single_lung_removal", -75)
					lungs_changed = 1

				if (prob(20))
					donor.take_oxygen_deprivation(1 * mult)
					donor.losebreath+=(1 * mult)
			if (2)
				if (working_lungs != lungs_changed)
					donor.remove_stam_mod_regen("single_lung_removal")
					donor.remove_stam_mod_max("single_lung_removal")
					donor.remove_stam_mod_regen("double_lung_removal")
					donor.remove_stam_mod_max("double_lung_removal")
					lungs_changed = 2

/*=================================*/
/*---------- Human Procs ----------*/
/*=================================*/

/mob/living/carbon/human/proc/eye_istype(var/obj/item/I)
	if (!src.organHolder || !I)
		return 0
	if (!src.organHolder.left_eye && !src.organHolder.right_eye)
		return 0
	if (istype(src.organHolder.left_eye, I) || istype(src.organHolder.right_eye, I))
		return 1
	else
		return 0

/mob/living/carbon/human/proc/organ_istype(var/organ, var/organ_type)
	if (!src.organHolder || !organ || !organ_type)
		return 0
	var/obj/item/I = get_organ(organ)
	if (istype(I, organ_type))
		return 1
	return 0

/mob/living/carbon/human/proc/get_organ(var/organ)
	RETURN_TYPE(/obj/item)
	if (!src.organHolder || !organ)
		return 0
	return src.organHolder.get_organ(organ)

/mob/living/carbon/human/proc/drop_organ(var/organ, var/location)
	if (!src.organHolder || !organ)
		return 0
	return src.organHolder.drop_organ(organ, location)

/mob/living/carbon/human/proc/receive_organ(var/obj/item/I, var/organ, var/op_stage = 0.0, var/force = 0)
	if (!src.organHolder || !I || !organ)
		return 0
	return src.organHolder.receive_organ(I, organ, op_stage, force)



/*=================================*/
/*---------- Critter Stuff --------*/
/*=================================*/

/datum/organHolder/critter //for the animals. same stuff as human, but with a brain as the only organ

	New(var/mob/living/L, var/obj/item/organ/brain/custom_brain_type)
		..()
		if (!ismobcritter(L))
			return
		if (istype(L))
			src.donor = L
		if (src.donor)
			src.create_organs(custom_brain_type)

	create_organs(var/obj/item/organ/brain/custom_brain_type) //Same create_organs proc as the parent, but with all the organs removed except brain
		if (!src.donor)
			return // vOv

		var/all_synth = (prob(1) && prob(1))

		if (!src.brain)
			if(custom_brain_type)
				src.brain = new custom_brain_type(src.donor, src)
			else
				if (prob(2) || all_synth)
					src.brain = new /obj/item/organ/brain/synth(src.donor, src)
				else
					src.brain = new /obj/item/organ/brain(src.donor, src)
			src.brain.setOwner(src.donor.mind)
			organ_list["brain"] = brain
			SPAWN_DBG(2 SECONDS)
				if (src.brain && src.donor)
					//src.brain.name = "[src.donor.real_name]'s [initial(src.brain.name)]"
					if (src.donor.mind)
						src.brain.setOwner(src.donor.mind)


/mob/living/critter/small_animal/proc/eye_istype(var/obj/item/I)
	return 0

/mob/living/critter/small_animal/proc/organ_istype(var/organ, var/organ_type)
	if (!src.organHolder || !organ || !organ_type)
		return 0
	var/obj/item/I = get_organ(organ)
	if (istype(I, organ_type))
		return 1
	return 0

/mob/living/critter/small_animal/proc/get_organ(var/organ)
	if (!src.organHolder || !organ)
		return 0
	return src.organHolder.get_organ(organ)

/mob/living/critter/small_animal/proc/drop_organ(var/organ, var/location)
	if (!src.organHolder || !organ)
		return 0
	return src.organHolder.drop_organ(organ, location)

/mob/living/critter/small_animal/proc/receive_organ(var/obj/item/I, var/organ, var/op_stage = 0.0, var/force = 0)
	if (!src.organHolder || !I || !organ)
		return 0
	return src.organHolder.receive_organ(I, organ, op_stage, force)


// HI IT'S ME CIRR AGAIN COMMANDEERING CODE
/datum/organHolder/critter/flock

	create_organs(var/obj/item/organ/brain/custom_brain_type)
		..() // call parent
		// add extra organs
		if(!src.heart)
			src.heart = new /obj/item/organ/heart/flock(src.donor, src)
			organ_list["heart"] = heart
			SPAWN_DBG(2 SECONDS) // god damn i wish i didn't need to have these spawns here, it's gross, i'm sorry, i'm really sorry
				if (src.heart && src.donor)
					src.heart.name = initial(src.heart.name)

/*===============================*/
/*---------- Abilities ----------*/
/*===============================*/
// mostly cobbled together from critter and bioeffect ability holders
/datum/abilityHolder/organ
	usesPoints = 0
	regenRate = 0
	tabName = "Body"

/obj/screen/ability/topBar/organ
	clicked(params)
		var/datum/targetable/organAbility/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(usr.loc))
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr:targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN_DBG(0)
				spell.handleCast()

/datum/targetable/organAbility
	icon = 'icons/mob/organ_abilities.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	preferred_holder_type = /datum/abilityHolder/organ
	var/disabled = 0
	var/toggled = 0
	var/is_on = 0   // used if a toggle ability
	var/obj/item/organ/linked_organ = null

	New()
		var/obj/screen/ability/topBar/organ/B = new /obj/screen/ability/topBar/organ(null)
		B.name = src.name
		B.desc = src.desc
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		src.object = B

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/organ()
			object.icon = src.icon
			object.owner = src
		if (disabled)
			object.name = "[src.name] (unavailable)"
			object.icon_state = src.icon_state + "_cd"
		else if (src.last_cast > world.time)
			object.name = "[src.name] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else if (toggled)
			if (is_on)
				object.name = "[src.name] (on)"
				object.icon_state = src.icon_state
			else
				object.name = "[src.name] (off)"
				object.icon_state = src.icon_state + "_cd"
		else
			object.name = src.name
			object.icon_state = src.icon_state

	proc/incapacitationCheck()
		var/mob/living/M = holder.owner
		return M.restrained() || is_incapacitated(M)

	castcheck()
		if (!linked_organ || (!islist(src.linked_organ) && linked_organ.loc != holder.owner))
			boutput(holder.owner, "<span class='alert'>You can't use that ability right now.</span>")
			return 0
		else if (incapacitationCheck())
			boutput(holder.owner, "<span class='alert'>You can't use that ability while you're incapacitated.</span>")
			return 0
		else if (disabled)
			boutput(holder.owner, "<span class='alert'>You can't use that ability right now.</span>")
			return 0
		return 1

	cast(atom/target)
		if (!holder || !holder.owner)
			return 1
		if (!linked_organ)
			return 1
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		if (ismob(target))
			logTheThing("combat", holder.owner, target, "used ability [src.name] ([src.linked_organ]) on [constructTarget(target,"combat")].")
		else if (target)
			logTheThing("combat", holder.owner, null, "used ability [src.name] ([src.linked_organ]) on [target].")
		else
			logTheThing("combat", holder.owner, null, "used ability [src.name] ([src.linked_organ]).")
		return 0

/datum/targetable/organAbility/eyebeam
	name = "Eyebeam"
	desc = "Shoot a laser from your eye."
	icon_state = "eye-laser"
	targeted = 1
	target_anything = 1
	cooldown = 40
	var/datum/projectile/eye_proj = /datum/projectile/laser/eyebeams

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(holder.owner)) // remember to take off your headgear if you want to fire the laser
			var/mob/living/carbon/human/H = holder.owner
			var/obj/item/I
			if (istype(H.glasses) && H.glasses.c_flags & COVERSEYES)
				I = H.glasses
			else if (istype(H.wear_mask) && H.wear_mask.c_flags & COVERSEYES)
				I = H.wear_mask
			else if (istype(H.head) && H.head.c_flags & COVERSEYES)
				I = H.head
			else if (istype(H.wear_suit) && H.wear_suit.c_flags & COVERSEYES)
				I = H.wear_suit
			if (istype(I)) // or it might go
				I.combust() // POOF
				holder.owner.visible_message("<span class='combat'><b>[holder.owner]'s [I.name] catches on fire!</b></span>",\
				"<span class='combat'><b>Your [I.name] catches on fire!</b> Maybe you should have taken it off first!</span>")
				return

		if (!ispath(eye_proj))
			return 1

		var/turf/T = get_turf(target)

		var/mult = src.eye_proj == /datum/projectile/laser/eyebeams ? 1 : 0
		holder.owner.visible_message("<span class='combat'><b>[holder.owner]</b> shoots [mult ? "eye beams" : "an eye beam"]!</span>")
		var/datum/projectile/PJ = new eye_proj
		shoot_projectile_ST(holder.owner, PJ, T)

/datum/projectile/laser/eyebeams/left
	icon_state = "eyebeamL"
	power = 10
	cost = 10

/datum/projectile/laser/eyebeams/right
	icon_state = "eyebeamR"
	power = 10
	cost = 10

/datum/targetable/organAbility/meson
	name = "Meson Toggle"
	desc = "Toggle the Meson Vision functionality of your eye."
	icon_state = "eye-meson"
	targeted = 0
	toggled = 1
	cooldown = 5
	is_on = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/item/organ/eye/cyber/meson/M = linked_organ
		if (istype(M))
			M.toggle()
			src.is_on = M.on
		if(is_on)
			src.icon_state = initial(src.icon_state)
		else
			src.icon_state = "[initial(src.icon_state)]_cd"


/datum/targetable/organAbility/kidneypurge
	name = "Kidney Purge"
	desc = "Dangerously overclock your cyberkidneys to rapidly purge chemicals from your blood."
	icon_state = "cyberkidney"
	targeted = 0
	cooldown = 40 SECONDS
	var/power = 6

	cast(atom/target)
		if (..())
			return 1

		if(length(linked_organ))
			for(var/obj/item/organ/O in linked_organ)
				O.take_damage(15, 15) //safe-ish
		else
			linked_organ.take_damage(30, 30) //not safe
		boutput(holder.owner, "<span class='notice'>You overclock your cyberkidney[islist(linked_organ) ? "s" : ""] to rapidly purge chemicals from your body.</span>")
		APPLY_MOB_PROPERTY(holder.owner, PROP_CHEM_PURGE, src, power)
		holder.owner.urine += power // -.-
		SPAWN_DBG(15 SECONDS)
			if(holder?.owner)
				REMOVE_MOB_PROPERTY(holder.owner, PROP_CHEM_PURGE, src)

	proc/cancel_purge()
		if(holder?.owner)
			REMOVE_MOB_PROPERTY(holder.owner, PROP_CHEM_PURGE, src)

/datum/targetable/organAbility/liverdetox
	name = "\"Detox\" Toggle"
	desc = "Activate the experimental \"detoxification\" function of your liver to metabolize ethanol into omnizine."
	icon_state = "cyberliver"
	targeted = 0
	toggled = 1
	cooldown = 5
	is_on = 0

	New()
		..()
		src.icon_state = "[initial(src.icon_state)]_cd"

	cast(atom/target)
		if (..())
			return 1

		var/obj/item/organ/liver/cyber/L = linked_organ
		if (istype(L))
			L.overloading = !L.overloading
			src.is_on = L.overloading
			boutput(holder.owner, "<span class='notice'>You [is_on ? "" : "de"]activate the \"detox\" mode on your cyberliver.</span>")
		if(is_on)
			src.icon_state = initial(src.icon_state)
		else
			src.icon_state = "[initial(src.icon_state)]_cd"

/datum/targetable/organAbility/quickdigest
	name = "Rapid Digestion"
	desc = "Force your cyberintestines to rapidly process the contents of your stomach. This can't be healthy."
	icon_state = "cyberintestine"
	targeted = 0
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		linked_organ.take_damage(20, 20) //not safe
		if(istype(holder.owner, /mob/living))
			var/mob/living/L = holder.owner
			if (L.stomach_process && L.stomach_process.len)
				boutput(L, "<span class='notice'>You force your cyberintestines to rapidly process the contents of your stomach.</span>")
				for(var/obj/item/reagent_containers/food/snacks/bite/B in L.stomach_process)
					B.process_stomach(L, (B.reagents.total_volume)) //all of the food!
			else
				boutput(L, "<span class='alert'>Your intestines crunch painfully in your gut. Maybe they would work better with some food to process.</span>")
				linked_organ.take_damage(30) //owwww


/datum/targetable/organAbility/projectilevomit
	name = "Projectile Vomiting"
	desc = "Upchuck your stomach contents with deadly force."
	icon_state = "cyberstomach"
	targeted = 1
	target_anything = 1
	cooldown = 10

	cast(atom/target)
		if (..())
			return 1

		if(istype(holder.owner, /mob/living))
			var/mob/living/L = holder.owner
			if (L.stomach_process && L.stomach_process.len)
				L.visible_message("<span class='alert'>[L] convulses and vomits right at [target]!</span>", "<span class='alert'>You upchuck some of your cyberstomach contents at [target]!</span>")
				SPAWN_DBG(0)
					for (var/i in 1 to 3)
						var/obj/item/O = L.vomit()
						O.throw_at(target, 8, 3, bonus_throwforce=5)
						linked_organ.take_damage(3)
						sleep(0.1 SECONDS)
						if(linked_organ.broken || !L.stomach_process.len)
							break
			else
				boutput(L, "<span class='alert'>You try to vomit, but your cyberstomach has nothing left inside!</span>")
				linked_organ.take_damage(30) //owwww
				L.vomit()

/datum/targetable/organAbility/rebreather
	name = "Rebreather Toggle"
	desc = "Dangerously overload your cyberlungs to completely pause your breathing. Any oxygen deprivation already suffered will not be cleared, however."
	icon_state = "cyberlung"
	targeted = 0
	toggled = 1
	cooldown = 5
	is_on = 0

	New()
		..()
		src.icon_state = "[initial(src.icon_state)]_cd"

	cast(atom/target)
		if (..())
			return 1
		if(!islist(linked_organ) && !is_on)
			boutput(holder.owner, "<span class='notice'>This ability is only usable with two unregulated cyberlungs!</span>")
			return 1

		src.is_on = !src.is_on
		boutput(holder.owner, "<span class='notice'>You [is_on ? "" : "de"]activate the rebreather mode on your cyberlungs.</span>")
		for(var/obj/item/organ/lung/cyber/L in linked_organ)
			L.overloading = is_on
		if(is_on)
			APPLY_MOB_PROPERTY(holder.owner, PROP_REBREATHING, "cyberlungs")
		else
			REMOVE_MOB_PROPERTY(holder.owner, PROP_REBREATHING, "cyberlungs")

		if(is_on)
			src.icon_state = initial(src.icon_state)
		else
			src.icon_state = "[initial(src.icon_state)]_cd"
