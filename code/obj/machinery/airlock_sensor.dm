obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "Airlock Sensor"

	anchored = 1

	var/id_tag
	var/master_tag
	var/frequency = FREQ_AIRLOCK_CONTROL


	var/on = 1
	var/alert = 0

	update_icon()
		if(on)
			if(alert)
				icon_state = "airlock_sensor_alert"
			else
				icon_state = "airlock_sensor_standby"
		else
			icon_state = "airlock_sensor_off"

	attack_hand(mob/user)
		var/datum/signal/signal = get_free_signal()
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = "cycle"

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, AIRLOCK_CONTROL_RANGE)
		flick("airlock_sensor_cycle", src)

	process()
		if(on)
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = air_master.current_cycle

			var/datum/gas_mixture/air_sample = return_air()

			var/pressure = round(MIXTURE_PRESSURE(air_sample),0.1)
			alert = (pressure < ONE_ATMOSPHERE*0.8)

			signal.data["pressure"] = num2text(pressure)

			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, AIRLOCK_CONTROL_RANGE)

		UpdateIcon()

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, frequency)
