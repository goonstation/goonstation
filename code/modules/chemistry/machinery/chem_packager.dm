#define CHEMMASTER_MINIMUM_REAGENT 5 //!mininum reagent for pills, bottles and patches
#define CHEMMASTER_NO_CONTAINER_MAX 24 //!maximum number of unboxed pills/patches
#define CHEMMASTER_ITEMNAME_MAXSIZE 24 //!maximum characters allowed for the item name
#define CHEMMASTER_MAX_PILL 22 //!22 pill icons
#define CHEMMASTER_MAX_CANS 26 //!26 flavours of cans

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
	var/obj/beaker = null
	var/list/beaker_cache = null
	///If TRUE, the beaker cache will be rebuilt on ui_data
	var/rebuild_cache = FALSE
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

	var/obj/item/robot_chemaster/prototype/parent_item = null

	New(var/loc, var/obj/item/robot_chemaster/prototype/parent_item = null)
		..()
		if (!src.emagged && islist(global.chem_whitelist) && length(global.chem_whitelist))
			src.whitelist = global.chem_whitelist
		AddComponent(/datum/component/transfer_output)
		src.parent_item = parent_item

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

		if(istype(src.beaker, /obj/reagent_dispensers/chemicalbarrel))
			remove_barrel(src.beaker)
			return

		if(!src.roboworking)
			var/obj/item/I = src.beaker
			TRANSFER_OR_DROP(src, I) // causes Exited proc to be called
			user?.put_in_hand_or_eject(I)
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
		.["name_max_len"] = CHEMMASTER_ITEMNAME_MAXSIZE
		var/list/patch_icons = list()

		for(var/patch_path in patches_list)
			var/obj/item/reagent_containers/patch = new patch_path(src)
			var/icon/patch_icon = icon(patch.icon, patch.icon_state)
			var/patch_capacity = patch.initial_volume
			patch_icons.Add(list(list(patch_capacity, icon2base64(patch_icon))))
			qdel(patch)
		.["patch_icons"] = patch_icons

	proc/rebuild_beaker_cache()
		if(QDELETED(src.beaker))
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
					name = current_reagent.name,
					id = reagent_id,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					volume = current_reagent.volume
				)))

	proc/invalidate_cache()
		src.rebuild_cache = TRUE

	proc/manufacture_name(var/param_name)
		var/name = param_name
		name = trimtext(copytext(sanitize(html_encode(name)), 1, CHEMMASTER_ITEMNAME_MAXSIZE))
		if(isnull(name) || !length(name) || name == " ")
			name = null
			if(src.beaker)
				name = src.beaker.reagents.get_master_reagent_name()
		return name

	proc/try_attach_barrel(var/obj/reagent_dispensers/chemicalbarrel/barrel, var/mob/user)
		if (src.status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (src.beaker == barrel)
			user.show_text("The [barrel.name] is already connected to the [src.name]!", "red")
			return

		if(BOUNDS_DIST(src, user) > 0)
			user.show_text("The [src.name] is too far away to mess with!", "red")
			return

		if (GET_DIST(barrel, src) > 1)
			usr.show_text("The [src.name] is too far away from the [barrel.name] to hook up!", "red")
			return

		if(src.beaker)
			src.eject_beaker(user)

		src.beaker = barrel
		barrel.linked_machine = src
		boutput(user, "You hook the [src.beaker] up to the [src.name].")
		RegisterSignal(barrel, COMSIG_MOVABLE_MOVED, PROC_REF(remove_barrel))
		RegisterSignal(barrel, COMSIG_ATOM_REAGENT_CHANGE, PROC_REF(invalidate_cache))

		var/tube_x = 5 //where the tube connects to the chemmaster (changes with dir)
		var/tube_y = -5
		if(dir == EAST)
			tube_x = 7
			tube_y = 6
		if(dir == WEST)
			tube_x = -8
			tube_y = 0
		var/datum/lineResult/result = drawLineImg(src, barrel, "chemmaster", "chemmaster_end", src.pixel_x + tube_x, src.pixel_y + tube_y, barrel.pixel_x + 6, barrel.pixel_y + 8)
		result.lineImage.pixel_x = -src.pixel_x
		result.lineImage.pixel_y = -src.pixel_y
		if(src.layer > barrel.layer) //this should ensure it renders above both the barrel and chemmaster
			result.lineImage.layer = src.layer + 0.1
		else
			result.lineImage.layer = barrel.layer + 0.1
		src.UpdateOverlays(result.lineImage, "tube")

		rebuild_beaker_cache()
		global.tgui_process.update_uis(src)
		src.UpdateIcon()

	proc/remove_barrel(var/obj/reagent_dispensers/chemicalbarrel/barrel)
		barrel.linked_machine = null
		UnregisterSignal(src.beaker, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(src.beaker, COMSIG_ATOM_REAGENT_CHANGE)
		src.beaker = null
		rebuild_beaker_cache()
		src.UpdateIcon()
		global.tgui_process.update_uis(src)
		src.UpdateOverlays(null, "tube")

	mouse_drop(atom/over_object, src_location, over_location)
		if (istype(over_object, /obj/reagent_dispensers/chemicalbarrel))
			try_attach_barrel(over_object, usr)
		..()

	ui_data(mob/user)
		. = list()

		if(!QDELETED(src.beaker))
			.["default_name"] = src.beaker.reagents.get_master_reagent_name()
		else
			.["default_name"] = null
		if (src.rebuild_cache)
			src.rebuild_beaker_cache()
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
				if(use_pill_bottle || pillcount > CHEMMASTER_NO_CONTAINER_MAX)
					if(!use_pill_bottle && pillcount > CHEMMASTER_NO_CONTAINER_MAX)
						src.visible_message(SPAN_ALERT("The [src]'s output limit beeps sternly, and a pill bottle is automatically dispensed!"))
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
					pill_bottle.rebuild_desc()

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
					boutput(ui.user, "[src] bottler makes a weird grinding noise. That can't be good.")
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

				patch.name = "[item_name] [patch.name]"
				patch.medical = src.check_patch_whitelist()
				src.beaker.reagents.trans_to(patch, reagent_amount)

				logTheThing(LOG_COMBAT, usr, "used the [src] to create [patch] containing [log_reagents(patch)] at [log_loc(src)].")

				patch.on_reagent_change()

				if(!QDELETED(patch))
					TRANSFER_OR_DROP(src, patch)
					ui.user.put_in_hand_or_eject(patch)
				else
					boutput(ui.user, "[src] patcher makes a weird grinding noise. That can't be good.")

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
				if(use_box || patchcount > CHEMMASTER_NO_CONTAINER_MAX)
					if(!use_box && patchcount > CHEMMASTER_NO_CONTAINER_MAX)
						src.visible_message(SPAN_ALERT("The [src]'s output limit beeps sternly, and a patch box is automatically dispensed!"))
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

				var/failed = FALSE
				for(var/i = 0, i < patchcount, ++i)
					var/obj/item/reagent_containers/patch/P = new patch_path(src)
					P.name = "[item_name] [P.name]"
					P.medical = is_medical_patch
					src.beaker.reagents.trans_to(P, reagent_amount)
					P.on_reagent_change()
					if(QDELETED(P))
						failed = TRUE
						continue
					if(patch_box)
						P.set_loc(patch_box)
					else
						TRANSFER_OR_DROP(src, P)

				if(failed)
					boutput(ui.user, "[src] patcher makes a weird grinding noise. That can't be good.")

				if(patch_box)
					TRANSFER_OR_DROP(src, patch_box)
					ui.user.put_in_hand_or_eject(patch_box)

				if(!src.beaker.reagents.total_volume) // qol eject when empty
					eject_beaker(ui.user)

				rebuild_beaker_cache()
				. = TRUE

	update_icon()
		if(src.beaker)
			if(istype(src.beaker, /obj/reagent_dispensers/chemicalbarrel))
				icon_state = "mixer_barrel"
			else
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

	ui_status()
		if (src.parent_item)
			return src.parent_item.ui_status(arglist(args))
		else
			return ..()

#undef CHEMMASTER_NO_CONTAINER_MAX
#undef CHEMMASTER_ITEMNAME_MAXSIZE
#undef CHEMMASTER_MAX_PILL
#undef CHEMMASTER_MAX_CANS
#undef CHEMMASTER_MINIMUM_REAGENT
