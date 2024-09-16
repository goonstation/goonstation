/obj/item/gang_machete
	name = "machete"
	desc = "A hefty, unbalanced blade. Wielding it fills you with thoughts of savagery."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "machete"
	item_state = "welder_machete"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	hit_type = DAMAGE_CUT
	flags = USEDELAY
	force = 25
	click_delay = 16 DECI SECONDS //unbalanced blade
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	contraband = 4
	w_class = W_CLASS_NORMAL
	tool_flags = TOOL_CUTTING
	attack_verbs = "slashes"
	hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'

	New()
		..()
		src.AddComponent(/datum/component/bloodflick)
		src.setItemSpecial(/datum/item_special/massacre)


/obj/item/switchblade
	name = "switchblade"
	desc = "Spring-loaded and therefore completely illegal in Space England."
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = ""
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "switchblade-idle"
	hit_type = DAMAGE_BLUNT
	force = 3
	throwforce = 7
	stamina_damage = 5
	stamina_cost = 1
	event_handler_flags = USE_GRAB_CHOKE
	special_grab = /obj/item/grab
	stamina_crit_chance = 5
	var/active = FALSE
	w_class = W_CLASS_SMALL
	HELP_MESSAGE_OVERRIDE({"This knife can be concealed in clothing by hitting worn clothes with it, do the *snap emote to retrieve it.\n
	While unfolded, using this weapon's special attack grants increased critical chance & bleed effects."})
	New()
		src.AddComponent(/datum/component/bloodflick)
		..()

	attack_self(mob/user)
		toggle_active(user)
		return ..()

	proc/toggle_active(mob/user)
		if (!active)
			hitsound = 'sound/impact_sounds/Blade_Small_Bloody.ogg'
			user.visible_message("<span class='combat bold'>[user] flips \the [src] open!</span>")
			w_class = W_CLASS_NORMAL
			active = TRUE
			tool_flags = TOOL_CUTTING
			item_state = "knife"
			src.setItemSpecial(/datum/item_special/simple/bloodystab)
			icon_state = "switchblade-open"
			hit_type = DAMAGE_CUT
			force = 10
			stamina_crit_chance = 33
			playsound(user, 'sound/items/blade_pull.ogg', 60, TRUE)
		else if (!chokehold)
			hitsound = 'sound/impact_sounds/Generic_Hit_1.ogg'
			user.visible_message("<span class='combat bold'>[user] folds \the [src].</span>")
			w_class = W_CLASS_SMALL
			active = FALSE
			item_state = ""
			tool_flags = 0
			src.setItemSpecial(/datum/item_special/simple)
			icon_state = "switchblade-close"
			hit_type = DAMAGE_BLUNT
			stamina_crit_chance = 5
			force = 3
			playsound(user, 'sound/machines/heater_off.ogg', 40, TRUE)
		user.update_inhands()
		tooltip_rebuild = TRUE

	afterattack(obj/O as obj, mob/user as mob)
		if (O.loc == user && istype(O, /obj/item/clothing))
			if (active)
				toggle_active(user)
			icon_state = "switchblade-idle"
			boutput(user, "<span class='hint'>You hide the [src] inside \the [O]. (Use the snap emote while wearing the clothing item to retrieve it.)</span>")
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
		else
			..()
