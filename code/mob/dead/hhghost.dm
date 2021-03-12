/mob/dead/hhghost
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	var/mob/original = null
	name = "ghost"

/mob/dead/hhghost/disposing()
	original = null
	..()

/mob/dead/hhghost/New()
	. = ..()
	src.invisibility = 100
	src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	src.see_invisible = 0

/mob/dead/hhghost/Login()
	..()
	if(!src.client) //This could not happen but hey byond and just in case.
		return

	src.client.images.Cut()

	for(var/image/I in orbicons)
		boutput(src, I)

	SPAWN_DBG(5 SECONDS)
		updateOrbs()
	return

/mob/dead/hhghost/proc/updateOrbs()
	set background = 1
	if(src.client)
		src.client.images.Cut()
		for(var/image/I in orbicons)
			boutput(src, I)
	SPAWN_DBG(5 SECONDS)
		updateOrbs()
	return

/mob/dead/hhghost/Logout()
	..()
	src.client?.images.Cut()
	return

/mob/dead/hhghost/Move(var/turf/NewLoc, direct)
	if(!canmove) return
	if(!isturf(src.loc)) src.set_loc(get_turf(src))
	if(NewLoc)
		src.set_loc(NewLoc)
		NewLoc.HasEntered(src)
		for(var/atom/A in NewLoc)
			if(A == src) continue
			A.HasEntered(src)
		return
	if((direct & NORTH) && src.y < world.maxy)
		src.y++
	if((direct & SOUTH) && src.y > 1)
		src.y--
	if((direct & EAST) && src.x < world.maxx)
		src.x++
	if((direct & WEST) && src.x > 1)
		src.x--

/mob/dead/hhghost/can_use_hands()	return 0
/mob/dead/hhghost/is_active()		return 0

/mob/dead/observer/say_understands(var/other)
	return 1
