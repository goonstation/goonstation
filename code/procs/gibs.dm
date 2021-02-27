/proc/gibs(atom/location, var/list/diseases, var/list/ejectables, var/blood_DNA, var/blood_type, var/headbits = 1, mob/living/source=null)
    // Added blood type and DNA for forensics (Convair880).
	var/obj/decal/cleanable/blood/gibs/gib = null
	var/list/gibs = new()
	if(!location)
		location = usr
	playsound(location, "sound/impact_sounds/Flesh_Break_2.ogg", 50, 1)

	LAGCHECK(LAG_LOW)
	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibup1"
	gib.streak_cleanable(NORTH)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	if(source?.blood_id) gib.sample_reagent = source.blood_id
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.streak_cleanable(SOUTH)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	if(source?.blood_id) gib.sample_reagent = source.blood_id
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak_cleanable(WEST)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	if(source?.blood_id) gib.sample_reagent = source.blood_id
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak_cleanable(EAST)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	if(source?.blood_id) gib.sample_reagent = source.blood_id
	gibs.Add(gib)

	if(headbits)
		LAGCHECK(LAG_LOW)
		// RANDOM BODY
		gib = make_cleanable( /obj/decal/cleanable/blood/gibs/body,location)
		gib.streak_cleanable()
		gib.diseases += diseases
		gib.blood_DNA = blood_DNA
		gib.blood_type = blood_type
		if(source?.blood_id) gib.sample_reagent = source.blood_id
		gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// CORE
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/core,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	if(source?.blood_id) gib.sample_reagent = source.blood_id
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	handle_ejectables(location, ejectables)

	. = gibs

// separating this out because other gib procs could use it - cirr
/proc/handle_ejectables(atom/location, var/list/ejectables)
	var/turf/Q = get_turf(location)
	if (!Q)
		return
	if (length(ejectables))
		for (var/atom/movable/I in ejectables)
			if(istype(I.loc, /mob))
				var/mob/M = I.loc
				M.u_equip(I)
			I.set_loc(location)
			ThrowRandom(I, 12, 3)

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
	gib.streak_cleanable(NORTH)
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	if (prob(25))
		gib.icon_state = "gibdown1"
	gib.streak_cleanable(SOUTH)
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak_cleanable(WEST)
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak_cleanable(EAST)
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/robot_debris,location)
	gib.streak_cleanable()
	gibs.Add(gib)

	LAGCHECK(LAG_LOW)
	// RANDOM LIMBS
	for (var/i = 0, i < pick(0, 1, 2), i++)
		gib = make_cleanable( /obj/decal/cleanable/robot_debris/limb,location)
		gib.streak_cleanable()
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
	gib.streak_cleanable(NORTH)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak_cleanable(SOUTH)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak_cleanable(WEST)


	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak_cleanable(EAST)


	LAGCHECK(LAG_LOW)
	// RANDOM BODY
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs/body,location)
	gib.diseases += diseases
	gib.blood_DNA = blood_DNA
	gib.blood_type = blood_type
	gib.color = pick(party_colors)
	gib.streak_cleanable()


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
	gib.streak_cleanable(NORTH)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak_cleanable(SOUTH)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak_cleanable(WEST)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable(/obj/decal/cleanable/martian_viscera,location)
	gib.streak_cleanable(EAST)

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/martian_viscera,location)
	gib.streak_cleanable()

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
	gib.streak_cleanable(NORTH)

	LAGCHECK(LAG_LOW)
	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak_cleanable(SOUTH)

	LAGCHECK(LAG_LOW)
	// WEST
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak_cleanable(WEST)

	LAGCHECK(LAG_LOW)
	// EAST
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak_cleanable(EAST)

	LAGCHECK(LAG_LOW)
	// RANDOM
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris,location)
	gib.streak_cleanable()

	LAGCHECK(LAG_LOW)
	handle_ejectables(location, ejectables)

	LAGCHECK(LAG_LOW)
	// CORE SPLAT
	gib = make_cleanable( /obj/decal/cleanable/flockdrone_debris/fluid,location)
