//These are the surface normal directions for the two states (so NW_SE has faces pointing north west and south east)
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
	//perspective occlusion check, should the mirror be rendered "in front" of the laser
	if (src.in_laser.dir == SOUTH || src.facing == NW_SE && src.in_laser.dir == EAST || src.facing == SW_NE && src.in_laser.dir == WEST)
		//fake perspective with an inverted alpha filter of our own sprite
		src.out_laser.add_filter("mirror_occlusion", 0, alpha_mask_filter(icon=icon(src.icon, src.icon_state), flags = MASK_INVERSE))
	return TRUE

/obj/laser_sink/mirror/exident(obj/linked_laser/laser)
	qdel(src.out_laser)
	src.out_laser = null
	..()

///One over root 2, the component length of a 45 degree unit vector
#define LENGTH 1/(2**(1/2))

///Manually defined angled normals depending on mirror direction
///I think this may be stupid and bad and should probably be a vector transform somehow but it works for now
/obj/laser_sink/mirror/normal_x(incident_dir)
	switch(incident_dir)
		if (WEST)
			return -LENGTH
		if (EAST)
			return LENGTH
		if (SOUTH)
			if (src.facing == NW_SE)
				return LENGTH
			else
				return -LENGTH
		if (NORTH)
			if (src.facing == NW_SE)
				return -LENGTH
			else
				return LENGTH

/obj/laser_sink/mirror/normal_y(incident_dir)
	switch(incident_dir)
		if (WEST)
			if (src.facing == NW_SE)
				return LENGTH
			else
				return -LENGTH
		if (EAST)
			if (src.facing == NW_SE)
				return -LENGTH
			else
				return LENGTH
		if (SOUTH)
			return -LENGTH
		if (NORTH)
			return LENGTH

#undef LENGTH

/obj/laser_sink/mirror/bullet_act(obj/projectile/P)
	//cooldown to prevent client lag caused by infinite projectile loops
	if (P.proj_data.damage_type == D_ENERGY && !ON_COOLDOWN(src, "reflect_projectile", 1 DECI SECOND))
		var/obj/projectile/new_proj = shoot_reflected_bounce(P, src, INFINITY, play_shot_sound = FALSE, fire_from = get_turf(src))
		new_proj.travelled = P.travelled
		P.die()
	else
		. = ..()

/obj/laser_sink/mirror/traverse(proc_to_call)
	src.out_laser.traverse(proc_to_call)

#undef NW_SE
#undef SW_NE
