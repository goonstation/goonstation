/obj/item/goboard
	name = "go board"
	desc = "it's a board for playing go!"
	icon = 'icons/obj/clothing/dryadmiscinv.dmi'
	icon_state = "goboard"
	var/list/openwindows = list()
	var/list/piecelist = list()
	var/list/desync = list()

	proc/uisetup()
		usr << browse_rsc(file("browserassets/css/go.css"))
		usr << browse_rsc(file("browserassets/js/go.js"))
		usr << browse_rsc('browserassets/images/go/goboard.png', "goboard.png")
		usr << browse_rsc('browserassets/images/go/goblack.png', "goblack.png")
		usr << browse_rsc('browserassets/images/go/gowhite.png', "gowhite.png")
		usr << browse(replacetext(replacetext(grabResource("html/go.htm"), "honk", json_encode(piecelist)), "!!SRC_REF!!", "\ref[src]"), "window=go;size=595x595;border=0;can_resize=0;can_minimize=1;")

	attack_hand(mob/user as mob)
		if(!(user in src.openwindows) && istype(user,/mob/living/carbon/human) && !(src in user.contents))
			src.openwindows.Add(user)
			uisetup()
		else
			..()
			return

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
					if(istype(equipped,/obj/item/gostoneb))
						user << output("black","go.browser:checkhand")
						user.u_equip(equipped)
						qdel(equipped)
						return
					else if(istype(equipped,/obj/item/gostonew))
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
				var offsetx = text2num(href_list["offsetx"])
				var offsety = text2num(href_list["offsety"])
				var color = href_list["color"]

				if(!(src.GetOverlayImage("[href_list["position"]]")))
					var/image/piecedisplay = new /image('icons/obj/clothing/dryadmiscinv.dmi',"goboardstone[color]")
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
						user.put_in_hand_or_drop(new /obj/item/gostoneb)
					else
						user.put_in_hand_or_drop(new /obj/item/gostonew)

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

	MouseDrop(mob/user as mob)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	disposing()
		for(var/mob/living/carbon/human/user in src.openwindows)
			user << browse(null, "window=go")
		..()

/obj/item/gobowlb
	name = "bowl of black stones"
	desc = "a bowl of little black stones."
	icon = 'icons/obj/clothing/dryadmiscinv.dmi'
	icon_state = "gobowlb"

	attack_hand(mob/user as mob)
		user.put_in_hand_or_drop(new /obj/item/gostoneb)

	attackby(obj/item/weapon as obj,mob/user as mob)
		if((istype(weapon, /obj/item/gostoneb)) || (istype(weapon, /obj/item/gostonew)))
			user.u_equip(weapon)
			qdel(weapon)

	MouseDrop(mob/user as mob)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		var/total
		var/color
		if(istype(O,/obj/item/gostoneb))
			color = "black"
			for (var/obj/item/gostoneb/s in range(1, user))
				qdel(s)
				total++
				sleep(2)
		else if(istype(O,/obj/item/gostonew))
			color = "white"
			for (var/obj/item/gostonew/s in range(1, user))
				qdel(s)
				total++
				sleep(2)
		src.visible_message("<span><b>[usr]</b> adds [total] [color] stones to the bowl!</span>")

/obj/item/gobowlw
	name = "bowl of white stones"
	desc = "a bowl of little white stones."
	icon = 'icons/obj/clothing/dryadmiscinv.dmi'
	icon_state = "gobowlw"

	attack_hand(mob/user as mob)
		user.put_in_hand_or_drop(new /obj/item/gostonew)

	attackby(obj/item/weapon as obj,mob/user as mob)
		if((istype(weapon, /obj/item/gostoneb)) || (istype(weapon, /obj/item/gostonew)))
			user.u_equip(weapon)
			qdel(weapon)

	MouseDrop(mob/user as mob)
		if((istype(user,/mob/living/carbon/human))&&(!user.stat)&&!(src in user.contents))
			user.put_in_hand_or_drop(src)

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		var/total
		var/color
		if(istype(O,/obj/item/gostoneb))
			color = "black"
			for (var/obj/item/gostoneb/s in range(1, user))
				qdel(s)
				total++
				sleep(2)
		else if(istype(O,/obj/item/gostonew))
			color = "white"
			for (var/obj/item/gostonew/s in range(1, user))
				qdel(s)
				total++
				sleep(2)
		src.visible_message("<span><b>[usr]</b> adds [total] [color] stones to the bowl!</span>")

/obj/item/gostoneb
	name = "black stone"
	desc = "a little black stone"
	icon = 'icons/obj/clothing/dryadmiscinv.dmi'
	icon_state = "gostoneb"
	w_class = 1

/obj/item/gostonew
	name = "white stone"
	desc = "a little white stone"
	icon = 'icons/obj/clothing/dryadmiscinv.dmi'
	icon_state = "gostonew"
	w_class = 1
