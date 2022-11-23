#define ORDER_LABEL_MAX_LEN 32 // The "order label" refers to the label you can specify when ordering something through cargo.

/datum/rockbox_globals
	var/const/rockbox_standard_fee = 5
	var/rockbox_client_fee_min = 1
	var/rockbox_client_fee_pct = 10
	var/rockbox_premium_purchased = 0

var/global/datum/rockbox_globals/rockbox_globals = new /datum/rockbox_globals

/proc/build_qm_categories()
	QM_CategoryList.Cut()
	if (!global.qm_supply_cache)
		message_coders("ZeWaka/QMCategories: QM Supply Cache was not found!")
	for(var/datum/supply_packs/S in qm_supply_cache )
		if(S.syndicate || S.hidden) continue //They don't have their own categories anyways.
		if (S.category)
			if (!(global.QM_CategoryList.Find(S.category)))
				QM_CategoryList += S.category
				// gonna be real here it seems more useful to have the oft-used stuff at the top.
				//global.QM_CategoryList.Insert(1,S.category) //So Misc. is not #1, reverse ordering.

/datum/cdc_contact_analysis
	var/uid = 0
	var/time_factor = 0
	var/time_done = 0
	var/begun_at = 0
	var/description_available = 0
	var/cure_available = 0
	var/cure_cost = 0
	var/name = ""
	var/desc = ""
	var/datum/pathogen/assoc_pathogen = null

/datum/cdc_contact_controller
	var/list/analysis_by_uid = list()
	var/list/ready_to_analyze = list()
	var/list/completed_analysis = list()
	var/datum/cdc_contact_analysis/current_analysis = null
	var/datum/pathogen/working_on = null
	var/working_on_time_factor = 0
	var/next_cure_batch = 0
	var/batches_left = 0
	var/next_crate = 0
	var/last_switch = 0

	New()
		..()
		processing_items.Add(src)

	proc/process()
		if (next_cure_batch < ticker.round_elapsed_ticks && working_on)
			var/obj/storage/crate/biohazard/B = new
			var/count = rand(3,6)
			for (var/i = 0, i < count, i++)
				new/obj/item/serum_injector(B, working_on, 1, 0)
			B.name = "CDC Pathogen cure crate ([working_on.name])"
			shippingmarket.receive_crate(B)
			batches_left--
			if (batches_left)
				next_cure_batch = round(rand(175, 233) / 100 * working_on_time_factor) + ticker.round_elapsed_ticks
			else
				working_on = null

	proc/receive_pathogen_samples(obj/storage/crate/biohazard/cdc/sell_crate)
		for (var/R in sell_crate)
			var/list/patho = null
			if (istype(R, /obj/item/reagent_containers))
				var/obj/item/reagent_containers/RC = R
				patho = RC.reagents.aggregate_pathogens()
				qdel(RC)
			else if (ishuman(R)) // heh
				var/mob/living/carbon/human/H = R
				patho = H.reagents.aggregate_pathogens()
				H.ghostize()
				qdel(H)
			else
				qdel(R)
				continue
			for (var/uid in patho)
				if (!(uid in src.analysis_by_uid))
					var/datum/pathogen/P = patho[uid]
					var/datum/cdc_contact_analysis/D = new
					D.uid = uid
					var/sym_count = clamp(length(P.effects), 2, 7)
					D.time_factor = sym_count * rand(10, 15) // 200, 600
					D.cure_cost = sym_count * rand(25, 40) // 2100, 4300
					D.name = P.name
					var/rating = max(P.advance_speed, P.suppression_threshold, P.spread)
					var/ds = "weak"
					switch (P.stages)
						if (4)
							ds = "potent"
						if (5)
							ds = "deadly"
					var/df = "a relatively one-sided"
					switch (sym_count)
						if (3 to 4)
							df = "a somewhat colorful"
						if (5 to 6)
							df = "a rather diverse"
						if (7)
							df = "an incredibly symptomatic"
					D.desc = "It is [df] pathogen with a hazard rating of [rating]. We identify it to be a [ds] organism made up of [P.body_type.plural]. [P.suppressant.desc]"
					var/datum/pathogen/copy = new /datum/pathogen
					copy.setup(0, P, 0, null)
					D.assoc_pathogen = copy
					src.analysis_by_uid[uid] = D
					src.ready_to_analyze += D
			qdel(sell_crate)
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"=list(MGD_CARGO, MGA_SHIPPING), "sender"="00000000", "message"="Notification: Pathogen sample crate delivered to the CDC.")
		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

var/global/datum/cdc_contact_controller/QM_CDC = new()

/obj/machinery/computer/supplycomp
	name = "Quartermaster's Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "QMcom"
	req_access = list(access_supply_console)
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL
	circuit_type = /obj/item/circuitboard/qmsupply
	var/temp = null
	var/last_cdc_message = null
	var/hacked = 0
	var/tradeamt = 1
	var/in_dialogue_box = 0
	var/printing = 0
	var/obj/item/card/id/scan = null
	var/list/datum/supply_pack

	//These will be used to not update the price list needlessly
	var/last_market_update = -INFINITY
	var/price_list = null

	light_r =1
	light_g = 0.7
	light_b = 0.03

	New()
		..()
		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, FREQ_STATUS_DISPLAY)

/obj/machinery/computer/supplycomp/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if(!hacked)
		if(user)
			boutput(user, "<span class='notice'>The intake safety shorts out. Special supplies unlocked.</span>")
		shippingmarket.launch_distance = 200 // dastardly
		src.hacked = 1
		return 1
	return 0

/obj/machinery/computer/supplycomp/demag(var/mob/user)
	if(!hacked)
		return 0
	if(user)
		boutput(user, "<span class='notice'>Treacherous supplies removed.</span>")
	src.hacked = 0
	return 1

/obj/machinery/computer/supplycomp/attackby(I, mob/user)
	if(!istype(I,/obj/item/card/emag))
		//I guess you'll wanna put the emag away now instead of getting a massive popup
		..()

/obj/machinery/computer/supplycomp/attack_hand(var/mob/user)
	if(!src.allowed(user))
		boutput(user, "<span class='alert'>Access Denied.</span>")
		return

	if(..())
		return

	var/timer = shippingmarket.get_market_timeleft()
	src.add_dialog(user)
	// post_signal("supply") // I'm pretty sure this doesn't do anything except create lag every time someone clicks it
	var/HTML

	var/header_thing_chui_toggle = (user.client && !user.client.use_chui) ? {"
		<style type='text/css'>
			body {
				font-family: Verdana, sans-serif;
				background: #222228;
				color: #ddd;
				}
			strong {
				color: #fff;
				}
			a {
				color: #6ce;
				text-decoration: none;
				}
			a:hover, a:active {
				color: #cff;
				}
			#topBar {
				top: 0;
				left: 0;
				right: 0;
				background: #433;
				box-shadow: 0 -2px 12px 4px black;
				}
			img, a img {
				border: 0;
				}
		</style>
	"} : {"
	<style type='text/css'>
		/* when chui is on */
		#topBar {
			top: 46px;
			left: 4px;
			right: 10px;
			background: #222228;
			}
		#qmquickjump { display: none; }
	</style>
	"}

	// Always-visible main menu.
	HTML += {"
[header_thing_chui_toggle]
	<title>Quartermaster Console</title>
	<style type="text/css">
		.qmtable {
			width: 100%;
			}
		.qmtable th, td {
			padding: 0.1em 0.5em;
			margin: 0.1em 0.2em;
			border-bottom: 1px solid #888;
			}

		.qmtable th {
			text-align: left;
			color: white;
			}

		.qmtable thead th {
			background: #344556;
			text-align: center;
			font-weight: bold;
			}

		.qmtable .noborder {
			border: 0;
			}

		.qmtable .itemtop {
			padding-top: 0.6em;
			color: #ccc;
			}
		.qmtable .itemdesc {
			padding-bottom: 0.9em;
			font-size: 90%;
			color: #ccc;
			}

		.qmtable .row0 {
			background: #222228;
			}

		.qmtable .row1 {
			background: #181820;
			}

		.categoryGroup {
			padding: 5px;
			margin-bottom: 8px;
			border: 1px solid black
			}

		.categoryGroup .title {
			display: block;
			color: white;
			padding: 2px 5px;
			margin: -5px -5px 2px -5px;
			width: auto;
			height: auto;
			/* MAXIMUM COMPATIBILITY ACHIEVED */
			filter: glow(color=black, strength=1);
			text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
			}

		#topBar {
			position: fixed;
			border-bottom: 1px solid black;
			}

		#topBar, #fakeTopBar {
			padding: 0.2em 0.5em;
			}

		#fakeTopBar {
			// position: sticky but shitty
			visibility: hidden;
			margin-bottom: 0.5em;
			opacity: 0;
			}

		.shoplist li {
			padding: 0.7em 0.3em;
			border-top: 1px dotted #bbb;
			border-bottom: 1px dotted #bbb;
			}

		.shoplist {
			list-style: none;
			margin: 0;
			padding: 0.5em 0;
			}

		hr {
			border: none;
			border-top: 1px dotted #bbb;
			color: #bbb;
			text-align: center;
			height: 1px;
			padding: 0.5em 1em;
			}

		a.qmbutton {
			display: inline-block;
			text-align: center;
			padding: 0.25em 1em;
			background: #114466;
			border: 2px outset #468;
			border-radius: 4px;
			color: white;
			}

		a.qmbutton:hover, a.qmbutton:active {
			background: #226677;
			border: 2px outset #7bd;
			}

		h1, h2, h3, h4, h5, h6 {
			margin: 0.2em 0;
			background: #111520;
			text-align: center;
			padding: 0.2em;
			border-top: 1px solid #456;
			border-bottom: 1px solid #456;
		}

		h2 { font-size: 130%; }
		h3 { font-size: 110%; margin-top: 1em; }

	</style>
	<script type="text/javascript">
	// apparently just normal ol "a href=#fuck" links dont work in byond
	// im at a loss for words
	function are_you_fucking_shitting_me(h) {
		var top = document.getElementById(h).offsetTop;
		window.scrollTo(0, top - 65); /* ehhhhHHHHHHHHhhhhhhhhhhh */
	}

	// lol because chui uses its own shitty inner scrolling crap this doesnt work OH WELL
	// if u use chui u get nothing good day sir.
	</script>

	<div id="fakeTopBar">
		<div style='float: right;'>
			Market updates in <strong>99:99</strong>
		</div>
		Budget: <strong>XXXXXXXX</strong> Credits
		<div style='clear: both; text-align: center; font-weight: bold; padding: 0.2em;'>
			Requests &middot;
			Place Order &middot;
			Order History &middot;
			Shipping Market
			<br>
			Contact CDC &middot;
			Traders
			Requisitions
			RockBox Controls
		</div>
	</div>
	<div id="topBar">
		<div style='float: right;'>
			Market updates in <strong>[timer ? timer : "...uh"]</strong>
		</div>
		Budget: <strong>[wagesystem.shipping_budget]</strong> Credits
		<div style='clear: both; text-align: center; font-weight: bold; padding: 0.2em;'>
			<a href='[topicLink("requests")]'>Requests ([shippingmarket.supply_requests.len])</a> &bull;
			<a href='[topicLink("order")]'>Place Order</a> &bull;
			<a href='[topicLink("order_history")]'>Order History</a> &bull;
			<a href='[topicLink("viewmarket")]'>Shipping Market</a>
			<br>
			<a href='[topicLink("contact_cdc")]'>Contact CDC</a> &bull;
			<a href='[topicLink("trader_list")]'>Traders</a> &bull;
			<a href='[topicLink("requis_list")]'>Requisitions</a> &bull;
			<a href='[topicLink("rockbox_controls")]'>Rockbox Controls</a>
		</div>
	</div>

	"}


	if (src.temp)
		HTML += src.temp

	// i have no idea how chui ever worked with this because [src] evaluates to "Quartermaster's Console"
	// which as [src] turns into ... location = '.chui onclose Quartermaster's Console'
	// which as you can probably guess is a syntax error. i have no idea why this only started
	// happening halfway into this but: chui!!!!!!!!!!!!!!!!!!
	user.Browse(HTML, "window=qmComputer_\ref[src];title=Quartermaster Console;size=575x625;")
	onclose(user, "qmComputer_\ref[src]")
	return

// I know I'm repeating myself with this showing up in a bunch of places;
// part of it is that there's no real good way to genericize this yet,
// and part of it is that chui already sort of kind of eh maybe does it
/obj/machinery/computer/supplycomp/proc/topicLink(action, subaction, var/list/extra)
	return "?src=\ref[src]&action=[action][subaction ? "&subaction=[subaction]" : ""]&[extra && islist(extra) ? list2params(extra) : ""]"


/obj/machinery/computer/supplycomp/proc/set_cdc()
	src.temp = "<h2>Center for Disease Control</h2>"
	src.temp += "<I>Greetings, [station_name]; how can we help you today?</I><br><br>"

	if (src.last_cdc_message)
		src.temp += "[last_cdc_message]<br><br>"

	src.temp += "<B>Pathogen analysis services</B><br>"
	src.temp += "To send us pathogen samples, you can <A href='[topicLink("req_biohazard_crate")]'>requisition a biohazardous materials crate</a> from us for 5 credits.<br>"
	if (!QM_CDC.current_analysis)
		src.temp += "Our researchers currently have free capacity to analyze pathogen and blood samples for you.<br>"
		if (length(QM_CDC.ready_to_analyze))
			src.temp += "We received your packages and are ready to <A href='[topicLink("cdc_analyze")]'>analyze some samples</A>. It will cost you, but hey, you would like to survive, right?<br>"
		else
			src.temp += "We have no unanalyzed pathogen samples from your station.<br>"
	else
		src.temp += "We're currently analyzing the pathogen sample [QM_CDC.current_analysis.name]. We can <A href='[topicLink("cdc_analyze")]'>analyze something different</A>, if you want."
		if (QM_CDC.current_analysis.description_available <= ticker.round_elapsed_ticks)
			src.temp += "Here's what we have so far: <br>[QM_CDC.current_analysis.desc]<br>"
			if (QM_CDC.current_analysis.cure_available <= ticker.round_elapsed_ticks)
				src.temp += "We've also discovered a method to synthesize a cure for this pathogen.<br>"
				QM_CDC.completed_analysis += QM_CDC.current_analysis
				QM_CDC.current_analysis = null
			else
				var/CA = round((QM_CDC.current_analysis.cure_available - ticker.round_elapsed_ticks) / 600)
				src.temp += "We're really close to discovering a cure as well. It should be available a few [CA > 0 ? "minutes" : "seconds"].<br>"
		else
			var/DA = round((QM_CDC.current_analysis.description_available - ticker.round_elapsed_ticks) / 600)
			src.temp += "We cannot tell you anything about this pathogen so far. Check back in [DA > 1 ? "[DA] minutes" : (DA > 0 ? "1 minute" : "a few seconds")].<br>"
	src.temp += "<br>"
	src.temp += "<B>Pathogen cure services</B><br>"
	if (length(QM_CDC.working_on))
		src.temp += "We are currently working on [QM_CDC.batches_left] batch[QM_CDC.batches_left > 1 ? "es" : null] of cures for the [QM_CDC.working_on.name] pathogen. The crate will be delivered soon."
	else if (length(QM_CDC.completed_analysis))
		src.temp += "We have cures ready to be synthesized for [length(QM_CDC.completed_analysis)] pathogen[length(QM_CDC.completed_analysis) > 1 ? "s" : null].<br>"
		src.temp += "You can requisition in batches. The more batches you order, the less time per batch it takes for us to deliver and the less credits per batch it will cost you.<br>"
		src.temp += "<table style='width:100%; border:none; cell-spacing: 0px'>"
		for (var/datum/cdc_contact_analysis/analysis in QM_CDC.completed_analysis)
			var/one_cost = analysis.cure_cost
			var/five_cost = analysis.cure_cost * 4
			var/ten_cost = analysis.cure_cost * 7
			src.temp += "<tr><td><b>[analysis.assoc_pathogen.name]</b><td><a href='[topicLink("batch_cure", "\ref[analysis]", list(count = "1"))]'>1 batch for [one_cost] credits</a></td><td><a href='[topicLink("batch_cure", "\ref[analysis]", list(count = "5"))]'>5 batches for [five_cost] credits</a></td><td><a href='[topicLink("batch_cure", "\ref[analysis]", list(count = "10"))]'>10 batches for [ten_cost] credits</a></td></tr>"
			src.temp += "<tr><td colspan='4' style='font-style:italic'>[analysis.desc]</td></tr>"
			src.temp += "<tr><td colspan='4'>&nbsp;</td></tr>"
		src.temp += "</table><br>"
	else
		src.temp += "We have no pathogen samples from your station that we can cure, yet.<br>"
	src.temp += "<br>"
	src.temp += "<A href='[topicLink("mainmenu")]'>Main Menu</A>"


/obj/machinery/computer/supplycomp/proc

	order_menu(subaction, href_list)
		. = ""

		switch (subaction)

			// Build list of possible packages to order.
			if (null, "list")

				. += "<h2>Order Supplies</h2><div style='text-align: center;' id='qmquickjump'>"
				var/ordershit = ""
				var/catnum = 0
				if (!global.QM_CategoryList)
					message_coders("ZeWaka/QMCategories: QMcategoryList was not found for [src]!")
				for (var/foundCategory in global.QM_CategoryList)
					//var/categorycolor = random_color() //I must say, I simply love the colors this generates.

					. += "[catnum ? " &middot; " : ""] <a href='javascript:are_you_fucking_shitting_me(\"category-[catnum]\");' style='white-space: nowrap; display: inline-block; margin: 0 0.2em;'>[foundCategory]</a> "

					ordershit += {"
			<a name='category-[catnum]' id='category-[catnum]'></a><h3>[foundCategory]</h3>
				<table class='qmtable'>
					<thead>
						<tr>
							<th style='width: 80%;'>Item</th>
							<th style='width: 20%;'>Cost</th>
						</tr>
					</thead>
					<tbody>
						"}
					catnum++

					var/rownum = 0
					for (var/datum/supply_packs/S in qm_supply_cache) //yes I know what this is doing, feel free to make it more perf-friendly
						if((S.syndicate && !src.hacked) || S.hidden) continue
						if (S.category == foundCategory)
							ordershit += {"
								<tr class='row[rownum % 2]'>
									<th class='noborder itemtop'><a href='?src=\ref[src];action=order;subaction=buy;what=\ref[S]'>[S.name]</a></td>
									<th class='noborder itemtop' style='text-align: right;'>[S.cost]</td>
								</tr>
								<tr class='row[rownum % 2]'>
									<td colspan='2' class='itemdesc'>[S.desc]</td>
								</tr>
								"}
							rownum++
						LAGCHECK(LAG_LOW)

					ordershit += "</tbody></table>"

				. += "</div>[ordershit]"
				return .


			if ("buy")
				// Handles purchasing items...

				if(istype(locate(href_list["what"]), /datum/supply_order))
					//If this is a supply order we came from the request approval form
					var/datum/supply_order/O = locate(href_list["what"])
					var/datum/supply_packs/P = O.object
					shippingmarket.supply_requests -= O
					if(wagesystem.shipping_budget >= P.cost)
						O.object = P
						O.orderedby = usr.name
						var/default_comment = ""
						O.comment = tgui_input_text(usr, "Comment:", "Enter comment", default_comment, multiline = TRUE, max_length = ORDER_LABEL_MAX_LEN, allowEmpty = TRUE)
						if (isnull(O.comment))
							return .("list") // The user cancelled the order
						O.comment = html_encode(O.comment)
						wagesystem.shipping_budget -= P.cost
						var/obj/storage/S = O.create(usr)
						shippingmarket.receive_crate(S)
						logTheThing(LOG_STATION, usr, "ordered a [P.name] at [log_loc(src)].")
						if(O.comment && O.comment != default_comment)
							phrase_log.log_phrase("order-comment", O.comment, no_duplicates=TRUE)
						shippingmarket.supply_history += "[O.object.name] ordered by [O.orderedby] for [P.cost] credits. Comment: [O.comment]<br>"
						. = {"<strong>Thanks for your order.</strong>"}
					else
						. = {"<strong>Insufficient funds in shipping budget.</strong>"}
				else
					//Comes from the orderform

					var/datum/supply_order/O = new/datum/supply_order ()
					var/datum/supply_packs/P = locate(href_list["what"])
					if(istype(P))

						// The order computer has no emagged / other ability to display hidden or syndicate packs.
						// It follows that someone's being clever if trying to order either of these items
						if((P.syndicate && !src.hacked) || P.hidden)
							// Get that jerk
							if (usr in range(1))
								//Check that whoever's doing this is nearby - otherwise they could gib any old scrub
								trigger_anti_cheat(usr, "tried to href exploit order packs on [src]")

							return

						if(wagesystem.shipping_budget >= P.cost)
							O.object = P
							O.orderedby = usr.name
							var/default_comment = ""
							O.comment = tgui_input_text(usr, "Comment:", "Enter comment", default_comment, multiline = FALSE, max_length = ORDER_LABEL_MAX_LEN, allowEmpty = TRUE)
							if (isnull(O.comment))
								return .("list") // The user cancelled the order
							O.comment = html_encode(O.comment)
							wagesystem.shipping_budget -= P.cost
							var/obj/storage/S = O.create(usr)
							shippingmarket.receive_crate(S)
							logTheThing(LOG_STATION, usr, "ordered a [P.name] at [log_loc(src)].")
							if(O.comment && O.comment != default_comment)
								phrase_log.log_phrase("order-comment", O.comment, no_duplicates=TRUE)
							shippingmarket.supply_history += "[O.object.name] ordered by [O.orderedby] for [P.cost] credits. Comment: [O.comment]<br>"
							. = {"<strong>Thanks for your order.</strong>"}
						else
							. = {"<strong>Insufficient funds in shipping budget.</strong>"}


				return . + .("list")


	order_history(subaction, href_list)
		. = "<h2>Order History</h2>"
		for(var/S in shippingmarket.supply_history)
			. += S

		return .


	requests(subaction, href_list)
		switch (subaction)
			if (null, "list")
				. = "<h2>Current Requests</h2><br><a href='[topicLink("requests", "clear")]'>Clear all</a><br><ul>"
				for(var/datum/supply_order/SO in shippingmarket.supply_requests)
					. += "<li>[SO.object.name], requested by [SO.orderedby] from [SO.console_location]. Price: [SO.object.cost] <a href='[topicLink("order", "buy", list(what = "\ref[SO]"))]'>Approve</a> <a href='[topicLink("requests", "remove", list(what = "\ref[SO]"))]'>Deny</a></li>"

				. += {"</ul>"}
				return .

			if ("remove")
				shippingmarket.supply_requests -= locate(href_list["what"])
				// todo: fancy "your request got denied, doofus" message?
				. = {"Request denied."}

			if ("clear")
				shippingmarket.supply_requests = null
				shippingmarket.supply_requests = new/list()
				// todo: message people that their stuff's been denied?
				. = {"All requests have been cleared."}

		return .

	rockbox_controls(subaction, href_list)
		switch (subaction)
			if (null, "list")
				. = {"<h2>Rockbox™ Ore Cloud Storage Service Settings:</h2><ul><br>
					<B>Rockbox™ Fees:</B> [!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0][CREDIT_SIGN] per ore [!rockbox_globals.rockbox_premium_purchased ? "(Purchase our <A href='[topicLink("rockbox_controls", "premium_service")]'>Premium Service</A> to remove this fee!)" : ""]<BR>
					<B>Client Quartermaster Transaction Fee:</B> <A href='[topicLink("rockbox_controls", "fee_pct")]'>[rockbox_globals.rockbox_client_fee_pct]%</A><BR>
					<B>Client Quartermaster Transaction Fee Per Ore Minimum:</B> <A href='[topicLink("rockbox_controls", "fee_min")]'>[rockbox_globals.rockbox_client_fee_min][CREDIT_SIGN]</A><BR>
					</ul>"}

				return

			if ("premium_service")
				var/response = ""
				response = tgui_alert(usr, "Would you like to purchase the Rockbox™ Premium Service for 10000 Credits?", "Rockbox™ Premium Service", list("Yes", "No"))
				if(response == "Yes")
					if(wagesystem.shipping_budget >= 10000)
						wagesystem.shipping_budget -= 10000
						rockbox_globals.rockbox_premium_purchased = 1
						. = {"Congratulations on your purchase of RockBox™ Premium!"}
					else
						. = {"Not enough money in the budget!"}


			if ("fee_pct")
				var/fee_pct = null
				fee_pct = input(usr,"What fee percent would you like to set? (Min 0)","Fee Percent per Transaction:",null) as num
				fee_pct = max(0,fee_pct)
				rockbox_globals.rockbox_client_fee_pct = fee_pct
				. = {"Fee Percent per Transaction is now [rockbox_globals.rockbox_client_fee_pct]%"}

			if ("fee_min")
				var/fee_min = null
				fee_min = input(usr,"What fee min would you like to set? (Min 0)","Minimum Fee per Transaction in Credits:",) as num
				fee_min = max(0,fee_min)
				rockbox_globals.rockbox_client_fee_min = fee_min
				. = {"Minimum Fee per Transaction is now [rockbox_globals.rockbox_client_fee_min][CREDIT_SIGN]"}

		return


/obj/machinery/computer/supplycomp/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		src.add_dialog(usr)

	var/subaction = (href_list["subaction"] ? href_list["subaction"] : null)

	switch (href_list["action"])
		if ("order")
			src.temp = order_menu(subaction, href_list)

		if ("order_history")
			src.temp = order_history(subaction, href_list)

		if ("requests")
			src.temp = requests(subaction, href_list)

		if("rockbox_controls")
			src.temp = rockbox_controls(subaction,href_list)

		if ("viewmarket")
			if(shippingmarket.last_market_update != last_market_update) //Okay, the market has updated and we need a new price list
				last_market_update = shippingmarket.last_market_update
				price_list = ""
				var/list/prices = list()
				for(var/item_type in shippingmarket.commodities)
					var/datum/commodity/C = shippingmarket.commodities[item_type]
					var/viewprice = C.price
					if (C.indemand)
						viewprice *= shippingmarket.demand_multiplier

					prices += "<tr><td>[C.indemand ? "<strong>🔥 [C.comname]</strong> <em style='color: #f88;'>Hot item!</em>" : "[C.comname]"]</td><td style='text-align: right;'>[C.indemand ? "<strong>[viewprice]</strong>" : "[viewprice]"]</td></tr>"

				price_list = prices.Join("")

			src.temp = {"<h2>Shipping Market Prices</h2>
					<table class='qmtable'>
						<thead>
							<tr><th>Item</th><th>Value</th></tr>
						</thead>
						<tbody>
						[price_list]
						</tbody>
					</table>
						"}

		if ("contact_cdc")
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with the CDC.</span>")
				return
			set_cdc()
			last_cdc_message = null

		if ("req_biohazard_crate")
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with the CDC.</span>")
				return
			if (ticker.round_elapsed_ticks < QM_CDC.next_crate)
				last_cdc_message = "<span style=\"color:red; font-style: italic\">We are fresh out of crates right now to send you. Check back in [ceil((QM_CDC.next_crate - ticker.round_elapsed_ticks) / (1 SECOND))] seconds!</span>"
			else
				if (wagesystem.shipping_budget < 5)
					last_cdc_message = "<span style=\"color:red; font-style: italic\">You're completely broke. You cannot even afford a crate.</span>"
				else
					wagesystem.shipping_budget -= 5
					last_cdc_message = "<span style=\"color:blue; font-style: italic\">We're delivering the crate right now. It should arrive shortly.</span>"
					shippingmarket.receive_crate(new /obj/storage/crate/biohazard/cdc())
					QM_CDC.next_crate = ticker.round_elapsed_ticks + 300
			set_cdc()

		if ("cdc_analyze")
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with the CDC.</span>")
				return
			src.temp = "<B>Center for Disease Control communication line</B><HR>"
			src.temp += "<i>These are the unanalyzed samples we have from you, [station_name].</i><br><br>"
			if (QM_CDC.current_analysis)
				src.temp += "We are currently researching the sample [QM_CDC.current_analysis.assoc_pathogen.name]. We can start on a new one if you like, but the analysis cost will not be refunded.<br><br>"
			src.temp += "Analysis costs 100 credits to begin. Choose a pathogen sample to analyze:<br>"
			for (var/datum/cdc_contact_analysis/C in QM_CDC.ready_to_analyze)
				src.temp += "<a href='[topicLink("cdc_analyze_me", "\ref[C]")]'>[C.assoc_pathogen.name]</a> ([round(C.time_done / (2 * C.time_factor))]% done)<br>"
			src.temp += "<br><A href='[topicLink("contact_cdc")]'>Back</A><br><A href='[topicLink("mainmenu")]'>Main Menu</A>"

		if ("cdc_analyze_me")
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with the CDC.</span>")
				return
			if (QM_CDC.last_switch > ticker.round_elapsed_ticks - 300)
				last_cdc_message = "<span style=\"color:red; font-style: italic\">We just switched projects. Hold on for a bit.</span>"
			else if (wagesystem.shipping_budget < 100)
				last_cdc_message = "<span style=\"color:red; font-style: italic\">You cannot afford to start a new analysis.</span>"
			else
				var/datum/cdc_contact_analysis/C = locate(subaction)
				if (!(C in QM_CDC.ready_to_analyze))
					last_cdc_message = "<span style=\"color:red; font-style: italic\">That's not ready to analyze right now.</span>"
				else
					last_cdc_message = "<span style=\"color:blue; font-style: italic\">We'll begin the analysis and keep you updated.</span>"
					wagesystem.shipping_budget -= 100
					if (QM_CDC.current_analysis)
						var/datum/cdc_contact_analysis/A = QM_CDC.current_analysis
						A.time_done += ticker.round_elapsed_ticks - A.begun_at
						if (A.cure_available <= ticker.round_elapsed_ticks)
							QM_CDC.completed_analysis += A
						else
							QM_CDC.ready_to_analyze += A
					QM_CDC.current_analysis = C
					QM_CDC.ready_to_analyze -= C
					C.begun_at = ticker.round_elapsed_ticks
					C.description_available = C.begun_at + C.time_factor - C.time_done
					C.cure_available = C.description_available + C.time_factor
					QM_CDC.last_switch = C.begun_at

			set_cdc()

		if ("batch_cure")
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with the CDC.</span>")
				return
			var/datum/cdc_contact_analysis/C = locate(subaction)
			if (!(C in QM_CDC.completed_analysis))
				last_cdc_message = "<span style=\"color:red; font-style: italic\">That's not ready to be cured yet.</span>"
			var/count = text2num_safe(href_list["count"])
			var/cost = 0
			switch (count)
				if (1)
					cost = C.cure_cost
				if (5)
					cost = 4 * C.cure_cost
				if (10)
					cost = 7 * C.cure_cost
				else
					last_cdc_message = "<span style=\"color:red; font-style: italic\">No leet haxing, chump.</span>"
			if (cost > 0)
				if (wagesystem.shipping_budget < cost)
					last_cdc_message = "<span style=\"color:red; font-style: italic\">You cannot afford these cures.</span>"
				else
					wagesystem.shipping_budget -= cost
					QM_CDC.working_on = C.assoc_pathogen
					QM_CDC.working_on_time_factor = C.time_factor
					QM_CDC.next_cure_batch = round(rand(175, 233) / 100 * C.time_factor) + ticker.round_elapsed_ticks
					QM_CDC.batches_left = count

			set_cdc()

		if ("trader_list")
			if (!shippingmarket.active_traders.len)
				boutput(usr, "<span class='alert'>No traders detected in communications range.</span>")
				return
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing contact with trader vessels.</span>")
				return

			src.temp = "<h2>Available Traders</h2><br><div style='text-align: center;'>"
			for (var/datum/trader/T in shippingmarket.active_traders)
				if (!T.hidden)
					src.temp += {"
						<a href='[topicLink("trader", "\ref[T]")]' style="display: inline-block; text-align: center; vertical-align: top; padding: 0.25em 0.5em;">
							<img src="[resource("images/traders/[T.picture]")]">
							<br>
							[T.name]
						</a>
						"}
					//src.temp += "* <a href='[topicLink("trader", "\ref[T]")]'>[T.name]</A><br>"
			src.temp += "</div>"


		// This code is mostly hot garbage and is being refactored, slowly
		if ("trader")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			src.trader_dialogue_update("greeting", T)

		if ("trader_selling")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			src.trader_dialogue_update("selling",T)

		if ("trader_buying")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			src.trader_dialogue_update("buying",T)

		if ("trader_cart")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			src.trader_dialogue_update("cart",T)

		if ("goods_addtocart")
			var/datum/trader/T = locate(href_list["the_trader"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return
			var/datum/commodity/C = locate(href_list["subaction"]) in T.goods_sell
			if (!src.commodity_sanity_check(C))
				return
			if (src.in_dialogue_box)
				return

			if (C.amount == 0)
				T.current_message = pick(T.dialogue_out_of_stock)
				src.trader_dialogue_update("selling",T)
				src.updateUsrDialog()
				return

			var/buy_cap = 99
			var/total_stuff_in_cart = 0

			if (shippingmarket && istype(shippingmarket,/datum/shipping_market))
				buy_cap = shippingmarket.max_buy_items_at_once
			else
				logTheThing(LOG_DEBUG, null, "<b>ISN/Trader:</b> Shippingmarket buy cap improperly configured")

			for(var/datum/commodity/cartcom in T.shopping_cart)
				total_stuff_in_cart += cartcom.amount

			if (total_stuff_in_cart >= buy_cap)
				boutput(usr, "<span class='alert'>You may only have a maximum of [buy_cap] items in your shopping cart. You have already reached that limit.</span>")
				return

			src.in_dialogue_box = 1
			var/howmany = input("How many units do you want to purchase?", "Trader Purchase", null, null) as num
			if (howmany < 1)
				src.in_dialogue_box = 0
				return
			if (C.amount > 0 && howmany > C.amount)
				howmany = C.amount

			if (howmany + total_stuff_in_cart > buy_cap)
				boutput(usr, "<span class='alert'>You may only have a maximum of [buy_cap] items in your shopping cart. This order would exceed that limit.</span>")
				src.in_dialogue_box = 0
				return

			var/datum/commodity/trader/incart/newcart = new /datum/commodity/trader/incart(T)
			T.shopping_cart += newcart
			newcart.reference = C
			newcart.comname = C.comname
			newcart.amount = howmany
			newcart.price = C.price
			newcart.comtype = C.comtype
			if (C.amount > 0) C.amount -= howmany
			src.trader_dialogue_update("selling",T)
			src.in_dialogue_box = 0

		if ("goods_haggle_sell")
			var/datum/trader/T = locate(href_list["the_trader"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return
			var/datum/commodity/C = locate(href_list["subaction"]) in T.goods_sell
			if (!src.commodity_sanity_check(C))
				return
			if (src.in_dialogue_box)
				return

			if (T.patience <= 0)
				// whoops, you've pissed them off and now they're going to fuck off
				src.trader_dialogue_update("fuckyou", T)
				src.updateUsrDialog()
				T.hidden = 1
				return

			src.in_dialogue_box = 1
			var/haggling = input("Suggest a new lower price.", "Haggle", null, null)  as null|num
			if (haggling < 1)
				// yeah sure let's reduce the barter into negative numbers, herp derp
				boutput(usr, "<span class='alert'>That doesn't even make any sense!</span>")
				src.in_dialogue_box = 0
				return
			T.haggle(C,haggling,1)

			src.trader_dialogue_update("selling",T)
			src.in_dialogue_box = 0

		if ("goods_haggle_buy")
			var/datum/trader/T = locate(href_list["the_trader"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return
			var/datum/commodity/C = locate(href_list["subaction"]) in T.goods_buy
			if (!src.commodity_sanity_check(C))
				return
			if (src.in_dialogue_box)
				return

			if (T.patience <= 0)
				// whoops, you've pissed them off and now they're going to fuck off
				// unless they've got negative patience in which case haggle all you like
				src.trader_dialogue_update("fuckyou", T)
				src.updateUsrDialog()
				T.hidden = 1
				return

			src.in_dialogue_box = 1
			var/haggling = input("Suggest a new higher price.", "Haggle", null, null)  as null|num
			if (haggling < 1)
				// yeah sure let's reduce the barter into negative numbers, herp derp
				boutput(usr, "<span class='alert'>That doesn't even make any sense!</span>")
				src.in_dialogue_box = 0
				return
			T.haggle(C,haggling,0)

			src.trader_dialogue_update("buying",T)
			src.in_dialogue_box = 0

		if ("goods_removefromcart")
			var/datum/trader/T = locate(href_list["the_trader"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return
			var/datum/commodity/trader/incart/C = locate(href_list["subaction"]) in T.shopping_cart
			if (!src.commodity_sanity_check(C))
				return

			var/howmany = 1
			if (C.amount > 1)
				howmany = input("Remove how many units?", "Remove from Cart", null, null) as num
				if (howmany < 1)
					return
			howmany = clamp(howmany, 0, C.amount)

			C.amount -= howmany

			if (C.reference && istype(C.reference,/datum/commodity/trader/))
				if (C.reference.amount > -1)
					C.reference.amount += howmany

			if (C.amount < 1)
				T.shopping_cart -= C
				qdel (C)
			src.trader_dialogue_update("cart",T)

		if ("trader_buy_cart")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return

			if (!T.shopping_cart.len)
				boutput(usr, "<span class='alert'>There's nothing in the shopping cart to buy!</span>")
				return

			var/cart_cost = 0
			var/total_cart_amount = 0
			for (var/datum/commodity/C in T.shopping_cart)
				cart_cost += C.price * C.amount
				total_cart_amount += C.amount

			var/buy_cap = 99

			if (shippingmarket && istype(shippingmarket,/datum/shipping_market))
				buy_cap = shippingmarket.max_buy_items_at_once
			else
				logTheThing(LOG_DEBUG, null, "<b>ISN/Trader:</b> Shippingmarket buy cap improperly configured")

			if (total_cart_amount > buy_cap)
				boutput(usr, "<span class='alert'>There are too many items in the cart. You may only order [buy_cap] items at a time.</span>")
			else
				if (wagesystem.shipping_budget < cart_cost)
					T.current_message = pick(T.dialogue_cant_afford_that)
				else
					T.current_message = pick(T.dialogue_purchase)
					T.buy_from()
			src.trader_dialogue_update("cart",T)

		if ("trader_clr_cart")
			var/datum/trader/T = locate(href_list["subaction"]) in shippingmarket.active_traders
			if (!src.trader_sanity_check(T))
				return

			T.wipe_cart()
			src.trader_dialogue_update("cart",T)

		if ("pin_contract")
			var/datum/req_contract/RC = locate(href_list["subaction"]) in shippingmarket.req_contracts
			if(RC)
				if(RC.pinned)
					RC.pinned = FALSE
					shippingmarket.has_pinned_contract = FALSE
				else if(!shippingmarket.has_pinned_contract)
					RC.pinned = TRUE
					shippingmarket.has_pinned_contract = TRUE
			src.requisitions_update()

		if ("requis_list")
			if (!shippingmarket.req_contracts.len)
				boutput(usr, "<span class='alert'>No requisitions are currently on offer.</span>")
				return
			if (signal_loss >= 75)
				boutput(usr, "<span class='alert'>Severe signal interference is preventing a connection to requisition hub.</span>")
				return
			src.requisitions_update()

		if ("print_req")
			if(!src.printing)
				var/datum/req_contract/RC = locate(href_list["subaction"]) in shippingmarket.req_contracts
				src.print_requisition(RC)

		if ("mainmenu")
			src.temp = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/supplycomp/proc/requisitions_update()
	src.temp = "<h2>Open Requisition Contracts</h2><div style='text-align: center;'>"
	src.temp += "To fulfill these contracts, please send full requested<br>"
	src.temp += "complement of items with the contract's Requisitions tag.<br>"
	src.temp += "Insufficient or extra items will be returned to you.<br><br>"
	src.temp += "One contract at a time may be pinned, which reserves it<br>"
	src.temp += "for your use, even through market shifts.<br><br>"
	src.temp += "When fulfilling third-party contracts, you <B>must</B><br>"
	src.temp += "send the included requisition sheet; please be aware<br>"
	src.temp += "<B>third-party returns are at clients' discretion</B><br>"
	src.temp += "and your shipment may not be returned if insufficient."
	for (var/datum/req_contract/RC in shippingmarket.req_contracts)
		src.temp += "<h3>[RC.name][RC.pinned ? " (Pinned)" : null]</h3>"
		src.temp += "Contract Reward:"
		if(length(RC.item_rewarders) && !RC.hide_item_payouts)
			src.temp += "<br>"
			if(RC.payout > 0) src.temp += "[RC.payout] Credits<br>"
			for(var/datum/rc_itemreward/RI in RC.item_rewarders)
				if(RI.count) src.temp += "[RI.count]x [RI.name]<br>"
				else src.temp += "[RI.name]<br>"
			src.temp += "<br>"
		else
			src.temp += " [RC.payout] Credits<br>"
		src.temp += "Requisition Code: [RC.req_code]<br><br>"
		if(RC.flavor_desc) src.temp += "[RC.flavor_desc]<br><br>"
		src.temp += "[RC.requis_desc]"
		if(RC.req_class == AID_CONTRACT && !RC.pinned) // Cannot ordinarily be pinned. Unpin support included for contract testing.
			var/datum/req_contract/aid/RCAID = RC
			src.temp += "URGENT - Cannot Be Reserved<br>"
			if(RCAID.cycles_remaining)
				var/formatted_cycles_remaining = RCAID.cycles_remaining + 1
				src.temp += "Contract leaves market in [formatted_cycles_remaining] cycles<br>"
			else
				src.temp += "Contract leaves market with next cycle<br>"
		else
			src.temp += "<A href='[topicLink("pin_contract","\ref[RC]")]'>[RC.pinned ? "Unpin Contract" : "Pin Contract"]</A><br>"
		src.temp += "<A href='[topicLink("print_req","\ref[RC]")]'>Print List</A>"

/obj/machinery/computer/supplycomp/proc/print_requisition(var/datum/req_contract/contract)
	src.printing = 1
	playsound(src.loc, 'sound/machines/printer_thermal.ogg', 60, 0)
	SPAWN(2 SECONDS)
		var/obj/item/paper/thermal/P = new(src.loc)
		P.info = "<font face='System' size='2'><center>REQUISITION CONTRACT MANIFEST<br>"
		P.info += "FOR SUPPLIER REFERENCE ONLY<br><br>"
		P.info += uppertext(contract.requis_desc)
		P.info += "</center></font>"
		P.name = "Requisition: [contract.name]"
		src.printing = 0

/obj/machinery/computer/supplycomp/proc/trader_dialogue_update(var/dialogue,var/datum/trader/T)
	if (!dialogue || !T)
		return

	if (!src.trader_sanity_check(T))
		return

	var/cart_price = 0
	var/cart_items = 0
	for (var/datum/commodity/C in T.shopping_cart)
		cart_price += C.price * C.amount
		cart_items += C.amount

	var/topMenu = {"
		<h2>Trader Communications</h2>
		<div style='float: right;'><a href='[topicLink("trader_cart", "\ref[T]")]'>🛒 [cart_items] item\s ([cart_price][CREDIT_SIGN])</a></div>
		[T.goods_sell.len ? "<a href='[topicLink("trader_selling", "\ref[T]")]'>Selling ([T.goods_sell.len])</a>" : ""]
		[T.goods_sell.len && T.goods_buy.len ? " &bull; " : ""]
		[T.goods_buy.len ? "<a href='[topicLink("trader_buying", "\ref[T]")]'>Buying ([T.goods_buy.len])</a>" : ""]
		<div style='clear: both;'></div>
		"}

	var/bottomText = ""

	switch (dialogue)

		if ("greeting")
			bottomText = {"
				<div style='text-align: center;'>
					[T.goods_sell.len ? "<a href='[topicLink("trader_selling", "\ref[T]")]' class='qmbutton' style='padding: 1.5em 1em; width: 40%;'><span style='font-size: 125%;'>Items For Sale</span><br>([T.goods_sell.len] item\s)</a>" : ""]
					[T.goods_buy.len ? "<a href='[topicLink("trader_buying", "\ref[T]")]' class='qmbutton' style='padding: 1.5em 1em; width: 40%;'><span style='font-size: 125%;'>Wanted Items</span><br>([T.goods_buy.len] item\s)</a>" : ""]
				</div>
			"}

		if ("fuckyou")
			topMenu = ""
			T.current_message = pick(T.dialogue_leave)
			bottomText = "Your haggling has pushed [T.name] too far, and they have left."

		if ("cart")
			var/total_price = 0
			if (!T.shopping_cart.len)
				bottomText = "There is nothing in your shopping cart."
			else if (T.currently_selling)
				bottomText = "Your order is now being processed!"
			else
				bottomText = {"
					<h3>Shopping Cart</h3>
					<table class='qmtable'>
						<thead>
							<tr>
								<th style='width: 0;'>&nbsp;</th>
								<th>Item</th>
								<th>Price</th>
								<th>Qty</th>
								<th>Total</th>
							</tr>
						</thead>
						<tbody>
					"}
				for (var/datum/commodity/C in T.shopping_cart)
					bottomText += {"
						<tr>
							<td style='width: 0;'>
								<a href='[topicLink("goods_removefromcart", "\ref[C]", list(the_trader = "\ref[T]"))]'>❌</a>
							</td>
							<th>[C.comname]</th>
							<td style='text-align: right;'>[C.price]</td>
							<td style='text-align: right;'>[C.amount]</td>
							<th style='text-align: right;'>[C.price * C.amount]</th>
						</tr>
						"}
					total_price += C.price * C.amount
				bottomText += {"
						<tr>
							<th colspan='4' style='text-align: right'><strong>TOTAL:</strong></th>
							<th style='text-align: right;'><strong>[total_price]</strong></th>
						</tr>
					</tbody>
				</table>
				"}

			if (T.shopping_cart.len && !T.currently_selling)
				bottomText += {"
					<br>
					<div style='text-align: center;'>
						<a class='qmbutton' href='[topicLink("trader_buy_cart", "\ref[T]")]'><span style='font-size: 125%;'>Complete Purchase</span><br>[total_price] credits</a>
					<br>
					<br>
					<a href='[topicLink("trader_clr_cart", "\ref[T]")]'>Empty Shopping Cart</a>
					</div>
					"}


		if ("buying")
			bottomText += "<h3>Wanted Goods</h3><ul class='shoplist'>"
			for (var/datum/commodity/trader/C in T.goods_buy)
				if (C.hidden)
					continue
				bottomText += {"
					<li>
						<div style='float: right;'>
							<a href='[topicLink("goods_haggle_buy", "\ref[C]", list("the_trader" = "\ref[T]"))]'>Haggle</a>
						</div>
						<strong>[C.comname]</strong> - [C.amount >= 0 ? "[C.amount] more, at " : ""][C.price] credit\s each
						<br>[C.listed_name]
					</li>
					"}

			bottomText += {"
				</ul>
				<br>
				<br><em>To sell goods to this trader, print a barcode for <strong>[T.name]</strong> on the barcode computer, attach it to a crate containing the goods, and send the crate out the 'sell' mass driver.
				<br>
				<br>Load no more than 50 items into a crate at once, or the trader's cargo computer may not be able to keep up!</em>
				"}

		if ("selling")
			bottomText += "<h3>Goods For Sale</h3><ul class='shoplist'>"
			for (var/datum/commodity/trader/C in T.goods_sell)
				if (C.hidden)
					continue
				bottomText += {"
					<li>
						<div style='float: right;'>
							[C.amount != 0 ? {"
							<a href='[topicLink("goods_addtocart", "\ref[C]", list("the_trader"="\ref[T]"))]'>Purchase</a> &bull;
							<a href='[topicLink("goods_haggle_sell", "\ref[C]", list("the_trader"="\ref[T]"))]'>Haggle</a>
							"} : "Out of stock"]
						</div>
						<strong>[C.comname]</strong> - [C.amount >= 0 ? "[C.amount] left, at " : ""][C.price] credit\s each
						<br>[C.listed_name]
					</li>
					"}
			bottomText += "</ul>"


	src.temp = {"
			[topMenu]
			<table class='qmtable' style="border: none; clear: both; margin: 0.5em 0;">
				<tr>
					<td width="0" style="border: none; padding: 0 0.5em; text-align: center;"><img src="[resource("images/traders/[T.picture]")]"><br><strong>[T.name]</strong></td>
					<td style="border: none; padding: 0 1em; vertical-align: middle;"><div style="background: #444; margin-bottom: 1em; padding: 0.2em 0.6em; border-radius: 6px; box-shadow: 3px 3px 5px -1px black;">\"[T.current_message]\"
				</tr>
			</table>
			[bottomText]
			"}



/obj/machinery/computer/supplycomp/proc/trader_sanity_check(var/datum/trader/T)
	if (!T || !istype(T,/datum/trader/) || T.hidden)
		src.temp = {"Error contacting trader. They may have departed from communications range.<br>
					<A href='[topicLink("mainmenu")]'>Main Menu</A>"}
		return 0
	if (signal_loss >= 75)
		src.temp = {"Severe signal interference is preventing contact with [T.name].<br>
					<A href='[topicLink("mainmenu")]'>Main Menu</A>"}
		return 0
	return 1

/obj/machinery/computer/supplycomp/proc/commodity_sanity_check(var/datum/commodity/C)
	if (!C)
		boutput(usr, "<span class='alert'>Something has gone wrong trying to access this commodity! Report this please!</span>")
		return 0
	if (!istype(C,/datum/commodity/))
		boutput(usr, "<span class='alert'>Something has gone wrong trying to access this commodity! Report this please!</span>")
		return 0
	return 1

/obj/machinery/computer/supplycomp/proc/post_signal(var/command)
	var/datum/signal/status_signal = get_free_signal()
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command
	status_signal.data["address_tag"] = "STATDISPLAY"

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, status_signal, null, FREQ_STATUS_DISPLAY)

#undef ORDER_LABEL_MAX_LEN
