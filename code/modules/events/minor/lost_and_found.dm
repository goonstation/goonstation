#define LOST_ITEM_SEC_PAYOUT 100
#define LOST_ITEM_LOWER_COUNT 7
#define LOST_ITEM_UPPER_COUNT 15

/datum/random_event/minor/lost_and_found
	name = "Lost and Found"
	centcom_headline = "NanoTrasen Logistics Division"
	centcom_message = "The NanoTrasen Office for Item Reclaimation has confirmed several misplaced personal items are aboard. Security is encouraged to return lost items to their owners."
	weight = 50

	event_effect(source)
		. = ..()
		var/list/eligible_containers = get_random_station_storage_list(closed=TRUE)
		for (var/i = 1; i <= rand(LOST_ITEM_LOWER_COUNT, LOST_ITEM_UPPER_COUNT); i++)
			if (length(eligible_containers) == 0)
				break

			var/obj/storage/hiding_spot = pick(eligible_containers)
			eligible_containers -= hiding_spot // don't stack lost items

			var/item_to_lose = pick(possible_lost_items)
			var/obj/item/lost_item = new item_to_lose(get_turf(hiding_spot))
			lost_item.loc = hiding_spot

			var/datum/db_record/item_owner = pick(data_core.general.records)
			lost_item.name = "lost [lost_item.name]"
			lost_item.desc = "Didn't [item_owner["name"]] lose one of these?"
			lost_item.add_fingerprint_direct(item_owner["fingerprint"])

			RegisterSignal(lost_item, COMSIG_ITEM_PICKUP, PROC_REF(lost_item_pickup))

/datum/random_event/minor/lost_and_found/proc/lost_item_pickup(obj/item/lost_item, mob/user)
	if (findtext(lost_item.desc, user.real_name, 4)) // skip "lost"
		lost_item.name = "returned [initial(lost_item.name)]"
		lost_item.desc = "Oh, I'm so glad [user.real_name] found it!"

		// reward security for the item being returned
		var/list/datum/db_record/security_team = FindBankAccountsByJobs(security_jobs)
		if (length(security_team) > 0)
			// payout
			for (var/datum/db_record/account as anything in security_team)
				account["current_money"] += LOST_ITEM_SEC_PAYOUT
			// notify
			var/datum/signal/signal = get_free_signal()
			signal.data["sender"] = "00000000"
			signal.data["command"] = "text_message"
			signal.data["sender_name"] = "BONUS-MAILBOT"
			signal.data["group"] = MGD_SECURITY
			signal.data["message"] = "Bonus of [LOST_ITEM_SEC_PAYOUT][CREDIT_SIGN] issued for a lost item being returned to [user.real_name]."
			radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

		UnregisterSignal(lost_item, COMSIG_ITEM_PICKUP)

#undef LOST_ITEM_SEC_PAYOUT
#undef LOST_ITEM_LOWER_COUNT
#undef LOST_ITEM_UPPER_COUNT
