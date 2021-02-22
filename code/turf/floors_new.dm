/*
	Don't forget to use the [DEFINE_FLOORS] macro on any new turfs you add!

	simulated/floor		The inital floor turf, required to set variables for the others
	floor/pattern			Pattern floors, like the checkers you see around the station or in the chapel
	floor/decal				Decal pattern floors, ie the big sign outside manta's security
	floor/full				Fully-Coloured floors, think stuff like the white tiles in medical bag
	floor/misc				Random misc floors, such as the blob's floor
	floor/setpeice		Setpeice & azone floors. Cause we have some of those simulated?
	floor/side				The side turf floors, think what you see outside arrivals
*/
////////////	Inital floor turf

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000

	turf_flags = IS_TYPE_SIMULATED | MOB_SLIP | MOB_STEP

	var/broken = 0
	var/burnt = 0
	var/plate_mat = null
	var/reinforced = FALSE

	New()
		..()
		plate_mat = getMaterial("steel")
		setMaterial(getMaterial("steel"))
		var/obj/plan_marker/floor/P = locate() in src
		if (P)
			src.icon = P.icon
			src.icon_state = P.icon_state
			src.icon_old = P.icon_state
			allows_vehicles = P.allows_vehicles
			var/pdir = P.dir
			SPAWN_DBG(0.5 SECONDS)
				src.set_dir(pdir)
			qdel(P)

////////////	Pattern floors

DEFINE_FLOORS_SIMMED_UNSIMMED(pattern,
	icon_state = "")

DEFINE_FLOORS_SIMMED_UNSIMMED(pattern/checker/,
	icon_state = "")

DEFINE_FLOORS_SIMMED_UNSIMMED(pattern/checker/whiteblue,
	icon_state = "bluechecker")

DEFINE_FLOORS_SIMMED_UNSIMMED(pattern/checker/bluegreen,
	icon_state = "blugreenfull")
//	Macro doesn't work for these, so these need manually mirroring
/turf/simulated/floor/circuit
	name = "transduction matrix"
	desc = "An elaborate, faintly glowing matrix of isolinear circuitry."
	icon_state = "circuit"
	RL_LumR = 0
	RL_LumG = 0   //Corresponds to color of the icon_state.
	RL_LumB = 0.3
	mat_appearances_to_ignore = list("pharosium")
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	New()
		..()
		setMaterial(getMaterial("pharosium"))

/turf/simulated/floor/pattern/circuit/green
	icon_state = "circuit-green"
	RL_LumR = 0
	RL_LumG = 0.3
	RL_LumB = 0

/turf/simulated/floor/pattern/circuit/white
	icon_state = "circuit-white"
	RL_LumR = 0.2
	RL_LumG = 0.2
	RL_LumB = 0.2

/turf/simulated/floor/pattern/circuit/purple
	icon_state = "circuit-purple"
	RL_LumR = 0.1
	RL_LumG = 0
	RL_LumB = 0.2

/turf/simulated/floor/pattern/circuit/red
	icon_state = "circuit-red"
	RL_LumR = 0.3
	RL_LumG = 0
	RL_LumB = 0

/turf/simulated/floor/pattern/circuit/vintage
	icon_state = "circuit-vint1"
	RL_LumR = 0.1
	RL_LumG = 0.1
	RL_LumB = 0.1

/turf/simulated/floor/pattern/circuit/off
	icon_state = "circuitoff"
	RL_LumR = 0
	RL_LumG = 0
	RL_LumB = 0
//
////////////	Decal pattern floors

DEFINE_FLOORS_SIMMED_UNSIMMED(decal,
	icon_state = "")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(decal/bot,
	icon_state = "bot")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/bot/white,
	icon_state = "bot_white")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/bot/blue,
	icon_state = "bot_blue")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/bot/darkpurple,
	icon_state = "bot_dpurple")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/bot/caution,
	icon_state = "botcaution")
//
DEFINE_FLOORS_SIMMED_UNSIMMED(decal/delivery,
	icon_state = "delivery")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/delivery/white,
	icon_state = "delivery_white")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/delivery/caution,
	icon_state = "deliverycaution")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(decal/floorhazard,
	icon_state = "floor_hazard")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/floorhazard/northsouth,
	icon_state = "floor_hazard_ns")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/floorhazard/westeast,
	icon_state = "floor_hazard_we")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/floorhazard/corners,
	icon_state = "floor_hazard_corners")

DEFINE_FLOORS_SIMMED_UNSIMMED(decal/floorhazard/misc,
	icon_state = "floor_hazard_misc")

//
////////////	Fully-Coloured floors

DEFINE_FLOORS_SIMMED_UNSIMMED(full,
	icon_state = "")

//	Okay so 'dark' is darker than 'black', So 'dark' will be named black and 'black' named grey.
DEFINE_FLOORS_SIMMED_UNSIMMED(full/black,
	icon_state = "dark")

DEFINE_FLOORS_SIMMED_UNSIMMED(full/blue,
	icon_state = "fullblue")

////////////	Random misc floors

DEFINE_FLOORS_SIMMED_UNSIMMED(misc,
	icon_state = "")

////////////	Setpeice & azone floors

DEFINE_FLOORS_SIMMED_UNSIMMED(setpieces,
	icon_state = "")

////////////	The side turf floors

DEFINE_FLOORS_SIMMED_UNSIMMED(side,
	icon_state = "")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/arrival,
	icon_state = "arrival")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/arrival/corner,
	icon_state = "arrivalcorner")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/black,
	icon_state = "greyblack")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/black/corner,
	icon_state = "greyblackcorner")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/whiteblack,
	icon_state = "darkwhite")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/whiteblack/corner,
	icon_state = "darkwhitecorner")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/blue,
	icon_state = "blue")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/blue/corner,
	icon_state = "bluecorner")

//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/blueblack,
	icon_state = "blueblack")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/blueblack/corner,
	icon_state = "blueblackcorner")
//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/bluegreen,
	icon_state = "blugreen")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/bluegreen/corner,
	icon_state = "blugreencorner")
//
DEFINE_FLOORS_SIMMED_UNSIMMED(side/whiteblue,
	icon_state = "bluewhite")

DEFINE_FLOORS_SIMMED_UNSIMMED(side/whiteblue/corner,
	icon_state = "bluewhitecorner")

//
////////////////////////
////////////////////////		~~~~~~~AAAAAAAAAAAAAAAAAAAA
////////////////////////

/turf/simulated/floor/plating/airless
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	//fullbright = 1
	allows_vehicles = 1

	New()
		..()
		name = "plating"

/turf/simulated/floor/plating/airless/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	reinforced = TRUE

/turf/simulated/floor/shuttlebay
	name = "shuttle bay plating"
	icon_state = "engine"
	allows_vehicles = 1
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED
	reinforced = TRUE

/turf/simulated/floor/metalfoam
	icon = 'icons/turf/floors.dmi'
	icon_state = "metalfoam"
	var/metal = 1
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	intact = 0
	layer = PLATING_LAYER
	allows_vehicles = 1 // let the constructor pods move around on these
	step_material = "step_plating"
	step_priority = STEP_PRIORITY_MED

	desc = "A flimsy foamed metal floor."
/turf/simulated/floor/misc/blob
	name = "blob floor"
	desc = "Blob floors to lob blobs over."
	icon = 'icons/mob/blob.dmi'
	icon_state = "bridge"
	default_melt_cap = 80
	allows_vehicles = 1

	New()
		..()
		setMaterial(getMaterial("blob"))

	proc/setOvermind(var/mob/living/intangible/blob_overmind/O)
		if (!material)
			setMaterial(getMaterial("blob"))
		material.color = O.color
		color = O.color

	attackby(var/obj/item/W, var/mob/user)
		if (isweldingtool(W))
			visible_message("<b>[user] hits [src] with [W]!</b>")
			if (prob(25))
				ReplaceWithSpace()

	ex_act(severity)
		if (prob(33))
			..(max(severity - 1, 1))
		else
			..(severity)

	burn_tile()
		return

// metal foam floors

/turf/simulated/floor/metalfoam/update_icon()
	if(metal == 1)
		icon_state = "metalfoam"
	else
		icon_state = "ironform"

/turf/simulated/floor/metalfoam/ex_act()
	ReplaceWithSpace()

/turf/simulated/floor/metalfoam/attackby(obj/item/C as obj, mob/user as mob)

	if(!C || !user)
		return 0
	if (istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if (T.amount >= 1)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			T.build(src)
		return

	if(prob(75 - metal * 25))
		ReplaceWithSpace()
		boutput(user, "You easily smash through the foamed metal floor.")
	else
		boutput(user, "Your attack bounces off the foamed metal floor.")

/turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/shuttle/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		return 0
	return ..()

/turf/unsimulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if (!src.allows_vehicles && (istype(mover, /obj/machinery/vehicle) && !istype(mover,/obj/machinery/vehicle/tank)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/burn_down()
	src.ex_act(2)

/turf/simulated/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ReplaceWithSpace()
#ifdef UNDERWATER_MAP
			//if (prob(10))
			//	src.ex_act(severity+1)
#endif

		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					if(prob(33))
						var/obj/item/I = unpool(/obj/item/raw_material/scrap_metal)
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							var/datum/material/M = getMaterial("steel")
							I.setMaterial(M)
					src.ReplaceWithLattice()
				if(2)
					src.ReplaceWithSpace()
				if(3)
					if(prob(33))
						var/obj/item/I = unpool(/obj/item/raw_material/scrap_metal)
						I.set_loc(src)
						if (src.material)
							I.setMaterial(src.material)
						else
							var/datum/material/M = getMaterial("steel")
							I.setMaterial(M)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act(var/power)
	return

/turf/simulated/floor/proc/update_icon()

/turf/simulated/attack_hand(mob/user as mob)
	if (src.density == 1)
		return
	if (!user.canmove || user.restrained())
		return
	if (!user.pulling || user.pulling.anchored || (user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		//get rid of click delay since we didn't do anything
		user.next_click = world.time
		return
	//duplicate user.pulling for RTE fix
	if (user.pulling && user.pulling.loc == user)
		user.pulling = null
		return
	//if the object being pulled's loc is another object (being in their contents) return
	if (isobj(user.pulling.loc))
		var/obj/container = user.pulling.loc
		if (user.pulling in container.contents)
			return

	var/turf/fuck_u = user.pulling.loc
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(M, get_dir(fuck_u, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(fuck_u, src))
	return

/turf/simulated/floor/proc/to_plating(var/force_break)
	if(!force_break)
		if(src.reinforced) return
	if(!intact) return
	if (!icon_old)
		icon_old = icon_state
	if (!name_old)
		name_old = name
	src.name = "plating"
	src.icon_state = "plating"
	setIntact(FALSE)
	broken = 0
	burnt = 0
	if(plate_mat)
		src.setMaterial(plate_mat)
	else
		src.setMaterial(getMaterial("steel"))
	levelupdate()

/turf/simulated/floor/proc/dismantle_wall()//can get called due to people spamming weldingtools on walls
	return

/turf/simulated/floor/proc/break_tile_to_plating()
	if(intact) to_plating()
	break_tile()

/turf/simulated/floor/proc/break_tile(var/force_break)
	if(!force_break)
		if(src.reinforced) return

	if(broken) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(broken || burnt || reinforced) return
	if (!icon_old)
		icon_old = icon_state
	if(intact)
		src.icon_state = "floorscorched[pick(1,2)]"
	else
		src.icon_state = "panelscorched"
	burnt = 1

/turf/simulated/floor/shuttle/burn_tile()
	return

/turf/simulated/floor/proc/restore_tile()
	if(intact) return
	setIntact(TRUE)
	broken = 0
	burnt = 0
	icon = initial(icon)
	if(icon_old)
		icon_state = icon_old
	else
		icon_state = "floor"
	if (name_old)
		name = name_old
	levelupdate()

/turf/simulated/floor/var/global/girder_egg = 0

//basically the same as walls.dm sans the
/turf/simulated/floor/proc/attach_light_fixture_parts(var/mob/user, var/obj/item/W)
	if (!user || !istype(W, /obj/item/light_parts/floor))
		return

	// the wall is the target turf, the source is the turf where the user is standing
	var/obj/item/light_parts/parts = W
	var/turf/target = src


	playsound(src, "sound/items/Screwdriver.ogg", 50, 1)
	boutput(user, "You begin to attach the light fixture to [src]...")

	if (!do_after(user, 4 SECONDS))
		user.show_text("You were interrupted!", "red")
		return

	if (!parts) //ZeWaka: Fix for null.fixture_type
		return

	// if they didn't move, put it up
	boutput(user, "You attach the light fixture to [src].")

	var/obj/machinery/light/newlight = new parts.fixture_type(target)
	newlight.icon_state = parts.installed_icon_state
	newlight.base_state = parts.installed_base_state
	newlight.fitting = parts.fitting
	newlight.status = 1 // LIGHT_EMPTY

	newlight.add_fingerprint(user)
	src.add_fingerprint(user)

	user.u_equip(parts)
	qdel(parts)
	return

/turf/simulated/floor/proc/pry_tile(obj/item/C as obj, mob/user as mob, params)
	if (!intact)
		return
	if(src.reinforced)
		boutput(user, "<span class='alert'>You can't pry apart reinforced flooring! You'll have to loosen it with a welder or wrench instead.</span>")
		return

	if(broken || burnt)
		boutput(user, "<span class='alert'>You remove the broken plating.</span>")
	else
		var/atom/A = new /obj/item/tile(src)
		if(src.material)
			A.setMaterial(src.material)
		else
			var/datum/material/M = getMaterial("steel")
			A.setMaterial(M)
		.= A //return tile for crowbar special attack ok

	to_plating()
	playsound(src, "sound/items/Crowbar.ogg", 80, 1)

/turf/simulated/floor/attackby(obj/item/C as obj, mob/user as mob, params)

	if (!C || !user)
		return 0

	if (ispryingtool(C))
		src.pry_tile(C,user,params)
		return

	if (istype(C, /obj/item/pen))
		var/obj/item/pen/P = C
		P.write_on_turf(src, user, params)
		return

	if (istype(C, /obj/item/light_parts/floor))
		src.attach_light_fixture_parts(user, C) // Made this a proc to avoid duplicate code (Convair880).
		return

	if (src.reinforced && ((isweldingtool(C) && C:try_weld(user,0,-1,0,1)) || iswrenchingtool(C)))
		boutput(user, "<span class='notice'>Loosening rods...</span>")
		if(iswrenchingtool(C))
			playsound(src, "sound/items/Ratchet.ogg", 80, 1)
		if(do_after(user, 3 SECONDS))
			if(!src.reinforced)
				return
			var/obj/R1 = new /obj/item/rods(src)
			var/obj/R2 = new /obj/item/rods(src)
			if (material)
				R1.setMaterial(material)
				R2.setMaterial(material)
			else
				R1.setMaterial(getMaterial("steel"))
				R2.setMaterial(getMaterial("steel"))
			ReplaceWithFloor()
			src.to_plating()
			return

	if(istype(C, /obj/item/rods))
		if (!src.intact)
			if (C:amount >= 2)
				boutput(user, "<span class='notice'>Reinforcing the floor...</span>")
				if(do_after(user, 3 SECONDS))
					ReplaceWithEngineFloor()

					if (C)
						C:amount -= 2
						if (C:amount <= 0)
							qdel(C) //wtf

						if (C.material)
							src.setMaterial(C.material)

					playsound(src, "sound/items/Deconstruct.ogg", 80, 1)
			else
				boutput(user, "<span class='alert'>You need more rods.</span>")
		else
			boutput(user, "<span class='alert'>You must remove the plating first.</span>")
		return

	if(istype(C, /obj/item/tile))
		var/obj/item/tile/T = C
		if(intact)
			var/obj/P = user.find_tool_in_hand(TOOL_PRYING)
			if (!P)
				return
			// Call ourselves w/ the tool, then continue
			src.attackby(P, user)

		// Don't replace with an [else]! If a prying tool is found above [intact] might become 0 and this runs too, which is how floor swapping works now! - BatElite
		if (!intact)
			restore_tile()
			src.plate_mat = src.material
			if(C.material)
				src.setMaterial(C.material)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)

			if(!istype(src.material, /datum/material/metal/steel))
				logTheThing("station", user, null, "constructs a floor (<b>Material:</b>: [src.material && src.material.name ? "[src.material.name]" : "*UNKNOWN*"]) at [log_loc(src)].")

			T.change_stack_amount(-1)
			//if(T && (--T.amount < 1))
			//	qdel(T)
			//	return


	if(istype(C, /obj/item/sheet))
		if (!(C?.material?.material_flags & (MATERIAL_METAL | MATERIAL_CRYSTAL))) return
		if (!C:amount_check(2,usr)) return

		var/msg = "a girder"

		if(!girder_egg)
			var/count = 0
			for(var/obj/structure/girder in src)
				count++
			var/static/list/insert_girder = list(
			"a girder",
			"another girder",
			"yet another girder",
			"oh god it's another girder",
			"god save the queen its another girder",
			"sweet christmas its another girder",
			"the 6th girder",
			"you're not sure but you think it's a girder",
			"um... ok. a girder, I guess",
			"what does girder even mean, anyway",
			"the strangest girder",
			"the girder that confuses you",
			"the metallic support frame",
			"a very untrustworthy girder",
			"the \"i'm concerned about the sheer number of girders\" girder",
			"a broken wall",
			"the 16th girder",
			"the 17th girder",
			"the 18th girder",
			"the 19th girder",
			"the 20th century girder",
			"the 21th girder",
			"the mfin girder coming right atcha",
			"the girder you cant believe is a girder",
			"rozenkrantz \[sic?\] and girderstein",
			"a.. IS THAT?! no, just a girder",
			"a gifter",
			"a shitty girder",
			"a girder potato",
			"girded loins",
			"the platonic ideal of stacked girders",
			"a complete goddamn mess of girders",
			"FUCK",
			"a girder for ants",
			"a girder of a time",
			"a girder girder girder girder girder girder girder girder girder girder girder girder.. mushroom MUSHROOM",
			"an attempted girder",
			"a failed girder",
			"a girder most foul",
			"a girder who just wants to be a wall",
			"a human child",//40
			"ett gürdür",
			"a girdle",
			"a g--NOT NOW MOM IM ALMOST AT THE 100th GIRDER--irder",
			"a McGirder",
			"a Double Cheesegirder",
			"an egg salad",
			"the ugliest damn girder you've ever seen in your whole fucking life",
			"the most magnificent goddamn girder that you've ever seen in your entire fucking life",
			"the constitution of the old republic, and also a girder",
			"a waste of space, which is crazy when you consider where you built this",//50
			"pure girder vibrations",
			"a poo containment girder",
			"an extremely solid girder, your parents would be proud",
			"the girder who informs you to the authorities",
			"a discount girder",
			"a counterfeit girder",
			"a construction",
			"readster's very own girder",
			"just a girder",
			"a gourder",//60
			"a fuckable girder",
			"a herd of girders",
			"an A.D.G.S",
			"the... thing",
			"the.. girder?",
			"a girder. one that girds if you girder it.",
			"the frog(?)",
			"the unstable relationship",
			"nice",
			"the girder egg")
			msg = insert_girder[min(count+1, insert_girder.len)]
			if(count >= 70)
				girder_egg = 1
				actions.start(new /datum/action/bar/icon/build(C, /obj/item/reagent_containers/food/snacks/ingredient/egg/critter/townguard/passive, 2, null, 1, 'icons/obj/structures.dmi', "girder egg", msg, null), user)
			else
				actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)
		else
			actions.start(new /datum/action/bar/icon/build(C, /obj/structure/girder, 2, C:material, 1, 'icons/obj/structures.dmi', "girder", msg, null, spot = src), user)


	if(istype(C, /obj/item/cable_coil))
		if(!intact)
			var/obj/item/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			boutput(user, "<span class='alert'>You must remove the plating first.</span>")

//grabsmash??
	else if (istype(C, /obj/item/grab/))
		var/obj/item/grab/G = C
		if  (!grab_smash(G, user))
			return ..(C, user)
		else
			return

	// hi i don't know where else to put this :D - cirr
	else if (istype(C, /obj/item/martianSeed))
		var/obj/item/martianSeed/S = C
		if(S)
			S.plant(src)
			logTheThing("station", user, null, "plants a martian biotech seed (<b>Structure:</b> [S.spawn_path]) at [log_loc(src)].")
			return

	//also in turf.dm. Put this here for lowest priority.
	else if (src.temp_flags & HAS_KUDZU)
		var/obj/spacevine/K = locate(/obj/spacevine) in src.contents
		if (K)
			K.attackby(C, user, params)

	else
		return attack_hand(user)

/turf/simulated/floor/MouseDrop_T(atom/A, mob/user as mob)
	..(A,user)
	if(istype(A,/turf/simulated/floor))
		var/turf/simulated/floor/F = A
		var/obj/item/I = user.equipped()
		if(I)
			if(istype(I,/obj/item/cable_coil))
				var/obj/item/cable_coil/C = I
				if((get_dist(user,F)<2) && (get_dist(user,src)<2))
					C.move_callback(user, F, src)
