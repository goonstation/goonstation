/obj/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox0"
	desc = "A display case for antique possessions."
	density = 1
	anchored = ANCHORED
	material_amt = 0.3
	var/health = 30
	var/obj/item/displayed = null // The item held within.
	var/destroyed = 0

	New()
		..()
		if (ispath(src.displayed))
			src.displayed = new src.displayed

		if (displayed)
			displayed.set_loc(src)
			displayed.pixel_x = 0
			displayed.pixel_y = 0
			displayed.transform *= 0.8
			overlays += displayed

/obj/displaycase/ex_act(severity)
	switch(severity)
		if (1)
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)

			qdel(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()

/obj/displaycase/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	if (damage < 1)
		return

	switch(P.proj_data.damage_type)
		if(D_KINETIC)
			src.health -= (damage*2)
		if(D_PIERCING)
			src.health -= (damage/2)
		if(D_ENERGY)
			src.health -= (damage/4)

	src.healthcheck()
	return


/obj/displaycase/blob_act(var/power)
	if (prob(50))
		src.health = 0
		src.healthcheck()
		qdel(src)


/obj/displaycase/meteorhit(obj/O as obj)
	src.health = 0
	src.healthcheck()
	qdel(src)


/obj/displaycase/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.set_density(0)
			src.destroyed = 1
			var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
			G.set_loc(src.loc)
			if (displayed)
				displayed.set_loc(src.loc)
				displayed.transform *= 1.25
				displayed = null
				overlays.Cut()
			desc = "A display case for antique possessions. It has been destroyed."
			playsound(src, "shatter", 70, 1)
			UpdateIcon()
	else
		playsound(src.loc, 'sound/impact_sounds/Glass_Hit_1.ogg', 75, 1)
	return

/obj/displaycase/update_icon()
	if(src.destroyed)
		src.icon_state = "glassboxb0"
	else
		src.icon_state = "glassbox0"
	return


/obj/displaycase/attackby(obj/item/W, mob/user)
	if (isscrewingtool(W)) // To bolt to the floor
		if (src.anchored == 0)
			src.anchored = ANCHORED
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_message(SPAN_NOTICE("You bolt the display case to the floor."))
		else
			src.anchored = UNANCHORED
			playsound(user, 'sound/items/Screwdriver2.ogg', 65, TRUE)
			user.show_message(SPAN_NOTICE("You unbolt the display case from the floor."))
		return
	else if (iswrenchingtool(W) && destroyed) // To disassemble when broken
		boutput(user, SPAN_NOTICE("You begin to disassemble the broken display case."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		var/turf/T = user.loc
		sleep(2 SECONDS)
		if ((user.loc == T && user.equipped() == W))
			boutput(user, SPAN_NOTICE("You disassemble the broken display case."))
			qdel(src)
		return
	else if (istype(W, /obj/item/sheet/glass) && destroyed) // To repair when broken
		boutput(user, SPAN_NOTICE("You begin to repair the broken display case."))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		var/turf/T = user.loc
		sleep(1.5 SECONDS)
		if ((user.loc == T && user.equipped() == W))
			user.show_message(SPAN_NOTICE("You fix the broken display case."))
			var/obj/item/sheet/glass/G = W
			G.change_stack_amount(-1)
			src.set_density(1)
			src.destroyed = 0
			src.health = 30
			UpdateIcon()
			desc = "A display case for antique possessions."
		return
	else if (displayed == null && !(destroyed)) // To put items inside when not broken
		if (W.cant_drop)
			boutput(user, SPAN_ALERT("You can't put items that are attached to you in the display case!"))
			return
		if (istype(W, /obj/item/grab))
			boutput(user, SPAN_ALERT("You can't put that in the display case!"))
			return
		user.drop_item()
		displayed = W
		displayed.set_loc(src)
		displayed.pixel_x = 0
		displayed.pixel_y = 0
		displayed.transform *= 0.8
		desc = "A display case for antique possessions. There is \an [displayed.name] inside of it."
		overlays += displayed
		boutput(user, SPAN_NOTICE("You place the [W.name] in the display case."))
	else // When punched
		user.lastattacked = get_weakref(src)
		attack_particle(user, src)
		src.health -= W.force
		src.healthcheck()
	..()
	return

/obj/displaycase/attack_hand(mob/user)
	if (user.a_intent == INTENT_HARM)
		user.visible_message(SPAN_ALERT("[user] kicks the display case."))
		user.lastattacked = get_weakref(src)
		attack_particle(user, src)
		src.health -= 2
		src.healthcheck()
	..()
	return

//lets have an actual subtype instead of just varediting this
/obj/displaycase/captain
	displayed = /obj/item/gun/energy/antique
