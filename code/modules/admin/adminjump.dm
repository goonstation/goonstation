/client/proc/Jump(var/area/A in world)
	set desc = "Area to jump to"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Jump"
	set popup_menu = 0

	admin_only

	if(config.allow_admin_jump)
		if(flourish)
			shrink_teleport(src.mob)
		var/list/turfs = get_area_turfs(A, 1)
		if (turfs && turfs.len)
			usr.set_loc(pick(turfs))
		else
			boutput(src, "Can't jump there, zero turfs in that area.")
			return
		logTheThing("admin", usr, null, "jumped to [A] ([showCoords(usr.x, usr.y, usr.z)])")
		logTheThing("diary", usr, null, "jumped to [A] ([showCoords(usr.x, usr.y, usr.z)])", "admin")
		message_admins("[key_name(usr)] jumped to [A] ([showCoords(usr.x, usr.y, usr.z)])")
	else
		alert("Admin jumping disabled")

/client/proc/jumptoturf(var/turf/T in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Jump To Turf"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		//Wire note: attempted fix for: Cannot read null.x (I guess the target turf...disappeared?)
		if (!T) return

		logTheThing("admin", usr, null, "jumped to [showCoords(T.x, T.y, T.z)] in [get_area(T)]")
		logTheThing("diary", usr, null, "jumped to [showCoords(T.x, T.y, T.z, 1)] in [get_area(T)]", "admin")
		message_admins("[key_name(usr)] jumped to [showCoords(T.x, T.y, T.z)] in [get_area(T)]")
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
	admin_only
	src.jumptoturf(T)

/client/proc/jumptomob(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Jump to Mob"
	set popup_menu = 0
	admin_only

	if(config.allow_admin_jump)
		logTheThing("admin", usr, M, "jumped to [constructTarget(M,"admin")] ([showCoords(M.x, M.y, M.z)] in [get_area(M)])")
		logTheThing("diary", usr, M, "jumped to [constructTarget(M,"diary")] ([showCoords(M.x, M.y, M.z)] in [get_area(M)])", "admin")
		message_admins("[key_name(usr)] jumped to [key_name(M)] ([showCoords(M.x, M.y, M.z)] in [get_area(M)])")
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(get_turf(M))
	else
		alert("Admin jumping disabled")

/client/proc/jtm(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTM"
	set popup_menu = 0
	admin_only
	src.jumptomob(M)

/client/proc/jumptokey(var/client/ckey in clients)
	SET_ADMIN_CAT(ADMIN_CAT_PLAYERS)
	set name = "Jump to Key"
	set popup_menu = 0

	admin_only

	if(config.allow_admin_jump)
		var/mob/target
		if (!ckey)
			var/client/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in clients
			if(!selection)
				return
			target = selection.mob
		else
			target = ckey.mob
		logTheThing("admin", usr, target, "jumped to [constructTarget(target,"admin")] ([showCoords(target.x, target.y, target.z)] in [get_area(target)])")
		logTheThing("diary", usr, target, "jumped to [constructTarget(target,"diary")] ([showCoords(target.x, target.y, target.z)] in [get_area(target)])", "admin")
		message_admins("[key_name(usr)] jumped to [key_name(target)] ([showCoords(target.x, target.y, target.z)] in [get_area(target)])")
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(target.loc)
	else
		alert("Admin jumping disabled")

/client/proc/jtk(var/client/ckey in clients)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTK"
	set popup_menu = 0
	admin_only
	src.jumptokey(ckey)

/client/proc/jumptocoord(var/x = 1 as num, var/y = 1 as num, var/z = 1 as num)
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Jump to Coord"
	set desc = "Jump to a coordinate in world (x, y, z)"

	admin_only

	if(config.allow_admin_jump)
		if (x > world.maxx || x < 1 || y > world.maxy || y < 1 || z > world.maxz || z < 1)
			alert("Invalid coordinates")
			return
		var/turf/turf = locate(x, y, z)
		if(flourish)
			shrink_teleport(src.mob)
		usr.set_loc(turf)
		logTheThing("admin", usr, null, "jumped to [showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)]")
		logTheThing("diary", usr, null, "jumped to [showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)]", "admin")
		message_admins("[key_name(usr)] jumped to [showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)]")
	else
		alert("Admin jumping disabled")

/client/proc/jtc(var/x = 1 as num, var/y = 1 as num, var/z = 1 as num)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "JTC"
	set popup_menu = 0
	admin_only
	src.jumptocoord(x, y, z)

/client/proc/Getmob(var/mob/M in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Get Mob"
	set desc = "Mob to teleport"
	set popup_menu = 0
	admin_only
	if(config.allow_admin_jump)
		logTheThing("admin", usr, M, "teleported [constructTarget(M,"admin")] ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
		logTheThing("diary", usr, M, "teleported [constructTarget(M,"diary")] ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
		message_admins("[key_name(usr)] teleported [key_name(M)] ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
		M.set_loc(get_turf(usr))
	else
		alert("Admin jumping disabled")

/client/proc/sendmob(var/mob/M in world, var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Send Mob"
	set popup_menu = 0
	admin_only
	if(config.allow_admin_jump)
		var/list/turfs = get_area_turfs(A)
		if (turfs == null || turfs.len == 0)
			boutput(src, "Unable to find any turf in that area.")
			return

		var/turf/T = pick(turfs)
		M.set_loc(T)
		logTheThing("admin", usr, M, "sent [constructTarget(M,"admin")] to [A] ([showCoords(T.x, T.y, T.z)] in [get_area(A)])")
		logTheThing("diary", usr, M, "sent [constructTarget(M,"diary")] to [A] ([showCoords(T.x, T.y, T.z)] in [get_area(A)])", "admin")
		message_admins("[key_name(usr)] teleported [key_name(M)] to [A] ([showCoords(T.x, T.y, T.z)] in [get_area(A)])")
	else
		alert("Admin jumping disabled")

/client/proc/sendhmobs(var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Send all Human Mobs"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		for(var/mob/living/carbon/human/H in mobs)
			H.set_loc(pick(get_area_turfs(A)))

		logTheThing("admin", usr, null, "teleported all humans to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])")
		logTheThing("diary", usr, null, "teleported all humans to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])", "admin")
		message_admins("[key_name(usr)] teleported all humans to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])")
	else
		alert("Admin jumping disabled")

/client/proc/sendmobs(var/area/A in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Send all Mobs"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		for(var/mob/living/M in mobs)
			M.set_loc(pick(get_area_turfs(A)))

		logTheThing("admin", usr, null, "teleported all mobs to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])")
		logTheThing("diary", usr, null, "teleported all mobs to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])", "admin")
		message_admins("[key_name(usr)] teleported all mobs to [A] ([showCoords(A.x, A.y, A.z)] in [get_area(A)])")
	else
		alert("Admin jumping disabled")

/client/proc/gethmobs()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Human Mobs"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/carbon/human/H in mobs)
					H.set_loc(get_turf(usr))

				logTheThing("admin", usr, null, "teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
				logTheThing("diary", usr, null, "teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
				message_admins("[key_name(usr)] teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getmobs()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Mobs"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/H in mobs)
					H.set_loc(get_turf(usr))

				logTheThing("admin", usr, null, "teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
				logTheThing("diary", usr, null, "teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
				message_admins("[key_name(usr)] teleported all humans to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getclients()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Clients"
	set desc = "Teleports any mob with a client to you."
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for (var/client/C)
					if (!C.mob) continue
					if (istype(C.mob, /mob/new_player)) continue
					C.mob.set_loc(get_turf(usr))

				logTheThing("admin", usr, null, "teleported all clients to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
				logTheThing("diary", usr, null, "teleported all clients to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
				message_admins("[key_name(usr)] teleported all clients to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/gettraitors()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Traitors"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/M in mobs)
					if(checktraitor(M))
						M.set_loc(get_turf(usr))

				logTheThing("admin", usr, null, "brought all traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
				logTheThing("diary", usr, null, "brought all traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
				message_admins("[key_name(usr)] teleported all traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/getnontraitors()
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Get all Non-Traitors"
	set popup_menu = 0

	admin_only
	if(config.allow_admin_jump)
		switch(alert("Are you sure?",,"Yes","No"))
			if("Yes")
				for(var/mob/living/M in mobs)
					if(checktraitor(M))
						continue
					M.set_loc(get_turf(usr))

				logTheThing("admin", usr, null, "brought all non-traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
				logTheThing("diary", usr, null, "brought all non-traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])", "admin")
				message_admins("[key_name(usr)] teleported all non-traitors to themselves ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)])")
			if("No")
				return
	else
		alert("Admin jumping disabled")

/client/proc/cmd_admin_get_mobject(var/atom/target as mob|obj in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	set name = "Get Thing"
	set desc = "Gets either a mob or an object, bringing it right to you! Wow!"
	admin_only

	if (config.allow_admin_jump)
		logTheThing("admin", usr, null, "teleported [target] to their turf ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])")
		logTheThing("diary", usr, null, "teleported [target] to their turf ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])", "admin")
		message_admins("[key_name(usr)] teleported [target] to their turf ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])")
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
	admin_only

	if (config.allow_admin_jump)
		logTheThing("admin", usr, null, "teleported [target] to their loc ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])")
		logTheThing("diary", usr, null, "teleported [target] to their loc ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])", "admin")
		message_admins("[key_name(usr)] teleported [target] to their loc ([showCoords(usr.x, usr.y, usr.z)] in [get_area(usr)] from [showCoords(target.x, target.y, target.z)])")
		target:set_loc(usr.loc)
	else
		alert("Admin jumping disabled")
