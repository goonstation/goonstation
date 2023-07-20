/// skeleton commander rally effect, applied to obj/critters
/datum/statusEffect/skeleton_rallied
	id = "skeleton_rallied"
	desc = "Rallied"
	unique = TRUE
	visible = FALSE
	maxDuration = 25 SECONDS

	onAdd(optional)
		. = ..()
		var/obj/critter/C = owner
		C.atk_delay = (C.atk_delay / 1.5)
		C.atk_brute_amt = (C.atk_brute_amt * 1.5)
		C.atk_burn_amt = (C.atk_burn_amt * 1.5)

	onRemove()
		var/obj/critter/C = owner
		C.atk_delay = (C.atk_delay * 1.5)
		C.atk_brute_amt = (C.atk_brute_amt / 1.5)
		C.atk_burn_amt = (C.atk_burn_amt / 1.5)
		. = ..()
