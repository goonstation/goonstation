/obj/decal
	text = ""
	plane = PLANE_NOSHADOW_BELOW
	var/list/random_icon_states = list()
	var/random_dir = 0

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

	proc/setup(var/L,var/list/viral_list)
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
	anchored = 1
	pixel_y = 0
	pixel_x = 0
	mouse_opacity = 0
	blend_mode = 2
	plane = PLANE_NOSHADOW_ABOVE

	New()
		add_filter("motion blur", 1, motion_blur_filter(x=0, y=3))
		..()

/obj/decal/floatingtiles
	name = "floating tiles"
	desc = "These tiles are just floating around in the void."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "floattiles1"

/obj/decal/implo
	name = "implosion"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "dimplo"
	layer = EFFECTS_LAYER_BASE
	opacity = 0
	anchored = 1
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
	anchored = 1
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
	anchored = 1

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
	anchored = 1
	density = 1
*/

/obj/decal/nav_danger
	name = "DANGER"
	desc = "This navigational marker indicates a hazardous zone of space."
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "mule_dropoff"

obj/decal/fakeobjects
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT
	var/true_name = "fuck you erik"	//How else will players banish it or place curses on it?? honestly people

	New()
		..()
		true_name = name

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.true_name][name_suffix(null, 1)]"

/obj/decal/fakeobjects/skeleton
	name = "skeleton"
	desc = "The remains of a human."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "skeleton_l"
	plane = PLANE_DEFAULT

	decomposed_corpse
		name = "decomposed corpse"
		desc = "Eugh, the stench is horrible!"
		icon = 'icons/misc/hstation.dmi'
		icon_state = "body1"

	unanchored
		anchored = 0

		summon
			New()
				flick("skeleton_summon", src)
				..()


	cap
		name = "remains of the captain"
		desc = "The remains of the captain of this station ..."
		opacity = 0
		density = 0
		anchored = 1
		icon = 'icons/obj/adventurezones/void.dmi'
		icon_state = "skeleton_l"

/obj/decal/fakeobjects/pole
	name = "Barber Pole"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "pole"
	anchored = 1
	density = 0
	desc = "Barber poles historically were signage used to convey that the barber would perform services such as blood letting and other medical procedures, with the red representing blood, and the white representing the bandaging. In America, long after the time when blood-letting was offered, a third colour was added to bring it in line with the colours of their national flag. This one is in space."
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT

/obj/decal/fakeobjects/oven
	name = "Oven"
	desc = "An old oven."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	anchored = 1
	density = 1
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT

/obj/decal/fakeobjects/sink
	name = "Sink"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	desc = "The sink doesn't appear to be connected to a waterline."
	anchored = 1
	density = 1
	layer = OBJ_LAYER
	plane = PLANE_DEFAULT

/obj/decal/fakeobjects/console_lever
	name = "lever console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lever0"
	density = 1

/obj/decal/fakeobjects/console_randompc
	name = "computer console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "randompc"
	density = 1

/obj/decal/fakeobjects/console_radar
	name = "radar console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "radar"
	density = 1

obj/decal/fakeobjects/cargopad
	name = "Cargo Pad"
	desc = "Used to receive objects transported by a Cargo Transporter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "cargopad"
	anchored = 1

/obj/decal/fakeobjects/robot
	name = "Inactive Robot"
	desc = "The robot looks to be in good condition."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	anchored = 0
	density = 1

/obj/decal/fakeobjects/apc_broken
	name = "broken APC"
	desc = "A smashed local power unit."
	icon = 'icons/obj/power.dmi'
	icon_state = "apc-b"
	anchored = 1

obj/decal/fakeobjects/teleport_pad
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pad0"
	name = "teleport pad"
	anchored = 1
	layer = FLOOR_EQUIP_LAYER1
	desc = "A pad used for scientific teleportation."

/obj/decal/fakeobjects/firealarm_broken
	name = "broken fire alarm"
	desc = "This fire alarm is burnt out, ironically."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "firex"
	anchored = 1

/obj/decal/fakeobjects/firelock_broken
	name = "rusted firelock"
	desc = "Rust has rendered this firelock useless."
	icon = 'icons/obj/doors/door_fire2.dmi'
	icon_state = "door0"
	anchored = 1

/obj/decal/fakeobjects/airlock_broken
	name = "rusted airlock"
	desc = "Rust has rendered this airlock useless."
	icon = 'icons/obj/doors/Door1.dmi';
	icon_state = "doorl";
	anchored = 1
	density = 1
	opacity = 1

/obj/decal/fakeobjects/lighttube_broken
	name = "shattered light tube"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-broken"
	anchored = 1

/obj/decal/fakeobjects/lightbulb_broken
	name = "shattered light bulb"
	desc = "Something has broken this light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-broken"
	anchored = 1

/obj/decal/fakeobjects/airmonitor_broken
	name = "broken air monitor"
	desc = "Something has broken this air monitor."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarmx"
	anchored = 1

/obj/decal/fakeobjects/shuttlethruster
	name = "propulsion unit"
	desc = "A small impulse drive that moves the shuttle."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "alt_propulsion"
	anchored = 1
	density = 1
	opacity = 0

/obj/decal/fakeobjects/shuttleweapon
	name = "weapons unit"
	desc = "A weapons system for shuttles and similar craft."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "shuttle_laser"
	anchored = 1
	density = 1
	opacity = 0

	base
		icon_state = "alt_heater"

/obj/decal/fakeobjects/pipe
	name = "rusted pipe"
	desc = "Good riddance."
	icon = 'icons/obj/atmospherics/pipes/regular_pipe.dmi'
	icon_state = "intact"
	anchored = 1

	heat
		icon = 'icons/obj/atmospherics/pipes/heat_pipe.dmi'

/obj/decal/fakeobjects/oldcanister
	name = "old gas canister"
	desc = "All the gas in it seems to be long gone."
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "old_oxy"
	anchored = 0
	density = 1


	plasma
		name = "old plasma canister"
		icon_state = "old_plasma"
		desc = "This used to be the most feared piece of equipment on the station, don't you believe it?"

/obj/decal/fakeobjects/shuttleengine
	name = "engine unit"
	desc = "A generator unit that uses complex technology."
	icon = 'icons/obj/shuttle.dmi'
	icon_state = "heater"
	anchored = 1
	density = 1
	opacity = 0

/obj/decal/fakeobjects/falseladder
	name = "ladder"
	desc = "The ladder is blocked, you can't get down there."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "ladder"
	anchored = 1
	density = 0

/obj/decal/fakeobjects/sealedsleeper
	name = "sleeper"
	desc = "This one appears to still be sealed. Who's in there?"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sealedsleeper"
	anchored = 1
	density = 1

//sealab prefab fakeobjs

/obj/decal/fakeobjects/pcb
	name = "PCB constructor"
	desc = "A combination pick and place machine and wave soldering gizmo.  For making boards.  Buddy boards.   Well, it would if the interface wasn't broken."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "fab-general"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/palmtree
	name = "palm tree"
	desc = "This is a palm tree. Smells like plastic."
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm"
	anchored = 1
	density = 0

/obj/decal/fakeobjects/brokenportal
	name = "broken portal ring"
	desc = "This portal ring looks completely fried."
	icon = 'icons/obj/teleporter.dmi'
	icon_state = "tele_fuzz"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/lawrack
	name = "defunct AI Law Mount Rack"
	desc = "A large electronics rack that can contain AI Law Circuits, to modify the behaivor of connected AIs. This one looks non-functional."
	icon = 'icons/obj/large/32x48.dmi'
	icon_state = "airack_empty"
	anchored = 1
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	plane = PLANE_DEFAULT

/obj/decal/bloodtrace
	name = "blood trace"
	desc = "Oh my!!"
	icon = 'icons/effects/blood.dmi'
	icon_state = "lum"
	invisibility = INVIS_ALWAYS
	blood_DNA = null
	blood_type = null

/obj/decal/boxingrope
	name = "Boxing Ropes"
	desc = "Do not exit the ring."
	density = 1
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	plane = PLANE_DEFAULT
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER

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
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER
	event_handler_flags = USE_FLUID_ENTER

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
			user.visible_message("<span class='notice'><b>[M]</b> climbs up on [src]!</span>", "<span class='notice'>You climb up on [src].</span>")
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
	anchored = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ringrope"
	layer = OBJ_LAYER

/obj/decal/alienflower
	name = "strange alien flower"
	desc = "Is it going to eat you if you get too close?"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "alienflower"
	random_dir = 8
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
	anchored = 1
	plane = PLANE_FLOOR

/obj/decal/icefloor/Crossed(atom/movable/AM)
	..()
	if (iscarbon(AM))
		var/mob/M =	AM
		// drsingh fix for undefined variable mob/living/carbon/monkey/var/shoes

		if (M.getStatusDuration("weakened") || M.getStatusDuration("stunned") || M.getStatusDuration("frozen"))
			return

		if (!(M.bioHolder?.HasEffect("cold_resist") > 1) && M.slip(walking_matters = 1))
			boutput(M, "<span class='alert'>You slipped on [src]!</span>")
			if (prob(5))
				M.TakeDamage("head", 5, 0, 0, DAMAGE_BLUNT)
				M.visible_message("<span class='alert'><b>[M]</b> hits their head on [src]!</span>")
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, 1)

// These used to be static turfs derived from the standard grey floor tile and thus didn't always blend in very well (Convair880).
/obj/decal/mule
	name = "Don't spawn me"
	mouse_opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank"
	layer = TURF_LAYER + 0.1 // Should basically be part of a turf.

	beacon
		name = "MULE delivery destination"
		icon_state = "mule_beacon"
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
		icon_state = "mule_dropoff"

/obj/decal/ballpit
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "ballpitwater"
	name = "ball pit"
	real_name = "ball pit"
	layer = 25
	mouse_opacity = 0

//Decals that glow.
/obj/decal/glow
	var/brightness = 0
	var/color_r = 0.36
	var/color_g = 0.35
	var/color_b = 0.21
	var/datum/light/light

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
	anchored = 1
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
