// Flock-themed furniture!
//
// CONTENTS:
// Table (and table parts)
// Chair (and chair parts)
// Locker
// Light
// Fibrenet (functionally a lattice)
// Barricade (functionally a grille, but flockdrones can pass through it)

//----------------------------
// TABLE & PARTS
//----------------------------

TYPEINFO(/obj/table/flock)
TYPEINFO_NEW(/obj/table/flock)
	. = ..()
	smooth_list = typecacheof(/obj/table/flock/auto)

TYPEINFO(/obj/table/flock)
	mat_appearances_to_ignore = list("gnesis")
/obj/table/flock
	name = "humming surface"
	desc = "A table? An alien supercomputer? Well, it's flat, you can put stuff on it."
	icon = 'icons/obj/furniture/table_flock.dmi'
	parts_type = /obj/item/furniture_parts/table/flock
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/table/flock/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_attack=FALSE)

/obj/table/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] Storage Surface<br>\
			[SPAN_BOLD("###=-")]")]"}

/obj/table/flock/Crossed(atom/movable/mover)
	. = ..()
	var/mob/living/critter/flock/drone/drone = mover
	if(istype(drone) && !drone.floorrunning)
		animate_flock_passthrough(mover)
		. = TRUE
	else if(istype(mover,/mob/living/critter/flock))
		. = TRUE

/obj/table/flock/Cross(atom/movable/mover)
	if (istype(mover, /mob/living/critter/flock))
		return TRUE
	return ..()

/obj/table/flock/auto
	auto = TRUE

TYPEINFO(/obj/item/furniture_parts/table/flock)
	mat_appearances_to_ignore = list("gnesis")
/obj/item/furniture_parts/table/flock
	name = "collapsed disk"
	desc = "An extendable... <i>thing</i> that can be stretched out to make, uh, probably a table of some kind? Where's the goddamn instructions?!"
	icon = 'icons/obj/furniture/table_flock.dmi'
	furniture_type = /obj/table/flock/auto
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/item/furniture_parts/table/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] Storage Surface, Deployable State<br>\
			[SPAN_BOLD("Instructions:")] Activate within grip tool to deploy<br>\
			[SPAN_BOLD("###=-")]")]"}

///////////////////////////
// CHAIR & PARTS
///////////////////////////

TYPEINFO(/obj/stool/chair/comfy/flock)
	mat_appearances_to_ignore = list("gnesis")
/obj/stool/chair/comfy/flock
	name = "thrumming alcove"
	desc = "It's like an egg chair, but gaudy. Okay, more gaudy."
	icon_state = "chair_flock"
	arm_icon_state = "chair_flock-arm"
	comfort_value = 6
	deconstructable = TRUE
	climbable = FALSE
	parts_type = /obj/item/furniture_parts/flock_chair
	scoot_sounds = list( 'sound/misc/chair/glass/scoot1.ogg', 'sound/misc/chair/glass/scoot2.ogg', 'sound/misc/chair/glass/scoot3.ogg', 'sound/misc/chair/glass/scoot4.ogg', 'sound/misc/chair/glass/scoot5.ogg' )
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/stool/chair/comfy/flock/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_unarmed=FALSE, report_attack=FALSE)

/obj/stool/chair/comfy/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] Resting Chamber<br>\
			[SPAN_BOLD("###=-")]")]"}

TYPEINFO(/obj/item/furniture_parts/flock_chair)
	mat_appearances_to_ignore = list("gnesis")
/obj/item/furniture_parts/flock_chair
	name = "pulsing orb"
	desc = "It feels dense and like it wants to pop open. If you fumble around, maybe you can find some sort of catch or button."
	icon = 'icons/obj/furniture/chairs.dmi'
	icon_state = "flchair_parts"
	force = 3
	stamina_damage = 20
	stamina_cost = 10
	furniture_type = /obj/stool/chair/comfy/flock
	furniture_name = "thrumming alcove"
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/item/furniture_parts/flock_chair/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] Resting Chamber<br>\
			[SPAN_BOLD("###=-")]")]"}

///////////////////////////
// LOCKER
///////////////////////////

TYPEINFO(/obj/storage/closet/flock)
	mat_appearances_to_ignore = list("steel","gnesis")
/obj/storage/closet/flock
	name = "flashy capsule"
	desc = "It looks kinda like a closet. There's no handle, though. Also, it looks like a giant bar of soap."
	var/flock_id = "Containment capsule"
	icon_state = "flock"
	icon_closed = "flock"
	icon_opened = "flock-open"
	open_sound = 'sound/misc/flockmind/flockdrone_locker_open.ogg'
	close_sound = 'sound/misc/flockmind/flockdrone_locker_close.ogg'
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"
	var/health_attack = 100
	var/health_max = 100
	var/repair_per_resource = 2.5
	var/hitsound = 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg'

	take_damage(var/force, var/mob/user as mob)
		if (!isnum(force) || force <= 0)
			return
		src.health_attack = clamp(src.health_attack - force, 0, src.health_max)
		if (src.health_attack <= 0)
			var/turf/T = get_turf(src)
			playsound(T, 'sound/impact_sounds/Glass_Shatter_3.ogg', 25, TRUE)
			var/obj/item/raw_material/shard/S = new /obj/item/raw_material/shard
			S.set_loc(T)
			S.setMaterial(getMaterial("gnesisglass"))
			src.dump_contents()
			make_cleanable( /obj/decal/cleanable/flockdrone_debris, T)
			qdel(src)

/obj/storage/closet/flock/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_unarmed=FALSE, report_attack=FALSE)

/obj/storage/closet/flock/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/grab))
		return ..()

	if (!src.open)
		if (istype(W, /obj/item/cargotele))
			boutput(user, SPAN_ALERT("For some reason, it refuses to budge."))
		else if (isweldingtool(W) && W:try_weld(user, 0, -1, FALSE, FALSE))
			boutput(user, SPAN_ALERT("It doesn't matter what you try, it doesn't seem to keep welded shut."))
		else if (isitem(W))
			if(SEND_SIGNAL(src, COMSIG_FLOCK_ATTACK, user, TRUE))
				return
			var/force = W.force
			user.lastattacked = src
			attack_particle(user, src)
			playsound(src.loc, src.hitsound, 50, 1, pitch = 1.6)
			src.take_damage(force, user)
	else
		if (istype(W, /obj/item/satchel) && length(W.contents))
			..()
		else if (!issilicon(user))
			if(user.drop_item())
				W?.set_loc(src.loc)

/obj/storage/closet/flock/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health_attack)
	src.health_attack += health_given
	return ceil(health_given / src.repair_per_resource)

/obj/storage/closet/flock/proc/deconstruct()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/impact_sounds/Glass_Shatter_3.ogg', 25, TRUE)
	var/obj/item/raw_material/shard/S = new /obj/item/raw_material/shard(T)
	S.setMaterial(getMaterial("gnesisglass"))
	src.dump_contents()
	qdel(src)

/obj/storage/closet/flock/attack_hand(mob/user)
	if (BOUNDS_DIST(user, src) > 0)
		return

	interact_particle(user,src)
	add_fingerprint(user)

	if(isflockmob(user))
		if (!src.toggle())
			return src.Attackby(null, user)
	else
		boutput(user, SPAN_ALERT("Nothing you can do can persuade this thing to either open or close. Bummer."))

/obj/storage/closet/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] [src.flock_id]<br>\
			[SPAN_BOLD("System Integrity:")] [round((src.health_attack/src.health_max)*100)]%<br>\
			[SPAN_BOLD("###=-")]")]"}

// flockdrones can always move through
/obj/storage/closet/flock/Crossed(atom/movable/mover)
	. = ..()
	var/mob/living/critter/flock/drone/drone = mover
	if(!src.open && istype(drone) && !drone.floorrunning)
		animate_flock_passthrough(mover)
		. = TRUE
	else if(istype(mover,/mob/living/critter/flock))
		. = TRUE

/obj/storage/closet/flock/Cross(atom/movable/mover)
	return istype(mover,/mob/living/critter/flock)

///////////////////////////
// LIGHT FITTING
///////////////////////////

TYPEINFO(/obj/machinery/light/flock)
	mat_appearances_to_ignore = list("gnesis")
/obj/machinery/light/flock
	name = "shining cabochon"
	desc = "It pulses and flares to a strange rhythm."
	var/flock_id = "Light emitter"
	icon_state = "flock1"
	base_state = "flock"
	brightness = 1.2
	power_usage = 0
	on = TRUE
	removable_bulb = FALSE
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/machinery/light/flock/New()
	..()
	light.set_color(0.45, 0.75, 0.675)
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_unarmed=FALSE)

/obj/machinery/light/flock/attack_hand(mob/user)
	if(isflockmob(user))
		add_fingerprint(user)
		seton(!on)
	else
		..()

/obj/machinery/light/flock/proc/deconstruct()
	var/turf/T = get_turf(src)
	make_cleanable(/obj/decal/cleanable/flockdrone_debris/fluid, T)
	playsound(T, 'sound/impact_sounds/Glass_Shatter_3.ogg', 25, TRUE)
	qdel(src)

/obj/machinery/light/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] [src.flock_id]<br>\
			[SPAN_BOLD("###=-")]")]"}

/obj/machinery/light/flock/floor
	icon_state = "flock_floor1"
	base_state = "flock_floor"
	plane = PLANE_FLOOR
/////////////
// FIBRENET
/////////////
TYPEINFO(/obj/lattice/flock)
	mat_appearances_to_ignore = list("steel","gnesis")
/obj/lattice/flock
	desc = "Some sort of floating mesh in space, like a bendy lattice. Those wacky flock things."
	name = "fibrenet"
	var/flock_id = "Structural foundation"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "fibrenet"
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

/obj/lattice/flock/New()
	..()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection, report_attack=FALSE)

/obj/lattice/flock/attackby(obj/item/C, mob/user)
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			T.build(get_turf(src))
			playsound(src.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 1)
			T.add_fingerprint(user)
			qdel(src)
	if (isweldingtool(C) && C:try_weld(user,0,-1,FALSE,FALSE))
		if(SEND_SIGNAL(src, COMSIG_FLOCK_ATTACK, user, TRUE))
			return
		boutput(user, SPAN_NOTICE("The fibres burn away in the same way glass doesn't. Huh."))
		qdel(src)

/obj/lattice/flock/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] Structural Foundation<br>\
			[SPAN_BOLD("###=-")]")]"}
