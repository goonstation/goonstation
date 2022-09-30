/datum/component/holdertargeting/baseball_bat_reflect
	dupe_mode = COMPONENT_DUPE_ALLOWED
	signals = list(COMSIG_ATOM_HITBY_THROWN)
	proctype = .proc/reflect

TYPEINFO(/datum/component/holdertargeting/baseball_bat_reflect)
	initialization_args = list()

/datum/component/holdertargeting/baseball_bat_reflect/proc/reflect(mob/owner, atom/movable/thing, datum/thrown_thing/thr)
	var/homerun = prob(1)
	var/generator/gen = generator("num", -1, 1, NORMAL_RAND)

	var/angle = -arctan(thr.dist_x, thr.dist_y) // opposite direction
	var/angle_deviation_max = 70
	if(owner.traitHolder?.hasTrait("athletic"))
		angle_deviation_max /= 2
	var/drunkenness = owner.reagents.get_reagent_amount("ethanol")
	if(drunkenness <= 15)
		angle_deviation_max -= drunkenness * 2
	else if(drunkenness <= 20)
		angle_deviation_max -= (20 - drunkenness) * 3 * 2
	else
		angle_deviation_max *= 2
	if(owner.bioHolder?.HasEffect("blind"))
		angle_deviation_max *= 20
	angle_deviation_max += owner.eye_blurry + owner.eye_damage

	angle += gen.Rand() * angle_deviation_max // deviation from the base direction

	var/turf/T = null
	var/turf_search_dist = 64
	var/turf/origin = get_turf(owner)
	while(isnull(T) && turf_search_dist >= 0)
		T = locate(
			round(origin.x + cos(angle) * turf_search_dist),
			round(origin.y + sin(angle) * turf_search_dist),
			origin.z
		)
		turf_search_dist -= 4
	if(isnull(T))
		return

	SPAWN(0)
		thing.throw_at( \
			T,
			round(12 + gen.Rand() * 4),
			thr.speed + (homerun ? 6 : 1) + gen.Rand() * 2,
			bonus_throwforce = homerun ? 10 : 0
		)

	if(!ON_COOLDOWN(owner, "baseball-bat-reflect-sound-spam", 1 DECI SECOND))
		playsound(owner, 'sound/items/woodbat.ogg', 50, 1)
		if(homerun)
			playsound(owner, 'sound/items/batcheer.ogg', 50, 1)
			owner.visible_message("<span class='alert'>[owner] hits \the [thing] with \the [src.parent] and scores a HOMERUN! Woah!!!!</span>")
		else
			owner.visible_message("<span class='alert'>[owner] hits \the [thing] with \the [src.parent]!</span>")

	return TRUE
