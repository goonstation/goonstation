/datum/targetable/critter/self_immolate
	name = "Self Immolate"
	desc = "Expend 20% of your current health to create a permanent fire that gives off healing embers."
	icon_state = "fire_e_immolate"

	cooldown = 25 SECONDS
	targeted = FALSE

	cast()
		if (..())
			return 1


		var/mob/fe = holder.owner
		// boutput(holder.owner, SPAN_ALERT("[fe.get_damage()] damage."))
		if (fe.get_damage() < 0)
			boutput(fe, SPAN_ALERT("You must be in good health to self-immolate!"))
			return 1

		var/damage_dealt = fe.get_damage() * 0.2
		fe.TakeDamage("All", damage_dealt, 0, 0, DAMAGE_BLUNT)
		holder.owner.visible_message(SPAN_NOTICE("<b>[holder.owner] self immolates!</b>"))

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

		//Make flame on tile we're standing on
		var/obj/hotspot/chemfire/cf = locate(/obj/hotspot/chemfire) in T
		if (cf == null || cf.fire_color != CHEM_FIRE_DARKRED)
			new /obj/hotspot/chemfire(T,  CHEM_FIRE_DARKRED)

		//Make flame on tile to the East/West or North/South
		var/obj/hotspot/chemfire/o = new /obj/hotspot/chemfire(T,  CHEM_FIRE_DARKRED)
		o.set_real_color()
		spawn(1)
			handle_fire_spread(T, T1, o)
		var/obj/hotspot/chemfire/o1 = new /obj/hotspot/chemfire(T,  CHEM_FIRE_DARKRED)
		o1.set_real_color()
		spawn(1)
			handle_fire_spread(T, T2, o1)
		return 0


	proc/handle_fire_spread(turf/Source, turf/Destination, obj/fire)
		fire.set_loc(Destination)
		if (get_turf(fire) == Source)
			qdel(fire)
		// If tile it moves to has a darkred chemfire, then delete this
		if (get_turf(fire) == Destination)
			for(var/obj/hotspot/chemfire/cf in  Destination)
				if (cf == fire) continue
				if (cf.fire_color == CHEM_FIRE_DARKRED)
					qdel(fire)
					break;

