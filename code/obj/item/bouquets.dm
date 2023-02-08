ABSTRACT_TYPE(/obj/item/bouquet)
/obj/item/bouquet
	name = "abstract bouquet"
	desc = "If you're seeing this, something's wrong"
	var/paper_used = null
	var/flower_type_used = null
	var/flowers_stored = null
	var/max_flowers = 6 // 6 seems like a reasonable amount for now, lets not have 99 flowers in one bouquet
	var/min_flowers = 2 // can't have a bouquet with only one flower
	proc/unroll(mob/user)
		// should give us back the paper and flowers when done with snipping tool
		// actually this should be under dispose shouldnt it

/obj/item/bouquet/lavender
	name = "lavender bouquet"
	desc = "They smell pretty, and the purple can't be beat."
	icon_state = "bouquet_lavender"
	item_state = "bouquet_lavender"
	flower_type_used = /obj/item/clothing/head/flower/lavender

/obj/item/bouquet/rose
	name = "rose bouquet"
	desc = "Red is the color of passion; or, of the medbay."
	icon_state = "bouquet_rose"
	item_state = "bouquet_rose"
	flower_type_used = /obj/item/plant/flower/rose

//obj/item/bouquet/mixed
// this can be done later if needed
