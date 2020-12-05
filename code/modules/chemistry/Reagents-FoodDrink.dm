//Contains reagents related to eating or drinking.

ABSTRACT_TYPE(/datum/reagent/fooddrink)
ABSTRACT_TYPE(/datum/reagent/fooddrink/alcoholic)
ABSTRACT_TYPE(/datum/reagent/fooddrink/temp_bioeffect)

datum
	reagent
		fooddrink/
			name = "food drink stuff"
			viscosity = 0.05

		fooddrink/bilk
			name = "bilk"
			id = "bilk"
			fluid_r = 147
			fluid_g = 100
			fluid_b = 65
			transparency = 240
			taste = "vile"
			depletion_rate = 0.075
			description = "This appears to be beer mixed with milk."
			reagent_state = LIQUID
			value = 2
			thirst_value = 0.4
			bladder_value = -0.2
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1) //temp
				if(!M) M = holder.my_atom
				if(M.losebreath > 10)
					M.losebreath = max(10, M.losebreath-(10 * mult))
				if(M.get_oxygen_deprivation() > 85)
					M.take_oxygen_deprivation(-10 * mult)
				if((M.health + M.losebreath) < 0)
					if(M.get_toxin_damage())
						M.take_toxin_damage(-1 * mult)
					M.HealDamage("All", 1 * mult, 1 * mult)
				..()
				return

		fooddrink/milk
			name = "milk"
			id = "milk"
			description = "An opaque white liquid produced by the mammary glands of mammals."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_b = 255
			fluid_g = 255
			transparency = 255
			thirst_value = 0.6
			bladder_value = -0.2
			viscosity = 0.3

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (M.get_toxin_damage() <= 25)
					M.take_toxin_damage(-1 * mult)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (bone_system)
						for (var/obj/item/organ/O in H.organs)
							if (O.bones)
								O.bones.repair_damage(1 * mult)
					if(H.mob_flags & IS_BONER)
						M.HealDamage("All", 2 * mult, 2 * mult, 1 * mult)
						if(probmult(15))
							boutput(H, "<span class='notice'>The milk comforts your [pick("boanes","bones","bonez","boens","bowns","beaunes","brones","bonse")]!</span>")
				if (M.reagents.has_reagent("capsaicin"))
					M.reagents.remove_reagent("capsaicin", 5 * mult)
				..()
				return

		fooddrink/milk/chocolate_milk
			name = "chocolate milk"
			id = "chocolate_milk"
			fluid_r = 133
			fluid_g = 67
			fluid_b = 44
			transparency = 255
			taste = "chocolatey"
			description = "Chocolate-flavored milk, tastes like being a kid again."
			reagent_state = LIQUID
			thirst_value = 0.75
			value = 3 // 1 2

		fooddrink/milk/strawberry_milk
			name = "strawberry milk"
			id = "strawberry_milk"
			fluid_r = 248
			fluid_g = 196
			fluid_b = 196
			transparency = 255
			taste = "like strawberries"
			description = "Strawberry-flavored milk, tastes like being a kid again."
			reagent_state = LIQUID
			thirst_value = 0.75
			value = 3 // 1 2

		fooddrink/alcoholic
			name = "alcoholic reagent parent"
			id = "alcoholic_parent"
			description = "You shouldn't be seeing this ingame. If you do, report it to a coder."
			reagent_state = LIQUID
			taste = "confusing"
			fluid_r = 133
			fluid_g = 64
			fluid_b = 27
			transparency = 190
			var/alch_strength = 0.07
			bladder_value = -0.15
			thirst_value = 0.4
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.reagents.add_reagent("ethanol", alch_strength * mult)
				M.reagents.remove_reagent(src, 1 * mult)
				..()
				return

			on_add()
				if(!istype(holder) || !istype(holder.my_atom) || !ishuman(holder.my_atom))
					return
				var/mob/living/carbon/human/H = holder.my_atom
				if(H.bioHolder.age < 21) // Yes. Its 21. This is Space America. That is canon now.
					if(seen_by_camera(H))
					// determine the name of the perp (goes by ID if wearing one)
						var/perpname = H.name
						if(H:wear_id && H:wear_id:registered)
							perpname = H:wear_id:registered
						// find the matching security record
						for(var/datum/data/record/R in data_core.general)
							if(R.fields["name"] == perpname)
								for (var/datum/data/record/S in data_core.security)
									if (S.fields["id"] == R.fields["id"])
										// now add to rap sheet
										S.fields["criminal"] = "*Arrest*"
										S.fields["mi_crim"] = "Underage drinking."

									break

		fooddrink/alcoholic/beer
			name = "beer"
			id = "beer"
			description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
			reagent_state = LIQUID
			taste = "hoppy"

			fluid_r = 133
			fluid_g = 64
			fluid_b = 27
			transparency = 190
			minimum_reaction_temperature = -INFINITY

			reaction_temperature(exposed_temperature, exposed_volume)
				if(exposed_temperature <= T0C + 7)
					name = "Chilled Beer"
					description = "A nice chilled beer. Perfect!"
					taste = "nicely cool and hoppy"
				else if (exposed_temperature > T0C + 30)
					name = "Warm Beer"
					description = "Warm Beer. Ughhh, this is disgusting."
					taste = "grossly warm and hoppy"
				else
					name = "Beer"
					description = initial(description)
					taste = initial(taste)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/mult = 1)
				var/mytemp = holder.total_temperature
				src = null
				if(!volume_passed) return 1
				if(method == INGEST)
					if(mytemp <= T0C+7) //Nice & cold.
						if(M.get_toxin_damage())
							M.take_toxin_damage(-5 * mult)
						if (prob(25)) boutput(M, "<span class='notice'>Nice and cold! How refreshing!</span>")
					else if (mytemp > T0C + 30) //Warm & disgusting.
						M.emote("frown")
						boutput(M, "<span class='alert'>This beer is all warm and nasty. Ugh.</span>")
					return 0
				return 1

		fooddrink/alcoholic/cider
			name = "cider"
			id = "cider"
			fluid_r = 8
			fluid_g = 65
			fluid_b = 7
			alch_strength = 0.06
			description = "An alcoholic beverage derived from apples."
			reagent_state = LIQUID

		fooddrink/alcoholic/mead
			name = "mead"
			id = "mead"
			fluid_r = 8
			fluid_g = 65
			fluid_b = 7
			alch_strength = 0.3
			description = "An alcoholic beverage derived from honey."
			reagent_state = LIQUID
			viscosity = 0.4

		fooddrink/alcoholic/wine
			name = "wine"
			id = "wine"
			fluid_r = 161
			fluid_g = 71
			fluid_b = 231
			alch_strength = 0.13
			description = "An alcoholic beverage derived from grapes."
			reagent_state = LIQUID
			taste = "sweet"
			viscosity = 0.3

		fooddrink/alcoholic/wine/white
			name = "white wine"
			id = "white_wine"
			fluid_r = 252
			fluid_g = 168
			fluid_b = 177

		fooddrink/alcoholic/champagne
			name = "champagne"
			id = "champagne"
			fluid_r = 251
			fluid_g = 140
			fluid_b = 108
			alch_strength = 0.12
			description = "A fizzy alcoholic beverage derived from grapes, made in Champagne, France."
			reagent_state = LIQUID
			taste = "sweet"

		fooddrink/alcoholic/rum
			name = "rum"
			id = "rum"
			fluid_r = 240
			fluid_g = 120
			fluid_b = 30
			alch_strength = 0.6
			description = "An alcoholic beverage derived from sugar."
			reagent_state = LIQUID
			viscosity = 0.4

		fooddrink/alcoholic/vodka
			name = "vodka"
			id = "vodka"
			fluid_r = 165
			fluid_g = 255
			fluid_b = 255
			transparency = 20
			alch_strength = 0.5
			description = "A strong alcoholic beverage derived from potatoes."
			reagent_state = LIQUID
			taste = "smooth"

		fooddrink/alcoholic/bourbon
			name = "bourbon"
			id = "bourbon"
			fluid_r = 240
			fluid_g = 120
			fluid_b = 30
			alch_strength = 0.45
			description = "An alcoholic beverage derived from maize."
			reagent_state = LIQUID

		fooddrink/alcoholic/tequila
			name = "tequila"
			id = "tequila"
			fluid_r = 255
			fluid_g = 252
			fluid_b = 144
			alch_strength = 0.6
			description = "A somewhat notorious liquor made from agave. One tequila, two tequila, three tequila, floor."
			reagent_state = LIQUID

		fooddrink/alcoholic/ricewine
			name = "rice wine"
			id = "ricewine"
			fluid_r = 239
			fluid_g = 237
			fluid_b = 198
			alch_strength = 0.15
			description = "An alcoholic beverage derived from fermented rice."
			reagent_state = LIQUID

		fooddrink/alcoholic/boorbon
			name = "BOOrbon"
			id = "boorbon"
			fluid_r = 121
			fluid_g = 171
			fluid_b = 121
			alch_strength = 0.6
			description = "An alcoholic beverage derived from maize.  Also ghosts."
			taste = "spooky"
			viscosity = 0.4

		fooddrink/alcoholic/beepskybeer
			name = "Beepskybräu Security Schwarzbier"
			id = "beepskybeer"
			description = "A dark German beer, typically served with dark bread, cream cheese, and an intense appreciation for the law."
			reagent_state = LIQUID
			taste = "lawful"
			bladder_value = -2
			fluid_r = 61
			fluid_g = 57
			fluid_b = 56
			transparency = 200
			alch_strength = 0.1 //stronger than regular beer; fortified by the LAW
			viscosity = 0.3

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M)
					M = holder.my_atom

				var/obj/vehicle/V = M.loc
				if (istype(V) && V.rider == M)
					boutput(M, "<b><font color=red face=System>DRUNK DRIVING IS A CRIME</font></b>")
					boutput(M, "<span class='alert'>You feel a paralyzing shock in your lower torso!</span>")
					M << sound('sound/impact_sounds/Energy_Hit_3.ogg', repeat = 0, wait = 0, volume = 50, channel = 0)
					M.changeStatus("weakened", 2 SECONDS) //No hulk immunity when the stun is coming from inside your liver, ok .I
					M.stuttering = 10
					M.changeStatus("stunned", 10 SECONDS)

					M.Virus_ShockCure(33)
					M.shock_cyberheart(33)

					V.eject_rider(1,0)


				else if (istype(V, /obj/machinery/vehicle)) //if somebody adds /obj/item/vehicle, I'm killing myself.
					var/obj/machinery/vehicle/MV = V
					if (MV.pilot == M)
						boutput(M, "<b><font color=red face=System>DRUNK DRIVING IS A CRIME</font></b>")
						boutput(M, "<span class='alert'>You feel a paralyzing shock in your lower torso!</span>")
						M << sound('sound/impact_sounds/Energy_Hit_3.ogg', repeat = 0, wait = 0, volume = 50, channel = 0)
						M.changeStatus("weakened", 2 SECONDS)
						M.stuttering = 10
						M.changeStatus("stunned", 10 SECONDS)

						M.Virus_ShockCure(33)
						M.shock_cyberheart(33)

						MV.eject(M)

				..()
				return

		fooddrink/alcoholic/moonshine
			name = "moonshine"
			id = "moonshine"
			description = "An illegaly brewed and highly potent alcoholic beverage."
			reagent_state = LIQUID
			value = 5
			taste = "painfully strong"

			fluid_r = 165
			fluid_g = 65
			fluid_b = 30
			transparency = 190
			alch_strength = 5
			depletion_rate = 0.2

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed) return
				if(method == INGEST)
					if(M.client && (istraitor(M) || isspythief(M)))
						M.reagents.add_reagent("omnizine",10)
						M.reagents.del_reagent("moonshine")
						return

		fooddrink/alcoholic/bojack // Bar Contest Winner's Drink
			name = "Bo Jack Daniel's"
			id = "bojack"
			description = "A strong beverage. Drinking this will put hair on your chest. Maybe."
			reagent_state = LIQUID
			alch_strength = 5
			value = 0.25 //most of the alcohol content is handled below
			taste = "manly"

			fluid_r = 130
			fluid_g = 65
			fluid_b = 30
			transparency = 190
			on_mob_life(var/mob/target, var/mult = 1)
				if(!target) target = holder.my_atom
				var/mob/living/carbon/human/M = target
				if (!istype(M))
					return

				if (probmult(8) && (M.gender == "male"))
					if (M.cust_two_state != "gt" && M.cust_two_state != "neckbeard" && M.cust_two_state != "fullbeard" && M.cust_two_state != "longbeard")
						M.cust_two_state = pick("gt","neckbeard","fullbeard","longbeard")
						M.set_face_icon_dirty()
						boutput(M, "<span class='notice'>You feel manly!</span>")

				if (probmult(8))
					M.say(pick("God Jesus what the fuck.",\
					"It's just like, damn, man.",\
					"I remember playing the banana game at boarding school.",\
					"It's kinda hard knowing you've nothing to go home to except a crater.",\
					"The only good hug is a dead hug.",\
					"Tried to fart stealthily in class. Sharted. Why the hell do you think my suit is brown?",\
					"I remember my first holiday away from my parents. Costa Concordia, the ship was called.",\
					"Cry because it's over, don't smile because it happened.",\
					"They say when you are missing someone that they are probably feeling the same, but I don't think it's possible for you to miss me as much as I'm missing you right now.",\
					"Why do beautiful songs make you sad? Because they aren't true.",\
					"Tears are words that need to be written.",\
					"I'm lonely. And I'm lonely in some horribly deep way and for a flash of an instant, I can see just how lonely, and how deep this feeling runs. And it scares the shit out of me to be this lonely because it seems catastrophic.",\
					"Someday, we'll run into each other again, I know it. Maybe I'll be older and smarter and just plain better. If that happens, that's when I'll deserve you. But now, at this moment, you can't hook your boat to mine, because I'm liable to sink us both.",\
					"There you go...let it all slide out. Unhappiness can't stick in a person's soul when it's slick with tears.",\
					"I was in the biggest breakdown of my life when I stopped crying long enough to let the words of my epiphany really sink in. That whore, karma had finally made her way around and had just bitch-slapped me right across the face. The realization only made me cry harder.",\
					"I waste at least an hour every day lying in bed. Then I waste time pacing. I waste time thinking. I waste time being quiet and not saying anything because I'm afraid I'll stutter."))
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed) return
				if(method == INGEST)
					var/alch = volume_passed * 0.75
					M.reagents.add_reagent("ethanol", alch)
					if(isliving(M))
						var/mob/living/H = M
						if (isalcoholresistant(H))
							return
						if (volume_passed + H.reagents.get_reagent_amount("bojack") > 10)

							boutput(M, "<span class='alert'>Oh god, this stuff is far too manly to keep down...!</span>")
							SPAWN_DBG(pick(30,50,70))
								M.visible_message("<span class='alert'>[M] pukes everywhere and passes out!</span>")
								M.vomit()
								M.reagents.del_reagent("bojack")
								M.changeStatus("paralysis", 30)

		fooddrink/alcoholic/cocktail_screwdriver
			name = "Screwdriver"
			id = "screwdriver"
			description = "A tangy mixture of vodka and orange juice."
			reagent_state = LIQUID
			taste = "sweet"
			fluid_r = 252
			fluid_g = 163
			fluid_b = 30
			transparency = 190
			alch_strength = 0.25 //half vodka by content, half vodka strength

		fooddrink/alcoholic/cocktail_bloodymary
			name = "Bloody Mary"
			id = "bloody_mary"
			description = "Mixed tomato juice and vodka."
			reagent_state = LIQUID
			taste = "spicy"
			fluid_r = 255
			fluid_g = 53
			fluid_b = 0
			transparency = 190
			alch_strength = 0.25

		fooddrink/alcoholic/cocktail_bloodyscary
			name = "Bloody Scary"
			id = "bloody_scary"
			description = "A mix of vodka and the blood of a terrible Other Thing."
			reagent_state = LIQUID
			taste = "scary"
			fluid_r = 255
			fluid_g = 53
			fluid_b = 0
			transparency = 200
			alch_strength = 0.30

		fooddrink/alcoholic/snakebite
			name = "Snakebite"
			id = "snakebite"
			description = "A slightly tart cocktail made from beer and cider that reminds you of autumn."
			reagent_state = LIQUID
			taste = "like falling leaves"
			fluid_r = 143
			fluid_g = 74
			fluid_b = 37
			alch_strength = 0.15

		fooddrink/alcoholic/diesel
			name = "Diesel"
			id = "diesel"
			description = "A tart, yet sweet cocktail."
			reagent_state = LIQUID
			taste = "like falling leaves and cranberries"
			fluid_r = 163
			fluid_g = 64
			fluid_b = 27
			alch_strength = 0.25

		fooddrink/alcoholic/cocktail_suicider
			name = "Suicider"
			id = "suicider"
			description = "An unbelievably strong and potent variety of Cider."
			reagent_state = LIQUID
			taste = "strong"
			fluid_r = 255
			fluid_g = 53
			fluid_b = 0
			transparency = 190
			alch_strength = 1

		fooddrink/alcoholic/cocktail_grog
			name = "grog"
			id = "grog"
			description = "A highly caustic and nigh-undrinkable substance often associated with piracy."
			reagent_state = LIQUID
			taste = "seaworthy"
			thirst_value = 0.899
			bladder_value = -1
			fluid_r = 0
			fluid_g = 255
			fluid_b = 0
			transparency = 255
			alch_strength = 5 //1 unit grog = 100 ticks drunk

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (prob(15))
					M.take_toxin_damage(1 * mult)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume, var/list/paramslist = 0)
				var/mob/living/carbon/human/H = M

				if (method == TOUCH)
					var/silent = 0
					if (length(paramslist))
						if ("silent" in paramslist)
							silent = 1

					if (silent)
						M.TakeDamage("All", volume * 0.5, 0, 0, DAMAGE_BLUNT)
					else if (prob(75))
						M.TakeDamage("head", 25, 0, 0, DAMAGE_BLUNT) // this does brute for some reason, whateverrrr
						M.emote("scream")
						boutput(M, "<span class='alert'>Your face has become disfigured!</span>")
						M.real_name = "Unknown"
						M.unlock_medal("Red Hood", 1)
					else
						M.TakeDamage("All", 5, 0, 0, DAMAGE_BLUNT)

				if(istype(H))
					if(method == INGEST && H.reagents && H.reagents.has_reagent("super_hairgrownium")) //if this starts being abused i will change it, but only admins seem to use grog so fuck it
						H.visible_message("<span class='alert'><b>[H] explodes in a shower of gibs, hair and piracy!</b></span>","<span class='alert'><b>Oh god, too much hair!</b></span>")
						new /obj/item/clothing/glasses/eyepatch(get_turf(H))
						new /obj/item/clothing/mask/moustache(get_turf(H))
						H.gib()
						return
					if(H.cust_one_state != "dreads" || H.cust_two_state != "fullbeard")
						boutput(H, "<b>You feel more piratey! Arr!</b>")
						H.cust_one_state = "dreads"
						H.cust_two_state = "fullbeard"
						H.bioHolder.mobAppearance.customization_first = "Dreadlocks"
						H.bioHolder.mobAppearance.customization_second = "Full Beard"
						H.real_name = "Captain [H.real_name]"
						if (H.wear_id)
							if (istype(H.wear_id, /obj/item/card/id))
								H.wear_id:registered = H.real_name
								H.wear_id:name = "[H.real_name]'s ID ([H.wear_id:assignment])"
							else if (istype(H.wear_id, /obj/item/device/pda2) && H.wear_id:ID_card)
								H.wear_id:ID_card:registered = H.real_name
								H.wear_id:ID_card:name = "[H.real_name]'s ID ([H.wear_id:ID_card:assignment])"
						if(!istype(H.glasses, /obj/item/clothing/glasses/eyepatch))
							var/obj/item/old_glasses = H.glasses
							if(istype(old_glasses))
								H.u_equip(old_glasses)
								if(old_glasses)
									old_glasses.set_loc(H.loc)
									old_glasses.dropped(H)
									old_glasses.layer = initial(old_glasses.layer)
							else
								qdel(H.glasses)
							SPAWN_DBG(0.5 SECONDS)
								if (H)
									var/obj/item/clothing/glasses/eyepatch/E = new /obj/item/clothing/glasses/eyepatch(H)
									E.name = "Pirate Eyepatch"
									E.desc = "Arr!"
									H.equip_if_possible(E,H.slot_glasses)
						H.set_face_icon_dirty()
						H.set_body_icon_dirty()
				else
					random_brute_damage(M, 5)

			reaction_obj(var/obj/O, var/volume)
				if(isitem(O) && prob(20))
					var/obj/decal/cleanable/molten_item/I = make_cleanable(/obj/decal/cleanable/molten_item,O.loc)
					I.desc = "Looks like this was \an [O] some time ago."
					for(var/mob/M in AIviewers(5, O))
						boutput(M, "<span class='alert'>\the [O] melts.</span>")
					qdel(O)

		fooddrink/alcoholic/port
			name = "port"
			id = "port"
			description = "A fortified wine frequently implicated in spontaneous teleportation."
			fluid_r = 161
			fluid_g = 71
			fluid_b = 231
			alch_strength = 0.2
			reagent_state = LIQUID
			taste = "moving"

			on_mob_life(var/mob/M, var/mult = 1)
				if (probmult(15))
					if (isrestrictedz(M.z))
						boutput(M, "<span class='notice'>You feel strange. Almost a sense of guilt.</span>")
						return
					var/telerange = 10
					elecflash(M,power=2)
					var/list/randomturfs = new/list()
					for(var/turf/T in orange(M, telerange))
						if(istype(T, /turf/space) || T.density) continue
						randomturfs.Add(T)
					if (!randomturfs.len)
						..()
						return
					boutput(M, text("<span class='alert'>You blink, and suddenly you're somewhere else!</span>"))
					playsound(M.loc, "sound/effects/mag_warp.ogg", 25, 1, -1)
					M.set_loc(pick(randomturfs))
				..()
				return

		fooddrink/alcoholic/gin
			name = "gin"
			id = "gin"
			fluid_r = 200
			fluid_g = 200
			fluid_b = 200
			transparency = 50
			alch_strength = 0.4
			description = "A strong alcoholic beverage that tastes heavily of juniper."
			reagent_state = LIQUID
			taste = "smooth"

		fooddrink/alcoholic/vermouth
			name = "vermouth"
			id = "vermouth"
			fluid_r = 161
			fluid_g = 71
			fluid_b = 231
			alch_strength = 0.15
			description = "A fortified wine with botanicals for flavor."
			reagent_state = LIQUID
			taste = "sweet"

		fooddrink/alcoholic/bitters
			name = "bitters"
			id = "bitters"
			fluid_r = 83
			fluid_g = 45
			fluid_b = 48
			alch_strength = 0.45
			description = "Extremely bitter extract used to flavor cocktails. Not recommended for consumption on its own."
			reagent_state = LIQUID
			taste = "bitter"

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				var/datum/reagents/old_holder = src.holder
				src = null
				if(!volume_passed)
					return

				var/do_stunny = 1
				var/list/covered = old_holder.covered_turf()
				if (covered.len > 1)
					do_stunny = prob(100/covered.len)

				//var/mob/living/carbon/human/H = M
				if(method == INGEST && do_stunny)
					boutput(M, "<span class='alert'>Ugh! Why did you drink that?!</span>")
					M.changeStatus("stunned", 3 SECONDS)
					M.changeStatus("weakened", 3 SECONDS)
					if (prob(25))

						M.visible_message("<span class='alert'>[M] horks all over \himself. Gross!</span>")
						M.vomit()


		fooddrink/alcoholic/whiskey_sour
			name = "Whiskey Sour"
			id = "whiskey_sour"
			fluid_r = 170
			fluid_g = 188
			fluid_b = 67
			alch_strength = 0.2
			description = "For the manly man who can't quite stomach straight liquor."
			reagent_state = LIQUID
			taste = "sour"

		fooddrink/alcoholic/daiquiri
			name = "Daiquiri"
			id = "daiquiri"
			fluid_r = 8
			fluid_g = 65
			fluid_b = 7
			alch_strength = 0.2
			description = "Rum with some lime juice and sugar."
			reagent_state = LIQUID
			taste = "sweet"
			thirst_value = 0.25

		fooddrink/alcoholic/martini
			name = "Martini"
			id = "martini"
			fluid_r = 238
			fluid_g = 238
			fluid_b = 238
			alch_strength = 0.3
			transparency = 190
			description = "Hastily slopped together, not stirred."
			reagent_state = LIQUID
			taste = "dry"

		fooddrink/alcoholic/v_martini
			name = "Vodka Martini"
			id = "v_martini"
			fluid_r = 238
			fluid_g = 238
			fluid_b = 238
			alch_strength = 0.3
			transparency = 190
			description = "From Russia with Love."
			reagent_state = LIQUID
			taste = "smooth and dry"

		fooddrink/alcoholic/murdini
			name = "Murdini"
			id = "murdini"
			fluid_r = 255
			fluid_g = 238
			fluid_b = 238
			alch_strength = 1.1
			transparency = 190
			description = "Made from apples, mostly."
			reagent_state = LIQUID
			taste = "strongly alcoholic"
			thirst_value = -1

		fooddrink/mutini
			name = "mutini"
			id = "mutini"
			description = "A volatile drink."
			reagent_state = LIQUID
			fluid_r = 70
			fluid_g = 250
			fluid_b = 160
			transparency = 155
			data = null
			depletion_rate = 1

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if (!volume_passed)
					return
				if (!ishuman(M))
					return
				if (!islist(mutini_effects) || !mutini_effects.len)
					return ..()
				var/power_granted = pick(mutini_effects)
				var/power_time = rand(1,10)
				M.bioHolder.AddEffect(power_granted)//, 0, power_time) the timeLeft var either wasn't working here or was grumpy about something so now we manually remove this below
				SPAWN_DBG(power_time*10)
					if (M?.bioHolder)
						M.bioHolder.RemoveEffect(power_granted)

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (!islist(mutini_effects) || !mutini_effects.len)
					return ..()
				var/power_granted = pick(mutini_effects)
				var/power_time = rand(1,10)
				M.bioHolder.AddEffect(power_granted)//, 0, power_time)
				SPAWN_DBG(power_time*10)
					if (M?.bioHolder)
						M.bioHolder.RemoveEffect(power_granted)
				..()
				return

		fooddrink/alcoholic/Manhattan
			name = "Manhattan"
			id = "manhattan"
			fluid_r = 164
			fluid_g = 84
			fluid_b = 14
			alch_strength = 0.3
			description = "For the alcoholic who doesn't quite want to drink straight from the bottle yet."
			reagent_state = LIQUID

		fooddrink/alcoholic/libre
			name = "Space-Cuba Libre"
			id = "libre"
			fluid_r = 41
			fluid_g = 24
			fluid_b = 24
			alch_strength = 0.1
			description = "Made to celebrate the liberation of Space Cuba in 2028."
			reagent_state = LIQUID

		fooddrink/alcoholic/ginfizz
			name = "Gin Fizz"
			id = "ginfizz"
			fluid_r = 248
			fluid_g = 255
			fluid_b = 206
			alch_strength = 0.25
			description = "Don't question how it's fizzing without seltzer."
			reagent_state = LIQUID
			taste = "fizzy"

		fooddrink/alcoholic/gimlet
			name = "Gimlet"
			id = "gimlet"
			fluid_r = 222
			fluid_g = 255
			fluid_b = 206
			alch_strength = 0.25
			description = "So named because you're a tool if you drink it."
			reagent_state = LIQUID

		fooddrink/alcoholic/v_gimlet
			name = "Vodka Gimlet"
			id = "v_gimlet"
			fluid_r = 222
			fluid_g = 255
			fluid_b = 206
			alch_strength = 0.25
			description = "Trading pine cones for rubbing alcohol."
			reagent_state = LIQUID

		fooddrink/alcoholic/w_russian
			name = "White Russian"
			id = "w_russian"
			fluid_r = 244
			fluid_g = 244
			fluid_b = 244
			alch_strength = 0.3
			description = "Nice drink, Dude."
			reagent_state = LIQUID

		fooddrink/alcoholic/b_russian
			name = "Black Russian"
			id = "b_russian"
			fluid_r = 99
			fluid_g = 32
			fluid_b = 15
			alch_strength = 0.15 //adding milk shouldn't quadruple the alcohol per volume
			description = "A vodka-infused coffee cocktail. Supposedly created in honor of a US Ambassador that no one remembers."
			reagent_state = LIQUID

		fooddrink/alcoholic/irishcoffee
			name = "Irish Coffee"
			id = "irishcoffee"
			fluid_r = 54
			fluid_g = 42
			fluid_b = 42
			alch_strength = 0.1
			description = "The breakfast of hung-over champions."
			reagent_state = LIQUID
			taste = ""
			thirst_value = -0.5

		fooddrink/alcoholic/cosmo
			name = "Cosmopolitan"
			id = "cosmo"
			fluid_r = 250
			fluid_g = 206
			fluid_b = 253
			alch_strength = 0.1
			description = "Well, at least it's not giving awful dating advice."
			reagent_state = LIQUID

		fooddrink/alcoholic/beach
			name = "Sex on the Beach"
			id = "beach"
			fluid_r = 227
			fluid_g = 121
			fluid_b = 98
			alch_strength = 0.1
			description = "Fun fact: the name of this cocktail was deemed a war crime in 2025."
			reagent_state = LIQUID
			taste = "sexy"

		fooddrink/alcoholic/gtonic
			name = "Gin and Tonic"
			id = "gtonic"
			fluid_r = 195 //adjusted from 200 to 195 to fix longstanding issue with invisible gin and tonics
			fluid_g = 195
			fluid_b = 195
			transparency = 50
			alch_strength = 0.25
			description = "Once made to make bitter medication taste better, now drunk for its flavor."
			reagent_state = LIQUID

		fooddrink/alcoholic/vtonic
			name = "Vodka Tonic"
			id = "vtonic"
			fluid_r = 195 //same
			fluid_g = 195
			fluid_b = 195
			transparency = 50
			alch_strength = 0.25
			description = "All the bitterness of a gin and tonic, now without any other flavor but alcohol burn!"
			reagent_state = LIQUID

		fooddrink/alcoholic/sonic
			name = "Gin and Sonic"
			id = "sonic"
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			alch_strength = 0.2
			description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
			reagent_state = LIQUID
			//decays into sugar/some sort of stimulant, maybe gives unique stimulant effect/messages, like bold red GOTTA GO FASTs? Makes you take damage when you run into a wall?
			taste = "FAST"
			bladder_value = -5
			stun_resist = 6

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_jittery(2)
				M.drowsyness = max(M.drowsyness-5, 0)
				if(prob(8))
					M.reagents.add_reagent("methamphetamine", 1.2 * mult)
					var/speed_message = pick("Gotta go fast!", "Time to speed, keed!", "I feel a need for speed!", "Let's juice.", "Juice time.", "Way Past Cool!")
					if (prob(50))
						M.say( speed_message )
					else
						var/headersize = rand(1,4)
						boutput(M, "<span class='alert'><h[headersize]>[speed_message]</h[headersize]></span>")

					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						if (H.shoes)
							H.shoes.icon_state = "red"
				..()
				return


		fooddrink/alcoholic/gpink
			name = "Pink Gin and Tonic"
			id = "gpink"
			fluid_r = 253
			fluid_g = 212
			fluid_b = 212
			alch_strength = 0.3
			description = "A gin and tonic for people who think the gin gets in the way."
			reagent_state = LIQUID

		fooddrink/alcoholic/eraser
			name = "Mind Eraser"
			id = "eraser"
			fluid_r = 90
			fluid_g = 61
			fluid_b =  61
			alch_strength = 0.3
			description = "Holy shit, you're getting a buzz just looking at this!"
			reagent_state = LIQUID

		//For laffs (http.//www.youtube.com/watch?v=ySq4O4sZj1w).
		fooddrink/alcoholic/dbreath
			name = "Dragon's Breath"
			id = "dbreath"
			fluid_r = 220
			fluid_g = 0
			fluid_b = 0
			alch_strength = 5 //same as grog
			description = "Possessing this stuff probably breaks the Geneva convention."
			reagent_state = LIQUID
			taste = "hot"
			depletion_rate = 1

			// lights drinker on fire
			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if(method == INGEST && prob(20))
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 300)
				return

			on_mob_life(var/mob/M, var/mult = 1)
				if (!M) M = holder.my_atom
				// if the user drinks milk, they'll be fine
				if (M.reagents.has_reagent("milk"))
					boutput(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
					M.reagents.del_reagent("milk")
					M.reagents.del_reagent("dbreath")
				if (probmult(8))
					boutput(M, "<span class='alert'><b>Oh god! Oh GODD!!</b></span>")
				if (probmult(50))
					boutput(M, "<span class='alert'>Your throat burns terribly!</span>")
					M.emote(pick("scream","cry","choke","gasp"))
					M.changeStatus("stunned", 2 SECONDS)
				if (probmult(8))
					boutput(M, "<span class='alert'>Why!? WHY!?</span>")
				if (probmult(8))
					boutput(M, "<span class='alert'>ARGHHHH!</span>")
				// has a scaling chance of incinerating the drinker like ghostlier chili extract (without the chance to randomly purge it)
				if (probmult(0.2 * volume))
					boutput(M, "<span class='alert'><b>OH GOD OH GOD PLEASE NO!!</b></span>")
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 1000 * mult)
					if (prob(50))
						SPAWN_DBG(2 SECONDS)
							//Roast up the player
							if (M)
								boutput(M, "<span class='alert'><b>IT BURNS!!!!</b></span>")
								sleep(0.2 SECONDS)
								M.visible_message("<span class='alert'>[M] is consumed in flames!</span>")
								M.firegib()

				..()

		fooddrink/alcoholic/squeeze
			name = "squeeze"
			id = "squeeze"
			description = "Alcohol made from fuel. Do you really think you should drink this? I think you have a problem. Maybe you should talk to a doctor."
			reagent_state = LIQUID
			taste = "vile"

			fluid_r = 178
			fluid_g = 163
			fluid_b = 25
			transparency = 190
			alch_strength = 1 //its literally methanol
			depletion_rate = 0.4
			thirst_value = 0.6
			thirst_value = -0.3

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed)
					return
				if(!ishuman(M))
					return


				var/do_stunny = 1
				var/list/covered = holder?.covered_turf()
				if (length(covered) > 1)
					do_stunny = prob(100/length(covered))

				if(method == INGEST && do_stunny)
					boutput(M, "<span class='alert'>Drinking that was an awful idea!</span>")
					M.changeStatus("stunned", 3 SECONDS)
					M.changeStatus("weakened", 3 SECONDS)
					var/mob/living/L = M
					L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
					if (prob(10))
						M.visible_message("<span class='alert'>[M] horks all over \himself. Gross!</span>")
						M.vomit()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.take_toxin_damage(1 * mult)
				..()

		fooddrink/alcoholic/hunchback
			name = "Hunchback"
			id = "hunchback"
			fluid_r = 50
			fluid_g = 0
			fluid_b =  0
			alch_strength = 0.1
			description = "An alleged cocktail invented by a notorious scientist. Useful in a pinch as an impromptu purgative, or interrogation tool."
			reagent_state = LIQUID
			//Acts like ghetto calomel that can be made outside medbay, chance to give food poisoning, vomit constantly and explosively while racking up moderate toxin damage that has no/very low HP cap and burning out other chemicals in the body at a rate equal to/greater than calomel - more potent, more dangerous/weaponizable, alternate sleepypen fuel for bartender

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				for(var/reagent_id in M.reagents.reagent_list)
					if(reagent_id != id)
						M.reagents.remove_reagent(reagent_id, 8 * mult)
				if(M.health > 10)
					M.take_toxin_damage(2 * mult)
				if(probmult(20))
					M.visible_message("<span class='alert'>[M] pukes all over \himself!</span>")
					M.vomit()
				if(probmult(10))
					var/mob/living/L = M
					L.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1)
				..()
				return

		fooddrink/alcoholic/madmen
			name = "Old Fashioned"
			id = "madmen"
			fluid_r = 240
			fluid_g = 185
			fluid_b =  19
			alch_strength = 0.5
			description = "The favorite drink of unfaithful, alcoholic executives in really nice suits."
			reagent_state = LIQUID

		fooddrink/alcoholic/planter
			name = "Planter's Punch"
			id = "planter"
			fluid_r = 255
			fluid_g = 175
			fluid_b = 0
			alch_strength = 0.4
			description = "A Drink then you'll have that's not bad - / At least, so they say in Jamaica!"
			reagent_state = LIQUID

		fooddrink/alcoholic/maitai
			name = "Mai Tai"
			id = "maitai"
			fluid_r = 231
			fluid_g = 107
			fluid_b = 25
			alch_strength = 0.3
			description = "Even in space, you can't escape Tiki drinks."
			reagent_state = LIQUID

		fooddrink/alcoholic/harlow
			name = "Jean Harlow"
			id = "harlow"
			fluid_r = 233
			fluid_g = 97
			fluid_b = 83
			alch_strength = 0.6
			description = "A.K.A. that one actress who would have played Fay Wray's part in King Kong if she hadn't died."
			reagent_state = LIQUID

		fooddrink/alcoholic/gchronic
			name = "Gin and Chronic"
			id = "gchronic"
			fluid_r = 162
			fluid_g = 255
			fluid_b = 0
			alch_strength = 0.25
			description = "DUUUUUUUUUUUUUUUUUUUUDE"
			reagent_state = LIQUID
			//Decays into ethanol and THC

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(10))
					M.reagents.add_reagent("THC", rand(1,10) * mult)
				..()
				return

		fooddrink/alcoholic/margarita
			name = "Margarita"
			id = "margarita"
			fluid_r = 183
			fluid_g = 242
			fluid_b = 81
			alch_strength = 0.2
			description = "Something something Jimmy Buffet something something dated references."
			reagent_state = LIQUID

		fooddrink/alcoholic/tequini
			name = "Tequini"
			id = "tequini"
			fluid_r = 251
			fluid_g = 255
			fluid_b = 193
			alch_strength = 0.4
			description = "You kinda want to punch whoever came up with this name."
			reagent_state = LIQUID

		fooddrink/alcoholic/pfire
			name = "Prairie Fire"
			id = "pfire"
			fluid_r = 184
			fluid_g = 44
			fluid_b = 44
			alch_strength = 0.25
			description = "The leading cause of flaming toilets across the galaxy."
			reagent_state = LIQUID
			//decays into large amounts of capsaicin and maybe histamines?

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(20))
					M.reagents.add_reagent("capsaicin", rand(10,20) * mult)
				if(prob(10))
					M.reagents.add_reagent("histamine", rand(1,5) * mult)
				..()
				return

		fooddrink/alcoholic/bull
			name = "Brave Bull"
			id = "bull"
			fluid_r = 60
			fluid_g = 42
			fluid_b = 45
			alch_strength = 0.35
			description = "Mmm, tastes like heart attacks."
			reagent_state = LIQUID
			stun_resist = 8


		fooddrink/alcoholic/longisland
			name = "Long Island Iced Tea"
			id = "longisland"
			fluid_r = 174
			fluid_g = 171
			fluid_b = 51
			alch_strength = 0.4
			description = "Preferred by housewives, raging alcoholics, and the rather large overlap between them."
			reagent_state = LIQUID

		fooddrink/alcoholic/longbeach
			name = "Long Beach Iced Tea"
			id = "longbeach"
			fluid_r = 229
			fluid_g = 54
			fluid_b = 77
			alch_strength = 0.4
			description = "For when you want a healthier glass of knocks-you-the-fuck-out."
			reagent_state = LIQUID

		fooddrink/alcoholic/pinacolada
			name = "Piña Colada"
			id = "pinacolada"
			fluid_r = 255
			fluid_g = 255
			fluid_b = 204
			alch_strength = 0.2
			description = "I don't really like being caught in the rain all that much, to be honest."
			reagent_state = LIQUID

		fooddrink/alcoholic/mimosa
			name = "Mimosa"
			id = "mimosa"
			fluid_r = 240
			fluid_g = 184
			fluid_b = 1
			alch_strength = 0.05
			description = "Not a flower, but a sweet cocktail typically served at formal functions."
			reagent_state = LIQUID

		fooddrink/alcoholic/french75
			name = "French 75"
			id = "french75"
			fluid_r = 194
			fluid_g = 147
			fluid_b = 41
			alch_strength = 0.15
			description = "A strong champagne cocktail."
			reagent_state = LIQUID

		fooddrink/alcoholic/sangria
			name = "Sangria"
			id = "sangria"
			fluid_r = 124
			fluid_g = 26
			fluid_b = 54
			alch_strength = 0.2
			description = "A tasty fruit wine cocktail."
			reagent_state = LIQUID

			on_mob_life(var/mob/M, var/mult = 1)
				if(M.bodytemperature < 400)
					M.bodytemperature = min(M.bodytemperature+(5 * mult),400)
				..()

		fooddrink/alcoholic/tomcollins
			name = "Tom Collins"
			id = "tomcollins"
			fluid_r = 232
			fluid_g = 224
			fluid_b = 197
			alch_strength = 0.18
			description = "A timeless classic."
			reagent_state = LIQUID

		fooddrink/alcoholic/peachschnapps
			name = "Peach Schnapps"
			id = "peachschnapps"
			fluid_r = 255
			fluid_g = 140
			fluid_b = 170
			alch_strength = 0.25
			description = "Everything about this is just peachy."
			reagent_state = LIQUID

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(4))
					M.reagents.add_reagent("VHFCS", 2 * mult)
				..()

		fooddrink/alcoholic/moscowmule
			name = "Moscow Mule"
			id = "moscowmule"
			fluid_r = 232
			fluid_g = 211
			fluid_b = 118
			alch_strength = 0.15
			description = "A ginger ale and vodka concoction with a dash of lime."
			reagent_state = LIQUID

		fooddrink/alcoholic/tequilasunrise
			name = "Tequila Sunrise"
			id = "tequilasunrise"
			fluid_r = 255
			fluid_g = 124
			fluid_b = 30
			alch_strength = 0.22
			description = "A strikingly orange drink."
			reagent_state = LIQUID

		fooddrink/alcoholic/paloma
			name = "Paloma"
			id = "paloma"
			fluid_r = 255
			fluid_g = 183
			fluid_b = 183
			description = "A delicious summer cocktail."
			alch_strength = 0.1

		fooddrink/alcoholic/mintjulep
			name = "Mint Julep"
			id = "mintjulep"
			fluid_r = 240
			fluid_g = 208
			fluid_b = 83
			alch_strength = 0.15
			description = "A refreshing cocktail with a minty aftertaste."
			reagent_state = LIQUID

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 280)
					M.bodytemperature = max(M.bodytemperature-(5 * mult),280)
				..()
				return

		fooddrink/alcoholic/mojito
			name = "Mojito"
			id = "mojito"
			fluid_r = 198
			fluid_g = 220
			fluid_b = 92
			alch_strength = 0.2
			description = "Rum with some lime juice, sugar, and mint."
			reagent_state = LIQUID

		fooddrink/alcoholic/cremedementhe
			name = "Créme de Menthe"
			id = "cremedementhe"
			fluid_r = 55
			fluid_g = 179
			fluid_b = 102
			alch_strength = 0.4
			description = "Strikingly green and surprisingly sweet."
			reagent_state = LIQUID

		fooddrink/alcoholic/grasshopper
			name = "Grasshopper"
			id = "grasshopper"
			fluid_r = 114
			fluid_g = 235
			fluid_b = 186
			alch_strength = 0.2
			description = "Patience."
			reagent_state = LIQUID
			var/bioeffect_length = 0

			pooled()
				..()
				bioeffect_length = 0

			on_mob_life(var/mob/living/carbon/human/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(istype(M) && !M.mutantrace)
					bioeffect_length++
				..()

			on_mob_life_complete(var/mob/living/carbon/human/M)
				if(M && istype(M))
					if (!M.mutantrace)
						if(M.bioHolder)
							M.bioHolder.AddEffect("roach",0,bioeffect_length) //length of bioeffect proportionate to length grasshopper was in human

		fooddrink/alcoholic/freeze
			name = "Freeze"
			id = "freeze"
			fluid_r = 149
			fluid_g = 249
			fluid_b = 233
			alch_strength = 4
			description = "A space yeti favorite."
			taste = "cold"
			depletion_rate = 1
			reagent_state = LIQUID


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.reagents.has_reagent("chocolate"))
					boutput(M, "<span class='notice'>The chocolate warms you up. Ahhh.</span>")
					M.reagents.del_reagent("chocolate")
					M.reagents.del_reagent("freeze")
				if(M.bodytemperature > 0)
					M.bodytemperature=max(M.bodytemperature-(10 * mult),0)
				if(probmult(10))
					boutput(M, pick("<span class='notice'><i>Brrr...</i></span>","<span class='notice'><i>Isn't it a bit chilly in here?</i></span>","<span class='notice'><i>Who left an airlock open?</i></span>"))
				if(probmult(15))
					M.emote(pick("cough","sneeze","gasp"))
				if(probmult(20))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 30 * mult))
				if(prob(40))
					random_burn_damage(M, 2 * mult)
				if(probmult(0.2 * volume))
					M.emote("scream")
					boutput(M, "<span class='notice'><b>Oh. God.</b></span>")
					SPAWN_DBG(2 SECONDS)
						if (M)
							M:become_ice_statue()
				..()
				return

		fooddrink/alcoholic/curacao
			name = "Curacao"
			id = "curacao"
			fluid_r = 25
			fluid_g = 82
			fluid_b = 255
			alch_strength = 2
			description = "A distinctive and aromatic liqueur."
			reagent_state = LIQUID

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (probmult(5))
					M.say(pick("Ye damned whale",\
					"I don't shleep, I die.",\
					"Call me Ishmael.",\
					"Yo ho and a bottle of rum.",\
					"This ish no place for a clergyman'sh shon!",\
					"Ahoy!.",\
					"There she blowsh."))
				..()
				return

		fooddrink/alcoholic/bluelagoon
			name = "Blue Lagoon"
			id = "bluelagoon"
			fluid_r = 122
			fluid_g = 217
			fluid_b = 255
			alch_strength = 0.1
			description = "A visually and flavorfully pleasing cocktail."
			reagent_state = LIQUID

		fooddrink/alcoholic/bluehawaiian
			name = "Blue Hawaiian"
			id = "bluehawaiian"
			fluid_r = 89
			fluid_g = 208
			fluid_b = 255
			alch_strength = 0.18
			description = "A deliciously icy tropical cocktail."
			reagent_state = LIQUID

		fooddrink/alcoholic/negroni
			name = "Negroni"
			id = "negroni"
			fluid_r = 167
			fluid_g = 0
			fluid_b = 0
			alch_strength = 0.6
			description = "A sweet gin cocktail."
			reagent_state = LIQUID

		fooddrink/alcoholic/necroni
			name = "Necroni"
			id = "necroni"
			fluid_r = 152
			fluid_g = 171
			fluid_b = 0
			alch_strength = 0.5
			description = "A hellish cocktail that stinks of rotting garbage."
			reagent_state = LIQUID
		fooddrink/alcoholic/kalimoxto
			name = "Kalimoxto"
			id = "kalimoxto"
			fluid_r = 164
			fluid_g = 77
			fluid_b = 65
			alch_strength = 0.3
			description = "A refreshing Spanish mixture of cola and wine."
			reagent_state = LIQUID

		fooddrink/alcoholic/derby
			name = "Derby"
			id = "derby"
			fluid_r = 253
			fluid_g = 224
			fluid_b = 34
			alch_strength = 0.4
			description = "One of the many cocktails with the same name."
			reagent_state = LIQUID

		fooddrink/alcoholic/horsesneck
			name = "Horse's Neck"
			id = "horsesneck"
			fluid_r = 252
			fluid_g = 205
			fluid_b = 63
			alch_strength = 0.5
			description = "Not to be confused with a horse mask."
			reagent_state = LIQUID

		fooddrink/alcoholic/rose
			name = "Rose"
			id = "rose"
			fluid_r = 254
			fluid_g = 28
			fluid_b = 187 //oh god my eyes
			alch_strength = 0.3
			description = "An eye-searingly pink mixed drink."
			reagent_state = LIQUID

		fooddrink/alcoholic/gunfire
			name = "Gunfire"
			id = "gunfire"
			fluid_r = 247
			fluid_g = 127
			fluid_b = 0
			alch_strength = 0.1
			description = "A mixture of tea and rum. Huh."
			reagent_state = LIQUID

		fooddrink/alcoholic/seabreeze
			name = "Sea Breeze"
			id = "seabreeze"
			fluid_r = 253
			fluid_g = 116
			fluid_b = 101
			alch_strength = 0.2
			description = "A refreshing mixed drink evocative of the seaside."
			reagent_state = LIQUID

		fooddrink/alcoholic/brassmonkey
			name = "Brass Monkey"
			id = "brassmonkey"
			fluid_r = 253
			fluid_g = 198
			fluid_b = 47
			alch_strength = 0.3
			description = "Contains no monkeys or brass."
			reagent_state = LIQUID

		fooddrink/alcoholic/hotbutteredrum
			name = "Hot Buttered Rum"
			id = "hotbutteredrum"
			fluid_r = 209
			fluid_g = 147
			fluid_b = 93
			alch_strength = 0.3
			description = "A rich and indulgent drink with actual butter in it."
			reagent_state = LIQUID

		fooddrink/alcoholic/fluffycritter
			name = "Fluffy Critter"
			id = "fluffycritter"
			fluid_r = 252
			fluid_g = 240
			fluid_b = 188
			alch_strength = 0.2
			description = "A sweet mixed drink with a cutesy name."
			reagent_state = LIQUID

		fooddrink/alcoholic/michelada
			name = "Michelada"
			id = "michelada"
			fluid_r = 211
			fluid_g = 53
			fluid_b = 8
			alch_strength = 0.1
			description = "?Una cerveza preparada de M?ico perfecta para los sedientos habitantes de la estaci? espacial que quieren algo con un bocado!"
			reagent_state = LIQUID

		fooddrink/alcoholic/espressomartini
			name = "Espresso Martini"
			id = "espressomartini"
			fluid_r = 93
			fluid_g = 48
			fluid_b = 22
			alch_strength = 0.1
			description = "Does this really count as a Martini?"
			reagent_state = LIQUID

		fooddrink/alcoholic/radler
			name = "Radler"
			id = "radler"
			fluid_r = 254
			fluid_g = 215
			fluid_b = 58
			alch_strength = 0.1
			description = "A lemonade and beer shandy."
			reagent_state = LIQUID

		fooddrink/alcoholic/threemileislandicedtea
			name = "Three Mile Island Iced Tea"
			id = "threemileislandicedtea"
			fluid_r = 178
			fluid_g = 254
			fluid_b = 15
			alch_strength = 0.6
			description = "Does this really count as a Martini?"
			reagent_state = LIQUID

		fooddrink/sodawater
			name = "soda water"
			id = "sodawater"
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			description = "Carbonated water."
			reagent_state = LIQUID

		fooddrink/simplesyrup
			name = "Simple Syrup"
			id = "simplesyrup"
			fluid_r = 230
			fluid_g = 218
			fluid_b = 204
			description = "A viscous and gloopy syrup."
			reagent_state = LIQUID

		fooddrink/ectocooler
			name = "Ecto Cooler"
			id = "ectocooler"
			fluid_r = 105
			fluid_g =  255
			fluid_b = 0
			description = "Said to taste exactly like a proton beam. Considering anyone who's tried to taste a proton beam has lost their jaws, it's hard to say where this idea came from."
			reagent_state = LIQUID
			thirst_value = -0.5

			//decays into 1 VHFCS per unit for a real good time, and also lets you see ghosts

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.reagents.add_reagent("VHFCS", 1 * mult)
				if (prob(10))
					M.reagents.add_reagent("green_goop", 1 * mult)
				..()
				return

		fooddrink/refried_beans
			name = "refried beans"
			id = "refried_beans"
			description = "A dish made of mashed beans cooked with lard."
			reagent_state = LIQUID
			fluid_r = 104
			fluid_g = 68
			fluid_b = 53
			transparency = 255
			hunger_value = 2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.nutrition += 1 * mult

				if(probmult(10))
					M.emote("fart")
				..()

		fooddrink/death_spice
			name = "death spice"
			id = "death_spice"
			description = "Despite its name, this sweet-smelling black powder is completely harmless. Maybe."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 255
			taste = "deadly"

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				var/odds = rand(1,1000000)
				if(odds == 1)
					M.visible_message("<span class='alert'>[M] suddenly drops dead!</span>")
					M.death()
				..()
				return

		fooddrink/bread
			name = "bread"
			id = "bread"
			description = "Bread! Yep, bread."
			reagent_state = SOLID
			fluid_r = 156
			fluid_g = 80
			fluid_b = 19
			transparency = 255
			hunger_value = 2

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5 && !(locate(/obj/item/reagent_containers/food/snacks/breadslice) in T))
					new /obj/item/reagent_containers/food/snacks/breadslice(T)

		fooddrink/george_melonium
			name = "george melonium"
			id = "george_melonium"
			description = "A robust and mysterious substance."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 255
			fluid_b = 0
			transparency = 30
			hunger_value = 5
			thirst_value = 5

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed)
					return
				//var/mob/living/carbon/human/H = M
				if(method == INGEST)
					switch(rand(1,5))
						if(1)
							boutput(M, "<span class='alert'>What an explosive burst of flavor!</span>")
							var/turf/T = get_turf(M.loc)
							explosion(M, T, -1, -1, 1, 1)
						if(2)
							boutput(M, "<span class='alert'>So juicy!</span>")
							M.reagents.add_reagent(pick("capsaicin","psilocybin","LSD","THC","ethanol","poo","omnizine","methamphetamine","haloperidol","mutagen","radium","acid","mercury","space_drugs","morphine"), rand(10,40))
						if(3)
							boutput(M, "<span class='notice'>How refreshing!</span>")
							M.HealDamage("All", 30, 30)
							M.take_toxin_damage(-30)
							M.take_oxygen_deprivation(-30)
							M.take_brain_damage(-30)
						if(4)
							boutput(M, "<span class='notice'>This flavor is out of this world!</span>")
							M.reagents.add_reagent("space_drugs", 30)
							M.reagents.add_reagent("THC", 30)
							M.reagents.add_reagent("LSD", 30)
							M.reagents.add_reagent("psilocybin", 30)
						if(5)
							boutput(M, "<span class='alert'>What stunning texture!</span>")
							M.changeStatus("paralysis", 60)
							M.changeStatus("stunned", 7 SECONDS)
							M.changeStatus("weakened", 80)
							M.stuttering += 20

		fooddrink/capsaicin
			name = "capsaicin"
			id = "capsaicin"
			description = "A potent irritant produced by pepper plants in the Capsicum genus."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 77
			taste = "hot"
			addiction_prob = 1 // heh
			addiction_prob2 = 10
			addiction_min = 2
			max_addiction_severity = "LOW"
			//penetrates_skin = 1
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (holder.get_reagent_amount(src.id) >= 20)
					M.stuttering += rand(0,5)
					if(prob(10))
						M.emote(pick("choke","gasp","cough"))
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 10 * mult))
						M.take_oxygen_deprivation(rand(0,10) * mult)
						M.bodytemperature += rand(5,20) * mult
				M.stuttering += rand(0,2)
				M.bodytemperature += rand(0,3) * mult
				if(prob(10))
					M.emote(pick("cough"))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 10 * mult))
				..()

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed)
					return

				//var/mob/living/carbon/human/H = M
				if(method == INGEST)
					if (volume_passed > 10)
						if (volume_passed >= 80)
							boutput(M, "<span class='alert'><b>HOLY FUCK!!!!</b></span>")
							M.emote("scream")
							M.stuttering += 30
							M.changeStatus("weakened", 5 SECONDS)
						else if (volume_passed >= 40 && volume_passed < 80)
							boutput(M, "<span class='alert'>HOT!!!!</span>")
							M.emote("cough")
							M.stuttering += 15
						else if (volume_passed >= 11 && volume_passed < 40)
							boutput(M, "<span class='alert'>Hot!</span>")
							M.stuttering += 5
					else boutput(M, "<span class='alert'>Spicy!</span>")


				else if (method == TOUCH)
					if(iscarbon(M))
						if(!M.wear_mask)
							M.reagents.add_reagent("capsaicin",round(volume_passed/5))
							if(prob(50))
								M.emote("scream")
								boutput(M, "<span class='alert'><b>Your eyes hurt!</b></span>")
								M.take_eye_damage(1, 1)
							M.change_eye_blurry(3)
							M.changeStatus("stunned", 2 SECONDS)
							M.change_misstep_chance(10)


		fooddrink/el_diablo
			name = "El Diablo chili"
			id = "el_diablo"
			description = "Rumored to be the tears of the devil himself."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 40
			taste = "hot"
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				if(!M) M = holder.my_atom
				M.stuttering += rand(0,5)
				if(prob(25))
					M.emote(pick("choke","gasp"))
					M.take_oxygen_deprivation(rand(0,10) * mult)
					M.bodytemperature += rand(0,7) * mult
				M.stuttering += rand(0,2)
				M.bodytemperature += rand(0,3) * mult
				if(probmult(10))
					M.emote(pick("cough"))

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed)
					return
				//var/mob/living/carbon/human/H = M
				if(method == INGEST)
					boutput(M, "<span class='alert'><b>HOLY FUCK!!!!</b></span>")
					M.emote("scream")
					M.stuttering += 30
					M.changeStatus("stunned", 2 SECONDS)
					if (prob(20))
						if(isliving(M))
							var/mob/living/L = M
							boutput(L, "<span class='alert'>Oh christ too hot!!!!</span>")
							L.update_burning(25)

		fooddrink/space_cola
			name = "cola"
			id = "cola"
			description = "A refreshing beverage."
			reagent_state = LIQUID
			fluid_r = 66
			fluid_g = 33
			fluid_b = 33
			transparency = 190
			taste = "sugary"
			thirst_value = 0.75
			bladder_value = -0.03
			viscosity = 0.4
			bladder_value = -0.2

			on_mob_life(var/mob/M, var/mult = 1)
				M.drowsyness = max(0,M.drowsyness-5)
				if(M.bodytemperature > M.base_body_temp) // So it doesn't act like supertep
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(5 * mult))
				..()
				return

		fooddrink/sarsaparilla // traditionally non-caffeinated
			name = "sarsaparilla"
			id = "sarsaparilla"
			description = "A refreshing beverage that only like, four people on station like."
			reagent_state = LIQUID
			fluid_r = 86
			fluid_g = 43
			fluid_b = 43
			transparency = 190
			taste = "sugary"
			thirst_value = 0.75

			on_mob_life(var/mob/M, var/mult = 1)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.sims)
						H.sims.affectMotive("Bladder", (-0.05 * mult))
				if(M.bodytemperature > M.base_body_temp) // So it doesn't act like supertep
					M.bodytemperature = max(M.base_body_temp, M.bodytemperature-(5 * mult))
				..(M, mult)
				return

		fooddrink/cheese
			name = "cheese"
			id = "cheese"
			description = "Some cheese. Pour it out to make it solid."
			reagent_state = SOLID
			fluid_r = 255
			fluid_b = 0
			fluid_g = 255
			transparency = 255
			hunger_value = 1
			viscosity = 0.5
			minimum_reaction_temperature = -INFINITY



			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5 && !(locate(/obj/item/reagent_containers/food/snacks/ingredient/cheese) in T))
					new /obj/item/reagent_containers/food/snacks/ingredient/cheese(T)

			on_mob_life(var/mob/M, var/mult = 1)
				if(prob(3))
					M.reagents.add_reagent("cholesterol", rand(1,2) * mult)
				..()

		fooddrink/gcheese
			name = "weird cheese"
			id = "gcheese"
			description = "Hell, I don't even know if this IS cheese. Whatever it is, it ain't normal. If you want to, pour it out to make it solid."
			reagent_state = SOLID
			fluid_r = 80
			fluid_b = 0
			fluid_g = 255
			transparency = 255
			addiction_prob = 1//5 // hey man some people really like weird cheese
			addiction_prob2 = 10
			addiction_min = 5
			max_addiction_severity = "LOW"
			taste = "weird"
			hunger_value = 1
			viscosity = 0.6

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 5 && !(locate(/obj/item/reagent_containers/food/snacks/ingredient/gcheese) in T))
					new /obj/item/reagent_containers/food/snacks/ingredient/gcheese(T)

			on_mob_life(var/mob/M, var/mult = 1)
				if(prob(5))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)
				..()

		fooddrink/meat_slurry
			name = "meat slurry"
			id = "meat_slurry"
			description = "A paste comprised of highly-processed organic material. Uncomfortably similar to deviled ham spread."
			reagent_state = SOLID
			fluid_r = 235
			fluid_g = 215
			fluid_b = 215
			transparency = 255
			hunger_value = 0.5
			viscosity = 0.5

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				src = null

				if (covered.len > 9)
					volume = (volume/covered.len)

				if(volume >= 5 && prob(10))
					if(!locate(/obj/decal/cleanable/blood/gibs) in T)
						playsound(T, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
						make_cleanable(/obj/decal/cleanable/blood/gibs,T)

			on_mob_life(var/mob/M, var/mult = 1)
				..() // call your parents  :(
				if(prob(4))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)

		fooddrink/coffee
			name = "coffee"
			id = "coffee"
			description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
			reagent_state = LIQUID
			fluid_r = 39
			fluid_g = 28
			fluid_b = 16
			transparency = 245
			addiction_prob = 2//5
			addiction_prob2 = 20
			addiction_min = 10
			max_addiction_severity = "LOW"
			var/remove_buff = 0
			thirst_value = 0.3
			bladder_value = -0.1
			energy_value = 0.3
			stun_resist = 7

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_regen"))
					remove_buff = holder.my_atom:add_stam_mod_regen("consumable_good", 2)
				..()

			on_remove()
				if(remove_buff)
					if(istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_regen"))
						holder.my_atom:remove_stam_mod_regen("consumable_good")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				M.dizziness = max(0,M.dizziness-5)
				M.drowsyness = max(0,M.drowsyness-3)
				M.sleeping = 0
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(5 * mult))
				M.make_jittery(3)

		fooddrink/coffee/fresh
			name = "freshly brewed coffee"
			id = "coffee_fresh"
			addiction_prob2 = 10
			thirst_value = 1
			energy_value = 0.6

		fooddrink/coffee/espresso //the good stuff
			name = "espresso"
			id = "espresso"
			description = "An espresso is a strong black coffee with more caffeine."
			fluid_r = 37
			fluid_g = 26
			fluid_b = 14
			thirst_value = 0.25
			energy_value = 0.8
			var/caffeine_rush = 3
			var/caffeine_jitters = 10
			stun_resist = 10

			on_add()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"add_stam_mod_regen")) //gotta get hyped
					holder.my_atom:add_stam_mod_regen("caffeine rush", src.caffeine_rush)
				..()

			on_remove()
				if (istype(holder) && istype(holder.my_atom) && hascall(holder.my_atom,"remove_stam_mod_regen"))
					holder.my_atom:remove_stam_mod_regen("caffeine rush")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				..()
				M.make_jittery(1)

		fooddrink/coffee/espresso/expresso // the stupid stuff
			name = "expresso"
			id = "expresso"
			description = "An expresso is a strong black coffee with more stupid."
			stun_resist = 25
			on_mob_life(var/mob/M, var/mult = 1)
				..()
				M.take_brain_damage(2 * mult)

		fooddrink/coffee/espresso/decaf
			name = "decaf espresso"
			id = "decafespresso"
			description = "A decaf espresso contains less caffeine than a regular espresso."
			caffeine_rush = 2
			caffeine_jitters = 5
			addiction_prob = 1
			addiction_prob2 = 5
			energy_value = 0

		fooddrink/coffee/energydrink
			name = "energy drink"
			id = "energydrink"
			description = "An energy drink is a liquid plastic with a high amount of caffeine."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 64
			transparency = 170
			overdose = 25
			addiction_prob = 4
			addiction_prob2 = 10
			var/tickcounter = 0
			thirst_value = 0.055
			bladder_value = 0.04
			energy_value = 1
			stun_resist = 25

			pooled()
				..()
				tickcounter = 0

			on_add()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				return ..()

			on_remove()
				if (ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				return ..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if (ishuman(M))
					tickcounter++

				..()

			on_mob_life_complete(var/mob/M)
				if(M)
					if (tickcounter < 20)
						return
					else
						M.show_message("<span class='alert'>You feel exhausted!</span>")
						M.drowsyness = tickcounter - 20
						M.dizziness = tickcounter - 20
					src.holder.del_reagent(id)


			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if (severity == 1 && prob(10))
					M.show_message("<span class='alert'>Your heart feels like it wants to jump out of your chest.</span>")
				else if (ishuman(M) && ((severity == 2 && probmult(3 + tickcounter / 25)) || (severity == 1 && probmult(tickcounter / 50))))
					M:contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)

		fooddrink/tea
			name = "tea"
			id = "tea"
			description = "An aromatic beverage derived from the leaves of the camellia sinensis plant."
			reagent_state = LIQUID
			fluid_r = 139
			fluid_g = 90
			fluid_b = 54
			thirst_value = 1
			bladder_value = 0.04
			energy_value = 0.04
			addiction_prob = 1
			addiction_prob2 = 1
			addiction_min = 10
			minimum_reaction_temperature = -INFINITY

			reaction_temperature(exposed_temperature, exposed_volume)
				if (exposed_temperature <= T0C + 7)
					name = "iced tea"
					description = "Tea, but cold!"
				else if (exposed_temperature > (T0C + 40) )
					name = "hot tea"
					description = "A common way to enjoy tea."
				else
					name = "tea"
					description = initial(description)

			on_mob_life(var/mob/M, var/mult = 1)
				if (holder.has_reagent("toxin")) //Tea is good for you!!
					holder.remove_reagent("toxin", 1 * mult)
				if (holder.has_reagent("toxic_slurry"))
					holder.remove_reagent("toxic_slurry", 1 * mult)
				..()
				return

		fooddrink/honey_tea
			name = "tea"
			id = "honey_tea"
			description = "An aromatic beverage derived from the leaves of the camellia sinensis plant. There's a little bit of honey in it."
			reagent_state = LIQUID
			fluid_r = 145
			fluid_g = 97
			fluid_b = 52
			transparency = 232
			thirst_value = 0.075
			bladder_value = 0.04
			energy_value = 0.04
			addiction_prob = 1
			addiction_prob2 = 2
			addiction_min = 10

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M) M = holder.my_atom
				for (var/datum/ailment_data/disease/virus in M.ailments)
					if (probmult(5) && istype(virus.master,/datum/ailment/disease/cold))
						M.cure_disease(virus)
					if (probmult(3) && istype(virus.master,/datum/ailment/disease/flu))
						M.cure_disease(virus)
					if (probmult(3) && istype(virus.master,/datum/ailment/disease/food_poisoning))
						M.cure_disease(virus)
				if (probmult(11))
					M.show_text("You feel calm and relaxed.", "blue")
				..()
				return

		fooddrink/mint_tea
			name = "tea"
			id = "mint_tea"
			description = "An aromatic beverage derived from the leaves of the camellia sinensis plant. There's a little bit of mint in it."
			reagent_state = LIQUID
			fluid_r = 117
			fluid_g = 120
			fluid_b = 65
			thirst_value = 0.075
			bladder_value = 0.04
			energy_value = 0.04
			transparency = 232
			thirst_value = 1.5

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 280)
					M.bodytemperature = max(M.bodytemperature-(5 * mult),280)
				..()
				return

		fooddrink/ginger_ale
			name = "ginger ale"
			id = "ginger_ale"
			description = "A delightful carbonated beverage with ginger flavor."
			reagent_state = LIQUID
			fluid_r = 216
			fluid_g = 209
			fluid_b = 127
			transparency = 160
			thirst_value = 0.078
			bladder_value = 0.05

			on_mob_life(var/mob/M, var/mult = 1)
				if(probmult(4))
					M.emote("burp")
				..()

		fooddrink/chocolate
			name = "chocolate"
			id = "chocolate"
			description = "Chocolate is a delightful product derived from the seeds of the theobroma cacao tree."
			reagent_state = LIQUID
			fluid_r = 39
			fluid_g = 28
			fluid_b = 16
			transparency = 245
			thirst_value = 0.5
			hunger_value = 1
			viscosity = 0.5

			on_mob_life(var/mob/M, var/mult = 1)
				if(M.bodytemperature < M.base_body_temp) // So it doesn't act like supermint
					M.bodytemperature = min(M.base_body_temp, M.bodytemperature+(5 * mult))
				M.reagents.add_reagent("sugar", 0.8 * mult)
				..()

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 3)
					if(locate(/obj/item/reagent_containers/food/snacks/candy/chocolate) in T) return
					new /obj/item/reagent_containers/food/snacks/candy/chocolate(T)

		fooddrink/nectar
			name = "nectar"
			id = "nectar"
			description = "A sweet liquid produced by plants to attract pollinators."
			reagent_state = LIQUID
			fluid_r = 221
			fluid_g = 221
			fluid_b = 24
			transparency = 200
			viscosity = 0.3

		fooddrink/honey
			name = "honey"
			id = "honey"
			description = "A sweet substance produced by bees through partial digestion.  Bee barf."
			reagent_state = LIQUID
			fluid_r = 206
			fluid_g = 206
			fluid_b = 19
			transparency = 240
			hunger_value = 0.5
			viscosity = 0.4

			on_mob_life(var/mob/M, var/mult = 1)
				M.reagents.add_reagent("sugar",0.4 * mult)
				M.nutrition++
				..()

			reaction_turf(var/turf/T, var/volume)
				src = null
				if (volume >= 5)
					if (locate(/obj/item/reagent_containers/food/snacks/ingredient/honey) in T)
						return

					new /obj/item/reagent_containers/food/snacks/ingredient/honey(T)

		fooddrink/royal_jelly
			name = "royal jelly"
			id = "royal_jelly"
			description = "A nutritive gel used to induce extended development in the larvae of greater domestic space-bees."
			reagent_state = LIQUID
			fluid_r = 153
			fluid_g = 0
			fluid_b = 102
			transparency = 200
			hunger_value = 1
			viscosity = 0.6

			on_mob_life(var/mob/M, var/mult = 1)
				M.reagents.add_reagent("sugar",0.8 * mult)
				M.nutrition+=2 * mult
				..()


			 //to-do. BEE MEN

		fooddrink/eggnog
			name = "egg nog"
			id = "eggnog"
			description = "A festive dairy drink made with beaten eggs."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 237
			fluid_b = 202
			transparency = 255
			hunger_value = 1
			thirst_value = 1
			bladder_value = -1
			viscosity = 0.3

			on_mob_life(var/mob/M, var/mult = 1)
				M.reagents.add_reagent("sugar", 1.6 * mult)
				M.nutrition++
				..()

			on_add()
				if(holder && ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					if(M.client)
						boutput(M, "<em>You feel reinvigorated with xmas spirit!</em>")

					if(M.get_oxygen_deprivation())
						M.take_oxygen_deprivation(-1)
					if(M.get_toxin_damage())
						M.take_toxin_damage(-1)
					if(M.losebreath)
						M.lose_breath(-1)
					M.HealDamage("All", 2, 2, 1)
					if (isliving(M))
						var/mob/living/L = M
						if (L.bleeding)
							repair_bleeding_damage(L, 10, 1)
						if (L.blood_volume < 500)
							L.blood_volume ++
						if (ishuman(M))
							var/mob/living/carbon/human/H = M
							if (H.organHolder)
								H.organHolder.heal_organs(1, 1, 1, target_organs)

		fooddrink/guacamole
			name = "guacamole"
			id = "guacamole"
			description = "A paste comprised primarily of avocado."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 123
			fluid_b = 28
			hunger_value = 1.5
			viscosity = 0.4

			on_mob_life(var/mob/M, var/mult = 1)
				if(prob(50))
					M.nutrition+= 1 * mult
				..()

		fooddrink/catonium
			name = "catonium"
			id = "catonium"
			description = "An herbal extract noted for its peculiar effect on felines."
			reagent_state = LIQUID

			reaction_obj(var/obj/O, var/volume)
				if (istype(O, /obj/critter/cat))
					var/obj/critter/cat/theCat = O
					theCat.catnip_effect()

		fooddrink/vanilla
			name = "vanilla"
			id = "vanilla"
			description = "An expensive spice of the new world. Combination with ice not recommended."
			reagent_state = LIQUID
			fluid_r = 253
			fluid_g = 248
			fluid_b = 244
			transparency = 245

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if ( (method==TOUCH && prob(33)) || method==INGEST)
					if(M.bioHolder.HasAnyEffect(EFFECT_TYPE_POWER) && prob(4))
						M.bioHolder.RemoveAllEffects(EFFECT_TYPE_POWER)
						boutput(M, "You feel plain.")
				return

		fooddrink/chickensoup
			name = "chicken soup"
			id = "chickensoup"
			description = "An old household remedy for mild illnesses."
			reagent_state = LIQUID
			fluid_r = 180
			fluid_g = 180
			fluid_b = 0
			transparency = 255
			depletion_rate = 0.2
			hunger_value = 2
			thirst_value = 0.5
			bladder_value = -1

			on_mob_life(var/mob/living/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(50))
					M.nutrition += 1 * mult
				for(var/datum/ailment_data/disease/virus in M.ailments)
					if(probmult(10) && istype(virus.master,/datum/ailment/disease/cold))
						M.cure_disease(virus)
					if(probmult(10) && istype(virus.master,/datum/ailment/disease/flu))
						M.cure_disease(virus)
					if(probmult(10) && istype(virus.master,/datum/ailment/disease/food_poisoning))
						M.cure_disease(virus)
				..()
				return

		fooddrink/salt
			name = "salt"
			id = "salt"
			description = "Sodium chloride, common table salt."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 150
			overdose = 100
			value = 3 // 1c + 1c + 1c
			thirst_value = -0.25

			reaction_turf(var/turf/T, var/volume)
				var/list/covered = holder.covered_turf()
				src = null
				if (volume >= 10 && covered.len < 2)
					if (!T.messy)
						make_cleanable(/obj/decal/cleanable/saltpile,T)
					else
						var/obj/decal/cleanable/saltpile/pile = locate(/obj/decal/cleanable/saltpile) in T
						if (pile)
							pile.health = min(pile.health+10, 30)
							//pile.update_icon()


			reaction_obj(var/obj/O, var/volume)
				if (istype(O, /obj/critter/slug))
					var/obj/critter/slug/S = O
					S.visible_message("<span class='alert'>[S] shrivels up!</span>")
					S.CritterDeath()
				..(O, volume)
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				src = null
				if (istype(M, /mob/living/critter/small_animal/slug))
					M.show_text("<span class='alert'><b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b></span>")
					M.TakeDamage(null, volume, volume)
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!istype(M))
					return
				if(prob(70))
					M.take_brain_damage(1 * mult)
					M.reagents.add_reagent("diluted_fliptonium", 1 * mult) //salty
				..()
				return

			on_mob_life(var/mob/living/M, var/mult = 1)
				if (!M)
					M = holder.my_atom
				if (istype(M, /mob/living/critter/small_animal/slug))
					M.show_text("<span class='alert'><b>OH GOD THE SALT [pick("IT BURNS","HOLY SHIT THAT HURTS","JESUS FUCK YOU'RE DYING")]![pick("","!","!!")]</b></span>")
					M.TakeDamage(null, src.depletion_rate * mult, src.depletion_rate * mult)
				..()
				return

		fooddrink/pepper
			name = "pepper"
			id = "pepper"
			description = "A common condiment."
			reagent_state = SOLID
			fluid_r = 25
			fluid_g = 10
			fluid_b = 10
			transparency = 255
			value = 3 // same as salt vOv

		fooddrink/ketchup
			name = "ketchup"
			id = "ketchup"
			description = "A condiment often used on hotdogs and sandwiches."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			transparency = 255

			reaction_turf(var/turf/T, var/volume) //Makes the kechup splats
				var/list/covered = holder.covered_turf()
				src = null

				if (covered.len > 9)
					volume = (volume/covered.len)

				if (volume >= 5)
					if (!locate(/obj/decal/cleanable/ketchup) in T)
						playsound(T, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
						make_cleanable(/obj/decal/cleanable/ketchup,T)

		fooddrink/mustard
			name = "mustard"
			id = "mustard"
			description = "A condiment often used on hotdogs and sandwiches."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 0
			transparency = 255

		fooddrink/porktonium
			name = "porktonium"
			id = "porktonium"
			description = "A highly-radioactive pork byproduct first discovered in hotdogs."
			reagent_state = LIQUID
			fluid_r = 238
			fluid_b = 111
			fluid_g = 111
			transparency = 155
			depletion_rate = 0.2
			hunger_value = 1
			viscosity = 0.6

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(!holder.has_reagent(src.id,133))
					..()
					return
				if(prob(15))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)
				if(prob(8))
					M.reagents.add_reagent("radium", 15 * mult)
					M.reagents.add_reagent("cyanide", 10 * mult)
				..()
				return

		fooddrink/mugwort
			name = "mugwort"
			id = "mugwort"
			description = "A rather bitter herb once thought to hold magical protective properties."
			reagent_state = SOLID
			fluid_r = 39
			fluid_g = 28
			fluid_b = 16
			transparency = 250

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed, var/mult = 1)
				src = null
				if(!volume_passed || method != INGEST)
					return
				if (!iswizard(M))
					return

				if(M.get_oxygen_deprivation() && prob(45))
					M.take_oxygen_deprivation(-1 * mult)
				if(M.get_toxin_damage() && prob(45))
					M.take_toxin_damage(-1 * mult)
				if(M.losebreath && prob(85))
					M.losebreath -= (1 * mult)
				if(prob(45))
					M.HealDamage("All", 6 * mult, 6 * mult)
				//M.UpdateDamageIcon()
				return

			on_mob_life(var/mob/M, var/mult = 1) //god fuck this proc
				if(!M) M = holder.my_atom
				if (iswizard(M))
					if(M.reagents.has_reagent("sarin"))
						M.reagents.remove_reagent("sarin", 5 * mult)
				..()

		fooddrink/grease
			name = "space-soybean oil"
			id = "grease"
			description = "An oil derived from extra-terrestrial soybeans."
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 150
			viscosity = 0.3

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(10))
					M.nutrition+= 1 * mult
				if(prob(10))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)
				if(prob(8))
					M.reagents.add_reagent("porktonium", 5 * mult)
				..()

				return

		fooddrink/badgrease
			name = "partially hydrogenated space-soybean oil"
			id = "badgrease"
			description = "An oil derived from extra-terrestrial soybeans, with additional hydrogen atoms added to convert it into a saturated form."
			fluid_r = 220
			fluid_g = 220
			fluid_b = 220
			transparency = 175
			depletion_rate = 0.2
			viscosity = 0.8

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(10))
					M.nutrition+= 1 * mult
				if(prob(15))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)
				if(prob(8))
					M.reagents.add_reagent("porktonium", 5 * mult)

				if (holder.has_reagent(src.id,75))
					depletion_rate = 0.4 * mult
					if (prob(33))
						boutput(M, "<span class='alert'>You feel horribly weak.</span>")
					if (prob(10))
						boutput(M, "<span class='alert'>You cannot breathe!</span>")
						M.take_oxygen_deprivation(5 * mult)
					if (prob(5))
						boutput(M, "<span class='alert'>You feel a sharp pain in your chest!</span>")
						M.take_oxygen_deprivation(25 * mult)
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 100 * mult))
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 60 * mult))
				else
					depletion_rate = 0.2 * mult
				..()

				return

		fooddrink/cornstarch
			name = "corn starch"
			id = "cornstarch"
			description = "The powdered starch of maize, derived from the kernel's endosperm. Used as a thickener for gravies and puddings."
			reagent_state = SOLID
			fluid_r = 240
			fluid_g = 240
			fluid_b = 240
			transparency = 255

		fooddrink/cornsyrup
			name = "corn syrup"
			id = "cornsyrup"
			description = "A sweet syrup derived from corn starch that has had its starches converted into maltose and other sugars."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 240
			fluid_b = 240
			transparency = 100
			viscosity = 0.6

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.reagents.add_reagent("sugar", 1.2 * mult)
				..()

			glaucogen
				name = "glaucogen"
				id = "glaucogen"
				description = "A synthetically generated polysaccharide structure that mimics the main storage form of glucose in the body."
				depletion_rate = 1

		fooddrink/VHFCS
			name = "very-high-fructose corn syrup"
			id = "VHFCS"
			description = "An incredibly sweet syrup, created from corn syrup treated with enzymes to convert its sugars into fructose."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 240
			fluid_b = 240
			transparency = 100
			viscosity = 0.8

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.reagents.add_reagent("sugar", 2.4 * mult)
				..()

		fooddrink/gravy
			name = "gravy"
			id = "gravy"
			description = "A savory sauce made from a simple meat-dripping roux and milk."
			reagent_state = LIQUID
			fluid_r = 182
			fluid_g = 100
			fluid_b = 26
			transparency = 250
			hunger_value = 0.25

		fooddrink/mashedpotatoes
			name = "mashed potatoes"
			id = "mashedpotatoes"
			description = "A starchy food paste made from boiled potatoes."
			reagent_state = SOLID
			fluid_r = 214
			fluid_g = 217
			fluid_b = 193
			transparency = 255
			hunger_value = 0.75
			viscosity = 0.4

		fooddrink/msg
			name = "monosodium glutamate"
			id = "msg"
			description = "Monosodium Glutamate is a sodium salt known chiefly for its use as a controversial flavor enhancer."
			fluid_r = 245
			fluid_g = 245
			fluid_b = 245
			transparency = 255
			depletion_rate = 0.2

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				src = null
				if(!volume_passed)
					return
				if(!ishuman(M))
					return
				if(method == INGEST)
					boutput(M, "<span class='notice'>That tasted amazing!</span>")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(ishuman(M) && ((M.bioHolder.bloodType != "A+") || probmult(5)))
					if (prob(10))
						M.take_toxin_damage(rand(2.4) * mult)
					if (prob(7))
						boutput(M, "<span class='alert'>A horrible migraine overpowers you.</span>")
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 40 * mult))
				..()

		fooddrink/egg
			name = "egg"
			id = "egg"
			description = "A runny and viscous mixture of clear and yellow fluids."
			reagent_state = LIQUID
			fluid_r = 240
			fluid_g = 220
			fluid_b = 0
			transparency = 225
			pathogen_nutrition = list("water", "sugar", "sodium", "iron", "nitrogen")
			hunger_value = 1
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.nutrition += 1 * mult

				if(probmult(8))
					M.emote("fart")

				if(prob(3))
					M.reagents.add_reagent("cholesterol", rand(1,2) * mult)
				..()

		fooddrink/beff
			name = "beff"
			id = "beff"
			description = "An advanced blend of mechanically-recovered meat and textured synthesized protein product notable for its unusual crystalline grain when sliced."
			reagent_state = SOLID
			fluid_r = 172
			fluid_g = 126
			fluid_b = 103
			transparency = 255
			hunger_value = 0.5
			viscosity = 0.2

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(5))
					M.reagents.add_reagent("cholesterol", rand(1,3) * mult)
				if(prob(8))
					M.reagents.add_reagent(pick("badgrease","toxic_slurry","synthflesh","bloodc","cornsyrup","porktonium"), depletion_rate*2 * mult)
				else if (prob(6))
					boutput(M, "<span class='alert'>[pick("You feel ill.","Your stomach churns.","You feel queasy.","You feel sick.")]</span>")
					M.emote(pick("groan","moan"))
				..()

		fooddrink/enriched_msg //Hukhukhuk brings you another culinary war crime
			name = "Enriched MSG"
			id = "enriched_msg"
			description = "This highly illegal substance was only rumored to exist, it is the most flavorful substance known. It is believed that it causes such euphoria that the body begins to heal its own wounds, however no living creature can resist having seconds."
			reagent_state = SOLID
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 255
			addiction_prob = 100
			addiction_min = 0
			overdose = 25
			viscosity = 0.2

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				//src = null
				if (!volume_passed)
					return ..()
				if (method == INGEST)
					var/datum/ailment/addiction/AD = M.addicted_to_reagent(src)
					if (!AD)
						boutput(M, "<B>THIS TASTES <font size='92'>~<font color='#FF0000'> A<font color='#FF9900'> M<font color='#FFff00'> A<font color='#00FF00'> Z<font color='#0000FF'> I<font color='#FF00FF'> N<font color='#660066'> G<font color='#000000'> ~ !</font></B>")
				..(M, method, volume_passed)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.get_oxygen_deprivation())
					M.take_oxygen_deprivation(-1 * mult)
				if(M.get_toxin_damage())
					M.take_toxin_damage(-1 * mult)
				if(M:losebreath)
					M:losebreath -= (1 * mult)
				M:HealDamage("All", 3 * mult, 3 * mult)
				M:UpdateDamageIcon()
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1) //lesser
					M.stuttering += 1
					if(effect <= 1)
						M.visible_message("<span class='alert'><b>[M.name]</b> suddenly starts salivating.</span>")
						M.emote("drool")
						M.change_misstep_chance(10 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 20 * mult))
					else if(effect <= 3)
						M.visible_message("<span class='alert'><b>[M.name]</b> begins to reminisce about food.</span>")
						M.changeStatus("stunned", 20 * mult)
					else if(effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> pouts and sniffles a bit.</span>")
					else if(effect <= 7)
						M.visible_message("<span class='alert'><b>[M.name]</b> shakes uncontrollably.</span>")
						M.make_jittery(30)
				else if (severity == 2) // greater
					if(effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> enters a food coma!</span>")
						M.emote("faint")
						M.setStatus("paralysis", max(M.getStatusDuration("paralysis"), 60 * mult))
					else if(effect <= 5)
						M.visible_message("<span class='alert'><b>[M.name]</b> wants more delicious food!</span>")
						M.emote("scream")
						M.setStatus("stunned", max(M.getStatusDuration("stunned"), 50 * mult))
					else if(effect <= 8)
						M.visible_message("<span class='alert'><b>[M.name]</b> appears extremely depressed.</span>")
						M.emote("moan")
						M.change_misstep_chance(25 * mult)
						M.setStatus("weakened", max(M.getStatusDuration("weakened"), 70 * mult))

		fooddrink/pepperoni //Hukhukhuk presents. pepperoni and acetone
			name = "pepperoni"
			id = "pepperoni"
			description = "An Italian-American variety of salami usually made from beef and pork"
			reagent_state = SOLID
			fluid_r = 172
			fluid_g = 126
			fluid_b = 103
			transparency = 255
			hunger_value = 0.25

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask)
							boutput(M, "<span class='alert'>The pepperoni bounces off your [H.wear_mask]!</span>")
							return
						if(H.head)
							boutput(M, "<span class='alert'>Your [H.head] protects you from the errant pepperoni!</span>")
							return

					if(prob(50))
						M.emote("burp")
						boutput(M, "<span class='alert'>My goodness, that was tasty!</span>")
					else
						boutput(M, "<span class='alert'>A slice of pepperoni slaps you!</span>")
						playsound(M.loc, "sound/impact_sounds/Generic_Slap_1.ogg", 50, 1)
						M.TakeDamage("head", 1, 0, 0, DAMAGE_BLUNT)

			reaction_turf(var/turf/T, var/volume)
				src = null
				if(volume >= 20 && !(locate(/obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log) in T))
					new /obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log(T)

		fooddrink/mint
			name = "mint" //calling it mint juice is weiiird
			id = "mint"
			fluid_r = 167
			fluid_g = 238
			fluid_b = 159
			transparency = 220
			description = "A light green liquid extracted from mint leaves."
			reagent_state = LIQUID

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(M.bodytemperature > 280)
					M.bodytemperature = max(M.bodytemperature-(5 * mult),280)
				..()
				return

		fooddrink/juice_lime
			name = "lime juice"
			id = "juice_lime"
			fluid_r = 33
			fluid_g = 248
			fluid_b = 66
			description = "A citric beverage extracted from limes."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask) return
						if(H.head) return
					if(prob(75))
						M.emote("gasp")
						boutput(M, "<span class='alert'>Your eyes sting!</span>")
						M.change_eye_blurry(rand(5, 20))

		fooddrink/juice_cran
			name = "Cranberry juice"
			id = "juice_cran"
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			description = "An extremely tart juice usually mixed into other drinks and juices."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_orange
			name = "orange juice"
			id = "juice_orange"
			fluid_r = 252
			fluid_g = 163
			fluid_b = 30
			description = "A citric beverage extracted from oranges."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask) return
						if(H.head) return
					if(prob(75))
						M.emote("gasp")
						boutput(M, "<span class='alert'>Your eyes sting!</span>")
						M.change_eye_blurry(rand(5, 20))
				else if (method == INGEST)
					if(M.reagents.has_reagent("menthol"))
						M.visible_message("<b>[M]</b> grimaces.","<span class='alert'>Yuck! This tastes awful!</span>")

		fooddrink/juice_lemon
			name = "lemon juice"
			id = "juice_lemon"
			fluid_r = 251
			fluid_g = 229
			fluid_b = 30
			description = "A citric beverage extracted from lemons."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask) return
						if(H.head) return
					if(prob(75))
						M.emote("gasp")
						boutput(M, "<span class='alert'>Your eyes sting!</span>")
						M.change_eye_blurry(rand(5, 20))

		fooddrink/juice_tomato
			name = "tomato juice"
			id = "juice_tomato"
			fluid_r = 255
			fluid_g = 0
			fluid_b = 0
			description = "Tomatoes pureed down to a liquid state."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_strawberry
			name = "strawberry juice"
			id = "juice_strawberry"
			fluid_r = 195
			fluid_g = 21
			fluid_b = 15
			description = "Fresh juice produced by strawberries."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_blueberry
			name = "blueberry juice"
			id = "juice_blueberry"
			fluid_r = 97
			fluid_g = 64
			fluid_b = 73
			description = "Don't get it on your hands or it'll be there forever."
			reagent_state = LIQUID
			thirst_value = 1.5

		fooddrink/juice_cherry
			name = "cherry juice"
			id = "juice_cherry"
			fluid_r = 235
			fluid_g = 0
			fluid_b = 0
			description = "The juice from a thousand screaming cherries.  Silent screams."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_pinapple
			name = "pineapple juice"
			id = "juice_pineapple"
			fluid_r = 255
			fluid_g = 249
			fluid_b = 71
			description = "Juice from a pineapple. A surprise, considering the name!"
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_apple
			name = "apple juice"
			id = "juice_apple"
			fluid_r = 233
			fluid_g = 216
			fluid_b = 0
			description = "Fresh juice produced by apples."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

		fooddrink/juice_peach
			name = "peach juice"
			id = "juice_peach"
			fluid_r = 255
			fluid_g = 170
			fluid_b = 140
			description = "An artificial peach drink that is legally sold as 100% all natural peach juice."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(8))
					M.reagents.add_reagent("juice_apple", 2 * mult)
				if(prob(6))
					M.reagents.add_reagent("VHFCS", 2 * mult)
				..()

		fooddrink/juice_carrot
			name = "carrot juice"
			id = "juice_carrot"
			fluid_r = 255
			fluid_g = 129
			fluid_b = 71
			description = "A glass of carrot juice a day keeps the ophthalmologist away."
			reagent_state = LIQUID
			thirst_value = 1
			bladder_value = -1

		fooddrink/juice_grapefruit
			name = "grapefruit juice"
			id = "juice_grapefruit"
			fluid_r = 255
			fluid_g = 159
			fluid_b = 135
			description = "A tart beverage extracted from grapefruits."
			reagent_state = LIQUID
			thirst_value = 1.5
			bladder_value = -1.5

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				for(var/reagent_id in M.reagents.reagent_list)
					var/datum/reagent/current_reagent = M.reagents.reagent_list[reagent_id]
					if(istype(current_reagent, /datum/reagent/medical))
						M.reagents.remove_reagent(reagent_id, 0.5) // grapefruit juice is known to reduce the effectiveness of a wide variety of medications
				..(M)

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask) return
						if(H.head) return
					if(prob(75))
						M.emote("gasp")
						boutput(M, "<span class='alert'>Your eyes sting!</span>")
						M.change_eye_blurry(rand(5, 20))

		fooddrink/coconut_milk
			name = "coconut milk"
			id = "coconut_milk"
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			description = "Well, it's not actually milk, considering that coconuts aren't mammals with mammary glands. It's really more like coconut juice. Or coconut water."
			reagent_state = LIQUID
			thirst_value = 1
			bladder_value = -1

		fooddrink/juice_pickle
			name = "pickle juice"
			id = "juice_pickle"
			fluid_r = 10
			fluid_g = 235
			fluid_b = 10
			transparency = 150
			description = "A salty brine containing garlic and dill, typically used to ferment and pickle cucumbers."
			reagent_state = LIQUID
			thirst_value = 1
			bladder_value = -1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(prob(15))
					M.reagents.add_reagent("charcoal", 1 * mult)
					M.reagents.add_reagent("antihol", 1 * mult)
				..()

		fooddrink/cocktail_citrus
			name = "triple citrus"
			id = "cocktail_citrus"
			description = "A refreshing mixed drink of orange, lemon and lime juice."
			reagent_state = LIQUID
			thirst_value = 2
			bladder_value = -2

			fluid_r = 12
			fluid_g = 229
			fluid_b = 72
			reaction_mob(var/mob/M, var/method=INGEST, var/volume)
				if(method == INGEST)
					if (M.get_toxin_damage())
						M.take_toxin_damage(rand(1,2) * -1) //I assume this was not supposed to be poison.

		fooddrink/cocktail_triple
			name = "Triple Triple"
			id = "cocktail_triple"
			description = "What the fuck is this, somehow the liquid looks unable to settle."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 235
			fluid_b = 7
			transparency = 155
			overdose = 33
			depletion_rate = 0.6
			energy_value = 10
			hunger_value = -2
			thirst_value = -2
			bladder_value = -2
			stun_resist = 100
			var/remove_buff = 0

			pooled()
				..()
				remove_buff = 0

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.add_stam_mod_regen("tripletriple", 3333)

				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/cocktail_triple, src.type)
				..()

			reaction_mob(var/mob/M, var/method=INGEST, var/volume)
				if(method == INGEST)
					if (M.get_toxin_damage())
						M.take_toxin_damage(9 * -1) //I assume this was not supposed to be poison.
					M.playsound_local(M, "sound/effects/bigwave.ogg", 50, 1)
					boutput(M, "<span class='notice'><B>You feel refreshed.<B></span>")

			on_remove()
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/cocktail_triple, src.type)

				if(hascall(holder.my_atom,"removeOverlayComposition"))
					holder.my_atom:removeOverlayComposition(/datum/overlayComposition/triplemeth)

				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					remove_buff = M.remove_stam_mod_regen("tripletriple")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M)
					M = holder.my_atom

				if(probmult(10))
					new /obj/decal/cleanable/urine(M.loc)

				if(probmult(15))
					M.visible_message("<span class='alert'>[M] pukes violently!</span>")
					M.vomit()
					if(prob(33))
						new /obj/item/reagent_containers/food/snacks/plant/lemon(M.loc)
						M.visible_message("<span class='alert'>[M] pukes out an entire lemon!</span>")
					else if(prob(33))
						new /obj/item/reagent_containers/food/snacks/plant/orange(M.loc)
						M.visible_message("<span class='alert'>[M] pukes out an entire orange!</span>")
					else if(prob(1))
						new /obj/item/reagent_containers/food/snacks/plant/lime(M.loc)
						new /obj/item/reagent_containers/food/snacks/plant/orange(M.loc)
						new /obj/item/reagent_containers/food/snacks/plant/lemon(M.loc)
						M.visible_message("<span class='alert'>[M] pukes out a trifecta of citrus!</span>")
					else
						new /obj/item/reagent_containers/food/snacks/plant/lime(M.loc)
						M.visible_message("<span class='alert'>[M] pukes out an entire lime!</span>")
				if(probmult(10))
					boutput(M, "<span class='alert'><B>Gotta get a grip!<B></span>")
				if(probmult(10))
					boutput(M, "<span class='alert'><B>I can only think of citrus!!<B></span>")
				M.playsound_local(M, "sound/effects/heartbeat.ogg", 50, 1)

				if(hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/triplemeth)

				if(probmult(50)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.make_dizzy(5 * mult)
				M.change_misstep_chance(50 * mult)
				M.take_brain_damage(1 * mult)
				if(M.getStatusDuration("paralysis")) M.delStatus("paralysis")
				M.delStatus("stunned")
				M.delStatus("weakened")
				M.delStatus("disorient")
				if(M.sleeping) M.sleeping = 0
				..(M)

			do_overdose(var/severity = 1, var/mob/M, var/mult = 1)
				if (severity == 1)
					M.take_toxin_damage(3 * mult)
					M.make_dizzy(33 * mult)

					M.take_brain_damage(9 * mult)
					M.emote("scream")

					if(probmult(25)) fake_attackEx(M, 'icons/effects/hallucinations.dmi', "orange", "orange")
					if(probmult(25)) fake_attackEx(M, 'icons/effects/hallucinations.dmi', "lime", "lime")
					if(probmult(25)) fake_attackEx(M, 'icons/effects/hallucinations.dmi', "lemon", "lemon")

					if(probmult(15)) boutput("<span class='alert'><B>FRUIT IN MY EYES!!!</B></span>")

					if(probmult(25))
						M.vomit()
						new /obj/item/reagent_containers/food/snacks/plant/lime(M.loc)
						new /obj/item/reagent_containers/food/snacks/plant/orange(M.loc)
						new /obj/item/reagent_containers/food/snacks/plant/lemon(M.loc)
						M.visible_message("<span class='alert'>[M] pukes out a trifecta of citrus!</span>")

		fooddrink/lemonade
			name = "lemonade"
			id = "lemonade"
			fluid_r = 237
			fluid_g = 218
			fluid_b = 44
			transparency = 150
			description = "A refreshing, sweet and sour drink consisting of sugar and lemon juice."
			reagent_state = LIQUID
			thirst_value = 0.7
			bladder_value = -0.2

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				if(method == TOUCH)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.wear_mask) return
						if(H.head) return
					if(prob(75))
						M.emote("gasp")
						boutput(M, "<span class='alert'>Your eyes sting!</span>")
						M.change_eye_blurry(rand(2, 10))
				else if (method == INGEST)
					if (prob(60) && (holder && holder.get_reagent_amount("sugar") < (volume/3)))
						M.visible_message("<b>[M]'s</b> mouth puckers!","<span class='alert'>Yow! Sour!</span>")

		fooddrink/lemonade/limeade
			name = "limeade"
			id = "limeade"
			fluid_r = 203
			fluid_g = 255
			fluid_b = 140
			description = "A refreshing, sweet and sour drink consisting of sugar and lime juice."

		fooddrink/halfandhalf
			name = "half and half"
			id = "halfandhalf"
			reagent_state = LIQUID
			fluid_r = 142
			fluid_g = 115
			fluid_b = 51
			transparency = 200
			description = "A mixture of half lemonade and half tea, sometimes named after a dead Earth golfer. Not to be confused with the dairy kind."
			thirst_value = 2
			bladder_value = -2
			viscosity = 0.1

		fooddrink/temp_bioeffect
			var/bioeffect_id = null

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume_passed)
				var/tempbioid = src.bioeffect_id //needed because we detatch the proc from src below
				src = null
				if(!volume_passed)
					return
				if(!ishuman(M))
					return
				if(!tempbioid)
					return
				//var/mob/living/carbon/human/H = M
				//if(method == INGEST)
				//drsingh commented method check to make this stuff work in smoke. because it's funny.
				M.bioHolder.AddEffect(tempbioid, timeleft = 180)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!bioeffect_id)
					return

				if(!M) M = holder.my_atom
				M.bioHolder.AddEffect(bioeffect_id, timeleft = 180)
				..()
				return

		fooddrink/temp_bioeffect/swedium
			name = "swedium"
			id = "swedium"
			description = "A rather neutral substance."
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			transparency = 20
			bioeffect_id = "accent_swedish"

		fooddrink/temp_bioeffect/caledonium
			name = "caledonium"
			id = "caledonium"
			description = "A brave blue substance with flecks of tartan."
			fluid_r = 37
			fluid_g = 72
			fluid_b = 180
			transparency = 20
			bioeffect_id = "accent_scots"

		fooddrink/temp_bioeffect/essenceofelvis
			name = "essence of Elvis"
			id = "essenceofelvis"
			description = "The King is dead, but a part of him lives on in all of us."
			fluid_r = 255
			fluid_g = 255
			fluid_b = 255
			transparency = 60
			bioeffect_id = "accent_elvis"

		fooddrink/temp_bioeffect/suomium
			name = "suomium"
			id = "suomium"
			description = "A feisty, no-nonsense substance."
			fluid_r = 125
			fluid_g = 125
			fluid_b = 255
			transparency = 60
			bioeffect_id = "accent_finnish"

		fooddrink/temp_bioeffect/quebon
			name = "fleur-de-lys"
			id = "quebon"
			description = "A rather self-important substance."
			fluid_r = 0
			fluid_g = 31
			fluid_b = 151
			transparency = 60
			bioeffect_id = "accent_french"
			addiction_prob = 10
			overdose = 30

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if (prob(5))
					boutput(M, "<span class='alert'>GAH! My culture! Erased!</span>")
					M.take_brain_damage(rand(1,2) * mult)

				return

		fooddrink/bonerjuice
			name = "the satisfaction of making spaghetti"
			id = "bonerjuice"
			description = "The congealed essence of cullinary passion."
			fluid_r = 200
			fluid_g = 231
			fluid_b = 220
			transparency = 160
			addiction_prob = 100
			overdose = 35

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if (prob(5))
					boutput(M, "<span class='alert'>GAH! My bones!</span>")
					M.TakeDamage("All", 5 * mult, 0, 0, DAMAGE_CRUSH)

				return

		fooddrink/yuck
			name = "????"
			id = "yuck"
			description = "A gross and unidentifiable substance."
			fluid_r = 10
			fluid_g = 220
			fluid_b = 10
			hunger_value = 0.25

			reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume_passed)
				if(!volume_passed)
					return
				if(!ishuman(M))
					return

				var/list/covered = holder.covered_turf()
				src = null

				var/do_stunny = 1
				if (covered.len > 1)
					do_stunny = prob(100/covered.len)

				//var/mob/living/carbon/human/H = M
				if(method == INGEST && do_stunny)
					boutput(M, "<span class='alert'>Ugh! Eating that was a terrible idea!</span>")
					M.changeStatus("stunned", 2 SECONDS)
					M.changeStatus("weakened", 2 SECONDS)
					M.contract_disease(/datum/ailment/disease/food_poisoning, null, null, 1) // path, name, strain, bypass resist

		fooddrink/fakecheese
			name = "cheese substitute"
			id = "fakecheese"
			description = "A cheese-like substance derived loosely from actual cheese."
			fluid_r = 255
			fluid_b = 50
			fluid_g = 255
			addiction_prob = 2//10
			addiction_prob2 = 10
			addiction_min = 5
			max_addiction_severity = "LOW"
			overdose = 50
			hunger_value = 0.25

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if (prob(8))
					boutput(M, "<span class='alert'>You feel something squirming in your stomach. Your thoughts turn to cheese and you begin to sweat.</span>")
					M.take_toxin_damage(rand(1,2) * mult)

				return

		fooddrink/pizza
			name = "pizza"
			id = "pizza"
			description = "I'm pizza"
			reagent_state = LIQUID
			fluid_r = 220
			fluid_g = 160
			fluid_b = 22
			depletion_rate = 1
			hunger_value = 3

			on_mob_life(var/mob/M, var/mult = 1)
				M.reagents.add_reagent("juice_tomato", 0.25 * mult)
				M.reagents.add_reagent("cheese", 0.25 * mult)
				M.reagents.add_reagent("bread", 0.25 * mult)
				M.reagents.add_reagent("pepperoni", 0.25 * mult)
				if(probmult(22))
					M.emote("burp")
				..()
			reaction_turf(var/turf/T, var/volume)
				src = null//WTF IS THIS
				if(volume < rand(5,9))
					if(prob(5))
						T.visible_message("<span class='alert'>The [T] fails to muster up the effort to become delicious!</span>")
					return
				else
					T.setMaterial(getMaterial("pizza"))
			reaction_obj(var/obj/O, var/volume)
				if(volume < rand(5,9))
					if(prob(5))
						O.visible_message("<span class='alert'>The [O] fails to muster up the effort to become delicious!</span>")
					return
				else
					O.setMaterial(getMaterial("pizza"))

		fooddrink/friedessence
			name = "The Physical Manifestation Of The Very Concept Of Fried Food"
			id = "friedessence"
			description = "Liquified fryer science. This stuff is liquid gold!"
			reagent_state = LIQUID
			fluid_r = 126
			fluid_g = 46
			fluid_b = 31

		fooddrink/ghostchilijuice
			name = "ghost chili juice"
			id = "ghostchilijuice"
			description = "Juice from the universe's hottest chilli. Do not consume."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 127
			fluid_b = 50
			transparency = 255

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				//If the user drinks milk, they'll be fine.
				if(M.reagents.has_reagent("milk"))
					boutput(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
					M.reagents.del_reagent("milk")
					M.reagents.del_reagent("ghostchilijuice")
				if(probmult(8))
					boutput(M, "<span class='alert'><b>Oh god! Oh GODD!!</b></span>")
				if(prob(50))
					boutput(M, "<span class='alert'>Your throat burns furiously!</span>")
					M.emote(pick("scream","cry","choke","gasp"))
					M.setStatus("stunned", max(M.getStatusDuration("stunned"), 20 * mult))
				if(probmult(8))
					boutput(M, "<span class='alert'>Why!? WHY!?</span>")
				if(probmult(8))
					boutput(M, "<span class='alert'>ARGHHHH!</span>")
				if(probmult(33))
					M.visible_message("<span class='alert'>[M] suddenly and violently vomits!</span>")
					M.vomit()
					boutput(M, "<span class='notice'>Thank goodness. You're not sure how long you could have held out with heat that intense!</span>")
					M.reagents.del_reagent("ghostchilijuice")
				if(probmult(min(10,5 * volume)))
					boutput(M, "<span class='alert'><b>OH GOD OH GOD PLEASE NO!!</b></span>")
					var/mob/living/L = M
					if(istype(L) && L.getStatusDuration("burning"))
						L.changeStatus("burning", 1000 * mult)
					if(prob(50))
						SPAWN_DBG(2 SECONDS)
							//Roast up the player
							if (M)
								boutput(M, "<span class='alert'><b>IT BURNS!!!!</b></span>")
								sleep(0.2 SECONDS)
								M.visible_message("<span class='alert'>[M] is consumed in flames!</span>")
								M.firegib()
				..()

		fooddrink/alcoholic/nicotini
			name = "nicotini"
			id = "nicotini"
			description = "Why would you even mix this? How does nicotine even taste?	"
			reagent_state = LIQUID
			fluid_r = 153
			fluid_g = 67
			fluid_b = 85
			transparency = 190
			alch_strength = 0.3
			depletion_rate = 0.4

			on_mob_life(var/mob/M, var/mult = 1)
				M.reagents.add_reagent("nicotine", 1 * mult)
				..()

		fooddrink/alcoholic/rcola
			name = "Rum and Cola"
			id = "rcola"
			fluid_r = 115
			fluid_g = 38
			fluid_b = 77
			alch_strength = 0.7
			description = "It's fizzy, it's tangy, and perfect for when you can't decide if you wanna get the jitters or knock yourself out!"
			reagent_state = LIQUID

		fooddrink/alcoholic/honky_tonic
			name = "Honky Tonic"
			id = "honky_tonic"
			fluid_r = 255
			fluid_g = 102
			fluid_b = 204
			alch_strength = 1
			description = "The true miracle of this bastardization of mixology is that it somehow isn't lethal."
			reagent_state = LIQUID

			// Occasionally weakens and stuns the mob. Sometimes they honk. More rarely, they might even randomly say something stupid against their will.
			on_mob_life(var/mob/M, var/mult = 1)
				..(M)
				if(!M) M = holder.my_atom
				src = null
				if(probmult(10))
					boutput(M, "<span class='alert'>Your body feels like it's being tickled from the inside out!</span>")
					M.changeStatus("weakened", 1 SECONDS)
					M.emote("laugh")
					M.visible_message("<span class='alert'>[M] sneezes. \His sneeze sounds like a honk!</span>")
					playsound(M.loc, "sound/items/bikehorn.ogg", 50, 1)
				if (probmult(4))
					//Create an alphabet soup of random phrases and force the mob to say it!
					var/message = null
					var/messageStart = pick(
						"Man, I sure feel like a",\
						"You are a",\
						"My mother once told me that I was born a",\
						"Father always said all I needed was a",\
						"That's just like the time I ate a",\
						"Aunty Muriel was always prone to giving me a",\
						"Your face looks like a",\
						"Spoiler alert! We're all living inside of a",\
						"Tonight we're gonna go on a trip in a",\
						"Save me! I'm being attacked by a",\
						"Brainstorming time; let's try making a",\
						"Let's try feeding the captain a",\
						"Chill out and dive right into the",\
						"Take off the clown's mask to reveal a",\
						"I heard you talking about me! You said I was a",\
						"Y'know, right now I could totally go for a",\
						"I read in a book once that in each and every one of us is a",\
						"I asked the captain what he thought of me, and he just turned to me and said I was a",\
						"You and me? We're just like a ")
					var/messageAdjective = pick(
						" REALLY big ",\
						" smelly ",\
						" delicious ",\
						" sweet sweet ",\
						" totally bodacious ",\
						"n awesomely radical ",\
						" super stinky ",\
						"n ugly-ass ",\
						" dum-dum bum-bum ",\
						" gorgeous and beautiful ",\
						" gramatically incorrect ",\
						" needlessly vulgar and generally problematic ",\
						" fucking dumbass bullshit poopie ",\
						" tired old ",\
						" mentally corrupt ",\
						" pretentious little ",\
						" not-so-robust ",\
						" flowery and aromatic ",\
						" fourth-wall breaking ",\
						" dirty yellow-bellied ",\
						" drunken and drugged ",\
						"n uncannily realistic")
					var/messageNoun = pick(
						"ghost!",\
						"freak!",\
						"pirate!",\
						"lawyer with WAY too much free time.",\
						"man made of meat.",\
						"bowl of word soup.",\
						"bee.",\
						"greytider.",\
						"buttbot.",\
						"existential nightmare.",\
						"key to worldwide destruction...",\
						"novel without a proper ending.",\
						"space station!",\
						"monkey.",\
						"frog.",\
						"space god.",\
						"monster made of madness.",\
						"wizard!",\
						"burrito.",\
						"ass." ,\
						"cluwne.")
					var/messageEnd = null
					if (prob(50))
						messageEnd = pick(
							" What did I mean by this?",\
							" And that's not even half of it!",\
							" Thanks for coming to my presentation.",\
							" Thank you have a good day.",\
							" I'M the traitor by the way!",\
							" Please free me from this chemical prison.",\
							" And that's just the tip of the iceberg!",\
							" By the way, I'm hungry.",\
							" Sorry, was that too much information?",\
							" Momma told me to keep that a secret though.",\
							" Sorry, didn't mean to make myself cry!",\
							" Sorry, I may be a little tipsy.",\
							" I never looked at life the same way ever since I learned that.",\
							" Deep, huh?",\
							" I still ponder the meaning of it to be honest.",\
							" I still haven't gotten over that.")
					message = messageStart + messageAdjective + messageNoun + messageEnd
					M.say(message)
				return

		fooddrink/alcoholic/lingtea
			name = "Ling Island Iced Tea"
			id = "lingtea"
			description = "Preferred by changelings, crew members, and the surprising overlap between them."
			reagent_state = LIQUID
			alch_strength = 0
			fluid_r = 137
			fluid_g = 158
			fluid_b = 81
			transparency = 200
			var/alch_counter = 0 //ripped straight from amantin - moonlol

			pooled()
				..()
				alch_counter = 0

			on_mob_life(var/mob/M, var/mult = 0)

				if (!M) M = holder.my_atom
				alch_counter += rand(0,0.1) + 0.2 // RNG rolls moved to accumulation proc for consistency

				..()

			on_mob_life_complete(var/mob/living/M)
				if(M)
					M.reagents.add_reagent("ethanol", (alch_counter + (rand(2,3))))

		fooddrink/alcoholic/hottoddy
			name = "hot Toddy"
			id = "hottoddy"
			fluid_r = 255
			fluid_g = 220
			fluid_b = 95
			alch_strength = 0.4
			description = "A warm, late night drink, usually enjoyed during long winter nights."
			reagent_state = LIQUID

		fooddrink/grenadine
			name = "grenadine"
			id = "grenadine"
			fluid_r = 234
			fluid_g = 19
			fluid_b = 19
			description = "A sticky, sweet and tart non-alcoholic bar syrup, used in cocktails for it's distinct bright red colour."
			reagent_state = LIQUID

		fooddrink/lemonade/pinklemonade
			name = "pink lemonade"
			id = "pinklemonade"
			fluid_r = 253
			fluid_g = 230
			fluid_b = 237
			description = "A popular twist on cloudy lemonade, this soft drink has been dyed pink. How colourful."
			reagent_state = LIQUID

		fooddrink/alcoholic/duckfart
			name = "Duck Fart"
			id = "duckfart"
			fluid_r = 253
			fluid_g = 245
			fluid_b = 230
			alch_strength = 0.6
			description = "An eccentric 'trio cocktail', in which the 3 ingredients have been layed on top on another."
			reagent_state = LIQUID

		fooddrink/alcoholic/philcollins
			name = "Phil Collins"
			id = "philcollins"
			fluid_r = 240
			fluid_g = 248
			fluid_b = 255
			alch_strength = 0.3
			description = "A variation on a well known drink, paying tribute to a well known drummer."
			reagent_state = LIQUID

		fooddrink/alcoholic/spicedrum
			name = "spiced rum"
			id = "spicedrum"
			fluid_r = 205
			fluid_g = 149
			fluid_b = 12
			alch_strength = 0.6
			description = "An egregious and disgusting misinterpretation of some perfectly good rum."
			reagent_state = LIQUID

		fooddrink/alcoholic/beesknees
			name = "Bee's Knees"
			id = "beesknees"
			fluid_r = 255
			fluid_g = 236
			fluid_b = 139
			alch_strength = 0.3
			description = "A cocktail from the prohibition era, named after a popular expression."
			reagent_state = LIQUID
