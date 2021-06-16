/obj/item/device/ticket_writer/odd
	name = "Security TicketWriter 3000"
	desc = "This new and improved edition features upgraded hardware and extra crime-deterring features."

	ticket(mob/user)
		var/target_key = ..()
		if (isnull(target_key))
			return
		var/mob/M = whois_ckey_to_mob_reference(target_key)
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			var/limb = pick("l_arm","r_arm","l_leg","r_leg")
			H.sever_limb(limb)



