#define SECURED_STATE_UNSECURED 0
#define SECURED_STATE_BOLTED 1
#define SECURED_STATE_SCREWED 2
#define SECURED_STATE_UNCHANGABLE 3

/obj/machinery/camera/television
	name = "television camera"
	desc = "A bulky stationary camera for wireless broadcasting of live feeds."
	icon_state = "television"
	network = "public"
	prefix = null
	uses_area_name = TRUE
	anchored = ANCHORED
	density = 1
	reinforced = TRUE
	/// does this camera also transmit audio to viewers
	var/transmits_audio = FALSE
	/// how anchored-to-the-floor is this camera
	var/secured_state = SECURED_STATE_SCREWED

/obj/machinery/camera/television/tv_studio
	name = "television studio camera"
	desc = "A bulky stationary camera for wireless broadcasting of live feeds. This one has an attached microphone."
	network = "public"
	transmits_audio = TRUE
	secured_state = SECURED_STATE_UNCHANGABLE

/obj/machinery/camera/television/auto
	name = "autoname - television"
	c_tag = "autotag"

/obj/machinery/camera/television/attackby(obj/item/W, mob/user)
	..()
	if (isscrewingtool(W)) //to move them
		switch (src.secured_state)
			if(SECURED_STATE_UNCHANGABLE)
				boutput(user, SPAN_ALERT("This camera cannot be secured or unsecured!"))
			if(SECURED_STATE_SCREWED)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 30, 1, -2)
				actions.start(new/datum/action/bar/icon/cameraSecure(src, src.secured_state), user)
			if (SECURED_STATE_BOLTED)
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 30, 1, -2)
				actions.start(new/datum/action/bar/icon/cameraSecure(src, src.secured_state), user)
			if (SECURED_STATE_UNSECURED)
				boutput(user, SPAN_ALERT("You need to secure the floor bolts first!"))

	else if (iswrenchingtool(W))
		switch (src.secured_state)
			if(SECURED_STATE_UNCHANGABLE)
				boutput(user, SPAN_ALERT("This camera cannot be secured or unsecured!"))
			if(SECURED_STATE_SCREWED)
				boutput(user, SPAN_ALERT("You need to undo the camera hookups on [src] first!"))
			if (SECURED_STATE_BOLTED)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 30, 1, -2)
				boutput(user, SPAN_ALERT("You unsecure the floor bolts on the [src]."))
				src.secured_state = SECURED_STATE_UNSECURED
				src.anchored = UNANCHORED
			if (SECURED_STATE_UNSECURED)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 30, 1, -2)
				boutput(user, SPAN_ALERT("You secure the floor bolts on the [src]."))
				src.secured_state = SECURED_STATE_BOLTED
				src.anchored = ANCHORED

/datum/action/bar/icon/cameraSecure //This is used when you are securing a non-mobile television camera
	duration = 150
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	icon_state = "screwdriver"
	var/obj/machinery/camera/television/cam
	var/secstate

	New(Camera, Secstate)
		cam = Camera
		secstate = Secstate
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(SPAN_NOTICE("[owner] begins [secstate == SECURED_STATE_SCREWED ? "un" : ""]securing the camera hookups on the [cam]."), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, SPAN_NOTICE("You were interrupted!"))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner.name] [secstate == SECURED_STATE_SCREWED ? "un" : ""]secures the camera hookups on the [cam]."))
		cam.secured_state = (secstate == SECURED_STATE_SCREWED) ? SECURED_STATE_BOLTED : SECURED_STATE_SCREWED
		if (cam.secured_state != SECURED_STATE_SCREWED)
			cam.UnsubscribeProcess()
		else
			cam.SubscribeToProcess()

/obj/machinery/camera/television/mobile
	name = "mobile television camera"
	desc = "A bulky mobile camera for wireless broadcasting of live feeds."
	anchored = UNANCHORED
	icon_state = "mobilevision"
	secured_state = SECURED_STATE_UNCHANGABLE

/obj/machinery/camera/television/mobile/science
	name = "mobile television - science"
	c_tag = "science mobile"
	network = "telesci"

#undef SECURED_STATE_UNSECURED
#undef SECURED_STATE_BOLTED
#undef SECURED_STATE_SCREWED
#undef SECURED_STATE_UNCHANGABLE
