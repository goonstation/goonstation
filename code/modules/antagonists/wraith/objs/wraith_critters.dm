/obj/critter/mouse/mad/ratden
	var/obj/machinery/wraith/rat_den/linked_den = null

	CritterDeath()
		..()
		if(linked_den.linked_critters > 0)
			linked_den.linked_critters--
