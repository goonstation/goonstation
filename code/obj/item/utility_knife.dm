/obj/item/utility_knife
	name = "utility knife"
	desc = "A Security-issue utility knife that functions as a crowbar. Very effective at clearing space flora."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "combat_knife"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife"

	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_PRYING | TOOL_CUTTING
	health = 5
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	w_class = W_CLASS_SMALL

	force = 7
	throwforce = 12
	stamina_damage = 10
	stamina_cost = 8
	stamina_crit_chance = 10

	m_amt = 50
	custom_suicide = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	attack(mob/living/carbon/M, mob/user)
		if (!pry_surgery(M, user))
			return ..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] slits [his_or_her(user)] own throat with a utility knife!</b></span>")
		take_bleeding_damage(user, null, 90, src.hit_type)
		user.TakeDamage("head", 70, 0)
		return 1
