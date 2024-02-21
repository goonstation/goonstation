/datum/targetable/wraithAbility/make_poltergeist
	name = "Make Poltergeist"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 600
	cooldown = 5 MINUTES
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1
#ifdef RP_MODE
		var/mob/living/intangible/wraith/wraith = holder.owner
		if (istype(wraith) && length(wraith.poltergeists) >= 2)
			boutput(wraith, SPAN_ALERT("This world is already loud with the voices of your children. No more ghosts will come for now."))
			return 1
#endif
		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm!")
			src.doCooldown()
			make_poltergeist(holder.owner, T)
			return 0
		else
			boutput(holder.owner, SPAN_ALERT("You can't cast this spell on your current tile!"))
			return 1

	proc/make_poltergeist(var/mob/living/intangible/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		W.spawn_marker = marker
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a poltergeist? Your name will be added to the list of eligible candidates.")
		text_messages.Add("You are eligible to be respawned as a poltergeist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithportal.ogg', 50, 0)
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = 1)
		if (!islist(candidates) || length(candidates) <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up poltergeist ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_poltergeist(W, T, tries++)
			return
		var/datum/mind/lucky_dude = candidates[1]
		if (lucky_dude.add_subordinate_antagonist(ROLE_POLTERGEIST, source = ANTAGONIST_SOURCE_SUMMONED, master = W.mind))
			log_respawn_event(lucky_dude, "poltergeist", src.holder.owner)
			message_admins("[lucky_dude.key] respawned as a poltergeist for [src.holder.owner].")
			usr.playsound_local(usr.loc, 'sound/voice/wraith/ghostrespawn.ogg', 50, 0)
			var/mob/living/intangible/wraith/poltergeist/P = lucky_dude.current
			P.marker = marker
		W.spawn_marker = null
