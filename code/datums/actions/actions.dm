// someone please split this into multiple files and/or move the actions out of this file to the places where they are used if they are that specific

/datum/action/bar/blob_health // WOW HACK
	bar_icon_state = "bar-blob"
	border_icon_state = "border-blob"
	color_active = "#9eee80"
	color_success = "#167935"
	color_failure = "#8d1422"
	onUpdate()
		var/obj/blob/B = owner
		if (!owner || !istype(owner) || !bar || !border) //Wire note: Fix for Cannot modify null.invisibility
			return
		if (B.health == B.health_max)
			border.invisibility = INVIS_ALWAYS
			bar.invisibility = INVIS_ALWAYS
		else
			border.invisibility = INVIS_NONE
			bar.invisibility = INVIS_NONE
		var/complete = B.health / B.health_max
		bar.color = "#00FF00"
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )

/datum/action/bar/bullethell
	var/obj/actions/bar/shield_bar
	var/obj/actions/bar/armor_bar

	onStart()
		..()
		var/atom/movable/A = owner
		if(owner != null)
			shield_bar = new /obj/actions/bar
			shield_bar.loc = owner.loc
			armor_bar = new /obj/actions/bar
			armor_bar.loc = owner.loc
			shield_bar.pixel_y = 5
			armor_bar.pixel_y = 5
			if (!islist(A.attached_objs))
				A.attached_objs = list()
			A.attached_objs.Add(shield_bar)
			A.attached_objs.Add(armor_bar)
			shield_bar.layer = initial(shield_bar.layer) + 2
			armor_bar.layer = initial(armor_bar.layer) + 1

	onDelete()
		..()
		shield_bar.invisibility = INVIS_NONE
		armor_bar.invisibility = INVIS_NONE
		bar.invisibility = INVIS_NONE
		border.invisibility = INVIS_NONE
		var/atom/movable/A = owner
		if (owner != null && islist(A.attached_objs))
			A.attached_objs.Remove(shield_bar)
			A.attached_objs.Remove(armor_bar)
		qdel(shield_bar)
		shield_bar = null
		qdel(armor_bar)
		armor_bar = null

	onUpdate()
		var/obj/bullethell/B = owner
		if (!owner || !istype(owner))
			return
		var/h_complete = B.health / B.max_health
		bar.color = "#00FF00"
		bar.transform = matrix(h_complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * h_complete)) / 2) )
		if (B.max_armor && B.armor)
			armor_bar.invisibility = INVIS_NONE
			var/a_complete = B.armor / B.max_armor
			armor_bar.color = "#FF8800"
			armor_bar.transform = matrix(a_complete, 1, MATRIX_SCALE)
			armor_bar.pixel_x = -nround( ((30 - (30 * a_complete)) / 2) )
		else
			armor_bar.invisibility = INVIS_ALWAYS
		if (B.max_shield && B.shield)
			shield_bar.invisibility = INVIS_NONE
			var/s_complete = B.shield / B.max_shield
			shield_bar.color = "#3333FF"
			shield_bar.transform = matrix(s_complete, 1, MATRIX_SCALE)
			shield_bar.pixel_x = -nround( ((30 - (30 * s_complete)) / 2) )
		else
			shield_bar.invisibility = INVIS_ALWAYS


/datum/action/bar/icon/hitthingwithitem // used when you need to make sure that mob is holding item
	// and is next to other thing while doing thing
	// what item is required to be held during it
	var/helditem = null
	// what mob is required to be holding the item
	var/mob/holdingmob = null
	// this was made for material compatibility, choose what to call the proc on
	var/call_proc_on = null
	// Copy-Pasted from Adhara's generic action bar
	/// set to a string version of the callback proc path
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	/// set to the path of the proc that will be called if the action bar finishes
	var/proc_path = null
	/// what the target of the action is, if any
	var/target = null
	/// what string is broadcast once the action bar finishes
	var/end_message = ""
	/// what is the maximum range target and owner can be apart? need to modify before starting the action.
	var/maximum_range = 1
	/// a list of args for the proc thats called once the action bar finishes, if needed.
	var/list/proc_args = null


	New(var/owner, var/mob/holdingmob, var/obj/item/helditem, var/target, var/call_proc_on, var/duration, var/proc_path, var/list/proc_args, var/icon, var/icon_state, var/end_message)
		..()
		if (owner)
			src.owner = owner
		else //no owner means we have nothing to do things with
			CRASH("action bars need an owner object to be tied to")
		if (holdingmob)
			src.holdingmob = holdingmob
		else
			CRASH("hitthingwithitem needs a mob to hold item")
		if (helditem)
			src.helditem = helditem
		else
			CRASH("hitthingwithitem needs an item to be held")
		if (target) //not having a target is okay, sometimes were just doing things to ourselves
			src.target = target
		if (call_proc_on)
			src.call_proc_on = call_proc_on // if we don't have a call_proc_on, we'll default to owner
		if (duration)
			src.duration = duration
		else //no duration dont do the thing
			CRASH("action bars need a duration to run for, there's no default duration")
		if (proc_path)
			src.proc_path = proc_path
		else //no proc, dont do the thing
			CRASH("no proc was specified to be called once the action bar ends")
		if (proc_args)
			if (islist(proc_args))
				src.proc_args = proc_args
			else
				src.proc_args = list(proc_args)
		if (icon) //optional, dont always want an icon
			src.icon = icon
			if (icon_state) //optional, dont always want an icon state
				src.icon_state = icon_state
		else if (icon_state)
			CRASH("icon state set for action bar, but no icon was set")
		if (end_message)
			src.end_message = end_message

		//generate a id
		if (src.proc_path)
			src.id = "[src.proc_path]"

	onStart()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if ((src.target && !IN_RANGE(src.owner, src.target, src.maximum_range)) || holdingmob.equipped() != helditem)
			interrupt(INTERRUPT_ALWAYS)

	onUpdate()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if ((src.target && !IN_RANGE(src.owner, src.target, src.maximum_range)) || holdingmob.equipped() != helditem)
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		if (!src.proc_path)
			CRASH("action bar had no proc to call upon completion")
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if ((src.target && !IN_RANGE(src.owner, src.target, src.maximum_range)) || holdingmob.equipped() != helditem)
			interrupt(INTERRUPT_ALWAYS)
			return

		src.owner.visible_message("[src.end_message]")
		if (src.call_proc_on)
			INVOKE_ASYNC(src.call_proc_on, src.proc_path, arglist(src.proc_args))
		else
			INVOKE_ASYNC(src.owner, src.proc_path, arglist(src.proc_args))

/datum/action/bar/icon/build
	/// Custom name of the object for messages if needed, otherwise just the object's initial name
	var/obj_name
	var/obj_turf
	var/obj/obj_type
	/// Amount of the object which will be made when we're done
	var/obj_amt
	var/obj/item/sheet/sheet1
	var/obj/item/sheet/sheet2
	var/cost1
	var/cost2
	/// Are we using a second sheet (e.g. Glass table parts)
	var/has_sheet2
	var/datum/material/obj_mat
	/// Callback once the thing is constructed
	var/post_callback

	New(var/obj/otype, var/target, var/oamt, var/btime, var/s1, var/c1, var/s2, var/c2, var/datum/material/omat, var/c_icon = null, var/c_icon_state = null, var/callback = null, var/name = null)
		..()
		resumable = FALSE
		obj_type = otype
		obj_name = (!name) ? initial(otype.name) : name
		obj_turf = get_turf(target || owner)
		obj_amt = oamt
		obj_mat = omat
		duration = btime
		sheet1 = s1
		cost1 = c1
		sheet2 = s2
		cost2 = c2
		has_sheet2 = (s2 != null)
		post_callback = callback
		// You need both to set a custom icon, there's no warning but you are expected to know this
		if (c_icon && c_icon_state)
			icon = c_icon
			icon_state = c_icon_state
		else
			icon = initial(otype.icon)
			icon_state = initial(otype.icon_state)

	/// Return TRUE if both sheets are there and valid, else false
	proc/has_valid_sheets()
		if (QDELETED(sheet1) || (has_sheet2 && QDELETED(sheet2)))
			boutput(owner, SPAN_NOTICE("You have nothing to build with!"))
			return FALSE
		if (sheet1.amount < cost1)
			boutput(owner, SPAN_NOTICE("You don't have enough [sheet1]\s to build \the [obj_name] with!"))
			return FALSE
		if (has_sheet2 && sheet2.amount < cost2)
			boutput(owner, SPAN_NOTICE("You don't have enough [sheet2]\s to build \the [obj_name] with!"))
			return FALSE
		if (ismob(owner))
			var/mob/M = owner
			if (!in_interact_range(sheet1, M))
				boutput(owner, SPAN_NOTICE("You dropped \the [sheet1]\s, how are you going to finish \the [obj_name]?"))
				return FALSE
			if (has_sheet2 && !in_interact_range(sheet2, M))
				boutput(owner, SPAN_NOTICE("\the [sheet2]\s have to be closer to build \the [obj_name]!"))
				return FALSE
		return TRUE

	/// Checks if there's a dense object on a turf, with notable exceptions for soul and directional things. Procs like can_crossed_by(AM) cannot be
	/// used because we haven't made the thing yet, so there's no /atom/movable to use. If there's a way to do this nicely in the future replace pls
	proc/has_dense_object()
		if (!obj_turf)
			return FALSE
		for (var/obj/O in obj_turf)
			if (src.should_ignore_dense_check(O))
				continue
			if (O.density)
				boutput(owner, SPAN_ALERT("You try to build \the [obj_name], but there's \the [O] in the way!"))
				return TRUE
		return FALSE

	/// Check if the object is one of a dense object which is an exception to most others -- and should be allowed to have
	/// several of its own instances on a tile. Girders, thin windows, and railings are all examples of this.
	proc/should_ignore_dense_check(var/obj/O)
		// girder for soul, window for thindow (fuck thindow) <- ((I have no idea what this means))
		return istype(O, /obj/structure/girder) || istype(O, /obj/window) || istype(O, /obj/railing)

	onStart()
		..()
//You can't build! The if is to stop compiler warnings
#if defined(MAP_OVERRIDE_POD_WARS)
		if (owner)
			boutput(owner, SPAN_ALERT("What are you gonna do with this? You have a very particular set of skills, and building is not one of them..."))
			interrupt(INTERRUPT_ALWAYS)
			return
#endif
		if (!src.has_valid_sheets() || !src.obj_turf)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (initial(src.obj_type.density) && src.has_dense_object())
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!isturf(owner.loc))
			boutput(owner, SPAN_ALERT("You don't think you can build \the [obj_name] from in here..."))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

		owner.visible_message(SPAN_NOTICE("[owner] begins assembling \the [obj_name]!"))

	onUpdate()
		. = ..()
		if (!src.has_valid_sheets())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if (!src.has_valid_sheets() || (initial(src.obj_type.density) && src.has_dense_object()))
			interrupt(INTERRUPT_ALWAYS)
			return
		owner.visible_message(SPAN_NOTICE("[owner] assembles \the [obj_name]!"))
		var/obj/item/R = new obj_type(obj_turf)
		if (isitem(R))
			var/mob/living/carbon/human/H = owner
			H.put_in_hand_or_drop(R)
		R.setMaterial(obj_mat)
		if (istype(R))
			R.amount = obj_amt
			R.inventory_counter?.update_number(R.amount)
		R.set_dir(owner.dir)
		sheet1.change_stack_amount(-cost1)
		if (sheet2 && cost2)
			sheet2.change_stack_amount(-cost2)
		logTheThing(LOG_STATION, owner, "builds \the [obj_name] (<b>Material:</b> [obj_mat && istype(obj_mat) && obj_mat.getID() ? "[obj_mat.getID()]" : "*UNKNOWN*"]) at [log_loc(owner)].")
		if (isliving(owner))
			var/mob/living/M = owner
			R.add_fingerprint(M)
		if (post_callback)
			call(post_callback)(src, R)

/datum/action/bar/icon/cruiser_repair
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 30
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/machinery/cruiser_destroyable/repairing
	var/obj/item/using

	New(var/obj/machinery/cruiser_destroyable/D, var/obj/item/U, var/duration_i)
		..()
		repairing = D
		using = U
		duration = duration_i

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, repairing) > 0 || repairing == null || owner == null || using == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/source = owner
		if(using != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message(SPAN_NOTICE("[owner] begins repairing [repairing]!"))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner] successfully repairs [repairing]!"))
		repairing.adjustHealth(repairing.health_max)

/datum/action/bar/private //This subclass is only visible to the owner of the action
	border_icon_state = "border-private"
	onStart()
		..()
		if (ismob(owner))
			var/mob/M = owner
			bar.icon = null
			border.icon = null
			M.client?.images += bar.img
			M.client?.images += border.img
			if(place_to_put_bar)
				target_bar.icon = null
				target_border.icon = null
				M.client?.images += target_bar.img
				M.client?.images += target_border.img

	onDelete()
		bar.icon = 'icons/ui/actions.dmi'
		border.icon = 'icons/ui/actions.dmi'
		if (ismob(owner))
			var/mob/M = owner
			M.client?.images -= bar.img
			M.client?.images -= border.img
			qdel(bar.img)
			qdel(border.img)
			if(place_to_put_bar)
				M.client?.images -= target_bar.img
				M.client?.images -= target_border.img
				qdel(target_bar.img)
				qdel(target_border.img)
		..()

/datum/action/bar/private/icon //Only visible to the owner and has a little icon on the bar.
	var/icon
	var/icon_state
	var/icon_y_off = 30
	var/icon_x_off = 0
	var/image/icon_image
	var/icon_plane = PLANE_HUD

	onStart()
		..()
		if(icon && icon_state && owner)
			icon_image = image(icon, owner, icon_state, 10)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			icon_image.plane = icon_plane

			icon_image.filters += filter(type="outline", size=0.5, color=rgb(255,255,255))
			if (ismob(owner))
				var/mob/M = owner
				M.client?.images += icon_image

	onDelete()
		if (ismob(owner))
			var/mob/M = owner
			M.client?.images -= icon_image
		qdel(icon_image)
		..()

//ACTIONS
/**
* Calls a specified proc if it finishes without interruptions. Only displayed to the user.
* Heavily copy pasted from /datum/action/bar/icon/callback.
*
* check [_std/macros/actions.dm] for documentation on a macro that uses this.
*/
/datum/action/bar/private/icon/callback
	/// set to a string version of the callback proc path
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	/// set to the path of the proc that will be called if the action bar finishes
	var/proc_path = null
	/// set to datum to perform callback on if seperate from owner or target
	var/call_proc_on = null
	/// what the target of the action is, if any
	var/target = null
	/// what string is broadcast once the action bar finishes
	var/end_message = ""
	/// what is the maximum range target and owner can be apart? need to modify before starting the action.
	var/maximum_range = 1
	/// a list of args for the proc thats called once the action bar finishes, if needed.
	var/list/proc_args = null

	New(owner, target, duration, proc_path, proc_args, icon, icon_state, end_message, interrupt_flags, call_proc_on)
		..()
		if (owner)
			src.owner = owner
		else //no owner means we have nothing to do things with
			CRASH("action bars need an owner object to be tied to")
		if (target) //not having a target is okay, sometimes were just doing things to ourselves
			src.target = target
		if (duration)
			src.duration = duration
		else //no duration dont do the thing
			CRASH("action bars need a duration to run for, there's no default duration")
		if (proc_path)
			src.proc_path = proc_path
		else //no proc, dont do the thing
			CRASH("no proc was specified to be called once the action bar ends")
		if(call_proc_on)
			src.call_proc_on = call_proc_on
		if (proc_args)
			if (islist(proc_args))
				src.proc_args = proc_args
			else
				src.proc_args = list(proc_args)
		if (icon) //optional, dont always want an icon
			src.icon = icon
			if (icon_state) //optional, dont always want an icon state
				src.icon_state = icon_state
		else if (icon_state)
			CRASH("icon state set for action bar, but no icon was set")
		if (end_message)
			src.end_message = end_message
		if (interrupt_flags != null)
			src.interrupt_flags = interrupt_flags
		//generate a id
		if (src.proc_path)
			src.id = "[src.proc_path]"

	onStart()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (src.target && !IN_RANGE(src.owner, src.target, src.maximum_range))
			interrupt(INTERRUPT_ALWAYS)

	onUpdate()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (src.target && !IN_RANGE(src.owner, src.target, src.maximum_range))
			interrupt(INTERRUPT_ALWAYS)

	onEnd()
		..()
		if (!src.proc_path)
			CRASH("action bar had no proc to call upon completion")
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.target && !IN_RANGE(src.owner, src.target, src.maximum_range))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (end_message)
			src.owner.visible_message("[src.end_message]")
		if (src.call_proc_on)
			INVOKE_ASYNC(src.call_proc_on, src.proc_path, arglist(src.proc_args))
		else if (src.target)
			INVOKE_ASYNC(src.target, src.proc_path, arglist(src.proc_args))
		else
			INVOKE_ASYNC(src.owner, src.proc_path, arglist(src.proc_args))

#define STAM_COST 30
/datum/action/bar/icon/otherItem//Putting items on or removing items from others.
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/source  //The mob doing the action
	var/mob/living/carbon/human/target  //The target of the action
	var/obj/item/item				    //The item if any. If theres no item, we tried to remove something from that slot instead of putting an item there.
	var/slot						    //The slot number
	var/hidden


	New(var/Source, var/Target, var/Item, var/Slot, var/ExtraDuration = 0, var/Hidden = 0)
		source = Source
		target = Target
		item = Item
		slot = Slot
		hidden = Hidden

		if(item)
			if(item.duration_put > 0)
				duration = item.duration_put
			else
				duration = 4.5 SECONDS
		else
			var/obj/item/I = target.get_slot(slot)
			if(I)
				if(I.duration_remove > 0)
					duration = I.duration_remove
				else
					duration = 2.5 SECONDS


		duration += ExtraDuration

		if (source.reagents && source.reagents.has_reagent("crime"))
			duration /= 5
		if (isunconscious(target))
			duration /= 2
		else if (isdead(target))
			duration /= 3
		..()

	onStart()
		target.add_fingerprint(source) // Added for forensics (Convair880).

		SEND_SIGNAL(source, COMSIG_MOB_TRIGGER_THREAT)

		if (source.use_stamina && source.get_stamina() < STAM_COST)
			boutput(source, SPAN_ALERT("You're too winded to [item ? "place that on" : "take that from"] [him_or_her(target)]."))
			src.resumable = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return
		source.remove_stamina(STAM_COST)

		if(item)
			logTheThing(LOG_COMBAT, source, "tries to put \an [item] on [constructTarget(target,"combat")] at at [log_loc(target)].")
			icon = item.icon
			icon_state = item.icon_state
			for(var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("<B>[source] tries to put [item] on [target]!</B>"), 1)
		else
			var/obj/item/I = target.get_slot(slot)
			logTheThing(LOG_COMBAT, source, "tries to remove \an [I] from [constructTarget(target,"combat")] at [log_loc(target)].")
			var/name = "something"
			if (!hidden)
				icon = I.icon
				icon_state = I.icon_state
				name = I.name

			for(var/mob/O in AIviewers(owner))
				O.show_message(SPAN_ALERT("<B>[source] tries to remove [name] from [target]!</B>"), 1)

		..() // we call our parents here because we need to set our icon and icon_state before calling them

	onEnd()
		..()

		if(BOUNDS_DIST(source, target) > 0 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		SEND_SIGNAL(source, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
		var/obj/item/I = target.get_slot(slot)

		if(item)
			if(item == source.equipped() && !I)
				if(target.can_equip(item, slot))
					logTheThing(LOG_COMBAT, source, "successfully puts \an [item] on [constructTarget(target,"combat")] at at [log_loc(target)].")
					for(var/mob/O in AIviewers(owner))
						O.show_message(SPAN_ALERT("<B>[source] puts [item] on [target]!</B>"), 1)
					source.u_equip(item)
					if(QDELETED(item))
						return
					target.force_equip(item, slot)
					target.update_inv()
		else if (I) //Wire: Fix for Cannot execute null.handle other remove().
			if(I.handle_other_remove(source, target))
				logTheThing(LOG_COMBAT, source, "successfully removes \an [I] from [constructTarget(target,"combat")] at [log_loc(target)].")
				for(var/mob/O in AIviewers(owner))
					O.show_message(SPAN_ALERT("<B>[source] removes [I] from [target]!</B>"), 1)

				// Re-added (Convair880).
				if (istype(I, /obj/item/mousetrap/))
					var/obj/item/mousetrap/MT = I
					if (MT?.armed)
						for (var/mob/O in AIviewers(owner))
							O.show_message(SPAN_ALERT("<B>...and triggers it accidentally!</B>"), 1)
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
				else if (istype(I, /obj/item/mine))
					var/obj/item/mine/M = I
					if (M.armed && M.used_up != 1)
						for (var/mob/O in AIviewers(owner))
							O.show_message(SPAN_ALERT("<B>...and triggers it accidentally!</B>"), 1)
						M.triggered(source)

				target.u_equip(I)
				I.set_loc(target.loc)
				I.dropped(target)
				I.layer = initial(I.layer)
				I.add_fingerprint(source)
				target.update_inv()
			else
				boutput(source, SPAN_ALERT("You fail to remove [I] from [target]."))

	canRunCheck(in_start)
		..()
		if(BOUNDS_DIST(source, target) > 0 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/obj/item/I = target.get_slot(slot)

		if(item)
			var/obj/item/existing_item = target.get_slot(slot)
			if(existing_item && in_start) // if they have something there, smack it with held item
				var/hidden_check = FALSE
				if(src.item.w_class <= W_CLASS_POCKET_SIZED && !(src.item.item_function_flags & OBVIOUS_INTERACTION_BAR))
					hidden_check = TRUE
				logTheThing(LOG_COMBAT, source, "uses the inventory menu while holding [log_object(item)] to interact with \
													[log_object(existing_item)] equipped by [log_object(target)].")
				if(hidden_check)
					actions.start(new /datum/action/bar/private/icon/callback(source, target, item.duration_remove > 0 ? item.duration_remove : 2.5 SECONDS, TYPE_PROC_REF(/mob/living, click), list(existing_item, list()),  item.icon, item.icon_state, null, null, source), source)
				else
					actions.start(new /datum/action/bar/icon/callback(source, target, item.duration_remove > 0 ? item.duration_remove : 2.5 SECONDS, TYPE_PROC_REF(/mob/living, click), list(existing_item, list()),  item.icon, item.icon_state, null, null, source), source) //this is messier
				interrupt(INTERRUPT_ALWAYS)
				return
			if(item != source.equipped())
				interrupt(INTERRUPT_ALWAYS)
			if(!target.can_equip(item, slot))
				if(in_start)
					boutput(source, SPAN_ALERT("[item] can not be put there."))
				interrupt(INTERRUPT_ALWAYS)
				return
			if(!isturf(target.loc))
				if(in_start)
					boutput(source, SPAN_ALERT("You can't put [item] on [target] when [(he_or_she(target))] is in [target.loc]!"))
				interrupt(INTERRUPT_ALWAYS)
				return
			if(item.cant_drop) //Fix for putting item arm objects into others' inventory
				if(in_start)
					source.show_text("You can't put \the [item] on [target] when it's attached to you!", "red")
				interrupt(INTERRUPT_ALWAYS)
				return
		else
			if(!target.get_slot(slot=slot))
				interrupt(INTERRUPT_ALWAYS)
			if(!I)
				if(in_start)
					boutput(source, SPAN_ALERT("There's nothing in that slot."))
				interrupt(INTERRUPT_ALWAYS)
				return
			if(!isturf(target.loc))
				if(in_start)
					boutput(source, SPAN_ALERT("You can't remove [I] from [target] when [(he_or_she(target))] is in [target.loc]!"))
				interrupt(INTERRUPT_ALWAYS)
				return
#undef STAM_COST

/datum/action/bar/icon/internalsOther //This is used when you try to set someones internals
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/clothing/item_masks.dmi'
	icon_state = "breath"
	var/mob/living/carbon/human/target
	var/remove_internals

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			if(target.internal)
				O.show_message(SPAN_ALERT("<B>[owner] attempts to remove [target]'s internals!</B>"), 1)
				remove_internals = 1
			else
				O.show_message(SPAN_ALERT("<B>[owner] attempts to set [target]'s internals!</B>"), 1)
				remove_internals = 0
	onEnd()
		..()
		if(owner && target && BOUNDS_DIST(owner, target) == 0)
			SEND_SIGNAL(owner, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			if(remove_internals)
				target.internal.add_fingerprint(owner)
				for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
					T.icon_state = "airoff"
				target.internal = null
				target.update_inv()
				for(var/mob/O in AIviewers(owner))
					O.show_message(SPAN_ALERT("<B>[owner] removes [target]'s internals!</B>"), 1)
			else
				if (!istype(target.wear_mask, /obj/item/clothing/mask))
					interrupt(INTERRUPT_ALWAYS)
					return
				else
					if (istype(target.back, /obj/item/tank))
						target.internal = target.back
						target.update_inv()
						for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
							T.icon_state = "airon"
						for(var/mob/M in AIviewers(target, 1))
							M.show_message(text("[] is now running on internals.", src.target), 1)
						target.internal.add_fingerprint(owner)

/datum/action/bar/icon/handcuffSet //This is used when you try to handcuff someone.
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	var/mob/living/carbon/human/target
	var/obj/item/handcuffs/cuffs

	New(Target, Cuffs)
		target = Target
		cuffs = Cuffs
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(target.hasStatus("handcuffed"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		logTheThing(LOG_COMBAT, owner, "attempts to handcuff [constructTarget(target,"combat")] with [cuffs] at [log_loc(owner)].")

		duration *= cuffs.apply_multiplier

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.traitHolder.hasTrait("training_security"))
				duration = round(duration / 2)

		for(var/mob/O in AIviewers(owner))
			O.show_message(SPAN_ALERT("<B>[owner] attempts to handcuff [target]!</B>"), 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(!istype(ownerMob) || !target || !cuffs || target.hasStatus("handcuffed") || cuffs != ownerMob.equipped() || BOUNDS_DIST(owner, target) != 0)
			return

		if (initial(cuffs.amount) > 1)
			if (cuffs.amount < 1)
				boutput(ownerMob, SPAN_ALERT("There's nothing left in the [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape roll" : "ziptie"]."))
				interrupt(INTERRUPT_ALWAYS)
				return
			var/obj/item/handcuffs/tape/inner_cuffs = new /obj/item/handcuffs/tape
			inner_cuffs.apply_multiplier = cuffs.apply_multiplier
			inner_cuffs.remove_self_multiplier = cuffs.remove_self_multiplier
			inner_cuffs.remove_other_multiplier = cuffs.remove_other_multiplier
			cuffs.amount--
			if (cuffs.amount < 1 && cuffs.delete_on_last_use)
				ownerMob.u_equip(cuffs)
				boutput(ownerMob, SPAN_ALERT("You used up the remaining length of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"]."))
				qdel(cuffs)
			else
				boutput(ownerMob, SPAN_NOTICE("The [cuffs.name] now has [cuffs.amount] lengths of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"] left."))
			cuffs = inner_cuffs
		else
			ownerMob.u_equip(cuffs)


		logTheThing(LOG_COMBAT, ownerMob, "handcuffs [constructTarget(target,"combat")] with [cuffs] at [log_loc(ownerMob)].")

		cuffs.cuff(target)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_message(SPAN_ALERT("<B>[owner] handcuffs [target]!</B>"), 1)

/datum/action/bar/icon/handcuffRemovalOther //This is used when you try to remove someone elses handcuffs.
	duration = 70
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	var/mob/living/carbon/human/target

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.hasStatus("handcuffed"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(target != null && ishuman(target) && target.hasStatus("handcuffed"))
			var/mob/living/carbon/human/H = target
			duration = round(duration * H.handcuffs.remove_other_multiplier)

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.traitHolder.hasTrait("training_security"))
				duration = round(duration / 2)

		for(var/mob/O in AIviewers(owner))
			O.show_message(SPAN_ALERT("<B>[owner] attempts to remove [target]'s handcuffs!</B>"), 1)

	onEnd()
		..()
		if(owner && target?.hasStatus("handcuffed"))
			SEND_SIGNAL(owner, COMSIG_MOB_CLOAKING_DEVICE_DEACTIVATE)
			var/mob/living/carbon/human/H = target
			H.handcuffs.drop_handcuffs(H)
			H.update_inv()
			for(var/mob/O in AIviewers(H))
				O.show_message(SPAN_ALERT("<B>[owner] manages to remove [target]'s handcuffs!</B>"), 1)
			logTheThing(LOG_COMBAT, owner, "removes [constructTarget(target,"combat")]'s handcuffs at [log_loc(owner)].")

/datum/action/bar/private/icon/handcuffRemoval //This is used when you try to resist out of handcuffs.
	duration = 600
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		if(owner != null && ishuman(owner) && owner.hasStatus("handcuffed"))
			var/mob/living/carbon/human/H = owner
			duration = round(duration * H.handcuffs.remove_self_multiplier)

		owner.visible_message(SPAN_ALERT("<B>[owner] attempts to remove the handcuffs!</B>"))

	onUpdate()
		. = ..()
		if(!owner.hasStatus("handcuffed"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt(var/flag)
		..()
		boutput(owner, SPAN_ALERT("Your attempt to remove your handcuffs was interrupted!"))
		if(!(flag & INTERRUPT_ACTION))
			src.resumable = FALSE

	onEnd()
		..()
		if(owner != null && ishuman(owner) && owner.hasStatus("handcuffed"))
			var/mob/living/carbon/human/H = owner
			H.handcuffs.drop_handcuffs(H)
			H.visible_message(SPAN_ALERT("<B>[H] attempts to remove the handcuffs!</B>"))
			boutput(H, SPAN_NOTICE("You successfully remove your handcuffs."))
			logTheThing(LOG_COMBAT, H, "removes their own handcuffs at [log_loc(H)].")

/datum/action/bar/private/icon/shackles_removal // Resisting out of shackles (Convair880).
	duration = 450
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/clothing/item_shoes.dmi'
	icon_state = "orange1"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(SPAN_ALERT("<B>[owner] attempts to remove the shackles!</B>"), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, SPAN_ALERT("Your attempt to remove the shackles was interrupted!"))

	onEnd()
		..()
		if (owner != null && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.shoes && H.shoes.chained)
				var/obj/item/clothing/shoes/SH = H.shoes
				H.u_equip(SH)
				SH.set_loc(H.loc)
				H.update_clothing()
				if (SH)
					SH.layer = initial(SH.layer)
				for(var/mob/O in AIviewers(H))
					O.show_message(SPAN_ALERT("<B>[H] manages to remove the shackles!</B>"), 1)
				H.show_text("You successfully remove the shackles.", "blue")
				logTheThing(LOG_COMBAT, H, "removes their own shackles at [log_loc(H)].")


/datum/action/bar/private/welding
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	var/call_proc_on = null
	var/obj/effects/welding/E
	var/list/start_offset
	var/list/end_offset


	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	/// set to the path of the proc that will be called if the action bar finishes
	var/proc_path = null
	/// what the target of the action is, if any
	var/atom/movable/target = null
	/// what string is broadcast once the action bar finishes
	var/end_message = ""
	/// a list of args for the proc thats called once the action bar finishes, if needed.
	var/list/proc_args = null
	bar_on_owner = FALSE

	proc/make_welding_effect()
		if(E)
			if(ismovable(src.target))
				var/atom/movable/M = src.target
				M.vis_contents -= E
			qdel(E)

		if(ismovable(src.target))
			var/atom/movable/M = src.target
			E = new(M)
			M.vis_contents += E
		else
			E = new(src.target)
		E.pixel_x = start_offset[1]
		E.pixel_y = start_offset[2]
		animate(E, time=src.duration, pixel_x=end_offset[1], pixel_y=end_offset[2])

	New(owner, target, duration, proc_path, proc_args, end_message, start, stop, call_proc_on)
		..()
		src.owner = owner
		src.target = target
		place_to_put_bar = target

		if(duration)
			src.duration = duration
		src.proc_path = proc_path
		src.proc_args = proc_args
		src.end_message = end_message
		src.start_offset = start
		src.end_offset = stop
		if(call_proc_on)
			src.call_proc_on = call_proc_on

	onStart()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (src.target && (BOUNDS_DIST(src.owner, src.target) > 0))
			interrupt(INTERRUPT_ALWAYS)
		src.make_welding_effect()

	onDelete(var/flag)
		if(E)
			if(ismovable(src.target))
				var/atom/movable/M = src.target
				M.vis_contents -= E
			qdel(E)
		..()

	onEnd()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.target && (BOUNDS_DIST(src.owner, src.target) > 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (end_message)
			src.owner.visible_message("[src.end_message]")

		if (src.call_proc_on)
			INVOKE_ASYNC(src.call_proc_on, src.proc_path, arglist(src.proc_args))
		else if (src.target)
			INVOKE_ASYNC(src.target, src.proc_path, arglist(src.proc_args))
		else
			INVOKE_ASYNC(src.owner, src.proc_path, arglist(src.proc_args))

/// A looping weld action bar. Duration and cost are per cycle.
/datum/action/bar/private/welding/loop
	/// Tool being used to weld (weldingtool, omnitool, etc)
	var/obj/item/welder
	/// Unit cost per cycle (for charging fuel)
	var/cycle_cost

	New(owner, target, duration, proc_path, proc_args, end_message, start, stop, call_proc_on, tool, cost)
		. = ..()
		src.welder = tool
		if(cost)
			src.cycle_cost = cost

	canRunCheck(in_start)
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (src.target && (BOUNDS_DIST(src.owner, src.target) > 0))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/M = owner
		if (!istype(M) || !isweldingtool(M.equipped()) || !src.welder:welding)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		src.loopStart()

	loopStart()
		..()
		src.make_welding_effect()

	onEnd()
		if(!src.welder:try_weld(owner, src.cycle_cost))
			src.interrupt(INTERRUPT_ALWAYS)
			return
		..()
		if(src.welder:get_fuel())
			src.onResume()
			src.onRestart()


/// Weld-repairing vehicles/pods hulls
/datum/action/bar/private/welding/loop/vehicle
	duration = 0.5 SECONDS
	cycle_cost = 1

/datum/action/bar/private/welding/loop/vehicle/New(owner, target, duration, proc_path, proc_args, end_message, start, stop, call_proc_on, tool, cost)
	. = ..()
	src.place_to_put_bar = owner

/datum/action/bar/private/welding/loop/vehicle/loopStart()
	var/obj/machinery/vehicle/V = target
	var/newPositions = V.get_welding_positions()
	src.start_offset = newPositions[1]
	src.end_offset = newPositions[2]
	. = ..()

/datum/action/bar/private/welding/loop/vehicle/canRunCheck(in_start)
	..()

	var/obj/machinery/vehicle/vehicle = target
	if(!istype(vehicle))
		src.interrupt(INTERRUPT_ALWAYS)

	if(vehicle.health >= vehicle.maxhealth)
		src.interrupt(INTERRUPT_ALWAYS)

	var/turf/T = get_turf(target)
	if(T.active_liquid)
		if(T.active_liquid.my_depth_level >= 3 && T.active_liquid.group.reagents.get_reagent_amount("tene")) //SO MANY PERIODS
			boutput(owner, SPAN_ALERT("The damaged parts are saturated with fluid. You need to move somewhere drier."))
			src.interrupt(INTERRUPT_ALWAYS)
#ifdef MAP_OVERRIDE_NADIR
	if(istype(T,/turf/space/fluid) || istype(T,/turf/simulated/floor/plating/airless/asteroid))
		//prevent in-acid welding from extending excursion times indefinitely
		boutput(owner, SPAN_ALERT("The damaged parts are saturated with acid. You need to move somewhere with less pressure."))
		src.interrupt(INTERRUPT_ALWAYS)
#endif

//CLASSES & OBJS

/obj/actions //These objects are mostly used for the attached_objs var on mobs to attach progressbars to mobs.
	icon = 'icons/ui/actions.dmi'
	anchored = ANCHORED
	density = 0
	opacity = 0
	layer = 5
	name = ""
	desc = ""
	mouse_opacity = 0

/obj/actions/bar
	icon_state = "bar"
	layer = 101
	plane = PLANE_HUD
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	var/image/img
	New()
		..()
		img = image('icons/ui/actions.dmi',src,"bar",6)

	set_icon_state(new_state)
		..()
		src.img.icon_state = new_state

/obj/actions/border
	layer = 100
	icon_state = "border"
	plane = PLANE_HUD
	appearance_flags = PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	var/image/img
	New()
		..()
		img = image('icons/ui/actions.dmi',src,"border",5)

	set_icon_state(new_state)
		..()
		src.img.icon_state = new_state

//Use this to start the action
//actions.start(new/datum/action/bar/private/icon/magPicker(item, picker), usr)
/datum/action/bar/private/icon/magPicker
	duration = 30 //How long does this action take in ticks.
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/items.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "magtractor-small"

	var/obj/item/target = null //This will contain the object we are trying to pick up.
	var/obj/item/magtractor/picker = null //This is the magpicker.

	New(Target, Picker)
		target = Target
		picker = Picker
		..()

	onUpdate() //check for special conditions that could interrupt the picking-up here.
		..()
		if(BOUNDS_DIST(owner, target) > 0 || picker == null || target == null || owner == null) //If the thing is suddenly out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || picker == null || target == null || owner == null || picker.working)  //If the thing is out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		else
			picker.working = 1
			playsound(picker.loc, 'sound/machines/whistlebeep.ogg', 50, 1)
			boutput(owner, SPAN_NOTICE("\The [picker.name] starts to pick up \the [target]."))
			if (picker.highpower && isghostdrone(owner))
				var/mob/living/silicon/ghostdrone/our_drone = owner
				if (!our_drone.cell) return
				var/hpm_cost = 25 * (target.w_class * 2 + 1)
				// Buff HPM by making it pick things up faster, at the expense of cell charge
				// only allow it if more than double that power remains to keep it from bottoming out
				if (our_drone.cell.charge >= hpm_cost * 2)
					duration /= 3
					our_drone.cell.use(hpm_cost)

	onInterrupt(var/flag) //They did something else while picking it up. I guess you dont have to do anything here unless you want to.
		..()
		picker.working = 0

	onEnd()
		..()
		//Shove the item into the picker here!!!
		if (ismob(target.loc))
			var/mob/M = target.loc
			M.u_equip(target)
		picker.pickupItem(target, owner)
		actions.start(new/datum/action/magPickerHold(picker, picker.highpower), owner)


/datum/action/magPickerHold
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED

	var/obj/item/magtractor/picker = null //This is the magpicker.

	New(Picker, hpm)
		if (hpm)
			src.interrupt_flags &= ~INTERRUPT_MOVE
		picker = Picker
		picker.holdAction = src
		..()

	onUpdate() //Again, check here for special conditions that are not normally handled in here. You probably dont need to do anything.
		..()
		if(picker == null || owner == null) //Interrupt if the user or the magpicker disappears.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		state = ACTIONSTATE_INFINITE //We can hold it indefinitely unless we move.
		if(picker == null || owner == null) //Interrupt if the user or the magpicker dont exist.
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if (picker)
			picker.dropItem()

	onInterrupt(var/flag)
		..()
		if (picker)
			picker.dropItem()


/datum/action/bar/icon/butcher_living_critter //Used when butchering a player-controlled critter
	duration = 120
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	var/mob/living/critter/target

	New(Target,var/dur = null)
		if(dur)
			duration = dur
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		if (target?.butcherer == owner)
			target.butcherer = null

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target.butcherer)
			interrupt(INTERRUPT_ALWAYS)
			return
		target.butcherer = owner
		owner.visible_message(SPAN_NOTICE("<B>[owner] begins to butcher [target].</B>"))

	onEnd()
		..()
		target?.butcherer = null
		if(owner && target)
			target.butcher(owner)
			owner.visible_message(SPAN_NOTICE("[owner] butchers [target].[target.butcherable == BUTCHER_YOU_MONSTER ? " <b>WHAT A MONSTER!</b>" : null]"), SPAN_NOTICE("You butcher [target]."))

/datum/action/bar/icon/critter_arm_removal // only supports things with left and right arms
	duration = 60
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	var/mob/living/critter/target
	var/left_or_right

	New(Target, LR)
		target = Target
		left_or_right = LR
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onInterrupt()
		..()
		if (target?.butcherer == owner)
			target.butcherer = null

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null || target.butcherer)
			interrupt(INTERRUPT_ALWAYS)
			return
		target.butcherer = owner
		target.visible_message(SPAN_ALERT("<B>[owner] begins to cut the [left_or_right] arm off of [target]. </B>"))

	onEnd()
		..()
		target?.butcherer = null
		if(owner && target)
			target.remove_arm(left_or_right)
			target.visible_message(SPAN_ALERT("<B>[owner] cuts the [left_or_right] arm off of [target].</B>"))

/datum/action/bar/icon/rev_flash
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "rev_imp"
	var/mob/living/target
	var/obj/item/device/flash/revolution/flash

	New(Flash, Target)
		flash = Flash
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(owner && target)
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/obj/item/implant/counterrev/found_imp = (locate(/obj/item/implant/counterrev) in H.implant)
				if (found_imp)
					found_imp.on_remove(target)
					H.implant.Remove(found_imp)
					qdel(found_imp)
					logTheThing(LOG_COMBAT, src.owner, "breaks [constructTarget(target)]'s counter-rev implant with a revolutionary flash at [log_loc(owner)]")

					playsound(target.loc, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, 0.1, 0, 0.9)
					target.visible_message(SPAN_NOTICE("The counter-revolutionary implant inside [target] shatters into one million pieces!"))

				flash.flash_mob(target, owner)

/datum/action/bar/icon/mop_thing
	duration = 30
	interrupt_flags = INTERRUPT_STUNNED
	icon = 'icons/obj/janitor.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "mop"
	var/atom/target
	var/obj/item/mop/mop

	New(Mop, Target)
		mop = Mop
		target = Target
		duration = istype(target,/obj/fluid) ? 0 : 10
		icon_state = mop.icon_state
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(owner && target)
			mop.clean(target, owner)

/datum/action/bar/icon/CPR
	duration = 4 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "cpr"
	var/mob/living/target

	New(target)
		..()
		src.target = target

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || target.health > 0 || !src.can_cpr())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || target.health > 0 || !src.can_cpr())
			interrupt(INTERRUPT_ALWAYS)
			return

		owner.visible_message(SPAN_NOTICE("<B>[owner] is trying to perform CPR on [target]!</B>"))
		..()

	onEnd()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || target.health > 0)
			..()
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/M = owner
		M.losebreath++ // ♪ give a little bit of your life to me ♪
		M.emote("gasp")

		target.take_oxygen_deprivation(-15)
		target.losebreath = 0
		target.changeStatus("unconscious", -2 SECONDS)

		if(target.find_ailment_by_type(/datum/ailment/malady/flatline) && target.health > -50)
			if ((target.reagents?.has_reagent("epinephrine") || target.reagents?.has_reagent("atropine")) ? prob(5) : prob(2))
				target.cure_disease_by_path(/datum/ailment/malady/flatline)

		owner.visible_message(SPAN_NOTICE("[owner] performs CPR on [target]!"))
		src.onRestart()

	proc/can_cpr()
		if (ishuman(owner))
			var/mob/living/carbon/human/human_owner = owner
			if (human_owner.head && (human_owner.head.c_flags & COVERSMOUTH))
				boutput(human_owner, SPAN_ALERT("You need to take off your headgear before you can give CPR!"))
				return FALSE

			if (human_owner.wear_mask)
				if (human_owner.wear_mask.c_flags & COVERSMOUTH)
					boutput(human_owner, SPAN_ALERT("You need to take off your facemask before you can give CPR!"))
					return FALSE
				if (istype(human_owner.wear_mask, /obj/item/clothing/mask/cigarette))
					var/obj/item/clothing/mask/cigarette/C = human_owner.wear_mask
					human_owner.u_equip(C)
					C.set_loc(human_owner.loc)
					boutput(human_owner, SPAN_ALERT("You spit out your cigarette in preparation to give CPR!"))

		if (ishuman(target))
			var/mob/living/carbon/human/human_target = target
			if (human_target.head && (human_target.head.c_flags & COVERSMOUTH))
				boutput(owner, SPAN_ALERT("You need to take off [human_target]'s headgear before you can give CPR!"))
				return FALSE

			if (human_target.wear_mask)
				if(human_target.wear_mask.c_flags & COVERSMOUTH)
					boutput(owner, SPAN_ALERT("You need to take off [human_target]'s facemask before you can give CPR!"))
					return FALSE
				if (istype(human_target.wear_mask, /obj/item/clothing/mask/cigarette))
					var/obj/item/clothing/mask/cigarette/C = human_target.wear_mask
					human_target.u_equip(C)
					C.set_loc(human_target.loc)
					boutput(owner, SPAN_ALERT("You knock the cigarette out of [human_target]'s mouth in preparation to give CPR!"))

		if (isdead(target))
			owner.visible_message(SPAN_ALERT("<B>[owner] tries to perform CPR, but it's too late for [target]!</B>"))
			return FALSE

		return TRUE

/datum/action/bar/icon/forcefeed
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/consumer
	var/obj/item/reagent_containers/food/snacks/food
	var/obj/item/reagent_containers/food/drinks/drink

	New(var/mob/consumer, var/item, var/icon, var/icon_state)
		..()
		src.consumer = consumer
		if (istype(item, /obj/item/reagent_containers/food/snacks))
			src.food = item
		else if (istype(item, /obj/item/reagent_containers/food/drinks/))
			src.drink = item
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/forcefeed called with invalid food/drink type [item].")
		src.icon = icon
		src.icon_state = icon_state


	onStart()
		if (!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		src.mob_owner = owner

		if(BOUNDS_DIST(owner, consumer) > 0 || !consumer || !owner || (mob_owner.equipped() != food && mob_owner.equipped() != drink))
			interrupt(INTERRUPT_ALWAYS)
			return
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, consumer) > 0 || !consumer || !owner || (mob_owner.equipped() != food && mob_owner.equipped() != drink))
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, consumer) > 0 || !consumer || !owner || (mob_owner.equipped() != food && mob_owner.equipped() != drink))
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!isnull(food))
			food.take_a_bite(consumer, mob_owner)
		else
			drink.take_a_drink(consumer, mob_owner)

/datum/action/bar/icon/syringe
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/target
	var/syringe_mode
	var/obj/item/reagent_containers/syringe/S

	New(var/mob/target, var/item, var/icon, var/icon_state)
		..()
		src.target = target
		if (istype(item, /obj/item/reagent_containers/syringe))
			S = item
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/syringe called with invalid type [item].")
		src.icon = icon
		src.icon_state = icon_state


	onStart()
		if (!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		src.mob_owner = owner
		syringe_mode = S.mode

		// only created if we're drawing blood from someone else
		logTheThing(LOG_COMBAT, mob_owner, "starts trying to draw blood from [constructTarget(target)].")

		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S)
			interrupt(INTERRUPT_ALWAYS)
			return
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S || syringe_mode != S.mode)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != S || syringe_mode != S.mode)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!isnull(S) && syringe_mode == S.mode)
			S.syringe_action(owner, target)

/datum/action/bar/icon/pill
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/mob_owner
	var/mob/target
	var/obj/item/reagent_containers/pill/P

	New(var/mob/target, var/item, var/icon, var/icon_state)
		..()
		src.target = target
		if (istype(item, /obj/item/reagent_containers/pill))
			P = item
			duration = round(clamp(P.reagents.total_volume, 30, 90) / 3 + 20)
		else
			logTheThing(LOG_DEBUG, src, "/datum/action/bar/icon/pill called with invalid type [item].")
		src.icon = icon
		src.icon_state = icon_state


	onStart()
		if (!ismob(owner))
			interrupt(INTERRUPT_ALWAYS)
			return

		src.mob_owner = owner

		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != P)
			interrupt(INTERRUPT_ALWAYS)
			return
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != P)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || !target || !owner || mob_owner.equipped() != P)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!isnull(P))
			P.pill_action(owner, target)


/datum/action/bar/private/spy_steal //Used when a spy tries to steal a large object
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/atom/target
	var/obj/item/uplink/integrated/pda/spy/uplink

	New(Target, Uplink)
		target = Target
		uplink = Uplink
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ismob(src.owner))
			var/mob/M = src.owner
			M.playsound_local(owner.loc, 'sound/machines/click.ogg', 60, 1)

	onEnd()
		..()
		if(owner && target && uplink)
			uplink.try_deliver(target, owner)



//DEBUG STUFF

/datum/action/bar/private/bombtest
	duration = 100

	onEnd()
		..()
		qdel(owner)

/obj/bombtest
	name = "large cartoon bomb"
	desc = "It looks like it's gonna blow."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "dumb_bomb"
	density = 1

	New()
		actions.start(new/datum/action/bar/private/bombtest(), src)
		..()

/datum/action/fire_roll //constant rolling
	duration = -1
	interrupt_flags = INTERRUPT_STUNNED

	var/mob/living/M = 0

	var/sfx_interval = 5
	var/sfx_count = 0

	var/pixely = 0
	var/up = 1

	New()
		..()

	onUpdate()
		..()
		if (M?.hasStatus("resting") && !M.stat && M.getStatusDuration("burning"))
			M.update_burning(-1.5)

			M.set_dir(turn(M.dir,up ? -90 : 90))
			pixely += up ? 1 : -1
			if (pixely != clamp(pixely, -5,5))
				up = !up
			M.pixel_y = pixely

			sfx_count += 1
			if (sfx_count >= sfx_interval)
				playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, 0 , 0.7)
				sfx_count = 0

			var/turf/T = get_turf(M)
			if (T.active_liquid)
				T.active_liquid.Crossed(M)

		else
			interrupt(INTERRUPT_ALWAYS)


	onStart()
		..()
		M = owner
		if (!M.hasStatus("resting"))
			M.setStatus("resting", INFINITE_STATUS)
			var/mob/living/carbon/human/H = M
			if (istype(H))
				H.hud.update_resting()
			for (var/mob/O in AIviewers(M))
				O.show_message(SPAN_ALERT("<B>[M] throws [himself_or_herself(M)] onto the floor!</B>"), 1, group = "resist")
		else
			for (var/mob/O in AIviewers(M))
				O.show_message(SPAN_ALERT("<B>[M] rolls around on the floor, trying to extinguish the flames.</B>"), 1, group = "resist")
		M.update_burning(-1.5)

		M.unlock_medal("Through the fire and flames", 1)
		playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, 0 , 0.7)

	onInterrupt(var/flag)
		..()
		if (M)
			M.pixel_y = 0

	onEnd()
		..()
		if (M)
			M.pixel_y = 0


/datum/action/bar/private/icon/pickup //Delayed pickup, used for mousedrags to prevent 'auto clicky' exploits but allot us to pickup with mousedrag as a possibel action
	duration = 0
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	var/obj/item/target
	icon = 'icons/ui/actions.dmi'
	icon_state = "pickup"

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, target) > 0 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(ishuman(owner)) //This is horrible and clunky and probably going to kill us all, I am so, so sorry.
			var/mob/living/carbon/human/H = owner
			if(H.limbs?.l_arm && !H.limbs.l_arm.can_hold_items)
				interrupt(INTERRUPT_ALWAYS)
				return
			if(H.limbs?.r_arm && !H.limbs.r_arm.can_hold_items)
				interrupt(INTERRUPT_ALWAYS)
				return

	onEnd()
		..()
		usr = owner // some stuff still uses usr, like context menus, sigh
		target.pick_up_by(owner)


	then_hud_click

		var/atom/over_object
		var/params

		New(Target, Over, Parameters)
			target = Target
			over_object = Over
			params = Parameters
			..()

		onEnd()
			..()
			target.try_equip_to_inventory_object(owner, over_object, params)

	then_obj_click

		var/atom/over_object
		var/params

		New(Target, Over, Parameters)
			target = Target
			over_object = Over
			params = Parameters
			..()

		onEnd()
			..()
			if (can_reach(owner,over_object) && ismob(owner) && owner:equipped() == target)
				usr = owner
				over_object.Attackby(target, owner, params)

/// general purpose action to anchor or unanchor stuff
/datum/action/bar/icon/anchor_or_unanchor
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/target
	var/obj/item/tool
	var/unanchor = FALSE

	New(var/obj/target, var/obj/item/tool, var/unanchor=null, var/duration=null)
		..()
		if (target)
			src.target = target
		if (tool)
			src.tool = tool
			icon = src.tool.icon
			icon_state = src.tool.icon_state
		if (!isnull(unanchor))
			src.unanchor = unanchor
		else
			src.unanchor = target.anchored
		if (duration)
			src.duration = duration
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (target == null || tool == null || owner == null || BOUNDS_DIST(owner, target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		if(unanchor && !target.anchored || !unanchor && target.anchored)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(iswrenchingtool(tool))
			playsound(target, 'sound/items/Ratchet.ogg', 50, TRUE)
		else if(isweldingtool(tool))
			tool:try_weld(owner,0,-1)
		else if(isscrewingtool(tool))
			playsound(target, 'sound/items/Screwdriver.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] begins [unanchor ? "un" : ""]anchoring [target]."))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner]  [unanchor ? "un" : ""]anchors [target]."))
		if(unanchor)
			target.anchored = UNANCHORED
		else
			target.anchored = ANCHORED


/datum/action/bar/icon/unhook_gangbag
	duration = 20 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "gang_dufflebag"
	id = "unhook_gangbag"
	var/obj/item/gang_loot/target

	New(new_owner, obj/item/gang_loot/new_target)
		owner = new_owner
		target = new_target
		..()
	onEnd()
		..()
		target.unhook()


/datum/action/bar/icon/doorhack
	duration = 3 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/gang.dmi'
	icon_state = "quickhack_fire"
	id = "quickhacking"
	var/maximum_range = 1
	var/obj/machinery/door/airlock/target
	var/obj/item/tool/quickhack/hack_tool

	New(Owner, Target, Hack)
		owner = Owner
		target = Target
		hack_tool = Hack
		..()

	onUpdate()
		..()
		if(!IN_RANGE(src.owner, target, maximum_range) || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (target && !IN_RANGE(src.owner, target, maximum_range))
			interrupt(INTERRUPT_ALWAYS)
		boutput(src.owner, "<span class='alert'>You press the [src.hack_tool.name] against the [src.target.name]...</span>")
		..()

	onEnd()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (src.target && !IN_RANGE(owner, target, maximum_range))
			interrupt(INTERRUPT_ALWAYS)
		else
			hack_tool.force_open(owner, target)



/datum/action/bar/icon/janktanktwo
	duration = JANKTANK2_CHANNEL_TIME
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/gang.dmi'
	icon_state = "janktank_2_inj"
	id = "janktanktwo"
	var/mob/living/carbon/human/target
	var/obj/item/tool/janktanktwo/injector

	New(Owner, Target, Injector)
		owner = Owner
		target = Target
		injector = Injector
		..()

	onStart()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (target && !IN_RANGE(src.owner, target, 1))
			interrupt(INTERRUPT_ALWAYS)
		boutput(src.owner, "<span class='alert'>You prepare the [injector.name], aiming right for [target]'s heart!</span>")
		..()

	onUpdate()
		..()
		if(!IN_RANGE(src.owner, target, 1) || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if (!src.owner)
			interrupt(INTERRUPT_ALWAYS)
		if (src.target && !IN_RANGE(owner, target, 1))
			interrupt(INTERRUPT_ALWAYS)
		else
			playsound(target.loc, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, 0)
			injector.inject(owner, target)


/datum/action/show_item
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = SHOWOFF_COOLDOWN
	var/mob/user = null
	var/obj/item/item = null
	var/hand_icon = ""
	var/pixel_x_offset = null
	var/pixel_y_offset = null
	var/pixel_x_hand_offset = null
	var/pixel_y_hand_offset = null

	New(mob/user, obj/item/item, hand_icon, x_offset = 6, y_offset = 2, x_hand_offset = 6, y_hand_offset = 2)
		. = ..()
		src.user = user
		src.item = item
		src.hand_icon = hand_icon
		src.pixel_x_offset = x_offset
		src.pixel_y_offset = y_offset
		src.pixel_x_hand_offset = x_hand_offset
		src.pixel_y_hand_offset = y_hand_offset

	onStart()
		. = ..()
		var/hand_icon_state = ""
		if(src.user.hand)
			hand_icon_state = "[hand_icon]_hold_l"
		else
			hand_icon_state = "[hand_icon]_hold_r"
			src.pixel_x_offset = -src.pixel_x_offset
			src.pixel_x_hand_offset = -src.pixel_x_hand_offset

		var/image/overlay = src.item.SafeGetOverlayImage("showoff_overlay", src.item.icon, src.item.icon_state, MOB_LAYER + 0.1, src.pixel_x_offset, src.pixel_y_offset)
		var/image/hand_overlay = src.item.SafeGetOverlayImage("showoff_hand_overlay", 'icons/effects/effects.dmi', hand_icon_state, MOB_LAYER + 0.11, src.pixel_x_hand_offset, src.pixel_y_hand_offset, color=user.get_fingertip_color())

		src.user.UpdateOverlays(overlay, "showoff_overlay")
		src.user.UpdateOverlays(hand_overlay, "showoff_hand_overlay")

		src.user.set_dir(SOUTH)

	onDelete()
		. = ..()
		src.user.UpdateOverlays(null, "showoff_overlay")
		src.user.UpdateOverlays(null, "showoff_hand_overlay")
