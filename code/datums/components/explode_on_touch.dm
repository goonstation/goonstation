/datum/component/explode_on_touch
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/explosion_size = 5
	var/gib = FALSE
	var/delete_self = TRUE
	var/remove_limbs = 0
	var/turf_safe_explosion = FALSE

TYPEINFO(/datum/component/explode_on_touch)
	initialization_args = list(
		ARG_INFO("explosion_size", "num", "Explosive force", 5),
		ARG_INFO("gib", "num", "If the mob that triggers should always gib (bool)", FALSE),
		ARG_INFO("delete_self", "num", "If should always delete self upon exploding (bool)", TRUE),
		ARG_INFO("remove_limbs", "num", "Number of limbs to remove", 0),
		ARG_INFO("turf_safe_explosion", "num", "If explosion should not breach (bool)", FALSE)
	)

/datum/component/explode_on_touch/Initialize(explosion_size=5, gib=FALSE, delete_self=TRUE, remove_limbs=0, turf_safe_explosion=FALSE)
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.explosion_size = explosion_size
	src.gib = gib
	src.delete_self = delete_self
	src.remove_limbs = remove_limbs
	src.turf_safe_explosion = turf_safe_explosion
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/do_the_boom)

/datum/component/explode_on_touch/proc/do_the_boom(atom/movable/thing, mob/user)
	boutput(user, "<span class='alert'>\The [thing] explodes.</span>")
	var/turf/T = get_turf(thing)
	if(!delete_self) // let's save ourselves from the boom
		thing.set_loc(null)
	if(explosion_size > 0)
		explosions.explode_at(thing, T, explosion_size, turf_safe=src.turf_safe_explosion)
	if(!delete_self)
		SPAWN_DBG(0.1 SECONDS)
			while(explosions.exploding)
				sleep(0.1 SECONDS)
			thing.set_loc(T)
	if(remove_limbs && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/list/limbs = list("r_arm", "l_arm", "l_leg", "r_leg")
		shuffle_list(limbs)
		for(var/i in 1 to remove_limbs)
			H.sever_limb(limbs[i])
	if(src.gib)
		user.gib()
	if(src.delete_self)
		qdel(thing)

/datum/component/explode_on_touch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKHAND)
	. = ..()
