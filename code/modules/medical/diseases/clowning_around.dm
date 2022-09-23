/*
[23:20] <@Showtime> 6:15 PM - Something angry!: I have already stated all of my decent ideas for the hour so I guess it's time for clown disease
[23:20] <@Showtime> 6:17 PM - Something angry!: Stage 1: The patient honks when hit and begins to exhibit signs of clumsiness
[23:20] <@Showtime> 6:18 PM - Something angry!: Stage 2: The patient's hair turns orange and forms into a goofy style
[23:20] <@Showtime> 6:18 PM - Something angry!: Stage 3: The subject sprouts full clown gear.  At this point there is no cure
[23:20] <@Showtime> 6:18 PM - [LLJK] Mr. Showtime: I support that
[23:20] <@Showtime> 6:19 PM - Something angry!: Make it transmitted by banana peels or something
*/

/datum/ailment/disease/clowning_around
	name = "Clowning Around"
	max_stages = 4
	spread = "Non-Contagious"
	cure = "Antibiotics"
	associated_reagent = "rainbow fluid"
	affected_species = list("Human")

/datum/ailment/disease/clowning_around/stage_act(var/mob/living/affected_mob, var/datum/ailment_data/D, mult)
	if (..())
		return
	if(affected_mob.job == "Clown")
		D.state = "Asymptomatic"
		return
	if(affected_mob.job == "Cluwne")
		D.state = "Asymptomatic"
		return
	if(isdead(affected_mob))
		return
	switch(D.stage)
		if(1, 2)
			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
				affected_mob.show_message(text("<span class='alert'>[] makes a strange honking sound!</span>", affected_mob), 1)
			if(probmult(8))
				boutput(affected_mob, "<span class='alert'>You feel your feet straining!</span>")
			if(probmult(8))
				boutput(affected_mob, "<span class='alert'>Peels... gotta get me some peels...</span>")
			if(probmult(8))
				affected_mob.say("HONK!")
		if(3)
			if(probmult(8))
				affected_mob.say("HONK HONK!!")
			if(probmult(8))
				affected_mob.say("Orange you glad I didn't say banana!")
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
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)

			if(probmult(10))
				if(!affected_mob:wear_mask || ((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/clown_hat)))
					var/c = affected_mob:wear_mask
					if((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/clown_hat))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/mask/clown_hat/clownmask = new /obj/item/clothing/mask/clown_hat(affected_mob)
					//clownmask.cursed = 1
					affected_mob:equip_if_possible( clownmask, affected_mob:slot_wear_mask) //Hope you like your new mask sucka!!!!!
		if(4)
#ifdef HALLOWEEN
			if(probmult(1))
				boutput(affected_mob, "<span class='alert'>You feel as if you could burst with joy!</span>")
				if(prob(50))
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(text("<span class='alert'><B>[]</B> starts convulsing violently!</span>", affected_mob), 1)
					// affected_mob.weakened = max(15, affected_mob.weakened)
					affected_mob.changeStatus("weakened", 2 SECONDS)
					affected_mob.make_jittery(1000)
					SPAWN(rand(20, 100))
						affected_mob.partygib()
					return
#endif
			if(probmult(10))
				if(!affected_mob:wear_mask || ((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/clown_hat)))
					var/c = affected_mob:wear_mask
					if((affected_mob:wear_mask != null) && !istype(affected_mob:wear_mask, /obj/item/clothing/mask/clown_hat))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/mask/clown_hat/clownmask = new /obj/item/clothing/mask/clown_hat(affected_mob)
					//clownmask.cursed = 1
					affected_mob:equip_if_possible( clownmask, affected_mob:slot_wear_mask)

			if(probmult(10))
				if(!affected_mob:w_uniform || ((affected_mob:w_uniform != null) && !istype(affected_mob:w_uniform, /obj/item/clothing/under/misc/clown)))
					var/c = affected_mob:w_uniform

					if((affected_mob:w_uniform != null) && !istype(affected_mob:w_uniform, /obj/item/clothing/under/misc/clown))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/under/misc/clown/clownsuit = new /obj/item/clothing/under/misc/clown(affected_mob)
					//clownsuit.cursed = 1
					affected_mob:equip_if_possible( clownsuit, affected_mob:slot_w_uniform)

			if(probmult(10))
				if(!affected_mob:shoes || ((affected_mob:shoes != null) && !istype(affected_mob:shoes, /obj/item/clothing/shoes/clown_shoes)))
					var/c = affected_mob:shoes
					if((affected_mob:shoes != null) && !istype(affected_mob:shoes, /obj/item/clothing/shoes/clown_shoes))
						affected_mob.u_equip(c)
						if(c)
							c:set_loc(affected_mob.loc)
							c:dropped(affected_mob)
							c:layer = initial(c:layer)

					var/obj/item/clothing/shoes/clown_shoes/clownshoes = new /obj/item/clothing/shoes/clown_shoes(affected_mob)
					//clownshoes.cursed = 1
					affected_mob:equip_if_possible( clownshoes, affected_mob:slot_shoes)

			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
				affected_mob.show_message(text("<span class='alert'>[] makes a strange honking sound!</span>", affected_mob), 1)

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
