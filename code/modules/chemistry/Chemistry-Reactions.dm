/proc/ldmatter_reaction(var/datum/reagents/holder, var/created_volume, var/id)
	var/in_container = 0
	var/atom/psource = holder.my_atom
	if(created_volume < 3)
		return

	while (psource)
		psource = psource.loc
		if (istype(psource, /obj) && !isitem(psource) && (istype(psource, /obj/machinery/vehicle) || !istype(psource, /obj/machinery)) && !istype(psource, /obj/submachine))
			in_container = 1
			break

	var/list/covered = holder.covered_turf()
	if (!covered || !length(covered))
		covered = list(get_turf(holder.my_atom))

	if(length(covered))
		var/howmany = clamp(covered.len / 2.2, 1, 15)
		for(var/i = 0, i < howmany, i++)
			var/atom/source = pick(covered)
			if(ON_COOLDOWN(source, "ldm_reaction_ratelimit", 0.2 SECONDS))
				continue
			new/obj/decal/implo(source)
			playsound(source, 'sound/effects/suck.ogg', 100, 1)

			if (in_container)
				var/damage = clamp(created_volume * rand(8, 15) / 10, 1, 80)	// 0.8 to 1.5 damage per unit made
				for (var/mob/living/M in psource)
					logTheThing(LOG_COMBAT, M, "takes [damage] damage due to ldmatter implosion while inside [psource].")
					M.TakeDamage("All", damage, 0)
					boutput(M, "<span class='alert'>[psource] [created_volume >= 10 ? "crushes you as it implodes!" : "compresses around you tightly for a moment!"]</span>")

				if (created_volume >= 10)
					for (var/atom/movable/O in psource)
						O.set_loc(source)
					psource:visible_message("<span class='alert'>[psource] implodes!</span>")
					qdel(psource)
					return
			SPAWN(0)
				for(var/atom/movable/M in view(clamp(2+round(created_volume/15), 0, 4), source))
					if(M.anchored || M == source || M.throwing) continue
					var/datum/component/glue_ready/maybe_glue_ready_comp = M.GetComponent(/datum/component/glue_ready)
					if(maybe_glue_ready_comp)
						qdel(maybe_glue_ready_comp)
					M.throw_at(source, 20 + round(created_volume * 2), 1 + round(created_volume / 10))
					LAGCHECK(LAG_MED)
	if (holder)
		holder.del_reagent(id)

/proc/sorium_reaction(var/datum/reagents/holder, var/created_volume, var/id)
	. = 1
	if(created_volume < 3)
		return 0

	var/list/covered = holder.covered_turf()
	if (!covered || !length(covered))
		covered = list(get_turf(holder.my_atom))

	if(length(covered))
		var/howmany = clamp(covered.len / 2.2, 1, 15)
		for(var/i = 0, i < howmany, i++)
			var/atom/source = pick(covered)
			if(ON_COOLDOWN(source, "sorium_reaction_ratelimit", 0.2 SECONDS))
				continue
			new/obj/decal/shockwave(source)
			playsound(source, 'sound/weapons/flashbang.ogg', 25, 1)
			SPAWN(0)
				for(var/atom/movable/M in view(clamp(2+round(created_volume/15), 0, 4), source))
					if(M.anchored || M == source || M.throwing) continue
					var/datum/component/glue_ready/maybe_glue_ready_comp = M.GetComponent(/datum/component/glue_ready)
					if(maybe_glue_ready_comp)
						qdel(maybe_glue_ready_comp)
					M.throw_at(get_edge_cheap(source, get_dir(source, M)),  20 + round(created_volume * 2), 1 + round(created_volume / 10))
					LAGCHECK(LAG_MED)

	if (holder)
		holder.del_reagent(id)


/proc/smoke_reaction(var/datum/reagents/holder, var/smoke_size, var/turf/location, var/vox_smoke = 0, var/do_sfx = 1)
	var/block = 0

	if(QDELETED(holder))
		return 0

	if (holder.my_atom) //this happens with burning plants somehow
		var/atom/psource = holder.my_atom.loc
		while (psource)
			if (istype(psource, /obj/machinery/vehicle))
				block = 1
				break
			psource = psource.loc

	if (block)
		return 0

	var/og_smoke_size = smoke_size

	var/list/covered = holder?.covered_turf()
	if (!covered || !length(covered))
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

		purge_smoke_blacklist(holder)

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
			purge_smoke_blacklist(FG.reagents)

			if (FG.contained_amt > diminishing_returns_thingymabob)
				react_amount = react_amount / (1 + ((FG.contained_amt - diminishing_returns_thingymabob) * 0.1))//MBC MAGIC NUMBERS :)
				//boutput(world,"[react_amount]")

		var/divisor = length(covered)
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
	if (!covered || !length(covered))
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
	var/list/possible_hairstyles = concrete_typesof(/datum/customization_style) - concrete_typesof(/datum/customization_style/biological)
	if (!all_hairs)
		possible_hairstyles -= concrete_typesof(/datum/customization_style/hair/gimmick)
	var/hair_type = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_first = new hair_type
	H.bioHolder.mobAppearance.customization_first_color = random_saturated_hex_color()
	hair_type = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_second = new hair_type
	H.bioHolder.mobAppearance.customization_second_color = random_saturated_hex_color()
	hair_type = pick(possible_hairstyles)
	H.bioHolder.mobAppearance.customization_third = new hair_type
	H.bioHolder.mobAppearance.customization_third_color = random_saturated_hex_color()
	H.update_colorful_parts()
	boutput(H, "<span class='notice'>Your entire head feels extremely itchy!</span>")

/proc/omega_hairgrownium_drop_hair(var/mob/living/carbon/human/H)
	H.visible_message("<strong style='font-size: 170%;'>[H.name] hair fall out!!</strong>", "<strong style='font-size: 170%;'>you hair fall out!!</strong>")
	H.reagents.del_reagent("stable_omega_hairgrownium")
	H.reagents.del_reagent("unstable_omega_hairgrownium")
	var/obj/item/I = H.create_wig()
	I.set_loc(H.loc)
	H.bioHolder.mobAppearance.customization_first = new /datum/customization_style/none
	H.bioHolder.mobAppearance.customization_second = new /datum/customization_style/none
	H.bioHolder.mobAppearance.customization_third = new /datum/customization_style/none
	H.update_colorful_parts()

/proc/flashpowder_reaction(turf/center, amount)
	elecflash(center)
	amount = clamp(amount/5, 0, 5)


	for (var/mob/living/M in all_viewers(5, center))
		if (isintangible(M) || ON_COOLDOWN(M, "flashpowder_anti_spam", 6 SECONDS))
			continue

		var/anim_dur = issilicon(M) ? 30 : 60
		var/dist = GET_DIST(M, center)
		var/stunned = max(0, amount * (4 - dist) * 0.2)
		var/eye_damage = issilicon(M) ? 0 : max(0, amount * (2 - dist) * 0.2)
		var/eye_blurry = issilicon(M) ? 0 : max(0, amount * (5 - dist) * 0.2)
		var/stam_damage = 15 * amount

		M.apply_flash(anim_dur, stunned, stunned, 0, eye_blurry, eye_damage, stamina_damage = stam_damage)

/proc/sonicpowder_reaction(turf/center, amount, hootmode, no_fluff)
	amount = clamp(amount/5, 0, 5)
	if (no_fluff == 0)
		if (hootmode)
			playsound(center, 'sound/voice/animal/hoot.ogg', 100, 1)
		else
			playsound(center, 'sound/weapons/flashbang.ogg', 25, 1)

	for (var/mob/living/M in all_hearers(world.view, center))
		if (isintangible(M) )
			continue
		if (!M.ears_protected_from_sound() && !ON_COOLDOWN(M, "sonicpowder_anti_spam", 6 SECONDS))
			boutput(M, "<span class='alert'><b>[hootmode ? "HOOT" : "BANG"]</b></span>")
		else
			continue

		var/checkdist = GET_DIST(M, center)

		var/weak = max(0, amount * 0.2 * (3 - checkdist))
		var/misstep = max(0, 2 + amount * (5 - checkdist))
		var/ear_damage = max(0, amount * 0.2 * (3 - checkdist))
		var/ear_tempdeaf = max(0, amount * 0.2 * (5 - checkdist)) //annoying and unfun so reduced dramatically
		var/stamina = max(0, 2 * amount * (7 - checkdist))

		if (issilicon(M))
			M.apply_sonic_stun(weak, 0)
		else
			M.apply_sonic_stun(weak, 0, misstep, 0, 0, ear_damage, ear_tempdeaf, stamina)

/// Deletes any reagents that are banned in smoke clouds.
/proc/purge_smoke_blacklist(datum/reagents/FG)
	FG.del_reagent("pyrosium")
	FG.del_reagent("big_bang")
	FG.del_reagent("big_bang_precursor")
	FG.del_reagent("poor_concrete")
	FG.del_reagent("okay_concrete")
	FG.del_reagent("good_concrete")
	FG.del_reagent("perfect_concrete")
