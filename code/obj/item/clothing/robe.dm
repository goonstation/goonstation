// contains various kinds of robe and occasionally matching masks.

/obj/item/clothing/suit/adeptus
	name = "adeptus mechanicus robe"
	desc = "A robe of a member of the adeptus mechanicus."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	icon_state = "adeptus"
	item_state = "adeptus"
	over_hair = TRUE
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM|C_GLOVES|C_SHOES|C_EARS
	wear_layer = MOB_FULL_SUIT_LAYER

	setupProperties()
		..()
		setProperty("chemprot", 10)

/obj/item/clothing/suit/cultist
	name = "cultist robe"
	desc = "The unholy vestments of a cultist."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "cultist"
	item_state = "cultist"
	see_face = 0
	magical = 1
	over_hair = TRUE
	wear_layer = MOB_FULL_SUIT_LAYER
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("heatprot", 20)
		setProperty("chemprot", 10)

/obj/item/clothing/suit/cultist/cursed
	cant_drop = TRUE
	cant_other_remove = TRUE
	cant_self_remove = TRUE

/obj/item/clothing/suit/cultist/hastur
	name = "yellow sign cultist robe"
	desc = "For those who have seen the yellow sign and answered its call.."
	icon_state = "hasturcultist"
	item_state = "hasturcultist"

/obj/item/clothing/suit/cultist/nerd
	name = "robes of dungeon mastery"
	desc = "Neeeeerds."

	New()
		. = ..()
		src.enchant(min(rand(1, 5), rand(1, 5)))

/obj/item/clothing/suit/flockcultist
	name = "weird cultist robe"
	desc = "Only unpopular nerds would ever wear this."
	icon = 'icons/obj/clothing/overcoats/item_suit_gimmick.dmi'
	wear_image_icon = 'icons/mob/clothing/overcoats/worn_suit_gimmick.dmi'
	inhand_image_icon = 'icons/mob/inhand/overcoat/hand_suit_gimmick.dmi'
	icon_state = "flockcultist"
	item_state = "flockcultistt"
	see_face = 0
	wear_layer = MOB_FULL_SUIT_LAYER
	c_flags = COVERSEYES | COVERSMOUTH
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM
	over_hair = TRUE

	setupProperties()
		..()
		setProperty("chemprot", 10)

/obj/item/clothing/suit/wizrobe
	name = "blue wizard robe"
	desc = "A traditional blue wizard's robe. It lacks all the stars and moons and stuff on it though."
	icon_state = "wizard"
	item_state = "wizard"
	magical = TRUE
	body_parts_covered = TORSO|LEGS|ARMS
	hides_from_examine = C_UNIFORM
	contraband = 4
	duration_remove = 10 SECONDS

	setupProperties()
		..()
		setProperty("coldprot", 90)
		setProperty("heatprot", 30)
		setProperty("chemprot", 40)

/obj/item/clothing/suit/wizrobe/red
	name = "red wizard robe"
	desc = "A very fancy and elegant red robe with gold trim."
	icon_state = "wizardred"
	item_state = "wizardred"

/obj/item/clothing/suit/wizrobe/purple
	name = "purple wizard robe"
	desc = "A real nice robe and cape, in purple, with blue and yellow accents."
	icon_state = "wizardpurple"
	item_state = "wizardpurple"

/obj/item/clothing/suit/wizrobe/green
	name = "green wizard robe"
	desc = "A neat green robe with gold trim."
	icon_state = "wizardgreen"
	item_state = "wizardgreen"

/obj/item/clothing/suit/wizrobe/necro
	name = "necromancer robe"
	desc = "A ratty stinky black robe for wizards who are trying way too hard to be menacing."
	icon_state = "wizardnec"
	item_state = "wizardnec"

