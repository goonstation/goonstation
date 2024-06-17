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
		boutput(holder.owner, SPAN_ALERT("[fe.get_damage()] damage."))
		if (fe.get_damage() < 100)
			boutput(fe, SPAN_ALERT("You must be in perfect health to self-immolate!"))
			return 1

		fe.TakeDamage("All", 50, 0, 0, DAMAGE_BLUNT)
		holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner] self immolates! [fe]!</b>"))

		// fireflash(get_turf(fe), 1, checkLos = FALSE, chemfire = CHEM_FIRE_BLUE)
		var/T = get_turf(fe)
		new /obj/hotspot/chemfire(T,  CHEM_FIRE_DARKRED)

		var/dir = fe.dir
		var/T1 = null
		var/T2 = null
		if (dir == NORTH || dir == SOUTH)
			T1 = get_step(T, EAST)
			T2 = get_step(T, WEST)
		else if( dir == EAST || dir == WEST)
			T1 = get_step(T, NORTH)
			T2 = get_step(T, SOUTH)
		else
			return 1
		new /obj/hotspot/chemfire(T1,  CHEM_FIRE_DARKRED)
		new /obj/hotspot/chemfire(T2,  CHEM_FIRE_DARKRED)

		return 0


