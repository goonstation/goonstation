TYPEINFO(/datum/component/deconstructing)
	initialization_args = list(
		ARG_INFO("baseDuration", DATA_INPUT_NUM, "Minimum deconstruction time.", 2 SECONDS),
		ARG_INFO("complexityMult", DATA_INPUT_NUM, "Multiplier for extra deconstruction time due to complexity.", 1),
	)

// Component used for tools that deconstruct things
/datum/component/deconstructing
	var/base_duration = 2 SECONDS
	var/complexity_mult = 1 //! How much complexity affects deconstruction time
	var/contextLayout

	Initialize(baseDuration=2 SECONDS, complexityMult=1)
		..()
		src.base_duration = baseDuration
		src.complexity_mult = complexityMult
		src.contextLayout = new/datum/contextLayout/flexdefault()

	///
	proc/finish_decon(atom/target, mob/user, atom/deconstructor)
		if (!isobj(target))
			return
		var/obj/O = target
		if (!O.can_deconstruct(user))
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
			var/decon_time = (decon_complexity * 2.5 SECONDS * src.complexity_mult) + src.base_duration
			actions.start(new/datum/action/bar/icon/deconstruct_obj(target,decon_tool,decon_time), user)
		else
			if (istype(O, /obj/item/storage/secure/ssafe)) //checks if secure safes are unlocked before attempting to deconstruct them.
				var/obj/item/storage/secure/safe = target
				if (safe.locked)
					boutput(user, SPAN_ALERT("You cannot deconstruct [target] while it is locked."))
					return ATTACK_PRE_DONT_ATTACK
			user.showContextActions(O.decon_contexts, O, src.contextLayout)
			boutput(user, SPAN_ALERT("You need to use some tools on [target] before it can be deconstructed."))
		return ATTACK_PRE_DONT_ATTACK

/datum/action/bar/icon/deconstruct_obj
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "decon"
	var/obj/target
	var/obj/item/decon_tool
	New(Obj, Decon, decon_time)
		src.target = Obj
		src.decon_tool = Decon
		src.duration = decon_time
		..()

	onUpdate()
		..()
		if(!can_decon_target())
			interrupt(INTERRUPT_ALWAYS)
		return

	onStart()
		..()
		if(!can_decon_target())
			interrupt(INTERRUPT_ALWAYS)
		return

	onEnd()
		..()
		if(!can_decon_target())
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ismob(owner))
			var/mob/M = owner
			if (!(decon_tool in M.equipped_list()))
				interrupt(INTERRUPT_ALWAYS)
				return
		var/datum/component/deconstructing/decon_comp = decon_tool.GetComponent(/datum/component/deconstructing)
		decon_comp.finish_decon(target, owner, decon_tool)

	onInterrupt()
		if (target && owner)
			boutput(owner, SPAN_ALERT("Deconstruction of [target] interrupted!"))
		..()

	proc/can_decon_target()
		return BOUNDS_DIST(owner, target) == 0 || target != null || owner != null || isdeconstructingtool(decon_tool) || !(locate(/mob/living) in target) || target.can_deconstruct(owner)
