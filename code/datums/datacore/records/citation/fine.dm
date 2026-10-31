/datum/db_record/citation/fine

/datum/db_record/citation/fine/build_fields()
	return alist(
		"id" 			= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"time"			= new /datum/record_field/string(src, "Time Issued", "00:00:00"),
		"authority"		= new /datum/record_field/string(src, "Authority", "Nanotrasen Corporate Security"),
		"type"			= new /datum/record_field/choice(src, "Type", "FINE", list("TICKET", "FINE")),
		"target"		= new /datum/record_field/string(src, "Recipient", "Unknown"),
		"status"		= new /datum/record_field/choice(src, "Status", "PENDING", list("PENDING", "UNPAID", "PAID")),
		"amount"		= new /datum/record_field/number(src, "Amount", 0),
		"paid_amount"	= new /datum/record_field/number(src, "Amount Paid", 0),
		"issuer"		= new /datum/record_field/string(src, "Issuer", "Unknown"),
		"issuer_job"	= new /datum/record_field/string(src, "Issuer Job", "Unknown"),
		"approver"		= new /datum/record_field/string(src, "Approver", "Awaiting Approval"),
		"approver_job"	= new /datum/record_field/string(src, "Approver Job", "Awaiting Approval"),
		"reason"		= new /datum/record_field/string(src, "Reason", "Unknown"),
	)

/datum/db_record/citation/fine/New(authority, target, amount, issuer, issuer_job, reason)
	. = ..()

	src["time"] = global.toIso8601InCharacter(world.timeofday)
	src["authority"] = authority
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

/datum/db_record/citation/fine/get_name()
	return "Official Fine Notification - [src["target"]]"

/datum/db_record/citation/fine/get_approver()
	if (src["issuer"] == src["approver"])
		return

	return {"\
		<table width="365px">\
		<tr><td width="200px">APPROVED BY</td><td>[src["approver"]]</td></tr>\
		<tr><td width="200px">ASSIGNMENT</td><td>[src["approver_job"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/fine/get_reason()
	return {"\
		<table width="365px">\
		<tr><td width="125px" colspan="2">AMOUNT<td>[src["amount"]][CREDIT_SIGN]</td></tr>\
		<tr><td width="100px">REASON</td><td colspan="2">[src["reason"]]</td></tr>\
		</table>\
	"}

/datum/db_record/citation/fine/build_citation(paper_icon_state = "paper_caution")
	if (src["status"] == "PENDING")
		CRASH("Attempted to print an unapproved fine.")

	. = ..()
