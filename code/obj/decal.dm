/obj/decal
	text = ""
	plane = PLANE_NOSHADOW_BELOW
	var/list/random_icon_states = list()
	var/random_dir = 0
	pass_unstable = FALSE

	New()
		..()
		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name
		src.flags |= UNCRUSHABLE

	proc/setup(var/L)
		if (random_icon_states && length(src.random_icon_states) > 0)
			src.icon_state = pick(src.random_icon_states)
		if (src.random_dir)
			if (random_dir >= 8)
				src.set_dir(pick(alldirs))
			else
				src.set_dir(pick(cardinal))

		if (!real_name)
			real_name = name

	meteorhit(obj/M as obj)
		if (isrestrictedz(src.z))
			return
		else
			return ..()

	ex_act(severity)
		if (isrestrictedz(src.z))
			return
		else
			qdel(src)
			//return ..()

	track_blood()
		src.tracked_blood = null
		return

////////////
// OTHERS //
////////////

/obj/decal/ceshield
	name = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "ceshield"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = ANCHORED
	pixel_y = 0
	pixel_x = 0
	mouse_opacity = 0
	blend_mode = 2
	plane = PLANE_NOSHADOW_ABOVE
	var/y_blur = 3

	New()
		add_filter("motion blur", 1, motion_blur_filter(x=0, y=src.y_blur))
		..()

	talisman
		icon_state = null
		y_blur = 2

		proc/activate_glimmer()
			flick("glimmer", src)

/obj/decal/floatingtiles
	name = "floating tiles"
	desc = "These tiles are just floating around in the void."
	opacity = 0
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "floattiles1"

/obj/decal/implo
	name = "implosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "dimplo"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = ANCHORED
	pixel_y = -16
	pixel_x = -16
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_ABOVE
	New(var/atom/location)
		src.set_loc(location)
		SPAWN(2 SECONDS) qdel(src)
		return ..(location)

/obj/decal/shockwave
	name = "shockwave"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "explocom"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = ANCHORED
	pixel_y = -16
	pixel_x = -16
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_ABOVE
	New(var/atom/location)
		src.set_loc(location)
		SPAWN(2 SECONDS) qdel(src)
		return ..(location)

/obj/decal/point
	name = "point"
	icon = 'icons/mob/screen1.dmi'
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
	icon_state = "arrow"
	layer = EFFECTS_LAYER_1
	plane = PLANE_HUD
	anchored = ANCHORED
	mouse_opacity = 0

proc/make_point(atom/movable/target, pixel_x=0, pixel_y=0, color="#ffffff", time=2 SECONDS, invisibility=INVIS_NONE, atom/movable/pointer)
	// note that `target` can also be a turf, but byond sux and I can't declare the var as atom because areas don't have vis_contents
	if(QDELETED(target)) return
	var/obj/decal/point/point = new
	if (!target.pixel_point)
		pixel_x = target.pixel_x
		pixel_y = target.pixel_y
	else
		pixel_x -= 16 - target.pixel_x
		pixel_y -= 16 - target.pixel_y
	point.pixel_x = pixel_x
	point.pixel_y = pixel_y
	point.color = color
	point.invisibility = invisibility
	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		var/atom/vis_loc = target.vis_locs[1]
		if(vis_loc)
			target_turf = get_turf(vis_loc)
			point.pixel_x += vis_loc.pixel_x
			point.pixel_y += vis_loc.pixel_y
		else
			target_turf = target
	target_turf.vis_contents += point
	if(pointer && GET_DIST(pointer, target_turf) <= 10) // check so that you can't shoot points across the station
		var/matrix/M = matrix()
		M.Translate((pointer.x - target_turf.x)*32 - pixel_x, (pointer.y - target_turf.y)*32 - pixel_y)
		point.transform = M
		animate(point, transform=null, time=2)
	SPAWN(time)
		if(target_turf)
			target_turf.vis_contents -= point
		qdel(point)
	return point

/* - Replaced by functional version: /obj/item/instrument/large/jukebox
/obj/decal/jukebox
	name = "Old Jukebox"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "jukebox"
	desc = "This doesn't seem to be working anymore."
	layer = OBJ_LAYER
	anchored = ANCHORED
	density = 1
*/

/obj/decal/nav_danger
	anchored = ANCHORED
	name = "DANGER"
	desc = "This navigational marker indicates a hazardous zone of space."
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "hazard_delivery"

/obj/decal/bloodtrace
	name = "blood trace"
	desc = "Oh my!!"
	icon = 'icons/obj/decals/blood/blood.dmi'
	icon_state = "floor2"
	color = "#3399FF"
	alpha = 200
	invisibility = INVIS_ALWAYS
	blood_DNA = null
	blood_type = null
	anchored = ANCHORED

/obj/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	plane = PLANE_DEFAULT
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER
	pass_unstable = TRUE

	Cross(atom/movable/mover) // stolen from window.dm
		if (mover && mover.throwing & THROW_CHAIRFLIP)
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, mover) & dir)

			return !density
		else
			return 1

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density)
			. = 1
		else if (get_dir(O.loc, O.movement_newloc) & src.dir)
			. = 0
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

/obj/stool/chair/boxingrope_corner
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER
	pass_unstable = TRUE
	deconstructable = FALSE

	rotatable = 0
	foldable = 0
	climbable = 2
	buckle_move_delay = 6 // this should have been a var somepotato WHY WASN'T IT A VAR
	securable = 0

	can_buckle(var/mob/M as mob, var/mob/user as mob)
		if (M != user)
			return 0
		if ((!( iscarbon(M) ) || BOUNDS_DIST(src, user) > 0 || user.restrained() || user.stat || !user.canmove))
			return 0
		return 1

	MouseDrop_T(mob/M as mob, mob/user as mob)
		if (can_buckle(M,user))
			M.set_loc(src.loc)
			user.visible_message(SPAN_NOTICE("<b>[M]</b> climbs up on [src]!"), SPAN_NOTICE("You climb up on [src]."))
			buckle_in(M, user, 1)

	Cross(atom/movable/mover) // stolen from window.dm
		if (mover && mover.throwing & THROW_CHAIRFLIP)
			return 1
		if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST || src.dir == SOUTH || src.dir == NORTH)
			return 0
		if(get_dir(loc, mover) & dir)

			return !density
		else
			return 1

	Uncross(atom/movable/O, do_bump = TRUE)
		if (!src.density)
			. = 1
		else if (get_dir(O.loc, O.movement_newloc) & src.dir)
			. = 0
		else
			. = 1
		UNCROSS_BUMP_CHECK(O)

/obj/decal/boxingropeenter
	name = "Ring entrance"
	desc = "Do not exit the ring."
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/decal/alienflower
	name = "strange alien flower"
	desc = "Is it going to eat you if you get too close?"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "alienflower"
	random_dir = WEST
	anchored = ANCHORED
	plane = PLANE_DEFAULT

	New()
		..()
		src.set_dir(pick(alldirs))
		src.pixel_y += rand(-8,8)
		src.pixel_x += rand(-8,8)

/obj/decal/cleanable/alienvine
	name = "strange alien vine"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "avine_l1"
	random_icon_states = list("avine_l1", "avine_l2", "avine_l3")
	plane = PLANE_DEFAULT
	New()
		..()
		src.set_dir(pick(cardinal))
		if (prob(20))
			new /obj/decal/alienflower(src.loc)

/obj/decal/icefloor
	name = "ice"
	desc = "Slippery!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "icefloor"
	density = 0
	opacity = 0
	anchored = ANCHORED
	plane = PLANE_FLOOR
	mouse_opacity = 0

/obj/decal/icefloor/Crossed(atom/movable/AM)
	..()
	if (iscarbon(AM))
		var/mob/M =	AM
		// drsingh fix for undefined variable mob/living/carbon/monkey/var/shoes

		if (M.getStatusDuration("knockdown") || M.getStatusDuration("stunned") || M.getStatusDuration("frozen"))
			return

		if (!(M.bioHolder?.HasEffect("cold_resist") > 1) && M.slip(walking_matters = 1))
			boutput(M, SPAN_ALERT("You slipped on [src]!"))
			if (prob(5))
				M.TakeDamage("head", 5, 0, 0, DAMAGE_BLUNT)
				M.visible_message(SPAN_ALERT("<b>[M]</b> hits their head on [src]!"))
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)

/obj/decal/icefloor/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume, cannot_be_cooled = FALSE)
	. = ..()
	if (exposed_temperature > T0C)
		if(prob((exposed_temperature - T0C) * 0.1))
			qdel(src)

// These used to be static turfs derived from the standard grey floor tile and thus didn't always blend in very well (Convair880).
/obj/decal/mule
	name = "Don't spawn me"
	mouse_opacity = 0
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank"
	layer = TURF_LAYER + 0.1 // Should basically be part of a turf.

	beacon
		name = "MULE delivery destination"
		icon_state = "hazard_caution"
		var/auto_dropoff_spawn = 1

		New()
			..()
			var/turf/T = get_turf(src)
			if (T && isturf(T) && src.auto_dropoff_spawn == 1)
				for (var/obj/machinery/navbeacon/mule/NB in T.contents)
					if (!isnull(NB.codes_txt))
						var/turf/TD = null
						switch (NB.codes_txt)
							if ("delivery;dir=1")
								TD = locate(T.x, T.y + 1, T.z)
							if ("delivery;dir=4")
								TD = locate(T.x + 1, T.y, T.z)
							if ("delivery;dir=2")
								TD = locate(T.x, T.y - 1, T.z)
							if ("delivery;dir=8")
								TD = locate(T.x - 1, T.y, T.z)
							else
								return

						if (TD && isturf(TD) && !TD.density)
							new /obj/decal/mule/dropoff(TD)
							if (!isnull(NB.location))
								src.name = "[src.name] ([NB.location])"
							break
			return

		no_auto_dropoff_spawn
			auto_dropoff_spawn = 0

	dropoff
		name = "MULE cargo dropoff point"
		icon_state = "hazard_delivery"

/obj/decal/ballpit
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ballpitwater"
	name = "ball pit"
	real_name = "ball pit"
	layer = 25
	mouse_opacity = 0
	anchored = ANCHORED_ALWAYS

//Decals that glow.
/obj/decal/glow
	var/brightness = 0
	var/color_r = 0.36
	var/color_g = 0.35
	var/color_b = 0.21
	var/datum/light/light
	anchored = ANCHORED_ALWAYS

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_color(src.color_r, src.color_g, src.color_b)
		light.set_brightness(src.brightness / 5)
		light.enable()

////////////
// RUDDER //
////////////
/obj/decal/rudder
	name = "ship steering wheel"
	desc = "They used these to steer ships a long, long time ago."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "rudder"
	density = 0
	opacity = 0
	anchored = ANCHORED
	plane = PLANE_DEFAULT



//floor guides

/obj/decal/tile_edge/floorguide
	name = "navigation guide"
	desc = "A navigation guide to help people find the department they're looking for."
	icon = 'icons/obj/decals/floorguides.dmi'
	icon_state = "endpiece_s"

/obj/decal/tile_edge/floorguide/security
	name = "Security Navigation Guide"
	desc = "The security department is in this direction."
	icon_state = "guide_sec"

/obj/decal/tile_edge/floorguide/science
	name = "R&D Navigation Guide"
	desc = "The science department is in this direction."
	icon_state = "guide_sci"

/obj/decal/tile_edge/floorguide/mining
	name = "Mining Navigation Guide"
	desc = "The mining department is in this direction."
	icon_state = "guide_mining"

/obj/decal/tile_edge/floorguide/medbay
	name = "Medbay Navigation Guide"
	desc = "The medical department is in this direction."
	icon_state = "guide_medbay"

/obj/decal/tile_edge/floorguide/evac
	name = "Evac Shuttle Navigation Guide"
	desc = "The evac shuttle bay is in this direction."
	icon_state = "guide_evac"

/obj/decal/tile_edge/floorguide/engineering
	name = "Engineering Navigation Guide"
	desc = "The engineering department is in this direction."
	icon_state = "guide_engi"

/obj/decal/tile_edge/floorguide/command
	name = "Bridge Navigation Guide"
	desc = "The station bridge is in this direction."
	icon_state = "guide_command"

/obj/decal/tile_edge/floorguide/botany
	name = "Botany Navigation Guide"
	desc = "The botany department is in this direction."
	icon_state = "guide_botany"

/obj/decal/tile_edge/floorguide/qm
	name = "QM Navigation Guide"
	desc = "The quartermaster is in this direction."
	icon_state = "guide_qm"

/obj/decal/tile_edge/floorguide/hop
	name = "Head Of Personnel Navigation Guide"
	desc = "The Head of Personnel's office is in this direction."
	icon_state = "guide_hop"

/obj/decal/tile_edge/floorguide/ai
	name = "AI Navigation Guide"
	desc = "The AI core is in this direction."
	icon_state = "guide_ai"

/obj/decal/tile_edge/floorguide/catering
	name = "Catering Navigation Guide"
	desc = "Catering is in this direction."
	icon_state = "guide_catering"

/obj/decal/tile_edge/floorguide/arrow_e
	name = "Directional Navigation Guide"
	icon_state = "endpiece_e"

/obj/decal/tile_edge/floorguide/arrow_w
	name = "Directional Navigation Guide"
	icon_state = "endpiece_w"

/obj/decal/tile_edge/floorguide/arrow_n
	name = "Directional Navigation Guide"
	icon_state = "endpiece_n"

/obj/decal/tile_edge/floorguide/arrow_s
	name = "Directional Navigation Guide"
	icon_state = "endpiece_s"

/obj/decal/slipup
	name = ""
	desc = ""
	anchored = ANCHORED
	mouse_opacity = 0
	icon = null
	icon_state = null
	alpha = 0
	opacity = 0
	pixel_x = 0
	pixel_y = 8
	plane = PLANE_NOSHADOW_ABOVE

	New(var/location = null, var/state = null, var/mob/target = null)
		if(location)
			src.set_loc(location)
		else
			src.set_loc(usr.loc)

		animate_slipup(src, state, target)
		..()

	proc/animate_slipup(var/obj/slipup_decal, var/state = null, var/mob/target = null)
		var/new_state = "slipup"
		if(state)
			new_state = state

		if (target)
			var/image/image = image('icons/effects/effects.dmi', src, new_state)
			target << image

		var/matrix/original = matrix()
		original.Scale(0.05)
		src.transform = original

		animate(src,transform = matrix(1, MATRIX_SCALE), time = 1 SECONDS, alpha = 255, pixel_y = 16, pixel_x = rand(-32, 32), easing = ELASTIC_EASING)
		animate(time = 1 SECOND, alpha = 0, pixel_y = 8, easing = CIRCULAR_EASING)
		SPAWN(2 SECONDS)
			qdel(src)

/obj/decal/slipup/clumsy
	pixel_x = -32
	pixel_y = 16

	animate_slipup(var/obj/decal/slipup_decal, var/state = null, var/mob/target = null)
		var/new_state = "slipup_clown1"
		if(state)
			new_state = state

		if (target)
			var/image/image = image('icons/effects/96x32.dmi', src, new_state)
			target << image

		animate(src, time = 0.5 SECOND, alpha = 255)
		animate(pixel_y = 64, pixel_x = rand(-64, 0), alpha = 0, time = 1.5 SECONDS, easing = SINE_EASING)
		SPAWN(2 SECONDS)
			qdel(src)
