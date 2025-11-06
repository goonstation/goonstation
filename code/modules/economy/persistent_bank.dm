//This is the main persistent bank window

//some related bits in :
//	client.dm	   :  Add-to-bank, Sub-from-bank procs
//	mind.dm		   :  keep track of the item that was purchased
//	gameticker.dm  :  Award players with cash on round end
//	new_player.dm  :  open up the bank dialog
//	jobprocs.dm    :  call Equip_Bank_Purchase()
//	persistent_bank_purchases.dm  :	(contains all purchaseable data)

/datum/spend_spacebux
	var/datum/bank_purchaseable/bought_this_round = null

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "SpendSpacebux", "Spend Spacebux")
			ui.open()

	ui_state(mob/user)
		return tgui_always_state

	ui_data(mob/user)
		var/found_held = null
		var/list/purchasables = list()

		for(var/datum/bank_purchaseable/p in persistent_bank_purchaseables)
			if(!p.hasJobXP(user.client.key)) continue
			purchasables += list(
				list(
					"pname" = p.name,
					"cost" = p.cost,
					"img" = icon2base64(icon(initial(p.icon), initial(p.icon_state), dir=p.icon_dir, frame=p.icon_frame, moving=0)),
				)
			)
			//If you have a purchased item: set held
			// or you have a persistent item: set it as purchased, and set held
			var/datum/bank_purchaseable/already_purchased = user.client?.mob?.mind?.purchased_bank_item
			if (istype(already_purchased) && p.name == already_purchased.name)
				found_held = p.name
			else if (p.name == user.client.persistent_bank_item)
				found_held = p.name
				var/mob/new_player/playermob = user.client.mob
				if (playermob.mind)
					playermob.mind.purchased_bank_item = p

		if(user.client.persistent_bank_item && user.client.persistent_bank_item != "none" && !found_held)
			user.client.set_last_purchase(null)
			boutput(user, SPAN_NOTICE("<b>The thing you previously purchased has been removed from your inventory due to it no longer existing.</b>"))

		var/truebalance = user.client.persistent_bank
		if(istype(src.bought_this_round))
			truebalance += src.bought_this_round.cost
		. = list(
			"purchasables" = purchasables,
			"held" = found_held,
			"balance" = user.client.persistent_bank,
			"truebalance" = truebalance
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		if(istype(ui.user,/mob/new_player))
			var/mob/new_player/playermob = ui.user
			if(playermob.spawning)
				boutput(ui.user, SPAN_NOTICE("<b>The round has started, you'll have to wait until the next round!</b>") )
				ui.close()
				return
		else
			boutput(ui.user, SPAN_NOTICE("<b>The round has started, you'll have to wait until the next round!</b>") )
			ui.close()
			return

		var/id = params["pname"]
		var/datum/bank_purchaseable/purchased = null
		for(var/datum/bank_purchaseable/p in persistent_bank_purchaseables)
			if(id == p.name)
				purchased = p

		if(istype(purchased))
			if (try_purchase(ui.user.client, purchased))
				ui.close()
		else
			boutput( ui.user, SPAN_NOTICE("<b>Oh no! Something is broken. Please tell a coder. (problem retrieving purchaseable id : [id])</b>") )

	proc/try_purchase(var/client/c, var/datum/bank_purchaseable/p)
		if(istype(c.mob,/mob/new_player))
			var/mob/new_player/playermob = c.mob
			if(playermob.spawning) //if you've spawned into the game, you can't buy things
				return FALSE
		else
			return FALSE //if the client's mob isn't a new_player, we've probably started already. If it's just null, we've got bigger problems

		if(istype(src.bought_this_round))
			if (istype(c.mob,/mob/new_player))
				var/mob/new_player/playermob = c.mob
				if (playermob.mind)
					playermob.mind.purchased_bank_item = null
					c.persistent_bank_item = 0

		if (c.bank_can_afford(p.cost))
			usr.playsound_local(usr, 'sound/misc/cashregister.ogg', 50, 0)
			boutput( usr, SPAN_NOTICE("<b>You purchased [p.name] for the round!</b>") )
			if (istype(c.mob,/mob/new_player))
				var/mob/new_player/playermob = c.mob
				if (playermob.mind)
					src.bought_this_round = p
					playermob.mind.purchased_bank_item = p
					c.persistent_bank_item = 0
				else
					boutput( usr, SPAN_NOTICE("<b>Can't find mind of new player mob [playermob]... please report this to a coder</b>") )
					return FALSE
			else
				boutput( usr, SPAN_NOTICE("<b>Can't find new player mob from client [c]... please report this to a coder</b>") )
				return FALSE

			return TRUE
		else
			usr.playsound_local(usr, 'sound/items/penclick.ogg', 80, 0)
			boutput( usr, SPAN_NOTICE("<b>You can't afford [p.name]!</b>") )
			return FALSE

//Subtract cash from bank on successful equip
/mob/proc/Equip_Bank_Purchase(var/datum/bank_purchaseable/purchase)
	if (!purchase)
		return

	if(purchase in persistent_bank_purchaseables)
		if (purchase.Create(src))
			boutput( src, SPAN_NOTICE("<b>[purchase.name] equipped successfully.</b>") )
		else
			boutput( src, SPAN_NOTICE("<b>[purchase.name] is not available for the job you rolled. It will be refunded.</b>") )
			src.client.add_to_bank(purchase.cost)
			src.client.set_last_purchase(null)
			return
	else
		boutput( src, SPAN_NOTICE("<b>The thing you previously purchased has been removed from your inventory due to it no longer existing.</b>"))
		src.client.set_last_purchase(null)
		return

	if (src.client.persistent_bank_item != purchase.name) //Only sub_from_bank if the purchase does not match the Held Item
		src.client.sub_from_bank(purchase)
		src.client.set_last_purchase(purchase)
	return
