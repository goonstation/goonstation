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
				SPAWN(0.8 SECONDS)
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
				src.visible_message(SPAN_ALERT("<B>[M]</B> falls into the [src] and melts away!"))
				logTheThing(LOG_COMBAT, M, "was firegibbed by [src] ([src.type]) at [log_loc(M)].")
				M.firegib() // thanks ISN!
		else
			src.visible_message(SPAN_ALERT("<B>[O]</B> falls into the [src] and melts away!"))
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
	can_burn = FALSE
	can_break = FALSE

	Crossed(atom/movable/AM)
		. = ..()
		if (do_lava_burn(AM))
			SPAWN (5 SECONDS)
				while(AM.loc == src)
					if (!do_lava_burn(AM))
						break
					sleep(5 SECONDS)

	proc/do_lava_burn(mob/M)
		if(!ismob(M))
			return
		if (istype(M,/mob/dead) || istype(M,/mob/living/intangible))
			return
		if (isdead(M))
			return
		if (isrobot(M))
			M.TakeDamage("chest", pick(5,10), 0, DAMAGE_BURN)
			M.changeStatus("stunned", 2 SECONDS)
			M.emote("scream")
			playsound(M.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
			boutput(M, "You get too close to the edge of the lava and spontaniously combust from the heat!")
			visible_message(SPAN_ALERT("[M] gets too close to the edge of the lava and their internal wiring suffers a major burn!"))
		else
			M.changeStatus("burning", 30 SECONDS)
			M.changeStatus("knockdown", 2 SECONDS)
			M.emote("scream",)
			playsound(M.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
			boutput(M, "You get too close to the edge of the lava and spontaniously combust from the heat!")
			visible_message(SPAN_ALERT("[M] gets too close to the edge of the lava and spontaniously combusts from the heat!"))
		return TRUE

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
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "purple1"


/turf/unsimulated/floor/carpet/purple/decal
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "fpurple1"
	innercross
		dir = NORTH
	outercross
		dir = EAST

/turf/unsimulated/floor/carpet/purple/standard/edge
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "purple2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/purple/standard/innercorner
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "purple3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "purple4"
		dir = NORTHEAST
	se_triple
		icon_state = "purple4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "purple4"
		dir = NORTHWEST
	sw_triple
		icon_state = "purple4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "purple1"
		dir = NORTHEAST
	nw_se
		icon_state = "purple1"
		dir = NORTHWEST
	omni
		icon_state = "purple1"
		dir = WEST

/turf/unsimulated/floor/carpet/purple/standard/narrow
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "purple6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "purple4"
		dir = NORTH
	south
		icon_state = "purple4"
		dir = SOUTH
	east
		icon_state = "purple4"
		dir = EAST
	west
		icon_state = "purple4"
		dir = WEST
	solo
		icon_state = "purple1"
		dir = EAST
	northsouth
		icon_state = "purple1"
		dir = SOUTHEAST
	eastwest
		icon_state = "purple1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/purple/standard/junction
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "purple5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

//fancy subvariant///////////////////////

/turf/unsimulated/floor/carpet/purple/fancy/edge
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "fpurple2"

	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/purple/fancy/innercorner
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "fpurple3"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	north
		dir = NORTH
	south
		dir = SOUTH
	east
		dir = EAST
	west
		dir = WEST
	ne_triple
		icon_state = "fpurple4"
		dir = NORTHEAST
	se_triple
		icon_state = "fpurple4"
		dir = SOUTHEAST
	nw_triple
		icon_state = "fpurple4"
		dir = NORTHWEST
	sw_triple
		icon_state = "fpurple4"
		dir = SOUTHWEST
	ne_sw
		icon_state = "fpurple1"
		dir = NORTHEAST
	nw_se
		icon_state = "fpurple1"
		dir = NORTHWEST
	omni
		icon_state = "fpurple1"
		dir = WEST

/turf/unsimulated/floor/carpet/purple/fancy/narrow
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "fpurple6"

	ne
		dir = NORTHEAST
	se
		dir = SOUTHEAST
	nw
		dir = NORTHWEST
	sw
		dir = SOUTHWEST
	T_north
		dir = NORTH
	T_south
		dir = SOUTH
	T_east
		dir = EAST
	T_west
		dir = WEST
	north
		icon_state = "fpurple4"
		dir = NORTH
	south
		icon_state = "fpurple4"
		dir = SOUTH
	east
		icon_state = "fpurple4"
		dir = EAST
	west
		icon_state = "fpurple4"
		dir = WEST
	northsouth
		icon_state = "fpurple1"
		dir = SOUTHEAST
	eastwest
		icon_state = "fpurple1"
		dir = SOUTHWEST

/turf/unsimulated/floor/carpet/purple/fancy/junction
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "fpurple5"

	sw_e
		dir = NORTH
	ne_w
		dir = SOUTH
	nw_s
		dir = EAST
	se_n
		dir = WEST
	sw_n
		dir = NORTHEAST
	nw_e
		dir = SOUTHEAST
	ne_s
		dir = NORTHWEST
	se_w
		dir = SOUTHWEST

/turf/unsimulated/wall/setpieces/Azarak/cavewall
	name = "rock wall"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "cave_wall"

	edges
		icon_state = "cave_wall_edges"

	corners
		icon_state = "cave_wall_corners"

/obj/fakeobject/bedrolls
	name = "bedrolls"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bedrolls"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/shrooms
	name = "weird looking mushrooms"
	desc = "What the hell are these..?"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "shrooms"
	anchored = ANCHORED

/obj/fakeobject/smallrocks
	name = "small rocks"
	desc = "Some small rocks."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "smallrocks"
	anchored = ANCHORED
	density = 1

	attackby(obj/item/W, mob/user)
		if ((istype(W, /obj/item/mining_tool) || istype(W, /obj/item/mining_tools)) && !isrestrictedz(src.z))
			boutput(user, "You hit the [src] a few times with the [W]!")
			src.visible_message(SPAN_NOTICE("<b>[src] crumbles into dust!</b>"))
			playsound(src.loc, 'sound/items/mining_pick.ogg', 70,1)
			qdel(src)

	attack_hand(mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			if (istype(human.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/gauntlets = human.gloves
				return src.Attackby(gauntlets.tool, user)
		. = ..()

/obj/fakeobject/bigrocks
	name = "big rocks"
	desc = "Those are some big rocks, they are probably from the ceiling..?"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bigrocks"
	anchored = ANCHORED
	density = 1

	attackby(obj/item/W, mob/user)
		if ((istype(W, /obj/item/mining_tool) || istype(W, /obj/item/mining_tools)) && !isrestrictedz(src.z))
			boutput(user, "You hit the [src] a few times with the [W]!")
			src.visible_message(SPAN_NOTICE("<b>After a few hits [src] crumbles into smaller rocks.</b>"))
			playsound(src.loc, 'sound/items/mining_pick.ogg', 80,1)
			new /obj/fakeobject/smallrocks(src.loc)
			qdel(src)

	attack_hand(mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			if (istype(human.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/gauntlets = human.gloves
				return src.Attackby(gauntlets.tool, user)
		. = ..()

/obj/fakeobject/biggerrock
	name = "big rock"
	desc = "Seriously big rocks."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "bigrock"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/azarakrocks
	name = "rock"
	desc = "Some lil' rocks."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "rock1"
	anchored = ANCHORED
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


/obj/fakeobject/cultiststatue
	name = "statue of a hooded figure"
	desc = "TEMP"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "cultiststatue"
	anchored = ANCHORED
	density = 1
	layer = EFFECTS_LAYER_UNDER_3

/obj/fakeobject/crossinverted
	name = "inverted cross"
	desc = "TEMP"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "cross"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/bookcase
	name = "bookcase"
	desc = "It's a bookcase. Full of books."
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "bookcase"
	anchored = ANCHORED
	density = 0
	layer = DECAL_LAYER

/obj/fakeobject/creepytv
	name = "broken old television"
	desc = "TEMP"
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "creepytv"
	anchored = ANCHORED
	density = 1

/obj/fakeobject/circle
	name = "summoning circle"
	desc = "TEMP"
	icon = 'icons/effects/224x224.dmi'
	icon_state = "circle"
	anchored = ANCHORED
	density = 0
	opacity= 0
	layer = FLOOR_EQUIP_LAYER1

/obj/fakeobject/Azarakcandleswall
	icon = 'icons/misc/AzungarAdventure.dmi'
	icon_state = "candles"
	name = "candles"
	desc = "TEMP"
	density = 0
	anchored = ANCHORED
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

/obj/fakeobject/Azarakcandles
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "candle"
	desc = "TEMP"
	density = 0
	anchored = ANCHORED
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

/obj/syndicateholoemitter
	name = "Holo-emitter"
	desc = "A compact holo emitter pre-loaded with a holographic image."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "emitter-on"
	flags = TABLEPASS
	anchored = ANCHORED_ALWAYS

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
	anchored = ANCHORED_ALWAYS
	layer = EFFECTS_LAYER_BASE
	var/datum/light/light
	var/obj/holoparticles/holoparticles

	New(var/_loc)
		set_loc(_loc)

		light = new /datum/light/point
		light.attach(src)
		light.set_color(0.5, 0.6, 0.94)
		light.set_brightness(0.7)
		light.enable()

		SPAWN(1 DECI SECOND)
			animate(src, alpha=130, color="#DDDDDD", time=7, loop=-1)
			animate(alpha=180, color="#FFFFFF", time=1)
			animate(src, pixel_y=10, time=15, flags=ANIMATION_PARALLEL, easing=SINE_EASING, loop=-1)
			animate(pixel_y=16, easing=SINE_EASING, time=15)

		holoparticles = new/obj/holoparticles(src.loc)
		attached_objs = list(holoparticles)
		..(_loc)

	disposing()
		if(holoparticles)
			holoparticles.invisibility = INVIS_ALWAYS
			qdel(holoparticles)
		..()

/obj/holoparticles
	desc = ""
	name = ""
	icon = 'icons/obj/janitor.dmi'
	icon_state = "holoparticles"
	anchored = ANCHORED
	alpha= 230
	pixel_y = 14
	layer = EFFECTS_LAYER_BASE

/obj/dispenser
	name = "handcuff dispenser"
	desc = "A handy dispenser for handcuffs."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_handcuffs"
	var/amount = 3

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/handcuffs))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, SPAN_NOTICE("You put a pair of handcuffs in the [src]. [amount] left in the dispenser."))
		return

	attack_hand(mob/user)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/handcuffs, user.hand)
			boutput(user, SPAN_ALERT("You take a pair of handcuffs from the [src]. [amount] left in the dispenser."))
			if (src.amount <= 0)
				src.icon_state = "dispenser_handcuffs"
		else
			boutput(user, SPAN_ALERT("There's no handcuffs left in the [src]!"))

/obj/fakeobject/mantacontainer
	name = "container"
	desc = "These huge containers are used to transport goods from one place to another."
	icon = 'icons/obj/large/64x96.dmi'
	icon_state = "manta"
	anchored = ANCHORED_ALWAYS
	density = 1
	bound_height = 32
	bound_width = 96
	layer = EFFECTS_LAYER_BASE

	attack_hand(mob/user)
		if (can_reach(user,src))
			boutput(user, SPAN_ALERT("You attempt to open the container but its doors are sealed tight. It doesn't look like you'll be able to open it."))
			playsound(src.loc, 'sound/machines/door_locked.ogg', 50, 1, -2)

	yellow
		icon_state = "mantayellow"
	blue
		icon_state = "mantablue"

/obj/fakeobject/mantacontainer/upwards
		name = "container"
		desc = "These huge containers are used to transport goods from one place to another."
		icon = 'icons/obj/large/96x64.dmi'
		icon_state = "manta"
		anchored = ANCHORED_ALWAYS
		density = 1
		bound_height = 96
		bound_width = 64
		layer = EFFECTS_LAYER_BASE

/obj/fakeobject/mantacontainer/upwards/yellow
	icon_state = "mantayellow"

/obj/roulette_table_w //Big thanks to Haine for the sprite and parts of the code!
	name = "roulette wheel"
	desc = "A table with a built-in roulette wheel and a little ball. The numbers are evenly distributed between black and red, except for the zero which is green. Unlike most of tables you'd find in America, this one only has a single zero, lowering the house edge to about 2.7% on almost every bet. Truly generous."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_w0"
	anchored = ANCHORED
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

	update_icon()
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
		UpdateIcon()
		var/real_run_time = rand(src.run_time - 10, src.run_time + 10)
		sleep(real_run_time - 10)
		playsound(src.loc, 'sound/items/coindrop.ogg', 30, 1)
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
		src.visible_message(SPAN_SUCCESS("[src] lands on [last_result_text]!"))
		src.running = 0
		UpdateIcon()
		sleep(1 SECONDS)
		src.maptext_x = -1
		src.maptext_y = 8
		src.maptext = "<span class='xfont sh c vm' style='background: [background_color];'> [src.last_result] </span>"
		SPAWN(4 SECONDS)
			src.maptext = ""


/obj/fakeobject/turbinetest
		name = "TEMP"
		desc = "TEMP"
		icon = 'icons/obj/large/96x160.dmi'
		icon_state = "turbine_main"
		anchored = ANCHORED_ALWAYS
		density = 1
		bound_height = 160
		bound_width = 96

/obj/fakeobject/nuclearcomputertest
		name = "TEMP"
		desc = "TEMP"
		icon = 'icons/obj/large/32x96.dmi'
		icon_state = "nuclearcomputer"
		anchored = ANCHORED_ALWAYS
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
	anchored = ANCHORED

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
				user.visible_message(SPAN_ALERT("<B>[user] fumbles the catch and is clonked on the head!</B>"))
				playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.changeStatus("stunned", 5 SECONDS)
				user.changeStatus("knockdown", 3 SECONDS)
				user.changeStatus("unconscious", 2 SECONDS)
				user.force_laydown_standup()
			else
				src.Attackhand(usr)
			return
		else
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/user = usr
				var/hos = (istype(user.head, /obj/item/clothing/head/hosberet) || istype(user.head, /obj/item/clothing/head/hos_hat))
				if(hos)
					var/mob/living/carbon/human/H = hit_atom
					H.changeStatus("stunned", 9 SECONDS)
					H.changeStatus("knockdown", 2 SECONDS)
					H.force_laydown_standup()
					//H.paralysis++
					playsound(H.loc, "swing_hit", 50, 1)
					usr.say("I AM THE LAW!")
				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

/obj/portalmartian
	name = "portal"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	anchored = ANCHORED
	var/recharging =0
	var/id = "shuttle" //The main location of the teleporter
	var/recharge = 20 //A short recharge time between teleports
	var/busy = 0
	layer = 2



	Bumped(mob/user as mob)
		if(busy) return
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		src.add_dialog(user)
		busy = 1
		showswirl(user.loc)
		playsound(src, 'sound/effects/teleport.ogg', 60, TRUE)
		SPAWN(1 SECOND)
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
					SPAWN(recharge)
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
		src.anchored = UNANCHORED
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
				src.visible_message(SPAN_COMBAT("<b>[src]</b> [src.angertext] [C.name]!"))
				src.task = "chasing"
				break
			else
				continue

	ChaseAttack(mob/M)
		src.visible_message(SPAN_COMBAT("<B>[src]</B> launches itself at [M]!"))
		if (prob(30)) M.changeStatus("knockdown", 2 SECONDS)

	CritterAttack(mob/M)
		src.attacking = 1
		src.visible_message(SPAN_COMBAT("<B>[src]</B> bites and claws at [src.target]!"))
		random_brute_damage(src.target, rand(3,5),1)
		random_burn_damage(src.target, rand(2,3))
		SPAWN(1 SECOND)
			src.attacking = 0

	CritterDeath()
		..()
		qdel(src)

TYPEINFO(/obj/item/rpcargotele)
	mats = 4

/obj/item/rpcargotele
	name = "special cargo transporter"
	desc = "A device for teleporting crated goods. There is something really, really shady about this.."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "syndicargotele"
	w_class = W_CLASS_SMALL
	c_flags = ONBELT

/obj/decoration/scenario/crate
	name = "NT vital supplies crate"
	anchored = ANCHORED_ALWAYS
	density = 1
	desc = "A tightly locked metal crate."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ntcrate"

	attackby(var/obj/item/I, var/mob/user)
		if (istype(I, /obj/item/rpcargotele))
			actions.start(new /datum/action/bar/icon/scenariocrate(src, I, 300), user)

/datum/action/bar/icon/scenariocrate
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
		if (thecrate == null || the_tool == null || owner == null || BOUNDS_DIST(owner, thecrate) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(thecrate, 'sound/machines/click.ogg', 60, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] starts to calibrate the cargo teleporter in a suspicious manner."))
	onEnd()
		..()
		owner.visible_message(SPAN_ALERT("[owner] has successfully teleported the NT vital supplies somewhere else!"))
		showswirl(thecrate.loc)
		qdel(thecrate)
		message_admins("One of the NT supply crates has been succesfully teleported!")
		boutput(owner, SPAN_NOTICE("You have successfully teleported one of the supply crates to the Syndicate."))
		playsound(thecrate, 'sound/machines/click.ogg', 60, TRUE)
