/datum/antagonist/subordinate/gang_member
	id = ROLE_GANG_MEMBER
	display_name = "gang member"
	antagonist_icon = "gang"

	/// The gang that this gang member belongs to.
	var/datum/gang/gang
	/// The headset of this gang member, tracked so that additional channels may be later removed.
	var/obj/item/device/radio/headset/headset

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		src.master = master
		src.gang = src.master.current.get_gang()
		src.gang.members += new_owner

		. = ..()

	disposing()
		src.gang.members -= src.owner

		. = ..()

	is_compatible_with(datum/mind/mind)
		return ishuman(mind.current)

	give_equipment()
		if (!ishuman(src.owner.current))
			return FALSE

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
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang/member, src)

	announce()
		. = ..()
		var/gang_name = src.gang.gang_name
		if(gang_name == initial(src.gang.gang_name))
			gang_name = "a yet to be named gang"
		boutput(src.owner.current, "<span class='alert'>You are now a member of [gang_name]!</span>")
		boutput(src.owner.current, "<span class='alert'>Your headset has been tuned to your gang's frequency. Prefix a message with :z to communicate on this channel.</span>")
		boutput(src.owner.current, "<span class='alert'>Your boss is denoted by the blue G and your fellow gang members are denoted by the red G! Work together and do some crime!</span>")
		boutput(src.owner.current, "<span class='alert'>You are free to harm anyone who isn't in your gang, but be careful, they can do the same to you!</span>")
		boutput(src.owner.current, "<span class='alert'>You should only use bombs if you have a good reason to, and also run any bombings past your gang!</span>")
		boutput(src.owner.current, "<span class='alert'>Capture areas for your gang by using spraypaint on other gangs' tags (or on any turf if the area is unclaimed).</span>")
		boutput(src.owner.current, "<span class='alert'>You can get spraypaint, an outfit, and a gang headset from your locker.</span>")
		boutput(src.owner.current, "<span class='alert'>Your gang will earn points for cash, drugs, and guns stored in your locker.</span>")
		boutput(src.owner.current, "<span class='alert'>Make sure to defend your locker, as other gangs can break it open to loot it!</span>")
		if(src.gang.base)
			boutput(src.owner.current, "<span class='alert'>Your gang's base is located in [src.gang.base], along with your locker.</span>")
		else
			boutput(src.owner.current, "<span class='alert'>Your gang doesn't have a base or locker yet.</span>")

		boutput(src.owner.current, "<span class='alert'>Your gang leader is <b>[src.gang.leader.current.real_name]</b> as <b>[src.gang.leader.current.job]</b>.</span>")
		var/list/member_strings = list()
		for(var/datum/mind/member in src.gang.members)
			if(!member.current)
				continue
			if(member == src.gang.leader || member == src.owner)
				continue
			var/job = member.current?.job
			member_strings += "[member.current.real_name] as [job]"
		if(length(member_strings))
			boutput(src.owner.current, "<span class='alert'>Other gang members of your gang are:<br>\t[jointext(member_strings, "<br>\t")]</span>")
		else
			boutput(src.owner.current, "<span class='alert'>Seems like it's only you and the gang leader.</span>")

	// The gang leader antagonist datum will announce information pertaining to gang members.
	handle_round_end()
		return
