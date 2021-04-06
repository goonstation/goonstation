/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	mats = list("CRY-1", "CON-2")
	module_research = list("tools" = 5, "devices" = 2)


	New()
		..()
		src.setItemSpecial(/datum/item_special/elecflash)

//I don't actually know what I'm doing but hopefully this will cause severe deadly burns. Also electrical puns.
/obj/item/device/multitool/custom_suicide = 1
/obj/item/device/multitool/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	user.visible_message("<span class='alert'><b>[user] connects the wires from the multitool onto [his_or_her(user)] tongue and presses pulse. It's pretty shocking to look at.</b></span>")
	user.TakeDamage("head", 0, 160)
	return 1
