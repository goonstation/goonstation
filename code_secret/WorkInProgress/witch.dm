// ALL THE THINGS FOR THE MIDSUMMER RP EVENT

ADMIN_INTERACT_PROCS(/obj/burning_barrel/bonfire, proc/light)
/obj/burning_barrel/bonfire
	name = "unlit bonfire"
	desc = "An unlit bonfire."
	icon = '+secret/icons/misc/32x64event.dmi'
	icon_state = "bonfire-unlit"
	bound_height = 48
	var/lit = FALSE

	New()
		..()
		light.disable()
		ClearAllParticles()

	attackby(obj/item/W, mob/user)
		if (lit)
			return ..()
		if (istype(W, /obj/item/match) && W:on)
			src.light()

	proc/light()
		if (lit)
			return
		name = "bonfire"
		desc = "A bonfire."
		icon_state = "bonfire-lit"
		lit = TRUE
		light.set_color(0.98, 0.38, 0.26)
		light.enable()
		UpdateParticles(new /particles/barrel_embers, "embers")
		var/particles/E = src.GetParticles("embers")
		E.lifespan = 8 SECONDS
		UpdateParticles(new /particles/barrel_smoke, "smoke")
		playsound(src, 'sound/effects/lit.ogg', 80, 0, 1)
		src.visible_message(SPAN_NOTICE("<b>[src] blazes to life!</b>"))

/obj/burning_barrel/bonfire/midsummer
	name = "pile of wood"
	desc = "A pile of wood, not quite yet large enough for a bonfire."
	icon_state = "bonfire-unlitsmall"

	attackby(obj/item/W, mob/user)
		if (!lit)
			if (istype(W, /obj/item/nature/wood/log/final))
				user.visible_message(SPAN_NOTICE("[user] places a final [W] on [src]."))
				name = "unlit bonfire"
				desc = "An unlit bonfire."
				icon_state = "bonfire-unlit"
			else
				user.visible_message(SPAN_NOTICE("[user] adds [W] to [src]."))
			user.u_equip(W)
			qdel(W)
		else
			if (tgui_alert(user, "Are you sure you'd like to offer [W] to the bonfire?", "Bonfire offering", list("Yes", "No")) != "Yes")
				return
			if (istype(W, /obj/item/reagent_containers/food/drinks))
				var/obj/item/reagent_containers/food/drinks/D = W
				if (!D.reagents.total_volume)
					boutput(user, SPAN_ALERT("[D] is empty!"))
					return
				user.visible_message(SPAN_NOTICE("<b>[user] splashes some [D.reagents.get_master_reagent_name()] into [src].</b>"))
				light.set_brightness(light.brightness - 0.005)
				SPAWN(1 SECOND)
					light.set_brightness(light.brightness + 0.005)
				D.reagents.clear_reagents()
			else
				user.u_equip(W)
				qdel(W)
				user.visible_message(SPAN_NOTICE("<b>[user] tosses [W] into [src].</b>"))
			if (istype(W, /obj/item/nature))
				light.set_brightness(light.brightness + 0.01)
			else
				light.set_brightness(light.brightness + 0.005)
			playsound(src, 'sound/effects/crackle3.ogg', 80, 0, 1)

ABSTRACT_TYPE(/obj/item/nature)
/obj/item/nature
	icon = '+secret/icons/obj/walp_witchobj.dmi'
	w_class = W_CLASS_TINY
	force = 5
	throwforce = 5
	throw_range = 15
	throw_speed = 3

ABSTRACT_TYPE(/obj/item/nature/wood)
/obj/item/nature/wood
	desc = "Perfect for starting fires."

/obj/item/nature/wood/log
	name = "log"
	icon_state = "woodlog"
	w_class = W_CLASS_NORMAL
	force = 10
	throwforce = 10
	throw_range = 8
	throw_speed = 1

/obj/item/nature/wood/log/final
	desc = "This log looks special."

/obj/item/nature/wood/twig
	name = "twig"
	icon_state = "woodtwig"

ABSTRACT_TYPE(/obj/item/nature/resin)
/obj/item/nature/resin
	name = "resin"

/obj/item/nature/resin/amber
	name = "amber"
	desc = "Fossilized tree resin."
	icon_state = "resin-ambsml"

/obj/item/nature/resin/frankincense
	desc = "An aromatic gold hued resin."
	icon_state = "resin-fcense"

/obj/item/nature/resin/myrrh
	desc = "An aromatic reddish-brown hued resin."
	icon_state = "resin-myrrh"

/obj/item/nature/resin/dragonsblood
	desc = "An aromatic red hued resin."
	icon_state = "resin-dblood"

/obj/item/nature/feather
	name = "feather"
	desc = "A feather, fallen."

	New()
		..()
		icon_state = "feather-[rand(1,2)]"

/obj/item/nature/fur
	name = "fur turf"
	desc = "A tuft of fur."
	icon_state = "furtuft"

/obj/item/nature/mushroom
	name = "mushroom"
	desc = "Magical, maybe."

	New()
		..()
		icon_state = "witchshroom-[rand(1,8)]"

/obj/item/nature/crystal
	name = "crystal"
	desc = "You can almost see yourself in its reflections."

	New()
		..()
		icon_state = "crystal-[rand(1,3)]"

ABSTRACT_TYPE(/obj/item/nature/flower)
/obj/item/nature/flower

/obj/item/nature/flower/waterlily
	name = "water lily"
	icon_state = "waterlily-p"
	desc = "A large freshwater flowering plant."

	New()
		..()
		if (prob(33))
			icon_state = "waterlily-w"

/obj/item/nature/flower/marigold
	name = "marsh marigold"
	icon_state = "marshmarigold"
	desc = "A bright yellow petaled flower."

/obj/item/nature/flower/lavender
	name = "lavender"
	icon_state = "lavender"
	desc = "An upright purple petaled flower with a soothing fragrance."

/obj/item/nature/flower/rose
	name = "wild rose"
	icon_state = "wildrose"
	desc = "A beautiful fuschia petaled flower with a soft fragrance."

/obj/item/nature/flower/daisy
	name = "daisy"
	icon_state = "daisy"
	desc = "A small white petaled flower."

/obj/item/nature/flower/clover
	name = "clover"
	icon_state = "clover-3leaf"
	desc = "This one has three leaves."

/obj/item/nature/flower/clover/lucky
	name = "lucky clover"
	icon_state = "clover-4leaf"
	desc = "This one has four leaves."

/obj/decoration/regallamp/floating
	name = "floating candelabra"

	New()
		..()
		animate_float(src)

/obj/item/dagger/witch
	name = "witch's dagger"
	desc = "A witch's dagger, used to cut herbs and inscribe candles, among other things."

	attack_hand(mob/user)
		if (user.job != "Witch")
			boutput(user, SPAN_ALERT("[src] slips right out of your hands."))
			return
		..()

/obj/item/clothing/gloves/ring/gold/witch
	name = "witch's ring"
	desc = "A ring, worn by a witch."
	cant_drop = TRUE
	cant_other_remove = TRUE
	cant_self_remove = TRUE

/obj/item/device/radio/headset/syndicate/enchanted
	name = "enchanted headset"
	desc = "It's been enchanted with magic."
	cant_other_remove = TRUE

/obj/shrub/berry
	name = "berry bush"
	icon_state = "bush"
	max_uses = 10
	spawn_chance = 50
	override_default_behaviour = TRUE

	New()
		..()
		src.pixel_x = rand(-10, 10)
		src.pixel_y = rand(-10, 10)

/obj/shrub/berry/blackberry
	additional_items = list(/obj/item/reagent_containers/food/snacks/plant/raspberry/blackberry)

/obj/shrub/berry/raspberry
	additional_items = list(/obj/item/reagent_containers/food/snacks/plant/raspberry,\
	/obj/item/reagent_containers/food/snacks/plant/raspberry/blueraspberry)

/obj/shrub/berry/blueberry
	additional_items = list(/obj/item/reagent_containers/food/snacks/plant/blueberry)

/obj/shrub/berry/strawberry
	additional_items = list(/obj/item/reagent_containers/food/snacks/plant/strawberry)

/datum/job/special/witch
	name = "Witch"
	limit = 0
	change_name_on_spawn = TRUE
	slot_card = null
	slot_belt = null
	slot_jump = list(/obj/item/clothing/under/shorts/black)
	slot_suit = list(/obj/item/clothing/suit/wizrobe/necro)
	slot_head = list(/obj/item/clothing/head/wizard/witch)
	slot_ears = list(/obj/item/device/radio/headset/syndicate/enchanted)
	slot_glov = list(/obj/item/clothing/gloves/ring/gold/witch)
	slot_foot = list(/obj/item/clothing/shoes/sandal/magic/wizard)
	slot_back = list(/obj/item/storage/backpack/satchel/brown)
	slot_poc1 = list(/obj/item/dagger/witch)

#ifdef MAP_OVERRIDE_EVENT
	special_spawn_location = LANDMARK_SYNDICATE
#endif

	special_setup(var/mob/living/carbon/human/M)
		..()
		if (!M)
			return
		var/datum/abilityHolder/witch/W = M.add_ability_holder(/datum/abilityHolder/witch)
		W.addAbility(/datum/targetable/witch/restore)
		W.addAbility(/datum/targetable/witch/summon_sustenance)
		W.addAbility(/datum/targetable/witch/mystic_rain)
		// W.addAbility(/datum/targetable/witch/set_home)
		// W.addAbility(/datum/targetable/witch/travel_home)
		// W.addAbility(/datum/targetable/witch/travel_home/venture_out)
		W.addAbility(/datum/targetable/witch/teleport_home)
		W.addAbility(/datum/targetable/witch/teleport_home/venture_out)

/datum/abilityHolder/witch
	tabName = "Witch"
	var/turf/home
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.attach(owner)

	disposing()
		..()
		light.disable()
		light.detach()
		light = null

	proc/glow(color, time)
		light.enable()
		var/list/rgb =  rgb2num(color)
		light.set_color(rgb[1] / 255, rgb[2] / 255, rgb[3] / 255)
		SPAWN(time)
			light.disable()

/datum/targetable/witch
	preferred_holder_type = /datum/abilityHolder/witch
	var/sfx

	cast()
		. = ..()
		playsound(holder.owner, sfx, 80, 0, 1)

/datum/targetable/witch/restore
	name = "Restore"
	desc = "Fully heal and revive your target."
	icon_state = "spellshield"
	targeted = TRUE
	cooldown = 2 MINUTES
	start_on_cooldown = TRUE
	sfx = 'sound/effects/magic1.ogg'

	cast(mob/target)
		if (!istype(target))
			return TRUE
		..()
		var/datum/abilityHolder/witch/W = holder
		W.glow("#51c963", 1.8 SECONDS)
		holder.owner.visible_message("<span style=\"color:#51c963\"><b>[holder.owner] glows a soothing green.</b></span>")
		target.full_heal()

/datum/targetable/witch/summon_sustenance
	name = "Summon Sustenance"
	desc = "Summon some sustenance."
	icon_state = "pandemonium"
	cooldown = 20 SECONDS
	start_on_cooldown = TRUE
	sfx = 'sound/effects/magic2.ogg'
	var/options = list(/obj/item/reagent_containers/food/snacks/plant/glowfruit,\
	/obj/item/reagent_containers/food/snacks/plant/apple,\
	/obj/item/reagent_containers/food/snacks/plant/grapefruit,\
	/obj/item/reagent_containers/food/snacks/plant/melonslice,\
	/obj/item/reagent_containers/food/snacks/plant/grape,\
	/obj/item/reagent_containers/food/snacks/plant/grape/green,\
	/obj/item/reagent_containers/food/snacks/plant/peach,\
	/obj/item/reagent_containers/food/snacks/plant/orange,\
	/obj/item/reagent_containers/food/snacks/plant/pear,\
	/obj/item/reagent_containers/food/snacks/plant/cherry,\
	/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/sane)

	cast()
		..()
		var/datum/abilityHolder/witch/W = holder
		W.glow("#e39532", 1.3 SECONDS)
		holder.owner.visible_message("<span style=\"color:#e39532\"><b>[holder.owner] glows a comforting orange.</b></span>")
		var/snack
		for(var/i = 1 to 5)
			snack = pick(options)
			var/obj/O = new snack
			O.set_loc(get_step(holder.owner, pick(alldirs)), 1, 1)
			O.Scale(0,0)
			animate(O, transform = matrix(), time = 1.5 SECONDS, easing = ELASTIC_EASING)
			sleep(0.2 SECONDS)

/datum/targetable/witch/mystic_rain
	name = "Mystic Rain"
	desc = "Call upon some mystic rain."
	icon_state = "prismspray"
	targeted = TRUE
	cooldown = 30 SECONDS
	start_on_cooldown = TRUE
	target_anything = TRUE
	sfx = 'sound/effects/magic3.ogg'

	cast(atom/target)
		..()
		var/datum/abilityHolder/witch/W = holder
		W.glow("#0ed0e6", 2 SECONDS)
		holder.owner.visible_message("<span style=\"color:#0ed0e6\"><b>[holder.owner] glows a steady blue.</b></span>")
		var/list/projs = list()
		for(var/i = 1 to 8)
			var/pick = pick(/datum/projectile/energy_bolt/pulse/magical, /datum/projectile/energy_bolt/magical, /datum/projectile/laser/light/magical)
			var/obj/P = initialize_projectile_pixel_spread(holder.owner, new pick, target)
			P.pixel_x = rand(-10, 10)
			P.pixel_y = rand(-10, 10)
			P.set_loc(get_step(holder.owner, pick(alldirs)), 1, 1)
			P.Scale(0,0)
			animate(P, transform = matrix(), time = 1.5 SECONDS, easing = ELASTIC_EASING)
			animate_levitate(P)
			projs += P
			sleep(0.2 SECONDS)
		for(var/obj/projectile/P in projs)
			P.launch()
			sleep(0.1 SECONDS)
		if (istype(target, /obj/burning_barrel/bonfire))
			var/obj/burning_barrel/bonfire/B = target
			if (B.lit)
				return
			B.light()

/datum/projectile/energy_bolt/pulse/magical
	name = "magical energy"
	icon_state = "pulse2"
	shot_sound = null
	stun = 50
	hit_ground_chance = 100
	window_pass = TRUE
	strong = TRUE

/datum/projectile/energy_bolt/magical
	name = "magical energy"
	icon_state = "pulse2"
	shot_sound = null
	stun = 50
	hit_ground_chance = 100
	window_pass = TRUE

/datum/projectile/laser/light/magical
	name = "magical energy"
	icon_state = "pulse2"
	shot_sound = null
	damage = 50
	hit_ground_chance = 100
	window_pass = TRUE

/datum/projectile/special/homing/travel/witch
	name = "apparition"
	icon_state = "pulse"
	brightness = 1
	color_red = 0.5
	color_green = 0.54
	color_blue = 0.98
	shot_sound = null

	on_hit(atom/hit, direction, var/obj/projectile/P)
		if (hit == P.target)
			P.die()

	tick(var/obj/projectile/P)
		..()
		if (get_turf(P) == P.target)
			P.die()

	on_end(var/obj/projectile/P)
		if (("owner" in P.special_data) && P.proj_data == src)
			var/mob/M = P.special_data["owner"]
			if (M.loc == P)
				M.set_loc(get_turf(P))

/datum/targetable/witch/set_home
	name = "Set Home"
	desc = "Set your home."
	icon_state = "warp"
	cooldown = 0
	targeted = TRUE
	target_anything = TRUE
	interrupt_action_bars = FALSE
	do_logs = FALSE

	cast(atom/target)
		var/datum/abilityHolder/witch/W = holder
		target = get_turf(target)

		if (istype(target, /turf/unsimulated/wall) || isrestrictedz(target.z))
			boutput(holder.owner, SPAN_ALERT("You cannot set your home there."))
			return TRUE

		. = ..()
		var/datum/targetable/witch/travel_home/TH = W.getAbility(/datum/targetable/witch/travel_home)
		TH.home = target
		boutput(holder.owner, SPAN_NOTICE("You set your home to [target]."))

/datum/targetable/witch/travel_home
	name = "Travel Home"
	desc = "Travel back home."
	icon_state = "teleport"
	cooldown = 2 MINUTES
	start_on_cooldown = TRUE
	sfx = 'sound/effects/magic4.ogg'
	var/turf/home

	cast()
		var/datum/abilityHolder/witch/W = holder
		if (!src.home)
			boutput(holder.owner, SPAN_ALERT("You have no home set."))
			return TRUE
		else if (!isturf(holder.owner.loc))
			boutput(holder.owner, SPAN_ALERT("You must be on a turf to use this spell."))
			return TRUE
		..()
		W.locked = TRUE
		W.glow("#ae81fd", 3.3 SECONDS)
		holder.owner.visible_message("<span style=\"color:#ae81fd\"><b>[holder.owner] glows a calm purple.</b></span>")
		animate(holder.owner, alpha = 0, time = 3.3 SECONDS, easing = LINEAR_EASING)
		SPAWN(3.3 SECONDS)
			var/obj/projectile/proj = initialize_projectile_pixel_spread(holder.owner, new /datum/projectile/special/homing/travel/witch, src.home)
			var/tries = 5
			while (tries > 0 && (!proj || proj.disposed))
				proj = initialize_projectile_pixel_spread(holder.owner, new /datum/projectile/special/homing/travel/witch, src.home)

			proj.special_data["owner"] = holder.owner
			proj.target = src.home
			proj.targets = list(src.home)

			proj.launch()
			holder.owner.alpha = 255

			W.locked = FALSE

/datum/targetable/witch/travel_home/venture_out
	name = "Venture Out"
	desc = "Venture out into the unknown."
	icon_state = "blink"

	cast()
#ifdef MIDSUMMER
		src.home = locate(rand(10, 290), rand(10, 290), 1)
#else
		if (get_z(src.holder.owner) != Z_LEVEL_STATION)
			boutput(holder.owner, SPAN_ALERT("You are already far from home!"))
			return TRUE
		var/frustration = 0
		while (frustration < 10)
			var/list/teleareas = get_teleareas()
			var/area/area = teleareas[pick(teleareas)]
			if (area.z == Z_LEVEL_STATION)
				var/turf/T = get_turf(pick(area.contents))
				if (isfloor(T) && !is_blocked_turf(T))
					src.home = T
					break
			frustration++

#endif
		..()

/datum/targetable/witch/teleport_home/venture_out
	name = "Teleport Out"
	desc = "Teleport out."
	icon_state = "blink"

	cast()
		src.home = locate(rand(10, 290), rand(10, 290), 1)
		..()

/datum/targetable/witch/teleport_home
	name = "Teleport Home"
	desc = "Teleport back home."
	icon_state = "teleport"
	cooldown = 2 MINUTES
	start_on_cooldown = TRUE
	sfx = 'sound/effects/magic4.ogg'
	var/turf/home

	cast()
		var/datum/abilityHolder/witch/W = holder
		if (!isturf(holder.owner.loc))
			boutput(holder.owner, SPAN_ALERT("You must be on a turf to use this spell."))
			return TRUE
		..()
		W.locked = TRUE
		W.glow("#ae81fd", 3.3 SECONDS)
		holder.owner.visible_message("<span style=\"color:#ae81fd\"><b>[holder.owner] glows a calm purple.</b></span>")
		animate(holder.owner, alpha = 0, time = 3.3 SECONDS, easing = LINEAR_EASING)
		animate_teleport_wiz(holder.owner)
		if (!home)
			home = pick_landmark(LANDMARK_SYNDICATE)
		playsound(home, sfx, 40, 0, 1)
		holder.owner.set_loc(home)

/datum/targetable/witch/summon_sun
	name = "Summon Sun"
	desc = "Yes, summon the sun."
	icon_state = "fireball"
	cooldown = 10 MINUTES
	sfx = 'sound/misc/dreamy.ogg'

	cast()
		..()
		var/datum/abilityHolder/witch/W = holder
		W.glow("#ed6386", 10 SECONDS)
		holder.owner.visible_message("<span style=\"color:#ed6386\"><b>[holder.owner] glows an auspicious rose.</b></span>")
		var/turf/T = pick_landmark(LANDMARK_SUMMON)
		var/obj/the_sun/TS = new /obj/the_sun
		TS.light.disable()
		TS.Scale(0,0)
		TS.set_loc(T)
		animate(TS, transform = matrix(), time = 10 SECONDS, easing = LINEAR_EASING)
		SPAWN(10 SECONDS)
			animate_spin(TS, "R", 150, -1, FALSE)
		TS.light.attach(TS, 2.5, 2.5)
		TS.light.set_brightness(2)
		TS.light.set_height(3)
		TS.light.set_color(0.9, 0.5, 0.3)
		TS.light.enable()
		W.removeAbility(src)

/proc/setup_for_event()
	// Irradiate the station
	for (var/area/station/S in world)
		if (S.do_not_irradiate || (S.z != Z_LEVEL_STATION))
			continue
		if (!S.irradiated)
			S.irradiated = 0.1
			S.UpdateIcon()
		// Break the lights
		for (var/obj/machinery/light/L in S)
			L.do_burn_out()
		LAGCHECK(LAG_LOW)
	// Disable the power
	for (var/obj/machinery/power/apc/C in machine_registry[MACHINES_POWER])
		if(C.cell && C.z == 1)
			C.cell.charge = 0
	for (var/obj/machinery/power/smes/S in machine_registry[MACHINES_POWER])
		if (istype(get_area(S), /area/station/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.UpdateIcon()
		S.power_change()

/area/crash
	name = "Crash Site"
	icon_state = "red"
	permarads = TRUE
	irradiated = 0.1

/area/planet
	name = "Planet Surface"
	icon_state = "green"
	requires_power = FALSE
	sound_environment = 4
	teleport_blocked = 1
	filler_turf = "/turf/unsimulated/floor/auto/grass/swamp_grass"
	ambient_light = rgb(221 * 1.00, 230 * 1.00, 255 * 1.00)

/area/planet/inside
	name = "Inside"
	icon_state = "purple"
	ambient_light = null

/area/planet/liminal
	name = "Liminal Space"
	icon_state = "blue"
	ambient_light = rgb(255 * 0.90, 146 * 0.90,  39 * 0.90)

/turf/unsimulated/floor/auto/grass/clover
	name = "clover"
	desc = "A patch of clover."
	icon = '+secret/icons/turf/walp_witchturf.dmi'
	icon_state = "clovergrass-3leaf"
	var/clover_type = /obj/item/nature/flower/clover

	attack_hand(mob/user)
		..()
		boutput(user, SPAN_NOTICE("You pick out a clover from the clover patch."))
		user.put_in_hand_or_drop(new clover_type(src))

/turf/unsimulated/floor/auto/grass/clover/lucky
	icon_state = "clovergrass-4leaf"
	clover_type = /obj/item/nature/flower/clover/lucky

/turf/unsimulated/wall/sunset
	name = "sunset"
	desc = "Eerie."
	icon = '+secret/icons/turf/walp_witchturf.dmi'
	icon_state = "sunsetsky-01"
	opacity = 0

/obj/fakeobject/stars
	name = "stars"
	desc = "Stars."
	icon = '+secret/icons/turf/walp_witchturf.dmi'
	icon_state = "sunsetstars-01"
	opacity = 0
	density = 0
	anchored = TRUE

/obj/decal/mushrooms/walp
	icon = '+secret/icons/obj/walp_witchobj.dmi'

	New()
		..()
		icon_state = "witchshroom-[rand(1,8)]"
