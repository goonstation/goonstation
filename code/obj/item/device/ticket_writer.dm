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
		var/ticket_flavor = list("Follow the Law.",
								"Contact a monkey in a [weighted_pick(list("suit" = 9, "biz suit" = 1))] and a funny hat if required.",
								"Do not Reoffend.",
								"Don't make it a habit.",
								"Your move, creep.",
								"I AM THE LAW.",
								"Justice is made.",
								"Unsafe for human consumption.",
								"Remember to recycle.",
								"Days without infractions: 0",
								"Could be your last.")

		var/ticket_text = {"<font face="Monospace" color="453425">
							<center>
							<font size="4">[corporate_rank]</font> <br>
							<font size="3">[station_name]</font> <br> <br>
							</center>
							<table width="365px">
							<tr><td width="200px">DATE OF ISSUE</td> <td>[time2text(world.realtime, "MM/DD/53 hh:mm")]</td></tr>
							</table>
							------------------------------------------------------
							<table width="365px">
							<tr><td width="200px">RECIPIENT</td> <td>[ticket_target]</td></tr>
							<tr></tr>
							<tr><td width="200px">ISSUER</td> <td>[issuer]</td></tr>
							<tr><td width="200px">ASSIGNMENT</td> <td>[issuer_job]</td></tr>
							</table>
							------------------------------------------------------
							<table width="365px">
							<tr><td width="100px">REASON</td> <td>[ticket_reason]</td></tr>
							</table>
							------------------------------------------------------
							<center>
							<font size="3">[pick(ticket_flavor)]</font>
							<table height="50px" cellspacing="2px">
							<tr>[random_barcode(20,"453425")]</td></tr>
							</table>
							</center>"}

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
			p.color = "#FFE9AD"

		return T.target_byond_key

/obj/item/device/ticket_writer/crust
	name = "crusty old security TicketWriter 1000"
	desc = "An old TicketWriter model held together by hopes and dreams alone."
	paper_icon_state = "paper_burned"

/obj/item/device/ticket_writer/nanotrasen
	name = "inspector TicketWriter 4000"
	desc = "A device used by NanoTrasen inspectors to issue tickets to poorly performing crew. The keys on it are rather worn down."
	icon_state = "ticketwriter_nt"
	corporate_rank = "Nanotrasen Internal Affairs"

