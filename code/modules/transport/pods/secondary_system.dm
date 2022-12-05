/obj/item/shipcomponent/secondary_system
	name = "Secondary System"
	desc = "Add functionality to the ship"
	power_used = 0
	system = "Secondary System"
	var/f_active = 0 //1 if use proc activates/deactivates the systems.
	var/hud_state = "blank"
	icon_state= "sec_system"

	proc/Use(mob/user as mob)
		boutput(user, "[ship.ship_message("No special function for this ship!")]")
		return

	proc/Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
		return

	proc/Clickdrag_ObjectToPod(var/mob/living/user,var/atom/A)
		return

/obj/item/shipcomponent/secondary_system/cloak
	name = "Medusa Stealth System 300"
	desc = "When activated cloaks the ship."
	power_used = 250
	hud_state = "cloak"
	f_active = 1
	var/image/shield = null
	icon_state= "medusa"

	Use(mob/user as mob)
		if(!active)
			activate()
		else
			deactivate()
		return

	activate()
		..()
		if(!active)
			return
		ship.invisibility = INVIS_CLOAK
		shield = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)
		ship.overlays += shield
		return

	deactivate()
		..()
		ship.invisibility = INVIS_NONE
		ship.overlays -= shield
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<B>SYSTEM ONLINE</B>"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

/obj/item/shipcomponent/secondary_system/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	desc = "Allows the ship to scoop up ore automatically."
	var/capacity = 300
	hud_state = "cargo"
	f_active = 1
	icon_state= "ore_hold"

	Use(mob/user as mob)
		activate()
		return

	activate()
		boutput(usr, "[ship.ship_message("To unload, click and drag the pod onto a nearby tile.")]")
		return

	deactivate()
		return

	on_shipdeath(var/obj/machinery/vehicle/ship)
		if (ship)
			SPAWN(1 SECOND)	//idk so it doesn't get caught on big pods when they are still aorund...
				for (var/obj/O in src.contents)
					O.set_loc(get_turf(ship))
					O.throw_at(get_edge_target_turf(O, pick(alldirs)), rand(1,3), 3)

		..()

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		dat += {"<BR><B>Capacity: [src.contents.len]/[src.capacity]</B><HR>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

	Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
		if (contents.len < 1)
			boutput(user, "<span class='alert'>[src] has nothing to unload.</span>")
			return

		var/turf/T = get_turf(A)

		var/inrange = 0
		for(var/turf/ST in src.ship.locs)
			if (BOUNDS_DIST(T, ST) == 0)
				inrange = 1
				break
		if (!inrange)
			boutput(user, "<span class='alert'>That tile too far away.</span>")
			return

		for(var/obj/O in T.contents)
			if(O.density)
				boutput(user, "<span class='alert'>That tile is blocked by [O].</span>")
				return

		for(var/obj/item/I in src.contents)
			I.set_loc(T)
		return

/obj/item/shipcomponent/secondary_system/cargo
	name = "Cargo Hold"
	desc = "Allows the ship to load crates and transport them. One of Tradecraft Seneca's best sellers."
	var/list/load = list() //Current crates inside
	var/maxcap = 3 //how many crates it can hold
	var/list/acceptable = list(/obj/storage/crate,
	/obj/storage/secure/crate,
	/obj/machinery/artifact,
	/obj/artifact,
	/obj/mopbucket,
	/obj/beacon_deployer,
	/obj/machinery/portable_atmospherics,
	/obj/machinery/space_heater,
	/obj/machinery/oreaccumulator,
	/obj/machinery/bot,
	/obj/machinery/nuclearbomb,
	/obj/bomb_decoy)

	hud_state = "cargo"
	f_active = 1

	small
		maxcap = 1
		name = "Small Cargo Hold"

	Exited(Obj, newloc)
		. = ..()
		src.load -= Obj

/obj/item/shipcomponent/secondary_system/cargo/Use(mob/user as mob)
	activate()
	return

/obj/item/shipcomponent/secondary_system/cargo/deactivate()
	for(var/atom/movable/O in load) //Drop cargo.
		src.unload(O)
	return

/obj/item/shipcomponent/secondary_system/cargo/activate()
	var/loadmode = tgui_input_list(usr, "Unload/Load", "Unload/Load", list("Load", "Unload"))
	switch(loadmode)
		if("Load")
			var/atom/movable/AM = null
			for(var/atom/movable/A in get_step(ship.loc, turn(ship.dir,180) ))
				if(!A.anchored)
					AM = A
					break
			if(AM)
				load(AM)
			return
		if("Unload")
			var/crate
			if (load.len == 1)
				crate = load[1]
			else
				crate = input(usr, "Choose which cargo to unload..", "Choose cargo")  as null|anything in load
			if(!crate)
				return
			unload(crate)
		else
			return
	return

/obj/item/shipcomponent/secondary_system/cargo/opencomputer(mob/user as mob)
	if(user.loc != src.ship)
		return
	src.add_dialog(user)

	var/dat = {"<TT><B>[src] Console</B><BR><HR><BR>
				<BR><B>Current Contents:</B><HR>"}
	for(var/cargoitem in load)
		dat += {"<BR><B>[cargoitem]</B><HR>
				<BR>"}
	user.Browse(dat, "window=ship_sec_system")
	onclose(user, "ship_sec_system")
	return

/obj/item/shipcomponent/secondary_system/cargo/Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
	if (!length(src.load))
		boutput(user, "<span class='alert'>[src] has nothing to unload.</span>")
		return
	var/turf/T = get_turf(A)

	var/inrange = 0
	for(var/turf/ST in src.ship.locs)
		if (in_interact_range(T,ST) && in_interact_range(user,ST))
			inrange = 1
			break
	if (!inrange)
		boutput(user, "<span class='alert'>That tile too far away.</span>")
		return

	for(var/obj/O in T.contents)
		if(O.density)
			boutput(user, "<span class='alert'>That tile is blocked by [O].</span>")
			return

	var/crate = input(user, "Choose which cargo to unload..", "Choose cargo")  as null|anything in load
	if(!crate)
		return
	unload(crate,T)
	return

/obj/item/shipcomponent/secondary_system/cargo/Clickdrag_ObjectToPod(var/mob/living/user,var/atom/A)
	if (length(src.load) > src.maxcap)
		boutput(user, "<span class='alert'>[src] has no available cargo space.</span>")
		return

	switch(src.load(A))
		if (1)
			// if cargo system is not emagged, only allow crates to be loaded
			boutput(user, "<span class='alert'>The pod's cargo autoloader rejects [A].</span>")
			return
		if (2)
			// cargo system full (this should never happen)
			boutput(user, "<span class='alert'>[src] has no available cargo space.</span>")
			return
		if (3)
			// out of range (this should never happen)
			boutput(user, "<span class='alert'>Something is too far away to do that.</span>")
			return
		if (0)
			// success
			src.visible_message("<span style=\"color:blue\">[user] loads the [A] into [src]'s cargo bay.</span>")
			return

	boutput(user, "<span class='alert'>[src] has no cargo system or no available cargo space.</span>")
	return

/obj/item/shipcomponent/secondary_system/cargo/proc/load(var/atom/movable/C)
	if(length(src.load) >= maxcap)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		boutput(usr, "[ship.ship_message("Cargo hold is full!")]")
		return 2

	var/inrange = 0
	for (var/turf/T in src.ship.locs)
		if (in_interact_range(T,C) && in_interact_range(usr,C))
			inrange = 1
			break
	if (!inrange)
		return 3

	// if a crate, close before loading
	var/obj/storage/crate/crate = C
	if(istype(crate))
		crate.close()

	var/acceptable_cargo = 0
	for(var/X in src.acceptable)
		if (istype(C,X))
			acceptable_cargo = 1
			break
	if (isliving(C))
		var/mob/living/L = C
		if(isdead(L))
			acceptable_cargo = 1
	if (!acceptable_cargo)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return 1 // invalid cargo

	C.set_loc(src)
	load += C
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
	return 0

/obj/item/shipcomponent/secondary_system/cargo/proc/unload(var/atom/movable/C,var/turf/T)
	if(!C || !(C in load))
		return

	if(T)
		C.set_loc(T)
	else
		C.set_loc(ship.loc)
	step(C, turn(ship.dir,180))
	return C

/obj/item/shipcomponent/secondary_system/cargo/on_shipdeath(var/obj/machinery/vehicle/ship)
	while(length(load))
		var/obj/O = src.unload(pick(load))
		if (O)
			O.visible_message("<span class='alert'><b>[O]</b> is flung out of [src.ship]!</span>")
			O.throw_at(get_edge_target_turf(O, pick(alldirs)), rand(3,7), 3)
		else
			break
	..()


/obj/item/shipcomponent/secondary_system/tractor_beam
	name = "Tri-Corp Tractor Beam"
	desc = "Allows the ship to pull objects towards it"
	var/atom/movable/target = null //how many crates it can hold
	var/seekrange = 10
	var/settingup = 1
	var/image/tractor = null
	f_active = 1
	power_used = 80
	hud_state = "tractor_beam"
	icon_state= "trac_beam"

	run_component()
		if(settingup)
			return
		if(target in view(src.seekrange,ship.loc))
			step_to(target, ship, 1)
			return
		deactivate()
		return

	Use(mob/user as mob)
		if(!active)
			activate()
		else
			deactivate()
	activate()
		..()
		if(!active)
			return
		var/list/targets = list()
		for (var/atom/movable/a in view(src.seekrange,ship.loc))
			if(!a.anchored)
				targets += a

		target = input(usr, "Choose what to use the tractor beam on", "Choose Target")  as null|anything in targets

		if(!target)
			deactivate()
			return
		tractor = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "tractor", "layer" = FLOAT_LAYER)
		target.overlays += tractor
		settingup = 0
	deactivate()
		..()
		settingup = 1
		if(target)
			target.overlays -= tractor
			target = null
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<BR><B>Current Target</B>: [target]"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

/obj/item/shipcomponent/secondary_system/repair
	name = "Duracorp Construction Device"
	desc = "Gives ships the ability to repair external damage to space stations."
	var/list/load = list() //Current crates inside
	var/ammo = 30 //current ammo
	var/maxammo = 30 //max RCD ammo
	f_active = 1
	hud_state = "repair"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		return

	activate()
		var/repairmode = input(usr, "Please choose the function to use.", "Repair Mode")  as null|anything in list("Construct", "Repair", "Deconstruct")
		switch(repairmode)
			if("Construct")
				if(!ammo)
					return
				var/turf/T = get_turf(get_step(ship.loc, ship.dir))
				if (istype(T, /turf/space) && ammo >= 1)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					T:ReplaceWithFloor()
					ammo--
					return
				if (istype(T, /turf/simulated/floor) && ammo >= 3)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(20))
						T:ReplaceWithWall()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						ammo -= 3
					return

			if("Repair")
				for(var/obj/structure/girder/G in get_step(ship.loc, ship.dir))
					var/turf/T = get_turf(G.loc)
					qdel(G)
					T:ReplaceWithWall()
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					break
				return


			if("Deconstruct")
				var/turf/T = get_turf(get_step(ship.loc, ship.dir))
				if (istype(T, /turf/simulated/wall) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithFloor()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					return
				if ((istype(T, /turf/simulated/wall/r_wall) || istype(T, /turf/simulated/wall/auto/reinforced) ) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithWall()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

					return
				if (istype(T, /turf/simulated/floor) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithSpace()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<B>Current Ammo</B>:[src.ammo]/[src.maxammo]"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

/obj/item/shipcomponent/secondary_system/gps
	name = "Ship's Navigation GPS"
	desc = "A useful navigation device for those lost in space."
	f_active = 1
	power_used = 50
	icon_state= "ship_gps"

	Use(mob/user as mob)
		opencomputer(user)
		return
	opencomputer(mob/user as mob)
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		dat+=  {"<BR><B>Located at:</B><HR>
			<b>X</b>: [src.ship.x]<BR><b>Y</b>: [src.ship.y]"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")

/obj/item/shipcomponent/secondary_system/UFO
	name = "Abductor"
	desc = "Useful for abducting humans for experimentation"
	f_active = 1
	power_used = 50
	hud_state = "abductor"

	Use(mob/user as mob)
		var/mob/target = input(user, "Choose Who to Abduct", "Choose Target")  as mob in view(ship.loc)
		if(target)
			boutput(target, "<span class='alert'><B>You have been abducted!</B></span>")
			showswirl(get_turf(target))
			target.set_loc(ship)
		return

	opencomputer(mob/user as mob)
		var/dat = "<TT><B>[src] Console</B><BR><HR>"
		for(var/mob/M in ship)
			if(M == ship.pilot) continue
			dat +="<A href='?src=\ref[src];release=[M.name]'><B><U>[M.name]</U></B></A><BR>"
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)
		if (href_list["release"])
			for(var/mob/M in ship)
				if(cmptext(href_list["release"], M.name))
					var/list/turfs = get_area_turfs(/area/shuttle/arrival, 1)
					if (length(turfs))
						M.set_loc(pick(turfs))
						showswirl(get_turf(M))
		opencomputer(usr)
		return

/obj/item/shipcomponent/secondary_system/lock
	name = "Hatch Locking Unit"
	desc = "A basic hatch locking mechanism with keypad entry."
	system = "Lock"
	f_active = 1
	power_used = 0
	icon_state = "lock"
	var/code = ""
	var/configure_mode = 0 //If true, entering a valid code sets that as the code.

	disposing()
		if (ship)
			ship.locked = 0
			ship.lock = null

		..()

	deactivate()
		if (ship)
			ship.locked = 0

		if (!src.active)
			src.active = 0
			ship.powercurrent -= power_used

	Use(mob/user as mob)
		return show_lock_panel(user, 1)

	proc/show_lock_panel(mob/user)
		var/dat = {"
<!DOCTYPE html>
<head>
<title>Pod Locking Mechanism</title>
<style type="text/css">
	table.keypad, td.key
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		border:2px solid #1F1F1F;
		padding:10px;
		font-size:24px;
		font-weight:bold;
	}
	a
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		font-size:24px;
		font-weight:bold;
		border:2px solid #1F1F1F;
		text-decoration:none;
		display:block;
	}
</style>

</head>



<body bgcolor=#2F2F2F>
	<table border = 2 bgcolor=#7F3030 width = 150px>
		<tr><td><font face='system' size = 6 color=#FF0000 id = "readout">&nbsp;</font></td></tr>
	</table>
	<br>
	<table class = "keypad">
		<tr><td><a href='javascript:keypadIn(7);'>7</a></td><td><a href='javascript:keypadIn(8);'>8</a></td><td><a href='javascript:keypadIn(9);'>9</a></td></td><td><a href='javascript:keypadIn("A");'>A</a></td></tr>
		<tr><td><a href='javascript:keypadIn(4);'>4</a></td><td><a href='javascript:keypadIn(5);'>5</a></td><td><a href='javascript:keypadIn(6)'>6</a></td></td><td><a href='javascript:keypadIn("B");'>B</a></td></tr>
		<tr><td><a href='javascript:keypadIn(1);'>1</a></td><td><a href='javascript:keypadIn(2);'>2</a></td><td><a href='javascript:keypadIn(3)'>3</a></td></td><td><a href='javascript:keypadIn("C");'>C</a></td></tr>
		<tr><td><a href='javascript:keypadIn(0);'>0</a></td><td><a href='javascript:keypadIn("F");'>F</a></td><td><a href='javascript:keypadIn("E");'>E</a></td></td><td><a href='javascript:keypadIn("D");'>D</a></td></tr>

		<tr><td colspan=2 width = 100px><a id = "enterkey" href='?src=\ref[src];enter=0;'>ENTER</a></td><td colspan = 2 width = 100px><a href='javascript:keypadIn("reset");'>RESET</a></td></tr>
	</table>

<script language="JavaScript">
	var currentVal = "";

	function updateReadout(t, additive)
	{
		if ((additive != 1 && additive != "1") || currentVal == "")
		{
			document.getElementById("readout").innerHTML = "&nbsp;";
			currentVal = "";
		}
		var i = 0
		while (i++ < 4 && currentVal.length < 4)
		{
			if (t.length)
			{
				document.getElementById("readout").innerHTML += t.substr(0,1) + "&nbsp;";
				currentVal += t.substr(0,1);
				t = t.substr(1);
			}
		}

		document.getElementById("enterkey").setAttribute("href","?src=\ref[src];enter=" + currentVal + ";");
	}

	function keypadIn(num)
	{
		switch (num)
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				updateReadout(num.toString(), 1);
				break;

			case "A":
			case "B":
			case "C":
			case "D":
			case "E":
			case "F":
				updateReadout(num, 1);
				break;

			case "reset":
				updateReadout("", 0);
				break;
		}
	}

</script>

</body>"}

		usr << browse(dat, "window=ship_lock;size=270x300;can_resize=0;can_minimize=0")
		onclose(user, "ship_lock")

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(ship, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		if (href_list["enter"])
			if (configure_mode)
				var/new_code = uppertext(ckey(href_list["enter"]))
				if (!new_code || length(new_code) != 4 || !is_hex(new_code))
					usr << output("ERR!&0", "ship_lock.browser:updateReadout")
				else
					code = new_code
					configure_mode = 0
					usr << output("SET!&0", "ship_lock.browser:updateReadout")
					//if (ship)
					//	ship.access_computer(usr)

			else
				if (uppertext(href_list["enter"]) == src.code)
					usr << output("!OK!&0", "ship_lock.browser:updateReadout")
					if (ship)
						ship.locked = 0
						boutput(usr, "<span class='alert'>The lock mechanism clicks unlocked.</span>")
					//	ship.access_computer(usr)
				else
					usr << output("ERR!&0", "ship_lock.browser:updateReadout")
					var/code_attempt = uppertext(ckey(href_list["enter"]))
					/*
					Mastermind game in which the solution is "code" and the guess is "code_attempt"
					First go through the guess and find any with the exact same position as in the solution
					Increment rightplace when such occurs.
					Then go through the guess and, with each letter, go through all the letters of the solution code
					Increment wrongplace when such occurs.

					In both cases, add a power of two corresponding to the locations of the relevant letters
					This forms a set of flags which is checked whenever same-letters are found

					Once all of the guess has been iterated through for both rightplace and wrongplace, construct
					a beep/boop message dependant on what was gotten right.
					*/
					if (length(code_attempt) == 4)
						var/guessplace = 0
						var/codeplace = 0
						var/guessflags = 0
						var/codeflags = 0

						var/wrongplace = 0
						var/rightplace = 0
						while (++guessplace < 5)
							if ((((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, guessplace, guessplace + 1)))
								guessflags += 2 ** (guessplace-1)
								codeflags += 2 ** (guessplace-1)
								rightplace++

						guessplace = 0
						while (++guessplace < 5)
							codeplace = 0
							while(++codeplace < 5)
								if(guessplace != codeplace && (((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (((codeflags - codeflags % (2 ** (codeplace - 1))) / (2 ** (codeplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, codeplace , codeplace + 1)))
									guessflags += 2 ** (guessplace-1)
									codeflags += 2 ** (codeplace-1)
									wrongplace++
									codeplace = 5

						var/desctext = ""
						switch(rightplace)
							if (1)
								desctext += "a short beep"
							if (2)
								desctext += "a pair of short beeps"
							if (3)
								desctext += "a trio of short beeps"

						if (desctext && (wrongplace) > 0)
							desctext += " and "

						switch(wrongplace)
							if (1)
								desctext += "a short boop"
							if (2)
								desctext += "two warbly boops"
							if (3)
								desctext += "a quick three boops"
							if (4)
								desctext += "a rather long boop"

						if (desctext)
							boutput(usr, "<span class='alert'>The lock panel emits [desctext].</span>")

		else if (href_list["lock"])
			if  (usr.loc != src.ship)
				boutput(usr, "<span class='alert'>You must be inside the ship to do that!</span>")
				return

			if (ship && !ship.locked)
				ship.locked = 1
				boutput(usr, "<span class='alert'>The lock mechanism clunks locked.</span>")
				//ship.access_computer(usr)

		else if (href_list["unlock"])
			if  (usr.loc != src.ship)
				boutput(usr, "<span class='alert'>You must be inside the ship to do that!</span>")
				return

			if (ship?.locked)
				ship.locked = 0
				boutput(usr, "<span class='alert'>The ship mechanism clicks unlocked.</span>")
				//ship.access_computer(usr)

		else if (href_list["setcode"])
			if  (usr.loc != src.ship)
				boutput(usr, "<span class='alert'>You must be inside the ship to do that!</span>")
				return

			src.configure_mode = 1
			if (src.ship)
				src.ship.locked = 0
			src.code = ""

			boutput(usr, "Code reset.  Please type new code and press enter.")
			show_lock_panel(usr)

/obj/item/shipcomponent/secondary_system/crash
	name = "Syndicate Explosive Entry Device"
	desc = "The SEED that when explosively planted in a space station, lets you grow into the best death blossom you can be."
	f_active = 1
	power_used = 0
	var/crashable = 0
	var/crashhits = 10
	var/in_bump = 0
	hud_state = "seed"
	icon_state= "pod_seed"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		crashable = 0
		return

	activate()
		if (crashable == 0) // To avoid spam. SEEDs can't be deactivated (Convair880).
			logTheThing(LOG_VEHICLE, usr, "activates a SEED, turning [src.ship] into a flying bomb at [log_loc(src.ship)]. Direction: [dir2text(src.ship.dir)].")
		crashable = 1
		return

/obj/item/shipcomponent/secondary_system/crash/proc/dispense()
	for (var/mob/living/B in ship.contents)
		boutput(B, "<span class='alert'>You eject!</span>")
		ship.leave_pod(B)
		ship.visible_message("<span class='alert'>[B] launches out of the [ship]!</span>")
		step(B,ship.dir,0)
		step(B,ship.dir,0)
		step(B,ship.dir,0)
		step_rand(B, 0)
		//B.remove_shipcrewmember_powers(ship.weapon_class)
	for(var/obj/item/shipcomponent/SC in src)
		SC.on_shipdeath()
	SPAWN(0) //???? otherwise we runtime
		qdel(ship)

/obj/item/shipcomponent/secondary_system/crash/proc/crashtime2(atom/A as mob|obj|turf)
	if (in_bump)
		return
	if (A == ship.pilot)
		return
	walk(src, 0)
	in_bump = 1
	crashhits--
	if(isturf(A))
		if((istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced)) && prob(40))
			in_bump = 0
			return
		if(istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/T = A
			T.dismantle_wall(1)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			boutput(ship.pilot, "<span class='alert'><B>You crash through the wall!</B></span>")
			in_bump = 0
		if(istype(A, /turf/simulated/floor))
			var/turf/T = A
			if(prob(50))
				T.ReplaceWithLattice()
			else
				T.ReplaceWithSpace()
			if(prob(50))
				for (var/mob/M in src)
					shake_camera(M, 6, 8)
			if(prob(30))
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				boutput(ship.pilot, "<span class='alert'><B>You plow through the floor!</B></span>")
	if(ismob(A))
		var/mob/M = A
		boutput(ship.pilot, "<span class='alert'><B>You crash into [M]!</B></span>")
		shake_camera(M, 8, 16)
		boutput(M, "<span class='alert'><B>The [src] crashes into [M]!</B></span>")
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("weakened", 5 SECONDS)
		M.TakeDamageAccountArmor("chest", 20, damage_type = DAMAGE_BLUNT)
		var/turf/target = get_edge_target_turf(ship, ship.dir)
		M.throw_at(target, 4, 2)
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		in_bump = 0
	if(isobj(A))
		var/obj/O = A
		if(O.density && O.anchored != 2)
			boutput(ship.pilot, "<span class='alert'><B>You crash into [O]!</B></span>")
			boutput(O, "<span class='alert'><B>[ship] crashes into you!</B></span>")
			var/turf/target = get_edge_target_turf(ship, ship.dir)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			O.throw_at(target, 4, 2)
			O.anchored = 0
			if (istype(O, /obj/machinery/vehicle))
				A.meteorhit(src)
				crashhits -= 3
			if (istype(O, /obj/rack) || istype(O, /obj/table))
				A.meteorhit(src)
			if (istype(O, /obj/storage/closet) || istype(O, /obj/storage/secure/closet))
				O:dump_contents()
				qdel(O)
			if(istype(O, /obj/window))
				for(var/obj/grille/G in get_turf(O))
					qdel(G)
				qdel(O)
			if(istype(O, /obj/grille))
				for(var/obj/window/W in get_turf(O))
					qdel(W)
				qdel(O)
			if (istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
				qdel(O)
			if (istype(O, /obj/critter) && !istype(O, /obj/critter/gunbot/drone)) // ugly hack to make this not instakill drones and stuff
				O:CritterDeath()
			in_bump = 0
	if (crashhits <= 0)
		explosion(ship, ship.loc, 1, 2, 2, 3)
		playsound(ship.loc, "explosion", 50, 1)
		dispense()
	in_bump = 0
	return

/obj/item/shipcomponent/secondary_system/syndicate_rewind_system
	name = "Syndicate Rewind System"
	desc = "An unfinished pod system, the blueprints for which have been plundered from a raid on a now-destroyed Syndicate base. Requires a unique power source to function."
	power_used = 50
	f_active = 1
	hud_state = "SRS_icon"
	var/cooldown = 0
	var/core_inserted = false
	var/health_snapshot
	var/image/rewind
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state= "SRS_empty"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		return

	activate()
		if(!core_inserted)
			boutput(ship.pilot, "<span class='alert'><B>The system requires a unique power source to function!</B></span>")
			return
		else if(cooldown > TIME)
			boutput(ship.pilot, "<span class='alert'><B>The system is still recharging!</B></span>")
			return
		else
			boutput(ship.pilot, "<span class='alert'><B>Snapshot created!</B></span>")
			playsound(ship.loc, 'sound/machines/reprog.ogg', 75, 1)
			cooldown = 20 SECONDS + TIME
			health_snapshot = ship.health
			if(ship.capacity == 1 || istype(/obj/machinery/vehicle/miniputt, ship) || istype(/obj/machinery/vehicle/recon, ship) || istype(/obj/machinery/vehicle/cargo, ship))
				rewind = image('icons/misc/retribution/SWORD_loot.dmi', "SRS_o_small", "layer" = EFFECTS_LAYER_4)
			else
				rewind = image('icons/misc/retribution/64x64.dmi', "SRS_o_large", "layer" = EFFECTS_LAYER_4)
			rewind.plane = PLANE_SELFILLUM
			src.ship.UpdateOverlays(rewind, "rewind")

			spawn(5 SECONDS)
				spawn(1 SECONDS)
					src.ship.UpdateOverlays(null, "rewind")
				playsound(ship.loc, 'sound/machines/bweep.ogg', 75, 1)
				if(ship.health < health_snapshot)
					ship.health = health_snapshot
					boutput(ship.pilot, "<span class='alert'><B>Snapshot applied!</B></span>")
				else
					boutput(ship.pilot, "<span class='alert'><B>Snapshot discarded!</B></span>")
				return
		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W) && core_inserted)
			core_inserted = false
			set_icon_state("SRS_empty")
			user.put_in_hand_or_drop(new /obj/item/sword_core)
			user.show_message("<span class='notice'>You remove the SWORD core from the Syndicate Rewind System!</span>", 1)
			desc = "After a delay, rewinds the ship's integrity to the state it was in at the moment of activation. The core is missing."
			tooltip_rebuild = 1
			return
		else if ((istype(W,/obj/item/sword_core) && !core_inserted))
			core_inserted = true
			qdel(W)
			set_icon_state("SRS")
			user.show_message("<span class='notice'>You insert the SWORD core into the Syndicate Rewind System!</span>", 1)
			desc = "After a delay, rewinds the ship's integrity to the state it was in at the moment of activation. The core is installed."
			tooltip_rebuild = 1
			return
