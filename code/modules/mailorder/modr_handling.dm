//A mail loading chute + landmark mailorder spawn and target are recommended for map addition
//as they allow direct shipping of goods, instead of relying on QM distribution

/obj/item/storage/box/mailorder
	name = "mail-order box"
	icon_state = "evidence"
	desc = "A box containing mail-ordered items."
	var/mail_dest = null //used if mail loop delivery
	var/buyer_name = null //used if QM delivery, configures container

	proc/yeetself(gothere) //forbidden techniques
		var/yeetdelay = rand(15 SECONDS,20 SECONDS)
		SPAWN_DBG(yeetdelay)
			src.invisibility = 0
			src.anchored = 0
		SPAWN_DBG(yeetdelay + 1 DECI SECOND)
			if(gothere)
				src.throw_at(gothere, 100, 1)
			else //how tho
				message_admins("<span class='alert'>[src] failed to launch at intended destination, tell kubius</span>")

/obj/storage/secure/crate/mailorder
	name = "mail-order crate"
	desc = "A crate that holds mail-ordered items."
	personal = 1

	New()
		..()

	proc/launch_procedure()
		if(src.registered)
			src.name = "[src.registered]'s mail-order crate"
			src.desc = "A crate that holds mail-ordered items. It's registered to [src.registered]."

/obj/machinery/floorflusher/industrial/mailorder
	name = "external mail loading chute"
	desc = "A large chute that only accepts specially designed mail-order boxes."
	var/destination_tag = null

	HasEntered(atom/movable/AM)
		if(istype(AM,/obj/item/storage/box/mailorder))
			..()

	MouseDrop_T()
		return

	attack_hand()
		return

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I,/obj/item/storage/box/mailorder))
			..()


	flush()

		flushing = 1

		closeup()
		var/obj/disposalholder/H = unpool(/obj/disposalholder)	// virtual holder object which actually
																// travels through the pipes.

		for(var/atom/movable/AM in src)
			if(istype(AM,/obj/item/storage/box/mailorder))
				var/obj/item/storage/box/mailorder/mobox = AM
				if(mobox.mail_dest)
					src.destination_tag = mobox.mail_dest

		H.init(src)	// copy the contents of disposer to holder

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
