//DEFINES ETC

/obj/machinery/engine_laser_spawner
	name = "Engine Laser Emitter"
	desc = "This is what it is."
	icon = 'engine_stuff.dmi'
	icon_state = "engine_laser_spawner0"
	machine_registry_idx = MACHINES_MISC
	var/obj/beam/engine_laser/first = null
	var/id = 1
	var/state = 0.0
	var/energy = 0
	var/health = 100
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 150

/obj/beam/engine_laser
	name = "engine laser"
	icon = 'engine_stuff.dmi'
	icon_state = "engine_laser"
	var/obj/beam/engine_laser/next = null
	var/obj/machinery/engine_laser_spawner/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	var/energy = 20
	anchored = 1.0
	flags = TABLEPASS

/obj/beam/focused_laser
	name = "focused laser"
	icon = 'engine_stuff.dmi'
	icon_state = "focused_laser"
	var/obj/beam/focused_laser/next = null
	var/obj/machinery/focusing_mirror/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	var/energy = 0
	anchored = 1.0
	flags = TABLEPASS

/obj/machinery/focusing_mirror
	name = "focusing mirror"
	icon = 'engine_stuff.dmi'
	icon_state = "focus_mirror"
	var/obj/beam/focused_laser/first = null
	var/b_number = 0
	var/energy = 0
	var/on = 1
	density = 0

/obj/machinery/computer/laser_computer
	name = "laser computer"
	icon = 'engine_stuff.dmi'
	icon_state = "laser_computer"
	var/id = 1
	var/list/emitters = list()
	var/pattern = "Single"
	var/started = 0


///////////////////////////////////////////////
// MIRROR STUFF
//////////////////////////////////////////////

/obj/machinery/focusing_mirror/proc/opp_dir(var/dir)
	if(dir == 1)
		return 2
	if(dir == 2)
		return 1
	if(dir == 3)
		return 4
	if(dir == 4)
		return 3
	if(dir == 5)
		return 8
	if(dir == 6)
		return 7
	if(dir == 7)
		return 6
	if(dir == 8)
		return 5

/obj/machinery/focusing_mirror/process()
	if(src.on && src.b_number)
		src.shoot()
		src.b_number = 0
		src.energy = 0
		return
	else
		qdel(src.first)



/obj/machinery/focusing_mirror/proc/shoot()
	if(!b_number)
		qdel(src.first)
		return null
	if(src.first)
		return
	var/obj/beam/focused_laser/I = new /obj/beam/focused_laser( (src.loc) )
	I.master = src
	I.set_density(1)
	I.set_dir(opp_dir(src.dir))
	I.energy = src.energy
	step(I, I.dir)
	if (I)
		I.set_dir(opp_dir(src.dir))
		I.set_density(0)
		src.first = I
		I.vis_spread(1)
		SPAWN_DBG( 0 )
			if (I)
				I.limit = 20
				I.process()
			return
	if (!( b_number ))
		qdel(src.first)
	src.b_number = 0
	return


/obj/machinery/focusing_mirror/proc/hit()
	return

/////////////////////////////////////////////
// MIRROR LASER BEAM STUFF
/////////////////////////////////////////////


/obj/beam/focused_laser/proc/hit()
	if (src.master)
		src.master.hit()
	qdel(src)
	return

/obj/beam/focused_laser/proc/vis_spread(v)
	src.visible = v
	SPAWN_DBG( 0 )
		if (src.next)
			src.next.vis_spread(v)
		return
	return

/obj/beam/focused_laser/proc/process()
	if ((src.loc.density || !( src.master )))
		qdel(src)
		return

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0

	var/obj/beam/focused_laser/I = new /obj/beam/focused_laser( src.loc )
	I.master = src.master
	//I.set_density(1)
	I.set_dir(src.dir)
	I.energy = src.energy
	step(I, I.dir)

	if (I)
		if (!( src.next ) && I)
			I.set_dir(src.dir)
			I.set_density(0)
			I.vis_spread(src.visible)
			src.next = I
			SPAWN_DBG( 0 )
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					I.process()
				return
		else
			if(I)
				qdel(I)
	else
		qdel(src.next)
	SPAWN_DBG( 10 )
		src.process()
		return
	return

/obj/beam/focused_laser/Bump()
	qdel(src)
	return

/obj/beam/focused_laser/Bumped()
	src.hit()
	return

/obj/beam/focused_laser/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	SPAWN_DBG( 0 )
		src.hit()
		return
	return

/obj/beam/focused_laser/disposing()
	if (src.next)
		src.next.dispose()
		src.next = null
	..()
	return



/////////////////////////////////////////////
// ENGINE LASER BEAM STUFF
/////////////////////////////////////////////


/obj/beam/engine_laser/proc/hit()
	if (src.master)
		src.master.hit()
	qdel(src)
	return

/obj/beam/engine_laser/proc/vis_spread(v)
	src.visible = v
	SPAWN_DBG( 0 )
		if (src.next)
			src.next.vis_spread(v)
		return
	return

/obj/beam/engine_laser/proc/process()

	if ((src.loc.density || !( src.master )))
		qdel(src)
		return

	if (src.left > 0)
		src.left--
	if (src.left < 1)
		if (!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0

	var/obj/beam/engine_laser/I = new /obj/beam/engine_laser( src.loc )
	I.master = src.master
	//I.set_density(1)
	I.set_dir(src.dir)
	I.energy = src.energy
	step(I, I.dir)

	if (I)
		for(var/obj/machinery/focusing_mirror/M in I.loc)
			if(I.dir != M.dir)
				M.b_number++
				M.energy += I.energy
			qdel(src.next)
			qdel(I)
			break
		if (!( src.next ) && I)
			I.set_dir(src.dir)
			I.set_density(0)
			I.vis_spread(src.visible)
			src.next = I
			SPAWN_DBG( 0 )
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					I.process()
				return
		else
			if(I)
				qdel(I)
	else
		qdel(src.next)
	SPAWN_DBG( 10 )
		src.process()
		return
	return

/obj/beam/engine_laser/Bump()
	qdel(src)
	return

/obj/beam/engine_laser/Bumped()
	src.hit()
	return

/obj/beam/engine_laser/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	SPAWN_DBG( 0 )
		src.hit()
		return
	return

/obj/beam/engine_laser/disposing()
	if (src.next)
		src.next.dispose()
		src.next = null
	..()
	return


//////////////////////////////////////////
// LASER SPAWNER STUFF
//////////////////////////////////////////

/obj/machinery/engine_laser_spawner/proc/hit()
	return

/obj/machinery/engine_laser_spawner/process()
	if(!state)
		qdel(src.first)
		return null

	if ((!( src.first ) && (src.state && (istype(src.loc, /turf)))))
		var/obj/beam/engine_laser/I = new /obj/beam/engine_laser( (src.loc) )
		I.master = src
		I.set_density(1)
		I.set_dir(src.dir)
		step(I, I.dir)
		if (I)
			I.set_dir(src.dir)
			I.set_density(0)
			src.first = I
			I.vis_spread(1)
			SPAWN_DBG( 0 )
				if (I)
					I.limit = 20
					I.process()
				return
	if (!( src.state ))
		qdel(src.first)
	SPAWN_DBG(0.3 SECONDS)
		src.state = 0
	return

/obj/machinery/engine_laser_spawner/attack_hand()
	qdel(src.first)
	..()
	return

/obj/machinery/engine_laser_spawner/Move()
	var/t = src.dir
	..()
	src.set_dir(t)
	qdel(src.first)
	return

/obj/machinery/engine_laser_spawner/verb/rotate()
	set src in usr

	src.set_dir(turn(src.dir, 45))
	return





//////////////////////////////////////////
// COMPUTER STUFF
//////////////////////////////////////////



/obj/machinery/computer/laser_computer/New()
	..()
	SPAWN_DBG(10 SECONDS)
		for(var/obj/machinery/engine_laser_spawner/M in machine_registry[MACHINES_MISC])
			if(src.id == M.id)
				src.emitters += M

/obj/machinery/computer/laser_computer/attack_ai(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/laser_computer/attack_hand(mob/user)
	add_fingerprint(user)
	if(status & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/laser_computer/proc/interact(mob/user)
	src.add_dialog(user)
	var/polledemitters
	for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
		if(M.health < 20)
			polledemitters += "<FONT color = 'red'>"
		polledemitters += "<BR>[M]<FONT color = 'black'>"
		if(M.state)
			polledemitters += "<FONT color = 'red'> Firing<FONT color = 'black'>"
	var/dat = text({"<TT>
<TT><B><FONT color = 'blue'>Loaded Laser Emitter Control Computer</B></TT><BR><BR>
<B><FONT color = 'black'>Emitters: [polledemitters] </B><BR>
Test: []<BR>
Start Pattern: []<BR>
Stop Pattern: []<BR>
Firing Pattern: []"},
text("<A href='?src=\ref[];testfire=1'>Fire</A>", src),
text("<A href='?src=\ref[];realfire=1'>Fire</A>", src),
text("<A href='?src=\ref[];stop=1'>Stop</A>", src),
text("<A href='?src=\ref[];pattern=1'>[src.pattern]</A>", src))
	user << browse("<HEAD><TITLE>Laser Emitter Control Computer</TITLE></HEAD>[dat]", "window=lasercomputer")
	onclose(user, "lasercomputer")
	return

/obj/machinery/computer/laser_computer/Topic(href, href_list)
	boutput(world, "Topic, [href_list]")
	src.add_dialog(usr)
	if (href_list["testfire"])
		if(!src.started)
			src.testfire()
	if (href_list["realfire"])
		src.started = 1
		src.realfire()
	if (href_list["stop"])
		src.started = 0
	if (href_list["pattern"])
		if(src.pattern == "Single")
			src.pattern = "Double"
		else if(src.pattern == "Double")
			src.pattern = "Quad"
		else
			src.pattern = "Single"
	if (ismob(src.loc))
		attack_hand(src.loc)
		return

/obj/machinery/computer/laser_computer/proc/testfire()
	SPAWN_DBG(0)
		if(src.pattern == "Single")
			for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
				M.state = 1
				sleep(3 SECONDS)
		else if(src.pattern == "Double")
			var/double = 0
			for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
				M.state = 1
				if(double)
					sleep(2 SECONDS)
					double = 0
				else
					double = 1
		else
			for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
				M.state = 1

/obj/machinery/computer/laser_computer/proc/realfire()
	SPAWN_DBG(0)
		while(src.started)
			if(src.pattern == "Single")
				for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
					M.state = 1
					sleep(3 SECONDS)
			else if(src.pattern == "Double")
				var/double = 0
				for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
					M.state = 1
					if(double)
						sleep(3 SECONDS)
						double = 0
					else
						double = 1
			else
				for(var/obj/machinery/engine_laser_spawner/M in src.emitters)
					M.state = 1
				sleep(3 SECONDS)


/obj/machinery/computer/laser_computer/process()
	SPAWN_DBG(0.2 SECONDS)
		src.updateDialog()

