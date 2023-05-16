// Rockworm vomit

/datum/targetable/critter/vomit_ore
	name = "Vomit ore"
	desc = "Throw out a piece of raw ore"
	icon_state = "puke"
	cooldown = 30 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/T)
		var/obj/obj/item/raw_material/ammo
		var/mob/living/critter/rockworm/C = holder.owner
		var/pickgem = rand(1,3)
		switch(pickgem)
			if(1) ammo = new /obj/item/raw_material/gemstone
			if(2) ammo = new /obj/item/raw_material/uqill
			if(3) ammo = new /obj/item/raw_material/fibrilith
		C.visible_message("<b><span class='alert'>[C] vomits up a piece of [created]!</span></b>")
		C.eaten -= C.rocks_per_gem
		ammo.set_loc(src.loc)
		ammo.throw_at(T, 32, 2)
		doCooldown()
