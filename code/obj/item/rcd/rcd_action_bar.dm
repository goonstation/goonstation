/datum/action/bar/icon/rcd_action
	var/atom/target
	var/mob/user
	var/obj/item/rcd/rcd
	var/callback_path
	var/list/additionalArguments
	var/ammo_cost
	var/callback_owner

	New(atom/target, mob/user, duration, obj/item/rcd/rcd, callback_path, callback_owner, ammo_cost, is_doing_surgery, list/arguments)
		..()

		src.target = target
		src.user = user
		src.duration = duration
		src.rcd = rcd
		src.callback_path = callback_path
		src.ammo_cost = ammo_cost
		src.callback_owner = callback_owner
		src.additionalArguments = arguments
		src.interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED

		src.icon = 'icons/ui/context16x16.dmi'
		src.icon_state = rcd_icon_state_from_mode(rcd.mode)

		src.apply_outline_filter = FALSE
		// If in the rare scenario where the RCD is being used for surgery,
		// it makes more sense for the action to appear above the would-be surgeon.

		if (!is_doing_surgery)
			src.place_to_put_bar = target
			src.bar_on_owner = FALSE
			src.icon_on_target = TRUE

	proc/rcd_icon_state_from_mode(mode)
		PRIVATE_PROC(TRUE)
		switch (mode)
			if (RCD_MODE_DECONSTRUCT)
				return "close"

			if (RCD_MODE_AIRLOCK)
				return "door"

			if (RCD_MODE_FLOORSWALLS)
				return "wall"

			if (RCD_MODE_LIGHTTUBES)
				return "tube"

			if (RCD_MODE_LIGHTBULBS)
				return "bulb"

			if (RCD_MODE_WINDOWS)
				return "window"

	onInterrupt(flag)
		. = ..(flag)

		if (istype(src.rcd))
			src.rcd.working_on -= src.target

	onUpdate()
		..()

		if (!can_reach(src.owner, src.target))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!can_reach(src.owner, src.rcd))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (src.user.equipped() != src.rcd)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()

		src.rcd.ammo_consume(src.owner, src.ammo_cost)
		var/datum/callback/cb = CALLBACK(src.callback_owner, src.callback_path)
		cb.arguments = list(src.target, src.owner) + src.additionalArguments
		cb.Invoke()

		playsound(src.rcd, 'sound/items/Deconstruct.ogg', 50, TRUE)
		src.rcd.sparkIfUnsafe()
		src.rcd.working_on -= src.target
