/obj/machinery/bot/mining
	name = "Digbot"
	desc = "A little robot with a pickaxe. He looks so jazzed to go hit some rocks!"
	icon = 'aibots.dmi'
	icon_state = "digbot"
	layer = 5.0
	density = 0
	anchored = 0
	var/on = 0
	var/digging = 0
	var/health = 25
	locked = 1
	var/diglevel = 2
	var/digsuspicious = 0
	var/hardthreshold = 2
	var/turf/target
	var/turf/oldtarget
	var/oldloc = null
	var/emagged = 0
	req_access = list(access_engineering)
	var/list/path = null
	var/list/digbottargets = list()

	New()
		..()

/obj/machinery/bot/mining/drill
	name = "Digbot Mk2"
	desc = "A little robot with a drill. Looks like he means business!"
	icon_state = "digbot2"
	diglevel = 4
	hardthreshold = 4

/obj/machinery/bot/mining/New()
	..()
	spawn(5)
		src.sd_SetLuminosity(src.on ? 2 : 0)

/obj/machinery/bot/mining/attack_hand(user as mob)
	var/dat
	dat += text({"
<TT><B>Automatic Asteroid Mining Bot v1.0</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},
text("<A href='?src=\ref[src];operation=start'>[src.on ? "On" : "Off"]</A>"))
	if(!src.locked)
		dat += text({"<BR>
Dig suspicious locations: []<BR>
Dig up to hardness level: []"},
text("<A href='?src=\ref[src];operation=suspicious'>[src.digsuspicious ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=hardness'>[src.hardthreshold]</A>"))

	user << browse("<HEAD><TITLE>Repairbot v1.0 controls</TITLE></HEAD>[dat]", "window=autorepair")
	onclose(user, "autorepair")
	return

/obj/machinery/bot/mining/attackby(var/obj/item/W , mob/user as mob)
	//Regular ID
	if(istype(W, /obj/item/card/id))
		if(src.allowed(usr))
			src.locked = !src.locked
			user << "You [src.locked ? "lock" : "unlock"] the [src] behaviour controls."
		else
			user << "The [src] doesn't seem to accept your authority."
		src.updateUsrDialog()
	//////////////////////
	///Emagged code///////
	//////////////////////
	if ((istype(W, /obj/item/card/emag)) && (!src.emagged))
		user << "\red You short out [src]. It.. didn't really seem to affect anything, though."
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("\red <B>[src] buzzes oddly!</B>", 1)
		src.target = null
		src.oldtarget = null
		src.anchored = 0
		src.emagged = 1
		src.on = 1

/obj/machinery/bot/mining/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	switch(href_list["operation"])
		if("start")
			src.on = !src.on
			src.sd_SetLuminosity(src.on ? 2 : 0)
			src.target = null
			src.oldtarget = null
			src.oldloc = null
			src.path = null
			src.updateUsrDialog()
		if("suspicious")
			src.digsuspicious = !src.digsuspicious
			src.updateUsrDialog()
		if("hardness")
			src.hardthreshold = input(usr, "Maximum hardness level this bot will dig up to?", "Hardness Threshold", "") as num
			src.updateUsrDialog()

/obj/machinery/bot/mining/attack_ai()
	src.on = !src.on
	src.target = null
	src.oldtarget = null
	src.oldloc = null
	src.path = null

/obj/machinery/bot/mining/process()
	//checks to see if robot is on
	if(!src.on) return
	//checks to see if already repairing
	if(src.digging) return
	//checks if already targeting something
	digbottargets = list()
	if(!src.target)
		for(var/obj/machinery/bot/mining/bot in machines)
			if(bot != src) digbottargets += bot.target
	/////////Search for target code
	if(!src.target)
	    ///Search for asteroid wall
		for (var/turf/simulated/wall/asteroid/D in view(7,src))
			if(!(D in digbottargets) && D != src.oldtarget)
				if (D.hardness <= src.hardthreshold)
					if (!src.digsuspicious)
						if(D.event)
							continue
					src.oldtarget = D
					src.target = D
					break

	if(!src.target)
		if(src.loc != src.oldloc)
			src.oldtarget = null
		return

	if(src.target && (!src.path || !src.path.len))
		spawn(0)
			if (!isturf(src.loc)) return
			if (!target) return
			src.path = AStar(src.loc, src.target, /turf/proc/AdjacentTurfsSpace, /turf/proc/Distance)
			if (!src.path)
				src.oldtarget = src.target
				src.target = null
				return
			src.path.len-- // walk next to target, not ontop

	if(src.path && src.path.len && src.target)
		step_to(src, src.path[1])
		src.path -= src.path[1]

	if(src.target in range(1,src))
		if(istype(src.target, /turf/simulated/wall/asteroid/)) src.dig(src.target)
		src.path = null
		return

	src.oldloc = src.loc


/obj/machinery/bot/mining/proc/dig(var/turf/simulated/wall/asteroid/target)
	if(!istype(target, /turf/simulated/wall/asteroid/)) return

	src.anchored = 1

	src.visible_message("\red [src] starts digging!")
	if (src.diglevel > 2) playsound(src.loc, 'welder.ogg', 100, 1)
	else playsound(src.loc, 'pickaxe.ogg', 100, 1)
	src.digging = 1

	var/cuttime = 3
	var/chance = 90
	var/minedifference = target.hardness - src.diglevel
	if (minedifference == -1)
		cuttime -= 1
		chance += 5
	else if (minedifference <= -2)
		cuttime -= 2
		chance = 100
	else if (minedifference == 1)
		cuttime += 1
		chance -= 15
	else if (minedifference >= 2)
		chance = 0

	if (cuttime < 1) cuttime = 1
	cuttime *= 10
	if (chance > 100) chance = 100
	if (chance < 0) chance = 0

	spawn(cuttime)
		if(prob(chance))
			target.destroy_asteroid(0)
			src.digging = 0
			src.anchored = 0
			src.target = null
		else
			src.visible_message("\red [src] fails to dig the asteroid!")
			src.digging = 0

//////////////////////////////////////
//////Digbot Construction/////////////
//////////////////////////////////////

/obj/item/digbotassembly
	name = "hard hat/sensor assembly"
	desc = "You need to add a robot arm next."
	icon = 'aibots.dmi'
	icon_state = "helmet_signaler"
	w_class = 3.0
	var/build_step = 0

	attackby(var/obj/item/T, mob/user as mob)
		if (istype(T, /obj/item/parts/robot_parts/arm/))
			if (src.build_step == 0)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				qdel(T)
				src.build_step = 1
				src.name = "hard hat/sensor/robot arm assembly"
				user << "You add the robot arm to the assembly. Now you need to add a mining tool."
			else
				user << "You already added that part!"
				return
		else if (istype(T, /obj/item/mining_tool/))
			if (src.build_step == 1)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				user << "You add [T.name]. Now you have a finished mining bot! Hooray!"
				qdel(T)
				new /obj/machinery/bot/mining(user.loc)
				qdel(src)
			else
				user << "It's not ready for that part yet."
				return
		else if (istype(T, /obj/item/mining_tool/drill))
			if (src.build_step == 1)
				if (user.r_hand == T) user.u_equip(T)
				else user.u_equip(T)
				user << "You add [T.name]. Now you have a finished mining bot! Hooray!"
				qdel(T)
				new /obj/machinery/bot/mining/drill(user.loc)
				qdel(src)
			else
				user << "It's not ready for that part yet."
				return
		else ..()

/obj/item/clothing/head/helmet/hardhat/attackby(var/obj/item/T, mob/user as mob)
	if(istype(T, /obj/item/device/prox_sensor))
		user << "You attach the proximity sensor to the hard hat. Now you need to add a robot arm."
		new /obj/item/digbotassembly(user.loc)
		qdel(T)
		qdel(src)
		return
	else ..()

/obj/machinery/bot/mining/proc/explode()
	src.on = 0
	for(var/mob/O in hearers(src, null))
		O.show_message("\red <B>[src] blows apart!</B>", 1)
	var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return