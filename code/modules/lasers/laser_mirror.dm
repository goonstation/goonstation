#define NW_SE 0
#define SW_NE 1

TYPEINFO(/obj/laser_sink/mirror)
	mats = list("metal" = 10,
				"crystal" = 10,
				"reflective" = 30)
/obj/laser_sink/mirror
	name = "laser mirror"
	desc = "A highly reflective mirror designed to redirect extremely high energy laser beams."
	anchored = 0
	density = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "laser_mirror0"

	var/obj/linked_laser/out_laser = null
	var/facing = NW_SE

/obj/laser_sink/mirror/attackby(obj/item/I, mob/user)
	if (isscrewingtool(I))
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(SPAN_NOTICE("[user] [src.anchored ? "un" : ""]screws [src] [src.anchored ? "from" : "to"] the floor."))
		src.anchored = !src.anchored
	else if (ispryingtool(I))
		src.rotate()
	else
		..()

/obj/laser_sink/mirror/attack_hand(mob/user)
	src.rotate()
	..()

/obj/laser_sink/mirror/proc/rotate()
	if (ON_COOLDOWN(src, "rotate", 1 SECOND)) //this is probably a good idea
		return
	var/obj/linked_laser/laser = src.in_laser
	src.exident(laser)
	src.facing = 1 - src.facing
	src.icon_state = "laser_mirror[src.facing]"
	if (laser)
		src.incident(laser)

/obj/laser_sink/mirror/proc/get_reflected_dir(dir)
	//very stupid angle maths
	var/angle
	if (src.facing == NW_SE)
		if (dir in list(WEST, EAST))
			angle = 90
		else
			angle = -90
	else
		if (dir in list(WEST, EAST))
			angle = -90
		else
			angle = 90
	return turn(dir, angle) //rotate based on which way the mirror is facing

/obj/laser_sink/mirror/incident(obj/linked_laser/laser)
	if (src.in_laser) //no infinite loops allowed
		return FALSE
	src.in_laser = laser
	src.out_laser = laser.copy_laser(get_turf(src), src.get_reflected_dir(laser.dir))
	laser.next = src.out_laser
	src.out_laser.try_propagate()
	src.out_laser.icon_state = out_laser.get_corner_icon_state(src.facing)
	return TRUE

/obj/laser_sink/mirror/exident(obj/linked_laser/laser)
	qdel(src.out_laser)
	src.out_laser = null
	..()

/obj/laser_sink/mirror/bullet_act(obj/projectile/P)
	//cooldown to prevent client lag caused by infinite projectile loops
	if (istype(P.proj_data, /datum/projectile/laser/heavy) && !ON_COOLDOWN(src, "reflect_projectile", 1 DECI SECOND))
		var/obj/projectile/new_proj = shoot_projectile_DIR(src, P.proj_data, src.get_reflected_dir(P.dir))
		new_proj.travelled = P.travelled
		P.die()
	else
		..()

/obj/laser_sink/mirror/traverse(proc_to_call)
	src.out_laser.traverse(proc_to_call)

#undef NW_SE
#undef SW_NE
