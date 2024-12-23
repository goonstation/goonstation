
/proc/testDrop()
	var/area/A = usr.loc.loc
	var/datum/random_event/special/supplydrop/S = new/datum/random_event/special/supplydrop()
	S.event_effect(A, 100, 3)
	return

/datum/random_event/special/supplydrop
	name = "Supply Drop"

	event_effect(var/source, var/area/A, var/preDropTime = 300, var/howMany = 3)
		..()

		if (!A) //manually called outside of BR gamemode
			A = get_area(pick_landmark(LANDMARK_PESTSTART))
		logTheThing(LOG_ADMIN, null, "Supply drop at [A]")
		var/list/turfs = get_area_turfs(A,1)
		if (!turfs)	DEBUG_MESSAGE("Getting turfs failed for [A]")

		for(var/x=0, x<howMany, x++)
			SPAWN(rand(0, 20)) //Looks better with a bit of variance
				new/obj/effect/supplymarker(pick(turfs), preDropTime)
		for(var/datum/mind/M in ticker.minds)
			boutput(M.current, SPAN_BLOBALERT("A supply drop will happen soon in the [A.name]"))
		SPAWN(20 SECONDS)
			for(var/datum/mind/M in ticker.minds)
				boutput(M.current, "[SPAN_BLOBALERT("A supply drop occurred in [A.name]!")]")

/obj/effect/supplymarker
	name = ""
	icon = 'icons/effects/64x64.dmi'
	icon_state = "impact_marker"
	density = 0
	anchored = ANCHORED
	pixel_x = -16
	pixel_y = -16
	var/gib_mobs = TRUE

	New(var/atom/location, var/preDropTime = 100, var/obj_path, var/no_lootbox)
		src.set_loc(location)
		SPAWN(preDropTime)
			if (gib_mobs)
				new/obj/effect/supplydrop(src.loc, obj_path, no_lootbox)
			else
				new/obj/effect/supplydrop/safe(src.loc, obj_path, no_lootbox)
			qdel(src)
		..()

/obj/effect/supplymarker/safe
	gib_mobs = FALSE

/obj/effect/supplydrop
	name = "supply drop"
	icon = 'icons/obj/large/32x96.dmi'
	icon_state = "lootdrop"
	density = 0
	anchored = ANCHORED
	plane = PLANE_FLOCKVISION
	var/dropTime = 30
	var/gib_mobs = TRUE

	New(atom/loc, var/obj_path, var/no_lootbox)
		pixel_y = 480
		animate(src, pixel_y = 0, time = dropTime)
		playsound(src.loc, 'sound/effects/flameswoosh.ogg', 75, 0)
		SPAWN(dropTime)
			new/obj/effect/supplyexplosion(src.loc)
			playsound(src.loc, 'sound/effects/ExplosionFirey.ogg', 50, 1)
			for(var/mob/M in view(7, src.loc))
				shake_camera(M, 20, 8)
				if(gib_mobs && M.loc == src.loc && isliving(M) && !isintangible(M))
					if(isliving(M))
						logTheThing(LOG_COMBAT, M, "was gibbed by [src] ([src.type]) at [log_loc(M)].")
					M.gib(1, 1)
			sleep(0.5 SECONDS)
			if (obj_path && no_lootbox)
				new obj_path(src.loc)
			else if (no_lootbox)
				makeRandomLootTrash().set_loc(src.loc)
			else
				new/obj/lootbox(src.loc, obj_path)
			qdel(src)
		..()

/obj/effect/supplydrop/safe
	gib_mobs = FALSE

/obj/effect/supplyexplosion
	name = ""
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explo_smoky"
	density = 0
	anchored = ANCHORED
	plane = PLANE_FLOCKVISION
	pixel_x = -32
	pixel_y = -32

	New()
		SPAWN(3 SECONDS)
			qdel(src)
		..()

/obj/lootbox
	name = "Lootcase"
	desc = "What wondrous items await you? Who knowwwwsss"
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "attachecase"
	var/used = 0
	anchored = UNANCHORED
	density = 1
	opacity = 0
	var/obj_path

	New(atom/loc, var/obj_path_arg)
		add_filter("loot drop", 1, drop_shadow_filter(x=0, y=0, size=5, offset=0, color=rgb(240,202,133)))
		obj_path = obj_path_arg
		return ..()

	attack_hand(mob/user)
		if(used) return
		used = 1
		set_density(0)
		icon_state = "attachecase_open"
		remove_filter("loot drop")
		lootbox(user, obj_path)
		return

/proc/lootbox(var/mob/user, var/obj_path)
	var/mob/living/carbon/human/H = user
	if(istype(H)) H.hud.add_screen(new/atom/movable/screen/lootcrateicon/crate(null, obj_path))
	return

/proc/makeRandomLootTrash()
	RETURN_TYPE(/atom/movable)
	var/obj/item/I = null
	var/list/permittedItemPaths = list(/obj/item/clothing)
	var/pickedClothingPath = pick(typesof(pick(permittedItemPaths)))
	var/list/obj/murder_supplies = list()

	for(var/datum/syndicate_buylist/D in syndi_buylist_cache)
		if(length(D.items) == 0)
			continue
		if(!D.br_allowed)
			continue
		for (var/item in D.items)
			murder_supplies.Add(item)

	var/datum/syndicate_buylist/S = pick(murder_supplies)
	var/pickedPath = pick(pickedClothingPath, S) //50-50 of either clothes or traitor item.

	I = new pickedPath()

	var/rarity = pick(100;ITEM_RARITY_COMMON, 65;ITEM_RARITY_UNCOMMON, 30;ITEM_RARITY_RARE, 15;ITEM_RARITY_EPIC, 10;ITEM_RARITY_LEGENDARY, 5;ITEM_RARITY_MYTHIC)

	var/numStats = 1
	var/statsMult = 1
	var/doTexture = 0
	var/doMaterial = 0
	var/doPaint = 0
	var/doSpecial = 0
	var/prefix = ""

	switch(rarity)
		if(ITEM_RARITY_COMMON)
			prefix = pick("Shiny", "Fresh", "Cool", "Nice", "Certified", "Painted")
			numStats = 1
			doPaint = 1
			statsMult = 1.15
		if(ITEM_RARITY_UNCOMMON)
			doPaint = 1
			doMaterial = 1
			prefix = pick("Rare", "Quality", "Flawless", "Perfect")
			numStats = 2
			statsMult = 1.33
		if(ITEM_RARITY_RARE)
			doPaint = 1
			numStats = 2
			doMaterial = 1
			statsMult = 1.5
			prefix = pick("Dominating", "Incredible", "Awesome", "Super")
		if(ITEM_RARITY_EPIC)
			doPaint = 1
			doTexture = 1
			numStats = 3
			doMaterial = 1
			statsMult = 2
			prefix = pick("Epic", "Godlike", "Hyper", "Ultimate")
		if(ITEM_RARITY_LEGENDARY)
			doPaint = 1
			doTexture = 1
			doSpecial = 1
			numStats = 3
			doMaterial = 1
			prefix = "Legendary"
			statsMult = 3
		if(ITEM_RARITY_MYTHIC)
			doPaint = 1
			doTexture = 1
			doSpecial = 1
			statsMult = 4
			doMaterial = 1
			numStats = 4
			prefix = "MYTHIC"

	if(doMaterial)
		var/list/material = pick(material_cache - list("cerenkite","ohshitium","plasmastone","koshmarite"))
		I.setMaterial(material_cache[material], appearance = 1, setname = 1)

	I.name_prefix(prefix)

	if(doPaint)
		var/datum/color/C = new()
		C.r = rand(0,255)
		C.g = rand(0,255)
		C.b = rand(0,255)
		C.a = 255
		I.color = rgb(C.r,C.g,C.b)
		I.name_prefix(get_nearest_color(C))

	var/list/possibleStats = list()
	for(var/x in globalPropList)
		if(!I.hasProperty(x) && x != "negate_fluid_speed_penalty" && x != "movespeed")
			possibleStats += x

	for(var/i=0,i<numStats,i++)
		var/pickedStat = pick(possibleStats)
		possibleStats -= pickedStat
		var/datum/objectProperty/P = globalPropList[pickedStat]
		I.setProperty(pickedStat, P.defaultValue*(statsMult*P.goodDirection))

	if(doTexture)
		I.setTexture(pick("damaged", "shiny", "tape1", "tape2", "static", "pizza", "pizza2", "bubbles_old", "bee", "bubbles", "bee1", "wood", "bamboo", "rock", "coral"), pick(100;BLEND_OVERLAY,33;BLEND_MULTIPLY,33;BLEND_ADD,33;BLEND_SUBTRACT), "rndtexture")

	if(istype(I))
		I.rarity = rarity
		if(doSpecial)
			I.setItemSpecial(pick(typesof(/datum/item_special) - /datum/item_special))

	I.UpdateName()

	return I

/atom/movable/screen/lootcratepreview
	screen_loc = "1,1"
	name = ""
	mouse_opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "meteor_shield"


	New()
		if(usr.client)
			transform = matrix((round(usr.client.getClientView(1))*32), (round(usr.client.getClientView(0))*32), MATRIX_TRANSLATE)
			filters += filter(type="drop_shadow", x=0, y=0, size=5, offset=0, color=rgb(240,202,133))
		..()

/atom/movable/screen/lootcrateicon
	icon = 'icons/effects/320x320.dmi'
	screen_loc = "1,1"
	name = ""

	New()
		if(usr.client)
			transform = matrix((round(usr.client.getClientView(1))*32)-160+16, (round(usr.client.getClientView(0))*32)-160+16, MATRIX_TRANSLATE)
		..()

	sparks
		icon_state = "sparks"
		mouse_opacity = 0


	background
		icon_state = "background"
		mouse_opacity = 0

	crate
		icon_state = "lootb0"
		var/opened = 0
		var/obj_path = null

		New(atom/loc, var/obj_path_arg)
			obj_path = obj_path_arg
			..()

		clicked(list/params)
			if(opened)
				return ..()
			else
				opened = 1

			playsound(usr, pick(20;'sound/misc/openlootcrate.ogg',100;'sound/misc/openlootcrate2.ogg'), 120, 0)
			icon_state = "lootb2"
			flick("lootb1", src)

			SPAWN(2 SECONDS)
				var/mob/living/carbon/human/H = usr
				var/atom/movable/AM = null
				if (obj_path)
					AM = new obj_path()
				else
					AM = makeRandomLootTrash()
				if(istype(H))
					var/atom/movable/screen/lootcrateicon/background/B = new/atom/movable/screen/lootcrateicon/background(src)
					var/atom/movable/screen/lootcrateicon/sparks/S = new/atom/movable/screen/lootcrateicon/sparks(src)
					var/atom/movable/screen/lootcratepreview/P = new/atom/movable/screen/lootcratepreview(src)
					P.icon = AM.icon
					P.icon_state = AM.icon_state
					P.color = AM.color
					H.hud.add_screen(B)
					H.hud.add_screen(S)
					H.hud.add_screen(P)

					if (ishuman(usr) && AM)
						var/mob/living/carbon/human/dude = usr
						dude.put_in_hand_or_drop(AM)

					SPAWN(2.5 SECONDS)
						del(B)
						del(S)
						del(P)
						del(src)
			return ..()

/client/proc/getClientView(var/horizontal = 1)
	if(findtext(view, "x"))
		var/list/split = splittext(view, "x")
		if(horizontal) return text2num(split[1]) / 2
		else return text2num(split[2]) / 2
	else
		if(istext(view))
			return text2num(view)
		else
			return view
