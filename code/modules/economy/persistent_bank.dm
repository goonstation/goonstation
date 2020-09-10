//This is the main persistent bank window

//some related bits in :
//	client.dm	   :  Add-to-bank, Sub-from-bank procs
//	mind.dm		   :  keep track of the item that was purchased
//	gameticker.dm  :  Award players with cash on round end
//	new_player.dm  :  open up the bank dialog
//	jobprocs.dm    :  call Equip_Bank_Purchase()
//	persistent_bank_purchases.dm  :	(contains all purchaseable data)

/chui/window/spend_spacebux
	name = "Spacebux"
	windowSize = "300x600"

	GetBody()
		if (!usr.client)
			return "Something went wrong loading your bank! If the issue persists, try relogging or asking an admin for help."

		var/ret = "<p style=\"font-size:125%;\">BALANCE :  <b>[usr.client.persistent_bank]</b></p><br/>"
		ret += "<p style=\"font-size:110%;\">HELD ITEM :  <b>[usr.client.persistent_bank_item ? usr.client.persistent_bank_item : "none"]</b></p><br/>"
		ret += "Purchase an item for the upcoming round. Earn more cash by completing rounds.<br/>"
		ret += "A purchased item will persist until you die or fail to escape the station. If you have a Held Item, buying a new one will replace it.<br/><br/>"
		for(var/i=1, i <= persistent_bank_purchaseables.len, i++)
			var/datum/bank_purchaseable/p = persistent_bank_purchaseables[i]

			if(!p.hasJobXP(usr.client.key)) continue

			ret += "[theme.generateButton(i, "[p.name] $[p.cost]")] <br/>"

			//Convert the HELD ITEM string into a purchased item on Mind if applicable here
			if (p.name == usr.client.persistent_bank_item)
				var/mob/new_player/playermob = usr.client.mob
				if (playermob.mind)
					playermob.mind.purchased_bank_item = p

		ret += "<br>This menu is a WIP! Expect additional items and other changes to come in the future!<br/>"
		return ret

	OnClick( var/client/who, var/id )
		if (istext(id))
			id = text2num(id)
		var/datum/bank_purchaseable/p = persistent_bank_purchaseables[id]
		if( p )
			if (try_purchase(who, p))
				Unsubscribe( who )
		else
			boutput( who, "<span class='notice'><b>Oh no! Something is broken. Please tell a coder. (problem retrieving purchaseable id : [id])</b></span>" )

	proc/try_purchase(var/client/c, var/datum/bank_purchaseable/p)
		if (c.bank_can_afford(p.cost))
			c << sound( 'sound/misc/cashregister.ogg' )
			boutput( usr, "<span class='notice'><b>You purchased [p.name] for the round!</b></span>" )
			if (istype(c.mob,/mob/new_player))
				var/mob/new_player/playermob = c.mob
				if (playermob.mind)
					playermob.mind.purchased_bank_item = p
					c.persistent_bank_item = 0
				else
					boutput( usr, "<span class='notice'><b>Can't find mind of new player mob [playermob]... please report this to a coder</b></span>" )
					return 0
			else
				boutput( usr, "<span class='notice'><b>Can't find new player mob from client [c]... please report this to a coder</b></span>" )
				return 0

			return 1
		else
			c << sound( 'sound/items/penclick.ogg' )
			boutput( usr, "<span class='notice'><b>You can't afford [p.name]!</b></span>" )
			return 0



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
#if ASS_JAM
			ret += "<p style=\"text-align:left;\">2X ASS DAY BONUS!</p>"
#endif

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

	if (purchase.Create(src))
		boutput( src, "<span class='notice'><b>[purchase.name] equipped successfully.</b></span>" )
	else
		boutput( src, "<span class='notice'><b>[purchase.name] is not available for the job you rolled. It will remain as your held item if possible.</b></span>" )

	if (src.client.persistent_bank_item != purchase.name) //Only sub_from_bank if the purchase does not match the Held Item
		src.client.sub_from_bank(purchase)
		src.client.set_last_purchase(purchase)
	return
