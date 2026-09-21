TYPEINFO(/datum/component/soldering)
	initialization_args = list(
		ARG_INFO("solderTime", DATA_INPUT_NUM, "Time to build a frame.", 1 SECOND),
	)

// Note: this component only affects deconstruction button repair
// Actual construction is still handled by the frame. That's just how it was originally.
/datum/component/soldering
	var/solder_time = 1 SECOND

	Initialize(solderTime=1 SECOND)
		..()
		src.solder_time = solderTime

	/// Bring back an object's deconstruction buttons
	proc/repair_deconstruction_buttons(atom/target, mob/user, var/text = null)
		if (!isobj(target))
			return
		var/obj/O = target
		var/decon_len = O.decon_contexts ? O.decon_contexts.len : 0
		O.decon_contexts = null
		if (O.build_deconstruction_buttons() != decon_len)
			if(text)
				boutput(user, SPAN_ALERT(text))
			else
				boutput(user, SPAN_ALERT("You repair \the [target]'s deconstructed state."))
			return

/datum/action/bar/icon/build_electronics_frame
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"
	var/obj/item/electronics/frame/frame = null
	var/density_check = FALSE

	New(Frame, var/dur)
		src.frame = Frame
		src.duration = dur

		if(src.frame.deconstructed_thing)
			density_check = src.frame.deconstructed_thing.density
		else
			var/atom/A = src.frame.store_type
			density_check = initial(A.density)
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(src.owner, src.frame) > 0 || src.frame == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/turf/T = get_turf(src.frame)
		if(T.density || density_check && !T.can_crossed_by(src.frame))
			boutput(owner, SPAN_ALERT("There's no room to deploy the frame."))
			src.resumable = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(src.owner, src.frame) > 0 || src.frame == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/turf/T = get_turf(src.frame)
		if(T.density || density_check && !T.can_crossed_by(src.frame))
			boutput(owner, SPAN_ALERT("There's no room to deploy the frame."))
			src.resumable = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(src.owner, src.frame) > 0 || src.frame == null || src.owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/turf/T = get_turf(src.frame)
		if(T.density || density_check && !T.can_crossed_by(src.frame))
			boutput(owner, SPAN_ALERT("There's no room to deploy the frame."))
			src.resumable = FALSE
			interrupt(INTERRUPT_ALWAYS)
			return

		if(src.owner && src.frame)
			src.frame.deploy(owner)
