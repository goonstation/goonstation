//CONTENTS
//Module base.
//Flashlight module.
//T-ray scanner module.
//Computer 3 Emulator / Associated Bits

TYPEINFO(/obj/item/device/pda_module)
	mats = 4

/obj/item/device/pda_module
	name = "PDA module"
	desc = "A piece of expansion circuitry for PDAs."
	icon = 'icons/obj/module.dmi'
	icon_state = "pdamod"
	w_class = W_CLASS_SMALL
	var/obj/item/device/pda2/host = null

	var/setup_use_menu_badge = 0  //Should we have a line in the main menu?
	var/setup_allow_os_config = 0 //Do we support a big config page?

	New()
		..()
		if(istype(src.loc, /obj/item/device/pda2))
			src.host = src.loc
			src.loc:module = src
			src.add_abilities_to_host()
		return

	Topic(href, href_list)
		if(!src.host || src.loc != src.host)
			return 1

		if ((!usr.contents.Find(src.host) && (!in_interact_range(src.host, usr) || !istype(src.host.loc, /turf))) && (!issilicon(usr)))
			return 1

		if(usr.stat || usr.restrained())
			return 1

		src.host.add_fingerprint(usr)
		return 0

	disposing()
		host = null
		contents = null
		..()

	//Return string as part of PDA main menu, ie easy way to toggle a function.  One line!!
	proc/return_menu_badge()
		return null

	proc/relay_pickup(mob/user as mob)
		return

	proc/relay_drop(mob/user as mob)
		return

	proc/install(var/obj/item/device/pda2/pda)
		if(pda)
			pda.module = src
			src.host = pda
			src.add_abilities_to_host()
		return

	proc/uninstall()
		if(src.host)
			src.remove_abilities_from_host()
			src.host.module = null
			src.host = null
		return

	proc/add_abilities_to_host()
		if (src.host && islist(src.ability_buttons) && length(src.ability_buttons))
			for (var/obj/ability_button/B in src.ability_buttons)
				if (!islist(src.host.ability_buttons))
					src.host.ability_buttons = list()
				if (!src.host.ability_buttons.Find(B))
					src.host.ability_buttons.Add(B)
					if (src.host.the_mob)
						src.host.the_mob.item_abilities.Add(B)
			if (src.host.the_mob)
				src.host.the_mob.need_update_item_abilities = 1
				src.host.the_mob.update_item_abilities()

	proc/remove_abilities_from_host()
		if (src.host && islist(src.host.ability_buttons) && src.host.ability_buttons.len && islist(src.ability_buttons) && length(src.ability_buttons))
			for (var/obj/ability_button/B in src.ability_buttons)
				src.host.ability_buttons.Remove(B)
				if (src.host.the_mob?.item_abilities)
					src.host.the_mob.item_abilities.Remove(B)
			if (src.host.the_mob)
				src.host.the_mob.need_update_item_abilities = 1
				src.host.the_mob.update_item_abilities()

/obj/item/device/pda_module/flashlight
	name = "flashlight module"
	desc = "A flashlight module for a PDA."
	icon_state = "pdamod_light"
	setup_use_menu_badge = 1
	var/on = 0 //Are we currently on?
	var/lumlevel = 0.2 //How bright are we?
	var/datum/light/light
	abilities = list(/obj/ability_button/pda_flashlight_toggle)
	var/flashlight_icon = 'icons/obj/items/pda.dmi'
	var/flashlight_icon_state = "flashlight"
	var/image/lensflare
	var/use_simple_light = 0
	var/use_medium_light = 1
	var/light_r = 255
	var/light_g = 255
	var/light_b = 255

	New()
		..()
		if (!use_simple_light && !use_medium_light)
			light = new /datum/light/line
			light.set_brightness(lumlevel)
			light.set_color(light_r,light_g,light_b)
		src.lensflare = image(src.flashlight_icon, src.flashlight_icon_state)

	relay_pickup(mob/user)
		..()
		if (!use_simple_light && !use_medium_light)
			light.attach(user)
		else if (on)
			if (src.host)
				src.host.remove_sm_light("pda\ref[src]")
			user.add_sm_light("pda\ref[src]", list(light_r,light_g,light_b,lumlevel * 255), use_medium_light)


	relay_drop(mob/user)
		..()
		SPAWN(0)
			if (src.host)
				if (src.host.loc != user)
					if (!use_simple_light && !use_medium_light)
						light.attach(src.host.loc)
					else if (on)
						user.remove_sm_light("pda\ref[src]")
						src.host.add_sm_light("pda\ref[src]", list(light_r,light_g,light_b,lumlevel * 255), use_medium_light)


	return_menu_badge()
		var/text = "<a href='byond://?src=\ref[src];toggle=1'>[src.on ? "Disable" : "Enable"] Flashlight</a>"
		return text

	install(var/obj/item/device/pda2/pda)
		..()
		if (!use_simple_light && !use_medium_light)
			light.attach(pda)
		else if (on)
			pda.add_sm_light("pda\ref[src]", list(light_r,light_g,light_b,lumlevel * 255), use_medium_light)

	uninstall()
		if (!use_simple_light && !use_medium_light)
			light.disable()
		else if (on)
			src.host.remove_sm_light("pda\ref[src]")
			src.host.loc.remove_sm_light("pda\ref[src]") // user
		src.on = 0
		src.host.underlays -= src.lensflare
		..()

	Topic(href, href_list)
		if(..())
			return
		if(href_list["toggle"])
			src.toggle_light()
		return

	proc/toggle_light()
		src.on = !src.on
		if (!use_simple_light && !use_medium_light)
			if (ismob(src.host.loc))
				light.attach(src.host.loc)

		if (src.on)
			src.host.underlays += src.lensflare
			if (!use_simple_light && !use_medium_light)
				light.enable()
			else
				if (!isturf(src.host.loc))
					var/atom/A = src.host.loc
					A.add_sm_light("pda\ref[src]", list(light_r,light_g,light_b,lumlevel * 255), use_medium_light)
				else
					src.host.add_sm_light("pda\ref[src]", list(light_r,light_g,light_b,lumlevel * 255), use_medium_light)

		else
			src.host.underlays -= src.lensflare
			if (!use_simple_light && !use_medium_light)
				light.disable()
			else
				if (!isturf(src.host.loc))
					var/atom/A = src.host.loc
					A.remove_sm_light("pda\ref[src]")
				else
					src.host.remove_sm_light("pda\ref[src]")

		if (islist(src.ability_buttons))
			for (var/obj/ability_button/pda_flashlight_toggle/B in src.ability_buttons)
				B.icon_state = "pda[src.on]"
		if (src.host)
			src.host.updateSelfDialog()

	disposing() // Remove lightsources first upon deletion for no lingering light effects
		if (src.on)
			src.toggle_light()
		..()

/obj/item/device/pda_module/flashlight/dan
	name = "Deluxe Dan's Fancy Flashlight Module"
	desc = "What a name, what an experience."
	lumlevel = 0.8

	toggle_light()
		src.light_r = rand(255)
		src.light_g = rand(255)
		src.light_b = rand(255)
		light?.set_color(light_r,light_g,light_b)
		..()


/obj/item/device/pda_module/flashlight/high_power
	name = "high-power flashlight module"
	lumlevel = 0.8
	flashlight_icon = 'icons/obj/items/pda.dmi'
	flashlight_icon_state = "flashlight-2"
	use_simple_light = 0
	use_medium_light = 1

/obj/ability_button/pda_flashlight_toggle
	name = "Toggle PDA Flashlight"
	icon_state = "pda0"

	execute_ability()
		var/obj/item/device/pda_module/flashlight/J = the_item
		if (J.host)
			J.toggle_light()

/obj/item/device/pda_module/tray
	name = "t-ray scanner module"
	desc = "A terahertz-ray emitter and scanner built into a handy PDA module."
	icon_state = "pdamod_tscanner"
	setup_use_menu_badge = 1
	abilities = list(/obj/ability_button/pda_tray_toggle)
	var/obj/item/device/t_scanner/pda/scanner

	New()
		..()
		scanner = new(src)

	return_menu_badge()
		var/text = "<a href='byond://?src=\ref[src];toggle=1'>[src.scanner.on ? "Disable" : "Enable"] T-ray Scanner</a>"
		return text

	Topic(href, href_list)
		if(..())
			return
		if(href_list["toggle"])
			src.toggle_scan()

	proc/toggle_scan()
		scanner.set_on(!scanner.on)
		for (var/obj/ability_button/pda_tray_toggle/B in src.ability_buttons)
			B.icon_state = "pda[scanner.on]"
		if (src.host)
			src.host.updateSelfDialog()

	disposing()
		qdel(scanner)
		scanner = null
		..()

	uninstall()
		..()
		scanner.set_on(FALSE)

/obj/ability_button/pda_tray_toggle
	name = "Toggle PDA T-ray Scanner"
	icon_state = "pda0"

	execute_ability()
		var/obj/item/device/pda_module/tray/J = the_item
		if (J.host)
			J.toggle_scan()

/obj/item/device/pda_module/alert
	name = "security alert module"
	desc = "A PDA module that lets you quickly send PDA alerts to the security department."
	icon_state = "pdamod_alert"
	setup_use_menu_badge = 1
	abilities = list(/obj/ability_button/pda_security_alert)
	var/list/mailgroups = list(MGD_SECURITY)

	return_menu_badge()
		var/text = "<a href='byond://?src=\ref[src];toggle=1'>Send Alert</a>"
		return text

	Topic(href, href_list)
		if(..())
			return
		if(href_list["toggle"])
			src.send_alert(usr)
		return

	proc/send_alert(mob/user)
		if (!src.host)
			boutput(user, SPAN_ALERT("No PDA detected."))
			return
		if (ON_COOLDOWN(src, "send_alert", 5 MINUTES))
			boutput(user, SPAN_ALERT("[src] is still on cooldown mode!"))
			return
		var/datum/signal/signal = get_free_signal()
		signal.source = src.host
		signal.data["address_1"] = "00000000"
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = src.host.owner
		signal.data["group"] = mailgroups + MGA_CRISIS
		var/area/A = get_area(src.host)
		signal.data["message"]  = "***SECURITY BACKUP REQUESTED*** Location: [A ? A.name : "nowhere"]!"
		signal.data["noreply"] = TRUE
		signal.data["is_alert"] = TRUE
		src.host.post_signal(signal)

		if(isliving(user))
			playsound(src, 'sound/items/security_alert.ogg', 60)
			var/map_text = null
			map_text = make_chat_maptext(user, "Emergency alert sent. Please assist this officer.", "color: #D30000; font-size: 6px;", alpha = 215)
			for (var/mob/O in hearers(user))
				O.show_message(assoc_maptext = map_text, just_maptext = TRUE)
			user.visible_message(SPAN_ALERT("[user] presses a red button on the side of their [src.host]."),
			SPAN_NOTICE("You press the \"Alert\" button on the side of your [src.host]."),
			SPAN_ALERT("You see [user] press a button on the side of their [src.host]."))


/obj/ability_button/pda_security_alert
	name = "Send Security Alert"
	icon_state = "alert"

	execute_ability()
		var/obj/item/device/pda_module/alert/J = the_item
		if (J.host)
			J.send_alert(src.the_mob)
