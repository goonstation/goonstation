/datum/antagonist/gang_leader
	id = ROLE_GANG_LEADER
	display_name = "gang leader"
	antagonist_icon = "gang_head"
	antagonist_panel_tab_type = /datum/antagonist_panel_tab/gang

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
		var/datum/client_image_group/image_group = get_image_group(src.gang)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
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
		boutput(src.owner.current, SPAN_ALERT("Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel."))
		if(!gamemode.random_gangs)
			boutput(src.owner.current, SPAN_ALERT("You must recruit people to your gang and compete for wealth and territory!"))
		boutput(src.owner.current, SPAN_ALERT("You can harm whoever you want, but be careful - the crew can harm gang members too!"))
		boutput(src.owner.current, SPAN_ALERT("To set your gang's home turf and spawn your locker, use the Set Gang Base ability in the top left. Make sure to pick somewhere safe, as your locker can be broken into and looted. You can only do this once!"))
		boutput(src.owner.current, SPAN_ALERT("Build up a stash of cash, guns and drugs. Use the items on your locker to store them."))
		if(!gamemode.random_gangs)
			boutput(src.owner.current, SPAN_ALERT("Use recruitment flyers obtained from the locker to invite new members, up to a limit of [src.gang.current_max_gang_members]."))
		boutput(src.owner.current, SPAN_ALERT("<b>Turf, cash, guns and drugs all count towards victory, and your survival gives your gang bonus points!</b>"))
		if(gamemode.random_gangs)
			var/list/member_strings = list()
			for(var/datum/mind/member in src.gang.members)
				if(!member.current || member == src.owner)
					continue
				var/job = member.current?.job
				member_strings += "[member.current.real_name] as [job]"
			if(length(member_strings))
				boutput(src.owner.current, SPAN_ALERT("Your gang members are:<br>\t[jointext(member_strings, "<br>\t")]"))
			else
				boutput(src.owner.current, SPAN_ALERT("You have no gang members, ouch!"))

	get_statistics()
		var/list/purchased_items = list()
		for (var/obj/purchased_item as anything in src.gang.items_purchased)
			purchased_items += list(
				list(
					"iconBase64" = "[icon2base64(icon(initial(purchased_item.icon), initial(purchased_item.icon_state), frame = 1, dir = initial(purchased_item.dir)))]",
					"name" = "[initial(purchased_item.name)] x[src.gang.items_purchased[purchased_item]]",
				)
			)

		return list(
			list(
				"name" = "Gang Name",
				"value" = "[src.gang.gang_name]",
			),
			list(
				"name" = "Purchased Items",
				"type" = "itemList",
				"value" = purchased_items,
			),
			list(
				"name" = "Areas Owned",
				"value" = "[src.gang.num_areas_controlled()]",
			),
			list(
				"name" = "Turf Score",
				"value" = "[src.gang.score_turf]",
			),
			list(
				"name" = "Cash Pile",
				"value" = "[src.gang.score_cash * 200][CREDIT_SIGN]",
			),
			list(
				"name" = "Guns Stashed",
				"value" = "[src.gang.score_gun]",
			),
			list(
				"name" = "Drug Score",
				"value" = "[src.gang.score_drug]",
			),
			list(
				"name" = "Event Score",
				"value" = "[src.gang.score_event]",
			),
			list(
				"name" = "Total Score",
				"value" = "[src.gang.gang_score()]",
			),
		)
