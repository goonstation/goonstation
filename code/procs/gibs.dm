/proc/gibs(atom/location, var/list/diseases, var/list/ejectables, var/blood_DNA, var/blood_type)
    // Added blood type and DNA for forensics (Convair880).
	var/obj/decal/cleanable/blood/gibs/gib = null
	var/list/gibs = new()

	playsound(location, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibup1"
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// RANDOM BODY
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/body,location)
	gib.streak(alldirs)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// CORE
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/core,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	handle_ejectables(location, ejectables)

	. = gibs

// separating this out because other gib procs could use it - cirr
/proc/handle_ejectables(atom/location, var/list/ejectables)
	var/turf/Q = get_turf(location)
	if (!Q)
		return
	if (ejectables && ejectables.len)
		for (var/atom/movable/I in ejectables)
			var/turf/target = null
			var/tries = 0
			while (!target)
				tries = tries + 1
				if (tries == 5)
					target = get_edge_target_turf(location, pick(alldirs))
					break
				var/tx = rand(-6, 6)
				var/ty = rand(-6, 6)
				if (tx == ty && tx == 0)
					continue
				target = locate(Q.x + tx, Q.y + ty, Q.z)

			if(istype(I.loc, /mob))
				var/mob/M = I.loc
				M.u_equip(I)
			I.set_loc(location)
			I.throw_at(target, 12, 3)

/proc/robogibs(atom/location, var/list/diseases)
	var/obj/decal/cleanable/robot_debris/gib = null
	var/list/gibs = new()

	playsound(location, "sound/impact_sounds/Machinery_Break_1.ogg", 50, 1)

	LAGCHECK(LAG_LOW)
	// RUH ROH
	elecflash(location,power=2)

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	if (prob(25))
		gib.icon_state = "gibup1"
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	if (prob(25))
		gib.icon_state = "gibdown1"
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak(alldirs)
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		gib = make_cleanable( /obj/decal/cleanable/robot_debris/limb,location)
		gib.streak(alldirs)
	gibs.Add(gib)

	.=gibs

/proc/partygibs(atom/location, var/list/diseases, var/blood_DNA, var/blood_type)
    // Added blood type and DNA for forensics (Convair880).
	var/list/party_colors = list(rgb(0,0,255),rgb(204,0,102),rgb(255,255,0),rgb(51,153,0))
	var/obj/decal/cleanable/blood/gibs/gib = null

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibup1"
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))


	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))


	LAGCHECK(LAG_LOW)
	// RANDOM BODY
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/body,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak(alldirs)


	LAGCHECK(LAG_LOW)
	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		var/limb_type = pick(/obj/item/parts/human_parts/arm/left, /obj/item/parts/human_parts/arm/right, /obj/item/parts/human_parts/leg/left, /obj/item/parts/human_parts/leg/right)
		gib = new limb_type(location)
		gib.throw_at(get_edge_target_turf(location, pick(alldirs)), 4, 3)
		gib.color = pick(party_colors)

	LAGCHECK(LAG_LOW)
	// CORE
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/core,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)

// cirr did this blame him
/proc/martiangibs(atom/location)
	if(!location) return
	var/obj/decal/cleanable/martian_viscera/gib = null

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/martian_viscera,location)
	gib.streak(alldirs)

	// TODO: random martian organs?

	LAGCHECK(LAG_LOW)
	// CORE SPLAT
	gib = make_cleanable( /obj/decal/cleanable/martian_viscera/fluid,location)


/proc/flockdronegibs(atom/location, var/list/diseases, var/list/ejectables, var/blood_DNA, var/blood_type)
	if(!location) return
	// WHO LIKES COPY PASTED CODE? I DO I LOVE IT DELICIOUS YUM YUM
	var/obj/decal/cleanable/flockdrone_debris/gib = null

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak(alldirs)

	LAGCHECK(LAG_LOW)
	handle_ejectables(location, ejectables)

	LAGCHECK(LAG_LOW)
	// CORE SPLAT
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris/fluid,location)

//Gib proc for Reliquary horrors. Reliquary bits + blood + Reliquary limbs

/proc/religibs(atom/location, var/list/diseases, var/list/ejectables, var/blood_DNA, var/blood_type)
	if(!location) return
	var/obj/decal/cleanable/reliquary_debris/gib = null

	LAGCHECK(LAG_LOW)
	// RUH ROH
	elecflash(location,power=2)
	boutput(world, "Sparks went off.")

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
	gib.streak(list(NORTH, NORTHEAST, NORTHWEST))
	boutput(world, "1st gib")

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
	gib.streak(list(SOUTH, SOUTHEAST, SOUTHWEST))
	boutput(world, "2st gib")
	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
	gib.streak(list(WEST, NORTHWEST, SOUTHWEST))
	boutput(world, "3st gib")
	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
	gib.streak(list(EAST, NORTHEAST, SOUTHEAST))
	boutput(world, "4st gib")
	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
	gib.streak(alldirs)
	boutput(world, "5st gib")
	LAGCHECK(LAG_LOW)
	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		gib = make_cleanable( /obj/decal/cleanable/reliquary_debris,location)
		gib.streak(alldirs)
		boutput(world, "extra gib")
