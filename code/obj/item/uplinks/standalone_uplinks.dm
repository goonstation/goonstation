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
	use_default_GUI = FALSE
	can_selfdestruct = 1

	setup(var/datum/mind/ownermind, var/obj/item/device/master)
		..()
		if (src.lock_code_autogenerate == 1)
			src.lock_code = src.generate_code()
			src.locked = 1

		return

	attack_self(mob/user as mob)
		if (src.vr_check(user) != 1)
			user.show_text("This uplink only works in virtual reality.", "red")
			return
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Uplink")
			ui.open()

	ui_data(mob/user)
		. = list(
			"currency_amount" = src.uses
		)

	ui_static_data(mob/user)
		var/list/categorised_items = list()
		categorised_items["General"] = src.items_general
		categorised_items["Job-Specific"] = src.items_job
		categorised_items["Objective"] = src.items_objective
		categorised_items["Telecrystals"] = src.items_telecrystal
		categorised_items["Ammunition"] = src.items_ammo
		var/list/categorised_data = list()
		for(var/category in categorised_items)
			categorised_data[category] = src.get_category_data(categorised_items[category])
		. = list(
			"title" = "Syndicate Uplink",
			"theme" = "syndicate",
			"currency_name" = global.syndicate_currency,
			"item_entries" = categorised_data,
			"vr" = src.is_VR_uplink
		)

	proc/get_category_data(var/buylist_entry_list)
		var/list/category_data = list()
		for(var/buylist_name as anything in buylist_entry_list)
			var/datum/syndicate_buylist/uplink_item = buylist_entry_list[buylist_name]
			var/atom/main_entry_type = uplink_item.items[1]
			var/icon/icon = icon2base64(icon(main_entry_type::icon, main_entry_type::icon_state, frame = 1))
			category_data += list(list(
				name = uplink_item.name,
				desc = uplink_item.desc,
				cost = uplink_item.cost,
				icon = icon,
				vr_allowed = uplink_item.vr_allowed,
			))
		return category_data

	ui_act(action, list/params)
		. = ..()
		if (.)
			return
		switch (action)
			if ("purchase")
				src.try_buy(params["item"])

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
