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
	cure_flags = CURE_ANTIBIOTICS
	associated_reagent = "rainbow fluid"
	affected_species = list("Human")

/datum/ailment/disease/clowning_around/stage_act(mob/living/affected_mob, datum/ailment_data/D, mult)
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
	var/mob/living/carbon/human/H = null
	if (istype(H, /mob/living/carbon/human))
		H = affected_mob
	switch(D.stage)
		if(1, 2)
			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
				affected_mob.show_message(SPAN_ALERT("[affected_mob] makes a strange honking sound!"), 1)
			if(probmult(8))
				boutput(affected_mob, SPAN_ALERT("You feel your feet straining!"))
			if(probmult(8))
				boutput(affected_mob, SPAN_ALERT("Peels... gotta get me some peels..."))
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
								affected_mob.changeStatus("knockdown", 2 SECONDS)
								boutput(affected_mob, SPAN_ALERT("You feel clumsy and suddenly slip!"))

			if(probmult(10))
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)

			if(H && probmult(10))
				if(!H.wear_mask || ((H.wear_mask != null) && !istype(H.wear_mask, /obj/item/clothing/mask/clown_hat)))
					var/obj/item/clothing/mask/old_mask = H.wear_mask
					if((H.wear_mask != null) && !istype(H.wear_mask, /obj/item/clothing/mask/clown_hat))
						affected_mob.u_equip(old_mask)
						if(old_mask)
							old_mask.set_loc(affected_mob.loc)
							old_mask.dropped(affected_mob)
							old_mask.layer = initial(old_mask.layer)

					var/obj/item/clothing/mask/clown_hat/clownmask = new /obj/item/clothing/mask/clown_hat(affected_mob)
					//clownmask.cursed = 1
					H.equip_if_possible( clownmask, SLOT_WEAR_MASK) //Hope you like your new mask sucka!!!!!
		if(4)
#ifdef HALLOWEEN
			if(probmult(1))
				boutput(affected_mob, SPAN_ALERT("You feel as if you could burst with joy!"))
				if(prob(50))
					for(var/mob/O in viewers(affected_mob, null))
						O.show_message(SPAN_ALERT("<B>[affected_mob]</B> starts convulsing violently!"), 1)
					// affected_mob.weakened = max(15, affected_mob.weakened)
					affected_mob.changeStatus("knockdown", 2 SECONDS)
					affected_mob.make_jittery(1000)
					SPAWN(rand(20, 100))
						affected_mob.partygib()
					return
#endif
			if(H && probmult(10))
				if(!H.wear_mask || ((H.wear_mask != null) && !istype(H.wear_mask, /obj/item/clothing/mask/clown_hat)))
					var/obj/item/clothing/mask/old_mask = H.wear_mask
					if((H.wear_mask != null) && !istype(H.wear_mask, /obj/item/clothing/mask/clown_hat))
						affected_mob.u_equip(old_mask)
						if(old_mask)
							old_mask.set_loc(affected_mob.loc)
							old_mask.dropped(affected_mob)
							old_mask.layer = initial(old_mask.layer)

					var/obj/item/clothing/mask/clown_hat/clownmask = new /obj/item/clothing/mask/clown_hat(affected_mob)
					//clownmask.cursed = 1
					H.equip_if_possible( clownmask, SLOT_WEAR_MASK)

			if(H && probmult(10))
				if(!H.w_uniform || ((H.w_uniform != null) && !istype(H.w_uniform, /obj/item/clothing/under/misc/clown)))
					var/obj/item/clothing/under/olduni = H.w_uniform

					if((H.w_uniform != null) && !istype(H.w_uniform, /obj/item/clothing/under/misc/clown))
						H.u_equip(olduni)
						if(olduni)
							olduni.set_loc(H.loc)
							olduni.dropped(H)
							olduni.layer = initial(olduni.layer)

					var/obj/item/clothing/under/misc/clown/clownsuit = new /obj/item/clothing/under/misc/clown(affected_mob)
					//clownsuit.cursed = 1
					H.equip_if_possible( clownsuit, SLOT_W_UNIFORM)

			if(H && probmult(10))
				if(!H.shoes || ((H.shoes != null) && !istype(H.shoes, /obj/item/clothing/shoes/clown_shoes)))
					var/obj/item/clothing/shoes/oldshoes = H.shoes
					if((H.shoes != null) && !istype(H.shoes, /obj/item/clothing/shoes/clown_shoes))
						H.u_equip(oldshoes)
						if(oldshoes)
							oldshoes.set_loc(H.loc)
							oldshoes.dropped(H)
							oldshoes.layer = initial(oldshoes.layer)

					var/obj/item/clothing/shoes/clown_shoes/clownshoes = new /obj/item/clothing/shoes/clown_shoes(H)
					//clownshoes.cursed = 1
					H.equip_if_possible( clownshoes, SLOT_SHOES)

			if(probmult(8))
				playsound(affected_mob.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1)
				affected_mob.show_message(SPAN_ALERT("[affected_mob] makes a strange honking sound!"), 1)

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
								affected_mob.changeStatus("knockdown", 2 SECONDS)
								boutput(affected_mob, SPAN_ALERT("You feel clumsy and suddenly slip!"))
