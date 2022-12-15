var/datum/respawn_controls/respawn_controller

// Datum to handle automatic respawns
/*

	MVP should cover:
	- Tracking dead players and allowing them to respawn if possible - DONE
		- Triggered when player dies, player is put into waiting list  - DONE
		- Player removed from waiting list when respawned in-game (eg. ghost drone, cloning, borging) - DONE

	- Granting the dead players a "Respawn" verb when they're brought back - DONE
	- Pop-up during RP-mode reminding of New-Life Rule - DONE

	- Configurable
		- Respawn timeout (in-code, ideally by define) - DONE
		- On/off (in-code) - DONE

	- Verification of mob-to-be respawned is in a valid state for respawning - DONE
	- Giving a disconnected/reconnected client their Respawn button back - DONE


	============
	Future
	============
	- Verification that player does not join as their old character (on pain of death / admin alert)
	- Most respawns done through this controller

*/
#define RESPAWNEE_STATE_WAITING 0
#define RESPAWNEE_STATE_ELIGIBLE 1
#define RESPAWNEE_STATE_ALIVE 2

/datum/respawn_controls
	var/respawn_time = DEFAULT_RESPAWN_TIME
	var/respawns_enabled = RESPAWNS_ENABLED

	var/list/respawnees

	var/rp_alert = 0


	New()
		..()
		respawnees = list()

#ifdef RP_MODE
		rp_alert = 1
		respawns_enabled = 1
#endif

	proc/process()
		if(!respawns_enabled) return
		// Check the ones due to respawn
		for(var/ckey in respawnees)
			var/datum/respawnee/R = respawnees[ckey]
			checkRespawnee(R)


	proc/checkRespawnee(var/datum/respawnee/R)
		switch(R.checkValid())
			if(RESPAWNEE_STATE_WAITING)
				// This could happen if the client disconnects
			if(RESPAWNEE_STATE_ELIGIBLE)
				// They are eligible for respawn
				R.notifyAndGrantVerb()
			if(RESPAWNEE_STATE_ALIVE)
				// They were somehow revived
				unsubscribeRespawnee(R.ckey)

	proc/subscribeNewRespawnee(var/ckey)
		if(ckey && !respawnees.Find(ckey))

			var/datum/respawnee/R = new
			R.initialize(ckey, src)

			respawnees[ckey] = R


	proc/unsubscribeRespawnee(var/ckey)
		if(!ckey) return
		var/datum/respawnee/R = respawnees[ckey]
		respawnees.Remove(ckey)
		if(R)
			R.dispose()
			R = null

	proc/doRespawn(var/ckey)
		if(!ckey) return
		var/datum/respawnee/R = respawnees[ckey]
		if(R) R.doRespawn()

/datum/respawnee
	var/ckey
	var/client_processed
	var/died_time
	var/client/the_client
	var/datum/player/player

	var/due_for_respawn

	var/respawn_time_modifier = 1

	var/datum/respawn_controls/master


	disposing()
		the_client?.verbs -= /client/proc/respawn_via_controller
		master = null
		..()

	proc/initialize(var/ckey, var/datum/respawn_controls/master)
		src.ckey = ckey
		src.player = find_player(ckey)
		src.master = master
		src.died_time = TIME

		// Get a reference to the client - this way we would know if they have disconnected or not
		src.the_client = src.player?.client

		if(src.the_client?.mob.suiciding)
			src.respawn_time_modifier *= 2

		src.update_time_display()

	proc/update_time_display()
		if(!master.respawns_enabled)
			return 0
		if(isnull(the_client))
			the_client = src.player?.client
		var/time_left = master.respawn_time * respawn_time_modifier - (TIME - src.died_time)
		var/mob/dead/observer/observer
		if(istype(the_client?.mob, /mob/dead/observer))
			observer = the_client.mob
		else if(istype(the_client?.mob, /mob/dead/target_observer))
			var/mob/dead/target_observer/target_observer = the_client?.mob
			observer = target_observer.ghost
		if(time_left > 0)
			observer?.hud?.get_respawn_timer().set_time_left(time_left)
		else
			observer?.hud?.get_respawn_timer().activate_clickability(master.rp_alert)
		return 1


	proc/checkValid()
		// Time check (short-circuit saves some steps)
		if(due_for_respawn || src.died_time + master.respawn_time * respawn_time_modifier <= TIME)
			due_for_respawn = 1

			// Try to get a valid client reference
			if(isnull(the_client))
				client_processed = 0
				the_client = src.player?.client
				if(isnull(the_client))
					return RESPAWNEE_STATE_WAITING

			src.update_time_display()

			// Check that the client is currently dead
			if(isobserver(the_client.mob) || isdead(the_client.mob))
				return RESPAWNEE_STATE_ELIGIBLE
		else
			src.update_time_display()
		return RESPAWNEE_STATE_WAITING

	proc/notifyAndGrantVerb()
		if(!client_processed && checkValid())
			// Send a message to the client
			the_client.mob.playsound_local(the_client.mob, "sound/misc/boing/[rand(1,6)].ogg", 50, flags=SOUND_IGNORE_SPACE)

			boutput(the_client.mob, "<h2>You are now eligible for a <a href='byond://winset?command=Respawn-As-New-Character'>respawn (click here)</a>!</h1>")
			if(master.rp_alert)
				boutput(the_client.mob, "<span class='alert'>Remember that you <B>must spawn as a <u>new character</u></B> and <B>have no memory of your past life!</B></span>")

			the_client.verbs |= /client/proc/respawn_via_controller
			client_processed = 1

	proc/doRespawn()
		if(checkValid() != RESPAWNEE_STATE_ELIGIBLE)
			SPAWN(0)
				tgui_alert(usr, "You are not eligible for a respawn, bub!", "Cannot respawn")

			return

		logTheThing(LOG_DEBUG, usr, "used a timed respawn.")
		logTheThing(LOG_DIARY, usr, "used a timed respawn.", "game")

		var/mob/new_player/M = new()
		M.adminspawned = 1
		M.is_respawned_player = 1
		M.key = the_client.key
		M.Login()
		M.mind.purchased_bank_item = null
		if(master.rp_alert)
			M.client?.preferences.ShowChoices(M)
			boutput(M, "<span class='alert'>Remember that you <B>must spawn as a <u>new character</u></B> and <B>have no memory of your past life!</B></span>")
		master.unsubscribeRespawnee(src.ckey)

/client/proc/respawn_via_controller()
	set name = "Respawn As New Character"
	set desc = "When you're tired of being dead."

	respawn_controller.doRespawn(src.ckey)

/atom/movable/screen/respawn_timer
	screen_loc = "CENTER, NORTH"
	maptext_width = 32 * 5
	maptext_x = -32 * 2

	proc/activate_clickability(rp=FALSE)
		maptext = {"<span class='pixel c ol' style='font-size:16px;'><a style='color:#8f8;text-decoration:underline;' href='byond://winset?command=Respawn-As-New-Character'>Click here to respawn[rp?" as a <b>new</b> character":""]!</a></span>"}

	proc/set_time_left(time)
		var/time_text
		if(time <= 75 SECONDS)
			time_text = "<span style='color:#f88;'>[ceil(time / (1 SECOND))]</span> seconds"
		else if(time <= 60 MINUTES)
			time_text = "<span style='color:#f88;'>[ceil(time / (1 MINUTE))]</span> minutes"
		else
			time_text = "<span style='color:#f88;'>[time2text(time, "hh:mm:ss", 0)]</span>"
		maptext = {"<span class='pixel c ol' style='font-size:16px;'>Respawn in [time_text]</span>"}

#undef RESPAWNEE_STATE_WAITING
#undef RESPAWNEE_STATE_ELIGIBLE
#undef RESPAWNEE_STATE_ALIVE

/atom/movable/screen/join_other
	screen_loc = "CENTER, NORTH-1"
	maptext_height = 32 * 2
	maptext_width = 32 * 7
	maptext_x = -32 * 3
	maptext_y = -32 * 0.5
	var/server_id = "main2"
	var/server_name = "2 Classic: Bombini"

	Topic(href, href_list)
		. = ..()
		if(href_list["action"] == "close")
			src.maptext= null

	New(loc, server_id=null, server_name=null)
		..()
		if(!isnull(server_id))
			src.server_id = server_id
		if(!isnull(server_name))
			src.server_name = server_name
		if (server_id == config.server_id)
			return
		maptext = {"<span class='pixel c ol' style='font-size:16px;'>Dead? No worries. <a style='color:red;background-color:black;' href="?src=\ref[src]&action=close">X</a><br><a style='color:#8f8;text-decoration:underline;' href='byond://winset?command=Change-Server [server_id]'>Click here to join<br>[server_name]!</a></span>"}
