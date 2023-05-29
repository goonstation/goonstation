// storage datums for bag of holding artifact. see code there for intent of these

/datum/storage/no_hud/eldtritch_bag_of_holding

/datum/storage/no_hud/eldtritch_bag_of_holding/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (istype(I, /obj/item/artifact/bag_of_holding))
		var/obj/item/artifact/bag_of_holding/boh = I
		var/datum/artifact/artifact = boh.artifact
		if (artifact.activated)
			combine_bags_of_holding(user, boh, src)
			return
	var/obj/item/artifact/bag_of_holding/boh = src.linked_item
	boh.ArtifactFaultUsed(user, boh)

/datum/storage/artifact_bag_of_holding

/datum/storage/artifact_bag_of_holding/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (istype(I, /obj/item/artifact/bag_of_holding))
		var/obj/item/artifact/bag_of_holding/boh = I
		var/datum/artifact/artifact = boh.artifact
		if (artifact.activated)
			combine_bags_of_holding(user, boh, src)
			return FALSE
	var/obj/item/artifact/bag_of_holding/boh = src.linked_item
	boh.ArtifactFaultUsed(user, boh)
	return TRUE
/*
/datum/storage/artifact_bag_of_holding/martian
	var/initial_slots
	var/initial_max_wclass

	var/seeking_ore = FALSE

/datum/storage/artifact_bag_of_holding/martian/New()
	..()
	src.initial_slots = src.slots
	src.initial_max_wclass = src.max_wclass

	src.linked_item.visible_message("<span class='alert'>[src.linked_item] growls. WHAT THE HELL?? Somehow, you can tell this thing wants Viscerite.</span>")
	boutput()

/datum/storage/artifact_bag_of_holding/martian/proc/upgrade_storage()
	if (src.slots < 13)


/datum/storage/artifact_bag_of_holding/martian/proc/reduce_storage()
	if (src.slots > 3)
		src.slots--

*/

/datum/storage/artifact_bag_of_holding/wizard
	var/visible_slots = 3

/datum/storage/artifact_bag_of_holding/wizard/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding, check_wclass,
	max_wclass, slots, sneaky, opens_if_worn, list/params)
	..()
	src.visible_slots = params["visible_slots"] || initial(src.visible_slots)

/datum/storage/artifact_bag_of_holding/wizard/show_hud()
	if (length(src.get_contents()) > src.visible_slots)
		for (var/i = 1 to src.visible_slots)
			src.stored_items.Swap(i, rand(1, length(src.get_contents())))

	// trick hud into showing fewer slots than storage actually has
	var/storage_slots = src.slots
	src.slots = src.visible_slots
	..()
	src.slots = storage_slots

/datum/storage/artifact_bag_of_holding/precursor

/datum/storage/artifact_bag_of_holding/precursor/add_contents_extra(obj/item/I, mob/user, visible)
	if (!..())
		return
	if (I.burning || I in by_cat[TR_CAT_BURNING_ITEMS])
		I.combust_ended()
		boutput(user, "<span class='notice'>[I] is enveloped in a glow and extinguished!</span>")
	var/initial_health = get_initial_item_health(I)
	if (I.health < initial_health)
		boutput(user, "<span class='notice'>[src.linked_item] hums for a moment, and [I] reforms to its original state!</span>")
		I.health = initial_health

	var/first_time_entrance = !GET_ATOM_PROPERTY(I, PROP_ATOM_PRECURSOR_BOH_ENTERED)
	APPLY_ATOM_PROPERTY(I, PROP_ATOM_PRECURSOR_BOH_ENTERED, src.linked_item)
	if (GET_COOLDOWN(src.linked_item, "precusor_boh_transformation_chance"))
		return
	ON_COOLDOWN(src.linked_item, "precusor_boh_transformation_chance", rand(15, 45) SECONDS)
	if (prob(75))
		return
	if (!first_time_entrance)
		return
	switch(rand(1, 4))
		if (1)
			I.color = rgb(pick(0, 255), pick(0, 255), pick(0, 255), prob(90) ? 255 : pick(127, 255))
		if (2)
			I.Scale(randfloat(0.5, 1.5), randfloat(0.5, 1.5))
		if (3)
			I.setMaterial(getMaterial(pick("rock", "slag")))
		if (4)
			var/datum/artifact_origin/origin = /datum/artifact_origin/precursor
			var/new_name = pick(initial(origin.adjectives)) + pick(initial(origin.nouns_small))
			I.name = new_name
			I.real_name = new_name
	boutput(user, "<span class='notice'>[src.linked_item] warps strangely and returns to normal. [I] isn't the same anymore!</span>")

// when a bag of holding artifact is put into another
// user can be null
proc/combine_bags_of_holding(mob/user, obj/item/artifact/boh_1, obj/item/artifact/boh_2)
	switch(rand(1, 4))
		if (1)
			explosion_new(boh_1, get_turf(boh_1), 10)
			user?.gib()
		if (2)
			var/obj/machinery/the_singularity/black_hole = new /obj/machinery/the_singularity(get_turf(boh_1), rad = 1)
			SPAWN(3 SECONDS)
				qdel(black_hole)
		if (3)
			var/list/items = boh_1.storage.get_contents() + boh_2.storage.get_contents()
			if (prob(50))
				if (length(items))
					var/list/humans = list()
					for (var/mob/living/carbon/human/H in mobs)
						humans += H
					shuffle_list(humans)
					var/mob/living/carbon/human/H
					for (var/i = 1 to min(length(items), length(humans)))
						H = humans[i]
						if (H.back.storage?.check_can_hold(items[i]))
							H.back.storage.add_contents(items[i], null, FALSE)
						else if (H.belt.storage?.check_can_hold(items[i]))
							H.belt.storage.add_contents(items[i], null, FALSE)
			else
				var/list/turfs = block(locate(1, 1, user.z), locate(world.maxx, world.maxy, user.z))
				for (var/obj/item/I as anything in boh_1.storage.get_contents())
					boh_1.storage.transfer_stored_item(I, pick(turfs))
				for (var/obj/item/I as anything in boh_2.storage.get_contents())
					boh_2.storage.transfer_stored_item(I, pick(turfs))
			playsound(boh_1.loc, "warp", 50, TRUE)
			boutput(user, "<span class='alert'><B>The artifacts disappear![length(items) ? "... Along with everything inside them!" : null]</B></span>")
		if (4)
			return

	for (var/obj/item/I as anything in (boh_1.storage.get_contents() + boh_2.storage.get_contents()))
		qdel(I)
	qdel(boh_1)
	qdel(boh_2)
