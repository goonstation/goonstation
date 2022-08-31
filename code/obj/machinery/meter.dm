/obj/machinery/meter
	name = "meter"
	icon = 'icons/obj/atmospherics/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	plane = PLANE_NOSHADOW_BELOW
	anchored = 1
	var/frequency = 0
	var/id
	var/noiselimiter = 0

/obj/machinery/meter/New()
	..()
	SPAWN(1 SECOND)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc
	MAKE_SENDER_RADIO_PACKET_COMPONENT(null, frequency)

/obj/machinery/meter/process()
	if(!target)
		icon_state = "meterX"
		return 0

	if(status & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = MIXTURE_PRESSURE(environment)
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"
		if(!noiselimiter)
			if(prob(50))
				playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
				noiselimiter = 1
				SPAWN(6 SECONDS)
				noiselimiter = 0


	if(frequency)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = 1

		signal.data["tag"] = id
		signal.data["device"] = "AM"
		signal.data["pressure"] = round(env_pressure)

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)


/obj/machinery/meter/examine()
	. = list("A gas flow meter. ")
	if(status & (NOPOWER|BROKEN))
		. += "It appears to be nonfunctional."
	else if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			. += text("The pressure gauge reads [] kPa", round(MIXTURE_PRESSURE(environment), 0.1))
		else
			. += "The sensor error light is blinking."
	else
		. += "The connect error light is blinking."


/obj/machinery/meter/Click()

	if(status & (NOPOWER|BROKEN))
		return

	var/t = null
	if (GET_DIST(usr, src) <= 3 || isAI(usr))
		if (src.target)
			var/datum/gas_mixture/environment = target.return_air()
			if(environment)
				t = text("<B>Pressure:</B> [] kPa", round(MIXTURE_PRESSURE(environment), 0.1))
			else
				t = "<span class='alert'><B>Results: Sensor Error!</B></span>"
		else
			t = "<span class='alert'><B>Results: Connection Error!</B></span>"
	else
		boutput(usr, "<span class='notice'><B>You are too far away.</B></span>")

	boutput(usr, t)
	return
