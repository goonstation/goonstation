
/obj/item/reagent_containers/food/snacks/ice_cream_cone
	name = "ice cream cone"
	desc = "A cone designed in 1937 by members of FDR's brain trust.  Its purpose? To hold as much ice cream as possible."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "icecream"
	bites_left = 1

/obj/item/reagent_containers/food/snacks/ice_cream
	name = "ice cream"
	desc = "You scream, I scream, we all scream, but nobody hears it.  This is space."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "icecream"
	real_name = "ice cream"
	bites_left = 4
	heal_amt = 4
	fill_amt = 3
	food_color = null
	var/flavor_name = null
	var/image/cream_image = null
	initial_volume = 40
	initial_reagents = list("cream" = 10)
	food_effects = list("food_cold")
	use_bite_mask = FALSE

	on_reagent_change()
		..()
		src.update_cone()
		src.UpdateName()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.flavor_name ? "[src.flavor_name]-flavored " : null][src.real_name][name_suffix(null, 1)]"

	proc/update_cone()
		src.flavor_name = src.reagents.get_master_reagent_name()
		src.food_color = src.reagents.get_master_color()
		if (!src.cream_image)
			src.cream_image = image(src.icon)
		var/cream_level = (100 * round(src.bites_left/src.uneaten_bites_left,0.25))
		if (!src.food_color)
			src.food_color = src.reagents.get_master_color()
		src.cream_image.icon_state = "ice[cream_level]"
		src.cream_image.color = src.food_color
		src.UpdateOverlays(src.cream_image, "cream")

	heal(var/mob/M)
		..()
		M.bodytemperature = min(M.base_body_temp, M.bodytemperature-20)
		if(!QDELETED(src))
			src.update_cone()

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		var/icecount = 0
		if (istype(user.l_hand,/obj/item/reagent_containers/food/snacks/ice_cream) && user.l_hand:bites_left)
			var/obj/item/reagent_containers/food/snacks/ice_cream/I = user.l_hand
			icecount += I.bites_left
			I.bites_left = 1
			I.update_cone()
		if (istype(user.r_hand,/obj/item/reagent_containers/food/snacks/ice_cream) && user.r_hand:bites_left)
			var/obj/item/reagent_containers/food/snacks/ice_cream/I = user.r_hand
			icecount += I.bites_left
			I.bites_left = 1
			I.update_cone()
		if (!icecount)
			return
		user.visible_message(SPAN_ALERT("<b>[user] eats the ice cream in one bite and collapses from brainfreeze!</b>"))
		user.TakeDamage("head", 0, 50 * icecount)
		user.changeStatus("unconscious", icecount SECONDS) //in case the damage isn't enough to crit
		user.changeBodyTemp(-100 KELVIN)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/reagent_containers/food/snacks/ice_cream/gross
	initial_reagents = "vomit"

/obj/item/reagent_containers/food/snacks/ice_cream/random
	New()
		..()
		SPAWN(0)
			if (src.reagents)
				var/flavor = null
				if (length(all_functional_reagent_ids) > 1)
					flavor = pick(all_functional_reagent_ids)
				else
					flavor = "vanilla"
				src.reagents.add_reagent(flavor, 40)

/obj/item/reagent_containers/food/snacks/ice_cream/goodrandom
	New()
		src.initial_reagents = pick("coffee","chocolate","vanilla")
		..()

/obj/item/reagent_containers/food/snacks/yoghurt
	name = "yoghurt"
	desc = "A plain yoghurt."
	icon = 'icons/obj/foodNdrink/food_snacks.dmi'
	icon_state = "yoghurt"
	required_utensil = REQUIRED_UTENSIL_SPOON
	bites_left = 4
	heal_amt = 1
	initial_volume = 25
	initial_reagents = list("yoghurt"=10)
	food_effects = list("food_disease_resist")

/obj/item/reagent_containers/food/snacks/yoghurt/frozen
	name = "frozen yoghurt"
	desc = "A delightful tub of frozen yoghurt."
	heal_amt = 2
	initial_volume = 25
	initial_reagents = list("yoghurt"=10, "cryostylane"=5)
	food_effects = list("food_cold", "food_disease_resist")
