#define CHARGING_BITS "Speed up Flockbits"
#define CHARGING_DRONES "Charge incapacitors"
#define CHARGING_STRUCTURES "Enhance structures"

/obj/flock_structure/sapper
	icon_state = "sapper-off" // current sprites are placeholders
	name = "sparking machine"
	desc = "A strange structure supporting four coils. You can feel the electricity coming off of it"
	flock_desc = "A multipurpose support structure that saps power from a local APC. It can be set to enchance Flockbits, Flockdrones, or structures."
	flock_id = "Sapper"
	health = 30
	health_max = 30
	repair_per_resource = 1.5
	resourcecost = 100

	passthrough = TRUE

	var/mode = CHARGING_BITS
	var/mode_cooldowns = list(CHARGING_BITS = 20 SECONDS, CHARGING_DRONES = 30 SECONDS, CHARGING_STRUCTURES = 30 SECONDS)

	var/obj/machinery/power/apc/linked_apc = null

	New(atom/location, datum/flock/F = null)
		..()
		src.linked_apc = src.try_link_apc()
		if (!src.linked_apc)
			src.icon_state = "sapper-off"

		src.info_tag.set_info_tag("Mode: [src.mode]")

		ON_COOLDOWN(src, CHARGING_BITS, src.mode_cooldowns[CHARGING_BITS])
		ON_COOLDOWN(src, CHARGING_DRONES, src.mode_cooldowns[CHARGING_DRONES])
		ON_COOLDOWN(src, CHARGING_STRUCTURES, src.mode_cooldowns[CHARGING_STRUCTURES])

	building_specific_info()
		return {"<span class='bold'>Mode:</span> [src.mode].
				<br><span class='bold'>Linked power supply charge:</span> [src.linked_apc?.cell ? "[round(src.linked_apc.cell.charge / src.linked_apc.cell.maxcharge * 100)]%": "Not linked"]."}

	process(mult)
		if (!src.linked_apc)
			src.try_link_apc()
			if (!src.linked_apc)
				src.icon_state = "sapper-off"
				return
		if (!linked_apc.cell || linked_apc.cell.charge <= 0 || linked_apc.status & BROKEN)
			src.icon_state = "sapper-off"
			return

		src.icon_state = "sapper-on"

		if (GET_COOLDOWN(src, src.mode))
			return
		if (linked_apc.cell.charge < linked_apc.cell.maxcharge * 0.1)
			return

		var/list/targets = list()

		switch(src.mode)
			if (CHARGING_BITS)
				var/list/nearby_mobs = range(4, src)
				shuffle_list(nearby_mobs)
				for (var/mob/living/critter/flock/bit/flockbit in nearby_mobs)
					if (flockbit.flock == src.flock)
						targets += flockbit
						if (length(targets) == 3)
							break
				if (!length(targets))
					return

				for (var/mob/living/critter/flock/bit/flockbit as anything in targets)
					flockbit.mob_flags |= HEAVYWEIGHT_AI_MOB
					SPAWN(src.mode_cooldowns[CHARGING_BITS] / 2)
						flockbit?.mob_flags &= ~HEAVYWEIGHT_AI_MOB

			if (CHARGING_DRONES)
				var/mob/living/critter/flock/drone/target
				var/list/nearby_mobs = range(4, src)
				shuffle_list(nearby_mobs)
				for (var/mob/living/critter/flock/drone/flockdrone in nearby_mobs)
					if (flockdrone.flock == src.flock)
						target = flockdrone
						break
				if (!target)
					return
				targets += target

				var/datum/handHolder/HH = target.hands[3]
				var/datum/limb/gun/flock_stunner/incapacitor = HH.limb
				incapacitor.cell.recharge_rate = 40
				incapacitor.cell.AddComponent(/datum/component/power_cell, incapacitor.cell.max_charge, incapacitor.cell.charge, incapacitor.cell.recharge_rate, incapacitor.cell.rechargable)
				SPAWN(src.mode_cooldowns[CHARGING_DRONES] / 2)
					if (incapacitor?.cell)
						incapacitor.cell.recharge_rate = initial(incapacitor.cell.recharge_rate)
						incapacitor.cell.AddComponent(/datum/component/power_cell, incapacitor.cell.max_charge, incapacitor.cell.charge, incapacitor.cell.recharge_rate, incapacitor.cell.rechargable)

			if (CHARGING_STRUCTURES)
				var/obj/flock_structure/target
				var/list/area_structures = list()
				for (var/obj/flock_structure/structure as anything in src.flock.structures)
					if (structure.accepts_sapper_power && get_area(structure) == get_area(src))
						area_structures += structure
				if (!length(area_structures))
					return
				target = pick(area_structures)
				targets += target
				if (!target.sapper_power())
					return

		playsound(src, 'sound/effects/elec_bigzap.ogg', 30, 1) // placeholder
		ON_COOLDOWN(src, src.mode, src.mode_cooldowns[src.mode])
		src.linked_apc.cell.use(src.linked_apc.cell.maxcharge * 0.1)
		src.linked_apc.AddComponent(/datum/component/flock_ping/sapper_power, 5 SECONDS)
		for (var/atom/A as anything in targets)
			A.AddComponent(/datum/component/flock_ping/sapper_power, src.mode_cooldowns[src.mode] / 2)

	Click(location, control, params)
		if (("alt" in params2list(params)) || !istype(usr, /mob/living/intangible/flock/flockmind))
			return ..()
		var/mode_select = tgui_input_list(usr, "Select mode or target removal", "Option select", list(CHARGING_BITS, CHARGING_DRONES, CHARGING_STRUCTURES))
		if (!mode_select || mode_select == src.mode)
			return
		if (mode_select != "Remove target")
			ON_COOLDOWN(src, mode_select, src.mode_cooldowns[mode_select])
			src.mode = mode_select
			src.info_tag.set_info_tag("Mode: [src.mode]")

	proc/try_link_apc()//
		var/obj/machinery/power/apc/apc_to_link = get_local_apc(src)
		if (!apc_to_link)
			return null
		return apc_to_link

#undef CHARGING_BITS
#undef CHARGING_DRONES
#undef CHARGING_STRUCTURES
