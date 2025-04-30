TYPEINFO(/obj/item/device/accessgun)
	mats = 14

/obj/item/device/accessgun
	name = "Access Pro"
	desc = "This device can reprogram electronic access requirements. It will copy the permissions of any inserted ID. Activate it in-hand while empty to change between AND/OR modes"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "accessgun"
	item_state = "accessgun"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	c_flags = ONBELT
	var/obj/item/card/id/ID_card = null
	req_access = list(access_change_ids,access_engineering_chief)
	var/mode = 0 //0 AND, 1 OR

	proc/eject_id_card(var/mob/user as mob)
		if (src.ID_card)
			if (istype(user))
				user.put_in_hand_or_drop(src.ID_card)
			else
				var/turf/T = get_turf(src)
				src.ID_card.set_loc(T)
			src.ID_card = null
			src.icon_state = "accessgun"

	proc/insert_id_card(var/obj/item/card/id/ID as obj, var/mob/user as mob)
		if (!istype(ID))
			return
		if (src.ID_card)
			src.eject_id_card(istype(user) ? user : null)
		src.ID_card = ID
		if (user)
			user.u_equip(ID)
		ID.set_loc(src)

		switch(ID.icon_state)
			if ("id", "id_civ")
				icon_state = "accessgun-civ"
			if ("id_sec")
				icon_state = "accessgun-sec"
			if ("id_com")
				icon_state = "accessgun-com"
			if ("id_res")
				icon_state = "accessgun-res"
			if ("id_eng")
				icon_state = "accessgun-eng"
			if ("id_clown")
				icon_state = "accessgun-clown"
			else
				icon_state = "accessgun-?"

		if (!ID.access)
			icon_state = "accessgun-null"
		else
			var/has_any = 0
			for (var/acc in ID.access)
				has_any = 1
				break
			if (!has_any)
				icon_state = "accessgun-null"

	attack_self(mob/user as mob)
		..()
		if (src.ID_card)
			boutput(user, SPAN_NOTICE("You eject [ID_card] from [src]."))
		else
			if (mode == 0)
				boutput(user, SPAN_NOTICE("[src] set to OR mode. The doors you reprogram will allow anyone with any of the accesses on the inserted ID."))
				mode = 1
			else
				boutput(user, SPAN_NOTICE("[src] set to AND mode. The doors you reprogram will only allow those who meet every access listed on the inserted ID."))
				mode = 0


		src.eject_id_card(user)

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/card/id))
			var/obj/item/card/id/ID = C
			if (src.ID_card)
				boutput(user, SPAN_NOTICE("You swap [ID] and [src.ID_card]."))
				src.eject_id_card(user)
				src.insert_id_card(ID, user)
				return
			else if (!src.ID_card)
				src.insert_id_card(ID, user)
				boutput(user, SPAN_NOTICE("You insert [ID] into [src]."))
		else
			..()

	afterattack(atom/target, mob/user, reach, params)
		..()
		if (!src.ID_card)
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] refuses to turn on without an ID inserted."))
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
		if (!(O.object_flags & CAN_REPROGRAM_ACCESS))
			. = TRUE
			return
		if (istype(O,/obj/machinery/door))
			var/obj/machinery/door/D = O
			if (D.cant_emag || isrestrictedz(D.z))
				. = TRUE


	proc/reprogram(var/obj/O,var/mob/user)
		var/str_contents = jointext(ID_card.access, ", ")
		if (!mode)
			O.set_access_list(list(ID_card.access))
		else
			O.set_access_list(ID_card.access)
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
	desc = "A device that sets the access requirements of newly constructed airlocks to ones scanned from an existing airlock."
	req_access = null
	ID_card = 1
	var/list/scanned_access = null

	New()
		scanned_access = list()
		req_access = list()
		. = ..()

	afterattack(obj/target, mob/user, reach, params)
		var/obj/machinery/door/airlock/door_reqs = target
		if (!istype(door_reqs))
			. = ..()
			return
		if(target.deconstruct_flags & DECON_BUILT)
			if (isnull(scanned_access))
				playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
				boutput(user, SPAN_NOTICE("[src] has no access requirements loaded."))
				return
			if (length(door_reqs.req_access))
				playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
				boutput(user, SPAN_NOTICE("[src] cannot reprogram [door_reqs.name], access requirements already set."))
				return
			. = ..()
			return
		if(is_restricted(door_reqs))
			playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 2)
			boutput(user, SPAN_NOTICE("[src] can't scan [door_reqs.name]"))
			return
		scanned_access = door_reqs.req_access
		icon_state = "accessgun-x"
		boutput(user, SPAN_NOTICE("[src] scans the access requirements of [door_reqs.name]."))


	reprogram(obj/O,mob/user)
		if (!isnull(scanned_access))
			O.set_access_list(scanned_access)
		playsound(src, 'sound/machines/reprog.ogg', 70, TRUE)

	attackby(obj/item/C, mob/user)
		if (istype(C, /obj/item/card/id))
			return
		. = ..()

	attack_self(mob/user as mob)
		boutput(user, SPAN_NOTICE("You clear the access requirements loaded in the [src]"))
		scanned_access = null
		icon_state = initial(icon_state)
