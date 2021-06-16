/obj/item/device/accessgun
	name = "access-pro"
	desc = "This device can reprogram electronic access requirements. It will copy the permissions of any inserted ID. Activate it in-hand while empty to change between AND/OR modes"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "accessgun"
	item_state = "accessgun"
	w_class = W_CLASS_SMALL
	rand_pos = 0
	flags = FPRINT | TABLEPASS | ONBELT
	mats = 14
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
			if ("id" || "id_civ")
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
			boutput(user, "<span class='notice'>You eject [ID_card] from [src].</span>")
		else
			if (mode == 0)
				boutput(user, "<span class='notice'>[src] set to OR mode. The doors you reprogram will allow anyone with any of the accesses on the inserted ID.</span>")
				mode = 1
			else
				boutput(user, "<span class='notice'>[src] set to AND mode. The doors you reprogram will only allow those who meet every access listed on the inserted ID.</span>")
				mode = 0


		src.eject_id_card(user)

	attackby(obj/item/C as obj, mob/user as mob)
		if (istype(C, /obj/item/card/id))
			var/obj/item/card/id/ID = C
			if (src.ID_card)
				boutput(user, "<span class='notice'>You swap [ID] and [src.ID_card].</span>")
				src.eject_id_card(user)
				src.insert_id_card(ID, user)
				return
			else if (!src.ID_card)
				src.insert_id_card(ID, user)
				boutput(user, "<span class='notice'>You insert [ID] into [src].</span>")
		else
			..()

	afterattack(atom/target, mob/user, reach, params)
		..()
		if (!src.ID_card)
			playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
			boutput(user, "<span class='notice'>[src] refuses to turn on without an ID inserted.</span>")
			return
		if (!isobj(target))
			playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
			boutput(user, "<span class='notice'>[src] can't reprogram this.</span>")
			return

		if (!allowed(user))
			playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
			boutput(user, "<span class='notice'>Your worn ID fails [src]'s check!</span>")
			return

		var/obj/O = target

		if (access_maxsec in O.req_access)
			playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
			boutput(user, "<span class='notice'>[src] can't reprogram this.</span>")
			return

		if (O.object_flags & CAN_REPROGRAM_ACCESS)
			if (istype(target,/obj/machinery/door))
				var/obj/machinery/door/D = target
				if (D.cant_emag || isrestrictedz(D.z))
					playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
					boutput(user, "<span class='notice'>[src] can't reprogram this.</span>")
					return

			actions.start(new/datum/action/bar/icon/access_reprog(O,src), user)
		else
			playsound(get_turf(src), 'sound/machines/airlock_deny.ogg', 35, 1, 0, 2)
			boutput(user, "<span class='notice'>[src] can't reprogram this.</span>")



	proc/reprogram(var/obj/O,var/mob/user)
		if (!mode)
			O.set_access_list(list(ID_card.access))
		else
			O.set_access_list(ID_card.access)
		playsound(get_turf(src), "sound/machines/reprog.ogg", 70, 1)


/datum/action/bar/icon/access_reprog
	duration = 90
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "access_reprog"
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
		if(get_dist(owner, O) > 1 || O == null || owner == null || A == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(get_dist(owner, O) > 1 || O == null || owner == null || A == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(get_dist(owner, O) > 1 || O == null || owner == null || A == null)
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
			boutput(owner, "<span class='alert'>Access change of [O] interrupted!</span>")
		..()
