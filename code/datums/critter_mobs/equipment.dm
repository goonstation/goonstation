/datum/equipmentHolder
	var/name = "head"							// designation of the
	var/offset_x = 0							// pixel offset on the x axis for mob overlays
	var/offset_y = 0							// pixel offset on the x axis for mob overlays
	var/show_on_holder = 1						// should this be displayed on the mob?
	var/armor_coverage = 0
	var/icon/icon = 'icons/mob/hud_human.dmi'	// the icon of the HUD object
	var/icon_state = "hair"						// the icon state of the HUD object
	var/obj/item/item							// the item being worn in this slot

	var/list/type_filters = list()				// a list of parent types whose subtypes are equippable
	var/atom/movable/screen/hud/screenObj				// ease of life

	var/mob/holder = null

	var/equipment_layer = MOB_CLOTHING_LAYER

	New(var/mob/M)
		..()
		holder = M

	disposing()
		if(screenObj)
			screenObj.dispose()
			screenObj = null
		item = null
		holder = null
		..()


	proc/can_equip(var/obj/item/I)
		for (var/T in type_filters)
			if (istype(I, T))
				return 1
		return 0

	proc/equip(var/obj/item/I)
		if (item || !can_equip(I))
			return 0
		if (screenObj)
			I.screen_loc = screenObj.screen_loc
		item = I
		item.set_loc(holder)
		holder.update_clothing()
		on_equip()
		return 1

	proc/drop(var/force = 0)
		if (!item)
			return 0
		if ((item.cant_drop || item.cant_other_remove) && !force)
			return 0
		item.set_loc(get_turf(holder))
		item.master = null
		item.layer = initial(item.layer)
		on_unequip()
		item = null
		holder.update_clothing()
		return 1

	proc/remove()
		if (!item)
			return 0
		if (item.cant_self_remove)
			return 0
		if (!holder.put_in_hand(item))
			return 0
		on_unequip()
		item = null
		return 1

	proc/on_update()
	proc/on_equip()
	proc/on_unequip()
	proc/after_setup(var/datum/hud)

	head
		name = "head"
		type_filters = list(/obj/item/clothing/head)
		icon = 'icons/mob/hud_human.dmi'
		icon_state = "hair"
		armor_coverage = HEAD

		skeleton
			var/datum/equipmentHolder/head/skeleton/next
			var/datum/equipmentHolder/head/skeleton/prev
			on_update()
				var/o = 0
				var/datum/equipmentHolder/head/skeleton/c = prev
				while (c)
					if (c.item)
						o += 3
					c = c.prev
				offset_y = o

			proc/spawn_next()
				next = new /datum/equipmentHolder/head/skeleton(holder)
				next.prev = src
				return next

		bird
			offset_y = -5
			on_update()
				if (istype(holder, /mob/living/critter/small_animal/bird))
					var/mob/living/critter/small_animal/bird/B = holder
					offset_y = B.hat_offset_y
					offset_x = B.hat_offset_x


		bee
			offset_y = -6

		slime
			offset_y = -15

	suit
		name = "suit"
		type_filters = list(/obj/item/clothing/suit)
		icon = 'icons/mob/hud_human.dmi'
		icon_state = "armor"
		armor_coverage = TORSO

	ears
		name = "ears"
		type_filters = list(/obj/item/device/radio)
		icon = 'icons/mob/hud_human.dmi'
		icon_state = "ears"

		on_equip()
			holder.ears = item

		on_unequip()
			holder.ears = null

		intercom
			after_setup(var/datum/hud/hud)
				var/obj/item/device/radio/intercom/O = new(holder)
				equip(O)
				// it's a built in radio, they can't take it off.
				O.cant_self_remove = TRUE
				O.cant_other_remove = TRUE

			syndicate
				after_setup(var/datum/hud/hud)
					var/obj/item/device/radio/intercom/syndicate/S = new(holder)
					equip(S)
					// it's a built in radio, they can't take it off.
					S.cant_self_remove = TRUE
					S.cant_other_remove = TRUE
