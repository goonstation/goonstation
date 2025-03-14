//Contains medical reagents / drugs.

ABSTRACT_TYPE(/datum/reagent/medical)

datum
	reagent
		medical/
			name = "medical thing"
			viscosity = 0.1

		medical/lexorin // COGWERKS CHEM REVISION PROJECT. this is a totally pointless reagent
			name = "lexorin"
			id = "lexorin"
			description = "Lexorin temporarily stops respiration. Causes tissue damage."
			reagent_state = LIQUID
			fluid_r = 125
			fluid_g = 195
			fluid_b = 160
			transparency = 80
			depletion_rate = 0.2
			value = 3
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_REBREATHING, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_REBREATHING, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				..()
				return


		medical/spaceacillin
			name = "spaceacillin"
			id = "spaceacillin"
			description = "An all-purpose antibiotic agent extracted from space fungus."
			reagent_state = LIQUID
			fluid_r = 10
			fluid_g = 180
			fluid_b = 120
			transparency = 255
			depletion_rate = 0.2
			value = 3 // 2c + 1c

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				for(var/datum/ailment_data/disease/virus in M.ailments)
					if (virus.cure_flags & CURE_ANTIBIOTICS)
						virus.state = "Remissive"
				if(M.hasStatus("poisoned"))
					M.changeStatus("poisoned", -10 SECONDS * mult)
				..()
				return

		medical/morphine // // COGWERKS CHEM REVISION PROJECT. roll the antihistamine effects into this?
			name = "morphine"
			id = "morphine"
			description = "A strong but highly addictive opiate painkiller with sedative side effects."
			reagent_state = LIQUID
			fluid_r = 169
			fluid_g = 251
			fluid_b = 251
			transparency = 30
			addiction_prob = 10
			addiction_min = 15
			overdose = 15
			var/counter = 1 //Data is conserved...so some jerkbag could inject a monkey with this, wait for data to build up, then extract some instant KO juice.  Dumb.
			depletion_rate = 0.4
			value = 5
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_morphine", -2)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/morphine, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_morphine")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/morphine, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!counter) counter = 1
				M.jitteriness = max(M.jitteriness-25,0)
				if(M.hasStatus("stimulants"))
					M.changeStatus("stimulants", -7.5 SECONDS * mult)
				if(M.hasStatus("recent_trauma"))
					M.changeStatus("recent_trauma", -5 SECONDS * mult)
				if(probmult(7)) M.emote("yawn")
				..()
				switch(counter += 1 * mult)
					if(16 to 36)
						if(probmult(10)) M.setStatus("drowsy", 10 SECONDS)
					if(36 to INFINITY)
						if(probmult(20)) M.setStatus("drowsy", 40 SECONDS)
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				switch(counter)
					if(16 to 36)
						M.setStatus("drowsy", 40 SECONDS)
					if(36 to INFINITY)
						M.setStatusMin("unconscious", 3 SECONDS * mult)
						M.setStatus("drowsy", 40 SECONDS)
				..()
				return

		medical/ether
			name = "diethyl ether"
			id = "ether"
			description = "A strong but highly addictive and flammable anesthetic and sedative."
			reagent_state = LIQUID
			fluid_r = 169
			fluid_g = 251
			fluid_b = 251
			transparency = 30
			addiction_prob = 10
			addiction_min = 15
			depletion_rate = 0.3
			overdose = 40   //Ether is known for having a big difference in effective to toxic dosage
			var/counter = 1 //Data is conserved...so some jerkbag could inject a monkey with this, wait for data to build up, then extract some instant KO juice.  Dumb.
			minimum_reaction_temperature = T0C + 80 //This stuff is extremely flammable
			var/temp_reacted = 0
			value = 5
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_ether", -4)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_ether")
				..()

			proc/ether_fireflash(var/volume) // Proc for all of the fireflash reactions
				if(!temp_reacted)
					temp_reacted = 1
					var/radius = clamp(volume*0.25, 0, 3) // Even the smoke might make a big problem here
					var/list/covered = holder.covered_turf()
					for(var/turf/t in covered)
						radius = clamp((volume/covered.len)*0.25, 0, 5)
						fireflash(t, radius, rand(2000, 3000), 500, chemfire = CHEM_FIRE_RED)
				holder?.del_reagent(id)

			reaction_temperature(exposed_temperature, exposed_volume)
				if (ismob(holder?.my_atom) && volume < 50) // We don't want this stuff exploding inside people..
					return
				ether_fireflash(volume)
				return

			reaction_obj(var/obj/O, var/volume)
				if (isnull(O)) return
				if(isitem(O))
					var/obj/item/I = O
					if(I.firesource) // Direct contact with any firesource is enough to cause the ether to combust
						ether_fireflash(volume)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == TOUCH)
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						ether_fireflash(volume)
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!counter) counter = 1
				M.jitteriness = max(M.jitteriness-25,0)
				if(M.hasStatus("stimulants"))
					M.changeStatus("stimulants", -4 SECONDS * mult)
				if(M.hasStatus("recent_trauma")) // can be used to help fix recent trauma
					M.changeStatus("recent_trauma", -2 SECONDS * mult)
				if(holder.has_reagent(src.id,10)) // large doses progress somewhat faster than small ones
					counter += mult
					depletion_rate = 0.6 // depletes faster in large doses as well
				else
					depletion_rate = 0.3

				switch(counter += 1 * mult)
					if(1 to 7)
						if(probmult(7)) M.emote("yawn")
					if(7 to 30)
						M.setStatus("drowsy", 40 SECONDS)
						if(probmult(9)) M.emote(pick("smile","giggle","yawn"))
					if(30 to INFINITY)
						depletion_rate = 0.6
						M.setStatusMin("unconscious", 6 SECONDS * mult)
						M.setStatus("drowsy", 40 SECONDS)
				..()
				return

		medical/cold_medicine
			name = "robustissin"
			id = "cold_medicine"
			description = "A pharmaceutical compound used to treat minor colds, coughs, and other ailments."
			reagent_state = LIQUID
			fluid_r = 107
			fluid_g = 29
			fluid_b = 122
			transparency = 70
			addiction_prob = 6
			overdose = 30
			value = 7 // Okay there are two recipes, so two different values... I'll just go with the lower one.

			on_mob_life(var/mob/living/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(8))
					M.emote(pick("smile","giggle","yawn"))
				for(var/datum/ailment_data/disease/virus in M.ailments)
					if(probmult(25) && istype(virus.master,/datum/ailment/disease/cold))
						M.cure_disease(virus)
					if(probmult(25) && istype(virus.master,/datum/ailment/disease/flu))
						M.cure_disease(virus)
					if(probmult(25) && istype(virus.master,/datum/ailment/disease/food_poisoning))
						M.cure_disease(virus)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				M.druggy = max(M.druggy, 15)
				M.stuttering += rand(0,2)
				if(severity == 1)
					if(effect <= 4)
						M.emote(pick("blink","shiver","drool"))
						M.change_misstep_chance(8 * mult)
					else if (effect <= 9)
						M.emote("twitch")
						M.setStatusMin("knockdown", 3 SECONDS * mult)
					else if(effect <= 12)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
						M.druggy ++
				else if (severity == 2)
					if(effect <= 4)
						M.emote(pick("shiver","moan","groan","laugh"))
						M.change_misstep_chance(14 * mult)
					else if (effect <= 10)
						M.emote("twitch")
						M.setStatusMin("knockdown", 3 SECONDS * mult)
					else if (effect <= 13)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
						M.druggy ++


		medical/teporone // COGWERKS CHEM REVISION PROJECT. marked for revision
			name = "teporone"
			id = "teporone"
			description = "This experimental plasma-based compound seems to regulate body temperature."
			reagent_state = LIQUID
			fluid_r = 210
			fluid_g = 100
			fluid_b = 225
			transparency = 200
			addiction_prob = 0.1
			addiction_min = 10
			overdose = 50
			value = 7 // 5c + 1c + 1c

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_jittery(2)
				if(M.bodytemperature > M.base_body_temp)
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(15 * mult))
				else if(M.bodytemperature < 311)
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(15 * mult))
				..()
				return

		medical/salicylic_acid
			name = "salicylic acid"
			id = "salicylic_acid"
			description = "This is a is a standard salicylate pain reliever and fever reducer."
			reagent_state = LIQUID
			fluid_r = 181
			fluid_g = 72
			fluid_b = 72
			transparency = 100
			overdose = 25
			depletion_rate = 0.1
			value = 11 // 5c + 3c + 1c + 1c + 1c
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/salicylic_acid, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/salicylic_acid, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(M.hasStatus("recent_trauma"))
					M.changeStatus("recent_trauma", -2.5 SECONDS * mult)
				if(!M) M = holder.my_atom
				if(prob(55))
					M.HealDamage("All", 2 * mult, 0)
				if(M.bodytemperature > M.base_body_temp)
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(10 * mult))
				// I only put this following bit because wiki claims it "attempts to return temperature to normal"
				// Rather than the previous functionality of cooling down when hot
				// No need to implement if the wiki is erronous here
				if(M.bodytemperature < M.base_body_temp)
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(10 * mult))
				..()
				return

		medical/menthol
			name = "menthol"
			id = "menthol"
			description = "Menthol relieves burns and aches while providing a cooling sensation."
			fluid_r = 239
			fluid_g = 249
			fluid_b = 202
			transparency = 180
			depletion_rate = 0.1
			penetrates_skin = 1
			value = 2 // I think this is correct?
			hygiene_value = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(55))
					M.HealDamage("All", 0, 2 * mult)
				if(M.bodytemperature > 280)
					M.bodytemperature = max(M.bodytemperature-(10 * mult),280)
				..()
				return

		medical/calomel // COGWERKS CHEM REVISION PROJECT. marked for revision. should be a chelation agent
			name = "calomel"
			id = "calomel"
			description = "This potent purgative rids the body of impurities. It is highly toxic however and close supervision is required."
			reagent_state = LIQUID
			fluid_r = 25
			fluid_g = 200
			fluid_b = 50
			depletion_rate = 0.8
			transparency = 200
			value = 3 // 1c + 1c + heat

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				flush(holder, 3 * mult)
				if(M.health > 20)
					M.take_toxin_damage(5 * mult, 1)	//calomel doesn't damage organs.
				M.nauseate(1)
				..()
				return

		/*medical/tricalomel // COGWERKS CHEM REVISION PROJECT. marked for revision. also a chelation agent
			name = "Tricalomel"
			id = "tricalomel"
			description = "Tricalomel can be used to remove most non-natural compounds from an organism. It is slightly toxic however and supervision is required."
			reagent_state = LIQUID
			fluid_r = 33
			fluid_g = 255
			fluid_b = 75
			depletion_rate = 0.8
			transparency = 200
			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				..()
				for(var/reagent_id in M.reagents.reagent_list)
					if(reagent_id != id)
						M.reagents.remove_reagent(reagent_id, 6)
				if(M.health > 18)
					M.take_toxin_damage(2)
				return  */


		medical/yobihodazine // COGWERKS CHEM REVISION PROJECT. probably just a magic drug, i have no idea what this is supposed to be
			name = "yobihodazine"
			id = "yobihodazine"
			description = "A powerful outlawed compound capable of preventing vacuum damage. Prolonged use leads to neurological damage."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			addiction_prob = 0.2
			addiction_min = 5
			value = 13

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp)
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(15 * mult))
				else if(M.bodytemperature > M.base_body_temp)
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(15 * mult))
				if(volume >= 1)
					var/oxyloss = M.get_oxygen_deprivation()
					M.take_oxygen_deprivation(-INFINITY)
					M.take_brain_damage(oxyloss / 15)
				..()
				return

		medical/synthflesh
			name = "synthetic flesh"
			id = "synthflesh"
			description = "A resorbable microfibrillar collagen and protein mixture that can rapidly heal injuries when applied topically."
			reagent_state = SOLID
			fluid_r = 255
			fluid_b = 235
			fluid_g = 235
			transparency = 255
			value = 9 // 6c + 2c + 1c

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/list/paramslist = 0)
				. = ..()
				if(!volume_passed)
					return
				volume_passed = clamp(volume_passed, 0, 10)

				if(method == TOUCH)
					. = 0
					if(issilicon(M)) //Metal flesh isn't repaired by synthflesh
						return
					M.HealDamage("All", volume_passed * 1.5, volume_passed * 1.5)
					if (isliving(M))
						var/mob/living/H = M
						if (H.disfigured)
							boutput(H, SPAN_NOTICE("You feel the synthflesh seeping into your face."))
							H.disfigured = FALSE
							H.UpdateName()
						if (H.bleeding)
							repair_bleeding_damage(H, 80, 2)
						if (ishuman(M))
							var/mob/living/carbon/human/healed = M
							healed.heal_slash_wound("all")
							healed.heal_laser_wound("all")

					var/silent = 0
					if (length(paramslist))
						if ("silent" in paramslist)
							silent = 1
					if (!silent)
						boutput(M, SPAN_NOTICE("The synthetic flesh integrates itself into your wounds, healing you."))

					M.UpdateDamageIcon()

				else if(method == INGEST)
					if (isliving(M))
						if (M.vdisfigured)
							boutput(M, SPAN_NOTICE("You feel the ache in your vocal chords dissipate as you ingest the synthflesh."))
							M.vdisfigured = FALSE

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 9)
					volume = (volume/covered.len)

				if(volume >= 5)
					if(!locate(/obj/decal/cleanable/blood/gibs) in T)
						playsound(T, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, TRUE)
						make_cleanable(/obj/decal/cleanable/blood/gibs,T)
			/*reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/parts/robot_parts/robot_frame))
					if (O.check_completion() && volume >= 20)
						O.replicant = 1
						O.overlays = null
						O.icon_state = "repli_suit"
						O.name = "Unfinished Replicant"
						for(var/mob/V in AIviewers(O, null)) V.show_message(text(SPAN_ALERT("The solution molds itself around []."), O), 1)
					else
						for(var/mob/V in AIviewers(O, null)) V.show_message(text(SPAN_ALERT("The solution fails to cling to []."), O), 1)*/


		medical/synaptizine // COGWERKS CHEM REVISION PROJECT. remove this, make epinephrine (epinephrine) do the same thing
			name = "synaptizine"
			id = "synaptizine"
			description = "Synaptizine a mild medical stimulant. Can be used to reduce drowsyness and resist disabling symptoms such as paralysis."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 0
			fluid_b = 255
			transparency = 175
			overdose = 40
			value = 7
			stun_resist = 31
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_synaptizine", 4)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_synaptizine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.changeStatus("drowsy", -10 SECONDS)
				if(M.sleeping) M.sleeping = 0
				if (M.get_brain_damage() <= 90)
					if (prob(50)) M.take_brain_damage(-1 * mult)
				else M.take_brain_damage(-10 * mult) // Zine those synapses into not dying *yet*
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 3)
						M.emote(pick("groan","moan"))
					else if (effect <= 8)
						M.take_toxin_damage(1 * mult)
					else if (effect <= 30)
						M.nauseate(1)
				else if (severity == 2)
					if (effect <= 5)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> staggers and drools, their eyes crazed and bloodshot!"))
						M.dizziness += 8
						M.reagents.add_reagent("madness_toxin", randfloat(2.5 , 5) * src.calculate_depletion_rate(M, mult))
					else if (effect <= 15)
						M.take_toxin_damage(1 * mult)
					else if(effect <= 40)
						M.nauseate(1)

		medical/omnizine // COGWERKS CHEM REVISION PROJECT. magic drug, ought to use plasma or something
			name = "omnizine"
			id = "omnizine"
			description = "Omnizine is a highly potent healing medication that can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 40
			addiction_prob = 0.2
			addiction_min = 5
			depletion_rate = 0.2
			overdose = 30
			value = 22
			target_organs = list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")	//RN this is all the organs. Probably I'll remove some from this list later.

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				if(M.get_oxygen_deprivation())
					M.take_oxygen_deprivation(-1 * mult)
				if(M.losebreath && prob(50))
					M.lose_breath(-1 * mult)
				M.HealDamage("All", 2 * mult, 2 * mult, 1 * mult)
				if (isliving(M))
					var/mob/living/L = M
					if (L.bleeding)
						repair_bleeding_damage(L, 10, 1 * mult)
					if (L.blood_volume < 500)
						L.blood_volume ++
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.organHolder)
							H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)

				//M.UpdateDamageIcon()
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1) //lesser
					M.stuttering += 1
					if(effect <= 1)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> suddenly cluches their gut!"))
						M.emote("scream")
						M.setStatusMin("knockdown", 4 SECONDS * mult)
					else if(effect <= 3)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> completely spaces out for a moment."))
						M.change_misstep_chance(15 * mult)
					else if(effect <= 5)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> stumbles and staggers."))
						M.dizziness += 5
						M.setStatusMin("knockdown", 4 SECONDS * mult)
					else if(effect <= 7)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> shakes uncontrollably."))
						M.make_jittery(30)
				else if (severity == 2) // greater
					if(effect <= 5)
						M.visible_message(pick(SPAN_ALERT("<b>[M.name]</b> jerks bolt upright, then collapses!"),
							SPAN_ALERT("<b>[M.name]</b> suddenly cluches their gut!")))
						M.setStatusMin("knockdown", 8 SECONDS * mult)
					else if(effect <= 8)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> stumbles and staggers."))
						M.dizziness += 5
						M.setStatusMin("knockdown", 4 SECONDS * mult)

		medical/saline // COGWERKS CHEM REVISION PROJECT. magic drug, ought to use plasma or something
			name = "saline-glucose solution"
			id = "saline"
			description = "This saline and glucose solution can help stabilize critically injured patients and cleanse wounds."
			reagent_state = LIQUID
			thirst_value = 0.25
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 40
			penetrates_skin = 1 // splashing saline on someones wounds would sorta help clean them
			depletion_rate = 0.15
			value = 5 // 3c + 1c + 1c

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (prob(33))
					M.HealDamage("All", 2 * mult, 2 * mult)
				if (blood_system && isliving(M) && prob(33))
					var/mob/living/H = M
					H.blood_volume += 1  * mult
					H.nutrition += 1  * mult
				//M.UpdateDamageIcon()
				..()
				return

		medical/anti_rad // COGWERKS CHEM REVISION PROJECT. replace with potassum iodide
			name = "potassium iodide"
			id = "anti_rad"
			description = "Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning."
			reagent_state = LIQUID
			fluid_r = 20
			fluid_g = 255
			fluid_b = 60
			transparency = 40
			value = 2 // 1c + 1c
			target_organs = list("left_kidney", "right_kidney", "liver")
			threshold = THRESHOLD_INIT
			threshold_volume = 5

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.radiation_dose && prob(75))
					M.take_radiation_dose(-0.01 SIEVERTS * mult)

				M.take_toxin_damage(-0.5 * mult)
				M.HealDamage("All", 0, 0, 0.5 * mult)

				if (prob(33) && ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)
				..()
				return

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, "r_potassium_iodide", 25)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_RADPROT_INT, "r_potassium_iodide")
				..()

		medical/smelling_salt
			name = "ammonium bicarbonate"
			id = "smelling_salt"
			description = "Ammonium bicarbonate."
			reagent_state = LIQUID
			fluid_r = 20
			fluid_g = 255
			fluid_b = 60
			transparency = 40
			value = 3
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("neurotoxin","capulettium","sulfonal","ketamine","sodium_thiopental","pancuronium", "neurodepressant")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_smelling_salt", 2)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_smelling_salt")
				..()
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/list/paramslist = 0)
				if(method == INGEST && volume_passed >= 3)
					if(isliving(M) && !M.hasStatus("smelling_salts") && ("inhaled" in paramslist))
						var/mob/living/H = M
						H.delStatus("drowsy")
						H.delStatus("passing_out")
						if (H.stamina < 0 || H.hasStatus("knockdown") || H.hasStatus("unconscious")) //enhanced effects if you're downed (also implies a second person is applying this)
							H.TakeDamage("chest", 0, 10, 0, DAMAGE_BURN) // a little damage penalty
							if (H.use_stamina)
								H.stamina = max(H.stamina_max*0.2,H.stamina)
							H.changeStatus("unconscious", -20 SECONDS)
							H.changeStatus("knockdown", -20 SECONDS)
						if (H.sleeping == TRUE)
							H.sleeping = 0
						H.setStatus("smelling_salts", 6 MINUTES)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				flush(holder, 3 * mult, flushed_reagents)
				if(M.getStatusDuration("radiation") && prob(30))
					M.take_radiation_dose(-0.005 SIEVERTS * mult)
				if (prob(5))
					M.take_toxin_damage(1 * mult)
				..()
				return

		medical/oculine // COGWERKS CHEM REVISION PROJECT. probably a magic drug, maybe ought to involve atropine
			name = "oculine"
			id = "oculine"
			description = "Oculine is a combined eye and ear medication with antibiotic effects."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 111
			penetrates_skin = 1
			value = 26 // 18 5 3

			// I've added hearing damage here (Convair880).
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom

				if (M.bioHolder)
					var/datum/bioEffect/BE
					BE = M.bioHolder.GetEffect("bad_eyesight")
					if (probmult(50) && BE?.curable_by_mutadone)
						M.bioHolder.RemoveEffect("bad_eyesight")
					BE = M.bioHolder.GetEffect("blind")
					if (probmult(30) && BE?.curable_by_mutadone)
						M.bioHolder.RemoveEffect("blind")
					BE = M.bioHolder.GetEffect("deaf")
					if (probmult(30) && (M.get_ear_damage() && M.get_ear_damage() <= M.get_ear_damage_natural_healing_threshold()) && BE?.curable_by_mutadone)
						M.bioHolder.RemoveEffect("deaf")

				if (M.get_eye_blurry())
					M.change_eye_blurry(-1)

				if (M.get_eye_damage() && prob(80)) // Permanent eye damage.
					M.take_eye_damage(-1 * mult)

				if (M.get_eye_damage(1) && prob(50)) // Temporary blindness.
					M.take_eye_damage(-0.5 * mult, 1)

				if (M.get_ear_damage() && prob(80)) // Permanent ear damage.
					M.take_ear_damage(-1 * mult)

				if (M.get_ear_damage(1) && prob(50)) // Temporary deafness.
					M.take_ear_damage(-0.5 * mult, 1)

				..()
				return

		medical/haloperidol // COGWERKS CHEM REVISION PROJECT. ought to be some sort of shitty illegal opiate or hypnotic drug
			name = "haloperidol"
			id = "haloperidol"
			description = "Haloperidol is a powerful antipsychotic and sedative. Will help control psychiatric problems, but may cause brain damage."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 220
			fluid_b = 255
			transparency = 255
			value = 8 // 2c + 3c + 1c + 1c + 1c
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("LSD","lsd_bee","psilocybin","crank","bathsalts","THC","space_drugs","catdrugs","methamphetamine","epinephrine","synaptizine")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_haloperidol", -5)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_haloperidol")
				..()

			on_mob_life(var/mob/living/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-50,0)
				if (M.druggy > 0)
					M.druggy -= 3
					M.druggy = max(0, M.druggy)
				flush(holder, 5 * mult, flushed_reagents)
				if(M.hasStatus("stimulants"))
					M.changeStatus("stimulants", -15 SECONDS * mult)
				if(probmult(5))
					for(var/datum/ailment_data/disease/virus in M.ailments)
						if(istype(virus.master,/datum/ailment/disease/space_madness) || istype(virus.master,/datum/ailment/disease/berserker))
							M.cure_disease(virus)
				if(prob(20)) M.take_brain_damage(1 * mult)
				if(probmult(50)) M.changeStatus("drowsy", 10 SECONDS)
				if(probmult(10)) M.emote("drool")
				..()
				return

		medical/epinephrine // COGWERKS CHEM REVISION PROJECT. Could be Epinephrine instead
			name = "epinephrine"
			id = "epinephrine"
			description = "Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest."
			reagent_state = LIQUID
			fluid_r = 210
			fluid_g = 255
			fluid_b = 250
			depletion_rate = 0.2
			overdose = 20
			value = 17 // 5c + 5c + 4c + 1c + 1c + 1c
			stun_resist = 10
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("histamine")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_epinephrine", 3)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/epinepherine, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_epinephrine")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/epinepherine, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(7 * mult))
				if(probmult(10))
					M.make_jittery(4)
				M.changeStatus("drowsy", -10 SECONDS)
				if(M.sleeping && probmult(5)) M.sleeping = 0
				if(M.get_brain_damage() && prob(5)) M.take_brain_damage(-1 * mult)
				flush(holder, 3 * mult, flushed_reagents) //combats symptoms not source //ok combats source a bit more
				if(M.losebreath > 3)
					M.losebreath -= (1 * mult)
				if(M.get_oxygen_deprivation() > 35)
					M.take_oxygen_deprivation(-10 * mult)
				if(M.health < -10 && M.health > -65)
					M.HealDamage("All", 1 * mult, 1 * mult, 1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 3)
						M.emote(pick("groan","moan"))
					else if (effect <= 8)
						M.emote("collapse")
					else if (effect <= 20)
						M.nauseate(1)
				else if (severity == 2)
					if (effect <= 5)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> staggers and drools, their eyes bloodshot!"))
						M.dizziness += 2
						M.setStatusMin("knockdown", 4 SECONDS * mult)
					else if (effect <= 15)
						M.emote("collapse")
					else if (effect <= 20)
						M.nauseate(1)

		medical/heparin
			name = "heparin"
			id = "heparin"
			description = "An anticoagulant used in heart surgeries, and in the treatment of heart attacks and blood clots."
			reagent_state = LIQUID
			fluid_r = 238
			fluid_g = 230
			fluid_b = 218
			transparency = 80
			depletion_rate = 0.4
			overdose = 20

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (holder.has_reagent("cholesterol"))
					holder.remove_reagent("cholesterol", 2 * mult) // insulin used to do this but now doesn't, so w/e this can do it now.
				..()
				return

			// od effects: you blood fall out (bleeding from pores esp.)
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				DEBUG_MESSAGE("[M] processing OD of heparin ([src.volume]u): severity [severity], effect [effect]")
				if (severity == 1) //lesser
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("[M] coughs up a lot of blood!"))
						playsound(M, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(M, rand(5,10) * mult, 3 * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("[M] coughs up a little blood!"))
						playsound(M, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(M, rand(1,2) * mult, 1 * mult)
				else if (severity == 2) // greater
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M] is bleeding from [his_or_her(M)] very pores!"))
						bleed(M, rand(10,20) * mult, rand(1,3) * mult)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							var/list/gear_to_bloody = list(H.r_hand, H.l_hand, H.head, H.wear_mask, H.w_uniform, H.wear_suit, H.belt, H.gloves, H.glasses, H.shoes, H.wear_id, H.back)
							for (var/obj/item/check in gear_to_bloody)
								LAGCHECK(LAG_LOW)
								if (prob(40))
									check.add_blood(H)
							H.update_blood_all()
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("[M] coughs up a lot of blood!"))
						playsound(M, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(M, rand(5,10) * mult, 3 * mult)
					else if (effect <= 8)
						M.visible_message(SPAN_ALERT("[M] coughs up a little blood!"))
						playsound(M, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(M, rand(1,2) * mult, 1 * mult)

		medical/proconvertin // old name for factor VII, which is a protein that causes blood to clot. this stuff is seemingly just used for people with hemophilia but this is ss13 so let's give it to everybody who's bleeding a little, it's fine.
			name = "proconvertin"
			id = "proconvertin"
			description = "A protein that causes blood to begin clotting, which can be useful in cases of uncontrollable bleeding, but it may also cause dangerous blood clots to form."
			reagent_state = LIQUID
			fluid_r = 252
			fluid_g = 252
			fluid_b = 224
			transparency = 230
			depletion_rate = 0.3
			overdose = 10
			threshold = THRESHOLD_INIT


			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_proconvertin", -2)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_proconvertin")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (isliving(M))
					var/mob/living/H = M
					repair_bleeding_damage(H, 50, 1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (isliving(M))
					var/mob/living/H = M
					if (probmult(6)) // ~60% chance to get a clot from 15u
						H.contract_disease(/datum/ailment/malady/bloodclot,null,null,1)

		medical/filgrastim // used to stimulate the body to produce more white blood cells. here, it will make you make more blood. this is good if you are losing a lot of blood and bad if you already have all your blood
			name = "filgrastim"
			id = "filgrastim"
			description = "A granulocyte colony stimulating factor analog, a hematopoiesis stimulant, which helps the body to produce more white blood cells, and thus more blood in general."
			reagent_state = LIQUID
			fluid_r = 157
			fluid_g = 180
			fluid_b = 161
			overdose = 35
			transparency = 120
			depletion_rate = 0.2
			target_organs = list("left_lung", "right_lung")

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (isliving(M))
					var/mob/living/H = M
					H.blood_volume += 2 * mult
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (isliving(M))
					var/mob/living/L = M
					if (prob(50))
						L.losebreath += 1*mult
					else
						L.take_oxygen_deprivation(1 * mult)
					if(prob(20))
						L.emote("cough")
					else if (severity > 1 && prob(50))
						L.visible_message(SPAN_ALERT("[L] coughs up a little blood!"))
						playsound(L, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE)
						bleed(L, rand(2,8) * mult, 3 * mult)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.organHolder)
							H.organHolder.damage_organs(1*mult, 0, 1*mult, target_organs, 50)

			// od effects: coughing up blood, damage to lungs (the alveoli specifically) so some oxy damage/losebreath

		medical/insulin // COGWERKS CHEM REVISION PROJECT. does Medbay have this? should be in the medical vendor
			name = "insulin"
			id = "insulin"
			description = "A hormone generated by the pancreas responsible for metabolizing carbohydrates and fat in the bloodstream."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 240
			transparency = 50
			value = 6
			var/list/flushed_reagents = list("sugar")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				flush(holder, 5 * mult, flushed_reagents)
				//if(holder.has_reagent("cholesterol")) //probably doesnt actually happen but whatever
					//holder.remove_reagent("cholesterol", 2)
				..()
				return

		medical/silver_sulfadiazine // COGWERKS CHEM REVISION PROJECT. marked for revision
			name = "silver sulfadiazine"
			id = "silver_sulfadiazine"
			description = "This antibacterial compound is used to treat burn victims."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 220
			fluid_b = 0
			transparency = 225
			depletion_rate = 3
			value = 6 // 2c + 1c + 1c + 1c + 1c

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				// Please don't set this to 8 again, medical patches add their contents to the bloodstream too.
				// Consequently, a single patch would heal ~200 damage (Convair880).
				M.HealDamage("All", 0, 2 * mult)
				M.UpdateDamageIcon()
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/list/paramslist = 0)
				. = ..()
				if(issilicon(M)) // borgs shouldn't heal from this
					return
				if (!volume_passed)
					return
				volume_passed = clamp(volume_passed, 0, 10)

				if (method == TOUCH)
					. = 0
					M.HealDamage("All", 0, volume_passed)

					var/silent = 0
					if (length(paramslist))
						if ("silent" in paramslist)
							silent = 1
					if (!silent)
						boutput(M, SPAN_NOTICE("The silver sulfadiazine soothes your burns."))


					M.UpdateDamageIcon()
				else if (method == INGEST)
					boutput(M, SPAN_ALERT("You feel sick..."))
					if (volume_passed > 0)
						M.take_toxin_damage(volume_passed/2)
						M.add_karma(0.5)


		medical/mutadone // COGWERKS CHEM REVISION PROJECT. - marked for revision. Magic bullshit chem, ought to be related to mutagen somehow
			name = "mutadone"
			id = "mutadone"
			description = "Mutadone is an experimental bromide that can cure genetic abnormalities."
			reagent_state = SOLID
			fluid_r = 80
			fluid_g = 150
			fluid_b = 200
			transparency = 255
			value = 9 // 5 3 1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bioHolder && M.bioHolder.effects && length(M.bioHolder.effects)) //One per cycle. We're having superpowered hellbastards and this is their kryptonite.
					var/datum/bioEffect/B = M.bioHolder.effects[pick(M.bioHolder.effects)]
					if (B?.curable_by_mutadone)
						M.bioHolder.RemoveEffect(B.id)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				var/datum/plantgenes/DNA = P.plantgenes
				if (P.growth > 5)
					growth_tick.growth_rate -= 4
				if (DNA.growtime < 0)
					growth_tick.growtime_bonus += 0.5
				if (DNA.harvtime < 0)
					growth_tick.harvtime_bonus += 0.5
				if (DNA.harvests < 0)
					growth_tick.harvests_bonus += 0.5
				if (DNA.cropsize < 0)
					growth_tick.cropsize_bonus += 0.5
				if (DNA.potency < 0)
					growth_tick.potency_bonus += 0.5
				if (DNA.endurance < 0)
					growth_tick.endurance_bonus += 0.5

		medical/promethazine // This stops you from vomiting
			name = "promethazine"
			id = "promethazine"
			description = "Promethazine is a anti-emetic agent."
			reagent_state = LIQUID
			fluid_r = 180
			fluid_g = 255
			fluid_b = 140
			depletion_rate = 0.4
			overdose = 100
			threshold = THRESHOLD_INIT

			on_mob_life(var/mob/M, var/mult = 1)
				. = ..()
				M.nauseate(-1)

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_CANNOT_VOMIT, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANNOT_VOMIT, src.type)
				..()

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 5)
						boutput(M, SPAN_ALERT("<b>You feel tired.</b>"))
						M.changeStatus("slowed", 4 SECONDS)
					if (effect <= 10)
						boutput(M, SPAN_ALERT("<b>Your [pick("mouth", "tongue")] feels dry.</b>"))
				else if (severity == 2)
					if (effect <= 5)
						boutput(M, SPAN_ALERT("<b>You feel tired and dizzy.</b>"))
						M.dizziness += 8
						M.changeStatus("slowed", 4 SECONDS)
					else if (effect <= 12)
						boutput(M, SPAN_ALERT("<b>Your vision blurs.</b>"))
						M.change_eye_blurry(4, 4)
				..()
				return

		medical/ephedrine // COGWERKS CHEM REVISION PROJECT. poor man's epinephrine
			name = "ephedrine"
			id = "ephedrine"
			description = "Ephedrine is a plant-derived stimulant."
			reagent_state = LIQUID
			fluid_r = 210
			fluid_g = 255
			fluid_b = 250
			depletion_rate = 0.3
			overdose = 35
			addiction_prob = 0.1
			addiction_min = 10
			value = 9 // 4c + 3c + 1c + 1c
			var/remove_buff = 0
			stun_resist = 15
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_ephedrine", 2)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_ephedrine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(5 * mult))
				M.make_jittery(4)
				M.changeStatus("drowsy", -10 SECONDS)
				if(M.losebreath > 3)
					M.losebreath = max(5, M.losebreath-(1 * mult))
				if(M.get_oxygen_deprivation() > 75)
					M.take_oxygen_deprivation(-1 * mult)
				if ((M.health < 0) || (M.health > 0 && probmult(33)))
					if (M.get_toxin_damage() && prob(25))
						M.take_toxin_damage(-1 * mult)
					M.HealDamage("All", 1 * mult, 1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 3)
						M.emote(pick("groan","moan"))
					else if (effect <= 8)
						M.take_toxin_damage(1 * mult)
					else if (effect <= 20)
						M.nauseate(1)
				else if (severity == 2)
					if (effect <= 5)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> staggers and drools, their eyes bloodshot!"))
						M.dizziness += 8
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					else if (effect <= 15)
						M.take_toxin_damage(1 * mult)
					else if (effect <= 30)
						M.nauseate(1)


		medical/penteticacid // COGWERKS CHEM REVISION PROJECT. should be a potent chelation agent, maybe roll this into tribenzocytazine as Pentetic Acid
			name = "pentetic acid"
			id = "penteticacid"
			description = "Pentetic Acid is an aggressive chelation agent. May cause tissue damage. Use with caution."
			reagent_state = LIQUID
			fluid_r = 178
			fluid_g = 255
			fluid_b = 209
			transparency = 200
			value = 16 // 7 2 4 1 1 1
			target_organs = list("left_kidney", "right_kidney", "liver", "stomach", "intestines")

			on_mob_life(var/mob/M, var/mult = 1)
				flush(holder, 3 * mult) //flushes all chemicals but itself
				M.take_radiation_dose(-0.05 SIEVERTS * mult)
				if (prob(75))
					M.HealDamage("All", 0, 0, 4 * mult)
				if (prob(33))
					M.TakeDamage("chest", 1 * mult, 1 * mult, 0, DAMAGE_BLUNT)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(3*mult, 3*mult, 3*mult, target_organs)
				..()
				return

		medical/antihistamine
			name = "diphenhydramine"
			id = "antihistamine"
			description = "Anti-allergy medication. May cause drowsiness, do not operate heavy machinery while using this."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_b = 255
			fluid_g = 230
			transparency = 220
			addiction_prob = 1
			addiction_min = 10
			value = 10 // 4 3 1 1 1
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("histamine","itching")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_diphenhydramine", -3)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_diphenhydramine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-20,0)
				flush(holder, 3 * mult, flushed_reagents)
				if(probmult(7)) M.emote("yawn")
				if(prob(3))
					M.setStatusMin("stunned", 3 SECONDS * mult)
					M.changeStatus("drowsy", 12 SECONDS)
					M.visible_message(SPAN_NOTICE("<b>[M.name]<b> looks a bit dazed."))
				..()
				return

		medical/styptic_powder // // COGWERKS CHEM REVISION PROJECT. marked for revision
			name = "styptic powder"
			id = "styptic_powder" // HOW FUCKING LONG WAS THIS MISSPELLED AS stypic_powder AND WHY DID IT TAKE ME TWO YEARS TO NOTICE?! *SCREAM
			description = "Styptic (aluminium sulfate) powder helps control bleeding and heal physical wounds."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 150
			fluid_b = 150
			transparency = 255
			depletion_rate = 3
			value = 6 // 3c + 1c + 1c + 1c

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				// Please don't set this to 8 again, medical patches add their contents to the bloodstream too.
				// Consequently, a single patch would heal ~200 damage (Convair880).
				M.HealDamage("All", 2 * mult, 0)
				M.UpdateDamageIcon()
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/list/paramslist = 0)
				. = ..()
				if(!volume_passed)
					return
				if(!isliving(M)) // fucking human shitfucks
					return
				if(issilicon(M)) // Borgs shouldn't heal from this
					return
				volume_passed = clamp(volume_passed, 0, 10)
				if(method == TOUCH)
					. = 0
					M.HealDamage("All", volume_passed, 0)
					// M.HealBleeding(volume_passed) // At least implement your stuff properly first, thanks. Styptic also shouldn't be as good as synthflesh for healing bleeding.

					/*for(var/A in M.organs)
						var/obj/item/affecting = null
						if(!M.organs[A])    continue
						affecting = M.organs[A]
						if(!istype(affecting, /obj/item/organ))    continue
						affecting.heal_damage(volume_passed, 0)*/

					var/mob/living/L = M
					if (L.bleeding == 1)
						repair_bleeding_damage(L, 50, 1)
					else if (L.bleeding <= 3)
						repair_bleeding_damage(L, 5, 1)

					M.UpdateDamageIcon()
				else if(method == INGEST)
					boutput(M, SPAN_ALERT("You feel gross!"))
					if (volume_passed > 0)
						M.take_toxin_damage(volume_passed/2)
						if (prob(1) && isliving(M))
							var/mob/living/L = M
							L.contract_disease(/datum/ailment/malady/bloodclot,null,null,1)

		medical/cryoxadone // COGWERKS CHEM REVISION PROJECT. magic drug, but isn't working right correctly
			name = "cryoxadone"
			id = "cryoxadone"
			description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 200
			transparency = 255
			value = 12 // 5 3 3 1
			target_organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")	//RN this is all the organs. Probably I'll remove some from this list later. no "brain",  either

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp - 100 && M.bodytemperature > M.base_body_temp - 275 && !M.hasStatus("burning")) //works in approx 35K to 210K -> -238C to -63C - medbay freezer goes down to -200C
					if(M.get_oxygen_deprivation())
						M.take_oxygen_deprivation(-2 * mult)
					if(M.losebreath && prob(50))
						M.lose_breath(-1 * mult)
					if (M.get_brain_damage())
						M.take_brain_damage(-2 * mult)
					M.HealDamage("All", 2 * mult, 2 * mult, 3 * mult)

					M.take_radiation_dose(-0.025 SIEVERTS * mult)
					M.bodytemperature = min(M.bodytemperature + (12.5 * mult), M.base_body_temp)

					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.organHolder)
							H.organHolder.heal_organs(2*mult, 2*mult, 2*mult, target_organs)

				..()

		medical/atropine // COGWERKS CHEM REVISION PROJECT. i dunno what the fuck this would be, probably something bad. maybe atropine?
			name = "atropine"
			id = "atropine"
			description = "Atropine is a potent cardiac resuscitant but it can causes confusion, dizzyness and hyperthermia."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			depletion_rate = 0.2
			overdose = 25
			var/remove_buff = 0
			var/total_misstep = 0
			value = 18 // 5 4 5 3 1
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("saxitoxin")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("atropine", -30)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("atropine")
				..()


			on_add()
				src.total_misstep = 0
				..()

			on_remove()
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					M.change_misstep_chance(-src.total_misstep)
				..()

			on_mob_life(var/mob/M, var/mult = 1) //god fuck this proc
				if(!M) M = holder.my_atom
				M.make_dizzy(1 * mult)
				M.change_misstep_chance(5 * mult)
				src.total_misstep += 5 * mult
				if(M.bodytemperature < M.base_body_temp)
					M.bodytemperature = min(M.base_body_temp + 10, M.bodytemperature+(10 * mult))
				if(probmult(4)) M.emote("collapse")
				if(M.losebreath > 5)
					M.losebreath = max(5, M.losebreath-(5 * mult))
				if(M.get_oxygen_deprivation() > 65)
					M.take_oxygen_deprivation(-10 * mult)
				if(M.health < -25)
					if(M.get_toxin_damage())
						M.take_toxin_damage(-1 * mult)
					M.HealDamage("All", 3 * mult, 3 * mult)
					if (M.get_brain_damage())
						M.take_brain_damage(-2 * mult)
				else if (M.health > 15 && M.get_toxin_damage() < 70)
					M.take_toxin_damage(1 * mult)
					flush(holder, 20 * mult, flushed_reagents)
				..()
				return

		medical/salbutamol // COGWERKS CHEM REVISION PROJECT. marked for revision. Could be Dexamesathone
			name = "salbutamol"
			id = "salbutamol"
			description = "Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			depletion_rate = 0.2
			value = 16 // 11 2 1 1 1
			overdose = 50
			target_organs = list("left_lung", "right_lung", "spleen")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_oxygen_deprivation(-6 * mult)
				if(M.losebreath)
					M.losebreath = max(0, M.losebreath-(4 * mult))

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)

				..()
				return

			//severe overdose can damage kidneys
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				// var/effect = ..(severity, M)
				if (severity >= 2)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.organHolder && probmult(40))
							if (prob(50))
								H.organHolder.damage_organ(0, 0, severity*mult, "right_kidney")
							else
								H.organHolder.damage_organ(0, 0, severity*mult, "left_kidney")
				..(severity, M)

		medical/perfluorodecalin
			name = "perfluorodecalin"
			id = "perfluorodecalin"
			description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 100
			fluid_b = 100
			transparency = 40
			addiction_prob = 0.2
			addiction_min = 10
			value = 6 // 3 1 1 heat
			target_organs = list("left_lung", "right_lung", "spleen")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_oxygen_deprivation(-25 * mult)
				if(src.volume >= 4) // stop killing dudes goddamn
					M.losebreath = max(6, M.losebreath)
				if(prob(33)) // has some slight healing properties due to tissue oxygenation
					M.HealDamage("All", 1 * mult, 1 * mult)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(2*mult, 2*mult, 2*mult, target_organs)
				..()
				return

		medical/mannitol
			name = "mannitol"
			id = "mannitol"
			description = "Mannitol is a sugar alcohol that can help alleviate cranial swelling."
			reagent_state = LIQUID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 255
			transparency = 240
			value = 3 // 1 1 1
			target_organs = list("brain")		//unused for now

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_brain_damage(-3 * mult)
				..()
				return

		medical/charcoal
			name = "charcoal"
			id = "charcoal"
			description = "Activated charcoal helps to absorb toxins."
			reagent_state = SOLID
			fluid_r = 0
			fluid_b = 0
			fluid_g = 0
			value = 5 // 3c + 1c + heat
			target_organs = list("left_kidney", "right_kidney", "liver", "stomach", "intestines")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(50))
					flush(holder, 1 * mult)
				M.HealDamage("All", 0, 0, 1.5 * mult)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)

				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				if(P.reagents.has_reagent("toxin"))
					P.reagents.remove_reagent("toxin", 2)
				if(P.reagents.has_reagent("toxic_slurry"))
					P.reagents.remove_reagent("toxic_slurry", 2)
				if(P.reagents.has_reagent("acid"))
					P.reagents.remove_reagent("acid", 2)
				if(P.reagents.has_reagent("plasma"))
					P.reagents.remove_reagent("plasma", 2)
				if(P.reagents.has_reagent("mercury"))
					P.reagents.remove_reagent("mercury", 2)
				if(P.reagents.has_reagent("fuel"))
					P.reagents.remove_reagent("fuel", 2)
				if(P.reagents.has_reagent("chlorine"))
					P.reagents.remove_reagent("chlorine", 2)
				if(P.reagents.has_reagent("radium"))
					P.reagents.remove_reagent("radium", 2)

		medical/antihol // COGWERKS CHEM REVISION PROJECT. maybe a diuretic or some sort of goofy common hangover cure
			name = "antihol"
			id = "antihol"
			description = "A medicine which quickly eliminates alcohol in the body."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_b = 180
			fluid_g = 200
			transparency = 220
			value = 6 // 5c + 1c
			var/list/flushed_reagents = list("ethanol")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				flush(holder, 8 * mult, flushed_reagents)
				if (M.get_toxin_damage() <= 25)
					M.take_toxin_damage(-2 * mult)
				..()
				return

		medical/ipecac
			name = "space ipecac"
			id = "ipecac"
			fluid_r = 2
			fluid_g = 20
			fluid_b =  5
			description = "Used to induce emesis. In space."
			reagent_state = LIQUID
			depletion_rate = 0.8
			value = 3 // 1c + 1c + heat
			viscosity = 0.8

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.health > 25)
					M.take_toxin_damage(1 * mult)
				M.nauseate(2) //ur gonna puke a lot
				if(probmult(5))
					var/mob/living/L = M
					L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
				..()
				return

		medical/necrovirus_cure // Necrotic Degeneration
			name = "necrovirus_cure"
			id = "necrovirus_cure"
			description = "The cure for the necrovirus/Zombie Disease. Can be used to totally cure infected below stage 4."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 220
			fluid_b = 200
			transparency = 230
