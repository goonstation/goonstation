
/datum/lifeprocess/decomposition

	//proc/handle_decomposition()
	process(datum/gas_mixture/environment)
		if (isdead(owner) && human_owner) //hey i know this only hanldes human right now but i predict we will want other mobs to decompose later on
			var/mob/living/carbon/human/H = owner
			var/turf/T = get_turf(owner)
			if (!T)
				return ..()

			var/mult = get_multiplier()

			if (!isrestrictedz(T.z) && H.loc == T && T.temp_flags & HAS_KUDZU) //only infect if on the floor
				H.infect_kudzu()

			if (H.mutantrace && !H.mutantrace.decomposes)
				return ..()

			var/suspend_rot = \
					istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell) || \
					istype(owner.loc, /obj/item/reagent_containers/food/snacks/shell) || \
					owner.reagents?.has_reagent("formaldehyde") || \
					owner.reagents?.has_reagent("miasmosa")

			if (istype(owner.loc, /obj/machinery/traymachine/morgue)) //Morgues require power now
				var/obj/machinery/traymachine/morgue/stinkbox = owner.loc
				suspend_rot = !(stinkbox.status & NOPOWER)

			if (H.decomp_stage >= DECOMP_STAGE_SKELETONIZED)
				return ..()

			if (!(suspend_rot || istype(owner.loc, /obj/item/body_bag) || (istype(owner.loc, /obj/storage) && owner.loc:welded) || istype(owner.loc, /obj/statue)))
				icky_icky_miasma(T)

			var/env_temp = 0

			if (!suspend_rot && environment)
				env_temp = environment.temperature
				var/temperature_modifier = (env_temp - T20C) / 10
				H.time_until_decomposition -= clamp(2 SECONDS + temperature_modifier, 0, 6 SECONDS) * mult

			if(H.time_until_decomposition < 0)
				H.time_until_decomposition = rand(4 MINUTES, 10 MINUTES)
				if (suspend_rot)
					return ..()
				H.decomp_stage = min(H.decomp_stage + 1, DECOMP_STAGE_SKELETONIZED)
				owner.update_body()
				owner.update_face()
		..()

	proc/icky_icky_miasma(var/turf/T)
		var/mob/living/carbon/human/H = owner
		var/max_produce_miasma = H.decomp_stage * 20
		if (T.active_airborne_liquid && prob(90)) //sometimes just add anyway lol
			var/obj/fluid/F = T.active_airborne_liquid
			if (F.group && F.group.reagents && F.group.reagents.total_volume > max_produce_miasma)
				max_produce_miasma = 0

		if (max_produce_miasma)
			// Devera-class interdictor: prohibit miasma formation
			var/miasma_blocked = FALSE
			for_by_tcl(IX, /obj/machinery/interdictor)
				if (IX.expend_interdict(30,src,TRUE,ITDR_DEVERA))
					miasma_blocked = TRUE
					break

			if(!miasma_blocked)
				T.fluid_react_single("miasma", 3, airborne = 1)
