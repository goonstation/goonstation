//A landmark mailorder spawn and target are required for mail order to work
//Mail order loading chute is recommended for any station with a mail loop

/obj/item/storage/box/mailorder
	name = "mail-order box"
	icon_state = "evidence"
	desc = "A box containing mail-ordered items."
	var/mail_dest = null

	proc/yeetself() //forbidden techniques
		var/yeetdelay = rand(15 SECONDS,20 SECONDS)
		SPAWN_DBG(yeetdelay)
			src.invisibility = 0
			src.anchored = 0
		SPAWN_DBG(yeetdelay + 1 DECI SECOND)
			var/gothere = pick_landmark(LANDMARK_MAILORDER_TARGET)
			if(gothere)
				src.throw_at(LANDMARK_MAILORDER_TARGET, 100, 1)

/obj/machinery/floorflusher/industrial/mail_order
	name = "external mail loading chute"
	desc = "A large chute that only accepts specially designed mail-order boxes."
	var/destination_tag = null

	HasEntered(atom/movable/AM)
		if(!istype(AM,/obj/item/storage/box/mailorder))
			return
		..()

	MouseDrop_T(mob/target, mob/user)
		return

	attackby(var/obj/item/I, var/mob/user)
		if(!istype(I,/obj/item/storage/box/mailorder))
			return
		..()


	flush()

		flushing = 1

		closeup()
		var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																// travels through the pipes.

		H.init(src)	// copy the contents of disposer to holder

		for(var/atom/movable/AM in src)
			if(istype(AM,/obj/item/storage/box/mailorder))
				var/obj/item/storage/box/mailorder/mobox = AM
				if(mobox.mail_dest)
					src.destination_tag = mobox.mail_dest

		if (!isnull(src.destination_tag))
			H.mail_tag = src.destination_tag
			src.destination_tag = null // dictated by package, not chute

		air_contents.zero() // empty gas

		sleep(1 SECOND)
		playsound(src, "sound/machines/disposalflush.ogg", 50, 0, 0)
		sleep(0.5 SECONDS) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0



		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return
