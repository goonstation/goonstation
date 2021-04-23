/////// cogwerks spooky automaton thing that kinda just sits there being weird and ominous

var/global/the_automaton = null

#define AUTOMATON_MAX_KEYS 7
/obj/critter/automaton
	name = "automaton"
	desc = "What is this thing? A toy? A machine? What is it doing? Why does it seem to be watching you?"
	icon_state = "automaton"
	health = 1000 // what kind of jerk would kill it
	anchored = 1
	aggressive = 0
	defensive = 0
	wanderer = 0
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 0.5
	brutevuln = 1
	generic = 0
	crit_chance = 0
	atk_text = "smashes"
	atk_brute_amt = 10
	var/atom/admiring_target = null
	var/keycount = 0
	var/vacation = 0
	var/pied = 0
	var/saw_moon_bee = 0
	var/sun_spin = 0
	var/spin_lock = null // for making sure the sun keeps spinning in the direction it's already going
	var/got_cheget_key = 0 // Don't keep handing me this you fuck

	New()
		..()
		SPAWN_DBG(1 SECOND)
			if (!the_automaton)
				the_automaton = src

	disposing()
		if (the_automaton == src)
			the_automaton = null
		..()

	disposing()
		if (the_automaton == src)
			the_automaton = null
		..()

	angry
		aggressive = 1
		atkcarbon = 1
		atksilicon = 1
		wanderer = 1
		opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY

	CritterAttack(mob/M)
		playsound(src.loc, "sound/misc/automaton_scratch.ogg", 50, 1)
		..()

	process()
		if(!..())
			return 0
		if (!alive)
			return
		if (prob(6))
			playsound(src.loc, "sound/misc/automaton_tickhum.ogg", 60, 1)
			if (!src.muted)
				src.visible_message("<span class='alert'><b>[src] emits [pick("a soft", "a quiet", "a curious", "an odd", "an ominous", "a strange", "a forboding", "a peculiar", "a faint")] [pick("ticking", "tocking", "humming", "droning", "clicking")] sound.</span>")
		if (prob(6))
			playsound(src.loc, "sound/misc/automaton_ratchet.ogg", 60, 1)
			if (!src.muted)
				src.visible_message("<span class='alert'><b>[src] emits [pick("a peculiar", "a worried", "a suspicious", "a reassuring", "a gentle", "a perturbed", "a calm", "an annoyed", "an unusual")] [pick("ratcheting", "rattling", "clacking", "whirring")] noise.</span>")
		if (prob(5))
			playsound(src.loc, "sound/misc/automaton_scratch.ogg", 50, 1)
			spin()

		if ((src.aggressive || prob(6)) && locate(/obj/critter/domestic_bee) in view(7,src))
			for (var/obj/critter/domestic_bee/moonbeeMaybe in view(7, src))
				if (moonbeeMaybe.desc == "A moon bee.  It's like a regular space bee, but it has a peculiar gleam in its eyes...") //Because bee names are customizable, but desc isn't!
					src.visible_message("<span class='alert'><b>[src]</b> [pick("points at", "stares at", "gesticulates at", "madly gestures towards")] [moonbeeMaybe]!</span>")
					if (!saw_moon_bee)
						saw_moon_bee = 1

					if (saw_moon_bee == 1 && keycount == INFINITY && !aggressive)

						ending_event()


					if (moonbeeMaybe.alive && prob(75))
						if (!moonbeeMaybe.muted)
							moonbeeMaybe.visible_message("<span class='alert'><b>[moonbeeMaybe]</b> buzzes [pick("grumpily","in a confused manner", "excitedly")] at [src]!</span>")

					return

				else if (moonbeeMaybe.desc == "A sun bee.  It's like a regular space bee, but it has a look of fiery passion.  Passion for doing bee stuff.") //Oh, it's the sun bee
					if (src.aggressive)
						src.visible_message("<span class='alert'><b>[src]</b> sees [moonbeeMaybe] and seems to calm down. Phew!</span>")
						src.aggressive = 0
						src.attacking = 0
						src.atkcarbon = 0
						src.atksilicon = 0
					saw_moon_bee = 2
					src.visible_message("<span class='alert'><b>[src]</b> [pick("points at", "stares at", "gesticulates at", "madly gestures towards")] [moonbeeMaybe]!</span>")

					if (moonbeeMaybe.alive && prob(75))
						if (!moonbeeMaybe.muted)
							moonbeeMaybe.visible_message("<span class='alert'><b>[moonbeeMaybe]</b> buzzes [pick("grumpily","in a confused manner", "excitedly")] at [src]!</span>")

					return

		if (prob(5)) // adapted chunk of peeker code
			var/list/mobsnearby = list()
			for (var/mob/M in view(7,src))
				mobsnearby.Add("[M.name]")
			var/mob/M1 = null
			if (mobsnearby.len > 0) // somehow this returned a blank list once wtf
				M1 = pick(mobsnearby)
			if (M1 && prob(50)) // do we see anyone
				if (!src.muted)
					src.visible_message("<span class='alert'><b>[src]</b> stares at [M1].</span>")
			else
				var/area/current_loc = get_area(src)
				switch (current_loc.type)
					if (/area/solarium)

						src.set_dir(4)
						if (!src.muted)
							src.visible_message("<span class='alert'><b>[src]</b> stares into the sun.</span>")
					if (/area/station/engine/core)
						if (!admiring_target)
							for (var/obj/machinery/power/generatorTemp/G in range(7, src))
								admiring_target = G
								break
						var/obj/machinery/power/generatorTemp/G = admiring_target
						if (istype(G) && G.lastgenlev >= 26)
							src.set_dir(get_dir(src, G))
							src.visible_message("<span class='alert'><b>[src]</b> [pick("stares","gazes","glares","looks")] [pick("alluringly", "enticingly", "lovingly", "fanatically", "zealously", "warmly", "obediently", "calmly")] at the [G.name].</span>")


	proc/spin()
		if (!src.muted)
			src.visible_message("<span class='alert'><b>[src]</b> [pick("turns", "pivots", "twitches", "spins")].</span>")
		src.set_dir(pick(alldirs))

	proc/inserted_key()
		switch (keycount)
			if (2)
				for (var/mob/M in range(5))
					M.flash(3 SECONDS)
				random_events.force_event("Solar Flare","Solarium Event (2 keys)")
			if (4)
				for (var/mob/M in range(5))
					M.flash(3 SECONDS)
				random_events.force_event("Radiation Storm","Solarium Event (4 keys)")
			if (6)
				for (var/mob/M in range(5))
					M.flash(3 SECONDS)
				random_events.force_event("Solar Flare","Solarium Event (6 keys)")

	attackby(obj/item/W as obj, mob/living/user as mob)
		if (!alive)
			return ..()
		if (aggressive)
			return ..()
		if (istype(W, /obj/item/device/key))
			var/obj/item/device/key/K = W

			if(K.dodgy)
				//Oh, you've done it now.
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a while, then <B>forcefully grabs [user]!</B>.</span>")
				playsound(src.loc, "sound/misc/automaton_scratch.ogg", 60, 1)
				user.changeStatus("stunned", 50)
				user.canmove = 0
				user.anchored = 1
				user.set_loc(src.loc)
				K.burn_possible = 1
				SPAWN_DBG(2 SECONDS)
					src.visible_message("<span class='alert'><B>[src] forces [user] inside one of the keyholes!</B>.</span>")
					user.implode()
					K.combust()
				return

			if (keycount >= AUTOMATON_MAX_KEYS)
				boutput(user, "<span class='alert'><b>[src]</b> ignores you.  Perhaps the time for that has passed?</span>")
				return

			user.visible_message("<span class='alert'>[user] hands [W] to [src]!</span>", "You hand [W] to [src].")

			if (istype(W, /obj/item/device/key/skull) && W.icon_state == "bloodyskull")
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a while, then hands it back.  It doesn't seem to want it in the state it's in.</span>")
				return

			if (istype(W, /obj/item/reagent_containers/food/snacks/pizza) && W.name == "cheese keyzza") // vOv
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a while, then hands it back.</span>")
				return

			if (istype(W, /obj/item/device/key/cheget)) //I don' like yer new-fangled mumbo-jumbo
				user.u_equip(W)
				W.dropped(user)
				W.set_loc(src)
				src.visible_message("<span class='alert'><b>[src]</b> takes \the [W] and studies it intently for a moment.</span>")
				sleep(3 SECONDS)
				if (!got_cheget_key)
					got_cheget_key = 1
					src.visible_message("<span class='alert'><B>[src]</B> clacks angrily and throws \the [W] at [user]!</span>")
					playsound(src.loc, "sound/misc/automaton_scratch.ogg", 60, 1)
					W.set_loc(src.loc)
					W.throw_at(user, 20, 2)
				else
					src.visible_message("<span class='alert'><B>[src]</B> makes a loud ratcheting noise and crumples up \the [W]!</span>")
					playsound(src.loc, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
					var/obj/item/raw_material/scrap_metal/scrapmetal = unpool(/obj/item/raw_material/scrap_metal)
					scrapmetal.set_loc(src.loc)
					qdel(W)
				return

			if (istype(W, /obj/item/device/key/filing_cabinet))
				boutput(user, "<span class='alert'><B>[src]</B> ignores you. This may be related to their lack of circular key holes.")
				return

			if (istype(W, /obj/item/device/key/hospital))
				user.visible_message("<span class='alert'><b>[src]</b> studies [src]'s open hand for a moment, then looks disappointed.</span>", "<span class='alert'><b>[src]</b> studies [W] intently for a moment, then hands it back.  Maybe it's not yet time?</span>")
				return

			//Normal keys below
			if (dd_hasprefix(ckey(W.name), "iridium"))
				if (keycount < (AUTOMATON_MAX_KEYS-1))
					src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, then hands it back.  Maybe it's not yet time?</span>")
				else
					keycount = AUTOMATON_MAX_KEYS
					src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, before secreting it away into a central key hole in its chest.</span>")
					playsound(src.loc, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
					playsound(src.loc, "sound/musical_instruments/Gong_Rumbling.ogg", 60, 1)
					qdel(W)
					sleep(0.5 SECONDS)
					playsound(src.loc, "sound/misc/automaton_scratch.ogg", 60, 1)
					sleep(0.8 SECONDS)
					src.visible_message("<span class='alert'><b>[src]</b> twitches before locking into a pose of contemplation.  Its hand held before it, as if reading from a text.</span>")

			else if (dd_hasprefix(ckey(W.name), "lead"))
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, then hands it back.  Maybe the material is off?</span>")
				return

			else if (dd_hasprefix(ckey(W.name), "solar"))
				keycount = AUTOMATON_MAX_KEYS
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, before secreting it away into a central key hole in its chest.</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
				playsound(src.loc, "sound/musical_instruments/Gong_Rumbling.ogg", 60, 1)
				qdel(W)
				sleep(0.5 SECONDS)
				playsound(src.loc, "sound/misc/automaton_scratch.ogg", 60, 1)
				sleep(0.8 SECONDS)
				src.visible_message("<span class='alert'><b>[src]</b> makes a curious sign in the air. Huh.</span>")

				for (var/mob/M in range(5))
					M.flash(3 SECONDS)

				//var/obj/overlay/the_sun = locate("the_sun")
				//if (istype(the_sun))
				if (the_sun)
					var/obj/Sun = the_sun
					Sun.icon_state = "sun"
					Sun.desc = "Hey, it looks better again!"

				sleep(0.8 SECONDS)
				src.visible_message("<span class='alert'><b>[src]</b> tips over.</span>")
				src.health = 0
				src.CritterDeath() // rip


			else
				keycount = min(keycount+1, AUTOMATON_MAX_KEYS-1)
				src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, before secreting it away into one of many key holes in its chest.</span>")
				playsound(src.loc, "sound/impact_sounds/Generic_Click_1.ogg", 60, 1)
				playsound(src.loc, "sound/musical_instruments/Gong_Rumbling.ogg", 60, 1)
				qdel (W)
				sleep(0.5 SECONDS)
				inserted_key()

				playsound(src.loc, "sound/misc/automaton_scratch.ogg", 60, 1)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/pie/lime) && keycount < AUTOMATON_MAX_KEYS)
			user.visible_message("<span class='alert'>[user] hands [W] to [src]!</span>", "You hand [W] to [src].")

			if (keycount < (AUTOMATON_MAX_KEYS-1) && !pied)
				keycount++
				inserted_key()
				pied = 1

			src.visible_message("<span class='alert'><b>[src]</b> studies [W] intently for a moment, before secreting it away into a pie-shaped hole in its chest. How did you not notice that before?</span>")
			playsound(src.loc, "sound/musical_instruments/Gong_Rumbling.ogg", 50, 1)
			qdel (W)

		else if (istype(W, /obj/item/skull))
			if (keycount != AUTOMATON_MAX_KEYS)
				user.visible_message("<span class='alert'><b>[src]</b> ignores [user].  Perhaps it's not time for that?</span>",\
				"<span class='alert'><b>[src]</b> ignores you.  Perhaps it's not time for that?</span>")
				return

			if (!istype(W, /obj/item/skull/crystal) || W.icon_state != "skull_crystal")
				src.visible_message("<span class='alert'><b>[src]</b> holds [W] out for a moment, staring into its empty face, then hands it back </span>")
				return

			src.visible_message("<span class='alert'><b>[src]</b> holds [W] out, staring into its empty eye sockets.<br>Alas, poor Yorick?</span>")
			qdel(W)
			//todo: good ending???? egg ending????

		else if (istype(W, /obj/item/iomoon_key))
			user.visible_message("<span class='alert'><b>[src]</b> totally ignores [user]. Maybe this is the wrong puzzle for [W] or something, sheesh.</span>",\
			"<span class='alert'>Okay, no. Good thought, but this is totally the wrong puzzle for that.</span>")

		else if (istype(W, /obj/item/alchemy/stone))
			src.visible_message("<span class='alert'>[src] studies [W] intently. It looks impressed, but hands [W] back. Perhaps it's not the right time for this yet?</span>")

		#ifdef SECRETS_ENABLED
		else if (istype(W, /obj/item/onyxphoto))
			if (!W:used)
				src.visible_message("<span class='notice'><b>[src]</b> studies [W] intently, then hands it back after a short pause.</span>")

				W:used = 1
				W.name = "empty photo"
				W.desc = "The key seems to be gone from the photo."
				if (keycount < (AUTOMATON_MAX_KEYS-1))
					keycount++
					inserted_key()
					playsound(src.loc, "sound/musical_instruments/Gong_Rumbling.ogg", 60, 1)
			else
				boutput(user, "<span class='alert'>[src] no longer seems interested in [W].</span>")
		#endif

		else if (istype(W, /obj/item/space_thing)) // if I'm gunna make a weird widget it may as well have some interaction with the automaton
			var/obj/item/space_thing/ST = W
			if (ST.icon_state == "thing")
				src.visible_message("<span class='alert'>[src] studies [ST] for a moment. It rotates it, and then hands it back.</span>")
				ST.icon_state = "thing2"
				//var/obj/overlay/the_sun = locate("the_sun")
				//if (istype(the_sun))
				if (the_sun)
					if (!src.spin_lock)
						src.spin_lock = pick("L", "R")
						DEBUG_MESSAGE("<B>HAINE DEBUG:</b> spin set to [src.spin_lock]")
					var/final_spin = 1000 - min(src.sun_spin, 999)
					DEBUG_MESSAGE("<B>HAINE DEBUG:</b> final spin set to [final_spin]")
					animate_spin(the_sun, src.spin_lock, final_spin, -1)
					if (src.sun_spin >= 990)
						src.sun_spin += 1
						DEBUG_MESSAGE("<B>HAINE DEBUG:</b> spin now [src.sun_spin]")
					else if (src.sun_spin >= 900)
						src.sun_spin += 10
						DEBUG_MESSAGE("<B>HAINE DEBUG:</b> spin now [src.sun_spin]")
					else
						src.sun_spin += 100
						DEBUG_MESSAGE("<B>HAINE DEBUG:</b> spin now [src.sun_spin]")
			else
				user.visible_message("<span class='alert'>[src] studies [ST] for a moment. It hands it back.</span>")

		else if (istype(W, /obj/item/book_kinginyellow))
			if (keycount < AUTOMATON_MAX_KEYS || derelict_mode)
				user.visible_message("<span class='alert'><b>[src]</b> ignores [user]'s attempts to hand over the book, even if \he waves it right in its face and get all obnoxious about it.  Maybe this isn't the right time?</span>",\
				"<span class='alert'><b>[src]</b> ignores your attempts to hand over the book, even if you wave it right in its face and get all obnoxious about it.  Maybe this isn't the right time?</span>")
				return

			user.visible_message("<span class='alert'>[user] hands [W] to [src]!</span>", "You hand [W] to [src].")
			src.visible_message("<span class='alert'><b>[src]</b> appears to read from [W].</span>")
			user.drop_item()
			W.set_loc(src)
			sleep(1 SECOND)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_3.ogg', 50, 1)
			src.visible_message("<span class='alert'><b>[src] frantically tears [W] to pieces! What!</b></span>")
			if (narrator_mode)
				playsound(src.loc, 'sound/vox/ghost.ogg', 60, 1)
			else
				playsound(src.loc, 'sound/effects/ghost.ogg', 60, 1)
			SPAWN_DBG(0)
				var/i = rand(4,8)
				while (i-- > 0)
					var/obj/item/paper/tornpaper = unpool(/obj/item/paper)
					tornpaper.set_loc(src.loc)

					tornpaper.name = "torn page"
					tornpaper.info = "A page torn from a book.  Most of the text is illegible."
					sleep(0.3 SECONDS)
					tornpaper.combust()
				keycount = INFINITY
				world << sound('sound/musical_instruments/Gong_Rumbling.ogg')
				//var/obj/overlay/the_sun = locate("the_sun")
				//if (istype(the_sun))
				if (the_sun)
					var/obj/Sun = the_sun
					Sun.icon_state = "sun_ripple"
					Sun.desc = "Uhhh...."

			if (W)
				for (var/mob/living/carbon/C in hearers(src.seekrange,src))
					W:readers += C

			if (saw_moon_bee == 1)
				ending_event()

		else
			return ..()

	proc/ending_event()
		if (saw_moon_bee == 2)
			return

		saw_moon_bee = 2
		var/turf/target_turf = locate(src.x - 1, src.y, src.z)
		var/obj/decal/teleport_swirl/swirl = unpool(/obj/decal/teleport_swirl)
		swirl.set_loc(target_turf)
		swirl.pixel_y = 10
		playsound(target_turf, "sound/effects/teleport.ogg", 50, 1)
		SPAWN_DBG(1.5 SECONDS)
			swirl.pixel_y = 0
			pool(swirl)

		src.visible_message("<span class='alert'>[src.name] seems to tense up and freeze.</span>")
		playsound(src.loc, "sound/machines/glitch1.ogg", 50, 1)
		alive = 0

		it_is_okay_to_do_the_endgame_thing = 1
		if(!src.vacation)
			new /obj/the_server_ingame_whoa(target_turf)
		else
			new /obj/item/sticker/gold_star(target_turf)
			src.visible_message("<span class='alert'>[src.name] looks very annoyed. It just wanted to relax!</span>")
/*
	proc/ending_death()

		world << sound('sound/effects/dramatic.ogg')
		world << sound('sound/misc/automaton_tickhum.ogg')
		spin()
		random_events.force_event("Solar Flare","Solarium Event (DEATH)")

		src.visible_message("<span class='alert'>[src.name] staggers!</span>")
		playsound(src.loc, "sound/machines/glitch1.ogg", 50, 1)
		spin()

		var/range = 7


		var/temp_effect_limiter = 7
		for (var/turf/T in view(range, src))
			var/T_dist = get_dist(T, src)
			var/T_effect_prob = 100 * (1 - (max(T_dist-1,1) / range))
			if (prob(8) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = unpool(/obj/effects/sparks)
				sparks.set_loc(T)
				SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)

			for (var/obj/item/I in T)
				if ( prob(T_effect_prob) )
					animate_float(I, 5, 10)
			if (prob(T_effect_prob))
				SPAWN_DBG(rand(30, 50))
					if (T)
						playsound(T, pick('sound/effects/elec_bigzap.ogg', 'sound/effects/elec_bzzz.ogg', 'sound/effects/electric_shock.ogg'), 40, 0)
						var/obj/somesparks = unpool(/obj/effects/sparks)
						somesparks.set_loc(T)
						SPAWN_DBG(2 SECONDS) if (somesparks) pool(somesparks)
						var/list/tempEffect
						if (temp_effect_limiter-- > 0)
							tempEffect = DrawLine(src, somesparks, /obj/line_obj/elec, 'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",FLY_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')
						sleep(0.6 SECONDS)
						for (var/obj/O in tempEffect)
							pool(O)
		world << sound('sound/misc/automaton_scratch.ogg')
		sleep (10)
		world << sound('sound/ambience/spooky/Void_Screaming.ogg')
		spin()
		sleep (10)
		world << sound('sound/ambience/spooky/Void_Wail.ogg')
		world << sound('sound/effects/thunder.ogg')
		boutput(world, "<span class='alert'><tt><b>Something feels terribly, terribly wrong.</b></tt></span>")
		sleep (10)
		spin()

		for(var/mob/living/carbon/human/H in mobs)
			animate_float(H, 5, 10)
			SPAWN_DBG(1 SECOND)
				H.flash(3 SECONDS)
				shake_camera(H, 210, 2)
			SPAWN_DBG(rand(10,70))
				H.emote("scream")
		var/turf/T = get_turf(src)
		sleep(0.1 SECONDS)
		new /obj/effects/void_break(T)
		src.visible_message("<span class='alert'><b>[src]</b> shatters! Oh shit!</span>")
		new /obj/effects/shockwave(T)
		new /obj/effects/exposion/smoky(T)
		src.health = 0
		src.CritterDeath()
		sleep(0.2 SECONDS)
		qdel(src)
		*/




#undef AUTOMATON_MAX_KEYS

	alohamaton
		icon_state = "alohamaton"
		vacation = 1

/obj/item/paper/postcard
	name = "postcard"
	info = "<font face='Comic Sans MS' color='#F75AA4' size=5><b>Wish you were here!</b></font>"
	icon_state = "postcard"
