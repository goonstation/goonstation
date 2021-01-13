var/global/list/chem_whitelist = list("antihol", "charcoal", "epinephrine", "insulin", "mutadone", "teporone",\
"silver_sulfadiazine", "salbutamol", "perfluorodecalin", "omnizine", "stimulants", "synaptizine", "anti_rad",\
"oculine", "mannitol", "penteticacid", "styptic_powder", "methamphetamine", "spaceacillin", "saline",\
"salicylic_acid", "cryoxadone", "blood", "bloodc", "synthflesh",\
"menthol", "cold_medicine", "antihistamine", "ipecac",\
"booster_enzyme", "anti_fart", "goodnanites", "smelling_salt")

/* =================================================== */
/* -------------------- Hypospray -------------------- */
/* =================================================== */

/obj/item/reagent_containers/hypospray
	name = "hypospray"
	desc = "An automated injector that will dump out any harmful chemicals it finds in itself."
	icon = 'icons/obj/chemical.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_medical.dmi'
	initial_volume = 30
	item_state = "syringe_0"
	icon_state = "hypo0"
	amount_per_transfer_from_this = 5
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH
	module_research = list("science" = 3, "medicine" = 2)
	module_research_type = /obj/item/reagent_containers/hypospray
	var/list/whitelist = list()
	var/inj_amount = 5
	var/safe = 1
	mats = 6
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	var/image/fluid_image
	var/sound/sound_inject = 'sound/items/hypo.ogg'
	hide_attack = 2
	inventory_counter_enabled = 1

	emagged
		New() // as it turns out it is me who is the dumb
			..()
			src.emag_act()

	New()
		..()
		if (src.safe && islist(chem_whitelist) && chem_whitelist.len)
			src.whitelist = chem_whitelist

	proc/update_icon()
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
		if (src.safe && add)
			check_whitelist(src, src.whitelist)
		src.update_icon()

	attack_self(mob/user as mob)
		update_icon()
		src.add_dialog(user)
		var/dat = ""
		dat += "Injection amount: <A href='?src=\ref[src];change_amt=1'>[inj_amount == -1 ? "ALL" : inj_amount]</A><BR><BR>"

		if (src.reagents.total_volume)
			dat += "Contains: <BR>"
			for (var/current_id in reagents.reagent_list)
				var/datum/reagent/current_reagent = reagents.reagent_list[current_id]
				dat += " - [current_reagent.volume] [current_reagent.name]<BR>"
			dat += "<A href='?src=\ref[src];dump_cont=1'>Dump contents</A>"

		user.Browse("<TITLE>Hypospray</TITLE>Hypospray:<BR><BR>[dat]", "window=hypospray;size=350x250")
		onclose(user, "hypospray")
		return

	Topic(href, href_list)
		..()
		if (usr != src.loc)
			return

		if (href_list["dump_cont"])
			src.reagents.clear_reagents()

		if (href_list["change_amt"])
			var/amt = input(usr,"Select:","Amount", inj_amount) in list("ALL",1,2,3,4,5,8,10,15,20,25)
			if (amt == "ALL")
				inj_amount = -1
			else
				inj_amount = amt

		updateUsrDialog()
		attack_self(usr)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!safe)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been disabled.", "red")
		safe = 0
		var/image/magged = image(src.icon, "hypomag", layer = FLOAT_LAYER)
		src.UpdateOverlays(magged, "emagged")
		return 1

	demag(var/mob/user)
		if (safe)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been reactivated.", "blue")
		safe = 1
		src.overlays = null
		src.update_icon()
		return 1

	attack(mob/M as mob, mob/user as mob, def_zone)
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
		logTheThing("combat", user, M, "uses a hypospray [log_reagents(src)] to inject [constructTarget(M,"combat")] at [log_loc(user)].")

		src.reagents.trans_to(M, amt_prop)

		if (src.safe && M.health < 90)
			JOB_XP(user, "Medical Doctor", 1)

		playsound(get_turf(M), src.sound_inject, 80, 0)

		update_icon()
