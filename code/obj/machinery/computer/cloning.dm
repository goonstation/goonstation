//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

/obj/machinery/computer/cloning
	name = "Cloning console"
	desc = "Use this console to operate a cloning scanner and pod. There is a slot to insert modules - they can be removed with a screwdriver."
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	req_access = list(access_heads) //Only used for record deletion right now.
	object_flags = CAN_REPROGRAM_ACCESS
	machine_registry_idx = MACHINES_CLONINGCONSOLES
	var/obj/machinery/clone_scanner/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = "Initializing System..."
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/data/record/active_record = null
	var/obj/item/disk/data/floppy/diskette = null //Mostly so the geneticist can steal somebody's identity while pretending to give them a handy backup profile.
	var/held_credit = 5000 // one free clone

	var/allow_dead_scanning = 0 //Can the dead be scanned in the cloner?
	var/portable = 0 //override new() proc and proximity check, for port-a-clones

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
	SPAWN_DBG(0.7 SECONDS)
		if(portable) return
		src.scanner = locate(/obj/machinery/clone_scanner, orange(2,src))
		src.pod1 = locate(/obj/machinery/clonepod, orange(4,src))

		src.temp = ""
		var/hookup_error = FALSE
		if (isnull(src.scanner))
			src.temp += " <font color=red>SCNR-ERROR</font>"
			hookup_error = TRUE
		if (isnull(src.pod1))
			src.temp += " <font color=red>POD1-ERROR</font>"
			hookup_error = TRUE
		if (!hookup_error)
			src.pod1?.connected = src
			src.scanner?.connected = src

		if (src.temp == "")
			src.temp = "System ready."
		return
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

/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	src.add_dialog(user)
	add_fingerprint(user)

	if(status & (BROKEN|NOPOWER))
		return

	var/dat = {"<h3>Cloning System Control</h3>
	<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>
	<br><tt>[temp]</tt><br><hr>"}

	switch(src.menu)
		if(1) //Scan someone
			dat += "<h4>Scanner Functions</h4>"

			if (isnull(src.scanner))
				dat += "No scanner connected!"
			else
				if (src.scanner.occupant)
					dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [src.scanner.occupant]</a>"
				else
					dat += "Scanner unoccupied"

				dat += "<br>Lock status: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Locked" : "Unlocked"]</a><BR>"

			dat += {"<h4>Cloning Pod Functions</h4>
					<a href='byond://?src=\ref[src];menu=5'>Genetic Analysis Mode</a><br>
					Status: <B>[pod1 && pod1.gen_analysis ? "Enabled" : "Disabled"]</B>
					<h4>Database Functions</h4>
					<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"}
			if (src.diskette)
				dat += {"<a href='byond://?src=\ref[src];disk=load'>Load from disk</a><br>
				<a href='byond://?src=\ref[src];disk=eject'>Eject disk</a><br>"}

			if (pod1 && pod1.BE)
				dat += "<br><b>Gene power module active</b><br>"

			if(src.allow_mind_erasure)
				dat += "<a href='byond://?src=\ref[src];menu=6'>Criminal rehabilitation controls</a>"


		if(2) //Viewing records
			dat += {"<h4>Current records</h4>
					<a href='byond://?src=\ref[src];menu=1'>Back</a><br><br>"}
			for(var/datum/data/record/R in src.records)
				dat += "<a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.fields["id"]]-[R.fields["name"]]</a><br>"

		if(3) //Viewing details of record
			dat += {"<h4>Selected Record</h4>
					<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"}

			if (!src.active_record)
				dat += "<font color=red>ERROR: Record not found.</font>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Delete Record</a></font><br>
						<b>Name:</b> [src.active_record.fields["name"]]<br>"}

				var/obj/item/implant/health/H = locate(src.active_record.fields["imp"])

				if ((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()]<br>"
				else
					dat += "<font color=red>Unable to locate implant.</font><br>"

				if (!isnull(src.diskette))
					dat += {"<a href='byond://?src=\ref[src];save_disk=holder'>Save to disk</a><br>"}
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				if (wagesystem.clones_for_cash)
					dat += "Current machine credit: [src.held_credit]<br>"
				dat += {"<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"}

		if(4) //Deleting a record
			if (!src.active_record)
				src.menu = 2
			dat = {"[src.temp]<br>
					<h4>Confirm Record Deletion</h4>
					<b><a href='byond://?src=\ref[src];del_rec=1'>Yes</a></b><br>
					<b><a href='byond://?src=\ref[src];menu=3'>No</a></b>"}

		if(5) //Advanced genetics analysis
			dat += {"<h4>Advanced Genetic Analysis</h4>
					<a href='byond://?src=\ref[src];menu=1'>Back</a><br>
					<B>Notice:</B> Enabling this feature will prompt the attached clone pod to transfer active genetic mutations from the genetic record to the subject during cloning.
					The cloning process will be slightly slower as a result.<BR><BR>"}

			if(pod1 && !pod1.operating)
				if(pod1.gen_analysis)
					dat += {"Enabled<BR>
							<a href='byond://?src=\ref[src];set_analysis=0'>Disable</A><BR>"}
				else
					dat += {"<a href='byond://?src=\ref[src];set_analysis=1'>Enable</A><BR>
							Disabled<BR>"}
			else
				dat += {"Cannot toggle while cloning pod is active. <BR>
						AGA: <B>[pod1.gen_analysis ? "Enabled" : "Disabled"]</B>"}

		if(6) // Mind erasure controls
			dat += {"<h4>Criminal rehabilitation controls</h4>
					<a href='byond://?src=\ref[src];menu=1'>Back</a><br>
					<B>Notice:</B> Enabling this feature will enable an experimental criminal rehabilitation routine.<BR><B>Human use is specifically forbidden by the space geneva convention.<B><BR>"}
			if(!pod1.operating)
				if(pod1.mindwipe)
					dat += {"Enabled<BR>
							<a href='byond://?src=\ref[src];set_mindwipe=0'>Disable</A><BR>"}
				else
					dat += {"<a href='byond://?src=\ref[src];set_mindwipe=1'>Enable</A><BR>
							Disabled<BR>"}
			else
				dat += {"Cannot toggle while cloning pod is active. <BR>"}

	user.Browse(dat, "window=cloning")
	onclose(user, "cloning")
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if ((href_list["scan"]) && (!isnull(src.scanner)))
		src.scan_mob(src.scanner.occupant)

		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(src.scanner)))
		if ((!src.scanner.locked) && (src.scanner.occupant))
			src.scanner.locked = 1
		else
			src.scanner.locked = 0

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"]) in records
		if ((isnull(src.active_record.fields["ckey"])) || (src.active_record.fields["ckey"] == ""))
			qdel(src.active_record)
			src.active_record = null
			src.temp = "ERROR: Record Corrupt"
		else
			src.menu = 3

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Delete record?"
			src.menu = 4

		else if (src.menu == 4)
			logTheThing("combat", usr, null, "deletes the cloning record [src.active_record.fields["name"]] for player [src.active_record.fields["ckey"]] at [log_loc(src)].")
			src.records.Remove(src.active_record)
			qdel(src.active_record)
			src.active_record = null
			src.temp = "Record deleted."
			src.menu = 2
/*
			var/obj/item/card/id/C = usr.equipped()
			if (istype(C))
				if(src.check_access(C))
					src.records.Remove(src.active_record)
					qdel(src.active_record)
					src.active_record = null
					src.temp = "Record deleted."
					src.menu = 2
				else
					src.temp = "Access Denied."
*/
	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if (src.diskette.read_only)
					// The file needs to be deleted from the disk after loading the record
					src.temp = "Load error - cannot transfer clone records from a disk in read only mode."
					src.updateUsrDialog()
					return

				var/loaded = 0

				for(var/datum/computer/file/clone/cloneRecord in src.diskette.root.contents)
					if (!find_record(cloneRecord.fields["ckey"]))
						var/datum/data/record/R = new
						R.fields = cloneRecord.fields
						src.records += R
						loaded++
						src.temp = "Load successful, [loaded] [loaded > 1 ? "records" : "record"] transferred."
						src.diskette.root.remove_file(cloneRecord)

				if(!loaded)
					src.temp = "Load error."
					src.updateUsrDialog()
					return

			if("eject")
				if (!isnull(src.diskette))
					src.diskette.set_loc(src.loc)
					usr.put_in_hand_or_eject(src.diskette) // try to eject it into the users hand, if we can
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Save error."
			src.updateUsrDialog()
			return

		for (var/datum/computer/file/clone/R in src.diskette.root.contents)
			if (R.fields["ckey"] == src.active_record.fields["ckey"])
				src.temp = "Record already exists on disk."
				src.updateUsrDialog()
				return

		var/datum/computer/file/clone/cloneFile = new
		cloneFile.name = "CloneRecord-[ckey(src.active_record.fields["name"])]"
		cloneFile.fields = src.active_record.fields
		src.temp = src.diskette.root.add_file(cloneFile) ? "Save successful." : "Save error."

	else if (href_list["refresh"])
		src.updateUsrDialog()

	else if (href_list["clone"])
		src.clone_record(locate(href_list["clone"]))

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])
	else if (href_list["set_analysis"])
		pod1.gen_analysis = text2num(href_list["set_analysis"])
		logTheThing("combat", usr, null, "toggles advanced genetic analysis [pod1.gen_analysis ? "on" : "off"] at [log_loc(src)].")
	else if (href_list["set_mindwipe"])
		pod1.mindwipe = text2num(href_list["set_mindwipe"])

	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob)
	if ((isnull(subject)) || (!ishuman(subject)))
		src.temp = "Error: Unable to locate valid genetic data."
		return
	if(!allow_dead_scanning && subject.decomp_stage)
		src.temp = "Error: Failed to read genetic data from subject.<br>Necrosis of tissue has been detected."
		return
	if (!subject.bioHolder || subject.bioHolder.HasEffect("husk"))
		src.temp = "Error: Extreme genetic degredation present."
		return
	if (istype(subject.mutantrace, /datum/mutantrace/kudzu))
		src.temp = "Error: Incompatible cellular structure."
		return
	if (subject.mob_flags & IS_BONER)
		src.temp = "Error: No tissue mass present.<br>Total ossification of subject detected."
		return

	var/datum/mind/subjMind = subject.mind
	if ((!subjMind) || (!subjMind.key))
		if ((subject.ghost && subject.ghost.mind && subject.ghost.mind.key))
			subjMind = subject.ghost.mind
		else if (subject.last_client && find_dead_player("[subject.last_client.ckey]"))
			var/mob/living/carbon/human/virtual/V = find_dead_player("[subject.last_client.ckey]")
			if ((istype(V) && V.isghost) || inafterlifebar(V))
				subjMind = V.mind
			else
				src.temp = "Error: Mental interface failure."
				return
		else
			src.temp = "Error: Mental interface failure."
			return
	if (!isnull(find_record(ckey(subjMind.key))))
		src.temp = "Subject already in database."
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
	src.temp = "Subject successfully scanned."
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
		src.temp = "Invalid or corrupt record."
		return
	if (!src.pod1)
		src.temp = "No cloning pod connected."
		return
	if (src.pod1.occupant)
		src.temp = "Cloning pod in use."
		return
	if (src.pod1.mess)
		src.temp = "Abnormal reading from cloning pod."
		return

	var/mob/selected = find_dead_player("[C.fields["ckey"]]")

	if (!selected)
		src.temp = "Can't clone: Unable to locate mind."
		return

	if (selected.mind && selected.mind.dnr)
		// leave the goddamn dnr ghosts alone
		src.temp = "Cannot clone: Subject has set DNR."
		return
	else
		//for deleting the mob in the afterlife bar if cloning person from there.
		var/mob/ALB_selection = selected
		if (inafterlifebar(ALB_selection))
			boutput(selected, "<span class='notice'>You are being returned to the land of the living!</span>")
			selected = ALB_selection.ghostize()
			qdel(ALB_selection)

	// at this point selected = the dude we wanna revive.

	if (wagesystem.clones_for_cash)
		var/datum/data/record/Ba = FindBankAccountByName(C.fields["name"])
		var/account_credit = 0

		if (Ba && Ba.fields["current_money"])
			account_credit = Ba.fields["current_money"]

		if ((src.held_credit + account_credit) >= wagesystem.clone_cost)
			if (src.pod1.growclone(selected, C.fields["name"], C.fields["mind"], C.fields["holder"], C.fields["abilities"] , C.fields["traits"]))
				var/from_account = min(wagesystem.clone_cost, account_credit)
				if (from_account > 0)
					Ba.fields["current_money"] -= from_account
				src.held_credit -= (wagesystem.clone_cost - from_account)
				src.temp = "Payment of [wagesystem.clone_cost] credits accepted. [from_account > 0 ? "Deducted [from_account] credits from [C.fields["name"]]'s account.' " : ""][from_account < wagesystem.clone_cost ? "Deducted [wagesystem.clone_cost - from_account] credits from machine credit." : ""] Cloning cycle activated."
				src.records.Remove(C)
				qdel(C)
				src.menu = 1
			else
				src.temp = "Unknown error when trying to start cloning process."
		else
			src.temp = "Insufficient funds to begin clone cycle."

	else if (src.pod1.growclone(selected, C.fields["name"], C.fields["mind"], C.fields["holder"], C.fields["abilities"] , C.fields["traits"]))
		src.temp = "Cloning cycle activated."
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

//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key, needbrain=0)
	if (isnull(find_key))
		return

	for(var/mob/M in mobs)
		//Dead people only thanks!
		if (!(isdead(M) || isVRghost(M) || isghostcritter(M) || inafterlifebar(M)) || (!M.client))
			continue
		//They need a brain!
		if (needbrain && ishuman(M) && !M:brain)
			continue

		if (M.ckey == find_key)
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
		connected.scanner = null
		connected = null
		pods = null
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
			O.loc = src.loc

		src.add_fingerprint(usr)

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

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.occupant.set_loc(src.loc)
		src.occupant = null
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


#undef PROCESS_IDLE
#undef PROCESS_STRIP
#undef PROCESS_MINCE
