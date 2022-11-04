/datum/ailment/disease/plasmatoid
	name = "Plasmatoid"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Mutadone"
	reagentcure = list("mutadone")
	recureprob = 15
	associated_reagent = "liquid plasma"
	affected_species = list("Monkey", "Human")

/datum/ailment/disease/plasmatoid/stage_act(mob/living/affected_mob,  datum/ailment_data/D, mult)
	if (..())
		return
	switch(D.stage)
		if(1)
			if(probmult(2))
				affected_mob.emote("cough")
		if(2)
			if(probmult(1))
				affected_mob.emote("cough")
			else if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel a strange pressure in your chest.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			else if(probmult(3))
				boutput(affected_mob, "<span class='alert'>Your chest hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(1)
		if(3)
			if(probmult(1))
				affected_mob.emote("cough")
			else if(probmult(2))
				boutput(affected_mob, "<span class='alert'>You feel a strange pressure in your chest.</span>")
				if(prob(20))
					random_brute_damage(affected_mob, 1)
			else if(probmult(1))
				boutput(affected_mob, "<span class='alert'>Your chest hurts.</span>")
				if(prob(20))
					affected_mob.take_toxin_damage(1)
			else if(probmult(3))
				boutput(affected_mob, "<span class='alert'>Your breathing feels labored.</span>")
				affected_mob.take_oxygen_deprivation(1)

		if(4)
			var/obj/item/organ/created_organ
			var/obj/item/organ/lung/left = affected_mob?.organHolder?.left_lung
			var/obj/item/organ/lung/right = affected_mob?.organHolder?.right_lung
			var/lung_replaced = FALSE
			if(left && !left.robotic && !istype(left, /obj/item/organ/lung/plasmatoid))
				created_organ = new /obj/item/organ/lung/plasmatoid/left()
				affected_mob.organHolder.drop_organ(left.organ_holder_name)
				qdel(left)

				created_organ.donor = affected_mob
				affected_mob.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)
				lung_replaced = TRUE


			if(right && !right.robotic && !istype(right, /obj/item/organ/lung/plasmatoid))
				created_organ = new /obj/item/organ/lung/plasmatoid/right()
				affected_mob.organHolder.drop_organ(right.organ_holder_name)
				qdel(right)

				created_organ.donor = affected_mob
				affected_mob.organHolder.receive_organ(created_organ, created_organ.organ_holder_name)
				lung_replaced = TRUE

			if(lung_replaced)
				boutput(affected_mob, "<span class='alert'>Your chest suddenly feels very tight as breathing seems different...</span>")
				affected_mob.take_oxygen_deprivation(2)
