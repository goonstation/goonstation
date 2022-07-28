//
/// # Sentinel structure,
//
#define NOT_CHARGED -1 //! The sentinel is without charge
#define LOSING_CHARGE 0 //! The sentinel is losing charge
#define CHARGING 1 //! The sentinel is gaining charge
#define CHARGED 2 //! The sentinel is charged
/obj/flock_structure/sentinel
	name = "glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	flock_desc = "A charged pylon, capable of sending disorienting arcs of electricity at enemies."
	icon_state = "sentinel"
	flock_id = "Sentinel"
	health = 80
	resourcecost = 150
	var/charge_status = NOT_CHARGED
	/// 0-100 charge percent
	var/charge = 0
	/// charge gained per tick
	var/charge_per_tick = 20
	/// Turret range in tiles
	var/range = 4
	/// The wattage of the arcflash
	var/wattage = 6000
	var/powered = FALSE


	// flockdrones can pass through this
	passthrough = TRUE

	var/online_compute_cost = 20
	compute = 0 //targetting consumes compute

	var/obj/effect/flock_sentinelrays/rays = null

/obj/flock_structure/sentinel/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)
	src.rays = new /obj/effect/flock_sentinelrays
	src.vis_contents += rays

/obj/flock_structure/sentinel/disposing()
	qdel(src.rays)
	..()


/obj/flock_structure/sentinel/building_specific_info()
	return {"<span class='bold'>Status:</span> [charge_status == 1 ? "charging" : (charge_status == 2 ? "charged" : "idle")].
	<br><span class='bold'>Charge Percentage:</span> [charge]%."}

/obj/flock_structure/sentinel/process(mult)
	updatefilter()

	if(!src.flock)//if it dont exist it off
		if (powered)
			src.update_flock_compute("remove")
		src.compute = 0
		powered = FALSE
	else if(src.flock.can_afford_compute(online_compute_cost))//if it has atleast 0 or more free compute, the poweruse is already calculated in the group
		src.compute = -online_compute_cost
		if (!powered)
			src.update_flock_compute("apply")
			powered = TRUE
	else if (src.flock.used_compute > src.flock.total_compute() || !src.powered)//if there isnt enough juice
		if (powered)
			src.update_flock_compute("remove")
		src.compute = 0
		powered = FALSE

	if(powered == 1)
		switch(charge_status)
			if(NOT_CHARGED)
				charge_status = CHARGING//begin charging as there is energy available
			if(LOSING_CHARGE)
				charge_status = CHARGING//if its losing charge and suddenly theres energy available begin charging
			if(CHARGING)
				if(icon_state != "sentinelon") icon_state = "sentinelon"//forgive me
				src.charge(charge_per_tick * mult)
			if(CHARGED)
				var/mob/loopmob = null
				var/list/hit = list()
				var/mob/mobtohit = null
				for(loopmob in view(src.range,src))
					if(!isflockmob(loopmob) && src.flock?.isEnemy(loopmob) && isturf(loopmob.loc) && isalive(loopmob) && !isintangible(loopmob))
						mobtohit = loopmob
						break//found target
				if(!mobtohit) return//if no target stop
				arcFlash(src, mobtohit, wattage, 1.1)
				hit += mobtohit
				for(var/i in 1 to rand(5,6))//this facilitates chaining. legally distinct from the loop above
					for(var/mob/nearbymob in view(2, mobtohit.loc))
						if(nearbymob != mobtohit && !isflockmob(nearbymob) && !(nearbymob in hit) && isturf(nearbymob.loc) && src.flock?.isEnemy(nearbymob) && isalive(loopmob) && !isintangible(loopmob))
							arcFlash(mobtohit, nearbymob, wattage/1.5, 1.1)
							hit += nearbymob
							mobtohit = nearbymob
				hit.len = 0//clean up
				charge = 1
				var/filter = src.rays.get_filter("flock_sentinel_rays")
				animate(filter, size=((-(cos(180*(3/100))-1)/2)*32), time=1 SECONDS, flags = ANIMATION_PARALLEL)
				charge_status = CHARGING
				return
	else
		if(charge > 0)//if theres charge make it decrease with time
			src.charge_status = LOSING_CHARGE
			src.charge(-5)
		else
			if(icon_state != "sentinel") icon_state = "sentinel"//forgive me again
			src.charge_status = NOT_CHARGED //out of juice its dead

/obj/flock_structure/sentinel/proc/charge(var/chargeamount = 0)
	if(charge < 100)
		src.charge = min(chargeamount + charge, 100)
	else
		charge_status = CHARGED


/obj/flock_structure/sentinel/proc/updatefilter()
	var/filter = rays.get_filter("flock_sentinel_rays")
	if(charge > 2)//else it just makes the sprite invisible, due to floats. this is small enough that it doesnt even showup anyway since its under the sprite
		animate(filter, size=((-(cos(180*(charge/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)
	else
		animate(filter, size=((-(cos(180*(3/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)

/obj/effect/flock_sentinelrays
	mouse_opacity = 0
	plane = PLANE_NOSHADOW_BELOW
	blend_mode = BLEND_ADD

	New()
		src.add_filter("flock_sentinel_rays", 0, rays_filter(x=-0.2, y=6, size=1, color=rgb(255,255,255), offset=rand(1000), density=20, threshold=0.2, factor=1))
		var/f = src.get_filter("flock_sentinel_rays")
		animate(f, size=((-(cos(180*(3/100))-1)/2)*32), time=5 MINUTES, easing=LINEAR_EASING, loop=-1, offset=f:offset + 100, flags=ANIMATION_PARALLEL)
		..()

#undef NOT_CHARGED
#undef LOSING_CHARGE
#undef CHARGING
#undef CHARGED
