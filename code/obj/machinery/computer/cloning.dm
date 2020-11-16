//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

// time to show the message for before removing it
#define MESSAGE_SHOW_TIME 	5 SECONDS

/obj/machinery/computer/cloning
	name = "Cloning Console"
	desc = "Use this console to operate a cloning scanner and pod. There is a slot to insert modules - they can be removed with a screwdriver."
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	req_access = list(access_heads) //Only used for record deletion right now.
	object_flags = CAN_REPROGRAM_ACCESS
	machine_registry_idx = MACHINES_CLONINGCONSOLES
	var/obj/machinery/clone_scanner/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/currentStatusMessage = list()
	var/currentMessageNumber = 0
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/obj/item/disk/data/floppy/diskette = null //Mostly so the geneticist can steal somebody's identity while pretending to give them a handy backup profile.
	var/held_credit = 5000 // one free clone
	var/allow_dead_scanning = 0 //Can the dead be scanned in the cloner?
	var/portable = 0 //override new() proc and proximity check, for port-a-clones
	var/recordDeleting = list()
	var/allow_mind_erasure = 0 // Can you erase minds?
	var/mindwipe = 0 //Is mind wiping active?

	lr = 1
	lg = 0.6
	lb = 1

	disposing()
		scanner?.connected = null
		pod1?.connected = null
		scanner = null
		pod1 = null
		diskette = null
		records = null
		STOP_TRACKING
		..()

	old
		icon_state = "old2"
		desc = "With the price of cloning pods nowadays it's not unexpected to skimp on the controller."

		power_change()

			if(status & BROKEN)
				icon_state = "old2b"
			else
				if( powered() )
					icon_state = initial(icon_state)
					status &= ~NOPOWER
				else
					SPAWN_DBG(rand(0, 15))
						src.icon_state = "old20"
						status |= NOPOWER

/obj/item/cloner_upgrade
	name = "\improper NecroScan II cloner upgrade module"
	desc = "A circuit module designed to improve cloning machine scanning capabilities to the point where even the deceased may be scanned."
	icon = 'icons/obj/module.dmi'
	icon_state = "cloner_upgrade"
	w_class = 1
	throwforce = 1

/obj/item/grinder_upgrade
	name = "\improper ProBlender X enzymatic reclaimer upgrade module"
	desc = "A circuit module designed to improve enzymatic reclaimer capabilities so that the machine will be able to reclaim more matter, faster."
	icon = 'icons/obj/module.dmi'
	icon_state = "grinder_upgrade"
	w_class = 1
	throwforce = 1

/obj/machinery/computer/cloning/New()
	..()
	START_TRACKING
	SPAWN_DBG(0.7 SECONDS)
		if(portable) return
		src.scanner = locate(/obj/machinery/clone_scanner, orange(2,src))
		src.pod1 = locate(/obj/machinery/clonepod, orange(4,src))

		var/hookup_error = FALSE
		if (isnull(src.scanner))
			hookup_error = TRUE
		if (isnull(src.pod1))
			hookup_error = TRUE
		if (!hookup_error)
			src.pod1?.connected = src
			src.scanner?.connected = src
	return

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob)
	if (wagesystem.clones_for_cash && istype(W, /obj/item/spacecash))
		var/obj/item/spacecash/cash = W
		src.held_credit += cash.amount
		cash.amount = 0
		user.show_text("<span class='notice'>You add [cash] to the credit in [src].</span>")
		user.u_equip(W)
		pool(W)
	else if (istype(W, /obj/item/disk/data/floppy))
		if (!src.diskette)
			user.drop_item()
			W.set_loc(src)
			src.diskette = W
			boutput(user, "You insert [W].")
			src.updateUsrDialog()
			return

	else if (isscrewingtool(W) && ((src.status & BROKEN) || !src.pod1 || !src.scanner || src.allow_dead_scanning || src.allow_mind_erasure || src.pod1.BE))
		playsound(src.loc, "sound/items/Screwdriver.ogg", 50, 1)
		if(do_after(user, 20))
			boutput(user, "<span class='notice'>The broken glass falls out.</span>")
			var/obj/computerframe/A = new /obj/computerframe( src.loc )
			if(src.material) A.setMaterial(src.material)
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)
			var/obj/item/circuitboard/cloning/M = new /obj/item/circuitboard/cloning( A )
			for (var/obj/C in src)
				C.set_loc(src.loc)
			M.records = src.records
			if (src.allow_dead_scanning)
				new /obj/item/cloner_upgrade (src.loc)
				src.allow_dead_scanning = 0
			if(src.allow_mind_erasure)
				new /obj/item/cloneModule/minderaser(src.loc)
				src.allow_mind_erasure = 0
			if(src.pod1 && src.pod1.BE)
				new /obj/item/cloneModule/genepowermodule(src.loc)
				src.pod1.BE = null
			A.circuit = M
			A.state = 3
			A.icon_state = "3"
			A.anchored = 1
			qdel(src)

	else if (istype(W, /obj/item/cloner_upgrade))
		if (allow_dead_scanning || allow_mind_erasure)
			boutput(user, "<span class='alert'>There is already an upgrade installed.</span>")
			return

		user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
		src.allow_dead_scanning = 1
		user.drop_item()
		logTheThing("combat", src, user, "[user] has added clone module ([W]) to ([src]) at [log_loc(user)].")
		qdel(W)

	else if (istype(W, /obj/item/cloneModule/minderaser))
		if(allow_mind_erasure || allow_dead_scanning)
			boutput(user, "<span class='alert'>There is already an upgrade installed.</span>")
			return
		user.visible_message("[user] installs [W] into [src].", "You install [W] into [src].")
		src.allow_mind_erasure = 1
		user.drop_item()
		logTheThing("combat", src, user, "[user] has added clone module ([W]) to ([src]) at [log_loc(user)].")
		qdel(W)
	else if (istype(W, /obj/item/cloneModule/genepowermodule))
		var/obj/item/cloneModule/genepowermodule/module = W
		if(module.BE == null)
			boutput(user, "<span class='alert'>You need to put an injector into the module before it will work!</span>")
			return
		if(pod1.BE)
			boutput(user,"<span class='alert'>There is already a gene module in this upgrade spot! You can remove it by blowing up the genetics computer and building a new one. Or you could just use a screwdriver, I guess.</span>")
			return
		src.pod1.BE = module.BE
		user.drop_item()
		user.visible_message("[user] installs [module] into [src].", "You install [module] into [src].")
		logTheThing("combat", src, user, "[user] has added clone module ([W] - [module.BE]) to ([src]) at [log_loc(user)].")
		qdel(module)


	else
		src.attack_hand(user)
	return

// message = message you want to pass to the noticebox
// status = warning/success/danger/info which changes the color of the noticebox on the frontend

/obj/machinery/computer/cloning/proc/show_message(message = "", status = "info")
	src.currentStatusMessage["text"] = message
	src.currentStatusMessage["status"] = status
	tgui_process?.update_uis(src)
	//prevents us from overwriting the wrong message
	currentMessageNumber += 1
	var/messageNumber = currentMessageNumber
	SPAWN_DBG(MESSAGE_SHOW_TIME)
	if(src.currentMessageNumber == messageNumber)
		src.currentStatusMessage["text"] = ""
		src.currentStatusMessage["status"] = ""
		tgui_process?.update_uis(src)

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	if ((isnull(subject)) || (!ishuman(subject)))
		show_message("Error: Unable to locate valid genetic data.", "danger")
		return
	if(!allow_dead_scanning && subject.decomp_stage)
		show_message("Error: Failed to read genetic data from subject.<br>Necrosis of tissue has been detected.")
		return
	if (!subject.bioHolder || subject.bioHolder.HasEffect("husk"))
		show_message("Error: Extreme genetic degredation present.", "danger")
		return
	if (istype(subject.mutantrace, /datum/mutantrace/kudzu))
		show_message("Error: Incompatible cellular structure.", "danger")
		return
	if (istype(subject.mutantrace, /datum/mutantrace/zombie))
		show_message("Error: Incompatible cellular structure.", "danger")
		return
	if (subject.mob_flags & IS_BONER)
		show_message("Error: No tissue mass present.<br>Total ossification of subject detected.", "danger")
		return

	var/datum/mind/subjMind = subject.mind
	if ((!subjMind) || (!subjMind.key))
		if ((subject.ghost && subject.ghost.mind && subject.ghost.mind.key))
			subjMind = subject.ghost.mind
		else if (subject.last_client)
			var/mob/M = find_ghost_by_key(subject.last_client.ckey)
			if (isVRghost(M) || inafterlifebar(M) || isghostcritter(M))
				subjMind = M.mind
			else
				show_message("Error: Mental interface failure.", "warning")
				return
		else
			show_message("Error: Mental interface failure.", "warning")
			return
	if (!isnull(find_record(ckey(subjMind.key))))
		show_message("Subject already in database.", "info")
		return

	var/datum/data/record/R = new /datum/data/record(  )
	R.fields["ckey"] = ckey(subjMind.key)
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)

	var/datum/bioHolder/H = new/datum/bioHolder(null)
	H.CopyOther(subject.bioHolder)

	R.fields["holder"] = H

	R.fields["abilities"] = null
	if (subject.abilityHolder)
		var/datum/abilityHolder/A = subject.abilityHolder.deepCopy()
		R.fields["abilities"] = A

	R.fields["traits"] = list()
	if(subject.traitHolder && subject.traitHolder.traits.len)
		R.fields["traits"] = subject.traitHolder.traits.Copy()

	//Add an implant if needed
	var/obj/item/implant/health/imp = locate(/obj/item/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/implant/health(subject)
		imp.implanted = 1
		imp.owner = subject
		subject.implant.Add(imp)
//		imp.implanted = subject // this isn't how this works with new implants sheesh
		R.fields["imp"] = "\ref[imp]"
	//Update it if needed
	else
		R.fields["imp"] = "\ref[imp]"

	if (!isnull(subjMind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = subjMind

	src.records += R
	show_message("Subject successfully scanned.", "success")
	JOB_XP(usr, "Medical Doctor", 10)

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/data/record/R in src.records)
		if (R.fields["ckey"] == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/proc/clone_record(datum/data/record/C)
	if (!istype(C))
		show_message("Invalid or corrupt record.", "danger")
		return
	if (!src.pod1)
		show_message("No cloning pod connected.", "danger")
		return
	if (src.pod1.attempting)
		show_message("Cloning pod in use.", "info")
		return
	if (src.pod1.mess)
		show_message("Abnormal reading from cloning pod.", "danger")
		return

	var/mob/selected = find_ghost_by_key(C.fields["ckey"])

	if (!selected)
		show_message("Can't clone: Unable to locate mind.", "danger")
		return

	if (selected.mind && selected.mind.dnr)
		// leave the goddamn dnr ghosts alone
		show_message("Cannot clone: Subject has set DNR.", "danger")
		return

	if (inafterlifebar(selected) || isghostcritter(selected) || isVRghost(selected))
		//for deleting the mob if theyre in the bar, in vr, or a ghost critter
		var/mob/soon_to_be_deleted = selected
		boutput(selected, "<span class='notice'>You are being returned to the land of the living!</span>")
		selected = soon_to_be_deleted.ghostize()
		qdel(soon_to_be_deleted)

	// at this point selected = the dude we wanna revive.

	if (wagesystem.clones_for_cash)
		var/datum/data/record/Ba = FindBankAccountByName(C.fields["name"])
		var/account_credit = 0

		if (Ba?.fields["current_money"])
			account_credit = Ba.fields["current_money"]

		if ((src.held_credit + account_credit) >= wagesystem.clone_cost)
			if (src.pod1.growclone(selected, C.fields["name"], C.fields["mind"], C.fields["holder"], C.fields["abilities"] , C.fields["traits"]))
				var/from_account = min(wagesystem.clone_cost, account_credit)
				if (from_account > 0)
					Ba.fields["current_money"] -= from_account
				src.held_credit -= (wagesystem.clone_cost - from_account)
				show_message("Payment of [wagesystem.clone_cost] credits accepted. [from_account > 0 ? "Deducted [from_account] credits from [C.fields["name"]]'s account.' " : ""][from_account < wagesystem.clone_cost ? "Deducted [wagesystem.clone_cost - from_account] credits from machine credit." : ""] Cloning cycle activated.", "info")
				src.records.Remove(C)
				qdel(C)
				src.menu = 1
			else
				show_message("Unknown error when trying to start cloning process.", "info")
		else
			show_message("Insufficient funds to begin clone cycle.", "warning")

	else if (src.pod1.growclone(selected, C.fields["name"], C.fields["mind"], C.fields["holder"], C.fields["abilities"] , C.fields["traits"]))
		show_message("Cloning cycle activated.", "success")
		src.records.Remove(C)
		qdel(C)
		JOB_XP(usr, "Medical Doctor", 15)
		src.menu = 1

/obj/machinery/computer/cloning/power_change()

	if(status & BROKEN)
		icon_state = "commb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			status &= ~NOPOWER
		else
			SPAWN_DBG(rand(0, 15))
				src.icon_state = "c_unpowered"
				status |= NOPOWER

/// find a ghost mob (or a ghost respawned as critter in vr/afterlife bar)
proc/find_ghost_by_key(var/find_key)
	if (!find_key)
		return null

	var/datum/player/player = find_player(find_key)
	if (player?.client?.mob)
		var/mob/M = player.client.mob
		if (isdead(M) || isVRghost(M) || inafterlifebar(M) || isghostcritter(M))
			return M
	return null

#define PROCESS_IDLE 0
#define PROCESS_STRIP 1
#define PROCESS_MINCE 2

/obj/machinery/clone_scanner
	name = "cloning machine scanner"
	desc = "Some sort of weird machine that you stuff people into to scan their genetic DNA for cloning."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	mats = 15
	var/locked = 0
	var/mob/occupant = null
	anchored = 1.0
	soundproofing = 10
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	var/obj/machinery/computer/cloning/connected = null

	// In case someone wants a perfectly safe device. For some weird reason.
	var/can_meat_grind = 1
	//Double functionality as a meat grinder
	var/list/obj/machinery/clonepod/pods
	// How long to run
	var/process_timer = 0
	var/timer_length = 0
	// Automatically strip the target of their equipment
	var/auto_strip = 1
	// Check if the target is a living human before mincing
	var/mince_safety = 1
	// How far away to find clone pods
	var/pod_range = 4
	// What we are working on at the moment
	var/active_process = PROCESS_IDLE
	// If we should start the mincer after the stripper (lol)
	var/automatic_sequence = 0
	// Our ID for mapping
	var/id = ""
	// If upgraded or not
	var/upgraded = 0

	allow_drop()
		return 0

	New()
		..()
		src.create_reagents(100)

	relaymove(mob/user as mob, dir)
		eject_occupant(user)

	disposing()
		connected?.scanner = null
		connected = null
		pods = null
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (get_dist(src,user) > 1 || get_dist(user, target) > 1)
			return

		if (target == user)
			move_mob_inside(target)
		else if (can_operate(user))
			var/previous_user_intent = user.a_intent
			user.a_intent = INTENT_GRAB
			user.drop_item()
			target.attack_hand(user)
			user.a_intent = previous_user_intent
			SPAWN_DBG(user.combat_click_delay + 2)
				if (can_operate(user))
					if (istype(user.equipped(), /obj/item/grab))
						src.attackby(user.equipped(), user)
		return


	proc/can_operate(var/mob/M)
		if (!isalive(M))
			return
		if (get_dist(src,M) > 1)
			return 0
		if (M.getStatusDuration("paralysis") || M.getStatusDuration("stunned") || M.getStatusDuration("weakened"))
			return 0
		if (src.occupant)
			boutput(M, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return

		.= 1

	verb/move_inside()
		set src in oview(1)
		set category = "Local"

		move_mob_inside(usr)
		return

	proc/move_mob_inside(var/mob/M)
		if (!can_operate(M)) return

		M.pulling = null
		M.set_loc(src)
		src.occupant = M
		src.icon_state = "scanner_1"

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(usr)
		src?.connected.updateUsrDialog()

		playsound(src.loc, "sound/machines/sleeper_close.ogg", 50, 1)

	attack_hand(mob/user as mob)
		..()
		eject_occupant(user)

	MouseDrop(mob/user as mob)
		if (can_operate(user))
			eject_occupant(user)
		else
			..()

	verb/eject()
		set src in oview(1)
		set category = "Local"

		eject_occupant(usr)
		return

	verb/eject_occupant(var/mob/user)
		if (!isalive(user))
			return
		src.go_out()
		add_fingerprint(user)

	attackby(var/obj/item/grab/G as obj, user as mob)
		if ((!( istype(G, /obj/item/grab) ) || !( ismob(G.affecting) )))
			return

		if (src.occupant)
			boutput(user, "<span class='notice'><B>The scanner is already occupied!</B></span>")
			return

		var/mob/M = G.affecting
		M.set_loc(src)
		src.occupant = M
		src.icon_state = "scanner_1"

		playsound(src.loc, "sound/machines/sleeper_close.ogg", 50, 1)

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(user)
		qdel(G)
		return

	proc/go_out()
		if ((!( src.occupant ) || src.locked))
			return

		if(!src.occupant.disposed)
			src.occupant.set_loc(src.loc)

		src.occupant = null

		for(var/atom/movable/A in src)
			A.set_loc(src.loc)

		src.icon_state = "scanner_0"

		playsound(src.loc, "sound/machines/sleeper_open.ogg", 50, 1)

		return

	proc/set_lock(var/lock_status)
		if(lock_status && !locked)
			locked = 1
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			bo(occupant, "<span class='alert'>\The [src] locks shut!</span>")
		else if(!lock_status && locked)
			locked = 0
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
			bo(occupant, "<span class='notice'>\The [src] unlocks!</span>")

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (air_group || (height==0))
			return 1
		..()

	// Meat grinder functionality.
	proc/find_pods()
		if (!islist(src.pods))
			src.pods = list()
		if (!isnull(src.id) && genResearch && islist(genResearch.clonepods) && genResearch.clonepods.len)
			for (var/obj/machinery/clonepod/pod in genResearch.clonepods)
				if (pod.id == src.id && !src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] (ID [src.id]) in genResearch.clonepods")
		else
			for (var/obj/machinery/clonepod/pod in orange(src.pod_range))
				if (!src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] in orange([src.pod_range])")

	process()
		switch(active_process)
			if(PROCESS_IDLE)
				UnsubscribeProcess()
				process_timer = 0
				return
			if(PROCESS_MINCE)
				do_mince()
			if(PROCESS_STRIP)
				do_strip()

	proc/report_progress()
		switch(active_process)
			if(PROCESS_IDLE)
				. = "Idle."
			if(PROCESS_MINCE)
				. = "Reclamation process [round(process_timer/timer_length)*100] % complete..."
			if(PROCESS_STRIP)
				. = "In progress..."

	proc/start_mince()
		active_process = PROCESS_MINCE
		timer_length = 15 + rand(-5, 5)
		process_timer = timer_length
		set_lock(1)
		bo(occupant, "<span style='color:red;font-weight:bold'>A whirling blade slowly begins descending upon you!</span>")
		playsound(get_turf(src), 'sound/machines/mixer.ogg', 50, 1)
		SubscribeToProcess()

	proc/start_strip()
		active_process = PROCESS_STRIP
		set_lock(1)
		bo(occupant, "<span class='alert'>Hatches open and tiny, grabby claws emerge!</span>")

		SubscribeToProcess()

	proc/do_mince()
		if (process_timer-- < 1)
			active_process = PROCESS_IDLE
			src.occupant.death(1)
			src.occupant.ghostize()
			qdel(src.occupant)
			DEBUG_MESSAGE("[src].reagents.total_volume on completion of cycle: [src.reagents.total_volume]")

			if (islist(src.pods) && pods.len && src.reagents.total_volume)
				for (var/obj/machinery/clonepod/pod in src.pods)
					src.reagents.trans_to(pod, (src.reagents.total_volume / max(pods.len, 1))) // give an equal amount of reagents to each pod that happens to be around
					DEBUG_MESSAGE("[src].reagents.trans_to([pod] [log_loc(pod)], [src.reagents.total_volume]/[max(pods.len, 1)])")
			process_timer = 0
			active_process = PROCESS_IDLE
			set_lock(0)
			automatic_sequence = 0
			return

		var/mult = src.upgraded ? 2 : 1
		src.reagents.add_reagent("blood", 2 * mult)
		src.reagents.add_reagent("meat_slurry", 2 * mult)
		if (prob(2))
			src.reagents.add_reagent("beff", 1 * mult)

		// Mess with the occupant
		var/damage = round(200 / timer_length) + rand(1, 10)
		src.occupant.TakeDamage(zone="All", brute=damage)
		bleed(occupant, damage * 2, 0)
		if(prob(50))
			playsound(get_turf(src), 'sound/machines/mixer.ogg', 50, 1)
		if(prob(30))
			SPAWN_DBG(0.3 SECONDS)
				playsound(src.loc, pick('sound/impact_sounds/Flesh_Stab_1.ogg', \
									'sound/impact_sounds/Slimy_Hit_3.ogg', \
									'sound/impact_sounds/Slimy_Hit_4.ogg', \
									'sound/impact_sounds/Flesh_Break_1.ogg', \
									'sound/impact_sounds/Flesh_Tear_1.ogg', \
									'sound/impact_sounds/Generic_Snap_1.ogg', \
									'sound/impact_sounds/Generic_Hit_1.ogg'), 100, 5)

	proc/do_strip()
		//Remove one item each cycle
		var/obj/item/to_remove
		if(src.occupant)
			to_remove = occupant.unequip_random()

		if(to_remove)
			if(prob(70))
				bo(occupant, "<span class='alert'>\The arms [pick("snatch", "grab", "steal", "remove", "nick", "blag")] your [to_remove.name]!</span>")
				playsound(get_turf(src), "sound/misc/rustle[rand(1,5)].ogg", 50, 1)
			to_remove.set_loc(src.loc)
		else
			if(automatic_sequence)
				start_mince()
			else
				set_lock(0)
				active_process = PROCESS_IDLE

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("delete")
			if(!src.allowed(usr))
				show_message("You do not have permission to delete records.", "danger")
				return TRUE
			var/selected_record =	find_record(params["ckey"])
			if(selected_record)
				logTheThing("combat", usr, null, "deletes the cloning record [selected_record["fields"]["name"]] for player [selected_record["fields"]["ckey"]] at [log_loc(src)].")
				src.records.Remove(selected_record)
				qdel(selected_record)
				selected_record = null
				show_message("Record deleted.", "danger")
				. = TRUE
		if("scan")
			if(usr == src.scanner.occupant)
				trigger_anti_cheat(usr, "tried to scan themselves using the cloning machine scanner")
				// this doesn't need to return we still want to scan them
			if(!isnull(src.scanner))
				src.scan_mob(src.scanner.occupant)
				. = TRUE
		if("clone")
			var/ckey = params["ckey"]
			if(ckey)
				clone_record(find_record(ckey))
				. = TRUE
		if("toggleGeneticAnalysis")
			if(pod1 && !pod1.attempting)
				pod1.gen_analysis = !pod1.gen_analysis
				. = TRUE
			else
				show_message("Cannot toggle any modules while cloner is active.", "warning")
				. = TRUE
		if("saveToDisk")
			var/ckey = params["ckey"]
			var/selected_record = find_record(ckey)
			if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(selected_record)))
				show_message("Save error.", "warning")
				. = TRUE

			for (var/datum/computer/file/clone/R in src.diskette.root.contents)
				if (R.fields["ckey"] == selected_record["fields"]["ckey"])
					show_message("Record already exists on disk.", "info")
					. = TRUE

			var/datum/computer/file/clone/cloneFile = new
			cloneFile.name = "CloneRecord-[ckey(selected_record["fields"]["name"])]"
			cloneFile.fields = selected_record["fields"]
			if((src.diskette.file_used + cloneFile.size) > src.diskette.file_amount)
				show_message("Disk is full.", "danger")
				return TRUE
			var/saved_status = src.diskette.root.add_file(cloneFile)
			show_message( saved_status ? "Save successful." : "Save error.", saved_status ? "info" : "warning")
			. = TRUE

		if("eject")
			if (!isnull(src.diskette))
				src.diskette.set_loc(src.loc)
				usr.put_in_hand_or_eject(src.diskette) // try to eject it into the users hand, if we can
				src.diskette = null
				. = TRUE
		if("load")
			if (src.diskette.read_only)
				// The file needs to be deleted from the disk after loading the record
				show_message("Load error - cannot transfer clone records from a disk in read only mode.", "warning")
				. = TRUE

			var/loaded = 0

			for(var/datum/computer/file/clone/cloneRecord in src.diskette.root.contents)
				if (!find_record(cloneRecord.fields["ckey"]))
					var/datum/data/record/R = new
					R.fields = cloneRecord.fields
					src.records += R
					loaded++
					show_message("Load successful, [loaded] [loaded > 1 ? "records" : "record"] transferred.", "success")
					src.diskette.root.remove_file(cloneRecord)
					. = TRUE

			if(!loaded)
				show_message("Load error.", "warning")
				. = TRUE
		if("toggleLock")
			if (!isnull(src.scanner))
				if ((!src.scanner.locked) && (src.scanner.occupant))
					src.scanner.locked = 1
					. = TRUE
				else
					src.scanner.locked = 0
					. = TRUE
		if("mindWipeToggle")
			if(!pod1.attempting && src.allow_mind_erasure)
				pod1.mindwipe = !pod1.mindwipe
				. = TRUE
			else
				show_message("Cannot toggle any modules while cloner is active.", "warning")
			. = TRUE


/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()
	var/list/recordsTemp = list()
	data["allowedToDelete"] = src.allowed(user)
	data["scannerGone"] = isnull(src.scanner)
	data["occupantScanned"] = FALSE
	data["podGone"] = isnull(src.pod1)
	if(!isnull(src.pod1))
		data["mindWipe"] = pod1.mindwipe
		data["meatLevels"] = pod1.meat_level
		data["cloneSlave"] = pod1.cloneslave
		data["geneticAnalysis"] = pod1.gen_analysis
		data["completion"] = (!isnull(pod1.occupant) ? clamp(100 - ((pod1.occupant.max_health - pod1.occupant.health) - pod1.heal_level), 0, 100) : 0)
	if(!isnull(src.scanner))
		data["scannerOccupied"] = src.scanner.occupant
		data["scannerLocked"] = src.scanner.locked
		if(!isnull(src.scanner?.occupant?.mind))
			data["occupantScanned"] = !isnull(find_record(ckey(src.scanner.occupant.mind.key)))
	data["message"] = src.currentStatusMessage
	data["disk"] = !isnull(src.diskette)
	if(!isnull(src.diskette))
		data["diskReadOnly"] = src.diskette.read_only
	data["allowMindErasure"] = src.allow_mind_erasure
	data["clonesForCash"] = wagesystem.clones_for_cash
	data["balance"] = src.held_credit


	for (var/r in records)
		var/saved = FALSE
		var/obj/item/implant/health/H = locate(r["fields"]["imp"])
		var/currentHealth = ""
		if ((H) && istype(H))
			currentHealth = H.getHealthList()
		if(src.diskette) // checks if saved to disk
			for (var/datum/computer/file/clone/F in src.diskette.root.contents)
				if(F.fields["ckey"] == r["fields"]["ckey"])
					saved = TRUE

		recordsTemp.Add(list(list(
			name = r["fields"]["name"],
			id = r["fields"]["id"],
			ckey = r["fields"]["ckey"],
			health = currentHealth,
			implant = !isnull(H),
			saved = saved
		)))

	data["cloneRecords"] = recordsTemp

	return data

/obj/machinery/computer/cloning/ui_state(mob/user)
	return tgui_default_state

/obj/machinery/computer/cloning/ui_status(mob/user, datum/ui_state/state)
	return min(
		state.can_use_topic(src, user),
		tgui_broken_state.can_use_topic(src, user),
		tgui_not_incapacitated_state.can_use_topic(src, user)
	)

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", src.name)
		ui.open()

#undef PROCESS_IDLE
#undef PROCESS_STRIP
#undef PROCESS_MINCE
