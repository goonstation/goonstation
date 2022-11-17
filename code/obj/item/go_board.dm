/obj/item/goboard
	name = "go board"
	desc = "it's a board for playing go!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "go-board"
	var/list/openwindows = list()
	var/list/piecelist = list()
	//var/list/desync = list()

	proc/uisetup()
		usr << browse(replacetext(replacetext(grabResource("html/go.htm"), "honk", json_encode(piecelist)), "!!SRC_REF!!", "\ref[src]"), "window=go;size=595x595;border=0;can_resize=0;can_minimize=1;")

	attack_hand(mob/user)
		if(!(user in src.openwindows) && istype(user,/mob/living/carbon/human) && !(src in user.contents))
			src.openwindows.Add(user)
		uisetup()

	attackby(obj/item/weapon, mob/user)
		if(istype(weapon,/obj/item/gostone/b) || istype(weapon,/obj/item/gostone/w))
			if(!(user in src.openwindows) && istype(user,/mob/living/carbon/human) && !(src in user.contents))
				src.openwindows.Add(user)
			uisetup()
		else
			..()

	Topic(href, href_list)
		switch(href_list["command"])
			if("close")
				if(usr in src.openwindows)
					src.openwindows.Remove(usr)
				return
			if("checkhand")
				if((istype(usr,/mob/living/carbon/human)) && (usr in range(1,src)))
					var/mob/living/carbon/human/user = usr
					var/equipped = user.equipped()
					if(!equipped)
						return
					if(istype(equipped,/obj/item/gostone/b))
						user << output("black","go.browser:checkhand")
						user.u_equip(equipped)
						qdel(equipped)
						return
					else if(istype(equipped,/obj/item/gostone/w))
						user << output("white","go.browser:checkhand")
						user.u_equip(equipped)
						qdel(equipped)
						return
				else if(usr.client && !(usr in range(usr.client.view,src)))
					usr << browse(null, "window=go")
					return
			if("piecelog")
				var/matchfound = 0
				if(piecelist.len)
					for(var/i=1,i<=src.piecelist.len,i++)
						if("[src.piecelist[i]["position"]]" == "[href_list["position"]]")
							matchfound = 1
							break
				if(matchfound == 0)
					src.piecelist.Add(list(list("position"=href_list["position"],"color"=href_list["color"])))
				var offsetx = text2num_safe(href_list["offsetx"])
				var offsety = text2num_safe(href_list["offsety"])
				var color = href_list["color"]

				if(!(src.GetOverlayImage("[href_list["position"]]")))
					var/image/piecedisplay = new /image('icons/obj/items/items.dmi',"go-render-stone-[color]")
					piecedisplay.pixel_x = (-offsetx)
					piecedisplay.pixel_y = (-offsety)

					src.UpdateOverlays(piecedisplay,"[href_list["position"]]")

				for(var/mob/living/carbon/human/u in src.openwindows)
					if(u == usr)
						continue
					if(u.client && !(u in range(u.client.view,src)))
						u << browse(null, "window=go")
						break
					u << output(list2params(list("null","null","[color]","null","secondary","[href_list["position"]]")),"go.browser:createpiece")
				return
			if("remove")
				if(istype(usr,/mob/living/carbon/human) && (usr in range(1,src)))
					var/mob/living/carbon/human/user = usr
					src.ClearSpecificOverlays("[href_list["position"]]")

					if(href_list["color"]=="black")
						user.put_in_hand_or_drop(new /obj/item/gostone/b)
					else
						user.put_in_hand_or_drop(new /obj/item/gostone/w)

					for(var/i=1,i<=src.piecelist.len,i++)
						if("[src.piecelist[i]["position"]]"==href_list["position"])
							src.piecelist[i] = null
							src.piecelist.Remove(null)
					for(var/mob/living/carbon/human/u in src.openwindows)
						if(u == user)
							continue
						if(u.client && !(u in range(u.client.view,src)))
							u << browse(null, "window=go")
							break
						u << output("[href_list["position"]]","go.browser:removepiece")
					return
				else if(usr.client && !(usr in range(usr.client.view,src)))
					usr << browse(null, "window=go")
					return

	mouse_drop(mob/user as mob)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	disposing()
		for(var/mob/living/carbon/human/user in src.openwindows)
			user << browse(null, "window=go")
		src.openwindows = null
		..()

/obj/item/gobowl
	name = "YOU SHOULDN'T SEE THIS! (*^ O ^*)"
	desc = "IT'S ILLEGAL!"
	icon = 'icons/obj/items/items.dmi'
	var/affinity //1 or 2 (black or white) : reference for setting the color of the pieces used by the bowl
	var/stones //amount of stones in the bowl

	attack_hand(mob/user)
		if(!stones)
			boutput(user, "<span style=\"color:red\">The [src] is empty!</span>")
			return
		else
			stones--
		switch(affinity)
			if(1)
				user.put_in_hand_or_drop(new /obj/item/gostone/b)
			if(2)
				user.put_in_hand_or_drop(new /obj/item/gostone/w)

	attackby(obj/item/weapon, mob/user)
		var/piece_affinity
		if(istype(weapon, /obj/item/gostone/b))
			piece_affinity = 1
		else if(istype(weapon, /obj/item/gostone/w))
			piece_affinity = 2
		else
			..()
		if(piece_affinity == affinity)
			user.u_equip(weapon)
			qdel(weapon)
			stones++
		else
			boutput(user, "<span style=\"color:red\">This piece doesn't go in that bowl, silly!</span>")
			return

	mouse_drop(mob/user as mob)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		var/total
		var/piece_affinity
		if(istype(O,/obj/item/gostone/b))
			piece_affinity = 1
		else if(istype(O,/obj/item/gostone/w))
			piece_affinity = 2
		else
			..()

		if(piece_affinity == affinity)
			switch(piece_affinity)
				if(1)
					for (var/obj/item/gostone/b/s in range(1, user))
						qdel(s)
						stones++
						total++
						sleep(2)
				if(2)
					for (var/obj/item/gostone/w/s in range(1, user))
						qdel(s)
						stones++
						total++
						sleep(2)
		else
			boutput(user, "<span style=\"color:red\">This piece doesn't go in that bowl, silly!</span>")
			return

		src.visible_message("<span><b>[user]</b> adds [total] [color] stones to the bowl!</span>")

/obj/item/gobowl/b
	name = "bowl of black stones"
	desc = "a bowl of little black stones."
	icon_state = "go-bowl-b"
	affinity = 1
	stones = 181

/obj/item/gobowl/w
	name = "bowl of white stones"
	desc = "a bowl of little white stones."
	icon_state = "go-bowl-w"
	affinity = 2
	stones = 180

/obj/item/gostone
	icon = 'icons/obj/items/items.dmi'
	w_class = W_CLASS_TINY

/obj/item/gostone/b
	name = "black stone"
	desc = "a little black stone"
	icon_state = "go-stone-b"

/obj/item/gostone/w
	name = "white stone"
	desc = "a little white stone"
	icon_state = "go-stone-w"
