/obj/item/screwdriver
	name = "screwdriver"
	desc = "A tool used to turn slotted screws and other slotted objects."
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/screwdriver.dmi'
	icon_state = "screwdriver"

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	tool_flags = TOOL_SCREWING
	health = 3
	w_class = W_CLASS_TINY

	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	rand_pos = 1
	custom_suicide = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)
		setItemSpecial(/datum/item_special/jab)

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] jams the screwdriver into [his_or_her(user)] eye over and over and over.</b>"))
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		playsound(user.loc, 'sound/effects/sdriver_suicide.ogg', 80, 0)
		return 1

/obj/item/screwdriver/vr
	icon_state = "screwdriver-vr"
	item_state = "screwdriver"

/obj/item/screwdriver/yellow
	desc = "A tool used to turn slotted screws and other slotted objects. This one has a nice lemon color."
	icon_state = "screwdriver-yellow"
	item_state = "screwdriver-yellow"

/obj/item/screwdriver/grey
	desc = "A tool used to turn slotted screws and other slotted objects. This one has a drab grey color."
	icon_state = "screwdriver-grey"
	item_state = "screwdriver-grey"

/obj/item/screwdriver/orange
	desc = "A tool used to turn slotted screws and other slotted objects. This one has a nice orange color."
	icon_state = "screwdriver-orange"
	item_state = "screwdriver-orange"

/obj/item/screwdriver/green
	desc = "A tool used to turn slotted screws and other slotted objects. The handle is green for added grip."
	icon_state = "screwdriver-green"
	item_state = "screwdriver-green"
