/datum/data/vending_product
	var/product_name = "generic"
	var/atom/product_path = null

	var/product_cost
	var/product_amount
	var/product_hidden
	var/logged_on_vend
	var/infinite = FALSE
	var/static/list/product_base64_cache = list()

	var/static/list/product_name_cache = list(/obj/item/reagent_containers/mender/brute = "brute auto-mender", /obj/item/reagent_containers/mender/burn = "burn auto-mender")


	New(productpath, amount=0, cost=0, hidden=0, logged_on_vend=FALSE, infinite=FALSE)
		..()
		if (istext(productpath))
			productpath = text2path(productpath)
		if (!ispath(productpath))
			qdel(src)
			return
		src.product_path = productpath

		var/name_check = product_name_cache[productpath]
		if (name_check)
			src.product_name = name_check
		else
			//var/obj/temp = new src.product_path(src)
			var/p_name = initial(product_path.name)
			src.product_name = capitalize(p_name)
			product_name_cache[productpath] = src.product_name
			//qdel(temp)

		src.product_amount = amount
		src.product_cost = round(cost)

		src.product_hidden = hidden
		src.logged_on_vend = logged_on_vend
		src.infinite = infinite

	proc/getBase64Img()
		var/path = src.product_path
		. = product_base64_cache[path]
		if(isnull(.))
			var/atom/dummy_atom = new path // people demand overlays on their vending machine bottles
			sleep(0) // give it a chance to do icon changes
			var/icon/dummy_icon = getFlatIcon(dummy_atom,initial(dummy_atom.dir),no_anim=TRUE)
			qdel(dummy_atom) // above is a hack to get this to work. if anyone has any better way of doing this, go ahead.
			. = icon2base64(dummy_icon)
			product_base64_cache[path] = .


TYPEINFO(/obj/machinery/vending)
	mats = 20

ADMIN_INTERACT_PROCS(/obj/machinery/vending, proc/throw_item)
/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"
	anchored = ANCHORED
	density = 1
	layer = OBJ_LAYER - 0.1 // so items get spawned at 3, don't @ me
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_MULTITOOL
	object_flags = CAN_REPROGRAM_ACCESS | NO_GHOSTCRITTER
	flags = TGUI_INTERACTIVE
	var/freestuff = 0
	var/obj/item/card/id/scan = null

	var/image/panel_image = null

	var/active = 1 //No sales pitches if off!
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 5 //How long does it take to vend?

	//Keep track of lists
	var/list/slogan_list = list()//new() //List of strings
	var/list/product_list = new() //List of datum/data/vending_product
	var/glitchy_slogans = 0 // do they come out aLL FunKY lIKe THIs?
	/// For player vending machines
	var/player_list
	//Replies when buying
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0

	//Slogans
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 600 //How long until we can pitch again?
	var/slogan_chance = 5
	var/slogan_text_alpha = 140
	var/slogan_text_color = "#C2BEBE"

	//Icons
	var/icon_panel = "generic-panel"
	var/icon_vend //Icon for vending
	var/icon_deny //Icon when denying vend (wrong access)

	var/icon_off // trying to cut down on some duplicated icons in vending.dmi so I'm adding more icon states wee
	var/icon_broken // you only need to set these to something if you want these icons to be something other than "[initial(icon_state)]-off/-broken/-fallen"
	var/icon_fallen // otherwise it'll just default to that behavior

	var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.

	//Malfunctioning machine
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shoot_inventory_chance = 5
	var/ai_control_enabled = 1

	var/extended_inventory = FALSE //can we access the hidden inventory?
	var/can_fall = TRUE //Can this machine be knocked over?
	var/can_hack = TRUE //Can this machine have it's panel open?

	var/panel_open = FALSE //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15

	// Paid vendor variables
	var/pay = 0 // Does this vending machine require money?
	var/acceptcard = 1 // does the machine accept ID swiping?
	var/credit = 0 //How much money is currently in the machine?
	var/profit = 0.9 // cogwerks: how much of a cut should the QMs get from the sale, expressed as a percent
	var/list/vendwires = list() // fuh

	var/datum/light/light
	var/light_r =1
	var/light_g = 1
	var/light_b = 1

	var/output_target = null
	///Try to put the item in the user's hand
	var/vend_inhand = TRUE
	///The product currently being vended
	var/datum/data/vending_product/currently_vending = null // zuh

	power_usage = 50

	New()
		START_TRACKING
		src.create_products()

		#ifdef UPSCALED_MAP
		for (var/datum/data/vending_product/product in src.product_list)
			product.product_amount *= 4
		#endif

		AddComponent(/datum/component/mechanics_holder)
		AddComponent(/datum/component/bullet_holes, 8, 5)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Vend Random", PROC_REF(vendinput))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Vend by Name", PROC_REF(vendname))
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(light_r, light_g, light_b)
		..()
		src.panel_image = image(src.icon, src.icon_panel)
		if (!src.chat_text)
			src.chat_text = new(null, src)
	var/lastvend = 0

	disposing()
		STOP_TRACKING
		..()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		if(newly_built)
			src.product_list = new()

	proc/vendinput(var/datum/mechanicsMessage/inp)
		if( world.time < lastvend ) return//aaaaaaa
		lastvend = world.time + 2
		var/datum/data/vending_product/R = throw_item()
		if(R?.logged_on_vend)
			logTheThing(LOG_STATION, usr, "randomly vended a logged product ([R.product_name]) using mechcomp from [src] at [log_loc(src)].")

	proc/vendname(var/datum/mechanicsMessage/inp)
		if( world.time < lastvend || !inp) return//aaaaaaa
		if(!length(inp.signal)) return//aaaaaaa
		lastvend = world.time + 5 //Make it slower to vend by name?
		var/datum/data/vending_product/R = throw_item(inp.signal)
		if(R?.logged_on_vend)
			logTheThing(LOG_STATION, usr, "vended a logged product by name ([R.product_name]) using mechcomp from [src] at [log_loc(src)].")

	// just making this proc so we don't have to override New() for every vending machine, which seems to lead to bad things
	// because someone, somewhere, always forgets to use a ..()
	proc/create_products()
		return

	mouse_drop(over_object, src_location, over_location)
		if(!istype(usr,/mob/living/))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the output target for [src].</span>")
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, "<span class='alert'>[src] is too far away from the target!</span>")
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set [src] to output on top of [O]!</span>")

		else if (istype(over_object,/turf) && !over_object:density)
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	proc/get_output_location()
		if (!src.output_target)
			return src.loc

		if (BOUNDS_DIST(src.output_target, src) > 0)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C

		else if (istype(src.output_target,/turf/simulated/floor/))
			return src.output_target

		else
			return src.loc

#define WIRE_EXTEND 1
#define WIRE_SCANID 2
#define WIRE_SHOCK 3
#define WIRE_SHOOTINV 4

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
		if(3)
			if (prob(25))
				SPAWN(0)
					src.malfunction()
					return
				return
			else if (prob(25))
				SPAWN(0)
					src.fall()
					return
		else
	return

/obj/machinery/vending/blob_act(var/power)
	if (prob(power * 1.25))
		SPAWN(0)
			if (prob(power / 3) && can_fall == 2)
				for (var/i = 0, i < rand(4,7), i++)
					src.malfunction()
				qdel(src)
			if (prob(50) || can_fall == 2)
				src.malfunction()
			else
				src.fall()
		return

	return

/obj/machinery/vending/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		src.emagged = 1
		if(user)
			boutput(user, "You short out the product lock on [src]")
		return 1
	return 0

/obj/machinery/vending/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You repair the product lock on [src].")
	src.emagged = 0
	return 1

/obj/machinery/vending/proc/scan_card(var/obj/item/card/id/card as obj, var/mob/user as mob)
	if (!card || !user || !src.acceptcard)
		return
	boutput(user, "<span class='notice'>You swipe [card].</span>")
	var/datum/db_record/account = null
	account = FindBankAccountByName(card.registered)
	if (account)
		var/enterpin = user.enter_pin("Enter PIN")
		if (enterpin == card.pin)
			boutput(user, "<span class='notice'>Card authorized.</span>")
			src.scan = card
		else
			boutput(user, "<span class='alert'>Pin number incorrect.</span>")
			src.scan = null
	else
		boutput(user, "<span class='alert'>No bank account associated with this ID found.</span>")
		src.scan = null

/obj/machinery/vending/attackby(obj/item/W, mob/user)
	if (istype(W,/obj/item/electronics/scanner) || istype(W,/obj/item/deconstructor)) // So people don't end up making the vending machines fall on them when they try to scan/deconstruct it
		return
	if (istype(W, /obj/item/currency/spacecash))
		if (src.pay)
			src.credit += W.amount
			W.amount = 0
			boutput(user, "<span class='notice'>You insert [W].</span>")
			user.u_equip(W)
			W.dropped(user)
			qdel( W )
			return
		else
			boutput(user, "<span class='alert'>This machine does not accept cash.</span>")
			return
	var/obj/item/card/id/id_card = get_id_card(W)
	if (istype(id_card))
		W = id_card
	if (istype(W, /obj/item/card/id))
		if (src.acceptcard)
			src.scan_card(W, user)
			return
			/*var/amount = input(user, "How much money would you like to deposit?", "Deposit", 0) as null|num
			if(amount <= 0)
				return
			if(amount > W:money)
				boutput(user, "<span class='alert'>Insufficent funds. [W] only has [W:money] credits.</span>")
				return
			src.credit += amount
			W:money -= amount
			boutput(user, "<span class='notice'>You deposit [amount] credits. [W] now has [W:money] credits.</span>")
			src.updateUsrDialog()
			return()*/
		else
			boutput(user, "<span class='alert'>This machine does not accept ID cards.</span>")
			return
	else if (isscrewingtool(W) && (src.can_hack))
		src.panel_open = !src.panel_open
		boutput(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		src.UpdateOverlays(src.panel_open ? src.panel_image : null, "panel")
		return
	else if (istype(W, /obj/item/device/t_scanner) || (istype(W, /obj/item/device/pda2) && istype(W:module, /obj/item/device/pda_module/tray)))
		if (src.seconds_electrified != 0)
			boutput(user, "<span class='alert'>[bicon(W)] <b>WARNING</b>: Abnormal electrical response received from access panel.</span>")
		else
			if (status & NOPOWER)
				boutput(user, "<span class='alert'>[bicon(W)] No electrical response received from access panel.</span>")
			else
				boutput(user, "<span class='notice'>[bicon(W)] Regular electrical response received from access panel.</span>")
		return
	else if (src.panel_open && (issnippingtool(W) || ispulsingtool(W)))
		src.Attackhand(user)
		return
	else if (ispryingtool(W))
		if (src.status & BROKEN) //if the vendor is broken
			//action bar is defined at the end of these procs
			actions.start(new /datum/action/bar/icon/right_vendor(src), user)
			return
		else
			actions.start(new /datum/action/bar/icon/rotate_machinery(src), user)
			return
	if (istype(W, /obj/item/vending/restock_cartridge))
		//check if cartridge type matches the vending machine
		var/obj/item/vending/restock_cartridge/Q = W
		if (istype(src, text2path("/obj/machinery/vending/[Q.vendingType]")))

		// if (istype(src, text2path("/obj/machinery/vending/[W:vendingType]")))
			//remove all producs, reinitialize array and then create the products like new
			src.product_list = new()
			src.create_products()

			boutput(user, "<span class='notice'>You restocked the items in [src].</span>")
			playsound(src.loc , 'sound/items/Deconstruct.ogg', 80, 0)
			user.u_equip(W)
			qdel(W)
			return
		else
			boutput(user, "<span class='alert'>[W] is not compatible with [src].</span>")
	else
		user.lastattacked = src
		hit_twitch(src)
		attack_particle(user,src)
		playsound(src, 'sound/impact_sounds/Metal_Clang_2.ogg', 50,1)
		..()
		if (W.force >= 5 && prob(4 + (W.force - 5)))
			src.fall(user)

/obj/machinery/vending/hitby(atom/movable/M, datum/thrown_thing/thr)
	if (iscarbon(M) && M.throwing)
		var/area/T = get_area(src)
		if(T?.sanctuary)
			return
		src.fall(M)
		return

	..()

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui)
  ui = tgui_process.try_update_ui(user, src, ui)
  if(!ui)
    ui = new(user, src, "Vendors")
    ui.open()

#define WIRE_VIOLET 1
#define WIRE_ORANGE 2
#define WIRE_GOLDENROD 3
#define WIRE_GREEN 4

/obj/machinery/vending/ui_static_data(mob/user)
	. = list()
	src.vendwires = list("Violet" = WIRE_VIOLET,\
	"Orange" = WIRE_ORANGE,\
	"Goldenrod" = WIRE_GOLDENROD,\
	"Green" = WIRE_GREEN)

	var/wireGuiColors = list("Violet" = "#882BCB",\
	"Orange" = "#ffa500",\
	"Goldenrod" = "#B8860B",\
	"Green" = "#00ff00") // this is so we can have fancy stuff on the gui

	var/lightcolors = list(
		"electrified" = (src.seconds_electrified > 0),
		"shootinventory" = src.shoot_inventory,
		"extendedinventory" = src.extended_inventory,
		"ai_control" = src.ai_control_enabled
	)

	for (var/wiredesc in vendwires)
		var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
		.["wiresList"] += list(list("name" = wiredesc,"color" = wireGuiColors[wiredesc],"uncut" = is_uncut))
	.["lightColors"] += lightcolors

	var/list/plist = player_list || product_list

	for (var/datum/data/vending_product/R in plist)
		if (R.product_hidden && !src.extended_inventory)
			continue
		var/display_amount = R.product_amount
		if (R.product_amount < 1)
			display_amount = "OUT OF STOCK"
		.["productList"] += list(list(
			"ref" = ref(R),
			"name" = R.product_name,
			"amount" = display_amount,
			"cost" = R.product_cost,
			"img" = R.getBase64Img(),
			"infinite" = R.infinite
		))
	if (!length(plist)) //this is needed to make TGUI clear out the list
		.["productList"] = list()

/obj/machinery/vending/ui_data(mob/user)
	var/bankaccount = FindBankAccountByName(src.scan?.registered)
	. = list(
		"windowName" = src.name,
		"wiresOpen" = src.panel_open ? TRUE : null,
		"bankMoney" = bankaccount ? bankaccount["current_money"] : 0,
		"cash" = src.credit,
		"acceptCard" = src.acceptcard,
		"requiresMoney" = src.pay,
		"cardname" = src.scan?.name,
		"name" = src.name,
		"currentlyVending" = src.currently_vending?.product_name
 	)

	if(istype(src,/obj/machinery/vending/player))
		var/obj/machinery/vending/player/P = src
		if(!P.owner && src.scan?.registered)
			.["owner"] = src.scan.registered
			P.owner = src.scan.registered
			P.owneraccount = FindBankAccountByName(src.scan.registered)
		else
			.["owner"] = P.owner
		.["playerBuilt"] = TRUE
		.["unlocked"] = P.unlocked
		.["loading"] = P.loading

/obj/machinery/vending/ui_act(action, params)
	. = ..()
	if (.) return
	var/obj/item/I = usr.equipped()

	switch(action)
		if("cutwire")
			if(params["wire"] && issnippingtool(I))
				if (seconds_electrified)
					if(src.shock(usr,100))
						return
				src.cut(src.vendwires[params["wire"]])
				update_static_data(usr)
		if("mendwire")
			if(params["wire"] && issnippingtool(I))
				if (seconds_electrified)
					if(src.shock(usr,100))
						return
				src.mend(src.vendwires[params["wire"]])
				update_static_data(usr)
		if("pulsewire")
			if(params["wire"] && ispulsingtool(I))
				if (seconds_electrified)
					if(src.shock(usr,100))
						return
				src.pulse(src.vendwires[params["wire"]])
				update_static_data(usr)
		if("logout")
			src.scan = null
		// player vending machine exclusives
		if("togglechute")
			if(istype(src,/obj/machinery/vending/player))
				var/obj/machinery/vending/player/P = src
				if(usr.get_id()?.registered == P.owner || !P.owner)
					P.loading = !P.loading
		if("togglelock")
			if(istype(src,/obj/machinery/vending/player))
				var/obj/machinery/vending/player/P = src
				if(usr.get_id()?.registered == P.owner || !P.owner)
					P.unlocked = !P.unlocked
					if(!P.unlocked)
						P.loading = FALSE
		if("setPrice")
			if(istype(src,/obj/machinery/vending/player))
				var/obj/machinery/vending/player/P = src
				if(usr.get_id()?.registered == P.owner || !P.owner)
					for (var/datum/data/vending_product/R in player_list)
						if(ref(R) == params["target"])
							R.product_cost = text2num(params["cost"])
				update_static_data(usr)
		if("rename")
			if(istype(src,/obj/machinery/vending/player))
				var/obj/machinery/vending/player/P = src
				if(usr.get_id()?.registered == P.owner || !P.owner)
					P.name = params["name"]
		if("setIcon")
			if(istype(src,/obj/machinery/vending/player))
				var/obj/machinery/vending/player/P = src
				if(usr.get_id()?.registered == P.owner || !P.owner)
					for (var/datum/data/vending_product/player_product/R in player_list)
						if(ref(R) == params["target"])
							P.promoimage = R.icon
							P.updateAppearance()
		// return cash
		if("returncash")
			if (src.credit > 0)
				var/obj/item/currency/spacecash/returned = new /obj/item/currency/spacecash
				returned.setup(src.get_output_location(), src.credit)
				usr.put_in_hand_or_eject(returned) // try to eject it into the users hand, if we can
				src.credit = 0
		if("vend")
			if(params["target"])
				if (!src.vend_ready)
					return
				if (seconds_electrified)
					if(src.shock(usr,100))
						return
				var/datum/db_record/account = null
				account = FindBankAccountByName(src.scan?.registered)
				if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID))
					boutput(usr, "<span class='alert'>Access denied.</span>") //Unless emagged of course
					flick(src.icon_deny,src)
					return
				if (src.pay)
					if (src.acceptcard && src.scan)
						if (!account)
							boutput(usr, "<span class='alert'>No bank account associated with ID found.</span>")
							flick(src.icon_deny,src)
							return
						if (account["current_money"] < params["cost"])
							boutput(usr, "<span class='alert'>Insufficient funds in account. To use machine credit, log out.</span>")
							flick(src.icon_deny,src)
							return
					else
						if (src.credit < params["cost"])
							boutput(usr, "<span class='alert'>Insufficient Credit.</span>")
							flick(src.icon_deny,src)
							return

				var/product_amount = 0 // this is to make absolutely sure that these numbers arent desynced
				var/datum/data/vending_product/product

				var/list/plist = player_list || product_list
				for (var/datum/data/vending_product/R in plist)
					if(ref(R) == (params["target"]))
						product_amount = R.product_amount
						product = R
				if(product_amount <= 0 || isnull(product))
					return
				src.vend_ready = 0
				src.prevend_effect()
				src.currently_vending = product
				SPAWN(src.vend_delay)
					src.vend_ready = 1
					for (var/datum/data/vending_product/R in plist)
						if(ref(R) == params["target"])
							product_amount = R.product_amount
							product = R
					var/atom/movable/vended = src.vend_product(product, usr)
					if (!product.infinite)
						if (plist == player_list && product_amount == 1)
							player_list -= product
							qdel(product)
						product.product_amount--
					if (src.pay && vended) // do we need to take their money
						if (src.acceptcard && account)
							account["current_money"] -= product.product_cost
						else
							src.credit -= product.product_cost
						if (!player_list)
							wagesystem.shipping_budget += round(product.product_cost * profit) // cogwerks - maybe money shouldn't just vanish into the aether idk
						else
							//Players get 90% of profit from player vending machines QMs get 10%
							var/obj/machinery/vending/player/vMachine = src
							vMachine.owneraccount["current_money"] += round(product.product_cost * profit)
							wagesystem.shipping_budget += round(product.product_cost * (1 - profit))
					src.currently_vending = null
					update_static_data(usr)
				if(product.logged_on_vend)
					logTheThing(LOG_STATION, usr, "vended a logged product ([product.product_name]) from [src] at [log_loc(src)].")
				if(player_list)
					logTheThing(LOG_STATION, usr, "vended a player product ([product.product_name]) from [src] at [log_loc(src)].")
	. = TRUE

/obj/machinery/vending/proc/vend_product(var/datum/data/vending_product/product, mob/user)
	if ((!product.infinite && product.product_amount <= 0) || !product.product_path)
		return
	var/atom/movable/vended
	if (istype(product, /datum/data/vending_product/player_product)) // pull the item out of where we stored it
		var/datum/data/vending_product/player_product/playerProduct = product
		vended = playerProduct.contents[1]
		playerProduct.contents -= vended
	else // make a new one
		vended = new product.product_path(src.get_output_location())
	vended.set_loc(src.get_output_location())
	vended.layer = src.layer + 0.1 //So things stop spawning under the fukin thing
	if(isitem(vended))
		if (src.vend_inhand)
			usr.put_in_hand_or_eject(vended) // try to eject it into the users hand, if we can
		src.postvend_effect()
	return vended

/obj/machinery/vending/attack_hand(mob/user as mob)
	if (status & (BROKEN|NOPOWER))
		return

	if (src.seconds_electrified != 0)
		if (src.shock(user, 100))
			return

	ui_interact(user)

	interact_particle(user,src)
	return

/obj/machinery/vending/Topic(href, href_list)
	if (status & (BROKEN|NOPOWER))
		return
	if (usr.stat || usr.restrained())
		return

	//ehh just let the AI operate vending machines. why not!!
	if (isAI(usr) && !src.ai_control_enabled)
		boutput(usr, "<span class='alert'>AI control for this vending machine has been disconnected!</span>")
		return

	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))))
		var/isplayer = 0
		src.add_dialog(usr)
		src.add_fingerprint(usr)
		if ((href_list["vend"]) && (src.vend_ready))

			if ((!src.allowed(usr)) && (!src.emagged) && (src.wires & WIRE_SCANID)) //For SECURE VENDING MACHINES YEAH
				boutput(usr, "<span class='alert'>Access denied.</span>") //Unless emagged of course
				flick(src.icon_deny,src)
				return

			var/datum/data/vending_product/R = locate(href_list["vend"]) in src.product_list
			if (!R)
				R = locate(href_list["vend"]) in src.player_list
				isplayer = TRUE
			if (!R || !istype(R))
				return
			else if(R.product_hidden && !src.extended_inventory)
				return
			var/product_path = R.product_path

			if (istext(product_path))
				product_path = text2path(product_path)

			if (!product_path && !isplayer)
				return

			if (R.product_amount <= 0)
				return

			//Wire: Fix for href exploit allowing for vending of arbitrary items
			if (!(R in src.product_list) && !(R in src.player_list))
				trigger_anti_cheat(usr, "tried to href exploit [src] to spawn an invalid item.")
				return

			var/datum/db_record/account = null
			if (src.pay)
				if (src.acceptcard && src.scan)
					account = FindBankAccountByName(src.scan.registered)
					if (!account)
						boutput(usr, "<span class='alert'>No bank account associated with ID found.</span>")
						flick(src.icon_deny,src)
						return
					if (account["current_money"] < R.product_cost)
						boutput(usr, "<span class='alert'>Insufficient funds in account. To use machine credit, log out.</span>")
						flick(src.icon_deny,src)
						return
				else
					if (src.credit < R.product_cost)
						boutput(usr, "<span class='alert'>Insufficient Credit.</span>")
						flick(src.icon_deny,src)
						return

			if (((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
				SPAWN(0)
					src.speak(src.vend_reply)
					src.last_reply = world.time

			use_power(10)
			if (src.icon_vend) //Show the vending animation if needed
				flick(src.icon_vend,src)

			src.vend_ready = 0
			src.prevend_effect()
			if(!src.freestuff) R.product_amount--

			if (src.pay)
				if (src.acceptcard && account)
					account["current_money"] -= R.product_cost
				else
					src.credit -= R.product_cost
				if (!isplayer)
					wagesystem.shipping_budget += round(R.product_cost * profit) // cogwerks - maybe money shouldn't just vanish into the aether idk
				else
					//Players get 90% of profit from player vending machines QMs get 10%
					var/obj/machinery/vending/player/T = src
					T.owneraccount["current_money"] += round(R.product_cost * profit)
					wagesystem.shipping_budget += round(R.product_cost * (1 - profit))
				if(R.product_amount <= 0 && !isplayer == 0)
					src.player_list -= R
			//Gotta do this before the SPAWN
			var/obj/item/playervended
			if (player_list)
				var/datum/data/vending_product/player_product/T = R
				playervended = T.contents[1]
				T.contents -= playervended

			SPAWN(src.vend_delay)
				src.vend_ready = 1

				if (ispath(product_path))
					var/atom/movable/vended = new product_path(src.get_output_location()) // changed from obj, because it could be a mob, THANKS VALUCHIMP
					vended.layer = src.layer + 0.1 //So things stop spawning under the fukin thing
					if(isitem(vended))
						usr.put_in_hand_or_eject(vended) // try to eject it into the users hand, if we can
					// else, just let it spawn where it is
				else if (player_list)
					playervended.layer = src.layer + 0.3 //To get over the CRT layer
					usr.put_in_hand_or_eject(playervended)
				else if (isicon(R.product_path))
					var/icon/welp = icon(R.product_path)
					if (welp.Width() > 32 || welp.Height() > 32)
						welp.Scale(32, 32)
						R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
					var/obj/dummy = new /obj/item(src.get_output_location())
					dummy.name = R.product_name
					dummy.desc = "?!"
					dummy.icon = welp
				else if (isfile(R.product_path))
					var/S = sound(R.product_path)
					if (S)
						playsound(src.loc, S, 50, 0)
				src.postvend_effect()

				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "productDispensed=[R.product_name]")
				src.scan = null

			if(R.logged_on_vend)
				logTheThing(LOG_STATION, usr, "vended a logged product ([R.product_name]) from [src] at [log_loc(src)].")
			if(player_list)
				logTheThing(LOG_STATION, usr, "vended a player product ([R.product_name]) from [src] at [log_loc(src)].")
		if (href_list["logout"])
			src.scan = null

		if (href_list["return_credits"])
			SPAWN(src.vend_delay)
				if (src.credit > 0)
					var/obj/item/currency/spacecash/returned = new /obj/item/currency/spacecash
					returned.setup(src.get_output_location(), src.credit)

					usr.put_in_hand_or_eject(returned) // try to eject it into the users hand, if we can
					src.credit = 0
					boutput(usr, "<span class='notice'>You receive [returned].</span>")

		if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num_safe(href_list["cutwire"])
			if (!usr.find_tool_in_hand(TOOL_SNIPPING))
				boutput(usr, "You need a snipping tool!")
				return
			else if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)

		if ((href_list["pulsewire"]) && (src.panel_open || isAI(usr)))
			var/twire = text2num_safe(href_list["pulsewire"])
			if (! (usr.find_tool_in_hand(TOOL_PULSING) || isAI(usr)) )
				boutput(usr, "You need a multitool or similar!")
				return
			else if (src.isWireColorCut(twire))
				boutput(usr, "You can't pulse a cut wire.")
				return
			else
				src.pulse(twire)
	else
		usr.Browse(null, "window=vending")
		return
	return

/obj/machinery/vending/process()
	if (status & BROKEN)
		return
	..()
	if (status & NOPOWER)
		return

	if (!src.active)
		return

	if (src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if (prob(src.slogan_chance) && ((src.last_slogan + src.slogan_delay) <= world.time) && (length(src.slogan_list) > 0))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if ((prob(shoot_inventory_chance)) && (src.shoot_inventory))
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if (status & NOPOWER)
		return

	if (!message)
		return

	var/image/chat_maptext/slogan_text
	var/text_out

	if (istype(src.loc, /turf))
		if (src.glitchy_slogans)
			text_out = voidSpeak(message)
		else
			text_out = message
		slogan_text = make_chat_maptext(src, text_out, "color: [src.slogan_text_color];", alpha = src.slogan_text_alpha)
		if (slogan_text && src.chat_text && length(src.chat_text.lines))
			slogan_text.measure(src)
			for (var/image/chat_maptext/I in src.chat_text.lines)
				if (I != slogan_text)
					I.bump_up(slogan_text.measured_height)

	if (!text_out)
		return

	if (src.glitchy_slogans)
		src.audible_message("<span class='game say'><span class='name'>[src]</span> beeps,</span> \"[text_out]\"", 2, assoc_maptext = slogan_text)
	else
		src.audible_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"[text_out]\"</span></span>", 2, assoc_maptext = slogan_text)

	return

/obj/machinery/vending/proc/prevend_effect()
	playsound(src.loc, 'sound/machines/driveclick.ogg', 30, 1, 0.1)
	return

/obj/machinery/vending/proc/postvend_effect()
	playsound(src.loc, 'sound/machines/vending_dispense.ogg', 40, 0, 0.1)
	return

/obj/machinery/vending/power_change()
	if (can_fall == 2)
		icon_state = icon_fallen ? icon_fallen : "[initial(icon_state)]-fallen"
		light.disable()
		return

	if (status & BROKEN)
		icon_state = icon_broken ? icon_broken : "[initial(icon_state)]-broken"
		light.disable()
	else
		if ( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
			light.enable()
		else
			SPAWN(rand(0, 15))
				src.icon_state = icon_off ? icon_off : "[initial(icon_state)]-off"
				status |= NOPOWER
				light.disable()

/obj/machinery/vending/proc/fall(mob/living/carbon/victim)
	if (can_fall != 1)
		return
	can_fall = 2
	status |= BROKEN
	var/turf/vicTurf = get_turf(victim)
	src.icon_state = "[initial(icon_state)]-fallen"
	playsound(src.loc, 'sound/machines/vending_crash.ogg', 50, 0)
//	SPAWN(0)
//		src.icon_state = "[initial(icon_state)]-fall"
//		SPAWN(2 SECONDS)
//			src.icon_state = "[initial(icon_state)]-fallen"
	if (istype(victim) && vicTurf && (BOUNDS_DIST(vicTurf, src) == 0))
		victim.do_disorient(80, 5 SECONDS, 5 SECONDS, 0, 3 SECONDS, FALSE, DISORIENT_NONE, FALSE)
		src.visible_message("<b><font color=red>[src.name] tips over onto [victim]!</font></b>")
		logTheThing(LOG_COMBAT, src, "falls on [constructTarget(victim,"combat")] at [log_loc(vicTurf)].")
		victim.force_laydown_standup()
		victim.set_loc(vicTurf)
		if (src.layer < victim.layer)
			src.layer = victim.layer+1
		src.set_loc(vicTurf)
		random_brute_damage(victim, rand(20,40),1)
	else
		src.visible_message("<b><font color=red>[src.name] tips over!</font></b>")

	src.power_change()
	src.anchored = UNANCHORED
	return

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_list)
		if (R.product_amount <= 0) //Try to use a record that actually has something to dump.
			continue

		var/dump_path = null
		if (ispath(R.product_path))
			dump_path = R.product_path
		else if (istext(R.product_path))
			dump_path = text2path(R.product_path)
			if (isnull(dump_path))
				continue
		else
			continue

		while(R.product_amount>0)
			new dump_path(src.loc)
			R.product_amount--
		break

	status |= BROKEN
	power_change()
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item(var/item_name_to_throw = "")
	var/mob/living/target = null
	for (var/mob/living/mob in view(7,src))
		if (!isintangible(mob))
			target = mob
			break

	if(!target)
		return null

	if(length(item_name_to_throw))
		for(var/datum/data/vending_product/R in src.product_list)
			if(lowertext(item_name_to_throw) == lowertext(strip_html(R.product_name_cache[R.product_path], no_fucking_autoparse = TRUE)))
				if(R.product_amount > 0 && !(R.product_hidden && !src.extended_inventory))
					throw_item_act(R, target)
					return R
				return
	else
		var/list/datum/data/vending_product/valid_products = list()
		for(var/datum/data/vending_product/R in src.product_list)
			if(R.product_amount <= 0 || (R.product_hidden && !src.extended_inventory)) //Try to use a record that actually has something to dump.
				continue
			valid_products.Add(R)
		if(length(valid_products))
			var/datum/data/vending_product/vending_product = pick(valid_products)
			throw_item_act(vending_product, target)
			return vending_product

/obj/machinery/vending/proc/throw_item_act(var/datum/data/vending_product/R, var/mob/living/target)
	var/obj/throw_item = null
	//Big if/else trying to create the object properly
	if (ispath(R.product_path))
		var/dump_path = R.product_path
		throw_item = new dump_path(src.loc)
	else if (istext(R.product_path))
		var/dump_path = text2path(R.product_path)
		if (dump_path)
			throw_item = new dump_path(src.loc)
	else if (isicon(R.product_path))
		var/icon/welp = icon(R.product_path)
		if (welp.Width() > 32 || welp.Height() > 32)
			welp.Scale(32, 32)
			R.product_path = welp // if scaling is required reset the product_path so it only happens the first time
		var/obj/dummy = new /obj/item(src.get_output_location())
		dummy.name = R.product_name
		dummy.desc = "?!"
		dummy.icon = welp
		throw_item = dummy
	else if (isfile(R.product_path))
		var/sound/S = sound(R.product_path)
		if (S)
			R.product_amount--
			SPAWN(0)
				playsound(src.loc, S, 50, 0)
				src.visible_message("<span class='alert'><b>[src] launches [R.product_name] at [target.name]!</b></span>")
			return 1

	if (throw_item)
		R.product_amount--
		use_power(10)
		if (src.icon_vend) //Show the vending animation if needed
			flick(src.icon_vend,src)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "productDispensed=[R.product_name]")
		throw_item.throw_at(target, 16, 3)
		src.visible_message("<span class='alert'><b>[src] launches [throw_item.name] at [target.name]!</b></span>")
		postvend_effect()
		return 1
	return 0


/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1
		if (WIRE_SCANID) //yeah the scanID wire also controls the AI control FUCK YOU
			if(src.ai_control_enabled)
				src.ai_control_enabled = 0

/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SCANID)
			src.ai_control_enabled = 1
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch (wireIndex)
		if (WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
		if (WIRE_SCANID)
			src.ai_control_enabled = !src.ai_control_enabled
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory

//"Borrowed" airlock shocking code.
/obj/machinery/vending/proc/shock(mob/user, prb)
	if (!prob(prb))
		return 0

	if (status & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0

	if (src.electrocute(user, 1))
		return 1
	else
		return 0

/obj/machinery/vending/electrocute(mob/user, netnum)
	if (!netnum)		// unconnected cable is unpowered
		return 0

	var/datum/powernet/PN			// find the powernet
	if (powernets && length(powernets) >= netnum)
		PN = powernets[netnum]

	elecflash(src)

	if (!PN) //Wire note: Fix for Cannot read null.avail
		return 0

	if (in_interact_range(src, user) && user.shock(src, PN.avail, user.hand == LEFT_HAND ? "l_arm" : "r_arm", 1, 0))
		for (var/mob/M in AIviewers(src))
			if (M == user)	continue
			M.show_message("<span class='alert'>[user.name] was shocked by the [src.name]!</span>", 3, "<span class='alert'>You hear a heavy electrical crack</span>", 2)
		return 1
	return 0

/obj/machinery/vending/proc/right()
	src.can_fall = 1
	src.layer = initial(src.layer)
	src.anchored = ANCHORED
	src.status &= ~BROKEN
	src.power_change()

/datum/action/bar/icon/right_vendor //This is used when you try to remove someone elses handcuffs.
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "right_vendor"
	icon = 'icons/obj/items/tools/crowbar.dmi'
	icon_state = "crowbar"
	var/obj/machinery/vending/vendor = null

	New(vending_machine, var/Owner)
		src.vendor = vending_machine
		src.owner = Owner
		..()

	onUpdate()
		..()
		if(!(BOUNDS_DIST(src.owner, src.vendor) == 0) || src.vendor == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!(src.vendor.status & BROKEN)) //it somehow got fixed while making it go upright??
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!(BOUNDS_DIST(src.owner, src.vendor) == 0) || src.vendor == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/M in AIviewers(src.owner))
			M.show_message("<span class='notice'><B>[src.owner] starts trying to pry \the [src.vendor] back up...</B></span>", 1)

	onEnd()
		..()
		if(src.owner && vendor && (src.vendor.status & BROKEN))
			vendor.right()
			for(var/mob/M in AIviewers(src.owner))
				M.show_message("<span class='notice'><B>[src.owner] manages to stand \the [src.vendor] back upright!</B></span>", 1)

#undef WIRE_EXTEND
#undef WIRE_SCANID
#undef WIRE_SHOCK
#undef WIRE_SHOOTINV

/obj/machinery/vending/coffee
	name = "coffee machine"
	desc = "A Robust Coffee vending machine."
	pay = 1
	vend_delay = 15
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	icon_panel = "coffee-panel"
	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, 25, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/tea, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/xmas, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/yerba, 10, cost=PAY_TRADESMAN/6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/chickensoup, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/weightloss_shake, 10, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/mate, 3, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/fruitmilk, 10, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/covfefe, 10, cost=PAY_TRADESMAN, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, rand(1, 6), cost=PAY_UNTRAINED/5, hidden=1)

/obj/machinery/vending/snack
	name = "snack machine"
	desc = "Tasty treats for crewman eats."
	pay = 1
	icon_state = "snack"
	icon_panel = "snack-panel"
	slogan_list = list("Try our new nougat bar!",
	"Twice the calories for half the price!",
	"Fill the gap in your stomach right now!",
	"A fresh delight is only a bite away!",
	"We feature Discount Dan's Noodle Soups!")
	light_r =1
	light_g = 0.4
	light_b = 0.4

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/candy/chocolate, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/chips, 10, cost=PAY_UNTRAINED/15)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/donut, 10, cost=PAY_TRADESMAN/20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/candy/nougat, 10, cost=PAY_UNTRAINED/12)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/fries, 10, cost=PAY_TRADESMAN/15)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/noodlecup, 10, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/burrito, 10, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/popsicle, 10, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/plasticpackage, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork/plastic, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon/plastic, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/plastic, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/tvdinner, 10, cost=PAY_UNTRAINED/6)


/obj/machinery/vending/cigarette
	name = "cigarette machine"
	desc = "If you want to get cancer, might as well do it in style!"
	pay = 1
	vend_delay = 10
	icon_state = "cigs"
	icon_panel = "cigs-panel"
	slogan_list = list("Space cigs taste good like a cigarette should!",
	"I'd rather toolbox than switch.",
	"Smoke!",
	"Don't believe the reports - smoke today!")
	light_r =0.55
	light_g = 1
	light_b = 0.5

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/cigpacket, 20, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/nicofree, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/menthol, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/propuffs, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo, 10, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/cigarbox, 1, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/matchbook, 10, cost=PAY_UNTRAINED/20)
		product_list += new/datum/data/vending_product(/obj/item/device/light/zippo, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/decoration/ashtray, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape, 10, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ecig_refill_cartridge, 20, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/item_box/medical_patches/nicotine, 5, cost=PAY_TRADESMAN/5)

		product_list += new/datum/data/vending_product(/obj/item/device/igniter, rand(1, 6), hidden=1, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, rand(0, 1), hidden=1, cost=420)
		product_list += new/datum/data/vending_product(/obj/item/cigpacket/cigarillo/juicer, rand(6, 9), hidden=1, cost=69)

TYPEINFO(/obj/machinery/vending/medical)
	mats = 10

/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "An ID-selective dispenser for drugs and medical equipment"
	icon_state = "med"
	icon_panel = "standard-panel"
	icon_deny = "med-deny"
	req_access = list(access_medical_lockers)
	acceptcard = 0
	light_r =1
	light_g = 0.88
	light_b = 0.88

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/bruise, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/burn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender_refill_cartridge/brute, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/mender_refill_cartridge/burn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antihistamine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/atropine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/calomel, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antitoxin, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/epinephrine, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/filgrastim, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/heparin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/insulin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/morphine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/eyedrops, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/antirad, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/proconvertin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/aspirin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/saline, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/synaptizine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/spaceacillin, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/coldmedicine, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mannitol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/mutadone, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salbutamol, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/ipecac, 8)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 5)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_organ_upgrade, 5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/medical_surgery_guide, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/genetic, 1)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/sulfonal, rand(1, 2), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/pancuronium, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/LSD, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=400)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(7, 13), hidden=1, cost=100)

	postvend_effect()
		playsound(src.loc, 'sound/machines/vending_dispense_small.ogg', 40, 0, 0.1)
		return

/obj/machinery/vending/medical_public
	name = "Public MiniMed"
	desc = "Medical supplies for everyone! Almost nearly as good as what the professionals use, kinda!"
	pay = 1
	vend_delay = 10
	icon_state = "pubmed"
	icon_panel = "pubmed-panel"
	slogan_list = list("It pays to be safe!",
	"It's safest to pay!",
	"We've gone green! Now using 100% recycled materials!",
	"Address all complaints about Public MiniMed services to FILE NOT FOUND for a swift response.",
	"Now 80% sterilized!",
	"There is a 1000 credit fine for bleeding on this machine.",
	"Are you or a loved one currently dying? Consider Discount Dan's burial solutions!",
	"ERROR: Item \"Stimpack\" not found!",
	"Please, be considerate! Do not block access to the machine with your bloodied carcass.",
	"Please contact your insurance provider for details on reduced payment options for this machine!")

	light_r =1
	light_g = 0.88
	light_b = 0.88

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/bruise, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/burn, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/epinephrine, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/salicylic_acid, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/menthol, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/charcoal, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/antihistamine, 2, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/emergency_injector/spaceacillin, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/ampoule/smelling_salts, 2, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer, 2, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/bandage, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/healthanalyzer_upgrade, rand(0, 2), hidden=1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/patch/mini/synthflesh, rand(0, 5), hidden=1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vape/medical, 1, hidden=1, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/bath_bomb, rand(2, 5), hidden=1, cost=PAY_TRADESMAN)
		if (prob(5))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/pill/bathsalts, 1, hidden=1, cost=PAY_TRADESMAN)

		if (prob(15))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/coffee, rand(1,5), hidden=1, cost=PAY_TRADESMAN/10)
		else
			slogan_list += "ERROR: OUT OF COFFEE!"

	postvend_effect()
		playsound(src.loc, 'sound/machines/vending_dispense_small.ogg', 40, 0, 0.1)
		return

/obj/machinery/vending/security
	name = "SecTech"
	desc = "An ID-selective dispenser for security equipment."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access = list(access_security)
	acceptcard = 0

	light_r =1
	light_g = 0.8
	light_b = 0.9

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/handcuffs/guardbot, 16)
		product_list += new/datum/data/vending_product(/obj/item/handcuffs, 8)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/fog, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/flash, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/sec_tape/vended, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38/stun, 2)
		product_list += new/datum/data/vending_product(/obj/item/implantcase/counterrev, 3)
		product_list += new/datum/data/vending_product(/obj/item/implanter, 1)
#ifdef RP_MODE
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/space_law, 1)
#endif
		product_list += new/datum/data/vending_product(/obj/item/device/flash/turbo, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38, rand(1, 2), hidden=1) // Obtaining a backpack full of lethal ammo required no effort whatsoever, hence why nobody ordered AP speedloaders from the Syndicate (Convair880).

/obj/machinery/vending/security_ammo //shitsec time yes
	name = "AmmoTech"
	desc = "A restricted vendor stocked with various riot-suppressive ammunitions."
	icon_state = "sec"
	icon_panel = "standard-panel"
	icon_deny = "sec-deny"
	req_access = list(access_maxsec)
	acceptcard = 0
	light_r =1
	light_g = 0.8
	light_b = 0.9
	is_syndicate = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/abg, 6)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38, 2)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a38/stun, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/nine_mm_NATO,3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/flare, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/smoke, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/pbr, 8)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/tranq_darts, 3)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/tranq_darts/anti_mutant, 3)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/flashbang, 7)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/a12/weak, 1, hidden=1) // this may be a bad idea, but it's only one box //Maybe don't put the delimbing version in here

ABSTRACT_TYPE(/obj/machinery/vending/cola)
/obj/machinery/vending/cola
	name = "soda machine"
	pay = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola, 10, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/canned_laughter, rand(1,5), cost=PAY_UNTRAINED/5,hidden=1)
		if(prob(25))
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/softsoft_pizza, rand(1, 3), cost=PAY_UNTRAINED/5, hidden = 1)

	red
		icon_state = "robust"
		icon_panel = "robust-panel"
		slogan_list = list("Drink Robust-Eez, the classic robustness tonic!",
		"A Dr. Pubber a day keeps the boredom away!",
		"Cool, refreshing Lime-Aid - it's good for you!",
		"Grones Soda! Where has your bottle been today?",
		"Decirprevo. The sophisticate's bottled water.")

		light_r =1
		light_g = 0.4
		light_b = 0.4

		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/red, 10, cost=PAY_UNTRAINED/10)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/pink, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/lime, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/grones, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater, 10, cost=PAY_UNTRAINED/4)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola/random, 10, cost=PAY_UNTRAINED/10)

	blue
		icon_state = "grife"
		icon_panel = "grife-panel"
		slogan_list = list("Grife-O - the soda of a space generation!",
		"The taste of nature!",
		"Spooky Dan's - it's altogether ooky!",
		"Everyone can see Orange-Aid is best!",
		"Decirprevo. The sophisticate's bottled water.")

		light_r =0.5
		light_g = 0.5
		light_b = 1

		create_products()
			..()
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/blue, 10, cost=PAY_UNTRAINED/10)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/orange, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/spooky, 10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/spooky2,10, cost=PAY_UNTRAINED/6)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/soda/bottledwater, 10, cost=PAY_UNTRAINED/4)
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cola/random, 10, cost=PAY_UNTRAINED/10)

/obj/machinery/vending/electronics
	name = "ElecTek Vendomaticotron"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	slogan_list = list("Stop fussing about in boxes, use ElecTek!",
	"Now with boards 100% of the time!",
	"No carbs!",
	"Now with 50% extra inventory!")

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/electronics/battery, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/board, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/fuse, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/switc, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/keypad, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/screen, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/capacitor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/buzzer, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/resistor, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/bulb, 30)
		product_list += new/datum/data/vending_product(/obj/item/electronics/relay, 30)

/obj/machinery/vending/mechanics
	name = "MechComp Dispenser"
	desc = "Dispenses electronics equipment."
	icon_state = "generic"
	icon_panel = "generic-panel"
	acceptcard = 0
	pay = 0

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/mechanicbook, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/andcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/association, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/math, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/counter, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/clock, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/button, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/buttonPanel, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/mc14500, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/interval_timer, 5)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pausecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/dispatchcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder/recharging, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/filecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/flushcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/accelerator, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/gunholder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/hscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/instrumentPlayer, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/ledcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/screen, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/miccomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/movement, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/orcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/pscan, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/cashmoney, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/networkcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/trigger/pressureSensor, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/radioscanner, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regfind, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/regreplace, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/relaycomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/selectcomp, 30)
		product_list += new/datum/data/vending_product(/obj/disposalconstruct/mechanics_sensor, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigbuilder, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/sigcheckcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/textmanip, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/synthcomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/telecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/zapper, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/thprint, 10)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/togglecomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/triplaser, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wificomp, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/wifisplit, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/screen_canvas, 30)
		product_list += new/datum/data/vending_product(/obj/item/mechanics/message_sign, 10)
/obj/machinery/vending/mechanics/attackby(obj/item/W, mob/user)
	if(!istype(W,/obj/item/mechanics))
		..()
		return
	if (W.cant_drop)
		boutput(user, "<span class='alert'>You can't put [W] into a vending machine while it's attached to you!</span>")
		return
	for(var/datum/data/vending_product/product in product_list)
		if(W.type == product.product_path)
			boutput(user, "<span class='notice'>You return the [W] to the vending machine.</span>")
			product.product_amount += 1
			qdel(W)
			return

/obj/machinery/vending/computer3
	name = "CompTech"
	desc = "A computer equipment vendor."
	icon_state = "comp"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	acceptcard = 0

	light_r =1
	light_g = 0.9
	light_b = 0.1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/motherboard, 8)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/fixed_disk, 8)
		//product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 4)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/card_scanner, 8)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/powernet_card, 4)

		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive/cart_reader, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/prize_vendor, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/network/radio, rand(1, 6), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/peripheral/drive/tape_reader, rand(1, 6), hidden=1)

//cogwerks- adding a floppy disk vendor
/obj/machinery/vending/floppy
	name = "SoftTech"
	desc = "A computer software vendor."
	icon_state = "software"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Remember to read the EULA!",
	"Don't copy that floppy!",
	"Welcome to the information age!")

	light_r =0.03
	light_g = 1
	light_b = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/computer3boot, 6, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/terminal_os, 6, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/network_progs, 4, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/medical_progs, 2, cost=PAY_TRADESMAN/2)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/security_progs, 2, cost=PAY_TRADESMAN/2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy/read_only/communications, 2, cost=PAY_TRADESMAN, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/diskbox, rand(2,3), cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/floppy, rand(5,8), cost=PAY_UNTRAINED/5)


/obj/machinery/vending/pda //cogwerks: vendor to clean up the pile of PDA carts a bit
	name = "CartyParty"
	desc = "A PDA cartridge vendor."
	icon_state = "pda"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Convenient and feature-packed!",
	"For the busy jet-setting businessperson on the go!",
	"-CHECKSUM FAILURE | STACK OVERFLOW - CONSULT YOUR TECHN-WONK")

	light_r =0.4
	light_g = 0.4
	light_b = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/pda2, 20, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/atmos, 5, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/game_codebreaker, 10, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/janitor, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/genetics, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/engineer, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/botanist, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/medical, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/toxins, 5, cost=PAY_DOCTORATE/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/quartermaster, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone, 5, cost=PAY_TRADESMAN/6)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_basic, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_chimes, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/ringtone_beepy, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/device/pda_module/flashlight/high_power, 10, cost=PAY_UNTRAINED/2)

		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/security, 1, cost=PAY_TRADESMAN/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/head, 1, cost=PAY_IMPORTANT/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/disk/data/cartridge/clown, 1, cost=PAY_DUMBCLOWN, hidden=1)

/obj/machinery/vending/book //cogwerks: eventually this oughta have some of the wiki job guides available in it
	name = "Books4u"
	desc = "A printed text vendor."
	icon_state = "books"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Read a book today!",
	"Educate thyself!",
	"Book Club meeting in the Chapel, every Thursday!")

	light_r =0.2
	light_g = 1
	light_b = 0.03

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/engine, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/cookbook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/dwainedummies, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/guardbot_guide, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/hydroponicsguide, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/bee_book, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/Cloning, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/pharmacopia, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/minerals, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/player_piano, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/DNDrulebook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual_revised, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/ai_programming_101, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/captaining_101, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/dealing_with_clonelieness, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/elective_prosthetics_for_dummies, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/fun_facts_about_shelterfrogs, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/teg_guide, 2, cost=PAY_UNTRAINED/5)

		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/the_trial, 1, cost=PAY_UNTRAINED/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/critter_compendium, 1, cost=PAY_UNTRAINED/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/syndies_guide/stolen, 1, cost=PAY_UNTRAINED/5, hidden=1)

/obj/machinery/vending/kitchen
	name = "FoodTech"
	desc = "Food storage unit."
	icon_state = "food"
	icon_panel = "standard-panel"
	icon_off = "food-off"
	icon_broken = "food-broken"
	icon_fallen = "food-fallen"
	req_access = list(access_kitchen)
	acceptcard = 0

	light_r =1
	light_g = 0.88
	light_b = 0.3


	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron,2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/fork, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife, 10)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/spoon, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/drinkingglass/icing, 3)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/chopsticks_package, 5)
		product_list += new/datum/data/vending_product(/obj/item/plate/tray, 3)
		product_list += new/datum/data/vending_product(/obj/surgery_tray/kitchen_island, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/lunchbox, 12)
		product_list += new/datum/data/vending_product(/obj/item/ladle, 1)
		product_list += new/datum/data/vending_product(/obj/item/soup_pot, 1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/syringe/baster, 3)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/rollingpin, 2)
		product_list += new/datum/data/vending_product(/obj/item/kitchen/utensil/knife/pizza_cutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bowl, 10)
		product_list += new/datum/data/vending_product(/obj/item/plate, 10)
		product_list += new/datum/data/vending_product(/obj/item/plate/pizza_box, 5)
		product_list += new/datum/data/vending_product(/obj/item/matchbook, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ice_cream_cone, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/oatmeal, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/flour, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/rice, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/sugar, 20)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/butter, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/spaghetti, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/meatball, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/syrup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/mayo, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/ketchup, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/condiment/soysauce, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/tomato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/apple, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/lettuce, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/potato, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/corn, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/ingredient/seaweed, 10)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/breakfast, rand(2, 4), hidden=1,)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/snack_cake, rand(1, 3), hidden=1,)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron/tricolor, rand(2, 2), hidden=1,)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/moustache/Italian , rand(2, 2), hidden=1,)
		product_list += new/datum/data/vending_product(pick(/obj/item/paper/recipe_tandoori, /obj/item/paper/recipe_potatocurry, /obj/item/paper/recipe_coconutcurry, /obj/item/paper/recipe_chickenpapplecurry), 1, hidden = 1)

//The burden of these machinations weighs on my shoulders
//And thus you will be burdened
/datum/data/vending_product/player_product
	var/contents
	var/product_type
	var/real_name
	var/image/icon
	var/label
	product_amount = 1
	New(obj/item/product,price)
		. = ..()
		contents = list()
		if (!product)
			return
		product_type = product.type
		product_name = product.name
		product_path = product_type
		real_name = product.real_name
		contents += product
		product_cost = price

	getBase64Img()
		var/key = "\ref[src]"
		. = product_base64_cache[key]
		if(isnull(.))
			var/icon/dummy_icon = getFlatIcon(src.contents[1], no_anim=TRUE)
			. = icon2base64(dummy_icon)
			product_base64_cache[key] = .

TYPEINFO(/obj/item/machineboard)
	mats = 2

/obj/item/machineboard
	name = "machine module"
	desc = "A circuit board assembly used in the construction of machinery."
	icon = 'icons/obj/electronics.dmi'
	icon_state = "board1"
	var/machinepath = null

/obj/item/machineboard/vending
	name = "vending machine module"
	desc = "An assembly used in the construction of a vending machine."
	machinepath = "/obj/machinery/vending/player"
	icon = 'icons/obj/vending.dmi'
	icon_state = "base-module"

/obj/item/machineboard/vending/player
	icon_state = "player-module"

TYPEINFO(/obj/item/machineboard/vending/monkeys)
	mats = 0 //No!!

/obj/item/machineboard/vending/monkeys
	name = "Valuchimp module"
	machinepath = "/obj/machinery/vending/monkey"
	icon_state = "monkey-module"

/obj/machinery/vendingframe
	name = "vending machine frame"
	desc = "A generic vending machine frame."
	icon = 'icons/obj/vending.dmi'
	icon_state = "standard-frame"
	density = 1
	material_amt = 0.3
	var/wrenched = FALSE
	var/glassed = FALSE
	var/boardinstalled = FALSE
	var/wiresinstalled = FALSE
	var/vendingtype = null
	var/basedesc
	var/boarddesc
	var/wiresdesc
	var/glassdesc
	var/readydesc
	New()
		. = ..()
		basedesc = desc
		boarddesc = "[desc] Seems to be missing the module, and everything else."
		wiresdesc = "[desc] Nothing has been wired up."
		glassdesc = "[desc] Isn't there usually glass?"
		readydesc = "[desc] Just needs a few screws tightened."

	proc/setFrameState(state, mob/user, obj/item/target)
		if (state == "WRENCHED")
			wrenched = TRUE
			anchored = ANCHORED
			desc = boarddesc
			boutput(user, "<span class='notice'>You wrench the frame into place.</span>")
		else if (state == "UNWRENCHED")
			wrenched = FALSE
			anchored = UNANCHORED
			desc = basedesc
			boutput(user, "<span class='notice'>You unfasten the frame.</span>")
		else if (state == "BOARDINSTALLED")
			var/obj/item/machineboard/vending/V = target
			vendingtype = V.machinepath
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			icon_state = "standard-frame-electronics"
			desc = wiresdesc
			boutput(user, "<span class='notice'>You install the module inside the frame.</span>")
			user.u_equip(target)
			target.set_loc(target)
			boardinstalled = TRUE
		else if (state == "WIRESINSTALLED")
			var/obj/item/cable_coil/targetcoil = target
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			targetcoil.use(5)
			wiresinstalled = TRUE
			icon_state = "standard-frame-wired"
			desc = glassdesc
			boutput(user, "<span class='notice'>You add cables to the frame.</span>")
		else if (state == "GLASSINSTALLED")
			var/obj/item/sheet/glass/S = target
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			S.change_stack_amount(-2)
			glassed = TRUE
			icon_state = "standard-frame-glassed"
			desc = readydesc
			boutput(user, "<span class='notice'>You put in the glass panel.</span>")
		else if (state == "GLASSREMOVED")
			var/obj/item/sheet/glass/A = new /obj/item/sheet/glass(src.loc)
			A.amount = 2
			glassed = FALSE
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			icon_state = "standard-frame-wired"
			desc = glassdesc
			boutput(user, "<span class='notice'>You remove the glass panel.</span>")
		else if (state == "BOARDREMOVED")
			icon_state = "standard-frame"
			desc = boarddesc
			boutput(user, "<span class='notice'>You remove the vending module.</span>")
			var/obj/item/machineboard/vending/E = locate()
			E.set_loc(src.loc)
			boardinstalled = FALSE
		else if (state == "WIRESREMOVED")
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			icon_state = "standard-frame-electronics"
			desc = wiresdesc
			boutput(user, "<span class='notice'>You remove the cables.</span>")
			var/obj/item/cable_coil/C = new /obj/item/cable_coil(src.loc)
			C.amount = 5
			C.UpdateIcon()
			wiresinstalled = FALSE
		else if (state == "DECONSTRUCTED")
			boutput(user, "<span class='notice'>You deconstruct the frame.</span>")
			var/obj/item/sheet/A = new /obj/item/sheet(src.loc)
			A.amount = 3
			if (src.material)
				A.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				A.setMaterial(M)
			qdel(src)
		else
			setFrameState("UNWRENCHED")
			CRASH("Invalid state \"[state]\" set in [src] construction process at [log_loc(src)]")

	attackby(obj/item/target, mob/user)
		if (iswrenchingtool(target))
			if (!wrenched)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("WRENCHED", user), target.icon, target.icon_state, null, null)
			else if (!boardinstalled && wrenched)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("UNWRENCHED", user), target.icon, target.icon_state, null, null)
		else if (istype(target, /obj/item/machineboard/vending))
			if (wrenched && !boardinstalled)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("BOARDINSTALLED", user, target), target.icon, target.icon_state, null, null)
		else if (istype(target, /obj/item/cable_coil) && boardinstalled && !wiresinstalled)
			var/obj/item/cable_coil/targetcoil = target
			if (targetcoil.amount >= 5)
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("WIRESINSTALLED", user, target), target.icon, target.icon_state, null, null)
			else if (!wiresinstalled && boardinstalled)
				boutput(user, "<span class='alert'>You need at least five pieces of cable to wire the vending machine.</span>")
		else if (istype(target, /obj/item/sheet) && wiresinstalled && !glassed)
			var/obj/item/sheet/glass/S = target
			if (!(S.material && S.amount >= 2))
				return
			setFrameState("GLASSINSTALLED", user, target)
		else if (isscrewingtool(target) && glassed)
			boutput(user, "<span class='notice'>You connect the screen.</span>")
			var/obj/machinery/vending/B = new vendingtype(src.loc)
			logTheThing(LOG_STATION, user, "assembles [B] [log_loc(B)]")
			qdel(src)
		else if (ispryingtool(target))
			if (glassed)
				setFrameState("GLASSREMOVED", user)
			else if (!wiresinstalled && boardinstalled)
				setFrameState("BOARDREMOVED", user)
		else if (issnippingtool(target) && wiresinstalled && !glassed)
			setFrameState("WIRESREMOVED", user)
		else if (isweldingtool(target) && !wrenched)
			var/obj/item/weldingtool/T = target
			if (T.try_weld(user,0,-1,1,1))
				SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/vendingframe/proc/setFrameState,\
				list("DECONSTRUCTED", user, target), target.icon, target.icon_state, null, null)
		else . = ..()

/obj/machinery/vending/player
	name = "Build-A-Vend" // Thanks Eagletanker
	icon_state = "player"
	desc = "A vending machine offering presumably legal goods sold by other crewmembers."
	pay = 1
	layer = OBJ_LAYER - 0.3
	//Product loading chute
	var/loading = FALSE
	var/unlocked = FALSE
	//Registered owner
	var/owner = null
	//card display name
	var/cardname
	//Bank account
	var/datum/db_record/owneraccount = null
	var/image/crtoverlay = null
	var/does_crt = TRUE
	var/image/promoimage = null
	///Set this var to update all static data at the end of the machine tick, done like this to avoid updating for every item added in a stack
	var/static_data_invalid = FALSE
	player_list = list()
	icon_panel = "standard-panel"

	New()
		. = ..()
		if (!src.does_crt)
			return
		crtoverlay = SafeGetOverlayImage("screen", src.icon, "player-crt")
		crtoverlay.layer = src.layer + 0.2
		crtoverlay.plane = PLANE_DEFAULT
		//These stop the overlay from being selected instead of the item by your mouse?
		crtoverlay.appearance_flags = NO_CLIENT_COLOR | PIXEL_SCALE
		crtoverlay.mouse_opacity = 0
		src.registerDisposals()
		updateAppearance()

	disposing()
		src.unregisterDisposals()
		. = ..()

	proc/pick_product_name()
		var/datum/data/vending_product/player_product/R = pick(src.player_list)
		var/itemPromo = sanitize(html_encode(R.product_name))
		return itemPromo

	proc/generate_slogans()
		if (!length(player_list) <= 0)
			slogan_list = list("By popular demand: [pick_product_name()]!",
		"[src.name]. The better vending machine.",
		"Potentially well stocked!",
		"Buy my stuff!",
		"Don't miss out on [pick_product_name()]!",
		"[src.name]. What else were you going to buy?",
		"New and improved [pick_product_name()]!")

	proc/getScaledIcon(obj/item/target)
		var/image/itemoverlay = null
		itemoverlay = SafeGetOverlayImage(null, target, target.icon_state)
		itemoverlay.transform = matrix(null, 0.45, 0.45, MATRIX_SCALE)
		itemoverlay.pixel_x = -3
		itemoverlay.pixel_y = -4
		itemoverlay.layer = src.layer + 0.1
		itemoverlay.plane = PLANE_DEFAULT
		return itemoverlay

	proc/updateAppearance()
		if (status & BROKEN)
			setCrtOverlayStatus(FALSE)
			setItemOverlay(null)
			panel_open = FALSE
			return FALSE
		else if (powered())
			setCrtOverlayStatus(TRUE)
			if (promoimage)
				icon_state = "[initial(icon_state)]-display"
				setItemOverlay(promoimage)
			else
				icon_state = initial(icon_state)
		else
			setCrtOverlayStatus(FALSE)
			setItemOverlay(null)
			return FALSE

	proc/setItemOverlay(image/target)
		UpdateOverlays(null, "item", 1, 1)
		UpdateOverlays(target, "item", 0, 1)

	proc/setCrtOverlayStatus(status)
		if (status)
			UpdateOverlays(crtoverlay, "screen", 0, 1)
		else
			UpdateOverlays(null, "screen", 0, 1)

	proc/acceptsProduct(atom/product)
		return isitem(product)

	///This is a mild hack, an expel proc to match /obj/disposaloutlet
	proc/expel(obj/disposalholder/holder)
		var/turf/expel_loc = get_turf(src)
		var/turf/target = get_ranged_target_turf(src, src.dir, 10)
		for (var/atom/movable/AM in holder)
			if (src.acceptsProduct(AM))
				src.addProduct(AM, null, TRUE)
			else
				AM.set_loc(expel_loc)
				AM.pipe_eject(src.dir)
				AM.throw_at(target, 10, 1)
		qdel(holder)
		src.static_data_invalid = TRUE

	proc/registerDisposals()
		var/obj/disposalpipe/trunk/trunk = locate() in get_turf(src)
		if (trunk && !trunk.linked)
			trunk.linked = src

	proc/unregisterDisposals()
		var/obj/disposalpipe/trunk/trunk = locate() in get_turf(src)
		if (trunk && trunk.linked == src)
			trunk.linked = null

	fall(mob/living/carbon/victim)
		src.unregisterDisposals()
		. = ..()

	right()
		. = ..()
		src.registerDisposals()

	proc/addProduct(obj/item/target, mob/user, quiet = FALSE)
		if (target.cant_drop)
			if(!quiet)
				boutput(user, "<span class='alert'>You can't put [target] into a vending machine while it's attached to you!</span>")
			return
		var/obj/item/targetContainer = target
		if (!targetContainer.storage && !istype(targetContainer, /obj/item/satchel))
			productListUpdater(target, user)
			if(!quiet)
				user.visible_message("<b>[user.name]</b> loads [target] into [src].")
			return
		var/action = quiet ? "Empty it into the vending machine" : \
			input(user, "What do you want to do with [targetContainer]?") as null|anything in list("Empty it into the vending machine","Place it in the vending machine")
		var/cantuse
		if (action)
			cantuse = ((isdead(user) || !can_act(user) || !in_interact_range(src, user)))
		if (action == "Place it in the vending machine" && !cantuse)
			productListUpdater(target, user)
			if(!quiet)
				user.visible_message("<b>[user.name]</b> loads [target] into [src].")
			return
		else if (cantuse || !action)
			return
		if(!quiet)
			user.visible_message("<b>[user.name]</b> dumps out [targetContainer] into [src].")

		for (var/obj/item/I as anything in targetContainer.storage.get_contents())
			targetContainer.storage.transfer_stored_item(I, src, user = user)
			productListUpdater(I, user)
		if (istype(targetContainer, /obj/item/satchel))
			targetContainer.UpdateIcon()
			targetContainer.tooltip_rebuild = 1

	proc/productListUpdater(obj/item/target, mob/user)
		if (!target)
			return
		user?.u_equip(target)
		target.set_loc(src)
		target.layer = (initial(target.layer))
		var/existed = FALSE
		//Finds items that have been labeled
		var/regex/labelFinder = new("\\*? \\(.*?\\)")
		//Extracts label contents via regex replace
		var/regex/labelExtractor = new("(?:.*?\\()(.*?)\\)")
		var/label = null
		if ((target.real_name != target.name) && labelFinder.Find(target.name))
			label = labelExtractor.Replace(target.name, "$1")
		//Add the item to an existing entry if there is one
		for (var/datum/data/vending_product/player_product/R in src.player_list)
			if (label && label == R.label)
				R.contents += target
				R.product_amount += 1
				existed = TRUE
				break
			else if (istype(target,R.product_type) && (R.real_name || R.product_name) == (target.real_name || target.name))
				R.contents += target
				R.product_amount += 1
				existed = TRUE
				break
		if (!existed)
			var/datum/data/vending_product/player_product/itemEntry = new/datum/data/vending_product/player_product(target, 15)
			itemEntry.icon = getScaledIcon(target)
			player_list += itemEntry
			if (label) itemEntry.label = label
			logTheThing(LOG_STATION, user, "added player product ([target.name]) to [src] at [log_loc(src)].")
			generate_slogans()

	power_change()
		. = ..()
		updateAppearance()

	process()
		. = ..()
		if (src.static_data_invalid)
			src.static_data_invalid = FALSE
			for (var/datum/tgui/ui as anything in tgui_process.get_uis(src))
				src.update_static_data(null, ui)
		//Don't update if we're working, always handle that in power_change()
		if ((status & BROKEN) || status & NOPOWER)
			updateAppearance()

	MouseDrop_T(atom/movable/dropped, mob/user)
		..()
		if (!dropped || !user || !isliving(user) || isintangible(user) || BOUNDS_DIST(dropped, user) > 0 || !in_interact_range(src, user) || !can_act(user))
			return

		if (istype(dropped, /obj/storage/crate) || istype(dropped, /obj/storage/cart))
			if(!loading || !panel_open)
				boutput(user, "<span class='alert'>\The [src]'s chute is not open to load stuff in!</span>")
				return

			var/obj/storage/store = dropped
			if(istype(store) && (store.welded || store.locked))
				boutput(user, "<span class='alert'>You cannot load from a [store] that cannot open!</span>")
				return

			var/num_loaded = 0
			for (var/obj/item/I in (dropped.storage?.get_contents() || dropped.contents))
				addProduct(I, user, quiet=TRUE)
				if(I.loc == src)
					num_loaded++
			if(num_loaded)
				boutput(user, "<span class='notice'>You load [num_loaded] item\s from \the [dropped] into \the [src].</span>")
				update_static_data(user)
			else if(length(dropped.contents))
				boutput(user, "<span class='alert'>\The [dropped] is empty!</span>")
			else
				boutput(user, "<span class='alert'>No items were loaded from \the [dropped] into \the [src]!</span>")

	attackby(obj/item/target, mob/user)
		if (loading && panel_open)
			addProduct(target, user)
			update_static_data(user)
		else
			. = ..()
		if (!panel_open) //lock up if the service panel is closed
			loading = FALSE
			unlocked = FALSE

/obj/machinery/vending/player/fallen
	New()
		. = ..()
		src.fall()
//Somewhere out in the vast nothingness of space, a chef (and an admin) is crying.

/obj/machinery/vending/pizza
	name = "pizza vending machine"
	icon_state = "pizza"
	desc = "A vending machine that serves... pizza?"
	var/bolt_status = " It is bolted to the floor."
	var/pizcooking = 0
	var/piztopping = "plain"
	anchored = ANCHORED
	acceptcard = FALSE
	vend_inhand = FALSE
	pay = TRUE
	pay = 1
	credit = 100
	slogan_list = list("A revolution in the pizza industry!",
	"Prepared in moments!",
	"I'm a chef who works 24 hours a day!")
	vend_delay = 20 SECONDS
	var/sharpen = FALSE
	var/price = 50
	light_r =1
	light_g = 0.6
	light_b = 0.2

	New()
		. = ..()
		update_desc()

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/pizza, 1, cost=src.price, infinite=TRUE)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/pizza/pepperoni, 1, cost=src.price, infinite=TRUE)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/pizza/mushroom, 1, cost=src.price, infinite=TRUE)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/pizza/meatball, 1, cost=src.price, infinite=TRUE)

	vend_product()
		var/obj/item/reagent_containers/food/snacks/pizza/pizza = ..()
		if (src.sharpen)
			pizza.sharpened = TRUE
			var/list/slices = pizza.make_slices()
			for(var/obj/item/reagent_containers/food/snacks/pizza/slice in slices)
				slice.throw_at(usr, 16, 3)
			return slices[1]
		else
			return pizza

	prevend_effect()
		playsound(src.loc, 'sound/machines/driveclick.ogg', 30, 1, 0.1)
		src.pizcooking = TRUE
		src.icon_state = "pizza-vend"

	postvend_effect()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1, -1)
		src.pizcooking = FALSE
		if (!(src.status & (NOPOWER|BROKEN)))
			src.icon_state = "pizza"

	ui_data(mob/user)
		. = ..()
		.["busy"] = src.pizcooking
		.["busyphrase"] = "Cooking your pizza!"

	emag_act(mob/user, obj/item/card/emag/E)
		if(..())
			for (var/datum/data/vending_product/product in src.product_list)
				product.product_cost = 0

	demag(mob/user)
		if (..())
			for (var/datum/data/vending_product/product in src.product_list)
				product.product_cost = src.price

	attackby(obj/item/W, mob/user)
		if (!sharpen && istype(W, /obj/item/kitchen/utensil/knife/pizza_cutter/traitor))
			sharpen = TRUE
			add_fingerprint(user)
			boutput(user, "You jam the pizza sharpener inside the vending machine.")
			user.u_equip(W)
			qdel(W)
			return
		if(iswrenchingtool(W) && !(status & BROKEN))
			if (!src.anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You secure the external reinforcing bolts to the floor.")
				src.anchored = ANCHORED
				update_desc()
				return
			else
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				boutput(user, "You undo the external reinforcing bolts.")
				src.anchored = UNANCHORED
				update_desc()
				return
		return ..()

/obj/machinery/vending/pizza/proc/update_desc()
	if (src.anchored)
		bolt_status = " It is bolted to the floor."
	else
		bolt_status = ""
	desc = initial(src.desc) + bolt_status

/obj/machinery/vending/pizza/fallen
	New()
		. = ..()
		src.fall()
		update_desc()

TYPEINFO(/obj/machinery/vending/monkey)
	mats = 0 // >:I

/obj/machinery/vending/monkey
	name = "ValuChimp"
	desc = "More fun than a barrel of monkeys! Monkeys may or may not be synthflesh replicas, may or may not contain partially-hydrogenated banana oil."
	icon_state = "monkey"
	icon_panel = "standard-panel"
	// monkey vendor has slightly special broken/etc sprites so it doesn't just inherit the standard set  :)
	acceptcard = 0
	slogan_list = list("My monkeys are too strong for you, traveler!")
	slogan_chance = 1

	light_r =1
	light_g = 0.88
	light_b = 0.3

	create_products()
		..()
		product_list += new/datum/data/vending_product(/mob/living/carbon/human/npc/monkey, rand(10, 15), logged_on_vend=TRUE)

		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/monkey_translator, rand(1,2), hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/snacks/plant/banana, rand(1,20), hidden=1)

/obj/machinery/vending/monkey/kitchen
	icon_state = "monkey-k"
	req_access = list(access_kitchen, access_heads)

	get_desc()
		. += "This vendor is restricted to kitchen access."

/obj/machinery/vending/monkey/genetics
	icon_state = "monkey-g"
	req_access = list(access_medical_lockers, access_heads)

	get_desc()
		. += "This vendor is restricted to medical access."

/obj/machinery/vending/monkey/research
	icon_state = "monkey-r"
	req_access = list(access_research, access_heads)

	get_desc()
		. += "This vendor is restricted to research access."

/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "wiz"
	icon_panel = "standard-panel"
	can_fall = FALSE
	acceptcard = 0
	slogan_list = list("Sling spells the proper way with MagiVend!",
	"Be your own Houdini! Use MagiVend!")

	vend_delay = 15
	vend_reply = "Have an enchanted evening!"

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/green, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/green, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/witch, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/wizard/necro, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wizrobe/necro, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/sandal/magic/wizard, 8)
		product_list += new/datum/data/vending_product(/obj/item/staff, 4)
		product_list += new/datum/data/vending_product(/obj/item/staff/crystal, 4, hidden=1)

/obj/machinery/vending/standard
	desc = "A vending machine full of various useful tools and devices that definitely cannot be used to make bombs"
	icon_state = "standard"
	icon_panel = "standard-panel"
	acceptcard = 0
	slogan_list = list("Please make your selection.")

	light_r =1
	light_g = 0.81
	light_b = 0.81

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/prox_sensor, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/igniter, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/signaler, 8)
		product_list += new/datum/data/vending_product(/obj/item/wirecutters, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/timer, 8)
		product_list += new/datum/data/vending_product(/obj/item/device/analyzer/atmosanalyzer_upgrade, 3)
		product_list += new/datum/data/vending_product(/obj/item/pressure_crystal, 5)
		product_list += new/datum/data/vending_product(/obj/item/device/pressure_sensor, 2)

		product_list += new/datum/data/vending_product(/obj/item/device/light/flashlight, rand(1, 6), hidden=1)
		//product_list += new/datum/data/vending_product(/obj/item/device/timer, rand(1, 6), hidden=1)



/obj/machinery/vending/hydroponics
	name = "GardenGear"
	desc = "A vendor for Hydroponics related equipment."
	icon_state = "gardengear"
	icon_panel = "standard-panel"
	icon_off = "gardengear-off"
	icon_broken = "gardengear-broken"
	icon_fallen = "gardengear-fallen"
	acceptcard = 0

	light_r =0.5
	light_g = 1
	light_b = 0.2

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/wateringcan, 5)
		product_list += new/datum/data/vending_product(/obj/item/plantanalyzer, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/compostbag, 5)
		product_list += new/datum/data/vending_product(/obj/item/saw, 3)
		product_list += new/datum/data/vending_product(/obj/item/gardentrowel, 5)
		product_list += new/datum/data/vending_product(/obj/item/satchel/hydro, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/beaker, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/weedkiller, 10)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/mutriant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/groboost, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/topcrop, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/powerplant, 5)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/fruitful, 5)
		product_list += new/datum/data/vending_product(/obj/decorative_pot, 5)
		product_list += new/datum/data/vending_product(/obj/chicken_nesting_box,3)
		product_list += new/datum/data/vending_product(/obj/item/chicken_carrier, 2)
		product_list += new/datum/data/vending_product(/obj/machinery/shieldgenerator/energy_shield/botany, 2)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/water_pipe, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/seedplanter/hidden, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/seed/grass, rand(3, 6), hidden=1)
		if (prob(25))
			product_list += new/datum/data/vending_product(/obj/item/seed/alien, 1, hidden=1)

/obj/machinery/vending/hydroponics/mean_solarium_bullshit
	mechanics_type_override = /obj/machinery/vending/hydroponics
	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/device/key/cheget,1, 954, 1)

/obj/machinery/vending/fortune
#ifdef HALLOWEEN
	name = "Necromancer Zoldorf"
	icon_state = "hfortuneteller"
	icon_vend = "hfortuneteller-vend"
	icon_fallen = "hfortuneteller-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_scratch.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	light_r =0.3
	light_g = 0.3
	light_b = 1
#else
	name = "Zoldorf"
	desc = "A horrid old fortune-telling machine."
	icon_state = "fortuneteller"
	icon_vend = "fortuneteller-vend"
	icon_fallen = "fortuneteller-fallen"
	pay = 1
	acceptcard = 1
	slogan_list = list("Ha ha ha ha ha!",
	"I am the great wizard Zoldorf!",
	"Learn your fate!")
	var/sound_riff = 'sound/machines/fortune_riff.ogg'
	var/sound_riff_broken = 'sound/machines/fortune_riff_broken.ogg'
	var/sound_greeting = 'sound/machines/fortune_greeting.ogg'
	var/sound_greeting_broken = 'sound/machines/fortune_greeting_broken.ogg'
	var/sound_laugh = 'sound/machines/fortune_laugh.ogg'
	var/sound_laugh_broken = 'sound/machines/fortune_laugh_broken.ogg'
	var/sound_ding = 'sound/machines/ding.ogg'
	var/list/sounds_working = list('sound/misc/automaton_scratch.ogg','sound/machines/mixer.ogg')
	var/list/sounds_broken = list('sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')

	light_r =0.3
	light_g = 0.3
	light_b = 1
#endif
	New()
		..()
		light.set_color(0.8, 0.4, 1)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/thermal/fortune, 25, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/card_box/tarot, 5, cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/zolscroll, 100, cost=PAY_UNTRAINED, hidden=1) //weird burrito

	prevend_effect()
		if(src.seconds_electrified || src.extended_inventory)
			src.visible_message("<span class='notice'>[src] wakes up!</span>")
			playsound(src.loc, sound_riff_broken, 60, 1)
			sleep(2 SECONDS)
			playsound(src.loc, sound_greeting_broken, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("F*!@$*(9HZZZZ9**###!")
			sleep(2.5 SECONDS)
			src.visible_message("<span class='notice'>[src] spasms violently!</span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1 SECOND)
			src.visible_message("<span class='notice'>[src] makes an obscene gesture!</b></span>")
			playsound(src.loc, pick(sounds_broken), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1.5 SECONDS)
			playsound(src.loc, sound_laugh_broken, 65, 1)
			speak("AHHH#######!")

		else
			src.visible_message("<span class='notice'>[src] wakes up!</span>")
			playsound(src.loc, sound_riff, 60, 1)
			sleep(2 SECONDS)
			playsound(src.loc, sound_greeting, 65, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			speak("The great wizard Zoldorf is here!")
			sleep(2.5 SECONDS)
			src.visible_message("<span class='notice'>[src] rocks back and forth!</span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1 SECOND)
			src.visible_message("<span class='notice'>[src] makes a mystical gesture!</b></span>")
			playsound(src.loc, pick(sounds_working), 40, 1)
			if (src.icon_vend)
				flick(src.icon_vend,src)
			sleep(1.5 SECONDS)
			playsound(src.loc, sound_laugh, 65, 1)
			speak("Ha ha ha ha ha!")

		return

	postvend_effect()
		playsound(src.loc, sound_ding, 50, 1)
		return

	fall(mob/living/carbon/victim)
		playsound(src.loc, sound_laugh, 65, 1)
		speak("Ha ha ha ha ha!")
		..()
		return

	shock(mob/user, prb)
		// Zap the fuck out of the user but don't prevent them from vending, because
		// fucked up Zoldorf is good and I miss seeing it.
		..()
		return 0

	electrocute(mob/user, netnum)
		..()
		if(!ON_COOLDOWN(src, "zoldorf_laugh", 5 SECONDS))
			playsound(src.loc, sound_laugh, 65, 1)
			speak("Ha ha ha ha ha!")
		return

	attackby(obj/item/weapon, mob/user) //pretty much just player zoldorf stuffs :)
		if((istype(weapon, /obj/item/zolscroll)) && istype(user,/mob/living/carbon/human) && (src.z == 1))
			var/obj/item/zolscroll/scroll = weapon
			var/mob/living/carbon/human/h = user
			if(h.unkillable)
				boutput(user,"<span class='alert'><b>Your soul is shielded and cannot be sold!</b></span>")
				return
			if(scroll.icon_state != "signed")
				boutput(h, "<span class='alert'>It doesn't seem to be signed yet.</span>")
				return
			if(scroll.signer == h.real_name)
				var/obj/machinery/playerzoldorf/pz = new /obj/machinery/playerzoldorf
				pz.credits = src.credit
				if(the_zoldorf.len)
					if(the_zoldorf[1].homebooth)
						//var/obj/booth = the_zoldorf[1].homebooth
						boutput(h, "<span class='alert'><b>There can only be one!</b></span>") // Maybe add a way to point where the booth is if people are being jerks
					else
						pz.booth(h,src.loc,scroll)
						qdel(src)
				else
					pz.booth(h,src.loc,scroll)
					qdel(src)
			else
				user.visible_message("<span class='alert'><b>[h.name] tries to sell [scroll.signer]'s soul to [src]! How dare they...</b></span>","<span class='alert'><b>You can only sell your own soul!</b></span>")
		else
			..()

/obj/machinery/vending/alcohol
	name = "Cap'n Bubs' Booze-O-Mat"
	desc = "A vending machine filled with various kinds of alcoholic beverages and things for fancying up drinks."
	pay = 1
	icon_state = "capnbubs"
	icon_panel = "capnbubs-panel"
	slogan_list = list("hm hm",
	"Liquor - get it in ya!",
	"I am the liquor",
	"I don't always drink, but when I do, I sell the rights to my likeness")

	light_r =1
	light_g = 0.3
	light_b = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/fancy_beer, 6)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/vodka, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/tequila, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/wine, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/cider, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/mead, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/gin, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/rum, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/champagne, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/bojackson, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_umbrellas, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/cocktail_doodads, 4)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/straws, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/fruit_wedges, 1)
		product_list += new/datum/data/vending_product(/obj/item/shaker/salt, 1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/cocktailshaker, 1)

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/hobo_wine, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/food/drinks/bottle/thegoodstuff, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/ammo/bullets/abg, 2, cost=PAY_TRADESMAN, hidden=1)

TYPEINFO(/obj/machinery/vending/chem)
	mats = null

/obj/machinery/vending/chem
	name = "ChemDepot"
	desc = "Some odd machine that dispenses little vials and packets of chemicals for exorbitant amounts of money. Is this thing even working right?"
	icon_state = "chem"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	glitchy_slogans = 1
	pay = 1
	acceptcard = 1
	slogan_list = list("Hello!",
	"Please state the item you wish to purchase.",
	"Many goods at reasonable prices.",
	"Please step right up!",
	"Greetings!",
	"Thank you for your interest in VENDOR NAME's goods!")

	light_r =1
	light_g = 0.3
	light_b = 0.95

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))
		var/lock1 = rand(1, 9)
		for (var/i = 0, i < lock1, i++) // this entire thing is just random luck
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/vial/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))
		var/lock2 = rand(1, 9)
		for (var/i = 0, i < lock2, i++) // so we'll add a random amount to each machine
			product_list += new/datum/data/vending_product(/obj/item/reagent_containers/vending/bag/random, 1, cost = rand(1000, 10000))

		product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)
		var/lock3 = rand(1, 9)
		for (var/i = 0, i < lock3, i++)
			product_list += new/datum/data/vending_product(/obj/item/cigpacket/random, 1, cost = rand(1000, 10000), hidden=1)

/obj/machinery/vending/cards
	name = "gaming machine"
	desc = "A machine that sells various kinds of recreational items, notably Spacemen the Grifening trading cards and dice!"
	pay = 1
	vend_delay = 10
	icon_state = "card"
	icon_panel = "card-panel"

	light_r =1
	light_g = 0.4
	light_b = 0.7

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/paper/yachtdice, 20, cost=PAY_UNTRAINED/8)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/grifening, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/stg_box, 5, cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/stg_booster, 20, cost=PAY_UNTRAINED/10)
		product_list += new/datum/data/vending_product(/obj/item/card_box/plain, 10, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/card_box/tarot, 5, cost=PAY_UNTRAINED/3)
		product_list += new/datum/data/vending_product(/obj/item/card_box/hanafuda, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/card_box, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/card_box/red, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/DNDrulebook, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/monster_manual_revised, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicebox, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/dicepouch, 5, cost=PAY_TRADESMAN/3)
		product_list += new/datum/data/vending_product(/obj/item/diceholder/dicecup, 5, cost=PAY_TRADESMAN/10)
		product_list += new/datum/data/vending_product(/obj/item/goboard, 1, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/gobowl/b, 1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/gobowl/w, 1, cost=PAY_TRADESMAN/4)
		product_list += new/datum/data/vending_product(/obj/item/boardgame/chess, 1, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/gameclock, 5, cost=PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/card_box/clow, 5, cost=PAY_TRADESMAN/2) // (this is an anime joke)
		product_list += new/datum/data/vending_product(/obj/item/clow_key, 5, cost=PAY_TRADESMAN/2)      //      (please laugh)
		product_list += new/datum/data/vending_product(/obj/item/card_box/solo, 5, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/paper/book/from_file/solo_rules, 5, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/currency/fakecash/fivehundred, 10, cost=PAY_UNTRAINED/4)
		product_list += new/datum/data/vending_product(/obj/item/currency/fakecash/thousand, 10, cost=PAY_UNTRAINED/2)
		product_list += new/datum/data/vending_product(/obj/item/currency/fakecash/hundredthousand, 1, cost=PAY_DOCTORATE)
		product_list += new/datum/data/vending_product(/obj/item/dice/weighted, rand(1,3), cost=PAY_TRADESMAN/2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/dice/d1, rand(0,1), cost=PAY_TRADESMAN/3, hidden=1)

/obj/machinery/vending/clothing
	name = "FancyPantsCo Sew-O-Matic"
	desc = "A clothing vendor."
	icon_state = "clothes"
	icon_vend = "clothes-vend"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	pay = 1
	acceptcard = 1
	vend_delay = 20
	slogan_list = list("Look snappy in seconds!",
	"Style over substance.")

	prevend_effect()
		playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
		return

	postvend_effect()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		return

	create_products()
		..()
		//for (var/j in typesof(/obj/item/clothing/under/color)) // alla dem
			//product_list += new/datum/data/vending_product([j], 5, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/red, 5, cost=PAY_TRADESMAN/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/red, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dress/hawaiian, 5, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/black, 5, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels/red, 5, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/poncho, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/lshirt, 2, cost=PAY_UNTRAINED/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/tan, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/maroon, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/magenta, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/mint, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/cerulean, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/navy, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/indigo, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/jacket/design/grey, 2, cost=PAY_UNTRAINED)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/dressb, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/sunhat, 2, cost=PAY_DOCTORATE/5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/white, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/gray, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/black, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/red, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/orange, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/yellow, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/green, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/blue, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headband/nyan/purple, 3, cost = PAY_TRADESMAN)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/pokervisor, 3, cost = PAY_TRADESMAN/5)


		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/yoga/communist, 1, cost=PAY_TRADESMAN/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/rando, 1, cost=PAY_TRADESMAN/3, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/wedding_dress, 1, cost=PAY_IMPORTANT*4, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/veil, 1, PAY_IMPORTANT, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/heels, 1, PAY_DOCTORATE/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/tuxedo_jacket, 1, cost=PAY_IMPORTANT, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender/tuxedo, 1, cost=PAY_IMPORTANT/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/dress_shoes, 1, cost=PAY_IMPORTANT/5, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/ring/gold, 2, cost=PAY_IMPORTANT, hidden=1)

TYPEINFO(/obj/machinery/vending/janitor)
	mats = 10

/obj/machinery/vending/janitor
	name = "JaniTech Vendor"
	desc = "One stop shop for all your custodial needs."
	icon_state = "janitor"
	icon_panel = "standard-panel"
	icon_off = "janitor-off"
	icon_broken = "janitor-broken"
	icon_fallen = "janitor-fallen"
	pay = 1
	acceptcard = 1

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/mop, 5)
		product_list += new/datum/data/vending_product(/obj/item/sponge, 4)
		product_list += new/datum/data/vending_product(/obj/item/spraybottle/cleaner, 3)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bucket, 4)
		product_list += new/datum/data/vending_product(/obj/item/reagent_containers/glass/bottle/cleaner, 4)
		product_list += new/datum/data/vending_product(/obj/item/chem_grenade/cleaner, 6)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/trash_bags, 8)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/biohazard_bags, 8)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/body_bag, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/box/mousetraps, 4)
		product_list += new/datum/data/vending_product(/obj/item/caution, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/long, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 4)

		product_list += new/datum/data/vending_product(/obj/item/sponge/cheese, 2, hidden=1)

/obj/machinery/vending/air_vendor
	name = "Oxygen Vending Machine"
	desc = "Here, you can buy the oxygen that you need to live."
	icon_state = "O2vend"
	icon_panel = "O2vend-panel"
	icon_off = "O2vend-off"
	icon_broken = "O2vend-broken"
	icon_fallen = "O2vend-fallen"
	deconstruct_flags = DECON_CROWBAR | DECON_WRENCH | DECON_MULTITOOL
	can_hack = FALSE
	pay = TRUE
	acceptcard = TRUE
	vend_delay = 0
	slogan_list = list("Come get a breath of fresh air",
	"You NEED this to live!.",
	"Breathing is GOOD!",
	"Contains only 2% farts!")
	var/global/image/holding_overlay_image = image('icons/obj/vending.dmi', "O2vend-slot")

	// Currently installed tank
	var/obj/item/tank/holding = null

	// Gas mix to be copied into the target tank
	var/datum/gas_mixture/gas_prototype = null

	var/target_pressure = ONE_ATMOSPHERE
	var/air_cost = 0.1 // units: credits / ( kPa * L )

	light_r =0.4
	light_g = 0.4
	light_b = 1

	New()
		..()
		gas_prototype = new /datum/gas_mixture

	proc/fill_cost()
		if(!holding) return 0
		return clamp(round((src.target_pressure - MIXTURE_PRESSURE(src.holding.air_contents)) * src.holding.air_contents.volume * src.air_cost), 0, INFINITY)

	proc/fill()
		if(!holding) return
		gas_prototype.volume = holding.air_contents.volume
		gas_prototype.temperature = T20C

		gas_prototype.oxygen = (target_pressure)*gas_prototype.volume/(R_IDEAL_GAS_EQUATION*gas_prototype.temperature)

		holding.air_contents.copy_from(gas_prototype)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tank))
			if (!src.holding)
				boutput(user, "You insert the [W] into the the [src].</span>")
				UpdateOverlays(holding_overlay_image, "o2_vend_tank_overlay")
				user.drop_item()
				W.set_loc(src)
				src.holding = W
				src.updateUsrDialog()
			else
				boutput(user, "You try to insert the [W] into the the [src], but there's already a tank there!</span>")
				return
		else
			..()

	attack_hand(mob/user)
		if (status & (BROKEN|NOPOWER))
			return
		if (user.stat || user.restrained())
			return

		src.add_dialog(user)
		var/list/html = list("")
		html += "<TT><b>Welcome!</b><br>"
		html += "<b>Current balance: <a href='byond://?src=\ref[src];return_credits=1'>[src.credit] credits</a></b><br>"
		if (src.scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			html += "<b>Current ID:</b> <a href='?src=\ref[src];logout=1'>[src.scan]</a><br />"
			html += "<b>Credits on Account: [account["current_money"]] Credits</b> <br>"
		else
			html += "<b>Current ID:</b> None<br>"
		if(src.holding)
			html += "<font color = 'blue'>Current tank:</font> <a href='?src=\ref[src];eject=1'>[holding]</a><br />"
			html += "<font color = 'red'>Pressure:</font> [MIXTURE_PRESSURE(holding.air_contents)] kPa<br />"
		else
			html += "<font color = 'blue'>Current tank:</font> none<br />"

		html += "<font color = 'green'>Desired pressure:</font> <a href='?src=\ref[src];changepressure=1'>[src.target_pressure] kPa</a><br/>"
		html += (holding) ? "<a href='?src=\ref[src];fill=1'>Fill ([src.fill_cost()] credits)</a>" : "<font color = 'red'>Fill (unavailable)</red>"

		user.Browse(html.Join(), "window=o2_vending")
		onclose(user, "vending")

	Topic(href, href_list)
		..()

		if(href_list["eject"])
			if(holding)
				usr.put_in_hand_or_eject(holding)
				holding = null
				UpdateOverlays(null, "o2_vend_tank_overlay")
				src.updateUsrDialog()

		if(href_list["changepressure"])
			var/change = input(usr,"Target Pressure (10.1325-1013.25):","Enter target pressure",target_pressure) as num
			if(isnum_safe(change))
				target_pressure = clamp(change, 10.1325, 1013.25)
				src.updateUsrDialog()

		if(href_list["fill"])
			if (holding)
				var/cost = fill_cost()
				if(credit >= cost)
					src.credit -= cost
					src.fill()
					boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
					src.updateUsrDialog()
					return
				else if(scan)
					var/datum/db_record/account = FindBankAccountByName(src.scan.registered)
					if (account && account["current_money"] >= cost)
						account["current_money"] -= cost
						src.fill()
						boutput(usr, "<span class='notice'>You fill up the [src.holding].</span>")
						src.updateUsrDialog()
						return
				boutput(usr, "<span class='alert'>Insufficient funds.</span>")
			else
				boutput(usr, "<span class='alert'>There is no tank to fill up!</span>")

ABSTRACT_TYPE(/obj/machinery/vending/jobclothing)

/obj/machinery/vending/jobclothing/security
	name = "Security Apparel"
	desc = "A vending machine that vends Security clothing."
	icon_state = "secclothing"
	icon_panel = "snack-panel"
	icon_off = "secclothing-off"
	icon_broken = "secclothing-broken"
	icon_fallen = "secclothing-fallen"
	pay = 1
	acceptcard = 1
	req_access = list(access_security)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/assistant, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/lawyer/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/jersey/red, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/dirty_vest, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/tourist/max_payne, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/police, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/security, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/swat, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/serpico, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/red, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/flatcap, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/policecap, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/bobby, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/siren, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/security, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/security, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/forensic, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/security, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/security, 1)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/security/april_fools, 1, hidden=1)

/obj/machinery/vending/jobclothing/medical
	name = "Medical Apparel"
	desc = "A vending machine that vends Medical clothing."
	icon_state = "medclothing"
	icon_panel = "snack-panel"
	icon_off = "medclothing-off"
	icon_broken = "medclothing-broken"
	icon_fallen = "medclothing-fallen"
	pay = 1
	acceptcard = 1
	req_access = list(access_medical)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/medical, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/robotics, 3)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/genetics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/nursedress, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical_shield, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/red, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/blue, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/headmirror, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/traditionalnursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/nursehat, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/medical, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/medical, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/medical/robotics, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/genetics, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/medic, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/robotics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/genetics, 1)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/genetics, 1)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/medical/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/medical/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/roboticist/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/robotics/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/geneticist/april_fools, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/genetics/april_fools, 1, hidden=1)

/obj/machinery/vending/jobclothing/engineering
	name = "Engineering Apparel"
	desc = "A vending machine that vends Engineering clothing."
	icon_state = "engclothing"
	icon_panel = "snack-panel"
	icon_off = "engclothing-off"
	icon_broken = "engclothing-broken"
	icon_fallen = "engclothing-fallen"
	pay = 1
	acceptcard = 1
	req_access = list(access_engineering)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/atmospheric_technician, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/orangeoveralls/yellow, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/engineering, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/hi_vis, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/fire, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/yellow/unsulated, 2) //heh
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/orange, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/yellow, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/orange, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/hardhat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/welding, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/helmet/firefighter, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/yellow, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/engineer, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/engine, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/technical_assistant, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/atmos, 2, cost=PAY_TRADESMAN/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/engineering, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/constructioncone, 16)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/engineer/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/mechanic/april_fools, 2, hidden=1)

/obj/machinery/vending/jobclothing/catering
	name = "Catering Apparel"
	desc = "A vending machine that vends Catering clothing."
	icon_state = "catclothing" //At first it was static on the bartender outfit, but it made it feel like it was only a bartender vendor, so I made it animated to switch between chef and bartender clothing.
	icon_panel = "snack-panel"
	icon_off = "catclothing-off"
	icon_broken = "catclothing-broken"
	icon_fallen = "catclothing-fallen"
	pay = 1
	acceptcard = 1
	req_access = list(access_bar, access_kitchen)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/butler, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/gimmick/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/bartender, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/souschef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/chef, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/apron, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/fingerless, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/black, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/chef, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/that, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/maid, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/souschefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhat, 1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/chefhatpuffy, 1)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/civilian, 2, cost=PAY_TRADESMAN/1.5)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2, 2, cost=PAY_TRADESMAN/1.5) //Currently, Chef and Barkeep have unique PDA's, but they are functionally the same. So putting a generic PDA here until that changes.
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack, 2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel, 2)
		//There isn't april fools versions of chef and bartender suits to put... Yet! - But I think the Chef's Sushi outfit (Being a level 0 reward) can do just great as a hidden item for now if the hidden items don't strictly have to be just alternative jumpsuits.
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/misc/itamae, 1, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/itamaehat, 1, hidden=1)
		product_list += new/datum/data/vending_product(pick(/obj/item/clothing/head/headband/nyan/white, /obj/item/clothing/head/headband/nyan/gray, /obj/item/clothing/head/headband/nyan/black), 1, hidden = 1) //Silly headbands (?)

/obj/machinery/vending/jobclothing/research
	name = "Research Apparel"
	desc = "A vending machine that vends Research clothing."
	icon_state = "sciclothing"
	icon_panel = "snack-panel"
	icon_off = "sciclothing-off"
	icon_broken = "sciclothing-broken"
	icon_fallen = "sciclothing-fallen"
	pay = 1
	acceptcard = 1
	req_access = list(access_research)

	create_products()
		..()
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/color/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist, 6)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/wintercoat/research, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/bio_suit, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/surgical, 10)
		product_list += new/datum/data/vending_product(/obj/item/clothing/mask/gas, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/gloves/latex, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/brown, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/shoes/white, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/bio_hood, 4)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/white, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/purple, 5)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/basecap/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/clothing/head/goggles/purple, 2)
		product_list += new/datum/data/vending_product(/obj/item/device/radio/headset/research, 2, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/device/pda2/toxins, 5, cost=PAY_DOCTORATE/2)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/research, 3)
		product_list += new/datum/data/vending_product(/obj/item/storage/backpack/satchel/research, 3)

		product_list += new/datum/data/vending_product(/obj/item/clothing/under/rank/scientist/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/science/april_fools, 2, hidden=1)
		product_list += new/datum/data/vending_product(/obj/item/clothing/suit/labcoat/dan, 1, hidden=1)

/obj/machinery/vending/player/chemicals
	name = "dispensary interlink"
	desc = "An ID-selective dispenser for advanced medical supplies from chemistry."
	icon_state = "medchem"
	acceptcard = FALSE
	pay = FALSE
	does_crt = FALSE
	slogan_chance = 0
	req_access = list(access_chemistry, access_medical_lockers)
	///For linking to the chemlink console thingy
	var/id = "chemlink"
	var/obj/machinery/disposal/chemlink/linked = null
	///Stuff wot can be put in
	var/list/allowed_types = list(/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/patch,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/ampoule,
		/obj/item/chem_pill_bottle,
		/obj/item/storage/box/patchbox,
	)

	New()
		..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	vend_product(datum/data/vending_product/product, mob/user)
		. = ..()
		SPAWN(0)
			src.linked.update_static_data(user)

	acceptsProduct(atom/A)
		for (var/type in src.allowed_types)
			if (istype(A, type))
				return TRUE
		return FALSE

	attackby(obj/item/W, mob/user)
		if (src.acceptsProduct(W))
			src.addProduct(W, user)
			src.update_static_data(user)
			return
		if (istype(W, /obj/item/screwdriver)) //no
			return
		. = ..()

	addProduct(obj/item/target, mob/user, quiet)
		. = ..()
		src.linked.static_data_invalid = TRUE
		if (!ON_COOLDOWN(src, "announce", 2 SECONDS))
			src.speak(pick("New product received: [target.name]!",
				"Supplies received: [target.name]!",
				"Now available for pickup: [target.name]!")
			)

	generate_slogans()
		if (!length(src.player_list) <= 0)
			src.slogan_list = list("[src.pick_product_name()] could save a life!",
				"Fresh supplies of [src.pick_product_name()]!",
				"Ask your doctor if [src.pick_product_name()] is right for you!",
				"Prescribe [src.pick_product_name()] today!"
			)
