
/obj/item/electronics/frame/collector_array
	name = "Radiation Collector Array frame"
	store_type = /obj/machinery/power/collector_array
	viewstat = 2
	secured = 2
	icon_state = "dbox"

TYPEINFO(/obj/machinery/power/collector_array)
	mats = 20

/obj/machinery/power/collector_array
	name = "Radiation Collector Array"
	desc = "A device which uses Hawking Radiation and plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "ca"
	anchored = ANCHORED
	density = 1
	directwired = 1
	var/magic = 0
	var/active = 0
	var/obj/item/tank/plasma/P = null
	var/obj/machinery/power/collector_control/CU = null
	deconstruct_flags = DECON_WELDER | DECON_MULTITOOL | DECON_CROWBAR | DECON_WRENCH
	HELP_MESSAGE_OVERRIDE({"Must be cardinally adjacent to a Radiation Collector Controller to function. \
							It can be bolted or unbolted to the floor with a <b>wrench</b>."})

/obj/machinery/power/collector_array/New()
	..()
	SPAWN(0.5 SECONDS)
		UpdateIcon()


/obj/machinery/power/collector_array/update_icon()
	if (src.active || src.magic)
		src.UpdateOverlays(image('icons/obj/singularity.dmi', "on"), "on")
	else
		src.UpdateOverlays(null, "on")

	if(src.P || src.magic)
		src.UpdateOverlays(image('icons/obj/singularity.dmi', "ptank"), "ptank")
	else
		src.UpdateOverlays(null, "ptank")

/obj/machinery/power/collector_array/power_change()
	..()
	UpdateIcon()

/obj/machinery/power/collector_array/process()

	if(magic == 1)
		src.active = 1
		icon_state = "ca_active"
	else
		if(P)
			if(P.air_contents.toxins <= 0)
				src.active = 0
				icon_state = "ca_deactive"
				UpdateIcon()
		else if(src.active == 1)
			src.active = 0
			icon_state = "ca_deactive"
			UpdateIcon()
		..()

/obj/machinery/power/collector_array/attack_hand(mob/user)
	if(src.active==1)
		src.active = 0
		icon_state = "ca_deactive"
		UpdateIcon()
		CU?.updatecons()
		boutput(user, "You turn off the collector array.")
		return

	if(src.active==0)
		src.active = 1
		icon_state = "ca_active"
		UpdateIcon()
		CU?.updatecons()
		boutput(user, "You turn on the collector array.")
		return

/obj/machinery/power/collector_array/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		if(src.active)
			boutput(user, SPAN_ALERT("The [src.name] must be turned off first!"))
		else
			if (!src.anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You secure the [src.name] to the floor.")
				src.anchored = ANCHORED
			else
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You unsecure the [src.name].")
				src.anchored = UNANCHORED
			logTheThing(LOG_STATION, user, "[src.anchored ? "bolts" : "unbolts"] a [src.name] [src.anchored ? "to" : "from"] the floor at [log_loc(src)].") // Ditto (Convair880).
	else if(istype(W, /obj/item/tank/plasma))
		if(src.P)
			boutput(user, SPAN_ALERT("There appears to already be a plasma tank loaded!"))
			return
		src.P = W
		W.set_loc(src)
		user.u_equip(W)
		CU?.updatecons()
		UpdateIcon()
	else if (ispryingtool(W))
		if(!P)
			return
		var/obj/item/tank/plasma/Z = src.P
		Z.set_loc(get_turf(src))
		Z.layer = initial(Z.layer)
		src.P = null
		CU?.updatecons()
		UpdateIcon()
	else
		src.add_fingerprint(user)
		boutput(user, SPAN_ALERT("You hit the [src.name] with your [W.name]!"))
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("The [src.name] has been hit with the [W.name] by [user.name]!"))
