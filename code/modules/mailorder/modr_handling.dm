//boxes and loaders for transfer of ordered goods to purchaser

/////////////CONFIGURATION NOTES/////////////

//A mail loading chute + landmark mailorder spawn and target are recommended for map addition.
//Mail order spawn landmark, located at edge of map
//Mail order target landmark, placed at location on station that is chute location or will feed box into chute
//Mail loading chute, located somewhere external, connected to the station's mail loop

//The chute should accept mail from a point external on the station and place it into the mail loop
//using a juncture that has a tag which doesn't match any mail chute.

//Adding the chute will not prevent purchase of the mail-order via QM secure crate;
//merely add the option for a less secure but more convenient box-based delivery

//Box for mail-based delivery
/obj/item/storage/box/mailorder
	name = "mail-order box"
	icon_state = "evidence"
	desc = "A box containing mail-ordered items."
	var/mail_dest = null //used in mail loop delivery

	proc/yeetself()
		var/yeetdelay = rand(15 SECONDS,20 SECONDS)
		SPAWN_DBG(yeetdelay)
			var/yeetbegin = pick_landmark(LANDMARK_MAILORDER_SPAWN)
			var/yeetend = pick_landmark(LANDMARK_MAILORDER_TARGET)
			if(!yeetbegin || !yeetend)
				logTheThing("debug",null,null,"[src] failed to launch at intended destination, tell kubius")
			src.set_loc(get_turf(yeetbegin))
			src.throw_at(yeetend, 100, 1)

//Box for QM-based delivery
/obj/storage/secure/crate/mailorder
	name = "mail-order crate"
	desc = "A crate that holds mail-ordered items."
	personal = 1

	New()
		..()

	proc/launch_procedure()
		if(src.registered)
			src.name = "\improper [src.registered]'s mail-order crate"
			src.desc = "A crate that holds mail-ordered items. It's registered to [src.registered]'s ID card."

//Auto chute that accepts boxes for mail-based delivery, and nothing else
/obj/machinery/floorflusher/industrial/mailorder
	name = "external mail loading chute"
	desc = "A large chute that only accepts specially designed mail-order boxes."
	var/destination_tag = null

	Crossed(atom/movable/AM)
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
		var/obj/disposalholder/H = new /obj/disposalholder	// virtual holder object which actually
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
