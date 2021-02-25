// Flock-themed furniture!
// because why the fuck not
//
// CONTENTS:
// Table (and table parts)
// Chair (and chair parts)
// Locker
// Light
// Fibrenet (functionally a lattice)
// Barricade (functionally a grille, but flockdrones can pass through it)

////////////////////////////
// TABLE & PARTS
///////////////////////////
/obj/table/flock
	name = "humming surface"
	desc = "A table? An alien supercomputer? Well, it's flat, you can put stuff on it."
	icon = 'icons/obj/furniture/table_flock.dmi'
	auto_type = /obj/table/flock/auto
	parts_type = /obj/item/furniture_parts/table/flock

/obj/table/flock/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Storage Surface
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description

/obj/table/flock/auto
	auto = 1

/obj/item/furniture_parts/table/flock
	name = "collapsed disk"
	desc = "An extendable... <i>thing</i> that can be stretched out to make, uh, probably a table of some kind? Where's the goddamn instructions?!"
	icon = 'icons/obj/furniture/table_flock.dmi'
	furniture_type = /obj/table/flock/auto

/obj/item/furniture_parts/table/flock/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Storage Surface, Deployable State
    <br><span class='bold'>Instructions:</span> Activate within grip tool to deploy.
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description

///////////////////////////
// CHAIR & PARTS
///////////////////////////

/obj/stool/chair/comfy/flock
	name = "thrumming alcove"
	desc = "It's like an egg chair, but gaudy. Okay, more gaudy."
	icon_state = "chair_flock"
	arm_icon_state = "chair_flock-arm"
	comfort_value = 6
	deconstructable = 1
	climbable = 0
	parts_type = /obj/item/furniture_parts/flock_chair
	scoot_sounds = list( 'sound/misc/chair/glass/scoot1.ogg', 'sound/misc/chair/glass/scoot2.ogg', 'sound/misc/chair/glass/scoot3.ogg', 'sound/misc/chair/glass/scoot4.ogg', 'sound/misc/chair/glass/scoot5.ogg' )

/obj/stool/chair/comfy/flock/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Resting Chamber
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description

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

/obj/item/furniture_parts/flock_chair/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Resting Chamber, Deployable State
    <br><span class='bold'>Instructions:</span> Activate within grip tool to deploy.
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description


///////////////////////////
// LOCKER
///////////////////////////

/obj/storage/closet/flock
	name = "flashy capsule"
	desc = "It looks kinda like a closet. There's no handle, though. Also, it looks like a giant bar of soap."
	icon_state = "flock"
	icon_closed = "flock"
	icon_opened = "flock-open"
	open_sound = "sound/misc/flockmind/flockdrone_locker_open.ogg"
	close_sound = "sound/misc/flockmind/flockdrone_locker_close.ogg"
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = 0
	mat_changedesc = 0
	var/health_attack = 100
	var/health_max = 100
	var/hitsound = "sound/impact_sounds/Generic_Hit_Heavy_1.ogg"

/obj/storage/closet/flock/New()
	..()
	setMaterial("gnesis")

/obj/storage/closet/flock/attackby(obj/item/W as obj, mob/user as mob)
	// handle tools
	if (istype(W, /obj/item/cargotele))
		boutput(user, "<span class='alert'>For some reason, it refuses to budge.</span>")
		return
	else if (istype(W, /obj/item/satchel/))
		boutput(user, "<span class='alert'>It isn't really clear how to make this work.</span>")
		return
	else if (!src.open && isweldingtool(W))
		if (W:try_weld(user,0,-1,0,0))
			boutput(user, "<span class='alert'>It doesn't matter what you try, it doesn't seem to keep welded shut.</span>")
		return
	// smack the damn thing if it's closed
	else if (!src.open && isitem(W))
		var/force = W.force
		// smack the damn thing
		user.lastattacked = src
		attack_particle(user,src)
		playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
		src.take_damage(force, user)
	// else if these special cases don't resolve things, throw it to the parent proc
	else
		..()

/obj/storage/closet/flock/proc/take_damage(var/force, var/mob/user as mob)
	if (!isnum(force) || force <= 0)
		return
	src.health_attack = max(0,min(src.health_attack - force,src.health_max))
	if (src.health_attack <= 0)
		var/turf/T = get_turf(src)
		playsound(T, "sound/impact_sounds/Glass_Shatter_3.ogg", 25, 1)
		var/obj/item/raw_material/shard/S = unpool(/obj/item/raw_material/shard)
		S.set_loc(T)
		S.setMaterial(getMaterial("gnesisglass"))
		src.dump_contents()
		make_cleanable( /obj/decal/cleanable/flockdrone_debris, T)
		qdel(src)

/obj/storage/closet/flock/attack_hand(mob/user as mob)
	if (get_dist(user, src) > 1)
		return

	interact_particle(user,src)
	add_fingerprint(user)

	if(isflock(user))
		if (!src.toggle())
			return src.attackby(null, user)
	else
		boutput(user, "<span class='alert'>Nothing you can do can persuade this thing to either open or close. Bummer.</span>")

/obj/storage/closet/flock/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Containment Capsule
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description

///////////////////////////
// LIGHT FITTING
///////////////////////////

/obj/machinery/light/flock
	name = "shining cabochon"
	desc = "It pulses and flares to a strange rhythm."
	icon_state = "flock1"
	base_state = "flock"
	brightness = 1.2
	power_usage = 0
	on = 1
	removable_bulb = 0

/obj/machinery/light/flock/New()
	..()
	light.set_color(0.45, 0.75, 0.675)

/obj/machinery/light/flock/attack_hand(mob/user)
	if(isflock(user))
		add_fingerprint(user)
		seton(!on)
	else
		..()

/obj/item/furniture_parts/flock_chair/special_desc(dist, mob/user)
  if(isflock(user))
    return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
    <br><span class='bold'>ID:</span> Light Emitter
    <br><span class='bold'>###=-</span></span>"}
  else
    return null // give the standard description


/////////////
// FIBRENET
/////////////
/obj/lattice/flock
	desc = "Some sort of floating mesh in space, like a bendy lattice. Those wacky flock things."
	name = "fibrenet"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "fibrenet"
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = 0
	mat_changedesc = 0

/obj/lattice/flock/New()
	..()
	setMaterial("gnesis")

/obj/lattice/flock/attackby(obj/item/C as obj, mob/user as mob)
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			T.build(get_turf(src))
			playsound(src.loc, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.add_fingerprint(user)
			qdel(src)

		if (T.amount < 1  && !issilicon(user))
			user.u_equip(T)
			qdel(T)
	if (isweldingtool(C) && C:try_weld(user,0,-1,0,0))
		boutput(user, "<span class='notice'>The fibres burn away in the same way glass doesn't. Huh.</span>")
		qdel(src)

/////////////
// BARRICADE
/////////////
/obj/grille/flock
	desc = "A glowing mesh of metallic fibres."
	name = "barricade"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "barricade"
	health = 50
	health_max = 50
	shock_when_entered = 0
	auto = FALSE
	mat_appearances_to_ignore = list("steel","gnesis")
	mat_changename = 0
	mat_changedesc = 0

	update_icon(special_icon_state) //fix for perspective grilles fucking these up
		if (ruined)
			return

		if (istext(special_icon_state))
			icon_state = initial(src.icon_state) + "-" + special_icon_state
			return

		var/diff = get_fraction_of_percentage_and_whole(health,health_max)
		switch(diff)
			if(-INFINITY to 25)
				icon_state = initial(src.icon_state) + "-3"
			if(26 to 50)
				icon_state = initial(src.icon_state) + "-2"
			if(51 to 75)
				icon_state = initial(src.icon_state) + "-1"
			if(76 to INFINITY)
				icon_state = initial(src.icon_state) + "-0"

/obj/grille/flock/New()
	..()
	setMaterial("gnesis")
	src.update_icon()


// flockdrones can always move through
/obj/grille/flock/CanPass(atom/movable/mover, turf/target)
	if (istype(mover, /mob/living/critter/flock/drone) && !mover:floorrunning)
		animate_flock_passthrough(mover)
		return 1
	return ..()
