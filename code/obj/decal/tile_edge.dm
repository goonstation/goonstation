
/obj/decal/tile_edge
	name = "edge"
	mouse_opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "tile_edge"
	layer = TURF_LAYER + 0.1 // it should basically be part of a turf
	plane = PLANE_FLOOR // hence, they should be on the same plane!
	var/merge_with_turf = 1

	initialize()
		if (src.merge_with_turf)
			var/turf/T = get_turf(src)
			if (!T)
				return ..()
			var/image/I = image(src.icon, T, src.icon_state, src.layer, src.dir)
			I.pixel_x = src.pixel_x
			I.pixel_y = src.pixel_y
			I.appearance_flags = RESET_COLOR
			if (src.color)
				I.color = src.color
			var/md5hasho = "tile_edge_[md5("[rand(1,10000)]_[rand(1,10000)]")]"
			//world.log << md5hasho
			if (T.UpdateOverlays(I, md5hasho))
				qdel(src)
			else
				return ..()
		else
			return ..()

	Move()
		SHOULD_CALL_PARENT(FALSE)
		return FALSE

/obj/decal/tile_edge/stripe
	name = "hazard stripe"
	icon = 'icons/obj/hazard_stripes.dmi'
	#ifndef XMAS
	icon_state = "stripe-edge"
	#else
	icon_state = "xmas"
	#endif

/obj/decal/tile_edge/stripe/big
	#ifndef XMAS
	icon_state = "bigstripe-edge"
	#else
	icon_state = "xmas"
	#endif

/obj/decal/tile_edge/stripe/extra_big
	#ifndef XMAS
	icon_state = "xtra_bigstripe-edge"
	#else
	icon_state = "xmas"
	#endif

/obj/decal/tile_edge/stripe/corner
	#ifndef XMAS
	name = "hazard stripe corner"
	#else
	icon_state = "xmas-corner"
	#endif

/obj/decal/tile_edge/stripe/corner/big
	#ifndef XMAS
	icon_state = "bigstripe-corner"
	#else
	icon_state = "xmas-corner"
	#endif

/obj/decal/tile_edge/stripe/corner/big2
	#ifndef XMAS
	icon_state = "bigstripe-corner2"
	#else
	icon_state = "xmas-corner2"
	#endif

/obj/decal/tile_edge/stripe/corner/extra_big
	#ifndef XMAS
	icon_state = "xtra_bigstripe-corner"
	#else
	icon_state = "xmas-corner"
	#endif

/obj/decal/tile_edge/stripe/corner/extra_big2
	#ifndef XMAS
	icon_state = "xtra_bigstripe-corner2"
	#else
	icon_state = "xmas-corner2"
	#endif

/obj/decal/tile_edge/stripe/corner/xmas
	icon_state = "xmas-corner"

/obj/decal/tile_edge/stripe/corner/xmas2
	icon_state = "xmas-corner2"

/obj/decal/tile_edge/line
	icon = 'icons/obj/line.dmi'
	icon_state = "linefull"

	white // the default white of these things is brighter than the white tiles, this color matches those
		color = "#E4E4E4"
	grey
		color = "#8D8C8C"
	black
		color = "#474646"
	red
		color = "#BC6B72"
	orange
		color = "#E7C88C"
	yellow
		color = "#BC9F6B"
	green
		color = "#90B672"
	blue
		color = "#6CA3BB"
	purple
		color = "#AB8CB0"

/obj/decal/tile_edge/check
	icon = 'icons/obj/hazard_stripes.dmi'
	icon_state = "checkfull"

	white // the default white of these things is brighter than the white tiles, this color matches those
		color = "#E4E4E4"
	grey
		color = "#8D8C8C"
	black
		color = "#474646"

	red
		color = "#BC6B72"
	orange
		color = "#E7C88C"
	yellow
		color = "#BC9F6B"
	green
		color = "#90B672"
	blue
		color = "#6CA3BB"
	purple
		color = "#AB8CB0"

/obj/decal/tile_edge/carpet
	name = "carpet"
	icon = 'icons/obj/hazard_stripes.dmi'
	icon_state = "rugfull"

/obj/decal/tile_edge/carpet/fancy
	icon_state = "frugfull"

/obj/decal/tile_edge/flowers // not really a edge thing but uh I want it to merge with the turf, so. ye. we doin this.
	name = "flowers"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "flowers1"
	anchored = 1

	New()
		src.icon_state = "flowers[rand(1,4)]"
		src.set_dir(pick(cardinal))
		..()

/obj/decal/stage_edge
	name = "stage"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "curtainthing"
	density = 1
	anchored = 1
	dir = NORTH
	event_handler_flags = USE_FLUID_ENTER
	pass_unstable = TRUE

	Cross(atom/movable/mover)
		if (istype(mover, /obj/projectile))
			return 1
		if (get_dir(loc, mover) & dir)
			return !density
		else
			return 1

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density)
			. = 1
		else if (istype(O, /obj/projectile))
			. = 1
		else if (get_dir(O.loc, O.movement_newloc) & src.dir)
			. = !density
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

/obj/decal/stage_edge/alt
	name = "edge"
	icon_state = "edge2"

//Special Manta bar decoration that goes on the floor, shoving it here since it has no better place.
/obj/decal/risingtidebar
	name = "The Rising Tide"
	anchored = 2
	desc = "Follow the anchor to reach The Rising Tide bar!"
	bound_height = 64
	bound_width = 32
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "risingtide"

