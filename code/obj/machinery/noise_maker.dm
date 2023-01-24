
/obj/machinery/noise_switch/attackby(obj/item/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.Attackhand(user)

/obj/machinery/noise_switch/attack_hand(mob/user)
	if(status & (NOPOWER|BROKEN))
		return
	use_power(5)
	for(var/obj/machinery/noise_maker/M in machine_registry[MACHINES_MISC])
		if (M.ID == src.ID)
			if(rep == 1)
				M.containment_fail = 1
				M.sound = 3
			M.emittsound()
	src.add_fingerprint(user)

/obj/machinery/noise_switch/attack_ai(mob/user as mob)
	return src.Attackhand(user)

/obj/machinery/noise_switch/attackby(obj/item/W, mob/user)
	user.visible_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")


/obj/machinery/noise_switch/process()
//	if(rep == 0)
//		for (var/obj/X in orange(4,src))
//			if(istype(X,/obj/machinery/the_singularity/))
//				for(var/obj/machinery/noise_maker/M in machine_registry[MACHINES_MISC])
//					rep = 1
//					M.containment_fail = 1
//					M.sound = 3
//					M.emittsound()
//				for(var/obj/machinery/field_generator/T in machines)
//					T.Varedit_start = 1
	qdel(src)



/obj/machinery/noise_maker/attack_hand(mob/user)
//	playsound(src.loc, 'sound/effects/Explosion1.ogg', 100, 1)
	src.add_fingerprint(user)

/obj/machinery/noise_maker/attackby(obj/item/W, mob/user)
	if (issnippingtool(W))
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 60, 1)
		if(broken)
			broken = 0
			icon_state = "nm n +o"
			user.visible_message("<span class='alert'>The [src.name] has been connected by [user.name]!</span>", "<span class='alert'>You connect the [src.name]!</span>")
		else
			broken = 1
			icon_state = "nm n -o"
			user.visible_message("<span class='alert'>The [src.name] has been disconnected by [user.name]!</span>", "<span class='alert'>You disconnect the [src.name]!</span>")

	else
		src.add_fingerprint(user)
		user.visible_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")

//Add when it gets emagged it perma shuts it off

/obj/machinery/noise_maker/proc/emittsound()
	if(broken == 0)
//		if(((src.last_shot + src.fire_delay) <= world.time))
//			src.last_shot = world.time
		if(sound == 1)
			playsound(src.loc, 'sound/effects/screech.ogg', 50, 1)
		else if(sound == 2)
			playsound(src.loc, 'sound/voice/burp.ogg', 100, 1)
		else if(sound == 3)
			playsound(src.loc, 'sound/effects/screech2.ogg', 100, 5,0)
	if(containment_fail == 1)
		SPAWN(9 SECONDS)
		emittsound()
