// Note: this component only affects deconstruction button repair
// Actual construction is still handled by the frame. That's just how it was originally.
/datum/component/soldering

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
