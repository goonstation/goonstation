/obj/item/screwdriver
	name = "screwdriver"
	desc = "A tool used to turn slotted screws and other slotted objects."
	icon = 'icons/obj/items/tools/screwdriver.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/screwdriver.dmi'
	icon_state = "screwdriver"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_SCREWING
	w_class = 1.0

	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 30
	hit_type = DAMAGE_STAB
	hitsound = 'sound/impact_sounds/Flesh_Stab_1.ogg'

	module_research = list("tools" = 4, "metals" = 1)
	rand_pos = 1
	custom_suicide = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] jams the screwdriver into [his_or_her(user)] eye over and over and over.</b></span>")
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		return 1

/obj/item/screwdriver/vr
	icon_state = "screwdriver-vr"
	item_state = "screwdriver"
