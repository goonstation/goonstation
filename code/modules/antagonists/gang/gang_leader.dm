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
		antagonist_icon = "gang_head_[gang.color_id]"
		SPAWN(0)
			src.gang.select_gang_name()

		if (src.gang.gang_points[new_owner] == null)
			src.gang.gang_points[new_owner] = GANG_STARTING_POINTS

		. = ..()

	disposing()
		src.gang.leader = null

		. = ..()

	on_death()
		if (GANG_LEADER_SOFT_DEATH_TIME > ticker.round_elapsed_ticks)
			src.gang.handle_leader_early_death()
		..()

	handle_cryo()
		src.gang.handle_leader_temp_cryo()

	handle_perma_cryo()
		src.gang.handle_leader_perma_cryo()


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
		src.ability_holder.addAbility(/datum/targetable/gang/toggle_overlay)
		src.ability_holder.addAbility(/datum/targetable/gang/locker_spot)

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

		src.headset?.remove_radio_upgrade()

	add_to_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.gang)
		image_group.add_mind_mob_overlay(src.owner, get_antag_icon_image())
		image_group.add_mind(src.owner)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		imgroup.add_mind(src.owner)
		var/datum/client_image_group/objimgroup = get_image_group(CLIENT_IMAGE_GROUP_GANG_OBJECTIVES)
		objimgroup.add_mind(src.owner)

	remove_from_image_groups()
		. = ..()
		var/datum/client_image_group/image_group = get_image_group(src.gang)
		image_group.remove_mind_mob_overlay(src.owner)
		image_group.remove_mind(src.owner)
		var/datum/client_image_group/imgroup = get_image_group(CLIENT_IMAGE_GROUP_GANGS)
		imgroup.remove_mind(src.owner)
		var/datum/client_image_group/objimgroup = get_image_group(CLIENT_IMAGE_GROUP_GANG_OBJECTIVES)
		objimgroup.remove_mind(src.owner)

	transfer_to(datum/mind/target, take_gear, source, silent = FALSE)
		var/datum/abilityHolder/gang/ability_source = src.owner.current.get_ability_holder(/datum/abilityHolder/gang)
		var/datum/mind/old_owner = owner
		..()
		gang.leader = target
		var/datum/abilityHolder/gang/ability_target = target.current.get_ability_holder(/datum/abilityHolder/gang)
		target.current.remove_ability_holder(ability_target)
		target.current.add_existing_ability_holder(ability_source)
		old_owner.current.remove_ability_holder(/datum/abilityHolder/gang)

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang, src)

	announce()
		. = ..()
		var/datum/game_mode/gang/gamemode = ticker.mode
		src.owner.current.show_antag_popup(ROLE_GANG_LEADER)
		boutput(src.owner.current, SPAN_ALERT("Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel."))
		if(!gamemode.random_gangs)
			boutput(src.owner.current, SPAN_ALERT("You must recruit people to your gang and compete for wealth and territory!"))
		boutput(src.owner.current, SPAN_ALERT("To set your gang's home turf and spawn your locker, use the Set Gang Base ability in the top left. Make sure to pick somewhere safe, as your locker is where your territory starts. You can only do this once!"))
		boutput(src.owner.current, SPAN_ALERT("Once your locker is spawned, grab your gear and spraycans, then expand your territory!"))
		boutput(src.owner.current, SPAN_ALERT("------"))
		boutput(src.owner.current, SPAN_ALERT("You and your gang earn points by claiming territory, finding dead drops, storing guns & drugs in your locker."))
		boutput(src.owner.current, SPAN_ALERT("Capture areas for your gang by using spraypaint around the edges of your territory. The more populated the area, the better!"))
		boutput(src.owner.current, SPAN_ALERT("In a few minutes, your gang will send PDA messages to civilians about a dead drop. Work with the civilians to find them for guns & loot!"))
		boutput(src.owner.current, SPAN_ALERT("Additionally, a couple of large weapons crates will spawn over the shift. watch the radio to find out where!"))
		boutput(src.owner.current, SPAN_ALERT("Be proud of your outfit! Wearing it grants benefits, hiding it under a suit doesn't count."))
		boutput(src.owner.current, SPAN_ALERT("------"))
		boutput(src.owner.current, SPAN_ALERT("You are free to harm anyone who isn't in your gang, but be careful, they can do the same to you!"))


		if(!gamemode.random_gangs)
			boutput(src.owner.current, SPAN_ALERT("Use recruitment flyers obtained from the locker to invite new members, up to a limit of [src.gang.current_max_gang_members]."))
		boutput(src.owner.current, SPAN_ALERT("<b>Keep in mind: As the gang leader, you have a special pool of 'Street Cred' to hire new gang members & buy revival syringes at your locker!</b>"))
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
				"name" = "Tiles Controlled",
				"value" = "[src.gang.num_tiles_controlled()]",
			),
			list(
				"name" = "Turf Score",
				"value" = "[src.gang.score_turf]",
			),
			list(
				"name" = "Cash Pile",
				"value" = "[src.gang.score_cash * GANG_CASH_DIVISOR][CREDIT_SIGN]",
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
