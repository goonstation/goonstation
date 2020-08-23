
/obj/poolwater
	name = "water"
	density = 0
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "poolwater"
	layer = EFFECTS_LAYER_UNDER_3
	mouse_opacity = 0
	var/float_anim = 1
	event_handler_flags = USE_HASENTERED

	New()
		var/datum/reagents/R = new/datum/reagents(10)
		reagents = R
		R.my_atom = src
		R.add_reagent("cleaner", 5)
		R.add_reagent("water", 5)
		SPAWN_DBG(0.5 SECONDS)
			if (src.float_anim)
				for (var/atom/movable/A in src.loc)
					if (!A.anchored)
						animate_bumble(A, floatspeed = 8, Y1 = 3, Y2 = 0)

	HasEntered(atom/A)
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

	HasExited(atom/movable/A, atom/newloc)
		var/turf/T = get_turf(newloc)
		if (istype(T))
			var/obj/poolwater/P = locate() in T
			if (!istype(P))
				if (istype(A, /atom/movable) && !isobserver(A) && !istype(A, /mob/living/critter/small_animal/bee) && !istype(A, /obj/critter/domestic_bee))
					animate(A)
					A.pixel_y = initial(A.pixel_y)
		return ..()

/obj/tree1
	name = "Tree"
	desc = "It's a tree."
	icon = 'icons/effects/96x96.dmi' // changed from worlds.dmi
	icon_state = "tree" // changed from 0.0
	anchored = 1
	layer = EFFECTS_LAYER_UNDER_3
	pixel_x = -20
	density = 1
	opacity = 0 // this causes some of the super ugly lighting issues too

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
	desc = "Its a river."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "river"
	anchored = 1

/obj/stone
	name = "Stone"
	desc = "Its a stone."
	icon = 'icons/misc/worlds.dmi'
	icon_state = "stone"
	anchored = 1
	density=1

/obj/shrub
	name = "shrub"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "shrub"
	anchored = 1
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

	New()
		..()
		max_uses = rand(0, 5)
		spawn_chance = rand(1, 40)
	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				src.take_damage(45)
	attack_hand(mob/user as mob)
		if (!user) return
		if (destroyed) return ..()

		user.lastattacked = src
		playsound(src, "sound/impact_sounds/Bush_Hit.ogg", 50, 1, -1)

		var/original_x = pixel_x
		var/original_y = pixel_y
		var/wiggle = 6

		SPAWN_DBG(0) //need spawn, why would we sleep in attack_hand that's disgusting
			while (wiggle > 0)
				wiggle--
				animate(src, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 2, easing = EASE_IN)
				sleep(0.1 SECONDS)

		animate(src, pixel_x = original_x, pixel_y = original_y, time = 2, easing = EASE_OUT)

		if (max_uses > 0 && ((last_use + time_between_uses) < world.time) && prob(spawn_chance))
			var/something = null

			if (override_default_behaviour && islist(additional_items) && additional_items.len)
				something = pick(additional_items)
			else
				something = pick(trinket_safelist)

			if (ispath(something))
				var/thing = new something(src.loc)
				visible_message("<b><span class='alert'>[user] violently shakes [src] around! \An [thing] falls out!</span></b>", 1)
				last_use = world.time
				max_uses--
		else
			visible_message("<b><span class='alert'>[user] violently shakes [src] around![prob(20) ? " A few leaves fall out!" : null]</span></b>", 1)

		//no more BUSH SHIELDS
		for(var/mob/living/L in get_turf(src))
			if (!L.getStatusDuration("weakened") && !L.hasStatus("resting"))
				boutput(L, "<span class='alert'><b>A branch from [src] smacks you right in the face!</b></span>")
				L.TakeDamageAccountArmor("head", rand(1,6), 0, 0, DAMAGE_BLUNT)
				logTheThing("combat", user, L, "shakes a bush and smacks [L] with a branch [log_loc(user)].")
				var/r = rand(1,2)
				switch(r)
					if (1)
						L.changeStatus("weakened", 4 SECONDS)
					if (2)
						L.changeStatus("stunned", 2 SECONDS)

		interact_particle(user,src)

	attackby(var/obj/item/W as obj, mob/user as mob)
		user.lastattacked = src
		hit_twitch(src)
		attack_particle(user,src)
		playsound(src, "sound/impact_sounds/Bush_Hit.ogg", 50, 1, 0)
		src.take_damage(W.force)
		user.visible_message("<span class='alert'><b>[user] hacks at [src] with [W]!</b></span>")

	proc/take_damage(var/damage_amount = 5)
		src.health -= damage_amount
		if (src.health <= 0)
			src.visible_message("<span class='alert'><b>The [src.name] falls apart!</b></span>")
			new /obj/decal/cleanable/leaves(get_turf(src))
			playsound(src.loc, "sound/impact_sounds/Slimy_Hit_3.ogg", 100, 0)
			qdel(src)
			return

/obj/shrub/captainshrub
	name = "\improper Captain's bonsai tree"
	icon = 'icons/misc/worlds.dmi'
	icon_state = "shrub"
	desc = "The Captain's most prized possession. Don't touch it. Don't even look at it."
	anchored = 1
	density = 1
	layer = EFFECTS_LAYER_UNDER_1
	dir = EAST

	// Added ex_act and meteorhit handling here (Convair880).
	proc/update_icon()
		if (!src) return
		src.dir = NORTHEAST
		src.destroyed = 1
		src.set_density(0)
		src.desc = "The scattered remains of a once-beautiful bonsai tree."
		playsound(src.loc, "sound/impact_sounds/Slimy_Hit_3.ogg", 100, 0)
		// The bonsai tree goes to the deadbar because of course it does
		var/obj/shrub/captainshrub/C = new /obj/shrub/captainshrub
		C.overlays += image('icons/misc/32x64.dmi',"halo")
		C.set_loc(pick(get_area_turfs(/area/afterlife/bar)))
		C.anchored = 0
		C.set_density(0)
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Captain")
				boutput(M, "<span class='alert'>You suddenly feel hollow. Something very dear to you has been lost.</span>")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W) return
		if (!user) return
		if (inafterlife(user))
			boutput(usr, "You can't bring yourself to hurt such a beautiful thing!")
			return
		if (src.destroyed) return
		if (user.mind && user.mind.assigned_role == "Captain")
			if (issnippingtool(W))
				boutput(user, "<span class='notice'>You carefully and lovingly sculpt your bonsai tree.</span>")
			else
				boutput(user, "<span class='alert'>Why would you ever destroy your precious bonsai tree?</span>")
		else if(isitem(W) && (user.mind && user.mind.assigned_role != "Captain"))
			src.update_icon()
			boutput(user, "<span class='alert'>I don't think the Captain is going to be too happy about this...</span>")
			src.visible_message("<b><span class='alert'>[user] ravages the [src] with [W].</span></b>", 1)
			src.interesting = "Inexplicably, the genetic code of the bonsai tree has the words 'fuck [user.real_name]' encoded in it over and over again."
		return

	meteorhit(obj/O as obj)
		src.visible_message("<b><span class='alert'>The meteor smashes right through [src]!</span></b>")
		src.update_icon()
		src.interesting = "Looks like it was crushed by a giant fuck-off meteor."
		return

	ex_act(severity)
		src.visible_message("<b><span class='alert'>[src] is ripped to pieces by the blast!</span></b>")
		src.update_icon()
		src.interesting = "Looks like it was blown to pieces by some sort of explosive."
		return

/obj/captain_bottleship
	name = "\improper Captain's ship in a bottle"
	desc = "The Captain's most prized possession. Don't touch it. Don't even look at it."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bottleship"
	anchored = 1
	density = 0
	layer = EFFECTS_LAYER_1
	var/destroyed = 0

	// stole all of this from the captain's shrub lol
	proc/update_icon()
		if (!src) return
		src.destroyed = 1
		src.desc = "The scattered remains of a once-beautiful ship in a bottle."
		playsound(src.loc, "sound/impact_sounds/Glass_Shards_Hit_1.ogg", 100, 0)
		// The bonsai goes to the deadbar so I guess the ship in a bottle does too lol
		var/obj/captain_bottleship/C = new /obj/captain_bottleship
		C.overlays += image('icons/misc/32x64.dmi',"halo")
		C.set_loc(pick(get_area_turfs(/area/afterlife/bar)))
		C.anchored = 0
		for (var/mob/living/M in mobs)
			if (M.mind && M.mind.assigned_role == "Captain")
				boutput(M, "<span class='alert'>You suddenly feel hollow. Something very dear to you has been lost.</span>")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W) return
		if (!user) return
		if (inafterlife(user))
			boutput(usr, "You can't bring yourself to hurt such a beautiful thing!")
			return
		if (src.destroyed) return
		if (user.mind && user.mind.assigned_role == "Captain")
			boutput(user, "<span class='alert'>Why would you ever destroy your precious ship in a bottle?</span>")
		else if(isitem(W) && (user.mind && user.mind.assigned_role != "Captain"))
			src.update_icon()
			boutput(user, "<span class='alert'>I don't think the Captain is going to be too happy about this...</span>")
			src.visible_message("<b><span class='alert'>[user] ravages the [src] with [W].</span></b>", 1)
			src.interesting = "Inexplicably, the signal flags on the shattered mast just say 'fuck [user.real_name]'."
		return

	meteorhit(obj/O as obj)
		src.visible_message("<b><span class='alert'>The meteor smashes right through [src]!</span></b>")
		src.update_icon()
		src.interesting = "Looks like it was crushed by a giant fuck-off meteor."
		return

	ex_act(severity)
		src.visible_message("<b><span class='alert'>[src] is shattered and pulverized by the blast!</span></b>")
		src.update_icon()
		src.interesting = "Looks like it was blown to pieces by some sort of explosive."
		return

/obj/potted_plant
	name = "potted plant"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ppot0"
	anchored = 1
	density = 0

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
	anchored = 1

/obj/window_blinds
	name = "blinds"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "blindsH-o"
	anchored = 1
	density = 0
	opacity = 0
	layer = FLY_LAYER+1.01 // just above windows
	var/base_state = "blindsH"
	var/open = 1
	var/id = null
	var/obj/blind_switch/mySwitch = null

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)
	attack_hand(mob/user as mob)
		src.toggle()
		src.toggle_group()

	attackby(obj/item/W, mob/user)
		src.toggle()
		src.toggle_group()

	proc/toggle(var/force_state as null|num)
		if (!isnull(force_state))
			src.open = force_state
		else
			src.open = !(src.open)
		src.update_icon()

	proc/toggle_group()
		if (istype(src.mySwitch))
			src.mySwitch.toggle()

	proc/update_icon()
		if (src.open)
			src.icon_state = "[src.base_state]-c"
			src.opacity = 1
		else
			src.icon_state = "[src.base_state]-o"
			src.opacity = 0

	left
		icon_state = "blindsH-L-o"
		base_state = "blindsH-L"
	middle
		icon_state = "blindsH-M-o"
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

/obj/blind_switch
	name = "blind switch"
	desc = "A switch for opening the blinds."
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1
	density = 0
	var/on = 0
	var/id = null
	var/list/myBlinds = list()

	New()
		..()
		if (!src.name || (src.name in list("N blind switch", "E blind switch", "S blind switch", "W blind switch")))//== "N light switch" || name == "E light switch" || name == "S light switch" || name == "W light switch")
			src.name = "blind switch"
		SPAWN_DBG(0.5 SECONDS)
			src.locate_blinds()
	ex_act(var/severity)
		switch(severity)
			if(1,2)
				qdel(src)
			else
				if(prob(50))
					qdel(src)
	proc/locate_blinds()
		for (var/X in by_type[/obj/window_blinds])
			var/obj/window_blinds/blind = X
			if (blind.id == src.id)
				if (!(blind in src.myBlinds))
					src.myBlinds += blind
					blind.mySwitch = src

	proc/toggle()
		src.on = !(src.on)
		src.icon_state = "light[!(src.on)]"
		if (!islist(myBlinds) || !myBlinds.len)
			return
		for (var/obj/window_blinds/blind in myBlinds)
			blind.toggle(src.on)

	attack_hand(mob/user as mob)
		src.toggle()

	attack_ai(mob/user as mob)
		src.toggle()

	attackby(obj/item/W, mob/user)
		src.toggle()

/obj/blind_switch/north
	name = "N blind switch"
	pixel_y = 24

/obj/blind_switch/east
	name = "E blind switch"
	pixel_x = 24

/obj/blind_switch/south
	name = "S blind switch"
	pixel_y = -24

/obj/blind_switch/west
	name = "W blind switch"
	pixel_x = -24

/obj/blind_switch/area
	locate_blinds()
		var/area/A = get_area(src)
		for (var/X in by_type[/obj/window_blinds])
			var/obj/window_blinds/blind = X
			var/area/blind_area = get_area(blind)
			if(blind_area != A)
				continue
			LAGCHECK(LAG_LOW)
			if (!(blind in src.myBlinds))
				src.myBlinds += blind
				blind.mySwitch = src

/obj/blind_switch/area/north
	name = "N blind switch"
	pixel_y = 24

/obj/blind_switch/area/east
	name = "E blind switch"
	pixel_x = 24

/obj/blind_switch/area/south
	name = "S blind switch"
	pixel_y = -24

/obj/blind_switch/area/west
	name = "W blind switch"
	pixel_x = -24

/obj/disco_ball
	name = "disco ball"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "disco0"
	anchored = 1
	density = 0
	layer = 6
	var/on = 0
	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(1)
		light.set_color(2,2,2)
		light.set_height(2.4)
		light.attach(src)

	attack_hand(mob/user as mob)
		src.toggle_on()

	proc/toggle_on()
		src.on = !src.on
		src.icon_state = "disco[src.on]"
		if (src.on)
			light.enable()
			if (!particleMaster.CheckSystemExists(/datum/particleSystem/sparkles_disco, src))
				particleMaster.SpawnSystem(new /datum/particleSystem/sparkles_disco(src))
		else
			light.disable()
			particleMaster.RemoveSystem(/datum/particleSystem/sparkles_disco, src)

/obj/admin_plaque
	name = "Admin's Office"
	desc = "A nameplate signifying who this office belongs to."
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "office_plaque"
	anchored = 1

/obj/chainlink_fence
	name = "chain-link fence"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "chainlink"
	anchored = 1
	density = 1
	centcom_edition
		name = "electrified super high-security mk. X-22 edition chain-link fence"
		desc = "Whoa."

/obj/effects/background_objects
	icon = 'icons/misc/512x512.dmi'
	icon_state = "moon-dark"
	name = "X7"
	desc = "A nearby moon orbiting the gas giant. Forbidden for landings, its exotic atmosphere and roiling electromagnetic storms deter much observation."
	mouse_opacity = 0
	opacity = 0
	anchored = 2
	density = 0
	plane = PLANE_SPACE

	x3
		icon_state = "moon-green"
		name = "X3"
		desc = "A nearby Earthlike moon orbiting the gas giant. Steady intake of icy debris from the giant's ring system feeds moisture into the shallow, chilly atmosphere."

	x5
		icon_state = "moon-chunky"
		name = "X5"
		desc = "A nearby Earthlike moon orbiting the gas giant. The stormy, humid atmosphere is quite breathable and the surface has been extensively seeded by terraforming efforts."

	x4
		icon = 'icons/obj/160x160.dmi'
		icon_state = "bigasteroid_1"
		name = "X4"
		desc = "A jagged little moonlet or a really big asteroid. It's fairly close to your orbit, you can see the lights of Outpost Kappa."

	x0
		icon = 'icons/misc/1024x1024.dmi'
		icon_state = "plasma_giant"
		name = "X0"
		desc = "Your neighborhood plasma giant, a fair bit larger than Jupiter. The atmosphere is primarily composed of volatile FAAE. Little can be discerned of the denser layers below the plasma storms."

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
	anchored = 1
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
	anchored = 2

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
	anchored = 1

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
	anchored = 1

	vent2
		icon_state = "vent2"
	vent3
		icon_state = "vent3"

obj/decoration/ceilingfan
	name = "ceiling fan"
	desc = "It's actually just kinda hovering above the floor, not actually in the ceiling. Don't tell anyone."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "detectivefan"
	anchored = 1
	layer = EFFECTS_LAYER_BASE

/obj/decoration/candles
	name = "wall mounted candelabra"
	desc = "It's a big candle."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "candles-unlit"
	density = 0
	anchored = 2
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

	proc/update_icon()
		if (src.lit == 1)
			src.icon_state = src.icon_on
			light.enable()

		else
			src.lit = 0
			src.icon_state = src.icon_off
			light.disable()

	attackby(obj/item/W as obj, mob/user as mob)
		if (!src.lit)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				boutput(user, "<span class='alert'><b>[user]</b> casually lights [src] with [W], what a badass.</span>")
				src.lit = 1
				update_icon()

			if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				boutput(user, "<span class='alert'>Did [user] just light \his [src] with [W]? Holy Shit.</span>")
				src.lit = 1
				update_icon()

			if (istype(W, /obj/item/device/igniter))
				boutput(user, "<span class='alert'><b>[user]</b> fumbles around with [W]; a small flame erupts from [src].</span>")
				src.lit = 1
				update_icon()

			if (istype(W, /obj/item/device/light/zippo) && W:on)
				boutput(user, "<span class='alert'>With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")
				src.lit = 1
				update_icon()

			if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				boutput(user, "<span class='alert'><b>[user] lights [src] with [W].</span>")
				src.lit = 1
				update_icon()

			if (W.burning)
				boutput(user, "<span class='alert'><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
				src.lit = 1
				update_icon ()

	attack_hand(mob/user as mob)
		if (src.lit)
			var/fluff = pick("snuff", "blow")
			src.lit = 0
			update_icon()
			user.visible_message("<b>[user]</b> [fluff]s out the [src].",\
			"You [fluff] out the [src].")


	disposing()
		if (light)
			light.dispose()
		..()

/obj/decoration/rustykrab
	name = "rusty krab sign"
	desc = "It's one of those old neon signs that diners used to have."
	icon_state = "rustykrab"
	icon = 'icons/obj/64x32.dmi'
	density = 0
	opacity = 0
	anchored = 2

/obj/decoration/bookcase
	name = "bookcase"
	desc = "It's a bookcase. Full of books."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "bookcase"
	anchored = 2
	density = 0
	layer = DECAL_LAYER

/obj/decoration/toiletholder
	name = "toilet paper holder"
	desc = "Why would you even need this when there's no..?"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "toiletholder"
	anchored = 1
	density = 0

/obj/decoration/tabletopfull
	name = "tabletop shelf"
	desc = "It's a shelf full of things that you'll need to play your favourite tabletop campaigns. Mainly a lot of dice that can only roll 1's."
	icon_state = "tabletopfull"
	icon = 'icons/obj/64x32.dmi'
	anchored = 2
	density = 0
	layer = DECAL_LAYER

/obj/decoration/syndiepc
	name = "syndicate computer"
	desc = "It looks rather sinister with all the red text. I wonder what does it all mean?"
	anchored = 2
	density = 1
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndiepc1"

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
	anchored = 2
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
	anchored = 2
	density = 0
	opacity = 0
	icon = 'icons/obj/decoration.dmi'
	icon_state = "collapsedwall"

/obj/decoration/ntcratesmall
	name = "metal crate"
	anchored = 2
	density = 1
	desc = "A tightly locked metal crate."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "ntcrate"

/obj/decoration/ntcrate
	name = "metal crate"
	anchored = 2
	density = 1
	desc = "Assortment of two metal crates, both of them sealed shut."
	icon = 'icons/obj/32x64.dmi'
	icon_state = "ntcrate1"
	layer = EFFECTS_LAYER_1
	appearance_flags = TILE_BOUND
	bound_height = 32
	bound_width = 32

	ntcrate2
		icon_state = "ntcrate2"

/obj/decoration/weirdmark
	name = "weird mark"
	anchored = 2
	icon = 'icons/obj/decoration.dmi'
	icon_state = "weirdmark"

/obj/decoration/frontwalldamage
	anchored = 2
	icon = 'icons/obj/decoration.dmi'
	icon_state = "frontwalldamage"

/obj/decoration/damagedchair
	anchored = 2
	icon = 'icons/obj/decoration.dmi'
	icon_state = "damagedchair"

/obj/decoration/syndcorpse5
	anchored = 2
	name = "syndicate corpse"
	icon = 'icons/obj/decoration.dmi'
	desc = "Whoever this was, you're pretty sure they've had better days. Makes you wonder where the other half is.."
	icon_state = "syndcorpse5"

/obj/decoration/syndcorpse10
	anchored = 2
	name = "syndicate corpse"
	icon = 'icons/obj/decoration.dmi'
	desc = "... Oh, there it is."
	icon_state = "syndcorpse10"

/obj/decoration/bullethole
	anchored = 2
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bhole"
	mouse_opacity = 0

	examine()
		return list()

/obj/decoration/plasmabullethole
	anchored = 2
	icon = 'icons/obj/decoration.dmi'
	icon_state = "plasma-bhole"
	mouse_opacity = 0

	examine()
		return list()
