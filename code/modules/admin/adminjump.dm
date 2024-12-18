/client/proc/Jump(var/area/A as null|area in by_type[/area])
	set desc = "Area to jump to"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Jump"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	if(config.allow_admin_jump)
		if (!A)
			A = tgui_input_list(usr, "Where do you want to jump?", "Jump", by_type[/area])
		if(flourish)
			shrink_teleport(src.mob)
		var/turf/origin_turf = get_turf(usr)
		var/list/turfs = get_area_turfs(A, 1)
		if (length(turfs))
			usr.set_loc(pick(turfs))
		else
			turfs = get_area_turfs(A, 0)
			if (length(turfs))
				boutput(src, "No floors found, jumping to a non-floor.")
				usr.set_loc(pick(turfs))
			else
				boutput(src, "Can't jump there, zero turfs in that area.")
				return
		logTheThing(LOG_ADMIN, usr, "jumped to [log_loc(usr)]")
		logTheThing(LOG_DIARY, usr, "jumped to [log_loc(usr)]", "admin")
		message_admins("[key_name(usr)] jumped [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [log_loc(usr)]")
	else
		alert("Admin jumping disabled")

/client/proc/jumptoturf(var/turf/T in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Jump To Turf"
	set popup_menu = 0

	ADMIN_ONLY
	if(config.allow_admin_jump)
		//Wire note: attempted fix for: Cannot read null.x (I guess the target turf...disappeared?)
		if (!T) return

		var/turf/origin_turf = get_turf(usr)
		logTheThing(LOG_ADMIN, usr, "jumped to [log_loc(T)]")
		logTheThing(LOG_DIARY, usr, "jumped to [log_loc(T)]", "admin")
		message_admins("[key_name(usr)] jumped [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [log_loc(T)]")
		if(flourish)
			shrink_teleport(src.mob)

		usr.set_loc(T)
	else
		alert("Admin jumping disabled")
	return

/client/proc/jtt(var/turf/T in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTT"
	set popup_menu = 0
	ADMIN_ONLY
	src.jumptoturf(T)

/client/proc/jumptomob(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Jump to Mob"
	set popup_menu = 0
	ADMIN_ONLY

	if(config.allow_admin_jump)
		var/turf/origin_turf = get_turf(usr)
		logTheThing(LOG_ADMIN, usr, "jumped to [constructTarget(M,"admin")] [log_loc(M)]")
		logTheThing(LOG_DIARY, usr, "jumped to [constructTarget(M,"diary")] [log_loc(M)]", "admin")
		message_admins("[key_name(usr)] jumped [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [key_name(M)] [log_loc(M)]")
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(get_turf(M))
	else
		alert("Admin jumping disabled")

/client/proc/jtm(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTM"
	set popup_menu = 0
	ADMIN_ONLY
	src.jumptomob(M)

/client/proc/jumptokey(var/client/ckey in clients)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Jump to Key"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	if(config.allow_admin_jump)
		var/mob/target
		if (!ckey)
			var/client/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in clients
			if(!selection)
				return
			target = selection.mob
		else
			target = ckey.mob
		var/turf/origin_turf = get_turf(usr)
		logTheThing(LOG_ADMIN, usr, "jumped to [constructTarget(target,"admin")] [log_loc(target)]")
		logTheThing(LOG_DIARY, usr, "jumped to [constructTarget(target,"diary")] [log_loc(target)]", "admin")
		message_admins("[key_name(usr)] jumped [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [key_name(target)] [log_loc(target)]")
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(target.loc)
	else
		alert("Admin jumping disabled")

/client/proc/jtk(var/client/ckey in clients)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTK"
	set popup_menu = 0
	ADMIN_ONLY
	src.jumptokey(ckey)

/client/proc/jumptocoord(var/x = 1 as num, var/y = 1 as num, var/z = 1 as num)
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Jump to Coord"
	set desc = "Jump to a coordinate in world (x, y, z)"

	ADMIN_ONLY
	SHOW_VERB_DESC

	if(config.allow_admin_jump)
		if (x > world.maxx || x < 1 || y > world.maxy || y < 1 || z > world.maxz || z < 1)
			alert("Invalid coordinates")
			return
		var/turf/turf = locate(x, y, z)
		var/turf/origin_turf = get_turf(usr)
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(turf)
		logTheThing(LOG_ADMIN, usr, "jumped to [log_loc(usr)]")
		logTheThing(LOG_DIARY, usr, "jumped to [log_loc(usr)]", "admin")
		message_admins("[key_name(usr)] jumped [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [log_loc(usr)]")
	else
		alert("Admin jumping disabled")

/client/proc/jtc(var/x = 1 as num, var/y = 1 as num, var/z = 1 as num)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTC"
	set popup_menu = 0
	ADMIN_ONLY
	src.jumptocoord(x, y, z)

/client/proc/Getmob(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Get Mob"
	set desc = "Mob to teleport"
	set popup_menu = 0
	ADMIN_ONLY
	if(config.allow_admin_jump)
		logTheThing(LOG_ADMIN, usr, "teleported [constructTarget(M,"admin")] [log_loc(usr)]")
		logTheThing(LOG_DIARY, usr, "teleported [constructTarget(M,"diary")] [log_loc(usr)]", "admin")
		var/turf/origin_turf = get_turf(M)
		message_admins("[key_name(usr)] teleported [key_name(M)] [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [log_loc(usr)]")
		M.set_loc(get_turf(usr))
	else
		alert("Admin jumping disabled")

/client/proc/sendmob(var/mob/M in world, var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Send Mob"
	set popup_menu = 0
	ADMIN_ONLY
	if(config.allow_admin_jump)
		var/list/turfs = get_area_turfs(A, 1)
		if (!length(turfs))
			turfs = get_area_turfs(A, 0)
			if (!length(turfs))
				boutput(src, "Unable to find any turf in that area.")
				return
			else
				boutput(src, "warning, no floors found, sending to non-floors.")

		var/turf/T = pick(turfs)
		var/turf/origin_turf = get_turf(M)
		M.set_loc(T)
		logTheThing(LOG_ADMIN, usr, "sent [constructTarget(M,"admin")] to [log_loc(T)]")
		logTheThing(LOG_DIARY, usr, "sent [constructTarget(M,"diary")] to [log_loc(T)]", "admin")
		message_admins("[key_name(usr)] teleported [key_name(M)] [isturf(origin_turf) ? "from [log_loc(origin_turf)]" : ""] to [log_loc(T)]")
	else
		alert("Admin jumping disabled")

/client/proc/sendhmobs(var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Send all Human Mobs"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		for(var/mob/living/carbon/human/H in mobs)
			H.set_loc(pick(get_area_turfs(A)))

		logTheThing(LOG_ADMIN, usr, "teleported all humans to [log_loc(A)]")
		logTheThing(LOG_DIARY, usr, "teleported all humans to [log_loc(A)]", "admin")
		message_admins("[key_name(usr)] teleported all humans to [log_loc(A)]")
	else
		alert("Admin jumping disabled")

/client/proc/sendmobs(var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Send all Mobs"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		for(var/mob/living/M in mobs)
			M.set_loc(pick(get_area_turfs(A)))

		logTheThing(LOG_ADMIN, usr, "teleported all mobs to [log_loc(A)]")
		logTheThing(LOG_DIARY, usr, "teleported all mobs to [log_loc(A)]", "admin")
		message_admins("[key_name(usr)] teleported all mobs to [log_loc(A)]")
	else
		alert("Admin jumping disabled")

/client/proc/gethmobs()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Human Mobs"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/carbon/human/H in mobs)
					H.set_loc(get_turf(usr))

				logTheThing(LOG_ADMIN, usr, "teleported all humans to themselves [log_loc(usr)]")
				logTheThing(LOG_DIARY, usr, "teleported all humans to themselves [log_loc(usr)]", "admin")
				message_admins("[key_name(usr)] teleported all humans to themselves [log_loc(usr)]")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getmobs()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Mobs"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/H in mobs)
					H.set_loc(get_turf(usr))

				logTheThing(LOG_ADMIN, usr, "teleported all humans to themselves [log_loc(usr)]")
				logTheThing(LOG_DIARY, usr, "teleported all humans to themselves [log_loc(usr)]", "admin")
				message_admins("[key_name(usr)] teleported all humans to themselves [log_loc(usr)]")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getclients()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Clients"
	set desc = "Teleports any mob with a client to you."
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for (var/client/C)
					if (!C.mob) continue
					if (istype(C.mob, /mob/new_player)) continue
					C.mob.set_loc(get_turf(usr))

				logTheThing(LOG_ADMIN, usr, "teleported all clients to themselves [log_loc(usr)]")
				logTheThing(LOG_DIARY, usr, "teleported all clients to themselves [log_loc(usr)]", "admin")
				message_admins("[key_name(usr)] teleported all clients to themselves [log_loc(usr)]")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/gettraitors()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Traitors"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/M in mobs)
					if(M.mind?.is_antagonist())
						M.set_loc(get_turf(usr))

				logTheThing(LOG_ADMIN, usr, "brought all traitors to themselves [log_loc(usr)]")
				logTheThing(LOG_DIARY, usr, "brought all traitors to themselves [log_loc(usr)]", "admin")
				message_admins("[key_name(usr)] teleported all traitors to themselves [log_loc(usr)]")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getnontraitors()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Non-Traitors"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/M in mobs)
					if(M.mind?.is_antagonist())
						continue
					M.set_loc(get_turf(usr))

				logTheThing(LOG_ADMIN, usr, "brought all non-traitors to themselves [log_loc(usr)]")
				logTheThing(LOG_DIARY, usr, "brought all non-traitors to themselves [log_loc(usr)]", "admin")
				message_admins("[key_name(usr)] teleported all non-traitors to themselves [log_loc(usr)]")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/cmd_admin_get_mobject(var/atom/target as mob|obj in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Get Thing"
	set desc = "Gets either a mob or an object, bringing it right to you! Wow!"
	ADMIN_ONLY

	if (config.allow_admin_jump)
		logTheThing(LOG_ADMIN, usr, "teleported [target] to their turf [log_loc(usr)] from [log_loc(target)]")
		logTheThing(LOG_DIARY, usr, "teleported [target] to their turf [log_loc(usr)] from [log_loc(target)]", "admin")
		message_admins("[key_name(usr)] teleported [target] to their turf [log_loc(usr)] from [log_loc(target)]")
		if(flourish)
			shrink_teleport(target)
		target:set_loc(get_turf(usr))
	else
		alert("Admin jumping disabled")

/client/proc/cmd_admin_get_mobject_loc(var/atom/target as mob|obj in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Get Thing (Location)"
	set desc = "Gets either a mob or an object, bringing it right to your loc! Wow!"
	ADMIN_ONLY

	if (config.allow_admin_jump)
		logTheThing(LOG_ADMIN, usr, "teleported [target] to their loc [log_loc(usr)] from [log_loc(target)]")
		logTheThing(LOG_DIARY, usr, "teleported [target] to their loc [log_loc(usr)] from [log_loc(target)]", "admin")
		message_admins("[key_name(usr)] teleported [target] to their loc [log_loc(usr)] from [log_loc(target)]")
		target:set_loc(usr.loc)
	else
		alert("Admin jumping disabled")
