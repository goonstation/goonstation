
/datum/lifeprocess/decomposition

	//proc/handle_decomposition()
	process(var/datum/gas_mixture/environment)
		if (isdead(owner) && human_owner) //hey i know this only hanldes human right now but i predict we will want other mobs to decompose later on
			var/mob/living/carbon/human/H = owner
			var/turf/T = get_turf(owner)
			if (!T)
				return ..()

			if (H.loc == T && T.temp_flags & HAS_KUDZU) //only infect if on the floor
				H.infect_kudzu()

			var/suspend_rot = 0
			if (H.decomp_stage >= 4)
				suspend_rot = (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(owner.loc, /obj/morgue) || (owner.reagents && owner.reagents.has_reagent("formaldehyde")))
				if (!(suspend_rot || istype(owner.loc, /obj/item/body_bag) || (istype(owner.loc, /obj/storage) && owner.loc:welded)))
					icky_icky_miasma(T)
				return ..()

			if (H.mutantrace)
				return ..()
			suspend_rot = (istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell) || istype(owner.loc, /obj/morgue) || (owner.reagents && owner.reagents.has_reagent("formaldehyde")))
			var/env_temp = 0
			// cogwerks note: both the cryo cell and morgue things technically work, but the corpse rots instantly when removed
			// if it has been in there longer than the next decomp time that was initiated before the corpses went in. fuck!
			// will work out a fix for that soon, too tired right now

			// hello I fixed the thing by making it so that next_decomp_time is added to even if src is in a morgue/cryo or they have formaldehyde in them - haine
			if (!suspend_rot)
				env_temp = environment.temperature
				H.next_decomp_time -= min(30, max(round((env_temp - T20C)/10), -60))
				if(!(istype(owner.loc, /obj/item/body_bag) || (istype(owner.loc, /obj/storage) && owner.loc:welded)))
					icky_icky_miasma(T)

			if (world.time > H.next_decomp_time) // advances every 4-10 game minutes
				H.next_decomp_time = world.time + rand(240,600)*10
				if (suspend_rot)
					return ..()
				H.decomp_stage = min(H.decomp_stage + 1, 4)
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
			T.fluid_react_single("miasma", 10, airborne = 1)
