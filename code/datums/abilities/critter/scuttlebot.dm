//Abilities of the scuttlebot

/datum/targetable/critter/takepicture
	name = "Snap picture"
	desc = "Take a picture."
	cooldown = 5 SECONDS
	targeted = 1
	target_anything = 1
	icon_state = "hatpicture"
	cast(atom/target)
		if (..())
			return 1
		playsound(target, "sound/items/polaroid[rand(1,2)].ogg", 100, 1, -1)
		if (!target)
			return 0
		var/turf/the_turf = get_turf(target)
		var/image/photo = image(the_turf.icon, null, the_turf.icon_state, OBJ_LAYER, the_turf.dir)
		var/icon/photo_icon = getFlatIcon(the_turf)
		if (!photo)
			return

		var/mob_title = null
		var/mob_detail = null

		var/item_title = null
		var/item_detail = null

		var/mobnumber = 0
		var/itemnumber = 0
		for (var/atom/A in the_turf)
			if (A.invisibility || istype(A, /obj/overlay/tile_effect))
				continue
			var/icon/ic = getFlatIcon(A)
			if (ic)
				photo_icon.Blend(ic, ICON_OVERLAY, x=A.pixel_x + world.icon_size * (A.x - the_turf.x), y=A.pixel_y + world.icon_size * (A.y - the_turf.y))
			if (ismob(A))
				var/mob/M = A

				if (!mob_title)
					mob_title = "[M]"
				else
					mob_title += " and [M]"

				if (mobnumber < 4)
					var/holding = null
					if (iscarbon(M))
						var/mob/living/carbon/temp = M
						if (temp.l_hand || temp.r_hand)
							var/they_are = "[hes_or_shes(M)]"
							if (temp.l_hand)
								holding = "[they_are] holding \a [temp.l_hand]"
							if (temp.r_hand)
								if (holding)
									holding += " and \a [temp.r_hand]."
								else
									holding = "[they_are] holding \a [temp.r_hand]."
							else if (holding)
								holding += "."

					var/they_look = "[he_or_she(M)] looks"
					var/health_info = M.health < 75 ? " - [they_look][M.health < 25 ? " really" : null] hurt" : null
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
		P = new/obj/item/photo((length(holder.owner?.contents) < 15 ? holder.owner : get_turf(holder.owner)), photo, photo_icon, finished_title, finished_detail)
		return isnull(P)

/datum/targetable/critter/flash
	name = "Blinding flash"
	desc = "Flash someone in the eyes."
	icon_state = "hatflash"
	cooldown = 20 SECONDS
	targeted = 1
	cast(atom/target)
		if (..())
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to flash."))
			return 1
		if (target == holder.owner)
			return 1
		var/mob/MT = target
		MT.apply_flash(10, 10, stamina_damage = 100, eyes_blurry = 5, eyes_damage = 5)
		playsound(holder.owner, 'sound/weapons/flash.ogg', 100, 1)

/datum/targetable/critter/control_owner
	name = "Return to body"
	desc = "Leave the scuttlebot and return to your body"
	icon_state = "shutdown"
	cast(atom/target)
		if (..())
			return 1
		if (istype(holder.owner, /mob/living/critter/robotic/scuttlebot))
			if(!holder.owner.mind)
				boutput(holder.owner, SPAN_ALERT("You don't have a mind somehow."))
				return 1

			var/mob/living/critter/robotic/scuttlebot/E = holder.owner
			if (!E.controller)
				boutput(holder.owner, SPAN_ALERT("You didn't have a body to go back to! The scuttlebot shuts down with a sad boop."))
				holder.owner.ghostize()
				return 1
			E.mind.transfer_to(E.controller)
			E.controller.network_device = null
			E.controller = null
		else //In case this ability is put on another mob
			boutput(holder.owner, SPAN_ALERT("You don't have a body to go back to!"))
			return 1

	incapacitationCheck()
		return FALSE

/datum/targetable/critter/scuttle_scan
	name = "Robotic scan"
	desc = "Use your robotic vision to gather forensics"
	icon_state = "scuttlescan"
	cooldown = 3 SECONDS
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1

		if (BOUNDS_DIST(target, holder.owner) > 0 || istype(target, /obj/ability_button))
			return

		holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner]</b> has scanned [target]."))
		boutput(holder.owner, scan_forensic(target, visible = 1))
