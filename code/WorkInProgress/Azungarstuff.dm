//AZARAK//


//AREAS//

/area/azarak/cave
	name = "azarak cave"
	icon_state = "azarak_cave"
	filler_turf = "/turf/unsimulated/floor/setpieces/Azarak/lavalethal"
	sound_environment = 21
	skip_sims = 1
	sims_score = 15
	sound_group = "azarak"

/area/azarak/retreat
	name = "azarak retreat"
	icon_state = "azarak_lava"
	filler_turf = "/turf/unsimulated/floor/setpieces/Azarak/lavalethal"
	sound_environment = 21
	skip_sims = 1
	sims_score = 15
	sound_group = "azarak"



//FLOORS//

/turf/unsimulated/floor/setpieces/Azarak/cavefloor
	name = "cave floor"
	desc = "Just some cave flooring. Wonder who was the last person to step on this..?."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "cave_floor"
	intact = 0

	floor2
		icon_state = "cave_floor2"

	floor3
		icon_state = "cave_floor3"

	edges
		icon_state = "cave_floor3_edges"

	underwalls
		icon_state = "lava_rockfloor"

/turf/unsimulated/floor/setpieces/Azarak/lavalethal
	name = "Lava"
	desc = "Some very very hot, dense liquid. Do not step on it."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "lava_floor"
	var/deadly = 1
	fullbright = 0
	pathable = 1
	can_replace_with_stuff = 0
	temperature = 10+T0C

	Entered(atom/movable/O)
		..()
		if(src.deadly && O.anchored != 2)
			if (istype(O, /obj/critter) && O:flying)
				return

			if (istype(O, /obj/projectile))
				return

			if (isintangible(O))
				return

			return_if_overlay_or_effect(O)

			if (O.throwing && !isliving(O))
				SPAWN_DBG(0.8 SECONDS)
					if (O && O.loc == src)
						melt_away(O)
				return

			melt_away(O)

	proc/melt_away(atom/movable/O)
		if (ismob(O))
			if (isliving(O))
				var/mob/living/M = O
				var/mob/living/carbon/human/H = M
				if (istype(H))
					H.unkillable = 0
				if(!M.stat) M.emote("scream")
				src.visible_message("<span class='alert'><B>[M]</B> falls into the [src] and melts away!</span>")
				M.firegib() // thanks ISN!
		else
			src.visible_message("<span class='alert'><B>[O]</B> falls into the [src] and melts away!</span>")
			qdel(O)

	ex_act(severity)
		return

	bubbling
		icon_state = "lava_floor_bubbling"

	bubbling2
		icon_state = "lava_floor_bubbling2"

/turf/unsimulated/floor/setpieces/Azarak/lava
	name = "lava edge"
	desc = "That is some seriously warm liquid.. Might not want to get too close to the edge."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "lava_edges"
	temperature = 10+T0C

	Entered(var/mob/M)
		if (istype(M,/mob/dead) || istype(M,/mob/wraith) || istype(M,/mob/living/intangible) || istype(M, /obj/lattice))
			return
		if(!ismob(M))
			return
		return_if_overlay_or_effect(M)


		SPAWN_DBG(0)
			if(M.loc == src)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					M.canmove = 0
					M.changeStatus("weakened", 6 SECONDS)
					boutput(M, "You get too close to the edge of the lava and spontaniously combust from the heat!")
					visible_message("<span class='alert'>[M] gets too close to the edge of the lava and spontaniously combusts from the heat!</span>")
					H.set_burning(500)
					playsound(M.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
					M.emote("scream")
				if (isrobot(M))
					M.canmove = 0
					M.TakeDamage("chest", pick(5,10), 0, DAMAGE_BURN)
					M.emote("scream")
					playsound(M.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
					boutput(M, "You get too close to the edge of the lava and spontaniously combust from the heat!")
					visible_message("<span class='alert'>[M] gets too close to the edge of the lava and their internal wiring suffers a major burn!</span>")
					M.changeStatus("stunned", 6 SECONDS)
			sleep(5 SECONDS)
			if(M.loc == src)
				if (ishuman(M))
					var/mob/living/carbon/human/H = M
					M.changeStatus("weakened", 10 SECONDS)
					M.set_body_icon_dirty()
					H.set_burning(1000)
					playsound(M.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
					M.emote("scream")
					if (H.limbs.l_leg && H.limbs.r_leg)
						if (H.limbs.l_leg)
							H.limbs.l_leg.delete()
						if (H.limbs.r_leg)
							H.limbs.r_leg.delete()
						boutput(M, "You can feel how both of your legs melt away!")
						visible_message("<span class='alert'>[M] continues to remain too close to the lava, their legs literally melting away!</span>")
					else
						boutput(M, "You can feel intense heat on the lower part of your torso.")
						visible_message("<span class='alert'>[M] continues to remain too close to the lava, if they had any legs, they would have melted away!</span>")

				if (isrobot(M))
					var/mob/living/silicon/robot/R = M
					R.canmove = 0
					R.TakeDamage("chest", pick(20,40), 0, DAMAGE_BURN)
					R.emote("scream")
					playsound(R.loc, "sound/effects/mag_fireballlaunch.ogg", 50, 0)
					R.changeStatus("stunned", 10 SECONDS)
					R.part_leg_r.holder = null
					qdel(R.part_leg_r)
					if (R.part_leg_r.slot == "leg_both")
						R.part_leg_l = null
						R.update_bodypart("l_leg")
					R.part_leg_r = null
					R.update_bodypart("r_leg")
					R.part_leg_l.holder = null
					qdel(R.part_leg_l)
					if (R.part_leg_l.slot == "leg_both")
						R.part_leg_r = null
						R.update_bodypart("r_leg")
					R.part_leg_l = null
					R.update_bodypart("l_leg")
					visible_message("<span class='alert'>[M] continues to remain too close to the lava, their legs literally melting away!</span>")
					boutput(M, "You can feel how both of your legs melt away!")
				else
					boutput(M, "You can feel intense heat on the lower part of your torso.")
					visible_message("<span class='alert'>[M] continues to remain too close to the lava, if they had any legs, they would have melted away!</span>")

	corners
		icon_state = "lava_corners"

	bubbling_edges
		icon_state = "lava_edges_bubbling"

/turf/unsimulated/floor/setpieces/Azarak/rockyfloor
	name = "rocky floor"
	desc = "Some rocky floor.."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "lava_rockfloor"
	temperature = 10+T0C

/turf/unsimulated/floor/carpet/purple
	icon = 'icons/turf/carpet.dmi'
	icon_state = "purple1"


/turf/unsimulated/floor/carpet/purple/decal
	icon = 'icons/turf/carpet.dmi'
	icon_state = "fpurple1"
	innercross
		dir = 1
	outercross
		dir = 4

/turf/unsimulated/floor/carpet/purple/standard/edge
	icon = 'icons/turf/carpet.dmi'
	icon_state = "purple2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/carpet/purple/standard/innercorner
	icon = 'icons/turf/carpet.dmi'
	icon_state = "purple3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "purple4"
		dir = 5
	se_triple
		icon_state = "purple4"
		dir = 6
	nw_triple
		icon_state = "purple4"
		dir = 9
	sw_triple
		icon_state = "purple4"
		dir = 10
	ne_sw
		icon_state = "purple1"
		dir = 5
	nw_se
		icon_state = "purple1"
		dir = 9
	omni
		icon_state = "purple1"
		dir = 8

/turf/unsimulated/floor/carpet/purple/standard/narrow
	icon = 'icons/turf/carpet.dmi'
	icon_state = "purple6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "purple4"
		dir = 1
	south
		icon_state = "purple4"
		dir = 2
	east
		icon_state = "purple4"
		dir = 4
	west
		icon_state = "purple4"
		dir = 8
	solo
		icon_state = "purple1"
		dir = 4
	northsouth
		icon_state = "purple1"
		dir = 6
	eastwest
		icon_state = "purple1"
		dir = 10

/turf/unsimulated/floor/carpet/purple/standard/junction
	icon = 'icons/turf/carpet.dmi'
	icon_state = "purple5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

//fancy subvariant///////////////////////

/turf/unsimulated/floor/carpet/purple/fancy/edge
	icon = 'icons/turf/carpet.dmi'
	icon_state = "fpurple2"

	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10

/turf/unsimulated/floor/carpet/purple/fancy/innercorner
	icon = 'icons/turf/carpet.dmi'
	icon_state = "fpurple3"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	north
		dir = 1
	south
		dir = 2
	east
		dir = 4
	west
		dir = 8
	ne_triple
		icon_state = "fpurple4"
		dir = 5
	se_triple
		icon_state = "fpurple4"
		dir = 6
	nw_triple
		icon_state = "fpurple4"
		dir = 9
	sw_triple
		icon_state = "fpurple4"
		dir = 10
	ne_sw
		icon_state = "fpurple1"
		dir = 5
	nw_se
		icon_state = "fpurple1"
		dir = 9
	omni
		icon_state = "fpurple1"
		dir = 8

/turf/unsimulated/floor/carpet/purple/fancy/narrow
	icon = 'icons/turf/carpet.dmi'
	icon_state = "fpurple6"

	ne
		dir = 5
	se
		dir = 6
	nw
		dir = 9
	sw
		dir = 10
	T_north
		dir = 1
	T_south
		dir = 2
	T_east
		dir = 4
	T_west
		dir = 8
	north
		icon_state = "fpurple4"
		dir = 1
	south
		icon_state = "fpurple4"
		dir = 2
	east
		icon_state = "fpurple4"
		dir = 4
	west
		icon_state = "fpurple4"
		dir = 8
	northsouth
		icon_state = "fpurple1"
		dir = 6
	eastwest
		icon_state = "fpurple1"
		dir = 10

/turf/unsimulated/floor/carpet/purple/fancy/junction
	icon = 'icons/turf/carpet.dmi'
	icon_state = "fpurple5"

	sw_e
		dir = 1
	ne_w
		dir = 2
	nw_s
		dir = 4
	se_n
		dir = 8
	sw_n
		dir = 5
	nw_e
		dir = 6
	ne_s
		dir = 9
	se_w
		dir = 10

/turf/unsimulated/wall/setpieces/Azarak/cavewall
	name = "rock wall"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "cave_wall"

	edges
		icon_state = "cave_wall_edges"

	corners
		icon_state = "cave_wall_corners"

/obj/decal/fakeobjects/bedrolls
	name = "bedrolls"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bedrolls"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/shrooms
	name = "weird looking mushrooms"
	desc = "What the hell are these..?"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "shrooms"
	anchored = 1

/obj/decal/fakeobjects/smallrocks
	name = "small rocks"
	desc = "Some small rocks."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "smallrocks"
	anchored = 1
	density = 1

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/mining_tool/power_pick))
			boutput(user, "You hit the [src] a few times with the [W]!")
			src.visible_message("<span class='notice'><b>[src] crumbles into dust!</b></span>")
			playsound(src.loc, 'sound/items/mining_pick.ogg', 90,1)
			qdel(src)

/obj/decal/fakeobjects/bigrocks
	name = "big rocks"
	desc = "Those are some big rocks, they are probably from the ceiling..?"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bigrocks"
	anchored = 1
	density = 1


	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/mining_tool/power_pick))
			boutput(user, "You hit the [src] a few times with the [W]!")
			src.visible_message("<span class='notice'><b>After a few hits [src] crumbles into smaller rocks.</b></span>")
			playsound(src.loc, 'sound/items/mining_pick.ogg', 90,1)
			new /obj/decal/fakeobjects/smallrocks(src.loc)
			qdel(src)

/obj/decal/fakeobjects/biggerrock
	name = "big rock"
	desc = "Seriously big rocks."
	icon = 'icons/obj/32x64.dmi'
	icon_state = "bigrock"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/azarakrocks
	name = "rock"
	desc = "Some lil' rocks."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "rock1"
	anchored = 1
	density = 1

	rock2
		name = "rocks"
		density = 0
		icon_state = "rock2"

	rock3
		name = "rocks"
		density = 0
		icon_state = "rock3"

	rock4
		name = "rocks"
		density = 0
		icon_state = "rock4"

	rock6
		name = "rocks"
		density = 0
		icon_state = "rock6"

	rock9
		name = "rocks"
		density = 0
		icon_state = "rock9"


/obj/decal/fakeobjects/cultiststatue
	name = "statue of a hooded figure"
	desc = "TEMP"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "cultiststatue"
	anchored = 1
	density = 1
	layer = EFFECTS_LAYER_UNDER_3

/obj/decal/fakeobjects/crossinverted
	name = "inverted cross"
	desc = "TEMP"
	icon = 'icons/obj/32x64.dmi'
	icon_state = "cross"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/bookcase
	name = "bookcase"
	desc = "It's a bookcase. Full of books."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bookcase"
	anchored = 1
	density = 0
	layer = DECAL_LAYER

/obj/decal/fakeobjects/creepytv
	name = "broken old television"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "creepytv"
	anchored = 1
	density = 1

/obj/decal/fakeobjects/circle
	name = "summoning circle"
	desc = "TEMP"
	icon = 'icons/effects/224x224.dmi'
	icon_state = "circle"
	anchored = 1
	density = 0
	opacity= 0
	layer = FLOOR_EQUIP_LAYER1

/obj/decal/fakeobjects/Azarakcandleswall
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "candles"
	name = "candles"
	desc = "TEMP"
	density = 0
	anchored = 1
	opacity = 0
	layer = FLOOR_EQUIP_LAYER1

	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.9)
		light.set_color(1, 0.6, 0)
		light.set_height(0.75)
		light.attach(src)
		light.enable()

/obj/decal/fakeobjects/Azarakcandles
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "candle"
	desc = "TEMP"
	density = 0
	anchored = 1
	opacity = 0

	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.8)
		light.set_color(1, 0.6, 0)
		light.set_height(0.75)
		light.attach(src)
		light.enable()

/*
/obj/decal/fakeobjects/Azarakaltar
	name = "altar"
	desc = "TEMP"
	icon_state = "altar"
	icon = 'icons/obj/64x96.dmi'
	density = 1
	anchored = 1

	attackby(obj/item/W as obj, mob/user as mob, params)
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (!G.state)
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return
			G.affecting.set_loc(src.loc)
			if (user.a_intent == "harm")
				if (!G.affecting.hasStatus("weakened"))
					G.affecting.changeStatus("weakened", 4 SECONDS)
				src.visible_message("<span class='alert'><b>[G.assailant] slams [G.affecting] onto \the [src]!</b></span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
				if (src.material)
					src.material.triggerOnAttacked(src, G.assailant, G.affecting, src)
			else
				if (!G.affecting.hasStatus("weakened"))
					G.affecting.changeStatus("weakened", 2 SECONDS)
				src.visible_message("<span class='alert'>[G.assailant] puts [G.affecting] on \the [src].</span>")

	place_on(obj/item/W as obj, mob/user as mob, params)
		..()
		if (. == 1) // successfully put thing on table, make a noise because we are a fancy special glass table
			return 1

/obj/cave_entrance
	name = "cave entrance"
	desc = "temp"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "cave_entrance"
	anchored = 1
	density = 0
	var/id = null

	New()
		..()
		if (!id)
			id = "generic"

		src.tag = "cave[id][src.icon_state == "cave_entrance" ? 0 : 1]"

	attack_hand(mob/user as mob)
		if (user.stat || user.getStatusDuration("weakened") || get_dist(user, src) > 1)
			return

		var/obj/cave_entrance/otherEntrance = locate("cave[id][src.icon_state == "cave_entrance"]")
		if (!istype(otherEntrance))
			return

		user.visible_message("", "You climb [src.icon_state == "cave_entrance" ? "down" : "up"] the stairs to the [src.icon_state == "cave_entrance" ? "cave" : "surface"]. ")
		user.set_loc(get_turf(otherEntrance))


/MOVE THIS INTO REAGENTS-EXPLOSIVEFIRE.DM LATER//

		//combustible/nitrogentriiodide/dry/hellshroom
			//name = "Hellshroom Extract"
			//id = "hellshroom"
			//description = "An organic substance that is extremely volatile due to it being so dry. Rather fascinating."

//MOVE THIS TO SEEDS.DM LATER//

/obj/item/seed/alien/hellshroom
	New()
		..()
		src.planttype = HY_get_species_from_path(/datum/plant/artifact/hellshroom, src)

//MOVE THIS TO SNACKS.DM LATER//

/obj/item/reagent_containers/food/snacks/hellshroom
	name = "hellshroom"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "hellshroom_produce"
	amount = 1
	heal_amt = 0
	initial_reagents = list("hellshroom_extract"=6)

//MOVE THIS TO PLANTS_ALIEN.DM LATER//

/datum/plant/artifact/hellshroom
	name = "Hellshroom"
	growthmode = "weed"
	category = "Miscellaneous"
	seedcolor = "#FF0000"
	override_icon_state = "hellshroom"
	crop = /obj/item/reagent_containers/food/snacks/hellshroom
	starthealth = 10
	nothirst = 1
	starthealth = 20
	growtime = 180
	harvtime = 250
	harvests = 10
	endurance = 20
	cropsize = 2
	force_seed_on_harvest = 1
	vending = 2
	genome = 30
	assoc_reagents = list("hellshroom_extract")

//MOVE THIS TO MISC_WEAPONS.DM LATER//

/obj/item/dagger/azarakknife
	name = "sacrificial knife"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "sacknife"
	inhand_image_icon = 'icons/misc/AzungarAdventure.dmi'
	item_state = "sacknife"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	tool_flags = TOOL_CUTTING
	hit_type = DAMAGE_CUT
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	force = 5.0
	throwforce = 15.0
	throw_range = 5
	desc = "TEMP"
	pickup_sfx = "sound/items/blade_pull.ogg"
	stamina_damage = 15
	stamina_cost = 15
	stamina_crit_chance = 50

//MOVE TO SMALL_ANIMALS.DM LATER//

/obj/critter/bat/hellbat
	name = "hellbat"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "hellbat"
	health = 35
	aggressive = 1
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	brutevuln = 0.7
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	seekrange = 5
	flying = 1
	density = 1 // so lasers can hit them
	angertext = "screeches at"

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> launches itself at [M]!</span>")
		if (prob(30)) M.changeStatus("weakened", 2 SECONDS)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='combat'><B>[src]</B> bites and claws at [src.target]!</span>")
		random_brute_damage(src.target, rand(3,5))
		random_burn_damage(src.target, rand(2,3))
		SPAWN_DBG(1 SECOND)
			src.attacking = 0


//MOVE TO HEART.DM LATER//

/obj/item/organ/heart/eldritchadventure
	name = "tainted heart"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "artifact_eldritchHeart"
	edible = 0

/mob/living/carbon/human/npc/cultist
	name = "Crazed cultist"
	real_name = "Crazed cultist"
	ai_aggressive = 1
	unobservable = 1

	New()
		..()
		SPAWN_DBG(0)
			bioHolder.mobAppearance.underwear = "briefs"
			JobEquipSpawned("DO NOT USE THIS JOB")
			update_clothing()
			//src.equip_new_if_possible(/obj/item/clothing/shoes/dress_shoes, slot_shoes)
			//src.equip_new_if_possible(/obj/item/clothing/under/suit/purple, slot_w_uniform)
			//src.equip_new_if_possible(/obj/item/clothing/suit/cultistblack/cursed, slot_wear_suit)
			//src.equip_new_if_possible(/obj/item/clothing/mask/eldritchskull {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_wear_mask)
			//src.equip_new_if_possible(/obj/item/dagger/azarakknife {cant_drop = 1; cant_other_remove = 1; cant_self_remove = 1} , slot_r_hand)

			var/obj/item/organ/heart/eldritchadventure/H = new /obj/item/organ/heart/eldritchadventure
			receive_organ(H, "heart", 0, 1)
			return




/datum/job/special/DONOTUSETHISJOB
	name = "DO NOT USE THIS JOB"
	limit = 0
	wages = 0
	slot_jump = /obj/item/clothing/under/suit/purple
	slot_foot = /obj/item/clothing/shoes/dress_shoes
	slot_rhan = null
	slot_back = null
	slot_card = null
	slot_ears = null
	slot_poc1 = null
	slot_poc2 = null

*/

/obj/syndicateholoemitter
	name = "Holo-emitter"
	desc = "A compact holo emitter pre-loaded with a holographic image."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "emitter-on"
	flags = FPRINT | TABLEPASS
	anchored = 2

/obj/juggleplaque/manta
	name = "dedication plaque"
	desc = "Dedicated to Lieutenant Emily Claire for her brave sacrifice aboard NSS Manta - \"May their sacrifice not paint a grim picture of things to come. - Space Commodore J. Ledger\""
	pixel_y = 25

/obj/abzuholo
	desc = "... is that Absu..?"
	name = "... is that Absu..?"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoplanet"
	alpha = 180
	pixel_y = 16
	anchored = 2
	layer = EFFECTS_LAYER_BASE
	var/datum/light/light
	var/obj/holoparticles/holoparticles

	New(var/_loc)
		set_loc(_loc)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.50, 0.60, 0.94)
		light.set_brightness(0.7)
		light.enable()

		SPAWN_DBG(1 DECI SECOND)
			animate(src, alpha=130, color="#DDDDDD", time=7, loop=-1)
			animate(alpha=180, color="#FFFFFF", time=1)
			animate(src, pixel_y=10, time=15, flags=ANIMATION_PARALLEL, easing=SINE_EASING, loop=-1)
			animate(pixel_y=16, easing=SINE_EASING, time=15)

		holoparticles = new/obj/holoparticles(src.loc)
		attached_objs = list(holoparticles)
		..(_loc)

	disposing()
		if(holoparticles)
			holoparticles.invisibility = 101
			qdel(holoparticles)
		..()

/obj/holoparticles
	desc = ""
	name = ""
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holoparticles"
	anchored = 1
	alpha= 230
	pixel_y = 14
	layer = EFFECTS_LAYER_BASE

/obj/dispenser
	name = "handcuff dispenser"
	desc = "A handy dispenser for handcuffs."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_handcuffs"
	var/amount = 3

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/handcuffs))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, "<span class='notice'>You put a pair of handcuffs in the [src]. [amount] left in the dispenser.</span>")
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/handcuffs, user.hand)
			boutput(user, "<span class='alert'>You take a pair of handcuffs from the [src]. [amount] left in the dispenser.</span>")
			if (src.amount <= 0)
				src.icon_state = "dispenser_handcuffs"
		else
			boutput(user, "<span class='alert'>There's no handcuffs left in the [src]!</span>")

/obj/decal/fakeobjects/mantacontainer
	name = "container"
	desc = "These huge containers are used to transport goods from one place to another."
	icon = 'icons/obj/64x96.dmi'
	icon_state = "manta"
	anchored = 2
	density = 1
	bound_height = 32
	bound_width = 96
	layer = EFFECTS_LAYER_BASE

	attack_hand(mob/user as mob)
		if (can_reach(user,src))
			boutput(user, "<span class='alert'>You attempt to open the container but its doors are sealed tight. It doesn't look like you'll be able to open it.</span>")
			playsound(src.loc, "sound/machines/door_locked.ogg", 50, 1, -2)

	yellow
		icon_state = "mantayellow"
	blue
		icon_state = "mantablue"

/obj/decal/fakeobjects/mantacontainer/upwards
		name = "container"
		desc = "These huge containers are used to transport goods from one place to another."
		icon = 'icons/obj/96x64.dmi'
		icon_state = "manta"
		anchored = 2
		density = 1
		bound_height = 96
		bound_width = 64
		layer = EFFECTS_LAYER_BASE

/obj/decal/fakeobjects/mantacontainer/upwards/yellow
	icon_state = "mantayellow"

/obj/roulette_table_w //Big thanks to Haine for the sprite and parts of the code!
	name = "roulette wheel"
	desc = "A table with a built-in roulette wheel and a little ball. The numbers are evenly distributed between black and red, except for the zero which is green. Unlike most of tables you'd find in America, this one only has a single zero, lowering the house edge to about 2.7% on almost every bet. Truly generous."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_w0"
	anchored = 1
	density = 1
	var/running = 0
	var/run_time = 40
	var/last_result = "red"
	var/list/nums_red = list(1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36)
	var/list/nums_black = list(2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35)
	var/last_result_text = null

	attack_hand(mob/user)
		src.spin(user)

	get_desc()
		return last_result_text ? "<br>The ball is currently on [last_result_text]." : ""

	proc/update_icon()
		if (running == 0)
			src.icon_state = "roulette_w0"
		else if (running == 1)
			src.icon_state = "roulette_w1"

	proc/spin(mob/user)
		src.maptext = ""
		if (src.running)
			if (user)
				user.show_text("[src] is already spinning, be patient!","red")
			return
		if (user)
			src.visible_message("[user] spins [src]!")
		else
			src.visible_message("[src] starts spinning!")
		src.running = 1
		update_icon()
		var/real_run_time = rand(src.run_time - 10, src.run_time + 10)
		sleep(real_run_time - 10)
		playsound(src.loc, "sound/items/coindrop.ogg", 30, 1)
		sleep(1 SECOND)

		src.last_result = rand(0,36)
		var/result_color = ""
		var/background_color = ""
		if (last_result in nums_red)
			result_color = "red"
			background_color = "#aa3333"
		else if (last_result in nums_black)
			result_color = "black"
			background_color = "#444444"
		else
			result_color = "green"
			background_color = "#33aa33"

		last_result_text = "<span style='padding: 0 0.5em; color: white; background-color: [background_color];'>[src.last_result]</span> [result_color]"
		src.visible_message("<span class='success'>[src] lands on [last_result_text]!</span>")
		src.running = 0
		update_icon()
		sleep(1 SECONDS)
		src.maptext_x = -1
		src.maptext_y = 8
		src.maptext = "<span class='xfont sh c vm' style='background: [background_color];'> [src.last_result] </span>"
		SPAWN_DBG(4 SECONDS)
			src.maptext = ""


/obj/decal/fakeobjects/turbinetest
		name = "TEMP"
		desc = "TEMP"
		icon = 'icons/obj/96x160.dmi'
		icon_state = "turbine_main"
		anchored = 2
		density = 1
		bound_height = 160
		bound_width = 96

/obj/decal/fakeobjects/nuclearcomputertest
		name = "TEMP"
		desc = "TEMP"
		icon = 'icons/obj/32x96.dmi'
		icon_state = "nuclearcomputer"
		anchored = 2
		density = 1
		bound_height = 96
		bound_width = 32

//Shamelessly stolen from Keelinstuff.dm

/obj/item/lawbook
	name = "Space Law 1st Print"
	desc = "A very rare first print of the fabled Space Law book."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "lawbook"

	density = 0
	opacity = 0
	anchored = 1

	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "lawbook"
	item_state = "lawbook"

	//throwforce = 10
	throw_range = 10
	throw_speed = 1
	throw_return = 1

	var/prob_clonk = 0

	New()
		..()
		BLOCK_SETUP(BLOCK_BOOK)

	throw_begin(atom/target)
		icon_state = "lawspin"
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		icon_state = "lawbook"
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and is clonked on the head!</B></span>")
				playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.changeStatus("stunned", 50)
				user.changeStatus("weakened", 3 SECONDS)
				user.changeStatus("paralysis", 2 SECONDS)
				user.force_laydown_standup()
			else
				src.attack_hand(usr)
			return
		else
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/user = usr
				var/hos = (istype(user.head, /obj/item/clothing/head/hosberet) || istype(user.head, /obj/item/clothing/head/helmet/HoS))
				if(hos)
					var/mob/living/carbon/human/H = hit_atom
					H.changeStatus("stunned", 90)
					H.changeStatus("weakened", 2 SECONDS)
					H.force_laydown_standup()
					//H.paralysis++
					playsound(H.loc, "swing_hit", 50, 1)
					usr.say("I AM THE LAW!")
				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN_DBG(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

/obj/portalmartian
	name = "portal"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	anchored = 1
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports
	var/busy = 0
	layer = 2



	Bumped(mob/user as mob)
		if(busy) return
		if(get_dist(user, src) > 1 || user.z != src.z) return
		src.add_dialog(user)
		busy = 1
		showswirl(user.loc)
		playsound(src, 'sound/effects/teleport.ogg', 60, 1)
		SPAWN_DBG(1 SECOND)
		teleport(user)
		busy = 0

	proc/teleport(mob/user)
		for(var/obj/portalmartian/S) // in world AUGHHH
			if(S.id == src.id && S != src)
				if(recharging == 1)
					return 1
				else
					S.recharging = 1
					src.recharging = 1
					user.set_loc(S.loc)
					showswirl(user.loc)
					SPAWN_DBG(recharge)
						S.recharging = 0
						src.recharging = 0
				return

/obj/critter/bat/hellbat
	name = "ancient bat"
	desc = "This bat must be really old!"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "hellbat"
	health = 35
	aggressive = 1
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	brutevuln = 0.7
	opensdoors = OBJ_CRITTER_OPENS_DOORS_NONE
	seekrange = 5
	flying = 1
	density = 1 // so lasers can hit them
	angertext = "screeches at"

	seek_target()
		src.anchored = 0
		for (var/mob/living/C in hearers(src.seekrange,src))
			if (src.target)
				src.task = "chasing"
				break
			if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if (iscarbon(C) && !src.atkcarbon) continue
			if (issilicon(C) && !src.atksilicon) continue
			if (C.health < 0) continue
			if (C in src.friends) continue
			if (C.name == src.attacker) src.attack = 1
			if (iscarbon(C) && src.atkcarbon) src.attack = 1
			if (issilicon(C) && src.atksilicon) src.attack = 1

			if (src.attack)
				src.target = C
				src.oldtarget_name = C.name
				src.visible_message("<span class='combat'><b>[src]</b> [src.angertext] [C.name]!</span>")
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		src.visible_message("<span class='combat'><B>[src]</B> launches itself at [M]!</span>")
		if (prob(30)) M.changeStatus("weakened", 2 SECONDS)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message("<span class='combat'><B>[src]</B> bites and claws at [src.target]!</span>")
		random_brute_damage(src.target, rand(3,5),1)
		random_burn_damage(src.target, rand(2,3))
		SPAWN_DBG(1 SECOND)
			src.attacking = 0

	CritterDeath()
		..()
		qdel(src)

/obj/item/rpcargotele
	name = "special cargo transporter"
	desc = "A device for teleporting crated goods. There is something really, really shady about this.."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "syndicargotele"
	w_class = 2
	flags = ONBELT
	mats = 4

/obj/decoration/scenario/crate
	name = "NT vital supplies crate"
	anchored = 2
	density = 1
	desc = "A tightly locked metal crate."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ntcrate"

	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if (istype(I, /obj/item/rpcargotele))
			actions.start(new /datum/action/bar/icon/scenariocrate(src, I, 300), user)

/datum/action/bar/icon/scenariocrate
	id = "scenariocrate"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 300
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "cargotele"

	var/obj/decoration/scenario/crate/thecrate
	var/obj/item/the_tool

	New(var/obj/O, var/obj/item/tool, var/duration_i)
		..()
		if (O)
			thecrate = O
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (duration_i)
			duration = duration_i

	onUpdate()
		..()
		if (thecrate == null || the_tool == null || owner == null || get_dist(owner, thecrate) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(get_turf(thecrate), "sound/machines/click.ogg", 60, 1)
		owner.visible_message("<span class='notice'>[owner] starts to calibrate the cargo teleporter in a suspicious manner.</span>")
	onEnd()
		..()
		owner.visible_message("<span class='alert'>[owner] has successfully teleported the NT vital supplies somewhere else!</span>")
		showswirl(thecrate.loc)
		qdel(thecrate)
		message_admins("One of the NT supply crates has been succesfully teleported!")
		boutput(owner, "<span class='notice'>You have successfully teleported one of the supply crates to the Syndicate.</span>")
		playsound(get_turf(thecrate), "sound/machines/click.ogg", 60, 1)
