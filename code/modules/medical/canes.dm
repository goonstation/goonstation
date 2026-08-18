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

	/// sound volume for cane tap
	var/tap_volume = 70

	proc/do_tap(turf/T, mob/user)

		var/flags = T?.material?.getMaterialFlags()

		// make absolutely sure we're playing glass sounds when we should, they use wood step sounds
		var/isglass = istype(T, /turf/unsimulated/floor/glassblock) || istype(T, /turf/simulated/floor/glassblock) || istype(T,/turf/simulated/floor/auto/glassblock)

		if (T.step_material == "step_plating" || flags & MATERIAL_METAL)
			var/metal_sound = pick('sound/impact_sounds/metal_thump.ogg','sound/impact_sounds/Metal_Hit_Lowfi_1.ogg')
			playsound(src, metal_sound, src.tap_volume, TRUE)

		else if (isglass || flags & MATERIAL_CRYSTAL)
			playsound(src,'sound/impact_sounds/Crystal_Hit_1.ogg', src.tap_volume, TRUE, pitch = 0.7)

		else if (T.step_material == "step_wood" || flags & MATERIAL_WOOD)
			playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg', src.tap_volume, TRUE)

		else
			// we dont know what the floor is, generic noise GO!
			playsound(src,'sound/impact_sounds/block_blunt.ogg', src.tap_volume/2, TRUE, pitch = 0.7)


		user.visible_message(SPAN_ALERT("[user] taps \the [src] on \the [T]!"), group = "cane_tap")

	attack_self(mob/user)
		. = ..()

		var/turf/T = get_turf(user)
		// if we cant reach the tile for some reason
		if (!T || istype(T,/turf/space) || T != user.loc)
			return

		// if we're floating for some god awful reason
		if (user.traction == TRACTION_NONE ||  HAS_ATOM_PROPERTY(user, PROP_ATOM_FLOATING))
			return

		if (!ON_COOLDOWN(src,"cane_tap",5 SECONDS))
			src.do_tap(T, user)

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

/obj/item/cane/metal/tennisball
	icon_state = "tennisball"
	desc = "Perfect when you need a million balloons!"

	do_tap(turf/T, mob/user)
		// extremely padded
		playsound(src,'sound/impact_sounds/block_blunt.ogg', src.tap_volume/2, TRUE, pitch = 1.1)
		user.visible_message(SPAN_ALERT("[user] taps \the [src] on \the [T]!"), group = "cane_tap")

// Geoff's funny canes below!
ABSTRACT_TYPE(/obj/item/cane/silly)

/obj/item/cane/silly/clown
	name = "clown cane"
	icon_state = "clown"
	desc = "My back feels funny."

	do_tap(turf/T, mob/user)

		// clown cane makes a honking noise
		playsound(src, pick('sound/musical_instruments/Bikehorn_bonk1.ogg', 'sound/musical_instruments/Bikehorn_bonk2.ogg', 'sound/musical_instruments/Bikehorn_bonk3.ogg'), src.tap_volume, TRUE, pitch = 0.7)
		user.visible_message(SPAN_ALERT("[user] taps \the [src] on \the [T]!"), group = "cane_tap")

/obj/item/cane/silly/mime
	name = "mime cane"
	icon_state = "mime"
	desc = "Suffering in silence."

	do_tap(turf/T, mob/user)

		// mime gets no sound because funny
		user.visible_message(SPAN_ALERT("[user] taps \the [src] on \the [T]!"), group = "cane_tap")

/obj/item/cane/silly/princess
	name = "pink cane"
	icon_state = "princess"
	desc = "Sparkle! Glimmer! Back pain! Sparkle!"

// Cargo exclusive below!

/obj/item/cane/golden
	name = "golden cane"
	icon_state = "golden"
	mat_changename = FALSE
	default_material = "gold"
	desc = "Now your grandkids won't call you for sure."
