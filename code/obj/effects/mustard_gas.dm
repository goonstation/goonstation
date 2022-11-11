/////////////////////////////////////////////
// Mustard Gas
/////////////////////////////////////////////


/obj/effects/mustard_gas
	name = "mustard gas"
	icon_state = "mustard"
	opacity = 1
	anchored = 0
	mouse_opacity = 0
	var/amount = 6

/obj/effects/mustard_gas/New()
	..()
	SPAWN(10 SECONDS)
		dispose()
	return

/obj/effects/mustard_gas/Move()
	. = ..()
	for(var/mob/living/carbon/human/R in get_turf(src))
		if (R.internal != null && R.wear_mask && (R.wear_mask.c_flags & MASKINTERNALS))
		else
			R.TakeDamage("chest", 0, 10)
			R.losebreath = max(5, R.losebreath)
			R.emote("scream")
			if (prob(25))
				R.changeStatus("stunned", 1 SECOND)
	return

/obj/effects/mustard_gas/Crossed(atom/movable/AM)
	..()
	if (ishuman(AM))
		var/mob/living/carbon/human/R = AM
		if (R.internal != null && R.wear_mask && (R.wear_mask.c_flags & MASKINTERNALS))
			return
		R.losebreath = max(5, R.losebreath)
		R.TakeDamage("chest", 0, 10)
		R.emote("scream")
		if (prob(25))
			R.changeStatus("stunned", 1 SECOND)
	return
