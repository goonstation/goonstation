/datum/component/power_cell
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/charge
	var/max_charge
	var/recharge_rate
	var/recharge_delay = 0
	var/recharge_time
	var/cycle = 0
	var/can_be_recharged

TYPEINFO(/datum/component/power_cell)
	initialization_args = list(
		ARG_INFO("max", DATA_INPUT_NUM, "Maximum cell charge", 200),
		ARG_INFO("start_charge", DATA_INPUT_NUM, "Initial cell charge", 200),
		ARG_INFO("recharge_rate", DATA_INPUT_NUM, "Recharge rate of cell (approx per 2.9 seconds)", 0),
		ARG_INFO("recharge_delay", DATA_INPUT_NUM, "Minimum time delay (in deciseconds) after power is used before self-charging resumes", 0),
		ARG_INFO("rechargable", DATA_INPUT_BOOL, "If the cell can recharged in a recharger", TRUE)
	)

/datum/component/power_cell/Initialize(max = 200, start_charge = 200, recharge = 0, delay = 0, rechargable = TRUE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.max_charge = max
	src.charge = start_charge
	src.recharge_rate = recharge
	src.recharge_delay = delay
	src.can_be_recharged = rechargable
	if(charge < max_charge && recharge_rate)
		processing_items |= parent
	RegisterSignal(parent, COMSIG_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(parent, COMSIG_CELL_CHARGE, PROC_REF(charge))
	RegisterSignal(parent, COMSIG_CELL_CAN_CHARGE, PROC_REF(can_charge))
	RegisterSignal(parent, COMSIG_CELL_USE, PROC_REF(use))
	RegisterSignal(parent, COMSIG_CELL_CHECK_CHARGE, PROC_REF(check_charge))
	RegisterSignal(parent, COMSIG_CELL_IS_CELL, PROC_REF(is_cell))
	RegisterSignal(parent, COMSIG_ITEM_PROCESS, PROC_REF(process))

/datum/component/power_cell/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKBY)
	UnregisterSignal(parent, COMSIG_CELL_CHARGE)
	UnregisterSignal(parent, COMSIG_CELL_CAN_CHARGE)
	UnregisterSignal(parent, COMSIG_CELL_USE)
	UnregisterSignal(parent, COMSIG_CELL_CHECK_CHARGE)
	UnregisterSignal(parent, COMSIG_CELL_IS_CELL)
	UnregisterSignal(parent, COMSIG_ITEM_PROCESS)
	. = ..()

/datum/component/power_cell/InheritComponent(datum/component/power_cell/C, i_am_original, max, start_charge, recharge, delay, rechargable)
	if(C)
		src.max_charge = C.max_charge
		src.charge = C.charge
		src.recharge_rate = C.recharge_rate
		src.recharge_delay = C.recharge_delay
		if(charge < max_charge && recharge_rate)
			processing_items |= parent
	else
		if(isnum_safe(max))
			src.max_charge = max
		if(isnum_safe(start_charge))
			src.charge = start_charge
		if(isnum_safe(recharge))
			src.recharge_rate = recharge
		if(isnum_safe(delay))
			src.recharge_delay = delay
		if(isnum_safe(rechargable))
			src.can_be_recharged = rechargable

/datum/component/power_cell/proc/attackby(source, obj/item/I, mob/user)
	SEND_SIGNAL(I, COMSIG_CELL_TRY_SWAP, parent, user)

/datum/component/power_cell/proc/can_charge()
	if(src.can_be_recharged)
		. = CELL_CHARGEABLE
	else
		. = CELL_UNCHARGEABLE

/datum/component/power_cell/proc/charge(source, amount)
	if (amount > 0)
		src.charge = min(src.charge + amount, src.max_charge)

	if (src.charge >= src.max_charge)
		processing_items -= parent
		src.charge = src.max_charge
		. = CELL_FULL
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/use(source, amount)
	src.charge = max(src.charge - amount, 0)
	if(src.recharge_rate && amount > 0)
		recharge_time = TIME + recharge_delay
		processing_items |= parent


	if(src.charge > 0) //return sufficient charge if cell is non-empty after drain, insufficient if cell was emptied by the drain
		. = CELL_SUFFICIENT_CHARGE
	else
		. = CELL_INSUFFICIENT_CHARGE

	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/check_charge(source, list/amount)
	if(islist(amount))
		amount["charge"] = src.charge
		amount["max_charge"] = src.max_charge
		. = CELL_RETURNED_LIST
	else if(isnum_safe(amount))
		. = (src.charge >= amount) ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE
	else
		. = src.charge > 0 ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE

/datum/component/power_cell/proc/is_cell()
	return TRUE

/datum/component/power_cell/proc/process()
	if(TIME >= recharge_time)
		src.charge(null, recharge_rate)
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)
	return

/datum/component/power_cell/flockdrone
	var/original_rate

/datum/component/power_cell/flockdrone/Initialize(max, start_charge, recharge, delay, rechargable)
	. = ..()
	src.original_rate = src.recharge_rate

/datum/component/power_cell/flockdrone/process()
	if (isfeathertile(get_turf(src.parent)))
		src.recharge_rate = src.original_rate
	else
		src.recharge_rate = src.original_rate/2
	..()

/datum/component/power_cell/redirect
	var/target_type = null
	var/obj/item/redirect_object = null
	var/parent_locked = FALSE

/datum/component/power_cell/redirect/Initialize(max, start_charge, recharge, delay, rechargable)
	. = ..( )
	RegisterSignal(parent, COMSIG_MOVABLE_SET_LOC, PROC_REF(update_redirect))
	processing_items |= parent

/datum/component/power_cell/redirect/can_charge(parent)
	if(src.distance_check())
		. = SEND_SIGNAL(redirect_object, COMSIG_CELL_CAN_CHARGE)

/datum/component/power_cell/redirect/use(parent, amount)
	if(src.distance_check())
		. = SEND_SIGNAL(redirect_object, COMSIG_CELL_USE, amount)

/datum/component/power_cell/redirect/check_charge(source, amount)
	if(src.distance_check())
		. = SEND_SIGNAL(redirect_object, COMSIG_CELL_CHECK_CHARGE, amount)

/datum/component/power_cell/redirect/proc/connect(obj/item/parent, atom/target, mob/user, reach, params)
	if(istype(target, target_type))
		redirect_object = target
		RegisterSignal(redirect_object, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), PROC_REF(check_redirect))
		boutput(user,SPAN_SUCCESS("You connect [parent] to [target]."))

/datum/component/power_cell/redirect/proc/update_redirect(atom/movable/target, previous_loc, direction)
	if(istype(parent, /obj/item/ammo/power_cell/redirect))
		var/obj/item/ammo/power_cell/redirect/cell = parent
		target_type = cell.target_type

		if(!cell.internal && !parent_locked)
			parent_locked = TRUE
			RegisterSignal(cell.loc, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), PROC_REF(check_redirect))
			RegisterSignal(cell.loc, COMSIG_ITEM_AFTERATTACK, PROC_REF(connect))

		var/obj/O = parent
		while(istype(O) && !istype(O, target_type))
			O = O.loc
		if(istype(O, target_type))
			redirect_object = O
		else if(cell.internal)
			CRASH("Target Not Found Internal Power Cell Redirect")
	else
		CRASH("[parent] is not /obj/item/ammo/power_cell/redirect")

/datum/component/power_cell/redirect/proc/check_redirect(atom/movable/target, previous_loc, direction)
	src.distance_check()

/datum/component/power_cell/redirect/proc/distance_check()
	if(src.redirect_object && (BOUNDS_DIST(src.parent, src.redirect_object) >= 1))
		var/obj/item/ammo/power_cell/redirect/cell = parent
		var/obj/target = cell.loc
		target.tri_message(target.loc, "[target]'s connection to [src.redirect_object] pops free.", second_message=SPAN_ALERT("[target]'s connection to [src.redirect_object] reaches the end of the cable... and pops free."), blind_message="You hear a faint popping sound as if something were unplugged.")
		UnregisterSignal(redirect_object, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		redirect_object = null
	. = !isnull(redirect_object)
