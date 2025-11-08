TYPEINFO(/datum/component/contraband)
	initialization_args = list(
		ARG_INFO("contraband_level", DATA_INPUT_NUM, "Non-firearm Contraband level this item will have", 0),
		ARG_INFO("carry_level", DATA_INPUT_NUM, "Firearm Contraband level this item will have", 0),
	)

/datum/component/contraband/Initialize(contraband_level = 0, carry_level = 0)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/AM = parent

	SEND_SIGNAL(AM, COMSIG_MOVABLE_CONTRABAND_CHANGED, FALSE)

	APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_VISIBLE_GUNS, src, carry_level)
	APPLY_ATOM_PROPERTY(AM, PROP_MOVABLE_VISIBLE_CONTRABAND, src, contraband_level)

	RegisterSignal(AM, COMSIG_MOVABLE_CONTRABAND_CHANGED, PROC_REF(visible_contraband_changed))

	if (isitem(AM))
		RegisterSignal(AM, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_PICKUP), PROC_REF(equipped))
		RegisterSignals(AM, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(removed))

	src.visible_contraband_changed(AM)

/datum/component/contraband/proc/visible_contraband_changed(atom/owner, self_applied = FALSE)
	if(self_applied)
		src.contraband_logic(owner, owner)
	else
		if(isitem(owner) && ismob(owner.loc))
			var/obj/item/I = owner
			var/mob/M = I.loc
			//if this component gives contraband porperties to the carrier of the item, we should update these as well
			if (HAS_ATOM_PROPERTY_FROM_SOURCE(M,PROP_MOVABLE_VISIBLE_CONTRABAND, src) || HAS_ATOM_PROPERTY_FROM_SOURCE(M,PROP_MOVABLE_VISIBLE_GUNS, src))
				src.equipped(I, M, I.equipped_in_slot)

		else if(ismovable(owner.loc))
			var/atom/movable/AM = owner.loc
			src.contraband_logic(owner, AM)
		else if (istype(owner, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner
			H.update_arrest_icon()

/datum/component/contraband/proc/contraband_logic(atom/movable/owner, atom/movable/applied, multiplier = 1)
	REMOVE_ATOM_PROPERTY(applied, PROP_MOVABLE_VISIBLE_GUNS, src)
	REMOVE_ATOM_PROPERTY(applied, PROP_MOVABLE_VISIBLE_CONTRABAND, src)

	var/has_contra_override = HAS_ATOM_PROPERTY(owner,PROP_MOVABLE_CONTRABAND_OVERRIDE)

	var/contra_guns = GET_ATOM_PROPERTY(owner,PROP_MOVABLE_VISIBLE_GUNS)
	if(contra_guns)
		APPLY_ATOM_PROPERTY(applied, PROP_MOVABLE_VISIBLE_GUNS, src, (has_contra_override ? GET_ATOM_PROPERTY(owner,PROP_MOVABLE_CONTRABAND_OVERRIDE) : contra_guns) * multiplier)
		has_contra_override = FALSE

	var/contra_nonguns = GET_ATOM_PROPERTY(owner,PROP_MOVABLE_VISIBLE_CONTRABAND)
	if(contra_nonguns || has_contra_override)
		APPLY_ATOM_PROPERTY(applied, PROP_MOVABLE_VISIBLE_CONTRABAND, src, (has_contra_override ? GET_ATOM_PROPERTY(owner,PROP_MOVABLE_CONTRABAND_OVERRIDE) : contra_nonguns) * multiplier)

	SEND_SIGNAL(applied, COMSIG_MOVABLE_CONTRABAND_CHANGED, FALSE)

/datum/component/contraband/proc/equipped(obj/item/owner, mob/user, slot = null)
	var/slot_mult = 1
	if (slot && ishuman(user))
		slot_mult = 0
		if (slot in list(SLOT_BACK, SLOT_BELT, SLOT_GLASSES, SLOT_GLOVES, SLOT_EARS))
			slot_mult = 0.5
		else if (slot in list(SLOT_L_HAND, SLOT_R_HAND, SLOT_WEAR_MASK, SLOT_HEAD, SLOT_SHOES, SLOT_WEAR_SUIT, SLOT_W_UNIFORM))
			slot_mult = 1

	src.contraband_logic(owner, user, slot_mult)

/datum/component/contraband/proc/removed(obj/item/owner, mob/user)
	REMOVE_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_GUNS, src)
	REMOVE_ATOM_PROPERTY(user, PROP_MOVABLE_VISIBLE_CONTRABAND, src)

	SEND_SIGNAL(user, COMSIG_MOVABLE_CONTRABAND_CHANGED, FALSE)

/datum/component/contraband/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOVABLE_CONTRABAND_CHANGED)

	if (isitem(parent))
		var/obj/item/I = parent
		if (ismob(I.loc))
			var/mob/M = I.loc
			src.removed(I, M)
		UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_PICKUP, COMSIG_ITEM_DROPPED))

	else if(ismovable(parent))
		var/atom/movable/AM = parent
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_VISIBLE_GUNS, src)
		REMOVE_ATOM_PROPERTY(AM, PROP_MOVABLE_VISIBLE_CONTRABAND, src)
		SEND_SIGNAL(AM, COMSIG_MOVABLE_CONTRABAND_CHANGED, FALSE)
