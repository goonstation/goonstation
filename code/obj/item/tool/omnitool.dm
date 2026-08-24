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

	var/datum/omnimode/mode = null
	var/list/datum/omnimode/list_modes = list()
	///List of tool settings
	var/list/mode_types = list(
		/datum/omnimode/crowbar,
		/datum/omnimode/screwdriver,
		/datum/omnimode/multitool,
		/datum/omnimode/wrench,
		/datum/omnimode/wirecutters
	)

	var/list/datum/contextAction/contexts = list()

	New()
		contextLayout = new /datum/contextLayout/experimentalcircle
		..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby))

		for(var/omnimode_type in src.mode_types)
			var/datum/omnimode/omnimode = new omnimode_type()
			if(!omnimode)
				CRASH("Wrong Omnimode Type: [omnimode_type] | [src]")
			src.list_modes += omnimode
			var/datum/contextAction/omnitool/action = new(omnimode)
			src.contexts += action
			if(!src.mode)
				src.change_mode(omnimode, null)

	attack_self(var/mob/user)
		if(!can_act(user) || !in_interact_range(src, user))
			return FALSE
		if(length(src.list_modes) == 2)
			// Don't bother with the context menu. There are only two options to choose from!
			if(src.mode == src.list_modes[1])
				src.change_mode_delayed(src.list_modes[2], user)
			else
				src.change_mode_delayed(src.list_modes[1], user)
			return
		else if(src.contexts)
			user.showContextActions(src.contexts, src, src.contextLayout)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!src.mode)
			return ..()
		if(src.mode.on_attack(src, target, user, def_zone, is_special, params))
			return ..()
		return

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		src.mode?.on_attack_after(src, target, user, reach, params)

	MouseDrop_T(atom/target, mob/user)
		src.pre_attackby(src, target, user)
		..()

	get_desc()
		if(src.mode)
			. += "It is currently set to [src.mode.mode_name] mode."
		else
			. += "It is currently not set to any mode."

	suicide(var/mob/user)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] stabs and beats [himself_or_herself(user)] with each tool in the [src] in rapid succession.</b>"))
		take_bleeding_damage(user, null, 25, DAMAGE_STAB)
		user.TakeDamage("head", 160, 0)
		return 1

	dropped(var/mob/user)
		. = ..()
		src.mode?.on_drop(src, user)

	/// Switch modes with a delay, if it exists
	proc/change_mode_delayed(var/datum/omnimode/mode_new, var/mob/holder)
		if(switch_delay)
			if(animated_delay)
				flick("[src.prefix]-delay-[mode_new.mode_id]", src)
				playsound(src, 'sound/machines/click.ogg', 15, TRUE, pitch = 1.25)
			actions.start(new/datum/action/bar/icon/omnitool_switch(src, mode_new, "[prefix]-[mode_new.mode_id]", switch_delay, src.animated_delay), holder)
		else
			src.change_mode(mode_new, holder)

	/// Change to an omnitool mode based on its ID
	proc/change_mode_id(var/mode_id, var/mob/holder)
		for(var/datum/omnimode/mode in src.list_modes)
			if(mode.mode_id == mode_id)
				change_mode(mode, holder)
				return

	/// Switch modes now
	proc/change_mode(var/datum/omnimode/mode_new, var/mob/holder)
		src.mode?.on_mode_exit(holder, src)

		tooltip_rebuild = TRUE
		src.mode = mode_new
		var/obj/item/currtype = src.mode.item_type
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

		src.mode?.on_mode_enter(holder, src)
		if(holder)
			holder.update_inhands()

	proc/has_mode(var/mode_id)
		for(var/datum/omnimode/mode in src.list_modes)
			if(mode.mode_id == mode_id)
				return TRUE
		return FALSE

	proc/pre_attackby(source, atom/target, mob/user)
		return src.mode?.on_attack_pre(src, target, user)

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
	mode_types = list(
		/datum/omnimode/crowbar,
		/datum/omnimode/screwdriver,
		/datum/omnimode/multitool,
		/datum/omnimode/wrench,
		/datum/omnimode/wirecutters,
		/datum/omnimode/welder
	)
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

		src.mode?.on_attack_after(src, O, user)

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

/obj/item/tool/omnitool/knockoff
	name = "Super-Omnifunction Helper"
	desc = "Multiple tools in one, like an old-fashioned Swiss army knife. A lot like one, actually. They're still making these things?"
	prefix = "orange-omnitool"
	mode_types = list(
		/datum/omnimode/screwdriver,
		/datum/omnimode/knife,
		/datum/omnimode/wirecutters,
		/datum/omnimode/spoon,
		/datum/omnimode/fork,
		/datum/omnimode/bottle_opener
	)
	switch_delay = 0.5 SECONDS

/obj/item/tool/omnitool/silicon
	prefix = "silicon-omnitool"
	desc = "A set of tools on telescopic arms. It's the robotic future!"
	animated_changes = TRUE

TYPEINFO(/obj/item/tool/omnitool/dualconstruction_device)
	analyser_flags = parent_type::analyser_flags | ANALYSER_ELECTRONIC
	mats = list("dense_property_ultra" = 10,
				"heat_dense" = 10)
/obj/item/tool/omnitool/dualconstruction_device
	name = "dualconstruction device"
	icon_state = "salvager-dual-deconstruction"
	prefix = "salvager-dual"
	desc = "A handy part of a salvager's toolkit that can swap between the functionality of a deconstruction device or a soldering iron."
	w_class = W_CLASS_NORMAL
	animated_delay = TRUE
	mode_types = list(/datum/omnimode/deconstruct, /datum/omnimode/solder)
	switch_delay = 1.5 SECONDS

	New()
		..()
		src.AddComponent(/datum/component/soldering, 1.5 SECONDS)
		src.AddComponent(/datum/component/deconstructing, 0.5 SECONDS, 1)

// ===========================================================================
// ========================= Omnitool Mode Datums =========================
// ===========================================================================
ABSTRACT_TYPE(/datum/omnimode)
/datum/omnimode
	var/mode_name = "empty"
	var/mode_id = "empty"
	var/context_icon
	var/item_type = null
	var/item_special_type = /datum/item_special/simple

	proc/on_mode_enter(var/mob/holder, var/obj/item/tool/omnitool/omni)
		omni.setItemSpecial(src.item_special_type)
		omni.set_icon_state("[omni.prefix]-[src.mode_id]")
		if(omni.animated_changes)
			FLICK(("[omni.prefix]-swap-[src.mode_id]"), omni)
		return
	proc/on_mode_exit(var/mob/holder, var/obj/item/tool/omnitool/omni)
		return
	proc/on_attack(var/obj/item/tool/omnitool/omni, mob/target, mob/user, def_zone, is_special, params)
		return TRUE
	proc/on_attack_pre(var/obj/item/tool/omnitool/omni, atom/target, mob/user)
		return
	proc/on_attack_after(var/obj/item/tool/omnitool/omni, atom/target, mob/user, reach, params)
		return
	proc/on_drop(var/obj/item/tool/omnitool/omni, var/mob/user)
		if(user.isContextActionTarget(omni))
			user.closeContextActions()
		return

	crowbar
		mode_name = "crowbar"
		mode_id = OMNITOOL::MODE_CROWBAR
		context_icon = "bar"
		item_type = /obj/item/crowbar
		item_special_type = /datum/item_special/tile_fling

		on_attack(var/obj/item/tool/omnitool/omni, mob/target, mob/user, def_zone, is_special, params)
			if (is_special || !omni.pry_surgery(target, user))
				return TRUE
			return FALSE

	screwdriver
		mode_name = "screwdriver"
		mode_id = OMNITOOL::MODE_SCREWDRIVER
		context_icon = "screw"
		item_type = /obj/item/screwdriver
		item_special_type = /datum/item_special/jab
	wirecutters
		mode_name = "wirecutters"
		mode_id = OMNITOOL::MODE_WIRECUTTER
		context_icon = "cut"
		item_type = /obj/item/wirecutters
		item_special_type = /datum/item_special/double
	wrench
		mode_name = "wrench"
		mode_id = OMNITOOL::MODE_WRENCH
		context_icon = "wrench"
		item_type = /obj/item/wrench
	multitool
		mode_name = "multitool"
		mode_id = OMNITOOL::MODE_MULTITOOL
		context_icon = "pulse"
		item_type = /obj/item/device/multitool
		item_special_type = /datum/item_special/elecflash

		on_attack_after(var/obj/item/tool/omnitool/omni, atom/target, mob/user, reach, params)
			. = ..()
			get_and_return_netid(target, user)
			return

	welder
		mode_name = "welder"
		mode_id = OMNITOOL::MODE_WELDER
		context_icon = "weld"
		item_type = /obj/item/weldingtool
		item_special_type = /datum/item_special/flame

		on_mode_enter(mob/holder, obj/item/tool/omnitool/omni)
			omni.setItemSpecial(src.item_special_type)
			if(omni.get_fuel())
				omni.set_icon_state("[omni.prefix]-[mode_id]-on")
				omni.force = 15
				omni.hit_type = DAMAGE_BURN
				omni.welding = TRUE
			else
				omni.set_icon_state("[omni.prefix]-[mode_id]-off")
				omni.welding = FALSE
			return
		on_attack(var/obj/item/tool/omnitool/omni, mob/target, mob/user, def_zone, is_special, params)
			if (is_special)
				return TRUE
			if (omni.welding && ishuman(target) && (user.a_intent != INTENT_HARM))
				var/mob/living/carbon/human/H = target
				if (H.bleeding || (H.organHolder?.back_op_stage > BACK_SURGERY_OPENED && user.zone_sel.selecting == "chest"))
					if (!omni.cautery_surgery(H, user, omni, omni.welding))
						return TRUE
			else
				return TRUE
			return FALSE
		on_attack_after(obj/item/tool/omnitool/omni, atom/target, mob/user, reach, params)
			. = ..()
			if(omni.welding && !(omni.get_fuel() > 0))
				omni.set_icon_state("[omni.prefix]-[mode_id]-off")
				omni.welding = FALSE

	solder
		mode_name = "soldering"
		mode_id = OMNITOOL::MODE_SOLDERING
		context_icon = "solder"
		item_type = /obj/item/electronics/soldering

		on_attack_after(var/obj/item/tool/omnitool/omni, atom/target, mob/user, reach, params)
			. = ..()
			var/datum/component/soldering/solder_comp = omni.GetComponent(/datum/component/soldering)
			solder_comp.repair_deconstruction_buttons(target, user)
			return

	deconstruct
		mode_name = "deconstructor"
		mode_id = OMNITOOL::MODE_DECON
		context_icon = "saw"
		item_type = /obj/item/deconstructor

		on_mode_exit(var/mob/holder, var/obj/item/tool/omnitool/omni)
			. = ..()
			holder?.closeContextActions()
		on_attack_pre(var/obj/item/tool/omnitool/omni, atom/target, mob/user)
			. = ..()
			var/datum/component/deconstructing/decon_comp = omni.GetComponent(/datum/component/deconstructing)
			return decon_comp.pre_attackby_decon(target, user, omni)
		on_drop(var/obj/item/tool/omnitool/omni, var/mob/user)
			user.closeContextActions()

	knife
		mode_name = "knife"
		mode_id = OMNITOOL::MODE_KNIFE
		context_icon = "knife"
		item_type = /obj/item/kitchen/utensil/knife
		item_special_type = /datum/item_special/double
	spoon
		mode_name = "spoon"
		mode_id = OMNITOOL::MODE_SPOON
		context_icon = "spoon"
		item_type = /obj/item/kitchen/utensil/spoon
	fork
		mode_name = "sawing"
		mode_id = OMNITOOL::MODE_FORK
		context_icon = "saw"
		item_type = /obj/item/kitchen/utensil/fork
	bottle_opener
		mode_name = "bottle opener"
		mode_id = OMNITOOL::MODE_BOTTLE_OPENER
		context_icon = "bottleopener"
		item_type = /obj/item/kitchen/utensil

// ===========================================================================
// ========================= Omnitool Context Actions =========================
// ===========================================================================
// Context actions for switching omnitool modes
/datum/contextAction/omnitool
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = FALSE
	desc = ""
	icon_state = "what"
	var/datum/omnimode/mode = null

	New(var/datum/omnimode/omnimode)
		. = ..()
		if(!omnimode)
			return
		src.mode = omnimode
		src.name = src.mode.mode_name
		src.icon_state = src.mode.context_icon

	execute(var/obj/item/tool/omnitool/omnitool, var/mob/user)
		if (!istype(omnitool))
			return
		omnitool.change_mode_delayed(src.mode, user)

	checkRequirements(var/obj/item/tool/omnitool/omnitool, var/mob/user)
		if(!can_act(user) || !in_interact_range(omnitool, user))
			return FALSE
		return omnitool in user

// Action bar delay for omnitool switching
/datum/action/bar/icon/omnitool_switch
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/tools/omnitool.dmi'
	icon_state = "omnitool-prying"
	var/prev_icon_state = null // Save the previous state in case animation is interrupted
	var/is_animated = FALSE // Change the icon_state if action is animated, in case animation flick ends early
	var/mob/user = null
	var/obj/item/tool/omnitool/omni = null
	var/datum/omnimode/mode

	New(var/obj/item/tool/omnitool/tool, var/datum/omnimode/new_mode, var/new_icon_state, var/duration, var/is_animated = FALSE)
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
