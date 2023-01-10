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
// /obj/machinery/clothingbooth/proc/uisetup(var/mob/user)
// 	if(!user.client)
// 		return
// 	if(!ishuman(user))
// 		return

// 	var/mob/living/carbon/human/H = user
// 	src.preview.update_appearance(H.bioHolder.mobAppearance, H.mutantrace, name=user.real_name)
// 	qdel(src.preview_item)
// 	src.preview_item = null
// 	src.preview.remove_all_clients()
// 	src.preview.add_client(user.client)

// 	user << browse_rsc('browserassets/css/clothingbooth.css')
// 	user << browse_rsc('browserassets/js/clothingbooth.js')
// 	user << browse(replacetext(replacetext(replacetext(grabResource("html/clothingbooth.html"), "!!BOOTH_LIST!!", clothingbooth_json), "!!SRC_REF!!", "\ref[src]"), "!!PREVIEW_ID!!", src.preview.preview_id), "window=ClothingBooth;size=600x600;can_resize=1;can_minimize=1;")

/obj/machinery/clothingbooth/ui_interact(mob/user, datum/tgui/ui)
	var/mob/living/carbon/human/H = user
	src.preview.update_appearance(H.bioHolder.mobAppearance, H.mutantrace, name=user.real_name)
	qdel(src.preview_item)
	src.preview_item = null
	src.preview.remove_all_clients()
	src.preview.add_client(user.client)

	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClothingBooth")
		ui.open()

//clothing booth stuffs <3
/obj/machinery/clothingbooth
	var/datum/character_preview/multiclient/preview
	var/obj/item/preview_item = null
	var/money = 0
	var/open = TRUE
	name = "Clothing Booth"
	desc = "Contains a sophisticated autoloom system capable of manufacturing a variety of clothing items on demand."
	icon = 'icons/obj/vending.dmi'
	icon_state = "clothingbooth-open"
	flags = TGUI_INTERACTIVE
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
		if (!isalive(user))
			return
		eject(user)

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
					boutput(usr, "<span class='alert'>Insufficient funds!</span>")
					animate_shake(src, 12, 3, 3)
			if("render")
				if (src.preview_item)
					src.preview.preview_mob.u_equip(src.preview_item)
					qdel(src.preview_item)
					src.preview_item = null
				src.preview_item = new itempath()
				src.preview.preview_mob.force_equip(src.preview_item, cb_item.slot)

	Click()
		if(!ishuman(usr))
			boutput(usr,"<span style=\"color:red\">Human clothes don't fit you!</span>")
			return
		if((usr in src) && (src.open == 0))
			if(istype(usr.equipped(),/obj/item/spacecash))
				var/obj/item/dummycredits = usr.equipped()
				src.money += dummycredits.amount
				dummycredits.amount = 0
				qdel(dummycredits)
				return
			else
				ui_interact(usr)
				return
		..()

/obj/machinery/clothingbooth/attackby(obj/item/weapon, mob/user)
	if(istype(weapon, /obj/item/spacecash))
		if(!(locate(/mob) in src))
			src.money += weapon.amount
			weapon.amount = 0
			user.visible_message("<span class='notice'>[user.name] inserts credits into [src]")
			playsound(user, 'sound/machines/capsulebuy.ogg', 80, 1)
			user.u_equip(weapon)
			weapon.dropped(user)
			qdel(weapon)
		else
			boutput(user,"<span style=\"color:red\">It seems the clothing booth is currently occupied. Maybe it's better to just wait.</span>")

	else if (istype(weapon, /obj/item/grab))
		var/obj/item/grab/G = weapon
		if (ismob(G.affecting))
			var/mob/GM = G.affecting
			if (src.open)
				GM.set_loc(src)
				user.visible_message("<span class='alert'><b>[user] stuffs [GM.name] into [src]!</b></span>","<span class='alert'><b>You stuff [GM.name] into [src]!</b></span>")
				src.close()
				qdel(G)
				logTheThing(LOG_COMBAT, user, "places [constructTarget(GM,"combat")] into [src] at [log_loc(src)].")
	else
		..()

/// open the booth
/obj/machinery/clothingbooth/proc/open()
	flick("clothingbooth-opening", src)
	src.icon_state = "clothingbooth-open"
	open = TRUE

/// close the booth
/obj/machinery/clothingbooth/proc/close()
	flick("clothingbooth-closing", src)
	src.icon_state = "clothingbooth-closed"
	open = FALSE

/// ejects occupant if any along with any contents
/obj/machinery/clothingbooth/proc/eject(mob/occupant)
	if (open) return
	open()
	SPAWN(2 SECONDS)
		var/turf/T = get_turf(src)
		if (!occupant)
			occupant = locate(/mob/living/carbon/human) in src
		if (occupant?.loc == src) //ensure mob wasn't otherwise removed during out spawn call
			occupant.set_loc(T)
			if(src.money > 0)
				occupant.put_in_hand_or_drop(new /obj/item/spacecash(T, src.money))
			src.money = 0
			for (var/obj/item/I in src.contents)
				occupant.put_in_hand_or_drop(I)
			for (var/atom/movable/AM in contents)
				AM.set_loc(T) //dump anything that's left in there on out
		else
			if(src.money > 0)
				new /obj/item/spacecash(T, src.money)
			src.money = 0
			for (var/atom/movable/AM in contents)
				AM.set_loc(T)


/obj/machinery/clothingbooth/attack_hand(mob/user)
	if (!ishuman(user))
		boutput(user,"<span style=\"color:red\">Human clothes don't fit you!</span>")
		return
	if (!IN_RANGE(user, src, 1))
		return
	if (!can_act(user))
		return
	if (open)
		user.set_loc(src.loc)
		SPAWN(0.5 SECONDS)
			if (!open) return
			user.set_loc(src)
			src.close()
			boutput(user, "<span class='success'><br>Welcome to the clothing booth! Click an item to view its preview. Click again to purchase. Purchasing items will pull from the credits you insert into the machine prior to entering.<br></span>")
			ui_interact(user)
	else
		SETUP_GENERIC_ACTIONBAR(user, src, 10 SECONDS, .proc/eject, null, src.icon, src.icon_state, "[user] forces open [src]!", INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION)
