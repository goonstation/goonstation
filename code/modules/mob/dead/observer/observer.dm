/mob/dead/observer/New(mob/corpse)
	src.invisibility = 10
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = 15
	src.see_in_dark = 100
	src.verbs += /mob/dead/observer/proc/dead_tele

	if(corpse)
		src.corpse = corpse
		src.loc = get_turf(corpse.loc)
		src.real_name = corpse.real_name
		src.name = corpse.real_name
		src.verbs += /mob/dead/observer/proc/reenter_corpse

/mob/proc/ghostize()
	set name = "Ghost"
	set desc = "You cannot be revived as a ghost"
	if(src.client)
		src.client.mob = new/mob/dead/observer(src)
	return

/mob/dead/observer/Move(NewLoc, direct)
	if(NewLoc)
		src.loc = NewLoc
		return
	if((direct & NORTH) && src.y < world.maxy)
		src.y++
	if((direct & SOUTH) && src.y > 1)
		src.y--
	if((direct & EAST) && src.x < world.maxx)
		src.x++
	if((direct & WEST) && src.x > 1)
		src.x--

/mob/dead/observer/examine()
	if(usr)
		usr << src.desc

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	statpanel("Status")
	if (src.client.statpanel == "Status")
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/dead/observer/proc/reenter_corpse()
	set category = "Special Verbs"
	set name = "Re-enter Corpse"
	if(!corpse)
		alert("You don't have a corpse!")
		return
//	if(corpse.stat == 2)
//		alert("Your body is dead!")
//		return
	if(src.client && src.client.holder && src.client.holder.state == 2)
		var/rank = src.client.holder.rank
		src.client.clear_admin_verbs()
		src.client.holder.state = 1
		src.client.update_admins(rank)
	src.client.mob = corpse
	del(src)

/mob/dead/observer/proc/dead_tele()
	set category = "Special Verbs"
	set name = "Teleport"
	set desc= "Teleport"
	if((usr.stat != 2) || !istype(usr, /mob/dead/observer))
		usr << "Not when you're not dead!"
		return
	var/A
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(50)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	A = input("Area to jump to", "BOOYEA", A) in list("Engine","Hallways","Toxins","Storage","Maintenance","Crew Quarters","Medical","Security","Chapel","Bridge","Prison","AI Satellite","Thunderdome")

	switch (A)
		if ("Engine")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/engine) && !istype(B, /area/engine/combustion) && !istype(B, /area/engine/engine_walls))
					L += B
			A = pick(L)
		if ("Hallways")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/hallway))
					L += B
			A = pick(L)
		if ("Toxins")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/toxins) && !istype(B, /area/toxins/test_area))
					L += B
			A = pick(L)
		if ("Storage")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/storage))
					L += B
			A = pick(L)
		if ("Maintenance")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/maintenance))
					L += B
			A = pick(L)
		if ("Crew Quarters")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/crew_quarters))
					L += B
			A = pick(L)
		if ("Medical")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/medical))
					L += B
			A = pick(L)
		if ("Security")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/security))
					L += B
			A = pick(L)
		if ("Chapel")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/chapel))
					L += B
			A = pick(L)
		if ("Bridge")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/bridge))
					L += B
			A = pick(L)
		if ("AI Satellite")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/turret_protected/aisat))
					L += B
			A = pick(L)
		if ("Prison")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/prison/control))
					L += B
			A = pick(L)
		if ("Thunderdome")
			var/list/L = list()
			for(var/area/B in world)
				if(istype(B, /area/tdome))
					L += B
			A = pick(L)

	var/list/L = list()
	for(var/turf/T in A)
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T

	usr.loc = pick(L)


