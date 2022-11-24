//
/// # Gnesis Turret - Shoots syringes full of coagulated gnesis at poor staffies
//
// A vat that slowly generates gnesis over time,
/obj/flock_structure/gnesisturret
	name = "spiky fluid vat"
	desc = "A vat of bubbling teal fluid, covered in hollow spikes."
	flock_desc = "A turret that fires gnesis-filled spikes at enemies, beginning their conversion to Flockbits."
	icon_state = "teleblocker-off"
	flock_id = "Gnesis turret"
	resourcecost = 150
	health = 80
	///maximum volume of coagualted gnesis that can be stored in the tank
	var/fluid_level_max = 250
	///how much gnesis is generated per-tick while there is sufficient compute
	var/fluid_gen_amt = 5
	///gnesis fluid ID - change this to do exciting things like having a turret that fires QGP
	var/fluid_gen_type = "flockdrone_fluid"
	//internals for turret targetting and accuracy
	var/target = null
	var/range = 8
	var/spread = 10
	var/datum/projectile/syringe/syringe_barbed/gnesis/current_projectile = null

	var/powered = FALSE
	// flockdrones can pass through this
	passthrough = TRUE
	accepts_sapper_power = TRUE

	var/making_projectiles = FALSE
	var/fluid_gen_cost = 30 //generating gnesis consumes compute
	var/base_compute = 20
	compute = 0

	New(var/atom/location, var/datum/flock/F=null)
		..(location, F)
		ensure_reagent_holder()
		src.current_projectile = new /datum/projectile/syringe/syringe_barbed/gnesis(src)
		src.current_projectile.shot_number = 4
		src.info_tag.set_info_tag("Gnesis: [src.reagents.total_volume]/[src.fluid_level_max]")


	proc/ensure_reagent_holder()
		if (!src.reagents)
			var/datum/reagents/R = new /datum/reagents(src.fluid_level_max)
			src.reagents = R
			R.my_atom = src

	building_specific_info()
		var/status = "" //this was gonna be a stack of inline conditions, but it's completely unreadable, so if chain instead
		if(!powered)
			status = "offline"
		else if (src.reagents.total_volume < fluid_level_max)
			if (src.making_projectiles)
				status =  "replicating"
			else
				status =  "insufficient compute for replication"
		else
			status = "idle"

		return {"<span class='bold'>Status:</span> [status].
	<br><span class='bold'>Gnesis Tank Level:</span> [src.reagents.total_volume]/[fluid_level_max]."}

	process(mult)
		if(!src.flock)//if it dont exist it off
			if (powered)
				src.making_projectiles = FALSE
				src.update_flock_compute("remove")
			src.compute = 0
			powered = FALSE
			src.icon_state = "teleblocker-off"
			return

		if(src.flock.can_afford_compute(base_compute))
			src.compute = !src.making_projectiles ? -base_compute : -(base_compute + fluid_gen_cost)
			if (!powered)
				src.update_flock_compute("apply")
				powered = TRUE
			src.icon_state = "teleblocker-on"
		else if (src.flock.used_compute > src.flock.total_compute() || !src.powered)//if there isnt enough juice
			if (src.making_projectiles)
				src.making_projectiles = FALSE
				src.update_flock_compute("remove", FALSE)
				src.compute = -base_compute
				src.update_flock_compute("apply")
			if (src.flock.used_compute > src.flock.total_compute() || !src.powered)
				if (powered)
					src.update_flock_compute("remove")
				src.compute = 0
				powered = FALSE
				src.icon_state = "teleblocker-off"
				return

		//if we need to generate more juice, do so and up the compute cost appropriately
		if(src.reagents.total_volume < src.reagents.maximum_volume)
			if(src.flock.can_afford_compute(fluid_gen_cost) && !src.making_projectiles)
				src.making_projectiles = TRUE
				src.update_flock_compute("remove", FALSE)
				src.compute = -(base_compute + fluid_gen_cost)
				src.update_flock_compute("apply")
			if (src.making_projectiles)
				src.reagents.add_reagent(fluid_gen_type, fluid_gen_amt * mult)
				src.info_tag.set_info_tag("Gnesis: [src.reagents.total_volume]/[src.fluid_level_max]")
		else if (src.making_projectiles)
			src.making_projectiles = FALSE
			src.update_flock_compute("remove", FALSE)
			src.compute = -base_compute
			src.update_flock_compute("apply")

		if(src.reagents.total_volume >= src.current_projectile.cost*src.current_projectile.shot_number)
			//shamelessly stolen from deployable_turret.dm
			if(!src.target && !src.seek_target()) //attempt to set the target if no target
				return
			if(!src.target_valid(src.target)) //check valid target
				src.target = null
				return
			else //GUN THEM DOWN
				if(src.target)
					logTheThing(LOG_COMBAT, src, "Flock gnesis turret at [log_loc(src)] belonging to flock [src.flock?.name] fires at [constructTarget(src.target)].")
					SPAWN(0)
						for(var/i in 1 to src.current_projectile.shot_number) //loop animation until finished
							muzzle_flash_any(src, get_angle(src, src.target), "muzzle_flash")
							sleep(src.current_projectile.shot_delay)
					shoot_projectile_ST_pixel_spread(src, current_projectile, target, 0, 0 , spread)

	sapper_power()
		if (!src.powered || !..())
			return FALSE
		src.accepts_sapper_power = FALSE
		src.fluid_gen_amt *= 4
		SPAWN(10 SECONDS)
			if (!QDELETED(src))
				src.accepts_sapper_power = TRUE
				src.fluid_gen_amt = initial(src.fluid_gen_amt)
		return TRUE

	proc/seek_target()
		var/list/target_list = list()
		for (var/mob/living/C in oviewers(src.range,src.loc))
			if (!isnull(C) && src.target_valid(C))
				target_list += C
				var/distance = GET_DIST(C.loc,src.loc)
				target_list[C] = distance

		if (length(target_list)>0)
			var/min_score = 99999 //lower score = better target
			var/target_score = 0
			for (var/mob/living/T in target_list)
				target_score = ((target_list[T]/src.range)*300) + T.reagents.get_reagent_amount(fluid_gen_type)
				if (target_score < min_score)
					src.target = T
					min_score = target_score

			playsound(src.loc, 'sound/misc/flockmind/flockdrone_door.ogg', 40, 1, pitch=0.5)

		return src.target

	proc/target_valid(var/mob/living/C)
		var/distance = GET_DIST(get_turf(C),get_turf(src))

		if(distance > src.range)
			return FALSE
		if (!C)
			return FALSE
		if(!isliving(C) || isintangible(C))
			return FALSE
		if (C.health < 0)
			return FALSE
		if (C.stat == 2)
			return FALSE
		if (!src.flock.isEnemy(C))
			return FALSE
		if (istype(C.loc,/obj/flock_structure/cage)) //already caged, stop shooting
			return FALSE
		if (istype(C,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if (H.hasStatus(list("resting", "weakened", "stunned", "paralysis"))) // stops it from uselessly firing at people who are already suppressed. It's meant to be a suppression weapon!
				return FALSE
			if (H.reagents.has_reagent(fluid_gen_type,300)) //don't keep shooting at people who are already flocked
				return FALSE
		if (isflockmob(C))
			return FALSE

		return TRUE


/datum/projectile/syringe/syringe_barbed/gnesis
	name = "nanite spike"
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "stunbolt"
	cost = 10 //how much gnesis you get per-shot
	implanted = /obj/item/implant/projectile/body_visible/syringe/syringe_barbed/gnesis_nanites

	var/obj/flock_structure/gnesisturret/parentTurret = null

	New(var/obj/flock_structure/gnesisturret/gt)
		. = ..()
		src.parentTurret = gt

	on_launch(obj/projectile/O)
		. = ..()
		parentTurret.reagents.trans_to(O,src.cost)
		parentTurret.info_tag.set_info_tag("Gnesis: [parentTurret.reagents.total_volume]/[parentTurret.fluid_level_max]")

/obj/item/implant/projectile/body_visible/syringe/syringe_barbed/gnesis_nanites
	name = "barbed crystalline spike"
	desc = "A hollow teal crystal, like some sort of weird alien syringe. It has a barbed tip. Nasty!"
	New()
		. = ..()
		src.material = getMaterial("gnesis")

	on_life(mult)
		. = ..()
		if(src.reagents?.total_volume == 0)
			if(!ON_COOLDOWN(src.owner, "gnesis_barb_spam", 5 SECONDS))
				src.owner.visible_message("\The [src] dissolves into [src.owner]'s skin!", "\The [src] dissolves into your skin!")
			src.on_remove(src.loc)
			qdel(src)
