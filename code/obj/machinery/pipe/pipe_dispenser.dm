
/obj/machinery/disposal_pipedispenser
	name = "Generic Pipe Dispenser"
	desc = "A retrofitted, old machine that dispenses atmospheric and disposal pipes."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "pipe-fab"
	density = 1
	anchored = 1
	mats = 16
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/dat

	var/static/list/pipesforcreation = list(
	"Pipe" = /obj/machinery/atmospherics/pipe/simple/overfloor,
	"Bent pipe" = /obj/machinery/atmospherics/pipe/simple/overfloor/bent,
	"Manifold" = /obj/machinery/atmospherics/pipe/manifold/overfloor,
	"Passive vent" = /obj/machinery/atmospherics/pipe/vent,
	"Pressure tank" = /obj/machinery/atmospherics/pipe/tank,
	"Passive gate" = /obj/machinery/atmospherics/binary/passive_gate,
	"Pressure pump" = /obj/machinery/atmospherics/binary/pump,
	"Volume pump" = /obj/machinery/atmospherics/binary/volume_pump,
	"Portable connector" = /obj/machinery/atmospherics/portables_connector,
	"Manual valve" = /obj/machinery/atmospherics/valve,
	"Digital valve" = /obj/machinery/atmospherics/valve/digital,
	"Furnace connector" = /obj/machinery/atmospherics/unary/furnace_connector,
	"Outlet Injector" = /obj/machinery/atmospherics/unary/outlet_injector,
	"Vent pump" = /obj/machinery/atmospherics/unary/vent_pump
	)

/obj/machinery/disposal_pipedispenser/New()
	..()

	dat = {"<b>Disposal Pipes</b><br><br>
		<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
		<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
		<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
		<A href='?src=\ref[src];dmake=3'>Y-Junction</A><BR>
		<A href='?src=\ref[src];dmake=4'>Trunk</A><BR>
		"}

	dat += "<BR><b>Atmospheric Pipes</b><br><br>"
	for (var/type in pipesforcreation)
		dat += "<A href='?src=\ref[src];atmosmake=[type]'>[type]</A><BR>"

/obj/machinery/disposal_pipedispenser/attack_hand(mob/user)
	if(..())
		return

	user.Browse("<HEAD><TITLE>Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk


/obj/machinery/disposal_pipedispenser/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	src.add_fingerprint(usr)
	if(href_list["dmake"])
		var/p_type = text2num_safe(href_list["dmake"])
		var/obj/disposalconstruct/C = new (src.loc)
		switch(p_type)
			if(0)
				C.ptype = 0
			if(1)
				C.ptype = 1
			if(2)
				C.ptype = 2
			if(3)
				C.ptype = 4
			if(4)
				C.ptype = 5

		C.update()

		usr.Browse(null, "window=pipedispenser")
		src.remove_dialog(usr)

	else if(href_list["atmosmake"])
		var/path = pipesforcreation[(href_list["atmosmake"])]
		var/obj/machinery/atmospherics/temp = new path()
		new /obj/item/pipeconstruct(src.loc, temp)
		qdel(temp)

		usr.Browse(null, "window=pipedispenser")
		src.remove_dialog(usr)

/obj/machinery/disposal_pipedispenser/mobile
	name = "Disposal Pipe Dispenser Cart"
	desc = "A tool for removing some of the tedium from pipe-laying."
	anchored = 0
	icon_state = "fab-mobile"
	mats = 16
	var/laying_pipe = 0
	var/removing_pipe = 0
	var/prev_dir = 0
	var/first_step = 0

	Move(var/turf/new_loc,direction)
		var/old_loc = loc
		. = ..()
		if(!(direction in cardinal)) // cardinal sin
			return
		if(old_loc != loc)
			if(src.laying_pipe)
				src.lay_pipe(old_loc, prev_dir, direction)
				src.connect_pipe(new_loc, turn(direction, 180))
			else if(src.removing_pipe)
				if(!new_loc.intact || istype(new_loc,/turf/space))
					for(var/obj/disposalpipe/pipe in old_loc)
						qdel(pipe)
			prev_dir = direction // might want to actually do this even when old_loc == loc but idk, it sucks with attempted diagonal movement

	proc/connect_pipe(var/turf/new_loc, var/new_dir)
		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/disposalpipe/pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			else if(avail_dirs.len >= 2)
				backup_pipe = D
			else if(avail_dirs.len == 0)
				backup_backup_pipe = D
		if(!pipe)
			pipe = backup_pipe
		if(!pipe)
			pipe = backup_backup_pipe
		if(!pipe)
			return
		if(new_dir & free_dirs)
			pipe_reconnect_disconnected(pipe, new_dir, 1)

	// look I didn't want to duplicate all this code either, I'm sorry :(
	proc/lay_pipe(var/turf/new_loc, var/old_dir, var/new_dir)
		var/is_first = src.first_step
		src.first_step = 0

		if(new_loc.intact && !istype(new_loc,/turf/space))
			return

		var/obj/disposalpipe/junction/junction = locate(/obj/disposalpipe/junction) in new_loc
		if(junction)
			if(new_dir & junction.dpdir)
				junction.set_dir(new_dir)
				junction.fix_sprite()
				return

		var/free_dirs = 1 | 2 | 4 | 8
		var/obj/disposalpipe/new_pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			else if(avail_dirs.len == 1)
				new_pipe = D
				break
			else if(avail_dirs.len >= 2)
				backup_pipe = D
			else if(avail_dirs.len == 0)
				backup_backup_pipe = D
		if(!new_pipe)
			new_pipe = backup_pipe
		if(!new_pipe)
			new_pipe = backup_backup_pipe
		if(!new_pipe && is_first)
			new_pipe = new/obj/disposalpipe/trunk(new_loc)
			new_pipe.set_dir(new_dir)
			new_pipe.dpdir = new_pipe.dir
			var/obj/disposalpipe/trunk/trunk = new_pipe
			trunk.getlinked()
			return
		else if(!new_pipe)
			var/new_pipe_dirs = new_dir | turn(old_dir, 180)
			if(new_pipe_dirs == new_dir) // if we back up
				new_pipe_dirs |= turn(new_dir, 180)
			if((new_pipe_dirs & free_dirs) != new_pipe_dirs) // subset of free dirs
				return
			new_pipe = new/obj/disposalpipe/segment(new_loc)
			new_pipe.set_dir(new_dir)
			new_pipe.dpdir = new_pipe_dirs

		if(new_dir & free_dirs)
			pipe_reconnect_disconnected(new_pipe, new_dir, 1)

	Topic(href, href_list)
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if(href_list["toggle_laying"])
			src.removing_pipe = 0
			src.laying_pipe = !(src.laying_pipe)
			if(src.laying_pipe)
				src.first_step = 1
				src.color = "#bbffbb"
			else
				src.color = "#ffffff"
				var/final_dir = turn(src.dir, 180)
				var/obj/disposalpipe/pipe = locate(/obj/disposalpipe/segment) in src.loc
				if(istype(pipe))
					var/list/disc_dirs = pipe.disconnected_dirs()
					final_dir = pipe.dpdir
					for(var/d in disc_dirs)
						final_dir &= ~d
				if(final_dir in cardinal)
					if(istype(pipe))
						qdel(pipe)
					var/obj/disposalpipe/trunk/trunk = new(src.loc)
					trunk.set_dir(final_dir)
					trunk.dpdir = trunk.dir
					trunk.getlinked()
			src.Attackhand(usr)
			return
		else if(href_list["toggle_removing"])
			src.laying_pipe = 0
			src.removing_pipe = !(src.removing_pipe)
			if(src.removing_pipe)
				src.color = "#ffbbbb"
			else
				src.color = "#ffffff"
			src.Attackhand(usr)
			return
		else if(href_list["dmake"])
			var/p_type = text2num_safe(href_list["dmake"])
			var/obj/disposalconstruct/C = new (src.loc)
			switch(p_type)
				if(0)
					C.ptype = 0
				if(1)
					C.ptype = 1
				if(2)
					C.ptype = 2
				if(3)
					C.ptype = 4
				if(4)
					C.ptype = 5

			C.update()

			usr << browse(null, "window=pipedispenser")
			src.remove_dialog(usr)
		return

/obj/machinery/disposal_pipedispenser/mobile/attack_hand(user)
	var/startstop_lay = (src.laying_pipe ? "Stop" : "Start")
	var/startstop_remove = (src.removing_pipe ? "Stop" : "Start")
	var/dat = {"<b>Disposal Pipes</b><br><br>
<A href='?src=\ref[src];dmake=0'>Pipe</A><BR>
<A href='?src=\ref[src];dmake=1'>Bent Pipe</A><BR>
<A href='?src=\ref[src];dmake=2'>Junction</A><BR>
<A href='?src=\ref[src];dmake=3'>Y-Junction</A><BR>
<A href='?src=\ref[src];dmake=4'>Trunk</A><BR>
<BR>
<A href='?src=\ref[src];toggle_laying=1'>[startstop_lay] Laying Pipe Automatically</A><BR>
<A href='?src=\ref[src];toggle_removing=1'>[startstop_remove] Removing Pipe Automatically</A><BR>
"}

	user << browse("<HEAD><TITLE>Disposal Pipe Dispenser</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk

