//everything that's indicative of a particular existing nation
ABSTRACT_TYPE(/obj/item/clothing/under/cultural)
/obj/item/clothing/under/cultural
    name = "cultural coders Jumpsuit"
    desc = "This is weird! Report this to a coder!"
    icon = 'icons/obj/clothing/jumpsuits/item_js_cultural.dmi'
    wear_image_icon = 'icons/mob/clothing/jumpsuits/worn_js_cultural.dmi'
    inhand_image_icon = 'icons/mob/inhand/jumpsuits/hand_js_cultural.dmi'

/obj/item/clothing/under/cultural/hakama
	name = "uwagi and hakama"
	desc = "The traditional garb of the samurai. You have no idea what this is doing on a space station."
	icon_state = "hakama_1"
	item_state = "hakama_1"

/obj/item/clothing/under/cultural/hakama/random
	New()
		var/n = rand(1,6)
		icon_state = "hakama_[n]"
		item_state = "hakama_[n]"
		..()

ABSTRACT_TYPE(/obj/item/clothing/under/cultural/yukata)
/obj/item/clothing/under/cultural/yukata
	name = "yukata"
	desc = "Light cotton robes secured with a large obi tied into a neat bow around the waist. Perfect for the Japanese summer heat, which you're very far away from."
	icon_state = "yukata_plain1"
	item_state = "yukata_plain1"

ABSTRACT_TYPE(/obj/item/clothing/under/cultural/yukata/plain)
/obj/item/clothing/under/cultural/yukata/plain
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

ABSTRACT_TYPE(/obj/item/clothing/under/cultural/yukata/floral)
/obj/item/clothing/under/cultural/yukata/floral
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

/obj/item/clothing/under/cultural/america
	name = "american pride shirt"
	desc = "I am a REAL AMERICAN, I fight for the rights of every man!"
	icon_state = "america"
	item_state = "america"

/obj/item/clothing/under/cultural/tricolor
    name = "Tricolor Jumpsuit"
    desc = "A jumpsuit that shows you're serious about pizza."
    icon_state = "tricolor"
    item_state = "tricolor"

/obj/item/clothing/under/cultural/kilt
	name = "kilt"
	desc = "Traditional Scottish clothing. A bit drafty in here, isn't it?"
	icon_state = "kilt"
	item_state = "kilt"
