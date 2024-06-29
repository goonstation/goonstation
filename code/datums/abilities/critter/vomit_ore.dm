// Rockworm vomit

/datum/targetable/critter/vomit_ore
	name = "Vomit ore"
	desc = "Throw up a piece of raw ore"
	icon_state = "puke"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/T)
		. = ..()
		var/mob/living/critter/C = holder.owner
		if (istype(C, /mob/living/critter/rockworm))
			var/mob/living/critter/rockworm/worm = C
			if (worm.eaten < worm.rocks_per_gem)
				boutput(worm, SPAN_ALERT("You don't feel full enough to vomit."))
				return
			worm.eaten -= worm.rocks_per_gem
		var/obj/item/created
		var/pickgem = rand(1,3)
		switch(pickgem)
			if(1) created = /obj/item/raw_material/gemstone
			if(2) created = /obj/item/raw_material/uqill
			if(3) created = /obj/item/raw_material/fibrilith
		var/obj/item/raw_material/ammo = new created(C.loc)
		ammo.throw_at(T, 32, 4)
		doCooldown()

		C.visible_message(SPAN_ALERT("<b>[C] vomits up \a [ammo]!</b>"))
