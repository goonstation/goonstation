#define ELECTRIC_CHAIR_TOGGLE_POWER 0
#define ELECTRIC_CHAIR_TOGGLE_LETHAL 1
#define ELECTRIC_CHAIR_SHOCK 2
#define ELECTRIC_CHAIR_SET_SIGNAL 3
/obj/stool/chair/e_chair
	name = "electrified chair"
	desc = "A chair that has been modified to conduct current with over 2000 volts, enough to kill a human nearly instantly."
	icon_state = "e_chair0"
	foldable = FALSE
	rotatable = FALSE
	var/on = FALSE
	var/obj/item/shock_kit/part1 = null
	var/last_time = 1
	var/lethal = FALSE
	var/image/image_belt = null
	comfort_value = -3
	securable = FALSE
	var/list/datum/contextAction/contexts = list()
	HELP_MESSAGE_OVERRIDE("")

	get_help_message(dist, mob/user)
		. = "You can use a <b>multitool</b> to open the settings menu, or a <b>wrench</b> to disassemble it."

	New(var/atom/new_location, var/obj/item/shock_kit/new_shock_kit)
		contextLayout = new /datum/contextLayout/experimentalcircle
		..()
		for(var/button in childrentypesof(/datum/contextAction/electric_chair))
			src.contexts += new button()
		if(!new_shock_kit)
			new_shock_kit = new /obj/item/shock_kit
		new_shock_kit.loc = src
		src.part1 = new_shock_kit
		new_shock_kit.master = src
		src.on = src.part1.electropack_part.on
		src.set_dir(SOUTH)
		src.UpdateIcon()
		// Electric chair + wrench  -> deconstruction
		src.AddComponent(/datum/component/assembly, TOOL_WRENCHING, PROC_REF(deconstruction), FALSE)
		// Electric chair + multitool  -> open context options
		src.AddComponent(/datum/component/assembly, TOOL_PULSING, PROC_REF(show_context_options), FALSE)

// ----------------------- Assembly-procs -----------------------

	/// deconstruction
	proc/deconstruction(var/atom/to_combine_atom, var/mob/user)
		var/turf/chosen_turf = get_turf(src)
		var/obj/stool/chair/new_chair = new /obj/stool/chair(chosen_turf)
		if (src.material)
			new_chair.setMaterial(src.material)
		if (src.part1)
			src.part1.set_loc(chosen_turf)
			src.part1.master = null
			src.part1 = null
		boutput(user, SPAN_NOTICE("You deconstruct the [src.name]."))
		playsound(chosen_turf, 'sound/items/Ratchet.ogg', 50, TRUE)
		qdel(src)
		// Since the assembly was done, return TRUE
		return TRUE

	/// change the options of the chair
	proc/show_context_options(var/atom/to_combine_atom, var/mob/user)
		user.showContextActions(src.contexts, src, src.contextLayout)
		// Since the "assembly" was done, return TRUE
		return TRUE

// ----------------------- -------------- -----------------------

	proc/set_option(setting, mob/user)
		switch(setting)
			if(ELECTRIC_CHAIR_TOGGLE_POWER)
				src.toggle_active()
			if(ELECTRIC_CHAIR_TOGGLE_LETHAL)
				src.toggle_lethal()
			if(ELECTRIC_CHAIR_SHOCK)
				if(src.buckled_guy)
					// The log entry for remote signallers can be found in item/shock_kit.dm (Convair880).
					logTheThing(LOG_COMBAT, usr, "activated an electric chair (setting: [src.lethal ? "lethal" : "non-lethal"]), shocking [constructTarget(src.buckled_guy,"combat")] at [log_loc(src)].")
				shock(lethal)
			if(ELECTRIC_CHAIR_SET_SIGNAL)
				src.part1.electropack_part.ui_interact(user)
		src.add_fingerprint(user)
		return

	proc/toggle_active()
		src.on = !(src.on)
		src.UpdateIcon()
		return src.on

	proc/toggle_lethal()
		src.lethal = !(src.lethal)
		src.UpdateIcon()
		return

	update_icon()
		src.icon_state = "e_chair[src.on]"
		if (!src.image_belt)
			src.image_belt = image(src.icon, "e_chairo[src.on][src.lethal]", layer = FLY_LAYER + 1)
			src.UpdateOverlays(src.image_belt, "belts")
		else
			src.image_belt.icon_state = "e_chairo[src.on][src.lethal]"
			src.UpdateOverlays(src.image_belt, "belts")
		for(var/datum/contextAction/electric_chair/button in src.contexts)
			switch(button.type)
				if(/datum/contextAction/electric_chair/toggle_power)
					button.icon_state = src.on ? "off_active" : "off"
				if(/datum/contextAction/electric_chair/toggle_lethal)
					button.icon_state = src.lethal ? "lethal_on" : "lethal"

	// Options:      1) place the chair anywhere in a powered area (fixed shock values),
	// (Convair880)  2) on top of a powered wire (scales with engine output).
	proc/get_connection()
		var/turf/T = get_turf(src)
		if (!istype(T, /turf/simulated/floor))
			return FALSE

		for (var/obj/cable/C in T)
			return C.netnum

		return FALSE

	proc/get_gridpower()
		var/netnum = src.get_connection()

		if (netnum)
			var/datum/powernet/PN
			if (powernets && length(powernets) >= netnum)
				PN = powernets[netnum]
				return PN.avail

		return FALSE

	proc/shock(lethal)
		if (!src.on)
			return
		if ((src.last_time + 50) > world.time)
			return
		src.last_time = world.time

		// special power handling
		var/area/A = get_area(src)
		if (!isarea(A))
			return
		if (!A.powered(EQUIP))
			return
		A.use_power(5000, EQUIP)
		A.UpdateIcon()

		for (var/mob/M in AIviewers(src, null))
			M.show_message(SPAN_ALERT("The electric chair went off!"), 3)
			if (lethal)
				playsound(src.loc, 'sound/effects/electric_shock.ogg', 50, FALSE)
			else
				playsound(src.loc, 'sound/effects/sparks4.ogg', 50, FALSE)

		if (src.buckled_guy && isliving(src.buckled_guy))
			var/mob/living/L = src.buckled_guy

			if (src.lethal)
				var/net = src.get_connection() // Are we wired-powered (Convair880)?
				var/power = src.get_gridpower()
				if (!net || (net && (power < 2000000)))
					L.shock(src, 2000000, "chest", 0.3, TRUE) // Nope or not enough juice, use fixed values instead (around 80 BURN per shock).
				else
					//DEBUG_MESSAGE("Shocked [L] with [power]")
					src.electrocute(L, 100, net, TRUE) // We are, great. Let that global proc calculate the damage.
			else
				L.shock(src, 2500, "chest", 1, TRUE)
				L.changeStatus("stunned", 10 SECONDS)

			if((L.mind?.get_antagonist(ROLE_REVOLUTIONARY)) && !(L.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY)) && prob(66))
				L.mind?.remove_antagonist(ROLE_REVOLUTIONARY)

		A.UpdateIcon()
		return

/datum/contextAction/electric_chair
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = TRUE
	var/action = null

	execute(obj/stool/chair/e_chair/e_chair, mob/user)
		if(!istype(e_chair))
			return
		e_chair.set_option(action, user)

	checkRequirements(obj/stool/chair/e_chair/e_chair, mob/user)
		. = can_act(user) && in_interact_range(e_chair, user)

	toggle_power
		icon_state = "off"
		name = "Toggle Power"
		action = ELECTRIC_CHAIR_TOGGLE_POWER

	toggle_lethal
		icon_state = "lethal"
		name = "Toggle Lethal"
		action = ELECTRIC_CHAIR_TOGGLE_LETHAL

	shock
		icon_state = "shock"
		name = "Shock"
		action = ELECTRIC_CHAIR_SHOCK

	set_signal
		icon_state = "radio"
		name = "Set radio"
		action = ELECTRIC_CHAIR_SET_SIGNAL


#undef ELECTRIC_CHAIR_TOGGLE_POWER
#undef ELECTRIC_CHAIR_TOGGLE_LETHAL
#undef ELECTRIC_CHAIR_SHOCK
#undef ELECTRIC_CHAIR_SET_SIGNAL
