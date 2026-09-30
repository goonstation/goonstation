/datum/db_record/citation/fine
	fields = alist(
		"id" 			= new /datum/record_field/string("ID", "000000", @"[a-f0-9]{6}"),
		"time"			= new /datum/record_field/string("Time Issued", "00:00:00"),
		"type"			= new /datum/record_field/choice("Type", "FINE", list("TICKET", "FINE")),
		"target"		= new /datum/record_field/string("Recipient", "Unknown"),
		"status"		= new /datum/record_field/choice("Status", "PENDING", list("PENDING", "UNPAID", "PAID")),
		"amount"		= new /datum/record_field/number("Amount", 0),
		"paid_amount"	= new /datum/record_field/number("Amount Paid", 0),
		"issuer"		= new /datum/record_field/string("Issuer", "Unknown"),
		"issuer_job"	= new /datum/record_field/string("Issuer Job", "Unknown"),
		"approver"		= new /datum/record_field/string("Approver", "Awaiting Approval"),
		"approver_job"	= new /datum/record_field/string("Approver Job", "Awaiting Approval"),
		"reason"		= new /datum/record_field/string("Reason", "Unknown"),
		"title"			= new /datum/record_field/string("Title", "Unknown"),
		"text"			= new /datum/record_field/string("Text", "Unknown"),
	)

/datum/db_record/citation/fine/New(target, amount, issuer, issuer_job, reason)
	. = ..()

	src["time"] = global.toIso8601InCharacter(world.timeofday)
	src["target"] = target
	src["amount"] = amount
	src["issuer"] = issuer
	src["issuer_job"] = issuer_job
	src["reason"] = reason

	logTheThing(LOG_ADMIN, usr, "requested a fine using [issuer] ([issuer_job])'s ID. It is a [amount] credit fine on <b>[target]</b> with the reason: [reason].")

	var/mob/living/M = usr
	var/datum/eventRecord/Fine/event = new()
	event.send(
		M.mind.get_player().id,
		target,
		html_decode(reason),
		M.real_name,
		M.job,
		M.ckey,
		amount,
	)

/datum/db_record/citation/fine/to_list_display_string()
	return copytext(src["time"], -9, -1) + "  FINE    " + global.pad_trailing(src["status"], 9) + src["target"]

/datum/db_record/citation/fine/proc/can_approve(list/access)
	if (!(access_fine_large in access) && (src["amount"] > SECURITY::TICKET::LARGE_FINE_AMOUNT))
		return FALSE

	if (!(access_fine_small in access))
		return FALSE

	return TRUE

/datum/db_record/citation/fine/proc/attempt_approve(approver, approver_job, list/access)
	if (src["status"] != "PENDING")
		CRASH("Attempted to approve an already-approved fine.")

	if (!(access_fine_large in access) && (src["amount"] > SECURITY::TICKET::LARGE_FINE_AMOUNT))
		return SECURITY::TICKET::ERR::FINE_LARGE

	if (!(access_fine_small in access))
		return SECURITY::TICKET::ERR::FINE_SMALL

	logTheThing(LOG_ADMIN, usr, "approved a fine using [approver] ([approver_job])'s ID. It is a [src["amount"]] credit fine on <b>[src["target"]]</b> with the reason: [src["reason"]].")

	src["status"] = "UNPAID"
	src["approver"] = approver
	src["approver_job"] = approver_job

	var/fine_text = "[src["target"]] has been fined [src["amount"]] credits by Nanotrasen Corporate Security for [src["reason"]] on [time2text(world.realtime, "DD/MM/53")].<br>"
	if (src["issuer"] == approver)
		fine_text += "Issued and approved by: [approver] - [approver_job]<br>"
	else
		fine_text += "Requested by: [src["issuer"]] - [src["issuer_job"]]<br>"
		fine_text += "Approved by: [approver] - [approver_job]<br>"

	src["title"] = "Official Fine Notification - [src["target"]]"
	src["text"] = fine_text

	var/datum/db_record/personnel/bank/bank_record = global.data_core.bank.find_record("name", src["target"])
	var/net_id = bank_record?["pda_net_id"]
	if (bank_record)
		var/datum/signal/signal = global.get_free_signal()
		signal.data["address_1"] = net_id
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = "FINE-MAILBOT"
		signal.data["sender"] = "00000000"
		signal.data["message"] = "Notification: You have been fined [src["amount"]] credits by [src["issuer"]] for [src["reason"]]."
		global.radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	src.process_payment()
	return SECURITY::TICKET::ERR::SUCCESS

/datum/db_record/citation/fine/proc/process_payment()
	var/datum/db_record/personnel/bank/bank_record = global.data_core.bank.find_record("name", src["target"])
	if (QDELETED(bank_record))
		return

	var/to_pay = src["amount"] - src["paid_amount"]

	if (bank_record["current_money"] >= to_pay)
		bank_record["current_money"] -= to_pay
		global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += to_pay
		src["status"] = "PAID"
		src["paid_amount"] = src["amount"]

	else
		src["paid_amount"] += bank_record["current_money"]
		global.wagesystem.budgets[BUDGET_CAT_PAYROLL] += bank_record["current_money"]
		bank_record["current_money"] = 0

		SPAWN(30 SECONDS)
			if (QDELETED(src))
				return

			src.process_payment()
