/datum/computer/file/terminal_program/db_manager/secmate
	name = "SecMate"
	size = 12
	req_access = list(access_security)

	var/obj/item/peripheral/network/radio/radiocard = null
	var/setup_mailgroup = MGD_SECURITY
	var/setup_mail_freq = FREQ_PDA

/datum/computer/file/terminal_program/db_manager/secmate/initialize()
	if (..())
		return TRUE

	src.radiocard = locate() in src.master.peripherals

/datum/computer/file/terminal_program/db_manager/secmate/disposing()
	src.radiocard = null
	. = ..()

/datum/computer/file/terminal_program/db_manager/secmate/get_menus()
	var/datum/db_record_group/security/record_group = new()

	. = ..() + alist(
		"main"			= new /datum/db_manager_menu/main/secmate(src),
		"record_list"	= new /datum/db_manager_menu/record_list(src, record_group),
		"search_input"	= new /datum/db_manager_menu/search_input(src, record_group),
	)

/datum/computer/file/terminal_program/db_manager/secmate/on_field_update(datum/db_record/record, key, old_value, new_value)
	if (key != "criminal")
		return

	var/datum/db_record/main_record = src.current_record_group.get_main_database().find_record("id", record["id"])
	if (!main_record)
		return

	var/target_name = main_record["name"]
	for_by_tcl(H, /mob/living/carbon/human)
		if ((H.real_name == target_name) || (H.name == target_name))
			H.update_arrest_icon()

	if ( \
		(old_value != SECURITY::ARREST::STATE::ARREST) && (old_value != SECURITY::ARREST::STATE::DETAIN) && \
		(new_value != SECURITY::ARREST::STATE::ARREST) && (new_value != SECURITY::ARREST::STATE::DETAIN) \
	)
		return

	if (usr)
		logTheThing(LOG_STATION, usr, "[target_name] is set from \[[old_value]\] to \[[new_value]\] by [usr] (using the ID card of [src.authenticated]) [global.log_loc(src.master)].")

	if (!src.radiocard)
		return

	if ((src.radiocard.frequency != src.setup_mail_freq) && !src.radiocard.setup_freq_locked)
		src.peripheral_command("[src.setup_mail_freq]", global.get_free_signal(), ref(src.radiocard))

	var/datum/signal/signal = global.get_free_signal()
	signal.data["command"] = "text_message"
	signal.data["sender_name"] = "SEC-MAILBOT"
	signal.data["group"] = list(src.setup_mailgroup, MGA_ARREST)
	signal.data["message"] = "Crew member \"[target_name]\" has been set from [old_value] to [new_value] by [src.authenticated]."

	src.peripheral_command("transmit", signal, ref(src.radiocard))
