/* -----------------------------------------------------------------------------*\
CONTENTS:
BIODOME AND BIODOME CAVE AREAS
LAVA TURFS - TODO:MOVE TO TURF.DM OR WHATEVER
LIGHT SHAFT
DECALS - maybe move to decals.dm when not lazy
	STALAGTITE & STALAGMITE
	SNOW
	RUNE MARKS
	CLIFF
	STATUE
	SEE NO EVIL HEAR NO EVIL SEE NO EVIL MONKEY STATUES
	WOOD CLUTTER
	MUSHROOMS
SNEAKY SHIFTING WALLS
WHIP
BOULDER TRAP
ANCIENT ARMOR
GRAVEYARD STUFF
ALCHEMY CIRCLE STUFF
CRASHING SATTELITE
SYNDICATE DRONE FACTORY AREAS
\*----------------------------------------------------------------------------- */

/area/crater
	name = "Cenote"  // renamed, crater doesn't make any sense here
	icon_state = "yellow"
	force_fullbright = 0
	sound_environment = 18
	skip_sims = 1
	sims_score = 30
	sound_group = "biodome"

/area/crater/biodome
	name = "Botanical Research Outpost Gamma"
	icon_state = "green"
	force_fullbright = 0
	sound_environment = 1
	skip_sims = 1
	sims_score = 30

	north
		name = "Biodome North"
		sound_environment = 7

	south
		name = "Biodome South"
		sound_environment = 7

	entry
		name = "Biodome Entrance"
		icon_state = "shuttle"
		sound_environment = 3

	research
		name = "Biodome Research Core"
		icon_state = "toxlab"
		sound_environment = 2

	crew
		name = "Biodome Staff Wing"
		icon_state = "crewquarters"
		sound_environment = 2

	maint
		name = "Biodome Maintenance Wing"
		icon_state = "yellow"
		sound_environment = 3

/area/crater/cave
	name = "Moist Caves"
	icon_state = "purple"
	force_fullbright = 0
	sound_environment = 8
	skip_sims = 1
	sims_score = 30

/area/crater/cave/lower
	name = "Lower Moist Caves"
	icon_state = "purple"
	force_fullbright = 0
	skip_sims = 1
	sims_score = 30

/turf/unsimulated/floor/cave
	name = "cave floor"
	icon_state = "cave-medium"
	fullbright = 0

/turf/unsimulated/wall/cave
	name = "cave wall"
	icon_state = "cave-dark"
	fullbright = 0


////////////////// BIODOME EXPANSION PROJECT AREAS ///////////////////
/area/swampzone
	name = "X-05 Fatuus"
	icon_state = "green"
	force_fullbright = 0
	filler_turf = "/turf/unsimulated/floor/auto/dirt"
	ambient_light = rgb(75, 100, 100)
	sound_environment = 15
	skip_sims = 1
	sims_score = 0
	sound_group = "swamp_outdoors"
	var/list/sfx_to_pick_from = list('sound/ambience/nature/Rain_ThunderDistant.ogg',\
		'sound/ambience/nature/Wind_Cold1.ogg',\
		'sound/ambience/nature/Wind_Cold2.ogg',\
		'sound/ambience/nature/Wind_Cold3.ogg',\
		'sound/ambience/nature/Lavamoon_RocksBreaking1.ogg',\
		'sound/voice/Zgroan1.ogg',\
		'sound/voice/Zgroan2.ogg',\
		'sound/voice/Zgroan3.ogg',\
		'sound/voice/Zgroan4.ogg',\
		'sound/voice/animal/werewolf_howl.ogg')

/area/swampzone/New()
	. = ..()
	START_TRACKING_CAT(TR_CAT_AREA_PROCESS)

/area/swampzone/disposing()
	STOP_TRACKING_CAT(TR_CAT_AREA_PROCESS)
	. = ..()

/area/swampzone/area_process()
	if(prob(20))
		src.sound_fx_2 = pick(sfx_to_pick_from)

		for(var/mob/living/carbon/human/H in src)
			H.client?.playAmbience(src, AMBIENCE_FX_2, 50)

/area/swampzone/heights
	name = "X-05 Heights"
	icon_state = "blue"
	ambient_light = rgb(180, 150, 150)
	sound_group = "swamp_heights"
	sound_loop = 'sound/ambience/nature/Rain_Heavy.ogg'

	New()
		. = ..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "rain_overlay", layer = EFFECTS_LAYER_BASE)

/area/swampzone/ground
	name = "X-05 Swamplands"
	sound_group = "swamp_surface"
	sound_loop = 'sound/ambience/nature/Rain_Heavy.ogg'
	sound_environment = 19

	New()
		. = ..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "rain_overlay", layer = EFFECTS_LAYER_BASE)

/area/swampzone/ground/forest
	name = "X-05 Forest"
	sound_group = "swamp_forest"
	sound_environment = 15

/area/swampzone/ground/canyon
	name = "X-05 Canyon"
	sound_group = "swamp_canyon"
	sound_environment = 14

/area/swampzone/deeps
	name = "X-05 Deep Swamp"
	icon_state = "green"
	ambient_light = rgb(10, 50, 35)
	sound_group = "swamp_deeps"
	sound_environment = 22
	sound_loop = 'sound/ambience/station/Underwater/ocean_ambi2.ogg'
	sfx_to_pick_from = list('sound/ambience/nature/Lavamoon_DeepBubble1.ogg',\
	'sound/ambience/nature/Lavamoon_DeepBubble2.ogg',\
	'sound/ambience/nature/Lavamoon_RocksBreaking1.ogg',\
	'sound/voice/Zgroan1.ogg',\
	'sound/voice/Zgroan2.ogg',\
	'sound/voice/Zgroan3.ogg',\
	'sound/voice/Zgroan4.ogg')

	New()
		. = ..()
		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "swampwater-overlay", layer = EFFECTS_LAYER_BASE)


// interiors //
/area/swampzone/interiors
	name = "X-05 Settlement"
	icon_state = "yellow"
	ambient_light = null
	sound_environment = 2
	sound_loop = 'sound/ambience/station/Station_MechanicalThrum2.ogg'

	outbuildings
		name = "X-05 Outbuildings"
		sound_group = "swamp_outbuildings"
		icon_state = "blue"

	tunnels
		name = "X-05 Utility Tunnels"
		sound_group = "swamp_tunnels"
		icon_state = "orange"
		sound_environment = 13

	basements
		name = "X-05 Basements"
		sound_group = null
		icon_state = "yellow"
		sound_environment = 5

	bonktek
		name = "BonkTek Pyramid"
		sound_group = "swamp_bonktek"
		icon_state = "purple"
		sound_environment = 9
		sound_loop = 'sound/ambience/station/Station_MechanicalThrum5.ogg'

		lounge
			name = "Zero G-Tek Lounge"
			sound_environment = 11
			sound_loop = 'sound/ambience/station/JazzLounge1.ogg'

		security
			name = "Bonktek Security Office"
			icon_state = "red"
			sound_environment = 2

		waffletek
			name = "WaffleTek Restaurant"
			icon_state = "blue"
			sound_environment = 4

		funktek
			name = "FunkTek Shop"
			icon_state = "blue"
			sound_environment = 4

		blastotek
			name = "BlastoTek Shop"
			icon_state = "blue"
			sound_environment = 4

		shootingrange
			name = "BlastoTek Shooting Range"
			icon_state = "red"
			sound_environment = 10

		genetek
			name = "GeneTek Office"
			icon_state = "blue"
			sound_environment = 5

		electek
			name = "ElecTek Substation"
			icon_state = "yellow"
			sound_environment = 2

		bathroom
			name = "Bathroom"
			icon_state = "white"
			sound_environment = 3

		maintenance
			name = "Bonktek Maintenance Corridors"
			icon_state = "orange"
			sound_environment = 13

	quarry
		name = "X-05 Quarry"
		icon_state = "orange"
		sound_group = "swamp_quarry"
		sound_environment = 18


	caves
		name = "X-05 Caves"
		icon_state = "blue"
		sound_group = "swamp_caves"
		sound_environment = 8
////////////////////// crypt place

/area/crypt
	sound_group = "crypt"

/area/crypt/graveyard
	name = "Graveyard"
	icon_state = "green"
	force_fullbright = 0
	filler_turf = "/turf/unsimulated/dirt"
	sound_environment = 15
	skip_sims = 1
	sims_score = 0
	sound_group = "spooky_swamp"
	sound_loop = 'sound/ambience/nature/Rain_Heavy.ogg'

	New()
		..()

		overlays += image(icon = 'icons/turf/areas.dmi', icon_state = "rain_overlay", layer = EFFECTS_LAYER_BASE)
		SPAWN(1 SECOND)
			process()

	proc/process()
		while(current_state < GAME_STATE_FINISHED)
			sleep(10 SECONDS)
			if (current_state == GAME_STATE_PLAYING)
				if(!played_fx_2 && prob(10))
					sound_fx_2 = pick('sound/ambience/nature/Rain_ThunderDistant.ogg','sound/ambience/nature/Wind_Cold1.ogg','sound/ambience/nature/Wind_Cold2.ogg','sound/ambience/nature/Wind_Cold3.ogg','sound/ambience/nature/Lavamoon_RocksBreaking1.ogg', 'sound/voice/Zgroan1.ogg', 'sound/voice/Zgroan2.ogg', 'sound/voice/Zgroan3.ogg', 'sound/voice/Zgroan4.ogg', 'sound/voice/animal/werewolf_howl.ogg')
					for(var/mob/M in src)
						if (M.client)
							M.client.playAmbience(src, AMBIENCE_FX_2, 50)


/area/crypt/graveyard/swamp
	name = "Courtyard" // renamed
	icon_state = "red"
	skip_sims = 1
	sims_score = 30

/area/crypt/mausoleum
	name = "Mausoleum"
	icon_state = "purple"
	force_fullbright = 0
	sound_environment = 5
	skip_sims = 1
	sims_score = 0



//// Jam Mansion 3.0
/area/crypt/sigma
	name = "Research Facility Sigma"
	icon_state = "derelict"
	sound_loop = 'sound/ambience/spooky/Evilreaver_Ambience.ogg'

/area/crypt/sigma/mainhall
	icon_state = "chapel"
	name = "Facility Sigma Main Hall"

/area/crypt/sigma/rd
	icon_state = "bridge"
	name = "Facility Sigma Director's Quarters"

/area/crypt/sigma/lab
	icon_state = "toxlab"
	name = "Facility Sigma Laboratory"

/area/crypt/sigma/crew
	icon_state = "crewquarters"
	name = "Facility Sigma Personnel's Quarters"

/area/crypt/sigma/kitchen
	icon_state = "kitchen"
	name = "Facility Sigma Kitchen"

/area/crypt/sigma/storage
	icon_state = "storage"
	name = "Facility Sigma Storage Rooms"

/area/crypt/sigma/morgue
	icon_state = "purple"
	name = "Facility Sigma Morgue"

/area/catacombs
	name = "Catacombs"
	icon_state = "purple"
	force_fullbright = 0
	sound_environment = 13
	skip_sims = 1
	sims_score = 0
	sound_group = "catacombs"

////// lava turf

/turf/unsimulated/floor/lava
	name = "Lava"
	desc = "The floor is lava. Oh no."
	icon_state = "lava"
	var/deadly = 1
	fullbright = 0
	pathable = 0
	can_replace_with_stuff = 1

	Entered(atom/movable/O, atom/old_loc)
		..()
		if(src.deadly && !(isnull(old_loc) || O.anchored == 2))
			if (istype(O, /obj/critter) && O:flying)
				return

			if (istype(O, /obj/projectile))
				return

			if (isintangible(O))
				return

			return_if_overlay_or_effect(O)

			if (O.throwing && !isliving(O))
				SPAWN(0.8 SECONDS)
					if (O && O.loc == src)
						melt_away(O)
				return

			melt_away(O)


	proc/melt_away(atom/movable/O)
		#ifdef CHECK_MORE_RUNTIMES
		if(current_state <= GAME_STATE_WORLD_NEW)
			CRASH("[identify_object(O)] melted in lava at [src.x],[src.y],[src.z] ([src.loc] [src.loc.type]) during world initialization")
		#endif
		if (ismob(O))
			if (isliving(O))
				var/mob/living/M = O
				var/mob/living/carbon/human/H = M
				if (istype(H))
					H.unkillable = 0
				if(!M.stat) M.emote("scream")
				src.visible_message("<span class='alert'><B>[M]</B> falls into the [src] and melts away!</span>")
				logTheThing(LOG_COMBAT, M, "was firegibbed by [src] ([src.type]) at [log_loc(M)].")
				M.firegib() // thanks ISN!
		else
			src.visible_message("<span class='alert'><B>[O]</B> falls into the [src] and melts away!</span>")
			qdel(O)

	ex_act(severity)
		return

/obj/decal/lightshaft
	name = "light"
	desc = "There's light coming through a hole in the ceiling."
	density = 0
	anchored = 1
	opacity = 0
	mouse_opacity = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	plane = PLANE_NOSHADOW_ABOVE
	icon = 'icons/effects/64x64.dmi'
	icon_state = "lightshaft"
	luminosity = 2

/obj/decal/stalagtite
	name = "stalactite" // c, not g! c as in ceiling, g as in ground. dang!
	desc = "It's a stalactite."
	density = 0
	anchored = 1
	opacity = 0
	layer = EFFECTS_LAYER_BASE
	icon = 'icons/misc/exploration.dmi'
	icon_state = "stal1"

/obj/decal/stalagmite
	name = "stalagmite"
	desc = "It's a stalagmite."
	density = 1
	anchored = 1
	opacity = 0
	layer = EFFECTS_LAYER_BASE
	icon = 'icons/misc/exploration.dmi'
	icon_state = "stal2"

/obj/decal/snowbits
	name = "snow"
	desc = "A bit of snow."
	density = 0
	anchored = 1
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "snowbits"

/obj/decal/runemarks
	name = "runes"
	desc = "A set of dimly glowing runes is carved into the rock here."
	density = 0
	anchored = 1
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "runemarks"

/obj/decal/cliff
	name = "cliff"
	desc = "The edge of a cliff."
	density = 0
	anchored = 2
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "cliff"

/obj/decal/cliff/shore
	name = "water's edge"
	desc = "The edge of an underground pool."

/obj/decal/statue
	name = "statue"
	desc = "A statue of some humanoid being."
	density = 1
	anchored = 1
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "stat1"

/obj/decal/statue/monkey1
	desc = "A statue of a monkey of some sort."
	icon_state = "stat2"

/obj/decal/statue/monkey2
	desc = "A statue of a monkey of some sort."
	icon_state = "stat3"

/obj/decal/statue/monkey3
	desc = "A statue of a monkey of some sort."
	icon_state = "stat4"

/obj/decal/woodclutter
	name = "pieces of wood"
	desc = "Theres bits and pieces of wood all over the place."
	density = 0
	anchored = 1
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "woodclutter4"

/obj/decal/mushrooms
	name = "mushroom"
	desc = "Some sort of mushroom."
	density = 0
	anchored = 1
	opacity = 0
	layer = OBJ_LAYER
	icon = 'icons/misc/exploration.dmi'
	icon_state = "mushroom7"

/obj/decal/mushrooms/type1
	icon_state = "mushroom1"

/obj/decal/mushrooms/type2
	icon_state = "mushroom2"

/obj/decal/mushrooms/type3
	icon_state = "mushroom3"

/obj/decal/mushrooms/type4
	icon_state = "mushroom4"

/obj/decal/mushrooms/type5
	icon_state = "mushroom5"

/obj/decal/mushrooms/type6
	icon_state = "mushroom6"

/obj/decal/mushrooms/type7
	icon_state = "mushroom7"

/obj/shifting_wall/sneaky/cave
	name = "strange wall"
	desc = "This wall seems strangely out-of-place."
	icon_state = "cave-0"
	icon = 'icons/turf/walls_cave.dmi'

	var/active = 0

	proc/do_move(var/direction)
		if(active) return
		var/turf/tile = get_step(src,direction)
		if(tile.density) return
		if(is_blocked_turf(tile)) return
		if(locate(/obj/decal/runemarks) in tile) return

		active = 1

		if(src.loc.invisibility) src.loc.invisibility = INVIS_NONE
		if(src.loc.opacity) src.loc.set_opacity(0)

		src.set_loc(tile)

		SPAWN(0.5 SECONDS)
			tile.invisibility = INVIS_ALWAYS_ISH
			tile.set_opacity(1)
			active = 0

	find_suitable_tiles()
		var/list/possible = new/list()

		for(var/A in cardinal)
			var/turf/current = get_step(src,A)
			if(current.density) continue
			if(is_blocked_turf(current)) continue
			if(someone_can_see(current)) continue
			if(locate(/obj/decal/runemarks) in current) continue
			possible +=  current

		return possible

	update()
		if(active) return
		if(someone_can_see_me())
			SPAWN(rand(50,80)) update()
			return

		var/list/possible = find_suitable_tiles()

		if(!possible.len)
			SPAWN(3 SECONDS) update()
			return

		active = 1
		if(prob(25)) // don't let all of them spam the noise at once
			SPAWN(rand(1,10))
				playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)

		var/turf/picked = pick(possible)
		if(src.loc.invisibility) src.loc.invisibility = INVIS_NONE
		if(src.loc.opacity) src.loc.set_opacity(0)

		src.set_loc(picked)

		SPAWN(0.5 SECONDS)
			picked.invisibility = INVIS_ALWAYS_ISH
			picked.set_opacity(1)
			active = 0

		//SPAWN(rand(100,200)) update() // raised delay

/obj/line_obj/whip
	name = "Whip"
	desc = ""
	anchored = 1
	density = 0
	opacity = 0

/obj/whip_trg_dummy
	name = ""
	desc = ""
	anchored = 1
	density = 0
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH

/obj/item/whip
	name = "whip"
	desc = "a sturdy whip."
	icon = 'icons/misc/exploration.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	icon_state = "whip"
	item_state = "c_tube"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_SMALL

	New()
		. = ..()
		src.special = null

	afterattack(atom/target, mob/user)
		if(target == user) return

		if(GET_DIST(user, target) > 5)
			boutput(user, "<span class='alert'>That is too far away!</span>")
			return

		var/atom/target_r = target

		if(isturf(target))
			target_r = new/obj/whip_trg_dummy(target)

		var/list/viewable_atoms = view(5, user)

		// if targetted turf is not viewable, dont do whip
		if (!viewable_atoms.Find(target_r))
			return

		var/list/affected = DrawLine(src.loc, target_r, /obj/line_obj/whip ,'icons/obj/projectiles.dmi',"WholeWhip",1,1,"HalfStartWhip","HalfEndWhip",OBJ_LAYER,1)

		playsound(src, 'sound/impact_sounds/Generic_Snap_1.ogg', 40, 1)

		for(var/obj/O in affected)
			O.anchored = 1 //Proc wont spawn the right object type so lets do that here.
			O.name = "Whip"

			var/turf/T = O.loc

			// if turf / object in whip path is dense, stop whipping
			if (T && !T.Cross(O))
				break

			if(locate(/obj/decal/stalagmite) in T)
				boutput(user, "<span class='alert'>You pull yourself to the stalagmite using the whip.</span>")
				user.set_loc(T)
			else if(locate(/obj/decal/stalagtite) in T)
				boutput(user, "<span class='alert'>You pull yourself to the stalagtite using the whip.</span>")
				user.set_loc(T)

		// cleanup whip visuals
		sleep(0.2 SECONDS)
		for (var/obj/O in affected)
			qdel(O)
		if(istype(target_r, /obj/whip_trg_dummy))
			qdel(target_r)

		return

/obj/boulder_trap_boulder
	icon = 'icons/misc/exploration.dmi'
	icon_state = "boulder"
	density = 1
	anchored = 1
	opacity = 0

	New(var/atom/sloc)
		..()
		src.set_loc(sloc)
		SPAWN(0) go()

	proc/go()
		while(!disposed)
			sleep(0.2 SECONDS)
			var/turf/next = get_step(src, SOUTH)
			if(prob(30))
				playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 60, 1) // having some noise might be rad

			if(!next || next.density)
				playsound(src.loc, 'sound/effects/Explosion2.ogg', 40, 1)
				new/obj/item/raw_material/rock(src.loc)
				new/obj/item/raw_material/rock(src.loc)
				new/obj/item/raw_material/rock(src.loc)
				new/obj/item/raw_material/rock(src.loc)
				SPAWN(0)
					dispose()
				return
			else
				src.set_loc(next)
				for(var/mob/living/carbon/C in next)
					C.TakeDamageAccountArmor("chest", 33, 0)
					if(hasvar(C, "weakened"))
						C:changeStatus("weakened", 5 SECONDS)


/obj/boulder_trap/respawning
	resets = 10

/obj/boulder_trap
	icon = 'icons/misc/mark.dmi'
	icon_state = "x4"
	invisibility = INVIS_ALWAYS
	anchored = 1
	density = 0
	var/ready = 1
	var/resets = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(!ready) return
		if(ismob(AM))
			if(AM:client)
				ready = 0
				playsound(src, 'sound/effects/exlow.ogg', 40, 0)
				var/turf/spawnloc = get_step(get_step(get_step(src, NORTH), NORTH), NORTH)
				new/obj/boulder_trap_boulder(spawnloc)
				playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)

				if(resets)
					SPAWN(resets) ready = 1

/obj/item/runetablet
	name = "Runic Tablet"
	desc = "A Tablet with several runes engraved upon its surface."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "runetablet"

	attack_self()

		var/dat = ""
		dat += "<b>There's several runes inscribed here ...</b><BR><BR>"
		dat += "<A href='?src=\ref[src];north=1'>Touch the first rune</A><BR>"
		dat += "<A href='?src=\ref[src];east=1'>Touch the second rune</A><BR>"
		dat += "<A href='?src=\ref[src];south=1'>Touch the third rune</A><BR>"
		dat += "<A href='?src=\ref[src];west=1'>Touch the fourth rune</A><BR>"

		src.add_dialog(usr)
		usr.Browse("[dat]", "window=rtab;size=400x300")
		onclose(usr, "rtab")
		return

	Topic(href, href_list)
		if (..(href, href_list))
			return

		var/movedir = null

		if (href_list["north"])
			boutput(usr, "<span class='notice'>The rune glows softly...</span>")
			movedir = NORTH
			playsound(src.loc, 'sound/machines/ArtifactEld1.ogg', 30, 1)
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)
		else if (href_list["east"])
			boutput(usr, "<span class='notice'>The rune glows softly...</span>")
			movedir = EAST
			playsound(src.loc, 'sound/machines/ArtifactEld1.ogg', 30, 1)
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)
		else if (href_list["south"])
			boutput(usr, "<span class='notice'>The rune glows softly...</span>")
			movedir = SOUTH
			playsound(src.loc, 'sound/machines/ArtifactEld1.ogg', 30, 1)
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)
		else if (href_list["west"])
			boutput(usr, "<span class='notice'>The rune glows softly...</span>")
			movedir = WEST
			playsound(src.loc, 'sound/machines/ArtifactEld1.ogg', 30, 1)
			playsound(src.loc, 'sound/impact_sounds/Stone_Scrape_1.ogg', 40, 1)

		if(movedir != null)
			for(var/obj/shifting_wall/sneaky/cave/C in orange(3, usr))
				C.do_move(movedir)

		usr.Browse(null, "window=rtab")
		src.updateUsrDialog()
		return


// cogwerks - wall shift trigger

/obj/sneaky_wall_trigger
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = 1
	density = 0
	var/active = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(75))
					active = 1
					for(var/obj/shifting_wall/sneaky/cave/C in orange(7, usr))
						C.update()
					SPAWN(10 SECONDS) active = 0

//////// cogwerks - reward item, based on the old cyborg suit

/obj/item/clothing/suit/armor/ancient
	name = "ancient armor"
	desc = "It belongs in a museum. Or maybe a laboratory. What the hell is this?"
	icon_state = "death"
	item_state = "death"
	// stole some shit from the welder's apron
	flags = FPRINT | TABLEPASS | SPACEWEAR
	body_parts_covered = TORSO|LEGS|ARMS
	fire_resist = T0C+5200
	protective_temperature = 1000
	cant_self_remove = 1
	cant_other_remove = 1
	w_class = W_CLASS_NORMAL
	var/processing = 0

	setupProperties()
		..()
		setProperty("coldprot", 80)
		setProperty("heatprot", 80)
		setProperty("movespeed", 2)
		setProperty("disorient_resist", 35)
		setProperty("chemprot", 30)

// scare the everliving fuck out of the player when they equip it
// what else should this thing do? idk yet. maybe some crazy hallucinations with an ancient blood reagent or something? something like the obsidian crown?
// spookycoders are welcome to contribute to this thing

/obj/item/clothing/suit/armor/ancient/equipped(var/mob/user, var/slot)
	..()
	boutput(user, "<span class='notice'>The armor plates creak oddly as you put on [src].</span>")
	playsound(src.loc, 'sound/machines/ArtifactEld2.ogg', 30, 1)
	user.reagents.add_reagent("itching", 10)
	take_bleeding_damage(user, null, 0, DAMAGE_STAB, 0)
	bleed(user, 5, 5)
	src.desc = "This isn't coming off... oh god..."
	if (!src.processing)
		src.processing++
		processing_items |= src
	SPAWN(5 SECONDS)
		boutput(user, "<span class='notice'>The [src] feels like it's getting tighter. Ouch! Seems to have a lot of sharp edges inside.</span>")
		random_brute_damage(user, 5)
		take_bleeding_damage(user, null, 0, DAMAGE_STAB, 0)
		bleed(user, 5, 5)
		sleep(9 SECONDS)
		user.visible_message("<span class='alert'><b>[src] violently contracts around [user]!</B></span>")
		playsound(user.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1, -1)
		random_brute_damage(user, 15)
		user.emote("scream")
		take_bleeding_damage(user, null, 0, DAMAGE_STAB, 0)
		bleed(user, 5, 1)
		sleep(5 SECONDS)
		user.visible_message("<span class='alert'><b>[src] digs into [user]!</B></span>")
		playsound(user.loc, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, 1, -1)
		random_brute_damage(user, 15)
		user.emote("scream")
		take_bleeding_damage(user, null, 0, DAMAGE_STAB, 0)
		bleed(user, 5, 5)
		sleep(5 SECONDS)
		var/mob/living/carbon/human/H = user
		playsound(user.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1, -1)
		H.visible_message("<span class='alert'><b>[src] absorbs some of [user]'s skin!</b></span>")
		random_brute_damage(user, 30)
		H.emote("scream")
		if (!H.decomp_stage)
			H.bioHolder.AddEffect("eaten") //gross
		take_bleeding_damage(user, null, 0, DAMAGE_CUT, 0)
		bleed(user, 15, 5)
		user.emote("faint")
		user.reagents.add_reagent("ectoplasm", 50)


/obj/item/clothing/suit/armor/ancient/process()
	var/mob/living/host = src.loc
	if (!istype(host))
		processing_items.Remove(src)
		processing = 0
		return

	if(prob(30) && ishuman(host))
		var/mob/living/carbon/human/M = host
		M.bioHolder.age++
		if(prob(10)) boutput(M, "<span class='alert'>You feel [pick("old", "strange", "frail", "peculiar", "odd")].</span>")
		if(prob(4)) M.emote("scream")
	return
/////////////////////////////// GRAVEYARD stuff

/obj/item/shovel
	name = "rusty old shovel"
	desc = "It's seen better days."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "shovel"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "shovel"
	w_class = W_CLASS_NORMAL
	c_flags = ONBELT
	force = 15
	hitsound = 'sound/impact_sounds/Metal_Hit_1.ogg'

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

/obj/graveyard/lightning_trigger
	icon = 'icons/misc/mark.dmi'
	icon_state = "ydn"
	invisibility = INVIS_ALWAYS
	anchored = 1
	density = 0
	var/active = 0

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(active) return
		if(ismob(AM))
			if(AM:client)
				if(prob(15))
					active = 1
					SPAWN(5 SECONDS) active = 0
					playsound(AM, pick('sound/effects/thunder.ogg','sound/ambience/nature/Rain_ThunderDistant.ogg'), 75, 1)

					for(var/mob/M in view(src, 5))
						M.flash(3 SECONDS)

/obj/graveyard/loose_rock
	icon = 'icons/misc/worlds.dmi'
	icon_state = "rockwall"
	dir = 4
	density = 1
	opacity = 1
	anchored = 1
	desc = "These rocks are riddled with small cracks and fissures. A cold draft lingers around them."
	name = "Rock Wall"
	var/id = "alchemy"

	New()
		..()
		if (!id)
			id = "generic"

		src.tag = "loose_rock_[id]"
		return


	proc/crumble()
		src.visible_message("<span class='alert'><b>[src] crumbles!</b></span>")
		playsound(src.loc, 'sound/effects/stoneshift.ogg', 50, 1)
		var/obj/effects/bad_smoke/smoke = new /obj/effects/bad_smoke
		smoke.name = "dust cloud"
		smoke.set_loc(src.loc)
		icon_state = "rubble"
		set_density(0)
		set_opacity(0)
		SPAWN(18 SECONDS)
			if ( smoke )
				smoke.name = initial(smoke.name)
				qdel(smoke)
		return

/////////////////////////////// ALCHEMY CIRCLE STUFF

/obj/item/alchemy/stone
	desc = "A blood red stone. It pulses ever so slightly when you hold it."
	name = "philosopher's stone"
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "pstone"
	item_state = "injector"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY
	var/datum/light/light

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(BOUNDS_DIST(target, user) > 0)
			return
		return

	attack()
		return

	New()
		..()
		src.visible_message("<span class='notice'><b>[src] appears out of thin air!</b></span>")
		new /obj/effects/shockwave {name = "mystical energy";} (src.loc)
		light = new /datum/light/point
		light.attach(src)
		light.set_color(1,0.5,0.5)
		light.set_height(0.2)
		light.set_brightness(0.4)
		light.enable()

/obj/item/alchemy/powder
	desc = "A little purple pouch filled with a white powder."
	name = "purple pouch"
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "powder"
	item_state = "injector"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(!in_interact_range(target, user) && !istype(target, /obj/alchemy/circle))
			return
		if(target == loc) return
		boutput(user, "<span class='notice'>Your sprinkle some powder on \the [target].</span>")
		if(istype(target, /obj/alchemy/circle))
			target:activate()
		return

	attack()
		return

/obj/item/paper/alchemy
	name = "notebook page 1"
	desc = "a page torn from a notebook"
	info = "... blood is the catalyst ... the arcane powder the key..."

/obj/item/paper/alchemy/north
	name = "notebook page 2"
	New()
		..()
		SPAWN(10 SECONDS)
			info = "... [alchemy_symbols["north"]] stands above all else ..."

/obj/item/paper/alchemy/southeast
	name = "notebook page 3"
	New()
		..()
		SPAWN(10 SECONDS)
			info = "... in the place the sun rises, [alchemy_symbols["southeast"]] is required ..."

/obj/item/paper/alchemy/southwest
	name = "notebook page 4"
	New()
		..()
		SPAWN(10 SECONDS)
			info = "... [alchemy_symbols["southwest"]] where light fades ..."

/obj/item/alchemy/symbol
	name = "Symbol"
	desc = "Some sort of alchemical Symbol on a Scroll."
	icon = 'icons/obj/items/alchemy.dmi'
	var/info = ""

/var/list/alchemy_symbols = new/list()

/obj/item/alchemy/symbol/water
	icon_state = "alch_water"
	info = "Water"

/obj/item/alchemy/symbol/fire
	icon_state = "alch_fire"
	info = "Fire"

/obj/item/alchemy/symbol/air
	icon_state = "alch_air"
	info = "Air"

/obj/item/alchemy/symbol/earth
	icon_state = "alch_earth"
	info = "Earth"

/obj/item/alchemy/symbol/connect
	icon_state = "alch_con"
	info = "Connection"

/obj/item/alchemy/symbol/distill
	icon_state = "alch_distill"
	info = "Distillation"

/obj/item/alchemy/symbol/incin
	icon_state = "alch_incin"
	info = "Incineration"

/obj/item/alchemy/symbol/life
	icon_state = "alch_life"
	info = "Life"

/obj/item/alchemy/symbol/proj
	icon_state = "alch_proj"
	info = "Projection"

/obj/item/alchemy/symbol/salt
	icon_state = "alch_salt"
	info = "Salt"

/obj/alchemy/empty
	name = "Empty Circle"
	desc = "An Empty Circle, waiting to be filled"
	anchored = 1
	density = 0
	opacity= 0
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "alch_empty"
	var/obj/item/alchemy/symbol = null
	var/requiredType = null

	attack_hand(mob/user)
		if(symbol != null)
			symbol.set_loc(src.loc)
			symbol = null
			overlays.Cut()
			boutput(user, "<span class='notice'>You remove the Symbol.</span>")
		return

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/alchemy/symbol) && symbol == null)
			user.drop_item()
			symbol = W
			symbol.set_loc(src)
			overlays += symbol
			boutput(user, "<span class='notice'>You put the Symbol in the Circle.</span>")
		return

/obj/alchemy/circle
	name = "Alchemy Circle"
	desc = "A bizzare looking mass of lines and circles is drawn onto the floor here."
	anchored = 1
	density = 0
	opacity= 0
	layer = FLOOR_EQUIP_LAYER1
	icon = 'icons/effects/160x160.dmi'
	icon_state = "alchcircle"
	bound_width = 160
	bound_height = 160
	var/activated = 0

	var/obj/alchemy/empty/north = null
	var/obj/alchemy/empty/southwest = null
	var/obj/alchemy/empty/southeast = null
	var/target_id = "alchemy"

	proc/activate()
		if(activated) return
		if((north.symbol && istype(north.symbol,north.requiredType)) && (southwest.symbol && istype(southwest.symbol,southwest.requiredType)) && (southeast.symbol && istype(southeast.symbol,southeast.requiredType)))
			var/turf/middle = locate(src.x + 2, src.y + 2, src.z)
			var/blood = 0
			for(var/atom/A in range(2, middle))
				if(istype(A, /obj/decal/cleanable/blood))
					blood = 1
					break
			if(blood == 1)
				activated = 1
				boutput(usr, "<span class='success'>The Circle begins to vibrate and glow.</span>")
				playsound(src.loc, 'sound/voice/chanting.ogg', 50, 1)
				sleep(1 SECOND)
				shake_camera(usr, 15, 16, 0.2)
				sleep(1 SECOND)
				for(var/turf/T in range(2,middle))
					make_cleanable(/obj/decal/cleanable/greenglow,T)
				sleep(1 SECOND)
				playsound_global(world, 'sound/effects/mag_pandroar.ogg', 60) // heh
				shake_camera(usr, 15, 16, 0.5)
				new/obj/item/alchemy/stone(middle)
				sleep(0.2 SECONDS)
				var/obj/graveyard/loose_rock/R = locate("loose_rock_[target_id]")
				if(istype(R))
					SPAWN(1 DECI SECOND)
						R.crumble()
				var/area/the_catacombs = get_area(src)
				for (var/mob/living/M in the_catacombs)
					if (isdead(M))
						continue

					M.unlock_medal("Illuminated", 1)

			else
				boutput(usr, "<span class='notice'>The Circle glows faintly before returning to normal. Maybe something is missing.</span>")
			return
		else
			boutput(usr, "<span class='alert'>The Circle remains silent ...</span>")

	attackby(obj/item/W, mob/user)
		if(activated) return


	New(var/location)
		..()
		var/list/types = new/list()
		var/obj/item/alchemy/symbol/S = null

		for(var/A in childrentypesof(/obj/item/alchemy/symbol))
			types += A

		set_loc(location)
		north = new(locate(src.loc.x + 2, src.loc.y + 3, src.loc.z))
		var/ntype = pick(types)

		S = new ntype()
		alchemy_symbols["north"] = S.info

		types -= ntype
		north.requiredType = ntype

		southwest = new(locate(src.loc.x + 1, src.loc.y + 1, src.loc.z))
		southwest.pixel_y = 16
		var/swtype = pick(types)

		S = new swtype()
		alchemy_symbols["southwest"] = S.info

		types -= swtype
		southwest.requiredType = swtype

		southeast = new(locate(src.loc.x + 3, src.loc.y + 1, src.loc.z))
		southeast.pixel_y = 16
		var/setype = pick(types)

		S = new setype()
		alchemy_symbols["southeast"] = S.info

		types -= setype
		southeast.requiredType = setype

		return

/////////////////////////////// crashed sattelite stuff

/obj/item/device/sat_crash_caller
	name = "satellite transceiver"
	desc = "A hand-held device for communicating with some sort of satellite."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "satcom"
	w_class = W_CLASS_TINY

	attack_self(mob/user as mob)
		if (..())
			return

		if (satellite_crash_event_status != -1)
			boutput(user, "<span class='alert'>The [src.name] emits a sad beep.</span>")
			playsound(src.loc, 'sound/machines/whistlebeep.ogg', 50, 1)
			return

		var/area/crypt/graveyard/ourArea = get_area(user)
		if (!istype(ourArea))
			boutput(user, "<span class='alert'>The [src.name] emits a rude beep! It appears to have no signal.</span>")
			playsound(src.loc, 'sound/machines/whistlebeep.ogg', 50, 1)
			return

		for (var/turf/T in range(user, 1))
			if (T.density)
				boutput(user, "<span class='alert'>The [src.name] gives off a grumpy beep! Looks like the signals are reflecting off of walls or something.  Maybe move?</span>")
				playsound(src.loc, 'sound/machines/whistlealert.ogg', 50, 1)
				return

		satellite_crash_event_status = 0
		user.visible_message("<span class='alert'>[user] pokes some buttons on [src]!</span>", "You activate [src].  Apparently.")
		playsound(user.loc, 'sound/machines/signal.ogg', 60, 1)
		new /obj/effects/sat_crash(get_turf(src))

		return

var/satellite_crash_event_status = -1
/obj/effects/sat_crash
	name = ""
	anchored = 1
	density = 0
	icon = 'icons/effects/64x64.dmi'
	icon_state = "impact_marker"
	layer = FLOOR_EQUIP_LAYER1
	pixel_y = -16
	pixel_x = -16

	New()
		..()

		if (satellite_crash_event_status != 0)
			del src
			return

		satellite_crash_event_status = 1
		SPAWN(0)
			satellite_crash_event()

	proc/satellite_crash_event()
		var/obj/decal/satellite = new /obj/decal (src.loc)
		satellite.pixel_y = 600
		satellite.pixel_x = -16
		satellite.icon = 'icons/effects/64x64.dmi'
		satellite.icon_state = "syndsat"
		satellite.anchored = 1
		satellite.bound_width = 64
		satellite.bound_height = 64
		satellite.name = "Syndicate TeleRelay Satellite"
		satellite.desc = "An example of a syndicate teleportation relay satellite.  The tech on these is experimental, cheaply implemented, and has a history of leaving parts....behind."
		var/datum/light/light = new /datum/light/point
		light.set_color(0.9, 0.7, 0.5)
		light.set_brightness(0.7)
		light.attach(satellite)
		light.enable()
		playsound(src.loc, 'sound/machines/satcrash.ogg', 50, 0)

		sleep(5 SECONDS)
		if (!satellite)
			satellite_crash_event_status = -1
			return

		src.invisibility = INVIS_ALWAYS_ISH
		var/particle_count = rand(8,16)
		while (particle_count--)
			var/obj/effects/expl_particles/EP = new /obj/effects/expl_particles {pixel_y = 600; name = "space debris";} (pick(orange(src,3)))
			animate(EP, pixel_y = 0, time=15, easing = SINE_EASING, transform = matrix(rand(-180, 180), MATRIX_ROTATE))

		sleep(1.5 SECONDS)
		var/oldTransform = satellite.transform
		animate(satellite, pixel_y = 0, time = 10, easing = SINE_EASING, transform = matrix(rand(5, 30), MATRIX_ROTATE))
		sleep(1 SECOND)
		var/datum/effects/system/explosion/explode = new /datum/effects/system/explosion
		explode.set_up( src.loc )
		explode.start()
		playsound(src.loc, 'sound/effects/kaboom.ogg', 90, 1)
		SPAWN(1 DECI SECOND)
			fireflash(src.loc, 4)
		for (var/mob/living/L in range(src.loc, 2))
			L.ex_act(GET_DIST(src.loc, L))

		sleep(0.5 SECONDS)
		satellite.icon_state = "syndsat-crashed"
		satellite.set_density(1)
		satellite.transform = oldTransform
		satellite.color = "#FFFFFF"
		light.disable()
		light.detach()
		sleep(4.5 SECONDS)
		qdel(explode)

		var/image/projection = image('icons/effects/64x64.dmi', "syndsat-projection")
		projection.pixel_x = 32
		projection.pixel_y = -32
		projection.layer = satellite.layer + 1
		satellite.overlays += projection

		var/obj/perm_portal/portal = new /obj/perm_portal {name="rift in space and time"; desc = "uh...huhh"; pixel_x = 16;} (locate(satellite.x+1,satellite.y-1, satellite.z))
		for (var/obj/O in portal.loc)
			if (O.density && O.anchored && O != portal)
				qdel(O)

		var/area/drone/zone/drone_zone = locate()
		if (istype(drone_zone))
			var/obj/decal/fakeobjects/teleport_pad/pad = locate() in drone_zone.contents
			if (istype(pad))
				portal.target = get_turf(pad)
			else
				portal.target = get_turf(pick( drone_zone.contents ))

			var/obj/perm_portal/portal2 = new /obj/perm_portal {name="rift in space and time"; desc = "uh...huhh";} (get_turf(portal.target))
			portal2.target = get_turf(portal)

		satellite_crash_event_status = 2
		qdel(src)

/////////////////////syndicate drone factory areas
/area/drone
	name = "Drone Assembly Outpost"
	icon_state = "red"
	sound_environment = 10
	sound_group = "drone_factory"

/area/drone/zone
	name = "Drone Assembly Outpost Entrance"

/area/drone/crew_quarters
	name = "Drone Engineer's Quarters"
	icon_state = "showers"
	sound_environment = 4

/area/drone/engineering
	name = "Drone Engineering"
	icon_state = "yellow"
	sound_environment = 5

/area/drone/office
	name = "Drone Design Office"
	icon_state = "purple"

/area/drone/assembly
	name = "Drone Assembly Floor"
	icon_state = "storage"
