//////////
//PARENT//
//////////

/obj/item_dispenser
	name = "item dispenser"
	desc = "A storage container that easily dispenses items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_handcuffs"
	pixel_y = 28
	anchored = ANCHORED
	var/filled_icon_state = "" 		//i tried to do this in a smart way but it was a PITA so here have this stinky code instead
	var/empty_icon_state = "" 		//autoset by the s y s t e m, dont set this yourself
	var/amount = 3 					//how many items does it have?
	var/deposit_type = null 		//this is a type that this item will accept to "reload" itself
	var/withdraw_type = null 		//this is a type that this item will dispense
	var/cant_deposit = 0 			//set this to 1 if you want people to not be able to put items into it
	var/cant_withdraw = 0 			//set this to 1 if you want people to not be able to take items out of it (why would you ever use this? why????)
	var/dispense_rate = 0			//How long must you wait (in deciseconds) between each dispensation
	var/last_dispense_time = 0		//Time when an item was last dispensed.
	var/display_amount = 1 			//displays amount of item in dispenser

	New()
		..()
		src.empty_icon_state = "[src.filled_icon_state]0"
		src.UpdateIcon()

	get_desc()
		if(display_amount)
			. += "There's [src.amount] left."

	attackby(obj/item/W, mob/user)
		if (src.cant_deposit)
			..()
			return
		if (istype(W, src.deposit_type))
			user.u_equip(W)
			src.amount++
			src.UpdateIcon()
			boutput(user, SPAN_NOTICE("You put \the [W] into \the [src]. [display_amount ? "There's [src.amount] left.": null ]"))
			qdel(W)

	attack_hand(mob/user)
		if (is_dead_or_ghost_role(user))
			return 1
		add_fingerprint(user)
		user.lastattacked = get_weakref(src) //prevents spam
		if (src.cant_withdraw)
			..()
			return 1

		if (src.amount >= 1)
			if (last_dispense_time + dispense_rate > TIME)
				boutput(user, SPAN_ALERT("The timer says that you must wait [round(( last_dispense_time + dispense_rate-TIME)/10)] second(s) before the next item is ready!"))
				playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
				return
			var/obj/vended = src.vend_item(user)
			boutput(user, SPAN_NOTICE("You take \the [vended] from \the [src]. [display_amount ? "There's [src.amount] left.": null ]"))
		else
			boutput(user, SPAN_ALERT("There's nothing in \the [src] to take!"))
			return 1

	proc/vend_item(mob/user)
		src.amount--
		last_dispense_time = TIME 	//gotta go before the UpdateIcon
		src.UpdateIcon()
		var/obj/item/I = new src.withdraw_type(src.loc)
		if(user)
			user.put_in_hand_or_drop(I)

		//This is pretty lame, but it's simpler than putting these in a process loop when they are rarely used. - kyle
		if (dispense_rate > 0 && (last_dispense_time + dispense_rate > TIME))
			SPAWN(dispense_rate)
				UpdateIcon()
		return I

	update_icon()
		if (src.amount <= 0)
			src.icon_state = src.empty_icon_state
		else
			//if a dispenser has a dispense_rate then we display the sprite based on time left, because of the spawn: UpdateIcon in attack_hand
			if (dispense_rate > 0)
				if (last_dispense_time + dispense_rate <= TIME)
					src.icon_state = src.filled_icon_state
				else
					src.icon_state = src.empty_icon_state

			else
				src.icon_state = src.filled_icon_state

///////////////////
//ITEM DISPENSERS//
///////////////////

/obj/item_dispenser/handcuffs
	name = "handcuffs dispenser"
	desc = "A storage container that easily dispenses handcuffs."
	icon_state = "dispenser_handcuffs"
	filled_icon_state = "dispenser_handcuffs"
	deposit_type = /obj/item/handcuffs
	withdraw_type = /obj/item/handcuffs

/obj/item_dispenser/latex_gloves
	name = "latex gloves dispenser"
	desc = "A storage container that easily dispenses latex gloves."
	icon_state = "dispenser_gloves"
	filled_icon_state = "dispenser_gloves"
	deposit_type = /obj/item/clothing/gloves/latex
	withdraw_type = /obj/item/clothing/gloves/latex

/obj/item_dispenser/medical_mask
	name = "medical mask dispenser"
	desc = "A storage container that easily dispenses medical masks."
	icon_state = "dispenser_mask"
	filled_icon_state = "dispenser_mask"
	deposit_type = /obj/item/clothing/mask/medical
	withdraw_type = /obj/item/clothing/mask/medical

/obj/item_dispenser/prescription_glasses
	name = "prescription glasses dispenser"
	desc = "A storage container that easily dispenses prescription glasses."
	icon_state = "dispenser_glasses"
	filled_icon_state = "dispenser_glasses"
	deposit_type = /obj/item/clothing/glasses/regular
	withdraw_type = /obj/item/clothing/glasses/regular

/obj/item_dispenser/idcarddispenser
	name = "\improper ID card dispenser"
	desc = "A storage container that easily dispenses fresh ID cards. It can be refilled with paper."
	icon_state = "dispenser_id"
	filled_icon_state = "dispenser_id"
	deposit_type = /obj/item/paper
	withdraw_type = /obj/item/card/id
	amount = 7

	attack_hand(mob/user)
		if(!..())
			playsound(src.loc, 'sound/machines/printer_dotmatrix.ogg', 25, 1)

/obj/item_dispenser/idcarddispenser/syndicate
	name = "\improper Syndicate ID card dispenser"
	desc = "A dispenser that dispenses syndicate brand IDs to recognised operatives. It can be refilled with paper."
	icon_state = "dispenser_id_syndie"
	filled_icon_state = "dispenser_id_syndie"
	// The two variables below could probably be replaced with something more available due to how similar they are to nukeop names
	/// List of operative codenames indexed by the mind that owns them
	var/static/operative_codenames = list()
	/// List of unused codenames
	var/static/available_codenames = list()

	attack_hand(mob/user)
		if(!istrainedsyndie(user))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			boutput(user, SPAN_ALERT("[src] doesn't recognise you!"))
			return
		if(!ishuman(user))
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			boutput(user, SPAN_ALERT("Only humans can use [src]!"))
			return
		. = ..()

	vend_item(mob/user)
		. = ..()
		var/obj/item/card/id/vended_card = .
		vended_card.icon_state = "id_syndie"
		vended_card.assignment = "Syndicate Operative"
		vended_card.registered = src.get_operative_codename(user)
		vended_card.pronouns = user.get_pronouns()
		vended_card.update_name()
		vended_card.access = list(access_maint_tunnels, access_syndicate_shuttle)

	proc/get_operative_codename(mob/user)
		var/target_mind = user?.mind
		if(!target_mind)
			return "Agent Braindead"
		if(!src.available_codenames || !length(src.available_codenames))
			var/list/callsign_pool_keys = list("nato", "melee_weapons", "colors", "birds", "mammals", "moons", "arthurian")
			src.available_codenames = strings("agent_callsigns.txt", pick(callsign_pool_keys))
		if(isnukeop(user))
			return user.real_name //Yeah the infil can DNA scramble but a syndicate brand ID is no help to them they already get an agent card
		if(src.operative_codenames[target_mind])
			return src.operative_codenames[target_mind]
		var/codename = pick(src.available_codenames)
		src.available_codenames -= codename
		var/full_name = "Agent [codename]"
		src.operative_codenames[user] = full_name
		return full_name

/obj/item_dispenser/icedispenser
	name = "ice dispenser"
	desc = "It's a small freezer unit that produces ice. Looks like it's hooked into the station water mains."
	icon_state = "dispenser_ice"
	filled_icon_state = "dispenser_ice"
	withdraw_type = /obj/item/raw_material/ice
	deposit_type = null
	amount = 10000
	display_amount = 0
	pixel_y = 0
	flags = NOSPLASH

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
			if (W.reagents.total_volume <= (W.reagents.maximum_volume - 10))
				W.reagents.add_reagent("ice", 10, null, (T0C - 50))
				user.visible_message("[user] adds some ice to the [W].",\
			SPAN_NOTICE("You add some ice to the [W]."))
			else
				boutput(user, SPAN_ALERT("[W] is too full!"))
