
/obj/critter/nicespider
	name = "bumblespider"
	desc = "It seems pretty friendly. D'aww."
	icon_state = "bumblespider"
	health = 30
	aggressive = 1
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	density = 0
	sleeping_icon_state = "bumblespider-sleep"
	atk_text = "nibbles"
	atk_brute_amt = 3
	crit_chance = 0
	var/venom1 = "venom"
	var/flailing = 0

	CritterAttack(mob/M)
		..()
		if(iscarbon(M) && M.reagents)
			M.reagents.add_reagent("[venom1]", 3)
		if(prob(15))
			spiderflail(src.target)

	attack_hand(mob/user)
		if (src.alive)
			if (user.a_intent == INTENT_HARM)
				return ..()
			else
				src.visible_message("<span class='alert'><b>[user]</b> [pick("pets","hugs","snuggles","cuddles")] [src]!</span>", group="spiderhug")
				if (prob(15) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
					for (var/mob/O in hearers(src, null))
						O.show_message("[src] coos[prob(50) ? " happily!" : ""]!",2)
						playsound(src.loc, 'sound/voice/babynoise.ogg', 30, 0)
				return
		else
			..()

		return

	proc/spiderflail(mob/M) //todo: centralize this fucking mess of spiders into one base type
		if (flailing)
			return

		flailing = 10
		playsound(src.loc, "rustle", 50, 0)
		SPAWN(0)
			while(flailing-- > 0 && src.alive)
				src.set_loc(M.loc)
				src.pixel_x = rand(-2,2) * 2
				src.pixel_y = rand(-2,2) * 2
				src.set_dir(pick(alldirs))
				if(prob(30))
					src.visible_message("<span class='alert'><B>[src]</B> bites [src.target]!</span>")
					playsound(src.loc, "rustle", 50, 1)
					random_brute_damage(src.target, rand(1,2))//it's all over you
					M.reagents.add_reagent("[venom1]", 2)
				sleep(0.4 SECONDS)
			src.pixel_x = 0
			src.pixel_y = 0
			if(flailing < 0)
				flailing = 0

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/nicespider
	name = "bumblespider egg"
	critter_type = /obj/critter/nicespider

/obj/critter/spider
	name = "space spider"
	desc = "A big ol' spider, from space. In space. A space spider."
	density = 1
	health = 50
	aggressive = 0
	defensive = 1
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 1
	atksilicon = 1
	firevuln = 0.65
	brutevuln = 0.45
	angertext = "scuttles towards"
	chase_text = "dives on"
	butcherable = 1
	var/flailing = 0
	var/feeding = 0
	var/venom1 = "venom"  // making these modular so i don't have to rewrite this gigantic goddamn section for all the subtypes
	var/venom2 = "spiders"
	var/babyspider = 0
	var/honk = 0 //this lets clownspiders scavenge
	var/adultpath = null
	var/bitesound = 'sound/weapons/handcuffs.ogg'
	var/stepsound = null
	var/deathsound = 'sound/impact_sounds/Generic_Snap_1.ogg'
	death_text = "%src% crumples up into a ball!"
	var/encase_in_web = 1 // do they encase people in ice, web, or, uh, cotton candy?
	var/reacting = 1 // when they inject their venom, does it react immediately or not?

	skinresult = /obj/item/material_piece/cloth/spidersilk
	max_skins = 4

	New()
		..()
		if (!icon_state && !babyspider)
			icon_state = pick("big_spide", "big_spide-red", "big_spide-green", "big_spide-blue")
			src.dead_state = "[src.icon_state]-dead"

	CritterDeath()
		if(!src.alive) return
		..()
		if (honk) return // clown spiders have special deaths
		playsound(src.loc, src.deathsound, 50, 0)
		src.reagents.add_reagent(venom1, 50, null)
		src.reagents.add_reagent(venom2, 50, null)

	seek_target()

		if (src.honk == 1)
			return ..()
		src.anchored = 0
		if (src.target)
			src.task = "chasing"
			return
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (isintangible(C)) continue //maybe dont attack blob overminds
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			//if (C.stat || C.health < 0) continue
			if (C.bioHolder.HasEffect("husk")) continue
			if (istype(C, /mob/living/critter/spider)) continue
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
			src.visible_message("<span class='alert'><B>[src]</B> hisses!</span>")
			break

	Move()
		if (src.stepsound)
			if(prob(30))
				playsound(src.loc, src.stepsound, 50, 0)
		. = ..()

	CritterAttack(mob/M)
		if(ismob(M))
			src.attacking = 1
			if (prob(20))
				src.visible_message("<span class='alert'><B>[src]</B> dives on [M]!</span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 0)
				M.changeStatus("weakened", 2 SECONDS)
				M.changeStatus("stunned", 2 SECONDS)
				random_brute_damage(M, rand(2,5),1)
				src.spiderflail(src.target)
				if(!M.stat) M.emote("scream") // don't scream while dead/asleep // why?
			else
				src.visible_message("<span class='alert'><B>[src]</B> bites [src.target]!</span>")
				playsound(src.loc, src.bitesound, 50, 1)
				if(ishuman(M))
					random_brute_damage(src.target, rand(1,2),1)
					src.reagents.add_reagent("[venom1]", 2) // doing this instead of directly adding reagents to M should give people the correct messages
					src.reagents.add_reagent("[venom2]", 2)
					if (src.reacting)
						src.reagents.reaction(M, INGEST)
					else
						src.reagents.trans_to(M, 4)
				else if(issilicon(M))
					switch(rand(1,4))
						if(1)
							M:compborg_take_critter_damage("r_arm", rand(2,4))
						if(2)
							M:compborg_take_critter_damage("l_arm", rand(2,4))
						if(3)
							M:compborg_take_critter_damage("r_leg", rand(2,4))
						if(4)
							M:compborg_take_critter_damage("l_leg", rand(2,4))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.was_harmed(src)
				if(isunconscious(M)) // kill KOd people faster
					src.set_loc(M.loc)
					src.visible_message("<span class='alert'><B>[src]</B> jumps onto [src.target]!</span>")
					sleep(0.5 SECONDS)
					src.visible_message("<span class='alert'><B>[src]</B> sinks its fangs into [src.target]!</span>")
					playsound(src.loc, 'sound/misc/fuse.ogg', 50, 1)
					src.reagents.add_reagent("[venom1]", 5) // doing this instead of directly adding reagents to M should give people the correct messages
					src.reagents.add_reagent("[venom2]", 5)
					if (src.reacting)
						src.reagents.reaction(M, INGEST)
					else
						src.reagents.trans_to(M, 10)
					random_brute_damage(M, rand(2,5),1)

				if(isdead(M) && !feeding) // drain corpses into husks
					if(ishuman(M))
						var/mob/living/carbon/human/T = M
						feeding = 1
						src.spiderflail(src.target)
						src.visible_message("<span class='alert'><B>[src]</B> starts draining the fluids out of [T]!</span>")
						src.set_loc(T.loc)
						sleep(2 SECONDS)
						playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
						sleep(5 SECONDS)
						if(src.target && T.stat && src.loc == T.loc) // check to see if the target is still passed out and under the spider
							src.visible_message("<span class='alert'><B>[src]</B> drains [T] dry!</span>")
							T.death(FALSE)
							T.real_name = "Unknown"
							T.bioHolder.AddEffect("husk")
							sleep(0.2 SECONDS)
							playsound(src.loc, 'sound/misc/fuse.ogg', 50, 1)
							src.set_loc(get_step(src, pick(alldirs))) // get the fuck out of the way of the ice cube
							sleep(0.2 SECONDS)
							var/obj/icecube/cube = new /obj/icecube(get_turf(M), M)
							M.set_loc(cube)
							switch (src.encase_in_web)
								if (2)
									src.visible_message("<span class='alert'><B>[src]</B> wraps [src.target] in cotton candy!</span>")
									cube.name = "bundle of cotton candy"
									cube.desc = "What the fuck spins webs out of - y'know what, scratch that. You don't want to find out."
									cube.icon_state = "candyweb2"
									cube.steam_on_death = 0

								if (1)
									src.visible_message("<span class='alert'><B>[src]</B> encases [src.target] in web!</span>")
									cube.name = "bundle of web"
									cube.desc = "A big wad of web. Someone seems to be stuck inside it."
									cube.icon_state = "web2"
									cube.steam_on_death = 0

								if (0)
									src.visible_message("<span class='alert'><B>[src]</B> encases [src.target] in ice!</span>")

							feeding = 0
							if (babyspider) // dawww
								src.visible_message("<span class='alert'><B>[src]</B> grows up!</span>")
								var/adult = text2path(src.adultpath)
								new adult(src.loc)
								qdel(src)
						else
							feeding = 0

			SPAWN(2 SECONDS)
				src.attacking = 0

	ChaseAttack(mob/M)
		playsound(src.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)
		src.visible_message("<span class='alert'><B>[src]</B> hisses!</span>")
		if (prob(30))
			..()
			playsound(src.loc, pick('sound/impact_sounds/Generic_Shove_1.ogg'), 50, 0)
			M.changeStatus("weakened", 2 SECONDS)
			M.changeStatus("stunned", 2 SECONDS)
			random_brute_damage(M, rand(2,5),1)
			src.spiderflail(src.target)
			if(!M.stat) M.emote("scream") // don't scream while dead or KOd
		else src.visible_message("<span class='alert'><B>[src]</B> dives at [M], but misses!</span>")

	on_pet(mob/user)
		if (..())
			return 1
		if (prob(15) && !ON_COOLDOWN(src, "playsound", 3 SECONDS))
			playsound(src.loc, 'sound/voice/babynoise.ogg', 30, 1)
			src.visible_message("<span class='alert'><b>[src] coos!</b></span>", 1)

	proc/spiderflail(mob/M)
		if (flailing)
			return

		flailing = 10
		if (src.stepsound)
			playsound(src.loc, src.stepsound, 50, 0)
		SPAWN(0)
			while(flailing-- > 0 && src.alive)
				src.set_loc(M.loc)
				src.pixel_x = rand(-2,2) * 2
				src.pixel_y = rand(-2,2) * 2
				src.set_dir(pick(alldirs))
				if(prob(30))
					src.visible_message("<span class='alert'><B>[src]</B> bites [src.target]!</span>")
					playsound(src.loc, src.bitesound, 50, 1)
					if(ishuman(M))
						random_brute_damage(src.target, rand(1,2),1)
						src.reagents.add_reagent("[venom1]", 2) // doing this instead of directly adding reagents to M should give people the correct messages
						src.reagents.add_reagent("[venom2]", 2)
						if (src.reacting)
							src.reagents.reaction(M, INGEST)
						else
							src.reagents.trans_to(M, 4)
					else if(issilicon(M))
						switch(rand(1,4))
							if(1)
								M:compborg_take_critter_damage("r_arm", rand(2,4))
							if(2)
								M:compborg_take_critter_damage("l_arm", rand(2,4))
							if(3)
								M:compborg_take_critter_damage("r_leg", rand(2,4))
							if(4)
								M:compborg_take_critter_damage("l_leg", rand(2,4))
				sleep(0.4 SECONDS)
			src.pixel_x = 0
			src.pixel_y = 0
			if(flailing < 0)
				flailing = 0

/obj/critter/spider/aggressive
	aggressive = 1

/obj/critter/spider/baby
	name = "li'l space spider"
	desc = "A li'l tiny spider, from space. In space. A space spider."
	icon_state = "lil_spide"
	density = 0
	health = 1
	venom1 = "toxin"
	venom2 = "black_goop"
	babyspider = 1
	max_skins = 1
	adultpath = "/obj/critter/spider"

	// don't ask
	proc/streak(var/list/directions)
		SPAWN(0)
			for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
				LAGCHECK(LAG_LOW)//sleep(0.3 SECONDS)
				if (step_to(src, get_step(src, pick(directions)), 0))
					break

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/spider
	name = "spider egg"
	critter_type = /obj/critter/spider/baby
	critter_reagent = "spiders"

/obj/critter/spider/ice
	name = "ice spider"
	desc = "It seems to be adapted to a frozen climate."
	icon_state = "icespider"
	density = 1
	health = 20
	aggressive = 1
	firevuln = 1.5
	brutevuln = 0.5
	hitsound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	venom1 = "toxin"
	venom2 = "cryostylane"
	babyspider = 0
	bitesound = 'sound/impact_sounds/Crystal_Hit_1.ogg'
	stepsound = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
	deathsound = 'sound/impact_sounds/Crystal_Shatter_1.ogg'
	encase_in_web = 0
	max_skins = 4
	reacting = 0

/// subtypes

/obj/critter/spider/ice/baby
	name = "baby ice spider"
	desc = "Dawww."
	icon_state = "babyicespider"
	density = 0
	health = 1
	venom1 = "toxin"
	venom2 = "cryostylane"
	babyspider = 1
	max_skins = 1
	adultpath = "/obj/critter/spider/ice"

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/icespider
	name = "ice spider egg"
	critter_type = /obj/critter/spider/ice/baby
	warm_count = 25
	critter_reagent = "spidereggs"

/obj/critter/spider/ice/queen
	name = "queen ice spider"
	desc = "AHHHHHHH"
	icon_state = "gianticespider"
	density = 1
	health = 100
	venom1 = "morphine"
	venom2 = "spidereggs"

	skinresult = /obj/item/material_piece/cloth/spidersilk
	max_skins = 8

/obj/critter/spider/ice/nice
	name = "nice spider"
	desc = "Aww, hi there!"
	aggressive = 0
	defensive = 0
	atkcarbon = 0
	atksilicon = 0
	venom1 = "hugs"
	venom2 = "sparkles"

/obj/critter/spider/ice/queen/nice
	name = "queen nice spider"
	desc = "AWWWWWWW!"
	icon_state = "gianticespider"
	aggressive = 0
	defensive = 0
	atkcarbon = 0
	atksilicon = 0
	venom1 = "hugs"
	venom2 = "sparkles"

/obj/critter/spider/spacerachnid // you get to be in here TOO
	name = "spacerachnid"
	desc = "A rather large spider."
	icon_state = "spider"
	density = 1
	health = 10
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
	atkcarbon = 1
	atksilicon = 1
	atcritter = 1
	firevuln = 0.65
	brutevuln = 0.45
	venom1 = "venom"
	venom2 = "venom"
	death_text = "%src% is squashed!"

/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/spacerachnid
	name = "spacerachnid egg"
	critter_type = /obj/critter/spider/spacerachnid
	critter_reagent = "spiders"


/obj/critter/spider/clown
	name = "clownspider"
	desc = "A surprisingly prolific space pest, the common clownspider mostly eats banana peels and cockroaches. Mostly."
	icon_state = "clownspider"
	health = 5
	aggressive = 1
	atkcarbon = 0
	atksilicon = 0
	wanderer = 1
	butcherable = 0
	scavenger = 1
	honk = 1
	angertext = "honks angrily at"
	death_text ="%src% splats messily!"
	atk_text = "kicks"
	atk_brute_amt = 2
	crit_text = "pummels"
	crit_brute_amt = 4
	adultpath = "/obj/critter/spider/clownqueen"
	var/sound_effect = 'sound/musical_instruments/Bikehorn_1.ogg'
	var/item_shoes = /obj/item/clothing/shoes/clown_shoes
	var/item_mask = /obj/item/clothing/mask/clown_hat

	cluwne
		name = "cluwnespider"
		desc = "Uhhh. That's not normal. Like, even for clownspiders."
		icon_state = "cluwnespider"
		sound_effect = 'sound/voice/cluwnelaugh3.ogg'
		adultpath = "/obj/critter/spider/clownqueen/cluwne"
		item_shoes = /obj/item/clothing/shoes/cursedclown_shoes
		item_mask = /obj/item/clothing/mask/cursedclown_hat

	New(var/parent = null)
		..()
		src.parent = parent

	attack_hand(mob/user)
		if (src.alive && (user.a_intent != INTENT_HARM))
			src.visible_message("<span class='combat'><b>[user]</b> [src.pet_text] [src]!</span>")
			return
		if(prob(50))
			if(src.alive)
				src.visible_message("<span class='combat'><B>[user] stomps [src], killing it instantly!</B></span>")
				CritterDeath()
				return
			else
				src.visible_message("<span class='combat'><B>[user] squishes [src] a little more for good measure.</B></span>")
				return
		..()

	CritterAttack(mob/M)
		playsound(src.loc, "swing_hit", 30, 0)
		..()
		if(prob(25))
			playsound(src.loc, src.sound_effect, 50, 0)

	ai_think()
		if (task == "scavenging") // beep beep here comes the terrible copy paste train
			var/mob/living/carbon/human/C = src.corpse_target
			if (istype(C) && C.bioHolder && C.bioHolder.HasEffect("husk")) // did a buddy get him first? // haine fix for Cannot read null.bioHolder
				src.task = "thinking"
				src.corpse_target = null
				return
			if (!src.scavenger || src.corpse_target == null)
				src.task = "thinking"
			if (GET_DIST(src, src.corpse_target) > src.attack_range)
				src.task = "chasing corpse"
			src.visible_message("<span class='alert'><B>[src]</B> starts draining the fluids out of [C]!</span>")
			src.set_loc(C.loc)
			sleep(2 SECONDS)
			playsound(src.loc, 'sound/misc/pourdrink.ogg', 50, 1)
			sleep(5 SECONDS)
			if(src.corpse_target && src.loc == C.loc)
				src.visible_message("<span class='alert'><B>[src]</B> drains [C] dry!</span>")
				C.real_name = "Unknown"
				C.bioHolder.AddEffect("husk")
				sleep(0.2 SECONDS)
				playsound(src.loc, 'sound/misc/fuse.ogg', 50, 1)
				src.set_loc(get_step(src, pick(alldirs))) // get the fuck out of the way of the ice cube
				sleep(0.2 SECONDS)
				var/obj/icecube/cube = new /obj/icecube(get_turf(C), C)
				C.set_loc(cube)
				src.visible_message("<span class='alert'><B>[src]</B> encases [src.target] in web!</span>")
				cube.name = "bundle of cotton candy"
				cube.desc = "What the fuck spins webs out of - y'know what, scratch that. You don't want to find out."
				cube.icon_state = "candyweb2"
				cube.steam_on_death = 0
				src.visible_message("<span class='alert'><B>[src]</B> grows up!</span>")
				var/adult = text2path(src.adultpath)
				new adult(src.loc)
				qdel(src)
		else ..()

	CritterDeath()
		..()
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
		var/obj/decal/cleanable/blood/gibs/gib = null
		gib = make_cleanable(/obj/decal/cleanable/blood/gibs,src.loc)
		new src.item_shoes(src.loc)
		if (prob(25))
			new src.item_mask(src.loc)
		gib.streak_cleanable(NORTH)
		qdel (src)

	disposing()
		if (istype(parent, /mob/living/critter/spider/clownqueen))	//obj/critter queens can't make babies so who cares.
			var/mob/living/critter/spider/clownqueen/queen = parent
			if (islist(queen.babies))
				queen.babies -= src
		..()

/obj/critter/spider/clownqueen
	name = "queen clownspider"
	desc = "You see this? This is why people hate clowns. This thing right here."
	icon_state = "clownspider_queen"
	health = 100
	aggressive = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY //clever girl
	venom1 = "rainbow fluid"
	death_text ="%src% explodes into technicolor gore!"
	encase_in_web = 2
	var/sound_effect = 'sound/musical_instruments/Bikehorn_1.ogg'
	var/item_shoes = /obj/item/clothing/shoes/clown_shoes
	var/item_mask = /obj/item/clothing/mask/clown_hat

	cluwne
		name = "queen cluwnespider"
		desc = "...I got nothin'."
		icon_state = "cluwnespider_queen"
		sound_effect = 'sound/voice/cluwnelaugh3.ogg'
		venom1 = "painbow fluid"
		item_shoes = /obj/item/clothing/shoes/cursedclown_shoes
		item_mask = /obj/item/clothing/mask/cursedclown_hat

	seek_target()
		src.anchored = 0
		if (src.target)
			src.task = "chasing"
			return
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (isintangible(C)) continue
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (C.bioHolder && C.bioHolder.HasEffect("husk")) continue
			if (istype(C, /mob/living/critter/spider)) continue
			src.target = C
			src.oldtarget_name = C.name
			src.task = "chasing"
			playsound(src.loc, src.sound_effect, 50, 1)
			src.visible_message("<span class='alert'><B>[src]</B> honks!</span>")
			break

	CritterDeath()
		..()
		playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
		var/obj/decal/cleanable/blood/gibs/gib = null
		gib = make_cleanable( /obj/decal/cleanable/blood/gibs,src.loc)
		new src.item_shoes(src.loc)
		new src.item_shoes(src.loc)
		new src.item_shoes(src.loc)
		new src.item_shoes(src.loc)
		if (prob(25))
			new src.item_mask(src.loc)
		gib.streak_cleanable(NORTH)
		qdel (src)


/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/clown
	name = "clown egg"
	desc = "Um."
	critter_type = /mob/living/critter/spider/clown
	warm_count = 20
	critter_reagent = "rainbow fluid"


/obj/item/reagent_containers/food/snacks/ingredient/egg/critter/cluwne
	name = "cluwne egg"
	desc = "Um???"
	critter_type = /mob/living/critter/spider/clown/cluwne
	warm_count = 20
	critter_reagent = "painbow fluid"
