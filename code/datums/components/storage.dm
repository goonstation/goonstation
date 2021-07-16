// STORAGE COMPONENT
// example:
// /obj/item/storage/backpack/monkey
//	 spawn_contents = list(/obj/item/toy/plush/small/monkey)
//	 New()
//		 ..()
//		 AddComponent(/datum/component/storage, max_wclass = 4)
// since /obj/item/storage already calls AddComponent with spawn_contents = spawn_contents, we don't need to specify that arg again. we just need to respecify our unique max_wclass of 4, or else it'll be set as /obj/item/storage/backpack's 3!

/datum/component/storage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // old component gets passed new component's initialization args
	var/datum/hud/storage/hud
	// future: add stored_contents list and use that to keep track instead of source.contents
	var/list/can_hold // if this exists, the storage checks it for what can be held
	var/in_list_or_max = FALSE // if this is true, the storage allows items that are either in its can_hold list or items that have a lesser w_class than max_wclass
	var/max_wclass = 2
	var/slots = 7
	var/sneaky = FALSE // does it play a sound when used?
	var/does_not_open_in_pocket = TRUE

/datum/component/storage/Initialize(var/list/spawn_contents, var/list/can_hold, var/in_list_or_max = FALSE, var/max_wclass = 2, var/slots = 7, var/sneaky = FALSE, var/does_not_open_in_pocket = TRUE)
	if (!isobj(parent)) // future: allow all movable atoms
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ATTACKBY), .proc/attack_by)
	RegisterSignal(parent, list(COMSIG_ATOM_HAND_ATTACK), .proc/hand_attack)
	RegisterSignal(parent, list(COMSIG_ATOM_MOUSE_DROP), .proc/mouse_drop)
	RegisterSignal(parent, list(COMSIG_OBJ_MOVE_TRIGGER), .proc/move_trigger)
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/attack_self)
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/attack)
	RegisterSignal(parent, list(COMSIG_ITEM_AFTER_ATTACK), .proc/after_attack)
	RegisterSignal(parent, list(COMSIG_ITEM_DROPPED), .proc/on_dropped)
	RegisterSignal(parent, list(COMSIG_ITEM_BUILD_TOOLTIP), .proc/build_tooltip)
	RegisterSignal(parent, list(COMSIG_STORAGE_GET_CONTENTS), .proc/get_contents)
	RegisterSignal(parent, list(COMSIG_STORAGE_GET_ALL_CONTENTS), .proc/get_all_contents)
	RegisterSignal(parent, list(COMSIG_STORAGE_FIND_TYPE), .proc/find_type)
	RegisterSignal(parent, list(COMSIG_STORAGE_TRANSFER_ITEM), .proc/transfer_item)
	RegisterSignal(parent, list(COMSIG_STORAGE_CAN_FIT), .proc/can_fit)
	RegisterSignal(parent, list(COMSIG_MOVABLE_EMP_ACT), .proc/emp_act)
	hud = new(src)
	src.can_hold = can_hold
	src.in_list_or_max = in_list_or_max
	src.max_wclass = max_wclass
	src.slots = slots
	src.sneaky = sneaky
	src.does_not_open_in_pocket = does_not_open_in_pocket
	if (spawn_contents)
		make_my_stuff(spawn_contents)

// since we have COMPONENT_DUPE_UNIQUE_PASSARGS, which means the old component gets passed the new component's initialization args, we should always get SC = null, original = TRUE (since new component doesn't get passed)
// we should only get passed the other args (the new component's initialization args), if applicable
/datum/component/storage/InheritComponent(datum/component/storage/SC, original, var/list/spawn_contents, var/list/can_hold, var/list/can_also_hold, var/in_list_or_max, var/max_wclass, var/slots, var/sneaky, var/does_not_open_in_pocket)
	if (spawn_contents)
		make_my_stuff(spawn_contents)
	if (can_hold)
		src.can_hold = can_hold
	if (can_also_hold)
		src.can_hold |= can_also_hold
	if (!isnull(in_list_or_max))
		src.in_list_or_max = in_list_or_max
	if (max_wclass)
		src.max_wclass = max_wclass
	if (slots)
		src.slots = slots
	if (!isnull(sneaky))
		src.sneaky = sneaky
	if (!isnull(does_not_open_in_pocket))
		src.does_not_open_in_pocket = does_not_open_in_pocket

/datum/component/storage/disposing()
	if (hud)
		for (var/mob/M in hud.mobs)
			if (M.s_active == src)
				M.s_active = null
		qdel(hud)
		hud = null
	..()

// source attacked with I by user
/datum/component/storage/proc/attack_by(atom/source, obj/item/I, mob/user)
	if (I.cant_drop)
		return
	if (islist(src.can_hold) && src.can_hold.len)
		var/ok = 0
		if (src.in_list_or_max && I.w_class <= src.max_wclass)
			ok = 1
		else
			for (var/A in src.can_hold)
				if (ispath(A) && istype(I, A))
					ok = 1
		if (!ok)
			boutput(user, "<span class='alert'>[source] cannot hold [I].</span>")
			return

	else if (I.w_class > src.max_wclass)
		boutput(user, "<span class='alert'>[I] won't fit into [source]!</span>")
		return

	if (get_contents_len(source) >= slots)
		boutput(usr, "<span class='alert'>[source] is full!</span>")
		return
	var/atom/checkloc = source.loc
	while (checkloc && !isturf(source.loc))
		if (checkloc == I)
			return
		checkloc = checkloc.loc

	src.add_item(source, I, user)

	source.add_fingerprint(user)
	animate_storage_rustle(source)
	if (!src.sneaky && !istype(I, /obj/item/gun/energy/crossbow))
		user.visible_message("<span class='notice'>[user] has added [I] to [source]!</span>", "<span class='notice'>You have added [I] to [source].</span>")
	playsound(source.loc, "rustle", 50, 1, -5)
	return RETURN_EARLY

// source attacked by user with an empty hand
/datum/component/storage/proc/hand_attack(source, mob/user)
	return src.handle_storage(user)

// source click dragged to over_object (can be HUD, usr, or turf)
/datum/component/storage/proc/mouse_drop(atom/source, atom/over_object)
	var/atom/movable/screen/hud/S = over_object
	if (istype(S)) // click drag storage from one HUD slot to another
		playsound(source.loc, "rustle", 50, 1, -5)
		if (!usr.restrained() && !usr.stat && source.loc == usr)
			if (S.id == "rhand")
				if (!usr.r_hand)
					usr.u_equip(source)
					usr.put_in_hand(source, 0)
			else
				if (S.id == "lhand")
					if (!usr.l_hand)
						usr.u_equip(source)
						usr.put_in_hand(source, 1)
			return
	if (over_object == usr && IN_RANGE(source, usr , 1) && isliving(usr) && !usr.stat) // click drag storage to mob to open it
		if (usr.s_active)
			usr.detach_hud(usr.s_active)
			usr.s_active = null
		if (src.mousetrap_check(usr))
			return
		usr.s_active = hud
		hud.update()
		usr.attach_hud(hud)
		return
	if (usr.is_in_hands(source)) // click drag storage to some other atom
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
				usr.visible_message("<span class='alert'>[usr] dumps the contents of [source] onto [T]!</span>")
				for (var/obj/item/I in source.contents)
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

/datum/component/storage/proc/move_trigger(atom/source, mob/user, kindof)
	for (var/obj/O in source.contents)
		if (O.move_triggered)
			O.move_trigger(user, kindof)

// user uses source, which is in their active hand
/datum/component/storage/proc/attack_self(source, mob/user)
	src.handle_storage(user)

// user attacks M with source
/datum/component/storage/proc/attack(source, mob/M, mob/user)
	if (surgeryCheck(M, user))
		insertChestItem(M, user)
		return

// after user attacks O with source
/datum/component/storage/proc/after_attack(atom/source, obj/O, mob/user)
	if (O in source.contents)
		user.drop_item()
		SPAWN_DBG(1 DECI SECOND)
			O.attack_hand(user)

// after source is dropped, also used as convenience hud update function
/datum/component/storage/proc/on_dropped()
	if (hud)
		hud.update()

// add text to passed tooltip desc
/datum/component/storage/proc/build_tooltip(atom/source, list/desc)
	desc += "<br>Holding [get_contents_len(source)]/[slots] objects"

// get contents; filter for items and out for grabs
/datum/component/storage/proc/get_contents(atom/source, list/cont)
	for (var/obj/item/I in source.contents)
		if(!istype(I, /obj/item/grab))
			cont += I

/datum/component/storage/proc/get_all_contents(atom/source, list/cont)
	var/list/C = list()
	src.get_contents(source, C)
	cont += C
	for (var/obj/item/I in C)
		var/list/cont2 = list()
		SEND_SIGNAL(I, COMSIG_STORAGE_GET_CONTENTS, cont2)
		cont += cont2

// find a certain type in contents
/datum/component/storage/proc/find_type(atom/source, item_type, list/found)
	for (var/A in source.contents)
		if (istype(A, item_type))
			found += A
			return RETURN_SUCCESS

// transfer I to target (if provided) and remove it from source contents and hud
/datum/component/storage/proc/transfer_item(atom/source, obj/item/I, var/target)
	if (target)
		I.set_loc(target)
	source.contents -= I
	hud.remove_item(I)
	return RETURN_SUCCESS

/datum/component/storage/proc/can_fit(source, obj/item/I)
	if (src.max_wclass <= I.w_class)
		return RETURN_FAILURE
	return RETURN_SUCCESS

/datum/component/storage/proc/emp_act(atom/source)
	if (source.contents.len)
		for (var/atom/A in source.contents)
			if (isitem(A))
				var/obj/item/I = A
				I.emp_act()
				SEND_SIGNAL(I, COMSIG_MOVABLE_EMP_ACT)
	return

// convenience function
/datum/component/storage/proc/get_contents_len(atom/source)
	var/items = 0
	for (var/obj/item/I in source.contents)
		if(!istype(I, /obj/item/grab))
			items++
	return items

// let user add I to source; does not have checks and should be internal
/datum/component/storage/proc/add_item(atom/source, obj/item/I, mob/user)
	user.u_equip(I)
	I.dropped(user)
	I.set_loc(source)
	hud.add_item(I)
	return RETURN_SUCCESS

// handles user opening the source and displaying the hud
/datum/component/storage/proc/handle_storage(mob/user)
	var/atom/A = src.parent
	if (!src.sneaky)
		playsound(A.loc, "rustle", 50, 1, -2)
	if (A.loc == user && (!src.does_not_open_in_pocket || A == user.l_hand || A == user.r_hand))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs)
				if ((A == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || (A == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
					return
		if (user.s_active)
			user.detach_hud(user.s_active)
			user.s_active = null
		if (src.mousetrap_check(user))
			return
		user.s_active = hud
		hud.update()
		user.attach_hud(hud)
		A.add_fingerprint(user)
		animate_storage_rustle(A)
		return RETURN_EARLY
	else
		for (var/mob/M in hud.mobs)
			if (M != user)
				M.detach_hud(hud)
		hud.update()

// run once on Initialize()
/datum/component/storage/proc/make_my_stuff(list/spawn_contents)
	for (var/thing in spawn_contents)
		var/amt = 1
		if (!ispath(thing))
			continue
		if (isnum(spawn_contents[thing]))
			amt = abs(spawn_contents[thing])
		for (amt, amt>0, amt--)
			new thing(src.parent)
	return 1

/datum/component/storage/proc/mousetrap_check(mob/user)
	var/atom/A = src.parent
	if (!ishuman(user) || user.stat)
		return
	for (var/obj/item/mousetrap/MT in A.contents)
		if (MT.armed)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a mousetrap!</B></span>",\
			"<span class='alert'><B>You reach into [src.parent], but there was a live mousetrap in there!</B></span>")
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			. = 1
	for (var/obj/item/mine/M in A.contents)
		if (M.armed && M.used_up != 1)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a [M]!</B></span>",\
			"<span class='alert'><B>You reach into [src.parent], but there was a live [M] in there!</B></span>")
			M.triggered(user)
			. = 1

// future: refactor into /datum/component/storage/shared
/datum/component/storage/bible

/datum/component/storage/bible/get_contents(atom/source, list/cont)
	cont += bible_contents

/datum/component/storage/bible/transfer_item(atom/source, obj/item/I, var/target)
	bible_contents -= I
	..()
	for (var/obj/item/bible/bible in by_type[/obj/item/bible])
		SEND_SIGNAL(bible, COMSIG_ITEM_DROPPED)

/datum/component/storage/bible/add_item(source, obj/item/I, mob/user)
	bible_contents += I
	..()
	for (var/obj/item/bible/bible in by_type[/obj/item/bible])
		SEND_SIGNAL(bible, COMSIG_ITEM_DROPPED)

