/obj/hud
	name = "hud"
	anchored = 1
	var/mob/mymob = null
	var/list/adding = null
	var/list/other = null
	var/list/intents = null
	var/list/mov_int = null
	var/list/mon_blo = null
	var/list/m_ints = null
	var/list/darkMask = null

	var/h_type = /atom/movable/screen

obj/hud/New(var/type = 0)
	src.instantiate(type)
	..()
	return

/obj/hud/var/show_otherinventory = 1
/obj/hud/var/atom/movable/screen/action_intent
/obj/hud/var/atom/movable/screen/move_intent

/obj/hud/proc/instantiate(var/type = 0)

	mymob = src.loc
	ASSERT(ismob(mymob))

	if(ishivebot(mymob))
		src.hivebot_hud()
		return

	if (islivingobject(mymob))
		src.object_hud()
