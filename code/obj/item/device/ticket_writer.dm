/obj/item/device/ticket_writer
	name = "security TicketWriter 2000"
	desc = "A device used to issue tickets from the security department."
	icon_state = "ticketwriter"
	item_state = "accessgun"
	w_class = W_CLASS_SMALL

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	var/paper_icon_state = "paper_caution"

	attack_self(mob/user)
		var/menuchoice = tgui_alert(user, "What would you like to do?", "Ticket writer", list("Ticket", "Nothing"))
		if (!menuchoice || menuchoice == "Nothing")
			return
		else if (menuchoice == "Ticket")
			src.ticket(user)

	proc/ticket(mob/user)
		var/obj/item/card/id/I
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			I = H.wear_id
		else if (ismobcritter(user))
			I = locate(/obj/item/card/id) in user.contents
		else if (issilicon(user))
			var/mob/living/silicon/S = user
			I = S.botcard
		if (!I || !(access_ticket in I.access))
			boutput(user, SPAN_ALERT("Insufficient access."))
			return
		playsound(src, 'sound/machines/keyboard3.ogg', 30, TRUE)
		var/issuer = I.registered
		var/issuer_job = I.assignment
		var/ticket_target = input(user, "Ticket recipient:", "Recipient", "Ticket Recipient") as text | null
		if (!ticket_target)
			return
		ticket_target = copytext(sanitize(html_encode(ticket_target)), 1, MAX_MESSAGE_LEN)
		var/ticket_reason = input(user, "Ticket reason:", "Reason") as text | null
		if (!ticket_reason)
			return
		ticket_reason = copytext(sanitize(html_encode(ticket_reason)), 1, MAX_MESSAGE_LEN)

		var/ticket_text = "[ticket_target] has been officially [pick("cautioned","warned","told off","yelled at","berated","sneered at")] by Nanotrasen Corporate Security for [ticket_reason] on [time2text(world.realtime, "DD/MM/53")].<br>Issued by: [issuer] - [issuer_job]<br>"

		var/datum/ticket/T = new /datum/ticket()
		T.target = ticket_target
		T.reason = ticket_reason
		T.issuer = issuer
		T.issuer_job = issuer_job
		T.text = ticket_text
		T.target_byond_key = get_byond_key(T.target)
		T.issuer_byond_key = user.key
		data_core.tickets += T

		logTheThing(LOG_ADMIN, user, "tickets <b>[ticket_target]</b> with the reason: [ticket_reason].")
		playsound(src, 'sound/machines/printer_thermal.ogg', 50, TRUE)
		SPAWN(3 SECONDS)
			var/obj/item/paper/p = new /obj/item/paper
			user.put_in_hand_or_drop(p)
			p.name = "Official Caution - [ticket_target]"
			p.info = ticket_text
			p.icon_state = src.paper_icon_state

		return T.target_byond_key

/obj/item/device/ticket_writer/crust
	name = "crusty old security TicketWriter 1000"
	desc = "An old TicketWriter model held together by hopes and dreams alone."
	paper_icon_state = "paper_burned"
