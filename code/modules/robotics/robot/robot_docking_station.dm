/obj/machinery/recharge_station
	name = "cyborg docking station"
	icon = 'icons/obj/robot_parts.dmi'
	desc = "A station which allows cyborgs to repair damage, recharge their cells, and have upgrades installed if they are present in the station."
	icon_state = "station"
	density = 1
	anchored = 1.0
	mats = 10
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	allow_stunned_dragndrop = 1
	var/chargerate = 400
	var/cabling = 250
	var/list/cells = list()
	var/list/upgrades = list()
	var/list/modules = list()
	var/list/clothes = list()
	var/allow_clothes = 1
	var/allow_self_service = 1
	var/conversion_chamber = 0
	var/mob/occupant = null
	power_usage = 50


/obj/machinery/recharge_station/New()
	..()
	src.create_reagents(500)
	reagents.add_reagent("fuel", 250)
	src.build_icon()

/obj/machinery/recharge_station/disposing()
	if(occupant)
		occupant.set_loc(get_turf(src.loc))
		occupant = null
	..()


/obj/machinery/recharge_station/process()
	if (!(src.status & BROKEN))
		// todo / at some point id like to fix the disparity between cells and 'normal power'
		if (src.occupant)
			src.power_usage = 500
		else
			src.power_usage = 50
		..()
	if (src.status & (NOPOWER | BROKEN) || !src.anchored)
		if (src.occupant)
			boutput(src.occupant, "<span class='alert'>You are automatically ejected from [src]!</span>")
			src.go_out()
			src.build_icon()
		return

	if (src.occupant)
		src.process_occupant()
	return 1

/obj/machinery/recharge_station/allow_drop()
	return 0

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if (src.conversion_chamber && !isrobot(user))
		boutput(user, "<span class='alert'>You're trapped inside!</span>")
		return
	src.go_out()

/obj/machinery/recharge_station/ex_act(severity)
	src.go_out()
	return ..(severity)

/obj/machinery/recharge_station/attack_hand(mob/user)
	if (src.status & BROKEN)
		boutput(usr, "<span class='alert'>[src] is broken and cannot be used.</span>")
		return
	if (src.status & NOPOWER)
		boutput(usr, "<span class='alert'>[src] is out of power and cannot be used.</span>")
		return
	if (!src.anchored)
		user.show_text("You must attach [src]'s floor bolts before the machine will work.", "red")
		return

	src.add_dialog(user)
	var/list/dat = list()
	dat += "<B>[src.name]</B> <A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR><HR>"

	if (!src.occupant)
		dat += "No occupant detected in [src.name].<BR><HR>"
	else
		if (isrobot(src.occupant))
			var/mob/living/silicon/robot/R = src.occupant
			dat += "<u><b>Occupant Name:</b></u> [R.name] "
			if (user != src.occupant)
				dat += "<A href='?src=\ref[src];rename=1'>(Rename)</A>"
			dat += "<BR>"

			var/mob/living/silicon/robot/RC = src.occupant
			var/dmgalerts = 0
			dat += "<u><b>Damage Report:</b></u><BR>"
			dat += "<A href='?src=\ref[src];repair=1'>Repair Structural Damage</A> | <A href='?src=\ref[src];repair=2'>Repair Burn Damage</A><BR>"
			if (RC.part_chest)
				if (RC.part_chest.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					dat += "<b>Chest Unit Damaged</b> ([RC.part_chest.ropart_get_damage_percentage(1)]%, [RC.part_chest.ropart_get_damage_percentage(2)]%)<BR>"

			if (RC.part_head)
				if (RC.part_head.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					dat += "<b>Head Unit Damaged</b> ([RC.part_head.ropart_get_damage_percentage(1)]%, [RC.part_head.ropart_get_damage_percentage(2)]%)<BR>"

			if (RC.part_arm_r)
				if (RC.part_arm_r.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					if (RC.part_arm_r.slot == "arm_both")
						dat += "<b>Arms Unit Damaged</b> ([RC.part_arm_r.ropart_get_damage_percentage(1)]%, [RC.part_arm_r.ropart_get_damage_percentage(2)]%)<BR>"
					else
						dat += "<b>Right Arm Unit Damaged</b> ([RC.part_arm_r.ropart_get_damage_percentage(1)]%, [RC.part_arm_r.ropart_get_damage_percentage(2)]%)<BR>"
			else
				dmgalerts++
				dat += "Right Arm Unit Missing<br>"

			if (RC.part_arm_l)
				if (RC.part_arm_l.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					if (RC.part_arm_l.slot != "arm_both")
						dat += "<b>Left Arm Unit Damaged</b> ([RC.part_arm_l.ropart_get_damage_percentage(1)]%, [RC.part_arm_l.ropart_get_damage_percentage(2)]%)<BR>"
			else
				dmgalerts++
				dat += "Left Arm Unit Missing<br>"

			if (RC.part_leg_r)
				if (RC.part_leg_r.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					if (RC.part_leg_r.slot == "leg_both")
						dat += "<b>Legs Unit Damaged</b> ([RC.part_leg_r.ropart_get_damage_percentage(1)]%, [RC.part_leg_r.ropart_get_damage_percentage(2)]%)<BR>"
					else
						dat += "<b>Right Leg Unit Damaged</b> ([RC.part_leg_r.ropart_get_damage_percentage(1)]%, [RC.part_leg_r.ropart_get_damage_percentage(2)]%)<BR>"
			else
				dmgalerts++
				dat += "Right Leg Unit Missing<br>"

			if (RC.part_leg_l)
				if (RC.part_leg_l.ropart_get_damage_percentage(0) > 0)
					dmgalerts++
					if (RC.part_leg_l.slot != "arm_both")
						dat += "<b>Left Leg Unit Damaged</b> ([RC.part_leg_l.ropart_get_damage_percentage(1)]%, [RC.part_leg_l.ropart_get_damage_percentage(2)]%)<BR>"
			else
				dmgalerts++
				dat += "Left Leg Unit Missing<br>"

			if (!dmgalerts && src.occupant.health < src.occupant.max_health)
				health_update_queue |= src.occupant

			if (dmgalerts == 0)
				dat += "No abnormalities detected.<br>"

			dat += "<b>Power Cell:</b> "
			if (R.cell)
				var/obj/item/cell/C = R.cell
				dat += "[C] - [C.charge]/[C.maxcharge]"
				if (!isrobot(user))
					dat += "<A HREF=?src=\ref[src];removecell=\ref[C]>(Remove)</A>"
			else
				dat += "None"
			dat += "<BR><BR>"

			dat += "<b>Module:</b> "
			if (R.module)
				var/obj/item/robot_module/M = R.module
				dat += "[M.name] <A HREF=?src=\ref[src];remove=\ref[M]>(Remove)</A>"
			else dat += "None"
			dat += "<BR><BR>"

			dat += "<b>Upgrades:</b> ([R.upgrades.len]/[R.max_upgrades]) "
			if (R.upgrades.len)
				for (var/obj/item/roboupgrade/U in R.upgrades)
					dat += "<br>[U.name] <A HREF=?src=\ref[src];remove=\ref[U]>(Remove)</A>"
			else
				dat += "None"

			if (src.allow_clothes)
				dat += "<BR><BR>"
				dat += "<b>Clothes:</b> "
				if (R.clothes.len)
					for (var/A in R.clothes)
						var/obj/O = R.clothes[A]
						dat += "<br>[O.name] <A HREF=?src=\ref[src];remove=\ref[O]>(Remove)</A>"
				else
					dat += "None"

			var/mob/living/silicon/robot/C = occupant
			dat += "<BR><B><U>Occupant is a Mk.2-Type Cyborg.</U></B><BR>"

			if (istype(C.cosmetic_mods, /datum/robot_cosmetic/))
				var/datum/robot_cosmetic/COS = C.cosmetic_mods
				dat += "<B>Chest Decoration:</B> <A href='?src=\ref[src];decor=chest'>[COS.ches_mod ? COS.ches_mod : "None"]</A><BR>"
				if (COS.painted)
					dat += "Paint Options: <A href='?src=\ref[src];paint=change'>Repaint</A> | <A href='?src=\ref[src];paint=remove'>Remove Paint</A><BR>"
				else
					dat += "Paint Options: <A href='?src=\ref[src];paint=add'>Add Paint</A><BR>"
				dat += "<B>Head Decoration:</B> <A href='?src=\ref[src];decor=head'>[COS.head_mod ? COS.head_mod : "None"]</A><BR>"
				dat += "<B>Arms Decoration:</B> <A href='?src=\ref[src];decor=arms'>[COS.arms_mod ? COS.arms_mod : "None"]</A><BR>"
				dat += "<B>Legs Decoration:</B> <A href='?src=\ref[src];decor=legs'>[COS.legs_mod ? COS.legs_mod : "None"]</A><BR>"
				dat += "<A href='?src=\ref[src];decor=fx'>Change Eye Color</A><BR>"

			dat += "<BR><HR>"

		else
			if (src.conversion_chamber && ishuman(src.occupant))
				var/mob/living/carbon/human/H = src.occupant
				dat += "Conversion process is [100 - round(100 * H.health / H.max_health)]% complete.<BR><HR>"
			else
				dat += "Cannot interface with occupant of unknown type.<BR><HR>"

	var/fuelamt = src.reagents.get_reagent_amount("fuel")
	dat += "<b>Cyborg Self-Service Allowed:</b> <A href='?src=\ref[src];selfservice=1'>[src.allow_self_service ? "Yes" : "No"]</A><BR>"
	dat += "<b>Welding Fuel Available:</b> [fuelamt]<BR>"
	dat += "<b>Cable Coil Available:</b> [src.cabling]<BR>"

	dat += "<b>Power Cells Available:</b> "
	if (src.cells.len)
		for (var/obj/item/cell/C in src.cells)
			dat += "<br>[C.name] - [C.charge]/[C.maxcharge]"
			if (isrobot(occupant) && !isrobot(user))
				dat += "<A HREF=?src=\ref[src];install=\ref[C]> (Install)</A>"
			dat += " <A HREF=?src=\ref[src];eject=\ref[C]>(Eject)</A>"
	else
		dat += "None"
	dat += "<BR><BR>"

	dat += "<b>Modules Available:</b> "
	if (src.modules.len)
		for (var/obj/item/robot_module/M in src.modules)
			dat += "<br>[M.name]"
			if (isrobot(src.occupant))
				dat += "<A HREF=?src=\ref[src];install=\ref[M]> (Install)</A>"
			dat += " <A HREF=?src=\ref[src];eject=\ref[M]>(Eject)</A>"
	else
		dat += "None"
	dat += "<BR><BR>"

	dat += "<b>Upgrades Available:</b> "
	if (src.upgrades.len)
		for (var/obj/item/roboupgrade/U in src.upgrades)
			dat += "<br>[U.name]"
			if (isrobot(src.occupant))
				dat += "<A HREF=?src=\ref[src];install=\ref[U]> (Install)</A>"
			dat += " <A HREF=?src=\ref[src];eject=\ref[U]>(Eject)</A>"
	else
		dat += "None"

	if (allow_clothes)
		dat += "<BR><BR>"
	else
		dat += "<BR><HR>"

	if (allow_clothes)
		dat += "<b>Clothes Available:</b> "
		if (src.clothes.len)
			for (var/obj/item/clothing/C in src.clothes)
				dat += "<br>[C.name]"
				if (isrobot(occupant))
					dat += "<A HREF=?src=\ref[src];install=\ref[C]> (Install)</A>"
				dat += " <A HREF=?src=\ref[src];eject=\ref[C]>(Eject)</A>"
		else
			dat += "None"
		dat += "<BR><HR>"

	user.Browse(dat.Join(), "window=cyberdock;size=400x500")
	onclose(user, "cyberdock")

/obj/machinery/recharge_station/Topic(href, href_list)
	if (src.status & (BROKEN | NOPOWER))
		return

	if (usr.stat || usr.restrained() || isghostcritter(usr))
		return

	if (!src.anchored)
		usr.show_text("You must attach [src]'s floor bolts before the machine will work.", "red")
		return

	if ((usr.contents.Find(src) || src.contents.Find(usr) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
		src.add_dialog(usr)

		if (href_list["refresh"])
			src.updateUsrDialog()
			return

		if (isrobot(usr))
			if (usr != src.occupant)
				boutput(usr, "<span class='alert'>You must be inside the docking station to use the functions.</span>")
				src.updateUsrDialog()
				return
			else
				if (!src.allow_self_service)
					boutput(usr, "<span class='alert'>Self-service is disabled at this docking station.</span>")
					src.updateUsrDialog()
					return
		else
			if (usr == src.occupant)
				boutput(usr, "<span class='alert'>Non-cyborgs cannot use the docking station functions.</span>")
				src.updateUsrDialog()
				return

		if (src.occupant && !isrobot(src.occupant))
			boutput(usr, "<span class='alert'>The docking station functions are not compatible with non-cyborg occupants.</span>")
			src.updateUsrDialog()
			return

		if (href_list["rename"])
			if (usr == src.occupant)
				boutput(usr, "<span class='alert'>You may not rename yourself!</span>")
				src.updateUsrDialog()
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/newname = copytext(strip_html(sanitize(input(usr, "What do you want to rename [R]?", "Cyborg Maintenance", R.name) as null|text)), 1, 64)
			if ((!issilicon(usr) && (get_dist(usr, src) > 1)) || usr.stat || !newname)
				return
			if (url_regex?.Find(newname))
				boutput(usr, "<span class='notice'><b>Web/BYOND links are not allowed in ingame chat.</b></span>")
				boutput(usr, "<span class='alert'>&emsp;<b>\"[newname]</b>\"</span>")
				return
			logTheThing("combat", usr, R, "uses a docking station to rename [constructTarget(R,"combat")] to [newname].")
			R.name = newname
			if (R.internal_pda)
				R.internal_pda.name = "[R]'s Internal PDA Unit"
				R.internal_pda.owner = "[R]"

		if (href_list["selfservice"])
			if (isrobot(usr))
				boutput(usr, "<span class='alert'>Cyborgs are not allowed to toggle this option.</span>")
				src.updateUsrDialog()
				return
			else
				src.allow_self_service = !src.allow_self_service

		if (href_list["repair"])
			if (!isrobot(occupant))
				src.updateUsrDialog()
				return
			var/mob/living/silicon/robot/R = src.occupant

			var/ops = text2num(href_list["repair"])

			var/mob/living/silicon/robot/C = R
			if (ops == 1 && C.compborg_get_total_damage(1) > 0)
				var/usage = input(usr, "How much welding fuel do you want to use?", "Docking Station", 0) as num
				if ((!issilicon(usr) && (get_dist(usr, src) > 1)) || usr.stat)
					return
				if (usage > C.compborg_get_total_damage(1))
					usage = C.compborg_get_total_damage(1)
				if (usage < 1)
					return
				for (var/obj/item/parts/robot_parts/RP in C.contents)
					RP.ropart_mend_damage(usage,0)
				src.reagents.remove_reagent("fuel", usage)
			else if (ops == 2 && C.compborg_get_total_damage(2) > 0)
				var/usage = input(usr, "How much wiring do you want to use?", "Docking Station", 0) as num
				if ((!issilicon(usr) && (get_dist(usr, src) > 1)) || usr.stat)
					return
				if (usage > C.compborg_get_total_damage(2))
					usage = C.compborg_get_total_damage(2)
				if (usage < 1)
					return
				for (var/obj/item/parts/robot_parts/RP in C.contents)
					RP.ropart_mend_damage(0, usage)
				src.cabling -= usage
				if (src.cabling < 0)
					src.cabling = 0
			else
				boutput(usr, "<span class='alert'>[C] has no damage to repair.</span>")
			R.update_appearance()

		if (href_list["install"])
			if (!isrobot(src.occupant))
				src.updateUsrDialog()
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/obj/item/O = locate(href_list["install"]) in src

			//My apologies for this ugly code.
			if (src.allow_clothes && istype(O, /obj/item/clothing))
				if (istype(O, /obj/item/clothing/under))
					if (R.clothes["under"] != null)
						var/obj/old = R.clothes["under"]
						src.clothes.Add(old)
						old.set_loc(src)
					R.clothes["under"] = O
					src.clothes.Remove(O)
					O.set_loc(R)
				else if (istype(O, /obj/item/clothing/suit))
					if (R.clothes["suit"] != null)
						var/obj/old = R.clothes["suit"]
						src.clothes.Add(old)
						old.set_loc(src)
					R.clothes["suit"] = O
					src.clothes.Remove(O)
					O.set_loc(R)
				else if (istype(O, /obj/item/clothing/mask))
					if (R.clothes["mask"] != null)
						var/obj/old = R.clothes["mask"]
						src.clothes.Add(old)
						old.set_loc(src)
					R.clothes["mask"] = O
					src.clothes.Remove(O)
					O.set_loc(R)
				else if (istype(O, /obj/item/clothing/head))
					if (R.clothes["head"] != null)
						var/obj/old = R.clothes["head"]
						src.clothes.Add(old)
						old.set_loc(src)
					R.clothes["head"] = O
					src.clothes.Remove(O)
					O.set_loc(R)
			if (istype(O, /obj/item/cell/))
				if (R.cell)
					var/obj/item/C = R.cell
					src.cells.Add(R.cell)
					C.set_loc(src)
					R.cell = null
					boutput(R, "<span class='notice'>Your power cell is being swapped...</span>")

				src.cells.Remove(O)
				O.set_loc(R)
				R.cell = O
				boutput(R, "<span class='notice'>Power cell installed: [O].</span>")
				R.hud.update_charge()

			if (istype(O, /obj/item/roboupgrade))
				if (R.upgrades.len >= R.max_upgrades)
					boutput(usr, "<span class='alert'>[R] has no room for further upgrades.</span>")
					src.updateUsrDialog()
					return
				if (locate(O.type) in R.upgrades)
					boutput(usr, "<span class='alert'>[R] already has that upgrade.</span>")
					src.updateUsrDialog()
					return
				src.upgrades.Remove(O)
				R.upgrades.Add(O)
				O.set_loc(R)
				boutput(R, "<span class='notice'>You recieved [O]! It can be activated from your panel.</span>")
				R.hud.update_upgrades()
			if (istype(O, /obj/item/robot_module))
				if (R.module)
					boutput(usr, "<span class='alert'>[R] already has a module installed!</span>")
				else
					var/obj/item/robot_module/RM = O
					R.set_module(RM)
					src.modules.Remove(RM)
			R.update_appearance()

		if (href_list["remove"])
			if (!isrobot(src.occupant))
				src.updateUsrDialog()
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/obj/item/O = locate(href_list["remove"]) in src.occupant

			if (istype(O, /obj/item/clothing))
				src.clothes.Add(O)
				O.set_loc(src)

				for (var/x in R.clothes)
					if (R.clothes[x] == O)
						R.clothes.Remove(x)
						break

				boutput(R, "<span class='alert'>\the [O.name] was removed!</span>")

			if (istype(O, /obj/item/roboupgrade))
				var/obj/item/roboupgrade/U = O
				if (!U.removable)
					boutput(usr, "<span class='alert'>This upgrade cannot be removed.</span>")
				else
					boutput(R, "<span class='alert'>[U] was removed!</span>")
					U.upgrade_deactivate(R)
					src.upgrades.Add(U)
					R.upgrades.Remove(U)
					U.set_loc(src)
					R.hud.update_upgrades()

			if (istype(O,/obj/item/robot_module))
				R.remove_module()
				src.modules.Add(O)
				O.set_loc(src)

			R.update_appearance()

		if (href_list["removecell"]) //ZeWaka: Special snowflake fix for cell ejecting not working.
			if (!isrobot(src.occupant))
				src.updateUsrDialog()
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/obj/item/C = R.cell
			src.cells.Add(R.cell)
			C.set_loc(src)
			R.cell = null
			boutput(R, "<span class='alert'>Your power cell was removed!</span>")
			logTheThing("combat", usr, R, "removes [constructTarget(R,"combat")]'s power cell at [log_loc(usr)].") // Renders them mute and helpless (Convair880).
			R.hud.update_charge()

		if (href_list["eject"])
			var/obj/item/O = locate(href_list["eject"]) in src
			if (istype(O, /obj/item/cell/))
				src.cells.Remove(O)
			if (istype(O, /obj/item/roboupgrade))
				src.upgrades.Remove(O)
			if (istype(O, /obj/item/robot_module))
				src.modules.Remove(O)
			if (istype(O, /obj/item/clothing/))
				src.clothes.Remove(O)
			if (O)
				O.set_loc(src.loc)
			usr.put_in_hand_or_eject(O) // try to eject it into the users hand, if we can

		// composite borg stuff

		if (href_list["decor"])
			var/selection = href_list["decor"]
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(usr, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				src.updateUsrDialog()
				return
			switch (selection)
				if ("chest")
					var/mod = input("Please select a chest decoration!", "Cyborg Decoration", null, null) in list("Nothing","Medical Insignia","Lab Coat")
					if (!mod)
						mod = "Nothing"
					if (mod == "Nothing")
						C.ches_mod = null
					else
						C.ches_mod = mod
				if ("head")
					var/mod = input("Please select a head decoration!", "Cyborg Decoration", null, null) in list("Nothing","Medical Mirror","Janitor Cap","Hard Hat","Afro and Shades")
					if (!mod)
						mod = "Nothing"
					if (mod == "Nothing")
						C.head_mod = null
					else
						C.head_mod = mod
				if ("arms")
					var/mod = input("Please select an arms decoration!", "Cyborg Decoration", null, null) in list("Nothing")
					if (!mod)
						mod = "Nothing"
					if (mod == "Nothing")
						C.arms_mod = null
					else
						C.arms_mod = mod
				if ("legs")
					var/mod = input("Please select a legs decoration!", "Cyborg Decoration", null, null) in list("Nothing","Disco Flares")
					if (!mod)
						mod = "Nothing"
					if (mod == "Nothing")
						C.legs_mod = null
					else
						C.legs_mod = mod
				if ("fx")
					C.fx[1] = input(usr,"How much red? (0 to 255)" ,"Eye and Glow", 0) as num
					C.fx[1] = max(min(C.fx[1], 255), 0)
					C.fx[2] = input(usr,"How much green? (0 to 255)" ,"Eye and Glow", 0) as num
					C.fx[2] = max(min(C.fx[2], 255), 0)
					C.fx[3] = input(usr,"How much blue? (0 to 255)" ,"Eye and Glow", 0) as num
					C.fx[3] = max(min(C.fx[3], 255), 0)
			R.update_appearance()
			R.update_bodypart()

		if (href_list["paint"])
			var/selection = href_list["paint"]
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(usr, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				src.updateUsrDialog()
				return
			switch(selection)
				if ("add")
					C.painted = 1
					C.paint = input(usr) as color
				if("change")
					C.paint = input(usr) as color
				if("remove")
					C.painted = 0
			R.update_appearance()
			R.update_bodypart()

	src.updateUsrDialog()

/obj/machinery/recharge_station/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/clothing) && src.allow_clothes)
		if (!istype(W, /obj/item/clothing/mask) && !istype(W, /obj/item/clothing/head) && !istype(W, /obj/item/clothing/under) && !istype(W, /obj/item/clothing/suit))
			boutput(user, "<span class='alert'>This type of is not compatible.</span>")
			return
		if (user.contents.Find(W))
			user.drop_item()
		if (W in src.clothes)
			qdel(W)
			return
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.clothes.Add(W)
		return
	if (istype(W, /obj/item/robot_module))
		if (user.contents.Find(W))
			user.drop_item()
		if (W in src.modules)
			qdel(W)
			return
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.modules.Add(W)
		return
	if (istype(W, /obj/item/roboupgrade))
		if (user.contents.Find(W))
			user.drop_item()
		if (W in src.upgrades)
			qdel(W)
			return
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.upgrades.Add(W)
		return
	if (istype(W, /obj/item/cell))
		if (user.contents.Find(W))
			user.drop_item()
		//Wire: Fix for clickdrag duplicating power cells in docks
		if (W in src.cells)
			qdel(W)
			return
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.cells.Add(W)
		return
	if (istype(W,/obj/item/cable_coil))
		var/obj/item/cable_coil/C = W
		src.cabling += C.amount
		boutput(user, "You insert [W]. [src] now has [src.cabling] cable available.")
		if (user.contents.Find(W))
			user.drop_item()
		qdel(W)
		return
	if (istype(W, /obj/item/reagent_containers/glass))
		if (!W.reagents.total_volume)
			boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")
			return
		if (!src.reagents.has_reagent("fuel"))
			boutput(user, "<span class='alert'>There's no fuel in [W]. It would be pointless to pour it in.</span>")
			return
		else
			user.visible_message("<span class='notice'>[user] pours [W:amount_per_transfer_from_this] units of [W]'s contents into [src].</span>")
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 100, 1)
			W.reagents.trans_to(src, W:amount_per_transfer_from_this)
			if (!W.reagents.total_volume)
				boutput(user, "<span class='alert'><b>[W] is now empty.</b></span>")
			src.reagents.isolate_reagent("fuel")
			return
	..()

/obj/machinery/recharge_station/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if (get_dist(O,user) > 1 || get_dist(src,user) > 1)
		return
	if (!isliving(user) || isAI(user))
		return

	if (isitem(O) && !user.stat)
		src.attackby(O, user)
		return

	if (isliving(O) && src.occupant)
		boutput(user, "<span class='alert'>The cell is already occupied!</span>")
		return

	if (isrobot(O))
		var/mob/living/silicon/robot/R = O
		if (isdead(R))
			boutput(user, "<span class='alert'>[R] is dead and cannot enter the docking station.</span>")
			return
		if (user != R)
			if (isunconscious(user))
				return
			else
				user.visible_message("<b>[user]</b> moves [R] into [src].")
		R.pulling = null
		R.set_loc(src)
		src.occupant = R
		if (R.client)
			src.attack_hand(R)
		src.add_fingerprint(user)
		src.build_icon()

	if (isshell(O))
		var/mob/living/silicon/hivebot/H = O
		if (isdead(H))
			boutput(user, "<span class='alert'>[H] is dead and cannot enter the docking station.</span>")
			return
		if (user != H)
			if (isunconscious(user))
				return
			else
				user.visible_message("<b>[user]</b> moves [H] into [src].")
		H.pulling = null
		H.set_loc(src)
		src.occupant = H
		if (H.client)
			src.attack_hand(H)
		src.add_fingerprint(user)
		src.build_icon()

	else if (ishuman(O) && !user.stat)
		if (!src.conversion_chamber)
			boutput(user, "<span class='alert'>Humans cannot enter recharging stations.</span>")
		else
			var/mob/living/carbon/human/H = O
			if (isdead(H))
				boutput(user, "<span class='alert'>[H] is dead and cannot be forced inside.</span>")
				return
			var/delay = 0
			if (user != H)
				delay = 30
				logTheThing("combat", user, H, "puts [constructTarget(H,"combat")] into a conversion chamber at [showCoords(src.x, src.y, src.z)]")
				logTheThing("diary", user, H, "puts [constructTarget(H,"diary")] into a conversion chamber at [showCoords(src.x, src.y, src.z)]", "combat")
			if (delay)
				user.visible_message("<b>[user]</b> begins moving [H] into [src].")
				boutput(user, "Both you and [H] will need to remain still for this action to work.")
			var/turf/T1 = get_turf(user)
			var/turf/T2 = get_turf(H)
			SPAWN_DBG(delay)
				if (user.loc != T1 || H.loc != T2)
					return

				if (user != H)
					user.visible_message("<b>[user]</b> moves [H] into [src].")
				else
					user.visible_message("<b>[user]</b> climbs into [src].")
				H.pulling = null
				H.set_loc(src)
				src.occupant = H
				src.add_fingerprint(user)
				src.build_icon()

/obj/machinery/recharge_station/proc/build_icon()
	src.overlays = null
	if (src.status & BROKEN)
		src.icon_state = "station-broke"
		return
	if (src.status & NOPOWER)
		return
	src.overlays += image('icons/obj/robot_parts.dmi', "station-pow")
	if (src.occupant)
		src.overlays += image('icons/obj/robot_parts.dmi', "station-occu")

/obj/machinery/recharge_station/proc/process_occupant()
	if (src.occupant)
		if (src.occupant.loc != src)
			src.go_out()
			return

		if (isrobot(src.occupant))
			var/mob/living/silicon/robot/R = src.occupant
			if (!R.cell)
				return
			else if (R.cell.charge >= R.cell.maxcharge)
				R.cell.charge = R.cell.maxcharge
				return
			else
				R.cell.charge += src.chargerate
				src.use_power(50)
				return

		else if (isshell(src.occupant))
			var/mob/living/silicon/hivebot/H = src.occupant

			if (!H.cell)
				return
			else if (H.cell.charge >= H.cell.maxcharge)
				H.cell.charge = H.cell.maxcharge
				return
			else
				H.cell.charge += src.chargerate
				src.use_power(50)
				return

		else if (ishuman(occupant) && src.conversion_chamber)
			var/mob/living/carbon/human/H = occupant
			if (prob(80))
				playsound(src.loc, pick('sound/machines/mixer.ogg','sound/misc/automaton_scratch.ogg','sound/misc/automaton_ratchet.ogg','sound/effects/brrp.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/pump.ogg','sound/effects/syringeproj.ogg'), 100, 1)
				if (prob(15))
					src.visible_message("<span class='alert'>[src] [pick("whirs","grinds","rumbles","clatters","clangs")] [pick("horribly","in a grisly manner","horrifyingly","scarily")]!</span>")
				if (prob(25))
					SPAWN_DBG(0.3 SECONDS)
						playsound(src.loc, pick('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Slimy_Hit_3.ogg','sound/impact_sounds/Slimy_Hit_4.ogg','sound/impact_sounds/Flesh_Break_1.ogg','sound/impact_sounds/Flesh_Tear_1.ogg','sound/impact_sounds/Generic_Snap_1.ogg','sound/impact_sounds/Generic_Hit_1.ogg'), 100, 1)
					SPAWN_DBG(0.6 SECONDS)
						if (H.gender == "female")
							playsound(src.loc, "sound/voice/screams/female_scream.ogg", 30, 1, channel=VOLUME_CHANNEL_EMOTE)
						else
							playsound(src.loc, "sound/voice/screams/male_scream.ogg", 30, 1, channel=VOLUME_CHANNEL_EMOTE)
						src.visible_message("<span class='alert'>A muffled scream comes from within [src]!</span>")

			if (H.health <= 2)
				boutput(H, "<span class='alert'>You feel... different.</span>")
				src.go_out()

				var/bdna = null // For forensics (Convair880).
				var/btype = null
				if (H.bioHolder.Uid && H.bioHolder.bloodType)
					bdna = H.bioHolder.Uid
					btype = H.bioHolder.bloodType
				gibs(src.loc, null, null, bdna, btype)

				H.Robotize_MK2(1)
				src.build_icon()
				playsound(src.loc, "sound/machines/ding.ogg", 100, 1)
			else
				H.bioHolder.AddEffect("eaten")
				random_brute_damage(H, 3)
				H.changeStatus("weakened", 5 SECONDS)
				if (prob(15))
					boutput(H, "<span class='alert'>[pick("You feel chunks of your flesh being ripped off!","Something cold and sharp skewers you!","You feel your organs being pulped and mashed!","Machines shred you from every direction!")]</span>")
			src.updateUsrDialog()

/obj/machinery/recharge_station/proc/go_out()
	if (!src.occupant)
		return
	src.occupant.set_loc(src.loc)
	src.occupant = null
	src.build_icon()

/obj/machinery/recharge_station/verb/move_eject()
	set src in oview(1)
	set category = "Local"
	if (isdead(usr))
		return
	if (ishuman(usr))
		if (src.conversion_chamber && src.occupant == usr)
			boutput(usr, "<span class='alert'>You're trapped inside!</span>")
			return
	src.go_out()
	add_fingerprint(usr)

/obj/machinery/recharge_station/verb/move_inside()
	set src in oview(1)
	set category = "Local"
	if (src.status & (NOPOWER | BROKEN))
		return
	if (isdead(usr))
		return
	if (!isrobot(usr) && !src.conversion_chamber)
		boutput(usr, "<span class='alert'>Only cyborgs may enter the recharger!</span>")
		return
	if (src.occupant)
		boutput(usr, "<span class='alert'>The cell is already occupied!</span>")
		return
	usr.pulling = null
	usr.set_loc(src)
	src.occupant = usr
	src.attack_hand(usr)
	src.add_fingerprint(usr)
	src.build_icon()

/obj/machinery/recharge_station/syndicate
	conversion_chamber = 1
	is_syndicate = 1
	anchored = 0
	p_class = 1.5

/obj/machinery/recharge_station/syndicate/attackby(obj/item/W as obj, mob/user as mob)
	if (iswrenchingtool(W))
		src.anchored = !src.anchored
		user.show_text("You [anchored ? "attach" : "release"] \the [src]'s floor clamps", "red")
		playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 0, 0)
		return
	..()
