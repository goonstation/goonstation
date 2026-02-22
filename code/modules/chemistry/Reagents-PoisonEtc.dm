//Contains reagents that are poisons or otherwise intended to be harmful

ABSTRACT_TYPE(/datum/reagent/harmful)
ABSTRACT_TYPE(/datum/reagent/harmful/simple_damage_toxin)
ABSTRACT_TYPE(/datum/reagent/harmful/simple_damage_burn)

datum
	reagent
		harmful/
			name = "dangerous stuff"
			viscosity = 0.16

		harmful/simple_damage_toxin
			name = "toxin precursor"
			id = "simple_damage_toxin"
			var/damage_factor = 1
			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(damage_factor * mult)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 3 * damage_factor

			nitrogen_dioxide
				name = "nitrogen dioxide"
				id = "nitrogen_dioxide"
				description = "A common, mildly toxic pollutant."
				reagent_state = GAS
				fluid_r = 128
				fluid_g = 32
				fluid_b = 32
				transparency = 120

		harmful/simple_damage_burn
			name = "irritant precursor"
			id = "simple_damage_burn"
			var/damage_factor = 1
			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.TakeDamage("chest", 0, damage_factor * mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 3 * damage_factor

		harmful/acid // COGWERKS CHEM REVISION PROJECT. give this a reaction and remove it from the dispenser machine, hydrogen (2) + sulfur (1) + oxygen (4)
			name = "sulfuric acid"
			id = "acid"
			description = "A strong mineral acid with the molecular formula H2SO4."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 255
			fluid_b = 50
			transparency = 20
			blob_damage = 1
			value = 3 // 1c + 1c + 1c
			var/melts_items = FALSE //!does this melt items? sulfuric acid doesn't since it smokes on reaction and that's Brutal

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				//M.take_toxin_damage(1)
				M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (M.nodamage)
					return .
				if (method == TOUCH)
					. = 0
					var/stack_mult = 1
					if(ON_COOLDOWN(M, "basic_acid_stack_check", 0.1 SECONDS))
						stack_mult = 0.5
					if (volume > 25)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.wear_mask)
								boutput(M, SPAN_ALERT("Your mask protects you from the acid!"))
								return
							if (H.head)
								boutput(M, SPAN_ALERT("Your helmet protects you from the acid!"))
								return

						if (prob(75))
							M.TakeDamage("head", 0, 10 * stack_mult, 0, DAMAGE_BURN)
							M.emote("scream")
							if(!M.disfigured)
								boutput(M, SPAN_ALERT("Your face has become disfigured!"))
								M.disfigured = TRUE
								M.UpdateName()
							M.unlock_medal("Red Hood", 1)
						else
							M.TakeDamage("All", 0, 10 * stack_mult, 0, DAMAGE_BURN)
					else

						M.TakeDamage("All", 0, min(5, volume * 0.5) * stack_mult, 0, DAMAGE_BURN)
				else
					boutput(M, SPAN_ALERT("The greenish acidic substance stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!"))
					if (volume >= 10)
						M.TakeDamage("All", 0, clamp((volume - 10) * 2, 4, 20), 0, DAMAGE_BURN)
						M.emote("scream")
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (!H.vdisfigured)
								boutput(H,SPAN_ALERT("Your vocal chords become scarred from ingesting acid!"))
								H.vdisfigured = TRUE

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/fluid))
					return 1
				if (istype(O,/obj/item/clothing/head/chemhood || /obj/item/clothing/suit/chemsuit))
					return 1
				if (isitem(O) && prob(40) && volume >= 10 && melts_items)
					var/obj/item/toMelt = O
					if (!(toMelt.item_function_flags & IMMUNE_TO_ACID))
						if(!O.hasStatus("acid"))
							O.changeStatus("acid", 5 SECONDS, list("leave_cleanable" = 1))
					else
						O.visible_message("The acidic substance slides off \the [O] harmlessly.")

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 5
				growth_tick.growth_rate -= 3

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (!blob_damage)
					return
				B.take_damage(blob_damage * min(volume, 10), 1, "mixed")

		harmful/acid/clacid
			name = "hydrochloric acid"
			id = "clacid"
			description = "A strong acid with the molecular formula HCl."
			fluid_r = 0
			fluid_g = 200
			fluid_b = 255
			blob_damage = 1.2
			melts_items = TRUE

		harmful/acid/nitric_acid
			name = "nitric acid"
			id = "nitric_acid"
			description = "A strong acid."
			fluid_r = 0
			fluid_g = 200
			fluid_b = 255
			blob_damage = 0.7
			melts_items = TRUE

		harmful/acetic_acid
			name = "acetic acid"
			id = "acetic_acid"
			description = "A weak acid that is the main component of vinegar and bad hangovers."
			fluid_r = 0
			fluid_g = 128
			fluid_b = 255
			transparency = 64
			reagent_state = LIQUID
			blob_damage = 0.2

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (M.nodamage)
					return .
				if (method == TOUCH)
					. = 0
					if (volume >= 50 && prob(75))
						M.TakeDamage("head", 0, 10, 0, DAMAGE_BURN)
						M.emote("scream")
						if(!M.disfigured)
							boutput(M, SPAN_ALERT("Your face has become disfigured!"))
							M.disfigured = TRUE
							M.UpdateName()
						M.unlock_medal("Red Hood", 1)
					else
						random_burn_damage(M, min(5, volume * 0.25))
				else
					boutput(M, SPAN_ALERT("The transparent acidic substance stings[volume < 25 ? " you, but isn't concentrated enough to harm you" : null]!"))
					if (volume >= 25)
						random_burn_damage(M, 2)
						M.emote("scream")

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 1

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (!blob_damage)
					return
				B.take_damage(blob_damage * min(volume, 10), 1, "mixed")

		harmful/amanitin
			name = "amanitin"
			id = "amanitin"
			description = "A toxin produced by certain mushrooms. Very deadly."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 50
			target_organs = list("liver", "left_kidney", "right_kidney")
			var/damage_counter = 0

			on_mob_life(mob/M, mult = 1)
				if (!M)
					M = holder.my_atom
				damage_counter += rand(2, 4) * mult * min(1, volume)
				..()
			on_remove()
				..()
				var/mob/living/carbon/human/M = holder.my_atom
				if (!istype(M)) return
				M.take_toxin_damage(damage_counter)
				logTheThing(LOG_COMBAT, M, "took [damage_counter] TOX damage from amanitin.")

				if (isliving(M))
					var/mob/living/target_mob = M
					target_mob.organHolder?.damage_organs(tox=damage_counter, organs=src.target_organs)

				damage_counter = 0


		harmful/chemilin
			name = "chemilin"
			id = "chemilin"
			description = "Discovered by A. S. Wonkington, on a friday the 13th, during lunch break. This cheese compound is unbelievably lethal."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 50
			random_chem_blacklisted = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(rand(10,30) * mult)
				if(probmult(30))
					var/atom/my_atom = holder.my_atom
					var/turf/location = 0
					if (my_atom)
						location = get_turf(my_atom)
						explosion(my_atom, location, 0, 1, 4, 5)
				..()

		harmful/coniine
			name = "coniine" // big brother to cyanide, very strong
			id = "coniine"
			description = "A neurotoxin that rapidly causes respiratory failure."
			reagent_state = LIQUID
			fluid_r = 125
			fluid_g = 195
			fluid_b = 160
			transparency = 80
			depletion_rate = 0.05
			target_organs = list("left_lung", "right_lung")

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(2 * mult)
				M.losebreath += 5 * mult
				if (isliving(M))
					var/mob/living/target_mob = M
					target_mob.organHolder?.damage_organs(tox=2*mult, organs=target_organs)
				..()
				return

		harmful/cyanide
			name = "cyanide"
			id = "cyanide"
			fluid_r = 0
			fluid_b = 180
			fluid_g = 25
			transparency = 10
			description = "A highly toxic chemical with some uses as a building block for other things."
			reagent_state = LIQUID
			transparency = 0
			depletion_rate = 0.1
			penetrates_skin = 1
			blob_damage = 5
			value = 7 // 3 2 1 heat
			var/counter = 1

			on_mob_life(var/mob/M, var/mult = 1) // -cogwerks. previous version
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				M.take_toxin_damage(1.5 * mult)
				if (probmult(8))
					M.emote("drool")
				if (prob(15))
					boutput(M, SPAN_ALERT("You cannot breathe!"))
					M.losebreath += (1 * mult)
					M.emote("gasp")
				switch(counter += (1 * mult))
					if (20 to 30)
						if (prob(15))
							boutput(M, SPAN_ALERT("You feel weak."))
							M.setStatusMin("stunned", 0.5 SECONDS * mult)
							M.take_toxin_damage(0.5 * mult)
					if (30 to 45)
						if (prob(20))
							boutput(M, SPAN_ALERT("You feel very weak."))
							M.setStatusMin("stunned", 1 SECONDS * mult)
							M.take_toxin_damage(1 * mult)
					if (45 to INFINITY)
						if (prob(25))
							boutput(M, SPAN_ALERT("You feel horribly weak."))
							M.setStatusMin("stunned", 2 SECONDS * mult)
							M.take_toxin_damage(1.5 * mult)

				..()
				return


		harmful/curare
			name = "curare"
			id = "curare"
			description = "A highly dangerous paralytic poison."
			fluid_r = 25
			fluid_g = 25
			fluid_b = 25
			reagent_state = SOLID
			transparency = 255
			depletion_rate = 0.2
			var/counter = 1
			penetrates_skin = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				M.take_toxin_damage(1 * mult)
				M.take_oxygen_deprivation(1 * mult)
				switch(counter += (1 * mult))
					if (1 to 5)
						if (prob(20) && !M.stat)
							M.emote(pick("drool", "pale", "gasp"))
					if (6 to 10)
						M.change_eye_blurry(5, 5)
						if (prob(8))
							boutput(M, SPAN_ALERT("<b>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</b>"))
							M.setStatusMin("stunned", 2 SECONDS * mult)
						else if (probmult(8))
							M.emote(pick("drool","pale", "gasp"))
					if (11 to INFINITY)
						M.setStatusMin("paralysis", 4 SECONDS * mult)
						M.setStatus("drowsy", 40 SECONDS)
						if (probmult(20) && !M.stat)
							M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
						else if (prob(8))
							boutput(M, SPAN_ALERT("<b>You can't [pick("breathe", "move", "feel your legs", "feel your face", "feel anything")]!</b>"))
							M.losebreath += (1 * mult)

				..()
				return

		harmful/ricin
			name = "space ricin"
			id = "ricin"
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			description = "Extremely toxic, but slow acting, stealthy, and hard to cure agent that causes organ failure."
			depletion_rate = 0.025
			penetrates_skin = 0
			target_organs = list("left_kidney","right_kidney","liver","stomach","intestines","spleen","pancreas")
			flushing_multiplier = 0.15
			var/counter = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				counter += (1 * mult)
				if (counter < 175)
					M.remove_vomit_behavior(/datum/vomit_behavior/blood)
				switch(counter)
					if (75 to 125)
						if(isliving(M) && probmult(15))
							var/mob/living/L = M
							L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.organHolder)
								H.organHolder.damage_organs(1*mult, 0, 1*mult, target_organs, 15)
					if (125 to 175)
						if (probmult(8))
							M.emote(pick("sneeze","cough","moan","groan"))
						else if (probmult(5))
							boutput(M, SPAN_ALERT("You feel weak and tired."))
							M.setStatus("drowsy", 4 SECONDS)
							M.change_eye_blurry(5, 5)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.organHolder)
								H.organHolder.damage_organs(1*mult, 0, 1*mult, target_organs, 25)
					if (175 to INFINITY)
						M.add_vomit_behavior(/datum/vomit_behavior/blood)
						if (probmult(10))
							M.emote(pick("sneeze","drool","cough","moan","groan"))
						if (probmult(20))
							boutput(M, SPAN_ALERT("You feel weak and drowsy."))
							M.setStatus("slowed", 5 SECONDS)
						if (probmult(20))
							M.nauseate(1)
						else if (probmult(5))
							boutput(M, SPAN_ALERT("You feel a sudden pain in your chest."))
							M.setStatusMin("stunned", 6 SECONDS * mult)
							M.take_toxin_damage(3)
						M.change_eye_blurry(5, 5)
						M.setStatus("drowsy", 10 SECONDS)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.organHolder)
								H.organHolder.damage_organs(1*mult, 0, 1*mult, target_organs, 50)
				..()
				return

		harmful/formaldehyde
			name = "embalming fluid"
			id = "formaldehyde"
			description = "Formaldehyde is a common industrial chemical and is used to preserve corpses and medical samples. It is highly toxic and irritating. Casualdehyde is the less invasive form of this chemical."
			reagent_state = LIQUID
			fluid_r = 180
			fluid_b = 0
			fluid_g = 75
			transparency = 20
			penetrates_skin = 1
			touch_modifier = 0.5

			value = 4 // 1 1 1 heat

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				if (prob(10))
					M.reagents.add_reagent("histamine", randfloat(12.5 , 37.5) * src.calculate_depletion_rate(M, mult))
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 4

		harmful/acetaldehyde
			name = "acetaldehyde"
			id = "acetaldehyde"
			description = "Acetaldehyde is a common industrial chemical. It is a severe irritant."
			reagent_state = LIQUID
			fluid_r = 180
			fluid_b = 0
			fluid_g = 75
			transparency = 20
			penetrates_skin = 1
			value = 4
			depletion_rate = 0.6
			touch_modifier = 0.33

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.TakeDamage("All", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 4

		harmful/lipolicide
			name = "lipolicide"
			id = "lipolicide"
			description = "A compound found in many seedy dollar stores in the form of a weight-loss tonic."
			fluid_r = 240
			fluid_g = 255
			fluid_b = 240
			transparency = 215
			depletion_rate = 0.2
			target_organs = list("stomach")

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (!M.nutrition && probmult(60))
					switch(rand(1,2))
						if (1)
							boutput(M, SPAN_ALERT("You feel hungry..."))
						if (2)
							M.take_toxin_damage(1 * mult)
							boutput(M, SPAN_ALERT("Your stomach grumbles painfully!"))
							if (isliving(M))
								var/mob/living/target_mob = M
								target_mob.organHolder?.damage_organs(tox=mult, organs=src.target_organs)

				else if (probmult(60))
					var/fat_to_burn = max(round(M.nutrition/100,1) * mult, 5)
					M.nutrition = max(M.nutrition-fat_to_burn,0)
				..()
				return

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (istype(B, /obj/blob/lipid))
					B.take_damage(B.health_max, 2, "chaos")

		harmful/initropidril
			name = "initropidril"
			id = "initropidril"
			description = "A highly potent cardiac poison - can kill within minutes."
			reagent_state = LIQUID
			fluid_r = 127
			fluid_g = 16
			fluid_b = 192
			transparency = 255
			threshold = THRESHOLD_INIT
			target_organs = list("heart")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_initropidril", 33)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_initropidril")
				..()

			on_mob_life(var/mob/living/M, var/mult = 1)

				if (!M) M = holder.my_atom
				if (probmult(33))
					M.take_toxin_damage(rand(5,25) * mult)
					if (isliving(M))
						var/mob/living/target_mob = M
						target_mob.organHolder?.damage_organs(tox=5*mult, organs=target_organs)
				if (probmult(33))
					boutput(M, SPAN_ALERT("You feel horribly weak."))
					M.setStatusMin("stunned", 3 SECONDS * mult)
				if (probmult(10))
					boutput(M, SPAN_ALERT("You cannot breathe!"))
					M.take_oxygen_deprivation(10 * mult)
					M.losebreath += (1 * mult)
				if (probmult(10))
					boutput(M, SPAN_ALERT("Your chest is burning with pain!"))
					M.take_oxygen_deprivation(10 * mult)
					M.losebreath += (1 * mult)
					M.setStatusMin("knockdown", 4 SECONDS * mult)
					M.contract_disease(/datum/ailment/malady/flatline, null, null, 1) // path, name, strain, bypass resist
				..()

		harmful/initrobeedril_old
			name = "old initrobeedril"
			id = "initrobeedril_old"
			description = "A highly experimental poison originally created by a mad scientist by the name of \"SpyGuy\" on earth in 2014."
			reagent_state = LIQUID
			fluid_r = 127
			fluid_g = 190
			fluid_b = 5
			transparency = 255
			depletion_rate = 0.1 //per 3 sec
			var/ticks = 0

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				ticks += mult

				var/col = min(ticks * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1 * mult)

				switch(ticks)
					if (1 to 8)
						if (prob(33))
							boutput(M, SPAN_ALERT("You feel weak."))
							M.setStatusMin("stunned", 2 SECONDS * mult)
					if (9 to 30)
						if (prob(33))
							boutput(M, SPAN_ALERT("<I>You feel very weak.</I>"))
							M.setStatusMin("stunned", 3 SECONDS * mult)
						if (prob(10))
							boutput(M, SPAN_ALERT("<I>You have trouble breathing!</I>"))
							M.take_oxygen_deprivation(2 * mult)
							M.losebreath += (1 * mult)
					if (31 to 50)
						if (prob(33))
							boutput(M, SPAN_ALERT("<B>You feel horribly weak.</B>"))
							M.setStatusMin("stunned", 4 SECONDS * mult)
						if (prob(10))
							boutput(M, SPAN_ALERT("<B>You cannot breathe!</B>"))
							M.take_oxygen_deprivation(2 * mult)
							M.losebreath += (1 * mult)
						if (prob(10))
							boutput(M, SPAN_ALERT("<B>Your heart flutters in your chest!</B>"))
							M.take_oxygen_deprivation(5 * mult)
							M.losebreath += (1 * mult)
							M.setStatusMin("knockdown", 5 SECONDS * mult)
					if (51 to INFINITY) //everything after
						var/obj/critter/domestic_bee/B = new/obj/critter/domestic_bee(M.loc)
						B.name = M.real_name
						B.desc = "This bee looks very much like [M.real_name]. How peculiar."
						B.beeKid = "#ffdddd"
						B.UpdateIcon()
						logTheThing(LOG_COMBAT, M, "was gibbed by reagent [name].")
						M.gib()
				..()

			on_remove()
				if (holder.my_atom)
					holder.my_atom.color = "#ffffff"
				return ..()

		harmful/initrobeedril // an attempt to tie noheart to this as per SpyGuy's request
			name = "initrobeedril"
			id = "initrobeedril"
			description = "A highly experimental poison originally created by a mad scientist by the name of \"SpyGuy\" on earth in 2014."
			reagent_state = LIQUID
			fluid_r = 127
			fluid_g = 190
			fluid_b = 5
			transparency = 255
			depletion_rate = 0.2
			var/ticks = 0

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				ticks += mult

				var/col = min(ticks * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder && H.organHolder.heart) // you can't barf up a bee heart if you ain't got no heart to barf
						switch (ticks)
							if (1 to 4)
								if (prob(33))
									boutput(H, SPAN_ALERT("You feel weak."))
									M.setStatusMin("stunned", 2 SECONDS * mult)
							if (5 to 15)
								if (prob(33))
									boutput(H, SPAN_ALERT("<I>You feel very weak.</I>"))
									M.setStatusMin("stunned", 3 SECONDS * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<I>You have trouble breathing!</I>"))
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
							if (16 to 25)
								if (prob(33))
									boutput(H, SPAN_ALERT("<B>You feel horribly weak.</B>"))
									M.setStatusMin("stunned", 4 SECONDS * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<B>You cannot breathe!</B>"))
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<B>Your heart flutters in your chest!</B>"))
									H.take_oxygen_deprivation(5 * mult)
									H.losebreath += (1 * mult)
									M.setStatusMin("knockdown", 5 SECONDS * mult)
							if (26 to INFINITY)

								var/obj/critter/domestic_bee/B

								if (H.organHolder.heart.robotic)
									B = new/obj/critter/domestic_bee/buddy(H.loc)
									REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, "heart")
									H.remove_stam_mod_max("heart")

								else
									B = new/obj/critter/domestic_bee(H.loc)

								B.name = "[H.real_name]’s heart"
								B.desc = "[H.real_name]'s heart is flying off. Better catch it quick!"
								B.beeMom = H
								B.beeKid = DEFAULT_BLOOD_COLOR
								B.UpdateIcon()

								playsound(H.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
								take_bleeding_damage(H, null, rand(10,30) * mult, DAMAGE_STAB)
								H.visible_message(SPAN_ALERT("<B>A bee bursts out of [H]'s chest! Oh fuck!</B>"), \
								SPAN_ALERT("<b>A bee bursts out of your chest! OH FUCK!</b>"))
								qdel(H.organHolder.heart)
				..()

			on_remove()
				if (holder.my_atom)
					holder.my_atom.color = "#ffffff"
				return ..()

		harmful/royal_initrobeedril // yep
			name = "royal initrobeedril"
			id = "royal_initrobeedril"
			description = "A highly experimental poison originally created by a mad scientist by the name of \"SpyGuy\" on earth in 2014."
			reagent_state = LIQUID
			fluid_r = 102
			fluid_g = 0
			fluid_b = 255
			transparency = 255
			depletion_rate = 0.2
			var/ticks = 0

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				ticks += mult

				var/col = min(ticks * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1 * mult)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder && H.organHolder.heart) // you can't barf up a bee heart if you ain't got no heart to barf
						switch(ticks)
							if (1 to 4)
								if (prob(33))
									boutput(H, SPAN_ALERT("You feel weak."))
									M.setStatusMin("knockdown", 2 SECONDS * mult)
							if (5 to 15)
								if (prob(33))
									boutput(H, SPAN_ALERT("<I>You feel very weak.</I>"))
									M.setStatusMin("knockdown", 3 SECONDS * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<I>You have trouble breathing!</I>"))
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
							if (16 to 25)
								if (prob(33))
									boutput(H, SPAN_ALERT("<B>You feel horribly weak.</B>"))
									M.setStatusMin("knockdown", 4 SECONDS * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<B>You cannot breathe!</B>"))
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
								if (prob(10))
									boutput(H, SPAN_ALERT("<B>Your heart flutters in your chest!</B>"))
									H.take_oxygen_deprivation(5 * mult)
									H.losebreath += (1 * mult)
									M.setStatusMin("knockdown", 5 SECONDS * mult)
							if (26 to INFINITY)

								var/obj/critter/domestic_bee/queen/B

								if (H.organHolder.heart.robotic)
									B = new/obj/critter/domestic_bee/queen/buddy(H.loc)

								else if (prob(5))
									B = new/obj/critter/domestic_bee/queen/big(H.loc)

								else
									B = new/obj/critter/domestic_bee/queen(H.loc)

								B.name = "[H.real_name]’s heart"
								B.desc = "[H.real_name]'s heart is flying off. What kind of heart problems did they have!?"
								B.beeMom = H
								B.beeKid = DEFAULT_BLOOD_COLOR
								B.UpdateIcon()

								playsound(H.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
								bleed(H, 500, 5) // you'll be gibbed in a moment you don't need it anyway
								H.visible_message(SPAN_ALERT("<B>A huge bee bursts out of [H]! OH FUCK!</B>"))
								qdel(H.organHolder.heart)
								logTheThing(LOG_COMBAT, H, "was gibbed by reagent [name].")
								H.gib()
				..()

			on_remove()
				if (holder.my_atom)
					holder.my_atom.color = "#ffffff"
				return ..()

		harmful/hyper_vomitium // vomit your heart out
			name = "hyper vomitium"
			id = "hyper_vomitium"
			description = "A highly potent variant of space ipecac, sufficient to make someone vomit out everything in them. Literally."
			reagent_state = LIQUID
			fluid_r = 2
			fluid_g = 50
			fluid_b = 25
			transparency = 200
			depletion_rate = 0.2
			/// how much cycles this has been in the target's system.
			var/cycles = 0

			on_mob_life(var/mob/M, var/mult = 1)
				src.cycles += mult
				M.nauseate(rand(2,5))
				..()

			on_add()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.add_vomit_behavior(/datum/vomit_behavior/hyper)

			on_remove()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.remove_vomit_behavior(/datum/vomit_behavior/hyper)

		harmful/cholesterol
			name = "cholesterol"
			id = "cholesterol"
			description = "Pure cholesterol. Probably not very good for you."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 250
			fluid_b = 200
			transparency = 255
			threshold = THRESHOLD_INIT
			target_organs = list("spleen", "heart")

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("r_cholesterol", -10)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("r_cholesterol")
				..()

			on_mob_life(var/mob/living/M, var/mult = 1)

				if (!M) M = holder.my_atom
				//if (prob(5)) // this is way too annoying and ruins fried foods
					//boutput(M, SPAN_ALERT("You feel [pick(")weak","shaky","ill")]!")
					//M.stunned ++
				else if (holder.get_reagent_amount(src.id) >= 25 && prob(holder.get_reagent_amount(src.id)*0.15))
					boutput(M, SPAN_ALERT("Your chest feels [pick("weird","uncomfortable","nasty","gross","odd","unusual","warm")]!"))
					M.take_toxin_damage(rand(1,2) * mult)
					if (isliving(M))
						var/mob/living/target_mob = M
						target_mob.organHolder?.damage_organs(tox=rand(1,2)*mult, organs=src.target_organs)
					if (probmult(1))
						switch(rand(1,2))
							if(1)
								M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1)
							if(2)
								M.contract_disease(/datum/ailment/malady/bloodclot, null, null, 1)
				else if (holder.get_reagent_amount(src.id) >= 45 && prob(holder.get_reagent_amount(src.id)*0.08))
					boutput(M, SPAN_ALERT("Your chest [pick("hurts","stings","aches","burns")]!"))
					M.take_toxin_damage(rand(2,4) * mult)
					if (isliving(M))
						var/mob/living/target_mob = M
						target_mob.organHolder?.damage_organs(tox=rand(2,4)*mult, organs=src.target_organs)
					M.setStatusMin("stunned", 2 SECONDS * mult)
					if (probmult(5))
						switch(rand(1,2))
							if(1)
								M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1)
							if(2)
								M.contract_disease(/datum/ailment/malady/bloodclot, null, null, 1)
				else if (holder.get_reagent_amount(src.id) >= 150 && prob(holder.get_reagent_amount(src.id)*0.01))
					boutput(M, SPAN_ALERT("Your chest is burning with pain!"))
					//M.losebreath += (1 * mult) //heartfailure handles this just fine
					M.setStatusMin("knockdown", 3 SECONDS * mult)
					M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1) // path, name, strain, bypass resist
				..()

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (B.type == /obj/blob)
					var/obj/blob/lipid/L = new /obj/blob/lipid(B.loc)
					L.setOvermind(B.overmind)
					qdel(B)

		harmful/itching
			name = "itching powder"
			id = "itching"
			description = "An abrasive powder beloved by cruel pranksters."
			reagent_state = SOLID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 100
			depletion_rate = 0.3
			penetrates_skin = 1

			on_mob_life(var/mob/M, var/mult = 1) // commence the tickling
				if (!M) M = holder.my_atom
				if (probmult(25)) M.emote(pick("twitch", "laugh", "sneeze", "cry"))
				if (probmult(20))
					boutput(M, SPAN_NOTICE("<b>Something tickles!</b>"))
					M.emote(pick("laugh", "giggle"))
				if (prob(15))
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> scratches at an itch."))
					random_brute_damage(M, 1 * mult)
					M.setStatusMin("stunned", 2 SECONDS * mult)
					M.emote("grumble")
				if (prob(10))
					boutput(M, SPAN_ALERT("<b>So itchy!</b>"))
					random_brute_damage(M, 2 * mult)
				if (prob(6))
					M.reagents.add_reagent("histamine", randfloat(11 , 33.4) * src.calculate_depletion_rate(M, mult))
				if (prob(2))
					boutput(M, SPAN_ALERT("<b><font size='[rand(2,5)]'>AHHHHHH!</font></b>"))
					random_brute_damage(M,5 * mult)
					M.setStatusMin("knockdown", 6 SECONDS * mult)
					M.make_jittery(6)
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> falls to the floor, scratching themselves violently!"))
				..()
				return

		harmful/pacid // COGWERKS CHEM REVISION PROJECT.. Change this to Fluorosulfuric Acid
			name = "fluorosulfuric acid"
			id = "pacid"
			description = "Fluorosulfuric acid is a an extremely corrosive super-acid."
			reagent_state = LIQUID
			fluid_r = 80
			fluid_g = 80
			fluid_b = 255
			transparency = 40
			dispersal = 1
			blob_damage = 4

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(method == TOUCH)
					. = 0
				if (method == TOUCH && raw_volume >= 10)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/blocked = 0
						if (!H.wear_mask && !H.head)
							H.TakeDamage("head", 0, clamp((raw_volume - 5) * 2, 8, 50), 0, DAMAGE_BURN)
							H.emote("scream")
							if(!H.disfigured)
								boutput(H, SPAN_ALERT("Your face has become disfigured!"))
								H.disfigured = TRUE
								H.UpdateName()
							H.unlock_medal("Red Hood", 1)
							return
						else
							if (H.head)
								var/obj/item/clothing/head/D = H.head
								if (!(D.item_function_flags & IMMUNE_TO_ACID) && D.getProperty("chemprot") <= raw_volume * 2)
									if(!D.hasStatus("acid"))
										boutput(M, SPAN_ALERT("Your [H.head] begins to melt!"))
										D.changeStatus("acid", 5 SECONDS, list("mob_owner" = M))
								else
									H.visible_message("<span class='alert>The blueish acidic substance slides off \the [D] harmlessly.</span>", SPAN_ALERT("Your [H.head] protects you from the acid!"))
								blocked = 1
							if (!(H.head?.c_flags & SPACEWEAR) || !(H.head?.item_function_flags & IMMUNE_TO_ACID))
								if (H.wear_mask)
									var/obj/item/clothing/mask/K = H.wear_mask
									if (!(K.item_function_flags & IMMUNE_TO_ACID) && K.getProperty("chemprot") <= raw_volume * 2)
										if(!K.hasStatus("acid"))
											boutput(M, SPAN_ALERT("Your [H.wear_mask] begins to melt away!"))
											K.changeStatus("acid", 5 SECONDS, list("mob_owner" = M))
									else
										H.visible_message(SPAN_ALERT("The blueish acidic substance slides off \the [K] harmlessly."), SPAN_ALERT("Your [H.wear_mask] protects you from the acid!"))
									blocked = 1

							if (blocked)
								return
					else
						random_brute_damage(M, min(15,volume))
				else if (volume >= 5)
					M.emote("scream")
					M.TakeDamage("All", 0, clamp((volume - 5) * 2, 8, 75), 0, DAMAGE_BURN)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (!H.vdisfigured)
							boutput(H,SPAN_ALERT("Your vocal chords become scarred from ingesting acid!"))
							H.vdisfigured = TRUE

				boutput(M, SPAN_ALERT("The blueish acidic substance stings[volume < 5 ? " you, but isn't concentrated enough to harm you" : null]!"))
				return

			reaction_obj(var/obj/O, var/volume)
				var/list/covered = holder.covered_turf()
				if (length(covered) > 16)
					volume = (volume/covered.len)

				if (istype(O,/obj/fluid))
					return 1
				if (isitem(O) && volume > O:w_class)
					var/obj/item/toMelt = O
					if (!(toMelt.item_function_flags & IMMUNE_TO_ACID))
						if(!O.hasStatus("acid"))
							O.changeStatus("acid", 5 SECONDS, list("leave_cleanable" = 1))
					else
						O.visible_message("The blueish acidic substance slides off \the [O] harmlessly.")

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 10
				growth_tick.growth_rate -= 5

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (!blob_damage)
					return
				B.take_damage(blob_damage * min(volume, 10), 1, "mixed")

		harmful/tene
			name = "aqua tenebrae"
			id = "tene"
			description = "A highly-caustic fluid comprised of several unknown acids, found in abundance in the seas of X-13."
			reagent_state = LIQUID
			fluid_r = 80
			fluid_g = 60
			fluid_b = 255
			dispersal = 1
			blob_damage = 2
			viscosity = 0.25

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if(!ischangeling(M))
					M.take_toxin_damage(1 * mult)
					M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/paramslist = 0, var/raw_volume)
				. = ..()
				if(method == TOUCH)
					. = 0
				var/datum/reagents/fluid_group/wildwetride = src.holder
				if(istype(wildwetride)) //applied by a fluid body, so we can keep it "simpleish"
					var/mob/living/carbon/human/H
					var/blocked = FALSE

					//if fluid touch chemloop exists, eliminate this cooldown and pass apply_decay the mult-adjusted time spent in acid
					if(ON_COOLDOWN(M, "corrode_a_homie", 1 SECOND))
						return

					if(ishuman(M))
						H = M
						var/obj/item/clothing/head/headgear = H.head
						var/obj/item/clothing/suit/suitgear = H.wear_suit

						//check for sealed protection
						if(headgear && suitgear)
							if(headgear.item_function_flags & IMMUNE_TO_ACID && suitgear.item_function_flags & IMMUNE_TO_ACID)
								return
							else if(headgear.c_flags & SPACEWEAR && suitgear.c_flags & SPACEWEAR) //full seal
								blocked = TRUE

						//apply decay if item isn't acid-immune and is yielding chemprot protection or full seal protection
						if(headgear && (blocked || headgear.getProperty("chemprot") > 0))
							var/datum/component/gear_corrosion/hcorroder = headgear.LoadComponent(/datum/component/gear_corrosion)
							hcorroder.apply_decay()
						if(suitgear && (blocked || suitgear.getProperty("chemprot") > 0))
							var/datum/component/gear_corrosion/scorroder = suitgear.LoadComponent(/datum/component/gear_corrosion)
							scorroder.apply_decay()

					if(blocked)
						return

					var/damage2deal = clamp(volume / 6, 0, 10)

					//var for message and emote, apply cooldown to this to make screams less often
					var/do_an_ouch = TRUE

					damage2deal = round(damage2deal)

					//changelings don't take damage, but they do get a bit liquefied if they're wandering around
					if(H && ischangeling(H))
						if(damage2deal >= 5 && !H.disfigured && !H.wear_mask && !H.head)
							boutput(H, SPAN_ALERT("The acid withers our visage."))
							H.disfigured = TRUE
							H.UpdateName()
						return

					if(damage2deal >= 5) //scream and face melty
						if(H)
							if(do_an_ouch)
								H.emote("scream")
							if (!H.wear_mask && !H.head)
								if(!H.disfigured)
									boutput(H, SPAN_ALERT("Your face has become disfigured!"))
									H.disfigured = TRUE
									H.UpdateName()
									H.unlock_medal("Red Hood", 1)
					else //just a gasp of pain
						if(H && do_an_ouch && damage2deal)
							H.emote("gasp")
					if(damage2deal)
						random_burn_damage(M, damage2deal)
						if(do_an_ouch)
							boutput(M, SPAN_ALERT("The blueish acidic substance burns!"))
				else //applied by a beaker splash
					if (method == TOUCH && volume >= 30)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							var/blocked = FALSE
							if (!H.wear_mask && !H.head)
								if(ischangeling(H)) //disfigures you, but doesn't harm you. make sure to scream to play along
									if(!H.disfigured)
										boutput(H, SPAN_ALERT("The acid withers our visage."))
										H.disfigured = TRUE
										H.UpdateName()
									return
								H.TakeDamage("head", 0, clamp((volume - 5), 8, 50), 0, DAMAGE_BURN)
								H.emote("scream")
								if(!H.disfigured)
									boutput(H, SPAN_ALERT("Your face has become disfigured!"))
									H.disfigured = TRUE
									H.UpdateName()
								H.unlock_medal("Red Hood", 1)
								return
							else
								if (H.head)
									var/obj/item/clothing/head/D = H.head
									if (!(D.item_function_flags & IMMUNE_TO_ACID))
										if(!D.hasStatus("acid"))
											boutput(M, SPAN_ALERT("Your [H.head] begins to melt!"))
											D.changeStatus("acid", 5 SECONDS, list("mob_owner" = M))
									else
										H.visible_message("<span class='alert>The blueish acidic substance slides off \the [D] harmlessly.</span>", SPAN_ALERT("Your [H.head] protects you from the acid!"))
									blocked = TRUE
								if (!(H.head?.c_flags & SPACEWEAR) || !(H.head?.item_function_flags & IMMUNE_TO_ACID))
									if (H.wear_mask)
										var/obj/item/clothing/mask/K = H.wear_mask
										if (!(K.item_function_flags & IMMUNE_TO_ACID))
											if(!K.hasStatus("acid"))
												boutput(M, SPAN_ALERT("Your [H.wear_mask] begins to melt away!"))
												K.changeStatus("acid", 5 SECONDS, list("mob_owner" = M))
										else
											H.visible_message(SPAN_ALERT("The blueish acidic substance slides off \the [K] harmlessly."), SPAN_ALERT("Your [H.wear_mask] protects you from the acid!"))
										blocked = TRUE

								if (blocked)
									return
						else if(!ischangeling(M))
							random_brute_damage(M, min(15,volume))
					else if (volume >= 6 && !ischangeling(M))
						M.emote("scream")
						M.TakeDamage("All", 0, volume / 6, 0, DAMAGE_BURN)
					boutput(M, SPAN_ALERT("The blueish acidic substance stings[volume < 6 ? " you, but isn't concentrated enough to harm you" : null]!"))

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.acid_damage += 8
				growth_tick.growth_rate -= 4

			reaction_blob(var/obj/blob/B, var/volume)
				. = ..()
				if (!blob_damage)
					return
				B.take_damage(blob_damage * min(volume, 10), 1, "mixed")

			reaction_obj(obj/item/clothing/item)
				if (istype(item) && !(item.item_function_flags & IMMUNE_TO_ACID))
					var/datum/component/gear_corrosion/corroder = item.LoadComponent(/datum/component/gear_corrosion)
					corroder.apply_decay()


		harmful/pancuronium
			name = "pancuronium"
			id = "pancuronium"
			description = "Pancuronium bromide is a powerful skeletal muscle relaxant."
			reagent_state = LIQUID
			fluid_r = 45
			fluid_g = 80
			fluid_b = 150
			transparency = 50
			depletion_rate = 0.2
			var/counter = 1
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("r_pancuronium", -30)
					..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("r_pancuronium")
					..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (3 to 9)
						if (probmult(10))
							M.emote(pick("drool", "tremble"))
					if (9 to 18)
						if (prob(4))
							boutput(M, SPAN_ALERT("<b>You feel [pick("weak", "like you can barely move", "tingly")].</b>"))
							M.setStatusMin("slowed", 2 SECONDS * mult)
						else if (prob(4))
							boutput(M, SPAN_ALERT("<b>You feel [pick("horribly weak", "numb")].</b>"))
							M.setStatusMin("stunned", 1 SECOND * mult)
						else if (probmult(8))
							M.emote(pick("drool", "tremble"))
					if (18 to INFINITY)
						M.setStatusMin("knockdown", 20 SECONDS * mult)
						if (prob(10))
							M.emote(pick("drool", "tremble", "gasp"))
							M.losebreath += (1 * mult)
						if (prob(9))
							boutput(M, SPAN_ALERT("<b>You can't [pick("move", "feel your legs", "feel your face", "feel anything")]!</b>"))
						if (prob(7))
							boutput(M, SPAN_ALERT("<b>You can't breathe!</b>"))
							M.losebreath+=(3 * mult)
				..()
				return

		harmful/polonium
			name = "polonium"
			id = "polonium"
			description = "Polonium is a rare and highly radioactive silvery metal."
			reagent_state = SOLID
			fluid_r = 120
			fluid_g = 120
			fluid_b = 120
			transparency = 255
			depletion_rate = 0.1
			penetrates_skin = 1
			blob_damage = 3

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_radiation_dose(0.125 SIEVERTS * mult, internal=TRUE)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.radiation_damage += 4
				growth_tick.mutation_severity += 0.25

		harmful/sodium_thiopental // COGWERKS CHEM REVISION PROJECT. idk some sort of potent opiate or sedative. chloral hydrate? ketamine
			name = "sodium thiopental"
			id = "sodium_thiopental"
			description = "An rapidly-acting barbituate tranquilizer."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 150
			fluid_b = 250
			transparency = 20
			depletion_rate = 0.7
			var/counter = 1
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("r_sodium_thiopental", -30)
					..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("r_sodium_thiopental")
					..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1

				switch(counter+= (1 * mult))
					if (1)
						M.emote("drool")
						M.change_misstep_chance(5 * mult)
					if (2 to 4)
						M.changeStatus("drowsy", 1 MINUTE)
					if (5)
						M.emote("faint")
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					if (6 to INFINITY)
						M.setStatusMin("unconscious", 5 SECONDS * mult)

				M.jitteriness = max(M.jitteriness-50,0)

				if (prob(10))
					M.emote("drool")
					M.take_brain_damage(1 * mult)

				..()
				return

		harmful/ketamine // COGWERKS CHEM REVISION PROJECT. ketamine
			name = "ketamine"
			id = "ketamine"
			description = "A potent veterinary tranquilizer."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 150
			fluid_b = 250
			transparency = 20
			depletion_rate = 0.8
			penetrates_skin = 1
			var/counter = 1
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("r_ketamine", -20)
					..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("r_ketamine")
					..()

			on_mob_life(var/mob/M, var/mult = 1) // sped this up a bit due to mob loop changes
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += 1 * mult)
					if (1 to 5)
						if (probmult(25)) M.emote("yawn")
					if (6 to 9)
						M.change_eye_blurry(10, 10)
						M.setStatus("drowsy", 10 SECONDS)
						if (probmult(35)) M.emote("yawn")
					if (10)
						M.emote("faint")
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					if (11 to INFINITY)
						M.setStatusMin("unconscious", 25 SECONDS * mult)

				..()
				return

		harmful/sulfonal
			name = "sulfonal"
			id = "sulfonal"
			description = "An old sedative with toxic side-effects."
			reagent_state = LIQUID
			fluid_r = 125
			fluid_g = 195
			fluid_b = 160
			transparency = 80
			depletion_rate = 0.1
			var/counter = 1
			var/remove_buff = 0
			var/fainted = FALSE
			blob_damage = 2
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.add_stam_mod_max("r_sulfonal", -10)
					..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					M.remove_stam_mod_max("r_sulfonal")
					..()

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				M.jitteriness = max(M.jitteriness-30,0)
				if(M.hasStatus("stimulants"))
					M.changeStatus("stimulants", -10 SECONDS * mult)

				switch(counter+= (1 * mult))
					if (1 to 11)
						if (probmult(7)) M.emote("yawn")
					if (11 to 21)
						M.setStatus("drowsy", 40 SECONDS)
					if (21 to INFINITY)
						if(!fainted)
							M.emote("faint")
							fainted = TRUE
						if (prob(20))
							M.emote("faint")
							M.setStatusMin("unconscious", 8 SECONDS * mult)
						M.setStatus("drowsy", 40 SECONDS)
				M.take_toxin_damage(1 * mult)
				..()
				return

		harmful/toxin
			name = "toxin"
			id = "toxin"
			description = "A Toxic chemical."
			reagent_state = LIQUID
			fluid_r = 25
			fluid_b = 0
			fluid_g = 25
			transparency = 20
			blob_damage = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(2 * mult)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.poison_damage += 1

		harmful/cytotoxin
			name = "cytotoxin"
			id = "cytotoxin"
			description = "An incredibly potent poison. Origin unknown."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 255
			fluid_b = 240
			transparency = 200
			depletion_rate = 0.2
			var/delimb_counter = 0
			var/limb_list = list("l_arm", "l_leg", "r_arm", "r_leg")

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				var/our_amt = holder.get_reagent_amount(src.id)
				if (prob(25))
					M.reagents.add_reagent("histamine", rand(125, 250) * src.calculate_depletion_rate(M, mult))
				if (our_amt < 20)
					M.take_toxin_damage(0.75 * mult)
					random_brute_damage(M, 0.75 * mult)
				else if (our_amt < 40)
					if (probmult(20))
						M.nauseate(1)
					M.take_toxin_damage(1.25 * mult)
					delimb_counter += 0.6 * mult
					random_brute_damage(M, 1.25 * mult)
				else
					if (probmult(20))
						M.nauseate(1)
					M.take_toxin_damage(2 * mult)
					delimb_counter += 1.5 * mult
					random_brute_damage(M, 2 * mult)

				if (delimb_counter > 15)
					delimb_counter = 0

					M.visible_message(SPAN_ALERT("<B>[M]</B> seems to be melting away!"), "You feel as if your body is tearing itself apart!")
					M.setStatusMin("knockdown", 4 SECONDS * mult)
					M.make_jittery(400)
					if (!isdead(M))
						M.emote(pick("cry", "tremble", "scream"))

					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						take_bleeding_damage(H, null, rand(15,35) * mult, DAMAGE_STAB)

						for (var/chosen_limb in limb_list)
							var/obj/item/parts/limb = H.limbs.get_limb(chosen_limb)
							if (istype(limb))
								H.lose_limb(chosen_limb)
								break
					else
						random_brute_damage(M, 25 * mult)

					return

				..()
				return

		harmful/hemotoxin
			name = "hemotoxin"
			id = "hemotoxin"
			description = "A dangerous toxin that causes massive bleeding and tissue damage"
			reagent_state = LIQUID
			fluid_r = 210
			fluid_g = 180
			fluid_b = 25
			depletion_rate = 0.3
			blob_damage = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(mult)

				if (isliving(M))
					var/mob/living/H = M
					if(H.blood_volume > 300)        //slows down your bleeding when you have less blood to bleed
						H.blood_volume -= 5 * mult
					else
						H.blood_volume -= 3 * mult
				if (probmult(6))
					M.visible_message(pick(SPAN_ALERT("<B>[M]</B>'s [pick("eyes", "arms", "legs")] bleed!"),\
											SPAN_ALERT("<B>[M]</B> bleeds [pick("profusely", "from every wound")]!"),\
											SPAN_ALERT("<B>[M]</B>'s [pick("chest", "face", "whole body")] bleeds!")))
					playsound(M, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, TRUE) //some bloody effects
					make_cleanable(/obj/decal/cleanable/blood/splatter,M.loc)
				else if (probmult(20))
					make_cleanable(/obj/decal/cleanable/blood/splatter,M.loc) //some extra bloody effects
				if (probmult(10))
					M.make_jittery(50)
					M.setStatus("slowed", max(M.getStatusDuration("slowed"), 5 SECONDS))
					boutput(M, SPAN_ALERT("<b>Your body hurts so much.</b>"))
					if (!isdead(M))
						M.emote(pick("cry", "tremble", "scream"))
				if (probmult(10))
					M.change_eye_blurry(6, 6)
					M.setStatus("slowed", max(M.getStatusDuration("slowed"), 5 SECONDS))
					boutput(M, SPAN_ALERT("<b>Everything starts hurting.</b>"))
					if (!isdead(M))
						M.emote(pick("shake", "tremble", "shudder"))

				..()
				return

		harmful/neurotoxin // COGWERKS CHEM REVISION PROJECT. which neurotoxin?
			name = "neurotoxin"
			id = "neurotoxin"
			description = "A dangerous toxin that attacks the nervous system"
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 145
			fluid_b = 110
			depletion_rate = 1
			var/counter = 1
			var/fainted = FALSE
			blob_damage = 1
			value = 4 // 3c + heat

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 5)
						return // let's not be incredibly obvious about who stung you for changelings
					if (5 to 11)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(10 * mult)
						if (probmult(20)) M.emote("drool")
					if (11 to 18)
						M.setStatus("drowsy", 20 SECONDS)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(20 * mult)
						if (probmult(35)) M.emote("drool")
					if (18 to INFINITY)
						M.changeStatus("paralysis", 10 SECONDS * mult)
						M.changeStatus("muted", 10 SECONDS * mult)
						M.setStatus("drowsy", 40 SECONDS)
						if (!fainted)
							M.force_laydown_standup()
							fainted = TRUE

				M.jitteriness = max(M.jitteriness-30,0)
				if (M.get_brain_damage() <= BRAIN_DAMAGE_SEVERE)
					M.take_brain_damage(1 * mult)
				else
					if (prob(10)) M.take_brain_damage(1 * mult) // let's slow down a bit after 80
				M.take_toxin_damage(1 * mult)
				..(M, mult)
				return

		harmful/neurodepressant
			name = "neurodepressant"
			id = "neurodepressant"
			description = "A debilitating compound that affects muscular function, extracted from neurotoxin."
			reagent_state = LIQUID
			fluid_r = 140
			fluid_g = 145
			fluid_b = 135
			depletion_rate = 0.2
			var/counter = 1
			blob_damage = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 5)
						return //evil evil evil make them think it's neurotoxin
					if (5 to 10)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(10 * mult)
						if (probmult(20)) M.emote("drool")
					if (10 to 18)
						M.setStatus("drowsy", 8 SECONDS)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(15 * mult)
						if (probmult(35)) M.emote("drool")
					if (18 to INFINITY)
						M.setStatus("drowsy", 8 SECONDS)
						M.make_dizzy(1 * mult)
						M.change_eye_blurry(6, 6)
						M.change_misstep_chance(20 * mult)
						if(M.reagents?.has_reagent("capulettium") && is_incapacitated(M))
							..()                      //will not cause emotes and puking if you are already downed by capulettium
							return					  //for preserving the death diguise
						if(probmult(15))
							if(!M.hasStatus("slowed"))
								M.setStatus("slowed", 2 SECONDS)
							boutput(M, pick(SPAN_ALERT("You feel extremely dizzy!"),\
											SPAN_ALERT("You feel like everything is spinning!"),\
											SPAN_ALERT("Your [pick("arms", "legs")] quiver!"),\
											SPAN_ALERT("Your feel a numbness through your [pick("hands", "fingers")].."),\
											SPAN_ALERT("Your vision [pick("gets all blurry", "goes fuzzy")]!"),\
											SPAN_ALERT("You feel very sick!")))
							if(prob(30)) //no need for probmult in here as it's already behind a probmult statement
								M.nauseate(1)
						else if(probmult(9))
							M.setStatus("muted", 10 SECONDS)
							boutput(M, pick(SPAN_ALERT("You feel like the words are getting caught up in your mouth!"),\
											SPAN_ALERT("You can't utter a single word!"),\
											SPAN_ALERT("Your [pick("face","chest")] feels numb..."),\
											SPAN_ALERT("You can't feel your [pick("mouth","tongue","throat")]!")))
							if(prob(25)) //no need for probmult in here as it's already behind a probmult statement
								M.losebreath += (1)
								M.emote(pick("gasp", "choke"))
							else if(prob(25)) //same thing
								M.setStatus("stunned", 3 SECONDS)
						else if (probmult(40)) M.emote(pick("twitch", "tremble", "drool", "drool", "twitch_v"))

				M.jitteriness = max(M.jitteriness-30,0)
				..(M, mult)
				return

		harmful/mutagen // COGWERKS CHEM REVISION PROJECT. magic chemical, fine as is
			name = "unstable mutagen"
			id = "mutagen"
			description = "Might cause unpredictable mutations. Keep away from children."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 255
			fluid_b = 0
			transparency = 255
			depletion_rate = 0.3
			blob_damage = 1
			value = 3 // 1 1 1

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (M.nodamage)
					return .
				if ( (method==TOUCH && prob((3 * volume) + 2)) || method==INGEST)
					if(ishuman(M))
						M.bioHolder.RandomEffect("bad")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_radiation_dose(0.02 SIEVERTS * mult, internal=TRUE)
				var/mutChance = 4
				if (M.traitHolder && M.traitHolder.hasTrait("stablegenes")) mutChance = 2
				if (probmult(mutChance) && ishuman(M))
					M.bioHolder.RandomEffect("bad")
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				if (P.growth > 1)
					growth_tick.growth_rate -= 0.4
				growth_tick.mutation_severity += 0.24

		////////////// work in progress. new mutagen for omega slurrypods - cogwerks

		harmful/omega_mutagen
			name = "glowing slurry"
			id = "omega_mutagen"
			description = "This is probably not good for you."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 255
			fluid_b = 0
			transparency = 255

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (M.nodamage)
					return .
				if ( (method==TOUCH && prob((5 * volume) + 1)) || method==INGEST)
					if(ishuman(M))
						M.bioHolder.RandomEffect("bad")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_radiation_dose(0.02 SIEVERTS * mult, internal=TRUE)
				// DNA buckshot
				var/mutChance = 15
				if (M.traitHolder && M.traitHolder.hasTrait("stablegenes")) mutChance = 7
				if (probmult(mutChance) && ishuman(M))
					M.bioHolder.RandomEffect("bad")
				if (probmult(3) && ishuman(M))
					M.bioHolder.RandomEffect("good")
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.growth_rate -= 1.5
				growth_tick.mutation_severity += 1

		harmful/formaldehyde/werewolf_serum_fake1
			name = "Werewolf Serum Precursor Alpha"
			id = "werewolf_part1"
			description = "A strange and poisonous lupine compound."
			reagent_state = LIQUID
			fluid_r = 149
			fluid_g = 172
			fluid_b = 147
			transparency = 150

		harmful/omega_mutagen/werewolf_serum_fake2
			name = "Werewolf Serum Precursor Beta"
			id = "werewolf_part2"
			description = "A potent and very unstable mutagenic substance."
			reagent_state = LIQUID
			fluid_r = 50
			fluid_g = 172
			fluid_b = 100
			transparency = 200

		harmful/fake_initropidril
			name = "initropidril"
			id = "fake_initropidril"
			description = "A highly potent toxin - can kill within minutes."
			reagent_state = LIQUID
			fluid_r = 127
			fluid_g = 16
			fluid_b = 192
			transparency = 220

		harmful/wolfsbane
			name = "Aconitine"
			id = "wolfsbane"
			description = "Also known as monkshood or wolfsbane, aconitine is a very potent neurotoxin."
			reagent_state = LIQUID
			fluid_r = 129
			fluid_b = 116
			fluid_g = 198
			transparency = 20

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(2 * mult)
				if (probmult(4))
					M.emote("drool")
				if (prob(8))
					boutput(M, SPAN_ALERT("You cannot breathe!"))
					M.losebreath += (1 * mult)
					M.emote("gasp")
				if (prob(10))
					boutput(M, SPAN_ALERT("You feel horribly weak."))
					M.setStatusMin("stunned", 3 SECONDS * mult)
					M.take_toxin_damage(2 * mult)
				..()
				return

		harmful/toxic_slurry
			name = "toxic slurry"
			id = "toxic_slurry"
			description = "A filthy, carcinogenic sludge produced by the Slurrypod plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 200
			fluid_b = 30
			transparency = 255

			on_add()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.add_vomit_behavior(/datum/vomit_behavior/green_goo)

			on_remove()
				if (ismob(holder.my_atom))
					var/mob/mob = holder.my_atom
					mob.remove_vomit_behavior(/datum/vomit_behavior/green_goo)

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (prob(10))
					M.take_toxin_damage(rand(2,4) * mult)
				if (prob(7))
					boutput(M, SPAN_ALERT("A horrible migraine overpowers you."))
					M.setStatusMin("stunned", 3 SECONDS * mult)
				if (probmult(20))
					M.nauseate(1)
				..()

		harmful/histamine
			name = "histamine" // cogwerks notes. allergic reaction tests (see. MSG) can metabolize this in the body for allergy simulation, if extracted and mass-produced, it's fairly lethal
			id = "histamine"
			description = "Immune-system neurotransmitter. If detected in blood, the subject is likely undergoing an allergic reaction."
			reagent_state = LIQUID
			fluid_r = 250
			fluid_g = 100
			fluid_b = 100
			transparency = 60
			depletion_rate = 0.2
			overdose = 40

			on_mob_life(var/mob/M, var/mult = 1) // allergies suck fyi
				if (!M) M = holder.my_atom
				if(M.reagents?.has_reagent("antihistamine") && prob(66)) //66% (intentionally not probmult) chance to cancel standard histamine effects, including hyperallergenic hist duplication
					..()
					return
				if (probmult(20)) M.emote(pick("twitch", "grumble", "sneeze", "cough"))
				if (probmult(10))
					boutput(M, SPAN_NOTICE("<b>Your eyes itch.</b>"))
					M.emote(pick("blink", "sneeze"))
					M.change_eye_blurry(3, 3)
				if (prob(10))
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> scratches at an itch."))
					random_brute_damage(M, 1 * mult)
					M.emote("grumble")
				if (prob(5))
					boutput(M, SPAN_ALERT("<b>You're getting a rash!</b>"))
					random_brute_damage(M, 2 * mult)

				// Hyperallergic
				if(M.traitHolder.hasTrait("allergic"))
					holder.add_reagent(src.id, min(2 + src.volume/20, 120-holder.get_reagent_amount(src.id)) * mult)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if (M.nodamage)
					return .
				if (method == TOUCH)
					M.reagents.add_reagent("histamine", min(10,volume * 2))
					M.make_jittery(10)
				else
					boutput(M, SPAN_ALERT("<b>You feel a burning sensation in your throat..."))
					M.make_jittery(30)
					M.emote(pick("drool"))
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if(M.reagents.has_reagent("epinephrine")) //epi-pens reduce the severity of the hist overdose, but won't exactly cure you if the source of hist is still around
					severity--
				if (severity == 1)
					if (effect <= 2)
						boutput(M, SPAN_ALERT("<b>You feel mucus running down the back of your throat.</b>"))
						M.take_toxin_damage(1 * mult)
						M.make_jittery(4)
						M.emote("sneeze", "cough")
					else if (effect <= 4)
						M.stuttering += rand(0,5)
						if (prob(25))
							M.emote(pick("choke","gasp"))
							M.take_oxygen_deprivation(5 * mult)
					else if (effect <= 7)
						boutput(M, SPAN_ALERT("<b>Your chest hurts!</b>"))
						M.emote(pick("cough","gasp"))
						M.take_oxygen_deprivation(3 * mult)
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]<b> breaks out in hives!"))
						random_brute_damage(M, 6 * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> has a horrible coughing fit!"))
						M.make_jittery(10)
						M.stuttering += rand(0,5)
						M.emote("cough")
						if (prob(40))
							M.emote(pick("choke","gasp"))
							M.take_oxygen_deprivation(6 * mult)
						M.setStatusMin("knockdown", 8 SECONDS * mult)
					else if (effect <= 7)
						boutput(M, SPAN_ALERT("<b>Your heartbeat is pounding inside your head!</b>"))
						M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
						M.emote("collapse")
						M.take_oxygen_deprivation(8 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatusMin("knockdown", 4 SECONDS * mult)
						M.emote(pick("choke", "gasp"))
						boutput(M, SPAN_ALERT("<b>You feel like you're dying!</b>"))

		harmful/saxitoxin // formerly: sarin
			name = "saxitoxin"
			id = "saxitoxin"
			description = "A viciously lethal paralytic agent derived from toxic algae blooms and tainted shellfish. Can be neutralized with atropine."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			penetrates_skin = 1
			depletion_rate = 0.1
			overdose = 25
			var/counter = 1
			blob_damage = 5

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				var/progression_speed = 1
				if(M.reagents.has_reagent("epinephrine"))
					progression_speed = 0.8

				switch(counter+= (progression_speed * mult))
					if (1 to 15)
						M.make_jittery(20)
						if (probmult(20))
							M.emote(pick("twitch","twitch_v","quiver"))
					if (16 to 30)
						if (probmult(25))
							M.emote(pick("twitch","twitch_v","drool","quiver","tremble"))
						M.change_eye_blurry(5, 5)
						M.stuttering = max(M.stuttering, 5)
						if (prob(10))
							M.change_misstep_chance(15 * mult)
						if (prob(15))
							M.setStatusMin("stunned", 2 SECONDS * mult)
					if (30 to 60)
						M.change_eye_blurry(5, 5)
						M.stuttering = max(M.stuttering, 5)
						if (prob(10))
							M.setStatusMin("stunned", 2 SECONDS * mult)
							M.emote(pick("twitch","twitch_v","drool","shake","tremble"))
						if (probmult(5))
							M.emote("collapse")
						if (prob(5))
							M.setStatusMin("knockdown", 4 SECONDS * mult)
							M.visible_message(SPAN_ALERT("<b>[M] has a seizure!</b>"))
							M.make_jittery(1000)
						if (prob(5))
							boutput(M, SPAN_ALERT("<b>You can't breathe!</b>"))
							M.emote(pick("gasp", "choke", "cough"))
							M.losebreath += (1 * mult)
					if (61 to INFINITY)
						if (probmult(15))
							M.emote(pick("gasp", "choke", "cough","twitch", "shake", "tremble","quiver","drool", "twitch_v","collapse"))
						M.losebreath = max(5, M.losebreath + (5 * mult))
						M.take_toxin_damage(1 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
				if (probmult(20))
					M.nauseate(1)
				M.take_toxin_damage(1 * mult)
				M.take_brain_damage(1 * mult)
				M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

		harmful/tetrodotoxin
			name = "tetrodotoxin"
			id = "tetrodotoxin"
			description = "An extremely dangerous neurotoxin which paralyses the heart, most commonly found in incorrectly prepared pufferfish."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 180
			fluid_b = 240
			transparency = 10
			depletion_rate = 0.2
			var/progression_speed = 1
			var/counter = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				switch(src.counter+= (mult * src.progression_speed))
					if (10 to 28) // Small signs of trouble
						if (prob(15))
							M.change_misstep_chance(15 * mult)
						if (probmult(13))
							boutput(M, SPAN_NOTICE("<b>You feel a [pick("sudden palpitation", "numbness", "slight burn")] in your chest.</b>"))
							M.stuttering = max(M.stuttering, 10)
						if (probmult(13))
							M.emote(pick("twitch","drool","tremble"))
							M.change_eye_blurry(2, 2)
					if (28 to 40) // Effects ramp up, breathlessness, early paralysis signs and heartache
						M.change_eye_blurry(5, 5)
						M.stuttering = max(M.stuttering, 5)
						M.setStatusMin("slowed", 40 SECONDS)
						if (prob(35))
							M.losebreath = max(5, M.losebreath + (5 * mult))
						if (prob(20))
							boutput(M, SPAN_ALERT("<b>Your chest [pick("burns", "hurts", "stings")] like hell.</b>"))
							M.change_misstep_chance(15 * mult)
						if (!ON_COOLDOWN(M, "heartbeat_hallucination", 30 SECONDS))
							M.playsound_local(get_turf(M), 'sound/effects/HeartBeatLong.ogg', 30, 1, pitch = 2)
					if (40 to INFINITY) // Heart effects kick in
						M.setStatusMin("slowed", 40 SECONDS)
						M.change_eye_blurry(15, 15)
						M.losebreath = max(5, M.losebreath + (5 * mult))
						if(isliving(M))
							var/mob/living/L = M
							L.contract_disease(/datum/ailment/malady/flatline, null, null, 1)
				..()
				return

		harmful/dna_mutagen
			name = "stable mutagen"
			id = "dna_mutagen"
			description = "Just the regular, boring sort of mutagenic compound.  Works in a completely predictable manner."
			reagent_state = LIQUID
			fluid_r = 125
			fluid_g = 255
			fluid_b = 0
			transparency = 255
			depletion_rate = 2

			var/tmp/progress_timer = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!src.data) // Pull bioholder data from blood that's in the same reagentholder
					for (var/bloodtype in holder.reagent_list)
						var/datum/reagent/blood = holder.reagent_list[bloodtype]
						if (blood && istype(blood.data, /datum/bioHolder))
							src.data = blood.data
							break

				if (src.data && M.bioHolder && progress_timer <= 10)
					if(istype(src.data, /datum/bioHolder))
						var/datum/bioHolder/tocopy = data
						if(tocopy?.mobAppearance?.mutant_race?.dna_mutagen_banned)
							return ..()
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.mutantrace?.dna_mutagen_banned)
							return ..()
					M.bioHolder.StaggeredCopyOther(data, progress_timer+=(1 * mult))
					if (probmult(50) && progress_timer > 7)
						boutput(M, SPAN_NOTICE("You feel a little [pick("unlike yourself", "out of it", "different", "strange")]."))
					if (progress_timer > 10)
						M.real_name = M.bioHolder.ownerName
						if (M.bioHolder?.mobAppearance?.mutant_race)
							M.set_mutantrace(M.bioHolder.mobAppearance.mutant_race.type)
						M.UpdateName()
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.update_colorful_parts()

				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P, var/datum/plantgrowth_tick/growth_tick)
				growth_tick.growth_rate -= 1.6
				growth_tick.mutation_severity += 0.16

		harmful/madness_toxin
			name = "Rajaijah"
			id = "madness_toxin"
			description = "A synthetic version of a potent neurotoxin derived from plants capable of driving a person to madness. First discovered in India by a Belgian reporter in 1931."
			reagent_state = LIQUID
			fluid_r = 157
			fluid_g = 206
			fluid_b = 69
			transparency = 255
			var/ticks = 0
			depletion_rate = 0.1
			var/spooksounds = list('sound/effects/ghost.ogg' = 80,'sound/effects/ghost2.ogg' = 20,'sound/effects/ghostbreath.ogg' = 60, \
					'sound/effects/ghostlaugh.ogg' = 40,'sound/effects/ghostvoice.ogg' = 90)

			var/lastSpook = 0
			var/lastSpookLen = 0
			var/ai_was_active = 0

			var/t1 = 2
			var/t2 = 11
			var/t3 = 18
			var/t4 = 26
			var/t5 = 28
			var/t6 = 30
			var/t7 = 50
			var/t8 = 51
			var/t9 = 101
			var/t10 = 103

			//MBC : you may be wondering why this looks so weird
			//we need to proc tiered effects IN ORDER, even if they were skipped! that is why! also im bad but this works fine its just harder to read than the OG way ok
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				var/mob/living/carbon/human/H = M
				if (!istype(H)) return

				ticks += mult

				if (t1 && ticks >= t1)
					if (probmult(33))
						H.changeStatus("drowsy", 6 SECONDS)
						H.show_text(pick_string("chemistry_reagent_messages.txt", "madness0"), "red")
					if (probmult(10)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e0"))

				if (t2 && ticks >= t2)
					t1 = 0
					if (probmult(33))
						H.changeStatus("drowsy", 15 SECONDS)
						H.show_text(pick_string("chemistry_reagent_messages.txt", "madness1"), "blue")
					if (probmult(10)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e1"))

				if (t3 && ticks >= t3)
					t2 = 0
					if (probmult(33))
						H.changeStatus("drowsy", 15 SECONDS)
						H.make_jittery(300)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness2")]</B>", "red")
						if (probmult(33) && world.time > lastSpook + lastSpookLen)
							var/spook = pick(spooksounds)
							H.playsound_local(H, spook, 50, 1)
							lastSpookLen = spooksounds[spook]
							lastSpook = world.time

					if (probmult(15)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

				if (t4 && ticks >= t4)
					t3 = 0
					H.show_text("<B>Your mind feels clearer.</B>", "blue")
					H.delStatus("drowsy")

				if (t5 && ticks >= t5)
					t4 = 0
					H.show_text("<font size=+2><B>IT HURTS!!</B></font>","red")
					H.emote("scream")
					ai_was_active = H.ai_active
					H.ai_init() //:getin:
					H.ai_aggressive = 1 //Fak
					H.ai_calm_down = 0
					logTheThing(LOG_COMBAT, H, "has their AI enabled by [src.id]")
					H.playsound_local(H, 'sound/effects/HeartBeatLong.ogg', 50, 1)
					lastSpook = world.time

				if (t6 && ticks >= t6)
					t5 = 0
					if (probmult(33))
						H.make_jittery(600)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness3")]</B>", "red")

					if (probmult(33)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

					if (probmult(20) && world.time > lastSpook + 510)
						H.show_text("You feel your heartbeat pounding inside your head...", "red")
						H.playsound_local(H, 'sound/effects/HeartBeatLong.ogg', 75, 1) // LOUD
						lastSpook = world.time


					//POWER UP!!
				if (t7 && ticks >= t7)
					t6 = 0
					APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, src.id, 100) //Buff
					H.show_text("You feel very buff!", "red")

				if (t8 && ticks >= t8)
					t7 = 0

					if (prob(20)) //The AI is in control now.
						H.change_misstep_chance(100 * mult)
						H.show_text("You can't seem to control your legs!", "red")

					if (probmult(10)) //Stronk
						H.show_text("You feel strong!", "red")
						H.remove_stuns()
						H.delStatus("disorient")

				if (t9 && ticks >= t9)
					t8 = 0
					H.ai_suicidal = 1
					H.show_text("Death... I can only stop this by dying...", "red")

				if (t10 && ticks > t10)
					t9 = 0
					if (probmult(33))
						H.make_jittery(600)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness3")]</B>", "red")

					if (probmult(33)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

					if (probmult(20) && world.time > lastSpook + 510)
						H.show_text("You feel your heartbeat pounding inside your head...", "red")
						H.playsound_local(H, 'sound/effects/HeartBeatLong.ogg', 100, 1) // LOUD
						lastSpook = world.time


					//POWER UP!!
					if (prob(20)) //The AI is in control now.
						H.change_misstep_chance(100 * mult)
						H.show_text("You can't seem to control your legs!", "red")

					if (probmult(20)) //V. Stronk
						H.show_text("You feel strong!", "red")
						H.remove_stuns()
						H.delStatus("disorient")

				H.take_brain_damage(0.5 * mult)

				..()
			on_remove()
				if (holder?.my_atom && ishuman(holder.my_atom))
					var/mob/living/carbon/human/H = holder.my_atom
					// moving the 'turn off the ai' part here because it failed
					// to actually deactivate, leaving it on forever
					//if(!ai_was_active)
					H.ai_stop()
					H.ai_aggressive = initial(H.ai_aggressive)
					H.ai_calm_down = initial(H.ai_calm_down)
					H.ai_suicidal = 0
					if (ticks >= 30)
						REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, src.id) //Not so buff
						logTheThing(LOG_COMBAT, H, "has their AI disabled by [src.id]")
						H.show_text("It's okay... it's okay... breathe... calm... it's okay...", "blue")
				..()

		harmful/strychnine
			name = "strychnine"
			id = "strychnine"
			description = "A highly potent neurotoxin in crystalline form. Causes severe convulsions and eventually death by asphyxiation. Has been known to be used as a performance enhancer by certain athletes."
			taste = "intensely bitter"
			reagent_state = SOLID
			fluid_r = 244
			fluid_g = 244
			fluid_b = 244
			transparency = 255
			depletion_rate = 0.2
			var/ticks = 0
			var/stage = 0

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/carbon/human/H = M
				if (!istype(H)) return

				ticks += mult

				switch (stage)
					if(0)
						if(ticks >= 2)
							stage++
					if(1)
						//Just started out. Everything's cool
						H.add_stam_mod_max(src.id, 75)
						if(ticks >= 3)
							stage++
					if(2)
						if(prob(10)) do_stuff(0, H, mult)
						if(ticks >= 15)
							stage++
					if(3)
						//Ok, now it's getting worrying
						if(prob(30)) do_stuff(1, H, mult)
						if(ticks >= 25)
							stage++
					if(4)
						H.remove_stam_mod_max(src.id)
						H.add_stam_mod_max(src.id, -50)
						APPLY_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, src.id, -2)
						if(ticks >= 26)
							stage++
					if(5)
						if(prob(30)) do_stuff(2, H, mult)
						if(ticks >= 36)
							stage++
					if(6)
						//Start at 30% chance of bad stuff, increase until death
						if(prob(min(ticks, 100)))
							do_stuff(3, H, mult)
				..()

			on_remove()
				..()
				var/mob/living/carbon/human/H = holder.my_atom
				if (!istype(H)) return
				H.remove_stam_mod_max(src.id)
				REMOVE_ATOM_PROPERTY(H, PROP_MOB_STAMINA_REGEN_BONUS, src.id)


			proc/do_stuff(var/severity, var/mob/living/carbon/human/H, var/mult = 1)
				if(!istype(H)) return

				switch(severity)
					if(0) //Harmless messages, etc
						H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine0"), "blue")
					if(1) //Getting kinda stiff... ouch (stuns, dropping items, etc)
						switch(rand(1,6))
							if(1 to 3) //Feels bad
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine1"), "red")
							if(4) //Drop stuff
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine1b"), "red")
								H.changeStatus("stunned", 1 SECOND * mult)
							if(5) //Trip
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine1c"), "red")
								H.changeStatus("knockdown", 2 SECONDS * mult)
							if(6) //Light-headedness
								H.show_text("You feel light-headed.", "red")
								H.changeStatus("drowsy", rand(8,16) SECONDS)

					if(2) //I don't feel so good (tripping, hard time breathing, randomly dropping stuff)
						switch(rand(1,4))
							if(1) //Chest-heaviness
								H.show_text("Your chest feels heavy.", "red")
								H.emote(pick("gasp", "choke", "cough"))
								H.losebreath += (1 * mult)
								H.take_oxygen_deprivation(rand(5, 10) * mult)
							if(2) //Drop stuff
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine2"), "red")
								H.changeStatus("stunned", 2 SECONDS * mult)
								H.change_misstep_chance(20 * mult)
							if(3) //Trip
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine2b"), "red")
								H.visible_message("<span class='combat bold'>[H] stumbles and falls!</span>")
								H.changeStatus("knockdown", 2 SECONDS * mult)
							if(4) //Light-headedness
								H.show_text("You feel like you are about to faint!", "red")
								H.changeStatus("drowsy", rand(12,24) SECONDS)
								if(probmult(20)) H.emote(pick("faint", "collapse"))
						if(prob(30))
							H.make_jittery(15)
				if(severity > 2)
					if(prob(min(ticks+10, 100))) //Stun, twitch, 50% chance ramps up to 100 after
						H.make_jittery(50)

						H.changeStatus("knockdown", 2 SECONDS)

						if(probmult(90)) H.visible_message("<span class='combat bold'>[H][pick_string("chemistry_reagent_messages.txt", "strychnine_deadly")]</span>")
						if(probmult(70)) playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"),50,1)

						if(prob(50))
							H.emote("scream") //It REALLY hurts
							H.TakeDamage(zone="All", brute=rand(2,5) * mult)

					if(prob(clamp(ticks/1.5, 100, 30))) //At least 30% risk of oxy damage
						if(probmult(50))H.emote(pick("gasp", "choke", "cough"))
						H.losebreath += rand(1,3) * mult

					if(probmult(25))
						H.emote(pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_emotes"))

					if(probmult(25))
						H.nauseate(1)
					else if (prob(5) && !HAS_ATOM_PROPERTY(H, PROP_MOB_CANNOT_VOMIT))
						var/damage = rand(1,10)
						H.visible_message(SPAN_ALERT("[H] [damage > 3 ? "vomits" : "coughs up"] blood!"), SPAN_ALERT("You [damage > 3 ? "vomit" : "cough up"] blood!"))
						playsound(H.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
						H.TakeDamage(zone="All", brute=damage)
						bleed(H, damage * 2 * mult, 3)

		harmful/mimic_toxin
			name = "mimicotoxin"
			id = "mimicotoxin"
			description = "A mild psychoactive neurotoxin that attacks the optic nerve, causing hallucinations, temporary blindness in low doses, and finally permenant blindness"
			taste = "intensely bitter"
			reagent_state = SOLID
			fluid_r = 188
			fluid_g = 111
			fluid_b = 207
			transparency = 255
			depletion_rate = 0.2
			target_organs = list("left_eye", "right_eye")

			on_mob_life(var/mob/M, var/mult = 1)
				. = ..()
				var/poison_amount = holder?.get_reagent_amount(src.id) // need to check holder as the reagent could be fully removed in the parent call
				if(poison_amount > 5)
					M.AddComponent(/datum/component/hallucination/random_image_override, timeout=10, image_list=list(image('icons/misc/critter.dmi',"mimicface")), target_list=list(/obj/item, /mob/living), range=5, image_prob=2, image_time=10, override=FALSE)
				if(poison_amount > 15)
					M.setStatusMin("blinded", 10 SECONDS * mult)
				if(poison_amount > 30)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						H.take_eye_damage(1)
					else
						M.take_toxin_damage(1 * mult)
