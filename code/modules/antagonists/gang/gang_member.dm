/datum/antagonist/subordinate/gang_member
	id = ROLE_GANG_MEMBER
	display_name = "gang member"

	/// The gang that this gang member belongs to.
	var/datum/gang/gang
	/// The headset of this gang member, tracked so that additional channels may be later removed.
	var/obj/item/device/radio/headset/headset

	New(datum/mind/new_owner, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
		src.master = master
		src.gang = src.master.current.get_gang()
		src.gang.members += new_owner

		. = ..()

		src.gang.leader.current?.antagonist_overlay_refresh(TRUE, FALSE)
		for(var/datum/mind/M in src.gang.members)
			M.current?.antagonist_overlay_refresh(TRUE, FALSE)

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
				H.equip_if_possible(src.headset, H.slot_r_store)
			else if (!H.l_store)
				H.equip_if_possible(src.headset, H.slot_l_store)
			else if (istype(H.back, /obj/item/storage/) && length(H.back.contents) < 7)
				H.equip_if_possible(src.headset, H.slot_in_backpack)
			else
				H.put_in_hand_or_drop(src.headset)

		src.headset.install_radio_upgrade(new /obj/item/device/radio_upgrade/gang(frequency = src.gang.gang_frequency))

	remove_equipment()
		src.headset.remove_radio_upgrade()

	assign_objectives()
		ticker.mode.bestow_objective(src.owner, /datum/objective/specialist/gang/member, src)

	announce()
		. = ..()
		boutput(src.owner.current, "<span class='alert'>You are now a member of [src.gang.gang_name]!</span>")
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

	// The gang leader antagonist datum will announce information pertaining to gang members.
	handle_round_end()
		return
