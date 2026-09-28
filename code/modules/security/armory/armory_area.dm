/area/station/ai_monitored/armory
	name = "Armory"
	icon_state = "armory"
	sound_environment = 2
	teleport_blocked = AREA_TELEPORT_BLOCKED
	spy_secure_area = TRUE
	station_map_colour = MAPC_ARMOURY
	var/static/list/entered_ckeys = list()
	var/armory_auth = FALSE

	proc/authorize()
		armory_auth = TRUE

	proc/unauthorize()
		armory_auth = FALSE

	New()
		..()
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_ARMORY_AUTH, PROC_REF(authorize))
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_ARMORY_UNAUTH, PROC_REF(unauthorize))
		SPAWN(5 SECONDS) // This delay should allow for armory items to be created and log component for every pickup to be added to guns
			var/area/A = locate(/area/station/ai_monitored/armory)
			for(var/obj/item/O in A)
				O.AddComponent(/datum/component/log_item_pickup, first_time_only=TRUE, authorized_job=null, message_admins_too=FALSE)

	Entered(atom/movable/A, atom/oldloc)
		. = ..()
		if (current_state == GAME_STATE_PLAYING) //Don't worry about this in setup.
			var/obj/O = A
			if (istype(O))
				if(access_armory in O.req_access) // Auto update access for armory stuff when it enters armory if it mismatches current auth status
					if(src.armory_auth && !(access_security in O.req_access))
						O.req_access += access_security
						O.visible_message(SPAN_NOTICE("[O]'s access is automatically updated!"))
						playsound(O, 'sound/machines/chime.ogg', 50)
					else if (!src.armory_auth && (access_security in O.req_access))
						O.req_access = list(access_armory)
						O.visible_message(SPAN_NOTICE("[O]'s access is automatically reset!"))
						playsound(O, 'sound/machines/chime.ogg', 50)
		if (current_state < GAME_STATE_FINISHED)
			if(istype(A, /mob/living) && !istype(A, /mob/living/intangible))
				var/mob/living/M = A
				if(!M.client)
					return
				if(M.client.holder)
					return
				if(M.client.ckey in entered_ckeys)
					return
				var/ckey = M.client.ckey
				entered_ckeys += ckey
				SPAWN(120 SECONDS)
					entered_ckeys -= ckey
				logTheThing(LOG_STATION, M, "entered the Armory [log_loc(M)].[armory_auth ? "" : " - Armory unauthorized."]")
				if(!src.armory_auth && (IS_IT_SATURDAY))
					var/ircmsg[] = new()
					ircmsg["key"] = (usr?.client) ? usr.client.key : "NULL"
					ircmsg["name"] = (usr?.real_name) ? stripTextMacros(usr.real_name) : "NULL"
					ircmsg["msg"] = "entered the armory while it's unauthorized."
					ircbot.export_async("admin", ircmsg)
