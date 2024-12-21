///

TYPEINFO(/obj/item/rcd)
	mats = list("metal_superdense" = 20,
				"crystal_dense" = 10,
				"conductive_high" = 10,
				"energy_high" = 10)
/// Base RCD this is the variant actually used in most scenarios
/obj/item/rcd
	name = "rapid construction device"
	desc = "Also known as an RCD, this is capable of rapidly constructing walls, flooring, windows, and doors."
	icon = 'icons/obj/items/rcd.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "base"
	item_state = "rcd" //oops
	opacity = 0
	density = 0
	anchored = UNANCHORED
	var/matter = 0
	var/max_matter = 50
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	health = 7
	w_class = W_CLASS_NORMAL
	m_amt = 50000

	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 5
	inventory_counter_enabled = 1
	contextLayout = new /datum/contextLayout/experimentalcircle

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

	var/matter_remove_limb = 6
	var/time_remove_limb = 3 SECONDS

	/// If true will spark after completing an action
	var/unsafe = TRUE

	/// Material the RCD will build structures out of
	var/material_name = "steel"

	/// Whether deconstructing a wall will make the material
	/// of the floor be different than the material of the wall
	/// used to prevent venting with a material RCD by building a wall, deconstructing it, and then deconstructing the floor.
	var/safe_deconstruct = FALSE

	/// List of materials that the RCD can deconstruct, if empty no restriction.
	var/list/restricted_materials

	// List of what this RCD is working on.
	// If you try to do something when something is in this the RCD ignores you.
	// No more easily flooding airlocks, jerks. Do it one at a time. >8)
	var/tmp/list/working_on = list()

	/// The modes that this RCD has available to it
	var/list/modes = list(RCD_MODE_FLOORSWALLS, RCD_MODE_AIRLOCK, RCD_MODE_DECONSTRUCT, RCD_MODE_WINDOWS, RCD_MODE_LIGHTBULBS, RCD_MODE_LIGHTTUBES)
	/// The selected mode
	var/mode = RCD_MODE_FLOORSWALLS

	/// do we really actually for real want this to work in adventure zones?? just do this with varedit dont make children with this on
	var/really_actually_bypass_z_restriction = FALSE

	/// Custom contextActions list so we can handle opening them ourselves
	var/list/datum/contextAction/contexts = list()

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
		src.AddComponent(/datum/component/log_item_pickup, first_time_only=FALSE, authorized_job="Chief Engineer", message_admins_too=FALSE)

		// see context_actions.dm for those
		for(var/actionType in childrentypesof(/datum/contextAction/rcd))
			var/datum/contextAction/rcd/action = new actionType()
			if (action.mode in src.modes)
				src.contexts += action
		src.UpdateIcon()

		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(attackby_pre))

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE)
		..()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/rcd_ammo))
			var/obj/item/rcd_ammo/R = W
			if (!restricted_materials || (R?.material?.getID() in restricted_materials))
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
				src.UpdateIcon()
				playsound(src, 'sound/machines/click.ogg', 50, TRUE)
				boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter-units.")
				return
			else
				boutput(user, "This cartridge is not made of the proper material to be used in \The [src].")

	attack_self(mob/user as mob)
		user.showContextActions(src.contexts, src, src.contextLayout)

	proc/switch_mode(var/mode, var/mob/user)
		if (!(mode in src.modes))
			CRASH("RCD [src] tried to switch to a mode not in its modes.")

		playsound(src, 'sound/effects/pop.ogg', 50, FALSE)

		src.mode = mode

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
				boutput(user, SPAN_NOTICE("Place a door control on a wall, then place any amount of pod doors on floors."))
				boutput(user, SPAN_NOTICE("You can also select an existing door control by whacking it with \the [src]."))

			if (RCD_MODE_LIGHTBULBS)
				boutput(user, "Changed mode to 'Light Bulb Fixture'")

			if (RCD_MODE_LIGHTTUBES)
				boutput(user, "Changed mode to 'Light Tube Fixture'")

		src.UpdateIcon()

	proc/handle_build_floor(turf/A, mob/user)
		var/turf/simulated/floor/T = A.ReplaceWithFloor()
		T.inherit_area()
		T.setMaterial(getMaterial(material_name))
		T.default_material = getMaterial(material_name)
		return

	proc/handle_build_wall(turf/A, mob/user)
		var/turf/simulated/wall/T = A.ReplaceWithWall()
		T.inherit_area()
		T.setMaterial(getMaterial(material_name))
		T.girdermaterial = getMaterial(material_name)
		log_construction(user, "builds a wall ([T])")
		return

	proc/handle_reinforce_wall(turf/A, mob/user)
		var/turf/simulated/wall/T = A.ReplaceWithRWall()
		T.inherit_area()
		T.setMaterial(getMaterial(material_name))
		log_construction(user, "reinforces a wall ([T])")
		return

	proc/handle_convert_girder_to_wall(atom/A, mob/user)
		var/turf/wallTurf = get_turf(A)

		var/turf/simulated/wall/T
		if (istype(A, /obj/structure/girder/reinforced))
			T = wallTurf.ReplaceWithRWall()
		else
			T = wallTurf.ReplaceWithWall()

		T.setMaterial(getMaterial(material_name))

		log_construction(user, "builds a wall ([T]) on girder ([A])")
		qdel(A)

	proc/handle_floors_and_walls(atom/A, mob/user)
		if (istype(A, /turf/simulated/floor))
			src.do_rcd_action(user, A, "building a wall", matter_create_wall, time_create_wall, PROC_REF(handle_build_wall), src)
			return

		if (istype(A, /turf/simulated/wall))
			if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced) || istype(A, /turf/simulated/wall/auto/shuttle))
				// You can't reinforce walls that are already reinforced
				return

			src.do_rcd_action(user, A, "reinforcing the wall", matter_reinforce_wall, time_reinforce_wall, PROC_REF(handle_reinforce_wall), src)
			return

		if (istype(A, /obj/structure/girder) && !istype(A, /obj/structure/girder/displaced))
			src.do_rcd_action(user, A, "turning \the [A] into a wall", matter_create_wall_girder, time_create_wall_girder, PROC_REF(handle_convert_girder_to_wall), src)
			return

		if (istype(A, /obj/lattice) || istype(A, /turf))
			var/turf/T = A
			if (istype(A, /obj/lattice))
				var/turf/L = get_turf(A)
				A = L
				T = L
			if (T.can_build)
				src.do_rcd_action(user, A, "building a floor", matter_create_floor, time_create_floor, PROC_REF(handle_build_floor), src)
				return

	proc/do_unreinforce_wall(turf/target, mob/user)
		PROTECTED_PROC(TRUE)

		var/turf/simulated/wall/T = target.ReplaceWithWall()
		T.setMaterial(getMaterial(material_name))
		log_construction(user, "deconstructs a reinforced wall into a normal wall ([T])")


	proc/do_deconstruct_wall(turf/simulated/wall/target, mob/user)
		PROTECTED_PROC(TRUE)

		log_construction(user, "deconstructs a wall ([target])")
		var/turf/simulated/floor/T = target.ReplaceWithFloor()
		if (!restricted_materials || !safe_deconstruct)
			T.setMaterial(getMaterial(material_name))
		else if(!("steel" in restricted_materials))
			T.setMaterial(getMaterial("steel"))
		else
			T.setMaterial(getMaterial("negativematter"))
		return

	proc/do_deconstruction(atom/target, mob/user, thing)
		PROTECTED_PROC(TRUE)

		log_construction(user, "deconstructs \an [thing] ([target])")
		qdel(target)
		return

	proc/do_delete_floor(turf/A, mob/user)
		PROTECTED_PROC(TRUE)

		log_construction(user, "removes flooring ([A])")
		A.ReplaceWithSpace()

	proc/handle_deconstruct(atom/A, mob/user)
		PRIVATE_PROC(TRUE)

		if (istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced))
			src.do_rcd_action(user, A, "removing the reinforcement from \the [A]", matter_unreinforce_wall, time_unreinforce_wall, PROC_REF(do_unreinforce_wall), src)
			return

		if (istype(A, /turf/simulated/wall))
			if (istype(A, /turf/simulated/wall/auto/shuttle))
				return

			src.do_rcd_action(user, A, "deconstructing \the [A]", matter_remove_wall, time_remove_wall, PROC_REF(do_deconstruct_wall), src)
			return

		if (istype(A, /turf/simulated/floor))
			var/turf/simulated/floor/T = A
			if(T.intact)
				var/datum/material/mat = istext(T.default_material) ? getMaterial(T.default_material) : T.default_material
				if(!(mat?.getID() in restricted_materials))
					boutput(user, "Target object is not made of a material this RCD can deconstruct.")
					return
			src.do_rcd_action(user, A, "removing \the [A]", matter_remove_floor, time_remove_floor, PROC_REF(do_delete_floor), src)
			return

		if (istype(A, /obj/machinery/door/airlock)||istype(A, /obj/machinery/door/unpowered/wood))
			var/obj/machinery/door/airlock/AL = A
			if (AL.hardened == 1)
				boutput(user, SPAN_ALERT("\The [AL] is reinforced against rapid deconstruction!"))
				return

			src.do_rcd_action(user, AL, "deconstructing \the [AL]", matter_remove_door, time_remove_door, PROC_REF(do_deconstruction), src, "airlock")
			return

		if (istype(A, /obj/structure/girder))
			src.do_rcd_action(user, A, "deconstructing \the [A]", matter_remove_girder, time_remove_girder, PROC_REF(do_deconstruction), src, "girder")
			return

		if (istype(A, /obj/window))
			src.do_rcd_action(user, A, "deconstructing \the [A]", matter_remove_window, time_remove_window, PROC_REF(do_deconstruction), src, "window")
			return

		if (istype(A, /obj/lattice))
			// really? why in the world are lattices so damn expensive. honk
			src.do_rcd_action(user, A, "deconstructing \the [A]", matter_remove_lattice, time_remove_lattice, PROC_REF(do_deconstruction), src, "lattice")
			return

		if (istype(A, /obj/machinery/light))
			src.do_rcd_action(user, A, "deconstructing \the [A]", matter_remove_light_fixture, time_remove_light_fixture, PROC_REF(do_deconstruction), src, "light fixture")
			return

	proc/do_build_wall_light(atom/A, mob/user, obj/item/light_parts/LP)
		PROTECTED_PROC(TRUE)

		LP.setMaterial(getMaterial(material_name))
		LP.attach_fixture(LP, A, user, TRUE)
		log_construction(user, "built a light fixture to a wall ([A])")

	proc/do_build_floor_light(atom/A, mob/user, obj/item/light_parts/LF)
		PROTECTED_PROC(TRUE)
		LF.setMaterial(getMaterial(material_name))
		LF.attach_fixture(LF, A, user, TRUE)
		log_construction(user, "built a floor lamp on a floor ([A])")

	proc/handle_light_bulbs(atom/A, mob/user)
		PRIVATE_PROC(TRUE)

		if (istype(A, /turf/simulated/wall) || istype(A, /obj/window))
			var/obj/item/light_parts/bulb/LB = new /obj/item/light_parts/bulb(src)
			if (LB.can_attach(A, user))
				src.do_rcd_action(user, A, "attaching a light bulb fixture to \the [A]", matter_create_light_fixture, time_create_light_fixture, PROC_REF(do_build_wall_light), src, LB)
			else
				qdel(LB)
		if (istype(A, /turf/simulated/floor))
			var/obj/item/light_parts/floor/LF = new /obj/item/light_parts/floor(src)
			if (LF.can_attach(A, user))
				src.do_rcd_action(user, A, "building a floor lamp on \the [A]", matter_create_light_fixture, time_create_light_fixture, PROC_REF(do_build_floor_light), src, LF)
			else
				qdel(LF)

	proc/handle_light_tubes(atom/A, mob/user)
		PRIVATE_PROC(TRUE)

		if (istype(A, /turf/simulated/wall) || istype(A, /obj/window))
			var/obj/item/light_parts/LP = new /obj/item/light_parts(src)
			if (LP.can_attach(A, user))
				src.do_rcd_action(user, A, "attaching a light bulb fixture to \the [A]", matter_create_light_fixture, time_create_light_fixture, PROC_REF(do_build_wall_light), src, LP)
			else
				qdel(LP)

	proc/do_build_window(atom/A, mob/user)
		PROTECTED_PROC(TRUE)

		// Is /auto always the one to use here? hm.
		new map_settings.windows(get_turf(A))
		log_construction(user, "builds a window")

	proc/handle_windows(atom/A, mob/user)
		PRIVATE_PROC(TRUE)

		if (istype(A, /turf/simulated/floor) || istype(A, /obj/mesh/grille/))
			if (istype(A, /obj/mesh/grille/))
				// You can do this with normal windows. So now you can do it with RCD windows. Honke.
				A = get_turf(A)
				if (!istype(A, /turf/simulated/floor))
					return

			src.do_rcd_action(user, A, "building a window", matter_create_window, time_create_window, PROC_REF(do_build_window), src)
			return

	// Pre attack filter to stop the RCD smashing lights while trying to remove them
	proc/attackby_pre(source, atom/target, mob/user)
		PROTECTED_PROC(TRUE)
		if (istype(target, /obj/machinery/light))
			return TRUE
		else
			return FALSE

	afterattack(atom/A, mob/user as mob)
		if ((isrestrictedz(user.z) || isrestrictedz(A.z)) && !src.really_actually_bypass_z_restriction)
			if(!(isgenplanet(user) && isgenplanet(A)))
				boutput(user, "\The [src] won't work here for some reason. Oh well!")
				return

		if (!can_reach(user, A))
			return

		switch(src.mode)
			if (RCD_MODE_FLOORSWALLS)
				handle_floors_and_walls(A, user)

			if (RCD_MODE_AIRLOCK)
				// create_door handles all the other stuff.
				SPAWN(0) //let's not lock the entire attack call and let people attack with zero delay
					create_door(A, user)

				return

			if (RCD_MODE_DECONSTRUCT)
				if (restricted_materials && !(A.material?.getID() in restricted_materials))
					boutput(user, "Target object is not made of a material this RCD can deconstruct.")
					return

				handle_deconstruct(A, user)
				return

			if (RCD_MODE_WINDOWS)
				handle_windows(A, user)
				return

			if (RCD_MODE_LIGHTBULBS)
				handle_light_bulbs(A, user)
				return

			if (RCD_MODE_LIGHTTUBES)
				handle_light_tubes(A, user)
				return

	proc/handle_surgery(obj/item/parts/surgery_target, mob/user, var/mob/living/carbon/human/target)
		PRIVATE_PROC(TRUE)

		var/user_limb_is_missing = FALSE
		if (ishuman(user) && user.bioHolder.HasEffect("clumsy") && prob(40)) //Clowns get a chance to tear off their own limb
			var/mob/living/carbon/human/Huser = user
			if (Huser.zone_sel.selecting == "chest")
				if (Huser.organHolder.butt == null)
					user_limb_is_missing = TRUE
			else
				if (Huser.limbs.vars[user.zone_sel.selecting] == null) //Cant remove a limb that isnt there
					user_limb_is_missing = TRUE

			if(user_limb_is_missing == TRUE) //The limb/ass is already missing, maim yourself instead
				user.visible_message(SPAN_ALERT("<b>[user] messes up really badly with [src] and maims [himself_or_herself(user)]! </b> "))
				random_brute_damage(user, 35)
				Huser.changeStatus("knockdown", 3 SECONDS)
				take_bleeding_damage(user, null, 25, DAMAGE_CUT, 1)
			else	//Limb's here? We lose it
				if (user.zone_sel.selecting == "chest")
					var/B = Huser.organHolder.drop_organ("butt")
					qdel(B)
				else
					surgery_target = Huser.limbs.vars[user.zone_sel.selecting]
					surgery_target.remove()
					qdel(surgery_target)
				user.visible_message(SPAN_ALERT("<b>[user] holds the [src] by the wrong end and removes [his_or_her(user)] own [surgery_target]! </b> "))
				random_brute_damage(user, 25)
				take_bleeding_damage(user, null, 20, DAMAGE_CUT, 1)
			playsound(user.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
			user.emote("scream")
			JOB_XP(user, "Clown", 3)
		else
			if (user.zone_sel.selecting == "chest")
				var/B = target.organHolder.drop_organ("butt")
				qdel(B)
			else
				surgery_target.remove()
				qdel(surgery_target)
			random_brute_damage(target, 25)
			take_bleeding_damage(target, null, 20)
			playsound(target.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
			user.visible_message(SPAN_ALERT("Deconstructs [target]'s [surgery_target] with the RCD."))

 	// Express limb surgery with an RCD
	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (issilicon(user))
			return ..()
		else if (length(working_on) > 0) //Lets not get too crazy
			boutput(user, SPAN_NOTICE("[src] is already working on something else."))
		else if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/obj/item/parts/surgery_target = null
			if (surgeryCheck(H, user) && (user.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg", "chest")) && (src.mode == RCD_MODE_DECONSTRUCT)) //In surgery conditions and aiming for a limb or an ass in deconstruction mode? Time for ghetto surgery
				if (user.zone_sel.selecting == "chest") //Ass begone
					if (H.organHolder.butt == null)
						user.visible_message(SPAN_ALERT("<b>Tries to remove [target]'s butt, but it's already gone!</b> "))
						return
					else
						surgery_target = H.organHolder.get_organ("butt")
				else if (user.zone_sel.selecting in list("l_arm","r_arm","l_leg","r_leg")) // Is the limb we are aiming for missing?
					if (H.limbs.vars[user.zone_sel.selecting] == null)
						user.visible_message(SPAN_ALERT("<b>Tries to remove one of [target]'s limbs, but it's already gone!</b> "))
						return
					else
						surgery_target = H.limbs.vars[user.zone_sel.selecting]

				if (surgery_target == null)
					return

				src.do_rcd_action(user, surgery_target, "removing [H]'s [surgery_target]", matter_remove_limb, time_remove_limb, PROC_REF(handle_surgery), src, H)

			else //Not in surgery conditions or aiming for a limb? Do a normal hit
				return ..()

	proc/sparkIfUnsafe()
		if (!src.unsafe)
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
				S.cell.use(checkamt * silicon_cost_multiplier)
		else
			src.matter -= checkamt
			boutput(user, "\The [src] now holds [src.matter]/[src.max_matter] matter units.")
			src.UpdateIcon()

	proc/do_build_airlock(var/turf/A, mob/user)
		PROTECTED_PROC(TRUE)
		var/interim = fetchAirlock()
		var/obj/machinery/door/airlock/T = new interim(A)
		log_construction(user, "builds an airlock ([T])")

		// makes everything around it look nice
		T.set_dir(user.dir)
		for (var/obj/window/auto/O in orange(1,T))
			O.UpdateIcon()
		for (var/obj/mesh/M in orange(1,T))
			M.UpdateIcon()
		for (var/turf/simulated/wall/auto/W in orange(1,T))
			W.UpdateIcon()
		for (var/turf/simulated/wall/false_wall/F in orange(1,T))
			F.UpdateIcon()

		T.autoclose = TRUE

	proc/create_door(var/turf/A, mob/user as mob)
		PROTECTED_PROC(TRUE)
		src.do_rcd_action(user, A, "building an airlock", matter_create_door, time_create_door, PROC_REF(do_build_airlock), src)

	/// Do an action with the RCD
	/// user - who is doing it
	/// target - to what
	/// what - a string describing the action
	/// delay - time it takes to do
	/// callback - proc reference to action code, needs to be of signature proc/my_proc(atom/A, mob/user, other/args)
	/// callback_owner - what the callback proc needs to be called on
	/// ... - remaining arguments will be passed to callback
	proc/do_rcd_action(mob/user as mob, atom/target, what, ammo_cost, delay, callback_path, callback_owner, ...)
		if (!ammo_check(user, ammo_cost))
			boutput(user, "Unable to start [what] &mdash; you need at least [issilicon(user) ? "[ammo_cost * src.silicon_cost_multiplier] charge" : "[ammo_cost] matter units"].")
			return FALSE

		var/doing_surgery = FALSE

		if (istype(target, /obj/item/parts))
			doing_surgery = TRUE

		if (target in src.working_on)
			// Make sure someone can't just spam the same command on the same item.
			// Building multiple things on the same turf? Nyet!
			boutput(user, "\The [src] is already operating on that!")
			return FALSE

		src.working_on += target

		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		boutput(user, "You start [what]... ([issilicon(user) ? "[ammo_cost * src.silicon_cost_multiplier] charge" : "[ammo_cost] matter units"][delay ? ", [delay / 10] seconds" : ""])")

		if (!ammo_check(user, ammo_cost))
			src.working_on -= target
			return FALSE

		var/list/arguments = args.Copy(8)

		var/datum/action/bar/icon/rcd_action/action = new(
			target,
			user,
			delay,
			src,
			callback_path,
			callback_owner,
			ammo_cost,
			doing_surgery,
			arguments)

		actions.start(action, user)
		return TRUE

	proc/log_construction(mob/user as mob, var/what)
		PROTECTED_PROC(TRUE)
		logTheThing(LOG_STATION, user, "[what] using \the [src] at [user.loc.loc] ([log_loc(user)])")

	update_icon() //we got fancy rcds now
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


/// Only for testing
/obj/item/rcd/testing
	matter = 1000
	max_matter = 1000


/// Unused except for in the research module
/obj/item/rcd/cyborg
	material_name = "electrum"

/obj/item/rcd/safe
	unsafe = FALSE
