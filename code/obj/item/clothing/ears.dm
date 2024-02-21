// EARS

/obj/item/clothing/ears
	name = "ears"
	icon = 'icons/obj/clothing/item_ears.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_headgear.dmi'
	wear_image_icon = 'icons/mob/clothing/ears.dmi'
	w_class = W_CLASS_TINY
	wear_layer = MOB_EARS_LAYER
	throwforce = 2
	block_hearing_when_worn = HEARING_BLOCKED

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Keeps you warm, makes it hard to hear."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	protective_temperature = 500

	setupProperties()
		..()
		setProperty("coldprot", 20)
		setProperty("disorient_resist_ear", 100)

/obj/item/clothing/ears/earmuffs/earplugs
	name = "ear plugs"
	desc = "Protects you from sonic attacks."
	icon_state = "earplugs"
	item_state = "nothing"
	protective_temperature = 0

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("disorient_resist_ear", 100)

/obj/item/clothing/ears/earmuffs/yeti
	name = "yeti-fur earmuffs"
	desc = "Keeps you warm without making it hard to hear."
	icon_state = "yetiearmuffs"
	item_state = "yetiearmuffs"
	block_hearing_when_worn = HEARING_NORMAL

	setupProperties()
		..()
		setProperty("coldprot", 80)
		setProperty("disorient_resist_ear", 80)
