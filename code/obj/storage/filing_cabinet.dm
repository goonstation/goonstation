/obj/filing_cabinet
	name = "filing cabinet"
	desc = "A cabinet whose sole purpose is to store your damn files."
	icon = 'icons/obj/large_storage.dmi'//fucking stupid fucking ass nothing i do works to make this icon be closed if someone doesnt interact with the menu
	icon_state = "filecabinet" //i guess its a feature now               ok bye
	anchored = 1
	density = 1

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/paper) || istype(W, /obj/item/folder))
			icon_state = "filecabinet-open"
			if (istype(W, /obj/item/paper)) //couldnt get this to work nicely with [w] so you get this instead god
				boutput(user, "You file the paper.")
			else if (istype(W, /obj/item/folder))
				boutput(user, "You file the folder.")
			user.drop_item()
			W.set_loc(src)
			SPAWN(5 DECI SECONDS)
				icon_state = "filecabinet"

	attack_hand(var/mob/user)
		icon_state = "filecabinet-open"
		show_window(user)

	Topic(var/href, var/href_list)

		if (BOUNDS_DIST(src, usr) > 0 || iswraith(usr) || isintangible(usr) || is_incapacitated(usr))
			return
		..()

		if(href_list["action"] == "retrieve")
			usr.put_in_hand_or_drop(src.contents[text2num_safe(href_list["id"])], usr)
			visible_message("[usr] takes something out of the cabinet.")
			icon_state = "filecabinet"
		else if(href_list["action"] == "close")
			icon_state = "filecabinet"
		show_window(usr)
		icon_state = "filecabinet"

	proc/show_window(var/user)
		if(!src.contents.len)
			boutput(user,"The filing cabinet is empty.")
			icon_state = "filecabinet"
			return
		var/output = "<html><head></head><body>"
		for(var/i = 1, i <= src.contents.len, i++)
			output += "<a href='?src=\ref[src];id=[i];action=retrieve'>[src.contents[i].name]</a><br>"
		output += "</body></html>"
		user << browse(output, "window=filing_cabinet;size=200x400")
