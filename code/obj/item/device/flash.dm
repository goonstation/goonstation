TYPEINFO(/obj/item/device/flash)
	mats = list("metal" = 3,
				"conductive" = 5,
				"crystal" = 5)
/obj/item/device/flash
	name = "flash"
	desc = "A device that emits a complicated strobe when used, causing disorientation. Useful for stunning people or starting a dance party."
	icon_state = "flash"
	force = 1
	throwforce = 5
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	click_delay = COMBAT_CLICK_DELAY
	flags = TABLEPASS | CONDUCT | ATTACK_SELF_DELAY
	tool_flags = TOOL_ASSEMBLY_APPLIER
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	item_state = "electronic"

	var/status = 1 // Bulb still functional?
	var/use = 0 // Times the flash has been used.
	var/emagged = 0 // Booby Trapped?

	var/eye_damage_mod = 0
	var/range_mod = 0
	var/burn_mod = 0 // De-/increases probability of bulb burning out, so not related to BURN damage.
	var/stun_mod = 0

	var/animation_type = "flash2"

	var/max_flash_power = 5000
	var/min_flash_power = 500

/obj/item/device/flash/New()
	..()
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ACTIVATION, PROC_REF(assembly_activation))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ON_ATTACK_OVERRIDE, PROC_REF(assembly_on_attack_override))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_DO_ATTACK_OVERRIDE, PROC_REF(assembly_do_attack_override))
	src.RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_REMOVAL, PROC_REF(assembly_removal))
	// Flash + cell -> flash/cell-Assembly
	src.AddComponent(/datum/component/assembly/trigger_applier_assembly, /obj/item/cell)
	// Flash + assembly-applier -> flash/Applier-Assembly
	src.AddComponent(/datum/component/assembly/trigger_applier_assembly)

/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

/obj/item/device/flash/assembly_get_part_examine_message(var/mob/user, var/obj/item/assembly/parent_assembly)
	return src.get_bulb_status_message()

/obj/item/device/flash/proc/handle_assembly_flash_animation(var/obj/item/assembly/parent_assembly)
	if(!parent_assembly)
		return
	//if someone knows a way to call animate() or something like flick on overlays, let me know.
	//This should be changed if e.g. assembly icons get generated from vis content or something which supports more functions
	if(parent_assembly.trigger == src)
		parent_assembly.trigger_icon_prefix = "[src.animation_type]"
		parent_assembly.update_icon()
		SPAWN(4)
			parent_assembly.trigger_icon_prefix = "[src.icon_state]"
			parent_assembly.update_icon()
	if(parent_assembly.applier == src)
		parent_assembly.applier_icon_prefix = "[src.animation_type]"
		parent_assembly.update_icon()
		SPAWN(4)
			parent_assembly.applier_icon_prefix = "[src.icon_state]"
			parent_assembly.update_icon()

/obj/item/device/flash/proc/assembly_activation(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/mob/user)
	if(src.do_pre_flash_checks(null, user, parent_assembly))
		src.flash_area(user, parent_assembly.applier)
		//The flash in an assembly as a trigger will trigger its applier. Got a flash/igniter/pipebomb-Assembly? Get exploded, nerd!
		SPAWN(0)
			var/datum/signal/signal = get_free_signal()
			signal.source = src
			signal.data["message"] = "ACTIVATE"
			parent_assembly.receive_signal(signal)

/obj/item/device/flash/proc/assembly_application(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
	//no rapid firing flash appliers
	if(!ON_COOLDOWN(src, "flash_applier", src.click_delay) && src.do_pre_flash_checks(null, null, parent_assembly))
		src.flash_area(null, parent_assembly.target)

/obj/item/device/flash/proc/assembly_setup(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
	if(parent_assembly.applier == src)
		// trigger/flash-Assembly + cell -> trigger/flash/cell assembly
		parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/cell), TYPE_PROC_REF(/obj/item/assembly, add_target_item), TRUE)
	//if this is build in as trigger, we make the assembly able to attack with the flash
	if(is_build_in && parent_assembly.trigger == src)
		parent_assembly.set_attacking_component(src)

/obj/item/device/flash/proc/assembly_removal(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/mob/user)
	//we need to remove the attacking component, if the flash was it
	if(parent_assembly.attacking_component == src)
		parent_assembly.remove_attacking_component()

/obj/item/device/flash/proc/assembly_on_attack_override(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/mob/target, var/mob/user, var/def_zone, var/is_special, var/params)
	if(!src.do_pre_flash_checks(target, user, parent_assembly))
		//if these checks fail, we make the assembly override fail and stop the attack
		return TRUE

/obj/item/device/flash/proc/assembly_do_attack_override(var/manipulated_flash, var/obj/item/assembly/parent_assembly, var/mob/target, var/mob/user, var/def_zone, var/is_special, var/params)
	parent_assembly.add_fingerprint(user)
	src.flash_mob(target, user, parent_assembly.applier)
	//The flash in an assembly as a trigger will trigger its applier. Got a flash/igniter/pipebomb-Assembly? Get exploded, nerd!
	SPAWN(0)
		var/datum/signal/signal = get_free_signal()
		signal.source = src
		signal.data["message"] = "ACTIVATE"
		parent_assembly.receive_signal(signal)
	//we need to send true here to override the attack-parent
	return TRUE

/// ----------------------------------------------

/obj/item/device/flash/emag_act(var/mob/user, var/obj/item/card/emag/E)
	if (!src.emagged)
		if (user)
			user.show_text("You use the card to poke a hole in the back of the [src]. That may not have been a very good idea.", "blue")
		src.emagged = 1
		src.desc += " There seems to be a tiny hole drilled into the back of it."
		return 1
	else
		if (user)
			user.show_text("There already seems to be some modifications done to the device.", "red")

/obj/item/device/flash/demag(var/mob/user)
	if (!src.emagged)
		return 0
	if (user)
		user.show_text("You fill the strange hole in the back of the [src].", "blue")
	src.emagged = 0
	src.desc = "A device that emits an extremely bright light when used. Useful for briefly stunning people or starting a dance party."
	return 1

/obj/item/device/flash/proc/get_bulb_status_message()
	var/output = ""
	if (src.status == 0)
		output = "\nThe bulb has been burnt out"
	else
		switch(src.use)
			if(0 to 4)
				output = "\nThe bulb is in perfect condition."
			if(4 to 6)
				output = "\nThe bulb is in good condition"
			if(6 to 8)
				output = "\nThe bulb is in decent condition"
			if(8 to 10)
				output = "\nThe bulb is in bad condition"
			else
				output = "\nThe bulb is in terrible condition"
	return output

/obj/item/device/flash/get_desc()
	. = ..()
	. += src.get_bulb_status_message()

/obj/item/device/flash/attack(var/mob/target, var/mob/user, var/def_zone, var/is_special = FALSE, var/params = null)
	if(src.do_pre_flash_checks(target, user, src))
		src.add_fingerprint(user)
		src.flash_mob(target, user)
	// Some after attack stuff.
	user.lastattacked = get_weakref(target)
	target.lastattacker = get_weakref(user)
	target.lastattackertime = world.time

/obj/item/device/flash/attack_self(var/mob/user)
	if(src.do_pre_flash_checks(null, user, src))
		src.add_fingerprint(user)
		src.flash_area(user)

/obj/item/device/flash/proc/do_pre_flash_checks(var/mob/living/target, var/mob/user, var/obj/item/used_item)
	if(user && isghostcritter(user))
		user.visible_message(SPAN_ALERT("your feeble nature is unable to handle [used_item]!"))
		return
	if(!used_item)
		used_item = src
	var/turf/t = get_turf(user)
	if (target && t.loc:sanctuary)
		user.visible_message(SPAN_ALERT("<b>[user]</b> tries to use [used_item], cannot quite comprehend the forces at play!"))
		return
	if (user && user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
		user.visible_message(SPAN_ALERT("<b>[user]</b> tries to use [used_item], but slips and drops it!"))
		JOB_XP(user, "Clown", 1)
		user.drop_item()
		return
	if (src.status == 0)
		boutput(user, SPAN_ALERT("The bulb has been burnt out!"))
		return
	return TRUE

//this proc handles flash/cell assembly power drain and calculation.
//it returns the new cell power
/obj/item/device/flash/proc/handle_power_cell_boost(var/mob/target, var/mob/user, var/obj/item/item_in_use, var/obj/item/cell/manipulated_cell)
	var/power_output = 1
	if(istype(manipulated_cell, /obj/item/cell/erebite))
		if(user)
			user.visible_message(SPAN_ALERT("[user]'s [item_in_use] violently explodes!"))
		logTheThing(LOG_COMBAT, user, "tries to blind [target ? "[constructTarget(target,"combat")] " : ""]with [item_in_use] (erebite power cell) at [log_loc(src)].")
		var/turf/T = get_turf(src)
		explosion(src, T, 0, 1, 2, 2)
		SPAWN(0.1 SECONDS)
			if(src && istype(src.master,/obj/item/assembly))
				qdel(src.master)
			else
				qdel(src)
		return 0
	if (manipulated_cell && manipulated_cell.charge >= min_flash_power)
		power_output = min(2,1 + (manipulated_cell.charge / max_flash_power))
		manipulated_cell.use(src.max_flash_power)
	return power_output

/obj/item/device/flash/proc/handle_animations(var/mob/user, var/obj/item_in_use)
	playsound(item_in_use, 'sound/weapons/flash.ogg', 100, TRUE)
	if(src.master)
		src.handle_assembly_flash_animation(src.master)
	else
		FLICK(src.animation_type, src)

// Tweaked attack and attack_self to reduce the amount of duplicate code. Turboflashes to be precise (Convair880).
/obj/item/device/flash/proc/flash_mob(var/mob/living/M, var/mob/user, var/obj/item/modifier_item)
	var/item_in_use = src
	if(src.master)
		item_in_use = src.master
	// Handle turboflash power cell.
	var/flash_power = 1
	if (istype(modifier_item, /obj/item/cell))
		flash_power = src.handle_power_cell_boost(M, user, item_in_use, modifier_item)
	if (flash_power == 0)
		//our erebite cell blew up, no flash for you
		return
	// Play animations.
	src.handle_animations(user, item_in_use)
	// Calculate target damage.
	var/animation_duration
	var/weakened
	var/eye_blurry
	var/eye_damage
	var/burning

	if (flash_power > 1)
		animation_duration = 60
		weakened = (10 + src.stun_mod) * flash_power
		eye_blurry = src.eye_damage_mod + rand(2, (4 * flash_power))
		eye_damage = src.eye_damage_mod + rand(5, (10 * flash_power))
		burning = 15 * flash_power
	else
		animation_duration = 30
		weakened = (8 + src.stun_mod) * flash_power
		eye_damage = src.eye_damage_mod + rand(0, (1 * flash_power))

	// We're flashing somebody directly, hence the 100% chance to disrupt cloaking device at the end.
	var/blind_success = M.apply_flash(animation_duration, weakened, 0, 0, eye_blurry, eye_damage, 0, burning, 100, stamina_damage = 70 * flash_power, disorient_time = 30)
	if (src.emagged)
		user.apply_flash(animation_duration, weakened, 0, 0, eye_blurry, eye_damage, 0, burning, 100, stamina_damage = 70 * flash_power, disorient_time = 30)
	// handling rev conversion
	convert(M,user)
	// Log entry.
	var/blind_msg_target = "!"
	var/blind_msg_others = "!"
	if (!blind_success)
		blind_msg_target = " but your eyes are protected!"
		blind_msg_others = " but [his_or_her(M)] eyes are protected!"
	M.visible_message(SPAN_ALERT("[user] blinds [M] with \the [item_in_use][blind_msg_others]"), SPAN_ALERT("[user] blinds you with \the [item_in_use][blind_msg_target]"))
	logTheThing(LOG_COMBAT, user, "blinds [constructTarget(M,"combat")] with [item_in_use] at [log_loc(user)].")
	if (src.emagged)
		logTheThing(LOG_COMBAT, user, "blinds themself with [item_in_use] at [log_loc(user)].")
	// Handle bulb wear.
	src.use++
	src.process_burnout(user, flash_power)
	return

/obj/item/device/flash/proc/flash_area(var/mob/user, var/obj/item/modifier_item)
	var/item_in_use = src
	if(src.master)
		item_in_use = src.master
	// Handle turboflash power cell.
	var/flash_power = 1
	if (istype(modifier_item, /obj/item/cell))
		flash_power = src.handle_power_cell_boost(null, user, item_in_use, modifier_item)
	if (flash_power == 0)
		//our erebite cell blew up, no flash for you
		return
	// Play animations.
	src.handle_animations(user, item_in_use)
	// Handle turboflash power cell.
	// Flash target mobs.
	for (var/atom/A in oviewers((3 + src.range_mod), get_turf(src)))
		var/mob/living/M
		if (istype(A, /obj/vehicle))
			var/obj/vehicle/V = A
			if (V.rider && V.rider_visible)
				M = V.rider
		else if (ismob(A))
			M = A
		if (M)
			if (flash_power > 1)
				M.apply_flash(35, 0, 0, 25)
			else
				var/dist = GET_DIST(get_turf(src),M)
				dist = min(dist,4)
				dist = max(dist,1)
				M.apply_flash(20, knockdown = 2, uncloak_prob = 100, stamina_damage = (35 / dist), disorient_time = 3)
	// Handle bulb wear.
	src.use++
	src.process_burnout(user, flash_power)
	return

/obj/item/device/flash/proc/convert(mob/living/M as mob, mob/user as mob)
	.= 0
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/safety = 0
		if (H.eyes_protected_from_light())
			safety = 1

		if (safety == 0 && user.mind && user.mind.get_antagonist(ROLE_HEAD_REVOLUTIONARY) && !isghostcritter(user))
			var/nostun = 0
			if (!H.client || !H.mind)
				user.show_text("[H] is braindead and cannot be converted.", "red")
			else if (locate(/obj/item/implant/counterrev) in H.implant)
				src.on_counterrev(M, user)
				.= 0.5
				nostun = 1
			else if (!H.can_be_converted_to_the_revolution())
				user.show_text("[H] seems unwilling to revolt.", "red")
				nostun = 1
			else if (H.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
				user.show_text("[H] is already a member of the revolution.", "red")
			else
				.= 1
				if (!(H.mind?.get_antagonist(ROLE_REVOLUTIONARY)))
					H.mind?.add_antagonist(ROLE_REVOLUTIONARY, source = ANTAGONIST_SOURCE_CONVERTED)
				else
					user.show_text("[H] is already a member of the revolution.", "red")
			if (!nostun)
				M.apply_flash(1, 2, 0, 0, 0, 0, 0, burning, 100, stamina_damage = 210, disorient_time = 40)

/obj/item/device/flash/proc/on_counterrev(mob/living/M, mob/user)
	user.show_text("There seems to be something preventing [M] from revolting.", "red")

/obj/item/device/flash/proc/process_burnout(var/mob/user, var/flash_power)
	tooltip_rebuild = TRUE
	//if the flash power was greater than 1, we used a cell and thus this thing can burn out
	if (flash_power > 1 || prob(max(0,((use-5)*10) + burn_mod)))
		status = 0
		if(user)
			boutput(user, SPAN_ALERT("<b>The bulb has burnt out!</b>"))
		set_icon_state("flash3")
		name = "depleted flash"
		if(istype(src.master,/obj/item/assembly))
			var/obj/item/assembly/checked_assembly = src.master
			if(checked_assembly.trigger == src) //in case a flash is used for something else than a trigger
				checked_assembly.trigger_icon_prefix = "flash3"
			if(checked_assembly.applier == src) //in case a flash is used for something else than a applier
				checked_assembly.applier_icon_prefix = "flash3"
			checked_assembly.UpdateIcon()
			checked_assembly.UpdateName()
	return

/obj/item/device/flash/detonator_act(event, var/obj/item/canbomb_detonator/det)
	switch (event)
		if ("attach")
			det.initial_wire_functions += src
		if ("pulse")
			det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] discharges.</span>")
			for (var/mob/living/M in viewers(4, det.attachedTo))
				M.apply_flash(30, 20)
		if ("cut")
			det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] goes black.</span>")
			det.attachments.Remove(src)
		if ("process")
			if (prob(5))
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] discharges.</span>")
				for (var/mob/living/M in viewers(2, det.attachedTo))
					M.apply_flash(30, 8)

/obj/item/device/flash/emp_act()
	if(iscarbon(src.loc))
		src.AttackSelf()
	return


/obj/item/device/flash/cyborg
	tool_flags = null

/obj/item/device/flash/cyborg/New()
	..()
	// don't turn your borg modules into assemblies, please
	src.RemoveComponentsOfType(/datum/component/assembly/trigger_applier_assembly)

/obj/item/device/flash/cyborg/process_burnout(mob/user)
	return

obj/item/device/flash/cyborg/handle_animations(var/mob/user, var/obj/item_in_use)
	..()
	SPAWN(0)
		var/atom/movable/overlay/animation = new(user.loc)
		animation.layer = user.layer + 1
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = user
		FLICK("blspell", animation)
		sleep(0.5 SECONDS)
		qdel(animation)

/obj/item/device/flash/cyborg/attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
	..()
	var/mob/living/silicon/robot/R = user
	if (istype(R))
		R.cell.use(300)

/obj/item/device/flash/cyborg/attack_self(mob/user as mob, flag)
	..()
	var/mob/living/silicon/robot/R = user
	if (istype(R))
		R.cell.use(150)

/obj/item/storage/box/turbo_flash_kit
	name = "\improper Box of flash/cell assemblies."
	desc = "A box filled with five dangerous looking flash/cell assemblies."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/assembly/flash_cell = 5)

TYPEINFO(/obj/item/device/flash/revolution)
	mats = 0
/obj/item/device/flash/revolution
	name = "revolutionary flash"
	desc = "A device that emits an extremely bright light when used. Something about this device forces people to revolt, when flashed by a revolution leader."
	icon_state = "rev_flash"
	animation_type = "rev_flash2"
	tool_flags = null

/obj/item/device/flash/revolution/New()
	. = ..()
	// indestructable flashes probably shouldn't be turned into flash/cell-assemblies...
	src.RemoveComponentsOfType(/datum/component/assembly/trigger_applier_assembly)

/obj/item/device/flash/revolution/process_burnout(mob/user as mob)
	return

/obj/item/device/flash/revolution/emp_act()
	return

/obj/item/device/flash/revolution/attackby(obj/item/W, mob/user)
	return

/obj/item/device/flash/revolution/on_counterrev(mob/living/M, mob/user)
	. = ..()
	playsound(src, 'sound/weapons/rev_flash_startup.ogg', 30, TRUE, 0, 0.6)
	user.show_text("Hold still to override . . . ", "red")
	actions.start(new/datum/action/bar/icon/rev_flash(src,M), user)

/obj/item/device/flash/conspiracy
	tool_flags = null
	///How long between successful conversions
	var/convert_cooldown = 1 MINUTE
	///How long the (private) actionbar is to convert
	var/convert_duration = 2 SECONDS

/obj/item/device/flash/conspiracy/New()
	. = ..()
	src.desc += " There's something weird about this one..."
	// indestructable flashes probably shouldn't be turned into flash/cell-assemblies...
	src.RemoveComponentsOfType(/datum/component/assembly/trigger_applier_assembly)

/obj/item/device/flash/conspiracy/process_burnout(mob/user as mob)
	return

/obj/item/device/flash/conspiracy/emp_act()
	return

/obj/item/device/flash/conspiracy/attackby(obj/item/W, mob/user)
	return

/obj/item/device/flash/conspiracy/convert(mob/living/M, mob/user)
	if (!isconspirator(user)) //it's just a regular flash to them
		return
	if (isconspirator(M) || issilicon(M) || !M.mind)
		return
	var/current_cooldown = GET_COOLDOWN(global, "conspiracy_convert")
	if (current_cooldown)
		boutput(user, SPAN_ALERT("[src] still needs to recharge before it can convert another. Time left: [current_cooldown/10]s"))
		return
	var/mob/living/carbon/human/H = M
	if (istype(H) && H.eyes_protected_from_light())
		return
	if (src.convert_duration)
		actions.start(new /datum/action/bar/private/icon/callback(user, M, src.convert_duration, PROC_REF(finish_conversion), list(M, user), src.icon, src.icon_state, SPAN_ALERT("[M]'s eyes glaze over for a second..."), INTERRUPT_ATTACKED | INTERRUPT_STUNNED, src), user)
	else //skip actionbar
		src.finish_conversion(M, user)

/obj/item/device/flash/conspiracy/proc/finish_conversion(mob/living/M, mob/user)
	M.mind?.add_antagonist(ROLE_CONSPIRATOR, source = ANTAGONIST_SOURCE_CONVERTED)
	M.setStatus("knockdown", 5 SECONDS)
	ON_COOLDOWN(global, "conspiracy_convert", src.convert_cooldown)
	for (var/datum/mind/antag in ticker.mode.traitors)
		if (antag.get_antagonist(ROLE_CONSPIRATOR))
			antag.current.setStatus("conspiracy_convert", src.convert_cooldown)
