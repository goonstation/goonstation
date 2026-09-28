/datum/component/proj_mining
	var/power_ratio = 1
	var/power_loss = 0
	var/mining_type = 0

TYPEINFO(/datum/component/proj_mining)
	initialization_args = list(
		ARG_INFO("power_ratio", DATA_INPUT_NUM, "conversion between projectile power to mining power", 1),
		ARG_INFO("power_loss", DATA_INPUT_NUM, "power loss per asteroid tile mined", 0),
		ARG_INFO("mining_type", DATA_INPUT_NUM, "what type of mining is being performed", 0)
	)
/datum/component/proj_mining/Initialize(var/power_ratio, var/power_loss, var/mining_type)
	. = ..()
	if (!istype(parent, /obj/projectile))
		return COMPONENT_INCOMPATIBLE
	if (power_ratio)
		src.power_ratio = power_ratio
	if (power_loss)
		src.power_loss = power_loss
	if (mining_type)
		src.mining_type = mining_type
	RegisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE, PROC_REF(mine))

/datum/component/proj_mining/proc/mine(var/obj/projectile/P, var/atom/hit)
	if(istype(hit, /turf/simulated/wall/auto/asteroid))
		var/turf/simulated/wall/auto/asteroid/T = hit
		if(P.power <= 0)
			return 0
		T.damage_asteroid(P.power * power_ratio, src.mining_type)
		P.initial_power -= power_loss
		if (!T.density)
			return PROJ_PASSWALL

/datum/component/proj_door_breach/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_OBJ_PROJ_COLLIDE)
	. = ..()

