/obj/item/clothing/lanyard
	name = "lanyard"
	desc = "Only dorks wear these."
	icon = 'icons/obj/clothing/item_lanyards.dmi'
	wear_image_icon = 'icons/mob/lanyards.dmi'
	icon_state = "blue"
	var/obj/item/card/id/ID_card = null
	var/registered = null

	New()
		..()
		AddComponent(/datum/component/storage)

	attackby(obj/item/W, mob/user, params)
		..()
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/ID = W
			src.registered = ID.registered

	attack_self(mob/user)
		attack_hand(user)
		..()

/datum/component/storage
	var/datum/hud/storage/hud
	var/list/can_hold
	var/in_list_or_max = 0
	var/max_wclass = 2
	var/slots = 7
	var/sneaky = 0
	var/does_not_open_in_pocket = 1

/datum/component/storage/Initialize(var/list/spawn_contents, var/list/can_hold, var/in_list_or_max, var/max_wclass, var/slots, var/sneaky, var/does_not_open_in_pocket)
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ATTACK_BY), .proc/attack_by)
	RegisterSignal(parent, list(COMSIG_ATOM_ATTACK_HAND), .proc/attack_hand)
	RegisterSignal(parent, list(COMSIG_ATOM_MOUSE_DROP), .proc/mouse_drop)
	RegisterSignal(parent, list(COMSIG_OBJ_MOVE_TRIGGER), .proc/move_trigger)
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/attack_self)
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/attack)
	RegisterSignal(parent, list(COMSIG_ITEM_AFTER_ATTACK), .proc/after_attack)
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), .proc/on_dropped)
	RegisterSignal(parent, list(COMSIG_MOVABLE_EMP_ACT), .proc/emp_act)
	src.hud = new(src)
	src.can_hold = can_hold
	src.in_list_or_max = in_list_or_max
	src.max_wclass = max_wclass
	src.slots = slots
	src.sneaky = sneaky
	src.does_not_open_in_pocket = does_not_open_in_pocket
	//SPAWN_DBG(1 DECI SECOND)
	if (spawn_contents)
		src.make_my_stuff(spawn_contents)

/datum/component/storage/disposing()
	if (hud)
		for (var/mob/M in hud.mobs)
			if (M.s_active == src)
				M.s_active = null
		qdel(hud)
		hud = null
	..()

/datum/component/storage/proc/attack_by(obj/source, obj/item/W, mob/user)
	if (W.cant_drop)
		return
	if (islist(src.can_hold) && src.can_hold.len)
		var/ok = 0
		if (src.in_list_or_max && W.w_class <= src.max_wclass)
			ok = 1
		else
			for (var/A in src.can_hold)
				if (ispath(A) && istype(W, A))
					ok = 1
		if (!ok)
			boutput(user, "<span class='alert'>[src.parent] cannot hold [W].</span>")
			return

	else if (W.w_class > src.max_wclass)
		boutput(user, "<span class='alert'>[W] won't fit into [src.parent]!</span>")
		return

	var/list/my_contents = src.GetComponent(/datum/component/storage)?.get_contents()
	if (my_contents.len >= slots)
		boutput(usr, "<span class='alert'>[src.parent] is full!</span>")
		return 0
	var/atom/movable/AM = src.parent
	var/atom/checkloc = AM.loc
	while (checkloc && !isturf(AM.loc))
		if (checkloc == W)
			return
		checkloc = checkloc.loc

	user.u_equip(W)
	W.dropped(user)
	src.add_contents(W)
	hud.add_item(W)

	AM.add_fingerprint(user)
	animate_storage_rustle(AM)
	if (!src.sneaky && !istype(W, /obj/item/gun/energy/crossbow))
		user.visible_message("<span class='notice'>[user] has added [W] to [src.parent]!</span>", "<span class='notice'>You have added [W] to [src.parent].</span>")
	playsound(AM.loc, "rustle", 50, 1, -5)

/datum/component/storage/proc/attack_hand(obj/source, mob/user)
	var/atom/movable/AM = src.parent
	if (!src.sneaky)
		playsound(AM.loc, "rustle", 50, 1, -2)
	if (AM.loc == user && (!does_not_open_in_pocket || AM == user.l_hand || AM == user.r_hand))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs)
				if ((AM == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || (AM == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
					return
		if (user.s_active)
			user.detach_hud(user.s_active)
			user.s_active = null
		if (src.mousetrap_check(user))
			return
		user.s_active = src.hud
		hud.update()
		user.attach_hud(src.hud)
		AM.add_fingerprint(user)
		animate_storage_rustle(AM)
	else
		for (var/mob/M in src.hud.mobs)
			if (M != user)
				M.detach_hud(src.hud)
		src.hud.update()

/datum/component/storage/proc/mouse_drop(atom/over_object)
	var/obj/screen/hud/S = over_object
	var/atom/movable/AM = src.parent
	if (istype(S))
		playsound(AM.loc, "rustle", 50, 1, -5)
		if (!usr.restrained() && !usr.stat && AM.loc == usr)
			if (S.id == "rhand")
				if (!usr.r_hand)
					usr.u_equip(src)
					usr.put_in_hand(src, 0)
			else
				if (S.id == "lhand")
					if (!usr.l_hand)
						usr.u_equip(src)
						usr.put_in_hand(src, 1)
			return
	if (over_object == usr && in_range(src, usr) && isliving(usr) && !usr.stat)
		if (usr.s_active)
			usr.detach_hud(usr.s_active)
			usr.s_active = null
		if (src.mousetrap_check(usr))
			return
		usr.s_active = src.hud
		hud.update()
		usr.attach_hud(src.hud)
		return
	if (usr.is_in_hands(src))
		var/turf/T = over_object
		if (istype(T, /obj/table))
			T = get_turf(T)
		if (!(usr in range(1, T)))
			return
		if (istype(T))
			for (var/obj/O in T)
				if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
					return
			if (!T.density)
				usr.visible_message("<span class='alert'>[usr] dumps the contents of [src] onto [T]!</span>")
				for (var/obj/item/I in src)
					I.set_loc(T)
					I.layer = initial(I.layer)
					if (istype(I, /obj/item/mousetrap))
						var/obj/item/mousetrap/MT = I
						if (MT.armed)
							MT.visible_message("<span class='alert'>[MT] triggers as it falls on the ground!</span>")
							MT.triggered(usr, null)
					else if (istype(I, /obj/item/mine))
						var/obj/item/mine/M = I
						if (M.armed && M.used_up != 1)
							M.visible_message("<span class='alert'>[M] triggers as it falls on the ground!</span>")
							M.triggered(usr)
					hud.remove_item(I)

/datum/component/storage/proc/move_trigger(var/mob/M, kindof)
	var/atom/movable/AM = src.parent
	for (var/obj/O in AM.contents)
		if (O.move_triggered)
			O.move_trigger(M, kindof)

/datum/component/storage/proc/attack_self(mob/user)
	var/atom/movable/AM = src.parent
	AM.attack_hand(user)

/datum/component/storage/proc/attack(mob/M as mob, mob/user as mob)
	if (surgeryCheck(M, user))
		insertChestItem(M, user)
		return

/datum/component/storage/proc/after_attack(obj/O as obj, mob/user as mob)
	var/atom/movable/AM = src.parent
	if (O in AM.contents)
		user.drop_item()
		SPAWN_DBG(1 DECI SECOND)
			O.attack_hand(user)

/datum/component/storage/proc/on_dropped(mob/user as mob)
	if (hud)
		hud.update()

/datum/component/storage/proc/emp_act()
	var/atom/movable/AM = src.parent
	if (AM.contents.len)
		for (var/atom/A in AM.contents)
			if (isitem(A))
				var/obj/item/I = A
				I.emp_act()
				SEND_SIGNAL(I, COMSIG_MOVABLE_EMP_ACT)
	return

/datum/component/storage/proc/add_contents(obj/item/I)
	I.set_loc(src.parent)

/datum/component/storage/proc/get_contents()
	RETURN_TYPE(/list)
	var/atom/movable/AM = src.parent
	var/list/cont = AM.contents.Copy()
	for(var/atom/A in cont)
		if(!istype(A, /obj/item) || istype(A, /obj/item/grab))
			cont.Remove(A)
	return cont

/datum/component/storage/proc/get_all_contents()
	var/list/L = list()
	L += get_contents()
	for (var/obj/item/storage/S in get_contents())
		L += S.GetComponent(/datum/component/storage)?.get_all_contents()
	return L

/datum/component/storage/proc/make_my_stuff(list/spawn_contents) // use this rather than overriding the container's New()
	for (var/thing in spawn_contents)
		var/amt = 1
		if (!ispath(thing))
			continue
		if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
			amt = abs(spawn_contents[thing])
		for (amt, amt>0, amt--)
			new thing(src.parent)
	return 1

/datum/component/storage/proc/mousetrap_check(mob/user)
	var/atom/movable/AM = src.parent
	if (!ishuman(user) || user.stat)
		return
	for (var/obj/item/mousetrap/MT in AM.contents)
		if (MT.armed)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a mousetrap!</B></span>",\
			"<span class='alert'><B>You reach into [src.parent], but there was a live mousetrap in there!</B></span>")
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			. = 1
	for (var/obj/item/mine/M in AM.contents)
		if (M.armed && M.used_up != 1)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a [M]!</B></span>",\
			"<span class='alert'><B>You reach into [src.parent], but there was a live [M] in there!</B></span>")
			M.triggered(user)
			. = 1
