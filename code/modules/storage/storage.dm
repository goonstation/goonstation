/* ================================================================== */
/* ------------------------- STORAGE DATUM -------------------------- */
/* ================================================================== */

// see storage.md for an intro to storage datums

/// add storage to an atom
/atom/proc/create_storage(storage_type, list/spawn_contents = list(), list/can_hold = list(), list/can_hold_exact = list(), list/prevent_holding = list(),
		check_wclass = FALSE, max_wclass = W_CLASS_SMALL, slots = 7, sneaky = FALSE, opens_if_worn = FALSE, list/params = list())
	var/list/previous_storage = list()
	for (var/obj/item/I as anything in src.storage?.get_contents())
		previous_storage += I
	src.remove_storage()
	src.storage = new storage_type(src, spawn_contents, can_hold, can_hold_exact, prevent_holding, check_wclass, max_wclass, slots, sneaky, opens_if_worn, params)
	for (var/obj/item/I as anything in previous_storage)
		src.storage.add_contents(I)

/// remove atom's storage
/atom/proc/remove_storage()
	qdel(src.storage)
	src.storage = null

/// a datum for atoms that allows holdable storage of items in a hud
/datum/storage
	/// Types that can be held
	var/list/can_hold = null
	/// Exact types that can be held, in addition to can_hold, if it has types
	var/list/can_hold_exact = null
	/// Types that have a w_class holdable but that the storage will not hold
	var/list/prevent_holding = null
	/// If set, if can_hold is used, an item not in can_hold or can_hold_exact can fit in the storage if its weight is low enough
	var/check_wclass = FALSE
	/// Storage hud attached to the storage
	var/datum/hud/storage/hud = null
	/// Don't print a visible message on use
	var/sneaky = FALSE
	/// Prevent accessing storage when clicked when worn, ex. in pocket
	var/opens_if_worn = FALSE
	/// Maximum w_class that can be held
	var/max_wclass = W_CLASS_SMALL
	/// Number of storage slots, even numbers overlap the close button for the on-ground hud layout
	var/slots = 7
	/// Does moving the linked storage item cause anything to happen to stored items
	var/move_triggered = TRUE
	/// The storage item linked to this datum
	var/atom/linked_item = null
	/// All items stored
	var/list/stored_items = null

/datum/storage/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass, max_wclass, \
		slots, sneaky, opens_if_worn, list/params)
	..()
	src.stored_items = list()

	src.linked_item = storage_item
	src.hud = new (src)
	src.can_hold = can_hold
	src.can_hold_exact = can_hold_exact
	src.prevent_holding = prevent_holding
	src.check_wclass = check_wclass
	src.max_wclass = max_wclass
	src.slots = slots
	src.sneaky = sneaky
	src.opens_if_worn = opens_if_worn

	if (istype(src.linked_item, /obj/item))
		var/obj/item/I = src.linked_item
		I.tooltip_rebuild = TRUE

	RegisterSignal(src.linked_item, COMSIG_ITEM_DROPPED, PROC_REF(storage_item_on_drop))

	if (length(spawn_contents))
		src.make_my_stuff(spawn_contents)

/datum/storage/disposing()
	for (var/obj/item/I as anything in src.get_contents())
		src.transfer_stored_item(I, get_turf(src.linked_item))

	for (var/mob/M as anything in src.hud.mobs)
		src.hide_hud(M)

	qdel(src.hud)
	src.hud = null

	if (istype(src.linked_item, /obj/item))
		var/obj/item/I = src.linked_item
		I.tooltip_rebuild = TRUE

	src.linked_item = null
	src.stored_items = null

	UnregisterSignal(src.linked_item, COMSIG_ITEM_DROPPED)

	..()

// ----------------- "INTERNAL" PROCS ----------------------

/// storage item moving triggers a movement of items inside
/datum/storage/proc/storage_item_move_triggered(mob/M, kindof)
	for (var/obj/item/I as anything in src.get_contents())
		if (I.move_triggered)
			I.move_trigger(M, kindof)

/// creates initial contents in the storage
/datum/storage/proc/make_my_stuff(list/spawn_contents)
	if (!length(spawn_contents))
		return
	var/total_amt = 0
	for (var/thing in spawn_contents)
		var/amt = 1
		if (!ispath(thing))
			continue
		if (isnum(spawn_contents[thing]))
			amt = abs(spawn_contents[thing])
		total_amt += amt
		while (amt > 0)
			src.add_contents(new thing(src.linked_item))
			amt--
	if (total_amt > slots)
		logTheThing(LOG_DEBUG, null, "STORAGE ITEM: [log_object(src.linked_item)] has more than [slots] items in it!")

/// when clicking the storage item with an object
/datum/storage/proc/storage_item_attack_by(obj/item/W, mob/user)
	. = TRUE
	// check if item is the storage item
	if (W == src.linked_item)
		boutput(user, "<span class='alert'>You can't put [W] into itself!</span>")
		return

	var/canhold = src.check_can_hold(W)

	// cases for if it seems the item cant be stored
	if (canhold != STORAGE_CAN_HOLD)
		if (canhold == STORAGE_CANT_HOLD || canhold == STORAGE_WONT_FIT || canhold == STORAGE_RESTRICTED_TYPE)
			// locked storage check
			if (istype(W, /obj/item/storage/secure))
				var/obj/item/storage/secure/S = W
				if (S.locked)
					boutput(user, "<span class='alert'>[S] is locked and cannot be opened!</span>")
					return
			// if item has a storage, dump contents into this storage
			if (W.storage && !src.is_full())
				for (var/obj/item/I as anything in (W.storage.get_contents() - src.linked_item))
					if (src.check_can_hold(I) == STORAGE_CAN_HOLD)
						if (I.anchored)
							continue
						W.storage.transfer_stored_item(I, src.linked_item, TRUE, user)
				return
		// show pocket or other storage
		if(src.opens_if_worn)
			src.storage_item_attack_hand(user)
		// give info message
		switch (canhold)
			if (STORAGE_CANT_HOLD)
				boutput(user, "<span class='alert'>[src.linked_item] cannot hold [W].</span>")
			if (STORAGE_WONT_FIT)
				boutput(user, "<span class='alert'>[W] won't fit into [src.linked_item]!</span>")
			if (STORAGE_IS_FULL)
				boutput(user, "<span class='alert'>[src.linked_item] is full!</span>")
		return

	// safety check
	var/atom/checkloc = src.linked_item.loc // no infinite loops for you
	while (checkloc && !isturf(src.linked_item.loc))
		if (checkloc == W) // nope
			//Hi hello this used to gib the user and create an actual 5x5 explosion on their tile
			//Turns out this condition can be met and reliably reproduced by players!
			//Lets not give players the ability to fucking explode at will eh
			return FALSE
		checkloc = checkloc.loc

	// add item to storage
	src.add_contents(W, user)

/// when clicking the storage item with an empty hand
/datum/storage/proc/storage_item_attack_hand(mob/user)
	if (!src.sneaky)
		playsound(src.linked_item.loc, "rustle", 50, TRUE, -2)
	// check if its in your inventory
	if (src.linked_item.loc == user && (src.opens_if_worn || (src.linked_item in user.equipped_list(FALSE)) || IS_LIVING_OBJECT_USING_SELF(user)))
		// check if storage is attached as an arm
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.limbs)
				if ((src.linked_item == H.l_hand && istype(H.limbs.l_arm, /obj/item/parts/human_parts/arm/left/item)) || \
						(src.linked_item == H.r_hand && istype(H.limbs.r_arm, /obj/item/parts/human_parts/arm/right/item)))
					return FALSE
		// open storage
		user.s_active?.master.hide_hud(user)
		if (src.mousetrap_check(user))
			return FALSE
		src.show_hud(user)
		src.linked_item.add_fingerprint(user)
		animate_storage_rustle(src.linked_item)
	else
		// make sure only the user can see the storage
		for (var/mob/M as anything in src.hud.mobs)
			if (M != user)
				src.hide_hud(M)
		src.hud.update(user)
	return TRUE

/// storage item is mouse dropped onto something
/datum/storage/proc/storage_item_mouse_drop(mob/user, atom/over_object, src_location, over_location)
	// if mouse dropping storage item onto a hand slot, attempt to hold it
	if (istype(over_object, /atom/movable/screen/hud))
		var/atom/movable/screen/hud/S = over_object
		playsound(src.linked_item.loc, "rustle", 50, TRUE, -5)
		if (!user.restrained() && !is_incapacitated(user) && src.linked_item.loc == user)
			if (S.id == "rhand" && !user.r_hand)
				user.u_equip(src.linked_item)
				user.put_in_hand_or_drop(src.linked_item)
			else if (S.id == "lhand" && !user.l_hand)
				user.u_equip(src.linked_item)
				user.put_in_hand_or_drop(src.linked_item)
	// if mouse dropping storage item onto self, look inside
	else if (over_object == user && in_interact_range(src.linked_item, user) && isliving(user) && !is_incapacitated(user) && !isintangible(user))
		user.s_active?.master.hide_hud(user)
		if (src.mousetrap_check(user))
			return
		src.show_hud(user)
	// if mouse dropping onto a table or rack, attempt to dump contents onto it
	else if (user.is_in_hands(src.linked_item))
		var/turf/T = over_object
		if (istype(T, /obj/table) || istype(T, /obj/rack))
			T = get_turf(T)
		if (!(user in range(1, T)))
			return
		if (!istype(T))
			return
		if (T.density)
			return
		for (var/obj/O in T)
			if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
				return
		user.visible_message("<span class='alert'>[user] dumps the contents of [src.linked_item.name] onto [over_object]!</span>")
		for (var/obj/item/I as anything in src.get_contents())
			src.transfer_stored_item(I, T, user = user)
			I.layer = initial(I.layer)
			if (istype(I, /obj/item/mousetrap))
				var/obj/item/mousetrap/MT = I
				if (MT.armed)
					MT.visible_message("<span class='alert'>[MT] triggers as it falls on the ground!</span>")
					MT.triggered(user, null)
			else if (istype(I, /obj/item/mine))
				var/obj/item/mine/M = I
				if (M.armed && M.used_up != TRUE)
					M.visible_message("<span class='alert'>[M] triggers as it falls on the ground!</span>")
					M.triggered(user)

/// using storage item in hand
/datum/storage/proc/storage_item_attack_self(mob/user)
	src.storage_item_attack_hand(user)

/// after attacking an object with the storage item
/datum/storage/proc/storage_item_after_attack(atom/target, mob/user, reach)
	// if item is stored, drop storage and take it out
	if (target in src.get_contents())
		user.drop_item()
		src.transfer_stored_item(target, get_turf(src.linked_item), user = user)
		SPAWN(1 DECI SECOND)
			target.Attackhand(user)
	// attempt to load item into storage if you have a free hand
	else if (isitem(target) && !istype(target, /obj/item/storage))
		var/obj/O = target
		if (O.anchored)
			return
		if (!can_reach(user, target))
			return
		user.swap_hand()
		if (user.equipped() == null)
			target.Attackhand(user)
			if (target in user.equipped_list())
				src.storage_item_attack_by(target, user)
		else
			boutput(user, "<span class='notice'>Your hands are full!</span>")
		user.swap_hand()

/// storage item is dropped
/datum/storage/proc/storage_item_on_drop(atom/source, mob/user)
	src.hud?.update(user)

/// when reaching inside the storage item, check for traps
/datum/storage/proc/mousetrap_check(mob/user)
	if (!ishuman(user) || is_incapacitated(user))
		return FALSE
	for (var/obj/item/mousetrap/MT in src.get_contents())
		if (MT.armed)
			user.visible_message("<span class='alert'><B>[user] reaches into \the [src.linked_item.name] and sets off a mousetrap!</B></span>",\
				"<span class='alert'><B>You reach into \the [src.linked_item.name], but there was a live mousetrap in there!</B></span>")
			MT.triggered(user, user.hand ? "l_hand" : "r_hand")
			return TRUE
	for (var/obj/item/mine/M in src.get_contents())
		if (M.armed && M.used_up != TRUE)
			user.visible_message("<span class='alert'><B>[user] reaches into \the [src.linked_item.name] and sets off a [M.name]!</B></span>",\
				"<span class='alert'><B>You reach into \the [src.linked_item.name], but there was a live [M.name] in there!</B></span>")
			M.triggered(user)
			return TRUE

// ----------------- PUBLIC PROCS ----------------------

/// check if the storage can hold an item or not
/datum/storage/proc/check_can_hold(obj/item/W)
	if (!W)
		return STORAGE_CANT_HOLD

	if (W.cant_drop)
		return STORAGE_WONT_FIT

	for (var/type in src.prevent_holding)
		if (ispath(type) && istype(W, type))
			return STORAGE_RESTRICTED_TYPE

	// if can_hold is defined, check against that
	if (length(src.can_hold) && !src.is_full())
		// early skip if weight class is allowed
		if (src.check_wclass && W.w_class <= src.max_wclass)
			return STORAGE_CAN_HOLD
		for (var/type in src.can_hold)
			if (ispath(type) && istype(W, type))
				return STORAGE_CAN_HOLD
		for (var/type in src.can_hold_exact)
			if (ispath(type) && W.type == type)
				return STORAGE_CAN_HOLD
		return STORAGE_CANT_HOLD

	else if (W.w_class > src.max_wclass)
		return STORAGE_WONT_FIT

	if (src.is_full())
		return STORAGE_IS_FULL

	return STORAGE_CAN_HOLD

/// when adding an item in
/datum/storage/proc/add_contents(obj/item/I, mob/user = null, visible = TRUE)
	if (user?.equipped() == I)
		user.u_equip(I)
	src.stored_items += I
	I.set_loc(src.linked_item, FALSE)
	src.hud.add_item(I, user)
	I.stored = src

	src.add_contents_extra(I, user, visible)

/// available if add_contents needs to be overridden
/datum/storage/proc/add_contents_extra(obj/item/I, mob/user, visible)
	// make sure storage item tooltip will be updated
	if (istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.tooltip_rebuild = TRUE
	// for storages that change icon with contents
	src.linked_item.UpdateIcon(user)

	if (!istype(user))
		return

	// a mob put the item in
	src.linked_item.add_fingerprint(user)
	if (visible)
		animate_storage_rustle(src.linked_item)
		if (!src.sneaky && !istype(I, /obj/item/gun/energy/crossbow))
			user.visible_message("<span class='notice'>[user] has added [I] to [src.linked_item]!</span>",
				"<span class='notice'>You have added [I] to [src.linked_item].</span>")
		playsound(src.linked_item.loc, "rustle", 50, TRUE, -5)

/// use this versus add_contents() if you also want extra safety checks
/datum/storage/proc/add_contents_safe(obj/item/I, mob/user = null, visible = TRUE)
	src.storage_item_attack_by(I, user)

/// when transfering something in the storage out
/datum/storage/proc/transfer_stored_item(obj/item/I, atom/location, add_to_storage = FALSE, mob/user = null)
	if (!(I in src.get_contents()))
		return
	if(I.anchored) //Niche exception where items are anchored in storage. "Mech Components mainly"
		return
	src.stored_items -= I
	src.hud.remove_item(I, user)
	I.stored = null

	src.transfer_stored_item_extra(I, location, add_to_storage, user)

/// for use if transfer_stored_item is overridden
/datum/storage/proc/transfer_stored_item_extra(obj/item/I, atom/location, add_to_storage, mob/user)
	// update storage item tooltip
	if (istype(src.linked_item, /obj/item))
		var/obj/item/W = src.linked_item
		W.tooltip_rebuild = TRUE
	src.linked_item.UpdateIcon(user)
	if (location?.storage && add_to_storage)
		location.storage.add_contents(I, user)
	else
		I.set_loc(location, FALSE)
		if (isturf(location))
			I.dropped(user)

/// return outputtable capacity
/datum/storage/proc/get_capacity_string()
	return "<br>Holding [length(src.get_contents())]/[src.slots] objects"

/// storage is full or not
/datum/storage/proc/is_full()
	return length(src.get_contents()) >= src.slots

/// return stored contents
/datum/storage/proc/get_contents()
	return src.stored_items

/// return recursive search of all contents
/datum/storage/proc/get_all_contents()
	. = list()
	var/our_contents = src.get_contents()
	. += our_contents
	for (var/atom/A as anything in our_contents)
		if (A.storage)
			. += A.storage.get_all_contents()

/// show storage contents
/datum/storage/proc/show_hud(mob/user)
	user.s_active = src.hud
	src.hud.update(user)
	user.attach_hud(src.hud)

/// hide storage
/datum/storage/proc/hide_hud(mob/user)
	if (user.s_active == src.hud)
		user.s_active = null
		user.detach_hud(src.hud)

/// if user sees the storage hud
/datum/storage/proc/hud_shown(mob/user)
	return user in src.hud.mobs

/// emping storage emps everything inside
/datum/storage/proc/storage_emp_act()
	for (var/atom/A as anything in src.get_contents())
		A.emp_act()
