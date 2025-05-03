/datum/antagonist/subordinate/gang_member
	id = ROLE_GANG_MEMBER
	display_name = "gang member"
	antagonist_icon = "gang"
	wiki_link = "https://wiki.ss13.co/Gang"

	/// The gang that this gang member belongs to.
	var/datum/gang/gang
	/// The headset of this gang member, tracked so that additional channels may be later removed.
	var/obj/item/device/radio/headset/headset
	/// The ability holder of this gang member, containing their abilities (namely, toggling the gang overlay)
	var/datum/abilityHolder/gang/ability_holder

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		src.master = master
		var/datum/antagonist/gang_leader/antagrole = src.master.get_antagonist(ROLE_GANG_LEADER)
		src.gang = antagrole.gang
		antagonist_icon = "gang_member_[gang.color_id]"
		src.gang.members += new_owner
		if (src.gang.gang_points[new_owner] == null)
			src.gang.gang_points[new_owner] = GANG_STARTING_POINTS
		. = ..()

	disposing()
		src.gang.members -= src.owner

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE


		var/datum/abilityHolder/gang/gangHolder = src.owner.current.get_ability_holder(/datum/abilityHolder/gang)
		if (!gangHolder)
			src.ability_holder = src.owner.current.add_ability_holder(/datum/abilityHolder/gang)
		else
			src.ability_holder = gangHolder

		src.ability_holder.addAbility(/datum/targetable/gang/toggle_overlay)
		src.ability_holder.addAbility(/datum/targetable/gang/locker_spot)

		var/mob/living/carbon/human/H = src.owner.current

		// If possible, get the gang member's headset.
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
		src.headset.remove_radio_upgrade()
		src.owner.current.remove_ability_holder(/datum/abilityHolder/gang)

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

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang/member, src)

	announce()
		. = ..()
		var/gang_name = src.gang.gang_name
		src.owner.current.show_antag_popup(ROLE_GANG_MEMBER)
		if(gang_name == initial(src.gang.gang_name))
			gang_name = "a yet to be named gang"
		// this is a LOT of text, but it will help in the absence of the wiki
		boutput(src.owner.current, SPAN_ALERT("You are now a member of [gang_name]!"))
		boutput(src.owner.current, SPAN_ALERT("Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel."))
		boutput(src.owner.current, SPAN_ALERT("You can get spraypaint, an outfit, and a gang headset from your locker."))
		boutput(src.owner.current, SPAN_ALERT("Be proud of your outfit! Wearing it grants benefits, hiding it under a suit doesn't count."))
		boutput(src.owner.current, SPAN_ALERT("------"))
		boutput(src.owner.current, SPAN_ALERT("You and your gang earn points by claiming territory, finding dead drops, storing guns & drugs in your locker."))
		boutput(src.owner.current, SPAN_ALERT("Capture areas for your gang by using spraypaint around the edges of your territory. The more populated the area, the better!"))
		boutput(src.owner.current, SPAN_ALERT("In a few minutes, your gang will send PDA messages to civilians about a dead drop. Work with the civilians to find them for guns & loot!"))
		boutput(src.owner.current, SPAN_ALERT("Additionally, a couple of large weapons crates will spawn over the shift. watch the radio to find out where!"))
		boutput(src.owner.current, SPAN_ALERT("------"))
		boutput(src.owner.current, SPAN_ALERT("You are free to harm anyone who isn't in your gang, but be careful, they can do the same to you!"))
		if(src.gang.base)
			boutput(src.owner.current, SPAN_ALERT("Your gang's base is located in [src.gang.base], along with your locker."))
		else
			boutput(src.owner.current, SPAN_ALERT("Your gang doesn't have a base or locker yet."))

		boutput(src.owner.current, SPAN_ALERT("Your gang leader is <b>[src.gang.leader.current.real_name]</b> as <b>[src.gang.leader.current.job]</b>."))
		var/list/member_strings = list()
		for(var/datum/mind/member in src.gang.members)
			if(!member.current)
				continue
			if(member == src.gang.leader || member == src.owner)
				continue
			var/job = member.current?.job
			member_strings += "[member.current.real_name] as [job]"
		if(length(member_strings))
			boutput(src.owner.current, SPAN_ALERT("Other gang members of your gang are:<br>\t[jointext(member_strings, "<br>\t")]"))
		else
			boutput(src.owner.current, SPAN_ALERT("Seems like it's only you and the gang leader."))
