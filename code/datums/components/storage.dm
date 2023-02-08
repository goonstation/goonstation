// STORAGE COMPONENT
// example:
// /obj/item/storage/backpack/monkey
//	 spawn_contents = list(/obj/item/toy/plush/small/monkey)
//	 New()
//		 ..()
//		 AddComponent(/datum/component/storage, max_wclass = 4)
// since /obj/item/storage already calls AddComponent with spawn_contents = spawn_contents, we don't need to specify that arg again. we just need to respecify our unique max_wclass of 4, or else it'll be set as /obj/item/storage/backpack's 3!

/datum/component/storage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/datum/hud/storage/hud
	/// acts as a whitelist for what can be added to the storage, if defined
	var/list/can_hold
	/// If can_hold has stuff in it, if this is set, something will fit if it's at or below max_wclass OR if it's in can_hold, otherwise only things in can_hold will fit
	var/in_list_or_max = FALSE
	/// maximum weight class of item that can be put in the storage
	var/max_wclass = 2 //todo
	/// number of slots in the storage, even numbers overlap the close button for the on-ground hud layout
	var/slots = 7
	/// if a sound is played when an item is put in the storage
	var/sneaky = FALSE
	/// storage won't open if it's clicked while in your pocket
	var/opens_in_pocket = FALSE

	/// contains a trap such as a mousetrap or mine
	var/contains_trap = FALSE

	var/list/stored_items = list()

// spawn_contents is a list of items initialized to spawn inside this, and may be associative to indicate the number of them to spawn
/datum/component/storage/Initialize(list/spawn_contents, list/can_hold, in_list_or_max = FALSE, max_wclass = W_CLASS_SMALL, slots = 7, sneaky = FALSE, opens_in_pocket = FALSE)
	if (!istype(parent, /atom))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attack_by)
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/hand_attack)
	RegisterSignal(parent, COMSIG_ATOM_MOUSEDROP, .proc/mouse_drop) // CHECK
	//RegisterSignal(parent, COMSIG_OBJ_MOVE_TRIGGER, .proc/move_trigger) // CHECK
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/attack_self)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/after_attack)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_dropped)
	RegisterSignal(parent, COMSIG_STORAGE_GET_CONTENTS, .proc/get_contents) // CHECK
	RegisterSignal(parent, COMSIG_STORAGE_GET_ALL_CONTENTS, .proc/get_all_contents) // CHECK
	RegisterSignal(parent, COMSIG_STORAGE_TRANSFER_ITEM, .proc/transfer_item) // CHECK
	RegisterSignal(parent, COMSIG_STORAGE_CAN_FIT, .proc/can_fit) // CHECK
	src.hud = new (src)
	src.can_hold = can_hold
	src.in_list_or_max = in_list_or_max
	src.max_wclass = max_wclass
	src.slots = slots
	src.sneaky = sneaky
	src.opens_in_pocket = opens_in_pocket
	if (spawn_contents)
		src.make_my_stuff(spawn_contents)


// CHECK

// since we have COMPONENT_DUPE_UNIQUE_PASSARGS, we should always get SC = null, original = TRUE (since new component doesn't get passed)
// we should only get passed the other args (the new component's initialization args), if applicable
/datum/component/storage/InheritComponent(datum/component/storage/SC, original, list/spawn_contents, list/can_hold, in_list_or_max, max_wclass, slots, sneaky, opens_in_pocket)
	if (spawn_contents)
		make_my_stuff(spawn_contents)
	src.can_hold = can_hold || SC?.can_hold
	src.in_list_or_max = in_list_or_max || SC?.in_list_or_max
	src.max_wclass = max_wclass || SC?.max_wclass
	src.slots = slots || SC?.slots
	src.sneaky = sneaky || SC?.sneaky
	src.opens_in_pocket = opens_in_pocket || SC?.opens_in_pocket

/datum/component/storage/disposing()
	if (src.hud)
		for (var/mob/M as anything in src.hud.mobs)
			if (M.s_active == src.hud)
				M.s_active = null
		qdel(hud)
		hud = null
	..()

/datum/component/storage/proc/attack_by(atom/source, obj/item/I, mob/user)
	if (I.cant_drop)
		return
	if (length(src.can_hold))
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
	if (length(src.stored_items) >= src.slots)
		boutput(usr, "<span class='alert'>[source] is full!</span>")
		return

	// some code to prevent gibbing and explosions on a tile
	var/atom/checkloc = source.loc
	while (checkloc && !isturf(source.loc))
		if (checkloc == I)
			return
		checkloc = checkloc.loc

	src.add_item(source, I, user)

	source.add_fingerprint(user)
	animate_storage_rustle(source)
	source.UpdateIcon()
	if (!src.sneaky && !istype(I, /obj/item/gun/energy/crossbow))
		user.visible_message("<span class='notice'>[user] has added [I] to [source]!</span>", "<span class='notice'>You have added [I] to [source].</span>")
	playsound(source.loc, "rustle", 50, TRUE, -5)

	/*
		if (canhold <= 0)
			if(istype(W, /obj/item/storage) && (canhold == 0 || canhold == -1))
				//is the storage locked?
				if (istype(W, /obj/item/storage/secure))
					var/obj/item/storage/secure/S = W
					if (S.locked)
						boutput(user, "<span class='alert'>[S] is locked and cannot be opened!</span>")
						return
				var/obj/item/storage/S = W
				for (var/obj/item/I in S.get_contents())
					if(src.check_can_hold(I) > 0 && !I.anchored)
						src.Attackby(I, user, S)
				return
			if(!does_not_open_in_pocket)
				attack_hand(user)
			switch (canhold)
				if(0)
					boutput(user, "<span class='alert'>[src] cannot hold [W].</span>")
				if(-1)
					boutput(user, "<span class='alert'>[W] won't fit into [src]!</span>")
				if(-2)
					boutput(user, "<span class='alert'>[src] is full!</span>")
			return
	*/

/datum/component/storage/proc/hand_attack(source, mob/user)
	src.handle_storage(user)

// CHECK

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
		if (src.contains_trap)
			src.trap_act(usr) // todo, check if usr is right
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

/datum/component/storage/proc/move_trigger(mob/user, kindof)
	for (var/obj/O as anything in src.stored_items)
		if (O.move_triggered)
			O.move_trigger(user, kindof)

// user uses source, which is in their active hand
/datum/component/storage/proc/attack_self(source, mob/user)
	src.handle_storage(user)

// after user attacks I with source
/datum/component/storage/proc/after_attack(atom/source, obj/item/I, mob/user)
	if (I in src.stored_items)
		user.drop_item()
		SPAWN(1 DECI SECOND)
			I.Attackhand(user)
	else if (!istype(I, /obj/item/storage) && !I.anchored)
		user.swap_hand()
		if(user.equipped() == null)
			I.Attackhand(user)
			if (I in user.equipped_list())
				source.Attackby(I, user, I.loc)
		else
			boutput(user, "<span class='notice'>Your hands are full!</span>")
		user.swap_hand()

/datum/component/storage/proc/on_dropped(mob/user)
	src.hud.update(user)

/datum/component/storage/proc/stored_item_info()
	return "<br>Holding [length(src.stored_items)]/[src.slots] objects"

/datum/component/storage/proc/get_contents(atom/source)
	return src.stored_items

// todo: refactor around signals
/datum/component/storage/proc/get_all_contents(atom/source)
	var/list/cont = src.stored_items
	var/list/main_contents = src.stored_items
	for (var/obj/O as anything in main_contents)
		//cont += O.get_all_contents()
		continue
	return cont

// CHECK

/datum/component/storage/proc/transfer_item(atom/source, obj/item/I, atom/target)
	if (target)
		I.set_loc(target)
	src.stored_items -= I
	src.hud.remove_item(I)

// CHECK

/datum/component/storage/proc/can_fit(source, obj/item/I)
	if (src.max_wclass <= I.w_class)
		return FALSE
	return TRUE

/datum/component/storage/proc/emp_self()
	if (length(src.stored_items))
		for (var/atom/A as anything in src.stored_items)
			A.emp_act()

/datum/component/storage/proc/add_item(obj/item/I, mob/user)
	user.u_equip(I)
	I.dropped(user)
	src.stored_items += I
	src.hud.add_item(I)

	if (!src.contains_trap && (istype(I, /obj/item/mousetrap) || istype(I, /obj/item/mine)))
		src.contains_trap = TRUE
/*
/datum/component/storage/proc/remove_item(atom/source, obj/item/I)
	I.set_loc(get_turf(source))
	src.stored_items -= I
	src.hud.remove_item(I)
*/
// handles user opening the source and displaying the hud
/datum/component/storage/proc/handle_storage(mob/user)
	var/atom/A = src.parent
	if (!src.sneaky)
		playsound(A.loc, "rustle", 50, TRUE, -2)
	if (A.loc == user && (!src.opens_in_pocket || A == user.l_hand || A == user.r_hand || IS_LIVING_OBJECT_USING_SELF(user)))
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs)
				if ((A == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || (A == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
					return
		if (user.s_active)
			user.detach_hud(user.s_active)
			user.s_active = null
		if (src.contains_trap)
			src.trap_act(user)
			A.add_fingerprint(user)
			return
		user.s_active = src.hud
		src.hud.update(user)
		user.attach_hud(src.hud)
		animate_storage_rustle(A)
	else
		for (var/mob/M in src.hud.mobs)
			if (M != user)
				M.detach_hud(src.hud)
		src.hud.update(user)
	A.add_fingerprint(user)

/datum/component/storage/proc/make_my_stuff(list/spawn_contents)
	var/amt
	for (var/thing in spawn_contents)
		amt = 1
		if (!ispath(thing))
			continue
		if (isnum(spawn_contents[thing]))
			amt = abs(spawn_contents[thing])
		while (amt > 0)
			if (length(src.stored_items) >= src.slots)
				// todo: debug msg
				return
			src.stored_items += new thing()
			amt--

/datum/component/storage/proc/trap_act(mob/user)
	if (!ishuman(user) || user.stat)
		return
	for (var/obj/item/mousetrap/MT in src.stored_items)
		if (MT.armed)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a mousetrap!</B></span>",\
				"<span class='alert'><B>You reach into [src.parent], but there was a live mousetrap in there!</B></span>")
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
	for (var/obj/item/mine/M in src.stored_items)
		if (M.armed && !M.used_up)
			user.visible_message("<span class='alert'><B>[user] reaches into [src.parent] and sets off a [M]!</B></span>",\
				"<span class='alert'><B>You reach into [src.parent], but there was a live [M] in there!</B></span>")
			M.triggered(user)

/*
// CHECK

// future: refactor into /datum/component/storage/shared
/datum/component/storage/bible

// CHECK

/datum/component/storage/bible/get_contents(atom/source, list/cont)
	cont += bible_contents

// CHECK

/datum/component/storage/bible/transfer_item(atom/source, obj/item/I, var/target)
	bible_contents -= I
	..()
	for (var/obj/item/bible/bible in by_type[/obj/item/bible])
		SEND_SIGNAL(bible, COMSIG_ITEM_DROPPED)

// CHECK

/datum/component/storage/bible/add_item(source, obj/item/I, mob/user)
	bible_contents += I
	..()
	for (var/obj/item/bible/bible in by_type[/obj/item/bible])
		SEND_SIGNAL(bible, COMSIG_ITEM_DROPPED)

*/
