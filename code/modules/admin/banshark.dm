/client/proc/sharkban(mob/sharktarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Shark Ban"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1

	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	else
		var/data[] = src.addBanTempDialog(sharktarget)
		if(data)
			var/speed = input(usr,"How fast is the shark? Lower is faster.","speed","5") as num
			if(!speed)
				return
			var/time = input(usr,"How long until it gives up and cheats? No relation to real time.","time","4") as num
			if(!time)
				return
			boutput(sharktarget, "Uh oh.")
			sharktarget.playsound_local_not_inworld('sound/misc/jaws.ogg', 100)
			logTheThing(LOG_DIARY, usr, "has set the Banshark on [constructTarget(sharktarget,"diary")]!", "admin")
			message_admins("[usr.client.ckey] has set the Banshark on [sharktarget.ckey]!")
			sleep(20 SECONDS)
			startx = sharktarget.x - rand(-11, 11)
			starty = sharktarget.y - rand(-11, 11)
			var/turf/pickedstart = locate(startx, starty, sharktarget.z)
			var/obj/banshark/Q = new /obj/banshark(pickedstart)
			Q.sharktarget2 = sharktarget
			Q.caller_mob = usr
			Q.data = data
			Q.timelimit = time
			Q.sharkspeed = speed


/client/proc/sharkgib(mob/sharktarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Shark Gib"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/speed = input(usr,"How fast is the shark? Lower is faster.","speed","5") as num
	if(!speed)
		return

	boutput(sharktarget, "Uh oh.")
	sharktarget.playsound_local_not_inworld('sound/misc/jaws.ogg', 100)
	sleep(20 SECONDS)
	startx = sharktarget.x - rand(-11, 11)
	starty = sharktarget.y - rand(-11, 11)

	var/turf/pickedstart = locate(startx, starty, sharktarget.z)
	var/obj/gibshark/Q = new /obj/gibshark(pickedstart)
	Q.sharktarget2 = sharktarget
	Q.caller_mob = usr
	Q.sharkspeed = speed

/obj/banshark
	name = "banshark"
	desc = "This is the most terrifying thing you've ever laid eyes on."
	icon = 'icons/misc/banshark.dmi'
	icon_state = "banshark1"
	layer = EFFECTS_LAYER_2
	density = 1
	anchored = UNANCHORED
	var/mob/sharktarget2 = null
	var/data = null
	var/caller_mob = null
	var/sharkcantreach = 0
	var/timelimit = 6
	var/sharkspeed = 1

	New()
		SPAWN(0) process()
		..()

	bump(atom/M as turf|obj|mob)
		if(M.density)
			M.density = 0
			SPAWN(0.4 SECONDS)
				M.density = 1
		SPAWN(0.1 SECONDS)
			var/turf/T = get_turf(M)
			src.x = T.x
			src.y = T.y

	proc/process()
		while (!disposed)
			if(!sharktarget2)
				banproc()
				return
			else if (sharkcantreach >= timelimit)
				src.x = sharktarget2.x
				src.y = sharktarget2.y
				src.z = sharktarget2.z
				banproc()
				return
			else if ((BOUNDS_DIST(src, src.sharktarget2) == 0))
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> bites [sharktarget2]!"), 1)
				sharktarget2.changeStatus("knockdown", 1 SECOND)
				sharktarget2.changeStatus("stunned", 10 SECONDS)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1, -1)
				banproc()
				return
			else
				walk_towards(src, src.sharktarget2, sharkspeed)
				sleep(1 SECOND)
				sharkcantreach++

	proc/banproc()
		// drsingh for various cannot read null
		if(sharktarget2)
			for(var/mob/O in AIviewers(src, null))
				O.show_message(SPAN_ALERT("<B>[src]</B> bans [sharktarget2] in one bite!"), 1)
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
			sharktarget2.gib()
			boutput(sharktarget2, SPAN_ALERT("<BIG><B>You have been eaten by the banshark!</B></BIG>"))
			logTheThing(LOG_ADMIN, sharktarget2, "has been eaten by the banshark!")
			message_admins(SPAN_INTERNAL("[sharktarget2.ckey] has been eaten by the banshark!"))
		else
			boutput(sharktarget2, SPAN_ALERT("<BIG><B>You can escape the banshark, but not the ban!</B></BIG>"))
			logTheThing(LOG_ADMIN, sharktarget2, "has evaded the shark by ceasing to exist!  Banning them anyway.")
			message_admins(SPAN_INTERNAL("[data["ckey"]] has evaded the shark by ceasing to exist!  Banning them anyway."))
		bansHandler.add(
			data["akey"],
			data["server"],
			data["ckey"],
			data["compId"],
			data["ip"],
			data["reason"],
			data["duration"]
		)
		playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
		qdel(src)

/obj/gibshark
	name = "gibshark"
	desc = "This is the second most terrifying thing you've ever laid eyes on."
	icon = 'icons/misc/banshark.dmi'
	icon_state = "banshark1"
	layer = EFFECTS_LAYER_2
	density = 1
	anchored = UNANCHORED
	var/mob/sharktarget2 = null
	var/sharkspeed = 1
	var/mob/caller_mob = null

	New()
		SPAWN(0) process()
		..()

	bump(atom/M as turf|obj|mob)
		if(M.density)
			M.density = 0
			SPAWN(0.4 SECONDS)
				M.density = 1
		SPAWN(0.1 SECONDS)
			var/turf/T = get_turf(M)
			src.x = T.x
			src.y = T.y

	proc/process()
		while (!disposed)
			if ((BOUNDS_DIST(src, src.sharktarget2) == 0))
				for(var/mob/O in AIviewers(src, null))
					O.show_message(SPAN_ALERT("<B>[src]</B> bites [sharktarget2]!"), 1)
				sharktarget2.changeStatus("knockdown", 1 SECOND)
				sharktarget2.changeStatus("stunned", 10 SECONDS)
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1, -1)
				gibproc()
				return
			else
				walk_towards(src, src.sharktarget2, sharkspeed)
				sleep(1 SECOND)

	proc/gibproc()
		// drsingh for various cannot read null.
		sleep(1.5 SECONDS)
		if ((BOUNDS_DIST(src, src.sharktarget2) == 0))
			for(var/mob/O in AIviewers(src, null))
				O.show_message(SPAN_ALERT("<B>[src]</B> gibs [sharktarget2] in one bite!"), 1)
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
			if(sharktarget2?.client)
				logTheThing(LOG_ADMIN, caller_mob, "sharkgibbed [constructTarget(sharktarget2,"admin")]")
				logTheThing(LOG_DIARY, caller_mob, "sharkgibbed [constructTarget(sharktarget2,"diary")]", "admin")
				message_admins(SPAN_INTERNAL("[key_name(caller_mob)] has sharkgibbed [key_name(sharktarget2)]."))
				sharktarget2.gib()
			sleep(0.5 SECONDS)
			playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
			sleep(0.5 SECONDS)
			qdel(src)
		else
			process()
