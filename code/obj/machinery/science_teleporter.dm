/obj/decal/residual_energy
	name = "residual energy"
	desc = "faintly glowing residual energy."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "residual"

/obj/decal/teleport_swirl
	name = "swirling energy"
	anchored = 1
	density = 0
	opacity = 0
	layer = EFFECTS_LAYER_BASE
	icon = 'icons/effects/effects.dmi'
	icon_state = "portswirl"

/datum/teleporter_bookmark
	var/x = 0
	var/y = 0
	var/z = 0
	var/name = "BLANK"

var/XMULTIPLY = 1
var/XSUBTRACT = 0
var/YMULTIPLY = 1
var/YSUBTRACT = 0
var/ZMULTIPLY = 1
var/ZSUBTRACT = 0
/*
/obj/machinery/computer/science_teleport
	var/xtarget = 0
	var/ytarget = 0
	var/ztarget = 0
	var/realx = 0
	var/realy = 0
	var/realz = 0
	var/obj/machinery/science_teleport_pad/linked_pad = null


	var/list/bookmarks = new/list()
	var/max_bookmarks = 5
	var/allow_bookmarks = 1

	var/allow_scan = 1

	var/list/portals = list()

	icon = 'icons/obj/computer.dmi'
	icon_state = "s_teleport"
	name = "teleport computer"
	density = 1
	anchored = 1

	New()
		link_pad()

		XMULTIPLY = pick(1,2,4) //If it is three, perfect precision is impossible because fractions will be recurring.
		XSUBTRACT = rand(0,100)
		YMULTIPLY = pick(1,2,4) // same as above
		YSUBTRACT = rand(0,100)
		ZSUBTRACT = rand(0,world.maxz)

	proc/link_pad()
		if (!linked_pad)
			for(var/obj/machinery/science_teleport_pad/S in orange(8, src.loc))
				linked_pad = S
				break

	process()
		if(status & (NOPOWER|BROKEN))
			return
		use_power(500)

	attack_hand(var/mob/user as mob)
		if (..(user))
			return

		if (!linked_pad)
			link_pad()

			if (!linked_pad)
				boutput(user, "There is no teleporter pad linked to this console.")
				return

		var/dat = ""
		dat += "X: <A href='?src=\ref[src];decreaseX=10'>(<<)</A><A href='?src=\ref[src];decreaseX=1'>(<)</A><A href='?src=\ref[src];setX=1'> [xtarget] </A><A href='?src=\ref[src];increaseX=1'>(>)</A><A href='?src=\ref[src];increaseX=10'>(>>)</A><BR><BR>"
		dat += "Y: <A href='?src=\ref[src];decreaseY=10'>(<<)</A><A href='?src=\ref[src];decreaseY=1'>(<)</A><A href='?src=\ref[src];setY=1'> [ytarget] </A><A href='?src=\ref[src];increaseY=1'>(>)</A><A href='?src=\ref[src];increaseY=10'>(>>)</A><BR><BR>"
		dat += "Z:  <A href='?src=\ref[src];decreaseZ=1'>(<)</A><A href='?src=\ref[src];setZ=1'> [ztarget] </A><A href='?src=\ref[src];increaseZ=1'>(>)</A>"
		dat += "<br><br><br><A href='?src=\ref[src];send=1'>Send</A>"
		dat += "<br><A href='?src=\ref[src];receive=1'>Receive</A>"
		if(!portals.len) dat += "<br><A href='?src=\ref[src];portal=1'>Open Portal</A>"
		else dat += "<br><A href='?src=\ref[src];delportal=1'>Close Portal</A>"

		if(allow_scan)
			dat += "<br><br><A href='?src=\ref[src];scan=1'>Scan</A>"

		if(allow_bookmarks)
			dat += "<br><A href='?src=\ref[src];addbookmark=1'>Add Bookmark</A>"

		if(allow_bookmarks && bookmarks.len)
			dat += "<br><br><br>Bookmarks:"
			for (var/datum/teleporter_bookmark/b in bookmarks)
				dat += "<br>[b.name] ([b.x]/[b.y]/[b.z]) <A href='?src=\ref[src];restorebookmark=\ref[b]'>Restore</A> <A href='?src=\ref[src];deletebookmark=\ref[b]'>Delete</A>"

		user.machine = src
		user.Browse("<TITLE>Teleport Computer</TITLE><b>Target Coordinates</b><BR>[dat]", "window=t_computer;size=400x600")
		onclose(user, "t_computer")
		return

	Topic(href, href_list)
		if (..(href, href_list))
			return

		if (!linked_pad)
			boutput(usr, "There is no teleporter pad linked to this console.")
			return

		if (href_list["scan"])
			var/turf/target = doturfcheck(0)
			if(!target)
				boutput(usr, " ")
				boutput(usr, "<span style=\"color:green\">Scan Results:</span>")
				boutput(usr, "<span style=\"color:green\">No Atmosphere.</span>")
				return
			else
				boutput(usr, " ")
				boutput(usr, "<span style=\"color:green\">Scan Results:</span>")
				if(!istype(target, /turf/space))
					var/datum/gas_mixture/GM = target.return_air()
					var/burning = 0
					if(istype(target, /turf/simulated))
						var/turf/simulated/T = target
						if(T.active_hotspot)
							burning = 1
					boutput(usr, "<span style=\"color:green\">Atmosphere: Oxy:[GM.oxygen], Tox:[GM.toxins], Nit:[GM.nitrogen], Car:[GM.carbon_dioxide],  [GM.temperature] Kelvin, [GM.return_pressure()] kPa, [(burning)?("<span style=\"color:red\">BURNING</span>"):(null)]")
				else
					boutput(usr, "<span style=\"color:green\">No Atmosphere.</span>")
			src.updateUsrDialog()
			return

		if (href_list["restorebookmark"])
			var/datum/teleporter_bookmark/bm = locate(href_list["restorebookmark"])
			if(!bm) return
			xtarget = bm.x
			ytarget = bm.y
			ztarget = bm.z
			updatereal()
			src.updateUsrDialog()
			return

		if (href_list["deletebookmark"])
			var/datum/teleporter_bookmark/bm = locate(href_list["deletebookmark"])
			if(!bm) return
			bookmarks.Remove(bm)
			src.updateUsrDialog()
			return

		if (href_list["addbookmark"])
			if(bookmarks.len >= max_bookmarks)
				boutput(usr, "<span style=\"color:red\">Maximum number of Bookmarks reached.</span>")
				return
			var/datum/teleporter_bookmark/bm = new
			var/title = input(usr,"Enter name:","Name","New Bookmark") as text
			title = copytext(adminscrub(title), 1, 128)
			if(!length(title)) return
			bm.name = title
			bm.x = xtarget
			bm.y = ytarget
			bm.z = ztarget
			bookmarks.Add(bm)
			src.updateUsrDialog()
			return

		if (href_list["decreaseX"])
			var/change = text2num(href_list["decreaseX"])
			xtarget = min(max(0, xtarget-change),500)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["increaseX"])
			var/change = text2num(href_list["increaseX"])
			xtarget = min(max(0, xtarget+change),500)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["setX"])
			var/change = input(usr,"Target X:","Enter target X coordinate",xtarget) as num
			if(!isnum(change)) return
			xtarget = min(max(0, change),500)
			src.updateUsrDialog()
			updatereal()
			return

		else if (href_list["decreaseY"])
			var/change = text2num(href_list["decreaseY"])
			ytarget = min(max(0, ytarget-change),500)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["increaseY"])
			var/change = text2num(href_list["increaseY"])
			ytarget = min(max(0, ytarget+change),500)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["setY"])
			var/change = input(usr,"Target Y:","Enter target Y coordinate",ytarget) as num
			if(!isnum(change)) return
			ytarget = min(max(0, change),500)
			src.updateUsrDialog()
			updatereal()
			return

		else if (href_list["decreaseZ"])
			var/change = text2num(href_list["decreaseZ"])
			ztarget = min(max(0, ztarget-change),14)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["increaseZ"])
			var/change = text2num(href_list["increaseZ"])
			ztarget = min(max(0, ztarget+change),14)
			src.updateUsrDialog()
			updatereal()
			return
		else if (href_list["setZ"])
			var/change = input(usr,"Target Z:","Enter target Z coordinate",ztarget) as num
			if(!isnum(change)) return
			ztarget = min(max(0, change),14)
			src.updateUsrDialog()
			updatereal()
			return

		else if (href_list["send"])
			if (!linked_pad)
				boutput(usr, "There is no teleporter pad linked to this console.")
				return

			if(linked_pad.recharging)
				boutput(usr, "The teleport pad is still recharging!")
				return

			src.linked_pad.icon_state = "pad1"
			linked_pad.recharging = 1
			sleep(1 SECOND)

			var/turf/turfcheck = doturfcheck(1)
			if(!turfcheck)
				src.badsend()
			else if(!is_allowed(turfcheck))
				boutput(usr, "Unknown interference prevents teleportation to that location!")
			else
				src.send(turfcheck)
			sleep(0.5 SECONDS)

			src.linked_pad.icon_state = "pad0"
			sleep(3.5 SECONDS)

			linked_pad.recharging = 0

			return

		else if (href_list["receive"])
			if (!linked_pad)
				boutput(usr, "There is no teleporter pad linked to this console.")
				return

			if(linked_pad.recharging)
				boutput(usr, "The teleport pad is still recharging!")
				return

			src.linked_pad.icon_state = "pad1"
			linked_pad.recharging = 1
			sleep(1 SECOND)

			var/turf/turfcheck = doturfcheck(1)
			if(!turfcheck)
				src.badreceive()
			else if(!is_allowed(turfcheck))
				boutput(usr, "Unknown interference prevents teleportation from that location!")
			else
				src.receive(turfcheck)
			sleep(0.5 SECONDS)

			src.linked_pad.icon_state = "pad0"
			SPAWN_DBG(3.5 SECONDS)

			linked_pad.recharging = 0

			return

		else if (href_list["portal"])
			if (!linked_pad)
				boutput(usr, "There is no teleporter pad linked to this console.")
				return

			if(linked_pad.recharging)
				boutput(usr, "The teleport pad is still recharging!")
				return

			src.linked_pad.icon_state = "pad1"
			linked_pad.recharging = 1
			sleep(1 SECOND)

			var/turf/turfcheck = doturfcheck(1)
			if(!turfcheck)
				src.badreceive()
			else if(!is_allowed(turfcheck))
				boutput(usr, "Unknown interference prevents creation of a portal to or from that location!")
			else
				src.doubleportal(turfcheck)
			sleep(0.5 SECONDS)

			src.linked_pad.icon_state = "pad0"
			SPAWN_DBG(3.5 SECONDS)

			linked_pad.recharging = 0

			return

		else if (href_list["delportal"])
			if(!portals)
				boutput(usr, "No active portals detected!")
			else
				for(var/obj/P in portals)
					portals -= P //not sure if this is necessary. better safe than sorry
					qdel(P)
			return

		else
			usr.Browse(null, "window=t_computer")
			src.updateUsrDialog()
			return

	proc/updatereal()
		realx = (xtarget * XMULTIPLY) - XSUBTRACT
		realy = (ytarget * YMULTIPLY) - YSUBTRACT
		realz = ztarget - ZSUBTRACT

	proc/doturfcheck(var/notify_invalid)
		var/turf/realturf = null
		var/xisbad = (realx < 1 || realx > world.maxx) || (realx - round(realx) != 0) ? 1 : 0;
		var/yisbad = (realy < 1 || realy > world.maxy) || (realy - round(realy) != 0) ? 1 : 0;
		var/zisbad = (realz < 1 || realz > world.maxz) || (realz - round(realz) != 0) ? 1 : 0;
		if (!xisbad && !yisbad && !zisbad)
			realturf = locate(realx, realy, realz)
		if (notify_invalid)
			if (xisbad) boutput(usr, "<span style=\"color:red\">X coordinate invalid.</span>")
			if (yisbad) boutput(usr, "<span style=\"color:red\">Y coordinate invalid.</span>")
			if (zisbad) boutput(usr, "<span style=\"color:red\">Z coordinate invalid.</span>")
		return realturf

	proc/is_allowed(var/turf/T)
		// first check the always allowed turfs from map landmarks
		if (T in telesci)
			return 1

		//if (istype(T.loc,/area/wizard_station) || istype(T.loc, /area/evilreaver) || istype(T.loc, /area/abandonedship) || istype(T.loc,/area/syndicate_station) || istype(T.loc,/area/station/security) && !istype(T.loc,/area/station/security/brig) || istype(T.loc,/area/listeningpost) || istype(T.loc,/area/h7) || isrestrictedz(T.z))
		if (T.loc:teleport_blocked || isrestrictedz(T.z))
			return 0
		return 1

	proc/send(var/turf/target)
		if (!target)
			boutput(usr, "Unknown interference prevents teleportation to that location!")
			return
		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in src.linked_pad.loc)
			if(O.anchored) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			which.set_loc(target)
		showswirl(src.linked_pad.loc)
		showswirl(target)
		leaveresidual(target)
		use_power(1500)
		if((prob(2) && prob(2)) || ((usr.ckey in Dorks) && prob(10)))
			usr.visible_message("<span style=\"color:red\">The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN_DBG(1 SECOND) processbadeffect(pick("flash","buzz","scatter","ignite","chill"))
		/*if(prob(1) && !locate(/obj/dfissure_to) in get_step(src.linked_pad, EAST))
			new/obj/dfissure_to(get_step(src.linked_pad, EAST))*/ // why would anyone ever want to complete Hemera Station if spamming bad coords on this is so much easier

	proc/receive(var/turf/receiveturf)
		if(!receiveturf)
			boutput(usr, "Unknown interference prevents teleportation from that location!")
			return
		var/list/stuff = list()
		for(var/atom/movable/O as obj|mob in receiveturf)
			if(O.anchored) continue
			stuff.Add(O)
		if (stuff.len)
			var/atom/movable/which = pick(stuff)
			which.set_loc(src.linked_pad.loc)
		showswirl(src.linked_pad.loc)
		showswirl(receiveturf)
		use_power(1500)
		if((prob(2) && prob(2)) || ((usr.ckey in Dorks) && prob(10)))
			usr.visible_message("<span style=\"color:red\">The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN_DBG(0.5 SECONDS) processbadeffect(pick("flash","buzz","minorsummon","tinyfire","chill"))

	proc/doubleportal(var/turf/target)
		if (!target)
			boutput(usr, "Unknown interference prevents teleportation to that location!")
			return
		var/list/send = list()
		var/list/receive = list()
		for(var/atom/movable/O as obj|mob in src.linked_pad.loc)
			if(O.anchored) continue
			send.Add(O)
		for(var/atom/movable/O as obj|mob in target)
			if(O.anchored) continue
			receive.Add(O)
		for(var/atom/movable/O in send)
			O.set_loc(target)
		for(var/atom/movable/O in receive)
			O.set_loc(src.linked_pad.loc)
		showswirl(src.linked_pad.loc)
		showswirl(target)
		use_power(500000)
		if(prob(2))
			usr.visible_message("<span style=\"color:red\">The console emits a loud pop and an acrid smell fills the air!</span>")
			XSUBTRACT = rand(0,100)
			YSUBTRACT = rand(0,100)
			ZSUBTRACT = rand(0,world.maxz)
			SPAWN_DBG(1 SECOND) processbadeffect(pick("flash","buzz","scatter","ignite","chill"))
		if(prob(5) && !locate(/obj/dfissure_to) in get_step(src.linked_pad, EAST))
			new/obj/dfissure_to(get_step(src.linked_pad, EAST))
		else
			makeportal(src.linked_pad.loc, target)
			makeportal(target, src.linked_pad.loc)

	proc/makeportal(var/turf/target,var/turf/location)
		var/obj/perm_portal/P = new/obj/perm_portal(location)
		P.target = target
		maintainportal(P)
		portals += P

	proc/maintainportal(var/obj/perm_portal/P)
		if(!P) return
		if(status & (NOPOWER|BROKEN))
			badreceive()
			portals -= P
			qdel(P)
			return
		use_power(25000)
		if(prob(1)) badreceive()
		SPAWN_DBG(1 SECOND)
			maintainportal(P)

	proc/badsend()
		showswirl(src.linked_pad.loc)

		var/effect = ""
		if(prob(90)) //MINOR EFFECTS
			effect = pick("flash","buzz","scatter","ignite","chill")
		else if(prob(80)) //MEDIUM EFFECTS
			effect = pick("tempblind","minormutate","sorium","rads","fire","widescatter","brute")
		else //MAJOR EFFECTS
			effect = pick("gib","majormutate","mutatearea","fullscatter")
		processbadeffect(effect)

	proc/badreceive()
		showswirl(src.linked_pad.loc)

		var/effect = ""
		if(prob(80)) //MINOR EFFECTS
			effect = pick("flash","buzz","minorsummon","tinyfire","chill")
		else if(prob(80)) //MEDIUM EFFECTS
			effect = pick("mediumsummon","sorium","rads","fire","getrandom")
		else //MAJOR EFFECTS
			effect = pick("mutatearea","areascatter","majorsummon")
		processbadeffect(effect)

	proc/processbadeffect(var/effect)
		switch(effect)
			if("")
				return
			if("flash")
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">A bright flash emnates from the [src.linked_pad]!</span>", 1)
				playsound(src.linked_pad.loc, "sound/weapons/flashbang.ogg", 50, 1)
				for(var/mob/N in viewers(src.linked_pad, null))
					if(get_dist(N, src.linked_pad) <= 6)
						N.flash(3 SECONDS)
						N.weakened = max(N.weakened, 5)
					if(N.client) shake_camera(N, 6, 4)
				return
			if("buzz")
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">You hear a loud buzz coming from the [src.linked_pad]!</span>", 1)
				playsound(src.linked_pad.loc, "sound/machines/buzz-sigh.ogg", 50, 1)
				return
			if("scatter") //stolen from hand tele, heh
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(5,src.linked_pad.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_allowed(T))
						turfs += T
				if(turfs && turfs.len)
					for(var/atom/movable/O as obj|mob in src.linked_pad.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("ignite")
				for(var/mob/living/carbon/M in src.linked_pad.loc)
					M.update_burning(30)
					boutput(M, "<span style=\"color:red\">You catch fire!</span>")
				return
			if("chill")
				for(var/mob/living/carbon/M in src.linked_pad.loc)
					M.bodytemperature -= 100
					boutput(M, "<span style=\"color:red\">You feel colder!</span>")
				return
			if("tempblind")
				for(var/mob/living/carbon/M in src.linked_pad.loc)
					M.eye_blind += 10
					boutput(M, "<span style=\"color:red\">You can't see anything!</span>")
				return
			if("minormutate")
				for(var/mob/living/carbon/M in src.linked_pad.loc)
					M:bioHolder:RandomEffect("bad")
				return
			if("sorium") // stolen from sorium, obviously
				explosion(src, src.linked_pad.loc, -1, -1, -1, 4)
				var/myturf = src.linked_pad.loc
				for(var/atom/movable/M in view(4, myturf))
					if(M.anchored) continue
					if(ismob(M)) if(hasvar(M,"weakened")) M:weakened += 8
					if(ismob(M)) random_brute_damage(M, 20)
					var/dir_away = get_dir(myturf,M)
					var/turf/target = get_step(myturf,dir_away)
					M.throw_at(target, 10, 2)
				return
			if("rads")
				for(var/turf/T in view(5,src.linked_pad.loc))
					if(!T.reagents)
						var/datum/reagents/R = new/datum/reagents(1000)
						T.reagents = R
						R.my_atom = T
					T.reagents.add_reagent("radium", 20)
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">The area surrounding the [src.linked_pad] begins to glow bright green!</span>", 1)
				return
			if("fire")
				fireflash(src.linked_pad.loc, 6) // cogwerks - lowered from 8, too laggy
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">A huge wave of fire explodes out from the [src.linked_pad]!</span>", 1)
				return
			if("widescatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(30,src.linked_pad.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_allowed(T))
						turfs += T
				if(turfs && turfs.len)
					for(var/atom/movable/O as obj|mob in src.linked_pad.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("brute")
				for(var/mob/living/M in src.linked_pad.loc)
					M.TakeDamage("chest", rand(20,30), 0)
					boutput(M, "<span style=\"color:red\">You feel like you're being pulled apart!</span>")
				return
			if("gib")
				for(var/mob/living/M in src.linked_pad.loc)
					M.gib()
				return
			if("majormutate")
				for(var/mob/living/carbon/M in src.linked_pad.loc)
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
					M:bioHolder:RandomEffect("bad")
				return
			if("mutatearea")
				for(var/mob/living/carbon/M in orange(5,src.linked_pad.loc))
					M:bioHolder:RandomEffect("bad")
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">A bright green pulse emnates from the [src.linked_pad]!</span>", 1)
				return
			if("explosion")
				explosion(src, src.linked_pad.loc, 0, 0, 5, 10)
				return
			if("fullscatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in world)
					LAGCHECK(LAG_LOW)
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_allowed(T))
						turfs += T
				if(turfs && turfs.len)
					for(var/atom/movable/O as obj|mob in src.linked_pad.loc)
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("minorsummon")
				var/summon = pick("pig","mouse","roach","rockworm")
				switch(summon)
					if("pig")
						var/obj/critter/pig/P = new /obj/critter/pig
						P.set_loc(src.linked_pad.loc)
					if("mouse")
						for(var/i=1,i<rand(1,3),i++)
							var/obj/critter/mouse/M = new /obj/critter/mouse
							M.set_loc(src.linked_pad.loc)
							i ++
					if("roach")
						for(var/i=1,i<rand(3,8),i++)
							var/obj/critter/roach/R = new /obj/critter/roach
							R.set_loc(src.linked_pad.loc)
							i ++
				return
			if("tinyfire")
				fireflash(src.linked_pad.loc, 3)
				for(var/mob/O in AIviewers(src.linked_pad, null)) O.show_message("<span style=\"color:red\">The area surrounding the [src.linked_pad] bursts into flame!</span>", 1)
				return
			if("mediumsummon")
				var/summon = pick("maneater","killertomato","bee","golem","magiczombie","mimic")
				switch(summon)
					if("maneater")
						var/obj/critter/maneater/P = new /obj/critter/maneater
						P.set_loc(src.linked_pad.loc)
					if("killertomato")
						var/obj/critter/killertomato/P = new /obj/critter/killertomato
						P.set_loc(src.linked_pad.loc)
					if("bee")
						var/obj/critter/spacebee/P = new /obj/critter/spacebee
						P.set_loc(src.linked_pad.loc)
					if("golem")
						var/obj/critter/golem/P = new /obj/critter/golem
						P.set_loc(src.linked_pad.loc)
					if("magiczombie")
						var/obj/critter/magiczombie/P = new /obj/critter/magiczombie
						P.set_loc(src.linked_pad.loc)
					if("mimic")
						var/obj/critter/mimic/P = new /obj/critter/mimic
						P.set_loc(src.linked_pad.loc)
					//if("mimic2") // Not much of a mimic. Doesn't use the current toolbox sprite (Convair880).
					//	var/obj/critter/mimic2/P = new /obj/critter/mimic2
					//	P.set_loc(src.linked_pad.loc)
				return
			if("getrandom")
				var/turfs = list()
				for(var/turf/T in world)
					LAGCHECK(LAG_LOW)
					if(!contents) continue
					turfs += T
				var/turf = pick(turfs)
				for(var/atom/movable/O as obj|mob in turf)
					O.set_loc(src.linked_pad.loc)
				return
			if("areascatter")
				var/list/turfs = new
				var/turf/target = null
				for(var/turf/T in orange(10,src.linked_pad.loc))
					if(T.x>world.maxx-4 || T.x<4)	continue
					if(T.y>world.maxy-4 || T.y<4)	continue
					if (is_allowed(T))
						turfs += T
				if (turfs && turfs.len)
					for(var/atom/movable/O as obj|mob in oview(src.linked_pad,5))
						if(O.anchored) continue
						target = pick(turfs)
						if(target) O.set_loc(target)
				qdel(turfs)
				return
			if("majorsummon")
				var/summon = pick("zombie","bear","syndicate","martian","lion","yeti","drone","ancient")
				switch(summon)
					if("maneater")
						var/obj/critter/zombie/P = new /obj/critter/zombie
						P.set_loc(src.linked_pad.loc)
					if("bear")
						var/obj/critter/bear/P = new /obj/critter/bear
						P.set_loc(src.linked_pad.loc)
					if("syndicate")
						var/mob/living/carbon/human/npc/syndicate/P = new /mob/living/carbon/human/npc/syndicate
						P.set_loc(src.linked_pad.loc)
					if("martian")
						var/obj/critter/martian/soldier/P = new /obj/critter/martian/soldier
						P.set_loc(src.linked_pad.loc)
					if("lion")
						var/obj/critter/lion/P = new /obj/critter/lion
						P.set_loc(src.linked_pad.loc)
					if("yeti")
						var/obj/critter/yeti/P = new /obj/critter/yeti
						P.set_loc(src.linked_pad.loc)
					if("drone")
						var/obj/critter/gunbot/drone/P = new /obj/critter/gunbot/drone
						P.set_loc(src.linked_pad.loc)
					if("ancient")
						var/obj/critter/ancient_thing/P = new /obj/critter/ancient_thing
						P.set_loc(src.linked_pad.loc)
				return

/obj/machinery/science_teleport_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = 1
	layer = FLOOR_EQUIP_LAYER1
	mats = 16
	desc = "Stand on this to have your wildest dreams come true!"
	var/recharging = 0

	process()
		if(status & (NOPOWER|BROKEN))
			return
		use_power(500)
*/
