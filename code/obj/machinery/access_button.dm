obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "Access Button"
	desc = "A button for cycling airlocks."

	layer = NOLIGHT_EFFECTS_LAYER_BASE

	anchored = ANCHORED

	var/master_tag
	var/frequency = FREQ_AIRLOCK_CONTROL
	var/command = "cycle"


	var/on = 1

	update_icon()
		if(on)
			icon_state = "access_button_standby"
		else
			icon_state = "access_button_off"

	attack_hand(mob/user)
		var/datum/signal/signal = get_free_signal()
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = master_tag
		signal.data["command"] = command

		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal, AIRLOCK_CONTROL_RANGE)
		FLICK("access_button_cycle", src)

	New()
		..()
		UnsubscribeProcess()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, null, frequency)
