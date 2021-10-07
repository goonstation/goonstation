//i just reorganised this thing and made it not actually awful to read dont mess this up please
//i havent done everything nicely, theres still a buncha things that could be like src.create_doors() but i cba to check and change like 800 lines sorry

/*
CONTAINS:
RCD
RCD deluxe
RCD ammo
Broken RCD + Effects
*/

#define RCD_MODE_FLOORSWALLS 1
#define RCD_MODE_AIRLOCK 2
#define RCD_MODE_DECONSTRUCT 3
#define RCD_MODE_WINDOWS 4
#define RCD_MODE_LIGHTBULBS 7
#define RCD_MODE_LIGHTTUBES 8
#define RCD_MODE_PODDOORCONTROL 5
#define RCD_MODE_PODDOOR 6

// @TODO: RCD Deluxe additional features (pod bay, etc)
// Letting the RCD-non-deluxe edit doors would be neat too, maybe. i guess. idk.
// bleh.

/*
	@TODO Fix the description stuff so it isn't manually updated constantly
	(get_desc is a thing!)
	Also maybe better handling; use on walls to reinforce?, that sort of thing
	maybe deconstructing an rwall turns into a normal wall first, etc
	hm hm

	also maybe an assoc list instead of matter_shit_fuck
*/

/obj/item/rcd
	name = "rapid construction device"
	desc = "Also known as an RCD, this is capable of rapidly constructing walls, flooring, windows, and doors."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "base"
	item_state = "rcd" //oops
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/max_matter = 50
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	m_amt = 50000

	mats = list("MET-3"=20, "DEN-3" = 10, "CON-2" = 10, "POW-2" = 10)
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	inventory_counter_enabled = 1

	// Borgs/drones can't really use matter units.
	// (matter cost) x (this) = (power cell charge used)
	var/const/silicon_cost_multiplier = 100

	/* construction cost and time */
	var/matter_create_floor = 1
	var/time_create_floor = 0 SECONDS

	var/matter_create_wall = 2
	var/time_create_wall = 5 SECONDS

	var/matter_reinforce_wall = 2
	var/time_reinforce_wall = 5 SECONDS

	var/matter_create_wall_girder = 1
	var/time_create_wall_girder = 2 SECONDS

	var/matter_create_door = 5
	var/time_create_door = 5 SECONDS

	var/matter_create_window = 2
	var/time_create_window = 2 SECONDS

	var/matter_create_light_fixture = 2
	var/time_create_light_fixture = 2 SECONDS

	/* deconstruction cost and time */
	var/matter_remove_door = 15
	var/time_remove_door = 5 SECONDS

	var/matter_remove_floor = 8
	var/time_remove_floor = 5 SECONDS

	var/matter_remove_lattice = 8
	var/time_remove_lattice = 5 SECONDS

	var/matter_remove_wall = 8
	var/time_remove_wall = 5 SECONDS

	var/matter_unreinforce_wall = 8
	var/time_unreinforce_wall = 5 SECONDS

	var/matter_remove_girder = 8
	var/time_remove_girder = 2 SECONDS

	var/matter_remove_window = 8
	var/time_remove_window = 5 SECONDS

	var/matter_remove_light_fixture = 1
	var/time_remove_light_fixture = 3 SECONDS

	var/shits_sparks = 1

	var/material_name = "steel"
	// list of materials that the RCD can deconstruct, if empty no restriction.
	var/safe_deconstruct = FALSE // whether deconstructing a wall will make the material
	// of the floor be different than the material of the wall
	// used to prevent venting with a material RCD by building a wall, deconstructing it, and then deconstructing the floor.
	var/list/restricted_materials
	// List of what this RCD is working on.
	// If you try to do something when something is in this the RCD ignores you.
	// No more easily flooding airlocks, jerks. Do it one at a time. >8)
	var/tmp/list/working_on = list()

	// The modes that this RCD has available to it
	var/list/modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS, RCD_MODE_LIGHTBULBS, RCD_MODE_LIGHTTUBES)
	// The actual selected mode
	var/mode = 1
	// What index into mode list we are (used for updating)
	var/internal_mode = 1

	/// do we really actually for real want this to work in adventure zones?? just do this with varedit dont make children with this on
	var/really_actually_bypass_z_restriction = false

	get_desc()
		. += "<br>It holds [matter]/[max_matter] [istype(src, /obj/item/rcd/material) ? material_name : "matter"]  units. It is currently set to "
		switch (src.mode)
			if (RCD_MODE_FLOORSWALLS)
				. += "Floors/Walls"
			if (RCD_MODE_AIRLOCK)
				. += "Airlocks"
			if (RCD_MODE_DECONSTRUCT)
				. += "Deconstruct"
			if (RCD_MODE_WINDOWS)
				. += "Windows"
			if (RCD_MODE_PODDOORCONTROL)
				. += "Pod Door Controls"
			if (RCD_MODE_PODDOOR)
				. += "Pod Doors"
			if (RCD_MODE_LIGHTBULBS)
				. += "Light Bulb Fixture"
			if (RCD_MODE_LIGHTTUBES)
				. += "Light Tube Fixture"
			else
				. += "???"
		. += " mode."

	New()
		..()
		src.update_icon()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			var/obj/item/rcd_ammo/R = W
			if (!restricted_materials || (R?.material.mat_id in restricted_materials))
				if (!R.matter)
					return
				if (matter == max_matter)
					boutput(user, "\The [src] can't hold any more matter.")
					return
				if (src.matter + R.matter > src.max_matter)
					R.matter -= (src.max_matter - src.matter)
					boutput(user, "The cartridge now contains [R.matter] units of matter.")
					src.matter = src.max_matter
				else
					src.matter += R.matter
					R.matter = 0
					qdel(R)
				R.tooltip_rebuild = 1
				src.update_icon()
				playsound(src, "sound/machines/click.ogg", 50, 1)
				boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter-units.")
				return
			else
				boutput(user, "This cartridge is not made of the proper material to be used in \The [src].")

	attack_self(mob/user as mob)
		playsound(src, "sound/effects/pop.ogg", 50, 0)

		src.internal_mode = (src.internal_mode % src.modes.len) + 1
		src.mode = src.modes[internal_mode]

		switch (mode)
			if (RCD_MODE_AIRLOCK)
				boutput(user, "Changed mode to 'Airlock'")

			if (RCD_MODE_DECONSTRUCT)
				boutput(user, "Changed mode to 'Deconstruct'")

			if (RCD_MODE_WINDOWS)
				boutput(user, "Changed mode to 'Windows'")

			if (RCD_MODE_FLOORSWALLS)
				boutput(user, "Changed mode to 'Floors and Walls'")

			if (RCD_MODE_PODDOORCONTROL)
				boutput(user, "Changed mode to 'Pod Door Control'")
				boutput(user, "<span class='notice'>Place a door control on a wall, then place any amount of pod doors on floors.</span>")
				boutput(user, "<span class='notice'>You can also select an existing door control by whacking it with \the [src].</span>")

			if (RCD_MODE_LIGHTBULBS)
				boutput(user, "Changed mode to 'Light Bulb Fixture'")

			if (RCD_MODE_LIGHTTUBES)
				boutput(user, "Changed mode to 'Light Tube Fixture'")

		// Gonna change this so it doesn't shit sparks when mode switched
		// Just that it does it only after actually doing something
		//src.shitSparks()
		src.update_icon()
		return

	afterattack(atom/A, mob/user as mob)
		if ((isrestrictedz(user.z) || isrestrictedz(A.z)) && !src.really_actually_bypass_z_restriction)
			boutput(user, "\The [src] won't work here for some reason. Oh well!")
			return

		if (get_dist(get_turf(src), get_turf(A)) > 1)
			return

		switch(src.mode)
			if (RCD_MODE_FLOORSWALLS)
				if (istype(A, /obj/lattice) || istype(A, /turf/space))
					if (istype(A, /obj/lattice))
						var/turf/L = get_turf(A)
						if (!istype(L, /turf/space)) return
						A = L

					if (do_thing(user, A, "building a floor", matter_create_floor, time_create_floor))
						var/turf/simulated/floor/T = A:ReplaceWithFloor()
						T.inherit_area()
						T.setMaterial(getMaterial(material_name))
						return


				if (istype(A, /turf/simulated/floor))
					if (do_thing(user, A, "building a wall", matter_create_wall, time_create_wall))
						var/turf/simulated/wall/T = A:ReplaceWithWall()
						T.inherit_area()
						T.setMaterial(getMaterial(material_name))
						log_construction(user, "builds a wall ([T])")
						return

				if (istype(A, /turf/simulated/wall))
					if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced) || istype(A, /turf/simulated/wall/auto/shuttle))
						return	// You can't go reinforcing stuff that's already reinforced you dope.
					if (do_thing(user, A, "reinforcing the wall", matter_reinforce_wall, time_reinforce_wall))
						var/turf/simulated/wall/T = A:ReplaceWithRWall()
						T.inherit_area()
						T.setMaterial(getMaterial(material_name))
						log_construction(user, "reinforces a wall ([T])")
						return

				if (istype(A, /obj/structure/girder) && !istype(A, /obj/structure/girder/displaced))
					if (do_thing(user, A, "turning \the [A] into a wall", matter_create_wall_girder, time_create_wall_girder))
						var/turf/wallTurf = get_turf(A)

						var/turf/simulated/wall/T
						if (istype(A, /obj/structure/girder/reinforced))
							T = wallTurf:ReplaceWithRWall()
						else
							T = wallTurf:ReplaceWithWall()

						T.setMaterial(getMaterial(material_name))

						log_construction(user, "builds a wall ([T]) on girder ([A])")
						qdel(A)
						return


			if (RCD_MODE_AIRLOCK)
				// create_door handles all the other stuff.
				create_door(A, user)
				return

			if (RCD_MODE_DECONSTRUCT)

				if(restricted_materials && !(A.material?.mat_id in restricted_materials))
					boutput(user, "Target object is not made of a material this RCD can deconstruct.")
					return
				if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
					if (do_thing(user, A, "removing the reinforcement from \the [A]", matter_unreinforce_wall, time_unreinforce_wall))
						var/turf/simulated/wall/T = A:ReplaceWithWall()
						T.setMaterial(getMaterial(material_name))
						log_construction(user, "deconstructs a reinforced wall into a normal wall ([T])")
						return

				if (istype(A, /turf/simulated/wall))
					if (istype(A, /turf/simulated/wall/auto/shuttle))
						return
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_wall, time_remove_wall))
						var/turf/simulated/floor/T = A:ReplaceWithFloor()
						if (!restricted_materials || !safe_deconstruct)
							T.setMaterial(getMaterial(material_name))
						else if(!("steel" in restricted_materials))
							T.setMaterial(getMaterial("steel"))
						else
							T.setMaterial(getMaterial("negativematter"))
						log_construction(user, "deconstructs a wall ([A])")
						return

				if (istype(A, /turf/simulated/floor))
					if (do_thing(user, A, "removing \the [A]", matter_remove_floor, time_remove_floor))
						log_construction(user, "removes flooring ([A])")
						A:ReplaceWithSpace()
						return

				if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
					var/obj/machinery/door/airlock/AL = A
					if (AL.hardened == 1)
						boutput(user, "<span class='alert'>\The [AL] is reinforced against rapid deconstruction!</span>")
						return
					if (do_thing(user, AL, "deconstructing \the [AL]", matter_remove_door, time_remove_door))
						log_construction(user, "deconstructs an airlock ([AL])")
						qdel(AL)
						return

				if (istype(A, /obj/structure/girder))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_girder, time_remove_girder))
						log_construction(user, "deconstructs a girder ([A])")
						qdel(A)
						return

				if (istype(A, /obj/window))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_window, time_remove_window))
						log_construction(user, "deconstructs a window ([A])")
						qdel(A)
						return

				if (istype(A, /obj/lattice))
					// really? why in the world are lattices so damn expensive. honk
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_lattice, time_remove_lattice))
						log_construction(user, "deconstructs a lattice ([A])")
						qdel(A)
						return

				if (istype(A, /obj/machinery/light))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_light_fixture, time_remove_light_fixture))
						log_construction(user, "deconstructs a light fixture ([A])")
						qdel(A)
						return

			if (RCD_MODE_WINDOWS)
				if (istype(A, /turf/simulated/floor) || istype(A, /obj/grille/))
					if (istype(A, /obj/grille/))
						// You can do this with normal windows. So now you can do it with RCD windows. Honke.
						A = get_turf(A)
						if (!istype(A, /turf/simulated/floor))
							return
					if (do_thing(user, A, "building a window", matter_create_window, time_create_window))
						// Is /auto always the one to use here? hm.
						new map_settings.windows(get_turf(A))
						log_construction(user, "builds a window")
						return
			if (RCD_MODE_LIGHTBULBS)
				if (istype(A, /turf/simulated/wall))
					if((locate(/obj/machinery/light) in A) || (locate(/obj/machinery/light) in get_turf(user)))
						boutput(user, "There's already a lamp there!") // stacking lights simply can't be good for the environment
						return
					var/dir
					for (var/d in cardinal)
						if (get_step(user,d) == A)
							dir = d
							break
					if(!dir) // lights only apply themselves if standing at a cardinal direction from the wall
						boutput(user, "You can't seem to reach that part of \the [A]. Try standing right up against it.")
						return
					var/turf/simulated/wall/W = A
					if (do_thing(user, W, "attaching a light bulb fixture to \the [W]", matter_create_light_fixture, time_create_light_fixture))
						var/obj/item/light_parts/bulb/LB = new /obj/item/light_parts/bulb(get_turf(W))
						LB.setMaterial(getMaterial(material_name))
						W.attach_light_fixture_parts(user, LB, TRUE)
						log_construction(user, "built a light fixture to a wall ([W])")

				if (istype(A, /turf/simulated/floor))
					if((locate(/obj/machinery/light) in A)) // Just check the floor, not the user
						boutput(user, "There's already a light there!") // stacking lights simply can't be good for the environment
						return
					var/turf/simulated/floor/F = A
					if (do_thing(user, F, "building a floor lamp on \the [F]", matter_create_light_fixture, time_create_light_fixture))
						var/obj/item/light_parts/floor/FL = new /obj/item/light_parts/floor(get_turf(F))
						FL.setMaterial(getMaterial(material_name))
						F.attach_light_fixture_parts(user, FL, TRUE)
						log_construction(user, "built a floor lamp on a floor ([F])")

			if (RCD_MODE_LIGHTTUBES)
				if((locate(/obj/machinery/light) in A) || (locate(/obj/machinery/light) in get_turf(user)))
					boutput(user, "There's already a lamp there!")
					return
				if (istype(A, /turf/simulated/wall))
					var/dir
					for (var/d in cardinal)
						if (get_step(user,d) == A)
							dir = d
							break
					if(!dir)
						boutput(user, "You can't seem to reach that part of \the [A]. Try standing right up against it.")
						return
					var/turf/simulated/wall/W = A
					if (do_thing(user, W, "attaching a light bulb fixture to \the [W]", matter_create_light_fixture, time_create_light_fixture))
						var/obj/item/light_parts/LB = new /obj/item/light_parts(get_turf(W))
						LB.setMaterial(getMaterial(material_name))
						W.attach_light_fixture_parts(user, LB, TRUE)
						log_construction(user, "built a light fixture to a wall ([W])")


/* flesh wall creation code
// holy jesus christ
	attack(mob/M as mob, mob/user as mob, def_zone)
		if (ishuman(M) && matter >= 3)
			var/mob/living/carbon/human/H = M
			if(!isdead(H) && H.health > 0)
				boutput(user, "<span class='alert'>You poke [H] with \the [src].</span>")
				boutput(H, "<span class='alert'>[user] pokes you with \the [src].</span>")
				return
			boutput(user, "<span class='alert'><B>You shove \the [src] down [H]'s mouth and pull the trigger!</B></span>")
			H.show_message("<span class='alert'><B>[user] is shoving an RCD down your throat!</B></span>", 1)
			for(var/mob/N in viewers(user, 3))
				if(N.client && N != user && N != H)
					N.show_message(text("<span class='alert'><B>[] shoves \the [src] down []'s throat!</B></span>", user, H), 1)
			playsound(src, "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 2 SECONDS))
				elecflash(src)
				var/mob/living/carbon/wall/W = new(H.loc)
				W.real_name = H.real_name
				playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
				playsound(src, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
				H.mind?.transfer_to(W)
				H.gib()
				matter -= 3
				boutput(user, "\the [src] now holds [matter]/30 matter-units.")
				desc = "A RCD. It currently holds [matter]/30 matter-units."
			return
		else
			return ..(M, user, def_zone)
*/

	proc/shitSparks()
		if (!src.shits_sparks)
			return
		elecflash(src)

	proc/ammo_check(mob/user as mob, var/checkamt = 0)
		if (issilicon(user))
			var/mob/living/silicon/S = user
			return (S.cell && (S.cell.charge >= checkamt * silicon_cost_multiplier))
		else
			return (src.matter >= checkamt)

	proc/ammo_consume(mob/user as mob, var/checkamt = 0)
		if (issilicon(user))
			var/mob/living/silicon/S = user
			if (S.cell)
				S.cell.charge -= checkamt * silicon_cost_multiplier
		else
			src.matter -= checkamt
			boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter units.")
			src.update_icon()

	proc/do_thing(mob/user as mob, atom/target, var/what, var/ammo, var/delay)
		if (!ammo_check(user, ammo))
			boutput(user, "Unable to start [what] &mdash; you need at least [issilicon(user) ? "[ammo * src.silicon_cost_multiplier] charge" : "[ammo] matter units"].")
			return 0

		if (target in src.working_on)
			// Make sure someone can't just spam the same command on the same item.
			// Building multiple things on the same turf? Nyet!
			boutput(user, "\The [src] is already operating on that!")
			return 0
		src.working_on += target

		playsound(src, "sound/machines/click.ogg", 50, 1)
		boutput(user, "You start [what]... ([issilicon(user) ? "[ammo * src.silicon_cost_multiplier] charge" : "[ammo] matter units"][delay ? ", [delay / 10] seconds" : ""])")

		if ((!delay || do_after(user, delay)) && ammo_check(user, ammo))
			ammo_consume(user, ammo)
			playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
			shitSparks()
			src.working_on -= target
			return 1

		src.working_on -= target
		return 0

	proc/log_construction(mob/user as mob, var/what)
		logTheThing("station", user, null, "[what] using \the [src] at [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

	proc/create_door(var/turf/A, mob/user as mob)
		if(do_thing(user, A, "building an airlock", matter_create_door, time_create_door))
			var/interim = fetchAirlock()
			var/obj/machinery/door/airlock/T = new interim(A)
			log_construction(user, "builds an airlock ([T])")

			//if(map_setting == "COG2") T.set_dir(user.dir)
			T.autoclose = 1

	proc/update_icon() //we got fancy rcds now
		if (GetOverlayImage("mode"))
			src.ClearSpecificOverlays("mode")
		var/ammo_amt = 0
		tooltip_rebuild = 1
		switch (round((src.matter / src.max_matter) * 100)) //is the round() necessary? yell at me if it isnt
			if (10 to 34)
				ammo_amt = 1
			if (34 to 67)
				ammo_amt = 2
			if (67 to 100)
				ammo_amt = 3
			if (100 to INFINITY)
				ammo_amt = 3
			else //is this necessary? yell at me if it isnt
				ammo_amt = 0

		var/mode = ""
		switch (src.mode)
			if (RCD_MODE_FLOORSWALLS)
				mode = "standard"
			if (RCD_MODE_AIRLOCK)
				mode = "doors"
			if (RCD_MODE_DECONSTRUCT)
				mode = "decon"
			if (RCD_MODE_WINDOWS)
				mode = "window"
			if (RCD_MODE_PODDOORCONTROL)
				mode = "poddoors"
			if (RCD_MODE_PODDOOR)
				mode = "poddoors"
			if (RCD_MODE_LIGHTBULBS)
				mode = "lights"
			if (RCD_MODE_LIGHTTUBES)
				mode = "lights"
			else
				mode = "standard"

		var/image/I = SafeGetOverlayImage("mode", src.icon, "[mode]-[ammo_amt]")
		src.UpdateOverlays(I, "mode")

		if (!issilicon(usr))
			src.inventory_counter.update_number(matter)

///////////////////
//NORMAL VARIANTS//
///////////////////

//unused except for in the research module
/obj/item/rcd/cyborg
	material_name = "electrum"

/obj/item/rcd/construction
	name = "rapid construction device deluxe"
	desc = "Also known as an RCD, this is capable of rapidly constructing walls, flooring, windows, and doors. The deluxe edition features a much higher matter capacity and enhanced feature set."
	max_matter = 15000

	matter_remove_door = 3
	matter_remove_wall = 2
	matter_remove_floor = 2

	var/static/hangar_id_number = 1 //static isnt a real thing in byond????? why does this compile???
	var/hangar_id = null
	var/door_name = null
	var/door_access = 0
	var/door_access_name_cache = null
	var/door_type_name_cache = null
	mats = list("MET-3"=100, "DEN-3" = 50, "CON-2"=50, "POW-3"=50, "starstone"=10)
	var/static/list/access_names = list() //ditto the above????
	var/door_type = null

// Safe variants don't spew sparks everywhere
/obj/item/rcd/construction/safe
	shits_sparks = 0

/obj/item/rcd/safe
	shits_sparks = 0

///Chief Engineer RCD has fancy door functions and a mild discount, but no capacity increase
/obj/item/rcd/construction/chiefEngineer
	name = "rapid construction device custom"
	desc = "Also known as an RCD, this is capable of rapidly constructing walls, flooring, windows, and doors. This device was customized by the Chief Engineer to have an enhanced feature set and work more efficiently."
	icon_state = "base_CE"
	mats = list("MET-3"=20, "DEN-3" = 10, "CON-2" = 10, "POW-2" = 10)

	max_matter = 50
	matter_create_wall = 1
	matter_create_door = 4
	matter_create_window = 1
	matter_remove_door = 10
	matter_remove_floor = 6
	matter_remove_wall = 6
	matter_remove_girder = 6
	matter_remove_window = 6

/obj/item/rcd/construction
	afterattack(atom/A, mob/user as mob)
		..()
		if (mode == RCD_MODE_DECONSTRUCT)
			if (istype(A, /obj/machinery/door/poddoor/blast) && ammo_check(user, matter_remove_door, 500))
				var /obj/machinery/door/poddoor/blast/B = A
				if (findtext(B.id, "rcd_built") != 0)
					boutput(user, "Deconstructing \the [B] ([matter_remove_door])...")
					playsound(src, "sound/machines/click.ogg", 50, 1)
					if(do_after(user, 5 SECONDS))
						if (ammo_check(user, matter_remove_door))
							playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
							src.shitSparks()
							ammo_consume(user, matter_remove_door)
							logTheThing("station", user, null, "removes a pod door ([B]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
							qdel(A)
							playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
				else
					boutput(user, "<span class='alert'>You cannot deconstruct that!</span>")
					return
			else if (istype(A, /obj/machinery/r_door_control) && ammo_check(user, matter_remove_door, 500))
				var/obj/machinery/r_door_control/R = A
				if (findtext(R.id, "rcd_built") != 0)
					boutput(user, "Deconstructing \the [R] ([matter_remove_door])...")
					playsound(src, "sound/machines/click.ogg", 50, 1)
					if(do_after(user, 5 SECONDS))
						if (ammo_check(user, matter_remove_door))
							playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
							src.shitSparks()
							ammo_consume(user, matter_remove_door)
							logTheThing("station", user, null, "removes a Door Control ([A]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
							qdel(A)
							playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
				else
					boutput(user, "<span class='alert'>You cannot deconstruct that!</span>")
					return
		else if (mode == RCD_MODE_PODDOORCONTROL)
			if (istype(A, /obj/machinery/r_door_control))
				var/obj/machinery/r_door_control/R = A
				if (findtext(R.id, "rcd_built") != 0)
					boutput(user, "<span class='notice'>Selected.</span>")
					hangar_id = R.id
					mode = RCD_MODE_PODDOOR
				else
					boutput(user, "<span class='alert'>You cannot modify that!</span>")
			else if (istype(A, /turf/simulated/wall) && ammo_check(user, matter_create_door, 500))
				boutput(user, "Creating Door Control ([matter_create_door])")
				playsound(src, "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 5 SECONDS))
					if (ammo_check(user, matter_create_door))
						playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						var/idn = hangar_id_number
						hangar_id_number++
						hangar_id = "rcd_built_[idn]"
						mode = RCD_MODE_PODDOOR
						var/obj/machinery/r_door_control/R = new /obj/machinery/r_door_control(A)
						R.id="[hangar_id]"
						R.pass="[hangar_id]"
						R.name="Access code: [hangar_id]"
						ammo_consume(user, matter_create_door)
						logTheThing("station", user, null, "creates Door Control [hangar_id] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
						boutput(user, "Now creating pod bay blast doors linked to the new door control.")

		else if (mode == RCD_MODE_PODDOOR)
			if (istype(A, /turf/simulated/floor) && ammo_check(user, matter_create_door, 500))
				boutput(user, "Creating Pod Bay Door ([matter_create_door])")
				playsound(src, "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 5 SECONDS))
					if (ammo_check(user, matter_create_door))
						playsound(src, "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						var/stepdir = get_dir(src, A)
						var/poddir = turn(stepdir, 90)
						var/obj/machinery/door/poddoor/blast/B = new /obj/machinery/door/poddoor/blast(A)
						B.id = "[hangar_id]"
						B.set_dir(poddir)
						B.autoclose = 1
						ammo_consume(user, matter_create_door)
						logTheThing("station", user, null, "creates Blast Door [hangar_id] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")

	create_door(var/turf/A, mob/user as mob)
		var/turf/L = get_turf(user)
		var/door_dir = user.dir
		var/set_data = 0

		if (A in src.working_on)
			return

		if (door_name)
			if (alert("Use current settings?\nName: [door_name]\nAccess: [door_access_name_cache]\nType: [door_type_name_cache]","fdhablkfdbhdflbk","Yes","No") == "No")
				set_data = 1
		else
			set_data = 1

		if (set_data)
			if (!access_names.len)
				access_names["None"] = 0
				for (var/access in get_all_accesses())
					var/access_name = get_access_desc(access)
					access_names[access_name] = access
			var/door_types = get_airlock_types()

			door_name = copytext(adminscrub(input("Door name", "RCD", door_name) as text), 1, 512)
			door_access_name_cache = input("Required access", "RCD", door_access_name_cache) in access_names
			door_type_name_cache = input("Door type", "Yep", door_type_name_cache) in door_types

			if (!door_types[door_type_name_cache])
				boutput(user, "Something went fucky with this and it broke, sorry. Call a coder.")
				return

			door_access = access_names[door_access_name_cache]
			door_type = door_types[door_type_name_cache]

		if (user.loc != L)
			boutput(user, "<span class='alert'>Airlock build cancelled - you moved.</span>")
			return

		if (do_thing(user, A, "building an airlock", matter_create_door, 5 SECONDS))
			var/obj/machinery/door/airlock/T = new door_type(A)
			log_construction(user, null, "builds an airlock ([T], name: [door_name], access: [door_access], type: [door_type])")
			T.set_dir(door_dir)
			T.autoclose = 1
			T.name = door_name
			if (door_access)
				T.req_access = list(door_access)
				T.req_access_txt = "[door_access]"
			else
				T.req_access = null
				T.req_access_txt = null

/obj/item/rcd/material


	afterattack(atom/A, mob/user as mob)
		if (get_dist(get_turf(src), get_turf(A)) > 1)
			return
		if (mode == RCD_MODE_WINDOWS)
			if (istype(A, /turf/simulated/floor) || istype(A, /obj/grille/))
				if (istype(A, /obj/grille/))
					// You can do this with normal windows. So now you can do it with RCD windows. Honke.
					A = get_turf(A)
					if (!istype(A, /turf/simulated/floor))
						return
				if (do_thing(user, A, "building a window", matter_create_window, time_create_window))
					// Is /auto always the one to use here? hm.
					var/obj/window/T = new (get_turf(A))
					log_construction(user, "builds a window")
					T.setMaterial(getMaterial(material_name))
					return
		else
			..()

	create_door(var/turf/A, mob/user as mob)
		var/turf/L = get_turf(user)
		var/door_dir = user.dir

		if (A in src.working_on)
			return

		if (user.loc != L)
			boutput(user, "<span class='alert'>Door build cancelled - you moved.</span>")
			return

		if (do_thing(user, A, "building a door", matter_create_door, 5 SECONDS))
			var/obj/machinery/door/unpowered/wood/T = new (A)
			T.set_dir(door_dir)
			T.setMaterial(getMaterial(material_name))
			log_construction(user, null, "builds a door ([T]")



/obj/item/rcd/material/cardboard
	name = "cardboard rapid construction Device"
	desc = "Also known as a C-RCD, this device is able to rapidly construct cardboard props."
	mats = list("DEN-3" = 10, "POW-2" = 10, "cardboard" = 30)
	matter_create_floor = 0.5
	time_create_floor = 0 SECONDS

	matter_create_wall = 3
	time_create_wall = 5 SECONDS

	matter_reinforce_wall = 2.5
	time_reinforce_wall = 5 SECONDS

	matter_create_wall_girder = 2
	time_create_wall_girder = 2 SECONDS

	matter_create_door = 4
	time_create_door = 5 SECONDS

	matter_create_window = 2
	time_create_window = 2 SECONDS

	matter_remove_door = -2
	time_remove_door = 5 SECONDS

	matter_remove_floor = 0
	time_remove_floor = 5 SECONDS

	matter_remove_lattice = 0
	time_remove_lattice = 5 SECONDS

	matter_remove_wall = -1
	time_remove_wall = 5 SECONDS

	matter_unreinforce_wall = -1
	time_unreinforce_wall = 5 SECONDS

	matter_remove_girder = -1
	time_remove_girder = 2 SECONDS

	matter_remove_window = -1
	time_remove_window = 5 SECONDS


	shits_sparks = 0

	material_name = "cardboard"
	restricted_materials = list("cardboard")
	safe_deconstruct = TRUE

	modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS)


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			..()
		else if (isExploitableObject(W))
			boutput(user, "Recycling [W] just doesn't work.")
		else if (istype(W, /obj/item/paper/book))
			matter += 5
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (istype(W, /obj/item/paper))
			matter += 0.5
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (istype(W, /obj/item/paper_booklet))
			var/obj/item/paper_booklet/booklet = W
			matter += booklet.pages.len/2
			boutput(user, "\The [src] recycles [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)
		else if (W?.material?.mat_id == "wood")
			matter += 20
			boutput(user, "\The [src] pulps [W], and now holds [src.matter]/[src.max_matter] [material_name]-units.")
			qdel(W)

////////
//AMMO//
////////

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for a rapid construction device."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "ammo"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	m_amt = 30000
	g_amt = 15000
	var/matter = 10

	get_desc()
		. += "<br>It contains [matter] units of ammo."

	attackby(obj/item/W, mob/user, params)
		if(istype(W, /obj/item/rcd))
			W.Attackby(src, user, params)
			return
		. = ..()

/obj/item/rcd_ammo/medium
		name = "medium compressed matter cartridge"
		icon_state = "ammo_big"
		matter = 50

/obj/item/rcd_ammo/big
		name = "large compressed matter cartridge"
		icon_state = "ammo_biggest"
		matter = 100

////////////////////
//GIMMICK VARIANTS//
////////////////////

//this isnt used anywhere that i can find
/obj/item/rcd_fake
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL

//Broken RCDs.  Attempting to use them is...ill advised.
/obj/item/broken_rcd
	name = "prototype rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/rcd.dmi'
	icon_state = "bad_rcd0"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rcd"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	m_amt = 50000
	var/mode = 1
	var/broken = 0 //Fully broken, that is.

	New()
		..()
		src.icon_state = "bad_rcd[rand(0,2)]"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			boutput(user, "\the [src] slot is not compatible with this cartridge.")
			return

	attack_self(mob/user as mob)
		if (src.broken)
			boutput(user, "<span class='alert'>It's broken!</span>")
			return

		playsound(src.loc, "sound/effects/pop.ogg", 50, 0)
		if (mode)
			mode = 0
			boutput(user, "Changed mode to 'Deconstruct'")
			elecflash(src)
			return
		else
			mode = 1
			boutput(user, "Changed mode to 'Floor & Walls'")
			elecflash(src)
			return

	afterattack(atom/A, mob/user as mob)
		if (src.broken > 1)
			boutput(user, "<span class='alert'>It's broken!</span>")
			return

		if (!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return
		if ((istype(A, /turf/space) || istype(A, /turf/simulated/floor)) && mode)
			if (src.broken)
				boutput(user, "<span class='alert'>Insufficient charge.</span>")
				return

			boutput(user, "Building [istype(A, /turf/space) ? "Floor (1)" : "Wall (3)"]...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 2 SECONDS))
				if (src.broken)
					return

				src.broken++
				elecflash(src)
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

				for (var/turf/T in orange(1,user))
					T.ReplaceWithWall()


				boutput(user, "<span class='alert'>\the [src] shorts out!</span>")
				return

		else if (!mode)
			boutput(user, "Deconstructing ??? ([rand(1,8)])...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user,50))
				if (src.broken)
					return

				src.broken++
				elecflash(src)
				playsound(src.loc, "sound/items/Deconstruct.ogg", 100, 1)

				boutput(user, "<span class='combat'>\the [src] shorts out!</span>")

				logTheThing("combat", user, null, "manages to vaporize \[[showCoords(A.x, A.y, A.z)]] with a halloween RCD.")

				new /obj/effects/void_break(A)
				if (user)
					user.gib()

/obj/effects/void_break
	invisibility = INVIS_ALWAYS
	anchored = 1
	var/lifespan = 4
	var/rangeout = 0

	New()
		..()
		lifespan = rand(2,4)
		rangeout = lifespan
		SPAWN_DBG(0.5 SECONDS)
			void_shatter()
			void_loop()

	proc/void_shatter()
		playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 80, 1)
		for (var/atom/A in range(lifespan, src))
			if (istype(A, /turf/simulated))
				A.pixel_x = rand(-4,4)
				A.pixel_y = rand(-4,4)
			else if (isliving(A))
				shake_camera(A, 8, 32)
				A.ex_act( get_dist(src, A) > 1 ? 3 : 1 )

			else if (istype(A, /obj) && (A != src))

				if ((get_dist(src, A) <= 2) || prob(10))
					A.ex_act(1)
				else if (prob(5))
					A.ex_act(3)

				continue

		elecflash(src,power=3)

	proc/void_loop()
		if (lifespan-- < 0)
			qdel(src)
			return

		for (var/turf/simulated/T in range(src, (rangeout-lifespan)))
			if (prob(5 + lifespan) && limiter.canISpawn(/obj/effects/sparks))
				var/obj/sparks = unpool(/obj/effects/sparks)
				sparks.set_loc(T)
				SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)

			T.ex_act((rangeout-lifespan) < 2 ? 1 : 2)

		SPAWN_DBG(1.5 SECONDS)
			void_loop()
		return
