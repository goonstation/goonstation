/datum/targetable/critter/takepicture
	name = "Snap picture"
	desc = "Take a picture."
	cooldown = 10
	soundbite = "sound/items/polaroid[rand(1,2)].ogg"
	brute_damage = 5
	cast(atom/target)
		if (..())
			return 1
		playsound(target, src.soundbite, 100, 1, -1)
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
		if(src.takes_voodoo_pics)
			P = new/obj/item/photo/voodoo(get_turf(src), photo, photo_icon, finished_title, finished_detail)
			P:cursed_dude = deafnote //kubius: using runtime eval because non-voodoo photos don't have a cursed_dude var
			if(src.takes_voodoo_pics == 2) //unlimited photo uses
				P:enchant_power = -1
		else if(src.steals_souls)
			P = new/obj/item/photo/haunted(get_turf(src), photo, photo_icon, finished_title, finished_detail)
			var/obj/item/photo/haunted/HP = P
			for(var/mob/M as anything in stolen_souls)
				HP.add_soul(M)
		else
			P = new/obj/item/photo(get_turf(src), photo, photo_icon, finished_title, finished_detail)

		return P
///datum/targetable/critter/flash

///datum/targetable/critter/control_owner
