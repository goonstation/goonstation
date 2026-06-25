/obj/machinery/computer3/luggable/techpersonal/cyber
	name = "Rugged Laptop"
	desc = "A much smaller computer workstation, designed to be hoisted around by 90s hackers."
	icon_state = "cyblap"
	base_icon_state = "cyblap"

	undeploy()
		if(!src.case)
			src.case = new /obj/item/luggable_computer/techpersonal/cyber(src)
			src.case.luggable = src
		. = ..()

/obj/item/luggable_computer/techpersonal/cyber
	name = "Rugged Laptop"
	desc = "A much smaller computer workstation, designed to be hoisted around by 90s hackers."
	icon_state = "cyblapshut"
	item_state = "cyblap"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	luggable_type = /obj/machinery/computer3/luggable/techpersonal/cyber
	w_class = W_CLASS_NORMAL


/obj/machinery/computer/cyberintel
	name = "Cyberintel console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "personnel_management"

	var/obj/item/card/id/scan = null
	var/vmode = 0
	deconstruct_flags = DECON_MULTITOOL
	light_r = 0
	light_g = 0
	light_b = 0.7
	circuit_type = /obj/item/circuitboard/cyberintel

/obj/machinery/computer/cyberintel/Topic(href, href_list)
	if (..())
		return 1

	if (usr in range(1, src))
		src.add_dialog(usr)

	if (href_list["aptinfo"])
		var/dat = "<html><head><title>Advanced Persistent Threats</title></head><body>"
		dat += file2text('strings/books/cybercriminals_and_you.txt')
		usr.Browse(dat, "window=aptinfo;size=600x400")

	if (href_list["refresh"])
		src.updateUsrDialog()


/obj/machinery/computer/cyberintel/attackby(var/obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		boutput(user, SPAN_NOTICE("You swipe the ID card."))
		src.scan = id_card
		src.updateUsrDialog()

/obj/machinery/computer/cyberintel/attack_hand(mob/user)
	if(..())
		return

	if(isnull(scan))
		boutput(user, SPAN_NOTICE("Access required."))
		return
	if(!(access_dwaine_superuser in scan.access))
		boutput(user, SPAN_NOTICE("Access required."))
		return

	src.add_dialog(user)

	var/css={"<style>
						.company {
							font-weight: bold;
						}
						.stable {
							width: 100%
							border: 1px solid black;
							border-collapse: collapse;
						}
						.stable tr {
							border: none;
						}
						.stable td, .stable th {
							border-right: 1px solid white;
							border-bottom: 1px solid black;
						}
						a.updated {
							color: red;
						}
						</style>"}

	var/dat = {"<html><head><title>[station_name()] Cyber Intelligence</title>[css]</head><body><h2>Cyber Intelligence</h2>
	<B>Scanned Card:</B> <A href='byond://?src=\ref[src];card=1'>([src.scan])</A><BR><HR>"}


	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];aptinfo=1'>View APTs</a> | <a href='byond://?src=\ref[src];refresh=1'>Refresh</a></div></div>"
	dat += "<hr>"
	for (var/datum/cyberintel/article/A as anything in cyberintel_articles) // in A: headline, article, outhash
		dat += "<p><h2>[A.headline]</h2></p>"
		dat += "<p>[A.article]</p>"
		dat += "<p>[A.outhash]</p>"
		dat += "<hr>"
	dat += "</body></html>"
	user.Browse(dat, "window=computer;size=600x400")
	onclose(user, "computer")
	src.add_fingerprint(user)

	return


/obj/machinery/computer/cybersecurity
	name = "Cybersecurity console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "personnel_management"
	var/obj/machinery/power/data_terminal/link = null
	var/net_id = null

	var/list/noav = list() // netids for av machines
	var/list/yesav = list()

	var/obj/item/card/id/scan = null
	var/vmode = 0

	var/list/updatehashes = list()
	var/list/wlessnetids = list()

	deconstruct_flags = DECON_MULTITOOL
	light_r = 0
	light_g = 0
	light_b = 0.7
	circuit_type = /obj/item/circuitboard/cybersecurity
	New()
		..()
		START_TRACKING
		SPAWN(0.6 SECONDS)
			if(!src.link)
				var/turf/T = get_turf(src)
				var/obj/machinery/power/data_terminal/test_link = locate() in T
				if(test_link && !DATA_TERMINAL_IS_VALID_MASTER(test_link, test_link.master))
					src.link = test_link
					src.link.master = src
		src.net_id = generate_net_id(src)

	proc
		updateList(mob/user)
			var/hash = input(user, "Enter the filehash:")
			updatehashes += hash
			SPAWN(1 SECOND)
				src.updateUsrDialog()

		clearList(mob/user)
			updatehashes = list()
			SPAWN(1 SECOND)
				src.updateUsrDialog()

		updateHashes(mob/user)
			for (var/netid in yesav)
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.transmission_method = TRANSMISSION_WIRE
				signal.data["address_1"] = netid
				signal.data["command"] = "av_upd"
				signal.data["sender"] = src.net_id
				for (var/hash in updatehashes)
					signal.data["hash"] = hash
					src.link.post_signal(src, signal)
			if(isnull(wlessnetids))
				return
			for (var/netid in wlessnetids)
				var/datum/signal/signal = get_free_signal()
				signal.source = src
				signal.transmission_method = TRANSMISSION_RADIO
				signal.data["address_1"] = netid
				signal.data["command"] = "av_upd"
				signal.data["sender"] = src.net_id
				for (var/hash in updatehashes)
					signal.data["hash"] = hash
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, signal)


		wlessNetid(mob/user)
			var/netid = input(user, "Enter the filehash:")
			wlessnetids += netid
			SPAWN(1 SECOND)
				src.updateUsrDialog()

		wlessClear(mob/user)
			wlessnetids = list()
			SPAWN(1 SECOND)
				src.updateUsrDialog()

	receive_signal(datum/signal/signal)
		if(signal.data["device"] != "PNET_ADAPTER")
			return
		if(signal.data["command"] == "av_reply0")
			if(signal.data["sender"] in noav)
				return	// dedup
			noav += signal.data["sender"]

		else if(signal.data["command"] == "av_reply1")
			if(signal.data["sender"] in yesav)
				return	// dedup
			yesav += signal.data["sender"]


/obj/machinery/computer/cybersecurity/Topic(href, href_list)
	if (..())
		return 1
	if (usr in range(1, src))
		src.add_dialog(usr)
	if (href_list["ping"])
		noav = list() // reset to update
		yesav = list()
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.transmission_method = TRANSMISSION_WIRE
		signal.data["address_1"] = "av_ping"
		signal.data["sender"] = src.net_id
		src.link.post_signal(src, signal)
		SPAWN(2 SECONDS)
			src.updateUsrDialog()

	else if (href_list["updatelist"])
		updateList(usr)
	else if (href_list["clearlist"])
		clearList(usr)
	else if (href_list["update"])
		updateHashes(usr)
	else if (href_list["wlessnetid"])
		wlessNetid(usr)
	else if (href_list["wlessclear"])
		wlessClear(usr)


/obj/machinery/computer/cybersecurity/attackby(var/obj/item/I, mob/user)
	var/obj/item/card/id/id_card = get_id_card(I)
	if (istype(id_card))
		boutput(user, SPAN_NOTICE("You swipe the ID card."))
		src.scan = id_card
		src.updateUsrDialog()

/obj/machinery/computer/cybersecurity/attack_hand(mob/user)
	if(..())
		return

	if(isnull(scan))
		boutput(user, SPAN_NOTICE("Superuser access required."))
		return
	if(!(access_dwaine_superuser in scan.access))
		boutput(user, SPAN_NOTICE("Superuser access required."))
		return

	src.add_dialog(user)

	var/css={"<style>
						.company {
							font-weight: bold;
						}
						.stable {
							width: 100%
							border: 1px solid black;
							border-collapse: collapse;
						}
						.stable tr {
							border: none;
						}
						.stable td, .stable th {
							border-right: 1px solid white;
							border-bottom: 1px solid black;
						}
						a.updated {
							color: red;
						}
						</style>"}

	var/dat = {"<html><head><title>[station_name()] Cybersecurity</title>[css]</head><body><h2>Cybersecurity</h2>
	<B>Scanned Card:</B> <A href='byond://?src=\ref[src];card=1'>([src.scan])</A><BR>"}

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];updatelist=1'>Enter hash</a> | "
	dat += "<a href='byond://?src=\ref[src];clearlist=1'>Clear hash list</a></div> | "
	dat += "<a href='byond://?src=\ref[src];update=1'>Update ThoughtGuards</a></div>"

	dat += "<p>"
	for (var/hash in updatehashes)
		dat += "[hash], "
	dat += "</p>"

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];wlesslist=1'>Enter wireless NETID</a> | "
	dat += "<a href='byond://?src=\ref[src];wlessclear=1'>Clear list</a></div>"
	dat += "<p>"
	for (var/W in wlessnetids)
		dat += "[W], "
	dat += "</p>"

	dat += "<hr>"
	dat += "<a href='byond://?src=\ref[src];ping=1'>Ping ThoughtGuard devices</a> Y:[length(yesav)] / N:[length(noav)]</div>"
	dat += "<p>NO AV: </p>"
	for (var/netid in noav)
		dat += "<div>[netid]</div>"
	dat += "<p>WITH AV: </p>"
	for (var/netid in yesav)
		dat += "<div>[netid]</div>"
	dat += "</body></html>"
	user.Browse(dat, "window=computer;size=600x400")
	onclose(user, "computer")
	src.add_fingerprint(user)

