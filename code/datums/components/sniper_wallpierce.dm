/datum/component/sniper_wallpierce
	var/pierces_left = 1 //default to 1 wall

/datum/component/sniper_wallpierce/Initialize(var/num_pierces)
	if(!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if(num_pierces)
		src.pierces_left=num_pierces
	RegisterSignal(parent, list(COMSIG_PROJ_COLLIDE), .proc/update_pierces)

/datum/component/sniper_wallpierce/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if(isrestrictedz(T.z))
		return 0
	if(isrwall(hit) || istype(hit, /obj/machinery/door/poddoor/blast))
		pierces_left-- //cost an extra pierce for rwalls and blast doors
	if(pierces_left-- > 0)
		return PROJ_PASSWALL | PROJ_PASSOBJ

/datum/component/sniper_wallpierce/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PROJ_COLLIDE)
	. = ..()
