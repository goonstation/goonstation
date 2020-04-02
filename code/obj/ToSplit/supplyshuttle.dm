//Config stuff
#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_POINTSPER 1      //Points per tick.
#define SUPPLY_POINTDELAY 450	//Delay between ticks in milliseconds.
#define SUPPLY_MOVETIME 1800	//Time to station is milliseconds. 1800 default
#define SUPPLY_POINTSPERCRATE 10	//Points per crate sent back.

var/list/supply_requestlist = new/list()
var/list/supply_history = new/list()
var/supply_shuttle_can_send = 1
var/supply_shuttle_time = 0
var/supply_shuttle_timeleft = 0
var/supply_shuttle_moving = 0
var/supply_shuttle_at_station = 0
var/door_id = "qm_dock"

/area/supply/spawn_point //the area supplies are spawned at and fired from
	name = "supply spawn point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

/area/supply/delivery_point //the area supplies are fired at
	name = "supply target point"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

/area/supply/sell_point //the area where supplies move from the station z level
	name = "supply sell region"
	icon_state = "shuttle3"
	requires_power = 0

	#ifdef UNDERWATER_MAP
	color = OCEAN_COLOR
	#endif

	Entered(var/atom/movable/AM)
		..()
		if(istype(AM,/obj/storage/crate))
			if(can_sell(AM))
				for(var/datum/trader/T in shippingmarket.active_traders)
					if (T.crate_tag == AM.delivery_destination)
						sell_to_trader(AM,T)
						return
				sell_crate(AM)

/obj/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "Plastic flaps"
	desc = "I definitely cant get past those. no way."
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = EFFECTS_LAYER_UNDER_1
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS

/obj/plasticflaps/CanPass(atom/A, turf/T)
	if (isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if (isghostdrone(M)) // except for drones
			return 1
		else if (istype(A,/mob/living/critter/changeling/handspider) || istype(A,/mob/living/critter/changeling/eyespider))
			return 1
		else if(!M.lying) // or you're lying down
			return 0
	return ..()

/obj/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/marker/supplymarker
	icon_state = "X"
	icon = 'icons/misc/mark.dmi'
	name = "X"
	invisibility = 101
	anchored = 1
	opacity = 0

/proc/supply_ticker()
	wagesystem.shipping_budget += SUPPLY_POINTSPER
	SPAWN_DBG(SUPPLY_POINTDELAY) supply_ticker()

/proc/can_sell(var/obj/storage/crate/sellcrate)
	/*var/filterdead = 0
	if (shippingmarket.trader)
		if (shippingmarket.trader:goodsname == "corpses") filterdead = 1
		for(var/mob/living/M in sellcrate)
			if(filterdead && isdead(M)) continue
			return 0
		for(var/atom/ATM in sellcrate)
			for(var/mob/living/N in ATM:contents)
				if(filterdead && isdead(N)) continue
				return 0*/
	// Is this even necessary anymore?

	return 1

/proc/sell_crate(var/obj/storage/crate/sell_crate)
	if (istype(sell_crate, /obj/storage/crate/biohazard/cdc))
		for (var/R in sell_crate)
			if (istype(R, /obj/item/reagent_containers) || ishuman(R)) //heh
				var/obj/item/reagent_containers/RC = R
				var/list/patho = RC.reagents.aggregate_pathogens()
				for (var/uid in patho)
					if (!(uid in QM_CDC.analysis_by_uid))
						var/datum/pathogen/P = patho[uid]
						var/datum/cdc_contact_analysis/D = new
						D.uid = uid
						var/sym_count = max(min(length(P.effects), 7), 2)
						D.time_factor = sym_count * rand(10, 15) // 200, 600
						D.cure_cost = sym_count * rand(25, 40) // 2100, 4300
						D.name = P.name
						var/rating = max(P.advance_speed, P.mutation_speed, P.mutativeness, P.suppression_threshold, P.maliciousness)
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
						var/datum/pathogen/copy = unpool(/datum/pathogen)
						copy.setup(0, P, 0, null)
						D.assoc_pathogen = copy
						QM_CDC.analysis_by_uid[uid] = D
						QM_CDC.ready_to_analyze += D
				if (ishuman(RC))
					var/mob/living/carbon/human/H = RC
					H.ghostize()
				qdel(RC)
			qdel(sell_crate)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Notification: Pathogen sample crate delivered to the CDC.")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)
		return

	var/amount = 1
		// log account information for QM sales
	var/obj/item/card/id/scan = sell_crate.scan
	var/datum/data/record/account = sell_crate.account
	var/list/to_sell = new/list()
	for(var/obj/M in sell_crate.contents)
		amount = hasvar(M, "amount") && M:amount > 1 ? M:amount : 1
		if (isnum(to_sell.Find(M.type)))
			to_sell[M.type] += amount
			//boutput(world, "<span style=\"color:red\"><b> HEY I SHOULD BE SELLING [M.type]</b></span>")
		else
			to_sell[M.type] = amount
			//boutput(world, "<span style=\"color:red\"><b> [M.type] in the house</b></span>")
		qdel(M)
	qdel(sell_crate)
	var/duckets = 0  // fuck yeah duckets
	duckets += SUPPLY_POINTSPERCRATE

	for(var/item_type in to_sell)
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// cogwerks - child types weren't inheriting their parent value properly, here is an ugly patch for the problem
		//boutput(world, "<b>PRESANITIZED SWITCH FOR [item_type]</b>") ////////////////////////////////////////////////////////
		var/sanitizer = item_type
		if(ispath(item_type, /obj/item/reagent_containers/food/snacks/ingredient/meat))
			sanitizer = /obj/item/reagent_containers/food/snacks/ingredient/meat
		if(ispath(item_type, /obj/item/reagent_containers/food/snacks/plant))
			sanitizer = /obj/item/reagent_containers/food/snacks/plant
		if(ispath(item_type, /obj/item/plant/herb))
			sanitizer = /obj/item/plant/herb
		if(ispath(item_type, /obj/item/electronics))
			sanitizer = /obj/item/electronics
		if(ispath(item_type, /obj/item/parts/robot_parts))
			sanitizer = /obj/item/parts/robot_parts
		if(ispath(item_type, /obj/item/sheet/steel))
			sanitizer = /obj/item/sheet/steel
		if(ispath(item_type, /obj/item/sheet/glass))
			sanitizer = /obj/item/sheet/glass
		//boutput(world, "[sanitizer] is our intermediary")
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////// add more ispath checks as needed, or get someone more competent to write a better workaround /////
		////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		var/datum/commodity/C = shippingmarket.commodities["[sanitizer]"]
		//boutput(world, "<b> WE ARE LOOKING FOR [item_type]")
		amount = to_sell[item_type]

		if (C)
			//boutput(world, "<b> [C] should fetch [C.price]")
			if (C.indemand)
				//wagesystem.shipping_budget += amount * C.price * shippingmarket.demand_multiplier
				duckets += amount * C.price * shippingmarket.demand_multiplier
				//boutput(world, "<b> IN DEMAND: SELLING [amount] of [C] for [C.price] times [shippingmarket.demand_multiplier]</b>")
			else
				//wagesystem.shipping_budget += amount * C.price
				duckets += amount * C.price
				//boutput(world, "<b> NOT IN DEMAND: SELLING [amount] of [C] for [C.price]</b>")
		else
			//wagesystem.shipping_budget += amount
			duckets += amount
			//boutput(world, "<b> [C] NEVER SOLD RIGHT, FUCKIN HELL</b>")
	if(scan && account)
		wagesystem.shipping_budget += duckets / 2
		account.fields["current_money"] += duckets / 2
					//////PDA NOTIFY/////
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment. Splitting half of profits with [scan.registered].")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)
		//////////
	else
		wagesystem.shipping_budget += duckets
			//////PDA NOTIFY/////
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Notification: [duckets] credits earned from last outgoing shipment.")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(null, pdaSignal)
			//////////


	////transaction is over ///


/proc/sell_to_trader(var/obj/storage/crate/sellcrate,var/datum/trader/the_trader)
	//return

	var/sellcount = 0
	var/amount = 1
	//var/sellmax = shippingmarket.trader:limit
	// log account information for QM sales // for some stupid reason this was getting a bad var bug and i have no idea why - cogwerks
	var/obj/item/card/id/scan = null
	if(sellcrate.scan)
		scan = sellcrate.scan
	var/datum/data/record/account = null
	if(sellcrate.account)
		account = sellcrate.account
	var/duckets = 0
	var/itemchecklimit = 0
	for(var/obj/M in sellcrate.contents)
		itemchecklimit++
		if (itemchecklimit > 100)
			break
		if (!the_trader)
			break
		//if (sellmax && (sellcount >= sellmax)) break
		/*if(ispath(M, /obj/item/reagent_containers/food/snacks/ingredient/meat))
			M = /obj/item/reagent_containers/food/snacks/ingredient/meat
		if(ispath(M, /obj/item/reagent_containers/food/snacks/plant))
			M = /obj/item/reagent_containers/food/snacks/plant
		if(ispath(M, /obj/item/plant/herb))
			M = /obj/item/plant/herb
		if(ispath(M, /obj/item/electronics))
			M = /obj/item/electronics
		if(ispath(M, /obj/item/parts/robot_parts))
			M = /obj/item/parts/robot_parts
		if(ispath(M, /obj/item/sheet/steel))
			M = /obj/item/sheet/steel
		if(ispath(M, /obj/item/sheet/glass))
			M = /obj/item/sheet/glass
		if(istype(M,shippingmarket.trader:tradegoods))
			amount = hasvar(M, "amount") && M:amount > 1 ? M:amount : 1
			duckets += amount * shippingmarket.trader:price
			score_stufftraded += amount
			sellcount++
			qdel(M)*/
		for(var/datum/commodity/C in the_trader.goods_buy)
			//if (M.type == C.comtype)
			if (istype(M,C.comtype))
				amount = hasvar(M, "amount") && M:amount > 1 ? M:amount : 1
				duckets += amount * C.price
				sellcount++

				if (istype(M,/obj/item/raw_material) || istype(M,/obj/item/material_piece) || istype(M,/obj/item/plant) || istype(M,/obj/item/reagent_containers/food/snacks/plant))
					pool(M)	////things we pool that are prob sold in very high quantity (i'm sorry!!!!)
				else
					qdel(M)
			LAGCHECK(100)//lollll

		LAGCHECK(LAG_REALTIME)

	qdel(sellcrate)

	if (sellcount)
		if(scan && account)
			wagesystem.shipping_budget += duckets / 2
			account.fields["current_money"] += duckets / 2
						//////PDA NOTIFY/////
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Deal with \"[the_trader.name]\" concluded. Net Profit: [duckets] credits. Splitting half of profits with [scan.registered].")
			pdaSignal.transmission_method = TRANSMISSION_RADIO
			if(transmit_connection != null)
				transmit_connection.post_signal(null, pdaSignal)
			//////////
		else
			wagesystem.shipping_budget += duckets
				//////PDA NOTIFY/////
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Deal with \"[the_trader.name]\" concluded. Net Profit: [duckets] credits.")
			pdaSignal.transmission_method = TRANSMISSION_RADIO
			if(transmit_connection != null)
				transmit_connection.post_signal(null, pdaSignal)



/*/proc/sell_corpses(var/obj/storage/crate/sellcrate)
	// special case sell proc for Vurdalak
	// he doesnt do this anymore it was a phase he was going through ok
	set background = 1
	var/sellcount = 0

	var/sellmax = shippingmarket.trader:limit
	for(var/mob/living/carbon/I in sellcrate)
		if (sellmax && (sellcount >= sellmax)) break
		if (!isdead(I))
			shippingmarket.trader = null
			var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
			var/datum/signal/pdaSignal = get_free_signal()
			pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Alert: \"[shippingmarket.trader:name]\" has abruptly rescinded their trade offer and left")
			pdaSignal.transmission_method = TRANSMISSION_RADIO
			transmit_connection.post_signal(src, pdaSignal)
			return
		wagesystem.shipping_budget += shippingmarket.trader:price
		score_stufftraded += 1
		sellcount++
		if (I.mind || I.client) // if the player is waiting in the corpse, ghost them so we dont get respawn exploits
			var/mob/dead/observer/newmob = new/mob/dead/observer(I)
			if(I.client) I:client:mob = newmob
			I.mind.transfer_to(newmob)

			SPAWN_DBG(0)
				qdel(I)
	qdel(sellcrate)
	if (sellcount)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Deal with \"[shippingmarket.trader:name]\" concluded. Net Profit: [sellcount * shippingmarket.trader:price] credits")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(src, pdaSignal)

	shippingmarket.trader = null*/

// fuck it doing this with more globals
var/crate_firing = 0


//These should be #defines probably
/proc/supplyshuttle_open_spawn_time()
	if (ismap("CHIRON"))
		return 40
	return 10
/proc/supplyshuttle_close_spawn_time()
	if (ismap("CHIRON"))
		return 180
	return 130



/proc/buy_thing(var/atom/movable/O as obj|mob)
	var/turf/spawnpoint
	for(var/turf/T in get_area_turfs(/area/supply/spawn_point))
		spawnpoint = T
		break

	var/turf/target
	for(var/turf/T in get_area_turfs(/area/supply/delivery_point))
		target = T
		break

	SPAWN_DBG(0)
		while(crate_firing)
			sleep(20)

		if (!spawnpoint)
			logTheThing("debug", null, null, "<b>Shipping: </b> No spawn turfs found! Can't deliver crate")
			return

		if (!target)
			logTheThing("debug", null, null, "<b>Shipping: </b> No target turfs found! Can't deliver crate")
			return

		crate_firing = 1
		SPAWN_DBG(8 SECONDS)
			crate_firing = 0

		O.set_loc(spawnpoint)

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Shipment arriving to Cargo Bay: [O.name].")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(null, pdaSignal)

		for(var/obj/machinery/door/poddoor/P in doors)
			if (P.id == door_id)
				playsound(P.loc, "sound/machines/bellalert.ogg", 50, 0)
				SPAWN_DBG(supplyshuttle_open_spawn_time())
					if (P && P.density)
						P.open()
				SPAWN_DBG(supplyshuttle_close_spawn_time())
					if (P && !P.density)
						P.close()

		SPAWN_DBG(2 SECONDS)
			O.throw_at(target, 100, 1)

/proc/buy_from_trader(var/datum/trader/the_trader)
	//could be multiple possible spawn turfs
	var/turf/spawnpoint
	for(var/turf/T in get_area_turfs(/area/supply/spawn_point))
		spawnpoint = T
		break

	//shouldn't be multiple delivery spots but it's possible
	var/turf/target
	for(var/turf/T in get_area_turfs(/area/supply/delivery_point))
		target = T
		break

	if (!the_trader)
		return

	the_trader.currently_selling = 1
	SPAWN_DBG(0)
		var/sanity = 0
		while(crate_firing && sanity < 30) // give up after 1 minute, should only take 15 seconds at most
			sleep(20)
			sanity++

		if (sanity == 30)
			logTheThing("debug", null, null, "<b>Shipping: </b> Timed out waiting to fire crate, what a bummer!")
			the_trader.currently_selling = 0
			return

		if (!spawnpoint)
			logTheThing("debug", null, null, "<b>Shipping: </b> No spawn turfs found! Can't deliver crate")
			the_trader.currently_selling = 0
			return

		if (!target)
			logTheThing("debug", null, null, "<b>Shipping: </b> No target turfs found! Can't deliver crate")
			the_trader.currently_selling = 0
			return

		crate_firing = 1
		SPAWN_DBG(8 SECONDS)
			crate_firing = 0

		var/atom/movable/A = new /obj/storage/crate(spawnpoint)
		A.name = "Goods Crate ([the_trader.name])"

		/*var/putincrate = purchaseamt
		if (putincrate < 1) putincrate = 1
		if(prob(shippingmarket.trader:bullshit * 10)) // oh no! you got ripped off!
			while(putincrate > 1)
				new ourTrader.scamgoods(A)
				putincrate--
		else // a good deal
			while(putincrate > 1)
				new ourTrader.tradegoods(A)
				putincrate--*/

		var/obj/item/paper/invoice = new /obj/item/paper(A)
		invoice.name = "Sale Invoice ([the_trader.name])"
		invoice.info = "Invoice of Sale from [the_trader.name]<br><br>"

		var/total_price = 0
		for (var/datum/commodity/trader/C in the_trader.shopping_cart)
			if (!C.comtype || C.amount < 1) continue

			total_price += C.price * C.amount
			invoice.info += "* [C.amount] units of [C.comname], [C.price * C.amount] credits<br>"
			var/putamount = C.amount
			while(putamount > 0)
				putamount--
				new C.comtype(A)
		invoice.info += "<br>Final Cost of Goods: [total_price] credits."

		wagesystem.shipping_budget -= total_price

		the_trader.wipe_cart(1) //This tells wipe_cart to not increase the amount in stock when clearing it out.
		the_trader.currently_selling = 0 //At this point the shopping cart has been processed

		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()
		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="CARGO-MAILBOT",  "group"="cargo", "sender"="00000000", "message"="Deal with \"[the_trader.name]\" concluded. Total Cost: [total_price] credits")
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		transmit_connection.post_signal(null, pdaSignal)

		for(var/obj/machinery/door/poddoor/P in doors)
			if (P.id == door_id)
				playsound(P.loc, "sound/machines/bellalert.ogg", 50, 0)
				SPAWN_DBG(supplyshuttle_open_spawn_time())
					if (P && P.density)
						P.open()
				SPAWN_DBG(supplyshuttle_close_spawn_time())
					if (P && !P.density)
						P.close()

		SPAWN_DBG(2 SECONDS)
			A.throw_at(target, 100, 1)

/proc/process_supply_order(var/datum/supply_order/SO,var/mob/orderer)
	//could be multiple possible spawn turfs
	var/turf/spawnpoint
	for(var/turf/T in get_area_turfs(/area/supply/spawn_point))
		spawnpoint = T
		break

	//shouldn't be multiple delivery spots but it's possible
	var/turf/target
	for(var/turf/T in get_area_turfs(/area/supply/delivery_point))
		target = T
		break

	SPAWN_DBG(0)
		var/sanity = 0
		while(crate_firing && sanity < 30) // give up after 1 minute, should only take 15 seconds at most
			sleep(20)
			sanity++

		if (sanity == 30)
			logTheThing("debug", null, null, "<b>Shipping: </b> Timed out waiting to fire crate, what a bummer!")
			return

		if (!spawnpoint)
			logTheThing("debug", null, null, "<b>Shipping: </b> No spawn turfs found! Can't deliver crate")
			return

		if (!target)
			logTheThing("debug", null, null, "<b>Shipping: </b> No target turfs found! Can't deliver crate")
			return

		crate_firing = 1
		SPAWN_DBG(8 SECONDS)
			crate_firing = 0

		var/atom/movable/A = SO.create(spawnpoint, orderer)

		for(var/obj/machinery/door/poddoor/P in doors)
			if (P.id == door_id)
				playsound(P.loc, "sound/machines/bellalert.ogg", 50, 0)
				SPAWN_DBG(supplyshuttle_open_spawn_time())
					if (P && P.density)
						P.open()
				SPAWN_DBG(supplyshuttle_close_spawn_time())
					if (P && !P.density)
						P.close()

		SPAWN_DBG(2 SECONDS)
			if (A)
				A.throw_at(target, 100, 1)
/*
#ifdef HALLOWEEN
			else if (halloween)
				halloween.throw_at(target, 100, 1)
#endif
*/
proc/prisontothestation()
	if(turd_location == 0)
		var/area/start_location = locate(/area/shuttle/prison/prison)
		var/area/end_location = locate(/area/shuttle/prison/station)
		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/turf/T in end_location)
			dstturfs += T
			if(T.y < throwy)
				throwy = T.y
		for(var/turf/T in dstturfs)
			var/turf/D = locate(T.x, throwy - 1, 1)
			for(var/atom/movable/AM as mob|obj in T)
				if(isobserver(AM))
					continue
				AM.Move(D)
			if(istype(T, /turf/simulated))
				qdel(T)

		start_location.move_contents_to(end_location)
		turd_location = 1
	else
		if(turd_location == 1)
			var/area/start_location = locate(/area/shuttle/prison/prison)
			var/area/end_location = locate(/area/shuttle/prison/station)
			end_location.move_contents_to(start_location)
			turd_location = 0
	return
