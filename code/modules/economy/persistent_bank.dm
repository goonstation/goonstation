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
			boutput(user, "<span class='notice'><b>The thing you previously purchased has been removed from your inventory due to it no longer existing.</b></span>")

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
				boutput(ui.user, "<span class='notice'><b>The round has started, you'll have to wait until the next round!</b></span>" )
				ui.close()
				return
		else
			boutput(ui.user, "<span class='notice'><b>The round has started, you'll have to wait until the next round!</b></span>" )
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
			boutput( ui.user, "<span class='notice'><b>Oh no! Something is broken. Please tell a coder. (problem retrieving purchaseable id : [id])</b></span>" )

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
			boutput( usr, "<span class='notice'><b>You purchased [p.name] for the round!</b></span>" )
			if (istype(c.mob,/mob/new_player))
				var/mob/new_player/playermob = c.mob
				if (playermob.mind)
					src.bought_this_round = p
					playermob.mind.purchased_bank_item = p
					c.persistent_bank_item = 0
				else
					boutput( usr, "<span class='notice'><b>Can't find mind of new player mob [playermob]... please report this to a coder</b></span>" )
					return FALSE
			else
				boutput( usr, "<span class='notice'><b>Can't find new player mob from client [c]... please report this to a coder</b></span>" )
				return FALSE

			return TRUE
		else
			usr.playsound_local(usr, 'sound/items/penclick.ogg', 80, 0)
			boutput( usr, "<span class='notice'><b>You can't afford [p.name]!</b></span>" )
			return FALSE


/chui/window/earn_spacebux
	name = "Spacebux"
	windowSize = "250x380"

	var/wage_base = 0
	var/wage_after_score = 0
	var/escaped = 1
	var/final_payout = 0
	var/new_balance = 0
	var/badguy = 0
	var/part_time = 0
	var/held_item = 0
	var/completed_objs = 0
	var/all_objs = 0
	var/pilot = 0 //buckled into pilots chair
	var/pilot_bonus = 0

	GetBody()
		var/ret
		if (!badguy)
			ret = "<p style=\"text-align:left;\">Base Wage [part_time ? "(part-time)" : ""].....<span style=\"float:right;\"><b>[wage_base]   </b></span> </p><br>"
			ret += "<p style=\"text-align:left;\">Station Grade Tax .....<span style=\"float:right;\"><b>- [wage_base-wage_after_score]  </b></span> </p><br>"
			if (!escaped)
				ret += "<p style=\"text-align:left;\">Did not escape .....<span style=\"float:right;\"><b>- [wage_after_score - final_payout] </b></span> </p>"
			if (completed_objs > 0)
				ret += "<p style=\"text-align:left;\">Crew objective bonus .....<span style=\"float:right;\"><b>+ [completed_objs] </b></span> </p>"
				if (all_objs > 0)
					ret += "<p style=\"text-align:left;\">All crew objective bonus .....<span style=\"float:right;\"><b>+ [all_objs] </b></span> </p>"
		else
			ret = "<p style=\"text-align:left;\">Base Wage .....<span style=\"float:right;\"><b>[final_payout]   </b></span> </p><br style=\"line-height:0px;\" />"
			ret += "<p style=\"text-align:left;\">Antagonist - No tax!</p>"
		if (pilot)
			ret += "<p style=\"text-align:left;\">Pilot's bonus ....<span style=\"float:right;\"><b>+ [pilot_bonus] </b></span> </p>"


		ret += "<hr>"
		ret += "<big><b><p style=\"text-align:left;\">PAYOUT ..... <span style=\"float:right;\">[final_payout]</span> </p></b></big><br>"
		ret += "<p style=\"text-align:left;\"><span style=\"float:right;\">ACCOUNT BALANCE :	<b>[new_balance]</b></span></p><br>"
		ret += "<p style=\"text-align:left;\"><span style=\"float:right;\">HELD ITEM :	<b>[held_item ? held_item : "none"]</b></span></p><br>"
		ret += "<p style=\"font-size:75%;\">Spend Spacebux from your bank when you Declare Ready for the next round!</p>"
		return ret


//Subtract cash from bank on successful equip
/mob/proc/Equip_Bank_Purchase(var/datum/bank_purchaseable/purchase)
	if (!purchase)
		return

	if(purchase in persistent_bank_purchaseables)
		if (purchase.Create(src))
			boutput( src, "<span class='notice'><b>[purchase.name] equipped successfully.</b></span>" )
		else
			boutput( src, "<span class='notice'><b>[purchase.name] is not available for the job you rolled. It will not be billed.</b></span>" )
			src.client.add_to_bank(purchase.cost)
			src.client.set_last_purchase(null)
			return
	else
		boutput( src, "<span class='notice'><b>The thing you previously purchased has been removed from your inventory due to it no longer existing.</b></span>")
		src.client.set_last_purchase(null)
		return

	if (src.client.persistent_bank_item != purchase.name) //Only sub_from_bank if the purchase does not match the Held Item
		src.client.sub_from_bank(purchase)
		src.client.set_last_purchase(purchase)
	return
