var/global/list/chem_whitelist = list("antihol", "charcoal", "epinephrine", "insulin", "mutadone", "teporone",\
"silver_sulfadiazine", "salbutamol", "perfluorodecalin", "omnizine", "synaptizine", "anti_rad",\
"oculine", "mannitol", "penteticacid", "styptic_powder", "methamphetamine", "spaceacillin", "saline",\
"salicylic_acid", "cryoxadone", "blood", "bloodc", "synthflesh",\
"menthol", "cold_medicine", "antihistamine", "ipecac",\
"booster_enzyme", "anti_fart", "goodnanites", "smelling_salt", "CBD")

/* =================================================== */
/* -------------------- Hypospray -------------------- */
/* =================================================== */

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "An advanced device capable of injecting various medicines into a patient instantaneously. Dumps any harmful chemicals."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	initial_volume = 30
	item_state = "syringe_0"
	icon_state = "hypo0"
	amount_per_transfer_from_this = 5
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH
	var/list/whitelist = list()
	var/inj_amount = 5
	var/safe = 1
	mats = 6
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/image/fluid_image
	var/sound/sound_inject = 'sound/items/hypo.ogg'
	hide_attack = ATTACK_PARTIALLY_HIDDEN
	inventory_counter_enabled = 1

	emagged
		New() // as it turns out it is me who is the dumb
			..()
			src.emag_act()

	New()
		..()
		if (src.safe && islist(chem_whitelist) && length(chem_whitelist))
			src.whitelist = chem_whitelist

	update_icon()
		if (src.reagents.total_volume)
			src.icon_state = "hypo1"
			src.name = "hypospray ([src.reagents.get_master_reagent_name()])"
			if (!src.fluid_image)
				src.fluid_image = image(src.icon, "hypoover", -1)
			src.fluid_image.color = src.reagents.get_master_color()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.icon_state = "hypo0"
			src.name = "hypospray"
			src.UpdateOverlays(null, "fluid")
		src.inventory_counter.update_number(src.reagents.total_volume)
		signal_event("icon_updated")

	on_reagent_change(add)
		..()
		if (src.safe && add)
			check_whitelist(src, src.whitelist)
		src.UpdateIcon()
		tgui_process.update_uis(src)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "Hypospray", "Hypospray")
			ui.open()

	ui_data(mob/user)
		. = list()
		var/datum/reagents/R = src.reagents
		var/list/reagentData = list(
			maxVolume = R.maximum_volume,
			totalVolume = R.total_volume,
			contents = list(),
			finalColor = "#000000"
		)

		var/list/contents = reagentData["contents"]
		if(istype(R) && R.reagent_list.len>0)
			reagentData["finalColor"] = R.get_average_rgb()
			for(var/reagent_id in R.reagent_list)
				var/datum/reagent/current_reagent = R.reagent_list[reagent_id]

				contents.Add(list(list(
					name = reagents_cache[reagent_id],
					id = reagent_id,
					colorR = current_reagent.fluid_r,
					colorG = current_reagent.fluid_g,
					colorB = current_reagent.fluid_b,
					volume = current_reagent.volume
				)))
		.["reagentData"] = reagentData
		.["injectionAmount"] = src.inj_amount
		.["emagged"] = !src.safe

	ui_act(action, params)
		. = ..()
		if(.)
			return
		switch(action)
			if("dump")
				src.reagents.clear_reagents()
				. = TRUE
			if("changeAmount")
				src.inj_amount = clamp(round(params["amount"]), 1, src.reagents.maximum_volume)
				. = TRUE


	attack_self(mob/user as mob)
		ui_interact(user)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!safe)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been disabled.", "red")
		safe = 0
		var/image/magged = image(src.icon, "hypomag", layer = FLOAT_LAYER)
		src.UpdateOverlays(magged, "emagged")
		tgui_process.update_uis(src)
		return 1

	demag(var/mob/user)
		if (safe)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been reactivated.", "blue")
		safe = 1
		src.UpdateOverlays(null, "emagged")
		src.UpdateIcon()
		tgui_process.update_uis(src)
		return 1

	attack(mob/M, mob/user, def_zone)
		if (issilicon(M))
			user.show_text("[src] cannot be used on silicon lifeforms!", "red")
			return

		if (!isliving(M))
			user.show_text("[src] can only be used on the living!", "red")
			return

		if (!reagents.total_volume)
			user.show_text("[src] is empty.", "red")
			return
		if(check_target_immunity(M))
			user.show_text("<span class='alert'>You can't seem to inject [M]!</span>")
			return
		var/amt_prop = inj_amount == -1 ? src.reagents.total_volume : inj_amount
		user.visible_message("<span class='notice'><B>[user] injects [M] with [min(amt_prop, reagents.total_volume)] units of [src.reagents.get_master_reagent_name()].</B></span>",\
		"<span class='notice'>You inject [min(amt_prop, reagents.total_volume)] units of [src.reagents.get_master_reagent_name()]. [src] now contains [max(0,(src.reagents.total_volume-amt_prop))] units.</span>")
		logTheThing(user == M ? LOG_CHEMISTRY : LOG_COMBAT, user, M, "uses a hypospray [log_reagents(src)] to inject [constructTarget(M,"combat")] at [log_loc(user)].")

		src.reagents.trans_to(M, amt_prop)

		if (src.safe && M.health < 90)
			JOB_XP(user, "Medical Doctor", 1)

		playsound(M, src.sound_inject, 80, 0)

		UpdateIcon()

	afterattack(obj/target, mob/user, flag)
		if (isobj(target) && target.is_open_container() && target.reagents)
			if (!src.reagents || !src.reagents.total_volume)
				boutput(user, "<span class='alert'>[src] is already empty.</span>")
				return

			if (target.reagents.is_full())
				boutput(user, "<span class='alert'>[target] is full!</span>")
				return

			logTheThing(LOG_CHEMISTRY, user, "dumps the contents of [src] [log_reagents(src)] into [target] at [log_loc(user)].")
			boutput(user, "<span class='notice'>You dump the contents of [src] into [target].</span>")
			src.reagents.trans_to(target, src.reagents.total_volume)

			playsound(src.loc, 'sound/misc/pourdrink2.ogg', 50, 1, 0.1)
			return
		else
			return ..()
