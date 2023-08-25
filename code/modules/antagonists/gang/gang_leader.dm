/datum/antagonist/gang_leader
	id = ROLE_GANG_LEADER
	display_name = "gang leader"
	antagonist_icon = "gang_head"

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
				H.equip_if_possible(src.headset, SLOT_R_STORE)
			else if (!H.l_store)
				H.equip_if_possible(src.headset, SLOT_L_STORE)
			else if (H.back?.storage && !H.back.storage.is_full())
				H.equip_if_possible(src.headset, SLOT_IN_BACKPACK)
			else
				H.put_in_hand_or_drop(src.headset)

		src.headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/gang(frequency = src.gang.gang_frequency))

	remove_equipment()
		src.ability_holder.removeAbility(/datum/targetable/gang/set_gang_base)
		src.owner.current.remove_ability_holder(/datum/abilityHolder/gang)

		src.headset.remove_radio_upgrade()

	add_to_image_groups()
		. = ..()
		var/image/image = image('icons/mob/antag_overlays.dmi', icon_state = src.antagonist_icon)
		var/datum/client_image_group/image_group = get_image_group(src.gang)
		image_group.add_mind_mob_overlay(src.owner, image)
		image_group.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.gang)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang, src)

	announce()
		. = ..()
		var/datum/game_mode/gang/gamemode = ticker.mode
		boutput(src.owner.current, "<span class='alert'>Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel.</span>")
		if(!gamemode.random_gangs)
			boutput(src.owner.current, "<span class='alert'>You must recruit people to your gang and compete for wealth and territory!</span>")
		boutput(src.owner.current, "<span class='alert'>You can harm whoever you want, but be careful - the crew can harm gang members too!</span>")
		boutput(src.owner.current, "<span class='alert'>To set your gang's home turf and spawn your locker, use the Set Gang Base ability in the top left. Make sure to pick somewhere safe, as your locker can be broken into and looted. You can only do this once!</span>")
		boutput(src.owner.current, "<span class='alert'>Build up a stash of cash, guns and drugs. Use the items on your locker to store them.</span>")
		if(!gamemode.random_gangs)
			boutput(src.owner.current, "<span class='alert'>Use recruitment flyers obtained from the locker to invite new members, up to a limit of [src.gang.current_max_gang_members].</span>")
		boutput(src.owner.current, "<span class='alert'><b>Turf, cash, guns and drugs all count towards victory, and your survival gives your gang bonus points!</b></span>")
		if(gamemode.random_gangs)
			var/list/member_strings = list()
			for(var/datum/mind/member in src.gang.members)
				if(!member.current || member == src.owner)
					continue
				var/job = member.current?.job
				member_strings += "[member.current.real_name] as [job]"
			if(length(member_strings))
				boutput(src.owner.current, "<span class='alert'>Your gang members are:<br>\t[jointext(member_strings, "<br>\t")]</span>")
			else
				boutput(src.owner.current, "<span class='alert'>You have no gang members, ouch!</span>")

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
