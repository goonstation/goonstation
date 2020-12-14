/proc/ldmatter_reaction(var/datum/reagents/holder, var/created_volume, var/id)
	var/in_container = 0
	var/atom/psource = holder.my_atom
	while (psource)
		psource = psource.loc
		if (istype(psource, /obj) && !isitem(psource) && (istype(psource, /obj/machinery/vehicle) || !istype(psource, /obj/machinery)) && !istype(psource, /obj/submachine))
			in_container = 1
			break

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 2.2)
	for(var/i = 0, i < howmany, i++)
		var/atom/source = pick(covered)
		new/obj/decal/implo(source)
		playsound(source, 'sound/effects/suck.ogg', 100, 1)

		if (in_container)
			var/damage = clamp(created_volume * rand(8, 15) / 10, 1, 80)	// 0.8 to 1.5 damage per unit made
			for (var/mob/living/M in psource)
				logTheThing("combat", M, null, "takes [damage] damage due to ldmatter implosion while inside [psource].")
				M.TakeDamage("All", damage, 0)
				boutput(M, "<span class='alert'>[psource] [created_volume >= 10 ? "crushes you as it implodes!" : "compresses around you tightly for a moment!"]</span>")

			if (created_volume >= 10)
				for (var/atom/movable/O in psource)
					O.set_loc(source)
				psource:visible_message("<span class='alert'>[psource] implodes!</span>")
				qdel(psource)
				return

		for(var/atom/movable/M in view(3 + (created_volume > 30 ? 1:0), source))
			if(M.anchored || M == source || M.throwing) continue
			M.throw_at(source, 20 + round(created_volume * 2), 1 + round(created_volume / 10))
			LAGCHECK(LAG_MED)
	if (holder)
		holder.del_reagent(id)

/proc/smoke_reaction(var/datum/reagents/holder, var/smoke_size, var/turf/location, var/vox_smoke = 0, var/do_sfx = 1)
	var/block = 0
	if (holder.my_atom)
		var/atom/psource = holder.my_atom.loc
		while (psource)
			if (istype(psource, /obj/machinery/vehicle))
				block = 1
				break
			psource = psource.loc

	if (block)
		return 0

	var/og_smoke_size = smoke_size

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 4)
	for(var/i = 0, i < howmany, i++)
		var/turf/source = 0
		if (location)
			source = location
		else
			source = pick(covered)

		if (!source)
			continue

		if (do_sfx)
			if (narrator_mode || vox_smoke)
				playsound(location, 'sound/vox/smoke.ogg', 50, 1, -3)
			else
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)

		//particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(source, holder, 20, smoke_size))

		var/prev_group_exists = 0
		var/diminishing_returns_thingymabob = 1000//MBC MAGIC NUMBERS :)

		var/react_amount = holder.total_volume
		if (source.active_airborne_liquid && source.active_airborne_liquid.group)
			prev_group_exists = 1
			var/datum/fluid_group/FG = source.active_airborne_liquid.group

			if (FG.contained_amt > diminishing_returns_thingymabob)
				react_amount = react_amount / (1 + ((FG.contained_amt - diminishing_returns_thingymabob) * 0.1))//MBC MAGIC NUMBERS :)
				//boutput(world,"[react_amount]")

		var/divisor = covered.len
		if (covered.len > 4)
			divisor += 0.2
		source.fluid_react(holder, react_amount/divisor, airborne = 1)

		if (!prev_group_exists && source.active_airborne_liquid && source.active_airborne_liquid.group)
			var/datum/fluid_group/FG = source.active_airborne_liquid.group
			while (smoke_size >= 0)
				FG.update_once(og_smoke_size * og_smoke_size)
				smoke_size--

	holder.clear_reagents()



/proc/classic_smoke_reaction(var/datum/reagents/holder, var/smoke_size, var/turf/location, var/vox_smoke = 0)
	var/block = 0
	if (holder.my_atom)
		var/atom/psource = holder.my_atom.loc
		while (psource)
			if (istype(psource, /obj/machinery/vehicle))
				block = 1
				break
			psource = psource.loc

	if (block)
		return 0

	if (narrator_mode || vox_smoke)
		playsound(location, 'sound/vox/smoke.ogg', 50, 1, -3)
	else
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)

	var/list/covered = holder.covered_turf()
	if (!covered || !covered.len)
		covered = list(get_turf(holder.my_atom))

	var/howmany = max(1,covered.len / 5)

	var/turf/source = 0

	for(var/i = 0, i < howmany, i++)
		if (location)
			source = location
		else
			source = pick(covered)
		particleMaster.SpawnSystem(new /datum/particleSystem/chemSmoke(source, holder, 20, smoke_size / howmany))


/proc/omega_hairgrownium_grow_hair(var/mob/living/carbon/human/H, var/all_hairs)
	var/list/possible_hairstyles
	if (all_hairs == 1)
		possible_hairstyles = customization_styles + customization_styles_gimmick
	else
		possible_hairstyles = customization_styles_gimmick
	H.bioHolder.mobAppearance.customization_first = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_first_color = random_saturated_hex_color()
	H.bioHolder.mobAppearance.customization_second = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_second_color = random_saturated_hex_color()
	H.bioHolder.mobAppearance.customization_third = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_third_color = random_saturated_hex_color()
	H.update_colorful_parts()
	boutput(H, "<span class='notice'>Your entire head feels extremely itchy!</span>")

/proc/omega_hairgrownium_drop_hair(var/mob/living/carbon/human/H)
	H.visible_message("<strong style='font-size: 170%;'>[H.name] hair fall out!!</strong>", "<strong style='font-size: 170%;'>you hair fall out!!</strong>")
	H.reagents.del_reagent("stable_omega_hairgrownium")
	H.reagents.del_reagent("unstable_omega_hairgrownium")
	var/obj/item/I = H.create_wig()
	I.set_loc(H.loc)
	H.bioHolder.mobAppearance.customization_first = "None"
	H.cust_one_state = customization_styles["None"]
	H.bioHolder.mobAppearance.customization_second = "None"
	H.cust_two_state = customization_styles["None"]
	H.bioHolder.mobAppearance.customization_third = "None"
	H.cust_three_state = customization_styles["None"]
	H.update_colorful_parts()
