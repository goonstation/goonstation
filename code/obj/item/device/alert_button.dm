/obj/item/device/alert_button
	name = "security alert button"
	icon_state = "button"
	desc = "Hit this button when you're in a dire situation and need backup or assistance! It has a cooldown, though, so use it wisely."
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	w_class = 2
	item_state = "electronic"
	var/list/mailgroups = list(MGD_SECURITY)
	var/net_id = null
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

/obj/item/device/alert_button/New()
	..()
	SPAWN_DBG(10 SECONDS)
		if (radio_controller)
			radio_connection = radio_controller.add_object(src, "[frequency]")
		if (!src.net_id)
			src.net_id = generate_net_id(src)

/obj/item/device/alert_button/disposing()
		radio_controller.remove_object(src, "[frequency]")
		mailgroups.Cut()
		..()

/obj/item/device/alert_button/attack_self(mob/user as mob)
	if (!radio_connection)
		boutput(user, "<span class='alert'>No radio connection detected.")
		return
	if (PROC_ON_COOLDOWN(5 MINUTES))
		boutput(user, "<span class='alert'>[src] is still on cooldown mode!")
		return
	src.add_fingerprint(user)
	var/area/A = get_area(user)
	var/message = "<b><span class='alert'>***SECURITY BACKUP REQUESTED*** Location: [A ? A.name : "nowhere"]!"
	src.send_alert(message, MGA_CRISIS)
	flick("button-pressed", src)

/obj/item/device/alert_button/proc/send_alert(var/message, var/alertgroup)
	var/datum/signal/newsignal = get_free_signal()
	newsignal.source = src
	newsignal.transmission_method = TRANSMISSION_RADIO
	newsignal.data["command"] = "text_message"
	newsignal.data["sender_name"] = "SEC-MAILBOT"
	newsignal.data["message"] = "[message]"

	newsignal.data["address_1"] = "00000000"
	newsignal.data["group"] = mailgroups + alertgroup
	newsignal.data["sender"] = src.net_id

	radio_connection.post_signal(src, newsignal)
