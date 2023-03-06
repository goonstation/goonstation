///Mail order manifest datum: sent to quartermasters to sign off on the goods being imported
/datum/mailorder_manifest
	var/list/stock = list() //things to instantiate in the order
	var/stock_frontend = "" //list of contents to show in the console
	var/dest_tag = "Send to QM" //destination to ship to, defaults to QM
	var/orderedby = null //name of orderer, as printed on card
	var/orderer_account = null //account associated with orderer, used for refund
	var/order_cost = null //tracks cost for refund in case of denial
	var/order_catalogue = "unknown seller" //name of catalogue's fulfiller (same as name of catalogue program)
	var/notify_netid = null //device address to ping

	proc/approve_order()
		switch(dest_tag)
			if("Send to QM") //set up for qm delivery
				var/obj/storage/secure/crate/mailorder/package = new /obj/storage/secure/crate/mailorder()
				package.spawn_contents = src.stock
				if(src.orderedby)
					package.registered = src.orderedby
				package.launch_procedure()
				shippingmarket.receive_crate(package)
			else //set up for direct yeet
				var/obj/item/storage/box/mailorder/package = new /obj/item/storage/box/mailorder()
				package.spawn_contents = src.stock
				if(src.orderedby)
					package.name = "mail-order box ([orderedby])"
				package.mail_dest = src.dest_tag
				package.yeetself()
		shippingmarket.supply_history += "Mail-order by [src.orderedby] fulfilled by [src.order_catalogue]. Destination: [src.dest_tag].<BR>"
		if(notify_netid)
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"=notify_netid, "command"="text_message", "sender_name"="CARGO-MAILBOT", "sender"="00000000", "message"="Notification: Your mail order has been approved. Destination: [dest_tag]")
			radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)

	proc/deny_order()
		if(src.orderedby)
			var/refund_acc = FindBankAccountByName(src.orderedby)
			if(refund_acc)
				refund_acc["current_money"] += src.order_cost
		if(notify_netid)
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"=notify_netid, "command"="text_message", "sender_name"="CARGO-MAILBOT", "sender"="00000000", "message"="Notification: Mail order denied by local quartermaster service.")
			radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(pdaSignal)


//boxes and loaders for transfer of ordered goods to purchaser

/////////////CONFIGURATION NOTES/////////////

//A mail loading chute + landmark mailorder spawn and target are recommended for map addition.
//Mail order spawn landmark, located at edge of map
//Mail order target landmark, placed at location on station that is chute location or will feed box into chute
//Mail loading chute, located somewhere external, connected to the station's mail loop

//The chute should accept mail from a point external on the station and place it into the mail loop
//using a juncture that has a tag which doesn't match any mail chute.

//Adding the chute will not prevent purchase of the mail-order via QM secure crate;
//merely add the option for a less secure but more convenient box-based delivery

///Box for mail-based delivery
/obj/item/storage/box/mailorder
	name = "mail-order box"
	icon_state = "evidence"
	desc = "A box containing mail-ordered items."
	var/mail_dest = null //used in mail loop delivery

	proc/yeetself()
		var/yeetdelay = rand(15 SECONDS,20 SECONDS)
		SPAWN(yeetdelay)
			var/yeetbegin = pick_landmark(LANDMARK_MAILORDER_SPAWN)
			var/yeetend = pick_landmark(LANDMARK_MAILORDER_TARGET)
			if(!yeetbegin || !yeetend)
				CRASH("[src] failed to launch at intended destination, tell kubius")
			src.set_loc(get_turf(yeetbegin))
			src.throw_at(yeetend, 100, 1)

///Box for QM-based delivery
/obj/storage/secure/crate/mailorder
	name = "mail-order crate"
	desc = "A crate that holds mail-ordered items."
	personal = 1

	proc/launch_procedure()
		if(src.registered)
			src.name = "\improper [src.registered]'s mail-order crate"
			src.desc = "A crate that holds mail-ordered items. It's registered to [src.registered]'s ID card."

///Auto chute that accepts boxes for mail-based delivery (routing them based on the box's mail tag), and nothing else
/obj/machinery/floorflusher/industrial/mailorder
	name = "external mail loading chute"
	desc = "A large chute that only accepts specially designed mail-order boxes."
	var/destination_tag = null

	Crossed(atom/movable/AM)
		if(istype(AM,/obj/item/storage/box/mailorder))
			..()

	MouseDrop_T()
		return

	attack_hand()
		return

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I,/obj/item/storage/box/mailorder))
			..()

	route_contents()
		for(var/atom/movable/AM in src)
			if(istype(AM,/obj/item/storage/box/mailorder))
				var/obj/item/storage/box/mailorder/mobox = AM
				if(mobox.mail_dest)
					return mobox.mail_dest
