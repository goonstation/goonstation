/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "album"
	item_state = "briefcase"

/obj/item/storage/photo_album/attackby(obj/item/W as obj, mob/user as mob)
	if (!istype(W,/obj/item/photo))
		boutput(user, "<span class='alert'>You can only put photos in a photo album.</span>")
		return

	return ..()

/obj/item/camera_test
	name = "camera"
	icon = 'icons/obj/items/device.dmi'
	desc = "A reusable polaroid camera."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	flags = FPRINT | TABLEPASS | EXTRADELAY | CONDUCT | ONBELT
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	mats = 15
	var/pictures_left = 10 // set to a negative to take INFINITE PICTURES
	var/pictures_max = 30
	var/can_use = 1
	var/takes_voodoo_pics = 0

	New()
		..()
		src.setItemSpecial(null)

	large
		mats = 25
		pictures_left = 30


	examine()
		. = ..()
		. += "There are [src.pictures_left < 0 ? "a whole lot of" : src.pictures_left] pictures left!"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/camera_film))
			var/obj/item/camera_film/C = W

			if (C.pictures <= 0)
				user.show_text("The [C.name] is used up.", "red")
				return
			if (src.pictures_left < 0)
				user.show_text("You go to replace the film cartrige, but it looks like the one already in [src] still has a whole lot of film left! You don't think you'll need to replace it in this lifetime.", "red")
				return
			if (src.pictures_left != 0)
				user.show_text("You have to use up the current film cartridge before you can replace it.", "red")
				return

			src.pictures_left = min(src.pictures_left + C.pictures, src.pictures_max)
			user.u_equip(C)
			qdel(C)
			user.show_text("You replace the film cartridge. The camera can now take [src.pictures_left] pictures.", "blue")

		else if (istype(W, /obj/item/parts/robot_parts/arm))
			var/obj/item/camera_arm_assembly/B = new /obj/item/camera_arm_assembly
			B.set_loc(user)
			user.u_equip(W)
			user.u_equip(src)
			user.put_in_hand_or_drop(B)
			boutput(user, "You add the robot arm to the camera!")
			qdel(W)
			qdel(src)
			return

		else
			..()
		return

/obj/item/camera_test/voodoo //kubius: voodoo cam subtyped for cleanliness
	desc = "There's some sort of faint writing etched into the casing."
	takes_voodoo_pics = 1

	ultimate
		name = "soul-binding camera"
		desc = "No one cam should have all this power."
		takes_voodoo_pics = 2

/obj/item/camera_film
	name = "film cartridge"
	desc = "A replacement film cartridge for an instant camera."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "camera_film"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	w_class = 2.0
	mats = 10
	var/pictures = 10

	large
		name = "film cartridge (large)"
		pictures = 30
		mats = 15

	examine()
		. = ..()
		. += "It is good for [src.pictures] pictures."


/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "photo"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	w_class = 1.0
	var/image/fullImage
	var/icon/fullIcon
	var/list/signed = list()
	var/written = null
	var/image/my_writing = null
	tooltip_flags = REBUILD_DIST

	New(location, var/image/IM, var/icon/IC, var/nname, var/ndesc)
		..(location)
		if (istype(IM))
			fullImage = IM
			IM.transform = matrix(0.6875, 0.625, MATRIX_SCALE)
			IM.pixel_y = 1
			src.UpdateOverlays(IM, "photo")
		if (istype(IC))
			fullIcon = IC
		if (nname)
			src.name = nname
		if (ndesc)
			src.desc = ndesc

/obj/item/photo/get_desc(var/dist)
	if(dist>1)
		return
	else
		if(signed || written)
			. += "<br>"
		if(signed.len > 0)
			for(var/x in signed)
				. += "It is signed: [x]"
				. += "<br>"
		if (written)
			. += "At the bottom is written: [written]"


/obj/item/photo/attackby(obj/item/W as obj, mob/user as mob)
	var/obj/item/pen/P = W
	if(istype(P))
		var/signwrite = input(user, "Sign or Write?", null, null) as null|anything in list("sign","write")
		var/t = input(user, "What do you want to [signwrite]?", null, null) as null|text
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		if(t)
			if(signwrite == "sign")
				var/image/signature = image(icon='icons/misc/photo_writing.dmi',icon_state="[signwrite]")
				signature.color = P.font_color
				signature.pixel_x = -10*(1-rand())
				signature.pixel_y = 15*(1-rand())
				signature.layer = OBJ_LAYER + 0.01
				src.overlays += signature
				signed += "<span style='color: [P.font_color]'>[t]</span>"
				tooltip_rebuild = 1
			else if (signwrite == "write")
				var/image/writing = image(icon='icons/misc/photo_writing.dmi',icon_state="[signwrite]")
				writing.color = P.font_color
				writing.layer = OBJ_LAYER + 0.01

				if(!written)
					written = "<span style='color: [P.font_color]'>[t]</span>"
				else
					src.overlays -= src.my_writing
					written = "[src.written] <span style='color: [P.font_color]'>[t]</span>"
				tooltip_rebuild = 1
				src.my_writing = writing
				src.overlays += writing
		return
	..()

/obj/item/photo/voodoo //kubius: voodoo "doll" photograph
	var/mob/cursed_dude = null //set at photo creation
	var/enchant_power = 13 //how long the photo's magic lasts, negative values make it infinite
	var/enchant_delay = 0 //rolling counter to prevent spam utilization
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE

	//farting is handled in human.dm

	attackby(obj/item/W as obj, mob/user as mob)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && istype(cursed_dude, /mob))
			cursed_dude.attackby(W,user)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		else
			..()
		if(enchant_power == 0)
			boutput(user,"<span class='alert'><b>[src]</b> crumbles away to dust!</span>")
			qdel(src)
		return

	throw_begin(atom/target)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && ismob(cursed_dude))
			cursed_dude.visible_message("<span class='alert'><b>[cursed_dude] is violently thrown by an unseen force!</b></span>")
			cursed_dude.throw_at(get_edge_cheap(src, get_dir(src, target)), 20, 1)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		if(enchant_power == 0)
			src.visible_message("<span class='alert'><b>[src]</b> crumbles away to dust!</span>")
			qdel(src)
		return ..(target)


//////////////////////////////////////////////////////////////////////////////////////////////////
/*/obj/item/camera_test*/
/proc/build_composite_icon(var/atom/C)
	if (!C)
		return
	var/image/composite = image(C.icon, null, C.icon_state, null /*max(OBJ_LAYER, C.layer)*/, C.dir)
	if (!composite)
		return

	composite.overlays = C.overlays
	composite.underlays = C.underlays
	return composite
//////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/camera_test/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/camera_test/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!can_use || ismob(target.loc)) return
	if (src.pictures_left == 0 && user)
		user.show_text("The film cartridge is used up. You have to replace it first.", "red")
		return

	src.create_photo(target)
	playsound(get_turf(src), "sound/items/polaroid[rand(1,2)].ogg", 75, 1, -3)

	if (src.pictures_left > 0)
		src.pictures_left = max(0, src.pictures_left - 1)
		if (user)
			boutput(user, "<span class='notice'>[pictures_left] photos left.</span>")
	can_use = 0
	SPAWN_DBG(5 SECONDS)
		if (src)
			src.can_use = 1

/obj/item/camera_test/proc/create_photo(var/atom/target, var/powerflash = 0)
	if (!target)
		return 0
	var/turf/the_turf = get_turf(target)

	var/image/photo = image(the_turf.icon, null, the_turf.icon_state, OBJ_LAYER, the_turf.dir)
	var/icon/photo_icon = getFlatIcon(the_turf)
	if (!photo)
		return

	if (istype(photo_icon))
		photo_icon.Crop(1,1,32,32) // mehhhh

	//photo.overlays += the_turf

	//turficon.Scale(22,20)

	var/mob_title = null
	var/mob_detail = null
	var/mob/deafnote = null //kubius: voodoo photo mob tracking, takes the first mob in an image
	//POSSIBLe gc woes later, on that is if we ever fuckin get mobs to gc at all hahaha

	var/item_title = null
	var/item_detail = null

	var/mobnumber = 0 // above 3 and it'll stop listing what they're holding and if they're hurt
	var/itemnumber = 0

	for (var/atom/A in the_turf)
		if (A.invisibility || istype(A, /obj/overlay/tile_effect))
			continue
		if (ismob(A))
			var/mob/M = A
			var/image/X = build_composite_icon(A)
			var/icon/Y = A:build_flat_icon()
			//X.Scale(22,20)
			photo.overlays += X
			photo_icon.Blend(Y, ICON_OVERLAY)
			qdel(X)
			qdel(Y)

			if (!mob_title)
				if(src.takes_voodoo_pics)
					deafnote = A
				mob_title = "[M]"
			else
				mob_title += " and [M]"

			if (mobnumber < 4)
				var/holding = null
				if (iscarbon(M))
					var/mob/living/carbon/temp = M
					if (temp.l_hand || temp.r_hand)
						var/they_are = M.gender == "male" ? "He's" : M.gender == "female" ? "She's" : "They're" // I wanna just use he_or_she() but it wouldn't really work
						if (temp.l_hand)
							holding = "[they_are] holding \a [temp.l_hand]"
						if (temp.r_hand)
							if (holding)
								holding += " and \a [temp.r_hand]."
							else
								holding = "[they_are] holding \a [temp.r_hand]."
						else if (holding)
							holding += "."

				var/they_look = M.gender == "male" ? "he looks" : M.gender == "female" ? "she looks" : "they look"
				var/health_info = M.health < 75 ? " - [they_look][M.health < 25 ? " really" : null] hurt" : null
				if (powerflash && M == target && !M.eyes_protected_from_light())
					if (!health_info)
						health_info = " - [they_look] dazed"
					else
						health_info += " and dazed"
				if (!mob_detail)
					mob_detail = "In the photo, you can see [M][M.lying ? " lying on [the_turf]" : null][health_info][holding ? ". [holding]" : "."]"
				else
					mob_detail += " You can also see [M][M.lying ? " lying on [the_turf]" : null][health_info][holding ? ". [holding]" : "."]"
			else
				mob_detail += " You can also see [M]."

		else
			if (itemnumber < 5)
				var/image/X = build_composite_icon(A)
				var/icon/Y = getFlatIcon(A)
				if (X)
					//X.Scale(22,20)
					photo.overlays += X
				if (Y)
					photo_icon.Blend(Y, ICON_OVERLAY)
				itemnumber++
				qdel(X)
				qdel(Y)

				if (!item_title)
					item_title = " \a [A]"
				else
					item_title = " some objects"

				if (!item_detail)
					item_detail = "\a [A]"
				else
					item_detail += " and \a [A]"

	var/finished_title = null
	var/finished_detail = null

	if (!item_title && !mob_title)
		finished_title = "boring photo"
		finished_detail = "This is a pretty boring photo of \a [the_turf]."
	else
		if (mob_title)
			finished_title = "photo of [mob_title][item_title ? " and[item_title]" : null]"
			finished_detail = "[mob_detail][item_detail ? " There's also [item_detail]." : null]"
		else if (item_title)
			finished_title = "photo of[item_title]"
			finished_detail = "You can see [item_detail]."

	var/obj/item/photo/P
	if(src.takes_voodoo_pics)
		P = new/obj/item/photo/voodoo(get_turf(src), photo, photo_icon, finished_title, finished_detail)
		P:cursed_dude = deafnote //kubius: using runtime eval because non-voodoo photos don't have a cursed_dude var
		if(src.takes_voodoo_pics == 2) //unlimited photo uses
			P:enchant_power = -1
	else
		P = new/obj/item/photo(get_turf(src), photo, photo_icon, finished_title, finished_detail)

	return P
