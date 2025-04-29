/obj/machinery/camera/television
	name = "television camera"
	desc = "A bulky stationary camera for wireless broadcasting of live feeds."
	icon_state = "television"
	network = CAMERA_NETWORK_PUBLIC
	prefix = null
	uses_area_name = TRUE
	anchored = ANCHORED
	density = 1
	reinforced = TRUE
	var/securedstate = 2

/obj/machinery/camera/television/auto
	name = "autoname - television"
	c_tag = "autotag"

/obj/machinery/camera/television/attackby(obj/item/W, mob/user)
	..()
	if (isscrewingtool(W)) //to move them
		if (securedstate && src.securedstate >= 1)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 30, 1, -2)
			actions.start(new/datum/action/bar/icon/cameraSecure(src, securedstate), user)
		else if (securedstate)
			boutput(user, SPAN_ALERT("You need to secure the floor bolts!"))
	else if (iswrenchingtool(W))
		if (src.securedstate <= 1)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 30, 1, -2)
			boutput(user, SPAN_ALERT("You [securedstate == 1 ? "un" : ""]secure the floor bolts on the [src]."))
			src.securedstate = (securedstate == 1) ? 0 : 1

			if (securedstate == 0)
				src.anchored = UNANCHORED
			else
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
			O.show_message(SPAN_NOTICE("[owner] begins [secstate == 2 ? "un" : ""]securing the camera hookups on the [cam]."), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, SPAN_NOTICE("You were interrupted!"))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner.name] [secstate == 2 ? "un" : ""]secures the camera hookups on the [cam]."))
		cam.securedstate = (secstate == 2) ? 1 : 2
		if (cam.securedstate != 2)
			cam.UnsubscribeProcess()
		else
			cam.SubscribeToProcess()

/obj/machinery/camera/television/mobile
	name = "mobile television camera"
	desc = "A bulky mobile camera for wireless broadcasting of live feeds."
	anchored = UNANCHORED
	icon_state = "mobilevision"
	securedstate = null //No bugginess thank you

/obj/machinery/camera/television/mobile/science
	name = "mobile television - science"
	c_tag = "science mobile"
	network = CAMERA_NETWORK_TELESCI
