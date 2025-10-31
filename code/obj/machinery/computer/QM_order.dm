/obj/machinery/computer/ordercomp
	name = "supply request console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMreq"
	var/temp = null
	var/obj/item/card/id/scan = null
	var/console_location = null
	circuit_type = /obj/item/circuitboard/qmorder

	light_r =1
	light_g = 0.7
	light_b = 0.03

	New()
		..()
		console_location = get_area(src)
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

/obj/machinery/computer/ordercomp/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"
/obj/machinery/computer/ordercomp/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "qmreq1"

/obj/machinery/computer/ordercomp/attack_hand(var/mob/user)
	if(..())
		return

	if (!global.QM_CategoryList)
		message_coders("ZeWaka/QMCategories: QMcategoryList was not found!")

	src.add_dialog(user)
	var/dat
	if (src.temp)
		dat = src.temp
	else

		dat += {"<B>Shipping Budget:</B> [wagesystem.shipping_budget] Credits<BR>
		<B>Scanned Card:</B> <A href='byond://?src=\ref[src];card=1'>([src.scan])</A><BR><HR>"}
		if(src.scan != null)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if(account)
				dat += "<B>Credits on Account:</B> [account["current_money"]] Credits<BR><HR>"
		dat += {"<A href='byond://?src=\ref[src];viewrequests=1'>View Requests</A><BR>
		<A href='byond://?src=\ref[src];order=1'>Request Items</A><BR>
		<A href='byond://?src=\ref[src];buypoints=1'>Contribute to Shipping Budget</A><BR>
		<A href='byond://?action=mach_close&window=computer'>Close</A>"}
		//<A href='byond://?src=\ref[src];vieworders=1'>View Approved Orders</A><BR><BR> This right here never worked anyway.
	user.Browse(dat, "title=Supply Request Console;window=computer_[src];size=575x450")
	onclose(user, "computer_[src]")
	return

/obj/machinery/computer/ordercomp/attackby(var/obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		boutput(user, SPAN_NOTICE("You swipe the ID card."))
		var/datum/db_record/account = null
		account = FindBankAccountByName(id_card.registered)
		if(account)
			var/enterpin = user.enter_pin("Order Console")
			if (enterpin == id_card.pin)
				boutput(user, SPAN_NOTICE("Card authorized."))
				src.scan = id_card
				src.Attackhand(user) // refresh console
			else
				boutput(user, SPAN_ALERT("PIN incorrect."))
				src.scan = null
		else
			boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
			src.scan = null
	else
		..()

/obj/machinery/computer/ordercomp/proc/view_requests()
	. = "<B>Current Requests:</B><BR><BR>"
	for(var/S in shippingmarket.supply_requests)
		var/datum/supply_order/SO = S
		. += "[SO.object.name] requested by [SO.orderedby] from [SO.console_location].<BR>"
	. += "<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"

/obj/machinery/computer/ordercomp/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

	if (href_list["order"])
		var/datum/db_record/account = null
		if(src.scan) account = FindBankAccountByName(src.scan.registered)
		src.temp = "<a name='top' id='top'></a><A href='byond://?src=\ref[src];mainmenu=1'>Main Menu</A> • "
		if(account)
			src.temp += "<B>Credits on Account:</B> [account["current_money"]] Credits<BR><HR>"
		else
			src.temp += "<B>Shipping Budget:</B> [wagesystem.shipping_budget] Credits<BR><HR>"
		src.temp += "<B>Please select the Supply Package you would like to request:</B><BR><BR>"
		src.temp += search_snippet()
		src.temp += "<BR><BR>"
		src.temp += {"
		<style>
			table {border-collapse: collapse;}
			th,td {padding: 5px;}
			.categoryGroup {padding:5px; margin-bottom:8px; border:1px solid black}
			.categoryGroup .title {display:block; color:white; padding: 2px 5px; margin: -5px -5px 2px -5px;
															width: auto;
															height: auto; /* MAXIMUM COMPATIBILITY ACHIEVED */
															filter: glow(color=black,strength=1);
															text-shadow: -1px -1px 0 #000,
																						1px -1px 0 #000,
																						-1px 1px 0 #000,
																						 1px 1px 0 #000;}
		</style>
		<script type="text/javascript">
			function scroll_to_id(id) {
				var element = document.getElementById(id);
				if (element) {
					var elementTop = element.getBoundingClientRect().top;
					var currentTop = window.pageYOffset || document.documentElement.scrollTop;
					var targetTop = elementTop + currentTop;

					// Smooth scroll polyfill for IE11
					function smoothScrollTo(endX, endY, duration) {
						var startX = window.scrollX || window.pageXOffset;
						var startY = window.scrollY || window.pageYOffset;
						var startTime = new Date().getTime();

						function easeInOutQuad(t, b, c, d) {
							t /= d / 2;
							if (t < 1) return c / 2 * t * t + b;
							t--;
							return -c / 2 * (t * (t - 2) - 1) + b;
						}

						function scroll() {
							var currentTime = new Date().getTime();
							var time = Math.min(1, ((currentTime - startTime) / duration));
							var timeFunction = easeInOutQuad(time, 0, 1, 1);
							window.scrollTo(
								Math.ceil((timeFunction * (endX - startX)) + startX),
								Math.ceil((timeFunction * (endY - startY)) + startY)
							);

							if (Math.abs(window.pageYOffset - endY) > 1) {
								requestAnimationFrame(scroll);
							}
						}

						scroll();
					}

					smoothScrollTo(0, targetTop, 600); // 600ms for the smooth scroll duration
				}
			}
		</script>
		"}

		var/buy_list = ""
		var/catnum = 0
		for (var/foundCategory in global.QM_CategoryList)
			src.temp += "[catnum ? " &middot; " : ""] <a href='#' onclick='scroll_to_id(\"category-[catnum]\"); return false;' style='white-space: nowrap; display: inline-block; margin: 0 0.2em;'>[foundCategory]</a> "

			buy_list += {"<div class='categoryGroup' id='[foundCategory]' style='border-color:#666'>
							<a name='category-[catnum]' id='category-[catnum]'></a><b class='title' style='background:#ccc'>[foundCategory]</b>"}
			buy_list += "<table border=1>"
			buy_list += "<tr><th>Item</th><th>Cost (Credits)</th><th>Contents</th></tr>"

			for (var/datum/supply_packs/S in qm_supply_cache) //yes I know what this is doing, feel free to make it more perf-friendly
				if(S.syndicate || S.hidden) continue
				if (S.category == foundCategory)
					buy_list += "<tr class='supply-package'><td><a href='byond://?src=\ref[src];doorder=\ref[S]'><b><u>[S.name]</u></b></a></td><td>[S.cost]</td><td>[S.desc]</td></tr>"
				LAGCHECK(LAG_LOW)

			buy_list += "</table></div><a href='#' onclick='scroll_to_id(\"top\"); return false;' style='white-space: nowrap; display: inline-block; margin: 0 0.2em;'>Back to top</a><hr>"
			catnum++

		src.temp += "<BR><HR><BR>"
		src.temp += buy_list
		src.temp += "<br><A href='byond://?src=\ref[src];mainmenu=1'>Main Menu</A><br>"

	else if (href_list["doorder"])
		var/datum/db_record/account = null
		if(src.scan) account = FindBankAccountByName(src.scan.registered)
		var/datum/supply_order/O = new/datum/supply_order ()
		var/datum/supply_packs/P = locate(href_list["doorder"])
		if(istype(P))
			// The order computer has no emagged / other ability to display hidden or syndicate packs.
			// It follows that someone's being clever if trying to order either of these items
			if(P.syndicate || P.hidden)
				// Get that jerk
				if (usr in range(1))
					//Check that whoever's doing this is nearby - otherwise they could gib any old scrub
					trigger_anti_cheat(usr, "tried to href exploit order packs on [src]")

				return
			if(account) //buy it with their money
				if(account["current_money"] < P.cost)
					boutput(usr, "Insufficient funds in account. Log out to request purchase using supply budget.")
				else
					account["current_money"] -= P.cost
					O.object = P
					if (account["pda_net_id"])
						O.address = account["pda_net_id"]
					O.orderedby = usr.name
					O.console_location = src.console_location
					var/obj/storage/S = O.create(usr)
					shippingmarket.receive_crate(S)
					logTheThing(LOG_STATION, usr, "ordered a [P.name] at [log_loc(src)].")
					boutput(usr, "Your order of [P.name] has been processed and will be delivered shortly.")
					shippingmarket.supply_history += "[O.object.name] ordered by [O.orderedby] for [P.cost] credits from personal account.<BR>"

					// pda alert ////////
					var/datum/signal/pdaSignal = get_free_signal()
					pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_SHIPPING), "sender"="00000000", "message"="Notification: [O.object] ordered by [O.orderedby] using personal account at [O.console_location].")
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")
					//////////////////
			else
				O.object = P
				O.orderedby = usr.name

				var/list/pda_list = list()

				// check visible PDAs
				var/mob/living/carbon/human/H = usr
				if(istype(H))
					pda_list += H.get_slot(SLOT_L_HAND)
					pda_list += H.get_slot(SLOT_R_HAND)
					pda_list += H.get_slot(SLOT_WEAR_ID)
					pda_list += H.get_slot(SLOT_BELT)

				for (var/obj/item/device/pda2/pda in pda_list)
					if (pda.host_program.message_on && pda.owner)
						O.address = pda.net_id
						break

				O.console_location = src.console_location
				shippingmarket.supply_requests += O
				boutput(usr, "Request for [P.name] sent to Supply Console. The Quartermasters will process your request as soon as possible.")

				// pda alert ////////
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_CARGOREQUEST), "sender"="00000000", "message"="Notification: [O.object] requested by [O.orderedby] at [O.console_location].")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")
				//////////////////
		else
			boutput(usr, "Communications error with central supply console. Please notify a Certified Service Technician.")
		src.Attackhand(usr) // refresh console

	else if (href_list["viewrequests"])
		src.temp += view_requests()

	else if (href_list["card"])
		if (src.scan) src.scan = null
		else
			var/obj/item/card/id/id_card = get_id_card(usr.equipped())
			if (istype(id_card))
				boutput(usr, SPAN_NOTICE("You swipe the ID card."))
				var/datum/db_record/account = null
				account = FindBankAccountByName(id_card.registered)
				if(account)
					var/enterpin = usr.enter_pin("Order Console")
					if (enterpin == id_card.pin)
						boutput(usr, SPAN_NOTICE("Card authorized."))
						src.scan = id_card
						src.Attackhand(usr) // refresh console
					else
						boutput(usr, SPAN_ALERT("PIN incorrect."))
						src.scan = null
				else
					boutput(usr, SPAN_ALERT("No bank account associated with this ID found."))
					src.scan = null
			else
				src.temp = "There is no card scan to log out.<BR>"
				src.temp += "<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["buypoints"])

		if (src.scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (!account)
				src.temp = {"<B>ERROR:</B> No bank account associated with this ID card found.<BR>
							<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"}
			else
				src.temp = {"<B>Contribute to Shipping Budget</B><BR>
							<B>Shipping Budget:</b> [wagesystem.shipping_budget] Credits<BR>
							<B>Credits in Account:</B> [account["current_money"]] Credits<BR><HR>
							<A href='byond://?src=\ref[src];buy=1'>Make Transaction</A><BR>
							<A href='byond://?src=\ref[src];mainmenu=1'>Cancel Transfer</A>"}
		else
			src.temp = {"You need to swipe an ID card first!<BR>
						<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"}

	else if (href_list["buy"])
		if (src.scan)
			if (src.scan.registered in FrozenAccounts)
				boutput(usr, SPAN_ALERT("Your account cannot currently be liquidated due to active borrows."))
				return
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (!account)
				src.temp = {"<B>ERROR:</B> No bank account associated with this ID card found.<BR>
							<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"}
			var/transaction = input("How much?", "Shipping Budget", null, null)  as null|num
			if (account["current_money"] >= transaction && (transaction > 0) && isnum_safe(transaction))
				account["current_money"] -= transaction
				wagesystem.shipping_budget += transaction
				src.temp = "Transaction successful. Thank you for your patronage.<BR>"
				////// PDA NOTIFY/////
				var/datum/signal/pdaSignal = get_free_signal()
				pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_SHIPPING), "sender"="00000000", "message"="Notification: [transaction] credits transferred to shipping budget from [src.scan.registered].")
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal, null, "pda")
				//////////
				src.temp += "<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"
			else
				src.temp = {"<B>ERROR:</B> Insufficient funds. Purchase cancelled.<BR>
							<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"}
		else
			src.temp = {"<B>ERROR:</B> Login removed mid-transaction. Purchase cancelled.<BR>
							<BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"}

	else if (href_list["mainmenu"])
		src.temp = null
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return
