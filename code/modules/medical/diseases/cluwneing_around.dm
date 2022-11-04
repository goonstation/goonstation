/*
<DrMelon>I see no reason not to add an admin-only Cluwne Virus
*/

/datum/ailment/disease/cluwneing_around
	name = "Cluwneing Arewund"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Antibiotics"
	associated_reagent = "painbow fluid"
	affected_species = list("Human")
	var/oldjob
	var/oldname
	var/laugh_rate = 12

	New()
		..()
		name = "[pick("CluwN","ClUrn","CLeWn","CloOon","ClerWn")][pick("eiNg","inge","UneIng","aEng","Oeoing")]"
		name += "[pick("AreoU","UroO","ArU","AoOro","AhRu")][pick("ndE","Ned","nhd")]"
	cluwne
		laugh_rate = 18
		cure = "Incurable"

/datum/ailment/disease/cluwneing_around/on_infection(var/mob/living/affected_mob,var/datum/ailment_data/D)
	..()
	if (D)
		src.oldname = affected_mob.real_name
		src.oldjob = affected_mob.job
	if (istype(affected_mob.wear_mask, /obj/item/clothing/mask/cursedclown_hat))
		D.cure = "Incurable"

/datum/ailment/disease/cluwneing_around/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return

	if(affected_mob.job == "Clown")
		D.state = "Asymptomatic"
		return
	if(isdead(affected_mob))
		return
	if (prob(laugh_rate)) affected_mob.emote("laugh")
	switch(D.stage)
		if(1, 2)

			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Boathorn_1.ogg', 45, 1)
				affected_mob.show_message(text("<span class='alert'>[] makes a VERY strange honking sound!</span>", affected_mob), 1)
			if(probmult(8))
				boutput(affected_mob, "<span class='alert'>You feel your feet crying out!</span>")
			if(probmult(8))
				boutput(affected_mob, "<span class='alert'>Your head throbs with pain.</span>")
			if(probmult(8))
				if(!istype(get_area(affected_mob), /area/sim/gunsim))
					affected_mob.say("HUNKE!")
			if(probmult(8))
				if(!istype(get_area(affected_mob), /area/sim/gunsim))
					affected_mob.say("HUNKE HUNKE!")
			if(probmult(8))
				if(!istype(get_area(affected_mob), /area/sim/gunsim))
					affected_mob.say("THE RINGMASTER DOESN'T RUN THE CIRCUS... HUNKE!")

		if(3)
			if(D.cure != "Incurable")
				D.cure = "Incurable"

			if (affected_mob.job != "Cluwne")
				affected_mob.real_name = "cluwne"
				affected_mob.stuttering = 120 * mult
				affected_mob.job = "Cluwne"
				affected_mob.UpdateName()

			if(probmult(10) && isturf(affected_mob.loc))
				var/turf/T = affected_mob.loc
				if (T && isturf(T))
					var/DS = 0
					for (var/obj/O in T)
						if (O.density)
							DS = 1
							break
						else
							continue
					if (DS == 0 && !T.density && !isrestrictedz(T.z))
						affected_mob.inertia_dir = affected_mob.last_move
						var/turf/T2 = get_step(affected_mob, affected_mob.inertia_dir)
						if (T2 && isturf(T2))
							var/DS2 = 0
							for (var/obj/O2 in T2)
								if (O2.density)
									DS2 = 1
									break
								else
									continue
							if (DS2 == 0 && !T2.density && !isrestrictedz(T2.z))
								affected_mob.set_loc(T2)
								affected_mob.changeStatus("stunned", 2 SECONDS)
								affected_mob.changeStatus("weakened", 2 SECONDS)
								boutput(affected_mob, "<span class='alert'>You feel clumsy and suddenly slip!</span>")

			if(probmult(10))
				playsound(affected_mob.loc, 'sound/musical_instruments/Boathorn_1.ogg', 45, 1)
			if(probmult(10))

				if(!affected_mob:wear_mask || ((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/cursedclown_hat)))
					var/c = affected_mob:wear_mask
					if((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/cursedclown_hat))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/mask/cursedclown_hat/clownmask = new /obj/item/clothing/mask/cursedclown_hat(affected_mob)
					clownmask.cant_self_remove = 1
					clownmask.cant_other_remove = 1
					affected_mob:equip_if_possible( clownmask, affected_mob:slot_wear_mask) //Hope you like your new mask sucka!!!!!
					SPAWN(2.5 SECONDS) // Don't remove.
						if (affected_mob) affected_mob.assign_gimmick_skull() // The mask IS your new face (Convair880).
		if(4)
			if(probmult(10))
				if(!affected_mob:wear_mask || ((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/cursedclown_hat)))
					var/c = affected_mob:wear_mask
					if((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/cursedclown_hat))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/mask/cursedclown_hat/clownmask = new /obj/item/clothing/mask/cursedclown_hat(affected_mob)
					clownmask.cant_self_remove = 1
					clownmask.cant_other_remove = 1
					affected_mob:equip_if_possible( clownmask, affected_mob:slot_wear_mask)
					SPAWN(2.5 SECONDS) // Don't remove.
						if (affected_mob) affected_mob.assign_gimmick_skull() // The mask IS your new face (Convair880).

			if(probmult(10))
				if(!affected_mob:w_uniform || ((affected_mob:w_uniform != null) && !istype(affected_mob:w_uniform, /obj/item/clothing/under/gimmick/cursedclown)))
					var/c = affected_mob:w_uniform

					if((affected_mob:w_uniform != null) && !istype(affected_mob:w_uniform, /obj/item/clothing/under/gimmick/cursedclown))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/under/gimmick/cursedclown/clownsuit = new /obj/item/clothing/under/gimmick/cursedclown(affected_mob)
					affected_mob:equip_if_possible(clownsuit, affected_mob:slot_w_uniform)

			if(probmult(10))
				if(!affected_mob:shoes || ((affected_mob:shoes != null) && !istype(affected_mob:shoes, /obj/item/clothing/shoes/cursedclown_shoes)))
					var/c = affected_mob:shoes
					if((affected_mob:shoes != null) && !istype(affected_mob:shoes, /obj/item/clothing/shoes/cursedclown_shoes))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/shoes/cursedclown_shoes/clownshoes = new /obj/item/clothing/shoes/cursedclown_shoes(affected_mob)
					affected_mob:equip_if_possible( clownshoes, affected_mob:slot_shoes)

			if(probmult(10))
				if(!affected_mob:gloves || ((affected_mob:gloves != null) && !istype(affected_mob:gloves, /obj/item/clothing/gloves/cursedclown_gloves)))
					var/c = affected_mob:gloves
					if((affected_mob:gloves != null) && !istype(affected_mob:gloves, /obj/item/clothing/gloves/cursedclown_gloves))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/gloves/cursedclown_gloves/clowngloves = new /obj/item/clothing/gloves/cursedclown_gloves(affected_mob)
					affected_mob:equip_if_possible( clowngloves, affected_mob:slot_gloves)

			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Boathorn_1.ogg', 45, 1)
				affected_mob.show_message(text("<span class='alert'>[] makes a VERY strange honking sound!</span>", affected_mob), 1)

			if(probmult(4) && isturf(affected_mob.loc))
				var/turf/T = affected_mob.loc
				if (T && isturf(T))
					var/DS = 0
					for (var/obj/O in T)
						if (O.density)
							DS = 1
							break
						else
							continue
					if (DS == 0 && !T.density && !isrestrictedz(T.z))
						affected_mob.inertia_dir = affected_mob.last_move
						var/turf/T2 = get_step(affected_mob, affected_mob.inertia_dir)
						if (T2 && isturf(T2))
							var/DS2 = 0
							for (var/obj/O2 in T2)
								if (O2.density)
									DS2 = 1
									break
								else
									continue
							if (DS2 == 0 && !T2.density && !isrestrictedz(T2.z))
								affected_mob.set_loc(T2)
								affected_mob.changeStatus("stunned", 2 SECONDS)
								affected_mob.changeStatus("weakened", 2 SECONDS)
								boutput(affected_mob, "<span class='alert'>You feel clumsy and suddenly slip!</span>")


/datum/ailment/disease/cluwneing_around/on_remove(var/mob/living/affected_mob,var/datum/ailment_data/D)
	if (affected_mob)
		if (src.oldname)
			affected_mob.real_name = src.oldname
		if (src.oldjob)
			affected_mob.job = src.oldjob
		if(affected_mob.job == "Cluwne" )
			affected_mob.job = "Cleansed Cluwne"
		boutput(affected_mob, "<span class='notice'>You feel like yourself again.</span>")
		affected_mob.UpdateName()
		for(var/obj/item/clothing/W in affected_mob)
			if(findtext("[W.name]","cursed") && W.cant_self_remove && W.cant_other_remove)
				affected_mob.u_equip(W)
				if (W)
					W.set_loc(affected_mob.loc)
					W.dropped(affected_mob)
					W.layer = initial(W.layer)
		affected_mob.change_misstep_chance(-INFINITY)
		affected_mob = null
	..()
