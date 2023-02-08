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
proc/make_bouquet(/obj/item/floweritem, obj/item/paperitem, mob/user)
	// first check if it's the right kind of flower, right amount, allocate bouquet
	// have some fail messages
	// make bouquet
	// we do a little storing, put the paper and flowers into flowers_stored and paper_used
	// then we possibly qdel it idk, probably don't need to if we're storing it
	user.visible_message("[user] roll up the [src] into a bouquet.", "You roll up the [src].")
	var/obj/item/bouquet/lavender/P = new(get_turf(user))
	qdel(src)

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
