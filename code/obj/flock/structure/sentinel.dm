//
// Sentinel structure
//
#define NOT_CHARGED -1 //! The sentinel is without charge
#define LOSING_CHARGE 0 //! The sentinel is losing charge
#define CHARGING 1 //! The sentinel is gaining charge
#define CHARGED 2 //! The sentinel is charged
/obj/flock_structure/sentinel
	name = "glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	flock_desc = "A charged pylon, capable of sending disorienting arcs of electricity at enemies. Consumes 20 compute."
	icon_state = "sentinel"
	flock_id = "Sentinel"
	health = 80
	resourcecost = 150
	show_in_tutorial = TRUE
	var/charge_status = NOT_CHARGED
	/// 0-100 charge percent
	var/charge = 0
	/// charge gained per tick
	var/charge_per_tick = 20
	/// Turret range in tiles
	var/range = 4
	/// The wattage of the arcflash
	var/wattage = 5000
	/// has extra range when chaining
	var/extra_chain_range = FALSE
	var/chain_targets = 2
	var/powered = FALSE

	passthrough = TRUE

	accepts_sapper_power = TRUE

	var/online_compute_cost = 20
	compute = 0 //targetting consumes compute

	var/obj/effect/flock_sentinelrays/rays = null

/obj/flock_structure/sentinel/New(atom/location, datum/flock/F = null)
	..(location, F)
	src.rays = new /obj/effect/flock_sentinelrays
	src.vis_contents += src.rays
	src.info_tag.set_info_tag("Charge: [src.charge]%")

/obj/flock_structure/sentinel/disposing()
	qdel(src.rays)
	src.rays = null
	..()

/obj/flock_structure/sentinel/building_specific_info()
	var/charge_message
	switch (src.charge_status)
		if (NOT_CHARGED)
			charge_message = "Idle"
		if (LOSING_CHARGE)
			charge_message = "Losing charge"
		if (CHARGING)
			charge_message = "Charging"
		if (CHARGED)
			charge_message = "Charged"
	return {"<span class='bold'>Status:</span> [charge_message].
		<br><span class='bold'>Charge Percentage:</span> [src.charge]%."}

/obj/flock_structure/sentinel/process(mult)
	if(!src.flock)
		if (src.powered)
			src.update_flock_compute("remove")
		src.compute = 0
		src.powered = FALSE
	else if(src.flock.can_afford_compute(src.online_compute_cost))
		src.compute = -src.online_compute_cost
		if (!src.powered)
			src.update_flock_compute("apply")
			src.powered = TRUE
	else if (src.flock.used_compute > src.flock.total_compute() || !src.powered)
		if (src.powered)
			src.update_flock_compute("remove")
		src.compute = 0
		src.powered = FALSE

	if(src.powered)
		if (src.charge_status != CHARGED)
			src.icon_state = "sentinelon"
			src.charge(src.charge_per_tick * mult)
			src.charge_status = CHARGING
		if (src.charge == 100)
			src.charge_status = CHARGED
			if (!length(src.flock?.enemies))
				src.updatefilter()
				return
			var/atom/to_hit
			var/list/hit = list()
			for(var/atom/A as anything in view(src.range, src))
				if(src.flock?.isEnemy(A))
					if (ismob(A))
						var/mob/M = A
						if (isdead(M) || is_incapacitated(M))
							continue
					if (ON_COOLDOWN(A, "sentinel_shock", 2 SECONDS))
						continue
					to_hit = A
					break
			if(!to_hit)
				src.updatefilter()
				return
			arcFlash(src, to_hit, wattage, 0.9)
			logTheThing(LOG_COMBAT, src, "Flock sentinel at [log_loc(src)] belonging to flock [src.flock?.name] fires an arcflash at [constructTarget(to_hit)].")
			hit += to_hit

			var/atom/last_hit = to_hit
			var/found_chain_target
			for(var/i in 1 to src.chain_targets) // chaining
				found_chain_target = FALSE
				for(var/atom/A as anything in view(2 + (src.extra_chain_range ? 1 : 0), last_hit.loc))
					if(src.flock?.isEnemy(A) && !(A in hit))
						if (ismob(A))
							var/mob/M = A
							if (isdead(M) || is_incapacitated(M))
								continue
						found_chain_target = TRUE
						arcFlash(last_hit, A, wattage / 1.5, 0.8)
						logTheThing(LOG_COMBAT, src, "Flock sentinel at [log_loc(src)] belonging to [src.flock?.name] hits [constructTarget(A)] with a chained arcflash.")
						hit += A
						last_hit = A
						break
				if (!found_chain_target)
					break
			src.charge = 0
			src.charge_status = CHARGING
	else
		if(src.charge > 0)
			src.charge(-5 * mult)
			src.charge_status = LOSING_CHARGE
		if (src.charge <= 0)
			src.icon_state = "sentinel"
			src.charge_status = NOT_CHARGED

	src.updatefilter()

/obj/flock_structure/sentinel/proc/charge(chargeamount)
	src.charge = clamp(src.charge + chargeamount, 0, 100)
	src.info_tag.set_info_tag("Charge: [src.charge]%")

/obj/flock_structure/sentinel/sapper_power()
	if (!src.powered || !..())
		return FALSE
	src.accepts_sapper_power = FALSE
	src.extra_chain_range = TRUE
	src.chain_targets = 3
	SPAWN(10 SECONDS)
		if (!QDELETED(src))
			src.chain_targets = initial(src.chain_targets)
			src.accepts_sapper_power = TRUE
			src.extra_chain_range = FALSE
	return TRUE

/obj/flock_structure/sentinel/proc/updatefilter()
	var/dm_filter/filter = src.rays.get_filter("flock_sentinel_rays")
	// for non-linear scaling of size, using an oscillating value from 0 to 1 * 32
	UNLINT(animate(filter, size = ((-(cos(180 * (charge / 100)) - 1) / 2) * 32), flags = ANIMATION_PARALLEL))

/obj/effect/flock_sentinelrays
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_BELOW
	blend_mode = BLEND_ADD

	New()
		src.add_filter("flock_sentinel_rays", 0, rays_filter(x = -0.2, y = 6, size = 1, color = rgb(255,255,255), offset = rand(1000), density = 20, threshold = 0.2, factor = 1))
		var/dm_filter/filter = src.get_filter("flock_sentinel_rays")
		UNLINT(animate(filter, size = 0, time = 5 MINUTES, loop = -1, offset = filter.offset + 100))
		..()

#undef NOT_CHARGED
#undef LOSING_CHARGE
#undef CHARGING
#undef CHARGED
