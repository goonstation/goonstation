/obj/item/wrench
	name = "wrench"
	desc = "A tool used to apply torque to turn nuts and bolts."
	icon = 'icons/obj/items/tools/wrench.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/wrench.dmi'
	icon_state = "wrench"

	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	tool_flags = TOOL_WRENCHING
	health = 5
	w_class = W_CLASS_SMALL

	force = 5
	throwforce = 7
	stamina_damage = 40
	stamina_cost = 14
	stamina_crit_chance = 15

	m_amt = 150
	rand_pos = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

	// attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	// 	if (is_special || !wrench_surgery(target, user))
	// 		return ..()

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

/obj/item/wrench/vr
	icon_state = "wrench-vr"
	item_state = "wrench"

/obj/item/wrench/battle //for nuke ops class
	name = "battle wrench"
	desc = "A heavy industrial wrench that packs a mean punch when used as a bludgeon. Can be applied to the Nuclear bomb to repair it in small increments."
	icon_state = "wrench-battle" //todo: new sprites
	item_state = "wrench-battle"
	force = 15
	stamina_damage = 55

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

/obj/item/wrench/yellow
	desc = "A tool used to apply torque to turn nuts and bolts. This one has a bright yellow handle."
	icon_state = "wrench-yellow"
	item_state = "wrench"

/obj/item/wrench/grey
	desc = "A tool used to apply torque to turn nuts and bolts, sporting a droll grey grip."
	icon_state = "wrench-grey"
	item_state = "wrench"

/obj/item/wrench/orange
	desc = "A tool used to apply torque to turn nuts and bolts. But orange!"
	icon_state = "wrench-orange"
	item_state = "wrench"

/obj/item/wrench/green
	desc = "A tool used to apply torque to turn nuts and bolts. In green!"
	icon_state = "wrench-green"
	item_state = "wrench"

/obj/item/wrench/glench
	name = "glench"
	desc = "That's a helluva wrench. The name 'GLEN' is etched into the handle."
	icon_state = "wrench-glench"
	item_state = "wrench-glench"
	force = 15
	stamina_damage = 55
	rarity = 6
	quality = 80

	New()
		..()
		src.setProperty("block", 15)
		setItemSpecial(/datum/item_special/slam)
