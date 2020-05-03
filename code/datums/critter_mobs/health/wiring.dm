/datum/healthHolder/wiring
	name = "wiring"
	associated_damage_type = "burn"

	on_attack(var/obj/item/I, var/mob/M)
		if (istype(I, /obj/item/cable_coil))
			var/obj/item/cable_coil/C = I
			var/dmg = maximum_value - value
			if (dmg == 0)
				M.show_message("<span class='alert'>Nothing to repair on [holder]!")
				return 0
			var/amt_req = round(dmg / 5) + 1
			if (amt_req >= C.amount)
				HealDamage(C.amount * 5)
				holder.visible_message("<span class='notice'>[M] repairs some wiring on [holder]!</span>")
				M.show_message("<span class='alert'>Your [C] runs out!</span>")
				C.amount = 0
				qdel(C)
			else
				C.use(amt_req)
				HealDamage(amt_req * 5)
				holder.visible_message("<span class='notice'>[M] repairs some wiring on [holder]!</span>")
			return 0
		return ..()
