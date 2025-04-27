/mob/dead
	stat = STAT_DEAD
	event_handler_flags =  IMMUNE_OCEAN_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	pass_unstable = FALSE
	///Our corpse, if one exists
	var/mob/living/corpse

// dead
/mob/dead/New()
	..()
	src.flags |= UNCRUSHABLE
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOATING, src)

// No log entries for unaffected mobs (Convair880).
/mob/dead/ex_act(severity)
	return

// Make sure to keep this JPS-cache safe
/mob/dead/Cross(atom/movable/mover)
	return 1

/mob/dead/say_understands()
	return 1

/mob/dead/can_strip()
	return 0

/mob/dead/Login()
	. = ..()
	if(client?.holder?.ghost_interaction)
		setalive(src)

	if (isadminghost(src))
		get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS).add_client(src.client)

/mob/dead/Logout()
	. = ..()
	setdead(src)

	if (src.last_client?.holder && (rank_to_level(src.last_client.holder.rank) >= LEVEL_MOD) && (istype(src, /mob/dead/observer) || istype(src, /mob/dead/target_observer)))
		get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS).remove_client(src.last_client)

/mob/dead/click(atom/target, params, location, control)
	if(src.client?.holder?.ghost_interaction)
		if(isitem(target))
			var/obj/item/itemtarget = target
			itemtarget.AttackSelf(src)
		else
			target.Attackhand(src, params, location, control, params)
	else if (targeting_ability)
		..()
	else
		if (GET_DIST(src, target) > 0)
			src.set_dir(get_dir(src, target))
		src.examine_verb(target)

/mob/dead/process_move(keys)
	if(keys && src.move_dir && !src.override_movement_controller && !istype(src.loc, /turf)) //Pop observers and Follow-Thingers out!!
		var/mob/dead/O = src
		O.set_loc(get_turf(src))
	. = ..()

/mob/dead/projCanHit(datum/projectile/P)
	// INVIS_ALWAYS ghosts are logged out/REALLY hidden.
	return (P.hits_ghosts && (src.invisibility != INVIS_ALWAYS))

/mob/dead/say(var/message)
	message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if (!message)
		return

	..()
	if (dd_hasprefix(message, "*"))
		return src.emote(copytext(message, 2),1)

	logTheThing(LOG_DIARY, src, "(GHOST): [message]", "say")

	if (src.client && src.client.ismuted())
		boutput(src, "<b class='alert'>You are currently muted and may not speak.</b>")
		return

	if(src?.client?.preferences.auto_capitalization)
		message = capitalize(message)

	phrase_log.log_phrase("deadsay", message)
	. = src.say_dead(message)

	for (var/mob/M in hearers(null, null))
		if (!M.stat)
			if (M.job == "Chaplain")
				if (prob (80))
					M.show_message(SPAN_REGULAR("<i>You hear muffled speech... but nothing is there...</i>"), 2)
				else
					M.show_message(SPAN_REGULAR("<i>[stutter(message)]</i>"), 2)
			else
				if (prob(90))
					return
				else if (prob (95))
					M.show_message(SPAN_REGULAR("<i>You hear muffled speech... but nothing is there...</i>"), 2)
				else
					M.show_message(SPAN_REGULAR("<i>[stutter(message)]</i>"), 2)

/mob/dead/emote(var/act, var/voluntary = 0) // fart
	if (!deadchat_allowed)
		src.show_text("<b>Deadchat is currently disabled.</b>")
		return
	..()
	var/message = null
	switch (lowertext(act))

		if ("fart")
			if (farting_allowed && src.emote_check(voluntary, 25, 1, 0))
				var/fluff = pick("spooky", "eerie", "ectoplasmic", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")
				var/fart_on_other = 0
				for (var/obj/item/bible/B in src.loc)
					playsound(src, 'sound/voice/farts/poo2.ogg', 7, FALSE, 0, src.get_age_pitch() * 0.4, channel=VOLUME_CHANNEL_EMOTE)
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
				if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
					var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
					if (fart_on_other)
						GH.change_points(15)
					else if (GH.spooking)
						animate_surroundings("fart")

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
#ifdef HALLOWEEN
				if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
					var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
					if (GH.spooking)
						animate_surroundings("dance")
#endif

		if ("flip")
			if (src.emote_check(voluntary, 100, 1, 0))
				message = "<B>[src]</B> does \an [pick("spooky", "eerie", "frightening", "terrifying", "ghoulish", "ghostly", "haunting", "morbid")] flip!"
				animate(src) // stop the animation
				animate_spin(src, prob(50) ? "R" : "L", 1, 0)
				SPAWN(1 SECOND)
					animate_bumble(src)
#ifdef HALLOWEEN
				if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
					var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
					if (GH.spooking)
						animate_surroundings("flip")
#endif

		if ("wave","salute","nod")
			if (src.emote_check(voluntary, 10, 1, 0))
				message = "<B>[src]</B> [act]s."

		else
			if (voluntary)
				src.show_text("Unusable emote '[act]'.", "blue")
			return

	if (message)
#ifdef HALLOWEEN
		if (istype(src.abilityHolder, /datum/abilityHolder/ghost_observer))
			var/datum/abilityHolder/ghost_observer/GH = src.abilityHolder
			GH.change_points(5)

#endif
		logTheThing(LOG_SAY, src, "EMOTE: [html_encode(message)]")
		src.visible_message(SPAN_DEADSAY("[SPAN_PREFIX("DEAD:")] [SPAN_MESSAGE("[message]")]"),group = "[src]_[lowertext(act)]")
		return 1
	return 0

/mob/dead/visible_message(var/message, var/self_message, var/blind_message, var/group = "")
	for (var/mob/M in viewers(src))
		if (!M.client)
			continue
		var/msg = message
		if (self_message && M == src)
			M.show_message(self_message, 1, self_message, 2, group)
		else
			M.show_message(msg, 1, blind_message, 2, group)

#ifdef HALLOWEEN
/mob/dead/proc/animate_surroundings(var/type="fart", var/range = 2)
	var/count = 0
	for (var/obj/item/I in range(src, 2))
		if (count > 5)
			return
		var/success = 0
		switch (type)
			if ("fart")
				animate_levitate(I, 1, 8)
				success = 1
			if ("dance")
				eat_twitch(I)
				success = 1
			if ("flip")
				animate_spin(src, prob(50) ? "R" : "L", 1, 0)
				success = 1
		count ++
		if (success)
			sleep(rand(1,4))
#endif

// nothing in the game currently forces dead mobs to vomit. this will probably change or end up exposed via someone fucking up (likely me) in future. - cirr
/mob/dead/vomit(var/nutrition=0, var/specialType=null, var/flavorMessage="[src] vomits!", var/selfMessage = null)
	. = ..(0, /obj/item/reagent_containers/food/snacks/ectoplasm)
	if(.)
		playsound(src.loc, 'sound/effects/ghost2.ogg', 50, 1)
		src.visible_message(SPAN_ALERT("Ectoplasm splats onto the ground from nowhere!"),
			SPAN_ALERT("Even dead, you're nauseated enough to vomit![pick("", "Oh god!")]"),
			SPAN_ALERT("You hear something strangely insubstantial land on the floor with a wet splat!"))

proc/can_ghost_be_here(mob/dead/ghost, var/turf/T)
	if(isnull(T))
		return FALSE
	if(isghostrestrictedz(T.z) && !restricted_z_allowed(ghost, T) && !(ghost.client && ghost.client.holder && !ghost.client.holder.tempmin))
		return FALSE
	return TRUE
