/var/const/OPEN = 1
/var/const/CLOSED = 2

/obj/firedoor_spawn
	name = "firedoor spawn"
	desc = "Place this over a door to spawn a firedoor underneath. Sets direction, too!"
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "f_spawn"

/obj/firedoor_spawn/New()
	..()
	SPAWN(1 DECI SECOND)
		src.setup()
		sleep(1 SECOND)
		qdel(src)

/obj/firedoor_spawn/proc/setup()
	for (var/obj/machinery/door/D in src.loc)
		var/obj/machinery/door/firedoor/pyro/P = new/obj/machinery/door/firedoor/pyro(src.loc)
		P.set_dir(D.dir)
		P.layer = D.layer + 0.01
		#ifdef UPSCALED_MAP
		P.bound_height = 64
		P.bound_width = 64
		P.transform = list(2, 0, 16, 0, 2, 16)
		#endif
		break

TYPEINFO(/obj/machinery/door/firedoor)
	mats = 30 // maybe a bit high??

/obj/machinery/door/firedoor
	name = "Firelock"
	desc = "Thick, fire-proof doors that prevent the spread of fire, they can only be pried open unless the fire alarm is cleared."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "door0"
	var/blocked = null
	opacity = 0
	density = 0
	var/nextstate = null
	var/control_frequency = FREQ_ALARM
	var/image/welded_image = null
	var/welded_icon_state = "welded"
	has_crush = FALSE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_DESTRUCT
	health = 200
	health_max = 200
/obj/machinery/door/firedoor/xmasify()
	return

/obj/machinery/door/firedoor/border_only
	name = "Firelock"
	icon = 'icons/obj/doors/door_fire2.dmi'
	icon_state = "door0"

/obj/machinery/door/firedoor/pyro
	icon = 'icons/obj/doors/SL_doors.dmi'
	icon_state = "fdoor0"
	icon_base = "fdoor"
	welded_icon_state = "fdoor_welded"
	layer = 3.1 // might just be me but I think these look better when they're over the doors

/obj/machinery/door/firedoor/New()
	..()
	SPAWN(0.5 SECONDS)
		var/list/zones = list()
		for (var/d in list(0) + cardinal)
			var/turf/T = get_step(src,d)
			if(T.density)
				continue
			var/area/A = get_area(T)
			if (A?.name)
				zones |= A.name

		src.AddComponent( \
			/datum/component/packet_connected/radio, \
			"alarm", \
			control_frequency, \
			null, \
			"receive_signal", \
			FALSE, \
			zones, \
			FALSE \
		)

/obj/machinery/door/firedoor/proc/set_open()
	if(!blocked)
		if(operating)
			nextstate = OPEN
		else
			open()
	return

/obj/machinery/door/firedoor/proc/set_closed()
	if(!blocked)
		if(operating)
			nextstate = CLOSED
		else
			close()
	return

// listen for fire alert from firealarm
/obj/machinery/door/firedoor/receive_signal(datum/signal/signal)
	if(!("address_tag" in signal.data) && !("address_1" in signal.data))
		return
	if(signal.data["type"] == "Fire")
		if(signal.data["alert"] == "fire")
			src.set_closed()
		else
			src.set_open()


/obj/machinery/door/firedoor/power_change()
	if( powered(ENVIRON) )
		src.status &= ~NOPOWER
	else
		src.status |= NOPOWER

/obj/machinery/door/firedoor/bumpopen(mob/user)
	return

/obj/machinery/door/firedoor/isblocked()
	if (src.blocked)
		return 1
	return 0

/obj/machinery/door/firedoor/emag_act(mob/user, obj/item/card/emag/E) //BELIEVE IT OR NOT, THIS AND THE CANT_EMAG VAR ARE DISTINCT
	return

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user)
	src.add_fingerprint(user)
	if (!ispryingtool(C))
		if (src.density)
			user.lastattacked = src
			attack_particle(user,src)
			playsound(src.loc, src.hitsound , 50, 1, pitch = 1.6)
			if (C)
				src.take_damage(C.force) //TODO: FOR MBC, WILL RUNTIME IF ATTACKED WITH BARE HAND, C IS NULL. ADD LIMB INTERACTIONS
		return

	if (!src.blocked && !src.operating)
		if(src.density)
			SPAWN( 0 )
				src.operating = 1

				play_animation("opening")
				src.UpdateIcon(1)
				sleep(1.5 SECONDS)
				src.set_density(0)
				src.update_nearby_tiles()
				if (ignore_light_or_cam_opacity)
					src.set_opacity(0)
				else
					src.RL_SetOpacity(0)
				src.operating = 0
				return
		else //close it up again
			SPAWN( 0 )
				src.operating = 1

				play_animation("closing")
				src.UpdateIcon(1)
				src.set_density(1)
				src.update_nearby_tiles()
				sleep(1.5 SECONDS)

				if (ignore_light_or_cam_opacity)
					src.set_opacity(1)
				else
					src.RL_SetOpacity(1)
				src.operating = 0
				return
		playsound(src, 'sound/machines/airlock_pry.ogg', 50, 1)

	return


/obj/machinery/door/firedoor/attack_ai(mob/user as mob)
	var/obj/machinery/door/airlock/mydoor = locate(/obj/machinery/door/airlock) in src.loc
	if(mydoor?.aiControlDisabled == 1)
		boutput(user, "<span class='notice'>You cannot control this firelock because its associated airlock's AI control is disabled!</span>")
		return
	if(!blocked && !operating)
		if(density)
			src.set_open()
		else
			src.set_closed()
	return

/obj/machinery/door/firedoor/proc/check_nextstate()
	switch (src.nextstate)
		if (OPEN)
			src.open()
		if (CLOSED)
			src.close()
	src.nextstate = null

/obj/machinery/door/firedoor/opened()
	..()
	check_nextstate()

/obj/machinery/door/firedoor/closed()
	..()
	check_nextstate()

/obj/machinery/door/firedoor/border_only

/obj/machinery/door/firedoor/border_only/gas_cross(turf/target)
	return (dir != get_dir(src,target))

/obj/machinery/door/firedoor/border_only/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/destination = get_step(source,dir)

	if(need_rebuild)
		if(istype(source)) //Rebuild/update nearby group geometry
			if(source.parent)
				air_master.groups_to_rebuild |= source.parent
			else
				air_master.tiles_to_update |= source
		if(istype(destination))
			if(destination.parent)
				air_master.groups_to_rebuild |= destination.parent
			else
				air_master.tiles_to_update |= destination

	else
		if(istype(source)) air_master.tiles_to_update |= source
		if(istype(destination)) air_master.tiles_to_update |= destination

	return 1

/obj/machinery/door/firedoor/update_icon(var/toggling = 0, override_parent = TRUE)
	if(toggling? !density : density)
		if (locked)
			icon_state = "[icon_base]_locked"
		else
			icon_state = "[icon_base]1"
		if (blocked)
			if (!src.welded_image)
				src.welded_image = image(src.icon, src.welded_icon_state)
			src.UpdateOverlays(src.welded_image, "weld")
		else
			src.UpdateOverlays(null, "weld")
	else
		src.UpdateOverlays(null, "weld")
		icon_state = "[icon_base]0"

	return

/obj/machinery/door/firedoor/custom_suicide = 1

/obj/machinery/door/firedoor/suicide(var/mob/living/carbon/human/user as mob)
	if (!istype(user) || !user.organHolder || !src.user_can_suicide(user))
		return FALSE
	if (src.density)
		return FALSE
	user.visible_message("<span class='alert'><b>[user] sticks [his_or_her(user)] head into [src] and closes it!</b></span>")
	src.close()
	var/obj/head = user.organHolder.drop_organ("head")
	qdel(head)
	make_cleanable( /obj/decal/cleanable/blood/gibs,src.loc)
	playsound(src.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)

	return TRUE
