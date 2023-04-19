/obj/submachine/chef_sink/chem_sink
	name = "sink"
	density = 0
	layer = 5
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sink"
	flags = NOSPLASH

// Removed quite a bit of of duplicate code here (Convair880).

///////////////////////////////////////////////////////////////////////////////////////////////////
TYPEINFO(/obj/machinery/chem_heater)
	mats = 15

/obj/machinery/chem_heater
	name = "Reagent Heater/Cooler"
	desc = "A device used for the slow but precise heating and cooling of chemicals. It looks like a cross between an oven and a urinal."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "heater"
	flags = NOSPLASH | TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	power_usage = 50
	var/obj/beaker = null
	var/active = 0
	var/target_temp = T0C
	var/output_target = null
	var/mob/roboworking = null
	var/static/image/icon_beaker = image('icons/obj/chemical.dmi', "heater-beaker")
	// The chemistry APC was largely meaningless, so I made dispensers/heaters require a power supply (Convair880).

	New()
		..()
		output_target = src.loc

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)

		if(istype(B, /obj/item/reagent_containers/glass))
			tryInsert(B, user)

	proc/tryInsert(obj/item/reagent_containers/glass/B, var/mob/user)
		if (status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (isrobot(user) && beaker && beaker == B)
			// If a cyborg is using this, and is trying to stick the same beaker into the heater again,
			// treat it like they just want to open the UI for QOL
			attack_ai(user)
			return

		if(src.beaker)
			boutput(user, "A beaker is already loaded into the machine.")
			return

		src.beaker =  B
		if (!isrobot(user))
			if(B.cant_drop)
				boutput(user, "You can't add the beaker to the machine!")
				src.beaker = null
				return
			else
				user.drop_item()
				B.set_loc(src)
		else
			roboworking = user
			SPAWN(1 SECOND)
				robot_disposal_check()

		if(src.beaker || roboworking)
			boutput(user, "You add the beaker to the machine!")
			src.ui_interact(user)
		src.UpdateIcon()

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.UpdateIcon()
			tgui_process.update_uis(src)

	ex_act(severity)
		switch(severity)
			if(1)
				qdel(src)
				return
			if(2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)


	ui_interact(mob/user, datum/tgui/ui)
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemHeater", src.name)
			ui.open()

	ui_data(mob/user)
		. = list()
		var/obj/item/reagent_containers/glass/container = src.beaker
		// Container data
		var/list/containerData
		if(container)
			var/datum/reagents/R = container.reagents
			containerData = list(
				name = container.name,
				maxVolume = R.maximum_volume,
				totalVolume = R.total_volume,
				temperature = R.total_temperature,
				contents = list(),
				finalColor = "#000000"
			)

			var/list/contents = containerData["contents"]
			if(istype(R) && R.reagent_list.len>0)
				containerData["finalColor"] = R.get_average_rgb()
				// Reagent data
				for(var/reagent_id in R.reagent_list)
					var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

					contents.Add(list(list(
						name = reagents_cache[reagent_id],
						id = reagent_id,
						colorR = current_reagent.fluid_r,
						colorG = current_reagent.fluid_g,
						colorB = current_reagent.fluid_b,
						volume = current_reagent.volume
					)))
		.["containerData"] = containerData
		.["targetTemperature"] = src.target_temp
		.["isActive"] = src.active

	ui_act(action, params)
		. = ..()
		if(.)
			return
		var/obj/item/reagent_containers/glass/container = src.beaker
		switch(action)
			if("eject")
				if(!container)
					return
				if (src.roboworking)
					if (usr != src.roboworking)
						// If a cyborg is using this, other people can't eject the beaker.
						usr.show_text("You cannot eject the beaker because it is part of [roboworking].", "red")
						return
					src.roboworking = null
				else
					container.set_loc(src.output_target) // causes Exited proc to be called
					usr.put_in_hand_or_eject(container) // try to eject it into the users hand, if we can
				src.beaker = null
				src.UpdateIcon()
				return

			if("insert")
				if (container)
					return
				var/obj/item/reagent_containers/glass/inserting = usr.equipped()
				if(istype(inserting))
					tryInsert(inserting, usr)
			if("adjustTemp")
				src.target_temp = clamp(params["temperature"], 0, 1000)
				src.UpdateIcon()
			if("start")
				if (!container?.reagents.total_volume)
					return
				src.active = 1
				active()
				src.UpdateIcon()
			if("stop")
				set_inactive()
		. = TRUE

	//MBC : moved to robot_disposal_check
	/*
	ProximityLeave(atom/movable/AM as mob|obj)
		if (roboworking && AM == roboworking && BOUNDS_DIST(src, AM) > 0)
			// Cyborg is leaving (or getting pushed away); remove its beaker
			roboworking = null
			beaker = null
			set_inactive()
			// If the heater was working, the next iteration of active() will turn it off and fix power usage
		return ..(AM)
	*/

	process()
		..()

	proc/active()
		if (!active) return
		if (status & (NOPOWER|BROKEN) || !beaker || !beaker.reagents.total_volume)
			set_inactive()
			return

		var/datum/reagents/R = beaker:reagents
		R.temperature_reagents(target_temp, 400)

		src.power_usage = 1000

		if(abs(R.total_temperature - target_temp) <= 3) active = 0

		tgui_process.update_uis(src)

		SPAWN(1 SECOND) active()

	proc/robot_disposal_check()
		// Without this, the heater might occasionally show that a beaker is still inserted
		// when it in fact isn't. That should only happen when
		//  - a cyborg was using the machine, and
		//  - the cyborg lost its chest with the beaker still inserted, and
		//  - the heater was inactive at the time of death.
		// Since we don't get any callbacks in this case - the borg leaves the tile by
		// way of qdel, so there's no ProximityLeave notification - the only way to update
		// the icon promptly is to run a periodic check when a borg has its beaker inserted
		// into the heater, regardless of whether the heater is active or not.
		// MBC note : also moved distance check here
		if (!roboworking)
			// This proc is only called when a robot was at one point using the heater, so if
			// roboworking is unset then it must have been deleted
			set_inactive()
		else if (BOUNDS_DIST(src, roboworking) > 0)
			roboworking = null
			beaker = null
			set_inactive()
		else
			SPAWN(1 SECOND)
				robot_disposal_check()

	proc/set_inactive()
		power_usage = 50
		active = 0
		UpdateIcon()
		tgui_process.update_uis(src)

	update_icon()
		src.overlays -= src.icon_beaker
		if (src.beaker)
			src.overlays += src.icon_beaker
			if (src.active && src.beaker:reagents && src.beaker:reagents:total_volume)
				if (target_temp > src.beaker:reagents:total_temperature)
					src.icon_state = "heater-heat"
				else if (target_temp < src.beaker:reagents:total_temperature)
					src.icon_state = "heater-cool"
				else
					src.icon_state = "heater"
			else
				src.icon_state = "heater"
		else
			src.icon_state = "heater"

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the Reagent Heater/Cooler's output target.</span>")
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, "<span class='alert'>The Reagent Heater/Cooler is too far away from the target!</span>")
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the Reagent Heater/Cooler to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	Exited(Obj, newloc)
		if(Obj == src.beaker)
			src.beaker = null
			src.UpdateIcon()
			tgui_process.update_uis(src)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define CHEMMASTER_MINIMUM_REAGENT 5 // mininum reagent for pills, bottles and patches
#define CHEMMASTER_CONTAINER_TRESHOLD 10 // equal or above this amount use container
#define CHEMMASTER_ITEMNAME_MAXSIZE 16 // chosen by fair dice roll
#define CHEMMASTER_MAX_PILL 22 // 22 pill icons
#define CHEMMASTER_MAX_CANS 26 // 26 flavours of cans

TYPEINFO(/obj/machinery/chem_master)
	mats = 15
/obj/machinery/chem_master
	name = "CheMaster 3000"
	desc = "A computer-like device used in the production of various pharmaceutical items. It has a slot for a beaker on the top."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	flags = NOSPLASH
	power_usage = 50
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/obj/item/beaker = null
	var/list/beaker_cache = null
	var/mob/roboworking = null
	var/emagged = FALSE
	var/list/whitelist = list()

	var/list/regular_bottles = list(
		/obj/item/reagent_containers/ampoule, // 5u ampoule
		/obj/item/reagent_containers/glass/bottle/plastic, // 30u plastic bottle
		/obj/item/reagent_containers/glass/bottle/chemical/plastic // 50u plastic bottle
	)
	var/list/patches_list = list(
		/obj/item/reagent_containers/patch/mini, // 15u
		/obj/item/reagent_containers/patch // 30u
	)

	New()
		..()
		if (!src.emagged && islist(global.chem_whitelist) && length(global.chem_whitelist))
			src.whitelist = global.chem_whitelist
		AddComponent(/datum/component/transfer_output)

	// borrowed from the reagent heater/cooler code
	proc/tryInsert(obj/item/reagent_containers/glass/B, var/mob/user)
		if (src.status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (src.beaker && src.beaker == B)
			return

		if(B.cant_drop && !isrobot(user))
			boutput(user, "You can't add [src.beaker] to the machine!")
			return

		if(BOUNDS_DIST(src, user) > 0)
			boutput(usr, "[src] is too far away.")
			return

		// Lets try replacing the current beaker first.
		if(src.beaker)
			src.eject_beaker(user) // Eject current beaker

		// Insert new beaker
		src.beaker = B

		if (isrobot(user))
			// prevent multiple spawns from a robot using various beakers
			if (!src.roboworking)
				SPAWN(1 SECOND)
					robot_disposal_check()
			src.roboworking = user
		else
			user.drop_item()
			B.set_loc(src)

		if(src.beaker || src.roboworking)
			boutput(user, "You add [src.beaker] to the machine!")
			src.ui_interact(user)

		rebuild_beaker_cache()
		global.tgui_process.update_uis(src)
		src.UpdateIcon()

	proc/eject_beaker(mob/user)
		if(!src.beaker)
			return FALSE

		if(!src.roboworking)
			var/obj/item/I = src.beaker
			TRANSFER_OR_DROP(src, I) // causes Exited proc to be called
			user.put_in_hand_or_eject(I)
		else // robos dont want exited proc
			src.beaker = null
			src.roboworking = null
			rebuild_beaker_cache()
			src.UpdateIcon()
			global.tgui_process.update_uis(src)
		return TRUE

	proc/robot_disposal_check()
		// explanation in the reagent heater/cooler
		if (src.roboworking)
			if (BOUNDS_DIST(src, src.roboworking) > 0)
				src.roboworking = null
				src.beaker = null
				rebuild_beaker_cache()
				src.UpdateIcon()
				global.tgui_process.update_uis(src)
			else
				SPAWN(1 SECOND)
					// robots can put their beakers in multiple machines at once
					rebuild_beaker_cache()
					robot_disposal_check()

	proc/design_pill(var/obj/item/reagent_containers/pill/P, var/pill_icon)
		if(!P.reagents)
			return

		pill_icon = clamp(pill_icon, 0, CHEMMASTER_MAX_PILL)
		if(pill_icon == 0)
			var/datum/color/average = P.reagents.get_average_color()
			P.color_overlay = image('icons/obj/items/pills.dmi', "pill0")
			P.color_overlay.color = average.to_rgb()
			P.color_overlay.alpha = P.color_overlay_alpha
			P.overlays += P.color_overlay
		else
			P.icon_state = "pill[pill_icon]"

	proc/bottle_from_param(var/bottle_selected)
		bottle_selected += 1 // JS arrays start at 0
		bottle_selected = clamp(bottle_selected, 1, length(regular_bottles) + 2 * CHEMMASTER_MAX_CANS)

		var/obj/item/reagent_containers/bottle = null
		if(bottle_selected <= length(regular_bottles))
			// prevent unused src warning
			var/obj/item/reagent_containers/bottle_path = regular_bottles[bottle_selected]
			bottle = new bottle_path(src)
			if(istype(bottle, /obj/item/reagent_containers/glass))
				bottle.can_recycle = FALSE
		else if(bottle_selected <= length(regular_bottles) + CHEMMASTER_MAX_CANS)
			bottle = new /obj/item/reagent_containers/food/drinks/cola/custom/small(src)
			bottle.icon_state = "cola-[bottle_selected-length(regular_bottles)]-small"
			bottle.can_recycle = FALSE
		else if(bottle_selected <= length(regular_bottles) + 2 * CHEMMASTER_MAX_CANS)
			bottle = new /obj/item/reagent_containers/food/drinks/cola/custom(src)
			bottle.icon_state = "cola-[bottle_selected-length(regular_bottles)-CHEMMASTER_MAX_CANS]"
			bottle.can_recycle = FALSE
		return bottle

	proc/patch_from_param(var/patch_selected)
		patch_selected += 1 // JS arrays start at 0
		patch_selected = clamp(patch_selected, 1, length(patches_list))

		var/obj/item/reagent_containers/patch/patch = null
		// prevent unused src warning
		var/obj/item/reagent_containers/patch_path = patches_list[patch_selected]
		patch = new patch_path(src)
		return patch

	// Check if beaker only has whitelisted chemicals for a medical patch
	proc/check_patch_whitelist()
		if(!src.beaker?.reagents)
			return FALSE
		if(src.emagged)
			return TRUE
		if(!src.whitelist || (islist(src.whitelist) && !length(src.whitelist)))
			return FALSE

		for (var/reagent_id in src.beaker.reagents.reagent_list)
			if (!src.whitelist.Find(reagent_id))
				return FALSE
		return TRUE

	ui_interact(mob/user, datum/tgui/ui)
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemMaster", "Chemical Master 3000")
			ui.open()

	ui_static_data(mob/user)
		. = list()

		var/list/pill_icons = list()
		for(var/i = 0, i <= CHEMMASTER_MAX_PILL, ++i)
			var/icon/pill_icon = icon('icons/obj/items/pills.dmi', "pill[i]")
			pill_icons.Add(list(icon2base64(pill_icon)))
		.["pill_icons"] = pill_icons

		var/list/bottle_icons = list()
		var/obj/item/reagent_containers/bottle = null
		var/icon/bottle_icon = null
		var/bottle_capacity = null
		for(var/bottle_path in regular_bottles)
			bottle = new bottle_path(src)
			bottle_icon = icon(bottle.icon, bottle.icon_state)
			bottle_capacity = bottle.initial_volume
			bottle_icons.Add(list(list(bottle_capacity, icon2base64(bottle_icon))))
			qdel(bottle)
		// small cola can
		bottle = new /obj/item/reagent_containers/food/drinks/cola/custom/small(src)
		bottle_capacity = bottle.initial_volume
		for(var/i = 1, i <= CHEMMASTER_MAX_CANS, ++i)
			bottle_icon = icon(bottle.icon, "cola-[i]-small")
			bottle_icons.Add(list(list(bottle_capacity, icon2base64(bottle_icon))))
		qdel(bottle)
		// big cola can
		bottle = new /obj/item/reagent_containers/food/drinks/cola/custom(src)
		bottle_capacity = bottle.initial_volume
		for(var/i = 1, i <= CHEMMASTER_MAX_CANS, ++i)
			bottle_icon = icon(bottle.icon, "cola-[i]")
			bottle_icons.Add(list(list(bottle_capacity, icon2base64(bottle_icon))))
		qdel(bottle)
		.["bottle_icons"] = bottle_icons

		var/list/patch_icons = list()

		for(var/patch_path in patches_list)
			var/obj/item/reagent_containers/patch = new patch_path(src)
			var/icon/patch_icon = icon(patch.icon, patch.icon_state)
			var/patch_capacity = patch.initial_volume
			patch_icons.Add(list(list(patch_capacity, icon2base64(patch_icon))))
			qdel(patch)
		.["patch_icons"] = patch_icons

	proc/rebuild_beaker_cache()
		if(!src.beaker)
			src.beaker_cache = null
			return

		src.beaker_cache = list(
			name = src.beaker.name,
			maxVolume = src.beaker.reagents.maximum_volume,
			totalVolume = src.beaker.reagents.total_volume,
			temperature = src.beaker.reagents.total_temperature,
			contents = list(),
			finalColor = "#000000"
		)

		var/list/contents = src.beaker_cache["contents"]
		if(istype(src.beaker.reagents) && length(src.beaker.reagents.reagent_list))
			src.beaker_cache["finalColor"] = src.beaker.reagents.get_average_rgb()
			// Reagent data
			for(var/reagent_id in src.beaker.reagents.reagent_list)
				var/datum/reagent/current_reagent = src.beaker.reagents.reagent_list[reagent_id]
				contents.Add(list(list(
					name = reagents_cache[reagent_id],
					id = reagent_id,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					volume = current_reagent.volume
				)))

	proc/manufacture_name(var/param_name)
		var/name = param_name
		name = trim(copytext(sanitize(html_encode(name)), 1, CHEMMASTER_ITEMNAME_MAXSIZE))
		if(isnull(name) || !length(name) || name == " ")
			name = null
			if(src.beaker)
				name = src.beaker.reagents.get_master_reagent_name()
		return name

	ui_data(mob/user)
		. = list()

		if(src.beaker)
			.["default_name"] = src.beaker.reagents.get_master_reagent_name()
		else
			.["default_name"] = null
		.["container"] = beaker_cache

	ui_act(action, list/params, datum/tgui/ui)
		. = ..()
		if(.)
			return

		switch(action)
			if("insert")
				var/obj/item/inserting = ui.user.equipped()
				if(istype(inserting, /obj/item/reagent_containers/glass))
					tryInsert(inserting, ui.user)
					. = TRUE
			if("eject")
				. = eject_beaker(ui.user)
			if("flushall")
				if (src.beaker)
					src.beaker.reagents.clear_reagents()
					eject_beaker(ui.user) // no point in keeping empty beaker
					rebuild_beaker_cache()
					. = TRUE
			if("analyze")
				var/id = params["reagent_id"]
				if(!src.beaker?.reagents)
					return
				var/datum/reagent/reagent = src.beaker.reagents.get_reagent(id)
				if(reagent)
					var/analyze_string = "Chemical info:<BR>"
					analyze_string += "<b>[reagent.name]</b> - "
					analyze_string += "[reagent.description]<BR>"
					analyze_string += reagent.get_recipes_in_text()
					boutput(ui.user, analyze_string)

			if("isolate")
				var/id = params["reagent_id"]
				if(src.beaker?.reagents)
					src.beaker.reagents.isolate_reagent(id)
					rebuild_beaker_cache()
					. = TRUE
			if("flush")
				var/id = params["reagent_id"]
				if(src.beaker?.reagents)
					var/reagent_amount = src.beaker.reagents.get_reagent_amount(id)
					src.beaker.reagents.remove_reagent(id, reagent_amount)
					if(!src.beaker.reagents.total_volume) // qol eject when empty
						eject_beaker(ui.user)
					rebuild_beaker_cache()
					. = TRUE
			if("flushinput")
				var/id = params["reagent_id"]
				var/reagent_amount = max(1, round(params["amount"]))
				if (src.beaker?.reagents)
					src.beaker.reagents.remove_reagent(id, reagent_amount)
					rebuild_beaker_cache()
					. = TRUE

			// Operations
			if("makepill")
				if(!src.beaker || !src.beaker.reagents.total_volume)
					return

				var/item_name = manufacture_name(params["item_name"])
				if(!item_name) // how did we get here?
					boutput(ui.user, "[src] pill labeller makes a weird buzz. That can't be good.")
					return

				// sanity check
				var/reagent_amount = clamp(round(params["amount"]), CHEMMASTER_MINIMUM_REAGENT, src.beaker.reagents.maximum_volume)
				var/pill_icon = params["icon"] // handled in design_pill

				var/obj/item/reagent_containers/pill/P = new(src)
				P.name = "[item_name] pill"
				src.beaker.reagents.trans_to(P, reagent_amount)
				design_pill(P, pill_icon)
				global.phrase_log.log_phrase("pill", item_name, no_duplicates=TRUE)
				logTheThing(LOG_COMBAT, usr, "used [src] to create a [P] pill containing [log_reagents(P)] at [log_loc(src)].")

				TRANSFER_OR_DROP(src, P)
				ui.user.put_in_hand_or_eject(P)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE
			if("makepills")
				if(!src.beaker || !src.beaker.reagents.total_volume)
					return

				var/item_name = manufacture_name(params["item_name"])
				if(!item_name) // how did we get here?
					boutput(ui.user, "[src] pill labeller makes a weird buzz. That can't be good.")
					return

				// sanity check
				var/reagent_amount = clamp(round(params["amount"]), CHEMMASTER_MINIMUM_REAGENT, src.beaker.reagents.maximum_volume)
				var/use_pill_bottle = params["use_bottle"]
				var/pill_icon = params["icon"] // handled in design_pill

				global.phrase_log.log_phrase("pill", item_name, no_duplicates=TRUE)

				var/pillcount = round(src.beaker.reagents.total_volume / reagent_amount)
				if(!pillcount)
					// invalid input
					boutput(ui.user, "[src] makes a weird grinding noise. That can't be good.")
					return

				logTheThing(LOG_COMBAT, usr, "used [src] to create [pillcount] [item_name] pills containing [log_reagents(src.beaker)] at [log_loc(src)].")

				var/obj/item/chem_pill_bottle/pill_bottle = null
				if(use_pill_bottle || pillcount >= CHEMMASTER_CONTAINER_TRESHOLD)
					pill_bottle = new(src)
					pill_bottle.name = "[item_name] [pill_bottle.name]"

				for(var/i = 0, i < pillcount, ++i)
					var/obj/item/reagent_containers/pill/P = new(src)
					P.name = "[item_name] pill"
					src.beaker.reagents.trans_to(P, reagent_amount)
					design_pill(P, pill_icon)
					if(pill_bottle)
						P.set_loc(pill_bottle)
					else
						TRANSFER_OR_DROP(src, P)

				if(pill_bottle)
					TRANSFER_OR_DROP(src, pill_bottle)
					ui.user.put_in_hand_or_eject(pill_bottle)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE
			if("makebottle")
				if(!src.beaker || !src.beaker.reagents.total_volume)
					return

				var/item_name = manufacture_name(params["item_name"])
				if(!item_name) // how did we get here?
					boutput(ui.user, "[src] bottle labeller makes a weird buzz. That can't be good.")
					return

				// sanity check
				var/obj/item/reagent_containers/bottle = bottle_from_param(params["bottle"])
				if(!bottle)
					// somehow we didn't get a bottle
					boutput(ui.user, "[src] bottleler makes a weird grinding noise. That can't be good.")
					return
				var/reagent_amount = clamp(round(params["amount"]), CHEMMASTER_MINIMUM_REAGENT, bottle.initial_volume)

				global.phrase_log.log_phrase("bottle", item_name, no_duplicates=TRUE)

				bottle.name = "[item_name] [bottle.name]"
				src.beaker.reagents.trans_to(bottle, reagent_amount)

				logTheThing(LOG_COMBAT, usr, "used the [src] to create [bottle] containing [log_reagents(bottle)] at [log_loc(src)].")

				TRANSFER_OR_DROP(src, bottle)
				ui.user.put_in_hand_or_eject(bottle)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE
			if("makepatch")
				if(!src.beaker || !src.beaker.reagents.total_volume)
					return

				var/item_name = manufacture_name(params["item_name"])
				if(!item_name) // how did we get here?
					boutput(ui.user, "[src] patcher labeller makes a weird buzz. That can't be good.")
					return

				// sanity check
				var/obj/item/reagent_containers/patch/patch = patch_from_param(params["patch"])
				if(!patch)
					// somehow we didn't get a patch
					boutput(ui.user, "[src] patcher makes a weird grinding noise. That can't be good.")
					return
				var/reagent_amount = clamp(round(params["amount"]), CHEMMASTER_MINIMUM_REAGENT, patch.initial_volume)

				// unused by log_phrase?
				//global.phrase_log.log_phrase("patch", src.item_name, no_duplicates=TRUE)

				patch.name = "[item_name] patch"
				patch.medical = src.check_patch_whitelist()
				src.beaker.reagents.trans_to(patch, reagent_amount)

				logTheThing(LOG_COMBAT, usr, "used the [src] to create [patch] containing [log_reagents(patch)] at [log_loc(src)].")

				patch.on_reagent_change()

				TRANSFER_OR_DROP(src, patch)
				ui.user.put_in_hand_or_eject(patch)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE
			if("makepatches")
				if(!src.beaker || !src.beaker.reagents.total_volume)
					return

				var/item_name = manufacture_name(params["item_name"])
				if(!item_name) // how did we get here?
					boutput(ui.user, "[src] patcher labeller makes a weird buzz. That can't be good.")
					return

				// sanity check
				var/obj/item/reagent_containers/patch/patch = patch_from_param(params["patch"])
				if(!patch)
					// somehow we didn't get a patch
					boutput(ui.user, "[src] patcher makes a weird grinding noise. That can't be good.")
					return
				var/obj/item/reagent_containers/patch_path = patch.type
				var/reagent_amount = clamp(round(params["amount"]), CHEMMASTER_MINIMUM_REAGENT, patch.initial_volume)
				var/use_box = params["use_box"]
				qdel(patch) // only needed the initial_volume

				var/patchcount = round(src.beaker.reagents.total_volume / reagent_amount)
				if(!patchcount)
					// invalid input
					boutput(ui.user, "[src] makes a weird grinding noise. That can't be good.")
					return

				// unused by log_phrase?
				//global.phrase_log.log_phrase("patch", src.item_name, no_duplicates=TRUE)

				var/is_medical_patch = src.check_patch_whitelist()
				var/obj/item/item_box/medical_patches/patch_box = null
				if(use_box || patchcount >= CHEMMASTER_CONTAINER_TRESHOLD)
					patch_box = new(src)
					patch_box.name = "box of [item_name] patches"
					if (is_medical_patch)
						patch_box.build_overlay(average = src.beaker.reagents.get_average_color())
					else // dangerrr
						patch_box.icon_state = "patchbox" // change icon
						patch_box.icon_closed = "patchbox"
						patch_box.icon_open = "patchbox-open"
						patch_box.icon_empty = "patchbox-empty"

				logTheThing(LOG_COMBAT, usr, "used the [src.name] to create [patchcount] [item_name] patches from [log_reagents(src.beaker)] at [log_loc(src)].")

				for(var/i = 0, i < patchcount, ++i)
					var/obj/item/reagent_containers/patch/P = new patch_path(src)
					P.name = "[item_name] [P.name]"
					P.medical = is_medical_patch
					src.beaker.reagents.trans_to(P, reagent_amount)
					P.on_reagent_change()
					if(patch_box)
						P.set_loc(patch_box)
					else
						TRANSFER_OR_DROP(src, P)

				if(patch_box)
					TRANSFER_OR_DROP(src, patch_box)
					ui.user.put_in_hand_or_eject(patch_box)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE

	update_icon()
		if(src.beaker)
			icon_state = "mixer1"
		else
			icon_state = "mixer0"

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if(istype(B, /obj/item/reagent_containers/glass))
			tryInsert(B, user)

	attack_hand(mob/user)
		if (src.status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return
		src.ui_interact(user)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	ex_act(severity)
		..(max(severity, 2))

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been disabled.", "red")
		src.emagged = 1
		return 1

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been reactivated.", "blue")
		src.emagged = 0
		return 1

	Exited(Obj, newloc)
		if(Obj == src.beaker)
			src.beaker = null
			src.roboworking = null
			rebuild_beaker_cache()
			src.UpdateIcon()
			global.tgui_process.update_uis(src)

#undef CHEMMASTER_CONTAINER_TRESHOLD
#undef CHEMMASTER_ITEMNAME_MAXSIZE
#undef CHEMMASTER_MAX_PILL
#undef CHEMMASTER_MAX_CANS
#undef CHEMMASTER_MINIMUM_REAGENT

/datum/chemicompiler_core/stationaryCore
	statusChangeCallback = "statusChange"

TYPEINFO(/obj/machinery/chemicompiler_stationary)
	mats = 15

/obj/machinery/chemicompiler_stationary
	name = "ChemiCompiler CCS1001"
	desc = "This device looks very difficult to use."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemicompiler_st_off"
	flags = NOSPLASH
	processing_tier = PROCESSING_FULL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/datum/chemicompiler_executor/executor
	var/datum/light/light

	New()
		..()
		AddComponent(/datum/component/mechanics_holder)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Run Script", .proc/runscript)
		executor = new(src, /datum/chemicompiler_core/stationaryCore)
		light = new /datum/light/point
		light.set_brightness(0.4)
		light.attach(src)

	proc/runscript(var/datum/mechanicsMessage/input)
		var/buttId = executor.core.validateButtId(input.signal)
		if(!buttId || executor.core.running)
			return
		if(islist(executor.core.cbf[buttId]))
			executor.core.runCBF(executor.core.cbf[buttId])

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	was_deconstructed_to_frame(mob/user)
		status = NOPOWER // If it works.
		SEND_SIGNAL(src, COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	attack_hand(mob/user)
		if (status & BROKEN || !powered())
			boutput( user, "<span class='alert'>You can't seem to power it on!</span>" )
			return
		src.add_dialog(user)
		executor.panel()
		onclose(user, "chemicompiler")
		return

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if (!istype(B, /obj/item/reagent_containers/glass))
			return
		if (isrobot(user)) return attack_ai(user)
		return attack_hand(user)

	power_change()

		if(status & BROKEN)
			icon_state = initial(icon_state)
			light.disable()

		else if(powered())
			if (executor.core.running)
				icon_state = "chemicompiler_st_working"
				light.set_brightness(0.6)
				light.enable()
			else
				icon_state = "chemicompiler_st_on"
				light.set_brightness(0.4)
				light.enable()
		else
			SPAWN(rand(0, 15))
				icon_state = initial(icon_state)
				status |= NOPOWER
				light.disable()

	process()
		. = ..()
		if ( src.executor )
			src.executor.on_process()

	proc
		topicPermissionCheck(action)
			if (!(src in range(1)))
				return 0
			if(executor.core.running)
				return action in list("getUIState", "reportError", "abortCode")
			return 1

		statusChange(oldStatus, newStatus)
			power_change()


// ORGONEIC CHAMISTREY FOR MUSTY JEANS
/obj/item/reagent_containers/glass/beaker/extractor_tank/thick
	initial_volume = 1000

/obj/machinery/chem_fractioning_still/ //a huge column boiler for separating chems by boiling point
	name = "fractional still"
	desc = "A towering piece of industrial equipment. It reeks of hydrocarbons."
	density = 1
	anchored = ANCHORED
	power_usage = 500
	var/active = 0
	var/overall_temp = T20C
	var/target_temp = T20C
	var/heating = 0
	var/distilling = 0
	var/cracking = 0
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/thick/bottoms = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/tops = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/feed = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/overflow = null
	var/obj/item/reagent_containers/user_beaker = null

	New()
		..()
		src.bottoms = new
		src.tops = new
		src.feed = new
		src.overflow = new

	disposing()
		if (src.bottoms)
			qdel(src.bottoms)
			src.bottoms = null
		if (src.tops)
			qdel(src.tops)
			src.tops = null
		if (src.feed)
			qdel(src.feed)
			src.feed = null
		if (src.overflow)
			qdel(src.overflow)
			src.overflow = null
		if (src.user_beaker)
			qdel(src.user_beaker)
			src.user_beaker = null
		UnsubscribeProcess()
		..()

	process(var/mult)
		if(!active)
			UnsubscribeProcess()
		if(heating)
			heat_up()
		else
			src.power_usage = initial(src.power_usage)
		if(distilling)
			distill(mult)
		if(cracking)
			do_cracking(bottoms,mult)
		bottoms.reagents.temperature_reagents(T20C, 1)
		..()

	proc/check_tank(var/obj/item/reagent_containers/tank,var/headroom)
		if(tank.reagents.total_volume >= tank.reagents.maximum_volume - headroom)
			tank.reagents.trans_to(overflow,(headroom*0.1))
		if(overflow.reagents.total_volume >= overflow.reagents.maximum_volume - headroom)
			src.visible_message("<span class='alert'>The internal overflow safety dumps its contents all over the floor!.</span>","<span class='alert'>You hear a tremendous gushing sound.</span>")
			var/turf/T = get_turf(src)
			overflow.reagents.reaction(T)

	proc/do_cracking(var/obj/item/reagent_containers/R, var/amount)
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.can_crack)
					reggie.crack(amount)

	proc/distill(var/amount)
		var/vapour_list = get_vapours(bottoms)
		if(vapour_list)
			heating = 0
			for(var/datum/reagent/R in vapour_list)
				bottoms.reagents.remove_reagent(R.id,amount)
				tops.reagents.add_reagent(R.id,amount)
				check_tank(tops,50)
				feed.reagents.trans_to(bottoms,amount)
				check_tank(bottoms,100)
		else
			if(bottoms.reagents && length(bottoms.reagents.reagent_list))
				heating = 1

	proc/heat_up()
		var/vapor_temp = min(get_lowest_temp(bottoms),target_temp)
		bottoms.reagents.temperature_reagents(vapor_temp, 10)
		src.power_usage = 1000

	proc/get_vapours(var/obj/item/reagent_containers/R)
		var/datum/reagent/reg = list()
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point <= overall_temp)
					reg += reggie
			return reg
		else return null

	proc/get_lowest_temp(var/obj/item/reagent_containers/R)
		var/top_temp = INFINITY
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point<top_temp)
					top_temp=reggie.boiling_point
			return top_temp
		else return T0C

	proc/get_lowest_temp_chem(var/obj/item/reagent_containers/R)
		var/top_temp = INFINITY
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point<top_temp)
					top_temp=reggie.boiling_point
					. = reggie
			return
		else return null

/obj/item/robot_chemaster/prototype
	name = "prototype ChemiTool"
	desc = "A prototype of a compact CheMaster/Reagent Extractor device."
	icon_state = "minichem_proto"
	flags = NOSPLASH
	var/mode = "overview"
	var/autoextract = 0
	var/obj/item/reagent_containers/glass/extract_to = null
	var/obj/item/reagent_containers/glass/inserted = null
	var/obj/item/reagent_containers/glass/storage_tank_1 = null
	var/obj/item/reagent_containers/glass/storage_tank_2 = null
	var/list/ingredients = list()
	var/list/allowed = list(/obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/seashell)
	var/output_target = null

	New()
		..()
		src.storage_tank_1 = new /obj/item/reagent_containers/glass/beaker/large(src)
		src.storage_tank_2 = new /obj/item/reagent_containers/glass/beaker/large(src)
		var/count = 1
		for (var/obj/item/reagent_containers/glass/beaker/large/ST in src.contents)
			ST.name = "Small Storage Tank [count]"
			count++
		output_target = src.loc

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/glass/))
			var/obj/item/reagent_containers/glass/B = W

			if (working)
				boutput(user, "<span class='alert'>CheMaster is working, be patient</span>")
				return
			var/mode_type = input("Which mode do you want to use?", "Mini-CheMaster",null,null) in list("CheMaster", "Reagent Extractor")
			if(mode_type == "CheMaster")
				if(!B.reagents.reagent_list.len || B.reagents.total_volume < 1)
					boutput(user, "<span class='alert'>That beaker is empty! There are no reagents for the [src.name] to process!</span>")
					return
				working = 1
				var/holder = src.loc
				var/the_reagent = input("Which reagent do you want to manipulate?","Mini-CheMaster",null,null) in B.reagents.reagent_list
				if (src.loc != holder || !the_reagent)
					return
				var/action = input("What do you want to do with the [the_reagent]?","Mini-CheMaster",null,null) in list("Isolate","Purge","Remove One Unit","Remove Five Units","Create Pill","Create Pill Bottle","Create Bottle","Create Patch","Create Ampoule","Do Nothing")
				if (src.loc != holder || !action || action == "Do Nothing")
					working = 0
					return

				switch(action)
					if("Isolate") B.reagents.isolate_reagent(the_reagent)
					if("Purge") B.reagents.del_reagent(the_reagent)
					if("Remove One Unit") B.reagents.remove_reagent(the_reagent, 1)
					if("Remove Five Units") B.reagents.remove_reagent(the_reagent, 5)
					if("Create Pill")
						var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(user.loc)
						var/default = B.reagents.get_master_reagent_name()
						var/name = copytext(html_encode(input(user,"Name:","Name your pill!",default)), 1, 32)
						if(!name || name == " ") name = default
						if(name && name != default)
							phrase_log.log_phrase("pill", name, no_duplicates=TRUE)
						P.name = "[name] pill"
						B.reagents.trans_to(P,B.reagents.total_volume)
					if("Create Pill Bottle")
						// copied from chem_master because fuck fixing everything at once jeez
						var/default = B.reagents.get_master_reagent_name()
						var/pillname = copytext( html_encode( input( user, "Name:", "Name the pill!", default ) ), 1, 32)
						if(!pillname || pillname == " ")
							pillname = default
						if(pillname && pillname != default)
							phrase_log.log_phrase("pill", pillname, no_duplicates=TRUE)

						var/pillvol = input( user, "Volume:", "Volume of chemical per pill!", "5" ) as num
						if( !pillvol || !isnum_safe(pillvol) || pillvol < 5 )
							pillvol = 5

						var/pillcount = round( B.reagents.total_volume / pillvol ) // round with a single parameter is actually floor because byond
						if(!pillcount)
							boutput(user, "[src] makes a weird grinding noise. That can't be good.")
						else
							var/obj/item/chem_pill_bottle/pillbottle = new /obj/item/chem_pill_bottle(user.loc)
							pillbottle.create_from_reagents(B.reagents, pillname, pillvol, pillcount)
					if("Create Bottle")
						var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle/plastic(user.loc)
						var/default = B.reagents.get_master_reagent_name()
						var/name = copytext(html_encode(input(user,"Name:","Name your bottle!",default)), 1, 32)
						if(!name || name == " ") name = default
						if(name && name != default)
							phrase_log.log_phrase("bottle", name, no_duplicates=TRUE)
						P.name = "[name] bottle"
						B.reagents.trans_to(P,30)
					if("Create Patch")
						var/datum/reagents/R = B.reagents
						var/input_name = input(user, "Name the patch:", "Name", R.get_master_reagent_name()) as null|text
						var/patchname = copytext(html_encode(input_name), 1, 32)
						if (isnull(patchname) || !length(patchname) || patchname == " ")
							working = 0
							return
						var/all_safe = 1
						for (var/reagent_id in R.reagent_list)
							if (!global.chem_whitelist.Find(reagent_id))
								all_safe = 0
						var/obj/item/reagent_containers/patch/P
						if (R.total_volume <= 15)
							P = new /obj/item/reagent_containers/patch/mini(user.loc)
							P.name = "[patchname] mini-patch"
							R.trans_to(P, P.initial_volume)
						else
							P = new /obj/item/reagent_containers/patch(user.loc)
							P.name = "[patchname] patch"
							R.trans_to(P, P.initial_volume)
						P.medical = all_safe
						P.on_reagent_change()
						logTheThing(LOG_CHEMISTRY, user, "used the [src.name] to create a [patchname] patch containing [log_reagents(P)] at [log_loc(src)].")
					if("Create Ampoule")
						var/datum/reagents/R = B.reagents
						var/input_name = input(user, "Name the ampoule:", "Name", R.get_master_reagent_name()) as null|text
						var/ampoulename = copytext(html_encode(input_name), 1, 32)
						if(!ampoulename)
							working = 0
							return
						if(ampoulename == " ")
							ampoulename = R.get_master_reagent_name()
						var/obj/item/reagent_containers/ampoule/A
						A = new /obj/item/reagent_containers/ampoule(user.loc)
						A.name = "ampoule ([ampoulename])"
						R.trans_to(A, 5)
						logTheThing(LOG_CHEMISTRY, user, "used the [src.name] to create a [ampoulename] ampoule containing [log_reagents(A)] at [log_loc(src)].")

				working = 0
			else if(mode_type == "Reagent Extractor")
				if(src.inserted)
					boutput(user, "<span class='alert'>A container is already loaded into the machine.</span>")
					return
				src.inserted =  W
				user.drop_item()
				W.set_loc(src)
				boutput(user, "<span class='notice'>You add [W] to the machine!</span>")
				src.updateUsrDialog()

		else if (istype(W,/obj/item/satchel/hydro)) //Extractor
			var/obj/item/satchel/S = W
			var/loadcount = 0
			for (var/obj/item/I in S.contents)
				if (src.canExtract(I) && (src.tryLoading(I, user)))
					loadcount++
			if (!loadcount)
				boutput(user, "<span class='alert'>No items were loaded from the satchel!</span>")
			else if (src.autoextract)
				boutput(user, "<span class='notice'>[loadcount] items were automatically extracted from the satchel!</span>")
			else
				boutput(user, "<span class='notice'>[loadcount] items were loaded from the satchel!</span>")

			S.UpdateIcon()
			src.updateUsrDialog()

		else
			if (!src.canExtract(W))
				boutput(user, "<span class='alert'>The extractor cannot accept that!</span>")
				return

			if (!src.tryLoading(W, user)) return
			boutput(user, "<span class='notice'>You add [W] to the machine!</span>")

			user.u_equip(W)
			W.dropped(user)

			src.updateUsrDialog()
			return

	attack_ai(var/mob/user as mob)
		return

	attack_hand(mob/user)
		if(src in user.equipped_list())
			src.add_dialog(user)
			var/list/dat = list("<B>Reagent Extractor</B><BR><HR>")
			if (src.mode == "overview")
				dat += "<b><u>Extractor Overview</u></b><br><br>"
				// Overview mode is just a general outline of what's in the machine at the time
				// Internal Storage Tanks
				if (src.storage_tank_1)
					dat += "<b>Storage Tank 1:</b> ([src.storage_tank_1.reagents.total_volume]/[src.storage_tank_1.reagents.maximum_volume])<br>"
					if(src.storage_tank_1.reagents.reagent_list.len)
						for(var/current_id in storage_tank_1.reagents.reagent_list)
							var/datum/reagent/current_reagent = storage_tank_1.reagents.reagent_list[current_id]
							dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i><br>"
					else dat += "Empty<BR>"
					dat += "<br>"
				else dat += "<b>Storage Tank 1 Missing!</b><br>"
				if (src.storage_tank_2)
					dat += "<b>Storage Tank 2:</b> ([src.storage_tank_2.reagents.total_volume]/[src.storage_tank_2.reagents.maximum_volume])<br>"
					if(src.storage_tank_2.reagents.reagent_list.len)
						for(var/current_id in storage_tank_2.reagents.reagent_list)
							var/datum/reagent/current_reagent = storage_tank_2.reagents.reagent_list[current_id]
							dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i><br>"
					else dat += "Empty<BR>"
					dat += "<br>"
				else dat += "<b>Storage Tank 2 Missing!</b><br>"
				// Inserted Beaker or whatever
				if (src.inserted)
					dat += "<B>Receptacle:</B> [src.inserted] ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><BR>"
					dat += "<b>Contents:</b> "
					if(src.inserted.reagents.reagent_list.len)
						for(var/current_id in inserted.reagents.reagent_list)
							var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
							dat += "<BR><i>[current_reagent.volume] units of [current_reagent.name]</i>"
					else dat += "Empty<BR>"
				else dat += "<B>No receptacle inserted!</B><BR>"

				if(src.ingredients.len)
					dat += "<BR><B>[src.ingredients.len] Items Ready for Extraction</B>"
				else
					dat += "<BR><B>No Items inserted!</B>"

			else if (src.mode == "extraction")
				dat += "<b><u>Extraction Management</u></b><br><br>"
				if (src.autoextract)
					dat += "<b>Auto-Extraction:</b> <A href='?src=\ref[src];autoextract=1'>Enabled</A>"
				else
					dat += "<b>Auto-Extraction:</b> <A href='?src=\ref[src];autoextract=1'>Disabled</A>"
				dat += "<br>"
				if (src.extract_to)
					dat += "<b>Extraction Target:</b> <A href='?src=\ref[src];extracttarget=1'>[src.extract_to]</A> ([src.extract_to.reagents.total_volume]/[src.extract_to.reagents.maximum_volume])"
					if (src.extract_to == src.inserted) dat += "<A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A>"
				else dat += "<A href='?src=\ref[src];extracttarget=1'><b>No current extraction target set.</b></A>"

				if(src.ingredients.len)
					dat += "<br><br><B>Extractable Items:</B><br><br>"
					for (var/obj/item/I in src.ingredients)
						dat += "* [I]<br>"
						dat += "<A href='?src=\ref[src];extractingred=\ref[I]'>(Extract)</A> <A href='?src=\ref[src];ejectingred=\ref[I]'>(Eject)</A><br>"
				else dat += "<br><br><B>No Items inserted!</B>"

			else if (src.mode == "transference")
				dat += "<b><u>Transfer Management</u></b><br><br>"

				if (src.inserted)
					dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.inserted]'><b>[src.inserted]:</b></A> ([src.inserted.reagents.total_volume]/[src.inserted.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.inserted]'>(Flush All)</A> <A href='?src=\ref[src];ejectbeaker=1'>(Eject)</A><br>"
					if(src.inserted.reagents.reagent_list.len)
						for(var/current_id in inserted.reagents.reagent_list)
							var/datum/reagent/current_reagent = inserted.reagents.reagent_list[current_id]
							dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.inserted];flush_reagent=[current_id]'>(X)</A><br>"
					else dat += "Empty<BR>"
				else dat += "<b>No receptacle inserted!</b><br>"

				dat += "<br>"

				dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.storage_tank_1]'><b>Storage Tank 1:</b></A> ([src.storage_tank_1.reagents.total_volume]/[src.storage_tank_1.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.storage_tank_1]'>(Flush All)</A><br>"
				if(src.storage_tank_1.reagents.reagent_list.len)
					for(var/current_id in storage_tank_1.reagents.reagent_list)
						var/datum/reagent/current_reagent = storage_tank_1.reagents.reagent_list[current_id]
						dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.storage_tank_1];flush_reagent=[current_id]'>(X)</A><br>"
				else dat += "Empty<BR>"

				dat += "<br>"
				dat += "<A href='?src=\ref[src];chemtransfer=\ref[src.storage_tank_2]'><b>Storage Tank 2:</b></A> ([src.storage_tank_2.reagents.total_volume]/[src.storage_tank_2.reagents.maximum_volume]) <A href='?src=\ref[src];flush=\ref[src.storage_tank_2]'>(Flush All)</A><br>"
				if(src.storage_tank_2.reagents.reagent_list.len)
					for(var/current_id in storage_tank_2.reagents.reagent_list)
						var/datum/reagent/current_reagent = storage_tank_2.reagents.reagent_list[current_id]
						dat += "* <i>[current_reagent.volume] units of [current_reagent.name]</i> <A href='?src=\ref[src];flush=\ref[src.storage_tank_2];flush_reagent=[current_id]'>(X)</A><br>"
				else dat += "Empty<BR>"

			else
				dat += {"<b>Software Error.</b><br>
				<A href='?src=\ref[src];page=1'>Please click here to return to the Overview.</A>"}

			dat += "<HR>"
			dat += "<b><u>Mode:</u></b> <A href='?src=\ref[src];page=1'>(Overview)</A> <A href='?src=\ref[src];page=2'>(Extraction)</A> <A href='?src=\ref[src];page=3'>(Transference)</A>"

			user.Browse(dat.Join(), "window=rextractor;size=370x500")
			onclose(user, "rextractor")
		else
			return ..()

	attack_self(mob/user)
		attack_hand(user)

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		return

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.updateUsrDialog()

	Topic(href, href_list)
		if(BOUNDS_DIST(usr, src) > 0 && !issilicon(usr) && !isAI(usr) )
			boutput(usr, "<span class='alert'>You need to be closer to the extractor to do that!</span>")
			return
		if(href_list["page"])
			var/ops = text2num_safe(href_list["page"])
			switch(ops)
				if(2) src.mode = "extraction"
				if(3) src.mode = "transference"
				else src.mode = "overview"
			src.updateUsrDialog()

		else if(href_list["ejectbeaker"])
			if (!src.inserted) boutput(usr, "<span class='alert'>No receptacle found to eject.</span>")
			else
				if (src.inserted == src.extract_to) src.extract_to = null
				src.inserted.set_loc(src.output_target)
				usr.put_in_hand_or_eject(inserted)
				src.inserted = null
			src.updateUsrDialog()

		else if(href_list["ejectingred"])
			var/obj/item/I = locate(href_list["ejectingred"]) in src
			if (istype(I))
				src.ingredients.Remove(I)
				I.set_loc(src.output_target)
				boutput(usr, "<span class='notice'>You eject [I] from the machine!</span>")
			src.updateUsrDialog()

		else if (href_list["autoextract"])
			src.autoextract = !src.autoextract
			src.updateUsrDialog()

		else if (href_list["flush_reagent"])
			var/id = href_list["flush_reagent"]
			var/obj/item/reagent_containers/T = locate(href_list["flush"]) in src
			if (istype(T, /obj/item/reagent_containers/food/drinks) || istype(T, /obj/item/reagent_containers/glass) && T.reagents)
				T.reagents.remove_reagent(id, 500)
			src.updateUsrDialog()

		else if (href_list["flush"])
			var/obj/item/reagent_containers/T = locate(href_list["flush"]) in src
			if (istype(T, /obj/item/reagent_containers/food/drinks) || istype(T, /obj/item/reagent_containers/glass) && T.reagents)
				T.reagents.clear_reagents()
			src.updateUsrDialog()

		else if(href_list["extracttarget"])
			var/list/ext_targets = list(src.storage_tank_1,src.storage_tank_2)
			if (src.inserted) ext_targets.Add(src.inserted)
			var/target = input(usr, "Extract to which target?", "Reagent Extractor", 0) in ext_targets
			if(BOUNDS_DIST(usr, src) > 0) return
			src.extract_to = target
			src.updateUsrDialog()

		else if(href_list["extractingred"])
			if (!src.extract_to)
				boutput(usr, "<span class='alert'>You must first select an extraction target.</span>")
			else
				if (src.extract_to.reagents.total_volume == src.extract_to.reagents.maximum_volume)
					boutput(usr, "<span class='alert'>The extraction target is already full.</span>")
				else
					var/obj/item/I = locate(href_list["extractingred"]) in src
					if (!istype(I) || !I.reagents)
						return

					src.doExtract(I)
					src.ingredients -= I
					qdel(I)
			src.updateUsrDialog()

		else if(href_list["chemtransfer"])
			var/obj/item/reagent_containers/glass/G = locate(href_list["chemtransfer"]) in src
			if (!G)
				boutput(usr, "<span class='alert'>Transfer target not found.</span>")
				src.updateUsrDialog()
				return
			else if (!G.reagents.total_volume)
				boutput(usr, "<span class='alert'>Nothing in container to transfer.</span>")
				src.updateUsrDialog()
				return

			var/list/ext_targets = list(src.storage_tank_1,src.storage_tank_2)
			if (src.inserted) ext_targets.Add(src.inserted)
			ext_targets.Remove(G)
			var/target = input(usr, "Transfer to which target?", "Reagent Extractor", 0) in ext_targets
			if(BOUNDS_DIST(usr, src) > 0) return
			var/obj/item/reagent_containers/glass/T = target

			if (!T) boutput(usr, "<span class='alert'>Transfer target not found.</span>")
			else if (G == T) boutput(usr, "<span class='alert'>Cannot transfer a container's contents to itself.</span>")
			else
				var/amt = input(usr, "Transfer how many units?", "Chemical Transfer", 0) as null|num
				if(!isnum_safe(amt))
					return
				if(BOUNDS_DIST(usr, src) > 0) return
				if (amt < 1) boutput(usr, "<span class='alert'>Invalid transfer quantity.</span>")
				else G.reagents.trans_to(T,amt)

			src.updateUsrDialog()

/obj/item/robot_chemaster/prototype/proc/doExtract(var/obj/item/I)
	// Welp -- we don't want anyone extracting these. They'll probably
	// feed them to monkeys and then exsanguinate them trying to get at the chemicals.
	if (istype(I, /obj/item/reagent_containers/food/snacks/candy/jellybean/everyflavor))
		src.extract_to.reagents.add_reagent("sugar", 50)
		return

	I.reagents.trans_to(src.extract_to, I.reagents.total_volume)

/obj/item/robot_chemaster/prototype/proc/canExtract(O)
	. = FALSE
	for(var/check_path in src.allowed)
		if(istype(O, check_path))
			return TRUE

/obj/item/robot_chemaster/prototype/proc/tryLoading(var/obj/item/O, var/mob/user as mob)
	// Pre: make sure that the item type can be extracted
	if (src.autoextract)
		if (!src.extract_to)
			boutput(user, "<span class='alert'>You must first select an extraction target if you want items to be automatically extracted.</span>")
			return FALSE
		if (src.extract_to.reagents.total_volume >= src.extract_to.reagents.maximum_volume)
			boutput(user, "<span class='alert'>The auto-extraction target is full.</span>")
			return FALSE
		src.doExtract(O)
		qdel(O)
		return TRUE
	else
		O.set_loc(src)
		src.ingredients += O
		return TRUE
