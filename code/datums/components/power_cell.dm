/datum/component/power_cell
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/charge
	var/max_charge
	var/recharge_rate
	var/cycle = 0

/datum/component/power_cell/Initialize(max = 200, start_charge = 200, recharge = 0)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.max_charge = max
	src.charge = start_charge
	src.recharge_rate = recharge
	if(charge < max_charge && recharge_rate)
		processing_items |= parent
	RegisterSignal(parent, COMSIG_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_CELL_CHARGE, .proc/charge)
	RegisterSignal(parent, COMSIG_CELL_CAN_CHARGE, .proc/can_charge)
	RegisterSignal(parent, COMSIG_CELL_USE, .proc/use)
	RegisterSignal(parent, COMSIG_CELL_CHECK_CHARGE, .proc/check_charge)
	RegisterSignal(parent, COMSIG_CELL_IS_CELL, .proc/is_cell)
	RegisterSignal(parent, COMSIG_ITEM_PROCESS, .proc/process)


/datum/component/power_cell/InheritComponent(datum/component/power_cell/C, i_am_original, max, start_charge, recharge)
	if(C)
		src.max_charge = C.max_charge
		src.charge = C.charge
		src.recharge_rate = C.recharge_rate
		if(charge < max_charge && recharge_rate)
			processing_items |= parent
	else
		if(isnum_safe(max))
			src.max_charge = max
		if(isnum_safe(start_charge))
			src.charge = start_charge
		if(isnum_safe(recharge))
			src.recharge_rate = recharge


/datum/component/power_cell/proc/attackby(source, obj/item/I, mob/user)
	SEND_SIGNAL(I, COMSIG_CELL_TRY_SWAP, parent, user)

/datum/component/power_cell/proc/can_charge()
	. = CELL_CHARGEABLE

/datum/component/power_cell/proc/charge(source, amount)
	if (amount > 0)
		src.charge = min(src.charge + amount, src.max_charge)

	if (src.charge >= src.max_charge)
		processing_items -= parent
		src.charge = src.max_charge
		. = CELL_FULL
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/use(source, amount, bypass)
	if(src.charge >= amount)
		. = CELL_SUFFICIENT_CHARGE
	else
		. = CELL_INSUFFICIENT_CHARGE

	if(. == CELL_SUFFICIENT_CHARGE || bypass)
		src.charge = max(src.charge - amount, 0)
		if(src.recharge_rate && amount > 0)
			processing_items |= parent

	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)

/datum/component/power_cell/proc/check_charge(source, list/amount)
	if(islist(amount))
		amount["charge"] = charge
		amount["max_charge"] = max_charge
		. = CELL_RETURNED_LIST
	else if(isnum_safe(amount))
		. = (charge >= amount) ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE
	else
		. = charge > 0 ? CELL_SUFFICIENT_CHARGE : CELL_INSUFFICIENT_CHARGE

/datum/component/power_cell/proc/is_cell()
	return TRUE

/datum/component/power_cell/proc/process()
	cycle = !cycle
	if(cycle)
		src.charge(null, recharge_rate)
	SEND_SIGNAL(parent, COMSIG_UPDATE_ICON)
	return
