/datum/antagonist/gang_leader
	id = ROLE_GANG_LEADER
	display_name = "gang leader"

	/// The gang that this gang leader belongs to.
	var/datum/gang/gang
	/// The ability holder of this gang leader, containing their respective abilities.
	var/datum/abilityHolder/gang/ability_holder
	/// The headset of this gang leader, tracked so that additional channels may be later removed.
	var/obj/item/device/radio/headset/headset

	New(datum/mind/new_owner)
		src.gang = new /datum/gang
		src.gang.leader = new_owner

		SPAWN(0)
			src.gang.select_gang_name()

		. = ..()

		for(var/datum/mind/M in src.gang.members)
			M.current?.antagonist_overlay_refresh(TRUE, FALSE)

	disposing()
		src.gang.leader = null

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

		var/datum/abilityHolder/gang/A = src.owner.current.get_ability_holder(/datum/abilityHolder/gang)
		if (!A)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/gang)
		else
			src.ability_holder = A

		src.ability_holder.addAbility(/datum/targetable/gang/set_gang_base)

		var/mob/living/carbon/human/H = src.owner.current

		// If possible, get the gang leader's headset.
		if (istype(H.ears, /obj/item/device/radio/headset))
			src.headset = H.ears
		else
			src.headset = new /obj/item/device/radio/headset(H)
			if (!H.r_store)
				H.equip_if_possible(src.headset, H.slot_r_store)
			else if (!H.l_store)
				H.equip_if_possible(src.headset, H.slot_l_store)
			else if (istype(H.back, /obj/item/storage/) && length(H.back.contents) < 7)
				H.equip_if_possible(src.headset, H.slot_in_backpack)
			else
				H.put_in_hand_or_drop(src.headset)

		src.headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/gang(frequency = src.gang.gang_frequency))

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/gang/set_gang_base)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/gang)

		src.headset.remove_radio_upgrade()

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='alert'>Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel.</span>")
		boutput(src.owner.current, "<span class='alert'>You must recruit people to your gang and compete for wealth and territory!</span>")
		boutput(src.owner.current, "<span class='alert'>You can harm whoever you want, but be careful - the crew can harm gang members too!</span>")
		boutput(src.owner.current, "<span class='alert'>To set your gang's home turf and spawn your locker, use the Set Gang Base ability in the top left. Make sure to pick somewhere safe, as your locker can be broken into and looted. You can only do this once!</span>")
		boutput(src.owner.current, "<span class='alert'>Build up a stash of cash, guns and drugs. Use the items on your locker to store them.</span>")
		boutput(src.owner.current, "<span class='alert'>Use recruitment flyers obtained from the locker to invite new members, up to a limit of [src.gang.current_max_gang_members].</span>")
		boutput(src.owner.current, "<span class='alert'><b>Turf, cash, guns and drugs all count towards victory, and your survival gives your gang bonus points!</b></span>")


	handle_round_end(log_data)
		. = list()
		. += "<br><h3><span class='regular'>[src.gang.gang_name]</span></h3>"

		// Announce gang leader.
		if(src.owner.current)
			. += "<h4><span class='regular'>Gang Leader: [src.owner.current] (played by [src.owner.displayed_key])</span></h4>"
		else
			. += "<h4><span class='regular'>Gang Leader: [owner.displayed_key] (character destroyed)</span></h4>"

		// Announce gang members.
		var/members = "<h4><span class='regular'>Members:</span></h4>"
		if(!length(src.gang.members))
			members += "None!"
		else
			var/count = 0
			for(var/datum/mind/member in src.gang.members)
				count++
				if(member.current)
					members += "[member.current.real_name] (played by <b>[member.displayed_key]</b>)[(count == length(src.gang.members)) ? "." : ", " ]"
				else
					members += "[member.displayed_key]</b> (character destroyed)[(count == length(src.gang.members)) ? "." : ", " ]"

		. += members

		// Announce gang purchases.
		var/items = "<br><h4><span class='regular'>Items Purchased:</span></h4>"
		if (!length(src.gang.items_purchased))
			items += "None!"
		else
			for (var/obj/purchased_item as anything in src.gang.items_purchased)
				var/number_of_purchased_items = src.gang.items_purchased[purchased_item]
				items += "[number_of_purchased_items] [bicon(purchased_item)] [purchased_item.name][s_es(number_of_purchased_items)], "

		. += items

		// Announce various scores.
		. += "<br><b>Areas Owned:</b> [src.gang.num_areas_controlled()]"
		. += "<b>Turf Score:</b> [src.gang.score_turf]"
		. += "<b>Cash Pile:</b> [src.gang.score_cash * 200][CREDIT_SIGN]"
		. += "<b>Guns Stashed:</b> [src.gang.score_gun]"
		. += "<b>Drug Score:</b> [src.gang.score_drug]"
		. += "<b>Event Score:</b> [src.gang.score_event]"
		. += "<b>Total Score: [src.gang.gang_score()]</b>"
