/obj/effects/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15
	var/mob/owner
	flags = TABLEPASS
	mouse_opacity = 0

/obj/effects/water/disposing()
	owner = null
	..()

/obj/effects/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if (--src.life < 1)
		if (!disposed)
			qdel(src)
		return 0
	if(newloc.density)
		if (!disposed)
			qdel(src)
		return 0
	.=..()

/obj/effects/water/proc/spray_at(var/turf/target, var/datum/reagents/R, var/try_connect_fluid = 0)
	if (!target || !R)
		qdel(src)
		return
	SPAWN(0)
		var/turf/T
		for(var/b=0, b<5, b++)
			step_towards(src,target)
			T = get_turf(src)
			if(!R || !R.total_volume)
				break
			R.reaction(T,TOUCH,1)
			if (!R || !R.total_volume) //i guess they can get removed after the first reaction
				break
			for(var/atom/atm in T)
				if(isliving(atm) && src.owner && (R.total_temperature != T20C || R.get_reagent_amount("ff-foam") != R.total_volume))
					logTheThing(LOG_COMBAT, atm, "is hit by water spray [log_reagents(R)] from [owner] at [log_loc(atm)].")
					logTheThing(LOG_COMBAT, owner, "hits [constructTarget(atm,"combat")], with extinguisher spray [log_reagents(R)] at [log_loc(atm)]")

				R.reaction(atm,TOUCH,1)
			R.remove_any(1)

			sleep(0.2 SECONDS)

			if (try_connect_fluid && T?.active_liquid)
				T.active_liquid.try_connect_to_adjacent()

			if(src.loc == target)
				break

			if (disposed)
				break

		if (!disposed)
			qdel(src)
