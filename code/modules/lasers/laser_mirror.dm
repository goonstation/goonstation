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
	anchored = UNANCHORED
	density = 1
	icon = 'icons/obj/lasers/laser_devices.dmi'
	icon_state = "laser_mirror0"

	var/facing = NW_SE

/obj/laser_sink/mirror/flipped
	icon_state = "laser_mirror1"
	facing = SW_NE

/obj/laser_sink/mirror/New()
	..()
	RegisterSignal(src, COMSIG_LASER_CONNECTED, PROC_REF(on_laser_incident))
	RegisterSignal(src, COMSIG_LASER_DISCONNECTED, PROC_REF(on_laser_exident))
	RegisterSignal(src, COMSIG_LASER_TRAVERSE, PROC_REF(on_laser_traverse))

//todo: componentize anchoring behaviour
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
	var/list/saved_lasers = src.laser_sink_comp.in_lasers.Copy()
	for (var/obj/linked_laser/laser in saved_lasers)
		SEND_SIGNAL(src, COMSIG_LASER_EXIDENT, laser)
	src.facing = 1 - src.facing
	src.icon_state = "laser_mirror[src.facing]"
	for (var/obj/linked_laser/laser in saved_lasers)
		SEND_SIGNAL(src, COMSIG_LASER_INCIDENT, laser)

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

/obj/laser_sink/mirror/proc/on_laser_incident(datum/source, obj/linked_laser/laser)
	var/obj/linked_laser/out = laser.copy_laser(get_turf(src), src.get_reflected_dir(laser.dir))
	laser.next = out
	out.previous = laser
	out.try_propagate()
	out.icon_state = out.get_corner_icon_state(src.facing)
	//perspective occlusion check, should the mirror be rendered "in front" of the laser
	if (laser.dir == SOUTH || src.facing == NW_SE && laser.dir == EAST || src.facing == SW_NE && laser.dir == WEST)
		//fake perspective with an inverted alpha filter of our own sprite
		out.add_filter("mirror_occlusion", 0, alpha_mask_filter(icon=icon(src.icon, src.icon_state), flags = MASK_INVERSE))

/obj/laser_sink/mirror/proc/on_laser_exident(datum/source, obj/linked_laser/laser)
	qdel(laser.next)
	laser.next = null

/obj/laser_sink/mirror/proc/on_laser_traverse(datum/source, proc_to_call)
	for (var/obj/linked_laser/laser in src.laser_sink_comp.in_lasers)
		laser.next?.traverse(proc_to_call)

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

#undef NW_SE
#undef SW_NE
