/obj/item/tool
	name = "tool"
	desc = "Some sort of tool."
	icon = 'icons/obj/items/tools/wrench.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/wrench.dmi'

	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	health = 5

	// sensible defaults
	force = 5
	throwforce = 5
	stamina_damage = STAMINA_ITEM_DMG * 5/4
	stamina_cost = STAMINA_ITEM_COST * 10/9
	stamina_crit_chance = STAMINA_CRIT_CHANCE * 2/5

	rand_pos = 1

	proc/on_use()
		return 1
