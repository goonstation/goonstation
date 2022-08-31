/datum/component/transfer_on_attack
	var/trans_amt = 5

TYPEINFO(/datum/component/transfer_on_attack)
	initialization_args = list(
		ARG_INFO("trans_amt", DATA_INPUT_NUM, "amount of reagent to try to transfer", 5)
	)
/datum/component/transfer_on_attack/Initialize(var/trans_amt)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	if(trans_amt)
		src.trans_amt=trans_amt
	RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_POST), .proc/stab_transfer)

/datum/component/transfer_on_attack/proc/stab_transfer(var/obj/item/I, var/mob/M, var/mob/user, var/damage)
	if (I.reagents && I.reagents.total_volume)
		logTheThing(LOG_COMBAT, user, "used [I] on [constructTarget(M,"combat")] (<b>Intent</b>: <i>[user.a_intent]</i>) (<b>Targeting</b>: <i>[user.zone_sel.selecting]</i>) [log_reagents(I)]")
		I.reagents.trans_to(M, trans_amt * damage / 10) //amount transferred is based on damage dealt

/datum/component/transfer_on_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_POST)
	. = ..()
