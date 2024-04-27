/datum/aiHolder/patroller/packet_based/securitron/New()
	. = ..()
	default_task = get_instance(/datum/aiTask/sequence/patrol/packet_based/securitron, list(src))

/datum/aiTask/sequence/patrol/packet_based/securitron
	combat_interrupt_type = /datum/aiTask/sequence/goalbased/critter/securitron_attack

/// A variant of attack that knows how to use batons
/datum/aiTask/sequence/goalbased/critter/securitron_attack
	name = "enforcing"
	weight = 10 // shouldnt matter in patrol, but who knows what this might be used for
	ai_turbo = TRUE // attack behaviour gets a speed boost for robustness
	max_dist = 7

/datum/aiTask/sequence/goalbased/critter/securitron_attack/New(parentHolder, transTask)
	..(parentHolder, transTask)
	add_task(holder.get_instance(/datum/aiTask/succeedable/critter/attack, list(holder)))

/datum/aiTask/sequence/goalbased/critter/securitron_attack/precondition()
	var/mob/living/critter/C = holder.owner
	return C.can_critter_attack()

/datum/aiTask/sequence/goalbased/critter/securitron_attack/on_reset()
	..()
	var/mob/living/critter/C = holder.owner
	if(C)
		C.set_a_intent(INTENT_DISARM)

/datum/aiTask/sequence/goalbased/critter/securitron_attack/get_targets()
	var/mob/living/critter/C = holder.owner
	return C.seek_target(src.max_dist)

/datum/aiTask/sequence/goalbased/critter/securitron_attack/on_tick()
	..()
	var/obj/item/I = src.holder.owner.equipped()
	if (I && istype(I,/obj/item/baton))
		var/obj/item/baton/baton = I
		if (!baton.is_active)
			baton.AttackSelf(src.holder.owner)

	if (src.target in holder.owner.grabbed_by)
		holder.owner.resist()
