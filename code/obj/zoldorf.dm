//The Holy Variable That Is Zoldorf
var/global/list/mob/zoldorf/the_zoldorf = list() //for some reason a global mob was acting strangely, so this list should hypothetically only ever have one zoldorf mob reference in it (the current one)

//Zoldorf Interface
var/global/zoldorf_items_raw
var/global/list/datum/zoldorfitem/zoldorf_items = list()

/proc/zoldorfsetup() //this is called in world.dm to initialize the zoldorf vending list for the rest of the round
	for(var/I in childrentypesof(/datum/zoldorfitem))
		var/datum/zoldorfitem/I2 = new I
		var/itemname = I2.name
		var/pathname = "[I2.path]"
		var/cost = I2.cost
		var/stock = I2.stock

		zoldorf_items[pathname] = new I //security list that is later called to check for tampering with the local ui
		zoldorf_items[pathname].raw_list = list("name"=itemname,"path"=pathname,"cost"="[cost]","stock"=stock)
		zoldorf_items_raw += list(zoldorf_items[pathname].raw_list)

/obj/machinery/playerzoldorf/proc/uisetup() //general proc for sending resources to the client and loading the zoldorf ui
	usr << browse(replacetext(replacetext(replacetext(grabResource("html/zoldorf.htm"), "!!ITEMS!!", json_encode(zoldorf_items_raw)), "!!CREDITS!!", src.credits), "!!SRC_REF!!", "\ref[src]"), "window=Zoldorf;size=700x600;can_resize=1;can_minimize=1;")

/obj/machinery/playerzoldorf/proc/updateui(var/mob/exclude,var/item_path) //opening a zoldorf ui adds a player to a list (they are removed on close). this proc references
	var/wasnull = 0														  //a list of all players currently viewing the interface and dynamically updates everyone for full syncing
	// TODO: this should use updateUsrDialog instead
	var/staticiterations = length(src.openwindows)
	for(var/i=1,i<=staticiterations,i++)
		if((src.openwindows[i] == exclude) || (src.openwindows[i] == null) || !(src.openwindows[i] in range(1,src)))
			if(src.openwindows[i]==null) //checking for nulls
				wasnull = 1
			continue
		if(src.openwindows[i].client && src.openwindows[i].mind)
			if(winget(src.openwindows[i],"Zoldorf","is-visible") == "true")
				if(item_path) //because of the data being tosses back and forth, a direct reference was needed in order to properly update certain things without desyncing
					var/datum/zoldorfitem/item = zoldorf_items[item_path]
					src.openwindows[i] << output(list2params(list("update",item.name,item.path,src.credits,item.stock)),"Zoldorf.browser:updatecredits")
				else
					src.openwindows[i] << output(list2params(list("update",null,null,src.credits)),"Zoldorf.browser:updatecredits")
			else
				src.openwindows.Remove(src.openwindows[i])
				staticiterations--
				i--
	if(wasnull == 1) //if any nulls were found, declog the list
		staticiterations = length(src.openwindows)
		for(var/i=1,i<=staticiterations,i++)
			if(src.openwindows[i] == null)
				src.openwindows -= src.openwindows[i]
				staticiterations--
				i--


//Zoldorf Objects
/obj/machinery/playerzoldorf //the actual player zoldorf object
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
	var/obj/o1 = new
	var/obj/o2 = new
	var/inuse = 0
	var/colorinputbuffer
	var/smokecolor
	var/messagethrottle
	var/omen
	var/occupied

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
		o1.mouse_opacity = 0
		o2.mouse_opacity = 0
		START_TRACKING

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
			boutput(user,"<span class='alert'><b>Only humans may take zoldorf's place!</b></span>")    //i added a lot of data parameters
			return

		var/image/holderim

		if((succession)&&(ready == 0)&&(src.name != "Vacant Booth")) //first stage of succession
			var/mob/zoldorf/z = the_zoldorf[1]
			if(world.time >= src.usurpgrace)
				if(!src.usurper) //if no one is currently in queue to usurp the current zoldorf, queues the contract holder and sends the prompt to the zoldorf
					qdel(contract)
					boutput(user,"<span class='success'><b>You have been queued for succession!</b></span>")
					src.usurper = user
					if(z.client)
						SPAWN(300) //starting the afk timer, in case the zoldorf is afk or theyre deliberately not answering the prompt
							if(!src.usurper) //after the wait, making sure the usurper still exists
								return
							if(!src.usurper.client || isdead(src.usurper)) //making sure the usurper is still in the game and not dead
								boutput(src, "<span class='success'><b>Your usurper has either disconnected or died.</b></span>")
								src.usurper = null
								return
							else if(!istype(src.usurper,/mob/living/carbon/human)) //afterward making sure theyre human
								boutput(src, "<span class='success'><b>Your usurper is no longer human and is unable to take your place.</b></span>")
								return
							if(!src.YN) //if the prompt was not answered, the proc runs itself with modified parameters to move on to the second half of boothing without having to go through the other types of zoldorfing
								booth(user,zoldorfturf,null,1,1)
								return //returns after the beta version of the proc completes so the alpha version doesnt run all the way through
						if(tgui_alert(z, "A player has signed over their soul to take your place as the mighty Zoldorf. Do you wish to relinquish control now?", "Relinquish Control", list("Yes", "No")) != "Yes") //the prompt
							if(z.free) //if a zoldorf is free that means they are no longer bound to the booth and therefore either suicided or were freed in another way, either way theyre no longer zoldorf
								return
							boutput(z,"<span class='success'><b>You will have three minutes to tie up loose ends!</b></span>") //this will happen if they select the option not to relinquish control now
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
					boutput(user, "<span class='success'><b>The current zoldorf is tying up loose ends. Your soul will be consumed shortly!</b></span>")
					return
				else
					boutput(user, "<span class='alert'><b>Another player is already queued for succession!</b></span>")
					return
			else //this happens if the current zoldorf is still in their grace period in which they cant be usurped (usurpgrace)
				boutput(user,"<span class='alert'><b>The power of the new soul is too potent at this time. Please try again later.</b></span>")
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
			holderim = image(H.flat_icon)
		holderim.filters += filter(type="alpha", icon=image('icons/obj/zoldorf.dmi', "take_off_shoes_mask"))
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
		user.visible_message("<span class='alert'><b>[user.name] evaporates! OH GOD!</b></span>")
		user.unequip_all()

		if(user in src.brandlist) //making sure there isnt an unnecessary null reference to the player's old body after it's destroyed (if branded)
			src.brandlist -= user

		if(user in src.openwindows) //making sure the zoldorf cant keep the zoldorf menu open and buy things from within the booth
			src.openwindows.Remove(user)

		var/mob/zoldorf/Z = user.make_zoldorf(src) //the rest is building the mob, cleaning up overlays and variables, and passing control to the new zoldorf!
		Z.set_loc(src)
		Z.homebooth = src
		Z.autofree = 1
		remove_antag(Z,null,0,0)
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
			boutput(Z,"<span class='alert'><b>WARNING:</b> As an admin, you will be able to hear deadchat in booth without activation of Medium (based on your deadchat-hearing settings) while a non-admin player would normally not be able to.</span>")

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

			src.visible_message("<span class='success'><b>The crystal ball emits a chilling ghost light!</b></span>")
			src.lightrfade()

			o2.layer = 5
			src.vis_contents += o2

			setdead(z)
			boutput(z, "<span class='notice'><b>You begin to hear the whisperings of the dead...</b></span>")

			for(var/i=1,i<=6,i++)
				o2.color = "#00BA88"
				o2.icon = 'icons/obj/zoldorf.dmi'
				o2.icon_state = "rcolorfade"
				sleep(2.5 SECONDS)
				o2.color = "#00BA88"
				o2.icon = 'icons/obj/zoldorf.dmi'
				icon_state = "colorfade"
				sleep(2.5 SECONDS)

			if(src)
				if(z.loc == src)
					z.stat = 0
					boutput(z, "<span class='notice'><b>The whispers and wails of those parted fade into nothingness...</b></span>")
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
					src.visible_message("<span class='notice'><b>The smoke clears and the orb returns to its inert state.</b></span>")
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
					src.visible_message("<span class='notice'><b>The color of the smoke within the crystal ball begins to shift and change color!</b></span>")
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
				src.visible_message("<span class='notice'><b>The crystal ball begins to rapidly fill with colored smoke!</b></span>")

			if(src.usurping)
				return
			o2.layer = 5
			src.vis_contents += o2
			o2.icon = 'icons/obj/zoldorf.dmi'
			o2.icon_state = "colorspiral"
			o2.color = src.smokecolor
			src.messagethrottle = 0
			return 1

	attackby(obj/item/weapon, mob/user)
		if(istype(weapon, /obj/item/spacecash)) //adding money to the vending machine
			src.credits += weapon.amount
			if(winget(user,"Zoldorf","is-visible") == "true")
				user << output(list2params(list("add",null,null,weapon.amount)),"Zoldorf.browser:updatecredits")
			updateui(user)
			weapon.amount = 0
			user.visible_message("<span class='notice'><b>[src.name] magically vacuums up [user.name]'s credits!</b></span>","<span class='notice'><b>Poof! The great [src.name] has made your credits disappear! Just kidding they're in the booth.</b></span>")
			user.u_equip(weapon)
			weapon.dropped(user)
			qdel(weapon)

		else if(istype(weapon, /obj/item/zolscroll)) //handling handing of contracts to begin the usurping process
			var/obj/item/zolscroll/scroll = weapon
			var/mob/living/carbon/human/h = user
			if(h.unkillable)
				boutput(h,"<span class='alert'><b>Your soul is shielded and cannot be sold!</b></span>")
				return
			if(scroll.icon_state != "signed")
				boutput(h, "<span class='alert'>It doesn't seem to be signed yet.</span>")
				return
			if(scroll.signer == h.real_name)
				var/zoldorfturf = get_turf(src)
				if(the_zoldorf.len && the_zoldorf[1].homebooth)
					if(the_zoldorf[1].homebooth == src)
						src.booth(user,zoldorfturf,scroll,1)
					else
						boutput(h, "<span class='alert'><b>There can only be one!</b></span>")
				else
					src.booth(user,zoldorfturf,scroll)
			else
				user.visible_message("<span class='alert'><b>[h.name] tries to sell [scroll.signer]'s soul to [src]! How dare they...</b></span>","<span class='alert'><b>You can only sell your own soul!</b></span>")
		else
			..()


	attack_hand(mob/user) //interface stuff
		if(!(user in src.openwindows))
			src.openwindows.Add(user)
		uisetup()
		..()

	ex_act(var/severity) //exploding is illegal
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

	Topic(href, href_list)
		var/datum/zoldorfitem/item = null
		if(href_list["command"] == "close") //handles removing subscribed users from the list of open zoldorf windows
			if(usr in src.openwindows)
				src.openwindows.Remove(usr)
				return
		if(href_list["command"]!="return") //handling the decrementing of items that have stock values in the vendor while making sure the data coming in aligns with the data stored in the security list
			item = zoldorf_items[href_list["path"]]
			if(!item)
				return
			if(item.soul_cost())
				if(istype(usr, /mob/living/carbon/human))
					var/mob/living/carbon/human/user = usr
					if(user.mind && user.mind.soul)
						if(user.mind.soul < item.soul_cost())
							boutput(user, "<span class='alert'><b>You don't have enough of a soul to sell!</b></span>")
							return
					else
						return
				else
					boutput(usr,"<span class='alert'><b>You don't have a soul, silly.</b></span>")
					return
			if(item.stock != "i")
				if(item.stock == 0)
					boutput(usr,"<span class='alert'><b>Item out of stock!</b></span>")
					return
				else
					item.stock--
					item.raw_list["stock"]--
		else
			if((text2num_safe(href_list["credits"]) <= src.credits) && (text2num_safe(href_list["credits"])>=1) && (usr in range(1,src)) && (!(usr in src))) //return command
				usr << output("return","Zoldorf.browser:serverconfirm")
				var/obj/item/moneyreturn = new /obj/item/spacecash(get_turf(src),src.credits)
				src.credits = 0
				usr.put_in_hand_or_drop(moneyreturn)
				updateui(usr)
				return
		if(item && (usr in range(1,src)) && (!(usr in src))) //if everything matches the server-side zoldorf list, continue with the spawning of the items
			switch(href_list["command"])
				if("spawn") //spawning items from credits
					if(isnum(item.cost))
						if(item.cost <= src.credits)
							usr << output(list2params(list("spawn", item.cost)),"Zoldorf.browser:serverconfirm")
							credits -= item.cost
							usr.put_in_hand_or_drop(new item.path(src))
						else
							boutput(usr, "<span class='alert'>[src.name] stares blankly into your soul...begging you for more credits...</span>")
				if("soulspawn") //spawning items at the cost of a portion of the soul
					var/cost = item.soul_cost()
					if(istype(usr, /mob/living/carbon/human))
						var/mob/living/carbon/human/user = usr
						if(user.unkillable) //*giggles in scientist language*
							boutput(user,"<span class='alert'><b>Your soul is shielded and cannot be sold!</b></span>")
							return
					var/confirm = tgui_alert(usr, "Are you sure you want to sell [item.cost] of your soul?", "Confirm Transaction", list("Yes", "No"))
					if(confirm == "Yes")
						if(usr in range(1,src))
							usr << output(list2params(list("spawn", item.cost)),"Zoldorf.browser:serverconfirm")
							//subtract from player soul
							if(istype(usr,/mob/living/carbon/human))
								var/mob/living/carbon/human/user = usr
								if(user.sell_soul(cost) == 0)
									return
								if(!item.on_bought(usr))
									usr.put_in_hand_or_drop(new item.path(src))
							//add partial soul to zoldorf
							src.partialsouls += cost
							//update soul jar display
							src.updatejar()
			updateui(usr, href_list["path"])
		else if((usr in range(1,src)) && (!(usr in src)))
			updateui(usr)
