
/* ===================================================== */
/* -------------------- Instruments -------------------- */
/* ===================================================== */

/obj/item/instrument
	name = "instrument"
	desc = "It makes noise!"
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bike_horn"
	inhand_image_icon = 'icons/mob/inhand/hand_instruments.dmi'
	item_state = "bike_horn"
	w_class = 3
	p_class = 1
	force = 2
	throw_speed = 3
	throw_range = 15
	throwforce = 5
	stamina_damage = 10
	stamina_cost = 10
	stamina_crit_chance = 5
	var/spam_flag = 0
	var/spam_timer = 100
	var/list/sounds_instrument = list('sound/musical_instruments/Bikehorn_1.ogg')
	var/desc_verb = list("plays", "lays down")
	var/desc_sound = list("funny", "rockin'", "great", "impressive", "terrible", "awkward")
	var/desc_music = list("riff", "jam", "bar", "tune")
	var/volume = 50
	var/randomized_pitch = 1
	var/dog_bark = 1
	var/affect_fun = 5
	module_research = list("audio" = 7)

	proc/play(mob/user as mob)
		if (!spam_flag)
			spam_flag = 1
			src.add_fingerprint(user)
			if (src.affect_fun && ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.sims)
					H.sims.affectMotive("fun", src.affect_fun)
			show_play_message(user)
			playsound(get_turf(src), islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument, src.volume, src.randomized_pitch)
			if (src.dog_bark)
				for (var/obj/critter/dog/george/G in by_type[/obj/critter/dog/george])
					if (DIST_CHECK(G, user, 6) && prob(60))
						G.howl()
			src.post_play_effect(user)
			SPAWN_DBG(src.spam_timer)
				spam_flag = 0
		return

	proc/show_play_message(mob/user as mob)
		if (user) return user.visible_message("<B>[user]</B> [islist(src.desc_verb) ? pick(src.desc_verb) : src.desc_verb] \a [islist(src.desc_sound) ? pick(src.desc_sound) : src.desc_sound] [islist(src.desc_music) ? pick(src.desc_music) : src.desc_music] on [his_or_her(user)] [src.name]!")

	proc/post_play_effect(mob/user as mob)
		return

	attack_self(mob/user as mob)
		..()
		src.play(user)

/* -------------------- Large Instruments -------------------- */

/obj/item/instrument/large
	w_class = 6
	p_class = 2 // if they're anchored you can't move them anyway so this should default to making them easy to move
	throwforce = 40
	density = 1
	anchored = 1
	desc_verb = list("plays", "performs", "composes", "arranges")
	desc_sound = list("nice", "classic", "classical", "great", "impressive", "terrible", "awkward", "striking", "grand", "majestic")
	desc_music = list("melody", "aria", "ballad", "chorus", "concerto", "fugue", "tune")
	volume = 100
	spam_timer = 200
	affect_fun = 15 // a little higher, why not?
	module_research = list("audio" = 14) // I don't think this is even relevant without being able to pick up the thing and also the research thing isn't even enabled atm but well. why not?

	attack_hand(mob/user as mob)
		src.play(user)

	show_play_message(mob/user as mob)
		if (user) return src.visible_message("<B>[user]</B> [islist(src.desc_verb) ? pick(src.desc_verb) : src.desc_verb] \a [islist(src.desc_sound) ? pick(src.desc_sound) : src.desc_sound] [islist(src.desc_music) ? pick(src.desc_music) : src.desc_music] on [src]!")

	attackby(obj/item/W as obj, mob/user as mob)
		if (istool(W, TOOL_SCREWING | TOOL_WRENCHING))
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the castors of [src].")
			playsound(get_turf(src), "sound/items/Screwdriver.ogg", 100, 1)
			src.anchored = !(src.anchored)
			return
		else
			return ..()

	get_desc() // so it doesn't show up as an item on examining it
		return

/* -------------------- Piano -------------------- */

/obj/item/instrument/large/piano
	name = "piano"
	desc = "Not very grand, is it?"
	icon_state = "piano"
	item_state = "piano"
	sounds_instrument = list('sound/musical_instruments/piano/furelise.ogg',
	'sound/musical_instruments/piano/gymno.ogg',
	'sound/musical_instruments/piano/lune.ogg',
	'sound/musical_instruments/piano/nachtmusik1.ogg',
	'sound/musical_instruments/piano/nachtmusik2.ogg')

/* -------------------- Grand Piano -------------------- */

/obj/item/instrument/large/piano/grand
	name = "grand piano"
	desc = "This piano is very...<br>Fancy!"
	icon_state = "gpiano"

/* -------------------- Organ -------------------- */

/obj/item/instrument/large/organ
	name = "reed organ"
	desc = "Mask, cloak and brooding nature not included."
	icon_state = "organ"
	item_state = "organ"
	desc_sound = list("nice", "classic", "classical", "great", "impressive", "terrible", "awkward", "striking", "grand", "majestic", "baroque", "gothic", "rumbling", "chilling")
	sounds_instrument = list('sound/musical_instruments/organ/bach1.ogg',
	'sound/musical_instruments/organ/bach2.ogg',
	'sound/musical_instruments/organ/bridal1.ogg',
	'sound/musical_instruments/organ/funeral.ogg')

/* -------------------- Jukebox -------------------- */

/obj/item/instrument/large/jukebox
	name = "old jukebox"
	desc = "I wonder who fixed this thing?"
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "jukebox"
	item_state = "jukebox"
	sounds_instrument = list('sound/musical_instruments/jukebox/neosoul.ogg',
	'sound/musical_instruments/jukebox/vintage.ogg',
	'sound/musical_instruments/jukebox/ultralounge.ogg',
	'sound/musical_instruments/jukebox/jazzpiano.ogg')

	show_play_message(mob/user as mob)
		return

/* -------------------- Saxophone -------------------- */

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "NEVER GONNA DANCE AGAIN, GUILTY FEET HAVE GOT NO RHYTHM"
	icon_state = "sax"
	item_state = "sax"
	sounds_instrument = list('sound/musical_instruments/Saxophone_CarelessWhisper.ogg', 'sound/musical_instruments/Saxophone_RunAway.ogg', 'sound/musical_instruments/Saxophone_BakerStreet.ogg', 'sound/musical_instruments/Saxophone_ComeSunday.ogg', 'sound/musical_instruments/Saxophone_GodOnlyKnows.ogg')
	desc_sound = list("sexy", "sensuous", "libidinous","spicy", "flirtatious", "salacious","sizzling", "carnal", "hedonistic")
	module_research = list("audio" = 7, "metals" = 3)

	New()
		..()
		BLOCK_ROD

/obj/item/instrument/saxophone/attack(mob/M as mob, mob/user as mob)
	playsound(get_turf(src), pick('sound/impact_sounds/Generic_Punch_2.ogg','sound/impact_sounds/Generic_Punch_2.ogg','sound/impact_sounds/Generic_Punch_3.ogg','sound/impact_sounds/Generic_Punch_4.ogg'), 50, 1, -1)
	playsound(get_turf(src), pick('sound/musical_instruments/saxbonk.ogg', 'sound/musical_instruments/saxbonk2.ogg', 'sound/musical_instruments/saxbonk3.ogg'), 50, 1, -1)
	user.visible_message("<span class='alert'><b>[user] bonks [M] with [src]!</b></span>")

/* -------------------- Bagpipe -------------------- */

/obj/item/instrument/bagpipe
	name = "bagpipe"
	desc = "Almost as much of a windbag as the Captain."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "bagpipe"
	item_state = "bagpipe"
	sounds_instrument = list('sound/musical_instruments/Bagpipes_1.ogg', 'sound/musical_instruments/Bagpipes_2.ogg','sound/musical_instruments/Bagpipes_3.ogg')
	desc_sound = list("patriotic", "rowdy", "wee", "grand", "free", "Glaswegian", "sizzling", "carnal", "hedonistic")
	module_research = list("audio" = 7, "metals" = 3)

	New()
		..()
		BLOCK_BOOK

/* -------------------- Bike Horn -------------------- */

/obj/item/instrument/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	w_class = 1
	throwforce = 3
	stamina_damage = 5
	stamina_cost = 5
	sounds_instrument = list('sound/musical_instruments/Bikehorn_1.ogg')
	desc_verb = list("honks")
	spam_timer = 8
	module_research = list("audio" = 8)

	show_play_message(mob/user as mob)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!istype(W, /obj/item/parts/robot_parts/arm))
			..()
			return
		else
			var/obj/machinery/bot/duckbot/D = new /obj/machinery/bot/duckbot
			D.eggs = rand(2,5) // LAY EGG IS TRUE!!!
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			D.set_loc(get_turf(user))
			qdel(W)
			qdel(src)

	is_detonator_attachment()
		return 1

	detonator_act(event, var/obj/item/assembly/detonator/det)
		var/sound_to_play = islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument
		switch (event)
			if ("pulse")
				playsound(det.attachedTo.loc, sound_to_play, src.volume, src.randomized_pitch)
			if ("cut")
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>The honking stops.</span>")
				det.attachments.Remove(src)
			if ("process")
				var/times = rand(1,5)
				for (var/i = 1, i <= times, i++)
					SPAWN_DBG(4*i)
						playsound(det.attachedTo.loc, sound_to_play, src.volume, src.randomized_pitch)
			if ("prime")
				for (var/i = 1, i < 15, i++)
					SPAWN_DBG(3*i)
						playsound(det.attachedTo.loc, sound_to_play, min(src.volume*10, 750), src.randomized_pitch)

/* -------------------- Dramatic Bike Horn -------------------- */

/obj/item/instrument/bikehorn/dramatic
	name = "dramatic bike horn"
	desc = "SHIT FUCKING PISS COCK IT'S SO RAW"
	sounds_instrument = list('sound/effects/dramatic.ogg')
	volume = 100
	randomized_pitch = 0
	spam_timer = 30
	mats = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if (!istype(W, /obj/item/parts/robot_parts/arm))
			..()
			return
		else
			var/obj/machinery/bot/chefbot/D = new /obj/machinery/bot/chefbot
			boutput(user, "<span class='notice'>You add [W] to [src].</span>")
			D.set_loc(get_turf(user))
			qdel(W)
			qdel(src)

/* -------------------- Air Horn -------------------- */

/obj/item/instrument/bikehorn/airhorn
	name = "air horn"
	desc = "It's time to drop the bass or announce the next song or just annoy the shit out of someone. Maybe all three."
	icon_state = "airhorn"
	item_state = "airhorn"
	sounds_instrument = list('sound/musical_instruments/Airhorn_1.ogg')
	volume = 100
	spam_timer = 10

/* -------------------- Harmonica -------------------- */

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "A cheap pocket instrument, good for helping time to pass."
	icon_state = "harmonica"
	item_state = "r_shoes"
	w_class = 1
	force = 1
	throwforce = 3
	stamina_damage = 2
	stamina_cost = 2
	spam_timer = 20
	sounds_instrument = list('sound/musical_instruments/Harmonica_1.ogg', 'sound/musical_instruments/Harmonica_2.ogg', 'sound/musical_instruments/Harmonica_3.ogg')
	desc_sound = list("delightful", "chilling", "upbeat")

/* -------------------- Whistle -------------------- */

/obj/item/instrument/whistle
	name = "whistle"
	desc = "A whistle. Good for getting attention."
	icon_state = "whistle"
	item_state = "r_shoes"
	w_class = 1
	force = 1
	throwforce = 3
	stamina_damage = 2
	stamina_cost = 2
	spam_timer = 20
	sounds_instrument = list('sound/musical_instruments/Whistle_Police.ogg')
	volume = 35

	show_play_message(mob/user as mob)
		if (user) return user.visible_message("<span style='color:red;font-weight:bold;font-size:120%'>[user] blows [src]!</span>")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span style='color:red;font-weight:bold'>[user] swallows [src] and [he_or_she(user)] begins to choke, [src] sounding shrilly!</span>")
		user.take_oxygen_deprivation(155)
		user.updatehealth()

		user.u_equip(src) // leaves it in the mob's contents, but takes it out of their hands and off their hud. makes it kinda like swallowing the whistle, it'll still be in them if they gib  :)
		playsound(get_turf(user), islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument, src.volume, src.randomized_pitch)
		for (var/i=5, i>0, i--)
			if (!user)
				break
			if (prob(75))
				playsound(get_turf(user), islist(src.sounds_instrument) ? pick(src.sounds_instrument) : src.sounds_instrument, src.volume, src.randomized_pitch)
			if (i<=1)
				user.suiciding = 0
			else
				sleep(5 SECONDS)
		return 1

/* -------------------- Vuvuzela -------------------- */

/obj/item/instrument/vuvuzela
	name = "vuvuzela"
	desc = "A loud horn made popular at soccer games-BZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
	icon_state = "vuvuzela"
	item_state = "vuvuzela"
	throwforce = 3
	stamina_damage = 6
	stamina_cost = 6
	sounds_instrument = list('sound/musical_instruments/Vuvuzela_1.ogg')
	volume = 80

	show_play_message(mob/user as mob)
		..()
		if (user)
			for (var/mob/M in hearers(user, null))
				if (M.ears_protected_from_sound())
					continue
				var/ED = max(0, rand(0, 2) - get_dist(user, M))
				M.take_ear_damage(ED)
				boutput(M, "<font size=[max(0, ED)] color='red'>BZZZZZZZZZZZZZZZZZZZ!</font>")
		return

	is_detonator_attachment()
		return 1

	detonator_act(event, var/obj/item/assembly/detonator/det)
		switch (event)
			if ("pulse")
				playsound(det.attachedTo.loc, "sound/musical_instruments/Vuvuzela_1.ogg", 50, 1)
			if ("cut")
				det.attachedTo.visible_message("<span class='bold' style='color:#B7410E'>The buzzing stops.</span>")
				det.attachments.Remove(src)
			if ("process")
				if (prob(45))
					var/times = rand(1,5)
					for (var/i = 1, i <= times, i++)
						SPAWN_DBG(4*i)
							playsound(det.attachedTo.loc, "sound/musical_instruments/Vuvuzela_1.ogg", 50, 1)
			if ("prime")
				for (var/i = 1, i < 15, i++)
					SPAWN_DBG(4*i)
						playsound(det.attachedTo.loc, "sound/musical_instruments/Vuvuzela_1.ogg", 500, 1)

/* -------------------- Trumpet -------------------- */

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = "There can be only one first chair."
	icon = 'icons/obj/instruments.dmi'
	icon_state = "trumpet"
	item_state = "trumpet"
	sounds_instrument = list('sound/musical_instruments/Trumpet_1.ogg', 'sound/musical_instruments/Trumpet_2.ogg', 'sound/musical_instruments/Trumpet_3.ogg', 'sound/musical_instruments/Trumpet_4.ogg', 'sound/musical_instruments/Trumpet_5.ogg', 'sound/musical_instruments/Bikehorn_2.ogg')
	desc_sound = list("slick", "egotistical", "snazzy", "technical", "impressive")
	module_research = list("audio" = 7, "metals" = 3)

/* -------------------- Spooky Trumpet -------------------- */

/obj/item/instrument/trumpet/dootdoot
	name = "spooky trumpet"
	desc= "Talk dooty to me."
	icon_state = "doot"
	item_state = "doot"
	sounds_instrument = list('sound/musical_instruments/Bikehorn_2.ogg')
	desc_verb = "doots"
	desc_sound = list("spooky", "scary", "boney", "creepy", "squawking", "squeaky", "low-quality", "compressed")
	affect_fun = 200 //because come on this shit's hilarious

	play(mob/user as mob)
		if (spam_flag)
			boutput(user, "<span class='alert'>\The [src] needs time to recharge its spooky strength!</span>")
			return
		else
			..()

	post_play_effect(mob/user as mob)
		var/turf/T = get_turf(src)
		if (!T)
			return
		for (var/mob/living/carbon/human/H in viewers(T, null))
			if (user && H == user)
				continue
			else
				src.dootize(H)

	proc/dootize(var/mob/living/carbon/human/S as mob)
		if (!istype(S))
			return
		if (S.mob_flags & IS_BONER)
			S.visible_message("<span class='notice'><b>[S.name]</b> claks in appreciation!</span>")
			playsound(S.loc, "sound/items/Scissor.ogg", 50, 0)
			return
		else
			S.visible_message("<span class='alert'><b>[S.name]'s skeleton rips itself free upon hearing the song of its people!</b></span>")
			playsound(get_turf(S), S.gender == "female" ? "sound/voice/screams/female_scream.ogg" : "sound/voice/screams/male_scream.ogg", 50, 0, 0, S.get_age_pitch())
			playsound(get_turf(S), "sound/effects/bubbles.ogg", 50, 0)
			playsound(get_turf(S), "sound/impact_sounds/Flesh_Tear_2.ogg", 50, 0)
			var/bdna = null // For forensics (Convair880).
			var/btype = null
			if (S.bioHolder.Uid && S.bioHolder.bloodType)
				bdna = S.bioHolder.Uid
				btype = S.bioHolder.bloodType
			gibs(S.loc, null, null, bdna, btype)

			S.set_mutantrace(/datum/mutantrace/skeleton)
			S.real_name = "[S.name]'s skeleton"
			S.name = S.real_name
			S.update_body()
			S.UpdateName()
			return

/* -------------------- Fiddle -------------------- */

/obj/item/instrument/fiddle
	name = "fiddle"
	icon_state = "fiddle"
	item_state = "fiddle"
	sounds_instrument = list('sound/musical_instruments/Fiddle_1.ogg', 'sound/musical_instruments/Fiddle_2.ogg', 'sound/musical_instruments/Fiddle_3.ogg', 'sound/musical_instruments/Fiddle_4.ogg', 'sound/musical_instruments/Fiddle_5.ogg')
	desc_sound = list("slick", "egotistical", "snazzy", "technical", "impressive") // works just as well for fiddles as it does for trumpets I guess  :v

/obj/item/instrument/fiddle/satanic
	desc_sound = list("devilish", "hellish", "satanic", "enviable", "sinful", "grumpy", "lazy", "lustful", "greedy")
	affect_fun = 20
	var/charge = 0 //A certain level of UNHOLY ENERGY is required to knock out a soul, ok.
	var/charge_required = 10

	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)
		playsound(get_turf(src), "swing_hit", 50, 1, -1)
		..()
		satanic_home_run(M, user)

	post_play_effect(mob/user as mob)
		src.charge++
		if (src.charge >= charge_required)
			icon_state = "fiddle-unholy"
		return

	proc/satanic_home_run(var/mob/living/some_poor_fucker, var/mob/user)
		if (!istype(some_poor_fucker) || !some_poor_fucker.mind || charge < src.charge_required || !user)
			return

		charge = 0
		src.icon_state = "fiddle"
		var/turf/T = get_edge_target_turf(user, get_dir(user, some_poor_fucker))
		var/mob/dead/observer/ghost_to_toss = some_poor_fucker.ghostize()
		var/obj/item/reagent_containers/food/snacks/ectoplasm/soul_stuff = new (some_poor_fucker.loc)

		if (istype(ghost_to_toss))
			ghost_to_toss.loc = soul_stuff

		soul_stuff.throw_at(T, 10, 1)
		SPAWN_DBG (10)
			if (soul_stuff && ghost_to_toss)
				ghost_to_toss.loc = soul_stuff.loc

		some_poor_fucker.throw_at(T, 1, 1)
		some_poor_fucker.changeStatus("weakened", 2 SECONDS)
