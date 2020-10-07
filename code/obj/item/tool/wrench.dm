/obj/item/wrench
	name = "wrench"
	desc = "A tool used to apply torque to turn nuts and bolts."
	icon = 'icons/obj/items/tools/wrench.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/wrench.dmi'
	icon_state = "wrench"

	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_WRENCHING
	w_class = 2.0

	force = 5.0
	throwforce = 7.0
	stamina_damage = 40
	stamina_cost = 14
	stamina_crit_chance = 15

	m_amt = 150
	module_research = list("tools" = 4, "metals" = 2)
	rand_pos = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

/obj/item/wrench/gold
	name = "golden wrench"
	desc = "A generic wrench, but now with gold plating!"
	icon_state = "wrench-gold"
	item_state = "wrench"

/obj/item/wrench/monkey
	name = "monkey wrench"
	desc = "What the FUCK is that thing???"
	icon_state = "wrench-monkey"
	item_state = "wrench"
	module_research = list("tools" = 8)

/obj/item/wrench/vr
	icon_state = "wrench-vr"
	item_state = "wrench"

/obj/item/wrench/battle //for nuke ops class
	name = "battle wrench"
	desc = "A heavy industrial wrench that packs a mean punch when used as a bludgeon."
	icon_state = "wrench-battle"
	item_state = "wrench-battle"
	force = 10.0
	stamina_damage = 35
	//todo: new sprites
