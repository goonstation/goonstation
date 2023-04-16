/datum/component/cell_holder
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/atom/movable/cell
	var/can_be_recharged = TRUE
	var/max_cell_size = INFINITY
	var/swappable_cell = TRUE

TYPEINFO(/datum/component/cell_holder)
	initialization_args = list(
		ARG_INFO("new_cell", DATA_INPUT_REF, "ref to cell that will be first used"),
		ARG_INFO("chargable", DATA_INPUT_BOOL, "If it can be placed in a recharger", TRUE),
		ARG_INFO("max_cell", DATA_INPUT_NUM, "Maximum size of cell that can be held", INFINITY),
		ARG_INFO("swappable", DATA_INPUT_BOOL, "If the cell can be swapped out", TRUE)
	)

/datum/component/cell_holder/Initialize(atom/movable/new_cell, chargable = TRUE, max_cell = INFINITY, swappable = TRUE)
	. = ..()
	if(!isitem(parent) || SEND_SIGNAL(parent, COMSIG_CELL_IS_CELL))
		return COMPONENT_INCOMPATIBLE
	if(SEND_SIGNAL(new_cell, COMSIG_CELL_IS_CELL))
		src.cell = new_cell
		new_cell.set_loc(parent)
		RegisterSignal(cell, COMSIG_UPDATE_ICON, .proc/UpdateIcon)
	can_be_recharged = chargable
	max_cell_size = max_cell
	swappable_cell = swappable

	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_CELL_SWAP, .proc/do_swap)
	RegisterSignal(parent, COMSIG_CELL_TRY_SWAP, .proc/try_swap)
	RegisterSignal(parent, COMSIG_CELL_CHARGE, .proc/do_charge)
	RegisterSignal(parent, COMSIG_CELL_CAN_CHARGE, .proc/can_charge)
	RegisterSignal(parent, COMSIG_CELL_USE, .proc/use)
	RegisterSignal(parent, COMSIG_CELL_CHECK_CHARGE, .proc/check_charge)


/datum/component/cell_holder/InheritComponent(datum/component/cell_holder/C, i_am_original, new_cell = null, chargable = null, max_cell = null, swappable = null)
	if(C) //we're passed an initalized cellholder
		src.can_be_recharged = C.can_be_recharged
		src.max_cell_size = C.max_cell_size
		src.swappable_cell = C.swappable_cell
		qdel(src.cell)
		src.cell = C.cell
		src.cell?.set_loc(parent)
	else //grab non-null args and use them
		if(ismovable(new_cell))
			var/atom/movable/maybecell = new_cell
			if(SEND_SIGNAL(maybecell, COMSIG_CELL_IS_CELL))
				qdel(src.cell)
				src.cell = new_cell
				src.cell.set_loc(parent)
				RegisterSignal(cell, COMSIG_UPDATE_ICON, .proc/UpdateIcon)
		else if(istype(new_cell, /datum/component/power_cell))
			src.cell.AddComponent(new_cell)
		else if(islist(new_cell))
			src.cell.AdminAddComponent(arglist(list(/datum/component/power_cell) + new_cell))

		if(isnum_safe(chargable))
			src.can_be_recharged = chargable
		if(isnum_safe(max_cell))
			src.max_cell_size = max_cell
		if(isnum_safe(swappable))
			src.swappable_cell = swappable
	. = ..()

/datum/component/cell_holder/disposing()
	qdel(src.cell)
	. = ..()

/datum/component/cell_holder/proc/attackby(source, obj/item/W, mob/user)
	if(SEND_SIGNAL(W, COMSIG_CELL_IS_CELL))
		src.begin_swap(user, W)
		return 1

/datum/component/cell_holder/proc/begin_swap(mob/user, atom/movable/P)
	if(src.swappable_cell)
		var/list/ret = list()
		if((SEND_SIGNAL(P, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST) && (ret["max_charge"] <= src.max_cell_size))
			actions.start(new /datum/action/bar/icon/cellswap(user, P, parent), user)
		else
			boutput(user, "<span class='notice'>[parent] cannot handle the amount of power in [P].</span>")
	else
		boutput(user, "<span class='notice'>[parent] doesn't have a port to swap power cells.</span>")

/datum/component/cell_holder/proc/do_swap(source, atom/movable/P, mob/user)
	var/atom/movable/old_cell = src.cell
	var/atom/old_loc = get_turf(parent)
	if(P)
		old_loc = P.loc
		if(user)
			user.u_equip(P)
			P.add_fingerprint(user)
		src.cell = P
		RegisterSignal(cell, COMSIG_UPDATE_ICON, .proc/UpdateIcon)
		P.set_loc(src.parent)
		SEND_SIGNAL(P, COMSIG_UPDATE_ICON)

	if(old_cell)
		old_cell.set_loc(old_loc)
		SEND_SIGNAL(old_cell, COMSIG_UPDATE_ICON)
		UnregisterSignal(old_cell, COMSIG_UPDATE_ICON)
		if(!P)
			src.cell = null
			if(user)
				old_loc = user
		if(user)
			old_cell.add_fingerprint(user)

		if(istype(old_loc, /mob))
			var/mob/M = old_loc
			M.put_in_hand_or_drop(old_cell)

	playsound(parent, 'sound/weapons/gunload_click.ogg', 50, 1)

/datum/component/cell_holder/proc/try_swap(source, obj/item/I, mob/user)
	begin_swap(user, I)

/datum/component/cell_holder/proc/can_charge(parent)
	if(src.can_be_recharged && (SEND_SIGNAL(cell, COMSIG_CELL_CAN_CHARGE) & CELL_CHARGEABLE))
		. = CELL_CHARGEABLE
	else
		. = CELL_UNCHARGEABLE

/datum/component/cell_holder/proc/do_charge(parent, amount)
	if(!src.can_be_recharged)
		. = CELL_UNCHARGEABLE
	else
		. = SEND_SIGNAL(src.cell, COMSIG_CELL_CHARGE, amount)


/datum/component/cell_holder/proc/use(parent, amount)
	. = SEND_SIGNAL(src.cell, COMSIG_CELL_USE, amount)

/datum/component/cell_holder/proc/check_charge(source, amount)
	. = SEND_SIGNAL(src.cell, COMSIG_CELL_CHECK_CHARGE, amount)

/datum/component/cell_holder/proc/UpdateIcon()
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/action/bar/icon/cellswap
	duration = 1 SECOND
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ATTACKED | INTERRUPT_ACTION
	id = "powercellswap"
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "power_cell"
	var/mob/living/user
	var/atom/movable/cell
	var/obj/item/cell_holder

	New(User, Cell, Cell_holder)
		src.user = User
		src.cell = Cell
		src.cell_holder = Cell_holder
		..()

	onStart()
		..()
		if(BOUNDS_DIST(user, cell_holder) > 0 || QDELETED(user) || QDELETED(cell) || QDELETED(cell_holder) || get_turf(cell_holder) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return
		return

	onUpdate()
		..()
		if(BOUNDS_DIST(user, cell_holder) > 0 || QDELETED(user) || QDELETED(cell) || QDELETED(cell_holder) || get_turf(cell_holder) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(user, cell_holder) > 0 || QDELETED(user) || QDELETED(cell) || QDELETED(cell_holder) || get_turf(cell_holder) != get_turf(cell) )
			interrupt(INTERRUPT_ALWAYS)
			return
		SEND_SIGNAL(cell_holder, COMSIG_CELL_SWAP, cell, user)
