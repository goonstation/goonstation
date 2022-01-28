/obj/item/clothing/under/gimmick/hakama
	name = "uwagi and hakama"
	desc = "The traditional garb of the samurai. You have no idea what this is doing on a space station."
	icon_state = "hakama_1"
	item_state = "hakama_1"

/obj/item/clothing/under/gimmick/hakama/random
	New()
		var/n = rand(1,6)
		icon_state = "hakama_[n]"
		item_state = "hakama_[n]"
		..()
