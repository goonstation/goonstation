#define LOST_ITEM_SEC_PAYOUT 100
#define LOST_ITEM_LOWER_COUNT 7
#define LOST_ITEM_UPPER_COUNT 15

/datum/random_event/minor/lost_and_found
	name = "Lost and Found"
	centcom_headline = "NanoTrasen Logistics Division"
	centcom_message = "The NanoTrasen Item Reclaimation Team has confirmed a misplaced personal items are aboard. Security teams are recommended to return lost items to their owners."
	weight = 10

	event_effect(source)
		. = ..()

		for(var/i = 1; i <= rand(LOST_ITEM_LOWER_COUNT, LOST_ITEM_UPPER_COUNT); i++)
			var/obj/storage/hiding_spot = null
			for(var/tries in 1 to 5)
				hiding_spot = get_a_random_station_unlocked_container_with_no_others_on_the_turf()
				if (hiding_spot?.open)
					continue
				if(istype(hiding_spot))
					var/T = pick(possible_lost_items)
					var/obj/item/I = new T(get_turf(hiding_spot))
					I.loc = hiding_spot
					var/datum/db_record/R = pick(data_core.general.records)
					I.name = "lost [I.name]"
					I.desc = "Didn't [R["name"]] lose one of these?"
					I.add_fingerprint_direct(R["fingerprint"])
					RegisterSignal(I, COMSIG_ITEM_PICKUP, PROC_REF(lost_item_pickup))
					break

/datum/random_event/minor/lost_and_found/proc/lost_item_pickup(obj/item/owner, mob/user)
	if(findtext(owner.desc, user.real_name, 4)) // skip "lost"
		owner.name = "returned [initial(owner.name)]"
		owner.desc = "Oh, I'm so glad [user.real_name] found it!"

		// reward security for the item being returned
		var/list/datum/db_record/security_team = FindBankAccountsByJobs(security_jobs)
		for(var/datum/db_record/account as anything in security_team)
			account["current_money"] += LOST_ITEM_SEC_PAYOUT
			if (account["pda_net_id"])
				var/datum/signal/signal = get_free_signal()
				signal.data["sender"] = "00000000"
				signal.data["command"] = "text_message"
				signal.data["sender_name"] = "BONUS-MAILBOT"
				signal.data["address_1"] = account["pda_net_id"]
				signal.data["message"] = "NanoTrasen has paid out a bonus to your account for a lost item being returned to its owner."
				radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

		UnregisterSignal(owner, COMSIG_ITEM_PICKUP)

#undef LOST_ITEM_SEC_PAYOUT
#undef LOST_ITEM_LOWER_COUNT
#undef LOST_ITEM_UPPER_COUNT
