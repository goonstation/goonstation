/proc/bonegibs(turf/T, viral_list, list/ejectables, bdna, btype)
	var/list/dirlist = list(list(NORTH, NORTHEAST, NORTHWEST), \
		                    list(SOUTH, SOUTHEAST, SOUTHWEST), \
		                    list(WEST, NORTHWEST, SOUTHWEST),  \
		                    list(EAST, NORTHEAST, SOUTHEAST))

	var/list/produce = list()

	for (var/i = 1, i <= 4, i++)
		var/PT = /obj/item/material_piece/bone
		var/obj/item/material_piece/bone/P = new PT
		P.set_loc(T)
		SPAWN(0)
			for (var/k = 1, k <= 3, k++)
			P.streak_object(dirlist[i])
		produce += P

	var/extra = rand(2,4)
	for (var/i = 1, i <= extra, i++)
		var/PT = /obj/item/material_piece/bone
		var/obj/item/material_piece/bone/P  = new PT
		P.set_loc(T)
		P.streak_object(alldirs)
		produce += P

	return produce


/mob/living/critter/skeleton
	name = "skeleton"
	real_name = "skeleton"
	desc = "Clak clak, motherfucker."
	density = 1
	icon_state = "skeleton"
	icon_state_dead = "skeleton-dead"
	custom_gib_handler = /proc/bonegibs
	hand_count = 2
	can_throw = 1
	can_grab = 1
	can_disarm = 1
	blood_id = null
	burning_suffix = "humanoid"
	metabolizes = 0
	mob_flags = IS_BONEY

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream", "clak")
				if (src.emote_check(voluntary, 50))
					playsound(src, 'sound/items/Scissor.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<span class='alert'>[src] claks!</span>"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "clak")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/suit(src)
		equipment += new /datum/equipmentHolder/ears(src)
		var/list/hats = list(new /datum/equipmentHolder/head/skeleton(src))
		equipment += hats[1]
		for (var/i = 1, i <= 10, i++)
			var/datum/equipmentHolder/head/skeleton/S = hats[i]
			var/datum/equipmentHolder/head/skeleton/S1 = S.spawn_next()
			hats += S1
			equipment += S1

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.icon_state = "handl"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"

	setup_healths()
		add_hh_flesh(50, 1)
		add_hh_flesh_burn(50, 0.7)
