/obj/infared_icon//Mostly copy/paste from paper
	name = "Infared Writing"
	icon = 'icons/obj/infared_writing.dmi'
	icon_state = "norm"
	var/info = "There is nothing here."
	infra_luminosity = 4
	anchored = 1
	invisibility = INVIS_INFRA

/obj/infared_icon/examine(mob/user)
	if(user.see_infrared)
		user << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
		onclose(user, "[src.name]")
	return list()

/obj/infared_icon/attack_ai(var/mob/living/silicon/user as mob)
//I still need a way for the AI to actually make these
	var/select = input("Select an action!", "Icon", null, null) in list("Add","Clear","Remove","View")
	switch(select)
		if("Add")
			var/t = input(user, "What text do you wish to add?", text("[]", src.name), null)  as message
			t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
			t = replacetext(t, "\n", "<BR>")
			t = replacetext(t, "\[b\]", "<B>")
			t = replacetext(t, "\[/b\]", "</B>")
			t = replacetext(t, "\[i\]", "<I>")
			t = replacetext(t, "\[/i\]", "</I>")
			t = replacetext(t, "\[u\]", "<U>")
			t = replacetext(t, "\[/u\]", "</U>")
			t = replacetext(t, "\[sign\]", text("<font face=vivaldi>[]</font>", user.real_name))
			t = text("<font face=calligrapher>[]</font>", t)
			src.info += t

		if("Clear")
			src.info = ""

		if("Remove")
			SPAWN(0.5 SECONDS)
			qdel(src)

		if("Change Icon")
			var/iconchange = input("Select an action!", "Icon", null, null) in list("Standard","Arrow Up","Arrow Left","Arrow Right","Arrow Down")
			switch(iconchange)
				if("Standard")
					icon_state = "norm"
				if("Arrow Up")
					icon_state = "up"
				if("Arrow Down")
					icon_state = "down"
				if("Arrow Left")
					icon_state = "left"
				if("Arrow Right")
					icon_state = "right"

		if("View")
			if(usr.see_infrared)
				user << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", src.name, src.info), text("window=[]", src.name))
				onclose(usr, "[src.name]")
	return

/obj/infared_icon/attackby(obj/item/P, mob/user)

	if (istype(P, /obj/item/pen/infared))

		var/select = input("Select an action!", "Icon", null, null) in list("Add","Clear","Remove")
		switch(select)
			if("Add")
				var/t = input(user, "What text do you wish to add?", text("[]", src.name), null)  as message
				if ((!in_interact_range(src, user) && src.loc != user && !( istype(src.loc, /obj/item/clipboard) ) && src.loc.loc != user && user.equipped() != P))
					return
				t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
				t = replacetext(t, "\n", "<BR>")
				t = replacetext(t, "\[b\]", "<B>")
				t = replacetext(t, "\[/b\]", "</B>")
				t = replacetext(t, "\[i\]", "<I>")
				t = replacetext(t, "\[/i\]", "</I>")
				t = replacetext(t, "\[u\]", "<U>")
				t = replacetext(t, "\[/u\]", "</U>")
				t = replacetext(t, "\[sign\]", text("<font face=vivaldi>[]</font>", user.real_name))
				t = text("<font face=calligrapher>[]</font>", t)
				src.info += t

			if("Clear")
				src.info = ""

			if("Remove")
				SPAWN(0.5 SECONDS)
				qdel(src)
