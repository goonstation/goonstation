/obj/item/crowbar
	name = "crowbar"
	desc = "A tool used as a lever to pry objects."
	icon = 'icons/obj/items/tools/crowbar.dmi'
	// TODO: crowbar inhand icon
	inhand_image_icon = 'icons/mob/inhand/tools/crowbar.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
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

	attack(mob/living/carbon/M, mob/user)
		if (!pry_surgery(M, user))
			return ..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] beats [him_or_her(user)]self in the head with a crowbar, like some kind of suicidal theoretical physicist.</b></span>")
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
