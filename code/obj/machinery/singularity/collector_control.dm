
/obj/item/electronics/frame/collector_control
	name = "Radiation Collector Control frame"
	store_type = /obj/machinery/power/collector_control
	viewstat = 2
	secured = 2
	icon_state = "dbox"

TYPEINFO(/obj/machinery/power/collector_control)
	mats = 25

/obj/machinery/power/collector_control
	name = "Radiation Collector Control"
	desc = "A device which uses Hawking Radiation and Plasma to produce power."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "cu"
	anchored = ANCHORED
	density = 1
	directwired = 1
	var/magic = 0
	var/active = 0
	var/lastpower = 0
	var/obj/item/tank/plasma/P1 = null
	var/obj/item/tank/plasma/P2 = null
	var/obj/item/tank/plasma/P3 = null
	var/obj/item/tank/plasma/P4 = null
	var/obj/machinery/power/collector_array/CA1 = null
	var/obj/machinery/power/collector_array/CA2 = null
	var/obj/machinery/power/collector_array/CA3 = null
	var/obj/machinery/power/collector_array/CA4 = null
	var/obj/machinery/power/collector_array/CAN = null
	var/obj/machinery/power/collector_array/CAS = null
	var/obj/machinery/power/collector_array/CAE = null
	var/obj/machinery/power/collector_array/CAW = null
	var/list/obj/machinery/the_singularity/S = null
	deconstruct_flags = DECON_WELDER | DECON_MULTITOOL | DECON_CROWBAR | DECON_WRENCH

	HELP_MESSAGE_OVERRIDE({"Transfers the energy from cardinally adjacent Radiation Collector Arrays \
							to the wire below it as usable electric power. \
							It can be bolted or unbolted to the floor with a <b>wrench</b>."})

/obj/machinery/power/collector_control/New()
	..()
	START_TRACKING
	AddComponent(/datum/component/mechanics_holder)
	SPAWN(1 SECOND)
		updatecons()

/obj/machinery/power/collector_control/disposing()
	STOP_TRACKING
	. = ..()

/obj/machinery/power/collector_control/proc/updatecons()

	if(magic != 1)

		CAN = locate(/obj/machinery/power/collector_array) in get_step(src,NORTH)
		CAS = locate(/obj/machinery/power/collector_array) in get_step(src,SOUTH)
		CAE = locate(/obj/machinery/power/collector_array) in get_step(src,EAST)
		CAW = locate(/obj/machinery/power/collector_array) in get_step(src,WEST)
		S = list()
		for_by_tcl(singu, /obj/machinery/the_singularity)//this loop checks for valid singularities
			if(!QDELETED(singu) && GET_DIST(singu,loc)<SINGULARITY_MAX_DIMENSION+2 )
				S |= singu

		if(!isnull(CAN))
			CA1 = CAN
			CAN.CU = src
			if(CA1.P)
				P1 = CA1.P
		else
			CAN = null
		if(!isnull(CAS))
			CA3 = CAS
			CAS.CU = src
			if(CA3.P)
				P3 = CA3.P
		else
			CAS = null
		if(!isnull(CAW))
			CA4 = CAW
			CAW.CU = src
			if(CA4.P)
				P4 = CA4.P
		else
			CAW = null
		if(!isnull(CAE))
			CA2 = CAE
			CAE.CU = src
			//DrMelon attempted fix for null.P at singularity.dm /// seemed to have been a tabulation error
			if(CA2.P)
				P2 = CA2.P
		else
			CAE = null

		UpdateIcon()
		SPAWN(1 MINUTE)
			updatecons()

	else
		UpdateIcon()
		SPAWN(1 MINUTE)
			updatecons()

/obj/machinery/power/collector_control/update_icon()
	overlays = null
	if(magic != 1)
		if(src.active == 0)
			return
		overlays += image('icons/obj/singularity.dmi', "cu on")
		if((P1)&&(CA1.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 1 on")
		if((P2)&&(CA2.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 2 on")
		if((P3)&&(CA3.active != 0))
			overlays += image('icons/obj/singularity.dmi', "cu 3 on")
		if((!P1)||(!P2)||(!P3))
			overlays += image('icons/obj/singularity.dmi', "cu n error")
		if(length(S))
			overlays += image('icons/obj/singularity.dmi', "cu sing")
			for(var/obj/machinery/the_singularity/singu in S)
				if(!singu.active)
					overlays += image('icons/obj/singularity.dmi', "cu conterr")
					break
	else
		overlays += image('icons/obj/singularity.dmi', "cu on")
		overlays += image('icons/obj/singularity.dmi', "cu 1 on")
		overlays += image('icons/obj/singularity.dmi', "cu 2 on")
		overlays += image('icons/obj/singularity.dmi', "cu 3 on")
		overlays += image('icons/obj/singularity.dmi', "cu sing")

/obj/machinery/power/collector_control/power_change()
	UpdateIcon()
	..()

/obj/machinery/power/collector_control/process(mult)
	if(magic != 1)
		if(src.active == 1)
			var/power_a = 0
			var/power_s = 0
			var/power_p = 0

			for(var/obj/machinery/the_singularity/singu in S)
				if(singu && !QDELETED(singu))
					power_s += singu.energy*max((singu.radius**2),1)/4
			if(P1?.air_contents)
				if(CA1.active != 0)
					power_p += P1.air_contents.toxins
					P1.air_contents.toxins -= 0.001 * mult
			if(P2?.air_contents)
				if(CA2.active != 0)
					power_p += P2.air_contents.toxins
					P2.air_contents.toxins -= 0.001 * mult
			if(P3?.air_contents)
				if(CA3.active != 0)
					power_p += P3.air_contents.toxins
					P3.air_contents.toxins -= 0.001 * mult
			if(P4?.air_contents)
				if(CA4.active != 0)
					power_p += P4.air_contents.toxins
					P4.air_contents.toxins -= 0.001 * mult
			power_a = power_p*power_s*50
			src.lastpower = power_a
			add_avail(power_a)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "power=[num2text(round(power_a), 50)]&powerfmt=[engineering_notation(power_a)]W")
			..()
	else
		var/power_a = 0
		var/power_s = 0
		var/power_p = 0
		for(var/obj/machinery/the_singularity/singu in S)
			if(singu && !QDELETED(singu))
				power_s += singu.energy*((singu.radius*2+1)**2)/DEFAULT_AREA  //should give the area of the singularity and divide it by the area of a standard singularity(a 5x5)
		power_p += 50
		power_a = power_p*power_s*50
		src.lastpower = power_a
		add_avail(power_a)
		..()

/obj/machinery/power/collector_control/attack_hand(mob/user)
	if(src.active==1)
		src.active = 0
		boutput(user, "You turn off the collector control.")
		src.lastpower = 0
		UpdateIcon()
		return

	if(src.active==0)
		src.active = 1
		boutput(user, "You turn on the collector control.")
		updatecons()
		return

/obj/machinery/power/collector_control/attackby(obj/item/W, mob/user)
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
	else if(istype(W, /obj/item/device/analyzer/atmospheric))
		boutput(user, SPAN_NOTICE("The analyzer detects that [lastpower]W are being produced."))

	else
		src.add_fingerprint(user)
		boutput(user, SPAN_ALERT("You hit the [src.name] with your [W.name]!"))
		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("The [src.name] has been hit with the [W.name] by [user.name]!"))
