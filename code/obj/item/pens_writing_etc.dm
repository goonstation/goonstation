/* ---------- WHAT'S HERE ---------- */
/*
 - Pens
 - Markers
 - Crayons
 - Infrared Pens (not "infared", jfc mport)
 - Hand labeler
 - Clipboard
 - Booklet
 - Sticky notes
 - Folder
*/
/* --------------------------------- */

/* =============== PENS =============== */

/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/writing.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "pen"
	flags = FPRINT | ONBELT | TABLEPASS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 60
	var/font = "Georgia" // custom pens
	var/webfont = null // atm this is used to add things to paper's font list. see /obj/item/pen/fancy and /obj/item/paper/attackby()
	var/font_color = "black"
	var/uses_handwriting = 0
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1
	var/in_use = 0
	var/color_name = "black"
	var/clicknoise = 1
	var/spam_flag_sound = 0
	var/spam_flag_message = 0 // one message appears for every five times you click the pen if you're just sitting there jamming on it
	var/spam_timer = 20

	attack_self(mob/user as mob)
		..()
		if (!src.spam_flag_sound && src.clicknoise)
			src.spam_flag_sound = 1
			playsound(get_turf(user), "sound/items/penclick.ogg", 50, 1)
			if (!src.spam_flag_message)
				src.spam_flag_message = 1
				user.visible_message("<span style='color:#888888;font-size:80%'>[user] clicks [src].</span>")
				SPAWN_DBG((src.spam_timer * 5))
					if (src)
						src.spam_flag_message = 0
			SPAWN_DBG(src.spam_timer)
				if (src)
					src.spam_flag_sound = 0

	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || get_dist(T, user) > 1 || isghostdrone(user))
			return
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		src.in_use = 1
		var/t = input(user, "What do you want to write?", null, null) as null|text
		if (!t || get_dist(T, user) > 1)
			src.in_use = 0
			return
		var/obj/decal/cleanable/writing/G = make_cleanable( /obj/decal/cleanable/writing,T)
		G.artist = user.key

		logTheThing("station", user, null, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if (src.font_color)
			G.color = src.font_color
		if (src.material)
			G.setMaterial(src.material)
		/* not used because it doesn't work (yet?)
		if (src.uses_handwriting && user && user.mind && user.mind.handwriting)
			G.font = user.mind.handwriting
			G.webfont = 1
		*/
		else if (src.font)
			G.font = src.font
			//if (src.webfont)
				//G.webfont = 1
		G.words = "[t]"
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

	onMaterialChanged()
		..()
		if (src.color != src.font_color)
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] gently pushes the end of [src] into [his_or_her(user)] nose, then leans forward until [he_or_she(user)] falls to the floor face first!</b></span>")
		user.TakeDamage("head", 175, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		qdel(src)
		return 1

/obj/item/pen/fancy
	name = "fancy pen"
	desc = "A pretty swag pen."
	icon_state = "pen_fancy"
	font_color = "blue"
	font = "Dancing Script, cursive"
	webfont = "Dancing Script"
	uses_handwriting = 1

/obj/item/pen/odd
	name = "odd pen"
	desc = "There's something strange about this pen."
	font = "Wingdings"

/obj/item/pen/red // we didn't have one of these already??
	name = "red pen"
	desc = "The horrible, the unspeakable, the dreaded <span class='alert'><b>RED PEN!!</b></span>"
	color = "red"
	font_color = "red"

/obj/item/pen/pencil // god this is a dumb path
	name = "pencil"
	desc = "The core is graphite, not lead, don't worry!"
	icon_state = "pencil-y"
	font_color = "#808080"
	font = "Dancing Script, cursive"
	webfont = "Dancing Script"
	uses_handwriting = 1
	clicknoise = 0

	New()
		..()
		if (prob(25))
			src.icon_state = pick("pencil-b", "pencil-g")

/* =============== MARKERS =============== */

/obj/item/pen/marker
	name = "felt marker"
	desc = "Try not to sniff it too much. Weirdo."
	icon_state = "marker"
	color = "#333333"
	font = "Permanent Marker, cursive"
	webfont = "Permanent Marker"
	clicknoise = 0

	red
		name = "red marker"
		color = "#FF0000"
		font_color = "#FF0000"

	orange
		name = "orange marker"
		color = "#FFAA00"
		font_color = "#FFAA00"

	yellow
		name = "yellow marker"
		color = "#FFFF00"
		font_color = "#FFFF00"

	green
		name = "green marker"
		color = "#00FF00"
		font_color = "#00FF00"

	aqua
		name = "aqua marker"
		color = "#00FFFF"
		font_color = "#00FFFF"

	blue
		name = "blue marker"
		color = "#0000FF"
		font_color = "#0000FF"

	purple
		name = "purple marker"
		color = "#AA00FF"
		font_color = "#AA00FF"

	pink
		name = "pink marker"
		color = "#FF00FF"
		font_color = "#FF00FF"

	random
		New()
			..()
			src.color = random_color()
			src.font_color = src.color
			src.name = "[hex2color_name(src.color)] marker"

/* =============== CRAYONS =============== */

/obj/item/pen/crayon
	name = "crayon"
	desc = "Don't shove it up your nose, no matter how good of an idea that may seem to you.  You might not get it back."
	icon_state = "crayon"
	color = "#333333"
	font = "Comic Sans MS"
	clicknoise = 0

	white
		name = "white crayon"
		color = "#FFFFFF"
		font_color = "#FFFFFF"
		color_name = "white"

	red
		name = "red crayon"
		color = "#FF0000"
		font_color = "#FF0000"
		color_name = "red"

	orange
		name = "orange crayon"
		color = "#FFAA00"
		font_color = "#FFAA00"
		color_name = "orange"

	yellow
		name = "yellow crayon"
		color = "#FFFF00"
		font_color = "#FFFF00"
		color_name = "yellow"

	green
		name = "green crayon"
		color = "#00FF00"
		font_color = "#00FF00"
		color_name = "green"

	aqua
		name = "aqua crayon"
		color = "#00FFFF"
		font_color = "#00FFFF"
		color_name = "aqua"

	blue
		name = "blue crayon"
		color = "#0000FF"
		font_color = "#0000FF"
		color_name = "blue"

	purple
		name = "purple crayon"
		color = "#AA00FF"
		font_color = "#AA00FF"
		color_name = "purple"

	pink
		name = "pink crayon"
		color = "#FF00FF"
		font_color = "#FF00FF"
		color_name = "pink"

	random
		New()
			..()
			src.color = random_color()
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)
			src.name = "[src.color_name] crayon"

		choose
			desc = "Don't shove it up your nose, no matter how good of an idea that may seem to you.  You might not get it back. Spin it, go ahead, you know you want to."

			on_spin_emote(var/mob/living/carbon/human/user as mob)
				..(user)
				src.color = random_color()
				src.font_color = src.color
				src.color_name = hex2color_name(src.color)
				src.name = "[src.color_name] crayon"
				user.visible_message("<span class='notice'><b>\"Something\" special happens to [src]!</b></span>")
				JOB_XP(user, "Clown", 1)




	rainbow
		name = "strange crayon"
		color = "#FFFFFF"
		New()
			..()
			if (!ticker) // trying to avoid pre-game-start runtime bullshit
				SPAWN_DBG(3 SECONDS)
					src.font_color = random_saturated_hex_color(1)
					src.color_name = hex2color_name(src.font_color)
			else
				src.font_color = random_saturated_hex_color(1)
				src.color_name = hex2color_name(src.font_color)

		write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
			if (!T || !user || src.in_use || get_dist(T, user) > 1)
				return
			src.font_color = random_saturated_hex_color(1)
			src.color_name = hex2color_name(src.font_color)
			..()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] jams [src] up [his_or_her(user)] nose!</b></span>")
		SPAWN_DBG(0.5 SECONDS) // so we get a moment to think before we die
			user.take_brain_damage(120)
		user.u_equip(src)
		src.set_loc(user) // SHOULD be redundant but you never know.
		health_update_queue |= user
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || get_dist(T, user) > 1)
			return
		src.in_use = 1
		var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
		var/list/c_symbol = list("Dollar", "Euro", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentacle")

		var/t = input(user, "What do you want to write?", null, null) as null|anything in ((isghostdrone(user) || !user.literate) ? c_symbol : (c_default + c_symbol))

		if (!t || get_dist(T, user) > 1)
			src.in_use = 0
			return
		var/obj/decal/cleanable/writing/G = make_cleanable(/obj/decal/cleanable/writing,T)
		G.artist = user.key

		logTheThing("station", user, null, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")
		G.icon_state = "c[t]"
		if (src.font_color && src.color_name)
			G.color = src.font_color
			G.color_name = src.color_name
			G.real_name = t
			G.UpdateName()
		if (src.material)
			G.setMaterial(src.material)
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

/* =============== CHALK (By Adhara) =============== */

/obj/item/pen/crayon/chalk
	name = "chalk"
	desc = "A stick of rock and dye that reminds you of your childhood. Don't get too carried away!"
	icon_state = "chalk-9"
	color = "#333333"
	font = "Comic Sans MS"
	var/chalk_health = 10 //10 uses before it snaps

	random
		New()
			..()
			src.color = "#[num2hex(rand(0, 255),2)][num2hex(rand(0, 255),2)][num2hex(rand(0, 255),2)]"
			src.font_color = src.color
			src.color_name = hex2color_name(src.color)
			src.name = "[src.color_name] chalk"

	proc/assign_color(var/color)
		src.color = color
		src.font_color = src.color
		src.color_name = hex2color_name(color)
		src.name = "[src.color_name] chalk"

	proc/chalk_break(var/mob/user as mob)
		if (src.chalk_health <= 1)
			user.visible_message("<span class='alert'><b>\The [src] snaps into pieces so small that you can't use them to draw anymore!</b></span>")
			qdel(src)
			return
		if (src.chalk_health % 2)
			src.chalk_health--
		src.chalk_health /= 2
		var/obj/item/pen/crayon/chalk/C = new(get_turf(src))
		C.chalk_health = src.chalk_health
		C.assign_color(src.color)
		C.adjust_icon()
		src.adjust_icon()
		user.visible_message("<span class='alert'><b>\The [src] snaps in half! [pick("Fuck!", "Damn!", "Shit!", "Damnit!", "Fucking...", "Argh!", "Arse!", "Piss!")]")

	proc/adjust_icon()
		if (src.chalk_health > 10) //shouldnt happen but it could
			src.icon_state = "chalk-9"
			return
		else if (src.chalk_health < 0) //shouldnt happen but it could
			src.icon_state = "chalk-0"
		else
			src.icon_state = "chalk-[src.chalk_health]"

	write_on_turf(var/turf/T as turf, var/mob/user as mob)
		..()
		if (src.chalk_health <= 1)
			src.chalk_break(user)
			return
		if (prob(15))
			src.chalk_break(user)
			return
		src.chalk_health--
		src.adjust_icon()

	attack(mob/M as mob, mob/user as mob, def_zone)
		if (user == M && ishuman(M) && istype(M:mutantrace, /datum/mutantrace/lizard))
			user.visible_message("[user] shoves \the [src] into [his_or_her(user)] mouth and takes a bite out of it! [pick("That's sick!", "That's metal!", "That's punk as fuck!", "That's hot!")]")
			playsound(user.loc, "sound/misc/chalkeat_[rand(1,2)].ogg", 60, 1)
			src.chalk_health -= rand(2,5)
			if (src.chalk_health <= 1)
				src.chalk_break(user)
				return
			src.adjust_icon()
		else
			boutput(user, "You couldn't possibly eat \the [src], that's such a cold blooded thing to do!") //heh

	suicide(var/mob/user as mob)
		user.visible_message("<span class='alert'><b>[user] crushes \the [src] into a powder and then [he_or_she(user)] snorts it all! That can't be good for [his_or_her(user)] lungs!</b></span>")
		SPAWN_DBG(5 DECI SECONDS) // so we get a moment to think before we die
			user.take_oxygen_deprivation(175)
		user.u_equip(src)
		src.set_loc(user) //yes i did this dont ask why i cant literally think of anything better to do
		SPAWN_DBG(10 SECONDS)
			if (user)
				user.suiciding = 0
		qdel(src)
		return 1

/* =============== INFRARED PENS =============== */

/obj/item/pen/infrared
	desc = "A pen that can write in infrared."
	name = "infrared pen"
	color = "#FFEE44" // color var owns
	font_color = "#D20040"

	write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use || get_dist(T, user) > 1)
			return
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		src.in_use = 1
		var/t = input(user, "What do you want to write?", null, null) as null|text
		if (!t || get_dist(T, user) > 1)
			src.in_use = 0
			return
		var/obj/decal/cleanable/writing/infrared/G = make_cleanable(/obj/decal/cleanable/writing/infrared,T)
		G.artist = user.key

		logTheThing("station", user, null, "writes on [T] with [src][src.material ? " (material: [src.material.name])" : null] [log_loc(T)]: [t]")
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if (src.font_color)
			G.color = src.font_color
		if (src.material)
			G.setMaterial(src.material)
		/*if (src.uses_handwriting && user && user.mind && user.mind.handwriting)
			G.font = user.mind.handwriting
			G.webfont = 1
		*/
		else if (src.font)
			G.font = src.font
			//if (src.webfont)
				//G.webfont = 1
		G.words = "[t]"
		if (islist(params) && params["icon-y"] && params["icon-x"])
			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

/* =============== HAND LABELERS =============== */

/obj/item/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/writing.dmi'
	icon_state = "labeler"
	item_state = "labeler"
	desc = "Make things seem more important than they really are with the hand labeler!<br/>Can also name your fancy new area by naming the fancy new APC you created for it."
	var/label = null
	var/labels_left = 10
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	rand_pos = 1

	get_desc()
		if (!src.label || !length(src.label))
			. += "<br>It doesn't have a label set."
		else
			. += "<br>Its label is set to \"[src.label]\"."

	attack(mob/M, mob/user as mob)
		/* lol vvv
		if (!ismob(M)) // do this via afterattack()
			return
		*/
		if (!src.labels_left)
			boutput(user, "<span class='alert'>No labels left.</span>")
			return
		if (!src.label || !length(src.label))
			RemoveLabel(M, user)
			return

		src.Label(M, user)

	afterattack(atom/A, mob/user as mob)
		if (ismob(A)) // do this via attack()
			return
		if (!src.labels_left)
			boutput(user, "<span class='alert'>No labels left.</span>")
			return
		if (!src.label || !length(src.label))
			RemoveLabel(A, user)
			return

		src.Label(A, user)

	attack_self(mob/user as mob)
		if(!user.literate)
			boutput(user, "<span class='alert'>You don't know how to write.</span>")
			return
		tooltip_rebuild = 1
		var/str = copytext(html_encode(input(usr,"Label text?","Set label","") as null|text), 1, 32)
		if(url_regex && url_regex.Find(str))
			str = null
		if (!str || !length(str))
			boutput(usr, "<span class='notice'>Label text cleared.</span>")
			src.label = null
			return
		if (length(str) > 30)
			boutput(usr, "<span class='alert'>Text too long.</span>")
			return
		src.label = "[str]"
		boutput(usr, "<span class='notice'>You set the text to '[str]'.</span>")
		logTheThing("combat", usr, null, "sets a hand labeler label to \"[str]\".")

	proc/RemoveLabel(var/atom/A, var/mob/user, var/no_message = 0)
		if(!islist(A.name_suffixes))
			//Name_suffixes wasn't a list, but it is now.
			A.name_suffixes = list()
			return	//No need to clear stuff if it wasn't a list in the first place

		if (A.name_suffixes.len)
			A.remove_suffixes(1)
			A.UpdateName()
			user.visible_message("<span class='notice'><b>[user]</b> removes the label from [A].</span>",\
			"<span class='notice'>You remove the label from [A].</span>")
			return

	proc/Label(var/atom/A, var/mob/user, var/no_message = 0)
		var/obj/machinery/power/apc/apc = A
		if(istype(A,/obj/machinery/power/apc) && apc.area.type == /area/built_zone)
			if(alert("Would you like to name this area, or just label the APC?", "Area Naming", "Label the APC", "Name the Area") == "Name the Area")
				var/area/built_zone/ba = apc.area
				ba.SetName(src.label)
				return

		if (user && !no_message)
			user.visible_message("<span class='notice'><b>[user]</b> labels [A] with \"[src.label]\".</span>",\
			"<span class='notice'>You label [A] with \"[src.label]\".</span>")
		if (istype(A, /obj/item/paper))
			A.name = "'[src.label]'"
		else
			if(!islist(A.name_suffixes))
				//Name_suffixes wasn't a list, but it is now.
				A.name_suffixes = list()
			A.name_suffix("([src.label])")
			A.UpdateName()
		if (user && !no_message)
			logTheThing("combat", user, A, "labels [constructTarget(A,"combat")] with \"[src.label]\"")
		else if(!no_message)
			logTheThing("combat", A, null, "has a label applied to them, \"[src.label]\"")
		A.add_fingerprint(user)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] labels [him_or_her(user)]self \"DEAD\"!</b></span>")
		src.label = "(DEAD)"
		Label(user,user,1)

		user.TakeDamage("chest", 300, 0) //they have to die fast or it'd make even less sense
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/* =============== CLIPBOARDS =============== */

/obj/item/clipboard
	name = "clipboard"
	icon = 'icons/obj/writing.dmi'
	icon_state = "clipboard00"
	var/obj/item/pen/pen = null
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "clipboard0"
	throwforce = 1
	w_class = 3.0
	throw_speed = 3
	throw_range = 10
	desc = "You can put paper on it. Ah, technology!"
	stamina_damage = 10
	stamina_cost = 1
	stamina_crit_chance = 5

	New()
		..()
		BLOCK_BOOK

	attack_self(mob/user as mob)
		var/dat = "<B>Clipboard</B><BR>"
		if (src.pen)
			dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
		for(var/obj/item/paper/P in src)
			dat += "<A href='?src=\ref[src];read=\ref[P]'>[P.name]</A> <A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];title=\ref[P]'>Title</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A><BR>"

		for(var/obj/item/photo/P in src) //Todo: make it actually show the photo.  Currently, using [bicon()] just makes an egg image pop up (??)
			dat += "<A href='?src=\ref[src];remove=\ref[P]'>[P.name]</A><br>"

		user.Browse(dat, "window=clipboard")
		onclose(user, "clipboard")
		return

	Topic(href, href_list)
		..()
		if ((usr.stat || usr.restrained()))
			return

		if (!usr.contents.Find(src))
			return

		src.add_dialog(usr)
		if (href_list["pen"])
			if (src.pen)
				usr.put_in_hand_or_drop(src.pen)
				src.pen = null
				src.update()

		else if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if (P && P.loc == src)
				usr.put_in_hand_or_drop(P)
				src.update()

		else if (href_list["read"])
			var/obj/item/paper/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( ishuman(usr) ))
					usr.Browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, stars(P.info)), text("window=[]", P.name))
					onclose(usr, "[P.name]")
				else
					usr.Browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.info), text("window=[]", P.name))
					onclose(usr, "[P.name]")

		else//Stuff that involves writing from here on down
			if(!usr.literate)
				boutput(usr, "<span class='alert'>You don't know how to write.</span>")
				return
			var/obj/item/pen/available_pen = null
			if (istype(usr.r_hand, /obj/item/pen))
				available_pen = usr.r_hand
			else if (istype(usr.l_hand, /obj/item/pen))
				available_pen = usr.l_hand
			else if (istype(src.pen, /obj/item/pen))
				available_pen = src.pen
			else
				boutput(usr, "<span class='alert'>You need a pen for that.</span>")
				return

			if (href_list["write"])
				var/obj/item/P = locate(href_list["write"])
				if ((P && P.loc == src))
					P.attackby(available_pen, usr)

			else if (href_list["title"])
				if (istype(available_pen, /obj/item/pen/odd))
					boutput(usr, "<span class='alert'>Try as you might, you fail to write anything sensible.</span>")
					src.add_fingerprint(usr)
					return
				var/obj/item/P = locate(href_list["title"])
				if (P && P.loc == src)
					var/str = copytext(html_encode(input(usr,"What do you want to title this?","Title document","") as null|text), 1, 32)
					if (str == null || length(str) == 0)
						return
					if (length(str) > 30)
						boutput(usr, "<span class='alert'>A title that long will never catch on!</span>") //We're actually checking because titles above a certain length get clipped, but where's the fun in that
						return
					if(url_regex && url_regex.Find(str))
						return
					P.name = str

		src.add_fingerprint(usr)
		src.updateSelfDialog()
		return

	attack_hand(mob/user as mob)
		if (!user.equipped() && (user.l_hand == src || user.r_hand == src))
			var/obj/item/paper/P = locate() in src
			if (P)
				user.put_in_hand_or_drop(P)
				src.update()
			src.add_fingerprint(user)
		else
			/*
			if (user.contents.Find(src))
				SPAWN_DBG( 0 )
					src.attack_self(user)
					return
			else
			*/
			return ..()
		return

	attackby(obj/item/P as obj, mob/user as mob)

		if (istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
			if (src.contents.len < 15)
				user.drop_item()
				P.set_loc(src)
			else
				boutput(user, "<span class='notice'>Not enough space!!!</span>")
		else
			if (istype(P, /obj/item/pen))
				if (!src.pen)
					user.drop_item()
					P.set_loc(src)
					src.pen = P
			else
				return
		src.update()
		user.update_inhands()
		SPAWN_DBG(0)
			attack_self(user)
			return
		return

	proc/update()
		src.icon_state = "clipboard[(locate(/obj/item/paper) in src) ? "1" : "0"][src.pen ? "1" : "0"]"
		src.item_state = "clipboard[(locate(/obj/item/paper) in src) ? "1" : "0"]"
		return

/obj/item/clipboard/with_pen
	New()
		..()
		src.pen = new /obj/item/pen(src)
		return

/* =============== FOLDERS (wip) =============== */

/obj/item/folder //if any of these are bad numbers just change them im a bad idiot
	name = "folder"
	desc = "A folder for holding papers!"
	icon = 'icons/obj/writing.dmi'
	icon_state = "folder" //futureproofed icons baby
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "folder"
	w_class = 2.0
	throwforce = 0
	w_class = 3.0
	throw_speed = 3
	throw_range = 10
	tooltip_flags = REBUILD_DIST

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/paper))
			if (src.contents.len < 10)
				boutput(user, "You cram the paper into the folder.")
				user.drop_item()
				W.set_loc(src)
				src.amount++
				tooltip_rebuild = 1

	attack_self(var/mob/user as mob)
		show_window(user)

	Topic(var/href, var/href_list)
		if (get_dist(src, usr) > 1 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (usr.hasStatus("paralysis", "stunned", "weakened", "resting"))
			return
		..()

		if(href_list["action"] == "retrieve")
			usr.put_in_hand_or_drop(src.contents[text2num(href_list["id"])], usr)
			tooltip_rebuild = 1
			usr.visible_message("[usr] takes a piece of paper out of the folder.")
		show_window(usr) // to refresh the window

	get_desc(dist)
		var/fullness = ""
		if (dist > 4)
			fullness = "You're too far away to see how many papers are in the folder."
		else if (src.contents.len)
			fullness = "It looks like there's about [src.contents.len] papers in the folder."
		else
			fullness = "It looks like the folder's empty!"
		return fullness

	proc/show_window(var/user)
		var/output = "<html><head><title>Folder</title></head><body><br>"
		for(var/i = 1, i <= src.contents.len, i++)
			output += "<a href='?src=\ref[src];id=[i];action=retrieve'>[src.contents[i].name]</a><br>"
		output += "</body></html>"
		user << browse(output, "window=folder;size=400x600")

/* =============== BOOKLETS =============== */

/obj/item/paper_booklet
	name = "booklet"
	desc = "A stack of papers stapled together in a sequence intended for reading in."
	icon = 'icons/obj/writing.dmi'
	icon_state = "booklet-thin"
	uses_multiple_icon_states = 1
	//cogwerks - burning vars
	burn_point = 220
	burn_output = 900
	burn_possible = 1
	health = 10
	w_class = 1.0

	var/offset = 1

	var/list/obj/item/paper/pages = new/list()

	New()
		..()
		if (!offset)
			return
		else
			src.pixel_y = rand(-8, 8)
			src.pixel_x = rand(-9, 9)

	proc/give_title(var/mob/user)
		var/n_name = input(user, "What would you like to label the booklet?", "Booklet Labelling", null) as null|text //stolen from paper.dm
		if (!n_name)
			return
		n_name = copytext(html_encode(n_name), 1, 32)
		if (((src.loc == user || (src.loc && src.loc.loc == user)) && isalive(user)))
			src.name = "booklet[n_name ? "- '[n_name]'" : null]"
			logTheThing("say", user, null, "labels a paper booklet: [n_name]")
		src.add_fingerprint(user)
		return

	proc/display_booklet_contents(var/mob/user as mob, var/page = 1)
		var/obj/item/paper/cur_page = pages[page]
		var/next_page = ""
		var/prev_page = "     "
		set src in view()
		set category = "Local"

		if(!user.literate)
			. = html_encode(illiterateGarbleText(cur_page.info)) // deny them ANY useful information
		else
			. = cur_page.info

			if (cur_page.form_startpoints && cur_page.form_endpoints)
				for (var/x = cur_page.form_startpoints.len, x > 0, x--)
					. = copytext(., 1, cur_page.form_startpoints[cur_page.form_startpoints[x]]) + "<a href='byond://?src=\ref[cur_page];form=[cur_page.form_startpoints[x]]'>" + copytext(., cur_page.form_startpoints[cur_page.form_startpoints[x]], cur_page.form_endpoints[cur_page.form_endpoints[x]]) + "</a>" + copytext(., cur_page.form_endpoints[cur_page.form_endpoints[x]])

		var/font_junk = ""
		for (var/i in cur_page.fonts)
			font_junk += "<link href='http://fonts.googleapis.com/css?family=[i]' rel='stylesheet' type='text/css'>"

		if (page > 1)
			prev_page = "<a href='byond://?src=\ref[src];action=prev_page;page=[page]'>Back</a> "
		if (page < pages.len)
			next_page = "<a href='byond://?src=\ref[src];action=next_page;page=[page]'>Next</a>"

		user.Browse("<HTML><HEAD><TITLE>[src.name] - [cur_page.name]</TITLE>[font_junk]</HEAD><BODY>Page [page] of [pages.len]<BR><a href='byond://?src=\ref[src];action=first_page'>First Page</a> <a href='byond://?src=\ref[src];action=title_book'>Title Book</a> <a href='byond://?src=\ref[src];action=last_page'>Last Page</a><BR>[prev_page]<a href='byond://?src=\ref[src];action=write;page=[page]'>Write</a> <a href='byond://?src=\ref[src];action=title_page;page=[page]'>Title</a> [next_page]<HR><TT>[.]</TT></BODY></HTML>", "window=[src.name]")

		onclose(usr, "[src.name]")
		return null

	attack_self(var/mob/user)
		..()
		src.display_booklet_contents(user,1)

	examine(mob/user)
		. = ..()
		src.display_booklet_contents(user, 1)

	Topic(href, href_list)
		..()

		if ((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
			return

		var/page_num = text2num(href_list["page"])
		var/obj/item/paper/cur_page = pages[page_num]

		switch (href_list["action"])
			if ("next_page")
				src.display_booklet_contents(usr,page_num + 1)
			if ("prev_page")
				src.display_booklet_contents(usr,page_num - 1)
			if ("write")
				if (istype(usr.equipped(), /obj/item/pen))
					cur_page.attackby(usr.equipped(),usr)
					src.display_booklet_contents(usr,page_num)
			if ("title_page")
				if (cur_page.loc.loc == usr)
					cur_page.attack_self(usr)
			if ("title_book")
				src.give_title(usr)
			if ("first_page")
				src.display_booklet_contents(usr,1)
			if ("last_page")
				src.display_booklet_contents(usr,pages.len)

	attackby(var/obj/item/P as obj, mob/user as mob)
		if (istype(P, /obj/item/paper))
			var/obj/item/staple_gun/S = user.find_type_in_hand(/obj/item/staple_gun)
			if (S && S.ammo)
				user.drop_item()
				src.pages += P
				P.set_loc(src)
				S.ammo--
				if (pages.len >= 10 && !icon_state == "booklet-thick")
					src.icon_state = "booklet-thick"
				src.visible_message("[user] staples [P] at the back of [src].")
				playsound(user,'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			else
				boutput(usr, "<span class='alert'>You need a loaded stapler in hand to add this paper to the booklet.</span>")
		else
			..()
		return

/* =============== STICKY NOTES =============== */

/obj/item/postit_stack
	name = "stack of crappy old sticky notes"
	desc = "A little stack of notepaper that you can stick to things. These are the old ones that suck a lot."
	icon = 'icons/obj/writing.dmi'
	icon_state = "postit_stack"
	force = 1
	throwforce = 1
	w_class = 1
	amount = 10
	burn_point = 220
	burn_output = 200
	burn_possible = 1
	health = 2

	// @TODO
	// HOLY SHIT REMOVE THIS THESE OLD POST ITS ARE GONE or something idk fuck
	New()
		new /obj/item/item_box/postit(get_turf(src))

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		if (!A)
			return
		if (isarea(A))
			return
		if (src.amount < 0)
			qdel(src)
			return
		var/turf/T = get_turf(A)
		var/obj/decal/cleanable/writing/postit/P = make_cleanable(/obj/decal/cleanable/writing/postit ,T)
		if (params && islist(params) && params["icon-y"] && params["icon-x"])
			// oh boy i can't wait to see people make huge post-it note trains across the station somehow!
			P.pixel_x = text2num(params["icon-x"]) - 16 //round(A.bound_width/2)
			P.pixel_y = text2num(params["icon-y"]) - 16 //round(A.bound_height/2)

		P.layer = A.layer + 1 //Do this instead so the stickers don't show over bushes and stuff.
		P.appearance_flags = RESET_COLOR

		user.visible_message("<b>[user]</b> sticks a sticky note to [T].",\
		"You stick a sticky note to [T].")
		var/obj/item/pen/pen = user.find_type_in_hand(/obj/item/pen)
		if (pen)
			P.attackby(pen, user)
		src.amount --
		if (src.amount < 0)
			qdel(src)
			return
