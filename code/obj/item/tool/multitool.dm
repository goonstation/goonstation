/obj/item/device/multitool
	name = "multitool"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	icon = 'icons/obj/items/tools/multitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/multitool.dmi'
	icon_state = "multitool"

	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	tool_flags = TOOL_PULSING
	w_class = 2.0

	force = 5.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	m_amt = 50
	g_amt = 20
	mats = 6
	module_research = list("tools" = 5, "devices" = 2)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] connects the wires from the multitool onto [his_or_her(user)] tongue and presses pulse. It's pretty shocking to look at.</b></span>")
		user.TakeDamage("head", 0, 160)
		return 1
