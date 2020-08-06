//Contains medical reagents / drugs.
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
					if (virus.cure == "Antibiotics")
						virus.state = "Remissive"
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
			addiction_prob = 10//50
			addiction_min = 15
			overdose = 20
			var/counter = 1 //Data is conserved...so some jerkbag could inject a monkey with this, wait for data to build up, then extract some instant KO juice.  Dumb.
			var/remove_buff = 0
			value = 5

			pooled()
				..()
				counter = 1
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_morphine", -3)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/morphine, src.type)
				return

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					if(remove_buff)
						M.remove_stam_mod_regen("r_morphine")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/morphine, src.type)
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!counter) counter = 1
				M.jitteriness = max(M.jitteriness-25,0)

				switch(counter++)
					if(1 to 15)
						if(prob(7)) M.emote("yawn")
					if(16 to 35)
						M.drowsyness  = max(M.drowsyness, 20)
					if(36 to INFINITY)
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 30 * mult))
						M.drowsyness  = max(M.drowsyness, 20)

				..()
				return

		medical/ether
			name = "ether"
			id = "ether"
			description = "A strong but highly addictive anesthetic and sedative."
			reagent_state = LIQUID
			fluid_r = 169
			fluid_g = 251
			fluid_b = 251
			transparency = 30
			addiction_prob = 10//50
			addiction_min = 15
			overdose = 20
			var/counter = 1 //Data is conserved...so some jerkbag could inject a monkey with this, wait for data to build up, then extract some instant KO juice.  Dumb.
			var/remove_buff = 0
			value = 5

			pooled()
				..()
				counter = 1
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_ether", -5)
				return

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_ether")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!counter) counter = 1
				M.jitteriness = max(M.jitteriness-25,0)

				switch(counter++)
					if(1 to 15)
						if(prob(7)) M.emote("yawn")
					if(16 to 35)
						M.drowsyness  = max(M.drowsyness, 20)
					if(36 to INFINITY)
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 30 * mult))
						M.drowsyness  = max(M.drowsyness, 20)

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
				if(prob(8))
					M.emote(pick("smile","giggle","yawn"))
				for(var/datum/ailment_data/disease/virus in M.ailments)
					if(prob(25) && istype(virus.master,/datum/ailment/disease/cold))
						M.cure_disease(virus)
					if(prob(25) && istype(virus.master,/datum/ailment/disease/flu))
						M.cure_disease(virus)
					if(prob(25) && istype(virus.master,/datum/ailment/disease/food_poisoning))
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
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 30 * mult))
					else if(effect <= 12)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
						M.druggy ++
				else if (severity == 2)
					if(effect <= 4)
						M.emote(pick("shiver","moan","groan","laugh"))
						M.change_misstep_chance(14 * mult)
					else if (effect <= 10)
						M.emote("twitch")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 30 * mult))
					else if (effect <= 13)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
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
			addiction_prob = 1//20
			addiction_prob2 = 10
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

			on_mob_life(var/mob/M, var/mult = 1)
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

			on_add()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/salicylic_acid, src.type)

			on_remove()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/salicylic_acid, src.type)

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

				for(var/reagent_id in M.reagents.reagent_list)
					if(reagent_id != id)
						M.reagents.remove_reagent(reagent_id, 5 * mult)
				if(M.health > 20)
					M.take_toxin_damage(5 * mult, 1)	//calomel doesn't damage organs.
				if(prob(6))
					M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>")
					M.vomit()
				if(prob(4))
					M.emote("piss")
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
			description = "A powerful outlawed compound capable of preventing vaccuum damage. Prolonged use leads to neurological damage."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			addiction_prob = 1//20
			addiction_prob2 = 20
			addiction_min = 5
			value = 13

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp)
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(15 * mult))
				else if(M.bodytemperature > M.base_body_temp)
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(15 * mult))
				M.take_oxygen_deprivation(-INFINITY)
				if(prob(20))
					M.take_brain_damage(1 * mult)
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
				src = null
				if(!volume_passed)
					return
				if(method == TOUCH)
					M.HealDamage("All", volume_passed * 1.5, volume_passed * 1.5)
					if (isliving(M))
						var/mob/living/H = M
						if (H.bleeding)
							repair_bleeding_damage(H, 80, 2)

					var/silent = 0
					if (paramslist && paramslist.len)
						if ("silent" in paramslist)
							silent = 1
					if (!silent)
						boutput(M, "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>")

					M.UpdateDamageIcon()

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				src = null

				if (covered.len > 9)
					volume = (volume/covered.len)

				if(volume >= 5)
					if(!locate(/obj/decal/cleanable/blood/gibs) in T)
						playsound(T, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
						make_cleanable(/obj/decal/cleanable/blood/gibs,T)
			/*reaction_obj(var/obj/O, var/volume)
				if(istype(O,/obj/item/parts/robot_parts/robot_frame))
					if (O.check_completion() && volume >= 20)
						O.replicant = 1
						O.overlays = null
						O.icon_state = "repli_suit"
						O.name = "Unfinished Replicant"
						for(var/mob/V in AIviewers(O, null)) V.show_message(text("<span class='alert'>The solution molds itself around [].</span>", O), 1)
					else
						for(var/mob/V in AIviewers(O, null)) V.show_message(text("<span class='alert'>The solution fails to cling to [].</span>", O), 1)*/


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
			var/remove_buff = 0
			value = 7
			stun_resist = 31

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_synaptizine", 4)
				..()

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_synaptizine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.drowsyness = max(M.drowsyness-5, 0)
				if(M.sleeping) M.sleeping = 0
				if (M.get_brain_damage() <= 90)
					if (prob(50)) M.take_brain_damage(-1 * mult)
				else M.take_brain_damage(-10 * mult) // Zine those synapses into not dying *yet*
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if( effect <= 1)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 3) M.emote(pick("groan","moan"))
					if (effect <= 8)
						M.take_toxin_damage(1 * mult)
				else if (severity == 2)
					if( effect <= 2)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> staggers and drools, their eyes crazed and bloodshot!</span>")
						M.dizziness += 8
						M.reagents.add_reagent("madness_toxin", rand(1,2) * mult)
					if (effect <= 15)
						M.take_toxin_damage(1 * mult)

		medical/omnizine // COGWERKS CHEM REVISION PROJECT. magic drug, ought to use plasma or something
			name = "omnizine"
			id = "omnizine"
			description = "Omnizine is a highly potent healing medication that can be used to treat a wide range of injuries."
			reagent_state = LIQUID
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 40
			addiction_prob = 1//5
			addiction_prob2 = 20
			addiction_min = 5
			depletion_rate = 0.2
			overdose = 30
			value = 22
			target_organs = list("brain", "left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")	//RN this is all the organs. Probably I'll remove some from this list later.

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom
				if(M.get_oxygen_deprivation())
					M.take_oxygen_deprivation(-1 * mult)
				if(M.get_toxin_damage())
					M.take_toxin_damage(-1 * mult)
				if(M.losebreath && prob(50))
					M.lose_breath(-1)
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
						M.visible_message("<span class='alert'><b>[M.name]</b> suddenly cluches their gut!</span>")
						M.emote("scream")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
					else if(effect <= 3)
						M.visible_message("<span class='alert'><b>[M.name]</b> completely spaces out for a moment.</span>")
						M.change_misstep_chance(15 * mult)
					else if(effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> stumbles and staggers.</span>")
						M.dizziness += 5
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
					else if(effect <= 7)
						M.visible_message("<span class='alert'><b>[M.name]</b> shakes uncontrollably.</span>")
						M.make_jittery(30)
				else if (severity == 2) // greater
					if(effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> suddenly cluches their gut!</span>")
						M.emote("scream")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 80 * mult))
					else if(effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> jerks bolt upright, then collapses!</span>")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 80 * mult))
					else if(effect <= 8)
						M.visible_message("<span class='alert'><b>[M.name]</b> stumbles and staggers.</span>")
						M.dizziness += 5
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))

		medical/saline // COGWERKS CHEM REVISION PROJECT. magic drug, ought to use plasma or something
			name = "saline-glucose solution"
			id = "saline"
			description = "This saline and glucose solution can help stabilize critically injured patients and cleanse wounds."
			reagent_state = LIQUID
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

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.getStatusDuration("radiation") && prob(80))
					M.changeStatus("radiation", -20 * mult, 1)

				M.take_toxin_damage(-0.5 * mult)
				M.HealDamage("All", 0, 0, 0.5 * mult)

				if (prob(33) && ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)
				..()
				return

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
			var/remove_buff = FALSE

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_smelling_salt", 5)
				return

			on_remove()
				if (remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_smelling_salt")
				return

			on_mob_life(var/mob/M, var/method=INGEST, var/mult = 1)
				if(!M)
					M = holder.my_atom
				if(holder.has_reagent("neurotoxin"))
					holder.remove_reagent("neurotoxin", 3 * mult)
				if(holder.has_reagent("capulettium"))
					holder.remove_reagent("capulettium", 3 * mult)
				if(holder.has_reagent("sulfonal"))
					holder.remove_reagent("sulfonal", 3 * mult)
				if(holder.has_reagent("ketamine"))
					holder.remove_reagent("ketamine", 3 * mult)
				if(holder.has_reagent("sodium_thiopental"))
					holder.remove_reagent("sodium_thiopental", 3 * mult)
				if(holder.has_reagent("pancuronium"))
					holder.remove_reagent("pancuronium", 3 * mult)


				if(method == INGEST)
					if (M.health < -5 && M.health > -30)
						M.HealDamage("All", 1 * mult, 1 * mult, 1 * mult)
				if(M.getStatusDuration("radiation") && prob(30))
					M.changeStatus("radiation", -20 * mult, 1)
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
					if (prob(50) && M.bioHolder.HasEffect("bad_eyesight"))
						M.bioHolder.RemoveEffect("bad_eyesight")
					if (prob(30) && M.bioHolder.HasEffect("blind"))
						M.bioHolder.RemoveEffect("blind")
					if (prob(30) && (M.get_ear_damage() && M.get_ear_damage() <= M.get_ear_damage_natural_healing_threshold()) && M.bioHolder.HasEffect("deaf") || M.ear_disability)
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
			var/remove_buff = 0
			value = 8 // 2c + 3c + 1c + 1c + 1c

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_haloperidol", -5)
				return

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_haloperidol")
				return

			on_mob_life(var/mob/living/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-50,0)
				if (M.druggy > 0)
					M.druggy -= 3
					M.druggy = max(0, M.druggy)
				if(holder.has_reagent("LSD"))
					holder.remove_reagent("LSD", 5 * mult)
				if(holder.has_reagent("psilocybin"))
					holder.remove_reagent("psilocybin", 5 * mult)
				if(holder.has_reagent("crank"))
					holder.remove_reagent("crank", 5 * mult)
				if(holder.has_reagent("bathsalts"))
					holder.remove_reagent("bathsalts", 5 * mult)
				if(holder.has_reagent("THC"))
					holder.remove_reagent("THC", 5 * mult)
				if(holder.has_reagent("space_drugs"))
					holder.remove_reagent("space_drugs", 5 * mult)
				if(holder.has_reagent("catdrugs"))
					holder.remove_reagent("catdrugs", 5 * mult)
				if(holder.has_reagent("methamphetamine"))
					holder.remove_reagent("methamphetamine", 5 * mult)
				if(holder.has_reagent("epinephrine"))
					holder.remove_reagent("epinephrine", 5 * mult)
				if(holder.has_reagent("ephedrine"))
					holder.remove_reagent("ephedrine", 5 * mult)
				if(holder.has_reagent("stimulants"))
					holder.remove_reagent("stimulants", 3 * mult)
				if(prob(5))
					for(var/datum/ailment_data/disease/virus in M.ailments)
						if(istype(virus.master,/datum/ailment/disease/space_madness) || istype(virus.master,/datum/ailment/disease/berserker))
							M.cure_disease(virus)
				if(prob(20)) M.take_brain_damage(1 * mult)
				if(prob(50)) M.drowsyness = max(M.drowsyness, 6)
				if(prob(10)) M.emote("drool")
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
			var/remove_buff = 0
			value = 17 // 5c + 5c + 4c + 1c + 1c + 1c
			stun_resist = 10

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_epinephrine", 3)
				..()

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_epinephrine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(7 * mult))
				if(prob(10))
					M.make_jittery(4)
				M.drowsyness = max(M.drowsyness-5, 0)
				if(M.sleeping && prob(5)) M.sleeping = 0
				if(M.get_brain_damage() && prob(5)) M.take_brain_damage(-1)
				if(holder.has_reagent("histamine"))
					holder.remove_reagent("histamine", 15 * mult)
				if(M.losebreath > 3)
					M.losebreath -= (1 * mult)
				if(M.get_oxygen_deprivation() > 35)
					M.take_oxygen_deprivation(-10 * mult)
				if(M.health < -10 && M.health > -65)
					if(M.get_toxin_damage())
						M.take_toxin_damage(-1 * mult)
					M.HealDamage("All", 1 * mult, 1 * mult, 1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if( effect <= 1)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 3) M.emote(pick("groan","moan"))
					if (effect <= 8) M.emote("collapse")
				else if (severity == 2)
					if( effect <= 2)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> staggers and drools, their eyes bloodshot!</span>")
						M.dizziness += 2
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
					if (effect <= 15) M.emote("collapse")

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
						M.visible_message("<span class='alert'>[M] coughs up a lot of blood!</span>")
						playsound(get_turf(M), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
						bleed(M, rand(5,10) * mult, 3 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'>[M] coughs up a little blood!</span>")
						playsound(get_turf(M), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
						bleed(M, rand(1,2) * mult, 1 * mult)
				else if (severity == 2) // greater
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M] is bleeding from [his_or_her(M)] very pores!</span>")
						bleed(M, rand(10,20) * mult, rand(1,3) * mult)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							var/list/gear_to_bloody = list(H.r_hand, H.l_hand, H.head, H.wear_mask, H.w_uniform, H.wear_suit, H.belt, H.gloves, H.glasses, H.shoes, H.wear_id, H.back)
							for (var/obj/item/check in gear_to_bloody)
								LAGCHECK(LAG_LOW)
								if (prob(40))
									check.add_blood(H)
							H.set_clothing_icon_dirty()
					else if (effect <= 4)
						M.visible_message("<span class='alert'>[M] coughs up a lot of blood!</span>")
						playsound(get_turf(M), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
						bleed(M, rand(5,10) * mult, 3 * mult)
					else if (effect <= 8)
						M.visible_message("<span class='alert'>[M] coughs up a little blood!</span>")
						playsound(get_turf(M), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
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

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (isliving(M))
					var/mob/living/H = M
					repair_bleeding_damage(H, 90, 1 * mult)
					if (prob(2))
						H.contract_disease(/datum/ailment/malady/bloodclot,null,null,1)
				..()
				return

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
						L.visible_message("<span class='alert'>[L] coughs up a little blood!</span>")
						playsound(get_turf(L), "sound/impact_sounds/Slimy_Splat_1.ogg", 30, 1)
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

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(holder.has_reagent("sugar"))
					holder.remove_reagent("sugar", 5 * mult)
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
				src = null
				if (!volume_passed)
					return

				if (method == TOUCH)
					M.HealDamage("All", 0, volume_passed)

					var/silent = 0
					if (paramslist && paramslist.len)
						if ("silent" in paramslist)
							silent = 1
					if (!silent)
						boutput(M, "<span class='notice'>The silver sulfadiazine soothes your burns.</span>")


					M.UpdateDamageIcon()
				else if (method == INGEST)
					boutput(M, "<span class='alert'>You feel sick...</span>")
					if (volume_passed > 0)
						M.take_toxin_damage(volume_passed/2)


		medical/mutadone // COGWERKS CHEM REVISION PROJECT. - marked for revision. Magic bullshit chem, ought to be related to mutagen somehow
			name = "mutadone"
			id = "mutadone"
			description = "Mutadone is an experimental bromide that can cure genetic abnomalities."
			reagent_state = SOLID
			fluid_r = 80
			fluid_g = 150
			fluid_b = 200
			transparency = 255
			value = 9 // 5 3 1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bioHolder && M.bioHolder.effects && M.bioHolder.effects.len) //One per cycle. We're having superpowered hellbastards and this is their kryptonite.
					var/datum/bioEffect/B = M.bioHolder.effects[pick(M.bioHolder.effects)]
					if (B && B.curable_by_mutadone)
						M.bioHolder.RemoveEffect(B.id)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				var/datum/plantgenes/DNA = P.plantgenes
				if (!prob(20) && P.growth > 5)
					P.growth -= 5
				if (DNA.growtime < 0 && prob(50))
					DNA.growtime++
				if (DNA.harvtime < 0 && prob(50))
					DNA.harvtime++
				if (DNA.harvests < 0 && prob(50))
					DNA.harvests++
				if (DNA.cropsize < 0 && prob(50))
					DNA.cropsize++
				if (DNA.potency < 0 && prob(50))
					DNA.potency++
				if (DNA.endurance < 0 && prob(50))
					DNA.endurance++

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
			addiction_prob = 1//25
			addiction_prob2 = 10
			addiction_min = 10
			value = 9 // 4c + 3c + 1c + 1c
			var/remove_buff = 0
			stun_resist = 15

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_ephedrine", 2)
				..()

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_ephedrine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(5 * mult))
				M.make_jittery(4)
				M.drowsyness = max(M.drowsyness-5, 0)
				if(M.losebreath > 3)
					M.losebreath = max(5, M.losebreath-(1 * mult))
				if(M.get_oxygen_deprivation() > 75)
					M.take_oxygen_deprivation(-1 * mult)
				if ((M.health < 0) || (M.health > 0 && prob(33)))
					if (M.get_toxin_damage() && prob(25))
						M.take_toxin_damage(-1 * mult)
					M.HealDamage("All", 1 * mult, 1 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if( effect <= 1)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 3) M.emote(pick("groan","moan"))
					if (effect <= 8)
						M.take_toxin_damage(1 * mult)
				else if (severity == 2)
					if( effect <= 2)
						M.visible_message("<span class='alert'>[M.name] suddenly and violently vomits!</span>")
						M.vomit()
					else if (effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> staggers and drools, their eyes bloodshot!</span>")
						M.dizziness += 8
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
					if (effect <= 15)
						M.take_toxin_damage(1 * mult)


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
				if (!M) M = holder.my_atom
				for (var/reagent_id in M.reagents.reagent_list)
					if (reagent_id != id)
						M.reagents.remove_reagent(reagent_id, 4 * mult)
				M.changeStatus("radiation", -70, 1)
				if (M.get_toxin_damage() && prob(75))
					M.take_toxin_damage(-4 * mult)
					M.HealDamage("All", 0, 0, 2 * mult)
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
			addiction_prob = 1//10
			addiction_min = 10
			var/remove_buff = 0
			value = 10 // 4 3 1 1 1

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_diphenhydramine", -3)
				return

			on_remove()
				if(remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_diphenhydramine")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness = max(M.jitteriness-20,0)
				if(holder.has_reagent("histamine"))
					holder.remove_reagent("histamine", 3 * mult)
				if(holder.has_reagent("itching"))
					holder.remove_reagent("itching", 3 * mult)
				if(prob(7)) M.emote("yawn")
				if(prob(3))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
					M.drowsyness++
					M.visible_message("<span class='notice'><b>[M.name]<b> looks a bit dazed.</span>")
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
				src = null
				if(!volume_passed)
					return
				if(!isliving(M)) // fucking human shitfucks
					return
				if(method == TOUCH)
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
					else
						repair_bleeding_damage(L, 5, 1)
						//H.bleeding = min(H.bleeding, rand(0,5))

					var/silent = 0
					if (paramslist && paramslist.len)
						if ("silent" in paramslist)
							silent = 1

					if (!silent)
						boutput(M, "<span class='notice'>The styptic powder stings like hell as it closes some of your wounds.</span>")
						M.emote("scream")
					M.UpdateDamageIcon()
				else if(method == INGEST)
					boutput(M, "<span class='alert'>You feel gross!</span>")
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
			target_organs = list("left_eye", "right_eye", "heart", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix")	//RN this is all the organs. Probably I'll remove some from this list later. no "brain",  either

			/*reaction_temperature(exposed_temperature, exposed_volume)
				var/myvol = volume

				if(exposed_temperature > T0C + 50) //Turns into omnizine. Derp.
					volume = 0
					holder.add_reagent("omnizine", myvol, null)

				return*/

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature < M.base_body_temp - 100)
					var/health_before = M.health

					if(M.get_oxygen_deprivation())
						M.take_oxygen_deprivation(-10 * mult)
					if(M.get_toxin_damage())
						M.take_toxin_damage(-3 * mult)
					if (M.get_brain_damage())
						M.take_brain_damage(-2 * mult)
					M.HealDamage("All", 12 * mult, 12 * mult)
					M.updatehealth() //I hate this, but we actually need the health on time here.
					if(M.health > health_before)
						var/increase = min((M.health - health_before)/37*25,25) //12+12+3+10 = 37 health healed possible, 25 max temp increase possible
						M.bodytemperature = min(M.bodytemperature+increase,M.base_body_temp)

					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.organHolder)
							H.organHolder.heal_organs(2*mult, 2*mult, 2*mult, target_organs)

				if(prob(25)) M.UpdateDamageIcon() // gonna leave this one on for now, but only call it a quarter of the time
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

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("atropine", -30)
					src.total_misstep = 0
				return

			on_remove()
				if(remove_buff)
					if(istype(holder) && istype(holder.my_atom))
						if (hascall(holder.my_atom,"remove_stam_mod_max"))
							holder.my_atom:remove_stam_mod_max("atropine")

					if (ismob(holder.my_atom))
						var/mob/M = holder.my_atom
						M.change_misstep_chance(-src.total_misstep)
				return

			on_mob_life(var/mob/M, var/mult = 1) //god fuck this proc
				if(!M) M = holder.my_atom
				M.make_dizzy(1 * mult)
				M.change_misstep_chance(5 * mult)
				src.total_misstep += 5 * mult
				if(M.bodytemperature < M.base_body_temp)
					M.bodytemperature = min(M.base_body_temp + 10, M.bodytemperature+(10 * mult))
				if(prob(4)) M.emote("collapse")
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
				if(M.reagents.has_reagent("sarin"))
					M.reagents.remove_reagent("sarin",20 * mult)
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
						if (H.organHolder && prob(40))
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
			addiction_prob = 1//20
			addiction_prob2 = 20
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
				for(var/reagent_id in M.reagents.reagent_list)
					if(reagent_id != id && prob(50)) // slow this down a bit
						M.reagents.remove_reagent(reagent_id, 1 * mult)
				M.take_toxin_damage(-1.5 * mult)
				M.HealDamage("All", 0, 0, 1 * mult)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder)
						H.organHolder.heal_organs(1*mult, 1*mult, 1*mult, target_organs)

				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
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

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(holder.has_reagent("ethanol")) holder.remove_reagent("ethanol", 8 * mult)
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
				if(prob(25))
					M.visible_message("<span class='alert'>[M] pukes all over \himself!</span>")
					M.vomit()
				if(prob(5))
					var/mob/living/L = M
					L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
				..()
				return
