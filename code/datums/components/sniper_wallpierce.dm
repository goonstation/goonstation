/datum/component/sniper_wallpierce
	var/pierces_left = 1 //default to 1 wall
	var/power_loss = 0 // bullet power lost on piercing a thing (lost on first pierce; further pierces do nothing to bullet power)
	var/pierced = FALSE //did our projectile already pierce something?

TYPEINFO(/datum/component/sniper_wallpierce)
	initialization_args = list(
		ARG_INFO("num_pierces", DATA_INPUT_NUM, "number of walls/etc to pierce", 1),
		ARG_INFO("damage_loss", DATA_INPUT_NUM, "power loss on piercing the first thing", 0)
	)
/datum/component/sniper_wallpierce/Initialize(var/num_pierces, var/power_loss)
	. = ..()
	if (!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if (num_pierces)
		src.pierces_left = num_pierces
	if (power_loss)
		src.power_loss = power_loss
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, .proc/update_pierces)

/datum/component/sniper_wallpierce/proc/update_pierces(var/obj/projectile/P, var/atom/hit)
	var/turf/T = get_turf(hit)
	if (isrestrictedz(T.z))
		return 0
	if (isrwall(hit) || istype(hit, /obj/machinery/door/poddoor/blast))
		pierces_left-- //cost an extra pierce for rwalls and blast doors
	if (!pierced)
		pierced = TRUE
		P.initial_power -= power_loss
	if (pierces_left-- > 0)
		return PROJ_PASSWALL | PROJ_PASSOBJ

/datum/component/sniper_wallpierce/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()
