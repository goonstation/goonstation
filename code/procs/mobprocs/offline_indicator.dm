#define OFFLINE_OVERLAY_KEY "offline_indicator"

// Singletons for offline indicators
// "this looks like the typing indicators" yes, and
var/mutable_appearance/offline_indicator = mutable_appearance('icons/mob/overhead_icons32x48.dmi', "offline")
var/mutable_appearance/offline_a_while_indicator = mutable_appearance('icons/mob/overhead_icons32x48.dmi', "offline_a_while")
/mob/proc/create_offline_indicator()
	return

/mob/proc/remove_offline_indicator()
	return

/mob/Login()
	remove_offline_indicator()
	. = ..()

/mob/living/Logout()
	create_offline_indicator()
	. = ..()


/mob/living/create_offline_indicator(force = FALSE)
	// the only people who get offline indicators are
	// - living
	// - alive
	// - has a ckey
	if (!src.has_offline_indicator && isalive(src) && src.last_ckey != null)

		if (!force)
			// bodies of currently-virtual people don't count either
			if (src.network_device)
				return
			// ai mainframes don't count, either.
			// "ismainframe()"? no. totally different thing.
			else if (istype(src, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = src
				if (AI.deployed_to_eyecam || AI.deployed_shell) // are you just moving elsewhere?
					return // you arent disconnected, get outta here

			else if (src.ckey)
				// if you have a ckey still you're offline for real.
				// check if you're an ai, since you deploy to shells and eyes
				var/mob/living/silicon/ai/AI
				if (isAIeye(src))
					var/mob/living/intangible/aieye/EYE = src
					AI = EYE.mainframe
				else if (issilicon(src))
					var/mob/living/silicon/S = src
					AI = S.mainframe
				if (AI)
					// if you disconnect while in a shell or eye,
					// update the ai mainframe to show you're out
					AI.create_offline_indicator(TRUE)

				if (isvirtual(src))
					var/mob/living/carbon/human/virtual/V = src
					V.body.create_offline_indicator(TRUE)

		src.has_offline_indicator = TRUE
		src.logout_at = TIME
		var/logout_check = src.logout_at
		src.UpdateOverlays(offline_indicator, OFFLINE_OVERLAY_KEY)
		RegisterSignal(src, COMSIG_MOB_DEATH, PROC_REF(remove_offline_indicator))

		SPAWN(5 MINUTES)
			// check if they're still logged out after a while and update the overlay
			if (src.has_offline_indicator == TRUE && logout_check == src.logout_at)
				src.UpdateOverlays(offline_a_while_indicator, OFFLINE_OVERLAY_KEY)

/mob/living/remove_offline_indicator()
	if (src.has_offline_indicator)
		src.has_offline_indicator = FALSE
		UnregisterSignal(src, COMSIG_MOB_DEATH)
		src.UpdateOverlays(null, OFFLINE_OVERLAY_KEY)


#undef OFFLINE_OVERLAY_KEY
