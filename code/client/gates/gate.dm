/datum/client_auth_gate
	proc/check(client/C)
		return TRUE

	proc/fail(client/C)
		if (istype(C?.mob, /mob/new_player))
			var/mob/new_player/new_player = C.mob
			new_player.blocked_from_joining = TRUE

		sleep(5 SECONDS)

		if (C?.mob) tgui_process.close_user_uis(C.mob)
		if (C) del(C)
