/obj/item/uplink/syndicate
	name = "station bounced radio"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "walkietalkie"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	w_class = W_CLASS_SMALL
	item_state = "radio"
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	use_default_GUI = 1
	can_selfdestruct = 1

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (src.lock_code_autogenerate == 1)
			src.lock_code = src.generate_code()
			src.locked = 1

		return

	alternate // a version that isn't hidden as a radio. So nukeops can better understand where to click to get guns.
		name = "syndicate equipment uplink"
		desc = "An uplink terminal that allows you to order weapons and items."
		icon_state = "uplink"
		purchase_flags = UPLINK_TRAITOR | UPLINK_NUKE_OP | UPLINK_SPY | UPLINK_SPY_THIEF | UPLINK_HEAD_REV //Currently this sits unused except for an admin's character, so we can safely have fun with it

	traitor
		purchase_flags = UPLINK_TRAITOR

	nukeop
		name = "syndicate operative uplink"
		desc = "An uplink terminal that allows you to order weapons and items."
		icon_state = "uplink"
		purchase_flags = UPLINK_NUKE_OP

	rev
		purchase_flags = UPLINK_HEAD_REV

	spy
		purchase_flags = UPLINK_SPY

	omni //For admin fuckery and omnitraitors, have fun.
		name = "syndicate omnivendor"
		desc = "Warning: User may suffer from choice paralysis."
		icon_state = "uplink"
		purchase_flags = UPLINK_TRAITOR | UPLINK_SPY | UPLINK_NUKE_OP | UPLINK_HEAD_REV | UPLINK_NUKE_COMMANDER | UPLINK_SPY_THIEF


/obj/item/uplink/syndicate/virtual
	name = "Syndicate Simulator 2053"
	desc = "Pretend you are a space terrorist! Harmless VR fun for all the family!"
	uses = INFINITY
	is_VR_uplink = 1
	can_selfdestruct = 0
	purchase_flags = UPLINK_TRAITOR

	explode()
		src.temp = "Bang! Just kidding."
		return
