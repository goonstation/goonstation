
TYPEINFO(/obj/machinery/disposal_pipedispenser)
	mats = 16

var/static/list/obj/machinery/disposal_pipedispenser/availdisposalpipes = list(
	"Pipe" = 0,
	"Bent Pipe" = 1,
	"Junction" = 2,
	"Flipped Junction" = 3,
	"Y-Junction" = 4,
	"Trunk" = 5,
)

#define MAX_BUILD_DISPOSAL 20

/obj/machinery/disposal_pipedispenser
	name = "Disposal Pipe Dispenser"
	desc = "A clunky, old machine that dispenses unanchored disposal pipes one at a time."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "pipe-fab"
	density = 1
	anchored = ANCHORED
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS

	var/dispenser_ready = TRUE
	var/dispenser_delay = 5 DECI SECONDS
	var/mobile = FALSE
	var/datum/action/bar/icon/timer

/obj/machinery/disposal_pipedispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PipeDispenser")
		ui.open()

/obj/machinery/disposal_pipedispenser/ui_data(mob/user)
	. = list(
		"dispenser_ready" = src.dispenser_ready,
	)

/obj/machinery/disposal_pipedispenser/ui_static_data(mob/user)
	. = list(
		"mobile" = src.mobile,
		"max_disposal_pipes" = MAX_BUILD_DISPOSAL,
		"windowName" = src.name,
	)
	for (var/disposaltype in availdisposalpipes)
		.["disposalpipes"] += list(list(
			"disposaltype" = disposaltype,
			"image" = getBase64ImgDisposal(disposaltype)
			))

/obj/machinery/disposal_pipedispenser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("dmake")
			if (!dispenser_ready)
				boutput(ui.user, SPAN_ALERT("The [src] isn't ready yet!"))
				return
			var/p_type = text2num_safe(availdisposalpipes[params["disposal_type"]])
			if (isnull(p_type))
				stack_trace("Tried to get ptype of [params["disposal_type"]] but couldn't find it.")
				return
			var/amount = clamp(params["amount"], 0, MAX_BUILD_DISPOSAL)
			var/duration = dispenser_delay * amount
			src.dispenser_ready = FALSE

			var/obj/disposalconstruct/dummy_pipe = new
			dummy_pipe.ptype = p_type
			dummy_pipe.update()
			SETUP_GENERIC_ACTIONBAR(src, null, duration, /obj/machinery/disposal_pipedispenser/proc/build_disposal_pipe, list(p_type, amount),\
			 dummy_pipe.icon, dummy_pipe.icon_state, SPAN_NOTICE("The [src] finishes making pipes!"), INTERRUPT_NONE)
			qdel(dummy_pipe) //Above creates a construct and changes its icon for usage in the actionbar icon.
			. = TRUE

/obj/machinery/disposal_pipedispenser/proc/build_disposal_pipe(pipe_type, amount)
	for (var/i in 1 to amount)
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = pipe_type
		C.update()
	src.dispenser_ready = TRUE
	tgui_process?.update_uis(src)

/obj/machinery/disposal_pipedispenser/proc/getBase64ImgDisposal(disposalpipe)
	var/obj/disposalconstruct/dummy_pipe = new
	dummy_pipe.ptype = availdisposalpipes[disposalpipe]
	dummy_pipe.update()
	var/icon/dummy_icon = getFlatIcon(dummy_pipe,initial(dummy_pipe.dir),no_anim=TRUE)
	qdel(dummy_pipe) // above is a hack to get this to work. if anyone has any better way of doing this, go ahead.
	. = icon2base64(dummy_icon)

TYPEINFO(/obj/machinery/disposal_pipedispenser/mobile)
	mats = 16

/obj/machinery/disposal_pipedispenser/mobile
	name = "Disposal Pipe Dispenser Cart"
	desc = "A tool for removing some of the tedium from pipe-laying."
	anchored = UNANCHORED
	icon_state = "fab-mobile"
	mobile = TRUE

	var/laying_pipe = FALSE
	var/removing_pipe = FALSE
	var/prev_dir = 0
	var/first_step = FALSE

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
						if (pipe.weldable)
							qdel(pipe)
			prev_dir = direction // might want to actually do this even when old_loc == loc but idk, it sucks with attempted diagonal movement

	proc/connect_pipe(var/turf/new_loc, var/new_dir)
		var/free_dirs = NORTH|SOUTH|EAST|WEST
		var/obj/disposalpipe/pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			else if(length(avail_dirs) >= 2)
				backup_pipe = D
			else if(length(avail_dirs) == 0)
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
		src.first_step = FALSE

		if(new_loc.intact && !istype(new_loc,/turf/space))
			return

		var/obj/disposalpipe/junction/junction = locate(/obj/disposalpipe/junction) in new_loc
		if(junction)
			if(new_dir & junction.dpdir)
				junction.set_dir(new_dir)
				junction.fix_sprite()
				return

		var/free_dirs = NORTH|SOUTH|EAST|WEST
		var/obj/disposalpipe/new_pipe = null
		var/obj/disposalpipe/backup_pipe = null
		var/obj/disposalpipe/backup_backup_pipe = null
		for(var/obj/disposalpipe/D in new_loc)
			var/list/avail_dirs = D.disconnected_dirs()
			free_dirs &= ~D.dpdir
			if(istype(D, /obj/disposalpipe/trunk)) // don't wanna mess with those, they are important
				continue
			switch(length(avail_dirs))
				if(0)
					backup_backup_pipe = D
				if(1)
					new_pipe = D
					break
				if(2 to INFINITY)
					backup_pipe = D
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

/obj/machinery/disposal_pipedispenser/mobile/ui_data(mob/user)
	. = ..()
	. += list(
		"removing_pipe" = src.removing_pipe,
		"laying_pipe" = src.laying_pipe,
	)

/obj/machinery/disposal_pipedispenser/mobile/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return
	switch(action)
		if("toggle_laying")
			src.removing_pipe = FALSE
			src.laying_pipe = !(src.laying_pipe)
			if(src.laying_pipe)
				src.first_step = TRUE
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
			. = TRUE
		if("toggle_removing")
			src.laying_pipe = FALSE
			src.removing_pipe = !(src.removing_pipe)
			if(src.removing_pipe)
				src.color = "#ffbbbb"
			else
				src.color = "#ffffff"
			. = TRUE

#undef MAX_BUILD_DISPOSAL
