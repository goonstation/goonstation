//The Holy Variable That Is Zoldorf
var/global/list/mob/zoldorf/the_zoldorf = list() //for some reason a global mob was acting strangely, so this list should hypothetically only ever have one zoldorf mob reference in it (the current one)

/// Player-controlled Zoldorf Machine
/obj/machinery/playerzoldorf
	name = "Zoldorf"
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "background"
	anchored = ANCHORED
	density = 1
	explosion_resistance = 1000
	var/list/souldorfs = list() //ability interaction
	var/list/brandlist = list("home")
	var/list/omencolors = list("none","custom","red","green")
	var/list/notes = list()
	var/omencolor
	var/obj/effect/o1 = new
	var/obj/effect/o2 = new
	var/inuse = 0
	var/colorinputbuffer
	var/smokecolor
	var/messagethrottle
	var/omen
	var/occupied

	var/list/datum/zoldorfitem/soul/soul_items = null
	var/list/datum/zoldorfitem/credit/credit_items = null

	var/initialsoul = 0 //interface and ability holder interaction
	var/storedsouls = 0
	var/partialsouls = 0
	var/credits = 0
	var/list/mob/openwindows = list()

	var/usurpgrace //succession stuffs
	var/mob/usurper
	var/usurping = 0
	var/YN

	New()
		. = ..()
		START_TRACKING
		src.soul_items = list()
		for (var/product in concrete_typesof(/datum/zoldorfitem/soul))
			src.soul_items += new product
		src.credit_items = list()
		for (var/product in concrete_typesof(/datum/zoldorfitem/credit))
			src.credit_items += new product

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if("returncash")
				if(src.credits <= 0)
					return
				var/obj/item/moneyreturn = new /obj/item/currency/spacecash(get_turf(src),src.credits)
				src.credits = 0
				ui.user.put_in_hand_or_drop(moneyreturn)
				return TRUE
			if("soul_purchase")
				var/item_name = params["item"]
				if (!item_name)
					return
				var/datum/zoldorfitem/soul/purchasing = null
				for(var/datum/zoldorfitem/soul/product in src.soul_items)
					if(product.name == item_name)
						purchasing = product
				if (!istype(purchasing, /datum/zoldorfitem/soul))
					return
				if ((purchasing.stock <= 0) && !purchasing.infinite)
					return
				var/confirm = tgui_alert(ui.user, "Are you sure you want to sell [purchasing.soul_percentage]% of your soul?", "Confirm Transaction", list("Yes", "No"))
				if(confirm != "Yes")
					return
				if (!soul_cost_check(ui.user, purchasing.soul_percentage))
					return
				var/mob/living/carbon/human/H = ui.user
				if(H.sell_soul(purchasing.soul_percentage))
					if(!purchasing.infinite)
						purchasing.stock -= 1
						src.update_static_data(ui.user)
					purchasing.on_bought(H)
					src.partialsouls += purchasing.soul_percentage
					src.updatejar()
				return TRUE
			if("credit_purchase")
				var/item_name = params["item"]
				if (!item_name)
					return
				var/datum/zoldorfitem/credit/purchasing = null
				for(var/datum/zoldorfitem/credit/product in src.credit_items)
					if(product.name == item_name)
						purchasing = product
				if(!istype(purchasing, /datum/zoldorfitem/credit))
					return
				if ((purchasing.stock <= 0) && !purchasing.infinite)
					return
				if(purchasing.price > src.credits)
					boutput(ui.user, SPAN_ALERT("[src.name] stares blankly into your soul...begging you for more credits..."))
					return
				src.credits -= purchasing.price
				if(!purchasing.infinite)
					purchasing.stock -= 1
					src.update_static_data(ui.user)
				purchasing.on_bought(ui.user)
				return TRUE

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ZoldorfPlayerShop", src.name)
		ui.open()

	ui_data(mob/user)
		. = ..()
		.["credits"] = src.credits
		.["user_soul"] = user.mind?.soul ? user.mind.soul : 0

	ui_static_data(mob/user)
		. = ..()
		var/list/products = list()
		for(var/datum/zoldorfitem/soul/product as anything in src.soul_items)
			products += list(list(
				"name" = product.name,
				"stock" = product.stock,
				"infinite" = product.infinite,
				"img" = product.img,
				"soul_percentage" = product.soul_percentage,
			))
		for(var/datum/zoldorfitem/credit/product as anything in src.credit_items)
			products += list(list(
				"name" = product.name,
				"stock" = product.stock,
				"infinite" = product.infinite,
				"img" = product.img,
				"price" = product.price,
			))
		.["products"] = products

	/// Check to see if the dispensing user has enough soul to purchase an item
	proc/soul_cost_check(mob/user, percentage)
		if(!istype(user, /mob/living/carbon/human) || !user.mind?.soul)
			boutput(usr,SPAN_ALERT("<b>You don't have a soul, silly.</b>"))
			return FALSE
		var/mob/living/carbon/human/H = user
		if(H.mind.soul < percentage)
			boutput(user, SPAN_ALERT("<b>You don't have enough of a soul to sell!</b>"))
			return FALSE
		if(H.unkillable)
			boutput(user,SPAN_ALERT("<b>Your soul is shielded and cannot be sold!</b>"))
			return FALSE
		return TRUE

	proc/updatejar() //updates soul jar display based on partial souls and adds any spillover to the current zoldorf's soul pool
		while(src.partialsouls >= 100)
			src.partialsouls -= 100
			src.storedsouls++
			if(the_zoldorf.len)
				var/mob/zoldorf/z = the_zoldorf[1]
				z.abilityHolder.points = src.storedsouls

		if(the_zoldorf.len)
			var/mob/zoldorf/z = the_zoldorf[1]
			var/datum/targetable/zoldorfAbility/a = z.getAbility(/datum/targetable/zoldorfAbility/jar)
			var/s = src.partialsouls
			if(s>=90)
				a.icon_state = "jar9"
			else if(s>=80)
				a.icon_state = "jar8"
			else if(s>=70)
				a.icon_state = "jar7"
			else if(s>=60)
				a.icon_state = "jar6"
			else if(s>=50)
				a.icon_state = "jar5"
			else if(s>=40)
				a.icon_state = "jar4"
			else if(s>=30)
				a.icon_state = "jar3"
			else if(s>=20)
				a.icon_state = "jar2"
			else if(s>0)
				a.icon_state = "jar1"
			else if(s==0)
				a.icon_state = "jare"
			z.updateButtons()

	proc/booth(var/mob/user,var/zoldorfturf = user.loc,var/contract = null,var/succession = 0,var/ready = 0) //sorry about the clutter on this proc. its called in about three different ways
		if(!istype(user,/mob/living/carbon/human))															 //and rather than overloading it and writing the same proc three times,
			boutput(user,SPAN_ALERT("<b>Only humans may take zoldorf's place!</b>"))    //i added a lot of data parameters
			return

		var/image/holderim

		if((succession)&&(ready == 0)&&(src.name != "Vacant Booth")) //first stage of succession
			var/mob/zoldorf/z = the_zoldorf[1]
			if(world.time >= src.usurpgrace)
				if(!src.usurper) //if no one is currently in queue to usurp the current zoldorf, queues the contract holder and sends the prompt to the zoldorf
					qdel(contract)
					boutput(user,SPAN_SUCCESS("<b>You have been queued for succession!</b>"))
					src.usurper = user
					if(z.client)
						SPAWN(300) //starting the afk timer, in case the zoldorf is afk or theyre deliberately not answering the prompt
							if(!src.usurper) //after the wait, making sure the usurper still exists
								return
							if(!src.usurper.client || isdead(src.usurper)) //making sure the usurper is still in the game and not dead
								boutput(src, SPAN_SUCCESS("<b>Your usurper has either disconnected or died.</b>"))
								src.usurper = null
								return
							else if(!istype(src.usurper,/mob/living/carbon/human)) //afterward making sure theyre human
								boutput(src, SPAN_SUCCESS("<b>Your usurper is no longer human and is unable to take your place.</b>"))
								return
							if(!src.YN) //if the prompt was not answered, the proc runs itself with modified parameters to move on to the second half of boothing without having to go through the other types of zoldorfing
								booth(user,zoldorfturf,null,1,1)
								return //returns after the beta version of the proc completes so the alpha version doesnt run all the way through
						if(tgui_alert(z, "A player has signed over their soul to take your place as the mighty Zoldorf. Do you wish to relinquish control now?", "Relinquish Control", list("Yes", "No")) != "Yes") //the prompt
							if(z.free) //if a zoldorf is free that means they are no longer bound to the booth and therefore either suicided or were freed in another way, either way theyre no longer zoldorf
								return
							boutput(z,SPAN_SUCCESS("<b>You will have three minutes to tie up loose ends!</b>")) //this will happen if they select the option not to relinquish control now
							src.YN = 1
							sleep(1800)
							booth(user,zoldorfturf,null,1,1) //same as before
							return
						else
							if(z.free) //alternativey if they chose to relinquish now, the successor is just boothed on the spot
								return
							src.YN = 1
							booth(user,zoldorfturf,null,1,1)
							return
					else
						if(z.free) //instant usurping if the zoldorf disconnected
							return
						src.YN = 1
						booth(user,zoldorfturf,null,1,1)
						return

				else if(user == src.usurper) //if the user is already the usurper, they are prompted to wait
					boutput(user, SPAN_SUCCESS("<b>The current zoldorf is tying up loose ends. Your soul will be consumed shortly!</b>"))
					return
				else
					boutput(user, SPAN_ALERT("<b>Another player is already queued for succession!</b>"))
					return
			else //this happens if the current zoldorf is still in their grace period in which they cant be usurped (usurpgrace)
				boutput(user,SPAN_ALERT("<b>The power of the new soul is too potent at this time. Please try again later.</b>"))
				return

		if(the_zoldorf.len && ready == 1) //this is called during the recursion to souldorfify the zoldorf in preparation for the newcomer
			var/mob/zoldorf/z = the_zoldorf[1]
			z.free()
			z.set_loc(get_turf(src))
			the_zoldorf = list()
			ready = 0

		//dress player sprite
		var/mob/living/carbon/human/H = user
		if(istype(H))
			holderim = image(H.build_flat_icon(SOUTH))
		holderim.filters += filter(type="alpha", icon=icon('icons/obj/zoldorf.dmi', "take_off_shoes_mask"))
		holderim.overlays += image('icons/mob/clothing/overcoats/worn_suit.dmi', icon_state="wizard")
		holderim.overlays += image('icons/mob/clothing/head.dmi', icon_state="wizard")
		holderim.pixel_y = -3

		//overlay player
		src.UpdateOverlays(holderim,"player")

		//overlay shell
		src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"shell"),"shell")

		//overlay table
		src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"tablenew"),"table")

		//overlay crystal ball
		if(src.usurper)
			src.usurping = 1
			src.vis_contents -= o1
			src.vis_contents -= o2
			src.smokecolor = null
			src.colorinputbuffer = null
			src.omen = 0
			src.inuse = 0

		src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"crystalball"),"crystalball")

		//spawn player zoldorf
		if(!src.usurper)
			src.set_loc(get_turf(zoldorfturf))
			src.layer = 3
			qdel(contract)

		//zoldorfify the player
		user.visible_message(SPAN_ALERT("<b>[user.name] evaporates! OH GOD!</b>"))
		user.unequip_all()

		if(user in src.brandlist) //making sure there isnt an unnecessary null reference to the player's old body after it's destroyed (if branded)
			src.brandlist -= user

		if(user in src.openwindows) //making sure the zoldorf cant keep the zoldorf menu open and buy things from within the booth
			src.openwindows.Remove(user)

		var/datum/mind/mind = user.mind
		if (mind)
			mind.wipe_antagonists()
			user = mind.current
		var/mob/zoldorf/Z = user.make_zoldorf(src) //the rest is building the mob, cleaning up overlays and variables, and passing control to the new zoldorf!
		Z.set_loc(src)
		Z.homebooth = src
		Z.autofree = 1
		src.souldorfs.Add(Z)
		src.occupied = 1
		the_zoldorf.Add(Z)
		Z.show_antag_popup("zoldorf")
		src.usurpgrace = world.time + 3000
		src.YN = null
		src.usurper = null
		src.usurping = null
		src.updatejar()

		if(Z.client && Z.client.holder && !Z.client.player_mode)
			boutput(Z,SPAN_ALERT("<b>WARNING:</b> As an admin, you will be able to hear deadchat in booth without activation of Medium (based on your deadchat-hearing settings) while a non-admin player would normally not be able to."))

	proc/lightfade(var/initialbright = 0.8) //lighting animation (i have no idea how intense this will be on the server) //fade out
		var/loops = (initialbright*10)
		for(var/i=1,i<=loops,i++)
			initialbright -= 0.1
			src.add_simple_light("zoldorf", list(0.25 * 255, 0.51 * 255, 0.43 * 255, initialbright))
			sleep(0.1 SECONDS)

	proc/lightrfade(var/targetbright = 0.8) //fade in
		var/initialbright = 0
		var/loops = targetbright*10
		for(var/i=1,i<=loops,i++)
			initialbright += 0.1
			src.add_simple_light("zoldorf", list(0.25 * 255, 0.51 * 255, 0.43 * 255, initialbright))
			sleep(0.1 SECONDS)

	proc/omen(var/mob/zoldorf/z) //this proc is 100% animations and stuff for the omen ability. its bound to the booth to stop weird things from happening if something happens to the mob mid-animation
		if(!src.omen)
			src.UpdateOverlays(null,"crystalball",0,1)
			o1.icon = 'icons/obj/zoldorf.dmi'
			o1.layer = 6
			src.vis_contents += o1
			o1.icon_state = "crystalfade"
			sleep(1.1 SECONDS)

			src.visible_message(SPAN_SUCCESS("<b>The crystal ball emits a chilling ghost light!</b>"))
			src.lightrfade()

			o2.layer = 5
			src.vis_contents += o2

			setdead(z)
			boutput(z, SPAN_NOTICE("<b>You begin to hear the whisperings of the dead...</b>"))

			for(var/i=1,i<=6,i++)
				o2.color = "#00BA88"
				o2.icon = 'icons/obj/zoldorf.dmi'
				o2.icon_state = "rcolorfade"
				sleep(2.5 SECONDS)
				o2.color = "#00BA88"
				o2.icon = 'icons/obj/zoldorf.dmi'
				o2.icon_state = "colorfade"
				sleep(2.5 SECONDS)

			if(src)
				if(z.loc == src)
					setalive(z)
					boutput(z, SPAN_NOTICE("<b>The whispers and wails of those parted fade into nothingness...</b>"))
				src.lightfade()
				src.remove_simple_light("zoldorf")
				if(src.usurping)
					return
				o1.icon_state = "rcrystalfade"
				sleep(1.1 SECONDS)
				if(src.usurping)
					return
				src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"crystalball"),"crystalball")
				o1.icon_state = null
				o2.icon = null
		else
			omencolor = input("Which omen would you like to display?", "Omens", null) as null|anything in omencolors
			if(!omencolor)
				return 0
			if(omencolor == "custom")
				src.colorinputbuffer = input(z,"Which omen color would you like?") as color
				if(!src.colorinputbuffer)
					return 0
			if(inuse)
				if(omencolor == "none")
					src.visible_message(SPAN_NOTICE("<b>The smoke clears and the orb returns to its inert state.</b>"))
					if(src.usurping)
						return
					o1.icon_state = "rcrystalfade"
					sleep(1.1 SECONDS)
					if(src.usurping)
						return
					src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"crystalball"),"crystalball")
					o1.icon_state = null
					inuse = 0
					o2.icon = null
					src.smokecolor = null
					src.colorinputbuffer = null
					src.omen = 0
					return
				else
					src.visible_message(SPAN_NOTICE("<b>The color of the smoke within the crystal ball begins to shift and change color!</b>"))
					src.messagethrottle = 1
					if(src.usurping)
						return
					o2.icon = 'icons/obj/zoldorf.dmi'
					o2.icon_state = "colorfade"
					o2.color = src.smokecolor
					sleep(2.5 SECONDS)
					if(src.usurping)
						return
					o2.icon = null
					src.smokecolor = null
			else if(omencolor == "none")
				return 0

			if(!inuse)
				if(src.usurping)
					return
				src.UpdateOverlays(null,"crystalball",0,1)

				o1.icon = 'icons/obj/zoldorf.dmi'
				o1.layer = 6
				src.vis_contents += o1
				o1.icon_state = "crystalfade"
				src.inuse = 1
				sleep(1.1 SECONDS)
				if(src.usurping)
					return

			switch(omencolor)
				if("red")
					src.smokecolor = "#FF3A3A"
				if("green")
					src.smokecolor = "#6DFF6D"
				if("custom")
					src.smokecolor = src.colorinputbuffer

			if(!src.messagethrottle)
				src.visible_message(SPAN_NOTICE("<b>The crystal ball begins to rapidly fill with colored smoke!</b>"))

			if(src.usurping)
				return
			o2.layer = 5
			src.vis_contents += o2
			o2.icon = 'icons/obj/zoldorf.dmi'
			o2.icon_state = "colorspiral"
			o2.color = src.smokecolor
			src.messagethrottle = 0
			return 1

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/currency/spacecash))
			var/obj/item/currency/spacecash/creds = I
			src.credits += creds.amount
			src.ui_interact(user)
			creds.amount = 0
			user.visible_message(SPAN_NOTICE("<b>[src.name] magically vacuums up [user.name]'s credits!</b>"),SPAN_NOTICE("<b>Poof! The great [src.name] has made your credits disappear! Just kidding, they're in the booth.</b>"))
			user.u_equip(creds)
			creds.dropped(user)
			qdel(creds)
			tgui_process.update_uis(src)

		else if(istype(I, /obj/item/zolscroll)) //handling handing of contracts to begin the usurping process
			var/obj/item/zolscroll/scroll = I
			var/mob/living/carbon/human/H = user
			if(H.unkillable)
				boutput(H,SPAN_ALERT("<b>Your soul is shielded and cannot be sold!</b>"))
				return
			if(scroll.icon_state != "signed")
				boutput(H, SPAN_ALERT("It doesn't seem to be signed yet."))
				return
			if(scroll.signer == H.real_name)
				var/zoldorfturf = get_turf(src)
				if(the_zoldorf.len && the_zoldorf[1].homebooth)
					if(the_zoldorf[1].homebooth == src)
						src.booth(user,zoldorfturf,scroll,1)
					else
						boutput(H, SPAN_ALERT("<b>There can only be one!</b>"))
				else
					src.booth(user,zoldorfturf,scroll)
			else
				user.visible_message(SPAN_ALERT("<b>[H.name] tries to sell [scroll.signer]'s soul to [src]! How dare they...</b>"),SPAN_ALERT("<b>You can only sell your own soul!</b>"))
		else
			..()

	ex_act(severity) //exploding is illegal
		return

	disposing() //cleanup stuffs: making sure the zoldorf is freed so its not frozen and helpless if the booth is deleted, cleaning up references and overlays, etc
		qdel(o2)
		qdel(o1)
		for(var/mob/zoldorf/Z in src.souldorfs)
			if(Z.free)
				continue
			Z.homebooth = null
			Z.free()
		the_zoldorf = list()
		STOP_TRACKING
		..()
