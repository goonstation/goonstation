obj/machinery/access_button
	icon = 'icons/obj/machinery/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "Access Button"
	desc = "A button for cycling airlocks."

	layer = NOLIGHT_EFFECTS_LAYER_BASE

	anchored = 1

	var/master_tag
	var/frequency = 1449
	var/command = "cycle"

	var/datum/radio_frequency/radio_connection

	var/on = 1

	proc/update_icon()
		if(on)
			icon_state = "access_button_standby"
		else
			icon_state = "access_button_off"

	attack_hand(mob/user)
		if(radio_connection)
			var/datum/signal/signal = get_free_signal()
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = master_tag
			signal.data["command"] = command

			radio_connection.post_signal(src, signal, AIRLOCK_CONTROL_RANGE)
		flick("access_button_cycle", src)

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		set_frequency(frequency)

	New()
		..()
		UnsubscribeProcess()
		if(radio_controller)
			set_frequency(frequency)

	disposing()
		radio_controller.remove_object(src, "[frequency]")
		..()
