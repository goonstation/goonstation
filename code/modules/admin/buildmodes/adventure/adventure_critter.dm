/datum/adventure_submode/critter
	name = "Critter"
	var/crittertype = null
	var/list/critter_vars = list()

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		var/obj/critter/C = new crittertype(get_turf(object))
		blink(get_turf(object))
		for (var/varname in critter_vars)
			C.vars[varname] = critter_vars[varname]

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (istype(object, /obj/critter))
			blink(get_turf(object))
			qdel(object)

	selected()
		var/kind = input(usr, "What kind of critter?", "Critter type", "Skeleton") in src.critters
		critter_vars = list()
		crittertype = src.critters[kind]
		boutput(usr, SPAN_NOTICE("Now placing [kind] critters in single spawn mode."))

	settings(var/ctrl, var/alt, var/shift)
		var/target = input(usr, "Which default setting to modify?", "Default setting", "aggressive") in list("aggressive", "atkcarbon", "atksilicon", "health", "opensdoors", "wanderer")
		if (!(target in critter_vars))
			critter_vars += target
		critter_vars[target] = input(usr, "Value for [target]", "Value", 0) as num

	var/static/list/critters = list(
		"Angry Bat" = /obj/critter/bat/buff,
		"Bear" = /mob/living/critter/bear,
		"Bee" = /obj/critter/domestic_bee,
		"Carebear" = /mob/living/critter/bear/care,
		"Darkness" = /mob/living/critter/shade,
		"Door (chompy)" = /obj/critter/monster_door,
		"Drone (CR)" = /obj/critter/gunbot/drone/buzzdrone,
		"Drone (Glitch)" = /obj/critter/gunbot/drone/glitchdrone,
		"Drone (HK)" = /obj/critter/gunbot/drone/heavydrone,
		"Drone (SC)" = /obj/critter/gunbot/drone,
		"Fermid" = /mob/living/critter/fermid,
		"Floating Thing" = /mob/living/critter/small_animal/floateye,
		"Floor (chompy)" = /obj/critter/monster_door/floor,
		"Ice Spider" = /mob/living/critter/spider/ice,
		"Ice Spider (baby)" = /mob/living/critter/spider/ice/baby,
		"Ice Spider (queen)" = /mob/living/critter/spider/ice/queen,
		"Killer Tomato" = /obj/critter/killertomato,
		"Martian Psychic" = /mob/living/critter/martian/mutant,
		"Martian Sapper" = /mob/living/critter/martian/sapper,
		"Martian Soldier" = /mob/living/critter/martian/soldier,
		"Martian Warrior" = /mob/living/critter/martian/warrior,
		"Meat Mutant" = /mob/living/critter/blobman,
		"Meat Thing" = /mob/living/critter/blobman/meat,
		"Micro Man" = /mob/living/critter/microman,
		"Mimic" = /mob/living/critter/mimic,
		"Plasma Spore" = /obj/critter/spore,
		"Skeleton" = /mob/living/critter/skeleton,
		"Space Wasp" = /mob/living/critter/small_animal/wasp,
		"Spider" = /mob/living/critter/spider/spacerachnid,
		"Spirit" = /obj/critter/spirit,
		"Town Guard" = /mob/living/critter/townguard,
		"Transposed Particle Field" = /mob/living/critter/aberration,
		"Transposed Scientist" = /mob/living/critter/crunched,
		"Weird Thing" = /obj/critter/ancient_thing,
		"Brullbar" = /mob/living/critter/brullbar,
		"Brullbar (king)" = /mob/living/critter/brullbar/king,
		"Zapping Robot" = /mob/living/critter/robotic/repairbot/security,
		"Zombie" = /mob/living/critter/zombie,
		"Zombie (science)"  = /mob/living/critter/zombie/scientist,
		"Zombie (security)"  = /mob/living/critter/zombie/security,
	)
