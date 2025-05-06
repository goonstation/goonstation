#define ACCESSGUN_MODE_ALL 0
#define ACCESSGUN_MODE_ANY 1

TYPEINFO(/obj/item/device/accessgun)
	mats = 14

/obj/item/device/accessgun
	name = "Access Pro"
	desc = "This device can reprogram electronic access requirements. Activate it in-hand to configure."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "accessgun"
	item_state = "accessgun"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	c_flags = ONBELT
	req_access = list(access_change_ids,access_engineering_chief)

	///Can only target doors?
	var/doors_only = FALSE
	///Can target objects that already have an access
	var/allow_replace_access = TRUE
	///Will target door need ALL accesses selected, or ANY of them.
	var/mode = ACCESSGUN_MODE_ANY
	///Currently stored list of accesses that will be set on the target
	var/list/selected_accesses = list()
	//Below stolen from ID computer, can definitely be done better (datumised access???)
	var/list/civilian_access_list = list(access_morgue, access_maint_tunnels, access_chapel_office, access_tech_storage, access_bar, access_janitor, access_crematorium, access_kitchen, access_hydro, access_ranch)
	var/list/engineering_access_list = list(access_engineering, access_engineering_storage, access_engineering_power, access_engineering_engine, access_engineering_mechanic, access_engineering_atmos, access_engineering_control)
	var/list/supply_access_list = list(access_cargo, access_supply_console, access_mining, access_mining_outpost)
	var/list/research_access_list = list(access_tox, access_tox_storage, access_research, access_chemistry, access_researchfoyer, access_artlab, access_telesci, access_robotdepot)
	var/list/medical_access_list = list(access_medical, access_medical_lockers, access_medlab, access_robotics, access_pathology)
	var/list/security_access_list = list(access_security, access_brig, access_forensics_lockers, access_securitylockers, access_carrypermit, access_contrabandpermit, access_ticket)
	var/list/command_access_list = list(access_research_director, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_engineering_chief, access_medical_director, access_head_of_personnel, access_dwaine_superuser, access_money)
	var/list/allowed_access_list

	New()
		. = ..()
		src.allowed_access_list = src.command_access_list + src.security_access_list + src.medical_access_list + src.research_access_list + src.supply_access_list + src.engineering_access_list + src.civilian_access_list

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "AccessPro", src.name)
			ui.open()

	ui_static_data()
		. = list()

		var/list/civilian_access = list()
		var/list/engineering_access = list()
		var/list/supply_access = list()
		var/list/research_access = list()
		var/list/medical_access = list()
		var/list/security_access = list()
		var/list/command_access = list()

		for(var/A in access_name_lookup)
			if (access_name_lookup[A] in civilian_access_list)
				civilian_access.Add(access_data(A))
			if (access_name_lookup[A] in engineering_access_list)
				engineering_access.Add(access_data(A))
			if (access_name_lookup[A] in supply_access_list)
				supply_access.Add(access_data(A))
			if (access_name_lookup[A] in research_access_list)
				research_access.Add(access_data(A))
			if (access_name_lookup[A] in medical_access_list)
				medical_access.Add(access_data(A))
			if (access_name_lookup[A] in security_access_list)
				security_access.Add(access_data(A))
			if (access_name_lookup[A] in command_access_list)
				command_access.Add(access_data(A))

		.["accesses_by_area"] = list(
			list(name = "Civilian", color = "civilian", accesses = civilian_access),
			list(name = "Engineering", color = "engineering", accesses = engineering_access),
			list(name = "Supply", color = "engineering", accesses = supply_access),
			list(name = "Science", color = "research", accesses = research_access),
			list(name = "Medical", color = "medical", accesses = medical_access),
			list(name = "Security", color = "security", accesses = security_access),
			list(name = "Command", color = "command", accesses = command_access),
		)

	proc/access_data(var/A)
		. = list(list(
			name = A,
			id = access_name_lookup[A]
		))

	ui_data(mob/user)
		. = list()
		.["selected_accesses"] = src.selected_accesses
		.["mode"] = src.mode

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return

		switch(action)
			if("access")
				var/access_type = text2num_safe(params["access"])
				var/access_allowed = text2num_safe(params["allowed"])
				if(access_type in src.allowed_access_list)
					if(!access_allowed)
						src.selected_accesses -= access_type
					else
						src.selected_accesses += access_type
			if("change_mode")
				if(src.mode == ACCESSGUN_MODE_ALL)
					src.mode = ACCESSGUN_MODE_ANY
				else if(src.mode == ACCESSGUN_MODE_ANY)
					src.mode = ACCESSGUN_MODE_ALL
		tgui_process.update_uis(src)
		. = TRUE

	attack_self(mob/user as mob)
		ui_interact(user)

	afterattack(atom/target, mob/user, reach, params)
		..()
		if (!src.selected_accesses || !length(src.selected_accesses))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("You need to configure [src]."))
			return
		if (!isobj(target))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] can't reprogram this."))
			return

		if (!allowed(user))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("Your worn ID fails [src]'s check!"))
			return

		var/obj/O = target

		if (O.has_access_requirements() && !src.allow_replace_access)
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] can only program objects with no access."))
			return

		if ((access_maxsec in O.req_access) || (access_armory in O.req_access))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] can't reprogram this."))
			return

		if (is_restricted(O, user))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] can't reprogram this."))
			return

		actions.start(new/datum/action/bar/icon/access_reprog(O,src), user)

	proc/is_restricted(obj/O)
		. = FALSE
		if(src.doors_only && !(istype(O, /obj/machinery/door)))
			return TRUE
		if (!(O.object_flags & CAN_REPROGRAM_ACCESS))
			. = TRUE
			return
		if (istype(O,/obj/machinery/door))
			var/obj/machinery/door/D = O
			if (D.cant_emag || isrestrictedz(D.z))
				. = TRUE

	proc/reprogram(var/obj/O,var/mob/user)
		var/str_contents = jointext(src.selected_accesses, ", ")
		if (mode == ACCESSGUN_MODE_ALL)
			O.set_access_list(list(src.selected_accesses))
		else
			O.set_access_list(src.selected_accesses)
		logTheThing(LOG_STATION, user, "reprograms door access on [constructName(O)] [log_loc(O)] to [str_contents] [mode ? "(AND mode)" : "(OR mode)"]")
		playsound(src, 'sound/machines/reprog.ogg', 70, TRUE)


/datum/action/bar/icon/access_reprog
	duration = 90
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/ui/actions.dmi'
	icon_state = "reprog"
	var/obj/O
	var/obj/item/device/accessgun/A
	New(Obj,AccessGun)
		O = Obj
		A = AccessGun
		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, O) > 0 || O == null || owner == null || A == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, O) > 0 || O == null || owner == null || A == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, O) > 0 || O == null || owner == null || A == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ismob(owner))
			var/mob/M = owner
			if (!(A in M.equipped_list()))
				interrupt(INTERRUPT_ALWAYS)
				return
		A.reprogram(O,owner)

	onInterrupt()
		if (O && owner)
			boutput(owner, SPAN_ALERT("Access change of [O] interrupted!"))
		..()

/obj/item/device/accessgun/lite
	name = "Access Lite"
	desc = "A device that sets the access requirements of newly built airlocks. Has less available accesses than an Access PRO"
	req_access = null
	doors_only = TRUE
	allow_replace_access = FALSE
	// stock civilian_access_list
	// stock engineering_access_list
	supply_access_list = list(access_cargo, access_mining)
	research_access_list = list(access_tox, access_research, access_chemistry, access_researchfoyer, access_artlab, access_telesci, access_robotdepot)
	medical_access_list = list(access_medical, access_medlab, access_robotics)
	security_access_list = list(access_security, access_brig)
	command_access_list = list(access_heads)

#undef ACCESSGUN_MODE_ALL
#undef ACCESSGUN_MODE_ANY
