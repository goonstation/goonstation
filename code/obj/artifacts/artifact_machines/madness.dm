/obj/machinery/artifact/madness
	name = "psycho-stimulator field"
	associated_datum = /datum/artifact/madness
	processing_tier = PROCESSING_QUARTER

/datum/artifact/madness
	associated_object = /obj/machinery/artifact/madness
	type_name = "Psycho-stimulator Field"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	fault_blacklist = list(ITEM_ONLY_FAULTS,TOUCH_ONLY_FAULTS)
	activ_text = "takes on an oily sheen!"
	deact_text = "goes dull."
	react_xray = list(8,60,80,6,"TUBULAR")
	shard_reward = ARTIFACT_SHARD_SPACETIME
	combine_flags = ARTIFACT_COMBINES_INTO_ANY | ARTIFACT_ACCEPTS_ANY_COMBINE
	var/range
	var/effect_type = "flock"
	var/recharge_time = 10 SECONDS
	var/static/type_to_effect = list(
		// spooky old things
		"ancient" = list("flock", "basic_attackers", "spiders"),
		// organic stuff
		"martian" = list("farts_4_days", "fleshy"),
		// goofy stuff
		"wizard" = list("pretty_colours", "farts_4_days"),
		// terrifying stuff
		"eldritch" = list("screaming", "fleshy", "spooky_ghosts"),
		// tech stuff
		"precursor" = list("flock", "pretty_colours","singulo"),
	)

	/// This is an associative list of hallucination name to a list of AddComponent arguments. Try not to cry.
	var/static/madness_effects = list(
		// disembodied screams
		"screaming" = list(
			list(/datum/component/hallucination/random_sound,
				list(
					timeout = 30,
					sound_list = list(
						'sound/voice/screams/male_scream.ogg',
						'sound/voice/screams/female_scream.ogg',
						'sound/voice/screams/fescream1.ogg',
						'sound/voice/screams/fescream2.ogg',
						'sound/voice/screams/fescream3.ogg',
						'sound/voice/screams/fescream4.ogg',
						'sound/voice/screams/fescream5.ogg',
						'sound/voice/screams/mascream4.ogg',
						'sound/voice/screams/mascream5.ogg',
						'sound/voice/screams/mascream6.ogg',
						'sound/voice/screams/mascream7.ogg'
					),
					sound_prob = 40,
					min_distance = 5
				)
			)
		),
		// people are covered in spiders, there's webs and cocoons everywhere, also spiders attack you
		"spiders" = list(
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=30,
					image_list=list(
						image(icon = 'icons/mob/human.dmi', icon_state = "spiders"),
					),
					target_list=list(/mob/living/carbon/human),
					range=6,
					image_prob=100,
					image_time=60,
					override=FALSE
				)
			),
			list(/datum/component/hallucination/random_image,
				list(
					timeout=30,
					image_list=list(
						image(icon = 'icons/effects/effects.dmi', icon_state = "web2"),
						image(icon = 'icons/effects/effects.dmi', icon_state = "web"),
						image(icon = 'icons/obj/decals/cleanables.dmi', icon_state = "cobweb_floor-c"),
						image(icon = 'icons/effects/effects.dmi', icon_state = "cobweb_circle_messy-unused"),
						image(icon = 'icons/effects/vomit.dmi', icon_state = "spiders1"),
						image(icon = 'icons/effects/vomit.dmi', icon_state = "spiders2"),
						image(icon = 'icons/effects/vomit.dmi', icon_state = "spiders3"),
					),
					image_prob=10,
					image_time=60,
				)
			),
			list(/datum/component/hallucination/fake_attack,
				list(
					timeout = 30,
					image_list = list(
						image(icon = 'icons/misc/critter.dmi', icon_state = "lil_spide"),
						image(icon = 'icons/misc/critter.dmi', icon_state = "med_spide"),
						image(icon = 'icons/misc/critter.dmi', icon_state = "big_spide"),
					),
					name_list = list("spider"),
					attacker_prob = 5,
					max_attackers = 2
				)
			)
		),
		// people look like ghosts, ghosts attack you
		"spooky_ghosts" = list(
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=30,
					image_list=list(
						image(icon = 'icons/mob/mob.dmi', icon_state = "ghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "borghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "doubleghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist-corp"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist"),
					),
					target_list=list(/mob/living/carbon/human),
					range=8,
					image_prob=100,
					image_time=60,
					override=TRUE,
					visible_creation = FALSE
				)
			),
			list(/datum/component/hallucination/fake_attack,
				list(
					timeout = 30,
					image_list = list(
						image(icon = 'icons/mob/mob.dmi', icon_state = "ghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "borghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "doubleghost"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist-corp"),
						image(icon = 'icons/mob/mob.dmi', icon_state = "poltergeist"),
					),
					name_list = list("spooky ghost", "poltergeist", "the ghost of christmas past", "casper", "ghost in the machine", "ghost", "spectre", "haunt"),
					attacker_prob = 5,
					max_attackers = 2
				)
			)
		),
		//just some pretty colours
		"pretty_colours" = list(
			list(/datum/component/hallucination/trippy_colors,
				list(
					timeout=30,
				)
			)
		),
		// constant fart sounds, sorry everybody (I am not sorry)
		"farts_4_days" = list(
			list(/datum/component/hallucination/random_sound,
				list(
					timeout = 30,
					sound_list = list(
						'sound/misc/flockmind/flockdrone_fart.ogg',
						'sound/vox/fart.ogg',
						'sound/voice/farts/poo2.ogg',
						'sound/voice/farts/poo2_robot.ogg',
						'sound/voice/farts/fart1.ogg',
						'sound/voice/farts/fart2.ogg',
						'sound/voice/farts/fart3.ogg',
						'sound/voice/farts/fart4.ogg',
						'sound/voice/farts/fart5.ogg',
						'sound/voice/farts/fart6.ogg',
						'sound/voice/farts/fart7.ogg',
						'sound/voice/farts/superfart.ogg',
					),
					sound_prob = 20
				)
			)
		),
		"basic_attackers" = list(
			list(/datum/component/hallucination/fake_attack,
				list(
					timeout = 30,
					image_list = null, //defaults
					name_list = null, //defaults,
					attacker_prob = 20,
					max_attackers = 3
				)
			)
		),
		// hear fleshy sounds, see the walls and floor become fleshy, be attacked by lumps of flesh
		"fleshy" = list(
			//flesh walls
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=30,
					image_list=list(
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodwall_2"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodwall_3"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodwall_4"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodwall_5"),
					),
					target_list=list(/turf/simulated/wall),
					range=6,
					image_prob=30,
					image_time=60,
					override=TRUE
				)
			),
			//flesh floors
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=10,
					image_list=list(
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodfloor_1"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodfloor_2"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "bloodfloor_3"),
					),
					target_list=list(/turf/simulated/floor),
					range=8,
					image_prob=80,
					image_time=60,
					override=TRUE
				)
			),
			//flesh sounds
			list(/datum/component/hallucination/random_sound,
				list(
					timeout = 30,
					sound_list = list(
						'sound/impact_sounds/Flesh_Break_2.ogg',
						'sound/impact_sounds/Flesh_Crush_1.ogg',
						'sound/impact_sounds/Flesh_Tear_1.ogg',
						'sound/impact_sounds/Flesh_Tear_2.ogg',
						'sound/impact_sounds/Flesh_Tear_3.ogg',
						'sound/impact_sounds/Flesh_Stab_1.ogg',
						'sound/impact_sounds/Glub_1.ogg',
						'sound/impact_sounds/meat_smack.ogg',
					),
					sound_prob = 20
				)
			),
			//fleshy attackers
			list(/datum/component/hallucination/fake_attack,
				list(
					timeout = 30,
					image_list = list(
						image(icon = 'icons/misc/meatland.dmi', icon_state = "light"),
						image(icon = 'icons/misc/meatland.dmi', icon_state = "meatmine"),
						image(icon = 'icons/misc/critter.dmi', icon_state = "blobman"),
						image(icon = 'icons/misc/critter.dmi', icon_state = "polyp"),
						image(icon = 'icons/misc/critter.dmi', icon_state = "meaty_mouth"),
					),
					name_list = list("fleshy abomination", "twisted meat", "oh god, what is that?", "collection of meat and bone", "pile of organs", "inside-out organ"),
					attacker_prob = 20,
					max_attackers = 2
				)
			)
		),
		//oh no it's a fake flock invasion
		"flock" = list(
			//flock walls
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=30,
					image_list=list(image(icon = 'icons/turf/walls/flock.dmi', icon_state = "flock0")),
					target_list=list(/turf/simulated/wall),
					range=6,
					image_prob=10,
					image_time=30,
					override=TRUE
				)
			),
			//flock floors
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=10,
					image_list=list(image(icon = 'icons/misc/featherzone.dmi', icon_state = "floor")),
					target_list=list(/turf/simulated/floor),
					range=8,
					image_prob=80,
					image_time=60,
					override=TRUE
				)
			),
			//flock objects
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=10,
					image_list=list(
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "reclaimer"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "teleblocker-on"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "sentinel"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "sentinelon"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "sapper-on"),
					),
					target_list=list(/obj/machinery/vending, /obj/machinery/computer3, /obj/machinery/computer, /obj/machinery/portable_atmospherics/canister, /obj/reagent_dispensers, /obj/machinery/manufacturer),
					range=6,
					image_prob=20,
					image_time=30,
					override=TRUE
				)
			),
			//flock drones
			list(/datum/component/hallucination/random_image_override,
				list(
					timeout=30,
					image_list=list(
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "drone"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "drone-d1"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "drone-d2"),
						image(icon = 'icons/misc/featherzone.dmi', icon_state = "flockbit"),
					),
					target_list=list(/mob/living/carbon/human),
					range=6,
					image_prob=40,
					image_time=30,
					override=TRUE,
					visible_creation = FALSE
				)
			),
			//flock sounds
			list(/datum/component/hallucination/random_sound,
				list(
					timeout = 30,
					sound_list = list(
						'sound/misc/flockmind/flockdrone_convert.ogg',
						'sound/misc/flockmind/flockdrone_quickbuild.ogg',
						'sound/misc/flockmind/flockdrone_build.ogg',
						'sound/misc/flockmind/flockdrone_build_complete.ogg',
						'sound/misc/flockmind/flockdrone_beep1.ogg',
						'sound/misc/flockmind/flockdrone_beep2.ogg',
						'sound/misc/flockmind/flockdrone_beep3.ogg',
						'sound/misc/flockmind/flockdrone_beep4.ogg',
						'sound/misc/flockmind/flockdrone_grump1.ogg',
						'sound/misc/flockmind/flockdrone_grump2.ogg',
						'sound/misc/flockmind/flockdrone_grump3.ogg',
						'sound/misc/flockmind/flockdrone_fart.ogg', //hehe
						'sound/misc/flockmind/flockdrone_floorrun.ogg',

					),
					sound_prob = 10
				)
			),
		),
		//oh god a singuloose is going to eat you!
		"singulo" = list(
			list(/datum/component/hallucination/fake_singulo,
				list(
					timeout=60,
				)
			)
		),
	)


	post_setup()
		. = ..()
		src.effect_type = pick(src.type_to_effect[src.artitype.name])
		recharge_time = rand(5,30) SECONDS
		range = rand(2,8)

	effect_process(var/obj/O)
		if (..())
			return
		if (ON_COOLDOWN(O, "madness_field" , recharge_time))
			return

		if(prob(2))
			var/turf/T = get_turf(O)
			T.visible_message("<b>[O]</b> shimmers briefly!")

		for (var/mob/living/L in range(range,O))
			if (!L.client) //no point hallucinating if there's nobody to see it
				continue

			var/mob/living/carbon/human/H  = L
			if(istype(H) && istype(H.head, /obj/item/clothing/head/tinfoil_hat))
				continue

			if(!ON_COOLDOWN(L, "halluc_cooldown_\ref[src]", 60 SECONDS)) //dont spam logs - we only want to log when a new effect applies - not a refresh
				logTheThing(LOG_COMBAT, L, "was affected by a [src.effect_type] hallucination from [src.associated_object] at [log_loc(src.associated_object)]")
			else
				EXTEND_COOLDOWN(L, "halluc_cooldown_\ref[src]", 60 SECONDS)

			for(var/list/comp_args_tuple in src.madness_effects[src.effect_type])
				//yes, we really do mean _AddComponent here, because it's already a list we're passing
				//also we do it with the summed list because _AddComponent modifies the list that is passed to it
				L._AddComponent(list(comp_args_tuple[1]) + comp_args_tuple[2])


