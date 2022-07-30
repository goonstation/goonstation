/// Super simple CC. Short-ranged elecflash.
/datum/targetable/arcfiend/elecflash
	name = "Flash"
	desc = "Release a sudden burst of power around yourself, disorienting nearby creatures."
	icon_state = "flash"
	cooldown = 10 SECONDS
	pointCost = 25
	container_safety_bypass = TRUE

	cast(atom/target)
		. = ..()
		elecflash(holder.owner, 2, 6, TRUE)
