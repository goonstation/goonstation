/obj/submachine/chef_sink/chem_sink
	name = "sink"
	density = 0
	layer = 5
	icon = 'icons/obj/chemical.dmi'
	icon_state = "sink"
	flags = NOSPLASH

// Removed quite a bit of of duplicate code here (Convair880).

///////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/chem_heater
	name = "Reagent Heater/Cooler"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "heater"
	flags = NOSPLASH
	mats = 15
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	power_usage = 50
	var/obj/beaker = null
	var/active = 0
	var/target_temp = T0C
	var/output_target = null
	var/mob/roboworking = null
	var/static/image/icon_beaker = image('icons/obj/chemical.dmi', "heater-beaker")
	// The chemistry APC was largely meaningless, so I made dispensers/heaters require a power supply (Convair880).

	New()
		..()
		output_target = src.loc

	attackby(var/obj/item/reagent_containers/glass/B as obj, var/mob/user as mob)

		if(!istype(B, /obj/item/reagent_containers/glass))
			return

		if (status & (NOPOWER|BROKEN))
			user.show_text("[src] seems to be out of order.", "red")
			return

		if (isrobot(user) && beaker && beaker == B)
			// If a cyborg is using this, and is trying to stick the same beaker into the heater again,
			// treat it like they just want to open the UI for QOL
			attack_ai(user)
			return

		if(src.beaker)
			boutput(user, "A beaker is already loaded into the machine.")
			return

		src.beaker =  B
		if (!isrobot(user))
			user.drop_item()
			B.set_loc(src)
		else
			roboworking = user
			SPAWN_DBG(1 SECOND)
				robot_disposal_check()

		boutput(user, "You add the beaker to the machine!")
		src.updateUsrDialog()
		src.update_icon()

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.update_icon()
			src.updateUsrDialog()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	Topic(href, href_list)
		if(status & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return

		src.add_dialog(usr)
		if (!beaker)
			// This should only happen when the UI is out of date - refresh it
			src.updateUsrDialog()
			return

		if (href_list["eject"])
			if (roboworking)
				if (usr != roboworking)
					// If a cyborg is using this, other people can't eject the beaker.
					usr.show_text("You cannot eject the beaker because it is part of [roboworking].", "red")
					return
				roboworking = null
			else
				beaker.set_loc(output_target)
				usr.put_in_hand_or_eject(beaker) // try to eject it into the users hand, if we can

			beaker = null
			src.update_icon()
			src.updateUsrDialog()
			return
		else if (href_list["adjustM"])
			if (!beaker.reagents.total_volume) return
			var/change = text2num(href_list["adjustM"])
			target_temp = min(max(0, target_temp-change),1000)
			src.update_icon()
			src.updateUsrDialog()
			return
		else if (href_list["adjustP"])
			if (!beaker.reagents.total_volume) return
			var/change = text2num(href_list["adjustP"])
			target_temp = min(max(0, target_temp+change),1000)
			src.update_icon()
			src.updateUsrDialog()
			return
		else if (href_list["settemp"])
			if (!beaker.reagents.total_volume) return
			var/change = input(usr,"Target Temperature (0-1000):","Enter target temperature",target_temp) as null|num
			if(!change || !isnum(change)) return
			target_temp = min(max(0, change),1000)
			src.update_icon()
			src.updateUsrDialog()
			return
		else if (href_list["stop"])
			set_inactive()
			return
		else if (href_list["start"])
			if (!beaker.reagents.total_volume) return
			active = 1
			active()
			src.update_icon()
			src.updateUsrDialog()
			return
		else
			usr.Browse(null, "window=chem_heater;title=Chemistry Heater")
			src.update_icon()
			src.updateUsrDialog()
			return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(status & (NOPOWER|BROKEN))
			return
		src.add_dialog(user)
		var/list/dat = list()

		if(!beaker)
			dat += "Please insert beaker.<BR>"
		else if (!beaker.reagents.total_volume)
			dat += "Beaker is empty.<BR>"
			dat += "<A href='?src=\ref[src];eject=1'>Eject beaker</A><BR><BR>"
		else
			var/datum/reagents/R = beaker:reagents
			dat += "<A href='?src=\ref[src];eject=1'>Eject beaker</A><BR><BR>"
			dat += "<A href='?src=\ref[src];adjustM=10'>(<<)</A><A href='?src=\ref[src];adjustM=1'>(<)</A><A href='?src=\ref[src];settemp=1'> [target_temp] </A><A href='?src=\ref[src];adjustP=1'>(>)</A><A href='?src=\ref[src];adjustP=10'>(>>)</A><BR><BR>"

			if(active)
				dat += "Status: Active ([(target_temp > R.total_temperature) ? "Heating" : "Cooling"])<BR>"
				dat += "Current Temperature: [R.total_temperature]<BR>"
				dat += "<A href='?src=\ref[src];stop=1'>Deactivate</A><BR><BR>"
			else
				dat += "Status: Inactive<BR>"
				dat += "Current Temperature: [R.total_temperature]<BR>"
				dat += "<A href='?src=\ref[src];start=1'>Activate</A><BR><BR>"

			for(var/reagent_id in R.reagent_list)
				var/datum/reagent/current_reagent = R.reagent_list[reagent_id]
				dat += "[current_reagent.name], [current_reagent.volume] Units.<BR>"

		user.Browse("<TITLE>Reagent Heating/Cooling Unit</TITLE>Reagent Heating/Cooling Unit:<BR><BR>[dat.Join()]", "window=chem_heater;title=Chemistry Heater")

		onclose(user, "chem_heater")
		return

	//MBC : moved to robot_disposal_check
	/*
	ProximityLeave(atom/movable/AM as mob|obj)
		if (roboworking && AM == roboworking && get_dist(src, AM) > 1)
			// Cyborg is leaving (or getting pushed away); remove its beaker
			roboworking = null
			beaker = null
			set_inactive()
			// If the heater was working, the next iteration of active() will turn it off and fix power usage
		return ..(AM)
	*/

	proc/active()
		if (!active) return
		if (status & (NOPOWER|BROKEN) || !beaker || !beaker.reagents.total_volume)
			set_inactive()
			return

		var/datum/reagents/R = beaker:reagents
		R.temperature_reagents(target_temp, 10)

		src.power_usage = 1000

		if(abs(R.total_temperature - target_temp) <= 3) active = 0

		src.updateUsrDialog()

		SPAWN_DBG(1 SECOND) active()

	proc/robot_disposal_check()
		// Without this, the heater might occasionally show that a beaker is still inserted
		// when it in fact isn't. That should only happen when
		//  - a cyborg was using the machine, and
		//  - the cyborg lost its chest with the beaker still inserted, and
		//  - the heater was inactive at the time of death.
		// Since we don't get any callbacks in this case - the borg leaves the tile by
		// way of qdel, so there's no ProximityLeave notification - the only way to update
		// the icon promptly is to run a periodic check when a borg has its beaker inserted
		// into the heater, regardless of whether the heater is active or not.
		// MBC note : also moved distance check here
		if (!roboworking)
			// This proc is only called when a robot was at one point using the heater, so if
			// roboworking is unset then it must have been deleted
			set_inactive()
		else if (get_dist(src, roboworking) > 1)
			roboworking = null
			beaker = null
			set_inactive()
		else
			SPAWN_DBG(1 SECOND)
				robot_disposal_check()

	proc/set_inactive()
		power_usage = 50
		active = 0
		update_icon()
		updateUsrDialog()

	proc/update_icon()
		src.overlays -= src.icon_beaker
		if (src.beaker)
			src.overlays += src.icon_beaker
			if (src.active && src.beaker:reagents && src.beaker:reagents:total_volume)
				if (target_temp > src.beaker:reagents:total_temperature)
					src.icon_state = "heater-heat"
				else if (target_temp < src.beaker:reagents:total_temperature)
					src.icon_state = "heater-cool"
				else
					src.icon_state = "heater"
			else
				src.icon_state = "heater"
		else
			src.icon_state = "heater"

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the Reagent Heater/Cooler's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The Reagent Heater/Cooler is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the Reagent Heater/Cooler to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "CheMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	flags = NOSPLASH
	mats = 15
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/obj/item/beaker = null
	var/list/whitelist = list()
	var/emagged = 0
	var/patch_box = 1
	var/pill_bottle = 1
	var/output_target = null

	New()
		..()
		if (!src.emagged && islist(chem_whitelist) && chem_whitelist.len)
			src.whitelist = chem_whitelist
		output_target = src.loc

	ex_act(severity)
		switch (severity)
			if (1.0)
				qdel(src)
				return
			if (2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	handle_event(var/event, var/sender)
		if (event == "reagent_holder_update")
			src.updateUsrDialog()

	attackby(var/obj/item/reagent_containers/glass/B as obj, var/mob/user as mob)
		if (!istype(B, /obj/item/reagent_containers/glass))
			return

		if (src.beaker)
			boutput(user, "A beaker is already loaded into the machine.")
			return
		if (isrobot(user))
			boutput(user, "This machine is not compatible with mechanical users.")
			return
		src.beaker =  B
		user.drop_item()
		B.set_loc(src)
		boutput(user, "You add the beaker to the machine!")
		src.updateUsrDialog()
		icon_state = "mixer1"
		src.attack_hand(user)

	Topic(href, href_list)
		if (status & BROKEN) return
		if (usr.stat || usr.restrained()) return
		if (!in_range(src, usr)) return

		src.add_fingerprint(usr)

		src.add_dialog(usr)

		if (href_list["close"])
			usr.Browse(null, "window=chem_master;title=Chemmaster 3000")
			return

		if (!beaker) return
		var/datum/reagents/R = beaker.reagents

		if (href_list["analyze"])
			var/dat = "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr.Browse(dat, "window=chem_master;size=575x400;title=Chemmaster 3000")
			return
		else if (href_list["isolate"])
			beaker.reagents.isolate_reagent(href_list["isolate"])
			src.updateUsrDialog()
			return
		else if (href_list["remove"])
			beaker.reagents.del_reagent(href_list["remove"])
			src.updateUsrDialog()
			return
		else if (href_list["remove5"])
			beaker.reagents.remove_reagent(href_list["remove5"], 5)
			src.updateUsrDialog()
			return
		else if (href_list["remove1"])
			beaker.reagents.remove_reagent(href_list["remove1"], 1)
			src.updateUsrDialog()
			return
		else if (href_list["main"])
			attack_hand(usr)
			return
		else if (href_list["eject"])
			if (src.beaker)
				beaker.set_loc(src.output_target)
			usr.put_in_hand_or_eject(beaker) // try to eject it into the users hand, if we can
			beaker = null
			icon_state = "mixer0"
			src.updateUsrDialog()
			return

		else if (href_list["createpill"])
			var/input_name = input(usr, "Name the pill:", "Name", R.get_master_reagent_name()) as null|text
			var/pillname = copytext(html_encode(input_name), 1, 32)
			if (isnull(pillname) || !src.beaker || !R || !length(pillname) || pillname == " " || get_dist(usr, src) > 1)
				return
			var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(src.output_target)
			P.name = "[pillname] pill"
			R.trans_to(P, 100)//R.total_volume) we can't move all of the reagents if it's >100u so let's only move 100u
			color_icon(P)
			src.updateUsrDialog()
			logTheThing("combat",usr,null,"created a [pillname] pill containing [log_reagents(P)].")
			return

		else if (href_list["togglepillbottle"])
			src.pill_bottle = !src.pill_bottle
			src.updateUsrDialog()
			return

		else if (href_list["multipill"])
			// get the pill name from the user
			var/input_pillname = input(usr, "Name the pill:", "Name", R.get_master_reagent_name()) as null|text
			var/pillname = copytext(html_encode(input_pillname), 1, 32)
			if (isnull(pillname) || !src.beaker || !R || !length(pillname) || pillname == " " || get_dist(usr, src) > 1)
				return
			// get the pill volume from the user
			var/pillvol = input(usr, "Volume of chemical per pill: (Min/Max 5/100):", "Volume", 5) as null|num
			if (!pillvol || !src.beaker || !R)
				return
			pillvol = clamp(pillvol, 5, 100)
			// maths
			var/pillcount = round(R.total_volume / pillvol) // round with a single parameter is actually floor because byond
			logTheThing("combat",usr,null,"created [pillcount] [pillname] pills from [log_reagents(R)].")
			var/use_bottle = src.pill_bottle
			if (pillcount > 20) // if you're trying to make a huge pile of pills you get a bottle regardless of what the machine is set to
				use_bottle = 1
			if (!pillcount)
				// invalid input
				boutput(usr, "[src] makes a weird grinding noise. That can't be good.")
				return
			else if (use_bottle)
				// create a pill bottle
				var/obj/item/chem_pill_bottle/B = new /obj/item/chem_pill_bottle(src.loc)
				B.create_from_reagents(R, pillname, pillvol, pillcount)
			else
				for (var/i=pillcount, i>0, i--)
					var/obj/item/reagent_containers/pill/P = new(src.output_target)
					P.name = pillname
					R.trans_to(P, pillvol)
					color_icon(P)
			src.updateUsrDialog()
			return

		else if (href_list["createbottle"])
			var/input_name = input(usr, "Name the bottle:", "Name", R.get_master_reagent_name()) as null|text
			var/bottlename = copytext(html_encode(input_name), 1, 32)
			if (isnull(bottlename) || !src.beaker || !R || !length(bottlename) || bottlename == " " || get_dist(usr, src) > 1)
				return
			var/obj/item/reagent_containers/glass/bottle/B
			if (R.total_volume <= 30)
				B = new/obj/item/reagent_containers/glass/bottle(src.output_target)
				R.trans_to(B,30)
			else
				B = new/obj/item/reagent_containers/glass/bottle/chemical(src.output_target)
				R.trans_to(B,50)
			B.name = "[bottlename] bottle"
			src.updateUsrDialog()
			logTheThing("combat",usr,null,"created a [bottlename] bottle containing [log_reagents(B)].")
			return

		else if (href_list["createpatch"])
			var/input_name = input(usr, "Name the patch:", "Name", R.get_master_reagent_name()) as null|text
			var/patchname = copytext(html_encode(input_name), 1, 32)
			if (isnull(patchname) || !src.beaker || !R || !length(patchname) || patchname == " " || get_dist(usr, src) > 1)
				return
			var/med = src.check_whitelist(R)
			var/obj/item/reagent_containers/patch/P
			if (R.total_volume <= 20)
				P = new /obj/item/reagent_containers/patch/mini(src.output_target)
				P.name = "[patchname] mini-patch"
				R.trans_to(P, P.initial_volume)
			else
				P = new /obj/item/reagent_containers/patch(src.output_target)
				P.name = "[patchname] patch"
				R.trans_to(P, P.initial_volume)
			P.medical = med
			P.on_reagent_change()
			src.updateUsrDialog()
			logTheThing("combat",usr,null,"created a [patchname] patch containing [log_reagents(P)].")
			return

		else if (href_list["togglepatchbox"])
			src.patch_box = !src.patch_box
			src.updateUsrDialog()
			return

		else if (href_list["createampoule"])
			var/input_name = input(usr, "Name the ampoule:", "Name", R.get_master_reagent_name()) as null|text
			var/ampoulename = copytext(html_encode(input_name), 1, 32)
			if(!ampoulename)
				return
			if(ampoulename == " ")
				ampoulename = R.get_master_reagent_name()
			var/obj/item/reagent_containers/ampoule/A
			A = new /obj/item/reagent_containers/ampoule(src.output_target)
			A.name = "ampoule ([ampoulename])"
			R.trans_to(A, 5)
			logTheThing("combat",usr,null,"created a [ampoulename] ampoule containing [log_reagents(A)].")
			updateUsrDialog()
			return

		else if (href_list["multipatch"])
			// get the pill name from the user
			var/input_name = input(usr, "Name the patch:", "Name", R.get_master_reagent_name()) as null|text
			var/patchname = copytext(html_encode(input_name), 1, 32)
			if (isnull(patchname) || !src.beaker || !R || !length(patchname) || patchname == " " || get_dist(usr, src) > 1)
				return
			// get the pill volume from the user
			var/patchvol = input(usr, "Volume of chemical per patch: (Min/Max 5/30)", "Volume", 5) as null|num
			if (!patchvol || !src.beaker || !R)
				return
			patchvol = clamp(patchvol, 5, 30)
			// maths
			var/patchcount = round(R.total_volume / patchvol) // round with a single parameter is actually floor because byond
			logTheThing("combat",usr,null,"created [patchcount] [patchname] patches from [log_reagents(R)].")
			var/use_box = src.patch_box
			if (patchcount > 20) // if you're trying to make a huge pile of patches you get a box regardless of what the machine is set to
				use_box = 1
			if (!patchcount)
				// invalid input
				boutput(usr, "[src] makes a weird grinding noise. That can't be good.")
				return
			var/patchloc = null
			var/med = src.check_whitelist(R)
			if (use_box)
				// create a patchbox
				var/obj/item/item_box/medical_patches/B = new /obj/item/item_box/medical_patches(src.output_target)
				B.name = "box of [patchname] [patchvol <= 15 ? "mini-" : null]patches"
				patchloc = B
				if (!med) // dangerrr
					B.icon_state = "patchbox" // change icon
					B.icon_closed = "patchbox"
					B.icon_open = "patchbox-open"
					B.icon_empty = "patchbox-empty"
			else
				patchloc = src.output_target

			if (patchloc)
				for (var/i=patchcount, i>0, i--)
					var/obj/item/reagent_containers/patch/P
					if (patchvol <= 15)
						P = new /obj/item/reagent_containers/patch/mini(patchloc)
						P.name = "[patchname] mini-patch"
					else
						P = new /obj/item/reagent_containers/patch(patchloc)
						P.name = "[patchname] patch"
					P.medical = med
					P.on_reagent_change()
					R.trans_to(P, patchvol)
			else
				boutput(usr, "[src] makes a weird grinding noise. That can't be good.")
				return

			src.updateUsrDialog()
			return

		else
			usr.Browse(null, "window=chem_master;title=Chemmaster 3000")
			return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if (status & BROKEN)
			return
		src.add_dialog(user)
		var/dat = ""
		if (!beaker)
			dat = "Please insert beaker.<BR>"
			dat += "<A href='?src=\ref[src];close=1'>Close</A>"
		else
			var/datum/reagents/R = beaker:reagents
			dat += "<A href='?src=\ref[src];eject=1'>Eject beaker</A><BR><BR>"
			if (!R.total_volume)
				dat += "Beaker is empty."
			else
				dat += "Contained reagents:<BR>"
				for (var/reagent_id in R.reagent_list)
					var/datum/reagent/current_reagent = R.reagent_list[reagent_id]
					dat += "[capitalize(current_reagent.name)] - [current_reagent.volume] Units - <A href='?src=\ref[src];analyze=1;desc=[html_encode(current_reagent.description)];name=[capitalize(current_reagent.name)]'>(Analyze)</A> <A href='?src=\ref[src];isolate=[current_reagent.id]'>(Isolate)</A> <A href='?src=\ref[src];remove=[current_reagent.id]'>(Remove all)</A> <A href='?src=\ref[src];remove5=[current_reagent.id]'>(-5)</A> <A href='?src=\ref[src];remove1=[current_reagent.id]'>(-1)</A><BR>"
				dat += "<BR><A href='?src=\ref[src];createpill=1'>Create pill (100 units max)</A><BR>"
				dat += "<A href='?src=\ref[src];multipill=1'>Create multiple pills (5 units min)</A> Bottle: <A href='?src=\ref[src];togglepillbottle=1'>[src.pill_bottle ? "Yes" : "No"]</A><BR>"
				dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A><BR>"
				dat += "<A href='?src=\ref[src];createpatch=1'>Create patch (30 units max)</A><BR>"
				dat += "<A href='?src=\ref[src];multipatch=1'>Create multiple patches (5 units min)</A> Box: <A href='?src=\ref[src];togglepatchbox=1'>[src.patch_box ? "Yes" : "No"]</A><BR>"
				dat += "<A href='?src=\ref[src];createampoule=1'>Create ampoule (5 units max)</A>"
		user.Browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400;title=Chemmaster 3000")
		onclose(user, "chem_master")
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been disabled.", "red")
		src.emagged = 1
		return 1

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("[src]'s safeties have been reactivated.", "blue")
		src.emagged = 0
		return 1

	proc/check_whitelist(var/datum/reagents/R)
		if (src.emagged || !R || !src.whitelist || (islist(src.whitelist) && !src.whitelist.len))
			return 1
		var/all_safe = 1
		for (var/reagent_id in R.reagent_list)
			if (!src.whitelist.Find(reagent_id))
				all_safe = 0
		return all_safe

	proc/color_icon(var/obj/item/reagent_containers/pill/P)
		if (P.reagents)
			var/datum/color/average = P.reagents.get_average_color()
			P.color_overlay = image('icons/obj/items/pills.dmi', "pill0")
			P.color_overlay.color = average.to_rgb()
			P.color_overlay.alpha = P.color_overlay_alpha
			P.overlays += P.color_overlay
			return

	MouseDrop(over_object, src_location, over_location)
		if(!isliving(usr))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the CheMaster 3000's output target.</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>The CheMaster 3000 is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		else if (istype(over_object,/turf/simulated/floor/))
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set the CheMaster 3000 to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

datum/chemicompiler_core/stationaryCore
	statusChangeCallback = "statusChange"

/obj/machinery/chemicompiler_stationary/
	name = "ChemiCompiler CCS1001"
	desc = "This device looks very difficult to use."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemicompiler_st_off"
	mats = 15
	flags = NOSPLASH
	processing_tier = PROCESSING_FULL
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	var/datum/chemicompiler_executor/executor
	var/datum/light/light

	New()
		..()
		executor = new(src, /datum/chemicompiler_core/stationaryCore)
		light = new /datum/light/point
		light.set_brightness(0.4)
		light.attach(src)

	ex_act(severity)
		switch (severity)
			if (1.0)
				qdel(src)
				return
			if (2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	attack_ai(mob/user as mob)
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		if (status & BROKEN || !powered())
			boutput( user, "<span class='alert'>You can't seem to power it on!</span>" )
			return
		src.add_dialog(user)
		executor.panel()
		onclose(usr, "chemicompiler")
		return

	attackby(var/obj/item/reagent_containers/glass/B as obj, var/mob/user as mob)
		if (!istype(B, /obj/item/reagent_containers/glass))
			return
		if (isrobot(user)) return attack_ai(user)
		return attack_hand(user)

	power_change()

		if(status & BROKEN)
			icon_state = initial(icon_state)
			light.disable()

		else if(powered())
			if (executor.core.running)
				icon_state = "chemicompiler_st_working"
				light.set_brightness(0.6)
				light.enable()
			else
				icon_state = "chemicompiler_st_on"
				light.set_brightness(0.4)
				light.enable()
		else
			SPAWN_DBG(rand(0, 15))
				icon_state = initial(icon_state)
				status |= NOPOWER
				light.disable()

	process()
		. = ..()
		if ( src.executor )
			src.executor.on_process()

	proc
		topicPermissionCheck(action)
			if (!(src in range(1)))
				return 0
			if (executor.core.running)
				if(!(action in list("getUIState", "reportError")))
					return 0
			return 1

		statusChange(oldStatus, newStatus)
			power_change()
