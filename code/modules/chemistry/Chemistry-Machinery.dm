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
	desc = "A device used for the slow but precise heating and cooling of chemicals."
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/heater.dmi'
	icon_state = "heater"
	flags = NOSPLASH | TGUI_INTERACTIVE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	power_usage = 50
	processing_tier = PROCESSING_HALF
	var/obj/beaker = null
	var/active = 0
	var/target_temp = T0C
	var/output_target = null
	var/mob/roboworking = null
	// The chemistry APC was largely meaningless, so I made dispensers/heaters require a power supply (Convair880).

	New()
		..()
		output_target = src.loc

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if (!tryInsert(B, user))
			return ..()

	proc/tryInsert(obj/item/reagent_containers/glass/B, var/mob/user)
		if(!istypes(B, list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/drinks/cocktailshaker))) //container paths are so baaad
			return
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
			. = TRUE
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
				if (prob(75))
					src.set_broken()
					return
			if(3)
				if (prob(50))
					src.set_broken()

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)
			return
		if (prob(25 * power/29))
			src.set_broken()

	bullet_act(obj/projectile/P)
		if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
			if(prob(P.power * P.proj_data?.ks_ratio / 2))
				src.set_broken()
		..()

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
				tryInsert(usr.equipped(), usr)
			if("adjustTemp")
				src.target_temp = clamp(params["temperature"], 0, 1000)
				src.UpdateIcon()
			if("start")
				if (!container?.reagents.total_volume)
					return
				src.active = 1
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

	process(mult)
		if (!active) return
		if (status & (NOPOWER|BROKEN) || !beaker || !beaker.reagents.total_volume)
			set_inactive()
			return

		var/datum/reagents/R = beaker:reagents
		R.temperature_reagents(target_temp, exposed_volume = (400 + R.total_volume * 5) * mult, change_cap = 100) //it uses juice in if the beaker is filled more. Or something.

		src.power_usage = 2000 + R.total_volume * 25

		if(abs(R.total_temperature - target_temp) <= 3)
			active = 0

		tgui_process.update_uis(src)
		..()

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

	power_change()
		. = ..()
		src.update_icon()

	update_icon()
		if (src.status & BROKEN)
			src.UpdateOverlays(null, "beaker", retain_cache=TRUE)
			src.icon_state = "heater-broken"
			return

		if (!src.beaker)
			src.UpdateOverlays(null, "beaker", retain_cache=TRUE)
			src.icon_state = "heater"
			return

		src.UpdateOverlays(SafeGetOverlayImage("beaker", 'icons/obj/heater.dmi', "heater-beaker"), "beaker")
		if (src.active && src.beaker:reagents && src.beaker:reagents:total_volume)
			if (target_temp > src.beaker:reagents:total_temperature)
				src.icon_state = "heater-heat"
			else if (target_temp < src.beaker:reagents:total_temperature)
				src.icon_state = "heater-cool"
			else
				src.icon_state = "heater-closed"
		else
			src.icon_state = "heater-closed"

	mouse_drop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, SPAN_ALERT("Only living mobs are able to set the Reagent Heater/Cooler's output target."))
			return

		if(BOUNDS_DIST(over_object, src) > 0)
			boutput(usr, SPAN_ALERT("The Reagent Heater/Cooler is too far away from the target!"))
			return

		if(BOUNDS_DIST(over_object, usr) > 0)
			boutput(usr, SPAN_ALERT("You are too far away from the target!"))
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, SPAN_NOTICE("You set the Reagent Heater/Cooler to output to [over_object]!"))

		else
			boutput(usr, SPAN_ALERT("You can't use that as an output target."))
		return

	set_broken()
		. = ..()
		if (.) return
		AddComponent(pick(/datum/component/equipment_fault/embers, /datum/component/equipment_fault/smoke), tool_flags = TOOL_WRENCHING | TOOL_SCREWING | TOOL_PRYING)
		animate_shake(src, 5, rand(3,8),rand(3,8))
		playsound(src, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)

	Exited(Obj, newloc)
		if(Obj == src.beaker)
			src.beaker = null
			src.UpdateIcon()
			tgui_process.update_uis(src)

	chemistry
		icon = 'icons/obj/heater_chem.dmi'

///////////////////////////////////////////////////////////////////////////////////////////////////
TYPEINFO(/obj/machinery/chem_shaker)
	mats = 10

// A lot of boilerplate code from this is borrowed from `/obj/machinery/chem_heater`.
/obj/machinery/chem_shaker
	name = "\improper Orbital Shaker"
	desc = "A machine which continuously agitates beakers and flasks when activated."
	icon = 'icons/obj/shaker.dmi'
#ifdef IN_MAP_EDITOR
	icon_state = "orbital_shaker-map"
#else
	icon_state = "orbital_shaker"
#endif
	anchored = ANCHORED
	flags = NOSPLASH
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	pixel_y = 4

	var/list/obj/item/reagent_containers/glass/held_containers = list()
	var/obj/dummy/platform_holder
	var/list/first_container_offsets = list("X" = 0, "Y" = 8)
	var/list/container_offsets = list ("X" = 10, "Y" = -4)
	var/active = FALSE
	var/emagged = FALSE
	/// The arrangement of the containers on the platform in the X direction.
	var/container_row_length = 1
	/// Also acts as the number of containers in the Y direction when divided by `src.container_row_length`.
	var/max_containers = 1
	/// The time it takes for the platform to complete one orbit.
	var/orbital_period = 0.6 SECONDS
	/// Radius of the platform's orbit in pixels.
	var/radius = 2
	/// How much force does the shaker apply on `process()`?
	var/physical_shock_force = 5

	New()
		..()
		src.platform_holder = new()
		src.platform_holder.icon = src.icon
		src.platform_holder.icon_state = "[src.icon_state]-platform"
		src.platform_holder.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
		src.platform_holder.appearance_flags |= KEEP_TOGETHER
		src.vis_contents.Add(src.platform_holder)

	disposing()
		for (var/obj/item/reagent_containers/glass/glass_container in src.held_containers)
			MOVE_OUT_TO_TURF_SAFE(glass_container, src)
			src.held_containers -= glass_container
		UnsubscribeProcess()
		..()

	attack_hand(mob/user)
		if (!can_act(user)) return
		switch (src.active)
			if (TRUE)
				if (src.emagged)
					boutput(user, SPAN_ALERT("[src] refuses to shut off!"))
					return FALSE
				src.set_inactive()
			if (FALSE)
				src.set_active()
		boutput(user, SPAN_NOTICE("You [!src.active ? "de" : ""]activate [src]."))

	attackby(obj/item/reagent_containers/glass/glass_container, var/mob/user)
		if(istype(glass_container, /obj/item/reagent_containers/glass))
			src.try_insert(glass_container, user)

	emag_act(mob/user, obj/item/card/emag/E)
		if (!src.emagged)
			src.emagged = TRUE
			boutput(user, SPAN_ALERT("[src]'s safeties have been disabled."))
			src.set_active()
			return TRUE
		return FALSE

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return

	blob_act(power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	attack_ai(mob/user as mob)
		return src.Attackhand(user)

	process(mult)
		..()
		if (src.status & (NOPOWER|BROKEN)) return src.set_inactive()
		for (var/obj/item/reagent_containers/glass/glass_container in src.held_containers)
			if (src.emagged)
				src.remove_container(glass_container)
				glass_container.throw_at(pick(range(5, src)), 5, 1)
				continue
			glass_container.reagents?.physical_shock(src.physical_shock_force)

	proc/arrange_containers()
		if (!src.count_held_containers()) return
		for (var/i in 1 to length(src.held_containers))
			if (!src.held_containers[i]) continue
			var/current_y = ceil(i / src.container_row_length)
			var/current_x = i - (src.container_row_length * (current_y - 1))
			src.held_containers[i].pixel_x = src.first_container_offsets["X"] + ((current_x - 1) * src.container_offsets["X"])
			src.held_containers[i].pixel_y = src.first_container_offsets["Y"] + ((current_y - 1) *src.container_offsets["Y"])

	proc/count_held_containers()
		var/count_buffer = 0
		for (var/i in 1 to length(src.held_containers))
			if (src.held_containers[i])
				++count_buffer
		return count_buffer

	proc/set_active()
		src.active = TRUE
		src.power_usage = src.emagged ? 1000 : 200
		animate_orbit(src.platform_holder, radius = src.radius, time = src.emagged ? src.orbital_period / 5 : src.orbital_period, loops = -1)
		if (src.emagged)
			src.audible_message(SPAN_ALERT("[src] is rotating a bit too fast!"))
		else
			src.audible_message(SPAN_NOTICE("[src] whirs to life, rotating its platform!"))
		if (!(src in processing_machines))
			SubscribeToProcess()

	proc/set_inactive()
		src.active = FALSE
		src.power_usage = 0
		animate(src.platform_holder, pixel_x = 0, pixel_y = 0, time = src.orbital_period/2, easing = SINE_EASING, flags = ANIMATION_LINEAR_TRANSFORM)
		src.audible_message(SPAN_NOTICE("[src] dies down, returning its platform to its initial position."))
		UnsubscribeProcess()

	proc/try_insert(obj/item/reagent_containers/glass/glass_container, var/mob/user)
		if (src.status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (src.count_held_containers() >= src.max_containers)
			boutput(user, SPAN_ALERT("There's too many beakers on the platform already!"))
			return

		if (isrobot(user))
			boutput(user, "Robot beakers won't work with this!")
			return

		user.drop_item(glass_container)
		glass_container.set_loc(src)
		glass_container.appearance_flags |= RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		glass_container.vis_flags |= VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
		glass_container.event_handler_flags |= NO_MOUSEDROP_QOL
		var/append_container = TRUE
		for (var/i in 1 to length(src.held_containers))
			if (!src.held_containers[i])
				src.held_containers[i] = glass_container
				append_container = FALSE
				break
		if (append_container)
			src.held_containers += glass_container
		src.platform_holder.vis_contents += glass_container
		src.arrange_containers()
		RegisterSignal(glass_container, COMSIG_ATTACKHAND, PROC_REF(remove_container))
		boutput(user, "You add the beaker to the machine!")

	proc/remove_container(obj/item/reagent_containers/glass/glass_container)
		if (!(glass_container in src.contents)) return
		for (var/i in 1 to length(src.held_containers))
			if (src.held_containers[i] == glass_container)
				src.held_containers[i] = null
		MOVE_OUT_TO_TURF_SAFE(glass_container, src)
		glass_container.appearance_flags = initial(glass_container.appearance_flags)
		glass_container.vis_flags = initial(glass_container.vis_flags)
		glass_container.event_handler_flags = initial(glass_container.event_handler_flags)
		src.platform_holder.vis_contents -= glass_container
		src.arrange_containers()
		UnregisterSignal(glass_container, COMSIG_ATTACKHAND)

	chemistry
		icon = 'icons/obj/shaker_chem.dmi'

TYPEINFO(/obj/machinery/chem_shaker/large)
	mats = 25
/obj/machinery/chem_shaker/large
	name = "large orbital shaker"
	icon_state = "orbital_shaker_large"
	max_containers = 4
	container_row_length = 2
	first_container_offsets = list("X" = -5, "Y" = 9)

	chemistry
		icon = 'icons/obj/shaker_chem.dmi'

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Run Script", PROC_REF(runscript))
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
			boutput( user, SPAN_ALERT("You can't seem to power it on!") )
			return
		ui_interact(user)
		return

	attackby(var/obj/item/reagent_containers/glass/B, var/mob/user)
		if (!istype(B, /obj/item/reagent_containers/glass))
			return
		if (isrobot(user)) return attack_ai(user)
		return src.Attackhand(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "ChemiCompiler", src.name)
			ui.open()

	ui_data(mob/user)
		. = executor.get_ui_data()

	ui_act(action, list/params)
		. = ..()
		if (.)
			return

		return executor.execute_ui_act(action, params)

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
			src.visible_message(SPAN_ALERT("The internal overflow safety dumps its contents all over the floor!."),SPAN_ALERT("You hear a tremendous gushing sound."))
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
	var/obj/submachine/chem_extractor/reagent_extractor
	var/obj/machinery/chem_master/che_master
	var/list/allowed = list(/obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/seashell)

	New()
		..()
		//Loc needs to be this item itself otherwise we get "nopower"
		reagent_extractor = new(src, src)
		che_master = new(src, src)
		AddComponent(/datum/component/transfer_input/quickloading, allowed, "tryLoading")

	//We don't want anything to do with /obj/item/robot_chemaster's attackby(...)
	attackby(var/obj/item/W, var/mob/user)
		return

	attack_self(mob/user as mob)
		reagent_extractor.ui_interact(user)
		che_master.ui_interact(user)

	attack_ai(var/mob/user as mob)
		return

	proc/tryLoading(atom/movable/incoming)
		reagent_extractor.tryLoading(incoming)
