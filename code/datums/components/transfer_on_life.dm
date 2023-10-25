TYPEINFO(/datum/component/holdertargeting/transfer_on_life)
	initialization_args = list(
		ARG_INFO("trans_amt", DATA_INPUT_NUM, "amount of reagent to try to transfer each Life tick", 5)
	)

/datum/component/holdertargeting/transfer_on_life
	dupe_mode = COMPONENT_DUPE_ALLOWED
	signals = list(COMSIG_LIVING_LIFE_TICK)
	proctype = PROC_REF(on_life)
	keep_while_on_mob = TRUE
	var/amount_to_transfer = 5

/datum/component/holdertargeting/transfer_on_life/Initialize(trans_amt=5)
	if (!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	amount_to_transfer = trans_amt

/datum/component/holdertargeting/transfer_on_life/proc/on_life(mob/living/L, mult)
	var/obj/item/item = parent
	item.reagents?.trans_to(L, amount_to_transfer * mult)
