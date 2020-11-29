/*/obj/silo_phantom
	color = "#404040"

/atom
	var/list/obj/silo_phantom/phantoms

	proc
		create_phantoms()
			src.phantom = new
			var/image/I = image(src)
			I.layer = src.layer * 0.01
			src.phantom.overlays += I

/turf/simulated/floor/phantom_test
	fullbright = 1

	New()
		..()
		src.create_phantom()
		src.phantom.loc = locate(src.x+16, src.y, src.z)

	Entered(atom/movable/A, turf/OldLoc)
		..()
		if (istype(A, /obj/overlay/tile_effect))
			return
		if (!A.phantom)
			A.create_phantom()
		A.phantom.loc = locate(src.x+16, src.y, src.z)
		A.phantom.set_dir(A.dir)

/turf/simulated/floor/phantom_test2
	fullbright = 1
	icon = null*/

/obj/grille/catwalk/dubious
	name = "rusty catwalk"
	desc = "This one looks even less safe than usual."
	var/collapsing = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		health = rand(5, 10)
		..()
		update_icon()

	HasEntered(atom/movable/A)
		if (ismob(A))
			src.collapsing++
			SPAWN_DBG(1 SECOND)
				collapse_timer()
				if (src.collapsing)
					playsound(src.loc, 'sound/effects/creaking_metal1.ogg', 25, 1)

	proc/collapse_timer()
		var/still_collapsing = 0
		for (var/mob/M in src.loc)
			src.collapsing++
			still_collapsing = 1
		if (!still_collapsing)
			src.collapsing--

		if (src.collapsing >= 5)
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
			for(var/mob/M in AIviewers(src, null))
				boutput(M, "[src] collapses!")
			qdel(src)

		if (src.collapsing)
			SPAWN_DBG(1 SECOND)
				src.collapse_timer()
