/datum/targetable/wraithAbility/harbinger_summon
	name = "Summon void creature"
	desc = "Attempt to breach the veil between worlds to allow a lesser void creature to enter this realm."
	icon_state = "summon_creature"
	targeted = 0
	pointCost = 400
	cooldown = 150 SECONDS
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	cast(atom/target, params)
		if (..())
			return TRUE

		var/turf/T = get_turf(holder.owner)
		if (!T || !istype(T,/turf/simulated/floor))
			boutput(holder.owner, "<span class='notice'>You cannot use this here!</span>")
			return TRUE
		for (var/obj/O in T)
			if (O.density)
				boutput(holder.owner, "<span class='notice'>There is something in the way!</span>")
				return TRUE
		boutput(holder.owner, "You begin to channel power to call a spirit to this realm!")
		src.doCooldown()
		make_summon(holder.owner, T)
		return FALSE

	proc/make_summon(var/mob/living/intangible/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a harbinger's summon? Your name will be added to the list of eligible candidates.")
		text_messages.Add("You are eligible to be respawned as a harbinger's summon. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending harbinger summon offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up harbinger summon ; no ghosts responded. Source: [src.holder]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up harbinger summon ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up harbinger summon ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_summon(W, T, tries++)
			return
		var/datum/mind/lucky_dude = candidates[1]

		//add poltergeist to master's list is done in /mob/living/intangible/wraith/potergeist/New
		if (lucky_dude.current)
			var/mob/living/critter/wraith/nascent/P = new /mob/living/critter/wraith/nascent(T, W)
			lucky_dude.transfer_to(P)
			antagify(lucky_dude.current, null, 1)
			message_admins("[lucky_dude.key] respawned as a harbinger summon for [src.holder.owner].")
			usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
			log_respawn_event(lucky_dude, "harbinger summon", src.holder.owner)
			boutput(P, "<span class='notice'><b>You have been respawned as a harbinger summon!</b></span>")
			boutput(P, "<span class='alert'><b>[W] is your master! Use your abilities to choose a path! Work with your master to spread chaos!</b></span>")
		qdel(marker)
