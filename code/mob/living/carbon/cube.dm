// cube refactoring courtesy of cirrial
// all blames acknowledged 2017

/mob/living/carbon/cube
	name = "cube"
	real_name = "cube"
	say_language = "cubic" // How they communicate to each other is a mystery.
	desc = "cubic"
	icon = 'icons/mob/mob.dmi'
	icon_state = "meatcube"
	a_intent = "disarm" // just so they don't swap with help intent users
	health = INFINITY
	anchored = ANCHORED
	density = 1
	nodamage = 1
	opacity = 0
	var/life_timer = 10
	sound_scream = 'sound/voice/screams/male_scream.ogg'
	use_stamina = 0

	examine(mob/user)
		. = list("<span class='notice'>*---------*</span>")
		. += "<span class='notice'>This is a [bicon(src)] <B>[src.name]</B>!</span>"
		if(prob(50) && ishuman(user) && user.bioHolder.HasEffect("clumsy"))
			. += "<span class='alert'>You can't help but laugh at it.</span>"
			user.emote("laugh")
		else
			. += "<span class='alert'>It looks [pick("kinda", "really", "sorta", "a bit", "slightly")] [desc].</span>"
		. += "<span class='notice'>*---------*</span>" // the fact this was missing bugged me - cirr

	say_understands(var/other)
		if (ishuman(other) || isrobot(other) || isAI(other))
			return 1
		return ..()

	attack_hand(mob/user)
		boutput(user, "<span class='notice'>You push the [src.name] but nothing happens!</span>")
		playsound(src.loc, 'sound/impact_sounds/Flesh_Crush_1.ogg', 40, 1)
		src.add_fingerprint(user)
		return

	ex_act(severity)
		..() // Logs.
		switch(severity)
			if(1)
				src.gib(1)
				return
			if(2)
				if (prob(25))
					src.gib(1)
		return

	proc/get_cube_idle()
		return "cubes cubily"

	proc/get_cube_action()
		return "cubes"

	proc/pop()
		src.gib(1)

	say_verb()
		return src.get_cube_action()

	proc/specific_emotes(var/act, var/param = null, var/voluntary = 0)
		return null

	proc/specific_emote_type(var/act)
		return 1

	emote(var/act, var/voluntary = 1)
		..()
		var/param = null

		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/message = specific_emotes(act, param, voluntary)
		var/m_type = specific_emote_type(act)
		if (!message)
			switch (lowertext(act))
				if("dance")
					if(src.emote_check(voluntary, 10))
						message = "<B>[src]</B> twitches to some kind of rhythm. At least, you think so. Those things are always twitching."
				if("fart")
					if (farting_allowed && src.emote_check(voluntary, 50))
						var/fart_on_other = 0
						for (var/mob/living/M in src.loc)
							if (M == src || !M.lying) continue
							message = "<span class='alert'><B>[src]</B> jumps and farts all over [M]! That's disgusting!</span>"
							fart_on_other = 1
							if(prob(20))
								message = "<span class='alert'>[M] vomits!</span>"
								M.vomit()
							break
						if(!fart_on_other)
							switch (rand(1, 10))
								if (1) message = "<B>[src]</B> releases some kind of gas into the air."
								if (2) message = "<B>[src]</B> farts! How can meat cubes do that?"
								if (3) message = "<B>[src]</B> shoots out a butt of death."
								if (4) message = "<B>[src]</B> squeezes itself inward and farts."
								if (5) message = "<B>[src]</B> hops up and down, farting all the while."
								if (6) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
								if (7) message = "<B>[src]</B> gets revenge on humanity with a terrible fart."
								if (8) message = "<B>[src]</B> stinks even worse than normal, somehow."
								if (9) message = "<B>[src]</B> shows that it can fart just as good as any human."
								if (10)
									message = "<B>[src]</B> farts blood and guts out of one of its sides! That's absolutely disgusting!"
									var/obj/decal/cleanable/blood/gibs/gib = null
									gib = make_cleanable(/obj/decal/cleanable/blood/gibs,src.loc)
									gib.streak_cleanable()
						playsound(src.loc, 'sound/vox/fart.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						src.remove_stamina(STAMINA_DEFAULT_FART_COST)
						src.stamina_stun()
				if ("flex","flexmuscles")
					if(src.emote_check(voluntary, 10))
						message = "<B>[src]</B>'s center compresses slightly more than the rest of its jiggling mass. Are those... muscles?"
				if ("flip")
					if(src.emote_check(voluntary, 50))
						if (istype(src.loc,/obj/))
							var/obj/container = src.loc
							boutput(src, "<span class='alert'>You leap and slam yourself against the inside of [container]! Ouch!</span>")
							src.changeStatus("paralysis", 4 SECONDS)
							src.changeStatus("weakened", 3 SECONDS)
							container.visible_message("<span class='alert'><b>[container]</b> emits a loud thump and rattles a bit.</span>")
							playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
							animate_shake(container)
							if (prob(33))
								if (istype(container, /obj/storage))
									var/obj/storage/C = container
									if (C.can_flip_bust == 1)
										boutput(src, "<span class='alert'>[C] [pick("cracks","bends","shakes","groans")].</span>")
										C.bust_out()
						else
							message = "<B>[src]</b> squishes down, pops up, and does a flip! Gross!"
							animate_spin(src, "R", 1, 0)
				if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
					// basic visible single-word emotes
					if(src.emote_check(voluntary, 10))
						message = "<B>[src]</B> jiggles like only a meat cube can."
				else
					if (voluntary) src.show_text("Invalid Emote: [act]")
		if (message && isalive(src))
			logTheThing(LOG_SAY, src, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/O in viewers(src, null))
					O.show_message(message, m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src, null))
					O.show_message(message, m_type)
			else if (!isturf(src.loc))
				var/atom/A = src.loc
				for (var/mob/O in A.contents)
					O.show_message(message, m_type)

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
			pop()
		else
			..()


	meat
		name = "meat cube"
		real_name = "meat cube"
		desc = "disturbing"
		icon_state = "meatcube-squish"


		New() // rather than doing this every single time the scream is needed, let's just pick it once and be done with it
			..()
			if(src.gender == MALE)
				sound_scream = 'sound/voice/screams/male_scream.ogg'
			else
				sound_scream = 'sound/voice/screams/female_scream.ogg'

		get_cube_idle()
			return "[pick("quivers","pulsates","squirms","flollops","shudders","twitches","willomies")] [pick("sadly","disgustingly","horrifically","unpleasantly","disturbingly","worryingly","pathetically","floopily")]"

		get_cube_action()
			return pick("gurgles","shivers","twitches","shakes","squirms", "cries")

		pop()
			for (var/i = 3, i > 0, i--)
				var/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat(src.loc)
				meat.name = "cube steak"
				meat.desc = "Grody."
			playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
			src.visible_message("<span class='alert'><b>The meat cube pops!</b></span>")
			..()


		krampus
			name = "Krampus 3.0" // 2.0 was the unpoppable meat cube, 3.0 is now a poppable meat cube
			desc = "horrible"
			life_timer = INFINITY
			icon_state = "krampus2-squish"

			New()
				..()
				real_name = pick("Krampus", "Krampus 3.0", "The Krampmeister", "The Krampster") //For deadchat
				SPAWN(2 SECONDS) //I do not know where the hell you get a bioholder from =I
					if(src.bioHolder) src.bioHolder.age = 110

			// people were somehow being shit even as a meatcube, so i'm removing the small mercy they had with being unpoppable - cirr

			// attackby(obj/item/W, mob/user)
			// 	user.visible_message("<span class='combat'><B>[user] pokes [src] with \the [W]!</B></span>") //No weldergibs. Krampus is truly a fiend.

			telekinetic //this one has the wraith click-drag to throw item ability
				name = "Krampus 3.1 III Turbo Edition: Alpha Strike"
				desc = "abominably godawful"

	metal
		name = "metal cube"
		real_name = "metal cube"
		desc = "unfortunate"
		icon_state = "metalcube-squish"
		sound_scream = 'sound/voice/screams/Robot_Scream_2.ogg'
		custom_gib_handler = /proc/robogibs

		get_cube_idle()
			return "[pick("rattles","ratchets","clanks","shakes","whirrs","judders","clicks","clonks","lumps","clatters","crashes")] [pick("sadly","jerkily","uncannily","awfully","painfully","concerningly","pathetically","weakly","plaintively","regretfully")]"

		get_cube_action()
			return pick("ratchets","judders","vibrates","clanks","whirrs","creaks","whines")

		pop()
			for (var/i = 3, i > 0, i--)
				var/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/M = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/(src.loc)
				M.cybermeat = 1
				M.name = "meatal"
				M.desc = "Raw, twitching silicon based muscle. Eww."
				M.icon_state = "cybermeat"
				if (prob(50))
					M.reagents.add_reagent("nanites", 5)
			playsound(src.loc, 'sound/machines/engine_grump2.ogg', 75, 1)
			src.visible_message("<span class='alert'><b>The metal cube violently falls apart!</b></span>")
			..()

		attackby(obj/item/W, mob/user)
			if (iswrenchingtool(W))
				pop()
			else
				..()

		specific_emotes(var/act, var/param = null, var/voluntary = 0)
			switch (act)
				if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
					// basic visible single-word emotes
					if(src.emote_check(voluntary, 10))
						return "<B>[src]</B> rattles like only a metal cube can."
				if("fart")
					if (farting_allowed && src.emote_check(voluntary, 50))
						var/message = ""
						var/fart_on_other = 0
						for (var/mob/living/M in src.loc)
							if (M == src || !M.lying) continue
							message = "<span class='alert'><B>[src]</B> jumps and farts all over [M]! That's disgusting!</span>"
							fart_on_other = 1
							if(prob(20))
								message = "<span class='alert'>[M] vomits!</span>"
								M.vomit()
							break
						if(!fart_on_other)
							switch (rand(1, 10))
								if (1) message = "<B>[src]</B> releases some kind of gas into the air."
								if (2) message = "<B>[src]</B> farts! How can metal cubes do that?"
								if (3) message = "<B>[src]</B> shoots out a bolt of death."
								if (4) message = "<B>[src]</B> squeezes itself inward and farts."
								if (5) message = "<B>[src]</B> hops up and down, farting all the while."
								if (6) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
								if (7) message = "<B>[src]</B> gets revenge on humanity with a terrible fart."
								if (8) message = "<B>[src]</B> stinks even worse than normal, somehow."
								if (9) message = "<B>[src]</B> shows that it can fart just as good as any human."
								if (10)
									message = "<B>[src]</B> farts oil and debris out of one of its sides! That's kinda grody!"
									var/obj/decal/cleanable/machine_debris/gib = make_cleanable(/obj/decal/cleanable/machine_debris, src.loc)
									gib.streak_cleanable()
						playsound(src.loc, 'sound/voice/farts/poo2_robot.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
						src.remove_stamina(STAMINA_DEFAULT_FART_COST)
						src.stamina_stun()
						return message
			return null

		specific_emote_type(var/act)
			switch (act)
				if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","nod","shrug","think","ponder","contemplate")
					return 1
				if ("fart")
					return 2
			return ..()
