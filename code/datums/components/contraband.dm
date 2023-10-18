TYPEINFO(/datum/component/contraband)
	initialization_args = list(
		ARG_INFO("contraband_level", DATA_INPUT_NUM, "Non-firearm Contraband level this item will have", 0),
		ARG_INFO("carry_level", DATA_INPUT_NUM, "Firearm Contraband level this item will have", 0),
	)

/datum/component/contraband
	var/contraband_level = 0
	var/carry_level = 0

/datum/component/contraband/Initialize(contraband_level = 0, carry_level = 0)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/AM = parent
	RegisterSignal(AM, COMSIG_MOVABLE_GET_CONTRABAND, PROC_REF(get_contraband))
	SEND_SIGNAL(AM, COMSIG_MOVABLE_CONTRABAND_CHANGED)
	src.contraband_level = contraband_level
	src.carry_level = carry_level
	RegisterSignal(parent, COMSIG_MOVABLE_CONTRABAND_CHANGED, PROC_REF(visible_contraband_changed))
	if (isitem(AM))
		var/obj/item/I = AM
		if (ismob(I.loc) && I.equipped_in_slot)
			var/mob/M = I.loc
			src.equipped(I, M, I.equipped_in_slot)
		RegisterSignal(AM, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
		RegisterSignal(AM, COMSIG_ITEM_PICKUP, PROC_REF(picked_up))
		RegisterSignals(AM, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(removed))
	src.visible_contraband_changed(AM)

/datum/component/contraband/proc/get_contraband(atom/owner, var/list/return_val, nonfirearms = TRUE, firearms = TRUE)
	if (!islist(return_val))
		return FALSE
	var/return_contraband = 0
	if (nonfirearms && firearms)
		return_contraband += HAS_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) ? GET_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) : (src.contraband_level + src.carry_level)
		return_contraband += GET_ATOM_PROPERTY(owner, PROP_MOVABLE_VISIBLE_CONTRABAND)
		return_contraband += GET_ATOM_PROPERTY(owner, PROP_MOVABLE_VISIBLE_GUNS)
		return_val += return_contraband
		return TRUE
	if (nonfirearms)
		return_contraband += HAS_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) ? GET_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) : src.contraband_level
		return_contraband += GET_ATOM_PROPERTY(owner, PROP_MOVABLE_VISIBLE_CONTRABAND)
		return_val += return_contraband
		return TRUE
	if (firearms)
		if (src.carry_level)
			return_contraband += HAS_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) ? GET_ATOM_PROPERTY(owner, PROP_MOVABLE_CONTRABAND_OVERRIDE) : src.carry_level
		return_contraband += GET_ATOM_PROPERTY(owner, PROP_MOVABLE_VISIBLE_GUNS)
		return_val += return_contraband
		return TRUE
	return FALSE

/datum/component/contraband/proc/visible_contraband_changed(atom/owner)
	if (ismovable(owner.loc))
		SEND_SIGNAL(owner.loc, COMSIG_MOVABLE_CONTRABAND_CHANGED)

/datum/component/contraband/proc/equipped(obj/item/owner, mob/user, slot)
	var/slot_mult = 1
	if (slot && ishuman(user))
		slot_mult = 0
		if (slot in list(SLOT_BACK, SLOT_BELT, SLOT_GLASSES, SLOT_GLOVES))
			slot_mult = 0.5
		else if (slot in list(SLOT_L_HAND, SLOT_R_HAND, SLOT_WEAR_MASK, SLOT_HEAD, SLOT_SHOES, SLOT_WEAR_SUIT))
			slot_mult = 1
	var/list/contraband_returned = list()
	src.get_contraband(owner, contraband_returned, FALSE, TRUE)
	APPLY_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_GUNS, src, max(contraband_returned) * slot_mult)
	contraband_returned = list()
	src.get_contraband(owner, contraband_returned, TRUE, FALSE)
	APPLY_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_CONTRABAND, src, max(contraband_returned) * slot_mult)
	SEND_SIGNAL(user, COMSIG_MOVABLE_CONTRABAND_CHANGED)

/datum/component/contraband/proc/picked_up(obj/item/owner, mob/user)
	var/list/contraband_returned = list()
	src.get_contraband(owner, contraband_returned, FALSE, TRUE)
	APPLY_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_GUNS, src, max(contraband_returned))
	contraband_returned = list()
	src.get_contraband(owner, contraband_returned, TRUE, FALSE)
	APPLY_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_CONTRABAND, src, max(contraband_returned))
	SEND_SIGNAL(user, COMSIG_MOVABLE_CONTRABAND_CHANGED)

/datum/component/contraband/proc/removed(obj/item/owner, mob/user)
	REMOVE_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_GUNS, src)
	REMOVE_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_CONTRABAND, src)
	SEND_SIGNAL(user, COMSIG_MOVABLE_CONTRABAND_CHANGED)

/datum/component/contraband/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOVABLE_GET_CONTRABAND)
	UnregisterSignal(parent, COMSIG_MOVABLE_CONTRABAND_CHANGED)
	SEND_SIGNAL(parent, COMSIG_MOVABLE_CONTRABAND_CHANGED)
	if (isitem(parent))
		var/obj/item/I = parent
		if (ismob(I.loc))
			var/mob/M = I.loc
			src.removed(I, M)
		UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)
		UnregisterSignal(parent, COMSIG_ITEM_UNEQUIPPED)
		UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))

