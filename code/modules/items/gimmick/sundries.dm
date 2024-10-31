/*
･°˖✧ SUNDRIES ✧˖°･
	⋆ Perfume
	⋆ etc.
*/

// Mostly for RP value. Feel free to extend the code or turn this into a reagent container if needed.
/obj/item/perfume
	name = "eau de parfum"
	desc = "A fancy looking eau de parfum bottle with one of those old fashioned atomizers."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "largebottle-labeled"
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	rand_pos = 1
	var/sprays_left = 5

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (sprays_left <= 0)
			return ..()
		var/right_in_the_face = FALSE
		if (user.zone_sel.selecting == "head" || user.bioHolder.HasEffect("clumsy"))
			right_in_the_face = TRUE
			if (!issmokeimmune(target))
				target.emote(pick("choke", "cough", "gasp", "sneeze"))
				target.changeStatus("stunned", 2 SECONDS)
			if (!target.eyes_protected_from_light())
				target.change_eye_blurry(rand(5,10))
		user.visible_message("<span style=\"color:#9a68ff\"><b>[user] [pick("mists", "sprays", "spritzes")] [(target == user) ? himself_or_herself(user) : target] [right_in_the_face ? "right in the face" : ""] with some [src.name].</b></span>")
		target.changeStatus("fragrant", 1 MINUTES)
		src.sprays_left--
		src.UpdateIcon()

	get_desc()
		. += "It appears to [src.sprays_left ? "have some sprays left" : "be empty"]."

	update_icon()
		switch (sprays_left)
			if (-INFINITY to 0)
				src.icon_state = "perfume-empty"
			if (1 to 2)
				src.icon_state = "perfume-dregs"
			if (3 to 4)
				src.icon_state = "perfume-half"
			if (5 to INFINITY)
				src.icon_state = "perfume-full"
