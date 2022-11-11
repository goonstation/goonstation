/* ================================================= */
/* -------------------- Dropper -------------------- */
/* ================================================= */

#define TO_SELF 0
#define TO_TARGET 1
/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	icon_state = "dropper0"
	initial_volume = 5
	amount_per_transfer_from_this = 5
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/icon_empty = "dropper0"
	var/icon_filled = "dropper1"
	var/image/fluid_image
	var/customizable_settings_available = 0
	var/transfer_amount = 5
	var/transfer_mode = TO_SELF

	on_reagent_change()
		..()
		src.underlays = null
		if (src.reagents.total_volume)
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "dropper1-fluid", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image

		src.UpdateIcon()
		return

	update_icon()
		if (!src || !istype(src))
			return

		if (src.reagents.total_volume)
			set_icon_state(src.icon_filled)
		else
			set_icon_state(src.icon_empty)

		return

	afterattack(obj/target, mob/user, flag)
		if (!src.reagents || !target.reagents)
			return

		if ((src.customizable_settings_available && src.transfer_mode == TO_SELF) || (!src.customizable_settings_available && !src.reagents.total_volume))
			var/t = min(src.transfer_amount, target.reagents.total_volume) // Can't draw more than THEY have.
			t = min(src.transfer_amount, src.reagents.maximum_volume - src.reagents.total_volume)
			if (t <= 0) return

			if (target.is_open_container() != 1 && !istype(target, /obj/reagent_dispensers))
				boutput(user, "<span class='alert'>You cannot directly remove reagents from [target].</span>")
				return
			if (!target.reagents.total_volume)
				boutput(user, "<span class='alert'>[target] is empty.</span>")
				return

			target.reagents.trans_to(src, t)
			boutput(user, "<span class='notice'>You fill the dropper with [t] units of the solution.</span>")
			src.UpdateIcon()

		else if ((src.customizable_settings_available && src.transfer_mode == TO_TARGET) || (!src.customizable_settings_available && src.reagents.total_volume))
			if (src.reagents.total_volume)
				var/t = min(src.transfer_amount, src.reagents.total_volume) // Can't drop more than you have.

				if (target.reagents.total_volume >= target.reagents.maximum_volume)
					boutput(user, "<span class='alert'>[target] is full.</span>")
					return
				if (target.is_open_container() != 1 && !ismob(target) && !istype(target, /obj/item/reagent_containers/food)) // You can inject humans and food but you can't remove the shit.
					boutput(user, "<span class='alert'>You cannot directly fill this object.</span>")
					return

				if (ismob(target))
					if (target != user)
						for (var/mob/O in AIviewers(world.view, user))
							O.show_message(text("<span class='alert'><B>[] is trying to drip something onto []!</B></span>", user, target), 1)
						src.log_me(user, target, 1)

						if (!do_mob(user, target, 15))
							if (user && ismob(user))
								user.show_text("You were interrupted!", "red")
							return
						if (!src.reagents || !src.reagents.total_volume)
							user.show_text("[src] doesn't contain any reagents.", "red")
							return

					for (var/mob/O in AIviewers(world.view, user))
						O.show_message(text("<span class='alert'><B>[] drips something onto []!</B></span>", user, target), 1)
					src.reagents.reaction(target, TOUCH, t) // Modify it so that the reaction only happens with the actual transferred amount.

				src.log_me(user, target)
				SPAWN(0.5 SECONDS)
					if (src?.reagents && target?.reagents)
						src.reagents.trans_to(target, t)

				user.show_text("You transfer [t] units of the solution.", "blue")
				src.UpdateIcon()
			else
				user.show_text("The [src] is empty!", "red")

		return

	proc/log_me(user, target, delayed = 0)
		if (!src || !istype(src) || !user|| !target)
			return

		logTheThing(LOG_COMBAT, user, "[delayed == 0 ? "drips" : "tries to drip"] chemicals [log_reagents(src)] from a dropper onto [constructTarget(target,"combat")] at [log_loc(user)].")
		return

/* ============================================================ */
/* -------------------- Mechanical Dropper -------------------- */
/* ============================================================ */

/obj/item/reagent_containers/dropper/mechanical
	name = "mechanical dropper"
	desc = "Allows you to transfer reagents in precise measurements."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "ppipette-empty"
	initial_volume = 10
	icon_empty = "ppipette-empty"
	icon_filled = "ppipette-filled"
	fluid_image = null
	customizable_settings_available = 1

	proc/set_transfer_amt(var/amt)
		src.transfer_amount = round(clamp(amt, 0, src.initial_volume), 0.1) // Sanity check.
		src.amount_per_transfer_from_this = src.transfer_amount
		return

	attack_self(mob/user)
		ui_interact(user)

	on_reagent_change()
		if (src.reagents.total_volume && !src.fluid_image)
			src.fluid_image = image(src.icon, "ppipette-fluid")

		if (src.reagents.is_full() && src.transfer_mode == TO_SELF)
			src.transfer_mode = TO_TARGET
		else if (!src.reagents.total_volume && src.transfer_mode == TO_TARGET)
			src.transfer_mode = TO_SELF
		src.UpdateIcon()
		..()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "MechanicalDropper")
			ui.open()

	ui_static_data(mob/user)
		. = list(
			"minTransferAmt" = 0,
			"maxTransferAmt" = src.reagents.maximum_volume,
		)


	ui_data(mob/user)
		. = list(
			"curTransferAmt" = src.transfer_amount,
			"transferMode" = transfer_mode,
			"curReagentVol" = src.reagents.total_volume,
			"reagentColor" = src.reagents.get_average_color().to_rgb(),
		)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		switch(action)
			if("mode")
				var/mode = params["mode"]
				src.transfer_mode = mode == TO_SELF ? TO_SELF : TO_TARGET;
				. = TRUE
			if ("amt")
				var/amt = params["amt"]
				set_transfer_amt(amt);
				. = TRUE

#undef TO_SELF
#undef TO_TARGET
