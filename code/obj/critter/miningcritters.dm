// mining related critters

/obj/critter/rockworm
	name = "rock worm"
	desc = "Tough lithovoric worms."
	icon_state = "rockworm"
	density = 0
	health = 80
	aggressive = 1
	defensive = 0
	wanderer = 1
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	atkcarbon = 0
	atksilicon = 0
	firevuln = 0.1
	brutevuln = 1
	angertext = "hisses at"
	death_text = null //has custom death message logic
	butcherable = 1
	var/eaten = 0
	var/const/rocks_per_gem = 10

	seek_target()
		src.anchored = UNANCHORED
		for (var/obj/item/raw_material/C in view(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			src.attack = 1
			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='alert'><b>[src]</b> sees [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	CritterAttack(mob/M)
		src.attacking = 1

		if(istype(M, /obj/item/raw_material/))
			var/obj/item/raw_material/material = M
			src.visible_message("<span class='alert'><b>[src]</b> hungrily eats [src.target]!</span>")
			playsound(src.loc, 'sound/items/eatfood.ogg', 30, 1, -2)
			src.eaten += material.amount
			qdel(src.target)
			src.target = null
			src.task = "thinking"

		src.attacking = 0
		return

	CritterDeath()
		if (!alive) return
		..()
		src.target = null
		src.task = "dead"

		if (src.eaten >= rocks_per_gem)
			src.visible_message("<b>[src]</b> vomits something up and dies!")
		else
			src.visible_message("<b>[src]</b> dies!")

		while (src.eaten >= rocks_per_gem)
			var/pickgem = rand(1,3)
			var/obj/item/created = null
			switch(pickgem)
				if(1) created = new /obj/item/raw_material/gemstone
				if(2) created = new /obj/item/raw_material/uqill
				if(3) created = new /obj/item/raw_material/fibrilith
			created.set_loc(src.loc)
			src.eaten -= rocks_per_gem

/obj/critter/rockworm/gary
	name = "Gary the rockworm"
