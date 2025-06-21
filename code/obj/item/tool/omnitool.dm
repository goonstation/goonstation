/obj/item/tool/omnitool
	name = "omnitool"
	desc = "Multiple tools in one, like an old-fashioned Swiss army knife. Truly, we are living in the future."
	icon = 'icons/obj/items/tools/omnitool.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	HELP_MESSAGE_OVERRIDE(null)
	var/prefix = "omnitool" //! Prefix for the tool's icon_state
	var/welding = FALSE
	var/animated_changes = FALSE //! Play an animation after mode is switched
	var/animated_delay = FALSE //! Play an animation with the action bar (if there is a delay)
	var/switch_delay = 0 SECONDS //! Time to manually switch between modes, or 0 for instant switching.

	custom_suicide = 1

	///List of tool settings
	var/list/modes = list(OMNI_MODE_PRYING, OMNI_MODE_SCREWING, OMNI_MODE_PULSING, OMNI_MODE_WRENCHING, OMNI_MODE_SNIPPING)
	var/mode = OMNI_MODE_PRYING //!The current tool setting

	var/list/datum/contextAction/contexts = list()

	New()
		contextLayout = new /datum/contextLayout/experimentalcircle
		..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby))
		src.change_mode(src.mode, null)

		// Don't bother with the context menu if there are only two options to choose from
		if(length(src.modes) > 2)
			for(var/actionType in childrentypesof(/datum/contextAction/omnitool))
				var/datum/contextAction/omnitool/action = new actionType()
				if (action.mode in src.modes)
					src.contexts += action

	attack_self(var/mob/user)
		if(src.contexts)
			user.showContextActions(src.contexts, src, src.contextLayout)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.mode == OMNI_MODE_PRYING)
			if (is_special || !pry_surgery(target, user))
				return ..()
		else if (src.mode == OMNI_MODE_WELDING)
			if (is_special)
				return ..()
			if (src.welding && ishuman(target) && (user.a_intent != INTENT_HARM))
				var/mob/living/carbon/human/H = target
				if (H.bleeding || (H.organHolder?.back_op_stage > BACK_SURGERY_OPENED && user.zone_sel.selecting == "chest"))
					if (!src.cautery_surgery(H, user, 15, src.welding))
						return ..()
			else
				..()
		else
			..()

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		if(src.mode == OMNI_MODE_PULSING)
			get_and_return_netid(target,user)
		else if(src.mode == OMNI_MODE_SOLDERING)
			var/datum/component/soldering/solder_comp = src.GetComponent(/datum/component/soldering)
			solder_comp.repair_deconstruction_buttons(target, user)

	MouseDrop_T(atom/target, mob/user)
		if(src.mode == OMNI_MODE_DECON)
			src.pre_attackby(src, target, user)
		..()

	get_desc()
		. += "It is currently set to [mode_to_text(src.mode)] mode."

	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] stabs and beats [himself_or_herself(user)] with each tool in the [src] in rapid succession.</b>"))
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		return 1

	dropped(var/mob/user)
		. = ..()
		// Don't close context actions while deconstructing things
		if(src.mode == OMNI_MODE_DECON || user.isContextActionTarget(src))
			user.closeContextActions()

	/// Switch modes with a delay, if it exists
	proc/change_mode_delayed(var/mode, var/mob/holder)
		if(switch_delay)
			if(animated_delay)
				flick("[src.prefix]-delay-[mode_to_text(mode)]", src)
				playsound(src, 'sound/machines/click.ogg', 15, TRUE, pitch = 1.25)
			actions.start(new/datum/action/bar/icon/omnitool_switch(src, mode, "[prefix]-[mode_to_text(mode)]", switch_delay, src.animated_delay), holder)
		else
			src.change_mode(mode, holder)

	/// Switch modes now
	proc/change_mode(var/new_mode, var/mob/holder)
		if(src.mode == OMNI_MODE_DECON)
			if(holder)
				holder.closeContextActions() // Close deconstruction context actions
		tooltip_rebuild = TRUE
		var/obj/item/currtype = mode_to_type(new_mode)
		src.mode = new_mode
		src.force = initial(currtype.force)
		src.tool_flags = initial(currtype.tool_flags)
		src.throwforce = initial(currtype.throwforce)
		src.throw_range = initial(currtype.throw_range)
		src.throw_speed = initial(currtype.throw_speed)
		src.stamina_damage = initial(currtype.stamina_damage)
		src.stamina_cost = initial(currtype.stamina_cost)
		src.stamina_crit_chance = initial(currtype.stamina_crit_chance)
		src.hit_type = initial(currtype.hit_type)
		src.hitsound = initial(currtype.hitsound)
		if(mode != OMNI_MODE_WELDING)
			set_icon_state("[prefix]-[mode_to_text(mode)]")
			if(src.animated_changes)
				FLICK(("[prefix]-swap-[mode_to_text(mode)]"), src)
		if(holder)
			holder.update_inhands()
		switch (src.mode)
			if (OMNI_MODE_PRYING)
				src.setItemSpecial(/datum/item_special/tile_fling)
			if (OMNI_MODE_PULSING)
				src.setItemSpecial(/datum/item_special/elecflash)
			if (OMNI_MODE_SCREWING)
				src.setItemSpecial(/datum/item_special/jab)
			if (OMNI_MODE_SNIPPING)
				src.setItemSpecial(/datum/item_special/simple)
			if (OMNI_MODE_WRENCHING)
				src.setItemSpecial(/datum/item_special/simple)
			if (OMNI_MODE_CUTTING)
				src.setItemSpecial(/datum/item_special/double)
			if(OMNI_MODE_WELDING)
				src.setItemSpecial(/datum/item_special/flame)
				if(get_fuel())
					set_icon_state("[prefix]-weldingtool-on")
					src.force = 15
					hit_type = DAMAGE_BURN
					welding = TRUE
				else
					set_icon_state("[prefix]-weldingtool-off")
					welding = FALSE
			if(OMNI_MODE_DECON)
				src.setItemSpecial(/datum/item_special/simple)
			if(OMNI_MODE_SOLDERING)
				src.setItemSpecial(/datum/item_special/simple)

	proc/pre_attackby(source, atom/target, mob/user)
		if(src.mode == OMNI_MODE_DECON)
			var/datum/component/deconstructing/decon_comp = src.GetComponent(/datum/component/deconstructing)
			return decon_comp.pre_attackby_decon(target, user, src)

	get_help_message(dist, mob/user)
		if (istype(src, /obj/item/tool/omnitool/syndicate))
			var/keybind = "Default: CTRL + X"
			var/datum/keymap/current_keymap = user.client.keymap
			for (var/key in current_keymap.keys)
				if (current_keymap.keys[key] == "flex")
					keybind = current_keymap.unparse_keybind(key)
					break
			return "Hit the omnitool on a piece of clothing to hide it. Retrieve the tool by using the <b>*flex</b> ([keybind]) emote."
		else
			return null

	proc/mode_to_text(var/omni_mode)
		switch(omni_mode)
			if(OMNI_MODE_PRYING) return "prying"
			if(OMNI_MODE_SNIPPING) return "snipping"
			if(OMNI_MODE_WRENCHING) return "wrenching"
			if(OMNI_MODE_SCREWING) return "screwing"
			if(OMNI_MODE_PULSING) return "pulsing"
			if(OMNI_MODE_CUTTING) return "cutting"
			if(OMNI_MODE_WELDING) return "welding"
			if(OMNI_MODE_DECON) return "deconstruction"
			if(OMNI_MODE_SOLDERING) return "soldering"
			else return null

	proc/mode_to_type(var/omni_mode)
		switch(omni_mode)
			if(OMNI_MODE_PRYING) return /obj/item/crowbar
			if(OMNI_MODE_SNIPPING) return /obj/item/wirecutters
			if(OMNI_MODE_WRENCHING) return /obj/item/wrench
			if(OMNI_MODE_SCREWING) return /obj/item/screwdriver
			if(OMNI_MODE_PULSING) return /obj/item/device/multitool
			if(OMNI_MODE_CUTTING) return /obj/item/kitchen/utensil/knife
			if(OMNI_MODE_WELDING) return /obj/item/weldingtool
			if(OMNI_MODE_DECON) return /obj/item/deconstructor
			if(OMNI_MODE_SOLDERING) return /obj/item/electronics/soldering
			else return null

	//
	// ========== Welder stuff ==========
	//
	proc/get_fuel()
		if (reagents)
			return reagents.get_reagent_amount("fuel")
		return 0

	proc/use_fuel(var/amount)
		amount = min(get_fuel(), amount)
		if (reagents)
			reagents.remove_reagent("fuel", amount)
		return

	proc/eyecheck(mob/user)
		if(user.isBlindImmune())
			return
		//check eye protection
		var/safety = 0
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!H.sight_check()) //don't blind if we're already blind
				safety = 2
			// we want to check for the thermals first so having a polarized eye doesn't protect you if you also have a thermal eye
			else if (istype(H.glasses, /obj/item/clothing/glasses/thermal) || H.eye_istype(/obj/item/organ/eye/cyber/thermal) || istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
				safety = -1
			else if (istype(H.head, /obj/item/clothing/head/helmet/welding))
				var/obj/item/clothing/head/helmet/welding/WH = H.head
				if(!WH.up)
					safety = 2
				else
					safety = 0
			else if (istype(H.head, /obj/item/clothing/head/helmet/space/industrial))
				var/obj/item/clothing/head/helmet/space/industrial/helmet = H.head
				if (helmet.has_visor && helmet.visor_enabled)
					safety = -1
				else
					safety = 2
			else if (istype(H.head, /obj/item/clothing/head/helmet/space))
				safety = 2
			else if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || H.eye_istype(/obj/item/organ/eye/cyber/sunglass))
				safety = 1
		switch (safety)
			if (1)
				boutput(user, SPAN_ALERT("Your eyes sting a little."))
				user.take_eye_damage(rand(1, 2))
			if (0)
				boutput(user, SPAN_ALERT("Your eyes burn."))
				user.take_eye_damage(rand(2, 4))
			if (-1)
				boutput(user, SPAN_ALERT("<b>Your goggles intensify the welder's glow. Your eyes itch and burn severely.</b>"))
				user.change_eye_blurry(rand(12, 20))
				user.take_eye_damage(rand(12, 16))

	proc/try_weld(mob/user, var/fuel_amt = 2, var/use_amt = -1, var/noisy=1, var/burn_eyes=1) //fuel amt is how much fuel is needed to weld, use_amt is how much fuel is used per action
		if (src.welding)
			if(use_amt == -1)
				use_amt = fuel_amt
			if (src.get_fuel() < fuel_amt)
				boutput(user, SPAN_NOTICE("Need more fuel!"))
				return 0 //welding, doesnt have fuel
			src.use_fuel(use_amt)
			if(noisy)
				playsound(user.loc, list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')[noisy], 40, 1)
			if(burn_eyes)
				src.eyecheck(user)
			return 1 //welding, has fuel
		return 0 //not welding

/obj/item/tool/omnitool/syndicate
	icon_state = "syndicate-omnitool-prying"
	prefix = "syndicate-omnitool"
	modes = list(OMNI_MODE_PRYING, OMNI_MODE_SCREWING, OMNI_MODE_PULSING, OMNI_MODE_WRENCHING, OMNI_MODE_SNIPPING, OMNI_MODE_CUTTING, OMNI_MODE_WELDING)
	c_flags = EQUIPPED_WHILE_HELD

	afterattack(obj/O, mob/user)
		if ((istype(O, /obj/reagent_dispensers/fueltank) || istype(O, /obj/item/reagent_containers/food/drinks/fueltank)) && BOUNDS_DIST(src, O) == 0)
			if (O.reagents.total_volume)
				O.reagents.trans_to(src, 20)
				boutput(user, SPAN_NOTICE("Welder refueled"))
				playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
			else
				boutput(user, SPAN_ALERT("The [O.name] is empty!"))
			return

		if(src.welding)
			if(!(get_fuel() > 0))
				src.change_mode(OMNI_MODE_WELDING, user)

		if (O.loc == user && O != src && istype(O, /obj/item/clothing) && !istype(O, /obj/item/clothing/mask/cigarette))
			boutput(user, SPAN_HINT("You hide the set of tools inside \the [O]. (Use the flex emote while wearing the clothing item to retrieve it.)"))
			user.u_equip(src)
			src.set_loc(O)
			src.dropped(user)
			return

		..()

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		. = ..()
		src.create_reagents(20)
		reagents.add_reagent("fuel", 20)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	setupProperties()
		..()
		setProperty("conductivity", 0)

/obj/item/tool/omnitool/silicon
	prefix = "silicon-omnitool"
	desc = "A set of tools on telescopic arms. It's the robotic future!"
	animated_changes = TRUE

TYPEINFO(/obj/item/tool/omnitool/dualconstruction_device)
	mats = list("dense_property_ultra" = 10,
				"heat_dense" = 10)
/obj/item/tool/omnitool/dualconstruction_device
	name = "dualconstruction device"
	icon_state = "salvager-dual-deconstruction"
	prefix = "salvager-dual"
	desc = "A handy part of a salvager's toolkit that can swap between the functionality of a deconstruction device or a soldering iron."
	w_class = W_CLASS_NORMAL
	animated_delay = TRUE
	modes = list(OMNI_MODE_DECON, OMNI_MODE_SOLDERING)
	mode = OMNI_MODE_DECON
	switch_delay = 1.5 SECONDS

	New()
		..()
		src.AddComponent(/datum/component/soldering, 1.5 SECONDS)
		src.AddComponent(/datum/component/deconstructing, 0.5 SECONDS, 1)

	attack_self(mob/user)
		// Don't bother with the context menu. There are only two options to choose from!
		if(!can_act(user) || !in_interact_range(src, user))
			return FALSE
		if(src.mode == OMNI_MODE_DECON)
			src.change_mode_delayed(OMNI_MODE_SOLDERING, user)
		else if(src.mode == OMNI_MODE_SOLDERING)
			src.change_mode_delayed(OMNI_MODE_DECON, user)

// Context actions for switching omnitool modes
/datum/contextAction/omnitool
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "wrench"
	var/mode = OMNI_MODE_PRYING

	execute(var/obj/item/tool/omnitool/omnitool, var/mob/user)
		if (!istype(omnitool))
			return
		omnitool.change_mode_delayed(src.mode, user)

	checkRequirements(var/obj/item/tool/omnitool/omnitool, var/mob/user)
		if(!can_act(user) || !in_interact_range(omnitool, user))
			return FALSE
		return omnitool in user

	prying
		name = "Crowbar"
		icon_state = "bar"
		mode = OMNI_MODE_PRYING
	screwing
		name = "Screwdriver"
		icon_state = "screw"
		mode = OMNI_MODE_SCREWING
	pulsing
		name = "Multitool"
		icon_state = "pulse"
		mode = OMNI_MODE_PULSING
	snipping
		name = "Wirecutters"
		icon_state = "cut"
		mode = OMNI_MODE_SNIPPING
	wrenching
		name = "Wrench"
		icon_state = "wrench"
		mode = OMNI_MODE_WRENCHING
	cutting
		name = "Knife"
		icon_state = "knife"
		mode = OMNI_MODE_CUTTING
	welding
		name = "Welding tool"
		icon_state = "weld"
		mode = OMNI_MODE_WELDING

// Action bar delay for omnitool switching
/datum/action/bar/icon/omnitool_switch
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/omnitool.dmi'
	icon_state = "omnitool-prying"
	var/prev_icon_state = null // Save the previous state in case animation is interrupted
	var/is_animated = FALSE // Change the icon_state if action is animated, in case animation flick ends early
	var/mob/user = null
	var/obj/item/tool/omnitool/omni = null
	var/mode

	New(var/obj/item/tool/omnitool/tool, var/new_mode, var/new_icon_state, var/duration, var/is_animated = FALSE)
		src.mode = new_mode
		src.omni = tool
		src.icon_state = new_icon_state
		src.is_animated = is_animated
		src.duration = duration
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, omni) > 0 || omni == null || user == null || (user.r_hand != omni && user.l_hand != omni))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.user = owner
		if(BOUNDS_DIST(owner, omni) > 0 || omni == null || (user.r_hand != omni && user.l_hand != omni))
			interrupt(INTERRUPT_ALWAYS)
			return
		if(src.is_animated)
			src.prev_icon_state = src.omni.icon_state
			src.omni.icon_state = src.icon_state

	onEnd()
		..()
		if(BOUNDS_DIST(owner, omni) > 0 || omni == null || user == null || (user.r_hand != omni && user.l_hand != omni))
			interrupt(INTERRUPT_ALWAYS)
			return
		omni.change_mode(src.mode, user)

	onInterrupt()
		if (owner)
			boutput(owner, SPAN_ALERT("Tool switching interrupted!"))
		if(src.is_animated)
			src.omni.icon_state = src.prev_icon_state
		..()
