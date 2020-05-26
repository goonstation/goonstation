/obj/item/clothing/lanyard
	name = "lanyard"
	desc = "Only dorks wear these."
	icon = 'icons/obj/clothing/item_lanyards.dmi'
	wear_image_icon = 'icons/mob/lanyards.dmi'
	icon_state = "blue"
	var/obj/item/card/id/ID_card = null
	var/registered = null
	var/access = list()

	New()
		..()
		AddComponent(/datum/component/storage, max_wclass = 1, slots = 3)

	attackby(obj/item/W, mob/user, params)
		..()
		if (istype(W, /obj/item/card/id))
			var/obj/item/card/id/ID = W
			src.registered = ID.registered
			src.access = ID.access
