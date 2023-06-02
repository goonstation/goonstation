// storage datums for bag of holding artifact. see code there for intent of these

/datum/storage/no_hud/eldritch_bag_of_holding

/datum/storage/no_hud/eldritch_bag_of_holding/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (istype(I, /obj/item/artifact/bag_of_holding))
		var/obj/item/artifact/bag_of_holding/boh = I
		var/datum/artifact/artifact = boh.artifact
		if (artifact.activated)
			combine_bags_of_holding(user, boh, src.linked_item)
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
			combine_bags_of_holding(user, boh, src.linked_item)
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

/datum/storage/artifact_bag_of_holding/wizard/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding,
		check_wclass, max_wclass, slots, sneaky, opens_if_worn, list/params)
	..()
	src.visible_slots = params["visible_slots"] || initial(src.visible_slots)

/datum/storage/artifact_bag_of_holding/wizard/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (user)
		src.show_hud(user)

/datum/storage/artifact_bag_of_holding/wizard/transfer_stored_item_extra(obj/item/I, atom/location, add_to_storage, mob/user)
	..()
	if (user)
		src.show_hud(user)

/datum/storage/artifact_bag_of_holding/wizard/show_hud(mob/user, refresh_hud = TRUE)
	shuffle_list(src.stored_items)
	..()
	for (var/obj/item/I in (src.hud.objects - src.get_hud_contents()))
		src.hud.remove_object(I)

/datum/storage/artifact_bag_of_holding/wizard/hud_can_add(obj/item/I)
	return (length(src.get_contents()) < src.visible_slots) && ..()

/datum/storage/artifact_bag_of_holding/wizard/get_visible_slots()
	return src.visible_slots

/datum/storage/artifact_bag_of_holding/wizard/get_hud_contents(hud_clear_check = TRUE)
	var/list/current_contents = src.get_contents()
	return !length(current_contents) ? current_contents : current_contents.Copy(1, min(length(current_contents), src.visible_slots) + 1)

/datum/storage/artifact_bag_of_holding/precursor

/datum/storage/artifact_bag_of_holding/precursor/add_contents_extra(obj/item/I, mob/user, visible)
	if (!..())
		return
	var/play_sound = FALSE
	if (I.burning || (I in by_cat[TR_CAT_BURNING_ITEMS]))
		I.combust_ended()
		boutput(user, "<span class='notice'>[I] is enveloped in a glow and extinguished!</span>")
		play_sound = TRUE
	var/initial_health = get_initial_item_health(I)
	if (I.health < initial_health)
		boutput(user, "<span class='notice'>[src.linked_item] hums for a moment, and [I] reforms to its original state!</span>")
		I.health = initial_health
		play_sound = TRUE

	if (play_sound)
		playsound(src.linked_item.loc, 'sound/machines/ArtifactPre1.ogg', 50, TRUE)

	var/first_time_entrance = !GET_ATOM_PROPERTY(I, PROP_ATOM_PRECURSOR_BOH_ENTERED)
	APPLY_ATOM_PROPERTY(I, PROP_ATOM_PRECURSOR_BOH_ENTERED, src.linked_item)
	if (GET_COOLDOWN(src.linked_item, "precusor_boh_transformation_chance"))
		return
	ON_COOLDOWN(src.linked_item, "precusor_boh_transformation_chance", rand(15, 45) SECONDS)
	if (prob(75))
		return
	if (!first_time_entrance)
		return

	var/item_name = I.name
	switch(rand(1, 4))
		if (1)
			I.color = rgb(pick(0, 255), pick(0, 255), pick(0, 255), prob(90) ? 255 : pick(127, 255))
		if (2)
			I.Scale(randfloat(0.5, 1.5), randfloat(0.5, 1.5))
		if (3)
			I.setMaterial(getMaterial(pick("rock", "slag")))
		if (4)
			var/new_name = "[pick("strange", "cold", "rough")]" + " [pick("utility", "device", "item")]"
			I.name = new_name
			I.real_name = new_name
	boutput(user, "<span class='notice'>[src.linked_item] warps strangely and returns to normal. \The [item_name] isn't the same anymore!</span>")
	if (!play_sound)
		playsound(src.linked_item.loc, 'sound/machines/ArtifactPre1.ogg', 50, TRUE)

// when a bag of holding artifact is put into into another
// user can be null, boh_1 is put into boh_2
proc/combine_bags_of_holding(mob/user, obj/item/artifact/boh_1, obj/item/artifact/boh_2)
	var/turf/T = get_turf(boh_2)
	switch(rand(1, 4))
		// explosion
		if (1)
			explosion_new(boh_1, T, 3) // causes a one tile hull breach
			T.visible_message("<span class='alert'><B>The artifacts explode! HOLY SHIT!!!")
			playsound(T, "explosion", 25, TRUE)
			user?.gib()
		// implosion
		if (2)
			var/obj/dummy/artifact_boh_singulo_dummy/black_hole = new (T)
			T.visible_message("<span class='alert'><B>The artifacts shink to nothing! UH OH.")
			playsound(T, 'sound/machines/singulo_start.ogg', 20, TRUE)
			qdel(T)
			qdel(user)
			SPAWN(3 SECONDS)
				qdel(black_hole)
		// teleport items everywhere
		if (3)
			var/list/items = boh_1.storage.get_contents() + boh_2.storage.get_contents() - boh_1
			// teleport to random storages
			if (prob(50))
				if (length(items))
					var/list/humans = list()
					for (var/mob/living/carbon/human/H in mobs)
						if ((H.back?.storage && !istype(H.back, /obj/item/artifact/bag_of_holding)) || (H.belt?.storage && !istype(H.belt, /obj/item/artifact/bag_of_holding)))
							humans += H
					if (length(humans))
						shuffle_list(humans)
						var/mob/living/carbon/human/H
						for (var/obj/item/I as anything in items)
							H = pick(humans)
							if (H.back.storage.check_can_hold(I) == STORAGE_CAN_HOLD)
								I.stored.transfer_stored_item(I, H.back, TRUE)
							else if (H.belt.storage.check_can_hold(I) == STORAGE_CAN_HOLD)
								I.stored.transfer_stored_item(I, H.belt, TRUE)
							humans -= H
							if (!length(humans))
								break
			// teleport to random turfs
			else
				var/list/turfs = block(locate(1, 1, T.z || Z_LEVEL_STATION), locate(world.maxx, world.maxy, T.z || Z_LEVEL_STATION))
				for (var/obj/item/I as anything in boh_1.storage.get_contents())
					boh_1.storage.transfer_stored_item(I, pick(turfs))
				for (var/obj/item/I as anything in (boh_2.storage.get_contents() - boh_1))
					boh_2.storage.transfer_stored_item(I, pick(turfs))
			playsound(T, "warp", 50, TRUE)
			boutput(user, "<span class='alert'><B>The artifacts disappear![length(items) ? "... Along with everything inside them!" : null]</B></span>")
		// strand user in pocket dimension
		if (4)
			if (user)
				playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)

				for (var/mob/M as anything in viewers(6, T))
					M.flash(3 SECONDS)

				var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/artifact_stranded)
				var/datum/allocated_region/region = prefab.load()
				user.set_loc(region.get_center())

				T.visible_message("<span class='alert'>[user] vanishes!</span>")

				SPAWN(5 SECONDS)
					boutput(user, "<span class='alert'>Yeah... you're not getting out of this place alive.</span>")

	for (var/obj/item/I as anything in (boh_1.storage.get_contents() + boh_2.storage.get_contents() - boh_1))
		qdel(I)
	qdel(boh_1)
	qdel(boh_2)

/obj/dummy/artifact_boh_singulo_dummy
	name = "gravitational singularity"
	desc = "That's... a singularity..."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "Sing2"
	anchored = ANCHORED
	density = TRUE
	plane = PLANE_DEFAULT_NOWARP

	event_handler_flags = IMMUNE_SINGULARITY

	pixel_x = -64
	pixel_y = -64

	New()
		..()
		src.SafeScale(0.2, 0.2)
