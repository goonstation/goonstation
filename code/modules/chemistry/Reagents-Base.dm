//Contains base elements / reagents.
datum
	reagent
		aluminium
			name = "aluminium"
			id = "aluminium"
			description = "A silvery white and ductile member of the boron group of chemical elements."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255

		barium
			name = "barium"
			id = "barium"
			description = "A highly reactive element."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255

		bromine
			name = "bromine"
			id = "bromine"
			description = "A red-brown liquid element."
			reagent_state = LIQUID
			fluid_r = 150
			fluid_g = 50
			fluid_b = 50
			transparency = 50

		calcium
			name = "calcium"
			id = "calcium"
			description = "A white metallic element."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

		carbon
			name = "carbon"
			id = "carbon"
			description = "A chemical element critical to organic chemistry."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			hygiene_value = -0.5
			transparency = 255

			reaction_turf(var/turf/T, var/volume)
				if(!istype(T, /turf/space))
					if(volume >= 5)
						if(!locate(/obj/decal/cleanable/dirt) in T)
							make_cleanable(/obj/decal/cleanable/dirt,T)
						T.wet = 0

		chlorine
			name = "chlorine"
			id = "chlorine"
			description = "A chemical element."
			reagent_state = GAS
			fluid_r = 220
			fluid_g = 255
			fluid_b = 160
			transparency = 60
			penetrates_skin = 1
			depletion_rate = 0.6
			touch_modifier = 0.33

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.TakeDamage("chest", 0, 1*mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",3)

		chromium
			name = "chromium"
			id = "chromium"
			description = "A catalytic chemical element."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255
			penetrates_skin = 0

		copper
			name = "copper"
			id = "copper"
			description = "A chemical element."
			reagent_state = SOLID
			fluid_r = 184
			fluid_g = 115
			fluid_b = 51
			transparency = 255
			penetrates_skin = 0

		fluorine
			name = "fluorine"
			id = "fluorine"
			description = "A highly-reactive chemical element."
			reagent_state = GAS
			fluid_r = 255
			fluid_g = 215
			fluid_b = 160
			transparency = 60
			penetrates_skin = 1
			touch_modifier = 0.33

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(0.75 * mult) // buffin this because fluorine is horrible - adding a burn effect
				M.TakeDamage("chest", 0, 0.75 * mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",3)

		ethanol
			name = "ethanol"
			id = "ethanol"
			description = "A well-known alcohol with a variety of applications."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_b = 255
			fluid_g = 255
			transparency = 5
			addiction_prob = 1
			addiction_min = 10
			depletion_rate = 0.05 // ethanol depletes slower but is formed in smaller quantities
			overdose = 100 // ethanol poisoning
			thirst_value = -0.02
			bladder_value = -0.2
			hygiene_value = 1
			target_organs = list("liver")	//heart,  "stomach", "intestines", "left_kidney", "right_kidney"

			on_add()
				if (holder && ismob(holder.my_atom))
					holder.my_atom.setStatus("drunk", duration = INFINITE_STATUS)
				return

			on_remove()
				if (ismob(holder.my_atom))
					holder.my_atom.delStatus("drunk")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (isliving(M))
					var/mob/living/H = M
					var/ethanol_amt = holder.get_reagent_amount(src.id)
					if(H?.reagents.has_reagent("moonshine"))
						mult *= 7
					var/liver_damage = 0
					if (!isalcoholresistant(H) || H?.reagents.has_reagent("moonshine"))
						if (ethanol_amt >= 15)
							if(probmult(10)) H.emote(pick("hiccup", "burp", "mumble", "grumble"))
							H.stuttering += 1
							if (H.can_drunk_act() && probmult(10))
								step(H, pick(cardinal))
							if (prob(20)) H.make_dizzy(rand(3,5) * mult)
						if (ethanol_amt >= 25)
							//Though this var is set when ethanol_amt >= 25, that damage is not dealt until ethanol_amt > 40 (which is checked at the end of the proc)
							liver_damage = 0.25
							if(probmult(10)) H.emote(pick("hiccup", "burp"))
							if (probmult(10)) H.stuttering += rand(1,10)
						if (ethanol_amt >= 45)
							if(probmult(10))
								H.emote(pick("hiccup", "burp"))
							if (probmult(15))
								H.stuttering += rand(1,10)
							if (H.can_drunk_act() && probmult(8))
								step(H, pick(cardinal))
						if (ethanol_amt >= 55)
							liver_damage = 0.4
							if(probmult(10))
								H.emote(pick("hiccup", "fart", "mumble", "grumble"))
							H.stuttering += 1
							if (probmult(33))
								H.change_eye_blurry(10 , 50)
							if (H.can_drunk_act() && probmult(15))
								step(H, pick(cardinal))
							if(prob(4))
								H.change_misstep_chance(20 * mult)
							if(probmult(6))
								H.visible_message("<span class='alert'>[H] pukes all over [himself_or_herself(H)].</span>")
								H.vomit()
							if(prob(15))
								H.make_dizzy(5 * mult)
						if (ethanol_amt >= 60)
							H.change_eye_blurry(10 , 50)
							if(probmult(6)) H.changeStatus("drowsy", 15 SECONDS)
							if(prob(5)) H.take_toxin_damage(rand(1,2) * mult)

					if (ishuman(M))
						var/mob/living/carbon/human/HH = M
						if (HH.organHolder && HH.organHolder.liver)			//Hax here, lazy. currently only organ is liver. fix when adding others. -kyle
							if (HH.organHolder.liver.robotic)
								M.take_toxin_damage(-liver_damage * 3 * mult)
								if(!HH.organHolder.liver.emagged)
									HH.organHolder.heal_organ(liver_damage *mult, liver_damage *mult, liver_damage *mult, "liver")
							else
								if (ethanol_amt < 40 && HH.organHolder.liver.get_damage() < 10)
									HH.organHolder.damage_organ(0, 0, liver_damage*mult, "liver")
								else if (ethanol_amt >= 40 && prob(ethanol_amt/2))
									HH.organHolder.damage_organ(0, 0, liver_damage*mult, "liver")
//inc_alcohol_metabolized()
//bunch of extra logic for dumb stat tracking. This is copy pasted from proc/how_many_depletions() in Chemistry-Reagents.dm
#if defined(MAP_OVERRIDE_POD_WARS)
						var/amt_of_alcohol_metabolized = depletion_rate
						if (H.traitHolder?.hasTrait("slowmetabolism")) //fuck
							amt_of_alcohol_metabolized/= 2
						if (H.organHolder)
							if (!H.organHolder.liver || H.organHolder.liver.broken)	//if no liver or liver is dead, deplete slower
								amt_of_alcohol_metabolized /= 2
							if (H.organHolder.get_working_kidney_amt() == 0)	//same with kidneys
								amt_of_alcohol_metabolized /= 2

						if (istype(ticker.mode, /datum/game_mode/pod_wars))
							var/datum/game_mode/pod_wars/mode = ticker.mode
							mode.stats_manager?.inc_alcohol_metabolized(H, amt_of_alcohol_metabolized * mult)
#endif
					..()


			do_overdose(var/severity, var/mob/M, var/mult = 1)
				//Maybe add a bit that gives you a stamina buff if OD-ing on ethanol and you have a cyberliver.
				var/mob/living/carbon/human/H = M
				if (!istype(H) || !isalcoholresistant(H))
					// H.organHolder.damage_organs(0, 0, 3*mult, target_organs, 50)
					//hax again.
					if (prob(50))
						if (H.organHolder)
							var/damage = rand(1,3)
							if (H.organHolder.liver && prob(10))
								H.organHolder.damage_organ(0,0,damage * mult * (!H.organHolder.liver.robotic), "liver")
							if (H.organHolder.left_kidney && prob(15))
								H.organHolder.damage_organ(0,0,damage * mult * (!H.organHolder.left_kidney.robotic), "left_kidney")
							if (H.organHolder.right_kidney && prob(35))
								H.organHolder.damage_organ(0,0,damage * mult * (!H.organHolder.right_kidney.robotic), "right_kidney")

					if (prob(1))
						H.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
					..()

		hydrogen
			name = "hydrogen"
			id = "hydrogen"
			description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
			reagent_state = GAS
			fluid_r = 202
			fluid_g = 254
			fluid_b = 252
			transparency = 20

		iodine
			name = "iodine"
			id = "iodine"
			description = "A purple gaseous element."
			reagent_state = GAS
			fluid_r = 127
			fluid_g = 0
			fluid_b = 255
			transparency = 50

		iron
			name = "iron"
			id = "iron"
			description = "Pure iron is a metal, and can help with the regeneration of red blood cells after major trauma."
			reagent_state = SOLID
			fluid_r = 145
			fluid_g = 135
			fluid_b = 135
			transparency = 255
			overdose = 20
			pathogen_nutrition = list("iron")

			on_mob_life(var/mob/living/H, var/mult = 1)
				..()
				if (H.can_bleed)
					H.blood_volume += 0.5 * mult
					if(prob(10))
						H.take_oxygen_deprivation(-1 * mult)
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				M.take_toxin_damage(1 * mult) // Iron overdose fucks you up bad
				if(probmult(5))
					if (M.nutrition > 10) // Not good for your stomach either
						for(var/mob/O in viewers(M, null))
							O.show_message(text("<span class='alert'>[] vomits on the floor profusely!</span>", M), 1)
						M.vomit()
						M.nutrition -= rand(3,5)
						M.take_toxin_damage(10) // im bad
						M.setStatusMin("stunned", 3 SECONDS * mult)
						M.setStatusMin("weakened", 3 SECONDS * mult)

		lithium
			name = "lithium"
			id = "lithium"
			description = "A chemical element."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.canmove && isturf(M.loc))
					step(M, pick(cardinal))
				if(probmult(5)) M.emote(pick("twitch","drool","moan"))
				..()
				return

		magnesium
			name = "magnesium"
			id = "magnesium"
			description = "A hot-burning chemical element."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255

			reaction_turf(var/turf/T, var/volume)
				if (volume >= 10)
					if (!locate(/obj/decal/cleanable/magnesiumpile) in T)
						make_cleanable(/obj/decal/cleanable/magnesiumpile,T)

		mercury
			name = "mercury"
			id = "mercury"
			description = "A chemical element."
			reagent_state = LIQUID
			fluid_r = 160
			fluid_g = 160
			fluid_b = 160
			transparency = 255
			penetrates_skin = 1
			touch_modifier = 0.2
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(70))
					M.take_brain_damage(1*mult)
				if (probmult(5) && isliving(M)) //folk treatment for the black plague- drinking mercury
					var/mob/living/L = M
					var/datum/ailment_data/disease/plague = L.find_ailment_by_type(/datum/ailment/disease/space_plague)
					if (istype(plague))
						L.cure_disease(plague)
				..()

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",1)

		nickel
			name = "nickel"
			id = "nickel"
			description = "Not actually a coin."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255

		nitrogen
			name = "nitrogen"
			id = "nitrogen"
			description = "A colorless, odorless, tasteless gas."
			reagent_state = GAS
			fluid_r = 202
			fluid_g = 254
			fluid_b = 252
			transparency = 20
			pathogen_nutrition = list("nitrogen")

		oxygen
			name = "oxygen"
			id = "oxygen"
			description = "A colorless, odorless gas."
			reagent_state = GAS
			fluid_r = 202
			fluid_g = 254
			fluid_b = 252
			transparency = 20

		phosphorus
			name = "phosphorus"
			id = "phosphorus"
			description = "A chemical element."
			reagent_state = SOLID
			fluid_r = 150
			fluid_g = 110
			fluid_b = 110
			transparency = 255

			on_plant_life(var/obj/machinery/plantpot/P)
				if (prob(66))
					P.growth++

		plasma
			name = "plasma"
			id = "plasma"
			description = "The liquid phase of an unusual extraterrestrial compound."
			reagent_state = LIQUID

			fluid_r = 130
			fluid_g = 40
			fluid_b = 160
			transparency = 222
			minimum_reaction_temperature = T0C + 100
			var/reacted_to_temp = 0 // prevent infinite loop in a fluid

			reaction_temperature(exposed_temperature, exposed_volume)
				if(!reacted_to_temp)
					reacted_to_temp = 1
					if(holder)
						var/list/covered = holder.covered_turf()
						for(var/turf/t in covered)
							SPAWN(1 DECI SECOND) fireflash(t, clamp(((volume/covered.len)/15), 0, 6))
				if(holder)
					holder.del_reagent(id)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(holder.has_reagent("epinephrine"))
					holder.remove_reagent("epinephrine", 2 * mult)
				M.take_toxin_damage(1 * mult)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 30 SECONDS)
				return 1

			reaction_obj(var/obj/O, var/volume)
				return 1

			reaction_turf(var/turf/T, var/volume)
				return 1 //changed return value to 1 for fluids. remove if this was a bad idea

			on_plant_life(var/obj/machinery/plantpot/P)
				var/datum/plant/growing = P.current
				if (growing.growthmode != "plasmavore")
					P.HYPdamageplant("poison",2)

		platinum
			name = "platinum"
			id = "platinum"
			description = "Shiny."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255

		potassium
			name = "potassium"
			id = "potassium"
			description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
			reagent_state = SOLID
			fluid_r = 190
			fluid_g = 190
			fluid_b = 190
			transparency = 255

			on_plant_life(var/obj/machinery/plantpot/P)
				if (prob(40))
					P.growth++
					P.health++

		silicon
			name = "silicon"
			id = "silicon"
			description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
			reagent_state = SOLID
			fluid_r = 120
			fluid_g = 140
			fluid_b = 150
			transparency = 255

		silver
			name = "silver"
			id = "silver"
			description = "A lustrous metallic element regarded as one of the precious metals."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 255
			taste = "metallic"

			reaction_obj(var/obj/item/I, var/volume)
				if (I.material && I.material.mat_id == "silver")
					return 1

				.= 1

				if (volume >= 20)
					if (istype(I, /obj/item/ammo/bullets/bullet_22HP) || istype(I, /obj/item/ammo/bullets/bullet_22) || istype(I, /obj/item/ammo/bullets/a38) || istype(I, /obj/item/ammo/bullets/custom) || istype(I,/datum/projectile/bullet/revolver_38))
						var/obj/item/ammo/bullets/bullet_holder = I
						var/datum/projectile/ammo_type = bullet_holder.ammo_type
						if (ammo_type && !(ammo_type.material && ammo_type.material.mat_id == "silver"))
							ammo_type.material = getMaterial("silver")
							holder.remove_reagent(src.id, 20)
							.= 0
				if (volume >= 50)
					if (I.type == /obj/item/handcuffs)
						I.setMaterial(getMaterial("silver"), copy = FALSE)
						holder.remove_reagent(src.id, 50)
						.= 0

		sulfur
			name = "sulfur"
			id = "sulfur"
			description = "A chemical element."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 255

		sugar
			name = "sugar"
			id = "sugar"
			description = "This white, odorless, crystalline powder has a pleasing, sweet taste."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			overdose = 200
			hunger_value = 0.098
			thirst_value = -0.098
			pathogen_nutrition = list("sugar")
			taste = "sweet"
			stun_resist = 6
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_sugar", 2)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_sugar")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_jittery(2 )
				M.changeStatus("drowsy", -10 SECONDS)
				if(prob(4))
					M.reagents.add_reagent("epinephrine", 1.2 * mult) // let's not metabolize into meth anymore
				//if(prob(2))
					//M.reagents.add_reagent("cholesterol", rand(1,3))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (M.bioHolder?.HasEffect("bee"))

					var/obj/item/reagent_containers/food/snacks/ingredient/honey/honey = new /obj/item/reagent_containers/food/snacks/ingredient/honey(get_turf(M))
					if (honey.reagents)
						honey.reagents.maximum_volume = 50

					honey.name = "human honey"
					honey.desc = "Uhhhh.  Uhhhhhhhhhhhhhhhhhhhh."
					M.reagents.trans_to(honey, 50)
					M.visible_message("<b>[M]</b> regurgitates a blob of honey! Gross!")
					playsound(M.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
					M.reagents.del_reagent(src.id)

					var/beeMax = 15
					for (var/obj/critter/domestic_bee/responseBee in range(7, M))
						if (!responseBee.alive)
							continue

						if (beeMax-- < 0)
							break

						responseBee.visible_message("<b>[responseBee]</b> [ pick("looks confused.", "appears to undergo a metaphysical crisis.  What is human?  What is space bee?<br>Or it might just have gas.", "looks perplexed.", "bumbles in a confused way.", "holds out its forelegs, staring into its little bee-palms and wondering what is real.") ]")

				else
					if (!M.getStatusDuration("paralysis"))
						boutput(M, "<span class='alert'>You pass out from hyperglycemic shock!</span>")
						M.emote("collapse")
						//M.changeStatus("paralysis", ((2 * severity)*15) * mult)
						M.changeStatus("weakened", ((4 * severity)*1.5 SECONDS) * mult)

					if (prob(8))
						M.take_toxin_damage(severity * mult)
				return

		//WHY IS SWEET ***TEA*** A SUBTYPE OF SUGAR?!?!?!?!
			//Because it's REALLY sweet

		sugar/sweet_tea
			name = "sweet tea"
			id = "sweet_tea"
			description = "A solution of sugar and tea, popular in the American South.  Some people raise the sugar levels in it to the point of saturation and beyond."
			reagent_state = LIQUID
			fluid_r = 139
			fluid_g = 90
			fluid_b = 54
			transparency = 235
			thirst_value = 0.7909
			hunger_value = 0.098

		helium
			name = "helium"
			id = "helium"
			description = "A chemical element."
			reagent_state = GAS
			fluid_r = 255
			fluid_g = 250
			fluid_b = 160
			transparency = 155
			data = null

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					if(M.bioHolder && !M.bioHolder.HasEffect("quiet_voice"))
						M.bioHolder.AddEffect("quiet_voice")
				..()

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					if(M?.bioHolder.HasEffect("quiet_voice"))
						M.bioHolder.RemoveEffect("quiet_voice")
				..()

		radium
			name = "radium"
			id = "radium"
			description = "Radium is an alkaline earth metal. It is highly radioactive."
			reagent_state = SOLID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 255
			penetrates_skin = 1
			touch_modifier = 0.5 //Half the dose lands on the floor
			blob_damage = 1

			New()
				..()
				if(prob(10))
					description += " Keep away from forums."

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_radiation_dose(0.05 SIEVERTS * mult, internal=TRUE)
				..()
				return

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				var/spawncleanable = 1
				if(length(covered) > 5 && (volume/length(covered) < 1))
					spawncleanable = prob((volume/covered.len) * 10)


				if(spawncleanable && !istype(T, /turf/space) && !(locate(/obj/decal/cleanable/greenglow) in T))
					make_cleanable(/obj/decal/cleanable/greenglow,T)

			on_plant_life(var/obj/machinery/plantpot/P)
				if (prob(80)) P.HYPdamageplant("radiation",3)
				if (prob(16)) P.HYPmutateplant(1)

		sodium
			name = "sodium"
			id = "sodium"
			description = "A soft, silvery-white, highly reactive alkali metal."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 255
			pathogen_nutrition = list("sodium")

		uranium
			name = "uranium"
			id = "uranium"
			description = "A radioactive heavy metal commonly used for nuclear fission reactions."
			reagent_state = SOLID
			fluid_r = 40
			fluid_g = 40
			fluid_b = 40
			transparency = 255

			on_mob_life(var/mob/M, var/mult = 1 )
				if(!M) M = holder.my_atom
				M.take_radiation_dose(0.075 SIEVERTS * mult, internal=TRUE)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("radiation",2)
				if (prob(24)) P.HYPmutateplant(1)

		water
			name = "water"
			id = "water"
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 165
			fluid_b = 254
			transparency = 80
			pathogen_nutrition = list("water")
			thirst_value = 0.8909
			hygiene_value = 1.33
			bladder_value = -0.2
			taste = "bland"
			minimum_reaction_temperature = -INFINITY
			target_organs = list("left_kidney", "right_kidney")
			heat_capacity = 400
#ifdef UNDERWATER_MAP
			block_slippy = 1
			description = "A little strange. Not like any water you've seen. But definitely OSHA approved."
#else
			description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
#endif

			on_mob_life(var/mob/living/L, var/mult = 1)
				..()
				if (ishuman(L))
					var/mob/living/carbon/human/H = L
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 0, 1*mult, target_organs, 10)
				L.nutrition += 1  * mult

			reaction_temperature(exposed_temperature, exposed_volume) //Just an example.
				if(exposed_temperature < T0C)
					var/prev_vol = volume
					volume = 0
					holder?.add_reagent("ice", prev_vol, null, (T0C - 1))
					if(holder)
						holder.del_reagent(id)
				else if (exposed_temperature > T0C && exposed_temperature <= T0C + 100 )
					name = "water"
					description = initial(description)
				else if (exposed_temperature > (T0C + 100) )
					if (!istype(holder,/datum/reagents/fluid_group))
						name = "steam"
						description = "Water turned steam."
					if (holder.my_atom && holder.my_atom.is_open_container() || istype(holder,/datum/reagents/fluid_group))
						//boil off
						var/list/covered = holder.covered_turf()
						if (covered.len < 5)
							for(var/turf/t in covered)
								if (covered.len > 2 && prob(50)) continue //lol look guys i 'fixed' it!
								var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
								smoke.set_up(1, 0, t)
								smoke.start()
								t.visible_message("The water boils off.")

						if (covered.len > 1)
							if (volume/covered.len < 10)
								holder.del_reagent(src.id)
							else
								holder.remove_reagent(src.id, max(1, volume * 0.2))

								var/difference = (T20C - holder.total_temperature)
								var/change = difference * 0.6
								holder.set_reagent_temp(holder.total_temperature + change)
						else
							holder.del_reagent(src.id)

				return

			reaction_turf(var/turf/target, var/volume)
				return 1//fluid is better. remove this later probably

			reaction_obj(var/obj/item/O, var/volume)
				. = ..()
				if(istype(O))
					if(O.burning && prob(80))
						O.combust_ended()
					else if(istype(O, /obj/item/toy/sponge_capsule))
						var/obj/item/toy/sponge_capsule/S = O
						S.add_water()

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(!raw_volume)
					raw_volume = 10
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", -1 * raw_volume SECONDS)
						playsound(L, 'sound/impact_sounds/burn_sizzle.ogg', 50, 1, pitch = 0.8)
						. = 0

		water/water_holy
			name = "holy water"
			id = "water_holy"
			description = "Blessed water, supposedly effective against evil."
			thirst_value = 0.8909
			hygiene_value = 2
			value = 3 // 1 1 1

			reaction_mob(var/mob/target, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				..()
				var/reacted = 0
				var/mob/living/M = target
				if(istype(M))
					if(by_type[/obj/machinery/playerzoldorf] && length(by_type[/obj/machinery/playerzoldorf]))
						var/obj/machinery/playerzoldorf/pz = by_type[/obj/machinery/playerzoldorf][1]
						if(M in pz.brandlist)
							pz.brandlist -= M
							boutput(M,"<span class='success'><b>The feeling of an otherworldly presence passes...</b></span>")
						for(var/mob/zoldorf/Z in M)
							Z.set_loc(Z.homebooth)
					if (isvampire(M))
						M.emote("scream")
						for(var/mob/O in AIviewers(M, null))
							O.show_message(text("<span class='alert'><b>[] begins to crisp and burn!</b></span>", M), 1)
						boutput(M, "<span class='alert'>Holy Water! It burns!</span>")
						var/burndmg = raw_volume * 1.25 //the sanctification inflicts the pain, not the water that carries it.
						burndmg = min(burndmg, 80) //cap burn at 110(80 now >:) so we can't instant-kill vampires. just crit em ok.
						M.TakeDamage("chest", 0, burndmg, 0, DAMAGE_BURN)
						M.change_vampire_blood(-burndmg)
						reacted = 1
					else if (method == TOUCH)
						if (M.traitHolder?.hasTrait("atheist"))
							boutput(M, "<span class='notice'>You feel insulted... and wet.</span>")
						else
							if (ishuman(M))
								var/mob/living/carbon/human/H = M
								if(H.bioHolder?.HasEffect("blood_curse") || H.bioHolder?.HasEffect("blind_curse") || H.bioHolder?.HasEffect("weak_curse") || H.bioHolder?.HasEffect("rot_curse"))
									H.bioHolder.RemoveEffect("blood_curse")
									H.bioHolder.RemoveEffect("blind_curse")
									H.bioHolder.RemoveEffect("weak_curse")
									H.bioHolder.RemoveEffect("rot_curse")
									H.visible_message("[H] screams as some black smoke exits their body.")
									H.emote("scream")
									random_burn_damage(H, 5)
									var/turf/T = get_turf(H)
									if (T && isturf(T))
										var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
										if (S)
											S.set_up(5, 0, T, null, "#3b3b3b")
											S.start()
								else
									boutput(M, "<span class='notice'>You feel somewhat purified... but mostly just wet.</span>")
							else
								boutput(M, "<span class='notice'>You feel somewhat purified... but mostly just wet.</span>")
							M.take_brain_damage(0 - clamp(volume, 0, 10))
						for (var/datum/ailment_data/disease/V in M.ailments)
							if(prob(1))
								M.cure_disease(V)
						reacted = 1
				if(method == TOUCH)
					var/mob/living/L = target
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", -20 SECONDS)
				return !reacted

		water/tonic
			name = "tonic water"
			id = "tonic"
			description = "Carbonated water with quinine for a bitter flavor. Protects against Space Malaria."
			reagent_state = LIQUID
			thirst_value = 0.8909
			hygiene_value = 0.75
			bladder_value = -0.25
			taste = "bitter"

			reaction_temperature(exposed_temperature, exposed_volume) //Just an example.
				if(exposed_temperature <= T0C)
					name = "tonic ice"
					description = "Frozen water with quinine for a bitter flavor. That is, if you eat ice cubes.  Weirdo."
				else if (exposed_temperature > T0C + 100)
					name = "tonic steam"
					description = "Water turned steam. Steam that protects against Space Malaria."
					if (holder.my_atom && holder.my_atom.is_open_container())
						//boil off
						var/list/covered = holder.covered_turf()
						if (covered.len < 5)
							for(var/turf/t in covered)
								if (covered.len > 2 && prob(50)) continue //lol look guys i 'fixed' it!
								var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
								smoke.set_up(1, 0, t)
								smoke.start()
								t.visible_message("The water boils off.")

						if (covered.len > 1)
							if (volume/covered.len < 10)
								holder.del_reagent(src.id)
							else
								holder.remove_reagent(src.id, max(1, volume * 0.4))
						else
							holder.del_reagent(src.id)
				else
					name = "Tonic water"
					description = "Carbonated water with quinine for a bitter flavor. Protects against Space Malaria."

		water/sea
			name = "seawater"
			id = "seawater"
			description = "A little strange. Not like any seawater you've seen. But definitely OSHA approved."
			block_slippy = 1
			reagent_state = LIQUID
			thirst_value = -0.3 //Sea water actually slowly dehydrates you because you use more liquid to get rid of the salt then you gain.
			hygiene_value = 0.3
			bladder_value = -0.5
			taste = "gross"

		ice
			name = "ice"
			id = "ice"
			description = "It's frozen water. What did you expect?!"
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 250
			transparency = 200
			thirst_value = 0.8909
			bladder_value = -0.2
			minimum_reaction_temperature = T0C+1 // if it adds 1'C water, 1'C is good enough.
			taste = "cold"

			reaction_temperature(exposed_temperature, exposed_volume)
				var/prev_vol = volume
				volume = 0
				holder?.add_reagent("water", prev_vol, null, T0C + 1)
				if(holder)
					holder.del_reagent(id)

			reaction_obj(var/obj/O, var/volume)
				return

			reaction_turf(var/turf/T, var/volume)
				if (volume >= 5 && !(locate(/obj/item/raw_material/ice) in T))
					var/obj/item/raw_material/ice/I = new /obj/item/raw_material/ice
					I.set_loc(T)
				return

		phenol
			name = "phenol"
			id = "phenol"
			description = "Also known as carbolic acid, this is a useful building block in organic chemistry."
			reagent_state = SOLID
			fluid_r = 180
			fluid_g = 180
			fluid_b = 180
			transparency = 35
			value = 5 // 3c + 1c + 1c
