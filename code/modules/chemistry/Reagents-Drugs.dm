//Contains wacky space drugs

ABSTRACT_TYPE(/datum/reagent/drug)

datum
	reagent
		drug/
			name = "some drug"

		drug/bathsalts
			name = "bath salts"
			id = "bathsalts"
			description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 100
			addiction_prob = 15//80
			addiction_min = 5
			overdose = 20
			depletion_rate = 0.6
			energy_value = 1
			hunger_value = -0.1
			bladder_value = -0.1
			thirst_value = -0.05
			threshold = THRESHOLD_INIT

			cross_threshold_under()
				..()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_bathsalts", 3)
				return

			cross_threshold_under()
				..()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_bathsalts")
				return

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom

				var/check = rand(0,100)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					if (check < 8 && H.bioHolder.mobAppearance.customization_second.id != "tramp") // M.is_hobo = very yes
						H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/beard/tramp
						H.set_face_icon_dirty()
						boutput(M, "<span class='alert'><b>You feel gruff!</b></span>")
						SPAWN(0.3 SECONDS)
							M.visible_message("<span class='alert'><b>[M.name]</b> has a wild look in their eyes!</span>")
					if(check < 60)
						if(H.getStatusDuration("paralysis")) H.delStatus("paralysis")
						H.delStatus("stunned")
						H.delStatus("weakened")
					if(check < 30)
						H.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))

				M.druggy = max(M.druggy, 15)
				if(check < 20)
					M.change_misstep_chance(10 * mult)
				// a really shitty form of traitor stimulants - you'll be tough to take down but nearly uncontrollable anyways and you won't heal the way stims do


				if(check < 8)
					M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
					M.visible_message("<span class='alert'><b>[M.name]</b> scratches at something under their skin!</span>")
					random_brute_damage(M, 5 * mult)
				else if (check < 16)
					switch(rand(1,2))
						if(1)
							if(prob(20))
								fake_attackEx(M, 'icons/misc/critter.dmi', "death", "death")
								boutput(M, "<span class='alert'><b>OH GOD LOOK OUT!!!</b>!</span>")
								M.emote("scream")
								M.playsound_local(M.loc, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, 1)
							else if(prob(50))
								fake_attackEx(M, 'icons/misc/critter.dmi', "mimicface", "smiling thing")
								boutput(M, "<span class='alert'><b>The smiling thing</b> laughs!</span>")
								M.playsound_local(M.loc, pick('sound/voice/cluwnelaugh1.ogg', 'sound/voice/cluwnelaugh2.ogg', 'sound/voice/cluwnelaugh3.ogg'), 35, 1)
							else
								M.playsound_local(M.loc, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), 50, 1)
								boutput(M, "<span class='alert'><b>You hear something strange behind you...</b></span>")
								var/ants = rand(1,3)
								for(var/i = 0, i < ants, i++)
									fake_attackEx(M, 'icons/effects/genetics.dmi', "psyche", "stranger")
						if(2)
							var/halluc_state = null
							var/halluc_name = null
							switch(rand(1,5))
								if(1)
									halluc_state = "husk"
									halluc_name = pick("dad", "mom")
								if(2)
									halluc_state = "fire3"
									halluc_name = pick("vision of your future", "dad", "mom")
								if(3)
									halluc_state = "eaten"
									halluc_name = pick("???", "bad bad BAD")
								if(4)
									halluc_state = "decomp3"
									halluc_name = pick("result of your poor life decisions", "grampa")
								if(5)
									halluc_state = "fire2"
									halluc_name = pick("mom", "dad", "why are they burning WHY")
							fake_attackEx(M, 'icons/mob/human.dmi', halluc_state, halluc_name)
				else if(check < 24)
					boutput(M, "<span class='alert'><b>They're coming for you!</b></span>")
				else if(check < 28)
					boutput(M, "<span class='alert'><b>THEY'RE GONNA GET YOU!</b></span>")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.emote("faint")
					//var/mob/living/carbon/human/H = M
					//if (istype(H))
					M.take_radiation_dose(0.001 SIEVERTS * volume, internal=TRUE)
					M.take_toxin_damage(5)
					M.take_brain_damage(10)
				else
					boutput(M, "<span class='notice'>You feel a bit more salty than usual.</span>")
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> flails around like a lunatic!</span>")
						M.change_misstep_chance(25 * mult)
						M.make_jittery(10)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.emote("twitch_s")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("faint")
						M.reagents.add_reagent("salts1", 5 * mult)
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> eyes dilate!</span>")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> convulses violently and falls to the floor!</span>")
						M.make_jittery(50)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("weakened", 9 SECONDS * mult)
						M.emote("gasp")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> tears at their own skin!</span>")
						random_brute_damage(M, 5 * mult)
						M.reagents.add_reagent("salts1", 5 * mult)
						M.emote("twitch")


		drug/jenkem
			name = "jenkem"
			id = "jenkem"
			description = "Jenkem is a prison drug made from fermenting feces in a solution of urine. Extremely disgusting."
			reagent_state = LIQUID
			fluid_r = 100
			fluid_g = 70
			fluid_b = 0
			transparency = 255
			addiction_prob = 5//30
			addiction_min = 5
			value = 2 // 1 1  :I
			viscosity = 0.4
			bladder_value = -0.03
			hunger_value = -0.04
			hygiene_value = -0.5
			thirst_value = -0.04
			energy_value = -0.04

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.make_dizzy(5 * mult)
				if(prob(10))
					M.emote(pick("twitch","drool","moan"))
					M.take_toxin_damage(1 * mult)
				..()
				return

		drug/crank
			name = "crank" // sort of a shitty version of methamphetamine that can be made by assistants
			id = "crank"
			description = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
			reagent_state = SOLID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 200
			transparency = 40
			addiction_prob = 10//50
			addiction_min = 5
			overdose = 20
			value = 20 // 10 2 1 3 1 heat explosion :v
			energy_value = 1.5
			bladder_value = -0.1
			hunger_value = -0.05
			thirst_value = -0.05
			stun_resist = 60
			threshold = THRESHOLD_INIT

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(15)) M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
				if(prob(8))
					boutput(M, "<span class='notice'><b>You feel great!</b></span>")
					M.reagents.add_reagent("methamphetamine", rand(1,2) * mult)
					M.emote(pick("laugh", "giggle"))
				if(prob(6))
					boutput(M, "<span class='notice'><b>You feel warm.</b></span>")
					M.bodytemperature += rand(1,10) * mult
				if(prob(4))
					boutput(M, "<span class='alert'><b>You feel kinda awful!</b></span>")
					M.take_toxin_damage(1 * mult)
					M.make_jittery(30 * mult)
					M.emote(pick("groan", "moan"))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks confused!</span>")
						M.change_misstep_chance(20 * mult)
						M.make_jittery(20)
						M.emote("scream")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(5,30) * mult
						M.take_brain_damage(1 * mult)
						M.take_toxin_damage(1 * mult)
						M.setStatusMin("stunned", 3 SECONDS * mult)
					else if (effect <= 7)
						M.make_jittery(30)
						M.emote("grumble")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> is sweating like a pig!</span>")
						M.bodytemperature += rand(20,100) * mult
						M.take_toxin_damage(5 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> starts tweaking the hell out!</span>")
						M.make_jittery(100)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(8 * mult)
						M.setStatusMin("weakened", 4 SECONDS * mult)
						M.change_misstep_chance(25 * mult)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 5 * mult)
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message("<span class='alert'><b>[M.name]</b> nervously scratches at their skin!</span>")
						M.make_jittery(10)
						random_brute_damage(M, 5 * mult)
						M.emote("twitch")

		drug/LSD
			name = "lysergic acid diethylamide"
			id = "LSD"
			description = "A highly potent hallucinogenic substance. Far out, maaaan."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 255
			transparency = 20
			value = 6 // 4 2
			thirst_value = -0.03
			var/counter = 1
			var/current_color_pattern = 1
			var/static/list/halluc_sounds = list(
				"punch",
				'sound/vox/poo-vox.ogg',
				new /datum/hallucinated_sound("clownstep", min_count = 1, max_count = 6, delay = 0.4 SECONDS),
				'sound/weapons/armbomb.ogg',
				new /datum/hallucinated_sound('sound/weapons/Gunshot.ogg', min_count = 1, max_count = 3, delay = 0.4 SECONDS),
				new /datum/hallucinated_sound('sound/impact_sounds/Energy_Hit_3.ogg', min_count = 2, max_count = 4, delay = COMBAT_CLICK_DELAY),
				'sound/voice/creepyshriek.ogg',
				new /datum/hallucinated_sound('sound/impact_sounds/Metal_Hit_1.ogg', min_count = 1, max_count = 3, delay = COMBAT_CLICK_DELAY),
				new /datum/hallucinated_sound('sound/machines/airlock_bolt.ogg', min_count = 1, max_count = 3, delay = 0.3 SECONDS),
				'sound/machines/airlock_swoosh_temp.ogg',
				'sound/machines/airlock_deny.ogg',
				'sound/machines/airlock_pry.ogg',
				new /datum/hallucinated_sound('sound/weapons/flash.ogg', min_count = 1, max_count = 3, delay = COMBAT_CLICK_DELAY),
				'sound/musical_instruments/Bikehorn_1.ogg',
				'sound/misc/talk/radio.ogg',
				'sound/misc/talk/radio2.ogg',
				'sound/misc/talk/radio_ai.ogg',
				'sound/weapons/laser_f.ogg',
				'sound/items/security_alert.ogg', //hehehehe
				new /datum/hallucinated_sound('sound/machines/click.ogg', min_count = 1, max_count = 4, delay = 0.4 SECONDS), //silenced pistol sound
				new /datum/hallucinated_sound('sound/effects/glare.ogg', pitch = 0.8), //vamp glare is pitched down for... reasons
				'sound/effects/poff.ogg',
				new /datum/hallucinated_sound('sound/effects/electric_shock_short.ogg', min_count = 3, max_count = 10, delay = 1 SECOND, pitch = 0.8), //arcfiend drain
				'sound/items/hypo.ogg',
				'sound/items/sticker.ogg',
			)
			var/static/list/speech_sounds = list(
				'sound/misc/talk/speak_1.ogg',
				'sound/misc/talk/speak_3.ogg',
				'sound/misc/talk/cow.ogg',
				'sound/misc/talk/roach.ogg',
				'sound/misc/talk/lizard.ogg',
				'sound/misc/talk/skelly.ogg',
			)
			var/static/list/voice_names = list(
				"The voice in your head",
				"Someone right behind you",
				"???",
				"A whisper in the vents",
				"The universe itself",
			)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				src.counter += 1 * mult //around half realtime
				if(M.client && counter >= 6 && prob(20)) //trippy colours
					if(src.current_color_pattern == 1)
						animate_fade_drug_inbetween_1(M.client, 40)
						src.current_color_pattern = 2
					else
						animate_fade_drug_inbetween_2(M.client, 40)
						src.current_color_pattern = 1
				if(probmult(12) && !ON_COOLDOWN(M, "hallucination_spawn", 30 SECONDS)) //spawn a fake critter
					if (prob(20))
						if(prob(60))
							fake_attack(M)
						else
							var/monkeys = rand(1,3)
							for(var/i = 0, i < monkeys, i++)
								fake_attackEx(M, 'icons/mob/monkey.dmi', "monkey_hallucination", pick_string_autokey("names/monkey.txt"))
					else
						var/fake_type = pick(childrentypesof(/obj/fake_attacker))
						new fake_type(M.loc, M)
				//THE VOICES GET LOUDER
				if(probmult(min(16 + src.counter/2, 30))) //play some fake audio
					var/atom/origin = M.loc
					var/turf/mob_turf = get_turf(M)
					if (mob_turf)
						origin = locate(mob_turf.x + rand(-10,10), mob_turf.y + rand(-10,10), mob_turf.z)
					//wacky loosely typed code ahead
					var/datum/hallucinated_sound/chosen = pick(src.halluc_sounds)
					if (istype(chosen)) //it's a datum
						chosen.play(M, origin)
					else //it's just a path directly
						M.playsound_local(origin, chosen, 100, 1)
				if(probmult(8)) //display a random chat message
					M.playsound_local(M.loc, pick(src.speech_sounds, 100, 1))
					boutput(M, "<b>[pick(src.voice_names)]</b> says, \"[phrase_log.random_phrase("say")]\"")
				if(probmult(10)) //turn someone into a critter
					var/list/candidates = list()
					for(var/mob/living/carbon/human/human in viewers(M))
						candidates += human
					var/mob/living/carbon/human/chosen = pick(candidates)
					var/obj/fake_attacker/fake_type = pick(childrentypesof(/obj/fake_attacker))
					var/image/override_img = image(initial(fake_type.fake_icon), chosen, initial(fake_type.fake_icon_state), chosen.layer)
					override_img.override = TRUE
					var/client/client = M.client //hold a reference to the client directly
					client?.images.Add(override_img)
					SPAWN (20 SECONDS)
						client?.images.Remove(override_img)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

			on_mob_life_complete(var/mob/living/M)
				if(M.client)
					if(src.current_color_pattern == 1)
						animate_fade_from_drug_1(M.client, 40)
					else
						animate_fade_from_drug_2(M.client, 40)

			on_remove()
				. = ..()
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom
					if (M.client)
						animate(M.client, color = null, time = 2 SECONDS, easing = SINE_EASING) // gotta come down sometime

		drug/lsd_bee
			name = "lsbee"
			id = "lsd_bee"
			description = "A highly potent hallucinogenic substance. It smells like honey."
			taste = "sweet"
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 235
			fluid_b = 0
			transparency = 100
			value = 5
			thirst_value = -0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 5)
				if (probmult(10))
					var/hstate = null
					var/hname = null
					switch(rand(1,5))
						if(1)
							hstate = "zombee-wings"
							hname = pick("zombee", "undead bee", "BZZZZZZZZ")
						if(2)
							hstate = "syndiebee-wings"
							hname = pick("syndiebee", "evil bee", "syndicate assassin bee", "IT HAS A GUN")
						if(3)
							hstate = "bigbee-angry"
							hname = pick("very angry bee", "extremely angry bee", "GIANT FRICKEN BEE")
						if(4)
							hstate = "lichbee-wings"
							hname = pick("evil bee", "demon bee", "YOU CAN'T BZZZZ FOREVER")
						if(5)
							hstate = "voorbees-wings"
							hname = pick("killer bee", "murder bee", "bad news bee", "RUN")
					fake_attackEx(M, 'icons/misc/bee.dmi', hstate, hname)
				if (probmult(12))
					M.visible_message(pick("<b>[M]</b> makes a buzzing sound.", "<b>[M]</b> buzzes."),pick("BZZZZZZZZZZZZZZZ", "<span class='alert'><b>THE BUZZING GETS LOUDER</b></span>", "<span class='alert'><b>THE BUZZING WON'T STOP</b></span>"))
				if (probmult(15))
					switch(rand(1,2))
						if(1)
							M.emote("twitch")
						if(2)
							M.emote("scream")
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, "Your ears start buzzing.")

		drug/space_drugs
			name = "space drugs"
			id = "space_drugs"
			description = "An illegal chemical compound used as a cheap drug."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 185
			fluid_b = 230
			addiction_prob = 15//65
			addiction_min = 10
			depletion_rate = 0.2
			value = 3 // 1c + 1c + 1c
			viscosity = 0.2
			thirst_value = -0.03
			minimum_reaction_temperature = T0C+400

			reaction_temperature(exposed_temperature, exposed_volume)
				var/myvol = volume
				holder.del_reagent(id)
				holder.add_reagent("neurotoxin", myvol, null)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				// if(M.canmove && isturf(M.loc))
				// 	step(M, pick(cardinal))
				if (M.canmove && prob(40))
					M.change_misstep_chance(5 * mult)

				if(probmult(7)) M.emote(pick("twitch","drool","moan","giggle"))
				..()
				return

		drug/THC
			name = "tetrahydrocannabinol"
			id = "THC"
			description = "A mild psychoactive chemical extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = -0.04

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.stuttering += rand(0,2)
				if(M.client && probmult(5))
					for (var/obj/critter/domestic_bee/bee in view(7,M))
						var/chat_text = null
						var/text = pick_smart_string("shit_bees_say_when_youre_high.txt", "strings", list(
							"M"="[M]",
							"beeMom"=bee.beeMom ? bee.beeMom : "Mom",
							"other_bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Spacebee" : "Seabee",
							"bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Seabee" : "Spacebee"
							))
						if(!M.client.preferences.flying_chat_hidden)
							var/speechpopupstyle = "font-family: 'Comic Sans MS'; font-size: 8px;"
							chat_text = make_chat_maptext(bee, text, "color: [rgb(194,190,190)];" + speechpopupstyle, alpha = 140)
						M.show_message("[bee] buzzes \"[text]\"",2, assoc_maptext = chat_text)
						break

				if(probmult(5))
					M.emote(pick("laugh","giggle","smile"))
				if(probmult(5))
					boutput(M, "[pick("You feel hungry.","Your stomach rumbles.","You feel cold.","You feel warm.")]")
				if(prob(4))
					M.change_misstep_chance(10 * mult)
				if (holder.get_reagent_amount(src.id) >= 50 && probmult(25))
					if(prob(10))
						M.setStatus("drowsy", 20 SECONDS)
				..()
				return

		drug/CBD
			name = "cannabidiol"
			id = "CBD"
			description = "A non-psychoactive phytocannabinoid extracted from the cannabis plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 225
			fluid_b = 0
			transparency = 200
			value = 3
			viscosity = 0.4
			hunger_value = -0.04
			thirst_value = 0.03

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(5))
					M.emote(pick("sigh","yawn","hiccup","cough"))
				if(probmult(5))
					boutput(M, "[pick("You feel peaceful.","You breathe softly.","You feel chill.","You vibe.")]")
				if(probmult(10))
					M.change_misstep_chance(-5)
					M.delStatus("weakened")
				if (holder.get_reagent_amount(src.id) >= 70 && probmult(25))
					if (holder.get_reagent_amount("THC") <= 20)
						M.setStatus("drowsy", 20 SECONDS)
				if(prob(25))
					M.HealDamage("All", 2 * mult, 0)
				..()
				return

		drug/nicotine
			name = "nicotine"
			id = "nicotine"
			description = "A highly addictive stimulant extracted from the tobacco plant."
			reagent_state = LIQUID
			fluid_r = 0
			fluid_g = 0
			fluid_b = 0
			viscosity = 0.2
			transparency = 190
			addiction_prob = 15//70
			addiction_min = 10
			max_addiction_severity = "LOW"
			overdose = 35 // raise if too low - trying to aim for one sleepypen load being problematic, two being deadlyish
			//var/counter = 1
			//note that nicotine is also horribly poisonous in concentrated form IRM - could be used as a poor-man's toxin?
			//just comment that out if you don't think it's any good.
			// Gonna try this out. Not good for you but won't horribly maim you from taking a quick puff of a cigarette - ISN
			value = 3
			thirst_value = -0.07
			stun_resist = 8
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_nicotine", 1)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_nicotine")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(probmult(50))
					M.make_jittery(5)
				..()

			//cogwerks - improved nicotine poisoning?
			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				M.take_toxin_damage(1 * mult)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks nervous!</span>")
						M.change_misstep_chance(15 * mult)
						M.take_toxin_damage(2 * mult)
						M.make_jittery(10)
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is all sweaty!</span>")
						M.bodytemperature += rand(15,30) * mult
						M.take_toxin_damage(3 * mult)
					else if (effect <= 7)
						M.take_toxin_damage(4 * mult)
						M.emote("twitch_v")
						M.make_jittery(10)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You can't breathe!</b></span>")
						M.take_oxygen_deprivation(15 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatusMin("stunned", 1 SECOND * mult)
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel terrible!</b></span>")
						M.emote("drool")
						M.make_jittery(10)
						M.take_toxin_damage(5 * mult)
						M.setStatusMin("weakened", 1 SECOND * mult)
						M.change_misstep_chance(33 * mult)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.setStatusMin("paralysis", 5 SECONDS * mult)
						M.make_jittery(30)
						M.take_toxin_damage(6 * mult)
						M.take_oxygen_deprivation(20 * mult)

		drug/nicotine/nicotine2
			name = "nicotwaine"
			id = "nicotine2"
			description = "A highly addictive stimulant derived from the twobacco plant."
			addiction_prob = 100
			overdose = 70
			stun_resist = 11
			threshold = THRESHOLD_INIT

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_nicotine2", 3)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_nicotine2")
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if (H.sims)
						H.sims.affectMotive("fun", 2)
				if(probmult(75))
					M.make_jittery(10)
				if(probmult(25))
					M.emote(pick("drool","shudder","groan","moan","shiver"))
					boutput(M, "<span class='success'><b>You feel... pretty good... and calm... weird.</b></span>")
				if(probmult(10))
					M.make_jittery(20)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>You can feel your heartbeat in your throat!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(2)
				if(probmult(5))
					M.delStatus("paralysis")
					M.delStatus("stunned")
					M.delStatus("weakened")
					M.delStatus("paralysis")
					M.sleeping = 0
					M.make_jittery(30)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, "<span class='alert'><b>Your heart's beating really really fast!</b></span>")
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(4)
				..(M)

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				..()
				..()
				/*var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks really nervous!</span>")
						boutput(M, "<span class='alert'><b>You feel really nervous!</b></span>")
						M.change_misstep_chance(30)
						M.take_toxin_damage(3)
						M.make_jittery(20)
						M.emote("twitch")
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> is super sweaty!</span>")
						boutput(M, "<span class='alert'><b>You feel hot! Is it hot in here?!</b></span>")
						M.bodytemperature += rand(30,60)
						M.take_toxin_damage(4)
					else if (effect <= 7)
						M.take_toxin_damage(5)
						M.emote("twitch_v")
						M.emote("twitch_v")
						M.make_jittery(20)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						M.emote("gasp")
						boutput(M, "<span class='alert'><b>You really can't breathe!</b></span>")
						M.take_oxygen_deprivation(15)
						M.take_toxin_damage(4)
						M.changeStatus("stunned", 10 * mult)
					else if (effect <= 4)
						boutput(M, "<span class='alert'><b>You feel really terrible!</b></span>")
						M.emote("drool")
						M.emote("drool")
						M.make_jittery(20)
						M.take_toxin_damage(5)
						M.changeStatus("weakened", 10 * mult)
						M.change_misstep_chance(66)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, "<span class='alert'><b>Your heart is pounding! You need help!</b></span>")
						M << sound('sound/effects/heartbeat.ogg')
						M.changeStatus("weakened", 50 * mult)
						M.make_jittery(60)
						M.take_toxin_damage(5)
						M.take_oxygen_deprivation(20)*/

		drug/psilocybin
			name = "psilocybin"
			id = "psilocybin"
			description = "A powerful hallucinogenic chemical produced by certain mushrooms."
			reagent_state = LIQUID
			fluid_r = 255
			fluid_g = 230
			fluid_b = 200
			transparency = 200
			value = 3
			viscosity = 0.1
			thirst_value = -0.3

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(8))
					boutput(M, "<b>You hear a voice in your head... <i>[phrase_log.random_phrase("say")]</i></b>")
				if(probmult(8))
					M.emote(pick("scream","cry","laugh","moan","shiver"))
				if(probmult(3))
					switch (rand(1,3))
						if(1)
							boutput(M, "<B>The Emergency Shuttle has docked with the station! You have 3 minutes to board the Emergency Shuttle.</B>")
						if(2)
							boutput(M, "<span class='alert'><b>Restarting world!</b> </span><span class='notice'>Initiated by Administrator!</span>")
							SPAWN(2 SECONDS) M.playsound_local(M.loc, pick('sound/misc/NewRound.ogg', 'sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'), 50, 1)
						if(3)
							switch (rand(1,4))
								if(1)
									boutput(M, "<span class='alert'><b>Unknown fires the revolver at [M]!</b></span>")
									M.playsound_local(M.loc, 'sound/weapons/Gunshot.ogg', 50, 1)
								if(2)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the fire extinguisher by Unknown</b></span>")
									M.playsound_local(M.loc, 'sound/impact_sounds/Metal_Hit_1.ogg', 50, 1)
								if(3)
									boutput(M, "<span class='alert'><b>Unknown has punched [M]</b></span>")
									boutput(M, "<span class='alert'><b>Unknown has weakened [M]</b></span>")
									M.setStatusMin("weakened", 1 SECOND * mult)
									M.playsound_local(M.loc, pick(sounds_punch), 50, 1)
								if(4)
									boutput(M, "<span class='alert'><b>[M] has been attacked with the taser gun by Unknown</b></span>")
									boutput(M, "<i>You can almost hear someone talking...</i>")
									M.setStatusMin("paralysis", 3 SECONDS * mult)
				..()


		drug/krokodil
			name = "krokodil"
			id = "krokodil"
			description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
			reagent_state = SOLID
			fluid_r = 0
			fluid_g = 100
			fluid_b = 180
			transparency = 250
			addiction_prob = 10//50
			addiction_min = 10
			overdose = 20
			hunger_value = -0.1
			thirst_value = -0.09

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.jitteriness -= 40
				if(prob(25)) M.take_brain_damage(1 * mult)
				if(probmult(15)) M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
				if(prob(10))
					boutput(M, "<span class='notice'><b>You feel pretty chill.</b></span>")
					M.bodytemperature -= 1 * mult
					M.emote("smile")
				if(prob(5))
					boutput(M, "<span class='alert'><b>You feel too chill!</b></span>")
					M.emote(pick("yawn", "drool"))
					M.setStatusMin("stunned", 2 SECONDS * mult)
					M.take_toxin_damage(1 * mult)
					M.take_brain_damage(1 * mult)
					M.bodytemperature -= 20 * mult
				if(prob(2))
					boutput(M, "<span class='alert'><b>Your skin feels all rough and dry.</b></span>")
					random_brute_damage(M, 2 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> looks dazed!</span>")
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.emote("drool")
					else if (effect <= 4)
						M.emote("shiver")
						M.bodytemperature -= 40 * mult
					else if (effect <= 7)
						boutput(M, "<span class='alert'><b>Your skin is cracking and bleeding!</b></span>")
						random_brute_damage(M, 5 * mult)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.emote("cry")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> sways and falls over!</span>")
						M.take_toxin_damage(3 * mult)
						M.take_brain_damage(3 * mult)
						M.setStatusMin("weakened", 9 SECONDS * mult)
						M.emote("faint")
					else if (effect <= 4)
						if(ishuman(M))
							M.visible_message("<span class='alert'><b>[M.name]'s</b> skin is rotting away!</span>")
							random_brute_damage(M, 25 * mult)
							M.emote("scream")
							M.bioHolder.AddEffect("eaten") //grody. changed line in human.dm to use decomp1 now
							M.emote("faint")
					else if (effect <= 7)
						M.emote("shiver")
						M.bodytemperature -= 70 * mult

		drug/catdrugs
			name = "cat drugs"
			id = "catdrugs"
			description = "Uhhh..."
			reagent_state = LIQUID
			fluid_r = 200
			fluid_g = 200
			fluid_b = 0
			transparency = 20
			viscosity = 0.14
			thirst_value = -0.1

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(11))
					M.visible_message("<span class='notice'><b>[M.name]</b> hisses!</span>")
					playsound(M.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
				if(probmult(9))
					M.visible_message("<span class='notice'><b>[M.name]</b> meows! What the fuck?</span>")
					playsound(M.loc, 'sound/voice/animal/cat.ogg', 50, 1)
				if(probmult(7))
					switch(rand(1,2))
						if(1)
							var/ghostcats = rand(1,3)
							for(var/i = 0, i < ghostcats, i++)
								fake_attackEx(M, 'icons/misc/critter.dmi', "cat-ghost", "ghost cat")
								M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
						if(2)
							var/wildcats = rand(1,3)
							for(var/i = 0, i < wildcats, i++)
								fake_attackEx(M, 'icons/misc/critter.dmi', "cat1-wild", "wild cat")
								M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
				if(probmult(20))
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
					boutput(M, "<span class='alert'><font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font></span>")
				return

		drug/triplemeth
			name = "triple meth"
			id = "triplemeth"
			description = "Hot damn ... i don't even ..."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 100
			addiction_min = 0
			overdose = 20
			depletion_rate = 0.2
			value = 39 // 13c * 3  :v
			energy_value = 3
			bladder_value = -0.1
			hunger_value = -0.3
			thirst_value = -0.2
			var/list/flushed_reagents = list("mannitol","synaptizine")

			on_remove()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "triplemeth")
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "triplemeth")
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "triplemeth")

				if(hascall(holder.my_atom,"removeOverlayComposition"))
					holder.my_atom:removeOverlayComposition(/datum/overlayComposition/triplemeth)
				..()


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom

				if(holder.has_reagent("methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "triplemeth", 98)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "triplemeth", 98)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "triplemeth", 1000)

				if(hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/triplemeth)
				flush(M, 5 * mult, flushed_reagents)
				if(probmult(50)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.make_dizzy(5 * mult)
				M.change_misstep_chance(15 * mult)
				M.take_brain_damage(1 * mult)
				M.delStatus("disorient")
				if(M.sleeping) M.sleeping = 0
				..()
				return

			do_overdose(var/severity, var/mob/overdoser, var/mult = 1)
				var/effect = ..(severity, overdoser)
				var/mob/living/M = overdoser
				if(!istype(M))
					return
				if(holder.has_reagent("methamphetamine"))
					return //Since is created by a meth overdose, dont react while meth is in their system.
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> can't seem to control their legs!</span>")
						M.change_misstep_chance(12 * mult)
						M.setStatusMin("weakened", 5 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.empty_hands()
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.empty_hands()
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
						M.make_jittery(10)
						M.setStatusMin("weakened", 10 SECONDS * mult)
					else if (effect <= 7)
						M.emote("laugh")

		drug/methamphetamine // // COGWERKS CHEM REVISION PROJECT. marked for revision
			name = "methamphetamine"
			id = "methamphetamine"
			description = "Methamphetamine is a highly effective and dangerous stimulant drug."
			reagent_state = SOLID
			fluid_r = 250
			fluid_g = 250
			fluid_b = 250
			transparency = 220
			addiction_prob = 10//60
			addiction_min = 5
			overdose = 20
			depletion_rate = 0.6
			value = 13 // 9c + 1c + 1c + 1c + heat
			energy_value = 1.5
			bladder_value = -0.09
			hunger_value = -0.09
			thirst_value = -0.09
			stun_resist = 50
			threshold = THRESHOLD_INIT
			var/list/flushed_reagents = list("mannitol","synaptizine")
			var/purge_brain = TRUE

			on_add()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "triplemeth")
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "triplemeth")
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "triplemeth")

				..()

			on_remove()
				if(ismob(holder?.my_atom))
					holder.del_reagent("triplemeth")
				..()

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_methamphetamine", 3)
					APPLY_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "r_methamphetamine")
					REMOVE_MOVEMENT_MODIFIER(M, /datum/movement_modifier/reagent/energydrink, src.type)
				..()

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				if(probmult(5)) M.emote(pick("twitch","blink_r","shiver"))
				M.make_jittery(5)
				M.changeStatus("drowsy", -20 SECONDS)
				if(M.sleeping) M.sleeping = 0
				if(prob(50))
					M.take_brain_damage(1 * mult)
				if(purge_brain)
					flush(M, 5 * mult, flushed_reagents)
				..()
				return

			do_overdose(var/severity, var/mob/overdoser, var/mult = 1)
				var/effect = ..(severity, overdoser)
				var/mob/living/M = overdoser
				if(!istype(M))
					return
				if (severity == 1)
					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]</b> can't seem to control their legs!</span>")
						M.change_misstep_chance(20 * mult)
						M.setStatusMin("weakened", 5 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.empty_hands()
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)

					if(!holder.has_reagent("triplemeth", 10 * mult))
						holder.add_reagent("triplemeth", 10 * mult, null)
						M.add_karma(10)

					if (effect <= 2)
						M.visible_message("<span class='alert'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
						M.empty_hands()
					else if (effect <= 4)
						M.visible_message("<span class='alert'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
						M.make_jittery(10)
						M.setStatusMin("weakened", 2 SECONDS * mult)
					else if (effect <= 7)
						M.emote("laugh")

			syndicate
				name = "methamphetamine"
				id = "synd_methamphetamine"
				description = "Methamphetamine is a highly effective and dangerous stimulant drug. This batch seems unusally high-grade and pure."
				purge_brain = FALSE
				fluid_r = 115 // This shit's pure and blue
				fluid_g = 197
				fluid_b = 250

		drug/hellshroom_extract
			name = "Hellshroom extract"
			id = "hellshroom_extract"
			description = "TEMP"
			reagent_state = SOLID
			fluid_r = 163
			fluid_g = 17
			fluid_b = 63
			transparency = 100
			depletion_rate = 0.3

			on_mob_life(var/mob/M, var/mult = 1) // commence bad times
				if(!M) M = holder.my_atom
				if(ishuman(M))
					var/mob/living/carbon/human/K = M
					if (K.sims)
						K.sims.affectMotive("Energy", 2)
						K.sims.affectMotive("fun", 1)
						K.sims.affectMotive("Bladder", -0.5)
						K.sims.affectMotive("Hunger", -1)
						K.sims.affectMotive("Thirst", -2)
				var/mob/living/H = M
				var/check = rand(0,100)
				if (istype(H))
					if (M.reagents.has_reagent("milk"))
						boutput(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
						M.reagents.del_reagent("milk")
						M.reagents.del_reagent("hellshroom_extract")
					if (check < 20)
						src.breathefire(M)
					if(check < 5)
						var/bats = rand(2,3)
						for(var/i = 0, i < bats, i++)
						fake_attackEx(M, 'icons/misc/AzungarAdventure.dmi', "hellbat", "hellbat")
						boutput(M, "<span class='alert'><b>A hellbat begins to chase you</b>!</span>")
						M.emote("scream")
					if(check < 20)
						boutput(M, "<span class='alert'><b>Oh god! Oh GODD!!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'><b>You feel like you are melting from the inside!</b></span>")
					if(check < 20)
						boutput(M, "<span class='alert'>Your throat feels like it's on fire!</span>")
						M.emote(pick("scream","cry","twitch_s","choke","gasp","grumble"))
						M.changeStatus("paralysis", 2 SECONDS)
					if(check < 20)
						boutput(M, "<span class='notice'><b>You feel A LOT warmer.</b></span>")
						M.bodytemperature += rand(30,60)
				..()
				return

datum/reagent/drug/hellshroom_extract/proc/breathefire(var/mob/M)
	var/temp = 3000
	var/range = 1

	var/turf/T = get_step(M,M.dir)
	T = get_step(T,M.dir)
	var/list/affected_turfs = getline(M, T)

	M.visible_message("<span class='alert'><b>[M] burps a stream of fire!</b></span>")
	playsound(M.loc, 'sound/effects/mag_fireballlaunch.ogg', 30, 0)

	var/turf/currentturf
	var/turf/previousturf
	for(var/turf/F in affected_turfs)
		previousturf = currentturf
		currentturf = F
		if(currentturf.density || istype(currentturf, /turf/space))
			break
		if(previousturf && LinkBlocked(previousturf, currentturf))
			break
		if (F == get_turf(M))
			continue
		if (GET_DIST(M,F) > range)
			continue
		tfireflash(F,1,temp)
