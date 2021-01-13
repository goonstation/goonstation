// NOTE WELL!
// Only include this file when debugging locally
// Do not include in release versions


#define VARSICON 1
#define SDEBUG 1

/client/verb/DEBUG_MESSAGE()
	set category = "Debug"
	set name = "Debug-Debug"
	if(src.holder.rank == "Coder")
		Debug = !Debug

		boutput(world, "Debugging [Debug ? "On" : "Off"]")
	else
		alert("Coders only baby")
		return

/turf/verb/Flow()
	set category = "Debug"
	//set hidden = 1
	if(Debug)
		for(var/turf/T in range(5))

			var/obj/mark/O = locate(/obj/mark/, T)

			if(!O)
				O = new /obj/mark(T)
			else
				O.overlays = null

			var/obj/move/OM = locate(/obj/move/, T)

			if(OM)

				if(! OM.updatecell)
					O.icon_state = "x2"
				else
					O.icon_state = "blank"
/*
Doing this because FindTurfs() isn't even used
				for(var/atom/U in OM.FindTurfs() )
					var/dirn = get_dir(OM, U)
					if(dirn == 1)
						O.overlays += image('icons/misc/mark.dmi', OM.airdir==1?"up":"fup")
					else if(dirn == 2)
						O.overlays += image('icons/misc/mark.dmi', OM.airdir==2?"dn":"fdn")
					else if(dirn == 4)
						O.overlays += image('icons/misc/mark.dmi', OM.airdir==4?"rt":"frt")
					else if(dirn == 8)
						O.overlays += image('icons/misc/mark.dmi', OM.airdir==8?"lf":"flf")
*/
			else

				if(!(T.updatecell))
					O.icon_state = "x2"
				else
					O.icon_state = "blank"

				if(T.airN)
					O.overlays += image('icons/misc/mark.dmi', T.airdir==1?"up":"fup")

				if(T.airS)
					O.overlays += image('icons/misc/mark.dmi', T.airdir==2?"dn":"fdn")

				if(T.airW)
					O.overlays += image('icons/misc/mark.dmi', T.airdir==8?"lf":"flf")

				if(T.airE)
					O.overlays += image('icons/misc/mark.dmi', T.airdir==4?"rt":"frt")


				if(T.condN)
					O.overlays += image('icons/misc/mark.dmi', T.condN == 1?"yup":"rup")

				if(T.condS)
					O.overlays += image('icons/misc/mark.dmi', T.condS == 1?"ydn":"rdn")

				if(T.condE)
					O.overlays += image('icons/misc/mark.dmi', T.condE == 1?"yrt":"rrt")

				if(T.condW)
					O.overlays += image('icons/misc/mark.dmi', T.condW == 1?"ylf":"rlf")
	else
		alert("Debugging off")
		return

/turf/verb/Clear()
	set category = "Debug"
	//set hidden = 1
	if(Debug)
		for(var/obj/mark/O in world)
			del(O)
			LAGCHECK(LAG_LOW)
	else
		alert("Debugging off")
		return

/proc/numbericon(var/tn as text,var/s = 0)
	if(Debug)
		var/image/I = image('icons/misc/mark.dmi', "blank")

		if(length(tn)>8)
			tn = "*"

		var/len = length(tn)

		for(var/d = 1 to length(tn))


			var/char = copytext(tn, len-d+1, len-d+2)

			if(char == " ")
				continue

			var/image/ID = image('icons/misc/mark.dmi', char)

			ID.pixel_x = -(d-1)*4
			ID.pixel_y = s
			//if(d>1) I.Shift(WEST, (d-1)*8)

			I.overlays += ID



		return I
	else
		alert("Debugging off")
		return

/*/turf/verb/Stats()
	set category = "Debug"
	for(var/turf/T in range(5))

		var/obj/mark/O = locate(/obj/mark/, T)

		if(!O)
			O = new /obj/mark(T)
		else
			O.overlays = null


		var/temp = round(T.temp-T0C, 0.1)

		O.overlays += numbericon("[temp]C")

		var/pres = round(T.tot_gas() / CELLSTANDARD * 100, 0.1)

		O.overlays += numbericon("[pres]", -8)
		O.mark = "[temp]/[pres]"
*/
/*
/turf/verb/Pipes()
	set category = "Debug"

	for(var/turf/T in range(6))

		//boutput(world, "Turf [T] at ([T.x],[T.y])")

		for(var/obj/machinery/M in T)
			//boutput(world, " Mach [M] with pdir=[M.p_dir]")

			if(M?.p_dir)

				//boutput(world, "Accepted")
				var/obj/mark/O = locate(/obj/mark/, T)

				if(!O)
					O = new /obj/mark(T)
				else
					O.overlays = null

				if(istype(M, /obj/machinery/pipes))
					var/obj/machinery/pipes/P = M
					O.overlays += numbericon("[P.plnum]    ", -20)
					M = P.pl


				var/obj/substance/gas/G = M.get_gas()

				if(G)

					var/cap = round( 100*(G.tot_gas()/ M.capmult / 6e6), 0.1)
					var/temp = round(G.temperature - T0C, 0.1)
					O.overlays += numbericon("[temp]C", 0)
					O.overlays += numbericon("[cap]", -8)

				break
*/
/turf/verb/Cables()
	set category = "Debug"
	if(Debug)
		for(var/turf/T in range(6))

			//boutput(world, "Turf [T] at ([T.x],[T.y])")

			var/obj/mark/O = locate(/obj/mark/, T)

			if(!O)
				O = new /obj/mark(T)
			else
				O.overlays = null

			var/marked = 0
			for(var/obj/M in T)
				//boutput(world, " Mach [M] with pdir=[M.p_dir]")


				if(M && istype(M, /obj/cable/))


					var/obj/cable/C = M
					//boutput(world, "Accepted")

					O.overlays += numbericon("[C.netnum]  " ,  marked)

					marked -= 8

				else if(M && istype(M, /obj/machinery/power/))

					var/obj/machinery/power/P = M
					O.overlays += numbericon("*[P.netnum]  " ,  marked)
					marked -= 8

			if(!marked)
				qdel(O)
	else
		alert("Debugging off")
		return


/turf/verb/Solar()
	set category = "Debug"
	if(Debug)

		for(var/turf/T in range(6))

			//boutput(world, "Turf [T] at ([T.x],[T.y])")

			var/obj/mark/O = locate(/obj/mark/, T)

			if(!O)
				O = new /obj/mark(T)
			else
				O.overlays = null


			var/obj/machinery/power/solar/S

			S = locate(/obj/machinery/power/solar, T)

			if(S)

				O.overlays += numbericon("[S.obscured]  " ,  0)
				O.overlays += numbericon("[round(S.sunfrac*100,0.1)]  " ,  -12)

			else
				qdel(O)
	else
		alert("Debugging off")
		return


/mob/verb/Showports()
	set category = "Debug"
	if(Debug)
		var/turf/T
		var/obj/machinery/pipes/P
		var/list/ndirs

		for(var/obj/machinery/pipeline/PL in plines)

			var/num = plines.Find(PL)

			P = PL.nodes[1]		// 1st node in list
			ndirs = P.get_node_dirs()

			T = get_step(P, ndirs[1])

			var/obj/mark/O = new(T)

			O.overlays += numbericon("[num] * 1  ", -4)
			O.overlays += numbericon("[ndirs[1]] - [ndirs[2]]",-16)


			P = PL.nodes[PL.nodes.len]	// last node in list

			ndirs = P.get_node_dirs()
			T = get_step(P, ndirs[2])

			O = new(T)

			O.overlays += numbericon("[num] * 2  ", -4)
			O.overlays += numbericon("[ndirs[1]] - [ndirs[2]]", -16)
	else
		alert("Debugging off")
		return

/atom/verb/delete()
	set category = "Debug"
	set src in view()
	if(Debug)
		qdel(src)
	else
		alert("Debugging off")
		return


/area/verb/dark()
	set category = "Debug"
	if(Debug)
		if(src.icon_state == "dark")
			icon_state = null
		else
			icon_state = "dark"
	else
		alert("Debugging off")
		return

/area/verb/power()
	set category = "Debug"
	if(Debug)
		power_equip = !power_equip
		power_environ = !power_environ

		boutput(world, "Power ([src]) = [power_equip]")

		power_change()
	else
		alert("Debugging off")
		return

// *****RM

// *****


/mob/verb/ShowPlasma()
	set category = "Debug"
	if(Debug)
		Plasma()
	else
		alert("Debugging off")
		return

/mob/verb/Blobcount()
	set category = "Debug"
	if(Debug)
		boutput(world, "Blob count: [blobs.len]")
	else
		alert("Debugging off")
		return


/mob/verb/Blobkill()
	set category = "Debug"
	if(Debug)
		blobs = list()
		boutput(world, "Blob killed.")
	else
		alert("Debugging off")
		return

/mob/verb/Blobmode()
	set category = "Debug"
	if(Debug)
		boutput(world, "Event=[ticker.event]")
		boutput(world, "Time =[(ticker.event_time - world.realtime)/10]s")
	else
		alert("Debugging off")
		return

/mob/verb/Blobnext()
	set category = "Debug"
	if(Debug)
		ticker.event_time = world.realtime
	else
		alert("Debugging off")
		return


/mob/verb/callshuttle()
	set category = "Debug"
	if(Debug)
		ticker.timeleft = 300
		ticker.timing = 1
	else
		alert("Debugging off")
		return

/mob/verb/apcs()
	set category = "Debug"
	if(Debug)
		for(var/obj/machinery/power/apc/APC in machine_registry[MACHINES_POWER])
			boutput(world, APC.report())
	else
		alert("Debugging off")
		return

/mob/verb/Globals()
	set category = "Debug"
	if(Debug)
		debugobj = new()

		debugobj.debuglist = list( powernets, plines, config, admins, ticker, SS13_airtunnel, sun )


		boutput(world, "<A href='?src=\ref[debugobj];Vars=1'>Debug</A>")
	else
		alert("Debugging off")
		return
	/*for(var/obj/O in plines)

		boutput(world, "<A href='?src=\ref[O];Vars=1'>[O.name]</A>")
	*/




/mob/verb/Mach()
	set category = "Debug"
	if(Debug)
		var/n = 0
			for(var/i in 1 to PROCESSING_MAX_IN_USE)
				for(var/list/machines_list in processing_machines[i])
					for(var/obj/machinery/M in machines_list)
						n++
						if(! (M in machines) && ! (M in atmos_machines))
							boutput(world, "[M] [M.type]: not in list")

		boutput(world, "in world: [n]; in list:[machines.len + atmos_machines.len]")
	else
		alert("Debugging off")
		return


/*/mob/verb/air()
	set category = "Debug"

	Air()

/proc/Air()


	var/area/A = locate(/area/airintake)

	var/atot = 0
	for(var/turf/T in A)
		atot += T.tot_gas()

	var/ptot = 0
	for(var/obj/machinery/pipeline/PL in plines)
		if(PL.suffix == "d")
			ptot += PL.ngas.tot_gas()

	var/vtot = 0
	for(var/obj/machinery/atmoalter/V in machines)
		if(V.suffix == "d")
			vtot += V.gas.tot_gas()

	var/ctot = 0
	for(var/obj/machinery/connector/C in machines)
		if(C.suffix == "d")
			ctot += C.ngas.tot_gas()


	var/tot = atot + ptot + vtot + ctot

	diary << "A=[num2text(atot,10)] P=[num2text(ptot,10)] V=[num2text(vtot,10)] C=[num2text(ctot,10)] :  Total=[num2text(tot,10)]"
*/
/mob/verb/Revive()
	set category = "Debug"
	if(Debug)
		HealDamage("All", 10000, 10000)
		toxloss = 0
		oxyloss = 0
		paralysis = 0
		stunned = 0
		delStatus("weakened")
		health = 100
		if(stat > 1) stat=0
		disabilities = initial(disabilities)
		sdisabilities = initial(sdisabilities)
		for(var/obj/item/organ/e in src)
			e.brute_dam = 0.0
			e.burn_dam = 0.0
			e.bandaged = 0.0
			e.wound_size = 0.0
			e.max_damage = initial(e.max_damage)
			e.update_icon()
		if(src.type == /mob/living/carbon/human)
			var/mob/living/carbon/human/H = src
			H.UpdateDamageIcon()
	else
		alert("Debugging off")
		return

/mob/verb/Smoke()
	set category = "Debug"
	if(Debug)
		var/obj/effects/smoke/O = new /obj/effects/smoke( src.loc )
		O.set_dir(pick(NORTH, SOUTH, EAST, WEST))
		SPAWN_DBG( 0 )
			O.Life()
	else
		alert("Debugging off")
		return

/mob/verb/revent(number as num)
	set category = "Debug"
	set name = "Change event %"
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	if(src.authenticated && src.holder)
		eventchance = number
		logTheThing("admin", src, null, "set the random event chance to [eventchance]%")
		logTheThing("diary", src, null, "set the random event chance to [eventchance]%", "admin")
		message_admins("[src.key] set the random event chance to [eventchance]%")

/mob/verb/removeplasma()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	SPAWN_DBG(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15

/mob/verb/fire(turf/T as turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Create Fire"
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	boutput(world, "[usr.key] created fire")
	SPAWN_DBG(0)
		T.poison += 30000000
		T.firelevel = T.poison

/mob/verb/co2(turf/T as turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Create CO2"
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	boutput(world, "[usr.key] created CO2")
	SPAWN_DBG(0)
		T.co2 += 300000000

/mob/verb/n2o(turf/T as turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Create N2O"
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	boutput(world, "[usr.key] created N2O")
	SPAWN_DBG(0)
		T.sl_gas += 30000000

/mob/verb/explosion(T as obj|mob|turf in world)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
	set name = "Create Explosion"
	if(!isadmin(src))
		boutput(src, "Only administrators may use this command.")
		return
	boutput(world, "[usr.key] created an explosion")
	var/obj/item/weapon/tank/plasmatank/pt = new /obj/item/weapon/tank/plasmatank( T )
	playsound(pt.loc, "explosion", 100, 1,3)
	playsound(pt.loc, "sound/effects/explosionfar.ogg", 100, 1,10)
	pt.gas.temperature = 500+T0C
	pt.ignite()
