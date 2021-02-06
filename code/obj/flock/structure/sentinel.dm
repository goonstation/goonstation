//
//Sentinel structure,
//
/obj/flock_structure/sentinel
	name = "Glowing pylon"
	desc = "A glowing pylon of sorts, faint sparks are jumping inside of it."
	icon_state = "sentinel"
	flock_id = "Sentinel"
	health = 80
	var/charge_status = -1 //-1 == not charged,0 == losing charge, 1 == charging, 2 == charged
	var/charge = 0 //0-100 charge percent
	var/powered = 0
	passthrough = 1 //drones can pass through this, might change this later, as balance point
	usesgroups = 1
	poweruse = 20//debug amount scale up if needed.

/obj/flock_structure/sentinel/New(var/atom/location, var/datum/flock/F=null)
	..(location, F)
	src.filters = filter(type="rays", x=-0.2, y=6, size=1, color=rgb(255,255,255), offset=rand(1000), density=20, threshold=0.2, factor=1, flags=FILTER_UNDERLAY)
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
			if(-1)
				charge_status = 1//begin charging as there is energy available
			if(0)
				charge_status = 1//if its losing charge and suddenly theres energy available begin charging
			if(1)
				if(icon_state != "sentinelon") icon_state = "sentinelon"//forgive me
				src.charge(5)
			if(2)
				var/mob/m = null
				var/list/hit = list()
				for(m in mobs)
					if(IN_RANGE(m, src, 5) && !isflock(m) && isturf(m.loc) && src.flock?.isEnemy(m))
						break//found target
				if(!m) return//if no target stop
				var/chain = rand(5, 6)
				arcFlash(src, m, 10000)
				hit += m
				while(chain > 0)
					for(var/mob/nearbymob in range(2, m))//todo: optimize(?) this.
						if(nearbymob != m && !isflock(nearbymob) && !(nearbymob in hit) && isturf(nearbymob.loc) && src.flock?.isEnemy(nearbymob))
							arcFlash(m, nearbymob, 10000)
							hit += nearbymob
							m = nearbymob
						chain--//infinite loop prevention, wouldve been in the if statement otherwise.
				hit.len = 0//clean up
				charge = 1
				var/f = src.filters[length(src.filters)]//force the visual to power down
				animate(f, size=((-(cos(180*(3/100))-1)/2)*32), time=1 SECONDS, flags = ANIMATION_PARALLEL)
				charge_status = 1
				return
	else
		if(charge > 0)//if theres charge make it decrease with time
			src.charge_status = 0
			src.charge(-5)
		else
			if(icon_state != "sentinel") icon_state = "sentinel"//forgive me again
			src.charge_status = -1 //out of juice its dead

/obj/flock_structure/sentinel/proc/charge(var/chargeamount = 0)
	if(charge < 100)
		src.charge = min(chargeamount + charge, 100)
	else
		charge_status = 2


/obj/flock_structure/sentinel/proc/updatefilter()
	if(charge > 2)//else it just makes the sprite invisible, due to floats. this is small enough that it doesnt even showup anyway since its under the sprite
		var/f = src.filters[length(src.filters)]
		animate(f, size=((-(cos(180*(charge/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)
	else
		var/f = src.filters[length(src.filters)]
		animate(f, size=((-(cos(180*(3/100))-1)/2)*32), time=10 SECONDS, flags = ANIMATION_PARALLEL)