// flockdrone door
/obj/machinery/door/feather
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "door1"
	name = "weird imposing wall"
	desc = "It sounds like it's hollow."
	mat_appearances_to_ignore = list("steel","gnesis")
	autoclose = 1
	var/broken = 0
	health = 80
	health_max = 80

/obj/machinery/door/feather/special_desc(dist, mob/user)
	if(isflock(user))
		var/special_desc = {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> Solid Seal Aperture
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%"}
		if(broken)
			special_desc += {"<br><span class='bold'>FUNCTION CRITICALLY IMPAIRED, REPAIRS REQUIRED</span>
			<br><span class='bold'>###=-</span></span>"}
		return special_desc
	else
		return null // give the standard description

/obj/machinery/door/feather/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (src.density)
		boutput(user, "<span class='alert'>No reaction, apparently.</span>")
	return 0

/obj/machinery/door/feather/take_damage(var/amount, var/mob/user = 0)
	..()
	if(src.health <= (src.health_max/2) && !broken)
		playsound(src.loc, "sound/impact_sounds/Glass_Shatter_1.ogg", 25, 1)
		src.name = "shattered wall door thing"
		src.desc = "Well, no one's opening this thing anymore."
		src.icon_state = "door-broke"
		src.broken = 1

/obj/machinery/door/feather/break_me_complitely()
	var/turf/T = get_turf(src)
	playsound(T, "sound/impact_sounds/Glass_Shatter_3.ogg", 25, 1)
	var/obj/item/raw_material/shard/S = unpool(/obj/item/raw_material/shard)
	S.set_loc(T)
	S.setMaterial(getMaterial("gnesisglass"))
	make_cleanable( /obj/decal/cleanable/flockdrone_debris, T)
	qdel(src)

/obj/machinery/door/feather/open()
	if(broken)
		return 1
	else
		return ..()

/obj/machinery/door/feather/heal_damage()
	src.icon_state = "door1"
	src.broken = 0
	close()
	src.health = initial(health)
	src.name = initial(name)
	src.desc = initial(desc)

/obj/machinery/door/feather/play_animation(animation)
	if(broken)
		return
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_[icon_base]c0", src)
			else
				flick("[icon_base]c0", src)
			icon_state = "[icon_base]0"
		if("closing")
			if(p_open)
				flick("o_[icon_base]c1", src)
			else
				flick("[icon_base]c1", src)
			icon_state = "[icon_base]1"
		if("deny")
			flick("[icon_base]_deny", src)
			playsound(src.loc, "sound/misc/flockmind/flockdrone_door_deny.ogg", 50, 1, -2)


/obj/machinery/door/feather/attack_ai(mob/user as mob)
	// do nothing, AI and borgs can't interface with the door
	boutput(user, "<span class='alert'>No response. It doesn't seem compatible with your systems.</span>")
	return

/obj/machinery/door/feather/attack_hand(mob/user as mob)
	return src.attackby(null, user)

/obj/machinery/door/feather/allowed(mob/M)
	return isflock(M) // haha fuck you everyone else

/obj/machinery/door/feather/New()
	..()
	setMaterial("gnesis")

/obj/machinery/door/feather/open()
	if(..())
		playsound(src.loc, "sound/misc/flockmind/flockdrone_door.ogg", 50, 1)

/obj/machinery/door/feather/close()
	if(..())
		playsound(src.loc, "sound/misc/flockmind/flockdrone_door.ogg", 50, 1)

/obj/machinery/door/feather/isblocked()
	return 0 // this door will not lock or be inaccessible to flockdrones

////////////////////
// friendly variant
////////////////////
/obj/machinery/door/feather/friendly
	// whee

/obj/machinery/door/feather/friendly/allowed(mob/M)
	return 1 // everyone welcome
