// storage datums for bag of holding artifact. see code there for how these are used

// --- eldritch ---

// eldritch storage that has no hud. doesn't inherit from other artifact storages' parent type since they don't have the no hud functionality
/datum/storage/no_hud/eldritch_bag_of_holding

// effect from putting a bag of holding into another
/datum/storage/no_hud/eldritch_bag_of_holding/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (istype(I, /obj/item/artifact/bag_of_holding))
		var/datum/artifact/artifact = I.artifact
		if (artifact.activated)
			destroy_bag_of_holding(src.linked_item, I, user)
			return
	if (istype(I, /obj/item/artifact/activator_key))
		var/obj/item/artifact/bag_of_holding/boh = src.linked_item
		var/datum/artifact/activator_key/key = I.artifact
		if (key.activated && (key.universal || key.artitype == boh.artifact.artitype))
			destroy_bag_of_holding(src.linked_item, I, user)
			return
	var/obj/item/artifact/bag_of_holding/boh = src.linked_item
	boh.ArtifactFaultUsed(user, boh)

// --- parent artifact storage type ---

// parent artifact bag of holding type
/datum/storage/artifact_bag_of_holding

// effect from putting a bag of holding into another
/datum/storage/artifact_bag_of_holding/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (istype(I, /obj/item/artifact/bag_of_holding))
		var/datum/artifact/artifact = I.artifact
		if (artifact.activated)
			destroy_bag_of_holding(src.linked_item, I, user)
			return
	if (istype(I, /obj/item/artifact/activator_key))
		var/obj/item/artifact/bag_of_holding/boh = src.linked_item
		var/datum/artifact/activator_key/key = I.artifact
		if (key.activated && (key.universal || key.artitype == boh.artifact.artitype))
			destroy_bag_of_holding(src.linked_item, I, user)
			return
	var/obj/item/artifact/bag_of_holding/boh = src.linked_item
	boh.ArtifactFaultUsed(user, boh)

// --- martian ---

// storage that changes what it can hold over time
/datum/storage/artifact_bag_of_holding/martian

/datum/storage/artifact_bag_of_holding/martian/New()
	..()
	src.linked_item.setStatus("martian_boh_morph")

/datum/storage/artifact_bag_of_holding/martian/disposing()
	src.linked_item.delStatus("martian_boh_morph")
	..()

// --- wizard ---

// storage that shows a random, smaller selection of the total contents each time you look inside or its contents change
/datum/storage/artifact_bag_of_holding/wizard
	var/visible_slots = 3

/datum/storage/artifact_bag_of_holding/wizard/New(atom/storage_item, list/spawn_contents, list/can_hold, list/can_hold_exact, list/prevent_holding,
		check_wclass, max_wclass, slots, sneaky, stealthy_storage, opens_if_worn, list/params)
	..()
	src.visible_slots = params["visible_slots"] || initial(src.visible_slots)

/datum/storage/artifact_bag_of_holding/wizard/add_contents_extra(obj/item/I, mob/user, visible)
	..()
	if (user?.s_active == src.hud)
		src.show_hud(user)

/datum/storage/artifact_bag_of_holding/wizard/transfer_stored_item_extra(obj/item/I, atom/location, add_to_storage, mob/user)
	..()
	if (user?.s_active == src.hud)
		src.show_hud(user)

// does the randomization of visible contents
/datum/storage/artifact_bag_of_holding/wizard/show_hud(mob/user)
	shuffle_list(src.stored_items)
	..()
	// item order is randomized, then hud refreshes, only adding new objects. this is needed to remove old objects
	for (var/obj/item/I in (src.hud.objects - src.get_hud_contents()))
		src.hud.remove_object(I)

// extra check for the storage
/datum/storage/artifact_bag_of_holding/wizard/hud_can_add(obj/item/I)
	return (length(src.get_contents()) < src.visible_slots) && ..()

/datum/storage/artifact_bag_of_holding/wizard/get_visible_slots()
	return src.visible_slots

// make sure only up to visible slots # of contents are shown
/datum/storage/artifact_bag_of_holding/wizard/get_hud_contents(hud_clear_check = TRUE)
	var/list/current_contents = src.get_contents()
	return !length(current_contents) ? current_contents : current_contents.Copy(1, min(length(current_contents), src.visible_slots) + 1)

// --- other ---

// when a "forbidden" artifact is put into an existing boh, after its been done
// artifact "added" is put into boh "boh"
proc/destroy_bag_of_holding(obj/item/artifact/boh, obj/added, mob/user = null)
	var/effect
	var/turf/T = get_turf(boh)
	switch(rand(1, 4))
		// explosion
		if (1)
			explosion_new(added, T, 3) // causes a one tile hull breach
			T.visible_message(SPAN_ALERT("<b>The artifacts explode! HOLY SHIT!!!</b>"))
			playsound(T, "explosion", 25, TRUE)
			user?.gib()

			effect = "explosion"
		// implosion
		if (2)
			var/obj/dummy/artifact_boh_singulo_dummy/black_hole = new (T)
			T.visible_message(SPAN_SAY("<b>The artifacts shrink to nothing! UH OH.</b>"))
			playsound(T, 'sound/machines/singulo_start.ogg', 20, TRUE)
			qdel(T)
			qdel(user)
			SPAWN(3 SECONDS)
				qdel(black_hole)

			effect = "black hole"
		// teleport items everywhere
		if (3)
			var/list/items = boh.storage.get_contents() + added.storage?.get_contents() - added
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
								logTheThing(LOG_STATION, boh, "[I] is transferred to [key_name(H)]'s back slot by a bag of holding fault")
								I.stored.transfer_stored_item(I, H.back, TRUE)
							else if (H.belt.storage.check_can_hold(I) == STORAGE_CAN_HOLD)
								logTheThing(LOG_STATION, boh, "[I] is transferred to [key_name(H)]'s belt slot by a bag of holding fault")
								I.stored.transfer_stored_item(I, H.belt, TRUE)
							humans -= H
							if (!length(humans))
								break

				effect = "content teleportation to random storages"
			// teleport to random turfs
			else
				var/list/turfs = block(locate(1, 1, T.z || Z_LEVEL_STATION), locate(world.maxx, world.maxy, T.z || Z_LEVEL_STATION))
				for (var/obj/item/I as anything in added.storage?.get_contents())
					added.storage.transfer_stored_item(I, pick(turfs))
				for (var/obj/item/I as anything in (boh.storage.get_contents() - added))
					boh.storage.transfer_stored_item(I, pick(turfs))

				effect = "content teleportation to random turfs"

			playsound(T, "warp", 50, TRUE)
			boutput(user, SPAN_ALERT("<B>The artifacts disappear![length(items) ? "... Along with everything inside them!" : null]</B>"))
		// strand user in pocket dimension
		if (4)
			if (user)
				playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)

				for (var/mob/M as anything in viewers(6, T))
					M.flash(3 SECONDS)

				var/datum/mapPrefab/allocated/prefab = get_singleton(/datum/mapPrefab/allocated/artifact_stranded)
				var/datum/allocated_region/region = prefab.load()
				user.set_loc(region.get_center())

				T.visible_message(SPAN_ALERT("[user] vanishes!"))

				SPAWN(5 SECONDS)
					boutput(user, SPAN_ALERT("Yeah... you're not getting out of this place alive."))

			effect = "user stranded in pocket dimension"

	logTheThing(LOG_STATION, boh, "artifact bags of holding combined at [log_loc(T)] by [key_name(user)] with effect [effect].")

	for (var/obj/item/I as anything in (added.storage?.get_contents() + boh.storage.get_contents() - added))
		qdel(I)
	qdel(added)
	qdel(boh)

// small singulo imitator that isn't deadly
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
