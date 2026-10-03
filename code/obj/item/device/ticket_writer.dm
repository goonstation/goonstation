/obj/item/device/ticket_writer
	name = "security TicketWriter 2000"
	desc = "A device used to issue tickets from the security department."
	icon_state = "ticketwriter"
	item_state = "accessgun"
	w_class = W_CLASS_SMALL

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	var/paper_icon_state = "paper_caution"
	/// What corperate entity warned the crimer
	var/corporate_rank = "Nanotrasen Corporate Security"

	attack_self(mob/user)
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
		var/ticket_target = tgui_input_text(user, "Ticket recipient:", "Ticket Writer")
		ticket_target = copytext(sanitize(html_encode(ticket_target)), 1, MAX_MESSAGE_LEN)
		if (!ticket_target)
			return
		var/ticket_reason = tgui_input_text(user, "Ticket reason:", "Ticket Writer")
		ticket_reason = copytext(sanitize(html_encode(ticket_reason)), 1, MAX_MESSAGE_LEN)
		if (!ticket_reason || !user.find_in_hand(src))
			return

		var/datum/db_record/citation/ticket/ticket = new(
			authority = src.corporate_rank,
			target = ticket_target,
			issuer = issuer,
			issuer_job = issuer_job,
			reason = ticket_reason,
		)
		global.data_core.tickets.add_record(ticket)

		playsound(src, 'sound/machines/printer_thermal.ogg', 50, TRUE)
		SPAWN(3 SECONDS)
			var/obj/item/paper/paper = new()
			user.put_in_hand_or_drop(paper)
			paper.name = ticket["title"]
			paper.info = ticket["text"]
			paper.icon_state = src.paper_icon_state

/obj/item/device/ticket_writer/crust
	name = "crusty old security TicketWriter 1000"
	desc = "An old TicketWriter model held together by hopes and dreams alone."
	paper_icon_state = "paper_burned"

/obj/item/device/ticket_writer/nanotrasen
	name = "inspector TicketWriter 4000"
	desc = "A device used by NanoTrasen inspectors to issue tickets to poorly performing crew. The keys on it are rather worn down."
	icon_state = "ticketwriter_nt"
	corporate_rank = "Nanotrasen Internal Affairs"

