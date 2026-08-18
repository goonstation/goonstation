//abstracts
ABSTRACT_TYPE(/obj/item/cane)
/obj/item/cane
	name = "cane"
	desc = "A handy walking stick for people who can't walk very well anymore, or just like to beat people with sticks."
	icon = 'icons/obj/canes.dmi'
	icon_state = "metal"
	inhand_image_icon = 'icons/mob/inhand/hand_canes.dmi'
	hitsound = 'sound/impact_sounds/bat_wood.ogg' // Bonk bonk bonk!
	hit_type = DAMAGE_BLUNT

	force = 5
	throwforce = 7
	throw_speed = 1
	stamina_damage = 55
	stamina_cost = 23
	stamina_crit_chance = 10
	var/can_tap = TRUE

	attack_self(mob/user)
		. = ..()
		if (!src.can_tap)
			return

		var/turf/T = get_turf(user)
		// if we cant reach the tile for some reason
		if (!T || istype(T,/turf/space) || T != user.loc)
			return

		// if we're floating for some god awful reason
		if (user.no_gravity ||  HAS_ATOM_PROPERTY(user, PROP_ATOM_FLOATING))
			return

		if (!ON_COOLDOWN(src,"cane_tap",5 SECONDS))

			var/flags = T?.material?.getMaterialFlags()
			if (flags & MATERIAL_WOOD)
				playsound(src, 'sound/impact_sounds/Wood_Tap.ogg', 50, TRUE,pitch=0.3)
			else if (flags & MATERIAL_METAL)
				playsound(src,'sound/impact_sounds/metal_thump.ogg', 50, TRUE)
			else
				if (T.step_material)
					playsound(src,"[T.step_material]", 50, TRUE)
				else
					playsound(src,'sound/impact_sounds/metal_thump.ogg', 50, TRUE)


			user.visible_message(SPAN_ALERT("[user] taps \the [src] on \the [T]!"),group="cane_tap")

// Wood crafted below!

/obj/item/cane/wooden
	icon_state = "wooden"
	mat_changename = FALSE
	mat_changeappearance = FALSE
	default_material = "wood"
	material_amt = 0.1

/obj/item/cane/wooden/wooden2
	icon_state = "wooden2"

/obj/item/cane/wooden/wooden3
	icon_state = "wooden3"

/obj/item/cane/wooden/black
	icon_state = "black"

// Medbay fabricated below!

/obj/item/cane/metal
	icon_state = "metal"

/obj/item/cane/metal/fourlegged
	icon_state = "fourlegged"
	can_tap = FALSE

/obj/item/cane/metal/tennisball
	icon_state = "tennisball"
	desc = "Perfect when you need a million balloons!"
	can_tap = FALSE // too padded

// Geoff's funny canes below!
ABSTRACT_TYPE(/obj/item/cane/silly)

/obj/item/cane/silly/clown
	name = "clown cane"
	icon_state = "clown"
	desc = "My back feels funny."
	can_tap = FALSE

/obj/item/cane/silly/mime
	name = "mime cane"
	icon_state = "mime"
	desc = "Suffering in silence."
	can_tap = FALSE

/obj/item/cane/silly/princess
	name = "pink cane"
	icon_state = "princess"
	desc = "Sparkle! Glimmer! Back pain! Sparkle!"
	can_tap = FALSE

// Cargo exclusive below!

/obj/item/cane/golden
	name = "golden cane"
	icon_state = "golden"
	mat_changename = FALSE
	default_material = "gold"
	desc = "Now your grandkids won't call you for sure."
