/obj/machinery/launcher_loader
	icon = 'icons/obj/stationobjs.dmi'
#ifndef IN_MAP_EDITOR
	icon_state = "launcher_loader_0"
#else
	icon_state = "launcher_loader_0-map"
#endif
	name = "Automatic mass-driver loader (AMDL)"
	desc = "An automated, hydraulic mass-driver loader."
	density = 0
	opacity = 0
	layer = 2.6
	anchored = ANCHORED
	plane = PLANE_NOSHADOW_BELOW

	var/obj/machinery/mass_driver/driver = null

	var/id = "null"
	var/operating = 0
	var/driver_operating = 0
	var/trash = 0
	/// Amount of time in seconds before connected blast doors should close
	var/door_delay = 3 // Multiplied by SECONDS on New()

	New()
		..()
		SPAWN(0.5 SECONDS)
			door_delay = door_delay SECONDS
			var/list/drivers = new/list()
			for(var/obj/machinery/mass_driver/D in range(1,src))
				drivers += D
			if(drivers.len)
				if(length(drivers) > 1)
					for(var/obj/machinery/mass_driver/D2 in drivers)
						if(D2.id == src.id)
							driver = D2
							break
					if(!driver) driver = pick(drivers)
				else
					driver = pick(drivers)

				src.set_dir(get_dir(src,driver))

	proc/activate()
		if(operating || !isturf(src.loc) || driver_operating) return
		operating = 1
		FLICK("launcher_loader_1",src)
		playsound(src, 'sound/effects/pump.ogg', 50, TRUE)
		SPAWN(0.3 SECONDS)
			for(var/atom/movable/AM in src.loc)
				if(AM.anchored || AM == src || isobserver(AM) || isintangible(AM) || isflockmob(AM)) continue
				if(trash && AM.delivery_destination != "Disposals")
					AM.delivery_destination = "Disposals"
				step(AM,src.dir)
			operating = 0
			handle_driver()

	proc/handle_driver()
		if(driver && !driver_operating)
			driver_operating = 1

			SPAWN(0)
				var/obj/machinery/door/poddoor/door = null
				for(var/obj/machinery/door/poddoor/P in by_type[/obj/machinery/door])
					if (P.id == driver.id)
						door = P
						SPAWN(0)
							if (door)
								door.open()
						SPAWN(door_delay)
							if (door)
								door.close()

				SPAWN(door ? door_delay : 2 SECONDS) driver_operating = FALSE

				sleep(door ? 20 : 10)
				if (driver)
					for(var/obj/machinery/mass_driver/D as anything in machine_registry[MACHINES_MASSDRIVERS])
						if(D.id == driver.id)
							D.drive()
	process()
		if(!operating && !driver_operating)
			var/drive = 0
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isobserver(M) || isintangible(M) || isflockmob(M)) continue
				drive = 1
				break
			if(drive) activate()

	Crossed(atom/movable/A)
		..()
		if (istype(A, /mob/dead) || A.anchored || isintangible(A) || iswraith(A) || isflockmob(A) || istype(A, /obj/projectile)) return
		return_if_overlay_or_effect(A)
		activate()


/obj/machinery/launcher_loader/north
	dir = NORTH
/obj/machinery/launcher_loader/east
	dir = EAST
/obj/machinery/launcher_loader/south
	dir = SOUTH
/obj/machinery/launcher_loader/west
	dir = WEST

/atom/movable
	var/delivery_destination = null

/obj/machinery/cargo_router
	icon = 'icons/obj/delivery.dmi'
	icon_state = "amdl_0"
	name = "Cargo Router"
	desc = "Scans the barcode on objects and reroutes them accordingly."
	density = 0
	opacity = 0
	anchored = ANCHORED
	event_handler_flags = USE_FLUID_ENTER
	plane = PLANE_NOSHADOW_BELOW

	var/default_direction = NORTH //The direction things get sent into when the router does not have a destination for the given barcode or when there is none attached.
	var/list/destinations = new/list() //List of tags and the associated directions.

	var/obj/machinery/mass_driver/driver = null
	var/operating = 0
	var/driver_operating = 0

	var/trigger_when_no_match = 1

	proc/get_next_dir()
		for(var/atom/movable/AM in src.loc)
			if(AM.anchored || AM == src || isobserver(AM) || isintangible(AM) || isflockmob(AM)) continue
			if(AM.delivery_destination)
				if(destinations.Find(AM.delivery_destination))
					return destinations[AM.delivery_destination]
		return null

	proc/activate()
		if(operating || !isturf(src.loc)) return

		var/next_dest = src.get_next_dir()

		if(next_dest)
			src.set_dir(next_dest)
		else
			if (!trigger_when_no_match)
				operating = 0
			src.set_dir(default_direction)

		operating = 1

		FLICK("amdl_1",src)
		playsound(src, 'sound/effects/pump.ogg', 50, TRUE)

		SPAWN(0.3 SECONDS)
			for(var/atom/movable/AM2 in src.loc)
				if(AM2.anchored || AM2 == src || isobserver(AM2) || isintangible(AM2) || isflockmob(AM2)) continue
				step(AM2,src.dir)

			driver = (locate(/obj/machinery/mass_driver) in get_step(src,src.dir))

			operating = 0
			handle_driver()

	proc/handle_driver()
		if(driver && !driver_operating)
			driver_operating = 1

			SPAWN(0)
				sleep(1 SECOND)
				if (driver)
					driver.drive()
				sleep(1 SECOND)
				driver_operating = 0
				driver = null

	process()
		if(!operating && !driver_operating)
			var/drive = 0
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isobserver(M) || isintangible(M) || isflockmob(M)) continue
				drive = 1
				break
			if(drive) activate()

	Crossed(atom/movable/A)
		..()
		if (istype(A, /mob/dead) || isintangible(A) || iswraith(A) || isflockmob(A)) return

		if (!trigger_when_no_match)
			var/atom/movable/AM = A
			if (!AM.delivery_destination)
				return

		return_if_overlay_or_effect(A)
		activate()

/obj/machinery/cargo_router/random
	get_next_dir()
		return src.destinations[pick(src.destinations)]

/obj/machinery/cargo_router/exampleRouter
	New()
		destinations = list("Medical-Science Dock" = SOUTH, "Catering Dock" = NORTH, "EVA Dock" = WEST, "Disposals" = EAST)
		default_direction = EAST //By default send things to disposals, for this example, if they dont have a code or we don't have a destination.
		//You could leave one direction open and use that as default to send things with invalid destinations back to QM or something.
		//Or if QM is already in the list of destinations , use that direction as default. I don't know.
		..()

// cogwerks notes: I'm starting with the first router from QM and moving sorta clockwise.
/obj/machinery/cargo_router/Router1
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = NORTH, "EVA" = WEST, "Disposals" = NORTH, "QM" = NORTH, "Engine" = NORTH, "Catering" = NORTH, "MedSci" = NORTH, "Security" = NORTH)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/Router2 //airbridge loader
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = WEST, "EVA" = WEST, "Disposals" = WEST, "QM" = WEST, "Engine" = WEST, "Catering" = WEST, "MedSci" = WEST, "Security" = WEST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/Router3 //eva loader
	New()
		destinations = list("Airbridge" = EAST, "Cafeteria" = EAST, "EVA" = NORTH, "Disposals" = EAST, "QM" = EAST, "Engine" = EAST, "Catering" = EAST, "MedSci" = EAST, "Security" = EAST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/Router4 //cafeteria
	New()
		destinations = list("Airbridge" = EAST, "Cafeteria" = NORTH, "EVA" = EAST, "Disposals" = EAST, "QM" = EAST, "Engine" = EAST, "Catering" = EAST, "MedSci" = EAST, "Security" = EAST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/Router5 //disposals
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = SOUTH, "EVA" = SOUTH, "Disposals" = EAST, "QM" = EAST, "Engine" = SOUTH, "Catering" = EAST, "MedSci" = EAST, "Security" = EAST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/Router6 //crusher or QM?
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = SOUTH, "EVA" = SOUTH, "Disposals" = EAST, "QM" = SOUTH, "Engine" = SOUTH, "Catering" = SOUTH, "MedSci" = SOUTH, "Security" = SOUTH)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/Router7 // shortcut - bypasses the central hub
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = WEST, "EVA" = WEST, "Disposals" = NORTH, "QM" = NORTH, "Engine" = WEST, "Catering" = NORTH, "MedSci" = NORTH, "Security" = NORTH)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/Router8 // engine dock
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = WEST, "EVA" = WEST, "Disposals" = WEST, "QM" = WEST, "Engine" = SOUTH, "Catering" = WEST, "MedSci" = WEST, "Security" = WEST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/Router9 // to outer router -> out
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = SOUTH, "EVA" = SOUTH, "Disposals" = SOUTH, "QM" = SOUTH, "Engine" = SOUTH, "Catering" = EAST, "MedSci" = EAST, "Security" = EAST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/Router10 // to outer router -> in
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = WEST, "EVA" = WEST, "Disposals" = WEST, "QM" = SOUTH, "Engine" = WEST, "Catering" = WEST, "MedSci" = WEST, "Security" = WEST)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/Router11 // outer router -> up
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = SOUTH, "EVA" = SOUTH, "Disposals" = SOUTH, "QM" = SOUTH, "Engine" = SOUTH, "Catering" = NORTH, "MedSci" = SOUTH, "Security" = NORTH)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/Router12 // outer router -> down
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = WEST, "EVA" = SOUTH, "Disposals" = WEST, "QM" = WEST, "Engine" = WEST, "Catering" = NORTH, "MedSci" = SOUTH, "Security" = NORTH)
		default_direction = WEST
		..()

/obj/machinery/cargo_router/Router13 // catering outer router -> east-west
	New()
		destinations = list("Airbridge" = SOUTH, "Cafeteria" = SOUTH, "EVA" = SOUTH, "Disposals" = SOUTH, "QM" = SOUTH, "Engine" = SOUTH, "Catering" = SOUTH, "MedSci" = SOUTH, "Security" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/Router14 // catering outer router -> west-east
	New()
		destinations = list("Airbridge" = EAST, "Cafeteria" = EAST, "EVA" = EAST, "Disposals" = EAST, "QM" = EAST, "Engine" = EAST, "Catering" = SOUTH, "MedSci" = EAST, "Security" = EAST)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/Router15 // undeliverable cargo outlet
	New()
		destinations = list("Airbridge" = WEST, "Cafeteria" = WEST, "EVA" = WEST, "Disposals" = WEST, "QM" = WEST, "Engine" = WEST, "Catering" = WEST, "MedSci" = WEST, "Security" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/oshan_north
	trigger_when_no_match = 0
	New()
		destinations = list("North Carousel" = NORTH, "South Carousel" = EAST, "East Carousel" = EAST, "West Carousel" = EAST)
		default_direction = NORTH
		..()

/obj/machinery/cargo_router/oshan_south
	trigger_when_no_match = 0
	New()
		destinations = list("South Carousel" = SOUTH, "North Carousel" = WEST, "East Carousel" = WEST, "West Carousel" = WEST)
		default_direction = SOUTH
		..()

/obj/machinery/cargo_router/oshan_east
	trigger_when_no_match = 0
	New()
		destinations = list("East Carousel" = EAST, "North Carousel" = SOUTH, "South Carousel" = SOUTH, "West Carousel" = SOUTH)
		default_direction = EAST
		..()

/obj/machinery/cargo_router/oshan_west
	trigger_when_no_match = 0
	New()
		destinations = list("West Carousel" = WEST, "North Carousel" = NORTH, "South Carousel" = NORTH, "East Carousel" = NORTH)
		default_direction = WEST
		..()


/obj/machinery/computer/barcode
	name = "barcode computer"
	desc = "Used to print barcode stickers for the cargo routing system."

	icon = 'icons/obj/delivery.dmi'
	icon_state = "barcode_comp"
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WIRECUTTERS | DECON_MULTITOOL

	var/printing = FALSE

	// log account information for QM sales
	var/obj/item/card/id/scan = null
	var/datum/db_record/account = null
	var/list/destinations = null



	connection_scan()
		if (!src.destinations)
			src.destinations = global.map_settings.shipping_destinations

	New()
		..()
		connection_scan()

	proc/print(var/destination, var/amount)
		if (printing)
			return
		printing = TRUE
		playsound(src.loc, 'sound/machines/printer_cargo.ogg', 75, 0)
		sleep(1.75 SECONDS)
		for (var/i in 1 to amount)
			var/obj/item/sticker/barcode/B = new/obj/item/sticker/barcode(src.loc)
			B.name = "Barcode Sticker ([destination])"
			B.destination = destination
			B.scan = src.scan
			B.account = src.account
		printing = FALSE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "BarcodeComputer")
			ui.open()

	ui_static_data(mob/user)
		var/list/destination_list = new()
		for (var/destination in destinations)
			destination_list += list(list("crate_tag" = destination)) //goddamn byond += overloading making me do listlist
		. = list()
		.["sections"] = list(list("title" = "Station", "destinations" = destination_list))


	ui_data(mob/user)
		. = list()
		if (!QDELETED(scan))
			//we have to do this mess because bicon returns the full img tag which tgui won't render
			var/bicon_split = splittext(bicon(scan), "'")
			var/icon_src = bicon_split[length(bicon_split) - 1]

			.["card"] = list(
				"name" = scan.registered,
				"role" = scan.assignment,
				"icon" = icon_src,
				"balance" = account?.get_field("current_money"),
			)
		else
			.["card"] = null

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		else if (action == "print")
			var/destination = strip_html(params["crate_tag"], 64)
			var/amount = clamp(round(params["amount"]), 1, 5)
			print(destination, amount)
		else if (action == "reset_id")
			scan = null
			account = null
			. = TRUE
			src.updateUsrDialog()

	attackby(var/obj/item/I, mob/user)
		var/obj/item/card/id/id_card = get_id_card(I)
		if (istype(id_card))
			boutput(user, SPAN_NOTICE("You swipe the ID card."))
			account = FindBankAccountByName(id_card.registered)
			if(account)
				var/enterpin = user.enter_pin("Barcode Computer")
				if (enterpin == id_card.pin)
					boutput(user, SPAN_NOTICE("Card authorized."))
					src.scan = id_card
					src.updateUsrDialog()
				else
					boutput(user, SPAN_ALERT("PIN incorrect."))
					src.scan = null
			else
				boutput(user, SPAN_ALERT("No bank account associated with this ID found."))
				src.scan = null
		else ..()
		return

/obj/machinery/computer/barcode/qm //has trader tags if there is one
	name = "\improper QM barcode computer"
	desc = "Used to print barcode stickers for the cargo routing system, and to mark crates for sale to traders."
	icon_state = "qm_barcode_comp"
	circuit_type = /obj/item/circuitboard/barcode_qm

	New()
		..()
	ui_static_data(mob/user)
		. = ..()
		var/list/traders = new()
		for (var/datum/trader/T in shippingmarket.active_traders)
			if (T.hidden)
				continue
			traders += list(list("crate_tag" = T.crate_tag, "name" = T.name))
		.["sections"] += list(list("title" = "Traders", "destinations" = traders))
		var/list/req_codes = new()
		req_codes += list(list("crate_tag" = "REQ-THIRDPARTY", "name" = "Third party"))
		for (var/datum/req_contract/RC in shippingmarket.req_contracts)
			req_codes += list(list("crate_tag" = RC.req_code, "name" = RC.name))
		.["sections"] += list(list("title" = "Requisition contracts", "destinations" = req_codes))

/obj/machinery/computer/barcode/qm/no_belthell
	name = "Barcode Computer"
	desc = "Used to print barcode stickers for the off-station merchants."
	destinations = list("Shipping Market")

/// Silicon-friendly portable barcoder. Does not allow for ID scanning.
/obj/item/portable_barcoder
	name = "portable barcoder"
	desc = "Used to print and attach barcode stickers for shipping."
	icon = 'icons/obj/delivery.dmi'
	icon_state = "handheld_barcoder" // TODO: better sprite
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "labeler"
	/// key-value store of destinations
	var/list/destinations = list()
	/// Currently selected destination target
	var/current_destination_target

	HELP_MESSAGE_OVERRIDE("Use in-hand to set the target destination. Click on an object or mob to apply the barcode.")

/obj/item/portable_barcoder/New()
	. = ..()
	src.update_destinations()

/obj/item/portable_barcoder/proc/update_destinations()
	src.destinations = list()
	for (var/destination in global.map_settings.shipping_destinations)
		src.destinations[destination] = destination

	for (var/datum/trader/T in shippingmarket.active_traders)
		if (T.hidden)
			continue
		src.destinations[T.name] = T.crate_tag

	src.destinations["Third Party"] = "REQ-THIRDPARTY"
	for (var/datum/req_contract/RC in shippingmarket.req_contracts)
		src.destinations[RC.name] = RC.req_code

/obj/item/portable_barcoder/attack_self(mob/user)
	src.select_destination(user)

/obj/item/portable_barcoder/attack(mob/target, mob/user, def_zone, is_special, params)
	return

/obj/item/portable_barcoder/afterattack(atom/target, mob/user, reach, params)
	if (!istype(target) || isturf(target)) return
	if ((target.plane == PLANE_HUD && !isitem(target)) || isgrab(target)) return
	if (BOUNDS_DIST(get_turf(target), get_turf(src)) > 0) return
	if (target == src.loc && target != user) return

	if (!src.current_destination_target)
		src.select_destination()
		if (!src.current_destination_target)
			boutput(user, SPAN_ALERT("You must select a destination before attaching a barcode!"))
			return
	if (ON_COOLDOWN(src, "barcode_print", 1.75 SECONDS))
		boutput(user, SPAN_NOTICE("The barcoder is spooling a new barcode!"))
		return

	var/obj/item/sticker/barcode/barcode = new /obj/item/sticker/barcode
	barcode.name = "Barcode Sticker ([src.current_destination_target])"
	barcode.destination = src.current_destination_target
	playsound(src.loc, 'sound/machines/printer_cargo.ogg', 75, 0)

	target:delivery_destination = src.current_destination_target
	user.visible_message(SPAN_NOTICE("[user] sticks a [barcode.name] on [target]."))

	if(istype(target, /obj/storage/crate))
		var/obj/storage/crate/C = target
		C.UpdateIcon()
	else
		var/pox = src.pixel_x
		var/poy = src.pixel_y
		if (params)
			if (islist(params) && params["icon-y"] && params["icon-x"])
				pox = text2num(params["icon-x"]) - 16
				poy = text2num(params["icon-y"]) - 16
		barcode.stick_to(target, pox, poy, user)

/obj/item/portable_barcoder/proc/select_destination(mob/user)
	var/choice = tgui_input_list(user, "Choose a routing destination", "Select Destination", src.destinations)
	if (!choice) return
	src.current_destination_target = src.destinations[choice]

/obj/item/sticker/barcode
	name = "barcode sticker"
	desc = "A barcode sticker used in the cargo routing system."
	icon = 'icons/obj/delivery.dmi'
	icon_state = "barcode"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"

	var/destination = "QM Dock"

	// log account information for QM sales
	var/obj/item/card/id/scan = null
	var/datum/db_record/account = null

	attack()
		return

	afterattack(atom/target, mob/user, reach, params)
		if ((target.plane == PLANE_HUD && !isitem(target)) || isgrab(target)) //just don't stick hud stuff or grabs PLEASE
			return
		if(BOUNDS_DIST(get_turf(target), get_turf(src)) == 0 && istype(target, /atom/movable))
			if(target==loc && target != user) return //Backpack or something
			target:delivery_destination = destination
			user.visible_message(SPAN_NOTICE("[user] sticks a [src.name] on [target]."))
			user.u_equip(src)
			if(istype(target, /obj/storage/crate))
				if (scan && account)
					var/obj/storage/crate/C = target
					C.scan = src.scan
					C.account = src.account
					boutput(user, SPAN_NOTICE("[target] has been marked with your account routing information."))
					C.desc = "[C] belongs to [scan.registered]."
				var/obj/storage/crate/C = target
				C.UpdateIcon()
				qdel(src)
			else
				var/pox = src.pixel_x
				var/poy = src.pixel_y
				DEBUG_MESSAGE("pox [pox] poy [poy]")
				if (params)
					if (islist(params) && params["icon-y"] && params["icon-x"])
						pox = text2num(params["icon-x"]) - 16 //round(A.bound_width/2)
						poy = text2num(params["icon-y"]) - 16 //round(A.bound_height/2)
						DEBUG_MESSAGE("pox [pox] poy [poy]")
				src.stick_to(target, pox, poy, user)
			if(isobj(target))
				var/obj/O = target
				if(O.artifact && src.scan)
					var/datum/artifact/art = O.artifact
					art.scan = src.scan
					art.account = src.account
					boutput(user, SPAN_NOTICE("[target] has been marked with your account routing information."))
					if(art.examine_hint)
						art.examine_hint += " [target] belongs to [scan.registered]."
					else
						art.examine_hint = "[target] belongs to [scan.registered]."

		return
