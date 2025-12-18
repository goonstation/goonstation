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
			addiction_prob = 15
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
					if (check < 8 && H.bioHolder.mobAppearance.customizations["hair_middle"].style.id != "tramp") // M.is_hobo = very yes
						H.bioHolder.mobAppearance.customizations["hair_middle"].style =  new /datum/customization_style/beard/tramp
						H.set_face_icon_dirty()
						boutput(M, SPAN_ALERT("<b>You feel gruff!</b>"))
						SPAWN(0.3 SECONDS)
							M.visible_message(SPAN_ALERT("<b>[M.name]</b> has a wild look in [his_or_her(M)] eyes!"))
					if(check < 60)
						H.remove_stuns()
					if(check < 30)
						H.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))

				M.druggy = max(M.druggy, 15)
				if(check < 20)
					M.change_misstep_chance(10 * mult)
				// a really shitty form of traitor stimulants - you'll be tough to take down but nearly uncontrollable anyways and you won't heal the way stims do


				if(check < 8)
					M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), randfloat(1.7 , 8.4) * src.calculate_depletion_rate(M, mult))
					M.visible_message(SPAN_ALERT("<b>[M.name]</b> scratches at something under [his_or_her(M)] [issilicon(M) ? "chassis" : "skin"]!"))
					random_brute_damage(M, 5 * mult)
				else if (check < 16)
					switch(rand(1,2))
						if(1)
							if(prob(20))
								fake_attackEx(M, 'icons/misc/critter.dmi', "death", "death")
								boutput(M, SPAN_ALERT("<b>OH GOD LOOK OUT!!!</b>!"))
								M.emote("scream")
								M.playsound_local(M.loc, 'sound/musical_instruments/Bell_Huge_1.ogg', 50, 1)
							else if(prob(50))
								fake_attackEx(M, 'icons/misc/critter.dmi', "mimicface", "smiling thing")
								boutput(M, SPAN_ALERT("<b>The smiling thing</b> laughs!"))
								M.playsound_local(M.loc, pick('sound/voice/cluwnelaugh1.ogg', 'sound/voice/cluwnelaugh2.ogg', 'sound/voice/cluwnelaugh3.ogg'), 35, 1)
							else
								M.playsound_local(M.loc, pick('sound/machines/ArtifactEld1.ogg', 'sound/machines/ArtifactEld2.ogg'), 50, 1)
								boutput(M, SPAN_ALERT("<b>You hear something strange behind you...</b>"))
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
					boutput(M, SPAN_ALERT("<b>They're coming for you!</b>"))
				else if(check < 28)
					boutput(M, SPAN_ALERT("<b>THEY'RE GONNA GET YOU!</b>"))
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, SPAN_ALERT("<font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font>"))
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.emote("faint")
					//var/mob/living/carbon/human/H = M
					//if (istype(H))
					M.take_radiation_dose(0.001 SIEVERTS * volume, internal=TRUE)
					M.take_toxin_damage(5)
					M.take_brain_damage(10)
				else
					boutput(M, SPAN_NOTICE("You feel a bit more salty than usual."))
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> flails around like a lunatic!"))
						M.change_misstep_chance(25 * mult)
						M.make_jittery(10)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> eyes dilate!"))
						M.emote("twitch_s")
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
					else if (effect <= 7)
						M.emote("faint")
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> eyes dilate!"))
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.change_eye_blurry(7, 7)
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> convulses violently and falls to the floor!"))
						M.make_jittery(50)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.setStatusMin("knockdown", 9 SECONDS * mult)
						M.emote("gasp")
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> tears at [his_or_her(M)] own skin!"))
						random_brute_damage(M, 5 * mult)
						M.reagents.add_reagent("salts1", 8.4 * src.calculate_depletion_rate(M, mult))
						M.emote("twitch")

		drug/crank
			name = "crank" // sort of a shitty version of methamphetamine that can be made by assistants
			id = "crank"
			description = "A cheap and dirty stimulant drug, commonly used by space biker gangs."
			reagent_state = SOLID
			fluid_r = 250
			fluid_b = 0
			fluid_g = 200
			transparency = 40
			addiction_prob = 10
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
					boutput(M, SPAN_NOTICE("<b>You feel great!</b>"))
					M.reagents.add_reagent("methamphetamine", randfloat(2.5 , 5) * src.calculate_depletion_rate(M, mult))
					M.emote(pick("laugh", "giggle"))
				if(prob(6))
					boutput(M, SPAN_NOTICE("<b>You feel warm.</b>"))
					M.changeBodyTemp(rand(1,10) KELVIN * mult)
				if(prob(4))
					boutput(M, SPAN_ALERT("<b>You feel kinda awful!</b>"))
					M.take_toxin_damage(1 * mult)
					M.make_jittery(30 * mult)
					M.emote(pick("groan", "moan"))
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> looks confused!"))
						M.change_misstep_chance(20 * mult)
						M.make_jittery(20)
						M.emote("scream")
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> is all sweaty!"))
						M.changeBodyTemp(rand(5,30) KELVIN * mult)
						M.take_brain_damage(1 * mult)
						M.take_toxin_damage(1 * mult)
						M.setStatusMin("stunned", 3 SECONDS * mult)
					else if (effect <= 7)
						M.make_jittery(30)
						M.emote("grumble")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> is sweating like a pig!"))
						M.changeBodyTemp(rand(20,100) KELVIN * mult)
						M.take_toxin_damage(5 * mult)
						M.setStatusMin("stunned", 4 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> starts tweaking the hell out!"))
						M.make_jittery(100)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(8 * mult)
						M.setStatusMin("knockdown", 4 SECONDS * mult)
						M.change_misstep_chance(25 * mult)
						M.emote("scream")
						M.reagents.add_reagent("salts1", 12.5 * src.calculate_depletion_rate(M, mult))
					else if (effect <= 7)
						M.emote("scream")
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> nervously scratches at [his_or_her(M)] skin!"))
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
			var/time_in_bloodstream = 0
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
			var/static/list/monkey_images = list(
				new /image('icons/mob/monkey.dmi', "monkey"),
				new /image('icons/mob/monkey.dmi', "fire3"),
				new /image('icons/mob/monkey.dmi', "skeleton"),
				new /image('icons/mob/monkey.dmi', "seamonkey"),
			)
			var/static/list/critter_image_list = list(
				new /image('icons/effects/hallucinations.dmi', "spider"),
				new /image('icons/effects/hallucinations.dmi', "dragon"),
				new /image('icons/effects/hallucinations.dmi', "pig"),
				new /image('icons/effects/hallucinations.dmi', "slime"),
				new /image('icons/effects/hallucinations.dmi', "shambler"),
				new /image('icons/misc/critter.dmi', "martianW"),
			)
			var/static/list/monkey_names = strings("names/monkey.txt")

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				//pretty colors
				src.time_in_bloodstream += mult
				if (src.time_in_bloodstream > 15)
					M.AddComponent(/datum/component/hallucination/trippy_colors, timeout=10)

			//get attacked
				if(prob(60)) //monkey mode
					M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=monkey_images, name_list=monkey_names, attacker_prob=4, max_attackers=1)
				else
					M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=null, name_list=null, attacker_prob=4, max_attackers=1)

				//THE VOICES GET LOUDER
				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.halluc_sounds, sound_prob=5)

				if(src.time_in_bloodstream > 10 && probmult(8)) //display a random chat message
					M.playsound_local(M.loc, pick(src.speech_sounds, 100, 1))
					boutput(M, "<b>[pick(src.voice_names)]</b> says, \"[phrase_log.random_phrase("say")]\"")

				//turn someone into a critter
				M.AddComponent(/datum/component/hallucination/random_image_override, timeout=10, image_list=critter_image_list, target_list=list(/mob/living/carbon/human), range=6, image_prob=10, image_time=20, override=TRUE)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					boutput(M, SPAN_ALERT("<font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font>"))
				return

			on_remove()
				. = ..()
				if (ismob(holder.my_atom))
					src.time_in_bloodstream = 0 //ehhhh
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
			var/static/list/bee_halluc = list(
				new /image('icons/misc/bee.dmi',"zombee-wings") = list("zombee", "undead bee", "BZZZZZZZZ"),
				new /image('icons/misc/bee.dmi',"syndiebee-wings") = list("syndiebee", "evil bee", "syndicate assassin bee", "IT HAS A GUN"),
				new /image('icons/misc/bee.dmi',"bigbee-angry") = list("very angry bee", "extremely angry bee", "GIANT FRICKEN BEE"),
				new /image('icons/misc/bee.dmi',"lichbee-wings") = list("evil bee", "demon bee", "YOU CAN'T BZZZZ FOREVER"),
				new /image('icons/misc/bee.dmi',"voorbees-wings") = list("killer bee", "murder bee", "bad news bee", "RUN"),
			)

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 5)
				var/image/imagekey = pick(bee_halluc)
				M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(imagekey), name_list=bee_halluc[imagekey], attacker_prob=7, max_attackers = 1)
				if (probmult(12))
					M.visible_message(pick("<b>[M]</b> makes a buzzing sound.", "<b>[M]</b> buzzes."),pick("BZZZZZZZZZZZZZZZ", SPAN_ALERT("<b>THE BUZZING GETS LOUDER</b>"), SPAN_ALERT("<b>THE BUZZING WON'T STOP</b>")))
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
			addiction_prob = 15
			addiction_min = 25
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

		drug/caffeine        //Unified chem for lots of caffeinated drinks, similar to how ethanol functions
			name = "caffeine"
			id = "caffeine"
			description = "An addictive stimulant contained in coffee beans and many caffeinated beverages."
			reagent_state = LIQUID
			fluid_r = 230
			fluid_g = 220
			fluid_b = 230
			addiction_prob = 1 //Less addictive than ethanol due to its higher depletion rate
			addiction_min = 50
			addiction_severity = LOW_ADDICTION_SEVERITY
			stun_resist = 3
			depletion_rate = 0.05
			taste = "bitter"
			overdose = 60
			threshold = THRESHOLD_INIT
			var/stamina_regen = 1
			var/expected_stamina_regen = 1
			var/expected_stun_resist = 3
			var/heart_failure_counter = 0

			proc/caffeine_stamina_change(stun_resist, stamina_regen)
				var/mob/M = holder.my_atom // All of the caffeine regen properties in a single place
				if (M.reagents.get_reagent_amount(src.id) <= threshold)
					return // Shouldn't add any stun resist to a chem that isn't there
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "reagent_[src.id]", stun_resist)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "reagent_[src.id]", stun_resist)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "caffeine_rush", stamina_regen)
				return

			cross_threshold_over()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "caffeine_rush", stamina_regen)
				..()

			cross_threshold_under()
				if(ismob(holder?.my_atom))
					var/mob/M = holder.my_atom
					REMOVE_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "caffeine_rush")
				..()

			calculate_depletion_rate(var/mob/affected_mob, var/mult = 1)
				. = ..()
				var/caffeine_amt = holder.get_reagent_amount(src.id)
				switch(caffeine_amt) //use ~midpoints for depeletion rate thresholds - need stronger coffees or blends to overcaffeinate
					if(3 to 10)
						. *= 2
					if(10 to 30)
						. *= 4
					if(30 to 50)
						. *= 8
					if(50 to INFINITY)
						. *= 10
				return .


			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				var/caffeine_amt = holder.get_reagent_amount(src.id)

				if (heart_failure_counter > 150 && ishuman(M)) // This has to get pretty high for bad things to happen
					var/mob/living/L = M
					L.contract_disease(/datum/ailment/malady/heartfailure, null, null, 1)
					heart_failure_counter = 0

				switch(caffeine_amt)
					if(0 to 5)   //This is a trace amount of caffeine, doesn't do much
						expected_stamina_regen = 1
						expected_stun_resist   = 3

					if(5 to 20)  //A regular coffee mug's worth
						if (M.get_eye_blurry() && prob(75))
							M.change_eye_blurry(-1 * mult)
						expected_stamina_regen = 2
						expected_stun_resist   = 7
						M.dizziness = max(0, M.dizziness-3)
						M.changeStatus("drowsy", -2 * mult SECONDS) //Helps combat that morning fatigue
						if (prob(25))
							M.make_jittery(10 * mult)

					if(20 to 40) //A significant amount of caffeine
						if (M.get_eye_blurry())
							M.change_eye_blurry(-1 * mult)
						expected_stamina_regen = 4
						expected_stun_resist   = 12
						M.changeStatus("drowsy", -4 * mult SECONDS)
						M.dizziness = max(0, M.dizziness-5)
						M.sleeping = 0 //Causes insomnia
						if (prob(35))
							M.make_jittery(10 * mult)
						if (probmult(3) && !ON_COOLDOWN(M, "Caffeine Message", 30 SECONDS)) // Limits emote spam
							boutput(M, pick(SPAN_NOTICE("You feel a slight twitch in your arm."),\
									SPAN_NOTICE("Your shoulders are unusually tense."),\
									SPAN_NOTICE("You feel kind of antsy, for some reason."),\
									SPAN_ALERT("You feel ready for anything!"),\
									SPAN_ALERT("You feel energized!"),\
									SPAN_ALERT("You've got a bit of a headache...")))

					if(40 to 60) //An unhealthy amount of caffeine
						if (M.get_eye_blurry())
							M.change_eye_blurry(-2 * mult)
						expected_stamina_regen = 6
						expected_stun_resist   = 20
						M.changeStatus("drowsy", -10 * mult SECONDS)
						M.dizziness = max(0, M.dizziness-7)
						M.make_jittery(10 * mult)
						M.change_misstep_chance(1 * mult)
						M.sleeping = 0
						if (probmult(3) && !ON_COOLDOWN(M, "Caffeine Message", 30 SECONDS)) // Limits emote spam
							boutput(M, pick(SPAN_NOTICE("The muscles in your arms are twitching a lot. Huh."),\
									SPAN_NOTICE("Your whole body feels really tense right now."),\
									SPAN_NOTICE("You feel very restless - something isn't right."),\
									SPAN_ALERT("You feel ready for anything! Nothing can stop you!"),\
									SPAN_ALERT("You can feel power coursing through your veins!"),\
									SPAN_ALERT("Your head is pounding...")))
						else if (probmult(9))
							M.emote(pick("twitch","twitch_v","blink_r", "shiver"))
						heart_failure_counter += mult //This will be bad for you, given enough time

					if(60 to INFINITY)  //Way too much coffee - very bad for you. This is actually non-trivial to reach now
						if (M.get_eye_blurry())
							M.change_eye_blurry(-3 * mult)
						expected_stamina_regen = 8
						expected_stun_resist   = 25
						M.change_misstep_chance(4 * mult)
						M.changeStatus("drowsy", -15 SECONDS)
						M.dizziness = max(0,M.dizziness-10)
						M.make_jittery(15 * mult)
						M.sleeping = 0
						if (probmult(3) && !ON_COOLDOWN(M, "Caffeine Message", 30 SECONDS))
							boutput(M, pick(SPAN_ALERT("Oh god, your chest just spasmed! That felt bad!"),\
									SPAN_ALERT("YOU ARE ENERGY INCARNATE."),\
									SPAN_ALERT("YOU FEEL LIKE YOU COULD CONQUER THE WORLD!"),\
									SPAN_ALERT("YOU CAN DO ANYTHING. YOU ARE READY FOR ANY CHALLENGE."),\
									SPAN_ALERT("There's a burning sensation in your chest!"),\
									SPAN_ALERT("Your head feels like it's throbbing!"),\
									SPAN_ALERT("Speed. You are speed."),\
									SPAN_NOTICE("Something is wrong.")))
						else if (probmult(12))
							M.emote(pick("shiver","twitch_v","blink_r","wheeze"))
						else if(probmult(9) && !ON_COOLDOWN(M, "feeling_own heartbeat", 60 SECONDS)) //This can't be good for you
							M.playsound_local(get_turf(M), 'sound/effects/HeartBeatLong.ogg', 20, 1)
							M.take_toxin_damage(5)
						heart_failure_counter += 5 * mult // This can be really bad for you

				if (stun_resist != expected_stun_resist || stamina_regen != expected_stamina_regen)
					stun_resist = expected_stun_resist
					stamina_regen = expected_stamina_regen
					caffeine_stamina_change(stun_resist, stamina_regen)

				..()
				return

		drug/solipsizine
			name = "solipsizine"
			id = "solipsizine"
			description = "A highly potent hallucinogenic substance that causes intense delirium and acute inability to perceive others."
			reagent_state = LIQUID
			depletion_rate = 0.2
			addiction_prob = 8
			fluid_r = 200
			fluid_g = 120
			fluid_b = 120
			transparency = 50
			var/counter = 1
			var/list/invisible_people
			var/list/mob/not_yet_invisible
			var/datum/client_image_group/invisible_group
			var/tick_counter = 0 // we actually count ticks, no mult here

			on_mob_life(var/mob/M, var/mult = 1)
				if(isnull(invisible_people))
					invisible_people = list()
				if(!M) M = holder.my_atom
				src.counter += 1 * mult //around half realtime
				src.tick_counter += 1

				if(probmult(3))
					boutput(M, pick(SPAN_NOTICE("You feel eerily alone..."),\
									SPAN_NOTICE("You feel like everything's gone silent."),\
									SPAN_NOTICE("Everything seems so quiet all of a sudden."),\
									SPAN_NOTICE("You can hear your heart beating."),\
									SPAN_NOTICE("Something is wrong.")))
				else if(probmult(3))
					M.emote(pick("shiver","shudder","drool"))

				if(counter > 15) //turn everyone into nothing
					if(M.ear_damage < 15 && M.ear_deaf < 5)
						M.take_ear_damage(3 * mult, 1) //makes it so you can't hear people after a bit

					var/list/candidates = null
					// every 15 ticks we check for newly created mobs just in case
					if(isnull(not_yet_invisible) || tick_counter % 15 == 0)
						not_yet_invisible = by_type[/mob/living/carbon/human] - invisible_people
					var/list/mob/current_viewers = viewers(M)
					candidates = not_yet_invisible - current_viewers
					not_yet_invisible &= current_viewers

					if(length(candidates) > 0)  //makes the other people disappear
						if (isnull(invisible_group))
							invisible_group = new /datum/client_image_group
							invisible_group.add_mob(M)
						for(var/mob/living/carbon/human/chosen in candidates)
							var/image/invisible_img = image(null, chosen, null, chosen.layer)
							invisible_img.name = "\u200b"
							invisible_img.override = TRUE
							invisible_group.add_image(invisible_img)
							invisible_people += chosen

				if(counter > 25)                   //some side effects (not using a switch statement so the stages stack)
					if(M.get_brain_damage() <= BRAIN_DAMAGE_MODERATE)
						M.take_brain_damage(1 * mult) //some amount of brain damage
					if(probmult(9) && !ON_COOLDOWN(M, "heartbeat_hallucination", 60 SECONDS)) //play some hearbeat sounds
						M.playsound_local(get_turf(M), 'sound/effects/HeartBeatLong.ogg', 20, 1)
				..()

			on_remove()
				. = ..()
				if (ismob(holder.my_atom))
					var/mob/M = holder.my_atom

					if(!isnull(invisible_group) && (M.get_brain_damage() > BRAIN_DAMAGE_MINOR / 2))          //hits you and knocks you down for a little
						M.visible_message(SPAN_ALERT("<B>[M]</B> starts convulsing violently!"),\
											"You feel as if your body is tearing itself apart!")
						M.setStatusMin("knockdown", 10 SECONDS)
						M.make_jittery(500)

				qdel(invisible_group)
				qdel(invisible_people)
				qdel(not_yet_invisible)
				invisible_group = null
				invisible_people = null
				not_yet_invisible = null

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
						var/text = pick_smart_string("shit_bees_say_when_youre_high.txt", "strings", list(
							"M"="[M]",
							"beeMom"=bee.beeMom ? bee.beeMom : "Mom",
							"other_bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Spacebee" : "Seabee",
							"bee"=istype(bee, /obj/critter/domestic_bee/sea) ? "Seabee" : "Spacebee"
						))
						bee.say(text, atom_listeners_override = list(M))
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
					M.delStatus("knockdown")
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
			addiction_prob = 15
			addiction_min = 10
			addiction_severity = LOW_ADDICTION_SEVERITY
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
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> looks nervous!"))
						M.change_misstep_chance(15 * mult)
						M.take_toxin_damage(2 * mult)
						M.make_jittery(10)
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> is all sweaty!"))
						M.changeBodyTemp(rand(15,30) KELVIN * mult)
						M.take_toxin_damage(3 * mult)
					else if (effect <= 7)
						M.take_toxin_damage(4 * mult)
						M.emote("twitch_v")
						M.make_jittery(10)
				else if (severity == 2)
					if (effect <= 2)
						M.emote("gasp")
						boutput(M, SPAN_ALERT("<b>You can't breathe!</b>"))
						M.take_oxygen_deprivation(15 * mult)
						M.take_toxin_damage(3 * mult)
						M.setStatusMin("stunned", 1 SECOND * mult)
					else if (effect <= 4)
						boutput(M, SPAN_ALERT("<b>You feel terrible!</b>"))
						M.emote("drool")
						M.make_jittery(10)
						M.take_toxin_damage(5 * mult)
						M.setStatusMin("knockdown", 1 SECOND * mult)
						M.change_misstep_chance(33 * mult)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, SPAN_ALERT("<b>Your heart is pounding!</b>"))
						M.playsound_local_not_inworld('sound/effects/heartbeat.ogg', 100)
						M.setStatusMin("unconscious", 5 SECONDS * mult)
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
					boutput(M, SPAN_SUCCESS("<b>You feel... pretty good... and calm... weird.</b>"))
				if(probmult(10))
					M.make_jittery(20)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, SPAN_ALERT("<b>You can feel your heartbeat in your throat!</b>"))
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(2)
				if(probmult(5))
					M.remove_stuns()
					M.sleeping = 0
					M.make_jittery(30)
					M.emote(pick("twitch","twitch_v","shiver","shudder","flinch","blink_r"))
					boutput(M, SPAN_ALERT("<b>Your heart's beating really really fast!</b>"))
					M.playsound_local(M.loc, 'sound/effects/heartbeat.ogg', 50, 1)
					M.take_toxin_damage(4)
				..(M)

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				..()
				..()
				/*var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> looks really nervous!"))
						boutput(M, SPAN_ALERT("<b>You feel really nervous!</b>"))
						M.change_misstep_chance(30)
						M.take_toxin_damage(3)
						M.make_jittery(20)
						M.emote("twitch")
						M.emote("twitch")
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> is super sweaty!"))
						boutput(M, SPAN_ALERT("<b>You feel hot! Is it hot in here?!</b>"))
						M.changeBodyTemp(rand(30,60) KELVIN)
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
						boutput(M, SPAN_ALERT("<b>You really can't breathe!</b>"))
						M.take_oxygen_deprivation(15)
						M.take_toxin_damage(4)
						M.changeStatus("stunned", 10 * mult)
					else if (effect <= 4)
						boutput(M, SPAN_ALERT("<b>You feel really terrible!</b>"))
						M.emote("drool")
						M.emote("drool")
						M.make_jittery(20)
						M.take_toxin_damage(5)
						M.changeStatus("knockdown", 10 * mult)
						M.change_misstep_chance(66)
					else if (effect <= 7)
						M.emote("collapse")
						boutput(M, SPAN_ALERT("<b>Your heart is pounding! You need help!</b>"))
						M << sound('sound/effects/heartbeat.ogg')
						M.changeStatus("knockdown", 50 * mult)
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
							boutput(M, "[SPAN_ALERT("<b>Restarting world!</b>")] [SPAN_NOTICE("Initiated by Administrator!")]")
							SPAWN(2 SECONDS) M.playsound_local(M.loc, pick('sound/misc/NewRound.ogg', 'sound/misc/NewRound2.ogg', 'sound/misc/NewRound3.ogg', 'sound/misc/NewRound4.ogg', 'sound/misc/TimeForANewRound.ogg'), 50, 1)
						if(3)
							switch (rand(1,4))
								if(1)
									boutput(M, SPAN_ALERT("<b>Unknown fires the revolver at [M]!</b>"))
									M.playsound_local(M.loc, 'sound/weapons/Gunshot.ogg', 50, 1)
								if(2)
									boutput(M, SPAN_ALERT("<b>[M] has been attacked with the fire extinguisher by Unknown</b>"))
									M.playsound_local(M.loc, 'sound/impact_sounds/Metal_Hit_1.ogg', 50, 1)
								if(3)
									boutput(M, SPAN_ALERT("<b>Unknown has punched [M]</b>"))
									boutput(M, SPAN_ALERT("<b>Unknown has weakened [M]</b>"))
									M.setStatusMin("knockdown", 1 SECOND * mult)
									M.playsound_local(M.loc, pick(sounds_punch), 50, 1)
								if(4)
									boutput(M, SPAN_ALERT("<b>[M] has been attacked with the taser gun by Unknown</b>"))
									boutput(M, "<i>You can almost hear someone talking...</i>")
									M.setStatusMin("unconscious", 3 SECONDS * mult)
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
			addiction_prob = 10
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
					boutput(M, SPAN_NOTICE("<b>You feel pretty chill.</b>"))
					M.changeBodyTemp(-1 * mult)
					M.emote("smile")
				if(prob(5))
					boutput(M, SPAN_ALERT("<b>You feel too chill!</b>"))
					M.emote(pick("yawn", "drool"))
					M.setStatusMin("stunned", 2 SECONDS * mult)
					M.take_toxin_damage(1 * mult)
					M.take_brain_damage(1 * mult)
					M.changeBodyTemp(-20 * mult)
				if(prob(2))
					boutput(M, SPAN_ALERT("<b>Your skin feels all rough and dry.</b>"))
					random_brute_damage(M, 2 * mult)
				..()
				return

			do_overdose(var/severity, var/mob/M, var/mult = 1)
				var/effect = ..(severity, M)
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> looks dazed!"))
						M.setStatusMin("stunned", 4 SECONDS * mult)
						M.emote("drool")
					else if (effect <= 4)
						M.emote("shiver")
						M.changeBodyTemp(-40 * mult)
					else if (effect <= 7)
						boutput(M, SPAN_ALERT("<b>Your skin is cracking and bleeding!</b>"))
						random_brute_damage(M, 5 * mult)
						M.take_toxin_damage(2 * mult)
						M.take_brain_damage(1 * mult)
						M.emote("cry")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> sways and falls over!"))
						M.take_toxin_damage(3 * mult)
						M.take_brain_damage(3 * mult)
						M.setStatusMin("knockdown", 9 SECONDS * mult)
						M.emote("faint")
					else if (effect <= 4)
						if (ishuman(M))
							if (isskeleton(M))
								M.visible_message(SPAN_ALERT("<b>[M.name]'s bones are rotting away from the inside!"))
							else
								M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> skin is rotting away!"))
							random_brute_damage(M, 25 * mult)
							M.emote("scream")
							M.bioHolder.AddEffect("eaten") //grody. changed line in human.dm to use decomp1 now
							M.emote("faint")
					else if (effect <= 7)
						M.emote("shiver")
						M.changeBodyTemp(-70 * mult)

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
			var/static/list/cat_halluc = list(
				new /image('icons/misc/critter.dmi',"cat-ghost") = list("ghost cat"),
				new /image('icons/misc/critter.dmi', "cat1-wild") = list("wild cat"),
			)
			var/static/list/cat_sounds = list('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg')

			on_mob_life(var/mob/M, var/mult = 1)
				if(!M) M = holder.my_atom
				M.druggy = max(M.druggy, 15)
				if(probmult(11))
					M.visible_message(SPAN_NOTICE("<b>[M.name]</b> hisses!"))
					playsound(M.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
				if(probmult(9))
					M.visible_message(SPAN_NOTICE("<b>[M.name]</b> meows! What the fuck?"))
					playsound(M.loc, 'sound/voice/animal/cat.ogg', 50, 1)

				var/image/imagekey = pick(cat_halluc)
				M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(imagekey), name_list=cat_halluc[imagekey], attacker_prob=7, max_attackers=3)
				M.AddComponent(/datum/component/hallucination/random_sound, timeout=10, sound_list=src.cat_sounds, sound_prob=20)
				..()
				return

			reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
				. = ..()
				if(method == INGEST)
					M.playsound_local(M.loc, pick('sound/voice/animal/cat.ogg', 'sound/voice/animal/cat_hiss.ogg'), 50, 1)
					boutput(M, SPAN_ALERT("<font face='[pick("Arial", "Georgia", "Impact", "Mucida Console", "Symbol", "Tahoma", "Times New Roman", "Verdana")]' size='[rand(3,6)]'>Holy shit, you start tripping balls!</font>"))
				return

		drug/triplemeth
			name = "triple meth"
			id = "triplemeth"
			description = "Hot damn ... I don't even ..."
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

				if(holder.has_reagent("methamphetamine") || holder.has_reagent("synd_methamphetamine")) return ..() //Since is created by a meth overdose, dont react while meth is in their system.
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST, "triplemeth", 98)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STUN_RESIST_MAX, "triplemeth", 98)
				APPLY_ATOM_PROPERTY(M, PROP_MOB_STAMINA_REGEN_BONUS, "triplemeth", 1000)

				if(hascall(holder.my_atom,"addOverlayComposition"))
					holder.my_atom:addOverlayComposition(/datum/overlayComposition/triplemeth)
				flush(holder, 5 * mult, flushed_reagents)
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
				if(holder.has_reagent("methamphetamine") || holder.has_reagent("synd_methamphetamine"))
					return //Since is created by a meth overdose, dont react while meth is in their system.
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> can't seem to control [his_or_her(M)] legs!"))
						M.change_misstep_chance(12 * mult)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.empty_hands()
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.empty_hands()
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> falls to the floor and flails uncontrollably!"))
						M.make_jittery(10)
						M.setStatusMin("knockdown", 10 SECONDS * mult)
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
			addiction_prob = 10
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
					flush(holder, 5 * mult, flushed_reagents)
				..()
				return

			do_overdose(var/severity, var/mob/overdoser, var/mult = 1)
				var/effect = ..(severity, overdoser)
				var/mob/living/M = overdoser
				if(!istype(M))
					return
				if (severity == 1)
					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> can't seem to control [his_or_her(M)] legs!"))
						M.change_misstep_chance(20 * mult)
						M.setStatusMin("knockdown", 5 SECONDS * mult)
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.empty_hands()
					else if (effect <= 7)
						M.emote("laugh")
				else if (severity == 2)

					if(!holder.has_reagent("triplemeth", 10 * mult))
						holder.add_reagent("triplemeth", 10 * mult, null)
						M.add_karma(10)

					if (effect <= 2)
						M.visible_message(SPAN_ALERT("<b>[M.name]'s</b> hands flip out and flail everywhere!"))
						M.empty_hands()
					else if (effect <= 4)
						M.visible_message(SPAN_ALERT("<b>[M.name]</b> falls to the floor and flails uncontrollably!"))
						M.make_jittery(10)
						M.setStatusMin("knockdown", 2 SECONDS * mult)
					else if (effect <= 7)
						M.emote("laugh")

			syndicate
				name = "methamphetamine"
				id = "synd_methamphetamine"
				description = "Methamphetamine is a highly effective and dangerous stimulant drug. This batch seems unusually high-grade and pure."
				purge_brain = FALSE
				fluid_r = 115 // This shit's pure and blue
				fluid_g = 197
				fluid_b = 250

		drug/question_mark
			name = "???"
			id = "question_mark"
			depletion_rate = 2

			on_mob_life(var/mob/M, var/mult = 1)
				if (prob(40))
					if(!M)
						M = holder.my_atom
					M.reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_primaries"), 1.5 * src.calculate_depletion_rate(M, mult))
					M.reagents.add_reagent(pick_string("chemistry_tools.txt", "CYBERPUNK_drug_adulterants"), 1 * src.calculate_depletion_rate(M, mult))
					M.reagents.remove_reagent(src, 1 * mult)
				..()

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
						boutput(M, SPAN_NOTICE("The milk stops the burning. Ahhh."))
						M.reagents.del_reagent("milk")
						M.reagents.del_reagent("hellshroom_extract")
					if (check < 20)
						src.breathefire(M)
					if(check < 5)
						var/bats = rand(2,3)
						M.AddComponent(/datum/component/hallucination/fake_attack, timeout=10, image_list=list(new /image('icons/misc/AzungarAdventure.dmi', "hellbat")), name_list=list("hellbat"), attacker_prob=100, max_attackers=bats)
						boutput(M, SPAN_ALERT("<b>A hellbat begins to chase you</b>!"))
						M.emote("scream")
					if(check < 20)
						boutput(M, SPAN_ALERT("<b>Oh god! Oh GODD!!</b>"))
					if(check < 20)
						boutput(M, SPAN_ALERT("<b>You feel like you are melting from the inside!</b>"))
					if(check < 20)
						boutput(M, SPAN_ALERT("Your throat feels like it's on fire!"))
						M.emote(pick("scream","cry","twitch_s","choke","gasp","grumble"))
						M.changeStatus("unconscious", 2 SECONDS)
					if(check < 20)
						boutput(M, SPAN_NOTICE("<b>You feel A LOT warmer.</b>"))
						M.changeBodyTemp(rand(30,60) KELVIN)
				..()
				return

datum/reagent/drug/hellshroom_extract/proc/breathefire(var/mob/M)
	var/temp = 3000
	var/range = 1

	var/turf/T = get_step(M,M.dir)
	T = get_step(T,M.dir)
	var/list/affected_turfs = getline(M, T)

	M.visible_message(SPAN_ALERT("<b>[M] burps a stream of fire!</b>"))
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
		fireflash(F,1,temp, chemfire = CHEM_FIRE_RED)
