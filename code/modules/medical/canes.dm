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

// Geoff's funny canes below!
ABSTRACT_TYPE(/obj/item/cane/silly)

/obj/item/cane/silly/clown
	name = "clown cane"
	icon_state = "clown"
	desc = "My back feels funny."

/obj/item/cane/silly/mime
	name = "mime cane"
	icon_state = "mime"
	desc = "Suffering in silence."

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
