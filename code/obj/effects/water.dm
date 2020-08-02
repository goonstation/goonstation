/obj/effects/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15.0
	flags = TABLEPASS
	mouse_opacity = 0

/obj/effects/water/pooled(var/poolname)
	 life = initial(life)
	 ..()

/obj/effects/water/Move(turf/newloc)
	//var/turf/T = src.loc
	//if (istype(T, /turf))
	//	T.firelevel = 0 //TODO: FIX
	if (--src.life < 1)
		//SN src = null
		if (!disposed)
			pool(src)
		return 0
	if(newloc.density)
		if (!disposed)
			pool(src)
		return 0
	.=..()

/obj/effects/water/proc/spray_at(var/turf/target, var/datum/reagents/R, var/try_connect_fluid = 0)
	if (!target || !R)
		pool(src)
		return

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
			R.reaction(atm,TOUCH,1)
		R.remove_any(1)

		sleep(0.2 SECONDS)

		if (try_connect_fluid && T && T.active_liquid)
			T.active_liquid.try_connect_to_adjacent()

		if(src.loc == target)
			break

		if (disposed)
			break

	if (!disposed)
		pool(src)
