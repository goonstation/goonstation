/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "album"
	item_state = "briefcase"

/obj/item/storage/photo_album/attackby(obj/item/W, mob/user)
	if (!istype(W,/obj/item/photo))
		boutput(user, SPAN_ALERT("You can only put photos in a photo album."))
		return

	return ..()

TYPEINFO(/obj/item/camera)
	mats = 15

TYPEINFO(/obj/item/camera/large)
	mats = 25

/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items/device.dmi'
	desc = "The Asteroid 120, a popular reusable instant-print camera."
	icon_state = "camera"
	item_state = "electropack"
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | EXTRADELAY | CONDUCT
	c_flags = ONBELT
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	var/pictures_left = 12 // set to a negative to take INFINITE PICTURES
	var/pictures_max = 30
	var/can_use = 1
	var/takes_voodoo_pics = 0
	var/steals_souls = FALSE

	New()
		..()
		src.setItemSpecial(null)

	large
		name = "camera deluxe"
		desc = "The Asteroid 220 Pro, a surveillance and forensics camera with a superzoom lens and self-printing instant film."
		icon_state = "camera_zoom"
		rarity = 3
		pictures_left = 24

		New()
			..()
			AddComponent(/datum/component/holdertargeting/sniper_scope, 8, 0, /datum/overlayComposition/telephoto, 'sound/machines/pod_switch.ogg')


	examine()
		. = ..()
		. += "There are [src.pictures_left < 0 ? "a whole lot of" : src.pictures_left] pictures left!"

	attackby(obj/item/W, mob/user)
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

/obj/item/camera/voodoo //kubius: voodoo cam subtyped for cleanliness
	desc = "There's some sort of faint writing etched into the casing."
	takes_voodoo_pics = 1

	ultimate
		name = "soul-binding camera"
		desc = "No one cam should have all this power."
		takes_voodoo_pics = 2

/obj/item/camera/spy
	inventory_counter_enabled = 1
	var/flash_mode = 0
	var/wait_cycle = 0

	attack_self(mob/user)
		if (user.find_in_hand(src) && user.mind && user.mind.special_role == ROLE_SPY_THIEF) // No metagming this
			if (!src.flash_mode)
				user.show_text("You use the secret switch to set the camera to flash mode.", "blue")
				playsound(user, 'sound/items/pickup_defib.ogg', 100, TRUE)
				src.icon_state = "camera_flash"
			else
				user.show_text("You use the secret switch to set the camera to take photos.", "blue")
				playsound(user, 'sound/items/putback_defib.ogg', 100, TRUE)
				src.icon_state = "camera"
			src.flash_mode = !src.flash_mode
			src.UpdateIcon()

	New()
		var/cell = new/obj/item/ammo/power_cell/self_charging/medium{recharge_rate = 5}
		AddComponent(/datum/component/cell_holder,cell, FALSE, 200, FALSE)
		RegisterSignal(src, COMSIG_UPDATE_ICON, /atom/proc/UpdateIcon)
		..()
		UpdateIcon()

	update_icon()
		if (!src.flash_mode)
			inventory_counter.update_text("")
		else
			var/list/ret = list()
			if (SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
				inventory_counter.update_percent(ret["charge"], ret["max_charge"])
			else
				inventory_counter.update_text("-")
		return 0

	disposing()
		processing_items -= src
		..()

/obj/item/camera/spy/attack(atom/target, mob/user, flag)
	if (!ismob(target))
		return
	if (src.flash_mode)
		// Use cell charge
		if (!(SEND_SIGNAL(src, COMSIG_CELL_CHECK_CHARGE, 25) & CELL_SUFFICIENT_CHARGE))
			user.show_text("[src] doesn't have enough battery power!", "red")
			return 0
		var/turf/T = get_turf(target.loc)
		if (T.is_sanctuary())
			user.visible_message(SPAN_ALERT("<b>[user]</b> tries to use [src], cannot quite comprehend the forces at play!"))
			return
		src.UpdateIcon()
		// Generic flash
		var/mob/M = target
		SEND_SIGNAL(src, COMSIG_CELL_USE, 25)
		var/blind_success = M.apply_flash(30, 8, 0, 0, 0, rand(0, 1), 0, 0, 100, 70, disorient_time = 30)
		playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
		FLICK("camera_flash-anim", src)
		// Log entry.
		var/blind_msg_target = "!"
		var/blind_msg_others = "!"
		if (!blind_success)
			blind_msg_target = " but your eyes are protected!"
			blind_msg_others = " but [his_or_her(M)] eyes are protected!"
		M.visible_message(SPAN_ALERT("[user] blinds [M] with the flash[blind_msg_others]"), SPAN_ALERT("You are blinded by the flash[blind_msg_target]")) // Pretend to be a flash
		logTheThing(LOG_COMBAT, user, "blinds [constructTarget(M,"combat")] with spy [src] at [log_loc(user)].")
	else
		. = ..()

/obj/item/camera/spy/afterattack(atom/target, mob/user, flag)
	if (!can_use || ismob(target.loc))
		return
	if (src.flash_mode)
		return
	else
		. = ..() 	// Call /obj/item/camera/spy/afterattack() for photo mode

TYPEINFO(/obj/item/camera_film)
	mats = 10

TYPEINFO(/obj/item/camera_film/large)
	mats = 15

/obj/item/camera_film
	name = "film cartridge"
	desc = "A replacement film cartridge for an instant camera. Produces a six by six centimeter image."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "camera_film"
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	item_state = "box"
	w_class = W_CLASS_SMALL
	var/pictures = 12

	large
		name = "film cartridge (large)"
		pictures = 24

	examine()
		. = ..()
		. += "It is good for [src.pictures] pictures."


/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "photo"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	w_class = W_CLASS_TINY
	var/image/fullImage
	var/icon/fullIcon
	var/list/signed = list()
	var/written = null
	var/image/my_writing = null
	tooltip_flags = REBUILD_DIST
	burn_point = 220
	burn_output = 900
	burn_possible = TRUE

	New(location, var/image/IM, var/icon/IC, var/nname, var/ndesc)
		..(location)
		if (istype(IM))
			fullImage = IM
			render_photo_image(src.layer)
		if (istype(IC))
			fullIcon = IC
		if (nname)
			src.name = nname
		if (ndesc)
			src.desc = ndesc

	/// Resize and update photo overlay (layer)
	proc/render_photo_image(var/layer)
		var/image/IM = src.fullImage
		IM.transform = matrix(24/32, 22/32, MATRIX_SCALE)
		IM.pixel_y = 1
		IM.layer = layer
		src.AddOverlays(IM, "photo")

	// Update overlay layer for photo to show in hand/backpack
	pickup()
		..()
		render_photo_image(HUD_LAYER_2)

	// Update overlay layer for photo when dropping on floor or in belt/bag/container
	dropped()
		..()
		if(src.disposed)
			return
		render_photo_image(initial(src.layer))

/obj/item/photo/get_desc(var/dist)
	if(dist>1)
		return
	else
		if(signed || written)
			. += "<br>"
		if(length(signed) > 0)
			for(var/x in signed)
				. += "It is signed: [x]"
				. += "<br>"
		if (written)
			. += "At the bottom is written: [written]"

/obj/item/photo/attackby(obj/item/W, mob/user)
	var/obj/item/pen/P = W
	if(istype(P))
		var/signwrite = input(user, "Sign or Write?", null, null) as null|anything in list("sign","write")
		var/t = input(user, "What do you want to [signwrite]?", null, null) as null|text
		t = copytext(html_encode(t), 1, MAX_MESSAGE_LEN)
		logTheThing(LOG_STATION, user, "[signwrite]s '[t]' on [src]")
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

	attackby(obj/item/W, mob/user)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && istype(cursed_dude, /mob))
			cursed_dude.Attackby(W,user)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		else
			..()
		if(enchant_power == 0)
			boutput(user,SPAN_ALERT("<b>[src]</b> crumbles away to dust!"))
			qdel(src)
		return

	throw_begin(atom/target)
		if (enchant_power && world.time > src.enchant_delay && cursed_dude && ismob(cursed_dude))
			cursed_dude.visible_message(SPAN_ALERT("<b>[cursed_dude] is violently thrown by an unseen force!</b>"))
			cursed_dude.throw_at(get_edge_cheap(src, get_dir(src, target)), 20, 1)
			src.enchant_delay = world.time + COMBAT_CLICK_DELAY
			if(enchant_power > 0) enchant_power--
		if(enchant_power == 0)
			src.visible_message(SPAN_ALERT("<b>[src]</b> crumbles away to dust!"))
			qdel(src)
		return ..(target)


//////////////////////////////////////////////////////////////////////////////////////////////////
/*/obj/item/camera*/
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
/obj/item/camera/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	return

/obj/item/camera/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!can_use || ismob(target.loc)) return
	if (src.pictures_left == 0 && user)
		user.show_text("The film cartridge is used up. You have to replace it first.", "red")
		return

	src.create_photo(target)
	playsound(src, "sound/items/polaroid[rand(1,2)].ogg", 75, 1, -3)

	if (src.pictures_left > 0)
		src.pictures_left = max(0, src.pictures_left - 1)
		if (user)
			boutput(user, SPAN_NOTICE("[pictures_left] photos left."))
	can_use = 0
	SPAWN(5 SECONDS)
		if (src)
			src.can_use = 1

/obj/item/camera/proc/create_photo(var/atom/target, var/powerflash = 0)
	if (!target)
		return 0
	var/turf/the_turf = get_turf(target)

	var/image/photo = image(the_turf.icon, null, the_turf.icon_state, OBJ_LAYER, the_turf.dir)
	var/icon/photo_icon = getFlatIcon(the_turf)
	if (!photo)
		return

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
	var/list/mob/stolen_souls = list()

	for (var/atom/A in the_turf)
		if (A.invisibility || istype(A, /obj/overlay/tile_effect))
			continue
		var/icon/ic = getFlatIcon(A)
		if (ic)
			photo_icon.Blend(ic, ICON_OVERLAY, x=A.pixel_x + world.icon_size * (A.x - the_turf.x), y=A.pixel_y + world.icon_size * (A.y - the_turf.y))
		if(!A.name)
			continue
		if (ismob(A))
			var/mob/M = A

			if(src.steals_souls)
				stolen_souls += M

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
						if (temp.l_hand)
							holding = "[hes_or_shes(M)] holding \a [temp.l_hand]"
						if (temp.r_hand)
							if (holding)
								holding += " and \a [temp.r_hand]."
							else
								holding = "[hes_or_shes(M)] holding \a [temp.r_hand]."
						else if (holding)
							holding += "."

				var/they_look = "[he_or_she(M)] look[M.get_pronouns().pluralize ? null : "s"]"
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
				itemnumber++

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

	if (istype(photo_icon))
		photo_icon.Crop(1,1,32,32)
	photo.icon = photo_icon

	var/obj/item/photo/P
	// if we're on the floor drop on the floor. If we're in a person or a bot drop in whatever they're in
	var/atom/output_loc = isturf(src.loc) ? src.loc : src.loc.loc
	if(src.takes_voodoo_pics)
		P = new/obj/item/photo/voodoo(output_loc, photo, photo_icon, finished_title, finished_detail)
		P:cursed_dude = deafnote //kubius: using runtime eval because non-voodoo photos don't have a cursed_dude var
		if(src.takes_voodoo_pics == 2) //unlimited photo uses
			P:enchant_power = -1
	else if(src.steals_souls)
		P = new/obj/item/photo/haunted(output_loc, photo, photo_icon, finished_title, finished_detail)
		var/obj/item/photo/haunted/HP = P
		for(var/mob/M as anything in stolen_souls)
			HP.add_soul(M)
	else
		P = new/obj/item/photo(output_loc, photo, photo_icon, finished_title, finished_detail)

	return P
