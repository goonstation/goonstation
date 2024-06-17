/datum/targetable/critter/self_immolate
	name = "Self Immolate"
	desc = "Expend some of your health to create a permanent fire that gives off healing embers."
	icon_state = "fire_e_immolate"

	cooldown = 15 SECONDS
	targeted = FALSE


	cast()
		if (..())
			return 1


		var/mob/fe = holder.owner
		// boutput(holder.owner, SPAN_ALERT("[fe.get_damage()] damage."))
		if (fe.get_damage() < 100)
			boutput(fe, SPAN_ALERT("You must be in good health to self-immolate!"))
			return 1

		fe.TakeDamage("All", 50, 0, 0, DAMAGE_BLUNT)
		holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner] self immolates! [fe]!</b>"))

		// fireflash(get_turf(fe), 1, checkLos = FALSE, chemfire = CHEM_FIRE_BLUE)
		var/T = get_turf(fe)


		var/dir = fe.dir
		var/turf/T1 = null
		var/turf/T2 = null
		// Get the turfs to the East/West or North/South of the mob based on the direction its facing
		if (dir == NORTH || dir == SOUTH)
			T1 = get_step(T, EAST)
			T2 = get_step(T, WEST)
		else if( dir == EAST || dir == WEST)
			T1 = get_step(T, NORTH)
			T2 = get_step(T, SOUTH)
		else
			return 1

		var/obj/hotspot/chemfire/cf = locate(/obj/hotspot/chemfire) in T
		if (cf == null || cf.fire_color != CHEM_FIRE_DARKRED)
			new /obj/hotspot/chemfire(T,  CHEM_FIRE_DARKRED)

		cf = locate(/obj/hotspot/chemfire) in T1
		if (cf == null || cf.fire_color != CHEM_FIRE_DARKRED)
			new /obj/hotspot/chemfire(T1,  CHEM_FIRE_DARKRED)

		cf = locate(/obj/hotspot/chemfire) in T2
		if (cf == null || cf.fire_color != CHEM_FIRE_DARKRED)
			new /obj/hotspot/chemfire(T2,  CHEM_FIRE_DARKRED)

		return 0


