/*Clothing Booth UI*/
//list creation
var/clothingbooth_json
var/list/clothingbooth_items = list()

/proc/clothingbooth_setup() //sends items to the interface far, far away from byond fuckery land
	var/list/list/list/boothlist = list()
	for(var/datum/clothingbooth_item/type as anything in concrete_typesof(/datum/clothingbooth_item))
		var/datum/clothingbooth_item/I = new type
		var/itemname = I.name
		var/pathname = "[I.path]"
		var/categoryname = I.category
		var/cost = I.cost
		var/matchfound = 0
		if(boothlist.len>0)
			for(var/i=1, i<=boothlist.len, i++)
				if(boothlist[i]["name"] == categoryname)
					boothlist[i]["items"].Add(list(list("name"=itemname, "path"=pathname, "cost"=cost)))
					matchfound = 1
					break
		if(matchfound == 0)
			boothlist.Add(list(list("name"=categoryname, "items"=list(list("name"=itemname, "path"=pathname, "cost"=cost)))))
		clothingbooth_items[pathname] = I
	clothingbooth_json = json_encode(boothlist)

//setting up player-side UI data
/obj/machinery/clothingbooth/proc/uisetup(var/mob/user)
	if(!user.client)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	src.preview.update_appearance(H.bioHolder.mobAppearance, H.mutantrace, name=user.real_name)
	qdel(src.preview_item)
	src.preview_item = null
	src.preview.remove_all_clients()
	src.preview.add_client(user.client)

	user << browse_rsc('browserassets/css/clothingbooth.css')
	user << browse_rsc('browserassets/js/clothingbooth.js')
	user << browse(replacetext(replacetext(replacetext(grabResource("html/clothingbooth.html"), "!!BOOTH_LIST!!", clothingbooth_json), "!!SRC_REF!!", "\ref[src]"), "!!PREVIEW_ID!!", src.preview.preview_id), "window=ClothingBooth;size=600x600;can_resize=1;can_minimize=1;")


//clothing booth stuffs <3
/obj/machinery/clothingbooth
	var/datum/character_preview/multiclient/preview
	var/obj/item/preview_item = null
	var/money = 0
	var/open = 1
	var/yeeting = 0
	name = "Clothing Booth"
	desc = "Please hand your credits to the goblin tailor before entering."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	anchored = 1
	density = 1
	//power_usage = 100
	var/datum/light/light
	New()
		..()
		UnsubscribeProcess()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.enable()
		src.preview = new()

	relaymove(mob/user as mob)
		if (user.stat != 0 || user.getStatusDuration("stunned"))
			return
		src.set_open(1)
		sleep(2 SECONDS)
		if(!(user in src))
			return
		user.set_loc(src.loc) //possible fix to the for loop bug (possibly need to clear contents of src upon dropping items)
		for (var/obj/O in src.contents)
			user.put_in_hand_or_drop(O)
		if(money > 0)
			var/obj/item/moneyreturn = new /obj/item/spacecash(get_turf(src),src.money)
			src.money = 0
			user.put_in_hand_or_drop(moneyreturn)

	Topic(href, href_list)
		var/datum/clothingbooth_item/cb_item = clothingbooth_items[href_list["path"]]
		if(!istype(cb_item))
			return
		if(!(usr in src.contents))
			return
		var/itempath = text2path(href_list["path"])
		switch(href_list["command"])
			if("spawn")
				if(text2num_safe(cb_item.cost) <= src.money)
					money -= text2num_safe(cb_item.cost)
					usr.put_in_hand_or_drop(new itempath(src))
				else
					boutput(usr, "<span class='alert'>The clothing machine rattles and roars with anger! You must offer more tribute to the goblin tailor!</span>")
					var/wiggle = 6
					while(wiggle > 0)
						wiggle--
						src.pixel_x = rand(-3,3)
						src.pixel_y = rand(-3,3)
						sleep(0.1 SECONDS)
					src.pixel_x = 0
					src.pixel_y = 0
			if("render")
				if (src.preview_item)
					src.preview.preview_mob.u_equip(src.preview_item)
					qdel(src.preview_item)
					src.preview_item = null
				src.preview_item = new itempath()
				src.preview.preview_mob.force_equip(src.preview_item, cb_item.slot)

	Click()
		if(!ishuman(usr))
			boutput(usr,"<span style=\"color:red\">Human clothes don't fit you, silly :P</span>")
			return
		if((usr in src) && (src.open == 0))
			if(istype(usr.equipped(),/obj/item/spacecash))
				var/obj/item/dummycredits = usr.equipped()
				src.money += dummycredits.amount
				dummycredits.amount = 0
				qdel(dummycredits)
				return
			else
				uisetup(usr)
				return
		..()

/obj/machinery/clothingbooth/attackby(obj/item/weapon as obj, mob/user as mob)
	if(istype(weapon, /obj/item/spacecash))
		if(!(locate(/mob) in src))
			src.money += weapon.amount
			weapon.amount = 0
			user.visible_message("<span class='notice'>[user.name] inserts credits into the- Wait, was that a hand?</span>","<span class='notice'>A small goblin-like hand reaches out from a compartment within the clothing booth, takes your credits, and quickly pulls them back inside.</span>")
			user.u_equip(weapon)
			weapon.dropped()
			qdel(weapon)
		else
			boutput(user,"<span style=\"color:red\">It seems the clothing booth is currently occupied. Maybe it's better to just wait.</span>")

	else
		var/obj/item/grab/G = weapon
		if(istype(G))
			if (ismob(G.affecting))
				var/mob/GM = G.affecting
				if ((istype(src, /obj/machinery/clothingbooth)) && (src.open == 1))
					GM.set_loc(src)
					user.visible_message("<span class='alert'><b>[user] stuffs [GM.name] into [src]!</b></span>","<span class='alert'><b>You stuff [GM.name] into [src]!</b></span>")
					src.set_open(0)
					qdel(G)
					logTheThing("combat", user, GM, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
					actions.interrupt(G.affecting, INTERRUPT_MOVE)
					actions.interrupt(user, INTERRUPT_ACT)

/obj/machinery/clothingbooth/proc/set_open(var/new_open)
	if(new_open == src.open)
		return
	if(new_open)
		src.icon_state = "clothingbooth-opening"
		animate(src, time = 20)
		animate(icon_state = "clothingbooth-open")
	else
		src.icon_state = "clothingbooth-closing"
		animate(src, time = 21.5)
		animate(icon_state = "clothingbooth-closed")
	src.open = new_open

/obj/machinery/clothingbooth/attack_hand(mob/user as mob)
	if(!ishuman(user))
		boutput(user,"<span style=\"color:red\">Human clothes don't fit you, silly :P</span>")
		return
	if(!(user in range(1,src)))
		return
	if((src.open == 1)&&(!user.stat))
		user.set_loc(src.loc)
		src.set_open(0)
		sleep(0.5 SECONDS)
		user.set_loc(src)
		boutput(user, "<span class='success'><br>Welcome to the clothing booth! Click an item to view its preview. Click again to purchase. Purchasing items will pull from the credits you insert into the machine prior to entering.<br></span>")
		uisetup(user)
	else
		if(src.yeeting == 0)
			src.yeeting = 1
			user.visible_message("<span class='alert'>Uh oh...It looks like [user.name] is thinking about charging into the clothing booth...</span>","<span class='alert'>You are working up the nerve to pull the occupant out...</span>")
			SPAWN_DBG(4 SECONDS)
				if((user in range(1, src)) && (locate(/mob) in src))
					if (prob(45))
						user.visible_message("<span class='success'>phew...[user.name] decided not to enter the booth.</span>","<span class='success'>Maybe not...they could be changing...</span>")
					else
						if((user in range(1, src)) && (locate(/mob) in src))
							user.visible_message("<span class='alert'><b>OH GOD, [uppertext(user.name)] IS GOING IN! THEY'RE INSANE!</b></span>","<span class='alert'>You're going in...</span>")
							src.set_open(1)
							if((user in range(1, src)) && (locate(/mob) in src))
								for(var/mob/M in src.contents)
									M.set_loc(src.loc)
									M.changeStatus("weakened", 2 SECONDS)
									M.changeStatus("stunned", 2 SECONDS)
									src.visible_message("<span class='alert'><b>[uppertext(user.name)] EMERGES FROM THE BOOTH DRAGGING [uppertext(M.name)] BY THE LEGS!</b></span>")
				else
					user.visible_message("<span class='success'>It looks like [user.name] decided against entering the booth.</span>","<span class='alert'>You are too far away from the booth or the occupant has escaped.</span>")
			src.yeeting = 0

		else
			boutput(user, "<span class='alert'>Someone is already working up the nerve to pull the ouccupant out.</span>")

/obj/machinery/clothingbooth/Exited()
	src.set_open(1)
