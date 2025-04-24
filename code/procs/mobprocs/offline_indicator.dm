/*
	Offline indicator for mobs -- a visual representation of "SSD" status

	Intended behaviors:
	- AI mainframe should show "Zz" only if the AI itself is offline
	- AI shells show a "remote off" when unoccupied
	- AI mainframe shows a "remote" when in a shell, otherwise nothing if in core/eye
	- Players in VR have a "remote" when in a different mob

*/

#define OFFLINE_OVERLAY_KEY "offline_indicator"

// "this looks like the typing indicators" yes, and
var/image/offline_indicator_0m = image('icons/mob/overhead_icons32x48.dmi', "offline_0m")
var/image/offline_indicator_1m = image('icons/mob/overhead_icons32x48.dmi', "offline_1m")
var/image/offline_indicator_5m = image('icons/mob/overhead_icons32x48.dmi', "offline_5m")
var/image/remote_indicator_on = image('icons/mob/overhead_icons32x48.dmi', "remote")
var/image/remote_indicator_off = image('icons/mob/overhead_icons32x48.dmi', "remote_offline")

/mob/proc/create_offline_indicator()
	return

/mob/living/Logout()
	create_offline_indicator()
	. = ..()

/mob/Login()
	src.logout_at = null
	src.ClearSpecificOverlays(OFFLINE_OVERLAY_KEY)
	. = ..()

/mob/death()
	src.ClearSpecificOverlays(OFFLINE_OVERLAY_KEY)
	. = ..()


/mob/living/create_offline_indicator(force = FALSE)
	set waitfor = FALSE
	// the only people who get offline indicators are
	// - living
	// - alive
	// - has a ckey
	if (!isalive(src) || src.last_ckey == null || src.is_npc)
		return

	if (!force)

		// admins can override this behavior if they want for gimmicks.
		try
			var/client/C = getClientFromCkey(src.last_ckey)
			if (C.holder && C.holder.hide_offline_indicators)
				return
		catch
			// this area intentionally left blank

		// if your mob has a key, you're offline for real.
		// you get an indicator for your offline-ness.
		if (src.key)
			// check if you're an ai, since you deploy to shells and eyes.
			// those will need to update too.
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
				// virtual mobs also update their non-virtual counterparts
				var/mob/living/carbon/human/virtual/V = src
				V.body.create_offline_indicator(TRUE)

			if (istype(src, /mob/living/critter/robotic/scuttlebot))
				var/mob/living/critter/robotic/scuttlebot/SC = src
				if (SC.controller)
					SC.controller.create_offline_indicator(TRUE)
				return


		// special handling for "not in THIS mob, but..." cases.
		// anything that doesn't return here will create an offline indicator.

		// bodies of currently-virtual people aren't offline,
		// they're virtual. that's different.
		// (this only handles and stops the "human -> virtual" check;
		//  if the virtual human logs out, that's handled above, and
		//  propagates to the real human via a force=TRUE call)
		else if (src.network_device)
			// give them a remote overlay
			src.UpdateOverlays(remote_indicator_on, OFFLINE_OVERLAY_KEY)
			return

		// ai mainframes get a remote indicator too, if they're out.
		// probable bug: ai eyecam (living/intangible) doesn't get caught here, so leaving it
		// still sets ai core? ?????
		else if (istype(src, /mob/living/silicon/ai))
			var/mob/living/silicon/ai/AI = src
			if (AI.deployed_to_eyecam)
				// deploying to the eyecam doesn't produce an overlay.
				return
			else if (AI.deployed_shell)
				// deployed to shell? you get a remote overlay like vr.
				src.UpdateOverlays(remote_indicator_on, OFFLINE_OVERLAY_KEY)
				return

		else if (isrobot(src))
			// logged out shell?
			var/mob/living/silicon/robot/R = src
			if (R.shell)
				// this is a shell, so give it the remote offline indicator
				src.UpdateOverlays(remote_indicator_off, OFFLINE_OVERLAY_KEY)
			return

		else if (istype(src, /mob/living/critter/robotic/scuttlebot))
			src.UpdateOverlays(remote_indicator_off, OFFLINE_OVERLAY_KEY)
			return

		else if (isAIeye(src))
			return

	src.logout_at = TIME
	var/logout_check = src.logout_at
	src.UpdateOverlays(offline_indicator_0m, OFFLINE_OVERLAY_KEY)

#define INVALID_OFFLINE (QDELETED(src) || !isalive(src) || src.is_npc || !src.GetOverlayImage(OFFLINE_OVERLAY_KEY))

	SPAWN(1 MINUTE)
		if (INVALID_OFFLINE)
			return
		// check if they're still logged out after a while and update the overlay
		if (!src.client && logout_check == src.logout_at)
			src.UpdateOverlays(offline_indicator_1m, OFFLINE_OVERLAY_KEY)

		SPAWN(4 MINUTES)
			if (INVALID_OFFLINE)
				return
			// check if they're STILL logged out and update the overlay again
			if (!src.client && logout_check == src.logout_at)
				src.UpdateOverlays(offline_indicator_5m, OFFLINE_OVERLAY_KEY)

#undef INVALID_OFFLINE
#undef OFFLINE_OVERLAY_KEY
