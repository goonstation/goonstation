/datum/abilityHolder/skeleton
	usesPoints = FALSE
	regenRate = 0

/datum/targetable/skeletonAbility
	icon = 'icons/mob/genetics_powers.dmi'
	icon_state = "skeleton"
	cooldown = 0
	last_cast = 0
	targeted = 0
	preferred_holder_type = /datum/abilityHolder/skeleton
	var/mob/living/carbon/human/L

	onAttach(datum/abilityHolder/H)
		. = ..()
		if(ishuman(holder.owner))
			L = holder.owner
		return

/datum/targetable/skeletonAbility/remove_head
	name = "Remove head"
	desc = "Remove your head. If your hands are full, drop it on the floor."
	cooldown = 30 SECONDS
	targeted = 0

	cast()
		if (..())
			return 1

		if (!istype(L.mutantrace, /datum/mutantrace/skeleton) || !L.organHolder.head)
			boutput(L, SPAN_NOTICE("You don't have a head!"))
			return 1

		var/obj/item/organ/head/H = L.organHolder.drop_organ("head")
		L.visible_message(SPAN_ALERT("<b>[L]</b> takes their head off!"))
		L.put_in_hand_or_eject(H)
		playsound(L, 'sound/items/capsule_pop.ogg', 50, TRUE)
