#define NOT_CHARGED -1
#define LOSING_CHARGE 0
#define CHARGING 1
#define CHARGED 2
//
//Sentinel structure,
//
/obj/flock_structure/sentinel
	name = "Glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	icon_state = "sentinel"
	flock_id = "Sentinel"
	health = 80
	var/charge_status = NOT_CHARGED
	var/charge = 0 //0-100 charge percent
	var/powered = 0

	event_handler_flags = USE_CANPASS
	passthrough = 1 //drones can pass through this, might change this later, as balance point

	usesgroups = 1
	poweruse = 20//debug amount scale up if needed.

/obj/flock_structure/sentinel/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)
	src.filters = filter(type="rays", x=-0.2, y=6, size=1, color=rgb(255,255,255), offset=rand(1000), density=20, threshold=0.2, factor=1)
	var/f = src.filters[length(src.filters)]
	animate(f, size=((-(cos(180*(3/100))-1)/2)*32), time=5 MINUTES, easing=LINEAR_EASING, loop=-1, offset=f:offset + 100, flags=ANIMATION_PARALLEL)

/obj/flock_structure/sentinel/building_specific_info()
	return {"<span class='bold'>Status:</span> [charge_status == 1 ? "charging" : (charge_status == 2 ? "charged" : "idle")].
	<br><span class='bold'>Charge Percentage:</span> [charge]%."}

/obj/flock_structure/sentinel/process()
	updatefilter()

	if(!src.group)//if it dont exist it off
		powered = 0
	else if(src.group.powerbalance >= 0)//if it has atleast 0 or more free power, the poweruse is already calculated in the group
		powered = 1
	else//if there isnt enough juice
		powered = 0

	if(powered == 1)
		switch(charge_status)
			if(NOT_CHARGED)
				charge_status = CHARGING//begin charging as there is energy available
			if(LOSING_CHARGE)
				charge_status = CHARGING//if its losing charge and suddenly theres energy available begin charging
			if(CHARGING)
				if(icon_state != "sentinelon") icon_state = "sentinelon"//forgive me
				src.charge(5)
			if(CHARGED)
				var/mob/m = null
				var/list/hit = list()
				for(m in mobs)
					if(IN_RANGE(m, src, 5) && !isflock(m) && src.flock?.isEnemy(m) && isturf(m.loc))
						break//found target
				if(!m) return//if no target stop
				arcFlash(src, m, 10000)
				hit += m
				for(var/i in 1 to rand(5,6))
					for(var/mob/nearbymob in range(2, m))//todo: optimize(?) this.
						if(nearbymob != m && !isflock(nearbymob) && !(nearbymob in hit) && isturf(nearbymob.loc) && src.flock?.isEnemy(nearbymob))
							arcFlash(m, nearbymob, 10000)
							hit += nearbymob
							m = nearbymob
				hit.len = 0//clean up
				charge = 1
				var/filter = src.filters[length(src.filters)]//force the visual to power down
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
	var/filter = src.filters[length(src.filters)]
	if(charge > 2)//else it just makes the sprite invisible, due to floats. this is small enough that it doesnt even showup anyway since its under the sprite
		animate(filter, size=((-(cos(180*(charge/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)
	else
		animate(filter, size=((-(cos(180*(3/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)


#undef NOT_CHARGED
#undef LOSING_CHARGE
#undef CHARGING
#undef CHARGED