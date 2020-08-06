var/datum/action_controller/actions

//See _setup.dm for interrupt and state definitions

/datum/action_controller
	var/list/running = list() //Associative list of running actions, format: owner=list of action datums

	proc/hasAction(var/atom/owner, var/id) //has this mob an action of a given type running?
		if(owner in running)
			var/list/actions = running[owner]
			for(var/datum/action/A in actions)
				if(A.id == id) return 1
		return 0

	proc/stop_all(var/atom/owner) //Interrupts all actions of a given owner.
		if(running.Find(owner))
			for(var/datum/action/A in running[owner])
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stop(var/datum/action/A, var/atom/owner) //Manually interrupts a given action of a given owner.
		if(running.Find(owner))
			var/list/actions = running[owner]
			if(actions.Find(A))
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stopId(var/id, var/atom/owner) //Manually interrupts a given action id of a given owner.
		if(running.Find(owner))
			var/list/actions = running[owner]
			for(var/datum/action/A in actions)
				if(A.id == id)
					A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/start(var/datum/action/A, var/atom/owner) //Starts a new action.
		if(!(owner in running))
			running.Add(owner)
			running[owner] = list(A)
		else
			interrupt(owner, INTERRUPT_ACTION)
			for(var/datum/action/OA in running[owner])
				//Meant to catch users starting the same action twice, and saving the first-attempt from deletion
				if(OA.id == A.id && OA.state == ACTIONSTATE_DELETE)
					OA.onResume()
					qdel(A)
					return OA
			running[owner] += A
		A.owner = owner
		A.started = world.time
		A.onStart()
		return A // cirr here, I added action ref to the return because I need it for AI stuff, thank you

	proc/interrupt(var/atom/owner, var/flag) //Is called by all kinds of things to check for action interrupts.
		if(running.Find(owner))
			for(var/datum/action/A in running[owner])
				A.interrupt(flag)
		return

	proc/process() //Handles the action countdowns, updates and deletions.
		for(var/X in running)
			for(var/datum/action/A in running[X])

				if( ((A.duration >= 0 && world.time >= (A.started + A.duration)) && A.state == ACTIONSTATE_RUNNING) || A.state == ACTIONSTATE_FINISH)
					A.state = ACTIONSTATE_ENDED
					A.onEnd()
					//continue //If this is not commented out the deletion will take place the tick after the action ends. This will break things like objects being deleted onEnd with progressbars - the bars will be left behind. But it will look better for things that do not do this.

				if(A.state == ACTIONSTATE_DELETE)
					A.onDelete()
					running[X] -= A
					continue

				A.onUpdate()

			if(length(running[X]) == 0)
				running.Remove(X)
		return

/datum/action
	var/atom/owner = null //Object that owns this action.
	var/duration = 1 //How long does this action take in ticks.
	var/interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION //When and how this action is interrupted.
	var/state = ACTIONSTATE_STOPPED //Current state of the action.
	var/started = -1 //world.time this action was started at
	var/id = "base" //Unique ID for this action. For when you want to remove actions by ID on a person.

	proc/interrupt(var/flag) //This is called by the default interrupt actions
		if(interrupt_flags & flag || flag == INTERRUPT_ALWAYS)
			state = ACTIONSTATE_INTERRUPTED
			onInterrupt(flag)
		return

	proc/onUpdate() //Called every tick this action is running. If you absolutely(!!!) have to you can do manual interrupt checking in here. Otherwise this is mostly used for drawing progress bars and shit.
		return

	proc/onInterrupt(var/flag = 0) //Called when the action fails / is interrupted.
		state = ACTIONSTATE_DELETE
		return

	proc/onStart()				   //Called when the action begins
		state = ACTIONSTATE_RUNNING
		return

	proc/onRestart()			   //Called when the action restarts (for example: automenders)
		sleep(1)
		started = world.time
		state = ACTIONSTATE_RUNNING
		loopStart()
		return

	proc/loopStart()				//Called after restarting. Meant to cotain code from -and be called from- onStart()
		return

	proc/onResume()				   //Called when the action resumes - likely from almost ending
		state = ACTIONSTATE_RUNNING
		return

	proc/onEnd()				   //Called when the action succesfully ends.
		state = ACTIONSTATE_DELETE
		return

	proc/onDelete()				   //Called when the action is complete and about to be deleted. Usable for cleanup and such.
		return

	proc/updateBar()				// Updates the animations
		return

/datum/action/bar //This subclass has a progressbar that attaches to the owner to show how long we need to wait.
	var/obj/actions/bar/bar
	var/obj/actions/border/border

	onStart()
		..()
		var/atom/movable/A = owner
		if(owner != null)
			bar = unpool(/obj/actions/bar)
			bar.loc = owner.loc
			border = unpool(/obj/actions/border)
			border.loc = owner.loc
			bar.pixel_y = 5
			bar.pixel_x = 0
			border.pixel_y = 5
			if (!islist(A.attached_objs))
				A.attached_objs = list()
			A.attached_objs.Add(bar)
			A.attached_objs.Add(border)
			// this will absolutely obviously cause no problems.
			bar.color = "#4444FF"
			updateBar()

	onRestart()
		//Start the bar back at 0
		bar.transform = matrix(0, 0, -15, 0, 1, 0)
		..()

	onDelete()
		..()
		var/atom/movable/A = owner
		if (owner != null && islist(A.attached_objs))
			A.attached_objs.Remove(bar)
			A.attached_objs.Remove(border)
		SPAWN_DBG(0.5 SECONDS)
			if (bar)
				bar.set_loc(null)
				pool(bar)
				bar = null
			if (border)
				border.set_loc(null)
				pool(border)
				border = null

	disposing()
		var/atom/movable/A = owner
		if (owner != null && islist(A.attached_objs))
			A.attached_objs.Remove(bar)
			A.attached_objs.Remove(border)
		if (bar)
			bar.set_loc(null)
			pool(bar)
			bar = null
		if (border)
			border.set_loc(null)
			pool(border)
			border = null
		..()

	onEnd()
		if (bar)
			bar.color = "#FFFFFF"
			animate( bar, color = "#00CC00", time = 2.5 , flags = ANIMATION_END_NOW)
			bar.transform = matrix() //Tiny cosmetic fix. Makes it so the bar is completely filled when the action ends.
		..()

	onInterrupt(var/flag)
		if(state != ACTIONSTATE_DELETE)
			if (bar)
				updateBar(0)
				bar.color = "#FFFFFF"
				animate( bar, color = "#CC0000", time = 2.5 )
		..()

	onResume()
		if (bar)
			updateBar()
			bar.color = "#4444FF"
		..()

	onUpdate()
		updateBar()
		..()

	updateBar(var/animate = 1)
		if (duration <= 0)
			return
		var/done = world.time - started
		// inflate it a little to stop it from hitting 100% "too early"
		var/fakeduration = duration + ((animate && done < duration) ? (world.tick_lag * 7) : 0)
		var/remain = max(0, fakeduration - done)
		var/complete = clamp(done / fakeduration, 0, 1)
		bar.transform = matrix(complete, 0, -15 * (1 - complete), 0, 1, 0)
		if (animate)
			animate( bar, transform = matrix(1, 0, 0, 0, 1, 0), time = remain )
		else
			animate( bar, flags = ANIMATION_END_NOW )
		return

/datum/action/bar/blob_health // WOW HACK
	onUpdate()
		var/obj/blob/B = owner
		if (!owner || !istype(owner) || !bar || !border) //Wire note: Fix for Cannot modify null.invisibility
			return
		if (B.health == B.health_max)
			border.invisibility = 101
			bar.invisibility = 101
		else
			border.invisibility = 0
			bar.invisibility = 0
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
			shield_bar = unpool(/obj/actions/bar)
			shield_bar.loc = owner.loc
			armor_bar = unpool(/obj/actions/bar)
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
		shield_bar.invisibility = 0
		armor_bar.invisibility = 0
		bar.invisibility = 0
		border.invisibility = 0
		var/atom/movable/A = owner
		if (owner != null && islist(A.attached_objs))
			A.attached_objs.Remove(shield_bar)
			A.attached_objs.Remove(armor_bar)
		pool(shield_bar)
		shield_bar = null
		pool(armor_bar)
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
			armor_bar.invisibility = 0
			var/a_complete = B.armor / B.max_armor
			armor_bar.color = "#FF8800"
			armor_bar.transform = matrix(a_complete, 1, MATRIX_SCALE)
			armor_bar.pixel_x = -nround( ((30 - (30 * a_complete)) / 2) )
		else
			armor_bar.invisibility = 101
		if (B.max_shield && B.shield)
			shield_bar.invisibility = 0
			var/s_complete = B.shield / B.max_shield
			shield_bar.color = "#3333FF"
			shield_bar.transform = matrix(s_complete, 1, MATRIX_SCALE)
			shield_bar.pixel_x = -nround( ((30 - (30 * s_complete)) / 2) )
		else
			shield_bar.invisibility = 101


/datum/action/bar/blob_replicator
	onUpdate()
		var/obj/blob/deposit/replicator/B = owner
		if (!owner)
			return
		if (!B.converting || (B.converting && !B.converting.maximum_volume))
			border.invisibility = 101
			bar.invisibility = 101
			return
		else
			border.invisibility = 0
			bar.invisibility = 0
		var/complete = 1 - (B.converting.total_volume / B.converting.maximum_volume)
		bar.color = "#0000FF"
		bar.transform = matrix(complete, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * complete)) / 2) )

	onDelete()
		bar.invisibility = 0
		border.invisibility = 0
		..()

/datum/action/bar/icon //Visible to everyone and has an icon.
	var/icon
	var/icon_state
	var/icon_y_off = 30
	var/icon_x_off = 0
	var/image/icon_image
	var/icon_plane = PLANE_HUD

	onStart()
		..()
		if(icon && icon_state && owner)
			icon_image = image(icon, border ,icon_state, 10)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			icon_image.plane = icon_plane
			icon_image.filters += filter(type="outline", size=0.5, color=rgb(255,255,255))
			border.overlays += icon_image

	onDelete()
		if (bar)
			bar.overlays.Cut()
		if (icon_image)
			del(icon_image)
		..()

/datum/action/bar/icon/build
	duration = 30
	var/obj/item/sheet/sheet
	var/objtype
	var/cost
	var/datum/material/mat
	var/amount
	var/objname
	var/callback = null
	var/obj/item/sheet/sheet2 // in case you need to pull from more than one sheet
	var/cost2 // same as above
	var/spot
	New(var/obj/item/sheet/csheet, var/cobjtype, var/ccost, var/datum/material/cmat, var/camount, var/cicon, var/cicon_state, var/cobjname, var/post_action_callback = null, var/obj/item/sheet/csheet2, var/ccost2, var/spot)
		..()
		icon = cicon
		icon_state = cicon_state
		sheet = csheet
		objtype = cobjtype
		cost = ccost
		mat = cmat
		amount = camount
		objname = cobjname
		callback = post_action_callback
		src.spot = spot
		if (csheet2)
			sheet2 = csheet2
		if (ccost2)
			cost2 = ccost2

	onStart()
		..()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.traitHolder.hasTrait("carpenter"))
				duration = round(duration / 2)

		owner.visible_message("<span class='notice'>[owner] begins assembling [objname]!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] assembles [objname]!</span>")
		var/obj/item/R = new objtype(get_turf(spot || owner))
		R.setMaterial(mat)
		if (istype(R))
			R.amount = amount
			R.inventory_counter?.update_number(R.amount)
		R.dir = owner.dir
		sheet.consume_sheets(cost)
		if (sheet2 && cost2)
			sheet2.consume_sheets(cost2)
		logTheThing("station", owner, null, "builds [objname] (<b>Material:</b> [mat && istype(mat) && mat.mat_id ? "[mat.mat_id]" : "*UNKNOWN*"]) at [log_loc(owner)].")
		if (callback)
			call(callback)(src, R)

/datum/action/bar/icon/cruiser_repair
	id = "genproc"
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
		if(get_dist(owner, repairing) > 1 || repairing == null || owner == null || using == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/mob/source = owner
		if(using != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		owner.visible_message("<span class='notice'>[owner] begins repairing [repairing]!</span>")

	onEnd()
		..()
		owner.visible_message("<span class='notice'>[owner] successfully repairs [repairing]!</span>")
		repairing.adjustHealth(repairing.health_max)

/datum/action/bar/private //This subclass is only visible to the owner of the action
	onStart()
		..()
		bar.icon = null
		border.icon = null
		owner << bar.img
		owner << border.img

	onDelete()
		bar.icon = 'icons/ui/actions.dmi'
		border.icon = 'icons/ui/actions.dmi'
		del(bar.img)
		del(border.img)
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
			icon_image = image(icon ,owner,icon_state,10)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			icon_image.plane = icon_plane

			icon_image.filters += filter(type="outline", size=0.5, color=rgb(255,255,255))
			owner << icon_image

	onDelete()
		del(icon_image)
		..()

//ACTIONS
/datum/action/bar/icon/genericProc //Calls a specific proc with the given arguments when the action succeeds. TBI
	id = "genproc"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

/datum/action/bar/icon/otherItem//Putting items on or removing items from others.
	id = "otheritem"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	var/mob/living/carbon/human/source  //The person doing the action
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
				duration = 45
		else
			var/obj/item/I = target.get_slot(slot)
			if(I)
				if(I.duration_remove > 0)
					duration = I.duration_remove
				else
					duration = 25

		duration += ExtraDuration

		if(source.reagents && source.reagents.has_reagent("crime"))
			duration /= 5
		..()

	onStart()

		target.add_fingerprint(source) // Added for forensics (Convair880).

		if (source.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in source.grabbed_by)
				G.shoot()

		if(item)
			if(!target.can_equip(item, slot))
				boutput(source, "<span class='alert'>[item] can not be put there.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if(!isturf(target.loc))
				boutput(source, "<span class='alert'>You can't put [item] on [target] when [(he_or_she(target))] is in [target.loc]!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if(issilicon(source))
				source.show_text("You can't put \the [item] on [target] when it's attached to you!", "red")
				interrupt(INTERRUPT_ALWAYS)
				return
			logTheThing("combat", source, target, "tries to put \an [item] on [constructTarget(target,"combat")] at at [log_loc(target)].")
			icon = item.icon
			icon_state = item.icon_state
			for(var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><B>[source] tries to put [item] on [target]!</B></span>", 1)
		else
			var/obj/item/I = target.get_slot(slot)
			if(!I)
				boutput(source, "<span class='alert'>There's nothing in that slot.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			if(!isturf(target.loc))
				boutput(source, "<span class='alert'>You can't remove [I] from [target] when [(he_or_she(target))] is in [target.loc]!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			/* Some things use handle_other_remove to do stuff (ripping out staples, wiz hat probability, etc) should only be called once per removal.
			if(!I.handle_other_remove(source, target))
				boutput(source, "<span class='alert'>[I] can not be removed.</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			*/
			logTheThing("combat", source, target, "tries to remove \an [I] from [constructTarget(target,"combat")] at [log_loc(target)].")
			var/name = "something"
			if (!hidden)
				icon = I.icon
				icon_state = I.icon_state
				name = I.name

			for(var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><B>[source] tries to remove [name] from [target]!</B></span>", 1)

		..() // we call our parents here because we need to set our icon and icon_state before calling them

	onEnd()
		..()

		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		var/obj/item/I = target.get_slot(slot)

		if(item)
			if(item == source.equipped() && !I)
				if(target.can_equip(item, slot))
					logTheThing("combat", source, target, "successfully puts \an [item] on [constructTarget(target,"combat")] at at [log_loc(target)].")
					for(var/mob/O in AIviewers(owner))
						O.show_message("<span class='alert'><B>[source] puts [item] on [target]!</B></span>", 1)
					source.u_equip(item)
					target.force_equip(item, slot)
		else if (I) //Wire: Fix for Cannot execute null.handle other remove().
			if(I.handle_other_remove(source, target))
				logTheThing("combat", source, target, "successfully removes \an [I] from [constructTarget(target,"combat")] at [log_loc(target)].")
				for(var/mob/O in AIviewers(owner))
					O.show_message("<span class='alert'><B>[source] removes [I] from [target]!</B></span>", 1)

				// Re-added (Convair880).
				if (istype(I, /obj/item/mousetrap/))
					var/obj/item/mousetrap/MT = I
					if (MT && MT.armed)
						for (var/mob/O in AIviewers(owner))
							O.show_message("<span class='alert'><B>...and triggers it accidentally!</B></span>", 1)
						MT.triggered(source, source.hand ? "l_hand" : "r_hand")
				else if (istype(I, /obj/item/mine))
					var/obj/item/mine/M = I
					if (M.armed && M.used_up != 1)
						for (var/mob/O in AIviewers(owner))
							O.show_message("<span class='alert'><B>...and triggers it accidentally!</B></span>", 1)
						M.triggered(source)

				target.u_equip(I)
				I.set_loc(target.loc)
				I.dropped(target)
				I.layer = initial(I.layer)
				I.add_fingerprint(source)
			else
				boutput(source, "<span class='alert'>You fail to remove [I] from [target].</span>")
	onUpdate()
		..()
		if(get_dist(source, target) > 1 || target == null || source == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(item)
			if(item != source.equipped() || target.get_slot(slot))
				interrupt(INTERRUPT_ALWAYS)
		else
			if(!target.get_slot(slot=slot))
				interrupt(INTERRUPT_ALWAYS)

/datum/action/bar/icon/internalsOther //This is used when you try to set someones internals
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "internalsother"
	icon = 'icons/obj/clothing/item_masks.dmi'
	icon_state = "breath"
	var/mob/living/carbon/human/target
	var/remove_internals

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			if(target.internal)
				O.show_message("<span class='alert'><B>[owner] attempts to remove [target]'s internals!</B></span>", 1)
				remove_internals = 1
			else
				O.show_message("<span class='alert'><B>[owner] attempts to set [target]'s internals!</B></span>", 1)
				remove_internals = 0
	onEnd()
		..()
		if(owner && target && get_dist(owner, target) <= 1)
			if(remove_internals)
				target.internal.add_fingerprint(owner)
				for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
					T.icon_state = "airoff"
				target.internal = null
				for(var/mob/O in AIviewers(owner))
					O.show_message("<span class='alert'><B>[owner] removes [target]'s internals!</B></span>", 1)
			else
				if (!istype(target.wear_mask, /obj/item/clothing/mask))
					interrupt(INTERRUPT_ALWAYS)
					return
				else
					if (istype(target.back, /obj/item/tank))
						target.internal = target.back
						for (var/obj/ability_button/tank_valve_toggle/T in target.internal.ability_buttons)
							T.icon_state = "airon"
						for(var/mob/M in AIviewers(target, 1))
							M.show_message(text("[] is now running on internals.", src.target), 1)
						target.internal.add_fingerprint(owner)

/datum/action/bar/icon/handcuffSet //This is used when you try to handcuff someone.
	duration = 40
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffsset"
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
		if(get_dist(owner, target) > 1 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(target.hasStatus("handcuffed"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null || cuffs == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.traitHolder.hasTrait("training_security"))
				duration = round(duration / 2)

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to handcuff [target]!</B></span>", 1)

	onEnd()
		..()
		var/mob/ownerMob = owner
		if(owner && ownerMob && target && cuffs && !target.hasStatus("handcuffed") && cuffs == ownerMob.equipped() && get_dist(owner, target) <= 1)

			var/obj/item/handcuffs/cuffs2

			if (issilicon(ownerMob))
				cuffs2 = new /obj/item/handcuffs
			else
				if (cuffs.amount >= 2)
					cuffs2 = new /obj/item/handcuffs/tape
					cuffs.amount--
					boutput(ownerMob, "<span class='notice'>The [cuffs.name] now has [cuffs.amount] lengths of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"] left.</span>")
				else if (cuffs.amount == 1 && cuffs.delete_on_last_use == 1)
					cuffs2 = new /obj/item/handcuffs/tape
					ownerMob.u_equip(cuffs)
					boutput(ownerMob, "<span class='alert'>You used up the remaining length of [istype(cuffs, /obj/item/handcuffs/tape_roll) ? "tape" : "ziptie"].</span>")
					qdel(cuffs)
				else
					ownerMob.u_equip(cuffs)

			logTheThing("combat", ownerMob, target, "handcuffs [constructTarget(target,"combat")] with [cuffs2 ? "[cuffs2]" : "[cuffs]"] at [log_loc(ownerMob)].")

			if (cuffs2 && istype(cuffs2))
				cuffs2.set_loc(target)
				target.handcuffs = cuffs2
			else
				cuffs.set_loc(target)
				target.handcuffs = cuffs
			target.drop_from_slot(target.r_hand)
			target.drop_from_slot(target.l_hand)
			target.drop_juggle()
			target.setStatus("handcuffed", duration = INFINITE_STATUS)
			target.update_clothing()

			for(var/mob/O in AIviewers(ownerMob))
				O.show_message("<span class='alert'><B>[owner] handcuffs [target]!</B></span>", 1)

/datum/action/bar/icon/handcuffRemovalOther //This is used when you try to remove someone elses handcuffs.
	duration = 70
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffsother"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	var/mob/living/carbon/human/target

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(!target.hasStatus("handcuffed"))
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] attempts to remove [target]'s handcuffs!</B></span>", 1)

	onEnd()
		..()
		if(owner && target && target.hasStatus("handcuffed"))
			var/mob/living/carbon/human/H = target
			H.handcuffs.drop_handcuffs(H)
			for(var/mob/O in AIviewers(H))
				O.show_message("<span class='alert'><B>[owner] manages to remove [target]'s handcuffs!</B></span>", 1)

/datum/action/bar/private/icon/handcuffRemoval //This is used when you try to resist out of handcuffs.
	duration = 600
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "handcuffs"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		owner.visible_message("<span class='alert'><B>[owner] attempts to remove the handcuffs!</B></span>")

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>Your attempt to remove your handcuffs was interrupted!</span>")

	onEnd()
		..()
		if(owner != null && ishuman(owner) && owner.hasStatus("handcuffed"))
			var/mob/living/carbon/human/H = owner
			H.handcuffs.drop_handcuffs(H)
			H.visible_message("<span class='alert'><B>[H] attempts to remove the handcuffs!</B></span>")
			boutput(H, "<span class='notice'>You successfully remove your handcuffs.</span>")

/datum/action/bar/private/icon/shackles_removal // Resisting out of shackles (Convair880).
	duration = 450
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "shackles"
	icon = 'icons/obj/clothing/item_shoes.dmi'
	icon_state = "orange1"

	New(var/dur)
		duration = dur
		..()

	onStart()
		..()
		for(var/mob/O in AIviewers(owner))
			O.show_message(text("<span class='alert'><B>[] attempts to remove the shackles!</B></span>", owner), 1)

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>Your attempt to remove the shackles was interrupted!</span>")

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
					O.show_message("<span class='alert'><B>[H] manages to remove the shackles!</B></span>", 1)
				H.show_text("You successfully remove the shackles.", "blue")


//CLASSES & OBJS

/obj/actions //These objects are mostly used for the attached_objs var on mobs to attach progressbars to mobs.
	icon = 'icons/ui/actions.dmi'
	anchored = 1
	density = 0
	opacity = 0
	layer = 5
	name = ""
	desc = ""
	mouse_opacity = 0

/obj/actions/bar
	icon_state = "bar"
	layer = 101
	plane = PLANE_HUD + 1
	var/image/img
	New()
		img = image('icons/ui/actions.dmi',src,"bar",6)

	unpooled()
		img = image('icons/ui/actions.dmi',src,"bar",6)
		icon = initial(icon)
		icon_state = initial(icon_state)

	pooled()
		loc = null
		attached_objs = list()
		overlays.len = 0

/obj/actions/border
	layer = 100
	icon_state = "border"
	plane = PLANE_HUD + 1
	var/image/img
	New()
		img = image('icons/ui/actions.dmi',src,"border",5)

	unpooled()
		img = image('icons/ui/actions.dmi',src,"border",5)
		icon = initial(icon)
		icon_state = initial(icon_state)

	pooled()
		loc = null
		attached_objs = list()
		overlays.len = 0

//Use this to start the action
//actions.start(new/datum/action/bar/private/icon/magPicker(item, picker), usr)
/datum/action/bar/private/icon/magPicker
	duration = 30 //How long does this action take in ticks.
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "magpicker"
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
		if(get_dist(owner, target) > 1 || picker == null || target == null || owner == null) //If the thing is suddenly out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || picker == null || target == null || owner == null || picker.working)  //If the thing is out of range, interrupt the action. Also interrupt if the user or the item disappears.
			interrupt(INTERRUPT_ALWAYS)
			return
		else
			picker.working = 1
			playsound(picker.loc, "sound/machines/whistlebeep.ogg", 50, 1)
			out(owner, "<span class='notice'>\The [picker.name] starts to pick up \the [target].</span>")
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
	id = "magpickerhold"

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
	id = "butcherlivingcritter"
	var/mob/living/critter/target

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		for(var/mob/O in AIviewers(owner))
			O.show_message("<span class='alert'><B>[owner] begins to butcher [target].</B></span>", 1)

	onEnd()
		..()
		if(owner && target)
			target.butcher(owner)
			for(var/mob/O in AIviewers(owner))
				O.show_message("<span class='alert'><B>[owner] butchers [target].[target.butcherable == 2 ? "<b>WHAT A MONSTER</b>" : null]</B></span>", 1)

/datum/action/bar/icon/rev_flash
	duration = 13 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "rev_flash"
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
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(owner && target)
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/obj/item/implant/antirev/found_imp = (locate(/obj/item/implant/antirev) in H.implant)
				if (found_imp)
					found_imp.on_remove(target)
					H.implant.Remove(found_imp)
					qdel(found_imp)

					playsound(target.loc, 'sound/impact_sounds/Crystal_Shatter_1.ogg', 50, 0.1, 0, 0.9)
					target.visible_message("<span class='notice'>The loyalty implant inside [target] shatters into one million pieces!</span>")

				flash.flash_mob(target, owner)

/datum/action/bar/icon/mop_thing
	duration = 30
	interrupt_flags = INTERRUPT_STUNNED
	id = "mop_thing"
	icon = 'icons/obj/janitor.dmi' //In these two vars you can define an icon you want to have on your little progress bar.
	icon_state = "mop"
	var/atom/target
	var/obj/item/mop/mop

	New(Mop, Target)
		mop = Mop
		target = Target
		duration = istype(target,/obj/fluid) ? 0 : 10
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if(owner && target)
			mop.clean(target, owner)


/datum/action/bar/private/spy_steal //Used when a spy tries to steal a large object
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "spy_steal"
	var/atom/target
	var/obj/item/uplink/integrated/pda/spy/uplink

	New(Target, Uplink)
		target = Target
		uplink = Uplink
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		playsound(owner.loc, "sound/machines/click.ogg", 60, 1)

	onEnd()
		..()
		if(owner && target && uplink)
			uplink.try_deliver(target, owner)



//DEBUG STUFF

/datum/action/bar/private/bombtest
	duration = 100
	id = "bombtest"

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
	id = "fire_roll"

	var/mob/living/M = 0

	var/sfx_interval = 5
	var/sfx_count = 0

	var/pixely = 0
	var/up = 1

	New()
		..()

	onUpdate()
		..()
		if (M && M.hasStatus("resting") && !M.stat && M.getStatusDuration("burning"))
			M.update_burning(-1.2)

			M.dir = turn(M.dir,up ? -90 : 90)
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
				T.active_liquid.HasEntered(M, T)

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
				O.show_message("<span class='alert'><B>[M] throws themselves onto the floor!</B></span>", 1, group = "resist")
		else
			for (var/mob/O in AIviewers(M))
				O.show_message("<span class='alert'><B>[M] rolls around on the floor, trying to extinguish the flames.</B></span>", 1, group = "resist")
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
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "pickup"
	var/obj/item/target
	icon = 'icons/ui/actions.dmi'
	icon_state = "pickup"
	icon_plane = PLANE_HUD+2

	New(Target)
		target = Target
		..()

	onUpdate()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, target) > 1 || target == null || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
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
				over_object.attackby(target, owner, params)
