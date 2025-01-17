/obj/item/crowbar
	name = "crowbar"
	desc = "A tool used as a lever to pry objects."
	icon = 'icons/obj/items/tools/crowbar.dmi'
	// TODO: crowbar inhand icon
	inhand_image_icon = 'icons/mob/inhand/tools/crowbar.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_PRYING
	health = 5
	w_class = W_CLASS_SMALL

	force = 7
	throwforce = 7
	stamina_damage = 35
	stamina_cost = 12
	stamina_crit_chance = 10

	m_amt = 50
	rand_pos = 1
	custom_suicide = 1

	New()
		..()
		src.setItemSpecial(/datum/item_special/tile_fling)
		BLOCK_SETUP(BLOCK_ROD)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (is_special || !pry_surgery(target, user))
			return ..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] beats [him_or_her(user)]self in the head with a crowbar, like some kind of suicidal theoretical physicist.</b>"))
		take_bleeding_damage(user, null, 25, src.hit_type)
		user.TakeDamage("head", 160, 0)
		return 1

/obj/item/crowbar/vr
	icon_state = "crowbar-vr"

/obj/item/crowbar/red
	name = "crowbar"
	desc = "A tool used as a lever to pry objects. This one appears to have been painted red as an indicator of its important emergency tool status, or maybe someone forgot to clean the blood off."
	icon_state = "crowbar-red"

/obj/item/crowbar/yellow
	desc = "A tool used as a lever to pry objects. This one's a nice lemon color."
	icon_state = "crowbar-yellow"

/obj/item/crowbar/blue
	desc = "A tool used as a lever to pry objects. The handle is painted an appropriate light blue."
	icon_state = "crowbar-blue"

/obj/item/crowbar/purple
	desc = "A tool used as a lever to pry objects. This one is curiously purple."
	icon_state = "crowbar-purple"

/obj/item/crowbar/grey
	desc = "A tool used as a lever to pry objects. Now in grey!"
	icon_state = "crowbar-grey"

/obj/item/crowbar/orange
	desc = "A tool used as a lever to pry objects. This one's got a hue somewhere between yellow and red."
	icon_state = "crowbar-orange"

/obj/item/crowbar/green
	desc = "A tool used as a lever to pry objects, with added green."
	icon_state = "crowbar-green"

/obj/item/crowbar/glowbar
	desc = "That doesn't look safe to handle, at all. The name 'KANG' is etched into the metal."
	name = "glowbar"
	icon_state = "crowbar-green"
	rarity = 7
	quality = 100

	New()
		..()
		AddComponent(/datum/component/radioactive, 25, FALSE, TRUE, 1)
		AddComponent(/datum/component/loctargeting/simple_light, 255, 50, 135, 135)
		src.setProperty("searing", 7)
		src.setProperty("unstable", 7)
		setItemSpecial(/datum/item_special/suck)
