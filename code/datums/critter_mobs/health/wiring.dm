/datum/healthHolder/wiring
	name = "wiring"
	associated_damage_type = "burn"

	on_attack(var/obj/item/I, var/mob/M)
		if (istype(I, /obj/item/cable_coil))
			var/obj/item/cable_coil/C = I
			var/dmg = maximum_value - value
			if (dmg == 0)
				M.show_message(SPAN_ALERT("Nothing to repair on [holder]!"))
				return 0
			var/amt_req = round(dmg / 5) + 1
			var/amount_to_repair = min(round(dmg/5 + 1), C.amount)
			if(C.use(amount_to_repair))
				HealDamage(amt_req * 5)
				holder.visible_message(SPAN_NOTICE("[M] repairs some wiring on [holder]!"))
			return 0
		return ..()
