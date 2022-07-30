// FINGERPRINT HOLDER

// All of this was phased out with the forensic scanner overhaul. Was useless anyway (Convair880).

/obj/item/fcardholder
	name = "Finger Print Case"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "fcardholder0"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "clipboard0"
	stamina_damage = 2
	stamina_cost = 2
	stamina_crit_chance = 1

/obj/item/fcardholder/attack_self(mob/user as mob)
	var/dat = "<B>Clipboard</B><BR>"
	for(var/obj/item/f_card/P in src)
		dat += text("<A href='?src=\ref[];read=\ref[]'>[]</A> <A href='?src=\ref[];remove=\ref[]'>Remove</A><BR>", src, P, P.name, src, P)
	user << browse(dat, "window=fcardholder")
	onclose(user, "fcardholder")
	return

/obj/item/fcardholder/Topic(href, href_list)
	..()
	if ((usr.stat || usr.restrained()))
		return
	if (usr.contents.Find(src))
		src.add_dialog(usr)
		if (href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if (P && P.loc == src)
				usr.put_in_hand_or_drop(P)
				src.add_fingerprint(usr)
			src.update()
		if (href_list["read"])
			var/obj/item/f_card/P = locate(href_list["read"])
			if ((P && P.loc == src))
				if (!( ishuman(usr) ))
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
					onclose(usr, "[P.name]")
				else
					usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", P.name, P.display()), text("window=[]", P.name))
					onclose(usr, "[P.name]")
			src.add_fingerprint(usr)
		if (ismob(src.loc))
			var/mob/M = src.loc
			if (M.machine == src)
				SPAWN( 0 )
					src.attack_self(M)
					return
	return

/obj/item/fcardholder/attack_hand(mob/user)
	if (user.contents.Find(src))
		SPAWN( 0 )
			src.attack_self(user)
			return
		src.add_fingerprint(user)
	else
		return ..()
	return

/obj/item/fcardholder/attackby(obj/item/P, mob/user)
	if (istype(P, /obj/item/f_card))
		if (src.contents.len < 30)
			user.drop_item()
			P.set_loc(src)
			add_fingerprint(user)
			src.add_fingerprint(user)
		else
			boutput(user, "<span class='notice'>Not enough space!!!</span>")
	else
		if (istype(P, /obj/item/pen))
			var/t = input(user, "Holder Label:", text("[]", src.name), null)  as text
			if (user.equipped() != P)
				return
			if ((!in_interact_range(src, user) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPCase- '[]'", t)
			else
				src.name = "Finger Print Case"
		else
			return
	src.update()
	SPAWN( 0 )
		attack_self(user)
		return
	return

/obj/item/fcardholder/proc/update()
	var/i = 0
	for(var/obj/item/f_card/F in src)
		i = 1
		break
	src.icon_state = text("fcardholder[]", (i ? "1" : "0"))
	return





// FINGERPRINT CARD

/obj/item/f_card
	name = "Finger Print Card"
	icon = 'icons/obj/items/card.dmi'
	icon_state = "fingerprint0"
	amount = 10
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 3
	throw_range = 5
	max_stack = 10


/obj/item/f_card/examine()
	. = ..()
	. += "<span class='notice'>There are [src.amount] on the stack!</span>"
	. += src.display()

/obj/item/f_card/proc/display()

	if (src.fingerprints)
		var/dat = "<B>Fingerprints on Card</B><HR>"
		var/L = params2list(src.fingerprints)
		for(var/i in L)
			dat += text("[]<BR>", i)
			//Foreach goto(41)
		return dat
	else
		return "<B>There are no fingerprints on this card.</B>"
	return

/obj/item/f_card/attack_hand(mob/user)

	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/f_card/F = new /obj/item/f_card( user )
		F.amount = 1
		src.amount--
		user.put_in_hand_or_drop(F)
		if (ishuman(user) && !user:gloves)
			F.add_fingerprint(user)
		if (src.amount < 1)
			qdel(src)
			return
	else
		..()
	return

/obj/item/f_card/attackby(obj/item/W, mob/user)

	if (istype(W, /obj/item/f_card))
		if ((src.fingerprints || W.fingerprints))
			return
		if (src.amount == 10)
			return
		if (W:amount + src.amount > 10)
			src.amount = 10
			W:amount = W:amount + src.amount - 10
		else
			src.amount += W:amount
			//W = null
			qdel(W)
		src.add_fingerprint(user)
		if (W)
			W.add_fingerprint(user)
	else
		if (istype(W, /obj/item/pen))
			var/t = input(user, "Card Label:", text("[]", src.name), null)  as text
			if (user.equipped() != W)
				return
			if ((!in_interact_range(src, user) && src.loc != user))
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = text("FPrintC- '[]'", t)
			else
				src.name = "Finger Print Card"
			W.add_fingerprint(user)
			src.add_fingerprint(user)
	return

/obj/item/f_card/add_fingerprint()

	..()
	if (!issilicon(usr))
		if (src.fingerprints)
			if (src.amount > 1)
				var/obj/item/f_card/F = new /obj/item/f_card( (ismob(src.loc) ? src.loc.loc : src.loc) )
				F.amount = --src.amount
				src.amount = 1
			src.icon_state = "fingerprint1"
	return
