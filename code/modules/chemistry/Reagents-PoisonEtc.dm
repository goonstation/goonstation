//Contains reagents that are poisons or otherwise intended to be harmful
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

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison", 3 * damage_factor)

			nitrogen_dioxide
				name = "nitrogen dioxide"
				id = "nitrogen_dioxide"
				description = "A common, mildly toxic pollutant."
				reagent_state = GAS
				fluid_r = 128
				fluid_g = 32
				fluid_b = 32
				transparency = 120
				penetrates_skin = 1

		harmful/simple_damage_burn
			name = "irritant precursor"
			id = "simple_damage_burn"
			var/damage_factor = 1
			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.TakeDamage("chest", 0, damage_factor * mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison", 3 * damage_factor)

			allyl_chloride
				name = "allyl chloride"
				id = "allyl_chloride"
				description = "A toxic intermediary substance."
				reagent_state = LIQUID
				fluid_r = 220
				fluid_g = 220
				fluid_b = 255
				transparency = 128
				damage_factor = 1.5

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

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				//M.take_toxin_damage(1)
				M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if (method == TOUCH)
					if (volume > 25)
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.wear_mask)
								boutput(M, "<span class='alert'>Your mask protects you from the acid!</span>")
								return
							if (H.head)
								boutput(M, "<span class='alert'>Your helmet protects you from the acid!</span>")
								return

						if (prob(75))
							M.TakeDamage("head", 5, 10, 0, DAMAGE_BURN)
							M.emote("scream")
							boutput(M, "<span class='alert'>Your face has become disfigured!</span>")
							M.real_name = "Unknown"
							M.unlock_medal("Red Hood", 1)
						else
							M.TakeDamage("All", 5, 10, 0, DAMAGE_BURN)
					else
						M.TakeDamage("All", min(1, volume * 0.1), min (5, volume * 0.5), 0, DAMAGE_BURN)
				else
					boutput(M, "<span class='alert'>The greenish acidic substance stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
					if (volume >= 10)
						M.TakeDamage("All", 0, min(max(4, (volume - 10) * 2), 20), 0, DAMAGE_BURN)
						M.emote("scream")

			reaction_obj(var/obj/O, var/volume)
				if (istype(O,/obj/fluid))
					return 1
				if (istype(O,/obj/item/clothing/head/chemhood || /obj/item/clothing/suit/chemsuit))
					return 1
				if (isitem(O) && prob(40))
					var/obj/decal/cleanable/molten_item/I = make_cleanable(/obj/decal/cleanable/molten_item,O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in AIviewers(5, O))
						boutput(M, "<span class='alert'>\the [O] melts.</span>")
					qdel(O)

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("acid",5)
				P.growth -= 3

			reaction_blob(var/obj/blob/B, var/volume)
				if (!blob_damage)
					return
				B.take_damage(blob_damage, volume, "mixed")

		harmful/acid/clacid
			name = "hydrochloric acid"
			id = "clacid"
			description = "A strong acid with the molecular formula HCl."
			fluid_r = 0
			fluid_g = 200
			fluid_b = 255
			blob_damage = 1.2

		harmful/acid/nitric_acid
			name = "nitric acid"
			id = "nitric_acid"
			description = "A strong acid."
			fluid_r = 0
			fluid_g = 200
			fluid_b = 255
			blob_damage = 0.7

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
				if (method == TOUCH)
					if (volume >= 50 && prob(75))
						M.TakeDamage("head", 5, 15, 0, DAMAGE_BURN)
						M.emote("scream")
						boutput(M, "<span class='alert'>Your face has become disfigured!</span>")
						M.real_name = "Unknown"
						M.unlock_medal("Red Hood", 1)
					else
						random_brute_damage(M, min(5, volume * 0.25))
				else
					boutput(M, "<span class='alert'>The transparent acidic substance stings[volume < 25 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
					if (volume >= 25)
						random_brute_damage(M, 2)
						M.emote("scream")

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("acid", 1)

			reaction_blob(var/obj/blob/B, var/volume)
				if (!blob_damage)
					return
				B.take_damage(blob_damage, volume, "mixed")

		harmful/amanitin
			name = "amanitin"
			id = "amanitin"
			description = "A toxin produced by certain mushrooms. Very deadly."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 50
			var/damage_counter = 0

			pooled()
				..()
				damage_counter = 0

			on_mob_life(var/mob/M, var/mult = 1)

				if (!M) M = holder.my_atom
				damage_counter += rand(2,4) * mult // RNG rolls moved to accumulation proc for consistency

				..()

			on_mob_life_complete(var/mob/living/M)
				if(M)
					M.take_toxin_damage(damage_counter + (rand(2,3)))


		harmful/chemilin
			name = "chemilin"
			id = "chemilin"
			description = "Discovered by A. S. Wonkington, on a friday the 13th, during lunch break. This cheese compound is unbelievably lethal."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 50

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(rand(10,30) * mult)
				if(prob(percentmult(30, mult)))
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

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(2 * mult)
				M.losebreath += 5 * mult
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

			on_mob_life(var/mob/M, var/mult = 1) // -cogwerks. previous version
				if (!M) M = holder.my_atom
				M.take_toxin_damage(1.5 * mult)
				if (prob(8))
					M.emote("drool")
				if (prob(10))
					boutput(M, "<span class='alert'>You cannot breathe!</span>")
					M.losebreath += (1 * mult)
					M.emote("gasp")
				if (prob(8))
					boutput(M, "<span class='alert'>You feel horribly weak.</span>")
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
					M.take_toxin_damage(2 * mult)
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
			depletion_rate = 0.1
			var/counter = 1
			penetrates_skin = 1

			pooled()
				..()
				counter = 1

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
							boutput(M, "<span class='alert'><b>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</b></span>")
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
						else if (prob(8))
							M.emote(pick("drool","pale", "gasp"))
					if (11 to INFINITY)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 40 * mult))
						M.drowsyness  = max(M.drowsyness, 20)
						if (prob(20) && !M.stat)
							M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
						else if (prob(8))
							boutput(M, "<span class='alert'><b>You can't [pick("breathe", "move", "feel your legs", "feel your face", "feel anything")]!</b></span>")
							M.losebreath += (1 * mult)

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
			value = 4 // 1 1 1 heat

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				if (prob(10))
					M.reagents.add_reagent("histamine", rand(5,15) * mult)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",4)

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

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.TakeDamage("All", 0, 1 * mult, 0, DAMAGE_BURN)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",4)

		harmful/lipolicide
			name = "lipolicide"
			id = "lipolicide"
			description = "A compound found in many seedy dollar stores in the form of a weight-loss tonic."
			fluid_r = 240
			fluid_g = 255
			fluid_b = 240
			transparency = 215
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				// Used to do exactly this back in 2012 or so (Convair880).
				if (prob(10) && M.bioHolder && M.bioHolder.HasEffect("fat"))
					M.bioHolder.RemoveEffect("fat")

				if (!M.nutrition)
					switch(rand(1,3))
						if (1)
							boutput(M, "<span class='alert'>You feel hungry...</span>")
						if (2)
							M.take_toxin_damage(1 * mult)
							boutput(M, "<span class='alert'>Your stomach grumbles painfully!</span>")

				else
					if (prob(60))
						var/fat_to_burn = max(round(M.nutrition/100,1) * mult, 5)
						M.nutrition = max(M.nutrition-fat_to_burn,0)
				..()
				return

			reaction_blob(var/obj/blob/B, var/volume)
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
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("r_initropidril", 33)
				return

			on_remove()
				if (remove_buff)
					if(ismob(holder?.my_atom))
						var/mob/M = holder.my_atom
						M.remove_stam_mod_regen("r_initropidril")
				return

			on_mob_life(var/mob/living/M, var/mult = 1)

				if (!M) M = holder.my_atom
				if (prob(33))
					M.take_toxin_damage(rand(5,25) * mult)
				if (prob(33))
					boutput(M, "<span class='alert'>You feel horribly weak.</span>")
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
				if (prob(10))
					boutput(M, "<span class='alert'>You cannot breathe!</span>")
					M.take_oxygen_deprivation(10 * mult)
					M.losebreath += (1 * mult)
				if (prob(10))
					boutput(M, "<span class='alert'>Your chest is burning with pain!</span>")
					M.take_oxygen_deprivation(10 * mult)
					M.losebreath += (1 * mult)
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
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

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (!data) data = 1
				else data += 1 * mult

				var/col = min(data * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1 * mult)

				switch(data)
					if (1 to 8)
						if (prob(33))
							boutput(M, "<span class='alert'>You feel weak.</span>")
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
					if (9 to 30)
						if (prob(33))
							boutput(M, "<span class='alert'><I>You feel very weak.</I></span>")
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
						if (prob(10))
							boutput(M, "<span class='alert'><I>You have trouble breathing!</I></span>")
							M.take_oxygen_deprivation(2 * mult)
							M.losebreath += (1 * mult)
					if (31 to 50)
						if (prob(33))
							boutput(M, "<span class='alert'><B>You feel horribly weak.</B></span>")
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 40 * mult))
						if (prob(10))
							boutput(M, "<span class='alert'><B>You cannot breathe!</B></span>")
							M.take_oxygen_deprivation(2 * mult)
							M.losebreath += (1 * mult)
						if (prob(10))
							boutput(M, "<span class='alert'><B>Your heart flutters in your chest!</B></span>")
							M.take_oxygen_deprivation(5 * mult)
							M.losebreath += (1 * mult)
							M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
					if (51 to INFINITY) //everything after
						var/obj/critter/domestic_bee/B = new/obj/critter/domestic_bee(M.loc)
						B.name = M.real_name
						B.desc = "This bee looks very much like [M.real_name]. How peculiar."
						B.beeKid = "#ffdddd"
						B.update_icon()
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

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (!data) data = 1
				else data += 1  * mult

				var/col = min(data * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder && H.organHolder.heart) // you can't barf up a bee heart if you ain't got no heart to barf
						switch (data)
							if (1 to 4)
								if (prob(33))
									boutput(H, "<span class='alert'>You feel weak.</span>")
									M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
							if (5 to 15)
								if (prob(33))
									boutput(H, "<span class='alert'><I>You feel very weak.</I></span>")
									M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
								if (prob(10))
									boutput(H, "<span class='alert'><I>You have trouble breathing!</I></span>")
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
							if (16 to 25)
								if (prob(33))
									boutput(H, "<span class='alert'><B>You feel horribly weak.</B></span>")
									M.setStatus("stunned", max(M.getStatusDuration("stunned"), 40 * mult))
								if (prob(10))
									boutput(H, "<span class='alert'><B>You cannot breathe!</B></span>")
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
								if (prob(10))
									boutput(H, "<span class='alert'><B>Your heart flutters in your chest!</B></span>")
									H.take_oxygen_deprivation(5 * mult)
									H.losebreath += (1 * mult)
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
							if (26 to INFINITY)

								var/obj/critter/domestic_bee/B

								if (H.organHolder.heart.robotic)
									B = new/obj/critter/domestic_bee/buddy(H.loc)
									H.remove_stam_mod_regen("heart")
									H.remove_stam_mod_max("heart")

								else
									B = new/obj/critter/domestic_bee(H.loc)

								B.name = "[H.real_name]'s heart"
								B.desc = "[H.real_name]'s heart is flying off. Better catch it quick!"
								B.beeMom = H
								B.beeKid = DEFAULT_BLOOD_COLOR
								B.update_icon()

								playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
								take_bleeding_damage(H, null, rand(10,30) * mult, DAMAGE_STAB)
								H.visible_message("<span class='alert'><B>A bee bursts out of [H]'s chest! Oh fuck!</B></span>", \
								"<span class='alert'><b>A bee bursts out of your chest! OH FUCK!</b></span>")
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

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom

				if (!data) data = 1
				else data+= 1 * mult

				var/col = min(data * 5, 255)
				M.color = rgb(255, 255, 255 - col)
				M.take_toxin_damage(1 * mult)

				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.organHolder && H.organHolder.heart) // you can't barf up a bee heart if you ain't got no heart to barf
						switch(data)
							if (1 to 4)
								if (prob(33))
									boutput(H, "<span class='alert'>You feel weak.</span>")
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 20 * mult))
							if (5 to 15)
								if (prob(33))
									boutput(H, "<span class='alert'><I>You feel very weak.</I></span>")
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 30 * mult))
								if (prob(10))
									boutput(H, "<span class='alert'><I>You have trouble breathing!</I></span>")
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
							if (16 to 25)
								if (prob(33))
									boutput(H, "<span class='alert'><B>You feel horribly weak.</B></span>")
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
								if (prob(10))
									boutput(H, "<span class='alert'><B>You cannot breathe!</B></span>")
									H.take_oxygen_deprivation(2 * mult)
									H.losebreath += (1 * mult)
								if (prob(10))
									boutput(H, "<span class='alert'><B>Your heart flutters in your chest!</B></span>")
									H.take_oxygen_deprivation(5 * mult)
									H.losebreath += (1 * mult)
									M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
							if (26 to INFINITY)

								var/obj/critter/domestic_bee/queen/B

								if (H.organHolder.heart.robotic)
									B = new/obj/critter/domestic_bee/queen/buddy(H.loc)

								else if (prob(5))
									B = new/obj/critter/domestic_bee/queen/big(H.loc)

								else
									B = new/obj/critter/domestic_bee/queen(H.loc)

								B.name = "[H.real_name]'s heart"
								B.desc = "[H.real_name]'s heart is flying off. What kind of heart problems did they have!?"
								B.beeMom = H
								B.beeKid = DEFAULT_BLOOD_COLOR
								B.update_icon()

								playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
								bleed(H, 500, 5) // you'll be gibbed in a moment you don't need it anyway
								H.visible_message("<span class='alert'><B>A huge bee bursts out of [H]! OH FUCK!</B></span>")
								qdel(H.organHolder.heart)
								H.gib()
				..()

			on_remove()
				if (holder.my_atom)
					holder.my_atom.color = "#ffffff"
				return ..()

		harmful/cholesterol
			name = "cholesterol"
			id = "cholesterol"
			description = "Pure cholesterol. Probably not very good for you."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 250
			fluid_b = 200
			transparency = 255
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("r_cholesterol", -10)
				return

			on_remove()
				if (remove_buff)
					if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_max"))
						holder.my_atom:remove_stam_mod_max("r_cholesterol")
				return

			on_mob_life(var/mob/living/M, var/mult = 1)

				if (!M) M = holder.my_atom
				//if (prob(5)) // this is way too annoying and ruins fried foods
					//boutput(M, "<span class='alert'>You feel [pick(</span>"weak","shaky","ill")]!")
					//M.stunned ++
				else if (holder.get_reagent_amount(src.id) >= 25 && prob(holder.get_reagent_amount(src.id)*0.15))
					boutput(M, "<span class='alert'>Your chest feels [pick("weird","uncomfortable","nasty","gross","odd","unusual","warm")]!</span>")
					M.take_toxin_damage(rand(1,2 * mult))
					if (prob(1))
						M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1) // path, name, strain, bypass resist
				else if (holder.get_reagent_amount(src.id) >= 45 && prob(holder.get_reagent_amount(src.id)*0.08))
					boutput(M, "<span class='alert'>Your chest [pick("hurts","stings","aches","burns")]!</span>")
					M.take_toxin_damage(rand(2,4) * mult)
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
					if (prob(5))
						M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1) // path, name, strain, bypass resist
				else if (holder.get_reagent_amount(src.id) >= 150 && prob(holder.get_reagent_amount(src.id)*0.01))
					boutput(M, "<span class='alert'>Your chest is burning with pain!</span>")
					//M.losebreath += (1 * mult) //heartfailure handles this just fine
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 30 * mult))
					M.contract_disease(/datum/ailment/malady/heartdisease, null, null, 1) // path, name, strain, bypass resist
				..()

			reaction_blob(var/obj/blob/B, var/volume)
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
				if (prob(25)) M.emote(pick("twitch", "laugh", "sneeze", "cry"))
				if (prob(20))
					boutput(M, "<span class='notice'><b>Something tickles!</b></span>")
					M.emote(pick("laugh", "giggle"))
				if (prob(15))
					M.visible_message("<span class='alert'><b>[M.name]</b> scratches at an itch.</span>")
					random_brute_damage(M, 1 * mult)
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
					M.emote("grumble")
				if (prob(10))
					boutput(M, "<span class='alert'><b>So itchy!</b></span>")
					random_brute_damage(M, 2 * mult)
				if (prob(6))
					M.reagents.add_reagent("histamine", rand(1,3) * mult)
				if (prob(2))
					boutput(M, "<span class='alert'><b><font size='[rand(2,5)]'>AHHHHHH!</font></b></span>")
					random_brute_damage(M,5 * mult)
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 60 * mult))
					M.make_jittery(6)
					M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor, scratching themselves violently!</span>")
					M.emote("scream")
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

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if (method == TOUCH && volume >= 10)
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/melted = 0
						if (!H.wear_mask && !H.head)
							H.TakeDamage("head", 0, min(max(8, (volume - 5) * 3), 75), 0, DAMAGE_BURN)
							H.emote("scream")
							boutput(H, "<span class='alert'>Your face has become disfigured!</span>")
							H.real_name = "Unknown"
							H.unlock_medal("Red Hood", 1)
							return
						else
							if (H.wear_mask)
								var/obj/item/clothing/mask/K = H.wear_mask
								if ( !K.acid_proof )
									boutput(M, "<span class='alert'>Your [H.wear_mask] melts away!</span>")
									K.dropped(H)
									H.u_equip(K)
									qdel(K)
								else
									boutput(M, "<span class='alert'>Your [H.wear_mask] protects you from the acid!</span>")
								melted = 1
							if (H.head)
								boutput(M, "<span class='alert'>Your [H.head] melts into uselessness!</span>")
								var/obj/item/clothing/head/D = H.head
								D.dropped(H)
								H.u_equip(D)
								qdel(D)
								melted = 1
							if (melted)
								return
					else
						random_brute_damage(M, min(15,volume))
				else if (method == TOUCH && volume <= 0 && prob(20))
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/melted = 0
						if (H.wear_mask && H.head)
							if (H.wear_mask)
								var/obj/item/clothing/mask/K = H.wear_mask
								if ( !K.acid_proof )
									boutput(M, "<span class='alert'>Your [H.wear_mask] melts away!</span>")
									K.dropped(H)
									H.u_equip(K)
									qdel(K)
								else
									boutput(M, "<span class='alert'>Your [H.wear_mask] protects you from the acid!</span>")
								melted = 1
							if (H.head)
								boutput(M, "<span class='alert'>Your [H.head] melts into uselessness!</span>")
								var/obj/item/clothing/head/D = H.head
								D.dropped(H)
								H.u_equip(D)
								qdel(D)
								melted = 1
							if (melted)
								return
				else if (volume >= 5)
					M.emote("scream")
					M.TakeDamage("All", 0, min(max(8, (volume - 5) * 4), 75), 0, DAMAGE_BURN)

				boutput(M, "<span class='alert'>The blueish acidic substance stings[volume < 5 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
				return

			reaction_obj(var/obj/O, var/volume)
				var/list/covered = holder.covered_turf()
				if (covered.len > 16)
					volume = (volume/covered.len)

				if (istype(O,/obj/fluid))
					return 1
				if (isitem(O) && volume > O:w_class)
					var/obj/decal/cleanable/molten_item/I = make_cleanable(/obj/decal/cleanable/molten_item,O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in AIviewers(5, O))
						boutput(M, "<span class='alert'>\the [O] melts.</span>")
					qdel(O)

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("acid",10)
				P.growth -= 5

			reaction_blob(var/obj/blob/B, var/volume)
				if (!blob_damage)
					return
				B.take_damage(blob_damage, volume, "mixed")

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
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0
				counter = 1

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("r_pancuronium", -30)
				return

			on_remove()
				if (remove_buff)
					if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_max"))
						holder.my_atom:remove_stam_mod_max("r_pancuronium")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 5)
						if (prob(10))
							M.emote(pick("drool", "tremble"))
					if (6 to 10)
						if (prob(8))
							boutput(M, "<span class='alert'><b>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</b></span>")
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
						else if (prob(8))
							M.emote(pick("drool", "tremble"))
					if (11 to INFINITY)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 200 * mult))
						if (prob(10))
							M.emote(pick("drool", "tremble", "gasp"))
							M.losebreath += (1 * mult)
						if (prob(9))
							boutput(M, "<span class='alert'><b>You can't [pick("move", "feel your legs", "feel your face", "feel anything")]!</b></span>")
						if (prob(7))
							boutput(M, "<span class='alert'><b>You can't breathe!</b></span>")
							M.losebreath+=3
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
				M.changeStatus("radiation", 50 * mult, 4)
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				if (prob(80)) P.HYPdamageplant("radiation",5)
				if (prob(25)) P.HYPmutateplant(1)

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
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0
				counter = 1

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("r_sodium_thiopental", -30)
				return

			on_remove()
				if (remove_buff)
					if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_max"))
						holder.my_atom:remove_stam_mod_max("r_sodium_thiopental")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1

				switch(counter+= (1 * mult))
					if (1)
						M.emote("drool")
						M.change_misstep_chance(5 * mult)
					if (2 to 4)
						M.drowsyness = max(M.drowsyness, 20)
					if (5)
						M.emote("faint")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
					if (6 to INFINITY)
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 50 * mult))

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
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0
				counter = 1

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("r_ketamine", -20)
				return

			on_remove()
				if (remove_buff)
					if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_max"))
						holder.my_atom:remove_stam_mod_max("r_ketamine")
				return

			on_mob_life(var/mob/M, var/mult = 1) // sped this up a bit due to mob loop changes
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += 1)
					if (1 to 5)
						if (prob(25)) M.emote("yawn")
					if (6 to 9)
						M.change_eye_blurry(10, 10)
						if (prob(35)) M.emote("yawn")
					if (10)
						M.emote("faint")
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
					if (11 to INFINITY)
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 250 * mult))

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
			blob_damage = 2

			pooled()
				..()
				remove_buff = 0
				counter = 1

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_max"))
					remove_buff = holder.my_atom:add_stam_mod_max("r_sulfonal", -10)
				return

			on_remove()
				if (remove_buff)
					if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_max"))
						holder.my_atom:remove_stam_mod_max("r_sulfonal")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				M.jitteriness = max(M.jitteriness-30,0)

				switch(counter+= (1 * mult))
					if (1 to 10)
						if (prob(7)) M.emote("yawn")
					if (11 to 20)
						M.drowsyness  = max(M.drowsyness, 20)
					if (21)
						M.emote("faint")
					if (22 to INFINITY)
						if (prob(20))
							M.emote("faint")
							M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 80 * mult))
						M.drowsyness  = max(M.drowsyness, 20)
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

			on_plant_life(var/obj/machinery/plantpot/P)
				P.HYPdamageplant("poison",1)

		harmful/spider_venom
			name = "venom"
			id = "venom"
			description = "An incredibly potent poison. Origin unknown."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 255
			fluid_b = 240
			transparency = 200
			depletion_rate = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				var/our_amt = holder.get_reagent_amount(src.id)
				if (prob(25))
					M.reagents.add_reagent("histamine", rand(5,10) * mult)
				if (our_amt < 20)
					M.take_toxin_damage(1 * mult)
					random_brute_damage(M, 1 * mult)
				else if (our_amt < 40)
					if (prob(8))
						M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						M.vomit()
					M.take_toxin_damage(2 * mult)
					random_brute_damage(M, 2 * mult)

				if (our_amt > 40 && prob(4))
					M.visible_message("<span class='alert'><B>[M]</B> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
					M.setStatus("weakened", max(M.getStatusDuration("weakened"), 150 * mult))
					M.make_jittery(1000)
					SPAWN_DBG(rand(20, 100))
						if (M) //ZeWaka: Fix for null.gib
							M.gib()
					return

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
			var/fainted = 0
			blob_damage = 1
			value = 4 // 3c + heat

			pooled()
				..()
				counter = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				if (!counter) counter = 1
				switch(counter += (1 * mult))
					if (1 to 4)
						return // let's not be incredibly obvious about who stung you for changelings
					if (5 to 10)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(10 * mult)
						if (prob(20)) M.emote("drool")
					if (11 to 17)
						M.drowsyness  = max(M.drowsyness, 10)
						M.make_dizzy(1 * mult)
						M.change_misstep_chance(20 * mult)
						if (prob(35)) M.emote("drool")
					if (18 to INFINITY)
						if (!fainted)
							M.emote("faint")
					if (19 to INFINITY)
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 100 * mult))
						M.drowsyness  = max(M.drowsyness, 20)

				M.jitteriness = max(M.jitteriness-30,0)
				if (M.get_brain_damage() <= 80)
					M.take_brain_damage(1 * mult)
				else
					if (prob(10)) M.take_brain_damage(1 * mult) // let's slow down a bit after 80
				M.take_toxin_damage(1 * mult)
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
				src = null
				if ( (method==TOUCH && prob((3 * volume) + 2)) || method==INGEST)
					M.bioHolder.RandomEffect("bad")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.changeStatus("radiation", 30 * mult, 1)
				var/mutChance = 4
				if (M.traitHolder && M.traitHolder.hasTrait("stablegenes")) mutChance = 2
				if (prob(mutChance))
					M.bioHolder.RandomEffect("bad")
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				/*if (prob(80)) P.growth -= rand(1,2)
				if (prob(16)) P.HYPmutateplant(1)*/
				if (prob(40) && P.growth > 1)
					P.growth--
				if (prob(24))
					P.HYPmutateplant(1)

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
				src = null
				if ( (method==TOUCH && prob((5 * volume) + 1)) || method==INGEST)
					M.bioHolder.RandomEffect("bad")
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.changeStatus("radiation", 20 * mult)
				// DNA buckshot
				var/mutChance = 15
				if (M.traitHolder && M.traitHolder.hasTrait("stablegenes")) mutChance = 7
				if (prob(mutChance))
					M.bioHolder.RandomEffect("bad")
				if (prob(3))
					M.bioHolder.RandomEffect("good")
				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				P.growth -= rand(1,2)
				P.HYPmutateplant(1)

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
			name = "Aconitum"
			id = "wolfsbane"
			description = "Also known as monkshood or wolfsbane, aconitum is a very potent neurotoxin."
			reagent_state = LIQUID
			fluid_r = 129
			fluid_b = 116
			fluid_g = 198
			transparency = 20

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				M.take_toxin_damage(2)
				if (prob(4))
					M.emote("drool")
				if (prob(8))
					boutput(M, "<span class='alert'>You cannot breathe!</span>")
					M.losebreath += (1 * mult)
					M.emote("gasp")
				if (prob(10))
					boutput(M, "<span class='alert'>You feel horribly weak.</span>")
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
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

			on_mob_life(var/mob/M, var/mult = 1)

				if (!M) M = holder.my_atom
				if (prob(10))
					M.take_toxin_damage(rand(2.4) * mult)
				if (prob(7))
					boutput(M, "<span class='alert'>A horrible migraine overpowers you.</span>")
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
				if (prob(7))
					for(var/mob/O in AIviewers(M, null))
						O.show_message("<span class='alert'>[M] vomits up some green goo.</span>", 1)
					playsound(M.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
					make_cleanable( /obj/decal/cleanable/greenpuke,M.loc)
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
				if (prob(20)) M.emote(pick("twitch", "grumble", "sneeze", "cough"))
				if (prob(10))
					boutput(M, "<span class='notice'><b>Your eyes itch.</b></span>")
					M.emote(pick("blink", "sneeze"))
					M.change_eye_blurry(3, 3)
				if (prob(10))
					M.visible_message("<span class='alert'><b>[M.name]</b> scratches at an itch.</span>")
					random_brute_damage(M, 1 * mult)
					M.emote("grumble")
				if (prob(5))
					boutput(M, "<span class='alert'><b>You're getting a rash!</b></span>")
					random_brute_damage(M, 2 * mult)

				// Hyperallergic
				if(M.traitHolder.hasTrait("allergic"))
					holder.add_reagent(src.id, src.depletion_rate * 10 + src.volume/10)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if (method == TOUCH)
					M.reagents.add_reagent("histamine", min(10,volume * 2))
					M.make_jittery(10)
				else
					boutput(M, "<span class='alert'><b>You feel a burning sensation in your throat...</span>")
					M.make_jittery(30)
					M.emote(pick("drool"))
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						boutput(M, "<span class='alert'><b>You feel mucus running down the back of your throat.</b></span>")
						M.take_toxin_damage(1 * mult)
						M.make_jittery(4)
						M.emote("sneeze", "cough")
					else if (effect <= 4)
						M.stuttering += rand(0,5)
						if (prob(25))
							M.emote(pick("choke","gasp"))
							M.take_oxygen_deprivation(5 * mult)
					else if (effect <= 7)
						boutput(M, "<span class='alert'><b>Your chest hurts!</b></span>")
						M.emote(pick("cough","gasp"))
						M.take_oxygen_deprivation(3 * mult)
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]<b> breaks out in hives!</span>")
						random_brute_damage(M, 6 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> has a horrible coughing fit!</span>")
						M.make_jittery(10)
						M.stuttering += rand(0,5)
						M.emote("cough")
						if (prob(40))
							M.emote(pick("choke","gasp"))
							M.take_oxygen_deprivation(6 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 80 * mult))
					else if (effect <= 7)
						boutput(M, "<span class='alert'><b>Your heartbeat is pounding inside your head!</b></span>")
						M.playsound_local(M.loc, "heartbeat.ogg", 50, 1)
						M.emote("collapse")
						M.take_oxygen_deprivation(8 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
						M.emote(pick("choke", "gasp"))
						boutput(M, "<span class='alert'><b>You feel like you're dying!</b></span>")

		harmful/sarin // yet another thing that will put ol' cogwerks on a watch list probably
			name = "sarin"
			id = "sarin"
			description = "A lethal organophosphate nerve agent. Can be neutralized with atropine."
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

			pooled()
				..()
				counter = 1

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom

				var/progression_speed = 1
				if(M.reagents.has_reagent("epinephrine"))
					progression_speed = 0.8

				switch(counter+= (progression_speed * mult))
					if (1 to 15)
						M.make_jittery(20)
						if (prob(20))
							M.emote(pick("twitch","twitch_v","quiver"))
					if (16 to 30)
						if (prob(25))
							M.emote(pick("twitch","twitch_v","drool","quiver","tremble"))
						M.change_eye_blurry(5, 5)
						M.stuttering = max(M.stuttering, 5)
						if (prob(10))
							M.change_misstep_chance(15 * mult)
						if (prob(15))
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
							if (!isdead(M))
								M.emote("scream")
					if (30 to 60)
						M.change_eye_blurry(5, 5)
						M.stuttering = max(M.stuttering, 5)
						if (prob(10))
							M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
							M.emote(pick("twitch","twitch_v","drool","shake","tremble"))
						if (prob(5))
							M.emote("collapse")
						if (prob(5))
							M.setStatus("weakened", max(M.getStatusDuration("weakened"), 40 * mult))
							M.visible_message("<span class='alert'><b>[M] has a seizure!</b></span>")
							M.make_jittery(1000)
						if (prob(5))
							boutput(M, "<span class='alert'><b>You can't breathe!</b></span>")
							M.emote(pick("gasp", "choke", "cough"))
							M.losebreath += (1 * mult)
					if (61 to INFINITY)
						if (prob(15))
							M.emote(pick("gasp", "choke", "cough","twitch", "shake", "tremble","quiver","drool", "twitch_v","collapse"))
						M.losebreath = max(5, M.losebreath + (5 * mult))
						M.take_toxin_damage(1 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 50 * mult))
				if (prob(8))
					M.visible_message("<span class='alert'>[M] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
					M.vomit()
				M.take_toxin_damage(1 * mult)
				M.take_brain_damage(1 * mult)
				M.TakeDamage("chest", 0, 1 * mult, 0, DAMAGE_BURN)
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
			pathogen_nutrition = list("dna_mutagen")

			var/tmp/progress_timer = 1

			pooled()
				..()
				progress_timer = 1


			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				//M.changeStatus("radiation", 30, 1)
				if (!src.data) // Pull bioholder data from blood that's in the same reagentholder
					if(holder.has_reagent("bloodc"))
						var/datum/reagent/blood/cheating = holder.reagent_list["bloodc"]
						if (cheating && istype(cheating.data, /datum/bioHolder))
							src.data = cheating.data
					else if(holder.has_reagent("blood"))
						var/datum/reagent/blood/cheating = holder.reagent_list["blood"]
						if (cheating && istype(cheating.data, /datum/bioHolder))
							src.data = cheating.data

				if (src.data && M.bioHolder && progress_timer <= 10)

					M.bioHolder.StaggeredCopyOther(data, progress_timer+=(1 * mult))
					if (prob(50) && progress_timer > 7)
						boutput(M, "<span class='notice'>You feel a little [pick("unlike yourself", "out of it", "different", "strange")].</span>")
					if (progress_timer > 10)
						M.real_name = M.bioHolder.ownerName
						M.UpdateName()

				..()
				return

			on_plant_life(var/obj/machinery/plantpot/P)
				if (prob(80)) P.growth -= rand(1,3)
				if (prob(16)) P.HYPmutateplant(1)

		harmful/madness_toxin
			name = "Rajaijah"
			id = "madness_toxin"
			description = "A synthetic version of a potent neurotoxin derived from plants capable of driving a person to madness. First discovered in India by a Belgian reporter in 1931."
			reagent_state = LIQUID
			fluid_r = 157
			fluid_g = 206
			fluid_b = 69
			transparency = 255
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

			pooled()
				..()
				lastSpook = 0
				lastSpookLen = 0
				ai_was_active = 0

			unpooled()
				..()
				data = 0
				t1 = initial(t1)
				t2 = initial(t2)
				t3 = initial(t3)
				t4 = initial(t4)
				t5 = initial(t5)
				t6 = initial(t6)
				t7 = initial(t7)
				t8 = initial(t8)
				t9 = initial(t9)
				t10 = initial(t10)


			//MBC : you may be wondering why this looks so weird
			//we need to proc tiered effects IN ORDER, even if they were skipped! that is why! also im bad but this works fine its just harder to read than the OG way ok
			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				var/mob/living/carbon/human/H = M
				if (!istype(H)) return

				data+=(1 * mult)

				if (t1 && data >= t1)
					if (prob(33))
						H.drowsyness = max(H.drowsyness,4)
						H.show_text(pick_string("chemistry_reagent_messages.txt", "madness0"), "red")
					if (prob(10)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e0"))

				if (t2 && data >= t2)
					t1 = 0
					if (prob(33))
						H.drowsyness = max(H.drowsyness,7)
						H.show_text(pick_string("chemistry_reagent_messages.txt", "madness1"), "blue")
					if (prob(10)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e1"))

				if (t3 && data >= t3)
					t2 = 0
					if (prob(33))
						H.drowsyness = max(H.drowsyness,7)
						H.make_jittery(300)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness2")]</B>", "red")
						if (prob(33) && world.time > lastSpook + lastSpookLen)
							var/spook = pick(spooksounds)
							H.playsound_local(H, spook, 50, 1)
							lastSpookLen = spooksounds[spook]
							lastSpook = world.time

					if (prob(15)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

				if (t4 && data >= t4)
					t3 = 0
					H.show_text("<B>Your mind feels clearer.<B>", "blue")
					H.drowsyness = 0

				if (t5 && data >= t5)
					t4 = 0
					H.show_text("<font size=+2><B>IT HURTS!!</B></font>","red")
					H.emote("scream")
					ai_was_active = H.ai_active
					H.ai_init() //:getin:
					H.ai_aggressive = 1 //Fak
					logTheThing("combat", H, null, "has their AI enabled by [src.id]")
					H.playsound_local(H, 'sound/effects/Heart Beat.ogg', 50, 1)
					lastSpook = world.time

				if (t6 && data >= t6)
					t5 = 0
					if (prob(33))
						H.make_jittery(600)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness3")]</B>", "red")

					if (prob(33)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

					if (prob(20) && world.time > lastSpook + 510)
						H.show_text("You feel your heartbeat pounding inside your head...", "red")
						H.playsound_local(H, 'sound/effects/Heart Beat.ogg', 75, 1) // LOUD
						lastSpook = world.time


					//POWER UP!!
				if (t7 && data >= t7)
					t6 = 0
					H.add_stam_mod_regen(src.id, 100) //Buff
					H.show_text("You feel very buff!", "red")

				if (t8 && data >= t8)
					t7 = 0

					if (prob(20)) //The AI is in control now.
						H.change_misstep_chance(100 * mult)
						H.show_text("You can't seem to control your legs!", "red")

					if (prob(10)) //Stronk
						H.show_text("You feel strong!", "red")
						H.delStatus("weakened")
						H.delStatus("stunned")
						H.delStatus("paralysis")
						H.delStatus("disorient")

				if (t9 && data >= t9)
					t8 = 0
					H.ai_suicidal = 1
					H.show_text("Death... I can only stop this by dying...", "red")

				if (t10 && data > t10)
					t9 = 0
					if (prob(33))
						H.make_jittery(600)
						H.show_text("<B>[pick_string("chemistry_reagent_messages.txt", "madness3")]</B>", "red")

					if (prob(33)) H.emote(pick_string("chemistry_reagent_messages.txt", "madness_e2"))

					if (prob(20) && world.time > lastSpook + 510)
						H.show_text("You feel your heartbeat pounding inside your head...", "red")
						H.playsound_local(H, 'sound/effects/Heart Beat.ogg', 100, 1) // LOUD
						lastSpook = world.time


					//POWER UP!!
					if (prob(20)) //The AI is in control now.
						H.change_misstep_chance(100 * mult)
						H.show_text("You can't seem to control your legs!", "red")

					if (prob(20)) //V. Stronk
						H.show_text("You feel strong!", "red")
						H.delStatus("weakened")
						H.delStatus("stunned")
						H.delStatus("paralysis")
						H.delStatus("disorient")

				H.take_brain_damage(0.5 * mult)

				..()
			on_remove()
				if (holder && holder.my_atom && ishuman(holder.my_atom))
					var/mob/living/carbon/human/H = holder.my_atom
					// moving the 'turn off the ai' part here because it failed
					// to actually deactivate, leaving it on forever
					//if(!ai_was_active)
					H.ai_stop()
					H.ai_aggressive = initial(H.ai_aggressive)
					H.ai_suicidal = 0
					if (data >= 30)
						H.remove_stam_mod_regen(src.id) //Not so buff
						logTheThing("combat", H, null, "has their AI disabled by [src.id]")
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

			on_mob_life(var/mob/M, var/mult = 1)

				var/mob/living/carbon/human/H = M
				if (!istype(H)) return

				switch(data+=(1 * mult))

					if(2) //Just started out. Everything's cool
						H.add_stam_mod_max(src.id, 75)
					if(3 to 14)
						if(prob(10)) do_stuff(0, H, mult)

					if(15 to 24) //Ok, now it's getting worrying
						if(prob(30)) do_stuff(1, H, mult)
					if(25)
						H.remove_stam_mod_max(src.id)
						H.add_stam_mod_max(src.id, -50)
						H.add_stam_mod_regen(src.id, -2)
					if(26 to 35)
						if(prob(30)) do_stuff(2, H, mult)
					if(36 to INFINITY)
						if(prob(min(data, 100))) //Start at 30% chance of bad stuff, increase until death
							do_stuff(3, H, mult)

				..()

			on_remove()
				..()
				var/mob/living/carbon/human/H = holder.my_atom
				if (!istype(H)) return
				H.remove_stam_mod_max(src.id)
				H.remove_stam_mod_regen(src.id)


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
								H.changeStatus("stunned", 10 * mult)
							if(5) //Trip
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine1c"), "red")
								H.changeStatus("weakened", 20 * mult)
							if(6) //Light-headedness
								H.show_text("You feel light-headed.", "red")
								H.drowsyness += rand(2,4)

					if(2) //I don't feel so good (tripping, hard time breathing, randomly dropping stuff)
						switch(rand(1,4))
							if(1) //Chest-heaviness
								H.show_text("Your chest feels heavy.", "red")
								H.emote(pick("gasp", "choke", "cough"))
								H.losebreath += (1 * mult)
								H.oxyloss += rand(5, 10) * mult
							if(2) //Drop stuff
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine2"), "red")
								H.changeStatus("stunned", 20 * mult)
								H.change_misstep_chance(20 * mult)
							if(3) //Trip
								H.show_text(pick_string("chemistry_reagent_messages.txt", "strychnine2b"), "red")
								H.visible_message("<span class='combat bold'>[H] stumbles and falls!</span>")
								if(prob(10)) H.emote("scream")
								H.changeStatus("weakened", 20 * mult)
							if(4) //Light-headedness
								H.show_text("You feel like you are about to faint!", "red")
								H.drowsyness += rand(4,7)
								if(prob(20)) H.emote(pick("faint", "collapse"))
						if(prob(30))
							H.make_jittery(15)
				if(severity > 2)
					if(prob(min(data+10, 100))) //Stun, twitch, 50% chance ramps up to 100 after
						H.make_jittery(50)

						H.changeStatus("weakened", 2 SECONDS)

						if(prob(90)) H.visible_message("<span class='combat bold'>[H][pick_string("chemistry_reagent_messages.txt", "strychnine_deadly")]</span>")
						if(prob(70)) playsound(H.loc, pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_noises"),50,1)

						if(prob(50))
							H.emote("scream") //It REALLY hurts
							H.TakeDamage(zone="All", brute=rand(2,5) * mult)

					if(prob(clamp(data/1.5, 100, 30))) //At least 30% risk of oxy damage
						if(prob(50))H.emote(pick("gasp", "choke", "cough"))
						H.losebreath += rand(1,3) * mult

					if(prob(25))
						H.emote(pick_string("chemistry_reagent_messages.txt", "strychnine_deadly_emotes"))

					if(prob(10))
						H.visible_message("<span class='alert'>[H] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
						H.vomit()
					else if (prob(5))
						var/damage = rand(1,10)
						H.visible_message("<span class='alert'>[H] [damage > 3 ? "vomits" : "coughs up"] blood!</span>", "<span class='alert'>You [damage > 3 ? "vomit" : "cough up"] blood!</span>")
						playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
						H.TakeDamage(zone="All", brute=damage)
						bleed(H, damage * 2 * mult, 3)

