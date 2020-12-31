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
	var/transfer_amount = 5.0
	var/transfer_mode = TO_SELF

	on_reagent_change()
		src.underlays = null
		if (src.reagents.total_volume)
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "dropper1-fluid", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image

		src.update_icon()
		return

	proc/update_icon()
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
			src.update_icon()

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
				SPAWN_DBG(0.5 SECONDS)
					if (src?.reagents && target?.reagents)
						src.reagents.trans_to(target, t)

				user.show_text("You transfer [t] units of the solution.", "blue")
				src.update_icon()
			else
				user.show_text("The [src] is empty!", "red")

		return

	attack_self(mob/user)
		if (src.customizable_settings_available == 0)
			return

		var/t = {"<TT><h1>Mechanical dropper</h><br><hr>
				<table header="Wheel" border=1 width=300>
					<tr>
						<td>
							<center><b><font size=+1>Wheel</font></b></center>
					<tr>
						<td>
							<center><a href='?src=\ref[src];action=decr_int'>&#60;&#60;</a> <a href='?src=\ref[src];action=decr_dec'>&#60;</a> [transfer_amount] <a href='?src=\ref[src];action=incr_dec'>&#62;</a> <a href='?src=\ref[src];action=incr_int'>&#62;&#62;</a></center>
					<tr>
						<td>
							<center><b><font size=+1>Mode</font></b></center>
					<tr>
						<td>
							<center><a href='?src=\ref[src];action=toggle_mode'>[transfer_mode == TO_SELF ? "DRAW":"DROP"]</a></center>
				</table>"}

		user.Browse(t,"window=mechdropper")
		onclose(user, "mechdropper")
		return

	Topic(href, href_list)
		if (get_dist(src, usr) > 1 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (usr.getStatusDuration("stunned") > 0 || usr.getStatusDuration("weakened") || usr.getStatusDuration("paralysis") > 0 || !isalive(usr) || usr.restrained())
			return

		..()

		switch(href_list["action"])
			//Decrease transfer amount
			if ("decr_int") modify_transfer_amt(-1)

			if ("decr_dec") modify_transfer_amt(-0.1)

			//increase it
			if ("incr_int") modify_transfer_amt(1)

			if ("incr_dec") modify_transfer_amt(0.1)

			if ("toggle_mode") transfer_mode = !transfer_mode

		if (usr) attack_self(usr)

	proc/modify_transfer_amt(var/diff)
		src.transfer_amount += diff
		src.transfer_amount = min(max(transfer_amount, 0.1), 10) // Sanity check.
		src.amount_per_transfer_from_this = src.transfer_amount
		return

	proc/log_me(var/user, var/target, var/delayed = 0)
		if (!src || !istype(src) || !user|| !target)
			return

		logTheThing("combat", user, target, "[delayed == 0 ? "drips" : "tries to drip"] chemicals [log_reagents(src)] from a dropper onto [constructTarget(target,"combat")] at [log_loc(user)].")
		return

#undef TO_SELF
#undef TO_TARGET

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

	on_reagent_change()
		if (src.reagents.total_volume && !src.fluid_image)
			src.fluid_image = image(src.icon, "ppipette-fluid")
		..()
