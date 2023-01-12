TYPEINFO(/obj/machinery/recharge_station)
	mats = 10

/obj/machinery/recharge_station
	name = "cyborg docking station"
	icon = 'icons/obj/robot_parts.dmi'
	desc = "A station which allows cyborgs to repair damage, recharge their cells, and have upgrades installed if they are present in the station."
	icon_state = "station"
	density = 1
	anchored = 1
	event_handler_flags = NO_MOUSEDROP_QOL | USE_FLUID_ENTER
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_MULTITOOL
	allow_stunned_dragndrop = TRUE
	var/chargerate = 400
	var/cabling = 250
	var/list/cells = list()
	var/list/upgrades = list()
	var/list/modules = list()
	var/list/clothes = list()
	var/allow_self_service = TRUE
	var/conversion_chamber = FALSE
	var/mob/occupant = null
	power_usage = 50

/obj/machinery/recharge_station/New()
	..()
	src.flags |= NOSPLASH
	src.create_reagents(500)
	src.reagents.add_reagent("fuel", 250)
	src.build_icon()

/obj/machinery/recharge_station/disposing()
	if (src.occupant)
		src.occupant.set_loc(get_turf(src.loc))
		src.occupant = null
	..()

/obj/machinery/recharge_station/process(mult)
	if (!(src.status & BROKEN))
		src.power_usage = src.occupant ? 500 : 50
		// syndicate gear is nuclear powered or something
		if (src.conversion_chamber) src.power_usage = 0
		..()
	if (src.status & BROKEN || (src.status & NOPOWER && !conversion_chamber))
		if (src.occupant)
			boutput(src.occupant, "<span class='alert'>You are automatically ejected from [src]!</span>")
			src.go_out()

	if (src.occupant)
		src.process_occupant(mult)

	use_power(power_usage)
	return TRUE

/obj/machinery/recharge_station/allow_drop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if (src.conversion_chamber && !isrobot(user))
		boutput(user, "<span class='alert'>You're trapped inside!</span>")
		return
	src.go_out()

/obj/machinery/recharge_station/ex_act(severity)
	src.go_out()
	if (severity > 1 && src.conversion_chamber) //syndie version is a little tougher
		return
	return ..(severity)

/obj/machinery/recharge_station/attack_hand(mob/user)
	if (src.status & BROKEN)
		boutput(user, "<span class='alert'>[src] is broken and cannot be used.</span>")
		return
	if (src.status & NOPOWER && !src.conversion_chamber)
		boutput(user, "<span class='alert'>[src] is out of power and cannot be used.</span>")
		return
	if (!src.anchored)
		boutput(user, "<span class='alert'>You must attach [src]'s floor bolts before the machine will work.</span>")
		return

	interact_particle(user, src)
	ui_interact(user)

/obj/machinery/recharge_station/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/clothing))
		if (!istype(W, /obj/item/clothing/mask) && !istype(W, /obj/item/clothing/head) && !istype(W, /obj/item/clothing/under) && !istype(W, /obj/item/clothing/suit))
			boutput(user, "<span class='alert'>This type of is not compatible.</span>")
			return
		if (user.contents.Find(W))
			user.drop_item()
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.clothes.Add(W)

	else if (istype(W, /obj/item/robot_module))
		if (user.contents.Find(W))
			user.drop_item()
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.modules.Add(W)

	else if (istype(W, /obj/item/roboupgrade))
		if (user.contents.Find(W))
			user.drop_item()
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.upgrades.Add(W)

	else if (istype(W, /obj/item/cell))
		if (user.contents.Find(W))
			user.drop_item()
		W.set_loc(src)
		boutput(user, "You insert [W].")
		src.cells.Add(W)

	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/C = W
		src.cabling += C.amount
		boutput(user, "You insert [W]. [src] now has [src.cabling] cable available.")
		if (user.contents.Find(W))
			user.drop_item()
		qdel(W)

	//this is defined here instead of just using OPENCONTAINER because we want to be able to dump large amounts of reagents at once
	else if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
		if (!W.reagents.total_volume)
			boutput(user, "<span class='alert'>There is nothing in [W] to pour!</span>")
			return
		if (!W.reagents.has_reagent("fuel"))
			boutput(user, "<span class='alert'>There's no fuel in [W]. It would be pointless to pour it in.</span>")
			return
		if (src.reagents.total_volume >= src.reagents.maximum_volume)
			boutput(user, "<span class='alert'>[src] is full.</span>")
			return
		var/amount = min(W.reagents.total_volume, src.reagents.maximum_volume - src.reagents.total_volume, 50)
		user.visible_message("<span class='notice'>[user] pours [amount] units of [W]'s contents into [src].</span>")
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		W.reagents.trans_to(src, amount)
		src.reagents.isolate_reagent("fuel")

	else if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if (G.state == GRAB_PASSIVE)
			boutput(user, "<span class='alert'>You need a tighter grip!</span>")
			return
		if (src.move_human_inside(user, G.affecting))
			qdel(G)

	else
		..()

/// check if we may put this human inside the chamber
/// on success returns true, else returns false
/obj/machinery/recharge_station/proc/move_human_inside(mob/user, mob/victim)
	if (!src.conversion_chamber)
		boutput(user, "<span class='alert'>Humans cannot enter recharging stations.</span>")
		return FALSE
	if (!ishuman(victim))
		boutput(user, "<span class='alert'>Non-Humans are not compatible with this device.</span>")
		return FALSE
	if (isdead(victim))
		boutput(user, "<span class='alert'>[victim] is dead and cannot be forced inside.</span>")
		return FALSE
	if (!src.anchored)
		boutput(user, "<span class='alert'>You must attach [src]'s floor bolts before the machine will work.</span>")
		return FALSE
	if (src.occupant)
		boutput(user, "<span class='alert'>There's already someone in there.</span>")
		return FALSE
	var/mob/living/carbon/human/H = victim
	logTheThing(LOG_COMBAT, user, "puts [constructTarget(H,"combat")] into a conversion chamber at [log_loc(src)]")
	user.visible_message("<span class='notice>[user] stuffs [H] into \the [src].")

	H.remove_pulling()
	H.set_loc(src)
	src.add_fingerprint(user)
	src.occupant = H
	src.build_icon()
	return TRUE

/obj/machinery/recharge_station/MouseDrop_T(atom/movable/AM as mob|obj, mob/user as mob)
	if (BOUNDS_DIST(AM, user) > 0 || BOUNDS_DIST(src, user) > 0)
		return
	if (!isturf(AM.loc) && !(AM in user))
		return
	if (!isliving(user) || isAI(user))
		return

	if (isitem(AM) && can_act(user))
		src.Attackby(AM, user)
		return

	if (isliving(AM) && src.occupant)
		boutput(user, "<span class='alert'>\The [src] is already occupied!</span>")
		return

	if (isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if (isdead(R))
			boutput(user, "<span class='alert'>[R] is dead and cannot enter [src].</span>")
			return
		if (user != R)
			if (isunconscious(user))
				return
			else
				user.visible_message("<b>[user]</b> moves [R] into  [src].")
		R.remove_pulling()
		R.set_loc(src)
		src.occupant = R
		if (R.client)
			src.Attackhand(R)
		src.add_fingerprint(user)
		src.build_icon()

	if (isshell(AM))
		var/mob/living/silicon/hivebot/H = AM
		if (isdead(H))
			boutput(user, "<span class='alert'>[H] is dead and cannot enter [src].</span>")
			return
		if (user != H)
			if (isunconscious(user))
				return
			else
				user.visible_message("<b>[user]</b> moves [H] into [src].")
		H.remove_pulling()
		H.set_loc(src)
		src.occupant = H
		if (H.client)
			src.Attackhand(H)
		src.add_fingerprint(user)
		src.build_icon()

	if (ishuman(AM))
		src.move_human_inside(user, AM)

/obj/machinery/recharge_station/proc/build_icon()
	if (src.occupant)
		src.UpdateOverlays(image('icons/obj/robot_parts.dmi', "station-occu"), "occupant")
	else
		src.UpdateOverlays(null, "occupant")
	if (src.status & BROKEN)
		src.icon_state = "station-broke"
		src.UpdateOverlays(null, "power")
		return
	if (src.status & NOPOWER)
		src.UpdateOverlays(null, "power")
		return
	src.UpdateOverlays(image('icons/obj/robot_parts.dmi', "station-pow"), "power")

/obj/machinery/recharge_station/proc/process_occupant(mult)
	if (src.occupant)
		if (src.occupant.loc != src)
			src.go_out()
			return

		if (isrobot(src.occupant))
			var/mob/living/silicon/robot/R = src.occupant
			if (!R.cell)
				return
			else if (R.cell.charge * mult >= R.cell.maxcharge)
				R.cell.charge = R.cell.maxcharge
				return
			else
				R.cell.charge += src.chargerate * mult
				src.use_power(50)
				return

		else if (isshell(src.occupant))
			var/mob/living/silicon/hivebot/H = src.occupant

			if (!H.cell)
				return
			else if (H.cell.charge * mult >= H.cell.maxcharge)
				H.cell.charge = H.cell.maxcharge
				return
			else
				H.cell.charge += src.chargerate * mult
				src.use_power(50)
				return

		else if (ishuman(occupant) && src.conversion_chamber)
			var/mob/living/carbon/human/H = occupant
			if (prob(80))
				playsound(src.loc, pick(
					'sound/machines/mixer.ogg',
					'sound/misc/automaton_scratch.ogg',
					'sound/misc/automaton_ratchet.ogg',
					'sound/effects/brrp.ogg',
					'sound/impact_sounds/Metal_Clang_1.ogg',
					'sound/effects/pump.ogg',
					'sound/effects/syringeproj.ogg',
				), 60, 1)
				if (prob(15))
					src.visible_message("<span class='alert'>[src] [pick("whirs", "grinds", "rumbles", "clatters", "clangs")] [pick("horribly", "in a grisly manner", "horrifyingly", "scarily")]!</span>")
				if (prob(25))
					SPAWN(0.3 SECONDS)
						playsound(src.loc, pick(
							'sound/impact_sounds/Flesh_Stab_1.ogg',
							'sound/impact_sounds/Slimy_Hit_3.ogg',
							'sound/impact_sounds/Slimy_Hit_4.ogg',
							'sound/impact_sounds/Flesh_Break_1.ogg',
							'sound/impact_sounds/Flesh_Tear_1.ogg',
							'sound/impact_sounds/Generic_Snap_1.ogg',
							'sound/impact_sounds/Generic_Hit_1.ogg',
						), 60, 1)
					SPAWN(0.6 SECONDS)
						occupant?.emote("scream", FALSE)

			if (H.health <= 2)
				boutput(H, "<span class='alert'>You feel... different.</span>")
				src.go_out()

				SPAWN(0)
					var/bdna = null // For forensics (Convair880).
					var/btype = null
					if (H.bioHolder.Uid && H.bioHolder.bloodType)
						bdna = H.bioHolder.Uid
						btype = H.bioHolder.bloodType
					gibs(src.loc, null, null, bdna, btype)

					H.Robotize_MK2(TRUE, syndicate=TRUE)
					src.build_icon()
					playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
			else
				H.bioHolder.AddEffect("eaten")
				random_brute_damage(H, 10)
				H.changeStatus("weakened", 5 SECONDS)
				if (prob(15))
					boutput(H, "<span class='alert'>[pick("You feel chunks of your flesh being ripped off!"," Something cold and sharp skewers you!", "You feel your organs being pulped and mashed!", "Machines shred you from every direction!")]</span>")
			src.updateUsrDialog()

/obj/machinery/recharge_station/proc/go_out()
	MOVE_OUT_TO_TURF_SAFE(src.occupant, src)
	src.occupant = null
	src.build_icon()

/obj/machinery/recharge_station/was_deconstructed_to_frame(mob/user)
	src.go_out()

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
		boutput(usr, "<span class='alert'>Only cyborgs may enter [src]!</span>")
		return
	if (src.occupant)
		boutput(usr, "<span class='alert'>\The [src] is already occupied!</span>")
		return
	usr.remove_pulling()
	usr.set_loc(src)
	src.occupant = usr
	src.Attackhand(usr)
	src.add_fingerprint(usr)
	src.build_icon()

/obj/machinery/recharge_station/syndicate
	conversion_chamber = 1
	is_syndicate = 1
	anchored = 0
	p_class = 1.5

/obj/machinery/recharge_station/syndicate/attackby(obj/item/W, mob/user)
	if (iswrenchingtool(W))
		src.anchored = !src.anchored
		if (!anchored)
			src.go_out()
		user.show_text("You [src.anchored ? "attach" : "release"] \the [src]'s floor clamps", "red")
		playsound(src, 'sound/items/Ratchet.ogg', 40, 0, 0)
		return
	..()

/obj/machinery/recharge_station/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyborgDockingStation")
		ui.open()

/obj/machinery/recharge_station/ui_data(mob/user)
	. = list()

	.["viewer_is_occupant"] = (user == src.occupant)
	.["viewer_is_robot"] = isrobot(user)
	.["allow_self_service"] = src.allow_self_service
	.["conversion_chamber"] = src.conversion_chamber

	.["cabling"] = src.cabling
	var/fuelamt = src.reagents.get_reagent_amount("fuel")
	.["fuel"] = fuelamt

	.["disabled"] = FALSE
	if (isrobot(user))
		if (user != src.occupant)
			.["disabled"] = TRUE
	else
		if (user == src.occupant)
			.["disabled"] = TRUE
	if (!src.allow_self_service && user == src.occupant)
		.["disabled"] = TRUE

	var/list/occupant_data = list()
	if (isrobot(src.occupant))
		var/mob/living/silicon/robot/R = src.occupant
		occupant_data["name"] = R.name
		occupant_data["kind"] = "robot"
		if (R.part_head.brain)
			occupant_data["user"] = "brain"
		else if (R.part_head.ai_interface)
			occupant_data["user"] = "ai"
		else
			occupant_data["user"] = "unknown"

		var/list/parts = list()

		var/list/chest = list()
		if (R.part_chest)
			chest["exists"] = TRUE
			chest["max_health"] = R.part_chest.max_health
			chest["dmg_blunt"] = R.part_chest.dmg_blunt
			chest["dmg_burns"] = R.part_chest.dmg_burns
		else
			chest["exists"] = FALSE
		parts["chest"] = chest

		var/list/head = list()
		if (R.part_head)
			head["exists"] = TRUE
			head["max_health"] = R.part_head.max_health
			head["dmg_blunt"] = R.part_head.dmg_blunt
			head["dmg_burns"] = R.part_head.dmg_burns
		else
			head["exists"] = FALSE
		parts["head"] = head

		var/list/arm_r = list()
		if (R.part_arm_r)
			arm_r["exists"] = TRUE
			arm_r["max_health"] = R.part_arm_r.max_health
			arm_r["dmg_blunt"] = R.part_arm_r.dmg_blunt
			arm_r["dmg_burns"] = R.part_arm_r.dmg_burns
		else
			arm_r["exists"] = FALSE
		parts["arm_r"] = arm_r

		var/list/arm_l = list()
		if (R.part_arm_l)
			arm_l["exists"] = TRUE
			arm_l["max_health"] = R.part_arm_l.max_health
			arm_l["dmg_blunt"] = R.part_arm_l.dmg_blunt
			arm_l["dmg_burns"] = R.part_arm_l.dmg_burns
		else
			arm_l["exists"] = FALSE
		parts["arm_l"] = arm_l

		var/list/leg_r = list()
		if (R.part_leg_r)
			leg_r["exists"] = TRUE
			leg_r["max_health"] = R.part_leg_r.max_health
			leg_r["dmg_blunt"] = R.part_leg_r.dmg_blunt
			leg_r["dmg_burns"] = R.part_leg_r.dmg_burns
		else
			leg_r["exists"] = FALSE
		parts["leg_r"] = leg_r

		var/list/leg_l = list()
		if (R.part_leg_l)
			leg_l["exists"] = TRUE
			leg_l["max_health"] = R.part_leg_l.max_health
			leg_l["dmg_blunt"] = R.part_leg_l.dmg_blunt
			leg_l["dmg_burns"] = R.part_leg_l.dmg_burns
		else
			leg_l["exists"] = FALSE
		parts["leg_l"] = leg_l

		occupant_data["parts"] = parts

		if (R.cell)
			var/list/this_cell = list()
			var/obj/item/cell/C = R.cell
			this_cell["name"] = C.name
			this_cell["current"] = C.charge
			this_cell["max"] = C.maxcharge
			occupant_data["cell"] = this_cell

		if (R.module)
			var/obj/item/robot_module/M = R.module
			occupant_data["module"] = M.name

		var/list/occupant_upgrades = list()
		if (length(R.upgrades))
			for (var/obj/item/roboupgrade/U in R.upgrades)
				var/list/this_upgrade = list()
				this_upgrade["name"] = U.name
				this_upgrade["ref"] = "\ref[U]"
				occupant_upgrades += list(this_upgrade)
		occupant_data["upgrades"] = occupant_upgrades
		occupant_data["upgrades_max"] = R.max_upgrades

		var/list/occupant_clothing = list()
		if (length(R.clothes))
			for (var/A in R.clothes)
				var/list/this_cloth = list()
				var/obj/O = R.clothes[A]
				this_cloth["name"] = O.name
				this_cloth["ref"] = "\ref[O]"
				occupant_clothing += list(this_cloth)
		occupant_data["clothing"] = occupant_clothing

		var/list/occupant_cosmetics = list()
		if(istype(R.cosmetic_mods, /datum/robot_cosmetic))
			var/datum/robot_cosmetic/COS = R.cosmetic_mods
			if(COS.ches_mod) occupant_cosmetics["chest"] = COS.ches_mod
			if(COS.painted) occupant_cosmetics["paint"] = COS.paint // hex color representation
			if(COS.head_mod) occupant_cosmetics["head"] = COS.head_mod
			if(COS.arms_mod) occupant_cosmetics["arms"] = COS.arms_mod
			if(COS.legs_mod) occupant_cosmetics["legs"] = COS.legs_mod
			occupant_cosmetics["fx"] = COS.fx // R,G,B representation

		occupant_data["cosmetics"] = occupant_cosmetics

	if (src.conversion_chamber && ishuman(src.occupant))
		var/mob/living/carbon/human/H = src.occupant
		occupant_data["name"] = H.name
		occupant_data["kind"] = "human"
		occupant_data["health"] = H.health
		occupant_data["max_health"] = H.max_health

	if (isshell(src.occupant)) // eyebot handling
		var/mob/living/silicon/hivebot/eyebot/E = src.occupant
		occupant_data["name"] = E.name
		occupant_data["kind"] = "eyebot"
		if (E.cell)
			var/list/this_cell = list()
			var/obj/item/cell/C = E.cell
			this_cell["name"] = C.name
			this_cell["current"] = C.charge
			this_cell["max"] = C.maxcharge
			occupant_data["cell"] = this_cell

	.["occupant"] = occupant_data

	var/list/power_cells_available = list()
	if (length(src.cells))
		for (var/obj/item/cell/C in src.cells)
			var/list/this_cell = list()
			this_cell["name"] = C.name
			this_cell["ref"] = "\ref[C]"
			this_cell["current"] = C.charge
			this_cell["max"] = C.maxcharge
			power_cells_available += list(this_cell)
	.["cells"] = power_cells_available

	var/list/modules_available = list()
	if (length(src.modules))
		for (var/obj/item/robot_module/M in src.modules)
			var/list/this_module = list()
			this_module["name"] = M.name
			this_module["ref"] = "\ref[M]"
			modules_available += list(this_module)
	.["modules"] = modules_available

	var/list/upgrades_available = list()
	if (length(src.upgrades))
		for (var/obj/item/roboupgrade/U in src.upgrades)
			var/list/this_upgrade = list()
			this_upgrade["name"] = U.name
			this_upgrade["ref"] = "\ref[U]"
			upgrades_available += list(this_upgrade)
	.["upgrades"] = upgrades_available

	var/list/clothing_available = list()
	if (length(src.clothes))
		for (var/obj/item/clothing/C in src.clothes)
			var/list/this_clothing = list()
			this_clothing["name"] = C.name
			this_clothing["ref"] = "\ref[C]"
			clothing_available += list(this_clothing)
	.["clothes"] = clothing_available

/obj/machinery/recharge_station/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if (.)
		return

	var/mob/user = ui.user

	if (isrobot(user))
		if (user != src.occupant)
			boutput(user, "<span class='alert'>You must be inside the docking station to use the functions.</span>")
			return
	else
		if (user == src.occupant && !isshell(user))
			boutput(user, "<span class='alert'>Non-cyborgs cannot use the docking station functions.</span>")
			return

	if (!src.allow_self_service && user == src.occupant)
		boutput(user, "<span class='alert'>Self-service has been disabled at this station.</span>")
		return

	switch(action)
		if("occupant-rename")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/newname = copytext(strip_html(sanitize(tgui_input_text(user, "What do you want to rename [R]?", "Cyborg Maintenance", R.name))), 1, 64)
			if ((!issilicon(user) && (BOUNDS_DIST(user, src) > 0)) || user.stat || !newname)
				return
			if (url_regex?.Find(newname))
				boutput(user, "<span class='notice'><b>Web/BYOND links are not allowed in ingame chat.</b></span>")
				boutput(user, "<span class='alert'>&emsp;<b>\"[newname]</b>\"</span>")
				return
			if(newname && newname != R.name)
				phrase_log.log_phrase("name-cyborg", newname, no_duplicates=TRUE)
			logTheThing(LOG_STATION, user, "uses a docking station to rename [constructTarget(R,"combat")] to [newname].")
			R.real_name = "[newname]"
			R.UpdateName()
			if (R.internal_pda)
				R.internal_pda.name = "[R.name]'s Internal PDA Unit"
				R.internal_pda.owner = "[R.name]"
			. = TRUE
		if("occupant-eject")
			src.go_out()
			. = TRUE
		if("occupant-paint-add")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			C.painted = TRUE
			C.paint = input(user) as color
			R.update_appearance()
			R.update_bodypart()
			. = TRUE
		if("occupant-paint-remove")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			C.painted = FALSE
			R.update_appearance()
			R.update_bodypart()
			. = TRUE
		if("occupant-paint-change")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			C.paint = input(user) as color
			R.update_appearance()
			R.update_bodypart("all")
			. = TRUE
		if("occupant-fx")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			var/selected_color = input(user) as color
			if(selected_color)
				C.fx = hex_to_rgb_list(selected_color)
				R.update_appearance()
				R.update_bodypart("head")
			. = TRUE
		if("cosmetic-change-chest")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			var/mod = tgui_input_list(user, "Please select a chest decoration!", "Cyborg Decoration", list("Nothing", "Medical Insignia", "Lab Coat"))
			if (!mod)
				mod = "Nothing"
			if (mod == "Nothing")
				C.ches_mod = null
			else
				C.ches_mod = mod
			R.update_bodypart("chest")
			R.update_appearance()
			. = TRUE
		if("cosmetic-change-head")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			var/mod = tgui_input_list(user, "Please select a head decoration!", "Cyborg Decoration", list("Nothing", "Medical Mirror", "Janitor Cap", "Hard Hat", "Afro and Shades"))
			if (!mod)
				mod = "Nothing"
			if (mod == "Nothing")
				C.head_mod = null
			else
				C.head_mod = mod
			R.update_bodypart("head")
			R.update_appearance()
			. = TRUE
		if("cosmetic-change-arms")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			var/mod = tgui_input_list(user, "Please select an arms decoration!", "Cyborg Decoration", list("Nothing"))
			if (!mod)
				mod = "Nothing"
			if (mod == "Nothing")
				C.arms_mod = null
			else
				C.arms_mod = mod
			R.update_bodypart("l_arm")
			R.update_bodypart("r_arm")
			R.update_appearance()
			. = TRUE
		if("cosmetic-change-legs")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/datum/robot_cosmetic/C = null
			if (R.cosmetic_mods)
				C = R.cosmetic_mods
			else
				boutput(user, "<span class='alert'>ERROR: Cannot find cyborg's decorations.</span>")
				return
			var/mod = tgui_input_list(user, "Please select a legs decoration!", "Cyborg Decoration", list("Nothing", "Disco Flares"))
			if (!mod)
				mod = "Nothing"
			if (mod == "Nothing")
				C.legs_mod = null
			else
				C.legs_mod = mod
			R.update_bodypart("l_leg")
			R.update_bodypart("r_leg")
			R.update_appearance()
			. = TRUE

		if("self-service")
			if (isrobot(user))
				boutput(user, "<span class='alert'>Cyborgs are not allowed to toggle this option.</span>")
				return
			else
				src.allow_self_service = !src.allow_self_service
			. = TRUE

		if("repair-fuel")
			if (!isrobot(occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			if (src.reagents.get_reagent_amount("fuel") < 1)
				boutput(user, "<span class='alert'>Not enough welding fuel for repairs.</span>")
				return
			if ((!issilicon(user) && (BOUNDS_DIST(user, src) > 0)) || user.stat)
				return
			var/usage = min(src.reagents.get_reagent_amount("fuel"), R.compborg_get_total_damage(1))
			if (usage < 1)
				return
			for (var/obj/item/parts/robot_parts/RP in R.contents)
				RP.ropart_mend_damage(usage, 0)
			src.reagents.remove_reagent("fuel", usage)
			R.update_appearance()
			. = TRUE

		if("repair-wiring")
			if (!isrobot(occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			if (src.cabling < 1)
				boutput(user, "<span class='alert'>Not enough wiring for repairs.</span>")
				return
			if ((!issilicon(user) && (BOUNDS_DIST(user, src) > 0)) || user.stat)
				return
			var/usage =  min(src.cabling, R.compborg_get_total_damage(2))
			if (usage < 1)
				return
			for (var/obj/item/parts/robot_parts/RP in R.contents)
				RP.ropart_mend_damage(0, usage)
			src.cabling -= usage
			if (src.cabling < 0)
				src.cabling = 0
			R.update_appearance()
			. = TRUE

		if("module-install")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/moduleRef = params["moduleRef"]
			if(moduleRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					if (R.module) // Remove installed module to make room for new module
						var/obj/item/robot_module/removed_module = R.remove_module()
						src.modules.Add(removed_module)
						removed_module.set_loc(src)

					R.set_module(module)
					src.modules.Remove(module)
					R.update_appearance()
			. = TRUE
		if("module-remove")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			if (R.module)
				var/obj/item/robot_module/removed_module = R.remove_module()
				src.modules.Add(removed_module)
				removed_module.set_loc(src)
				R.update_appearance()
			. = TRUE
		if("module-eject")
			var/moduleRef = params["moduleRef"]
			if(moduleRef)
				var/obj/item/robot_module/module = locate(moduleRef) in src.modules
				if (module)
					src.modules.Remove(module)
					if (module.loc == src)
						user.put_in_hand_or_eject(module)
			. = TRUE

		if("upgrade-install")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/upgradeRef = params["upgradeRef"]
			if(upgradeRef)
				var/obj/item/roboupgrade/upgrade = locate(upgradeRef) in src.upgrades
				if (upgrade)
					if (length(R.upgrades) >= R.max_upgrades)
						boutput(user, "<span class='alert'>[R] has no room for further upgrades.</span>")
						return
					if (locate(upgrade.type) in R.upgrades)
						boutput(user, "<span class='alert'>[R] already has that upgrade.</span>")
						return
					src.upgrades.Remove(upgrade)
					R.upgrades.Add(upgrade)
					upgrade.set_loc(R)
					boutput(R, "<span class='notice'>You received [upgrade]! It can be activated from your panel.</span>")
					R.hud.update_upgrades()
			. = TRUE
		if("upgrade-remove")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/upgradeRef = params["upgradeRef"]
			if(upgradeRef)
				var/obj/item/roboupgrade/upgrade = locate(upgradeRef) in R.upgrades
				if (upgrade)
					if (!upgrade.removable)
						boutput(user, "<span class='alert'>This upgrade cannot be removed.</span>")
					else
						boutput(R, "<span class='alert'>[upgrade] was removed!</span>")
						upgrade.upgrade_deactivate(R)
						src.upgrades.Add(upgrade)
						R.upgrades.Remove(upgrade)
						upgrade.set_loc(src)
						R.hud.update_upgrades()
			. = TRUE
		if("upgrade-eject")
			var/upgradeRef = params["upgradeRef"]
			if(upgradeRef)
				var/obj/item/roboupgrade/upgrade = locate(upgradeRef) in src.upgrades
				if (upgrade)
					src.upgrades.Remove(upgrade)
					if (upgrade.loc == src)
						user.put_in_hand_or_eject(upgrade)
			. = TRUE

		if("clothing-install")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/clothingRef = params["clothingRef"]
			if(clothingRef)
				var/obj/item/clothing/cloth = locate(clothingRef) in src.clothes
				if (istype(cloth, /obj/item/clothing))
					if (istype(cloth, /obj/item/clothing/under))
						if (R.clothes["under"] != null)
							var/obj/old = R.clothes["under"]
							src.clothes.Add(old)
							old.set_loc(src)
						R.clothes["under"] = cloth
						src.clothes.Remove(cloth)
						cloth.set_loc(R)
					else if (istype(cloth, /obj/item/clothing/suit))
						if (R.clothes["suit"] != null)
							var/obj/old = R.clothes["suit"]
							src.clothes.Add(old)
							old.set_loc(src)
						R.clothes["suit"] = cloth
						src.clothes.Remove(cloth)
						cloth.set_loc(R)
					else if (istype(cloth, /obj/item/clothing/mask))
						if (R.clothes["mask"] != null)
							var/obj/old = R.clothes["mask"]
							src.clothes.Add(old)
							old.set_loc(src)
						R.clothes["mask"] = cloth
						src.clothes.Remove(cloth)
						cloth.set_loc(R)
					else if (istype(cloth, /obj/item/clothing/head))
						if (R.clothes["head"] != null)
							var/obj/old = R.clothes["head"]
							src.clothes.Add(old)
							old.set_loc(src)
						R.clothes["head"] = cloth
						src.clothes.Remove(cloth)
						cloth.set_loc(R)
			R.update_appearance()
			. = TRUE
		if("clothing-remove")
			if (!isrobot(src.occupant))
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/clothingRef = params["clothingRef"]
			if(clothingRef)
				var/obj/item/clothing/clothing_to_remove = locate(clothingRef) in src.occupant
				for (var/clothing_slot in R.clothes)
					if ("\ref[R.clothes[clothing_slot]]" == clothingRef)
						src.clothes.Add(clothing_to_remove)
						clothing_to_remove.set_loc(src)
						R.clothes.Remove(clothing_slot)
						boutput(R, "<span class='alert'>\The [clothing_to_remove.name] was removed!</span>")
						R.update_appearance()
						break
			. = TRUE
		if("clothing-eject")
			var/clothingRef = params["clothingRef"]
			if(clothingRef)
				var/obj/item/clothing/cloth = locate(clothingRef) in src.clothes
				if (cloth)
					src.clothes.Remove(cloth)
					if (cloth.loc == src)
						user.put_in_hand_or_eject(cloth)
			. = TRUE

		if("cell-install")
			if (!isrobot(src.occupant))
				return
			if (user == src.occupant)
				boutput(user, "<span class='alert'>You can't modify your own power cell!</span>")
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/cellRef = params["cellRef"]
			if(cellRef)
				var/obj/item/cell/cell_to_install = locate(cellRef) in src.cells
				if (R.cell)
					var/obj/item/cell_to_remove = R.cell
					src.cells.Add(cell_to_remove)
					cell_to_remove.set_loc(src)
					R.cell = null
					R.part_chest?.cell = null
					boutput(R, "<span class='notice'>Your power cell is being swapped...</span>")
				src.cells.Remove(cell_to_install)
				cell_to_install.set_loc(R)
				R.cell = cell_to_install
				R.part_chest?.cell = cell_to_install
				boutput(R, "<span class='notice'>Power cell installed: [cell_to_install].</span>")
				R.hud.update_charge()
			. = TRUE
		if("cell-remove")
			if (!isrobot(src.occupant))
				return
			if (user == src.occupant)
				boutput(user, "<span class='alert'>You can't modify your own power cell!</span>")
				return
			var/mob/living/silicon/robot/R = src.occupant
			var/obj/item/cell_to_remove = R.cell
			src.cells += R.cell
			cell_to_remove.set_loc(src)
			R.cell = null
			R.part_chest?.cell = null
			boutput(R, "<span class='alert'>Your power cell was removed!</span>")
			logTheThing(LOG_COMBAT, user, "removes [constructTarget(R,"combat")]'s power cell at [log_loc(user)].")
			R.hud.update_charge()
			. = TRUE
		if("cell-eject")
			var/cellRef = params["cellRef"]
			if(cellRef)
				var/obj/item/cell/cell_to_eject = locate(cellRef) in src.cells
				if (cell_to_eject)
					src.cells.Remove(cell_to_eject)
					if (cell_to_eject.loc == src)
						user.put_in_hand_or_eject(cell_to_eject)
			. = TRUE
