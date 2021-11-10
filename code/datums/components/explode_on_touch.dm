/datum/component/explode_on_touch
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/explosion_size = 5
	var/gib = FALSE
	var/delete_self = TRUE
	var/remove_limbs = 0

/datum/component/explode_on_touch/Initialize(explosion_size=5, gib=FALSE, delete_self=TRUE, remove_limbs=0)
	if(!istype(parent, /atom/movable))
		return COMPONENT_INCOMPATIBLE
	src.explosion_size = explosion_size
	src.gib = gib
	src.delete_self = delete_self
	src.remove_limbs = remove_limbs
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/do_the_boom)

/datum/component/explode_on_touch/proc/do_the_boom(atom/movable/thing, mob/user)
	boutput(user, "<span class='alert'>\The [thing] explodes.</span>")
	if(explosion_size > 0)
		explosion_new(thing, get_turf(thing), explosion_size)
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
