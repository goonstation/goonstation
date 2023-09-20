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
		if(owner in running)
			for(var/datum/action/A in running[owner])
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stop(var/datum/action/A, var/atom/owner) //Manually interrupts a given action of a given owner.
		if(owner in running)
			var/list/actions = running[owner]
			if(A in actions)
				A.interrupt(INTERRUPT_ALWAYS)
		return

	proc/stopId(var/id, var/atom/owner) //Manually interrupts a given action id of a given owner.
		if(owner in running)
			var/list/actions = running[owner]
			for(var/datum/action/A in actions)
				if(A.id == id)
					A.interrupt(INTERRUPT_ALWAYS)
		return

	/// Starts an action and waits for it to finish, returns TRUE if it finished successfully, FALSE if it was interrupted.
	proc/start_and_wait(datum/action/A, atom/owner, timeout=null)
		if(isnull(A.promise))
			A.promise = new()
		src.start(A, owner)
		return !!A.promise.wait_for_value(timeout=timeout)

	proc/start(var/datum/action/A, var/atom/owner) //! Starts a new action.
		if(!owner)
			qdel(A)
			return
		if(!(owner in running))
			running.Add(owner)
			running[owner] = list(A)
		else
			interrupt(owner, INTERRUPT_ACTION)
			for(var/datum/action/OA in running[owner])
				//Meant to catch users starting the same action twice, and saving the first-attempt from deletion
				if(OA.id == A.id && OA.state == ACTIONSTATE_DELETE && (OA.interrupt_flags & INTERRUPT_ACTION) && OA.resumable)
					if(OA.interrupt_start != -1)
						OA.interrupt_time += TIME - OA.interrupt_start
						OA.interrupt_start = -1
					OA.canRunCheck()
					if(OA.state == ACTIONSTATE_DELETE || OA.state == ACTIONSTATE_RUNNING || OA.state == ACTIONSTATE_INFINITE)
						OA.onResume(A)
					if(OA.state == ACTIONSTATE_RUNNING || OA.state == ACTIONSTATE_INFINITE)
						OA.onUpdate()
					qdel(A)
					return OA
			running[owner] += A
		A.owner = owner
		A.started = TIME
		A.canRunCheck(in_start = TRUE)
		if(A.state == ACTIONSTATE_STOPPED || A.state == ACTIONSTATE_RUNNING || A.state == ACTIONSTATE_INFINITE)
			A.onStart()
		if(A.state == ACTIONSTATE_RUNNING || A.state == ACTIONSTATE_INFINITE)
			A.onUpdate()
		return A // cirr here, I added action ref to the return because I need it for AI stuff, thank you

	proc/interrupt(var/atom/owner, var/flag) //! Is called by all kinds of things to check for action interrupts.
		if(owner in running)
			for(var/datum/action/A in running[owner])
				A.interrupt(flag)
		return

	proc/process() //! Handles the action countdowns, updates and deletions.
		for(var/X in running)
			for(var/datum/action/A in running[X])

				if( ((A.duration >= 0 && A.time_spent() >= A.duration) && A.state == ACTIONSTATE_RUNNING) || A.state == ACTIONSTATE_FINISH)
					A.state = ACTIONSTATE_ENDED
					A.onEnd()
					A.promise?.fulfill(A)
					//continue //If this is not commented out the deletion will take place the tick after the action ends. This will break things like objects being deleted onEnd with progressbars - the bars will be left behind. But it will look better for things that do not do this.

				if(A.state == ACTIONSTATE_DELETE || A.disposed)
					A.onDelete()
					running[X] -= A
					if(A.promise && !A.promise.fulfilled)
						A?.promise.fulfill(null)
					continue

				A.canRunCheck()
				if(A.state != ACTIONSTATE_INTERRUPTED)
					A.onUpdate()

			if(length(running[X]) == 0)
				running.Remove(X)
		return

/datum/action
	var/atom/owner = null //! Object that owns this action.
	var/duration = 1 //! How long does this action take in ticks.
	var/interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION //! When and how this action is interrupted.
	var/state = ACTIONSTATE_STOPPED //! Current state of the action.
	var/started = -1 //! TIME this action was started at
	var/id = "base" //! Unique ID for this action. For when you want to remove actions by ID on a person.
	var/resumable = TRUE
	var/datum/promise/promise //! Promise that will be fulfilled when the action is finished or deleted. Finished = fulfilled with the action, deleted = fulfilled with null.
	var/interrupt_time = 0 //! How long the action spent interrupted. Used to calculate the remaining time when resuming.
	var/interrupt_start = -1 //! When the action was interrupted. Used to calculate interrupt_time

	proc/time_spent()
		if(interrupt_start == -1)
			return TIME - started - interrupt_time
		else
			return interrupt_start - started - interrupt_time

	proc/interrupt(flag, can_resume=TRUE) //! This is called by the default interrupt actions
		if(interrupt_flags & flag || flag == INTERRUPT_ALWAYS)
			if(state != ACTIONSTATE_INTERRUPTED)
				interrupt_start = TIME
			if(!can_resume || flag == INTERRUPT_ALWAYS)
				resumable = FALSE
			state = ACTIONSTATE_INTERRUPTED
			onInterrupt(flag)
		return

	proc/onUpdate() //! Called every tick this action is running. If you absolutely(!!!) have to you can do manual interrupt checking in here. Otherwise this is mostly used for drawing progress bars and shit.
		return

	proc/onInterrupt(var/flag = 0) //! Called when the action fails / is interrupted.
		SHOULD_CALL_PARENT(TRUE)
		state = ACTIONSTATE_DELETE
		return

	proc/onStart()				   //! Called when the action begins
		SHOULD_CALL_PARENT(TRUE)
		state = ACTIONSTATE_RUNNING
		return

	proc/onRestart()			   //! Called when the action restarts (for example: automenders)
		SHOULD_CALL_PARENT(TRUE)
		sleep(1)
		started = TIME
		state = ACTIONSTATE_RUNNING
		canRunCheck()
		if(state == ACTIONSTATE_RUNNING)
			loopStart()

	proc/loopStart()				//! Called after restarting. Meant to cotain code from -and be called from- onStart()
		SHOULD_CALL_PARENT(TRUE)
		return

	proc/onResume(datum/action/attempted)	 //! Called when the action resumes - likely from almost ending. Arg is the action which would have cancelled this.
		SHOULD_CALL_PARENT(TRUE)
		state = ACTIONSTATE_RUNNING
		return

	proc/onEnd()				   //! Called when the action succesfully ends.
		SHOULD_CALL_PARENT(TRUE)
		state = ACTIONSTATE_DELETE
		return

	proc/onDelete()				   //! Called when the action is complete and about to be deleted. Usable for cleanup and such.
		SHOULD_CALL_PARENT(TRUE)
		return

	/// Ran before onStart, onUpdate, onResume and in onRestart. Call interrupt here to stop the action from starting.
	proc/canRunCheck(in_start = FALSE)
		return

	proc/updateBar()				//! Updates the animations
		return

/datum/action/bar //! This subclass has a progressbar that attaches to the owner to show how long we need to wait.
	var/obj/actions/bar/bar
	var/obj/actions/border/border
	var/obj/actions/bar/target_bar
	var/obj/actions/border/target_border
	var/bar_icon_state = "bar"
	var/border_icon_state = "border"
	var/color_active = "#4444FF"
	var/color_success = "#00CC00"
	var/color_failure = "#CC0000"
	/// By default the bar is put on the owner, define this on the progress bar as the place you want to put it on.
	var/atom/movable/place_to_put_bar = null
	/// In case we want the owner to have no visible action bar but still want to make the bar.
	var/bar_on_owner = TRUE
	/// Does bar fill or empty?
	var/fill_bar = TRUE


	onStart()
		..()
		var/atom/movable/A = owner
		if(owner != null)
			bar = new /obj/actions/bar
			border = new /obj/actions/border
			border.set_icon_state(src.border_icon_state)
			bar.set_icon_state(src.bar_icon_state)
			bar.pixel_y = 5
			bar.pixel_x = 0
			border.pixel_y = 5
			if (bar_on_owner)
				A.vis_contents += bar
				A.vis_contents += border
			if (place_to_put_bar)
				target_bar = new /obj/actions/bar
				target_border = new /obj/actions/border
				target_border.set_icon_state(src.border_icon_state)
				target_bar.set_icon_state(src.bar_icon_state)
				target_bar.pixel_y = 5
				target_bar.pixel_x = 0
				target_border.pixel_y = 5
				place_to_put_bar.vis_contents += target_bar
				place_to_put_bar.vis_contents += target_border

			// this will absolutely obviously cause no problems.
			bar.color = src.color_active
			if (target_bar)
				target_bar.color = src.color_active
			updateBar()

	onRestart()
		//Start the bar back at 0
		bar.transform = matrix(0, 0, -15, 0, 1, 0)
		if (target_bar)
			target_bar.transform = matrix(0, 0, -15, 0, 1, 0)
		..()

	onDelete()
		..()
		var/atom/movable/A = owner
		if (owner && bar_on_owner)
			A.vis_contents -= bar
			A.vis_contents -= border
		if (place_to_put_bar)
			place_to_put_bar.vis_contents -= target_bar
			place_to_put_bar.vis_contents -= target_border
		SPAWN(0.5 SECONDS)
			if (bar)
				bar.set_loc(null)
				qdel(bar)
				bar = null
			if (border)
				border.set_loc(null)
				qdel(border)
				border = null
			if (target_bar)
				target_bar.set_loc(null)
				qdel(target_bar)
				target_bar = null
			if (target_border)
				target_border.set_loc(null)
				qdel(target_border)
				target_border = null

	disposing()
		var/atom/movable/A = owner
		if (owner && bar_on_owner)
			A.vis_contents -= bar
			A.vis_contents -= border
		if (place_to_put_bar)
			place_to_put_bar.vis_contents -= target_bar
			place_to_put_bar.vis_contents -= target_border
		if (bar)
			bar.set_loc(null)
			qdel(bar)
			bar = null
		if (border)
			border.set_loc(null)
			qdel(border)
			border = null
		if (target_bar)
			target_bar.set_loc(null)
			qdel(target_bar)
			target_bar = null
		if (target_border)
			target_border.set_loc(null)
			qdel(target_border)
			target_border = null
		..()

	onEnd()
		if (bar)
			bar.color = "#FFFFFF"
			animate( bar, color = src.color_success, time = 2.5 , flags = ANIMATION_END_NOW)
			bar.transform = matrix() //Tiny cosmetic fix. Makes it so the bar is completely filled when the action ends.
		if (target_bar)
			target_bar.color = "#FFFFFF"
			animate( target_bar, color = src.color_success, time = 2.5 , flags = ANIMATION_END_NOW)
			target_bar.transform = matrix() //Tiny cosmetic fix. Makes it so the target's bar is completely filled when the action ends.
		..()

	onInterrupt(var/flag)
		if(state != ACTIONSTATE_DELETE)
			if (bar)
				updateBar(0)
				bar.color = "#FFFFFF"
				animate( bar, color = src.color_failure, time = 2.5 )
			if (target_bar)
				updateBar(0)
				target_bar.color = "#FFFFFF"
				animate( target_bar, color = src.color_failure, time = 2.5 )
		..()

	onResume(datum/action/attempted)
		if (bar)
			updateBar()
			bar.color = src.color_active
		if (target_bar)
			updateBar()
			target_bar.color = src.color_active
		..()

	onUpdate()
		updateBar()
		..()

	updateBar(var/animate = 1)
		if (duration <= 0 || isnull(bar))
			return
		var/done = src.time_spent()
		// inflate it a little to stop it from hitting 100% "too early"
		var/fakeduration = duration + ((animate && done < duration) ? (world.tick_lag * 7) : 0)
		var/remain = max(0, fakeduration - done)
		var/complete = clamp(done / fakeduration, 0, 1)
		if(!fill_bar)
			complete = 1 - complete
		bar.transform = matrix(complete, 0, -15 * (1 - complete), 0, 1, 0)
		if (target_bar)
			target_bar.transform = matrix(complete, 0, -15 * (1 - complete), 0, 1, 0)
		if (animate)
			if(fill_bar)
				animate( bar, transform = matrix(1, 0, 0, 0, 1, 0), time = remain )
				if (target_bar)
					animate( target_bar, transform = matrix(1, 0, 0, 0, 1, 0), time = remain )
			else
				animate( bar, transform = matrix(0, 0, -15, 0, 1, 0), time = remain )
				if (target_bar)
					animate( target_bar, transform = matrix(0, 0, -15, 0, 1, 0), time = remain )
		else
			animate( bar, flags = ANIMATION_END_NOW )
			if (target_bar)
				animate( target_bar, flags = ANIMATION_END_NOW )
		return

/datum/action/bar/icon //Visible to everyone and has an icon.
	var/icon //! Icon to use above the bar. Can also be a mutable_appearance; pretty much anything that can be converted into an image
	var/icon_state
	var/icon_y_off = 30
	var/icon_x_off = 0
	var/image/icon_image
	var/icon_plane = PLANE_HUD
	/// Is the icon also on the target if we have one? if this is TRUE, make sure the target only handles overlays by using the UpdateOverlays proc.
	var/icon_on_target = FALSE

	onStart()
		..()
		if (icon && owner)
			if(icon_state)
				icon_image = image(icon, border, icon_state, 10)
			else
				icon_image = image(icon, border, layer = 10)
			icon_image.pixel_y = icon_y_off
			icon_image.pixel_x = icon_x_off
			icon_image.plane = icon_plane
			icon_image.layer = 10
			icon_image.filters += filter(type="outline", size=0.5, color=rgb(255,255,255))
			border.UpdateOverlays(icon_image, "action_icon")
			if (icon_on_target && place_to_put_bar)
				target_border.UpdateOverlays(icon_image, "action_icon")

	onDelete()
		if (icon_on_target && place_to_put_bar && target_border)
			target_border.UpdateOverlays(null, "action_icon")
		if (border)
			border.UpdateOverlays(null, "action_icon")
		if (icon_image)
			qdel(icon_image)
		..()


/**
* calls a specified proc if it finishes without interruptions.
*
* check [_std/macros/actions.dm] for documentation on a macro that uses this.
*/
/datum/action/bar/icon/callback
	/// set to a string version of the callback proc path
	id = null
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
