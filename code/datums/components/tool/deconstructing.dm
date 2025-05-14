TYPEINFO(/datum/component/deconstructing)
	initialization_args = list(
		ARG_INFO("deconMult", DATA_INPUT_NUM, "Multiplier for extra deconstruction time due to complexity.", 1),
	)

/datum/component/deconstructing
	var/decon_mult = 1

	Initialize(deconMult=1)
		..()
		src.decon_mult = deconMult

	///
	proc/finish_decon(atom/target, mob/user, atom/deconstructor)
		if (!isobj(target))
			return
		var/obj/O = target
		if(!O.can_deconstruct(user))
			return
		logTheThing(LOG_STATION, user, "deconstructs [target] in [user.loc.loc] ([log_loc(user)])")
		playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		user?.visible_message("<B>[user.name]</B> deconstructs [target].")
		O.become_frame(user)
		elecflash(deconstructor,power=2)

	/// When a user attacks a target
	proc/pre_attackby_decon(atom/target, mob/user, obj/item/decon_tool)
		if(user.a_intent == INTENT_HARM || !isobj(target))
			return
		var/obj/O = target
		if (O.deconstruct_flags == DECON_NONE)
			return

		var/decon_complexity = O.build_deconstruction_buttons()
		if (!decon_complexity || !O.can_deconstruct(user))
			if (O.deconstruct_flags & DECON_NULL_ACCESS)
				boutput(user, SPAN_ALERT("[target] is under an access lock and must have its access requirements removed before it can be deconstructed."))
			else
				boutput(user, SPAN_ALERT("[target] cannot be deconstructed."))
		else if (istext(decon_complexity))
			boutput(user, SPAN_ALERT("[decon_complexity]"))
		else if (issilicon(user) && (O.deconstruct_flags & DECON_NOBORG))
			boutput(user, SPAN_ALERT("Cyborgs cannot deconstruct this [target]."))
		else if ((!(O.allowed(user) || O.deconstruct_flags & DECON_NO_ACCESS) || O.is_syndicate) && !(O.deconstruct_flags & DECON_BUILT))
			boutput(user, SPAN_ALERT("You cannot deconstruct [target] without sufficient access to operate it."))
		else if(length(get_all_mobs_in(O)))
			boutput(user, SPAN_ALERT("You cannot deconstruct [target] while someone is inside it!"))
		else if (isrestrictedz(O.z) && !isitem(target) && !istype(get_area(O), /area/salvager)) //let salvagers deconstruct on the magpie
			boutput(user, SPAN_ALERT("You cannot bring yourself to deconstruct [target] in this area."))
		else if (O.decon_contexts && length(O.decon_contexts) <= 0) //ready!!!
			boutput(user, "Deconstructing [O], please remain still...")
			playsound(user.loc, 'sound/effects/pop.ogg', 50, 1)
			var/decon_time_extra = decon_complexity * 2.5 SECONDS * src.decon_mult
			actions.start(new/datum/action/bar/icon/deconstruct_obj(target,decon_tool,decon_time_extra), user)
		else
			user.showContextActions(O.decon_contexts, O)
			boutput(user, SPAN_ALERT("You need to use some tools on [target] before it can be deconstructed."))
		return ATTACK_PRE_DONT_ATTACK
