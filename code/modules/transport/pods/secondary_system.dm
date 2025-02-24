/obj/item/shipcomponent/secondary_system
	name = "Secondary System"
	desc = "Add functionality to the ship"
	power_used = 0
	system = "Secondary System"
	var/f_active = 0 //1 if use proc activates/deactivates the systems.
	var/hud_state = "blank"
	icon_state= "sec_system"

	proc/Use(mob/user as mob)
		boutput(user, "[ship.ship_message("No special function for this ship!")]")
		return

	proc/Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
		return

	proc/Clickdrag_ObjectToPod(var/mob/living/user,var/atom/A)
		return

/obj/item/shipcomponent/secondary_system/cloak
	name = "Medusa Stealth System 300"
	desc = "When activated cloaks the ship."
	power_used = 250
	hud_state = "cloak"
	f_active = 1
	var/image/shield = null
	icon_state = "medusa"

	Use(mob/user as mob)
		if(!active)
			activate()
		else
			deactivate()
		return

	activate()
		..()
		if(!active)
			return
		ship.invisibility = INVIS_CLOAK
		shield = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)
		ship.overlays += shield
		return

	deactivate()
		..()
		ship.invisibility = INVIS_NONE
		ship.overlays -= shield
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<B>SYSTEM ONLINE</B>"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

	run_component()
		if (!src.ship.passengers)
			src.deactivate()

/obj/item/shipcomponent/secondary_system/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	desc = "Allows the ship to scoop up ore automatically."
	var/capacity = 300
	var/max_stack_scoop = 20 //! if you try to put stacks inside the item, this one limits how much you can in one action. Creating 100 items out of a stack in a single action should not happen.
	hud_state = "cargo"
	f_active = 1
	icon_state = "ore_hold"

	Use(mob/user as mob)
		activate()
		return

	activate()
		boutput(usr, "[ship.ship_message("To unload, click and drag the pod onto a nearby tile.")]")
		return

	deactivate()
		return

	on_shipdeath(var/obj/machinery/vehicle/ship)
		if (ship)
			SPAWN(1 SECOND)	//idk so it doesn't get caught on big pods when they are still aorund...
				for (var/obj/O in src.contents)
					O.set_loc(get_turf(ship))
					O.throw_at(get_edge_target_turf(O, pick(alldirs)), rand(1,3), 3)

		..()

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		dat += {"<BR><B>Capacity: [src.contents.len]/[src.capacity]</B><HR>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

	Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
		if (length(contents) < 1)
			boutput(user, SPAN_ALERT("[src] has nothing to unload."))
			return

		var/turf/T = get_turf(A)

		var/inrange = 0
		for(var/turf/ST in src.ship.locs)
			if (BOUNDS_DIST(T, ST) == 0)
				inrange = 1
				break
		if (!inrange)
			boutput(user, SPAN_ALERT("That tile too far away."))
			return

		if (T.density)
			return

		for(var/obj/O in T.contents)
			if(O.density)
				boutput(user, SPAN_ALERT("That tile is blocked by [O]."))
				return

		for(var/obj/item/I in src.contents)
			I.set_loc(T)
		return

/obj/item/shipcomponent/secondary_system/cargo
	name = "Cargo Hold"
	desc = "Allows the ship to load crates and transport them. One of Tradecraft Seneca's best sellers."
	var/list/load = list() //Current crates inside
	var/maxcap = 3 //how many crates it can hold
	var/list/acceptable = list(/obj/storage/crate,
	/obj/storage/secure/crate,
	/obj/machinery/artifact,
	/obj/artifact,
	/obj/mopbucket,
	/obj/beacon_deployer,
	/obj/machinery/portable_atmospherics,
	/obj/machinery/space_heater,
	/obj/machinery/oreaccumulator,
	/obj/machinery/bot,
	/obj/machinery/nuclearbomb,
	/obj/bomb_decoy,
	/obj/gold_bee,
	/obj/reagent_dispensers/beerkeg)

	hud_state = "cargo"
	f_active = 1

	small
		maxcap = 1
		name = "Small Cargo Hold"

	Exited(Obj, newloc)
		. = ..()
		src.load -= Obj

/obj/item/shipcomponent/secondary_system/cargo/Use(mob/user as mob)
	activate()
	return

/obj/item/shipcomponent/secondary_system/cargo/deactivate()
	for(var/atom/movable/O in load) //Drop cargo.
		src.unload(O)
	return

/obj/item/shipcomponent/secondary_system/cargo/activate()
	var/loadmode = tgui_input_list(usr, "Unload/Load", "Unload/Load", list("Load", "Unload"))
	if(usr.loc != src.ship)
		return
	switch(loadmode)
		if("Load")
			var/atom/movable/AM = null
			for(var/atom/movable/A in get_step(ship.loc, turn(ship.dir,180) ))
				if(!A.anchored)
					AM = A
					break
			if(AM)
				load(AM)
			return
		if("Unload")
			var/crate
			if (length(load) == 1)
				crate = load[1]
			else
				crate = src.get_unloadable(usr)
			if(!crate)
				return
			unload(crate)
		else
			return
	return

/obj/item/shipcomponent/secondary_system/cargo/opencomputer(mob/user as mob)
	if(user.loc != src.ship)
		return
	src.add_dialog(user)

	var/dat = {"<TT><B>[src] Console</B><BR><HR><BR>
				<BR><B>Current Contents:</B><HR>"}
	for(var/cargoitem in load)
		dat += {"<BR><B>[cargoitem]</B><HR>
				<BR>"}
	user.Browse(dat, "window=ship_sec_system")
	onclose(user, "ship_sec_system")
	return

/obj/item/shipcomponent/secondary_system/cargo/Clickdrag_PodToObject(var/mob/living/user,var/atom/A)
	if (!length(src.load))
		boutput(user, SPAN_ALERT("[src] has nothing to unload."))
		return

	var/crate = src.get_unloadable(user)
	if(!crate)
		return

	var/turf/T = get_turf(A)
	var/inrange = 0
	for(var/turf/ST in src.ship.locs)
		if (in_interact_range(T,ST) && in_interact_range(user,ST))
			inrange = 1
			break
	if (!inrange)
		boutput(user, SPAN_ALERT("That tile too far away."))
		return

	if (T.density)
		return

	for(var/obj/O in T.contents)
		if(O.density)
			boutput(user, SPAN_ALERT("That tile is blocked by [O]."))
			return

	unload(crate,T)
	return

/obj/item/shipcomponent/secondary_system/cargo/Clickdrag_ObjectToPod(var/mob/living/user,var/atom/A)
	if(isturf(A))
		return
	if (length(src.load) > src.maxcap)
		boutput(user, SPAN_ALERT("[src] has no available cargo space."))
		return

	switch(src.load(A))
		if (1)
			// if cargo system is not emagged, only allow crates to be loaded
			boutput(user, SPAN_ALERT("The pod's cargo autoloader rejects [A]."))
			return
		if (2)
			// cargo system full (this should never happen)
			boutput(user, SPAN_ALERT("[src] has no available cargo space."))
			return
		if (3)
			// out of range (this should never happen)
			boutput(user, SPAN_ALERT("Something is too far away to do that."))
			return
		if (4)
			// crate is anchored
			boutput(user, SPAN_ALERT("The pod's cargo autoloader fails to budge [A]!"))
			return
		if (0)
			// success
			src.visible_message(SPAN_NOTICE("[user] loads the [A] into [src]'s cargo bay."))
			return

	boutput(user, SPAN_ALERT("[src] has no cargo system or no available cargo space."))
	return

/obj/item/shipcomponent/secondary_system/cargo/proc/load(var/atom/movable/C, var/mob/user)
	if(!user)
		user = usr

	if(length(src.load) >= maxcap)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		boutput(user, "[ship.ship_message("Cargo hold is full!")]")
		return 2

	var/inrange = 0
	for (var/turf/T in src.ship.locs)
		if (in_interact_range(T, C) && in_interact_range(user, C))
			inrange = 1
			break
	if (!inrange)
		return 3

	if(C.anchored)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return 4

	// if a crate, close before loading
	var/obj/storage/crate/crate = C
	if(istype(crate))
		crate.close()

	var/acceptable_cargo = 0
	for(var/X in src.acceptable)
		if (istype(C,X))
			acceptable_cargo = 1
			break
	if (isliving(C))
		var/mob/living/L = C
		if(isdead(L))
			acceptable_cargo = 1
	if (!acceptable_cargo)
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return 1 // invalid cargo

	C.set_loc(src)
	load += C
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
	return 0

/obj/item/shipcomponent/secondary_system/cargo/proc/unload(var/atom/movable/C,var/turf/T)
	if(!C || !(C in load))
		return

	if(T)
		C.set_loc(T)
	else
		C.set_loc(ship.loc)
	step(C, turn(ship.dir,180))
	return C

/obj/item/shipcomponent/secondary_system/cargo/proc/get_unloadable(mob/user)
	var/list/cargo_by_name = list()
	var/list/counts_by_type = list()
	for (var/atom/movable/AM as anything in src.load)
		counts_by_type[AM.type] += 1
		if (counts_by_type[AM.type] == 1)
			cargo_by_name[AM.name] = AM
		else
			cargo_by_name["[AM.name] #[counts_by_type[AM.type]]"] = AM

	return cargo_by_name[tgui_input_list(user, "Choose which cargo to unload", "Choose Cargo", sortList(cargo_by_name, GLOBAL_PROC_REF(cmp_text_asc)))]

/obj/item/shipcomponent/secondary_system/cargo/on_shipdeath(var/obj/machinery/vehicle/ship)
	shuffle_list(src.load)
	for(var/atom/movable/AM in src.load)
		if (src.unload(AM))
			AM.visible_message(SPAN_ALERT("<b>[AM]</b> is flung out of [src.ship]!"))
			AM.throw_at(get_edge_target_turf(AM, pick(alldirs)), rand(3,7), 3)
		else
			break
	..()

/obj/item/shipcomponent/secondary_system/cargo/jumpseat
	name = "personal containment unit"
	desc = "Allows the ship to load people as cargo. It is designed to integrate with the Life-Support System so it is probably safe?"
	acceptable = list(/mob/living/carbon, /mob/living/silicon)
	maxcap = 1
	hud_state = "jumpseat"

/obj/item/shipcomponent/secondary_system/cargo/jumpseat/handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		. = src.ship.handle_internal_lifeform(lifeform_inside_me, breath_request, mult)

/obj/item/shipcomponent/secondary_system/cargo/jumpseat/activate()
	var/loadmode = tgui_input_list(usr, "Unload/Load", "Unload/Load", list("Load", "Unload"))
	switch(loadmode)
		if("Load")
			var/mob/AM = null
			for(var/mob/living/LM in get_step(ship.loc, turn(ship.dir,180) ))
				if(!LM.anchored)
					AM = LM
					break
			if(AM)
				AM.show_text(SPAN_NOTICE("\The [src.ship] is trying to load you in!"))
				SETUP_GENERIC_ACTIONBAR(AM, src, 2 SECONDS, /obj/item/shipcomponent/secondary_system/cargo/proc/load, list(AM,usr), src.icon, src.icon_state, "[AM] successfully enters [his_or_her(AM)] \the [src.ship]'s!", null)
			return
		if("Unload")
			if (length(load) == 1)
				unload(load[1])
		else
			return
	return

/obj/item/shipcomponent/secondary_system/cargo/jumpseat/relaymove(mob/user as mob)
	if(is_incapacitated(user))
		return
	if(ON_COOLDOWN(src, "relaymove", 1.5 SECOND))
		return

	if(!user.restrained() && prob(33))
		user.show_text(SPAN_NOTICE("You manage to find the internal manual release!"))
		if(tgui_alert(user, "Are you sure you want to activate the release?", "Exit [src.ship]", list("Yes", "No")) == "Yes")
			src.unload(user)
	else
		user.show_text(SPAN_ALERT("You kick at [src], but it doesn't budge!"))

/obj/item/shipcomponent/secondary_system/cargo/jumpseat/mob_flip_inside(var/mob/user)
	..(user)
	if(prob(3) || (!user.restrained() && prob(33)))
		if (src.unload(user))
			user.show_text(SPAN_ALERT("You manage to catch something and hear a click!"))
			user.visible_message(SPAN_ALERT("<b>[user]</b> is flung out of [src.ship]!"))
			user.throw_at(get_edge_target_turf(user, pick(alldirs)), rand(3,7), 3)

/obj/item/shipcomponent/secondary_system/storage
	name = "Storage Hold"
	desc = "Allows the ship to hold many smaller items, versus a typical cargo hold."
	hud_state = "cargo"
	f_active = TRUE
	var/obj/dummy_storage/dummy_storage

	New()
		..()
		src.dummy_storage = new(null, src)

	disposing()
		qdel(src.dummy_storage)
		src.dummy_storage = null
		..()

/obj/item/shipcomponent/secondary_system/auto_repair_kit
	name = "Automatic Repair System"
	desc = "When fueled with welding fuel, consumes it over time to automatically repair any damage to the ship."
	hud_state = "auto_repair"
	power_used = 25

	New()
		src.flags |= OPENCONTAINER
		..()
		src.create_reagents(100)

	activate()
		if (src.reagents.get_reagent_amount("fuel") <= 0)
			boutput(src.ship.pilot, "[src.ship.ship_message("[src] is out of fuel!")]")
			return
		var/obj/machinery/vehicle/vehicle = src.ship
		if (vehicle.health >= vehicle.maxhealth)
			boutput(src.ship.pilot, "[src.ship.ship_message("The ship is at full health!")]")
			return

		return ..()

	run_component(mult)
		if (!src.active)
			return
		if (GET_COOLDOWN(src.ship, "in_combat"))
			return
		if (src.reagents.get_reagent_amount("fuel") <= 0)
			boutput(src.ship.pilot, "[src.ship.ship_message("[src] is out of fuel!")]")
			src.deactivate()
			return
		var/obj/machinery/vehicle/vehicle = src.ship
		if (vehicle.health >= vehicle.maxhealth)
			boutput(src.ship.pilot, "[src.ship.ship_message("The ship is now at full health.")]")
			src.deactivate()
			return
		var/fuel_to_use = min(src.reagents.get_reagent_amount("fuel"), 1 * mult)
		src.reagents.remove_reagent("fuel", fuel_to_use)
		vehicle.health = min(vehicle.health + 15 * mult, vehicle.maxhealth)
		vehicle.checkhealth()

	get_desc(dist, mob/user)
		. = ..()
		. += "<br>[SPAN_NOTICE("[src.reagents.get_description(user, RC_SCALE)]")]"

	attack_self(mob/user)
		..()
		if (tgui_alert(user, "Empty reagents?", "Confirmation", list("Yes", "No")) == "Yes")
			src.reagents.trans_to(get_turf(src), src.reagents.maximum_volume)

	afterattack(obj/O, mob/user)
		..()
		if (src.reagents.total_volume >= src.reagents.maximum_volume)
			boutput(user, SPAN_ALERT("[src] is at max capacity!"))
			return
		if ((istype(O, /obj/reagent_dispensers) || istype(O, /obj/item/reagent_containers/food/drinks/fueltank)) && BOUNDS_DIST(src, O) == 0)
			if (O.reagents.total_volume)
				O.reagents.trans_to(src, 100)
				playsound(src.loc, 'sound/effects/zzzt.ogg', 50, TRUE, -6)
			else
				boutput(user, SPAN_ALERT("The [O.name] is empty!"))

/obj/item/shipcomponent/secondary_system/storage/Use(mob/user)
	src.dummy_storage.storage.show_hud(user)

/obj/item/shipcomponent/secondary_system/storage/activate()
	src.dummy_storage.storage.show_hud(usr)

/obj/item/shipcomponent/secondary_system/storage/deactivate()
	for (var/atom/A as anything in src.dummy_storage.storage.get_contents())
		src.dummy_storage.storage.transfer_stored_item(A, get_turf(src))

/obj/item/shipcomponent/secondary_system/storage/Clickdrag_PodToObject(mob/living/user, atom/A)
	if (user == A)
		src.dummy_storage.storage.show_hud(user)

/obj/item/shipcomponent/secondary_system/storage/Clickdrag_ObjectToPod(mob/living/user, atom/A)
	if (istype(A, /obj/item) && src.dummy_storage.storage.check_can_hold(A) == STORAGE_CAN_HOLD)
		src.dummy_storage.storage.add_contents(A, user)
	else
		boutput(user, SPAN_NOTICE("[src] can't hold this!"))

/obj/item/shipcomponent/secondary_system/storage/on_shipdeath(var/obj/machinery/vehicle/ship)
	var/atom/movable/AM
	for (var/atom/A in src.dummy_storage.storage.get_contents())
		src.dummy_storage.storage.transfer_stored_item(A, get_turf(src.ship))
		A.visible_message(SPAN_ALERT("<b>[A]</b> is flung out of [src.ship]!"))
		if (istype(A, /atom/movable))
			AM = A
			AM.throw_at(get_edge_target_turf(AM, pick(alldirs)), rand(3, 7), 3)

/obj/dummy_storage
	name = "Storage Hold"

	New(turf/newLoc, obj/item/shipcomponent/secondary_system/storage/parent_storage)
		..()
		src.create_storage(/datum/storage, max_wclass = W_CLASS_NORMAL, slots = 10)
		src.set_loc(parent_storage)

ABSTRACT_TYPE(/obj/item/shipcomponent/secondary_system/thrusters)
/obj/item/shipcomponent/secondary_system/thrusters
	f_active = TRUE
	power_used = 50
	var/power_in_use = FALSE
	var/cooldown_time
	var/cd_message

	Use(mob/user)
		src.activate(user)

	toggle()
		src.activate()

	activate(mob/user)
		. = TRUE

		user = user || usr

		if (user != src.ship.pilot)
			return FALSE

		if (src.disrupted)
			boutput(src.ship.pilot, "[src.ship.ship_message("ALERT: [src] is temporarily disabled!")]")
			return FALSE

		if (ON_COOLDOWN(src, "thruster_movement", src.cooldown_time))
			boutput(user, "[src.ship.ship_message("[src.cd_message] [round(GET_COOLDOWN(src, "thruster_movement") / 10, 0.1)] seconds left.")]")
			return FALSE

		if (!src.power_in_use)
			if (src.ship.powercapacity < (src.ship.powercurrent + src.power_used))
				boutput(src.ship.pilot, "[src.ship.ship_message("Not enough power to activate [src]! ([ship.powercurrent + power_used]/[ship.powercapacity])")]")
				return FALSE
			src.ship.powercurrent += src.power_used
			src.active = TRUE
			src.power_in_use = TRUE

		src.use_thrusters(user)

	deactivate()
		..()
		src.power_in_use = FALSE

	proc/use_thrusters(mob/user)
		return

	proc/change_thruster_direction()
		return

/obj/item/shipcomponent/secondary_system/thrusters/lateral
	name = "Lateral Thrusters"
	desc = "A thruster system that provides a burst of lateral movement upon use. Note, NanoTrasen is not liable for any resulting injuries."
	help_message = "Initialized to provide movement to the right. When installed in a pod, click the pod and use the context menu button to change direction."
	hud_state = "lat_thrusters_right"
	cooldown_time = 5 SECONDS
	cd_message = "Thrusters are cooling down!"
	var/turn_dir = "right"

	use_thrusters(mob/user)
		var/turn_angle = src.turn_dir == "right" ? -90 : 90

		// spawn to allow button clunk sound to play right away
		SPAWN(0)
			for (var/i in 1 to 5)
				step(src.ship, turn(src.ship.dir, turn_angle))
				sleep(0.125 SECONDS)
			src.deactivate(FALSE)

	change_thruster_direction()
		if (src.turn_dir == "right")
			src.turn_dir = "left"
			src.hud_state = "lat_thrusters_left"
			src.ship.myhud.update_states()
		else
			src.turn_dir = "right"
			src.hud_state = "lat_thrusters_right"
			src.ship.myhud.update_states()
		boutput(usr, SPAN_NOTICE("Thrusters will now provide ship movement to the [src.turn_dir]."))

/obj/item/shipcomponent/secondary_system/thrusters/afterburner
	name = "Afterburner"
	desc = "An engine augment that enhances the burning of plasma, increasing maximum velocity for a short duration."
	icon_state = "afterburner"
	hud_state = "lat_thrusters_right"
	f_active = TRUE
	power_used = 50
	cooldown_time = 20 SECONDS
	cd_message = "Afterburner is recharging!"


	use_thrusters(mob/user)
		// spawn to allow button clunk sound to play right away
		SPAWN(0)
			boutput(user, "[src.ship.ship_message("Afterburner is now active!")]")
			src.ship.afterburner_accel_mod *= 1.1
			src.ship.afterburner_speed_mod *= 1.75
			sleep(5 SECONDS)
			src.deactivate()

	deactivate()
		..()
		src.ship.afterburner_accel_mod /= 1.1
		src.ship.afterburner_speed_mod /= 1.75

/obj/item/shipcomponent/secondary_system/tractor_beam
	name = "Tri-Corp Tractor Beam"
	desc = "Allows the ship to pull objects towards it"
	var/atom/movable/target = null //how many crates it can hold
	var/seekrange = 10
	var/settingup = 1
	var/image/tractor = null
	f_active = 1
	power_used = 80
	hud_state = "tractor_beam"
	icon_state = "trac_beam"

	run_component()
		if(settingup)
			return
		if(target in view(src.seekrange,ship.loc))
			step_to(target, ship, 1)
			return
		deactivate()
		return

	Use(mob/user as mob)
		if(!active)
			activate()
		else
			deactivate()
	activate()
		..()
		if(!active)
			return

		var/list/targets_by_name = list()
		var/list/counts_by_type = list()
		for (var/atom/movable/a in view(src.seekrange,ship.loc))
			if(!a.anchored)
				counts_by_type[a.type] += 1
				if (counts_by_type[a.type] == 1)
					targets_by_name[a.name] = a
				else
					targets_by_name["[a.name] #[counts_by_type[a.type]]"] = a

		target = targets_by_name[tgui_input_list(usr, "Choose what to use the tractor beam on", "Choose Target", sortList(targets_by_name, GLOBAL_PROC_REF(cmp_text_asc)))]

		if(!target)
			deactivate()
			return
		tractor = image("icon" = 'icons/obj/ship.dmi', "icon_state" = "tractor", "layer" = FLOAT_LAYER)
		target.overlays += tractor
		RegisterSignal(src.ship, COMSIG_MOVABLE_MOVED, PROC_REF(tractor_drag))
		settingup = 0

	deactivate()
		..()
		settingup = 1
		if(target)
			target.overlays -= tractor
			target = null
			UnregisterSignal(src.ship, COMSIG_MOVABLE_MOVED)
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<BR><B>Current Target</B>: [target]"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

	proc/tractor_drag(obj/machinery/vehicle/holding_ship, atom/previous_loc, direction)
		if (QDELETED(src.target) || GET_DIST(holding_ship, src.target) > src.seekrange)
			UnregisterSignal(src.ship, COMSIG_MOVABLE_MOVED)
			return
		step_to(src.target, src.ship, 1)

/obj/item/shipcomponent/secondary_system/repair
	name = "Duracorp Construction Device"
	desc = "Gives ships the ability to repair external damage to space stations."
	var/list/load = list() //Current crates inside
	var/ammo = 30 //current ammo
	var/maxammo = 30 //max RCD ammo
	f_active = 1
	hud_state = "repair"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		return

	activate()
		var/repairmode = input(usr, "Please choose the function to use.", "Repair Mode")  as null|anything in list("Construct", "Repair", "Deconstruct")
		switch(repairmode)
			if("Construct")
				if(!ammo)
					return
				var/turf/T = get_turf(get_step(ship.loc, ship.dir))
				if (istype(T, /turf/space) && ammo >= 1)
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					T:ReplaceWithFloor()
					ammo--
					return
				if (istype(T, /turf/simulated/floor) && ammo >= 3)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(20))
						T:ReplaceWithWall()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
						ammo -= 3
					return

			if("Repair")
				for(var/obj/structure/girder/G in get_step(ship.loc, ship.dir))
					var/turf/T = get_turf(G.loc)
					qdel(G)
					T:ReplaceWithWall()
					playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					break
				return


			if("Deconstruct")
				var/turf/T = get_turf(get_step(ship.loc, ship.dir))
				if (istype(T, /turf/simulated/wall) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithFloor()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					return
				if ((istype(T, /turf/simulated/wall/r_wall) || istype(T, /turf/simulated/wall/auto/reinforced) ) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithWall()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)

					return
				if (istype(T, /turf/simulated/floor) && ammo >= 5)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(after_time(50))
						ammo -= 5
						T:ReplaceWithSpace()
						playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
					return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		if(src.active)
			dat+=  {"<B>Current Ammo</B>:[src.ammo]/[src.maxammo]"}
		else
			dat += {"<B><span style=\"color:red\">SYSTEM OFFLINE</span></B>"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")
		return

/obj/item/shipcomponent/secondary_system/gps
	name = "Ship's Navigation GPS"
	desc = "A useful navigation device for those lost in space."
	f_active = 1
	power_used = 50
	icon_state = "ship_gps"

	Use(mob/user as mob)
		opencomputer(user)
		return
	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		src.add_dialog(user)

		var/dat = "<TT><B>[src] Console</B><BR><HR><BR>"
		dat+=  {"<BR><B>Located at:</B><HR>
			<b>X</b>: [src.ship.x]<BR><b>Y</b>: [src.ship.y]"}
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")

/obj/item/shipcomponent/secondary_system/UFO
	name = "Abductor"
	desc = "Useful for abducting humans for experimentation"
	f_active = 1
	power_used = 50
	hud_state = "abductor"

	Use(mob/user as mob)
		var/mob/target = input(user, "Choose Who to Abduct", "Choose Target")  as mob in view(ship.loc)
		if(target)
			boutput(target, SPAN_ALERT("<B>You have been abducted!</B>"))
			showswirl(get_turf(target))
			target.set_loc(ship)
		return

	opencomputer(mob/user as mob)
		if(user.loc != src.ship)
			return
		var/dat = "<TT><B>[src] Console</B><BR><HR>"
		for(var/mob/M in ship)
			if(M == ship.pilot) continue
			dat +="<A href='?src=\ref[src];release=[M.name]'><B><U>[M.name]</U></B></A><BR>"
		user.Browse(dat, "window=ship_sec_system")
		onclose(user, "ship_sec_system")

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)
		if (href_list["release"])
			for(var/mob/M in ship)
				if(cmptext(href_list["release"], M.name))
					var/list/turfs = get_area_turfs(/area/shuttle/arrival, 1)
					if (length(turfs))
						M.set_loc(pick(turfs))
						showswirl(get_turf(M))
		opencomputer(usr)
		return

/obj/item/shipcomponent/secondary_system/lock
	name = "Hatch Locking Unit"
	desc = "A basic hatch locking mechanism with keypad entry."
	system = "Lock"
	f_active = 1
	power_used = 0
	icon_state = "lock"
	var/code = ""
	var/configure_mode = 0 //If true, entering a valid code sets that as the code.

	disposing()
		if (ship)
			ship.locked = 0
			ship.lock = null

		..()

	deactivate()
		if (ship)
			ship.locked = 0

		if (!src.active)
			src.active = 0
			ship.powercurrent -= power_used

	Use(mob/user as mob)
		return show_lock_panel(user, 1)

	proc/show_lock_panel(mob/user)
		var/dat = {"
<!DOCTYPE html>
<head>
<title>Pod Locking Mechanism</title>
<style type="text/css">
	table.keypad, td.key
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		border:2px solid #1F1F1F;
		padding:10px;
		font-size:24px;
		font-weight:bold;
	}
	a
	{
		text-align:center;
		color:#1F1F1F;
		background-color:#7F7F7F;
		font-size:24px;
		font-weight:bold;
		border:2px solid #1F1F1F;
		text-decoration:none;
		display:block;
	}
</style>

</head>



<body bgcolor=#2F2F2F>
	<table border = 2 bgcolor=#7F3030 width = 150px>
		<tr><td><font face='system' size = 6 color=#FF0000 id = "readout">&nbsp;</font></td></tr>
	</table>
	<br>
	<table class = "keypad">
		<tr><td><a href='#' onclick='keypadIn(7); return false;'>7</a></td><td><a href='#' onclick='keypadIn(8); return false;'>8</a></td><td><a href='#' onclick='keypadIn(9); return false;'>9</a></td></td><td><a href='#' onclick='keypadIn("A"); return false;'>A</a></td></tr>
		<tr><td><a href='#' onclick='keypadIn(4); return false;'>4</a></td><td><a href='#' onclick='keypadIn(5); return false;'>5</a></td><td><a href='#' onclick='keypadIn(6); return false;'>6</a></td></td><td><a href='#' onclick='keypadIn("B"); return false;'>B</a></td></tr>
		<tr><td><a href='#' onclick='keypadIn(1); return false;'>1</a></td><td><a href='#' onclick='keypadIn(2); return false;'>2</a></td><td><a href='#' onclick='keypadIn(3); return false;'>3</a></td></td><td><a href='#' onclick='keypadIn("C"); return false;'>C</a></td></tr>
		<tr><td><a href='#' onclick='keypadIn(0); return false;'>0</a></td><td><a href='#' onclick='keypadIn("F"); return false;'>F</a></td><td><a href='#' onclick='keypadIn("E"); return false;'>E</a></td></td><td><a href='#' onclick='keypadIn("D"); return false;'>D</a></td></tr>

		<tr><td colspan=2 width = 100px><a id = "enterkey" href='?src=\ref[src];enter=0;'>ENTER</a></td><td colspan = 2 width = 100px><a href='#' onclick='keypadIn("reset"); return false;'>RESET</a></td></tr>
	</table>

<script language="JavaScript">
	var currentVal = "";

	function updateReadout(t, additive)
	{
		if ((additive != 1 && additive != "1") || currentVal == "")
		{
			document.getElementById("readout").innerHTML = "&nbsp;";
			currentVal = "";
		}
		var i = 0
		while (i++ < 4 && currentVal.length < 4)
		{
			if (t.length)
			{
				document.getElementById("readout").innerHTML += t.substr(0,1) + "&nbsp;";
				currentVal += t.substr(0,1);
				t = t.substr(1);
			}
		}

		document.getElementById("enterkey").setAttribute("href","?src=\ref[src];enter=" + currentVal + ";");
	}

	function keypadIn(num)
	{
		switch (num)
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
				updateReadout(num.toString(), 1);
				break;

			case "A":
			case "B":
			case "C":
			case "D":
			case "E":
			case "F":
				updateReadout(num, 1);
				break;

			case "reset":
				updateReadout("", 0);
				break;
		}
	}

</script>

</body>"}

		usr << browse(dat, "window=ship_lock;size=270x300;can_resize=0;can_minimize=0")
		onclose(user, "ship_lock")

	Topic(href, href_list)
		if(..())
			return

		if ((usr.contents.Find(src) || (in_interact_range(ship, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
			src.add_dialog(usr)

		if (href_list["enter"])
			if (configure_mode)
				var/new_code = uppertext(ckey(href_list["enter"]))
				if (!new_code || length(new_code) != 4 || !is_hex(new_code))
					usr << output("ERR!&0", "ship_lock.browser:updateReadout")
				else
					code = new_code
					configure_mode = 0
					usr << output("SET!&0", "ship_lock.browser:updateReadout")
					//if (ship)
					//	ship.access_computer(usr)

			else
				if (uppertext(href_list["enter"]) == src.code)
					usr << output("!OK!&0", "ship_lock.browser:updateReadout")
					if (ship)
						ship.locked = 0
						boutput(usr, SPAN_ALERT("The lock mechanism clicks unlocked."))
					//	ship.access_computer(usr)
				else
					usr << output("ERR!&0", "ship_lock.browser:updateReadout")
					var/code_attempt = uppertext(ckey(href_list["enter"]))
					/*
					Mastermind game in which the solution is "code" and the guess is "code_attempt"
					First go through the guess and find any with the exact same position as in the solution
					Increment rightplace when such occurs.
					Then go through the guess and, with each letter, go through all the letters of the solution code
					Increment wrongplace when such occurs.

					In both cases, add a power of two corresponding to the locations of the relevant letters
					This forms a set of flags which is checked whenever same-letters are found

					Once all of the guess has been iterated through for both rightplace and wrongplace, construct
					a beep/boop message dependant on what was gotten right.
					*/
					if (length(code_attempt) == 4)
						var/guessplace = 0
						var/codeplace = 0
						var/guessflags = 0
						var/codeflags = 0

						var/wrongplace = 0
						var/rightplace = 0
						while (++guessplace < 5)
							if ((((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, guessplace, guessplace + 1)))
								guessflags += 2 ** (guessplace-1)
								codeflags += 2 ** (guessplace-1)
								rightplace++

						guessplace = 0
						while (++guessplace < 5)
							codeplace = 0
							while(++codeplace < 5)
								if(guessplace != codeplace && (((guessflags - guessflags % (2 ** (guessplace - 1))) / (2 ** (guessplace - 1))) % 2 == 0) && (((codeflags - codeflags % (2 ** (codeplace - 1))) / (2 ** (codeplace - 1))) % 2 == 0) && (copytext(code_attempt, guessplace , guessplace + 1) == copytext(code, codeplace , codeplace + 1)))
									guessflags += 2 ** (guessplace-1)
									codeflags += 2 ** (codeplace-1)
									wrongplace++
									codeplace = 5

						var/desctext = ""
						switch(rightplace)
							if (1)
								desctext += "a short beep"
							if (2)
								desctext += "a pair of short beeps"
							if (3)
								desctext += "a trio of short beeps"

						if (desctext && (wrongplace) > 0)
							desctext += " and "

						switch(wrongplace)
							if (1)
								desctext += "a short boop"
							if (2)
								desctext += "two warbly boops"
							if (3)
								desctext += "a quick three boops"
							if (4)
								desctext += "a rather long boop"

						if (desctext)
							boutput(usr, SPAN_ALERT("The lock panel emits [desctext]."))

		else if (href_list["lock"])
			if  (usr.loc != src.ship)
				boutput(usr, SPAN_ALERT("You must be inside the ship to do that!"))
				return

			if (ship && !ship.locked)
				ship.locked = 1
				boutput(usr, SPAN_ALERT("The lock mechanism clunks locked."))
				//ship.access_computer(usr)

		else if (href_list["unlock"])
			if  (usr.loc != src.ship)
				boutput(usr, SPAN_ALERT("You must be inside the ship to do that!"))
				return

			if (ship?.locked)
				ship.locked = 0
				boutput(usr, SPAN_ALERT("The ship mechanism clicks unlocked."))
				//ship.access_computer(usr)

		else if (href_list["setcode"])
			if  (usr.loc != src.ship)
				boutput(usr, SPAN_ALERT("You must be inside the ship to do that!"))
				return

			src.configure_mode = 1
			if (src.ship)
				src.ship.locked = 0
			src.code = ""

			boutput(usr, "Code reset.  Please type new code and press enter.")
			show_lock_panel(usr)

/obj/item/shipcomponent/secondary_system/lock/bioscan
	name = "Biometric Hatch Locking Unit"
	desc = "A basic hatch locking mechanism with a biometric scan."
	system = "Lock"
	f_active = 1
	power_used = 0
	icon_state = "lock"
	code = ""
	configure_mode = 0 //If true, entering a valid code sets that as the code.
	var/bdna = null

	show_lock_panel(mob/living/user)
		if (isliving(user))
			if (isnull(bdna))
				boutput(user, SPAN_NOTICE("[ship]'s locking mechanism recognizes you as its key!"))
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				bdna = user?.bioHolder?.Uid
				ship.locked = 0
			else if ((bdna == user.bioHolder?.Uid) || (bdna == user.blood_DNA) )
				ship.locked = !ship.locked
				boutput(user, SPAN_ALERT("[ship] is now [ship.locked ? "locked" : "unlocked"]!"))
			else
				var/valid_dna_source = null
				if(ishuman(user))
					var/obj/item/parts/human_parts/limb
					var/mob/living/carbon/human/H = user
					limb = H.l_hand
					if(limb && ((istype(limb) && limb.original_DNA == bdna) || (limb.blood_DNA == bdna)))
						valid_dna_source = limb
					limb = H.r_hand
					if(!valid_dna_source && limb && ((istype(limb) && limb.original_DNA == bdna) || (limb.blood_DNA == bdna)))
						valid_dna_source = limb

				if(valid_dna_source)
					if(user.loc == src.ship)
						boutput(user, SPAN_ALERT("You press [valid_dna_source] against \the [src] for a moment."))
					else
						src.ship.visible_message("[user] holds [valid_dna_source] against the [src.ship] for a moment.")
					ship.locked = !ship.locked
					boutput(user, SPAN_ALERT("[ship] is now [ship.locked ? "locked" : "unlocked"]!"))

/obj/item/shipcomponent/secondary_system/crash
	name = "Syndicate Explosive Entry Device"
	desc = "The SEED that when explosively planted in a space station, lets you grow into the best death blossom you can be."
	f_active = 1
	power_used = 0
	var/crashable = 0
	var/crashhits = 10
	var/in_bump = 0
	hud_state = "seed"
	icon_state = "pod_seed"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		crashable = 0
		return

	activate()
		if (crashable == 0) // To avoid spam. SEEDs can't be deactivated (Convair880).
			logTheThing(LOG_VEHICLE, usr, "activates a SEED, turning [src.ship] into a flying bomb at [log_loc(src.ship)]. Direction: [dir2text(src.ship.dir)].")
		crashable = 1
		return

/obj/item/shipcomponent/secondary_system/crash/proc/dispense()
	for (var/mob/living/B in ship.contents)
		boutput(B, SPAN_ALERT("You eject!"))
		ship.leave_pod(B)
		ship.visible_message(SPAN_ALERT("[B] launches out of the [ship]!"))
		for(var/i in 1 to 3)
			step(B, turn(ship.dir, 180), 0)
		step_rand(B, 0)
		//B.remove_shipcrewmember_powers(ship.weapon_class)
	for(var/obj/item/shipcomponent/SC in src)
		SC.on_shipdeath()
	SPAWN(0) //???? otherwise we runtime
		qdel(ship)

/obj/item/shipcomponent/secondary_system/crash/proc/crashtime2(atom/A as mob|obj|turf)
	if (in_bump)
		return
	if (A == ship.pilot)
		return
	walk(src, 0)
	in_bump = 1
	crashhits--
	logTheThing(LOG_COMBAT, ship.pilot, "uses a SEED to crash into [A] at [log_loc(A)]")
	if(isturf(A))
		if((istype(A, /turf/simulated/wall/r_wall) || istype(A, /turf/simulated/wall/auto/reinforced)) && prob(40))
			in_bump = 0
			return
		if(istype(A, /turf/simulated/wall))
			var/turf/simulated/wall/T = A
			T.dismantle_wall(1)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
			boutput(ship.pilot, SPAN_ALERT("<B>You crash through the wall!</B>"))
			in_bump = 0
		if(istype(A, /turf/simulated/floor))
			var/turf/T = A
			if(prob(50))
				T.ReplaceWithLattice()
			else
				T.ReplaceWithSpace()
			if(prob(50))
				for (var/mob/M in src)
					shake_camera(M, 6, 8)
			if(prob(30))
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
				playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
				boutput(ship.pilot, SPAN_ALERT("<B>You plow through the floor!</B>"))
	if(ismob(A))
		var/mob/M = A
		boutput(ship.pilot, SPAN_ALERT("<B>You crash into [M]!</B>"))
		shake_camera(M, 8, 16)
		boutput(M, SPAN_ALERT("<B>The [src] crashes into you!</B>"))
		M.changeStatus("stunned", 8 SECONDS)
		M.changeStatus("knockdown", 5 SECONDS)
		M.TakeDamageAccountArmor("chest", 20, damage_type = DAMAGE_BLUNT)
		var/turf/target = get_edge_target_turf(ship, ship.dir)
		M.throw_at(target, 4, 2)
		playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
		in_bump = 0
	if(isobj(A))
		var/obj/O = A
		var/turf/T = get_turf(O)
		if(O.density && O.anchored != ANCHORED_ALWAYS && !isrestrictedz(T?.z))
			boutput(ship.pilot, SPAN_ALERT("<B>You crash into [O]!</B>"))
			var/turf/target = get_edge_target_turf(ship, ship.dir)
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, 1)
			playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 40, TRUE)
			O.throw_at(target, 20, 3, allow_anchored = TRUE, bonus_throwforce = 15)
			if (istype(O, /obj/machinery/vehicle))
				A.meteorhit(src)
				crashhits -= 3
			if (istype(O, /obj/rack) || istype(O, /obj/table))
				A.meteorhit(src)
			if (istype(O, /obj/storage/closet) || istype(O, /obj/storage/secure/closet))
				O:dump_contents()
				qdel(O)
			if(istype(O, /obj/window))
				for(var/obj/mesh/grille/G in get_turf(O))
					qdel(G)
				qdel(O)
			if(istype(O, /obj/mesh/grille))
				for(var/obj/window/W in get_turf(O))
					qdel(W)
				qdel(O)
			if (istype(O, /obj/machinery/door) || istype(O, /obj/structure/girder) || istype(O, /obj/foamedmetal))
				qdel(O)
			if (istype(O, /obj/critter) && !istype(O, /obj/critter/gunbot/drone)) // ugly hack to make this not instakill drones and stuff
				O:CritterDeath()
			in_bump = 0
	if (crashhits <= 0)
		explosion(ship, ship.loc, 1, 2, 2, 3)
		playsound(ship.loc, "explosion", 50, 1)
		dispense()
	in_bump = 0
	return

/obj/item/shipcomponent/secondary_system/syndicate_rewind_system
	name = "Syndicate Rewind System"
	desc = "An unfinished pod system, the blueprints for which have been plundered from a raid on a now-destroyed Syndicate base. Requires a unique power source to function."
	power_used = 50
	f_active = 1
	hud_state = "SRS_icon"
	var/cooldown = 0
	var/core_inserted = FALSE
	var/health_snapshot
	var/image/rewind
	icon = 'icons/misc/retribution/SWORD_loot.dmi'
	icon_state= "SRS_empty"

	Use(mob/user as mob)
		activate()
		return

	deactivate()
		return

	activate()
		if(!core_inserted)
			boutput(ship.pilot, SPAN_ALERT("<B>The system requires a unique power source to function!</B>"))
			return
		else if(cooldown > TIME)
			boutput(ship.pilot, SPAN_ALERT("<B>The system is still recharging!</B>"))
			return
		else
			boutput(ship.pilot, SPAN_ALERT("<B>Snapshot created!</B>"))
			playsound(ship.loc, 'sound/machines/reprog.ogg', 75, 1)
			cooldown = 20 SECONDS + TIME
			health_snapshot = ship.health
			if(ship.capacity == 1 || istype(/obj/machinery/vehicle/miniputt, ship) || istype(/obj/machinery/vehicle/recon, ship) || istype(/obj/machinery/vehicle/cargo, ship))
				rewind = image('icons/misc/retribution/SWORD_loot.dmi', "SRS_o_small", "layer" = EFFECTS_LAYER_4)
			else
				rewind = image('icons/misc/retribution/64x64.dmi', "SRS_o_large", "layer" = EFFECTS_LAYER_4)
			rewind.plane = PLANE_SELFILLUM
			src.ship.UpdateOverlays(rewind, "rewind")

			spawn(5 SECONDS)
				spawn(1 SECONDS)
					src.ship.UpdateOverlays(null, "rewind")
				playsound(ship.loc, 'sound/machines/bweep.ogg', 75, 1)
				if(ship.health < health_snapshot)
					ship.health = health_snapshot
					boutput(ship.pilot, SPAN_ALERT("<B>Snapshot applied!</B>"))
				else
					boutput(ship.pilot, SPAN_ALERT("<B>Snapshot discarded!</B>"))
				return
		return

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W) && core_inserted)
			core_inserted = FALSE
			set_icon_state("SRS_empty")
			user.put_in_hand_or_drop(new /obj/item/sword_core)
			user.show_message(SPAN_NOTICE("You remove the SWORD core from the Syndicate Rewind System!"), 1)
			desc = "After a delay, rewinds the ship's integrity to the state it was in at the moment of activation. The core is missing."
			tooltip_rebuild = 1
			return
		else if ((istype(W,/obj/item/sword_core) && !core_inserted))
			core_inserted = TRUE
			qdel(W)
			set_icon_state("SRS")
			user.show_message(SPAN_NOTICE("You insert the SWORD core into the Syndicate Rewind System!"), 1)
			desc = "After a delay, rewinds the ship's integrity to the state it was in at the moment of activation. The core is installed."
			tooltip_rebuild = 1
			return

ABSTRACT_TYPE(/obj/item/shipcomponent/secondary_system/shielding)
/obj/item/shipcomponent/secondary_system/shielding
	name = "Shielding System"
	desc = "Provides a timed shield to block incoming projectiles and explosions. Recharge is required between uses."
	f_active = TRUE
	hud_state = "shielding"
	/// % of damage, that the shielding blocks (0.5 would make a 40 dmg projectile deal 20 dmg instead)
	var/block_pct = 0
	/// health of the shield in dmg points
	var/life = 100
	/// how long the shield stays on
	var/duration = 0 SECONDS
	/// once deactivated, how long it takes for the shield to be ready again
	var/recharge_time = 0 SECONDS
	/// color of the shield
	var/shield_color

	New()
		..()
		src.desc += " Has a life of [src.life] damage, providing [round(block_pct * 100, 1)]% damage reduction. Shielding can be provided for [src.duration / 10] seconds" + \
					" with a shield recharge time of [src.recharge_time / 10] seconds."

	activate()
		var/cooldown = GET_COOLDOWN(src, "ship_shielding_recharge")
		if (cooldown)
			boutput(src.ship.pilot, "[src.ship.ship_message("[src] is currently recharging, and cannot be turned on. Wait [cooldown / 10] seconds.")]")
			return
		if (!..())
			return

		src.ship.add_filter("shield_outline", 0, outline_filter(2, src.shield_color))

		playsound(src.ship.loc, 'sound/effects/MagShieldUp.ogg', 75, TRUE, pitch = 1.5)

		SPAWN(src.duration)
			if (src.active)
				src.deactivate()

	deactivate()
		if (src.active)
			ON_COOLDOWN(src, "ship_shielding_recharge", src.recharge_time)
			for (var/mob/M in src.ship)
				boutput(M, "[src.ship.ship_message("[src]'s shield is now offline. Please wait for full recharge after [src.recharge_time / 10] seconds.")]")
			src.ship.remove_filter("shield_outline")
			playsound(src.ship.loc, 'sound/effects/MagShieldDown.ogg', 75, TRUE, pitch = 1.5)
			src.life = initial(src.life)
		..()

	// takes incoming damage "dmg", returns damage dealt to pod
	proc/process_incoming_dmg(dmg)
		var/dmg_dealt = dmg * (1 - src.block_pct)

		src.life -= dmg * src.block_pct

		if (src.life <= 0)
			src.deactivate()

		return dmg_dealt

/obj/item/shipcomponent/secondary_system/shielding/light
	name = "Light Shielding System"
	power_used = 50
	block_pct = 0.25
	life = 100
	duration = 10 SECONDS
	recharge_time = 60 SECONDS
	shield_color = "#1a4cf0"

/obj/item/shipcomponent/secondary_system/shielding/heavy
	name = "High Impact Shielding System"
	power_used = 150
	block_pct = 0.9
	life = 1000
	duration = 3 SECONDS
	recharge_time = 120 SECONDS
	shield_color = "#ff3916"

/obj/item/shipcomponent/secondary_system/trailblazer
	name = "Inferno Trailblazer"
	desc = "A totally RADICAL plasma igniter for your ship! Leave behind the COOLEST flames in the Frontier! Manufacturer is not responsible for deaths this device may cause."
	hud_state = "trailblazer"
	f_active = TRUE

	Use()
		return

	toggle()
		return

	activate()
		return

	deactivate()
		return
/obj/item/shipcomponent/secondary_system/weapons_loader
	name = "Weapons Loader"
	desc = "An automatic weapon loading system that quickly swaps a stored weapon with the ship's main weapon."
	icon_state = "weapons_loader-unloaded"
	help_message = "Attack with a pod weapon to load it in. Use in-hand to eject the loaded weapon."
	hud_state = "weapon-swap"
	f_active = TRUE
	var/obj/item/shipcomponent/mainweapon/loaded_wep = null

	Use(mob/user)
		src.activate(user)

	toggle()
		src.activate()

	activate()
		. = ..(FALSE)
		src.active = FALSE
		if (!.)
			return

		if (!src.loaded_wep && !src.ship.m_w_system)
			return

		if (src.loaded_wep && GET_COOLDOWN(src.loaded_wep, "fire") || src.ship.m_w_system && GET_COOLDOWN(src.ship.m_w_system, "fire"))
			boutput(src.ship.pilot, "[src.ship.ship_message("[src] must wait for all weapons to be off cooldown to work!")]")
			return

		for (var/mob/M in src.ship)
			if (src.loaded_wep && src.ship.m_w_system)
				boutput(M, "[src.ship.ship_message("[src.ship.m_w_system] has been swapped out for [src.loaded_wep].")]")
			else if (src.ship.m_w_system)
				boutput(M, "[src.ship.ship_message("[src.ship.m_w_system] has been swapped out.")]")
			else
				boutput(M, "[src.ship.ship_message("[src.loaded_wep] has been swapped in.")]")

		var/obj/item/shipcomponent/mainweapon/weapon = src.ship?.m_w_system
		if (istype(weapon))
			src.ship.eject_part(weapon, FALSE)
			src.ship.null_part(weapon)
		var/obj/item/shipcomponent/mainweapon/stored_weapon = src.loaded_wep
		if (stored_weapon)
			stored_weapon.ship = src.ship // prevents a bug in activate()
			src.ship.Install(stored_weapon, FALSE)
			src.loaded_wep = null
			src.UpdateIcon()
		if (istype(weapon))
			src.loaded_wep = weapon
			src.loaded_wep.set_loc(src)
			src.UpdateIcon()

		src.ship.myhud.update_systems()

	attack_self(mob/user)
		src.eject_wep(user)

	attack_hand(mob/user)
		if (!src.loaded_wep || src.loc != user)
			return ..()
		src.eject_wep(user)

	proc/eject_wep(mob/user)
		if (!src.loaded_wep)
			return
		src.loaded_wep.set_loc(get_turf(src))
		user.put_in_hand_or_drop(src.loaded_wep)
		src.loaded_wep = null
		src.UpdateIcon()

	attackby(obj/item/W, mob/user, params)
		..()
		if (src.loaded_wep)
			return
		if (!istype(W, /obj/item/shipcomponent/mainweapon))
			return
		user.drop_item(W)
		src.loaded_wep = W
		src.loaded_wep.set_loc(src)
		src.UpdateIcon()
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, FALSE)

	update_icon()
		..()
		src.icon_state = "weapons_loader-[src.loaded_wep ? "loaded" : "unloaded"]"
