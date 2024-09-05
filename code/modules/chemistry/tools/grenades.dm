
/* ================================================== */
/* -------------------- Grenades -------------------- */
/* ================================================== */

ADMIN_INTERACT_PROCS(/obj/item/chem_grenade, proc/arm, proc/explode)

/obj/item/chem_grenade
	name = "imcoder chemical grenade"
	icon_state = "grenade-chem1"
	desc = "Uh, you should not see this. look away and bug report this."
	icon = 'icons/obj/items/grenade.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "flashbang"
	w_class = W_CLASS_SMALL
	force = 2
	var/armed = 0
	var/icon_state_armed = "grenade-chem-armed"
	var/list/obj/beakers = new/list()
	throw_speed = 4
	throw_range = 20
	flags = TABLEPASS | CONDUCT | EXTRADELAY | NOSPLASH
	c_flags = ONBELT
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 0
	move_triggered = 1
	duration_put = 0.25 SECONDS //crime
	var/is_dangerous = TRUE
	var/detonating = 0
	/// damage when loaded into a 40mm convesion chamber
	var/launcher_damage = 25
	/// time until the grenade explodes when triggered
	var/grenade_time = 3 SECONDS
	/// standard time until the grenade explodes when triggered
	var/grenade_time_standard = 3 SECONDS
	/// maximum time be able to be set in seconds
	var/maximum_grenade_time = 15 SECONDS
	/// time intervals you are able to set the grenade to
	var/interval_grenade_time = 3 SECONDS
	HELP_MESSAGE_OVERRIDE("Use in your active hand (by clicking on pressing C) to activate, then throw (hold space and click on a tile).")

/obj/item/chem_grenade/New()
	..()
	src.create_reagents(150000)
	src.initialize_assemby()

///clone for grenade launcher purposes only. Not a real deep copy, just barely good enough to work for something that's going to be instantly detonated. Mostly for like, custom grenades or whatever
/obj/item/chem_grenade/proc/launcher_clone()
	return new src.type

/obj/item/chem_grenade/proc/initialize_assemby()
	// completed grenade + assemblies -> chemical grenade assembly
	src.AddComponent(/datum/component/assembly, list(/obj/item/assembly/time_ignite, /obj/item/assembly/prox_ignite, /obj/item/assembly/rad_ignite), PROC_REF(chem_grenade_assemblies), TRUE)
	// completed grenade + screwdriver -> adjusting of the arming time
	src.AddComponent(/datum/component/assembly, TOOL_SCREWING, PROC_REF(adjust_time), FALSE)

/obj/item/chem_grenade/is_open_container()
	return src.detonating

// warcrimes: Why the fuck is autothrow a feature why would this ever be a feature WHY. Now it wont do it unless it's primed i think.
/obj/item/chem_grenade/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (BOUNDS_DIST(user, target) == 0 || (!isturf(target) && !isturf(target.loc)) || !isturf(user.loc) || !src.armed)
		return
	var/area/a = get_area(target)
	if(a.sanctuary) return
	if (user.equipped() == src)
		if (src.arm(user))
			return ..()
		user.drop_item()
		src.throw_at(get_turf(target), 10, 3)
		return
	else if (isghostdrone(user))
		var/mob/living/silicon/ghostdrone/G = user
		if (istype(G.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/mag = G.active_tool
			if (mag.holding == src)
				if (src.arm(user))
					return ..()
				mag.dropItem()
				src.throw_at(get_turf(target), 10, 3)
				return

/obj/item/chem_grenade/attack_self(mob/user as mob)
	. = ..()
	src.arm(user)

/obj/item/chem_grenade/ex_act(severity)
	if(!src.detonating)
		src.explode()
	. = ..()

/obj/item/chem_grenade/get_desc()
	. = ..()
	. += " It is set to detonate in [src.grenade_time / (1 SECOND)] seconds."

/obj/item/chem_grenade/attack_hand()
	walk(src,0)
	return ..()

/obj/item/chem_grenade/proc/arm(mob/user as mob)
	if (src.armed)
		return 1
	var/area/A = get_area(src)
	if(A.sanctuary)
		return
	// Custom grenades only. Metal foam etc grenades cannot be modified (Convair880).
	var/log_reagents = null
	if (src.name == "grenade")
		for (var/obj/item/reagent_containers/glass/G in src.beakers)
			if (G.reagents.total_volume) log_reagents += "[log_reagents(G)] "

	if(!A.dont_log_combat)
		if(is_dangerous && user)
			message_admins("[log_reagents ? "Custom grenade" : "Grenade ([src])"] primed at [log_loc(src)] by [key_name(user)].")
		logTheThing(LOG_COMBAT, user, "primes a [log_reagents ? "custom grenade" : "grenade ([src.type])"] at [log_loc(user)].[log_reagents ? " [log_reagents]" : ""]")

	boutput(user, SPAN_ALERT("You prime the grenade! [src.grenade_time / (1 SECOND)] seconds!"))
	src.armed = TRUE
	src.icon_state = icon_state_armed
	playsound(src, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)
	// When the grenade is armed, we don't want it to be able to be disassembled or turned in assemblies
	src.RemoveComponentsOfType(/datum/component/assembly)
	SPAWN(src.grenade_time)
		if (src && !src.disposed)
			if(user?.equipped() == src)
				user.u_equip(src)
			explode()

/obj/item/chem_grenade/proc/explode()
	src.reagents.my_atom = src //hax
	var/has_reagents = 0
	src.detonating = 1
	for (var/obj/item/reagent_containers/glass/G in beakers)
		if (G.reagents.total_volume) has_reagents = 1

	if (!has_reagents)
		playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		src.armed = FALSE
		return

	playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

	for (var/obj/item/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)

	if (src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()
		var/min_dispersal = src.reagents.get_dispersal()
		for (var/atom/A in range(min_dispersal, get_turf(src.loc)))
			if ( A == src ) continue
			if (src?.reagents) // Erik: fix for cannot execute null.grenade effects()
				src.reagents.grenade_effects(src, A)
				src.reagents.reaction(A, 1, 10, 0)

	invisibility = INVIS_ALWAYS_ISH //Why am i doing this?
	if (src.master) src.master.invisibility = INVIS_ALWAYS_ISH
	SPAWN(5 SECONDS)		   //To make sure all reagents can work
		if (src.master) qdel(src.master)
		if (src) qdel(src)	   //correctly before deleting the grenade.

/obj/item/chem_grenade/move_trigger(var/mob/M, kindof)
	if (..())
		for (var/obj/O in contents)
			if (O.move_triggered)
				O.move_trigger(M, kindof)

//chem grenade-assemblies code

/// chem grenade assembly creation
/obj/item/chem_grenade/proc/chem_grenade_assemblies(var/atom/to_combine_atom, var/mob/user)
	var/obj/item/assembly/manipulated_assembly = to_combine_atom
	if (!manipulated_assembly || !manipulated_assembly:status)
		return
	boutput(user, SPAN_NOTICE("You attach the [src.name] to the [manipulated_assembly.name]!"))
	logTheThing(LOG_BOMBING, user, "made a chemical bomb with a [manipulated_assembly.name].")
	message_admins("[key_name(user)] made a chemical bomb with a [manipulated_assembly.name].")

	var/obj/item/assembly/chem_bomb/created_bomb = new /obj/item/assembly/chem_bomb(user)
	created_bomb.attacher = key_name(user)

	//i'm sinning here, but it's still better than UNLINT(manipulated_assembly:part1)
	var/obj/item/assembly_part1
	var/obj/item/device/igniter/assembly_part2
	switch(manipulated_assembly.type)
		if(/obj/item/assembly/time_ignite)
			var/obj/item/assembly/time_ignite/time_assembly = manipulated_assembly
			assembly_part1 = time_assembly.part1
			assembly_part2 = time_assembly.part2
			time_assembly.part1 = null
			time_assembly.part2 = null
			created_bomb.desc = "A very intricate igniter and timer assembly mounted to a chem grenade."
			created_bomb.name = "Timer/Igniter/Chem Grenade Assembly"
		if(/obj/item/assembly/prox_ignite)
			var/obj/item/assembly/prox_ignite/prox_assembly = manipulated_assembly
			assembly_part1 = prox_assembly.part1
			assembly_part2 = prox_assembly.part2
			prox_assembly.part1 = null
			prox_assembly.part2 = null
			created_bomb.desc = "A very intricate igniter and proximity sensor electrical assembly mounted to a chem grenade."
			created_bomb.name = "Proximity/Igniter/Chem Grenade Assembly"
		if(/obj/item/assembly/rad_ignite)
			var/obj/item/assembly/rad_ignite/rad_assembly = manipulated_assembly
			assembly_part1 = rad_assembly.part1
			assembly_part2 = rad_assembly.part2
			rad_assembly.part1 = null
			rad_assembly.part2 = null
			created_bomb.desc = "A very intricate igniter and signaller electrical assembly mounted to a chem grenade."
			created_bomb.name = "Radio/Igniter/Chem Grenade Assembly"

	// now we setting up the parts of the assembly at their fitting places
	created_bomb.triggering_device = assembly_part1
	created_bomb.c_state(0)
	assembly_part1.set_loc(created_bomb)
	assembly_part1.master = created_bomb //well, for stuff like this var/master is on item, i guess *shrug
	created_bomb.igniter = assembly_part2
	created_bomb.igniter.status = 1
	assembly_part2.set_loc(created_bomb)
	assembly_part2.master = created_bomb
	manipulated_assembly.layer = initial(manipulated_assembly.layer)
	user.u_equip(manipulated_assembly)
	user.put_in_hand_or_drop(created_bomb)
	src.master = created_bomb
	src.layer = initial(src.layer)
	user.u_equip(src)
	src.set_loc(created_bomb)
	created_bomb.payload = src
	qdel(manipulated_assembly)
	//We don't remove the assembly procs here since the bomb can be disassembled and we could manipulate it again.
	return TRUE

/// chem grenade time adjustment
/obj/item/chem_grenade/proc/adjust_time(var/atom/to_combine_atom, var/mob/user)
	if(src.grenade_time >= src.maximum_grenade_time)
		src.grenade_time = src.grenade_time_standard
	else
		src.grenade_time += src.interval_grenade_time
	boutput(user, SPAN_NOTICE("You set [src] to detonate in [src.grenade_time / (1 SECOND)] seconds."))
	src.tooltip_rebuild = 1
	return TRUE


/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

// Order matters. Water resp. the final smoke ingredient should always be the last reagent added to the beaker.
// If it's not, the foam resp. smoke reaction occurs prematurely without carrying the target reagents with them.

TYPEINFO(/obj/item/chem_grenade/custom)
	mats = list("metal_dense" = 4,
				"energy" = 2)
/obj/item/chem_grenade/custom
	name = "disassembled chemical grenade"
	icon_state = "grenade-chem1"
	desc = "A kit for the construction of a chemical grenade. Use it in hand to begin assembling it."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state_armed = "grenade-chem-armed"
	is_syndicate = 1
	/// maximum beaker size when assemblying beaker into custom grenades
	var/custom_grenade_max_beaker_volume = 50
	/// the stage of the current assembly
	var/stage = 0
	var/image/fluid_image1 //! The fluid image of the first beaker inserted into the custom grenade
	var/image/fluid_image2 //! The fluid image of the second beaker inserted into the custom grenade

/obj/item/chem_grenade/custom/New()
	..()
	src.fluid_image1 = image('icons/obj/items/grenade.dmi', "grenade-chem-fluid1", -1)
	src.fluid_image2 = image('icons/obj/items/grenade.dmi', "grenade-chem-fluid2", -1)

/obj/item/chem_grenade/custom/launcher_clone()
	var/obj/item/chem_grenade/custom/out = ..()
	out.beakers += new/obj/item/reagent_containers/glass/beaker(out)
	out.beakers += new/obj/item/reagent_containers/glass/beaker(out)
	src.beakers[1]?.reagents?.copy_to(out.beakers[1].reagents, 1, TRUE, TRUE)
	src.beakers[2]?.reagents?.copy_to(out.beakers[2].reagents, 1, TRUE, TRUE)
	out.chem_grenade_completing()
	return out

/obj/item/chem_grenade/custom/initialize_assemby()
	if (src.stage == 2)
		..()


/obj/item/chem_grenade/custom/attack_self(mob/user as mob)
	if (src.stage == 0)
		src.assemble_fuse(user)
	else
		src.arm(user)

/obj/item/chem_grenade/custom/get_desc()
	. = ..()
	if(stage == 2)
		. += " It is set to detonate in [src.grenade_time / (1 SECOND)] seconds."

/obj/item/chem_grenade/custom/get_help_message(dist, mob/user)
	switch(stage)
		if(0)
			. += "Hit the grenade casing with a fuse to begin the assembly."
		if(1)
			if (length(beakers) < 2)
				. += "Hit the grenade casing with a small beaker to load it inside, up to two."
			if(length(.))
				. += "<br>"
			. += "Hit a loaded grenade casing with a <b>screwdriver</b> to finish it. Then use it in hand to begin the countdown."
		if(2)
			. = ..()

/obj/item/chem_grenade/custom/arm(mob/user as mob)
	if (src.stage != 2)
		return 1
	..()


// Custom chem grenades assembly code

///On stage 0, using the grenade in hand sets the fuse into the grenade
/obj/item/chem_grenade/custom/proc/assemble_fuse(var/mob/user)
	boutput(user, SPAN_NOTICE("You add the fuse to the metal casing."))
	playsound(src, 'sound/items/Screwdriver2.ogg', 25, -3)
	src.icon_state = "grenade-chem2"
	src.name = "unsecured grenade"
	src.desc = "An unsecured chemical grenade. It can be modified by adding small beakers into it and secured with a screwdriver."
	src.stage = 1
	// unsecured grenade + beaker  -> unsecured grenade with beaker
	src.AddComponent(/datum/component/assembly, list(/obj/item/reagent_containers/glass), PROC_REF(chem_grenade_filling), TRUE)
	// unsecured grenade + wrench -> disassembling of the grenade
	src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(disassembly_filled), FALSE)
	src.tooltip_rebuild = 1

/// chem grenade filling proc
/obj/item/chem_grenade/custom/proc/chem_grenade_filling(var/atom/to_combine_atom, var/mob/user)
	if (length(src.beakers) >= 2)
		boutput(user, SPAN_ALERT("The grenade can not hold more containers."))
		return TRUE
	var/obj/item/reagent_containers/glass/manipulated_beaker = to_combine_atom
	if (manipulated_beaker.initial_volume > src.custom_grenade_max_beaker_volume) // anything bigger than a regular beaker, but someone could varedit their reagent holder beyond this for admin nonsense
		boutput(user, SPAN_ALERT("This beaker is too large!"))
	else
		if (manipulated_beaker.reagents && manipulated_beaker.reagents.total_volume)
			boutput(user, SPAN_NOTICE("You add \the [manipulated_beaker] to the assembly."))
			user.u_equip(manipulated_beaker)
			manipulated_beaker.set_loc(src)
			src.beakers += manipulated_beaker
			switch (length(src.beakers))
				if (1)
					src.fluid_image1.color = manipulated_beaker.reagents.get_average_color().to_rgba()
					src.UpdateOverlays(src.fluid_image1, "fluid1")
					//now that we got at least one beaker, we can make the assembly able to be completed by screwing
					// unsecured grenade with beaker + screwdriver -> completed grenade
					src.AddComponent(/datum/component/assembly, TOOL_SCREWING, PROC_REF(chem_grenade_completing), FALSE)
				if (2)
					src.fluid_image2.color = manipulated_beaker.reagents.get_average_color().to_rgba()
					src.UpdateOverlays(src.fluid_image2, "fluid2")
		else
			boutput(user, SPAN_ALERT("\The [manipulated_beaker] is empty."))
	return TRUE

/// chem grenade completion proc
/obj/item/chem_grenade/custom/proc/chem_grenade_completing(var/atom/to_combine_atom, var/mob/user)
	boutput(user, SPAN_NOTICE("You lock the assembly."))
	playsound(src, 'sound/items/Screwdriver.ogg', 25, -3)
	src.name = "chemical grenade"
	src.icon_state = "grenade-chem3"
	src.desc = "A chemical grenade. Use it to unleash chemicals over whoever you see fit."
	src.stage = 2
	src.tooltip_rebuild = 1
	//Since we changed the state, remove all assembly components and add the next state ones
	src.RemoveComponentsOfType(/datum/component/assembly)
	// completed grenade + assemblies -> chemical grenade assembly
	src.AddComponent(/datum/component/assembly, list(/obj/item/assembly/time_ignite, /obj/item/assembly/prox_ignite, /obj/item/assembly/rad_ignite), PROC_REF(chem_grenade_assemblies), TRUE)
	// completed grenade + screwdriver -> adjusting of the arming time
	src.AddComponent(/datum/component/assembly, TOOL_SCREWING, PROC_REF(adjust_time), FALSE)
	// completed grenade + wrench -> disassembling of the grenade
	src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(disassembly_filled), FALSE)
	logTheThing(LOG_CHEMISTRY, user, "Assembles a custom chemical grenade (beaker 1: [beakers[1]]; beaker 2: [beakers[2]])")
	return TRUE

/// chem grenade disassembly
/obj/item/chem_grenade/custom/proc/disassembly_filled(var/atom/to_combine_atom, var/mob/user)
	for (var/obj/item/reagent_containers/glass/manipulated_beaker in src.beakers)
		src.beakers -= manipulated_beaker
		manipulated_beaker.set_loc(get_turf(src))
	src.fluid_image1.color = rgb(255,255,255,0)
	src.UpdateOverlays(src.fluid_image1, "fluid1")
	src.fluid_image2.color = rgb(255,255,255,0)
	src.UpdateOverlays(src.fluid_image2, "fluid2")
	src.stage = 0
	src.icon_state = "grenade-chem1"
	src.name = "disassembled chemical grenade"
	src.desc = "A kit for the construction of a chemical grenade. Use it in hand to begin assembling it."
	src.grenade_time = src.grenade_time_standard
	//Since we changed the state, remove all assembly components
	src.RemoveComponentsOfType(/datum/component/assembly)
	src.tooltip_rebuild = 1
	return TRUE


/obj/item/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "After activating, creates a mess of foamed metal. Useful for plugging the hull up."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "metalfoam"
	icon_state_armed = "metalfoam1"
	is_dangerous = FALSE
	launcher_damage = 10

/obj/item/chem_grenade/metalfoam/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("aluminium", 30)
	B2.reagents.add_reagent("fluorosurfactant", 10)
	B2.reagents.add_reagent("acid", 10)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/firefighting
	name = "fire fighting grenade"
	desc = "Propells firefighting foam in a wide area around it after activation, putting out fires."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "firefighting"
	icon_state_armed = "firefighting1"
	is_dangerous = FALSE
	launcher_damage = 10

/obj/item/chem_grenade/firefighting/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("ff-foam", 30)
	B2.reagents.add_reagent("ff-foam", 30)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cleaner"
	icon_state_armed = "cleaner1"
	is_dangerous = FALSE
	launcher_damage = 5

/obj/item/chem_grenade/cleaner/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 30)
	B2.reagents.add_reagent("cleaner", 20)
	B2.reagents.add_reagent("water", 30)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/fcleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cleaner"
	icon_state_armed = "cleaner1"

/obj/item/chem_grenade/fcleaner/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 10)
	B1.reagents.add_reagent("superlube", 10)

	B2.reagents.add_reagent("pacid", 10) //The syndicate are sending the strong stuff now -Spy
	B2.reagents.add_reagent("water", 10)

	src.beakers += B1
	src.beakers += B2

TYPEINFO(/obj/item/chem_grenade/flashbang)
	mats = 6

/obj/item/chem_grenade/flashbang
	name = "flashbang"
	desc = "A standard stun grenade."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "flashbang"
	icon_state_armed = "flashbang1"
	is_syndicate = 1
	is_dangerous = FALSE

/obj/item/chem_grenade/flashbang/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.maximum_volume = 100
	B1.reagents.add_reagent("aluminium", 25)
	B1.reagents.add_reagent("potassium", 25)
	B1.reagents.add_reagent("cola", 25)
	B1.reagents.add_reagent("chlorine", 25)

	B2.reagents.maximum_volume = 100
	B2.reagents.add_reagent("sulfur", 25)
	B2.reagents.add_reagent("oxygen", 25)
	B2.reagents.add_reagent("phosphorus", 25)

	src.beakers += B1
	src.beakers += B2


TYPEINFO(/obj/item/chem_grenade/flashbang/revolution)
	mats = null

/obj/item/chem_grenade/flashbang/revolution //convertssss

/obj/item/chem_grenade/flashbang/revolution/explode()
	var/min_dispersal = src.reagents.get_dispersal()
	for (var/mob/M in range(max(min_dispersal,6), get_turf(src.loc)))
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/safety = 0
			if (H.eyes_protected_from_light() && H.ears_protected_from_sound())
				safety = 1

			if (safety == 0)
				var/can_convert = 1
				if (!H.client || !H.mind)
					can_convert = 0
				else if (!H.can_be_converted_to_the_revolution())
					can_convert = 0
				else if (H.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
					can_convert = 0
				else
					can_convert = 1

				for (var/obj/item/implant/counterrev/found_imp in H.implant)
					found_imp.on_remove(H)
					H.implant.Remove(found_imp)
					qdel(found_imp)

					playsound(H.loc, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, 0.1, 0, 0.9)
					H.visible_message(SPAN_NOTICE("The counter-revolutionary implant inside [H] shatters into one million pieces!"))

				if (can_convert && !(H.mind?.get_antagonist(ROLE_REVOLUTIONARY)))
					H.mind?.add_antagonist(ROLE_REVOLUTIONARY, source = ANTAGONIST_SOURCE_CONVERTED)

	..()


/obj/item/chem_grenade/cryo
	name = "cryo grenade"
	desc = "An experimental non-lethal grenade using cryogenic technologies."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "cryo"
	icon_state_armed = "cryo1"

/obj/item/chem_grenade/cryo/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)

	B1.reagents.add_reagent("cryostylane", 35)

	src.beakers += B1

/obj/item/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "A rather volatile grenade that creates a small fire."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary"
	icon_state_armed = "incendiary1"

/obj/item/chem_grenade/incendiary/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	B1.reagents.add_reagent("infernite", 20)
	src.beakers += B1

/obj/item/chem_grenade/very_incendiary
	name = "high range incendiary grenade"
	desc = "A rather volatile grenade that creates a large fire."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary-highrange"
	icon_state_armed = "incendiary-highrange1"

/obj/item/chem_grenade/very_incendiary/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	B1.reagents.add_reagent("firedust", 20)
	src.beakers += B1

/obj/item/chem_grenade/very_incendiary/vr
	icon = 'icons/effects/VR.dmi'
	icon_state = "chemg3"
	icon_state_armed = "chemg4"

/obj/item/chem_grenade/shock
	name = "shock grenade"
	desc = "An arc flashing grenade that shocks everyone close by."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "shock"
	icon_state_armed = "shock1"

/obj/item/chem_grenade/shock/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)

	B1.reagents.add_reagent("voltagen", 50)

	src.beakers += B1

/obj/item/chem_grenade/pepper
	name = "crowd dispersal grenade"
	desc = "An non-lethal grenade for use against protests, riots, vagrancy and loitering. Not to be used as a food additive."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "pepper"
	icon_state_armed = "pepper1"
	launcher_damage = 20

/obj/item/chem_grenade/pepper/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)
	B1.reagents.maximum_volume=75 //dumb hack, but it works
	B1.reagents.add_reagent("capsaicin", 50)
	B1.reagents.add_reagent("sugar",25)

	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("potassium", 25)
	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/saxitoxin
	name = "STX grenade"
	desc = "A smoke grenade containing an extremely lethal nerve agent. Use of this mixture constitutes a war crime, so... try not to leave any witnesses."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "saxitoxin"
	icon_state_armed = "saxitoxin1"

/obj/item/chem_grenade/saxitoxin/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)
	B1.reagents.maximum_volume=100 //dumb hack, but it works
	B1.reagents.add_reagent("saxitoxin", 75)
	B1.reagents.add_reagent("sugar",25)

	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("potassium", 25)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/luminol
	name = "luminol smoke grenade"
	desc = "A smoke grenade containing a compound that reveals traces of blood."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "luminol"
	icon_state_armed = "luminol1"
	is_dangerous = FALSE
	launcher_damage = 5

/obj/item/chem_grenade/luminol/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("luminol", 15)
	B1.reagents.add_reagent("sugar",15)

	B2.reagents.add_reagent("phosphorus", 15)
	B2.reagents.add_reagent("potassium", 15)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/fog
	name = "fog grenade"
	desc = "A specialized smoke grenade that releases a fog that blocks vision, but is not irritating to inhale."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "fog"
	icon_state_armed = "fog1"
	is_dangerous = FALSE
	launcher_damage = 10

/obj/item/chem_grenade/fog/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("fog", 25)
	B1.reagents.add_reagent("sugar",25)

	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("potassium", 25)

	src.beakers += B1
	src.beakers += B2

/obj/item/chem_grenade/napalm
	name = "napalm smoke grenade"
	desc = "A grenade that will fill an area with napalm smoke."
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "incendiary"
	icon_state_armed = "incendiary1"

/obj/item/chem_grenade/napalm/New()
	..()
	var/obj/item/reagent_containers/glass/B1 = new(src)
	var/obj/item/reagent_containers/glass/B2 = new(src)

	B1.reagents.add_reagent("syndicate_napalm", 25)
	B1.reagents.add_reagent("sugar",25)

	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("potassium", 25)

	src.beakers += B1
	src.beakers += B2
