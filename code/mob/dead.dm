/mob/dead
	stat = 2
	event_handler_flags = USE_CANPASS | IMMUNE_MANTA_PUSH

// dead

// No log entries for unaffected mobs (Convair880).
/mob/dead/ex_act(severity)
	return

/mob/dead/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/mob/dead/say_understands()
	return 1

/mob/dead/can_strip()
	return 0


/mob/dead/click(atom/target, params)
	if (targeting_ability)
		..()
	else
		if (get_dist(src, target) > 0)
			dir = get_dir(src, target)
		src.examine_verb(target)

/mob/dead/process_move(keys)
	if (!istype(src.loc,/turf)) //Pop observers and Follow-Thingers out!!
		var/mob/dead/O = src
		O.set_loc(get_turf(src))
	. = ..()

/mob/dead/projCanHit(datum/projectile/P)
	return P.hits_ghosts

/mob/dead/say(var/message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	if (dd_hasprefix(message, "*"))
		return src.emote(copytext(message, 2),1)

	logTheThing("diary", src, null, "(GHOST): [message]", "say")

	if (src.client && src.client.ismuted())
		boutput(src, "You are currently muted and may not speak.")
		return

	if(src?.client?.preferences.auto_capitalization)
		message = capitalize(message)

	. = src.say_dead(message)

	for (var/mob/M in hearers(null, null))
		if (!M.stat)
			if (M.job == "Chaplain")
				if (prob (80))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
				else
					M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
			else
				if (prob(90))
					return
				else if (prob (95))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
				else
					M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)

/mob/dead/emote(var/act, var/voluntary = 0) // fart
	if (!deadchat_allowed)
		src.show_text("<b>Deadchat is currently disabled.</b>")
		return

	var/message = null
	switch (lowertext(act))

		if ("fart")
			if (farting_allowed && src.emote_check(voluntary, 25, 1, 0))
				var/fluff = pick("spooky", "eerie", "ectoplasmic", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")
				var/fart_on_other = 0
				for (var/obj/item/storage/bible/B in src.loc)
					playsound(get_turf(src), 'sound/voice/farts/poo2.ogg', 7, 0, 0, src.get_age_pitch() * 0.4)
					break
				for (var/mob/living/M in src.loc)
					message = "<B>[src]</B> lets out \an [fluff] fart in [M]'s face!"
					fart_on_other = 1
					if (prob(95))
						break
					else
						M.show_text("<i>You feel \an [fluff] [pick("draft", "wind", "breeze", "chill", "pall")]...</i>")
						break
				if (!fart_on_other)
					message = "<B>[src]</B> lets out \an [fluff] fart!"
#ifdef HALLOWEEN
				if (fart_on_other)
					if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
						var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
						GH.change_points(20)
#endif

		if ("scream")
			if (src.emote_check(voluntary, 25, 1, 0))
				message = "<B>[src]</B> lets out \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] [pick("wail", "screech", "shriek")]!"

		if ("laugh")
			if (src.emote_check(voluntary, 20, 1, 0))
				message = "<B>[src]</B> lets out \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] [pick("laugh", "cackle", "chuckle")]!"

		if ("dance")
			if (src.emote_check(voluntary, 100, 1, 0))
				switch (rand(1, 4))
					if (1) message = "<B>[src]</B> does the Monster Mash!"
					if (2) message = "<B>[src]</B> gets spooky with it!"
					if (3) message = "<B>[src]</B> boogies!"
					if (4) message = "<B>[src]</B> busts out some [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] moves."
				if (prob(2)) // roll the probability first so we're not checking for critters each time this happens
					for (var/obj/critter/domestic_bee/responseBee in range(7, src))
						if (!responseBee.alive)
							continue
						responseBee.dance_response()
						break
					for (var/obj/critter/parrot/responseParrot in range(7, src))
						if (!responseParrot.alive)
							continue
						responseParrot.dance_response()
						break

		if ("flip")
			if (src.emote_check(voluntary, 100, 1, 0))
				message = "<B>[src]</B> does \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] flip!"
				animate(src) // stop the animation
				animate_spin(src, prob(50) ? "R" : "L", 1, 0)
				SPAWN_DBG(1 SECOND)
					animate_bumble(src)

		if ("wave","salute","nod")
			if (src.emote_check(voluntary, 10, 1, 0))
				message = "<B>[src]</B> [act]s."

		else
			src.show_text("Unusable emote '[act]'.", "blue")
			return

	if (message)
#ifdef HALLOWEEN
		if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
			GH.change_points(5)

#endif
		logTheThing("say", src, null, "EMOTE: [html_encode(message)]")
		/*for (var/mob/dead/O in viewers(src, null))
			O.show_*/src.visible_message("<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='message'>[message]</span></span>",group = "[src]_[lowertext(act)]")
		return 1
	return 0


// nothing in the game currently forces dead mobs to vomit. this will probably change or end up exposed via someone fucking up (likely me) in future. - cirr
/mob/dead/vomit(var/nutrition=0, var/specialType=null)
	..(0, /obj/item/reagent_containers/food/snacks/ectoplasm)
	playsound(src.loc, "sound/effects/ghost2.ogg", 50, 1)
	src.visible_message("<span class='alert'>Ectoplasm splats onto the ground from nowhere!</span>",
		"<span class='alert'>Even dead, you're nauseated enough to vomit![pick("", "Oh god!")]</span>",
		"<span class='alert'>You hear something strangely insubstantial land on the floor with a wet splat!</span>")
