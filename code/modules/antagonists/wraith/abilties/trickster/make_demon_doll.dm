/datum/targetable/wraithAbility/make_demon_doll
	name = "Summon Demon Doll"
	desc = "Dredge an evil spirit up from the depths of the void to pester the living."
	icon_state = "make_doll"
	targeted = 0
	pointCost = 250
	cooldown = 150 SECONDS
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS
	var/max_allowed_dolls = 3
	var/player_count = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return TRUE

		var/total_dolls = 0
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			if (!C.mob)
				continue
			player_count++
			var/mob/M = C.mob
			if (istype(M, /mob/living/critter/wraith/demon_doll))
				total_dolls++
		if(total_dolls < (max_allowed_dolls + (player_count / 30)))	//Population scaling
			var/turf/T = get_turf(holder.owner)
			if (!T || !istype(T,/turf/simulated/floor))
				boutput(holder.owner, SPAN_NOTICE("You cannot use this here!"))
				return TRUE
			for (var/obj/O in T)
				if (O.density)
					boutput(holder.owner, SPAN_NOTICE("There is something in the way!"))
					return TRUE
			boutput(holder.owner, "You begin to channel power to summon a demon doll into this realm!")
			src.doCooldown()
			make_demon_doll(holder.owner, T)
			return FALSE

		else
			boutput(holder.owner, SPAN_ALERT("This [station_or_ship()] is already filled with spirits, you cannot summon more!"))
			return TRUE

	proc/make_demon_doll(var/mob/living/intangible/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		W.spawn_marker = marker
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a demon doll? Your name will be added to the list of eligible candidates.")
		text_messages.Add("You are eligible to be respawned as a demon doll. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending demon doll offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if (!islist(candidates) || length(candidates) <= 0)
			message_admins("Couldn't set up demon doll ; no ghosts responded. Source: [src.holder]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up demon doll ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up demon doll ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_demon_doll(W, T, tries++)
			return
		var/datum/mind/lucky_dude = candidates[1]

		//add demon doll to master's list is done in /mob/living/critter/wraith/demon_doll/New
		if (lucky_dude.add_subordinate_antagonist(ROLE_DEMON_DOLL, source = ANTAGONIST_SOURCE_SUMMONED, master = W.mind))
			log_respawn_event(lucky_dude, "demon doll", src.holder.owner)
			message_admins("[key_name(lucky_dude)] respawned as a demon doll for [src.holder.owner].")
			usr.playsound_local(usr.loc, 'sound/voice/wraith/ghostrespawn.ogg', 50, 0)
		qdel(marker)
		W.spawn_marker = null
