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
		boutput(usr, "<span class='notice'>Now placing [kind] critters in single spawn mode.</span>")

	settings(var/ctrl, var/alt, var/shift)
		var/target = input(usr, "Which default setting to modify?", "Default setting", "aggressive") in list("aggressive", "atkcarbon", "atksilicon", "health", "opensdoors", "wanderer")
		if (!(target in critter_vars))
			critter_vars += target
		critter_vars[target] = input(usr, "Value for [target]", "Value", 0) as num

	var/static/list/critters = list(
		"Angry Bat" = /obj/critter/bat/buff,
		"Bear" = /obj/critter/bear,
		"Bee" = /obj/critter/domestic_bee,
		"Carebear" = /obj/critter/bear/care,
		"Darkness" = /obj/critter/shade,
		"Door (chompy)" = /obj/critter/monster_door,
		"Drone (CR)" = /obj/critter/gunbot/drone/buzzdrone,
		"Drone (Glitch)" = /obj/critter/gunbot/drone/glitchdrone,
		"Drone (HK)" = /obj/critter/gunbot/drone/heavydrone,
		"Drone (SC)" = /obj/critter/gunbot/drone,
		"Fermid" = /obj/critter/fermid,
		"Floating Thing" = /obj/critter/floateye,
		"Floor (chompy)" = /obj/critter/monster_door/floor,
		"Ice Spider" = /mob/living/critter/spider/ice,
		"Ice Spider (baby)" = /mob/living/critter/spider/ice/baby,
		"Ice Spider (queen)" = /mob/living/critter/spider/ice/queen,
		"Killer Tomato" = /obj/critter/killertomato,
		"Martian Psychic" = /obj/critter/martian/psychic,
		"Martian Sapper" = /obj/critter/martian/sapper,
		"Martian Soldier" = /obj/critter/martian/soldier,
		"Martian Warrior" = /obj/critter/martian/warrior,
		"Meat Mutant" = /obj/critter/blobman,
		"Meat Thing" = /obj/critter/blobman/meaty_martha,
		"Micro Man" = /obj/critter/microman,
		"Mimic" = /obj/critter/mimic,
		"Plasma Spore" = /obj/critter/spore,
		"Skeleton" = /obj/critter/magiczombie,
		"Space Wasp" = /obj/critter/wasp,
		"Spider" = /mob/living/critter/spider/spacerachnid,
		"Spirit" = /obj/critter/spirit,
		"Town Guard" = /obj/critter/townguard,
		"Transposed Particle Field" = /obj/critter/aberration,
		"Transposed Scientist" = /obj/critter/crunched,
		"Weird Thing" = /obj/critter/ancient_thing,
		"Brullbar" = /obj/critter/brullbar,
		"Brullbar (king)" = /obj/critter/brullbar/king,
		"Zapping Robot" = /obj/critter/ancient_repairbot/security,
		"Zombie" = /obj/critter/zombie,
		"Zombie (science)"  = /obj/critter/zombie/scientist,
		"Zombie (security)"  = /obj/critter/zombie/security,
	)
