ABSTRACT_TYPE(/obj/item/clothing/under/gimmick/yukata)
/obj/item/clothing/under/gimmick/yukata
	name = "yukata"
	desc = "Light cotton robes secured with a large obi tied into a neat bow around the waist. Perfect for the Japanese summer heat, which you're very far away from."
	icon_state = "yukata_plain1"
	item_state = "yukata_plain1"

ABSTRACT_TYPE(/obj/item/clothing/under/gimmick/yukata/plain)
/obj/item/clothing/under/gimmick/yukata/plain
	name = "plain yukata"

	gray
		icon_state = "yukata_plain1"
		item_state = "yukata_plain1"

	black
		icon_state = "yukata_plain2"
		item_state = "yukata_plain2"

	cream
		icon_state = "yukata_plain3"
		item_state = "yukata_plain3"

	navy
		icon_state = "yukata_plain4"
		item_state = "yukata_plain4"

	teal
		icon_state = "yukata_plain5"
		item_state = "yukata_plain5"

	random
		New()
			var/yukata_index = rand(1,5)
			icon_state = "yukata_plain[yukata_index]"
			item_state = "yukata_plain[yukata_index]"
			..()

ABSTRACT_TYPE(/obj/item/clothing/under/gimmick/yukata/floral)
/obj/item/clothing/under/gimmick/yukata/floral
	name = "floral yukata"
	icon_state = "yukata_floral1"
	item_state = "yukata_floral1"

	blue
		icon_state = "yukata_floral1"
		item_state = "yukata_floral1"

	orange
		icon_state = "yukata_floral2"
		item_state = "yukata_floral2"

	yellow
		icon_state = "yukata_floral3"
		item_state = "yukata_floral3"

	red
		icon_state = "yukata_floral4"
		item_state = "yukata_floral4"

	black
		icon_state = "yukata_floral5"
		item_state = "yukata_floral5"

	random
		New()
			var/yukata_index = rand(1,5)
			icon_state = "yukata_floral[yukata_index]"
			item_state = "yukata_floral[yukata_index]"
			..()
