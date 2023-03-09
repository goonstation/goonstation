/datum/targetable/wraithAbility/make_plague_rat
	name = "Summon Plague rat"
	desc = "Attempt to breach the veil between worlds to allow a plague rat to enter this realm."
	icon_state = "summonrats"
	targeted = 0
	pointCost = 150
	cooldown = 150 SECONDS
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS
	var/max_allowed_rats = 3
	var/player_count = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return TRUE

		var/total_plague_rats = 0
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			if (!C.mob)
				continue
			player_count++
			var/mob/M = C.mob
			if (istype(M, /mob/living/critter/wraith/plaguerat))
				total_plague_rats++
		if(total_plague_rats < (max_allowed_rats + (player_count / 30)))	//Population scaling
			var/turf/T = get_turf(holder.owner)
			if (!T || !istype(T,/turf/simulated/floor))
				boutput(holder.owner, "<span class='notice'>You cannot use this here!</span>")
				return TRUE
			for (var/obj/O in T)
				if (O.density)
					boutput(holder.owner, "<span class='notice'>There is something in the way!</span>")
					return TRUE
			boutput(holder.owner, "You begin to channel power to summon a plague rat into this realm!")
			src.doCooldown()
			make_plague_rat(holder.owner, T)
			return FALSE

		else
			boutput(holder.owner, "<span class='alert'>This [station_or_ship()] is already a rat den, you cannot summon another rat!</span>")
			return TRUE

	proc/make_plague_rat(var/mob/W, var/turf/T, var/tries = 0)
		if (!istype(W, /mob/living/intangible/wraith/wraith_decay))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a plague rat? Your name will be added to the list of eligible candidates.")
		text_messages.Add("You are eligible to be respawned as a plague rat. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending plague rat offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up plague rat ; no ghosts responded. Source: [src.holder]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up plague rat ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up plague rat ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_plague_rat(W, T, tries++)
			return
		var/datum/mind/lucky_dude = candidates[1]

		//add plague rat to master's list is done in /mob/living/critter/wraith/plaguerat/New
		if (lucky_dude.current)
			var/mob/living/critter/wraith/plaguerat/young/P = new /mob/living/critter/wraith/plaguerat/young(T, W)
			lucky_dude.transfer_to(P)
			antagify(lucky_dude.current, null, 1)
			message_admins("[lucky_dude.key] respawned as a plague rat for [src.holder.owner].")
			usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
			log_respawn_event(lucky_dude, "plague rat", src.holder.owner)
			boutput(P, "<span class='notice'><b>You have been respawned as a plague rat!</b></span>")
			boutput(P, "<span class='alert'><b>[W] is your master! Use your abilities to spread disease and consume rot! Work with your master to turn the station into a rat den!</b></span>")
		qdel(marker)
