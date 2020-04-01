/*
CONTAINS:
RCD
Broken RCD + Effects
*/

#define RCD_MODE_FLOORSWALLS 1
#define RCD_MODE_AIRLOCK 2
#define RCD_MODE_DECONSTRUCT 3
#define RCD_MODE_WINDOWS 4
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
	icon = 'icons/obj/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
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
	w_class = 3.0
	m_amt = 50000
	var/datum/effects/system/spark_spread/spark_system
	mats = 12
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	module_research = list("tools" = 8, "engineering" = 8, "devices" = 3, "efficiency" = 5)
	module_research_type = /obj/item/rcd

	// Borgs/drones can't really use matter units.
	// (matter cost) x (this) = (power cell charge used)
	var/const/silicon_cost_multiplier = 100

	var/matter_create_floor = 1
	var/matter_create_wall = 2
	var/matter_create_wall_girder = 1
	var/matter_create_door = 5
	var/matter_create_window = 2
	var/matter_remove_door = 15
	var/matter_remove_floor = 8
	var/matter_remove_wall = 8
	var/matter_remove_girder = 8
	var/matter_remove_window = 8

	var/shits_sparks = 1

	var/material_name = "steel"

	// List of what this RCD is working on.
	// If you try to do something when something is in this the RCD ignores you.
	// No more easily flooding airlocks, jerks. Do it one at a time. >8)
	var/tmp/list/working_on = list()

	// The modes that this RCD has available to it
	var/list/modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS)
	// The actual selected mode
	var/mode = 1
	// What index into mode list we are (used for updating)
	var/internal_mode = 1

	get_desc(dist)
		. += "<br>It holds [matter]/[max_matter] matter units. It is currently set to "
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
			else
				. += "???"
		. += "mode."


	// Unused?
	cyborg
		material_name = "electrum"


	construction
		name = "rapid construction device deluxe"
		desc = "Also known as an RCD, this is capable of rapidly constructing walls, flooring, windows, and doors. The deluxe edition features a much higher matter capacity and enhanced feature set."
		max_matter = 15000

		matter_remove_door = 3
		matter_remove_wall = 2
		matter_remove_floor = 2

		var/static/hangar_id_number = 1
		var/hangar_id = null
		var/door_name = null
		var/door_access = 0
		var/door_access_name_cache = null
		var/door_type_name_cache = null

		var/static/list/access_names = list()
		var/door_type = null

		// Safe variants don't spew sparks everywhere
		safe
			shits_sparks = 0

	safe
		shits_sparks = 0



	New()
		if (src.shits_sparks)
			src.spark_system = unpool(/datum/effects/system/spark_spread)
			spark_system.set_up(5, 0, src)
			spark_system.attach(src)
		return


	pickup(mob/M)
		..()
		src.update_maptext()

	dropped(mob/M)
		src.maptext = null
		..()


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			if (!W:matter)
				return
			if (matter == max_matter)
				boutput(user, "\The [src] can't hold any more matter.")
				return
			if (matter + W:matter > max_matter)
				W:matter -= (max_matter - matter)
				boutput(user, "The cartridge now contains [W:matter] units of matter.")
				matter = max_matter
			else
				matter += W:matter
				W:matter = 0
				qdel(W)
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			boutput(user, "\The [src] now holds [matter]/[max_matter] matter-units.")
			if (src.maptext)
				src.update_maptext()
			return


	attack_self(mob/user as mob)
		playsound(get_turf(src), "sound/effects/pop.ogg", 50, 0)

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
				boutput(user, "<span style=\"color:blue\">Place a door control on a wall, then place any amount of pod doors on floors.</span>")
				boutput(user, "<span style=\"color:blue\">You can also select an existing door control by whacking it with \the [src].</span>")

		// Gonna change this so it doesn't shit sparks when mode switched
		// Just that it does it only after actually doing something
		//src.shitSparks()
		src.update_maptext()
		return


	afterattack(atom/A, mob/user as mob)
		if (get_dist(get_turf(src), get_turf(A)) > 1)
			return

		switch(src.mode)
			if (RCD_MODE_FLOORSWALLS)
				if (istype(A, /obj/lattice) || istype(A, /turf/space))
					if (istype(A, /obj/lattice))
						var/turf/L = get_turf(A)
						if (!istype(L, /turf/space)) return
						A = L

					if (do_thing(user, A, "building a floor", matter_create_floor, 0 SECONDS))
						var/turf/simulated/floor/T = A:ReplaceWithFloor()
						T.inherit_area()
						T.setMaterial(getMaterial(material_name))
						return


				if (istype(A, /turf/simulated/floor))
					if (do_thing(user, A, "building a wall", matter_create_wall, 5 SECONDS))
						var/datum/material/M = A:material
						var/turf/simulated/wall/T = A:ReplaceWithWall()
						T.inherit_area()
						T.setMaterial(M ? M : getMaterial(material_name))
						log_construction(user, "builds a wall ([T])")
						return

				if (istype(A, /turf/simulated/wall))
					if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
						return	// You can't go reinforcing stuff that's already reinforced you dope.
					if (do_thing(user, A, "reinforcing the wall", matter_create_wall, 5 SECONDS))
						var/datum/material/M = A:material
						var/turf/simulated/wall/T = A:ReplaceWithRWall()
						T.inherit_area()
						T.setMaterial(M ? M : getMaterial(material_name))
						log_construction(user, "reinforces a wall ([T])")
						return

				if (istype(A, /obj/structure/girder) && !istype(A, /obj/structure/girder/displaced))
					if (do_thing(user, A, "turning \the [A] into a wall", matter_create_wall_girder, 2 SECONDS))
						var/datum/material/M = A:material
						var/turf/wallTurf = get_turf(A)

						var/turf/simulated/wall/T
						if (istype(A, /obj/structure/girder/reinforced))
							T = wallTurf:ReplaceWithRWall()
						else
							T = wallTurf:ReplaceWithWall()

						T.setMaterial(M ? M : getMaterial(material_name))

						log_construction(user, "builds a wall ([T]) on girder ([A])")
						qdel(A)
						return


			if (RCD_MODE_AIRLOCK)
				// create_door handles all the other stuff.
				create_door(A, user)
				return

			if (RCD_MODE_DECONSTRUCT)

				if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
					if (do_thing(user, A, "removing the reinforcement from \the [A]", matter_remove_wall, 5 SECONDS))
						var/datum/material/M = A:material
						var/turf/simulated/wall/T = A:ReplaceWithWall()
						T.setMaterial(M ? M : getMaterial(material_name))
						log_construction(user, "deconstructs a reinforced wall into a normal wall ([T])")
						return

				if (istype(A, /turf/simulated/wall))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_wall, 5 SECONDS))
						var/datum/material/M = A:material
						var/turf/simulated/floor/T = A:ReplaceWithFloor()
						T.setMaterial(M ? M : getMaterial(material_name))
						log_construction(user, "deconstructs a wall ([A])")
						return

				if (istype(A, /turf/simulated/floor))
					if (do_thing(user, A, "removing \the [A]", matter_remove_floor, 5 SECONDS))
						log_construction(user, "removes flooring ([A])")
						A:ReplaceWithSpace()
						return

				if (istype(A, /obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AL = A
					if (AL.hardened == 1)
						boutput(user, "<span style=\"color:red\">\The [AL] is reinforced against rapid deconstruction!</span>")
						return
					if (do_thing(user, AL, "deconstructing \the [AL]", matter_remove_door, 5 SECONDS))
						log_construction(user, "deconstructs an airlock ([AL])")
						qdel(AL)
						return

				if (istype(A, /obj/structure/girder))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_girder, 2 SECONDS))
						log_construction(user, "deconstructs a girder ([A])")
						qdel(A)
						return

				if (istype(A, /obj/window))
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_window, 5 SECONDS))
						log_construction(user, "deconstructs a window ([A])")
						qdel(A)
						return

				if (istype(A, /obj/lattice))
					// really? why in the world are lattices so damn expensive. honk
					if (do_thing(user, A, "deconstructing \the [A]", matter_remove_floor, 5 SECONDS))
						log_construction(user, "deconstructs a lattice ([A])")
						qdel(A)
						return

			if (RCD_MODE_WINDOWS)
				if (istype(A, /turf/simulated/floor) || istype(A, /obj/grille/))
					if (istype(A, /obj/grille/))
						// You can do this with normal windows. So now you can do it with RCD windows. Honke.
						A = get_turf(A)
						if (!istype(A, /turf/simulated/floor))
							return
					if (do_thing(user, A, "building a window", matter_create_window, 2 SECONDS))
						// Is /auto always the one to use here? hm.
						new map_settings.windows(get_turf(A))
						log_construction(user, "builds a window")
						return

	proc
		shitSparks()
			if (!src.shits_sparks)
				return
			spark_system.set_up(5, 0, src)
			src.spark_system.start()

		update_maptext()
			if (!src.matter)
				src.maptext = null
				return

			src.maptext_x = -2
			src.maptext_y = 1
			src.maptext = {"<span class="vb r pixel sh">[src.matter]</span></span>"}

		ammo_check(mob/user as mob, var/checkamt = 0)
			if (issilicon(user))
				var/mob/living/silicon/S = user
				return (S.cell && (S.cell.charge >= checkamt * silicon_cost_multiplier))
			else
				return (src.matter >= checkamt)

		ammo_consume(mob/user as mob, var/checkamt = 0)
			if (issilicon(user))
				var/mob/living/silicon/S = user
				if (S.cell)
					S.cell.charge -= checkamt * silicon_cost_multiplier
			else
				src.matter -= checkamt
				boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter units.")


		do_thing(mob/user as mob, atom/target, var/what, var/ammo, var/delay)
			if (!ammo_check(user, ammo))
				boutput(user, "Unable to start [what] &mdash; you need at least [issilicon(user) ? "[ammo * src.silicon_cost_multiplier] charge" : "[ammo] matter units"].")
				return 0

			if (target in src.working_on)
				// Make sure someone can't just spam the same command on the same item.
				// Building multiple things on the same turf? Nyet!
				boutput(user, "\The [src] is already operating on that!")
				return 0
			src.working_on += target

			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			boutput(user, "You start [what]... ([issilicon(user) ? "[ammo * src.silicon_cost_multiplier] charge" : "[ammo] matter units"][delay ? ", [delay / 10] seconds" : ""])")

			if ((!delay || do_after(user, delay)) && ammo_check(user, ammo))
				ammo_consume(user, ammo)
				playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
				src.update_maptext()
				shitSparks()
				src.working_on -= target
				return 1

			src.working_on -= target
			return 0


		log_construction(mob/user as mob, var/what)
			logTheThing("station", user, null, "[what] using \the [src] at [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")


		create_door(var/turf/A, mob/user as mob)
			if(do_thing(user, A, "building an airlock", matter_create_door, 5 SECONDS))
				var/interim = fetchAirlock()
				var/obj/machinery/door/airlock/T = new interim(A)
				log_construction(user, "builds an airlock ([T])")

				//if(map_setting == "COG2") T.dir = user.dir
				T.autoclose = 1


	construction
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
				boutput(user, "<span style=\"color:red\">Airlock build cancelled - you moved.</span>")
				return

			if (do_thing(user, A, "building an airlock", matter_create_door, 5 SECONDS))
				var/obj/machinery/door/airlock/T = new door_type(A)
				log_construction(user, null, "builds an airlock ([T], name: [door_name], access: [door_access], type: [door_type])")
				T.dir = door_dir
				T.autoclose = 1
				T.name = door_name
				if (door_access)
					T.req_access = list(door_access)
					T.req_access_txt = "[door_access]"
				else
					T.req_access = null
					T.req_access_txt = null


/obj/item/rcd/construction/afterattack(atom/A, mob/user as mob)
	..()
	if (mode == RCD_MODE_DECONSTRUCT)
		if (istype(A, /obj/machinery/door/poddoor/blast) && ammo_check(user, matter_remove_door, 500))
			var /obj/machinery/door/poddoor/blast/B = A
			if (findtext(B.id, "rcd_built") != 0)
				boutput(user, "Deconstructing \the [B] ([matter_remove_door])...")
				playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 50))
					if (ammo_check(user, matter_remove_door))
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						ammo_consume(user, matter_remove_door)
						logTheThing("station", user, null, "removes a pod door ([B]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
						qdel(A)
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			else
				boutput(user, "<span style=\"color:red\">You cannot deconstruct that!</span>")
				return
		else if (istype(A, /obj/machinery/r_door_control) && ammo_check(user, matter_remove_door, 500))
			var/obj/machinery/r_door_control/R = A
			if (findtext(R.id, "rcd_built") != 0)
				boutput(user, "Deconstructing \the [R] ([matter_remove_door])...")
				playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
				if(do_after(user, 50))
					if (ammo_check(user, matter_remove_door))
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
						src.shitSparks()
						ammo_consume(user, matter_remove_door)
						logTheThing("station", user, null, "removes a Door Control ([A]) using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")
						qdel(A)
						playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			else
				boutput(user, "<span style=\"color:red\">You cannot deconstruct that!</span>")
				return
	else if (mode == RCD_MODE_PODDOORCONTROL)
		if (istype(A, /obj/machinery/r_door_control))
			var/obj/machinery/r_door_control/R = A
			if (findtext(R.id, "rcd_built") != 0)
				boutput(user, "<span style=\"color:blue\">Selected.</span>")
				hangar_id = R.id
				mode = RCD_MODE_PODDOOR
			else
				boutput(user, "<span style=\"color:red\">You cannot modify that!</span>")
		else if (istype(A, /turf/simulated/wall) && ammo_check(user, matter_create_door, 500))
			boutput(user, "Creating Door Control ([matter_create_door])")
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (ammo_check(user, matter_create_door))
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
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
			playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 50))
				if (ammo_check(user, matter_create_door))
					playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
					src.shitSparks()
					var/stepdir = get_dir(src, A)
					var/poddir = turn(stepdir, 90)
					var/obj/machinery/door/poddoor/blast/B = new /obj/machinery/door/poddoor/blast(A)
					B.id = "[hangar_id]"
					B.dir = poddir
					B.autoclose = 1
					ammo_consume(user, matter_create_door)
					logTheThing("station", user, null, "creates Blast Door [hangar_id] using \the [src] in [user.loc.loc] ([showCoords(user.x, user.y, user.z)])")








/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for a rapid construction device."
	icon = 'icons/obj/ammo.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "rcd"
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
			W.attackby(src, user, params)
			return
		. = ..()

	medium
		name = "medium compressed matter cartridge"
		matter = 50

	big
		name = "large compressed matter cartridge"
		matter = 100



/*
// holy jesus christ
/obj/item/rcd/attack(mob/M as mob, mob/user as mob, def_zone)
	if (ishuman(M) && matter >= 3)
		var/mob/living/carbon/human/H = M
		if(!isdead(H) && H.health > 0)
			boutput(user, "<span style=\"color:red\">You poke [H] with \the [src].</span>")
			boutput(H, "<span style=\"color:red\">[user] pokes you with \the [src].</span>")
			return
		boutput(user, "<span style=\"color:red\"><B>You shove \the [src] down [H]'s mouth and pull the trigger!</B></span>")
		H.show_message("<span style=\"color:red\"><B>[user] is shoving an RCD down your throat!</B></span>", 1)
		for(var/mob/N in viewers(user, 3))
			if(N.client && N != user && N != H)
				N.show_message(text("<span style=\"color:red\"><B>[] shoves \the [src] down []'s throat!</B></span>", user, H), 1)
		playsound(get_turf(src), "sound/machines/click.ogg", 50, 1)
		if(do_after(user, 20))
			spark_system.set_up(5, 0, src)
			src.spark_system.start()
			var/mob/living/carbon/wall/W = new(H.loc)
			W.real_name = H.real_name
			playsound(get_turf(src), "sound/items/Deconstruct.ogg", 50, 1)
			playsound(get_turf(src), "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			if(H.mind)
				H.mind.transfer_to(W)
			H.gib()
			matter -= 3
			boutput(user, "\the [src] now holds [matter]/30 matter-units.")
			desc = "A RCD. It currently holds [matter]/30 matter-units."
		return
	else
		return ..(M, user, def_zone)
*/



// is this even used anywhere???
/obj/item/rcd_fake
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
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
	w_class = 3.0

//Broken RCDs.  Attempting to use them is...ill advised.
/obj/item/broken_rcd
	name = "prototype rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items.dmi'
	icon_state = "bad_rcd0"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "rcd"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 50000
	var/mode = 1
	var/broken = 0 //Fully broken, that is.
	var/datum/effects/system/spark_spread/spark_system

	New()
		..()
		src.icon_state = "bad_rcd[rand(0,2)]"
		src.spark_system = unpool(/datum/effects/system/spark_spread)
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/rcd_ammo))
			boutput(user, "\the [src] slot is not compatible with this cartridge.")
			return

	attack_self(mob/user as mob)
		if (src.broken)
			boutput(user, "<span style=\"color:red\">It's broken!</span>")
			return

		playsound(src.loc, "sound/effects/pop.ogg", 50, 0)
		if (mode)
			mode = 0
			boutput(user, "Changed mode to 'Deconstruct'")
			src.spark_system.start()
			return
		else
			mode = 1
			boutput(user, "Changed mode to 'Floor & Walls'")
			src.spark_system.start()
			return

	afterattack(atom/A, mob/user as mob)
		if (src.broken > 1)
			boutput(user, "<span style=\"color:red\">It's broken!</span>")
			return

		if (!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return
		if ((istype(A, /turf/space) || istype(A, /turf/simulated/floor)) && mode)
			if (src.broken)
				boutput(user, "<span style=\"color:red\">Insufficient charge.</span>")
				return

			boutput(user, "Building [istype(A, /turf/space) ? "Floor (1)" : "Wall (3)"]...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user, 20))
				if (src.broken)
					return

				src.broken++
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				playsound(src.loc, "sound/items/Deconstruct.ogg", 50, 1)

				for (var/turf/T in orange(1,user))
					T.ReplaceWithWall()


				boutput(user, "<span style=\"color:red\">\the [src] shorts out!</span>")
				return

		else if (!mode)
			boutput(user, "Deconstructing ??? ([rand(1,8)])...")

			playsound(src.loc, "sound/machines/click.ogg", 50, 1)
			if(do_after(user,50))
				if (src.broken)
					return

				src.broken++
				spark_system.set_up(5,0,src)
				src.spark_system.start()
				playsound(src.loc, "sound/items/Deconstruct.ogg", 100, 1)

				boutput(user, "<span class='combat'>\the [src] shorts out!</span>")

				logTheThing("combat", user, null, "manages to vaporize \[[showCoords(A.x, A.y, A.z)]] with a halloween RCD.")

				new /obj/effects/void_break(A)
				if (user)
					user.gib()

/obj/effects/void_break
	invisibility = 101
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
				shake_camera(A, 8, 3)
				A.ex_act( get_dist(src, A) > 1 ? 3 : 1 )

			else if (istype(A, /obj) && (A != src))

				if ((get_dist(src, A) <= 2) || prob(10))
					A.ex_act(1)
				else if (prob(5))
					A.ex_act(3)

				continue

		var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
		s.set_up(3, 1, src)
		s.start()

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
