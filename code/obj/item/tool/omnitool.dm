/obj/item/tool/omnitool
	name = "omnitool"
	desc = "Multiple tools in one, like an old-fashioned Swiss army knife. Truly, we are living in the future."
	icon = 'icons/obj/items/tools/omnitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	uses_multiple_icon_states = 1
	var/prefix = "omnitool"
	var/has_cutting = 0

	custom_suicide = 1

	var/omni_mode = "prying"

	New()
		..()
		src.change_mode(omni_mode)

	attack_self(var/mob/user as mob)
		// cycle between modes
		var/new_mode = null
		switch (src.omni_mode)
			if ("prying") new_mode = "screwing"
			if ("screwing") new_mode = "pulsing"
			if ("pulsing") new_mode = "snipping"
			if ("snipping") new_mode = "wrenching"
			if ("wrenching")
				if(has_cutting)
					new_mode = "cutting"
				else
					new_mode = "prying"
			if("cutting")
				new_mode = "prying"
			else new_mode = "prying"
		if (new_mode)
			src.change_mode(new_mode, user)

	get_desc(var/dist)
		if (dist < 3)
			. = "<span class='notice'>It is currently set to [src.omni_mode] mode.</span>"

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] stabs and beats [his_or_her(user)]self with each tool in the [src] in rapid succession.</b></span>")
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		return 1

	proc/change_mode(var/new_mode, var/mob/holder)
		switch (new_mode)
			if ("prying")
				src.omni_mode = "prying"
				// based on /obj/item/crowbar
				set_icon_state("[prefix]-prying")
				src.tool_flags = TOOL_PRYING
				src.force = 5.0
				src.throwforce = 7.0
				src.throw_range = 7
				src.throw_speed = 2
				// using relative amounts in case the default changes
				src.stamina_damage = STAMINA_ITEM_DMG * 33/20
				src.stamina_cost = STAMINA_ITEM_COST * 25/18
				src.stamina_crit_chance = STAMINA_CRIT_CHANCE * 10/25
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
			if ("pulsing")
				src.omni_mode = "pulsing"
				// based on /obj/item/device/multitool
				set_icon_state("[prefix]-pulsing")
				src.tool_flags = TOOL_PULSING
				src.force = 5.0
				src.throwforce = 5.0
				src.throw_range = 15
				src.throw_speed = 3
				// using relative amounts in case the default changes
				src.stamina_damage = STAMINA_ITEM_DMG * 5/20
				src.stamina_cost = STAMINA_ITEM_COST * 5/18
				src.stamina_crit_chance = STAMINA_CRIT_CHANCE * 1/25
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
			if ("screwing")
				src.omni_mode = "screwing"
				// based on /obj/item/screwdriver
				set_icon_state("[prefix]-screwing")
				src.tool_flags = TOOL_SCREWING
				src.force = 5.0
				src.throwforce = 5.0
				src.throw_range = 5
				src.throw_speed = 3
				// using relative amounts in case the default changes
				src.stamina_damage = STAMINA_ITEM_DMG * 10/20
				src.stamina_cost = STAMINA_ITEM_COST * 10/18
				src.stamina_crit_chance = min(STAMINA_CRIT_CHANCE * 30/25, 100)
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
			if ("snipping")
				src.omni_mode = "snipping"
				// based on /obj/item/wirecutters
				set_icon_state("[prefix]-snipping")
				src.tool_flags = TOOL_SNIPPING
				src.force = 6.0
				src.throwforce = 1.0
				src.throw_range = 9
				src.throw_speed = 2
				// using relative amounts in case the default changes
				src.stamina_damage = STAMINA_ITEM_DMG * 5/20
				src.stamina_cost = STAMINA_ITEM_COST * 10/18
				src.stamina_crit_chance = min(STAMINA_CRIT_CHANCE * 30/25, 100)
				src.hit_type = DAMAGE_STAB
				src.hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
			if ("wrenching")
				src.omni_mode = "wrenching"
				// based on /obj/item/wrench
				set_icon_state("[prefix]-wrenching")
				src.tool_flags = TOOL_WRENCHING
				src.force = 5.0
				src.throwforce = 7.0
				src.throw_range = 7
				src.throw_speed = 2
				// using relative amounts in case the default changes
				src.stamina_damage = STAMINA_ITEM_DMG * 25/20
				src.stamina_cost = STAMINA_ITEM_COST * 20/18
				src.stamina_crit_chance = STAMINA_CRIT_CHANCE * 15/25
				src.hit_type = DAMAGE_BLUNT
				src.hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'

			if ("cutting")
				src.omni_mode = "cutting"
				//based on /obj/item/kitchen/utensil/knife
				set_icon_state("[prefix]-cutting")
				src.tool_flags = TOOL_CUTTING
				src.force = 7
				src.throwforce = 10
				src.throw_range = 5
				src.throw_speed = 2
				// taken from wirecutters because I don't know what's going on here
				src.stamina_damage = STAMINA_ITEM_DMG * 5/20
				src.stamina_cost = STAMINA_ITEM_COST * 10/18
				src.stamina_crit_chance = min(STAMINA_CRIT_CHANCE * 30/25, 100)
				src.hit_type = DAMAGE_CUT
				src.hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'

		if (holder)
			holder.update_inhands()

/obj/item/tool/omnitool/syndicate
	prefix = "syndicate-omnitool"
	has_cutting = 1

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && O != src && istype(O, /obj/item/clothing))
			boutput(user, "<span class='hint'>You hide the set of tools inside \the [O]. (Use the flex emote while wearing the clothing item to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
		else
			..()
		return
