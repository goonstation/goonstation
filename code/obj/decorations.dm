
/obj/poolwater
	name = "water"
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwater"
	layer = EFFECTS_LAYER_UNDER_3
	mouse_opacity = 0
	var/float_anim = 1

	New()
		..()
		src.create_reagents(10)
		reagents.add_reagent("cleaner", 5)
		reagents.add_reagent("water", 5)
		SPAWN(0.5 SECONDS)
			if (src.float_anim)
				for (var/atom/movable/A in src.loc)
					if (!A.anchored)
						animate_bumble(A, floatspeed = 8, Y1 = 3, Y2 = 0)

	Crossed(atom/movable/A)
		if (src.float_anim)
			if (istype(A, /atom/movable) && !isobserver(A) && !istype(A, /mob/living/critter/small_animal/bee) && !istype(A, /obj/critter/domestic_bee))
				var/atom/movable/AM = A
				if (!AM.anchored)
					animate_bumble(AM, floatspeed = 8, Y1 = 3, Y2 = 0)
		if (isliving(A))
			var/mob/living/L = A
			L.update_burning(-30)
		reagents.reaction(A, TOUCH, 2)
		return ..()

	Uncrossed(atom/movable/A)
		var/turf/T = get_turf(A)
		if (istype(T))
			var/obj/poolwater/P = locate() in T
			if (!istype(P))
				if (istype(A, /atom/movable) && !isobserver(A) && !istype(A, /mob/living/critter/small_animal/bee) && !istype(A, /obj/critter/domestic_bee))
					animate(A)
					A.pixel_y = initial(A.pixel_y)
		return ..()

/obj/tree
	name = "tree"
	desc = "It's a tree."
	icon = 'icons/effects/96x96.dmi' // changed from worlds.dmi
	icon_state = "tree" // changed from 0
	anchored = ANCHORED
	layer = EFFECTS_LAYER_UNDER_3

	pixel_x = -20
	density = 1
	opacity = 0 // this causes some of the super ugly lighting issues too

	_max_health = 1

	var/falling = FALSE
	var/fallen = FALSE
	var/fall_time = 2 SECONDS

#ifdef SEASON_AUTUMN
	New()
		..()
		icon_state = pick("tree_red", "tree_yellow", "tree_orange")
#endif

	attackby(obj/item/I, mob/user)
		if ((issawingtool(I) || ischoppingtool(I)) && (!isrestrictedz(src.z) || isgenplanet(src)))
			if (I.hitsound)
				playsound(I, I.hitsound, 50, 1)
			src._health -= I.force
			user.lastattacked = get_weakref(src)
			if (src._health <= 0)
				if (src.falling)
					return
				if (src.fallen)
					var/turf/our_turf = get_turf(src)
					for (var/i in 0 to 2)
						var/obj/item/material_piece/organic/wood/log = new(locate(our_turf.x + i, our_turf.y, our_turf.z))
						log.Turn(90)
					qdel(src)
					return
				src.falling = TRUE
				src.animate_fall()
				playsound(src, 'sound/effects/treefall.ogg', 70, FALSE)
				src.visible_message(SPAN_ALERT("\The [src] falls!"), SPAN_ALERT("You hear a [src] fall, and thus prove that it has."))
				SPAWN(src.fall_time)
					src.falling = FALSE
					src.fallen = TRUE
		..()

	proc/animate_fall()
		var/ratio = 0.3
		var/icon/icon = new(src.icon)
		var/transform1 = matrix(src.transform, 90 * ratio, MATRIX_ROTATE)
		transform1 = matrix(transform1, icon.Width()/(3 / ratio), -icon.Height()/(2 / ratio), MATRIX_TRANSLATE)
		var/transform2 = matrix(src.transform, 90, MATRIX_ROTATE)
		transform2 = matrix(transform2, icon.Width()/3, -icon.Height()/2, MATRIX_TRANSLATE)
		animate(src, transform = transform1, time = src.fall_time/2, easing = QUAD_EASING | EASE_IN)
		animate(transform = transform2, time = src.fall_time/2, easing = BOUNCE_EASING | EASE_OUT)

	elm_random
		layer = EFFECTS_LAYER_UNDER_1 // match shrubs
		New()
			. = ..()
			src.dir = pick(cardinal - SOUTH)

	snow_random
		icon_state = "snowtree"
		layer = EFFECTS_LAYER_UNDER_1 // match shrubs
		pixel_x = -32
		New()
			. = ..()
			src.dir = pick(cardinal)

// what the hell is all this and why wasn't it just using a big icon? the lighting system gets all fucked up with this stuff

/*
 	New()
		var/image/tile10 = image('icons/misc/worlds.dmi',null,"1,0",10)
		tile10.pixel_x = 32

		var/image/tile01 = image('icons/misc/worlds.dmi',null,"0,1",10)
		tile01.pixel_y = 32

		var/image/tile11 = image('icons/misc/worlds.dmi',null,"1,1",10)
		tile11.pixel_y = 32
		tile11.pixel_x = 32

		overlays += tile10
		overlays += tile01
		overlays += tile11

		var/image/tile20 = image('icons/misc/worlds.dmi',null,"2,0",10)
		tile20.pixel_x = 64

		var/image/tile02 = image('icons/misc/worlds.dmi',null,"0,2",10)
		tile02.pixel_y = 64

		var/image/tile22 = image('icons/misc/worlds.dmi',null,"2,2",10)
		tile22.pixel_y = 64
		tile22.pixel_x = 64

		var/image/tile21 = image('icons/misc/worlds.dmi',null,"2,1",10)
		tile21.pixel_y = 32
		tile21.pixel_x = 64

		var/image/tile12 = image('icons/misc/worlds.dmi',null,"1,2",10)
		tile12.pixel_y = 64
		tile12.pixel_x = 32

		overlays += tile20
		overlays += tile02
		overlays += tile22
		overlays += tile21
		overlays += tile12 */


/obj/river
	name = "River"
	desc = "Some flowing water."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "river"
	anchored = ANCHORED

/obj/stone
	name = "stone"
	desc = "Rock and stone, son. Rock and stone."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "stone"
	anchored = ANCHORED
	density = TRUE

	_max_health = 25
	_health = 25

	attackby(obj/item/I, mob/user)
		if ((istype(I, /obj/item/mining_tool) || istype(I, /obj/item/mining_tools)) && !isrestrictedz(src.z))
			playsound(src, 'sound/impact_sounds/Stone_Cut_1.ogg', 50)
			//bleh
			if (istype(I, /obj/item/mining_tool))
				src._health -= I.force
			else
				var/obj/item/mining_tools/tool = I
				src._health -= tool.power * 2
			if (src._health <= 0)
				src.visible_message(SPAN_ALERT("\The [src] breaks apart."), SPAN_ALERT("You hear rock shattering."))
				for (var/i in 1 to 3)
					new /obj/item/raw_material/rock{rand_pos = TRUE}(src.loc)
				qdel(src)
		. = ..()

	attack_hand(mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/human = user
			if (istype(human.gloves, /obj/item/clothing/gloves/concussive))
				var/obj/item/clothing/gloves/concussive/gauntlets = human.gloves
				return src.Attackby(gauntlets.tool, user)
		. = ..()

	random
		New()
			. = ..()
			src.dir = pick(alldirs)

	snow
		icon = 'icons/turf/snow.dmi'
		icon_state = "snowstone"
		plane = PLANE_NOSHADOW_BELOW // has snow accents to meld with turf

		random
			New()
				. = ..()
				src.dir = pick(alldirs)

/obj/shrub
	name = "shrub"
	desc = "A bush. Despite your best efforts, you can't tell if it's real or not."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "shrub"
	anchored = ANCHORED
	density = 0
	layer = EFFECTS_LAYER_UNDER_1
	flags = FLUID_SUBMERGE
	text = "<font color=#5c5>s"
	var/health = 50
	var/destroyed = 0 // Broken shrubs are unable to vend prizes, this is also used to track a objective.
	var/max_uses = 0 // The maximum amount of time one can try to shake this shrub for something.
	var/spawn_chance = 0 // How likely is this shrub to spawn something?
	var/last_use = 0 // To prevent spam.
	var/time_between_uses = 400 // The default time between uses.
	var/override_default_behaviour = 0 // When this is set to 1, the additional_items list will be used to dispense items.
	var/list/additional_items = list() // See above.
	/// How many bites can cow people take out of it?
	var/bites = 5
	/// The mask used to show bite marks
	var/current_mask = 5
	/// Is the bush actually made out of plastic?
	var/is_plastic = FALSE

	New()
		..()
		START_TRACKING
		max_uses = rand(0, 5)
		spawn_chance = rand(1, 40)
		if (prob(5))
			is_plastic = TRUE
		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION)
			src.UpdateOverlays(image(src.icon, "[icon_state]-xmas"), "xmas")
		#endif
		#ifdef SEASON_AUTUMN
		src.try_set_icon_state(src.icon_state + "_autumn", src.icon) //this will change varedited shrubs into autumn versions but also won't break if there's no autumn version
		#endif

	disposing()
		STOP_TRACKING
		. = ..()

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				src.take_damage(45)

	attack_hand(mob/user)
		if (!user) return
		if (destroyed && iscow(user) && user.a_intent == INTENT_HELP)
			boutput(user, SPAN_NOTICE("You pick at the ruined bush, looking for any leafs to graze on, but cannot find any."))
			return ..()
		else if (destroyed)
			return ..()

		user.lastattacked = get_weakref(src)
		if (iscow(user) && user.a_intent == INTENT_HELP)	//Cow people may want to eat some of the bush's leaves
			graze(user)
			return 0

		src.wiggle()

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))
			var/something = null

			if (override_default_behaviour && islist(additional_items) && length(additional_items))
				something = pick(additional_items)
			else
				something = pick(trinket_safelist)

			if (ispath(something))
				#ifdef XMAS
				var/obj/item/gift/thing = new/obj/item/gift(src.loc)
				thing.gift = new something(thing)
				#else
				var/thing = new something(src.loc)
				#endif
				visible_message(SPAN_ALERT("<b>[user] violently shakes [src] around! \An [thing] falls out!</b>"))
				last_use = world.time
				max_uses--
			else if (istype(something, /obj))
				var/obj/thing = something
				additional_items -= something
				thing.set_loc(src.loc)
				visible_message(SPAN_ALERT("<b>[user] violently shakes [src] around! \An [thing] falls out!</b>"))
		else
			visible_message(SPAN_ALERT("<b>[user] violently shakes [src] around![prob(20) ? " A few leaves fall out!" : null]</b>"))

		//no more BUSH SHIELDS
		for(var/mob/living/L in get_turf(src))
			if (!L.getStatusDuration("knockdown") && !L.hasStatus("resting"))
				boutput(L, SPAN_ALERT("<b>A branch from [src] smacks you right in the face!</b>"))
				L.TakeDamageAccountArmor("head", rand(1,6), 0, 0, DAMAGE_BLUNT)
				logTheThing(LOG_COMBAT, user, "shakes a bush and smacks [L] with a branch [log_loc(user)].")
				var/r = rand(1,2)
				switch(r)
					if (1)
						L.changeStatus("knockdown", 4 SECONDS)
					if (2)
						L.changeStatus("stunned", 2 SECONDS)

		interact_particle(user,src)

	Crossed(atom/movable/AM)
		. = ..()
		if(isliving(AM))
			APPLY_ATOM_PROPERTY(AM, PROP_MOB_HIDE_ICONS, src)

	Uncrossed(atom/movable/AM)
		. = ..()
		if(isliving(AM))
			REMOVE_ATOM_PROPERTY(AM, PROP_MOB_HIDE_ICONS, src)

	attackby(var/obj/item/W, mob/user)
		user.lastattacked = get_weakref(src)
		hit_twitch(src)
		attack_particle(user,src)
		playsound(src, 'sound/impact_sounds/Bush_Hit.ogg', 50, TRUE, 0)
		src.take_damage(W.force)
		user.visible_message(SPAN_ALERT("<b>[user] hacks at [src] with [W]!</b>"))

	proc/take_bite()
		src.bites -= 1
		var/desired_mask = (src.bites / initial(src.bites)) * 5
		desired_mask = round(desired_mask)
		desired_mask = clamp(desired_mask, 1, 5)

		if (desired_mask != current_mask)
			current_mask = desired_mask
			src.add_filter("bite", 0, alpha_mask_filter(icon=icon('icons/obj/foodNdrink/food.dmi', "eating[desired_mask]")))

		if(src.bites <= 0)
			destroy()

	proc/graze(mob/living/carbon/human/user)
		eat_twitch(user)
		playsound(user, 'sound/items/eatfood.ogg', rand(10,50), 1)

		if (is_plastic)
			user.setStatus("knockdown", 3 SECONDS)
			user.visible_message(SPAN_NOTICE("[user] takes a bite out of [src] and chokes on the plastic leaves."), SPAN_ALERT("You munch on some of [src]'s leaves, but realise too late it's made of plastic. You start choking!"))
			user.take_oxygen_deprivation(20)
			user.losebreath += 2
		else
			user.changeStatus("food_hp_up", 20 SECONDS)
			user.visible_message(SPAN_NOTICE("[user] takes a bite out of [src]."), SPAN_NOTICE("You munch on some of [src]'s leaves, like any normal human would."))
			user.sims?.affectMotive("Hunger", 10)

		src.take_bite()

		return 0

	clamp_act(mob/clamper, obj/item/clamp)
		src.take_bite()
		return TRUE

	proc/take_damage(var/damage_amount = 5)
		src.health -= damage_amount
		if (src.health <= 0)
			destroy()
			return

	proc/destroy()
		src.visible_message(SPAN_ALERT("<b>The [src.name] falls apart!</b>"))
		new /obj/decal/cleanable/leaves(get_turf(src))
		playsound(src.loc, 'sound/impact_sounds/Wood_Snap.ogg', 90, 1)
		qdel(src)

	proc/wiggle()
		playsound(src, 'sound/impact_sounds/Bush_Hit.ogg', 50, TRUE, -1)

		var/original_x = pixel_x
		var/original_y = pixel_y
		var/wiggle = 6

		SPAWN(0)
			while (wiggle > 0)
				wiggle--
				animate(src, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 2, easing = EASE_IN)
				sleep(0.1 SECONDS)

		animate(src, pixel_x = original_x, pixel_y = original_y, time = 2, easing = EASE_OUT)

	random
		New()
			. = ..()
			src.dir = pick(alldirs)

	snow
		icon = 'icons/turf/snow.dmi'
		icon_state = "snowshrub"

		random
			New()
				. = ..()
				src.dir = pick(cardinal)

	dead
		name = "Dead shrub"
		icon_state = "shrub-dead"

//It'll show up on multitools
TYPEINFO(/obj/shrub/syndicateplant)
	mats = 2
/obj/shrub/syndicateplant
	var/net_id
	is_syndicate = TRUE
	New()
		. = ..()
		src.net_id = generate_net_id(src)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "control", FREQ_HYDRO)

	proc/fuck_up()
		var/datum/effects/system/spark_spread/S = new
		S.set_up(4, FALSE, src)
		S.start()
		src.visible_message(SPAN_ALERT("<b>[src] starts spraying sparks everywhere! What the fuck?</b>"))

	receive_signal(datum/signal/signal, receive_method, receive_param, connection_id)
		..()
		if(signal.data["address_1"] == "ping" && signal.data["sender"])
			var/datum/signal/response = get_free_signal()
			response.source = src
			response.transmission_method = TRANSMISSION_RADIO
			response.data["address_1"] = signal.data["sender"]
			response.data["command"] = "ping_reply"
			response.data["device"] = "WNET_SHRUB"
			response.data["netid"] = src.net_id
			response.data["sender"] = src.net_id
			SPAWN(0.5 SECONDS)
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, response)

		if(signal.data["address_1"] == src.net_id)
			switch(signal.data["command"])
				if("shake")
					if(prob(5)) // this thing sucks ass
						src.fuck_up()
					else
						src.wiggle()


/obj/shrub/captainshrub
	name = "\improper Captain's bonsai tree"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "bonsai"
	desc = "The Captain's most prized possession. Don't touch it. Don't even look at it."
	anchored = ANCHORED
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	dir = EAST

	destroy()
		src.set_dir(NORTHEAST)
		src.destroyed = 1
		src.set_density(0)
		icon_state = "bonsai-destroyed"
		src.desc = "The scattered remains of a once-beautiful bonsai tree."
		playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_3.ogg', 100, 0)
		message_ghosts("<b>[src]</b> has been VIOLENTLY DESTROYED at [log_loc(src, ghostjump=TRUE)].")
		// The bonsai tree goes to the deadbar because of course it does, except when there is no deadbar of course
		var/list/afterlife_turfs = get_area_turfs(/area/afterlife/bar)
		if(length(afterlife_turfs))
			var/obj/shrub/captainshrub/C = new /obj/shrub/captainshrub
			C.overlays += image('icons/misc/32x64.dmi',"halo")
			C.set_loc(pick(afterlife_turfs))
			C.anchored = UNANCHORED
			C.set_density(0)
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Captain")
				boutput(M, SPAN_ALERT("You suddenly feel hollow. Something very dear to you has been lost."))

	graze(mob/user)
		user.lastattacked = get_weakref(src)
		if (user.mind && user.mind.assigned_role == "Captain")
			boutput(user, SPAN_NOTICE("You catch yourself almost taking a bite out of your precious bonzai but stop just in time!"))
			return
		else
			boutput(user, SPAN_ALERT("I don't think the Captain is going to be too happy about this..."))
			user.visible_message(SPAN_ALERT("<b>[user] violently grazes on [src]!</b>"), SPAN_NOTICE("You voraciously devour the bonzai, what a feast!"))
			src.interesting = "Inexplicably, the genetic code of the bonsai tree has the words 'fuck [user.real_name]' encoded in it over and over again."
			src.destroy()
			user.changeStatus("food_deep_burp", 2 MINUTES)
			user.changeStatus("food_hp_up", 2 MINUTES)
			user.changeStatus("food_energized", 2 MINUTES)
			return

	attackby(obj/item/W, mob/user)
		if (!W) return
		if (!user) return
		if (inafterlife(user))
			boutput(user, "You can't bring yourself to hurt such a beautiful thing!")
			return
		if (src.destroyed) return
		if (user.mind && user.mind.assigned_role == "Captain")
			if (issnippingtool(W))
				boutput(user, SPAN_NOTICE("You carefully and lovingly sculpt your bonsai tree."))
			else
				boutput(user, SPAN_ALERT("Why would you ever destroy your precious bonsai tree?"))
		else if(isitem(W) && (user.mind && user.mind.assigned_role != "Captain"))
			src.destroy()
			boutput(user, SPAN_ALERT("I don't think the Captain is going to be too happy about this..."))
			src.visible_message(SPAN_ALERT("<b>[user] ravages [src] with [W].</b>"))
			src.interesting = "Inexplicably, the genetic code of the bonsai tree has the words 'fuck [user.real_name]' encoded in it over and over again."
		return

	meteorhit(obj/O as obj)
		src.visible_message(SPAN_ALERT("<b>The meteor smashes right through [src]!</b>"))
		src.destroy()
		src.interesting = "Looks like it was crushed by a giant fuck-off meteor."
		return

	ex_act(severity)
		src.visible_message(SPAN_ALERT("<b>[src] is ripped to pieces by the blast!</b>"))
		src.destroy()
		src.interesting = "Looks like it was blown to pieces by some sort of explosive."
		return

/obj/captain_bottleship
	name = "\improper Captain's ship in a bottle"
	desc = "The Captain's most prized possession. Don't touch it. Don't even look at it."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bottleship"
	anchored = ANCHORED
	density = 0
	layer = EFFECTS_LAYER_1
	var/destroyed = 0

	// stole all of this from the captain's shrub lol
	update_icon()
		if (!src) return
		src.destroyed = 1
		src.desc = "The scattered remains of a once-beautiful ship in a bottle."
		playsound(src.loc, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 100, 0)
		// The bonsai goes to the deadbar so I guess the ship in a bottle does too lol
		var/obj/captain_bottleship/C = new /obj/captain_bottleship
		C.overlays += image('icons/misc/32x64.dmi',"halo")
		C.set_loc(pick(get_area_turfs(/area/afterlife/bar)))
		C.anchored = UNANCHORED
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Captain")
				boutput(M, SPAN_ALERT("You suddenly feel hollow. Something very dear to you has been lost."))
		return

	attackby(obj/item/W, mob/user)
		if (!W) return
		if (!user) return
		if (inafterlife(user))
			boutput(user, "You can't bring yourself to hurt such a beautiful thing!")
			return
		if (src.destroyed) return
		if (user.mind && user.mind.assigned_role == "Captain")
			boutput(user, SPAN_ALERT("Why would you ever destroy your precious ship in a bottle?"))
		else if(isitem(W) && (user.mind && user.mind.assigned_role != "Captain"))
			src.UpdateIcon()
			boutput(user, SPAN_ALERT("I don't think the Captain is going to be too happy about this..."))
			src.visible_message(SPAN_ALERT("<b>[user] ravages the [src] with [W].</b>"))
			src.interesting = "Inexplicably, the signal flags on the shattered mast just say 'fuck [user.real_name]'."
		return

	meteorhit(obj/O as obj)
		src.visible_message(SPAN_ALERT("<b>The meteor smashes right through [src]!</b>"))
		src.UpdateIcon()
		src.interesting = "Looks like it was crushed by a giant fuck-off meteor."
		return

	ex_act(severity)
		src.visible_message(SPAN_ALERT("<b>[src] is shattered and pulverized by the blast!</b>"))
		src.UpdateIcon()
		src.interesting = "Looks like it was blown to pieces by some sort of explosive."
		return

/obj/potted_plant
	name = "potted plant"
	desc = "Considering the fact that plants communicate through their roots, you wonder if this one ever feels lonely."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ppot0"
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_SCREWDRIVER

	New()
		..()
		if (src.icon_state == "ppot0") // only randomize a plant if it's not set to something specific
			src.icon_state = "ppot[rand(1,5)]"

	potted_plant1
		icon_state = "ppot1"

	potted_plant2
		icon_state = "ppot2"

	potted_plant3
		icon_state = "ppot3"

	potted_plant4
		icon_state = "ppot4"

	potted_plant5
		icon_state = "ppot5"

/obj/grassplug
	name = "grass"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "grassplug"
	anchored = ANCHORED

/proc/switched_obj_toggle(var/category,var/id,var/new_state = FALSE)
	if(!category || !id)
		logTheThing(LOG_DEBUG, null, "Switched object toggle called without full var set. Variables passed: [category] | [id]")
		return
	for(var/atom/A in switched_objs[category][id])
		A:toggle(new_state)

/obj/window_blinds
	name = "blinds"
	desc = "Thin strips of plastic that can be angled to prevent light from passing through. There's probably a switch that controls them nearby."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "blindsH-o"
	anchored = ANCHORED
	density = 0
	opacity = 0
	layer = EFFECTS_LAYER_UNDER_3 // below lights, above windoors
	var/base_state = "blindsH"
	var/open = 1
	var/id = null

	New()
		. = ..()
		if (current_state > GAME_STATE_PREGAME)
			SPAWN(0.5 SECONDS)
				src.initialize()

	initialize()
		if (!src.id)
			var/area/blind_area = get_area(src)
			src.id = blind_area.name
		ADD_SWITCHED_OBJ(SWOB_BLINDS)

	disposing()
		REMOVE_SWITCHED_OBJ(SWOB_BLINDS)
		. = ..()

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)

	attack_hand(mob/user)
		src.toggle_group()

	attackby(obj/item/W, mob/user)
		src.toggle_group()

	proc/toggle(var/new_state)
		src.open = new_state
		src.UpdateIcon()

	proc/toggle_group()
		switched_obj_toggle(SWOB_BLINDS,src.id,!(src.open))

	update_icon()
		if (src.open)
			src.icon_state = "[src.base_state]-c"
			src.set_opacity(1)
		else
			src.icon_state = "[src.base_state]-o"
			src.set_opacity(0)

	left
		icon_state = "blindsH-L-o"
		base_state = "blindsH-L"
	middle
		icon_state = "blindsH-M-o"
		base_state = "blindsH-M"
	right
		icon_state = "blindsH-R-o"
		base_state = "blindsH-R"

	closed
		open = 0
		opacity = 1
		icon_state = "blindsH-c"
		left
			icon_state = "blindsH-L-c"
			base_state = "blindsH-L"
		middle
			icon_state = "blindsH-M-c"
			base_state = "blindsH-M"
		right
			icon_state = "blindsH-R-o"
			base_state = "blindsH-R"

	vertical
		icon_state = "blindsV-o"
		base_state = "blindsV"

		left
			icon_state = "blindsV-L-o"
			base_state = "blindsV-L"
		middle
			icon_state = "blindsV-M-o"
			base_state = "blindsV-M"
		right
			icon_state = "blindsV-R-o"
			base_state = "blindsV-R"

		closed
			open = 0
			opacity = 1
			icon_state = "blindsV-c"

			left
				icon_state = "blindsV-L-c"
				base_state = "blindsV-L"
			middle
				icon_state = "blindsV-M-c"
				base_state = "blindsV-M"
			right
				icon_state = "blindsV-R-c"
				base_state = "blindsV-R"

	cog2
		icon_state = "blinds_cog2-o"
		base_state = "blinds_cog2"

		left
			icon_state = "blinds_cog2-L-o"
			base_state = "blinds_cog2-L"
		middle
			icon_state = "blinds_cog2-M-o"
			base_state = "blinds_cog2-M"
		right
			icon_state = "blinds_cog2-R-o"
			base_state = "blinds_cog2-R"

		closed
			open = 0
			opacity = 1
			icon_state = "blindsV-c"

			left
				icon_state = "blinds_cog2-L-o"
				base_state = "blinds_cog2-L"
			middle
				icon_state = "blinds_cog2-M-o"
				base_state = "blinds_cog2-M"
			right
				icon_state = "blinds_cog2-R-o"
				base_state = "blinds_cog2-R"

/obj/blind_switch
	name = "blind switch"
	desc = "A switch for opening the blinds."
	icon = 'icons/obj/power.dmi'
	icon_state = "blind1"
	anchored = ANCHORED
	density = 0
	var/on = 0
	var/id = null

	New()
		. = ..()
		if (current_state > GAME_STATE_PREGAME)
			SPAWN(0.5 SECONDS)
				src.initialize()

	initialize()
		if (!src.name || (src.name in list("N blind switch", "E blind switch", "S blind switch", "W blind switch")))//== "N light switch" || name == "E light switch" || name == "S light switch" || name == "W light switch")
			src.name = "blind switch"
		if (!src.id)
			var/area/blind_area = get_area(src)
			src.id = blind_area.name
		ADD_SWITCHED_OBJ(SWOB_BLINDS)

	disposing()
		REMOVE_SWITCHED_OBJ(SWOB_BLINDS)
		. = ..()

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)

	proc/toggle(var/new_state)
		src.on = new_state
		src.icon_state = "blind[!(src.on)]"
		src.UpdateIcon()

	proc/toggle_group()
		switched_obj_toggle(SWOB_BLINDS,src.id,!(src.on))

	attack_hand(mob/user)
		. = ..()
		src.toggle_group()

	attack_ai(mob/user as mob)
		. = ..()
		src.toggle_group()

	attackby(obj/item/W, mob/user)
		. = ..()
		src.toggle_group()

/obj/blind_switch/north
	name = "N blind switch"
	dir = NORTH
	pixel_y = 24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/east
	name = "E blind switch"
	dir = EAST
	pixel_x = 24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/south
	name = "S blind switch"
	dir = SOUTH
	pixel_y = -24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/west
	name = "W blind switch"
	dir = WEST
	pixel_x = -24

	on
		on = 1
		icon_state = "blind0"

// left in for existing map compatibility; subsequent update could unify blind and sign switches codewise, and eliminate this subtype
/obj/blind_switch/area

/obj/blind_switch/area/north
	name = "N blind switch"
	dir = NORTH
	pixel_y = 24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/area/east
	name = "E blind switch"
	dir = EAST
	pixel_x = 24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/area/south
	name = "S blind switch"
	dir = SOUTH
	pixel_y = -24

	on
		on = 1
		icon_state = "blind0"

/obj/blind_switch/area/west
	name = "W blind switch"
	dir = WEST
	pixel_x = -24

	on
		on = 1
		icon_state = "blind0"

/obj/sign_switch
	name = "sign switch"
	desc = "Connected to one or more illuminated signs, turning them on or off."
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	anchored = ANCHORED
	density = 0
	var/on = FALSE
	var/id = null

	New()
		..()
		if (current_state > GAME_STATE_PREGAME)
			SPAWN(0.5 SECONDS)
				src.initialize()

	initialize()
		if (!src.name || (src.name in list("N sign switch", "E sign switch", "S sign switch", "W sign switch")))
			src.name = "sign switch"
		if (!src.id)
			var/area/sign_area = get_area(src)
			src.id = sign_area.name
		ADD_SWITCHED_OBJ(SWOB_SIGNAGE)

	disposing()
		REMOVE_SWITCHED_OBJ(SWOB_SIGNAGE)
		. = ..()

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)

	proc/toggle(var/new_state)
		src.on = new_state
		src.icon_state = "light[src.on]"
		src.UpdateIcon()

	proc/toggle_group()
		if(!ON_COOLDOWN(src, "toggle", 1 SECOND))
			switched_obj_toggle(SWOB_SIGNAGE,src.id,!(src.on))
			playsound(src, 'sound/misc/lightswitch.ogg', 50, TRUE)

	attack_hand(mob/user)
		src.toggle_group()

	attack_ai(mob/user as mob)
		src.toggle_group()

	attackby(obj/item/W, mob/user)
		src.toggle_group()

/obj/sign_switch/north
	name = "N sign switch"
	pixel_y = 24

/obj/sign_switch/east
	name = "E sign switch"
	pixel_x = 24

/obj/sign_switch/south
	name = "S sign switch"
	pixel_y = -24

/obj/sign_switch/west
	name = "W sign switch"
	pixel_x = -24

/obj/machinery/illuminated_sign
	name = "illuminated sign"
	desc = "It's a sign on the wall that does the glowy thing."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "occupancy-1"
	anchored = ANCHORED
	density = 0
	opacity = 0
	layer = FLY_LAYER+1.01 // just above windows
	var/base_state = "occupancy"
	var/on = FALSE
	var/id = null

	New()
		..()
		if (current_state > GAME_STATE_PREGAME)
			SPAWN(0.5 SECONDS)
				src.initialize()

	initialize()
		if (!src.id)
			var/area/sign_area = get_area(src)
			src.id = sign_area.name
		ADD_SWITCHED_OBJ(SWOB_SIGNAGE)

	disposing()
		REMOVE_SWITCHED_OBJ(SWOB_SIGNAGE)
		. = ..()

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)

	proc/toggle(var/new_state)
		src.on = new_state
		src.UpdateIcon()

	power_change()
		..()
		UpdateIcon()

/obj/machinery/illuminated_sign/update_icon()
	if(!on || status & NOPOWER)
		icon_state = "[src.base_state]-0"
		src.UpdateOverlays(null, "light")
	else
		icon_state = "[src.base_state]-1"
		var/mutable_appearance/light_ov = mutable_appearance(src.icon, "[src.base_state]-glow")
		light_ov.plane = PLANE_LIGHTING
		light_ov.alpha = 150
		src.UpdateOverlays(light_ov, "light")

/obj/machinery/illuminated_sign/occupancy
	name = "occupancy sign"
	desc = "A convenient illuminated sign to let you know that you're not supposed to butt in."
	icon_state = "occupancy-0"
	base_state = "occupancy"

/obj/machinery/illuminated_sign/onair
	name = "ON AIR sign"
	desc = "Glows in proximity to pompous radio hosts."
	icon_state = "onair-0"
	base_state = "onair"

/obj/machinery/illuminated_sign/open_neon
	name = "open sign"
	desc = "A fancy neon-style sign, traditionally used to welcome others to an active place of business."
	icon_state = "opensign-0"
	base_state = "opensign"

/obj/disco_ball
	name = "disco ball"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "disco0"
	anchored = ANCHORED
	density = 0
	layer = 6
	var/on = 0
	///List of dummy objects that contain the actual light overlays
	var/list/light_overlay_dummies = list()
	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.8)
		light.set_color(2,2,2)
		light.set_height(2.4)
		light.attach(src)

	attack_hand(mob/user)
		src.toggle_on()

	proc/add_lights()
		SPAWN(0) //SDMM doesn't seem to understand waitfor sooo
			for (var/i in 1 to 8)
				var/type = prob(50) ? pick(concrete_typesof(/obj/overlay/simple_light/disco_lighting/rainbow/random_start)) : pick(concrete_typesof(/obj/overlay/simple_light/disco_lighting/oscillator))
				var/obj/overlay/simple_light/disco_lighting/overlay = new type()
				overlay.alpha = 0
				animate(overlay, alpha = 255, time = 1 SECOND, flags = ANIMATION_PARALLEL)

				var/obj/dummy/dummy = new() //byond's animation system sucks, the colour changing animations interfere with the orbit so we do THIS SHIT
				dummy.mouse_opacity = FALSE
				dummy.vis_contents += overlay
				src.vis_contents += dummy
				src.light_overlay_dummies += dummy
				animate_orbit(dummy, radius = 64, time = 4 SECONDS)

				sleep(0.5 SECONDS)
				if (!src.on)
					return

	proc/remove_lights()
		for (var/obj/dummy/overlay as anything in src.light_overlay_dummies)
			src.light_overlay_dummies -= overlay
			overlay.vis_contents = null
			qdel(overlay)

	proc/toggle_on()
		if (!src.on && GET_COOLDOWN(src, "disco_ball_antispam")) //recently turned off, don't spam to stack overlays
			return
		src.on = !src.on
		src.icon_state = "disco[src.on]"
		if (src.on)
			src.add_lights()
			src.light.enable()
			if (!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles_disco, src))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparkles_disco(src))
		else
			ON_COOLDOWN(src, "disco_ball_antispam", 1 SECOND)
			src.light.disable()
			src.remove_lights()
			particleMaster.RemoveSystem(/datum/particleSystem/sparkles_disco, src)

	disposing()
		if (src.on)
			src.remove_lights()
		..()

/obj/admin_plaque
	name = "Admin's Office"
	desc = "A nameplate signifying who this office belongs to."
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "office_plaque"
	anchored = ANCHORED

/obj/chainlink_fence
	name = "chain-link fence"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "chainlink"
	anchored = ANCHORED
	density = 1
	centcom_edition
		name = "electrified super high-security mk. X-22 edition chain-link fence"
		desc = "Whoa."

		ex_act(severity)
			return

		meteorhit(obj/meteor)
			return

/obj/effects/background_objects
	icon = 'icons/misc/512x512.dmi'
	icon_state = "moon-ice"
	name = "X15"
	desc = "A nearby icy moon orbiting the gas giant. Deep reserves of liquid water have been detected below the fractured and desolate surface."
	mouse_opacity = 0
	opacity = 0
	anchored = ANCHORED_ALWAYS
	density = 0
	plane = PLANE_SPACE

	x3
		icon_state = "moon-green"
		name = "X3"
		desc = "A nearby rocky moon orbiting the gas giant. Steady intake of icy debris from the giant's ring system feeds moisture into the shallow, chilly atmosphere."

	x5
		icon_state = "moon-chunky"
		name = "X5"
		desc = "A nearby moon orbiting the gas giant. At certain elevations the atmosphere is thick enough to support terraforming efforts.."

	x4
		icon = 'icons/obj/large/160x160.dmi'
		icon_state = "bigasteroid_1"
		name = "X4"
		desc = "A jagged little moonlet or a really big asteroid. It's fairly close to your orbit, you can see the lights of Outpost Kappa."

	x0
		icon = 'icons/misc/1024x1024.dmi'
		icon_state = "plasma_giant"
		name = "X0"
		desc = "Your neighborhood plasma giant, a fair bit larger than Jupiter. The atmosphere is primarily composed of volatile FAAE. Little can be discerned of the denser layers below the plasma storms."

	star_red
		icon = 'icons/misc/galactic_objects_large.dmi'
		icon_state = "star-red"
		name = "Fugere" // formerly known as fugg
		desc = "A dying red subgiant star shrouded in cast-off shells of gas. Its name derives from the Latin verb, meaning to run away. It's sometimes called Fugg for short."

	star_blue
		icon = 'icons/misc/galactic_objects_large.dmi'
		icon_state = "star-blue"
		name = "Šid" // formerly known as Shidd, and the two stars were named the other way around once
		desc = "A blazing young blue star. Its name derives from the ancient persian name, Jamšid, where šid means brilliant or radiant. It's sometimes called Shidd for laughs."


	domus_dei
		icon_state = "domusDei"
		name = "Domus Dei"
		pixel_x = -256
		pixel_y = -256

	quadriga
		icon_state = "quadriga"
		name = "Quadriga"
		pixel_x = -256
		pixel_y = -256

	mundus
		icon_state = "mundus"
		name = "Mundus"
		pixel_x = -256
		pixel_y = -256

	iustitia
		icon_state = "iustitia"
		name = "Iustitia"
		pixel_x = -256
		pixel_y = -256

	iudicium
		icon_state = "iudicium"
		name = "Iudicium"
		pixel_x = -256
		pixel_y = -256

	fortuna
		icon_state = "fortuna"
		name = "Fortuna"
		pixel_x = -256
		pixel_y = -256

	fatuus
		icon_state = "fatuus"
		name = "Fatuus"
		pixel_x = -256
		pixel_y = -256

	magus
		icon_state = "magus"
		name = "Magus"
		pixel_x = -256
		pixel_y = -256

	regis
		icon_state ="regis"
		name = "Regis"
		pixel_x = -256
		pixel_y = -256

	regina
		icon = 'icons/obj/large/320x320.dmi'
		icon_state = "regina"
		name = "Regina"
		pixel_x = -110
		pixel_y = -170

	amantes
		icon_state = "amantes"
		name = "Amantes"
		pixel_x = -256
		pixel_y = -256

	antistes
		icon_state = "antistes"
		name = "Antistes"
		pixel_x = -256
		pixel_y = -256

	mors
		icon_state = "mors"
		name = "Mors"
		pixel_x = -256
		pixel_y = -256

	station
		name = "Space Station 14"
		desc = "Another Nanotrasen station passing by your orbit."
		icon = 'icons/obj/backgrounds.dmi'
		icon_state = "ss14"

		ss12
			name = "Space Station 12"
			desc = "That's... not good."
			icon_state = "ss12-broken"

		ss10
			name = "Space Station 10"
			desc = "Looks like the regional Nanotrasen hub station passing by your orbit."
			icon_state = "ss10"

obj/decoration


obj/decoration/decorativeplant
	name = "decorative plant"
	desc = "Is it flora or is it fauna? Hm."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "plant1"
	anchored = ANCHORED
	density = 1

	plant2
		icon_state = "plant2"
	plant3
		icon_state = "plant3"
	plant4
		icon_state = "plant4"
	plant5
		icon_state = "plant5"
	plant6
		icon_state = "plant6"
	plant7
		icon_state = "plant7"

obj/decoration/junctionbox
	name = "junction box"
	desc = "It seems to be locked pretty tight with no reasonable way to open it."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "junctionbox"
	anchored = ANCHORED_ALWAYS

	junctionbox2
		icon_state = "junctionbox2"
	junctionbox3
		icon_state = "junctionbox3"

obj/decoration/clock
	name = "clock"
	//desc = "No wonder time always feels so frozen.."
	icon_state = "clock"
	desc = " "
	icon = 'icons/obj/decoration.dmi'
	anchored = ANCHORED

	get_desc()
		. += "[pick("The time is", "It's", "It's currently", "It reads", "It says")] [o_clock_time()]."

obj/decoration/clock/frozen
	desc = "The clock seems to be completely unmoving, frozen at exactly 3 AM."

	get_desc()
		return

obj/decoration/vent
	name = "vent"
	desc = "Better not to stick your hand in there, those blades look sharp.."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "vent1"
	anchored = ANCHORED

	vent2
		icon_state = "vent2"
	vent3
		icon_state = "vent3"

obj/decoration/ceilingfan
	name = "ceiling fan"
	desc = "It's actually just kinda hovering above the floor, not actually in the ceiling. Don't tell anyone."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "detectivefan"
	anchored = ANCHORED
	layer = EFFECTS_LAYER_BASE

/obj/decoration/candles
	name = "wall mounted candelabra"
	desc = "It's a big candle."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "candles-unlit"
	density = 0
	anchored = ANCHORED_ALWAYS
	opacity = 0
	var/icon_off = "candles-unlit"
	var/icon_on = "candles"
	var/brightness = 1
	var/col_r = 0.5
	var/col_g = 0.3
	var/col_b = 0.0
	var/lit = 0
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(brightness)
		light.set_color(col_r, col_g, col_b)
		light.attach(src)

	update_icon()
		if (src.lit == 1)
			src.icon_state = src.icon_on
			light.enable()

		else
			src.lit = 0
			src.icon_state = src.icon_off
			light.disable()

	attackby(obj/item/W, mob/user)
		if (!src.lit)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				boutput(user, SPAN_ALERT("<b>[user]</b> casually lights [src] with [W], what a badass."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				boutput(user, SPAN_ALERT("Did [user] just light [his_or_her(user)] [src] with [W]? Holy Shit."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/device/igniter))
				boutput(user, SPAN_ALERT("<b>[user]</b> fumbles around with [W]; a small flame erupts from [src]."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/device/light/zippo) && W:on)
				boutput(user, SPAN_ALERT("With a single flick of [his_or_her(user)] wrist, [user] smoothly lights [src] with [W]. Damn [hes_or_shes(user)] cool."))
				src.lit = 1
				UpdateIcon()

			if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				boutput(user, SPAN_ALERT("<b>[user] lights [src] with [W]."))
				src.lit = 1
				UpdateIcon()

			if (W.burning)
				boutput(user, SPAN_ALERT("<b>[user]</b> lights [src] with [W]. Goddamn."))
				src.lit = 1
				UpdateIcon ()

	attack_hand(mob/user)
		if (src.lit)
			var/fluff = pick("snuff", "blow")
			src.lit = 0
			UpdateIcon()
			user.visible_message("<b>[user]</b> [fluff]s out the [src].",\
			"You [fluff] out the [src].")


	disposing()
		if (light)
			light.dispose()
		..()

	prelit
		New()
			. = ..()
			src.lit = TRUE
			UpdateIcon()

/obj/decoration/rustykrab
	name = "rusty krab sign"
	desc = "It's one of those old neon signs that diners used to have."
	icon_state = "rustykrab"
	icon = 'icons/obj/large/64x32.dmi'
	density = 0
	opacity = 0
	anchored = ANCHORED_ALWAYS

/obj/decoration/bookcase
	name = "bookcase"
	desc = "It's a bookcase. Full of books."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bookcase"
	anchored = ANCHORED_ALWAYS
	density = 0
	layer = DECAL_LAYER

/obj/decoration/toiletholder
	name = "toilet paper holder"
	desc = "Why would you even need this when there's no..?"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "toiletholder"
	anchored = ANCHORED
	density = 0

/obj/decoration/tabletopfull
	name = "tabletop shelf"
	desc = "It's a shelf full of things that you'll need to play your favourite tabletop campaigns. Mainly a lot of dice that can only roll 1's."
	icon_state = "tabletopfull"
	icon = 'icons/obj/large/64x32.dmi'
	anchored = ANCHORED_ALWAYS
	density = 0
	layer = DECAL_LAYER

obj/decoration/gibberBroken
	name = "rusty old gibber"
	desc = "This thing is completely broken and rusted. There's also a shredded armored jacket and some crunched up bloody bones inside. Huh."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "gibberBroken"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_CROWBAR

/obj/decoration/syndiepc
	name = "syndicate computer"
	desc = "It looks rather sinister with all the red text. I wonder what does it all mean?"
	anchored = ANCHORED_ALWAYS
	density = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndiepc1"

	New()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	syndiepc2
		icon_state = "syndiepc2"

	syndiepc3
		icon_state = "syndiepc3"

	syndiepc4
		icon_state = "syndiepc4"

	syndiepc5
		icon_state = "syndiepc5"

	syndiepc6
		icon_state = "syndiepc6"

	syndiepc7
		icon_state = "syndiepc7"

	syndiepc8
		icon_state = "syndiepc8"

	syndiepc9
		icon_state = "syndiepc9"

	syndiepc10
		icon_state = "syndiepc10"

	syndiepc11
		icon_state = "syndiepc11"

	syndiepc12
		icon_state = "syndiepc12"

	syndiepc13
		icon_state = "syndiepc13"

	syndiepc14
		icon_state = "syndiepc14"

	syndiepc15
		icon_state = "syndiepc15"

	syndiepc16
		icon_state = "syndiepc16"

	syndiepc17
		icon_state = "syndiepc17"

	syndiepc18
		icon_state = "syndiepc18"

	syndiepc19
		icon_state = "syndiepc19"

	syndiepc20
		icon_state = "syndiepc20"

/obj/decoration/bustedmantapc
	name = "broken computer"
	desc = "Yeaaah, it has certainly seen some better days."
	anchored = ANCHORED_ALWAYS
	density = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bustedmantapc"

	bustedmantapc2
		icon_state = "bustedmantapc2"
		name = "cracked computer"

	bustedmantapc3
		icon_state = "bustedmantapc3"
		name = "demolished computer"

/obj/decoration/collapsedwall
	name = "collapsed wall"
	anchored = ANCHORED_ALWAYS
	density = 0
	opacity = 0
	icon = 'icons/obj/decoration.dmi'
	icon_state = "collapsedwall"

/obj/decoration/ntcratesmall
	name = "metal crate"
	anchored = ANCHORED_ALWAYS
	density = 1
	desc = "A tightly locked metal crate."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ntcrate"

/obj/decoration/ntcrate
	name = "metal crate"
	anchored = ANCHORED_ALWAYS
	density = 1
	desc = "Assortment of two metal crates, both of them sealed shut."
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "ntcrate1"
	layer = EFFECTS_LAYER_1
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	bound_height = 32
	bound_width = 32

	ntcrate2
		icon_state = "ntcrate2"

/obj/decoration/weirdmark
	name = "weird mark"
	anchored = ANCHORED_ALWAYS
	icon = 'icons/obj/decoration.dmi'
	icon_state = "weirdmark"

/obj/decoration/frontwalldamage
	anchored = ANCHORED_ALWAYS
	icon = 'icons/obj/decoration.dmi'
	icon_state = "frontwalldamage"
	mouse_opacity = 0

/obj/decoration/damagedchair
	anchored = ANCHORED_ALWAYS
	icon = 'icons/obj/decoration.dmi'
	icon_state = "damagedchair"

/obj/decoration/syndcorpse5
	anchored = ANCHORED_ALWAYS
	name = "syndicate corpse"
	icon = 'icons/obj/decoration.dmi'
	desc = "Whoever this was, you're pretty sure they've had better days. Makes you wonder where the other half is..."
	icon_state = "syndcorpse5"

/obj/decoration/syndcorpse10
	anchored = ANCHORED_ALWAYS
	name = "syndicate corpse"
	icon = 'icons/obj/decoration.dmi'
	desc = "... Oh, there it is."
	icon_state = "syndcorpse10"

/obj/decoration/bullethole
	anchored = ANCHORED_ALWAYS
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullethole"
	mouse_opacity = 0

	examine()
		return list()

/obj/decoration/plasmabullethole
	anchored = ANCHORED_ALWAYS
	icon = 'icons/obj/decoration.dmi'
	icon_state = "plasma-bhole"
	mouse_opacity = 0

	examine()
		return list()

//fake guns for shooting range prefab

/obj/item/gun/laser_pistol
	name = "laser pistol"
	icon = 'icons/obj/decoration.dmi'
	desc = "A terribly cheap and discontinued old model of laser pistol."
	icon_state = "laser_pistol"
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	item_state = "protopistol"
	stamina_damage = 0
	stamina_cost = 4
	stamina_crit_chance = 0
	throwforce = 0

	attack_hand(mob/user)
		if ((user.r_hand == src || user.l_hand == src) && src.contents && length(src.contents))
			user.visible_message("The cell on this is corroded. Good luck getting this thing to fire ever again!")
			src.add_fingerprint(user)
		else
			return ..()

/obj/item/gun/laser_pistol/prototype
	name = "prototype laser pistol"
	icon = 'icons/obj/decoration.dmi'
	desc = "You've never heard of this pistol before... who made it?"
	icon_state = "e_laser_pistol"

/obj/item/caution/target_sheet
	desc = "A paper silhouette target sheet with a cardboard backing."
	name = "paper target"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "target_paper"
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "table_parts"
	density = 1
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	stamina_damage = 0
	stamina_cost = 4
	stamina_crit_chance = 0
	var/image/proj_image = null
	var/last_proj_update_time = null

	New()
		..()
		src.AddComponent(/datum/component/bullet_holes, 20, 0)
		BLOCK_SETUP(BLOCK_SOFT)

	attackby(obj/item/W, mob/user, params)
		if(iswrenchingtool(W))
			actions.start(new /datum/action/bar/icon/anchor_or_unanchor(src, W, duration=2 SECONDS), user)
			return
		. = ..()

//Walp Decor

/obj/decoration/regallamp
	name = "golden candelabra"
	desc = "Fancy."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "lamp_regal_unlit"
	density = 0
	anchored = UNANCHORED
	opacity = 0
	var/parts_type = /obj/item/furniture_parts/decor/regallamp
	var/icon_off = "lamp_regal_unlit"
	var/icon_on = "lamp_regal_lit"
	var/brightness = 1
	var/col_r = 0.5
	var/col_g = 0.3
	var/col_b = 0.0
	var/lit = 0
	var/securable = 1
	var/datum/light/light
	var/deconstructable = 1

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(brightness)
		light.set_color(col_r, col_g, col_b)
		UpdateIcon()
		light.attach(src)

	update_icon()
		if (src.lit == 1)
			src.icon_state = src.icon_on
			light.enable()

		else
			src.lit = 0
			src.icon_state = src.icon_off
			light.disable()

	attackby(obj/item/W, mob/user)
		if (!src.lit)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				boutput(user, SPAN_ALERT("<b>[user]</b> casually lights [src] with [W], what a badass."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				boutput(user, SPAN_ALERT("Did [user] just light [his_or_her(user)] [src] with [W]? Holy Shit."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/device/igniter))
				boutput(user, SPAN_ALERT("<b>[user]</b> fumbles around with [W]; a small flame erupts from [src]."))
				src.lit = 1
				UpdateIcon()

			if (istype(W, /obj/item/device/light/zippo) && W:on)
				boutput(user, SPAN_ALERT("With a single flick of [his_or_her(user)] wrist, [user] smoothly lights [src] with [W]. Damn [hes_or_shes(user)] cool."))
				src.lit = 1
				UpdateIcon()

			if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				boutput(user, SPAN_ALERT("<b>[user] lights [src] with [W]."))
				src.lit = 1
				UpdateIcon()

			if (W.burning)
				boutput(user, SPAN_ALERT("<b>[user]</b> lights [src] with [W]. Goddamn."))
				src.lit = 1
				UpdateIcon ()

	attack_hand(mob/user)
		if (src.lit)
			var/fluff = pick("snuff", "blow")
			src.lit = 0
			UpdateIcon()
			user.visible_message("<b>[user]</b> [fluff]s out the [src].",\
			"You [fluff] out the [src].")

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W) && src.deconstructable)
			actions.start(new /datum/action/bar/icon/furniture_deconstruct(src, W, 30), user)
			return
		else if (isscrewingtool(W) && src.securable)
			src.toggle_secure(user)
			return
		else
			return ..()

	proc/toggle_secure(mob/user as mob)
		if (user)
			user.visible_message("<b>[user]</b> [src.anchored ? "loosens" : "tightens"] the floor bolts of [src].[istype(src.loc, /turf/space) ? " It doesn't do much, though, since [src] is in space and all." : null]")
		playsound(src, 'sound/items/Screwdriver.ogg', 100, TRUE)
		src.anchored = !(src.anchored)
		src.p_class = src.anchored ? initial(src.p_class) : 2
		return

	disposing()
		if (light)
			light.dispose()
		..()

	proc/deconstruct()
		if (!src.deconstructable)
			return
		if (ispath(src.parts_type))
			var/obj/item/furniture_parts/P = new src.parts_type(src.loc)
			if (P && src.material)
				P.setMaterial(src.material)
		else
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			var/obj/item/sheet/S = new (src.loc)
			if (src.material)
				S.setMaterial(src.material)
			else
				var/datum/material/M = getMaterial("steel")
				S.setMaterial(M)
		qdel(src)
		return


obj/decoration/floralarrangement
	name = "floral arrangement"
	desc = "These look... Very plastic. Huh."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "floral_arrange"
	anchored = ANCHORED
	density = 1

obj/decoration/pottedfern
	name = "potted fern"
	desc = "These look... Very plastic. Huh."
	icon = 'icons/misc/walp_decor.dmi'
	icon_state = "plant_fern"
	anchored = ANCHORED
	density = 1

/obj/burning_barrel
	name = "burning barrel"
	desc = "cozy."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "barrel1"
	density = 1
	anchored = ANCHORED
	opacity = 0
	var/on = TRUE
	var/datum/light/light
	var/movable = TRUE
	var/extinguishable = TRUE

	New()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(1)
		light.set_color(0.5, 0.3, 0)
		src.set_on(src.on, TRUE)
		..()

	get_help_message(dist, mob/user)
		return "You can use a <b>wrench</b> to [src.anchored ? "unbolt it" : "bolt it down"]."

	proc/set_on(on, quiet = FALSE)
		if (on)
			src.UpdateParticles(new/particles/barrel_embers, "embers")
			src.UpdateParticles(new/particles/barrel_smoke, "smoke")
			src.light.enable()
			src.on = TRUE
			name = initial(name)
			desc = initial(desc)
			if (!quiet)
				playsound(src, 'sound/effects/lit.ogg', 80, 0, 1)
			global.processing_items |= src //shut up
		else
			src.light.disable()
			src.ClearAllParticles()
			src.on = FALSE
			src.name = "crusty barrel"
			src.desc = "A grody old barrel full of flammable looking wood."
			global.processing_items -= src
		src.UpdateIcon()

	proc/process()
		var/turf/T = get_turf(src)
		if (!T)
			return
		T.hotspot_expose(T0C + 300, 100, TRUE, FALSE)

	update_icon(...)
		if (src.on)
			src.icon_state = "barrel1"
		else
			src.icon_state = "barrel-planks"

	disposing()
		light.disable()
		light.detach()
		light = null
		..()

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/C = W
			if(!C.on && src.on)
				C.light(user, SPAN_ALERT("[user] lights the [C] with [src]. That seems appropriate."))
			return
		if (src.movable && (isscrewingtool(W) || iswrenchingtool(W)))
			if (istype(src.loc, /turf/space))
				boutput(user, SPAN_ALERT("There's nothing to bolt it to!"))
				return
			src.anchored = !src.anchored
			src.visible_message(SPAN_NOTICE("[user] [src.anchored ? "bolts down" : "unbolts"] [src]"))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, TRUE)
			return
		if (W.firesource && !src.on)
			src.set_on(TRUE)
			W.firesource_interact()
			return
		. = ..()

	reagent_act(reagent_id, volume, datum/reagentsholder_reagents)
		if (..() || !src.extinguishable)
			return
		if (reagent_id == "ff-foam" || reagent_id == "water" && volume >= 20)
			src.set_on(FALSE)

/obj/fireworksbox
	name = "Box of Fireworks"
	desc = "The Label simply reads : \"Firwerks fun is having total family.\""
	density = 0
	anchored = UNANCHORED
	opacity = 0
	icon = 'icons/obj/objects.dmi'
	icon_state = "fireworksbox"
	var/fireworking = 0

	attack_hand(mob/user)
		if(fireworking) return
		fireworking = 1
		boutput(user, SPAN_ALERT("The fireworks go off as soon as you touch the box. This is some high quality stuff."))
		anchored = ANCHORED

		SPAWN(0)
			for(var/i=0, i<rand(15,25), i++)
				particleMaster.SpawnSystem(new /datum/particleSystem/fireworks(src.loc))
				playsound(src.loc, 'sound/effects/firework.ogg', 50, 1)
				sleep(rand(2, 15))

			for(var/mob/O in oviewers(world.view, src))
				O.show_message(SPAN_NOTICE("The box of fireworks magically disappears."), 1)

			qdel(src)
		return

ADMIN_INTERACT_PROCS(/obj/lever, proc/toggle)
/obj/lever
	name = "lever"
	desc = "A big satisfying wall lever, ready to be pulled."
	density = 0
	anchored = ANCHORED
	icon = 'icons/obj/decoration.dmi'
	icon_state = "wall-lever-up"
	var/on = FALSE

	attack_hand(mob/user)
		. = ..()
		src.toggle()

	proc/toggle()
		if (ON_COOLDOWN(src, "toggle", 0.7 SECONDS))
			return
		playsound(src.loc, 'sound/machines/button.ogg', 40, 0.5)
		if (on)
			on = FALSE
			FLICK("wall-lever-up-anim", src)
			src.icon_state = "wall-lever-up"
			src.off()
		else
			on = TRUE
			FLICK("wall-lever-down-anim", src)
			src.icon_state = "wall-lever-down"
			src.on()

	proc/on()
		return

	proc/off()
		return


ADMIN_INTERACT_PROCS(/obj/lever/custom, proc/set_up)
/obj/lever/custom
	var/datum/target = null
	var/on_proc = ""
	var/off_proc = ""

	proc/set_up()
		var/list/data = usr.client.get_proccall_arglist(list(
			ARG_INFO("target_datum", DATA_INPUT_REFPICKER, "Target"),
			ARG_INFO("on_proc", DATA_INPUT_TEXT, "Name of proc to call when the lever is pulled ON"),
			ARG_INFO("off_proc", DATA_INPUT_TEXT, "Name of proc to call when the lever is pulled OFF")
		))
		src.target = data["target_datum"]
		src.on_proc = data["on_proc"]
		src.off_proc = data["off_proc"]

	on()
		if (src.target && length(src.on_proc))
			call(src.target, src.on_proc)()

	off()
		if (src.target && length(src.off_proc))
			call(src.target, src.off_proc)()


/obj/decoration/paperstack/massive
	name = "Pile of papers"
	desc = "The pile of papers is so overwhelming it crush you."
	icon = 'icons/obj/large/48x48.dmi'
	icon_state = "paperstack-massive"
	anchored = ANCHORED
	density = 1

/obj/decoration/paperstack/large
	name = "Pile of papers"
	desc = "The pile towers over you, it may collapse at any moment."
	icon = 'icons/obj/writing.dmi'
	icon_state = "paperstack-large"
	anchored = ANCHORED
	density = 1

/obj/decoration/paperstack/tall
	name = "Pile of papers"
	desc = "The pile towers over you, it may collapse at any moment."
	icon = 'icons/obj/writing.dmi'
	icon_state = "paperstack-tall"
	anchored = ANCHORED
	density = 0

/obj/decoration/paperstack/mid
	name = "Pile of papers"
	desc = "The pile looks impressive, it may collapse at any moment."
	icon = 'icons/obj/writing.dmi'
	icon_state = "paperstack-mid"
	anchored = ANCHORED
	density = 0

/obj/decoration/paperstack/small
	name = "Pile of papers"
	desc = "A small pile of papers neatly stacked."
	icon = 'icons/obj/writing.dmi'
	icon_state = "paperstack-small"
	anchored = ANCHORED
	density = 0

/obj/decoration/ritual
	name = "Strange drawing"
	desc = "Looks like someone made a fancy design here, how cool! Wonder what the candles are for."
	icon_state = "ritual"
	icon = 'icons/misc/wander_stuff.dmi'
	anchored = ANCHORED_ALWAYS
	density = 0
	plane = PLANE_NOSHADOW_BELOW

/obj/decoration/wineholder
	name = "Wall mounted wine holder"
	desc = "A shelf attached to the wall holding several bottles of wine."
	icon = 'icons/misc/wander_stuff.dmi'
	icon_state = "wineholder"
	anchored = ANCHORED
	density = 0
