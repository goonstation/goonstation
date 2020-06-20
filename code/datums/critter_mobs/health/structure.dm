/datum/healthHolder/structure
	name = "structural"
	associated_damage_type = "brute"

	on_attack(var/obj/item/I, var/mob/M)
		if (isweldingtool(I))
			if (I:try_weld(M,0))
				if (damaged())
					holder.visible_message("<span class='notice'>[M] repairs some dents on [holder]!</span>")
					HealDamage(5)
				else
					M.show_message("<span class='alert'>Nothing to repair on [holder]!")
				return 0
		return ..()
