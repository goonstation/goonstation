
/client/proc/cmd_admin_gib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return
	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has gibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has gibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has gibbed [key_name(M)]")
		M.transforming = 1

		var/atom/movable/overlay/gibs/O = new/atom/movable/overlay/gibs(get_turf(M))
		O.anchored = 1
		O.name = "Explosion"
		O.layer = NOLIGHT_EFFECTS_LAYER_BASE
		O.pixel_x = -92
		O.pixel_y = -96
		O.icon = 'icons/effects/214x246.dmi'
		O.icon_state = "explosion"
		//SPAWN_DBG(0.5 SECONDS)
		M.gib()
		SPAWN_DBG(3.5 SECONDS)
			if (O)
				O.delaydispose()


/client/proc/cmd_admin_partygib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Party Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has partygibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has partygibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has partygibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.partygib()

/client/proc/cmd_admin_owlgib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Owl Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has owlgibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has owlgibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has owlgibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.owlgib()

/client/proc/cmd_admin_firegib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Fire Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has firegibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has firegibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has firegibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.firegib()

/client/proc/cmd_admin_elecgib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Elec Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has elecgibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has elecgibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has elecgibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.elecgib()

/client/proc/cmd_admin_icegib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Ice Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!ishuman(M))
		boutput(src, "<span class='alert'>Only humans can be icegibbed.</span>")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has icegibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has icegibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has icegibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M:become_ice_statue()

/client/proc/cmd_admin_goldgib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Gold Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!ishuman(M))
		boutput(src, "<span class='alert'>Only humans can be goldgibbed.</span>")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has goldgibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has goldgibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has goldgibbed [key_name(M)]")

		M.desc = "A dumb looking statue. Very shiny, though."
		SPAWN_DBG(0.5 SECONDS) M:become_gold_statue()

/client/proc/cmd_admin_spidergib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Spider Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!ishuman(M))
		boutput(src, "<span class='alert'>Only humans can be spidergibbed.</span>")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has spidergibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has spidergibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has spidergibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M:spidergib()

/client/proc/cmd_admin_implodegib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Implode Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!ishuman(M))
		boutput(src, "<span class='alert'>Only humans can be imploded.</span>")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has imploded [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has imploded [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has imploded [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M:implode()

/client/proc/cmd_admin_buttgib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Butt Gib"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (!ishuman(M))
		boutput(src, "<span class='alert'>Only humans can be buttgibbed.</span>")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has buttgibbed [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has buttgibbed [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has buttgibbed [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M:buttgib()

/client/proc/cmd_admin_cluwnegib(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Cluwne Gib"
	set desc = "Summon the fearsome floor cluwne..."
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to gib [M]?", "Confirmation", "Yes", "No") == "Yes")
		var/duration = input("Input duration in 1/10ths of seconds (10 - 100)", "The Honkening", 30) as num
		if(!duration) return
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has set a floor cluwne upon [constructTarget(M,"admin")]")
			logTheThing("diary", usr, M, "has set a floor cluwne upon [constructTarget(M,"diary")]", "admin")
			message_admins("[key_name(usr)] has set a floor cluwne upon [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.cluwnegib(duration)

/client/proc/cmd_admin_admindamn(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Damn"
	set desc = "Darn them right to heck"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to damn [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has damned [constructTarget(M,"admin")] to hell")
			logTheThing("diary", usr, M, "has damned [constructTarget(M,"diary")] to hell", "admin")
			message_admins("[key_name(usr)] has damned [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.damn()

/client/proc/cmd_admin_adminundamn(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "UnDamn"
	set desc = "Un-Darn them right out of heck"
	set popup_menu = 0

	if (!src.holder)
		boutput(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to undamn [M]?", "Confirmation", "Yes", "No") == "Yes")
		if(usr.key != M.key && M.client)
			logTheThing("admin", usr, M, "has undamned [constructTarget(M,"admin")] from hell")
			logTheThing("diary", usr, M, "has undamned [constructTarget(M,"diary")] from hell", "admin")
			message_admins("[key_name(usr)] has undamned [key_name(M)]")

		SPAWN_DBG(0.5 SECONDS) M.un_damn()

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set popup_menu = 0
	var/turf/T = get_turf(src.mob)
	if(T)
		var/obj/overlay/O = new/obj/overlay(T)
		O.anchored = 1
		O.name = "Explosion"
		O.layer = NOLIGHT_EFFECTS_LAYER_BASE
		O.pixel_x = -92
		O.pixel_y = -96
		O.icon = 'icons/effects/214x246.dmi'
		O.icon_state = "explosion"
		O.mouse_opacity = 0
		SPAWN_DBG(3.5 SECONDS)
			qdel(O)
	src.mob.gib()

/client/proc/cmd_admin_tysonban(mob/tysontarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Tyson Ban"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1
//	var/startside = pick(cardinal)
//	var/pickstarter = null
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	else
		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				var/tysonmins = input(usr,"How long (in minutes)?","Ban time",1440) as num
				if(!tysonmins)
					return
				if(tysonmins >= 2441) tysonmins = 2440
				var/reason = input(usr,"Reason?","reason","Griefer") as text
				if(!reason)
					return
				var/speed = input(usr,"How fast is Tyson? Lower is faster.","speed","5") as num
				if(!speed)
					return
				var/time = input(usr,"How long until it gives up and cheats? No relation to real time.","time","4") as num
				if(!time)
					return
//				switch(startside)
//					if(NORTH)
//						starty = world.maxy-2
//						startx = rand(2, world.maxx-2)
//					if(EAST)
//						starty = rand(2,world.maxy-2)
//						startx = world.maxx-2
//					if(SOUTH)
//						starty = 2
//						startx = rand(2, world.maxx-2)
//					if(WEST)
//						starty = rand(2, world.maxy-2)
//						startx = 2
				boutput(tysontarget, "Uh oh.")
				tysontarget << sound('sound/misc/Boxingbell.ogg')
				sleep(20 SECONDS)
				startx = tysontarget.x - rand(-11, 11)
				starty = tysontarget.y - rand(-11, 11)
//				pickedstarter = get_turf(pick(tysontarget:range(10)))
				var/turf/pickedstart = locate(startx, starty, tysontarget.z)
				var/obj/bantyson/Q = new /obj/bantyson(pickedstart)
				Q.tysonmins2 = tysonmins
				Q.tysontarget2 = tysontarget
				Q.caller = usr
				Q.tysonreason = reason
				Q.timelimit = time
				Q.tysonspeed = speed
//				boutput(tysontarget, "<span class='alert'><BIG><B>You have been banned by [usr.client.ckey].<br>Reason: [reason].</B></BIG></span>")
//				boutput(tysontarget, "<span class='alert'>This is a temporary ban, it will be removed in [tysonmins] minutes.</span>")
//				logTheThing("admin", usr, tysontarget, "has tysoned [constructTarget(src,"diary")]. Reason: [reason]. This will be removed in [tysonmins] minutes.")
				logTheThing("diary", usr, tysontarget, "has tysoned [constructTarget(tysontarget,"diary")]. Reason: [reason]. This will be removed in [tysonmins] minutes.", "admin")
//				message_admins("<span class='internal'>[usr.client.ckey] has banned [tysontarget.ckey].<br>Reason: [reason]<br>This will be removed in [tysonmins] minutes.</span>")

/client/proc/cmd_admin_tysongib(mob/tysontarget as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "Tyson Gib"
	set popup_menu = 0
	var/startx = 1
	var/starty = 1
//	var/startside = pick(cardinal)
//	var/pickstarter = null
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return

	var/speed = input(usr,"How fast is Mike Tyson? Lower is faster.","speed","5") as num
	if(!speed)
		return
//				switch(startside)
//					if(NORTH)
//						starty = world.maxy-2
//						startx = rand(2, world.maxx-2)
//					if(EAST)
//						starty = rand(2,world.maxy-2)
//						startx = world.maxx-2
//					if(SOUTH)
//						starty = 2
//						startx = rand(2, world.maxx-2)
//					if(WEST)
//						starty = rand(2, world.maxy-2)
//						startx = 2
	boutput(tysontarget, "Uh oh.")
	tysontarget << sound('sound/misc/Boxingbell.ogg')
	startx = tysontarget.x - rand(-11, 11)
	starty = tysontarget.y - rand(-11, 11)
//				pickedstarter = get_turf(pick(tysontarget:range(10)))
	var/turf/pickedstart = locate(startx, starty, tysontarget.z)
	var/obj/gibtyson/Q = new /obj/gibtyson(pickedstart)
	Q.tysontarget2 = tysontarget
	Q.caller = usr
	Q.tysonspeed = speed
//				boutput(tysontarget, "<span class='alert'><BIG><B>You have been banned by [usr.client.ckey].<br>Reason: [reason].</B></BIG></span>")
//				boutput(tysontarget, "<span class='alert'>This is a temporary ban, it will be removed in [tysonmins] minutes.</span>")
//				logTheThing("admin", usr, tysontarget, "has tysoned [constructTarget(src,"diary")].<br>Reason: [reason]<br>This will be removed in [tysonmins] minutes.")
//				logTheThing("diary", usr, tysontarget, "has tysoned [constructTarget(src,"diary")].<br>Reason: [reason]<br>This will be removed in [tysonmins] minutes.", "admin")
//				message_admins("<span class='internal'>[usr.client.ckey] has banned [tysontarget.ckey].<br>Reason: [reason]<br>This will be removed in [tysonmins] minutes.</span>")


/obj/bantyson/
	name = "Mike Tyson"
	desc = "Oh shit!!!"
	icon = 'icons/misc/Tyson4real.dmi'
	icon_state = "idle"
	layer = EFFECTS_LAYER_2
	density = 1
	anchored = 0
	var/mob/tysontarget2 = null
	var/tysonmins2 = null
	var/mob/caller = null
	var/tysonreason = null
	var/tysoncantreach = 0
	var/timelimit = 6
	var/tysonspeed = 1

	New()
		SPAWN_DBG(0) process()
		..()

	Bump(M as turf|obj|mob)
		M:density = 0
		SPAWN_DBG(0.4 SECONDS)
			M:density = 1
		sleep(0.1 SECONDS)
		var/turf/T = get_turf(M)
		src.x = T.x
		src.y = T.y

	proc/process()
		while (!disposed)
			if (tysoncantreach >= timelimit)
				if (tysoncantreach >= 20)
					qdel(src)
					return
				src.x = tysontarget2.x
				src.y = tysontarget2.y
				src.z = tysontarget2.z
				banproc()
				return
			else if (get_dist(src, src.tysontarget2) <= 1)
				for(var/mob/O in AIviewers(src, null))
					O.show_message("<span class='alert'><B>[src]</B> punches [tysontarget2]!</span>", 1)
				tysontarget2.changeStatus("weakened", 10 SECONDS)
				tysontarget2.changeStatus("stunned", 10 SECONDS)
				playsound(src.loc, 'sound/impact_sounds/generic_hit_3.ogg', 50, 1, -1)
				banproc()
				return
			else
				walk_towards(src, src.tysontarget2, tysonspeed)
				sleep(1 SECOND)
				tysoncantreach++

	proc/banproc()
		// drsingh for various cannot read null.
		for(var/mob/O in AIviewers(src, null))
			O.show_message("<span class='alert'><B>[src]</B> bans [tysontarget2] in one punch!</span>", 1)
		playsound(src.loc, 'sound/impact_sounds/generic_hit_3.ogg', 30, 1, -2)
		if(tysontarget2?.client)
			if(tysontarget2.client.holder)
				boutput(tysontarget2, "Here is where you'd get banned.")
				qdel(src)
				return
			var/addData[] = new()
			addData["ckey"] = tysontarget2.ckey
			addData["compID"] =  tysontarget2.computer_id
			addData["ip"] = tysontarget2.client.address
			addData["reason"] = tysonreason
			addData["akey"] = caller:ckey
			addData["mins"] = tysonmins2
			addBan(addData)
			boutput(tysontarget2, "<span class='alert'><BIG><B>You have been tysoned by [usr.client.ckey].<br>Reason: [tysonreason] and he couldn't escape the tyson.</B></BIG></span>")
			boutput(tysontarget2, "<span class='alert'>This is a temporary tysonban, it will be removed in [tysonmins2] minutes.</span>")
			logTheThing("admin", caller:client, tysontarget2, "has tysonbanned [constructTarget(tysontarget2,"admin")]. Reason: [tysonreason] and he couldn't escape the tyson. This will be removed in [tysonmins2] minutes.")
			logTheThing("diary", caller:client, tysontarget2, "has tysonbanned [constructTarget(tysontarget2,"diary")]. Reason: [tysonreason] and he couldn't escape the tyson. This will be removed in [tysonmins2] minutes.", "admin")
			message_admins("<span class='internal'>[caller?.client?.ckey] has tysonbanned [tysontarget2.ckey].<br>Reason: [tysonreason] and he couldn't escape the tyson.<br>This will be removed in [tysonmins2] minutes.</span>")
			del(tysontarget2.client)
			tysontarget2.gib()
//			if(ishuman(tysontarget2))
//				animation = new(src.loc)
//				animation.icon_state = "blank"
//				animation.icon = 'icons/mob/mob.dmi'
//				animation.master = src
//			if (tysontarget2:client)
		playsound(src.loc, pick('sound/misc/Boxingbell.ogg'), 50, 0)
		qdel(src)

/obj/gibtyson/
	name = "Mike Tyson"
	desc = "Oh shit!"
	icon = 'icons/misc/Tyson4real.dmi'
	icon_state = "idle"
	layer = EFFECTS_LAYER_2
	density = 1
	anchored = 0
	var/mob/tysontarget2 = null
	var/tysonspeed = 1
	var/mob/caller = null

	New()
		SPAWN_DBG(0) process()
		..()

	Bump(M as turf|obj|mob)
		M:density = 0
		SPAWN_DBG(0.4 SECONDS)
			M:density = 1
		sleep(0.1 SECONDS)
		var/turf/T = get_turf(M)
		src.x = T.x
		src.y = T.y

	proc/process()
		while (!disposed)
			if (get_dist(src, src.tysontarget2) <= 1)
				for(var/mob/O in AIviewers(src, null))
					O.show_message("<span class='alert'><B>[src]</B> punches [tysontarget2]!</span>", 1)
				tysontarget2.changeStatus("weakened", 10 SECONDS)
				tysontarget2.changeStatus("stunned", 10 SECONDS)
				playsound(src.loc, 'sound/impact_sounds/generic_hit_3.ogg', 50, 1, -1)
				icon_state = "punch"
				sleep(0.5 SECONDS)
				icon_state = "idle"
				gibproc()
				return
			else
				walk_towards(src, src.tysontarget2, tysonspeed)
				sleep(1 SECOND)

	proc/gibproc()
		// drsingh for various cannot read null.
		sleep(1.5 SECONDS)
		if (get_dist(src, src.tysontarget2) <= 1)
			for(var/mob/O in AIviewers(src, null))
				O.show_message("<span class='alert'><B>[src]</B> KOs [tysontarget2] in one punch!</span>", 1)
			playsound(src.loc, 'sound/impact_sounds/generic_hit_3.ogg', 30, 1, -2)
			if(tysontarget2?.client)
				logTheThing("admin", caller:client, tysontarget2, "tysongibbed [constructTarget(tysontarget2,"admin")]")
				logTheThing("diary", caller:client, tysontarget2, "tysongibbed [constructTarget(tysontarget2,"diary")]", "admin")
				message_admins("<span class='internal'>[caller?.client?.ckey] has tysongibbed [tysontarget2.ckey].</span>")
				tysontarget2.gib()
			sleep(0.5 SECONDS)
			playsound(src.loc, pick('sound/misc/knockout.ogg'), 50, 0)
			sleep(0.5 SECONDS)
			qdel(src)
		else
			process()
