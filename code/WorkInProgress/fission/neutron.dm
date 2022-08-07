/obj/machinery/fission/neutron_injector

	icon = 'icons/obj/machines/nuclear.dmi'
	icon_state = "neutinj"

	name = "neutron injector"
	anchored = 1
	density = 1

	var/obj/item/rod/insertedRod = null

	attack_hand(mob/user)
		if(insertedRod)
			insertedRod.set_loc(src.loc)
			insertedRod = null
		return

	update_icon()
		if(status & NOPOWER)
			icon_state = "neutinj"
			return
		if(insertedRod)
			icon_state = "neutinjon"
		else
			icon_state = "neutinj"

	process()
		UpdateIcon()

		if(status & NOPOWER)
			return

		if(insertedRod)
			if(prob(0.1))
				refineRod()

	proc/refineRod()
		// Creates U239
		if(istype(insertedRod, /obj/item/rod/fuel/uranium/depleted))
			qdel(insertedRod)
			insertedRod = new /obj/item/rod/fuel/uranium/TwoThreeNine(src)

		// Creates Pu240
		if(istype(insertedRod, /obj/item/rod/fuel/plutonium/TwoThreeNine))
			qdel(insertedRod)
			insertedRod = new /obj/item/rod/fuel/plutonium/TwoFourZero(src)

		// Creates Pu241
		if(istype(insertedRod, /obj/item/rod/fuel/plutonium/TwoFourZero))
			qdel(insertedRod)
			insertedRod = new /obj/item/rod/fuel/plutonium/TwoFourOne(src)


	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/rod))
			if(!insertedRod)
				insertedRod = W
				// Unequipping
				user.u_equip(W)
				W.set_loc(src)
				W.dropped(user)
				// Letting everyone around know
				boutput(user, "<span class='alert'>You insert the [W] into the [src].</span>")
				for(var/mob/M in AIviewers(src))
					if(M == user)	continue
					M.show_message("<span class='alert'>[user.name] inserts the [W] into the [src].</span>")
				return
			else
				boutput(user, "<span class='alert'>No more rods can fit into the neutron injector.</span>")
		else
			src.add_fingerprint(user)
			boutput(user, "<span class='alert'>You hit the [src.name] with your [W.name]!</span>")
			for(var/mob/M in AIviewers(src))
				if(M == user)	continue
				M.show_message("<span class='alert'>The [src.name] has been hit with the [W.name] by [user.name]!</span>")

// Neutron
/datum/projectile/neutron
	name = ""
	// This won't have any icon
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "laser"

//How much of a punch this has, tends to be seconds/damage before any resist
	power = 200
//How much ammo this costs
	cost = 0
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//Kill/Stun ratio
	ks_ratio = 1
//name of the projectile setting, used when you change a guns setting
	sname = "neutron"
//file location for the sound you want it to play
	shot_sound = null
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1

	damage_type = D_RADIOACTIVE
	//With what % do we hit mobs laying down
	hit_ground_chance = 50
	//Can we pass windows
	window_pass = 0

//Any special things when it hits shit?

	on_hit(atom/hit)
		return
