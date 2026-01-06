// im pali

//bonk 2


// Pill of sheltestgrog for my office

/obj/item/reagent_containers/pill/sheltestgrog
	name = "pill"
	New()
		. = ..()
		src.reagents.add_reagent("sheltestgrog", 100)



// Gun that shoots Securitrons

/obj/item/ammo/bullets/beepsky
	sname = "Beepsky"
	name = "beepsky box"
	desc = "A box of large Beepsky-shaped bullets"
	icon_state = "lmg_ammo"
	amount_left = 10
	max_amount = 10
	ammo_type = new/datum/projectile/special/spawner/beepsky

	ammo_cat = AMMO_BEEPSKY
	icon_dynamic = 1
	icon_short = "lmg_ammo"
	icon_empty = "lmg_ammo-0"

/obj/item/gun/kinetic/beepsky
	name = "\improper Loose Cannon"
	desc = "Gets the job done."
	icon = 'icons/obj/items/guns/toy.dmi'
	icon_state = "buff_airzooka"
	color = "#555555"
	force = 5
	ammo_cats = list(AMMO_BEEPSKY)  // hell if I know
	max_ammo_capacity = 100
	auto_eject = 0

	flags =  TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = W_CLASS_BULKY

	New()
		ammo = new/obj/item/ammo/bullets/beepsky
		set_current_projectile(new/datum/projectile/special/spawner/beepsky)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.4)

	afterattack(atom/A, mob/user as mob)
		if(istype(A, /obj/machinery/bot/secbot))
			src.ammo.amount_left += 1
			user.visible_message(SPAN_ALERT("[user] loads \the [A] into \the [src]."), SPAN_ALERT("You load \the [A] into \the [src]."))
			qdel(A)
			return
		else
			..()

/obj/item/gun/kinetic/beepsky/one_bullet
	New()
		. = ..()
		src.ammo.amount_left = 1
		src.ammo.max_amount = 1








// Untitled Goose Game memes

/datum/limb/thief
	harm(atom/target, var/mob/living/user)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = target
			var/list/slots = list()
			for(var/slot in all_slots)
				if(M.get_slot(slot))
					slots.Add(slot)
			if(!slots)
				return
			actions.start(new/datum/action/bar/icon/otherItem(user, M, user.equipped(), pick(slots)) , user)
		else
			. = ..()

/mob/living/critter/small_animal/bird/goose/asshole
	name = "untitled goose"
	real_name = "untitled goose"
	desc = "An offshoot species of <i>branta canadensis</i> adapted for being a jerk."
	icon_state = "untitled"
	icon_state_dead = "untitled-dead"
	speech_verb_say = "honks"
	speech_verb_exclaim = "calls"
	speech_verb_ask = "warbles"
	speech_verb_gasp = "mumbles"
	speech_verb_stammer = "cackles"
	death_text = "%src% lets out a final weak honk and keels over."
	feather_color = list("#f2ebd5","#ffffff")
	flags = null
	fits_under_table = 1
	good_grip = 1
	bird_call_msg = "honks"
	bird_call_sound = 'sound/voice/animal/goose.ogg'
	health_brute = 50
	health_burn = 50
	add_abilities = list(/datum/targetable/critter/peck,
						/datum/targetable/critter/tackle)
	blood_id = "crime"
	player_can_spawn_with_pet = FALSE

	New(loc, nspecies)
		..()
		// apparently the fact that blood_id is crime and the goose adds crime to itself means that it bloodgibs nowadays eventually...
		APPLY_ATOM_PROPERTY(src, PROP_MOB_BLOODGIB_IMMUNE, src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new/datum/limb/thief

	proc/fix_pulling_sprite()
		if(src.pulling)
			src.icon_state = "untitled-pull"
		else
			src.icon_state = initial(src.icon_state)

	Life(datum/controller/process/mobs/parent)
		. = ..()
		if (!isdead(src))
			src.reagents.add_reagent("crime", 10)
			src.fix_pulling_sprite() // just in case

	set_pulling(atom/movable/A)
		. = ..()
		src.fix_pulling_sprite()

	hotkey(name)
		. = ..()
		src.fix_pulling_sprite()

	bump(atom/movable/AM as mob|obj)
		. = ..()
		src.fix_pulling_sprite()

	Move(atom/NewLoc, direct)
		. = ..()
		if(src.pulling)
			src.set_dir(turn(get_dir(src, src.pulling), 180))


// For when you want a turf to have maptext attached on it in a dmm

/obj/maptext_spawner
	var/loc_maptext = ""
	var/loc_maptext_width = 32
	var/loc_maptext_height = 32
	var/loc_maptext_x = 0
	var/loc_maptext_y = 0
	New()
		..()
		SPAWN(0)
			loc.maptext = loc_maptext
			loc.maptext_width = loc_maptext_width
			loc.maptext_height = loc_maptext_height
			loc.maptext_x = loc_maptext_x
			loc.maptext_y = loc_maptext_y
			qdel(src)


// I'm archiving a slightly improved version of the hell portal which is now gone

/obj/hellportal
	name = "hell portal"
	desc = "This looks bad."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whole-massive"
	pixel_x = -16
	pixel_y = -16
	var/number_left = 5
	var/critter_type = /mob/living/critter/zombie

/obj/hellportal/New()
	..()
	src.transform = matrix() * 0
	animate(src, transform = matrix(), time = 1 SECOND, easing = SINE_EASING)
	SPAWN(1 SECOND)
		new /obj/effects/void_break(src.loc)
		sleep(0.5 SECONDS)
		critter_spam()

/obj/hellportal/ex_act(severity) // avoid void_break self-destruction

/obj/hellportal/proc/critter_spam()
	for(var/I = 1 to src.number_left)
		var/atom/zomb = new src.critter_type(src.loc)
		zomb.alpha = 0
		animate(zomb, alpha = 255, time = 1 SECOND, easing = SINE_EASING)
		src.visible_message(SPAN_ALERT("<b> \The [zomb] emerges from \the [src]!</b>"))
		sleep(2.5 SECONDS)
		if(zomb.loc == src.loc)
			step(zomb, pick(alldirs))
	animate(src, transform = matrix() * 0, time = 1 SECOND, easing = SINE_EASING)
	sleep(1 SECOND)
	qdel(src)


// ray filter experiments

/obj/effect/ray_light_source
	mouse_opacity = 0
	plane = PLANE_LIGHTING
	layer = LIGHTING_LAYER_BASE
	blend_mode = BLEND_ADD
	appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM // PIXEL_SCALE omitted intentionally
	var/ray_density = 3
	var/shift_x = 0
	var/shift_y = 0

	New()
		..()
		add_filter("rays", 1, rays_filter(size=64, density=src.ray_density, factor=1, offset=rand(1000), threshold=0, color=src.color, x=shift_x, y=shift_y))

		var/f = src.get_filter("rays")
		animate(f, offset=f:offset + 100, time=5 MINUTES, easing=LINEAR_EASING, flags=ANIMATION_PARALLEL, loop=-1)


// A candle with fancy animated spooky lighting

/obj/item/strange_candle
	name = "strange candle"
	desc = "It's a strange candle."
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	var/obj/effect/ray_light_source/light

	New()
		. = ..()
		light = new/obj/effect/ray_light_source{color="#ffcc77"; shift_y=6; shift_x=2}(src)
		src.vis_contents += light

	set_loc(newloc)
		var/oldloc = src.loc
		. = ..()
		if(istype(src.loc, /turf) && !istype(oldloc, /turf))
			var/turf/T = oldloc
			T.vis_contents -= light
			src.vis_contents += light
		else if(istype(src.loc, /mob))
			var/mob/M = src.loc
			M.vis_contents += light
			src.vis_contents -= light

	disposing()
		if(istype(src.loc, /mob))
			var/mob/M = src.loc
			M.vis_contents -= light
		src.vis_contents -= light
		light.dispose()
		..()


// Katamari mob critter

/mob/living/critter/katamari
	name = "space thing"
	desc = "Some kinda thing, from space. In space. A space thing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "thing"
	custom_gib_handler = /proc/gibs // TODO
	density = 0
	hand_count = 0
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	speech_verb_say = "rattles"
	speech_verb_exclaim = "rattles"
	speech_verb_ask = "rattles"
	flags = TABLEPASS
	fits_under_table = 1
	blood_id = "iron"
	metabolizes = 0
	var/size = 0
	var/obj/item/implant/access/access
	var/obj/item/last_item_bump
	var/can_grab_mobs = TRUE

	New()
		. = ..()
		access = new /obj/item/implant/access(src)
		access.uses = -1

	bump(atom/movable/AM, yes = 1)
		. = ..()
		if(src.contents && !istype(AM, /obj/table) && !ON_COOLDOWN(src, "bump_attack", 0.5 SECONDS))
			var/obj/item/I = pick(src.contents)
			if(istype(I))
				src.last_item_bump = I
				SPAWN(0)
					src.weapon_attack(AM, I, 1)

	death(gibbed)
		src.vis_contents = null
		var/list/turf/targets = list()
		for(var/turf/T in view(8, src))
			targets += T
		var/list/atom/movable/to_densify = list()
		for(var/atom/movable/AM in src)
			if(istype(AM, /atom/movable/screen))
				continue
			AM.transform = null
			AM.set_loc(get_turf(src))
			if(AM.density)
				to_densify += AM
			AM.set_density(0)
			AM.throw_at(pick(targets), rand(1, 10), rand(1, 15), allow_anchored=TRUE)
		. = ..()
		SPAWN(1 SECOND)
			for(var/atom/movable/AM in to_densify)
				AM.set_density(TRUE)
			src.transforming = 1
			src.canmove = 0
			src.icon = null
			APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)
			if (src.mind || src.client)
				src.ghostize()
			qdel(src)

	equipped()
		return src.last_item_bump

	Move(NewLoc, direct)
		var/turf/new_turf = NewLoc
		var/turf/old_turf = src.loc
		var/matrix/M = src.transform
		if(istype(new_turf) && istype(old_turf) && (old_turf.x < new_turf.x || old_turf.x == new_turf.x && old_turf.y > new_turf.y))
			M.Turn(90)
		else
			M.Turn(-90)
		animate(src, transform=M, time=src.base_move_delay)
		if(size > 120 && istype(new_turf, /turf/simulated/floor))
			var/turf/simulated/floor/floor = new_turf
			floor.pry_tile(src.equipped(), src)
		var/found = 0
		for(var/atom/movable/AM in new_turf)
			if(istype(AM, /obj/overlay) || istype(AM, /obj/effect) || istype(AM, /obj/effects))
				continue
			if(AM.invisibility >= INVIS_GHOST)
				continue
			var/obj/item/I = AM
			if(size < 60 && (!istype(AM, /obj/item) || I.w_class > size / 10 + 1))
				continue
			if(size < 90 && AM.anchored)
				continue
			if(size < 120 && AM.density)
				continue
			if(size < 140 && ismob(AM) || !can_grab_mobs)
				continue
			if(istype(I, /obj/item/card/id))
				var/obj/item/card/id/id = I
				src.access.access.access |= id.access // access
			AM.set_loc(src)
			src.vis_contents += AM
			AM.pixel_x = 0
			AM.pixel_y = 0
			var/matrix/tr = new
			tr.Turn(rand(360))
			tr.Translate(sqrt(size) * 3 / 2, sqrt(size) * 3)
			tr.Turn(rand(360))
			AM.transform = tr
			size += 0.3
			found = 1
			break
		if(size > 180 && !found && new_turf.density && !isrestrictedz(new_turf.z) && prob(20))
			new_turf.ex_act(prob(1) ? 1 : 2)
		. = ..()

	setup_healths()
		add_hh_robot(150, 1.15)


// A belt which gives you big muscles (visual only)

/obj/item/storage/belt/muscly
	name = "muscly belt"
	desc = "Probably made out of steroids or something."
	icon_state = "machobelt"
	item_state = "machobelt"
	var/muscliness_factor = 7

	equipped(var/mob/user)
		..()
		user.add_filter("muscly", 1, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "muscly"), size=0))
		animate(user.get_filter("muscly"), size=src.muscliness_factor, time=1 SECOND, easing=SINE_EASING)

	unequipped(var/mob/user)
		..()
		animate(user.get_filter("muscly"), size=0, time=1 SECOND, easing=SINE_EASING)
		SPAWN(1 SECOND)
			user.remove_filter("muscly")


// Among Us memery

/obj/spawner/amongus_clothing
	var/cursed = FALSE

	New()
		. = ..()
		var/h = rand(360)
		var/s = rand() * 20 + 80
		var/v = rand() * 50 + 50
		var/suit_color = hsv2rgb(h, s, v)
		var/boots_color = hsv2rgb(h + rand(-30, 30), s, v * 0.8)
		var/col = color_mapping_matrix(
			list("#296C3F", "#CDCDD6", "#BC9800"),
			list("#5ea2a8", suit_color, boots_color)
		)
		var/obj/item/clothing/suit/hazard/bio_suit/suit = new(src.loc)
		var/obj/item/clothing/head/bio_hood/hood = new(src.loc)
		suit.color = col
		hood.color = col
		var/datum/color/base_color_datum = new
		base_color_datum.from_hex(suit_color)
		var/nearest_color_text = get_nearest_color(base_color_datum)
		suit.name = "[nearest_color_text] suit"
		hood.name = "[nearest_color_text] hood"
		suit.desc = "There's 1 impostor among us."
		hood.desc = "There's 1 impostor among us."
		if(src.cursed)
			suit.cant_other_remove = TRUE
			suit.cant_self_remove = TRUE
			hood.cant_other_remove = TRUE
			hood.cant_self_remove = TRUE
		var/mob/living/carbon/human/H = locate() in src.loc
		if(H)
			if(H.wear_suit)
				var/obj/item/old_suit = H.wear_suit
				H.u_equip(old_suit)
				old_suit.dropped(H)
				old_suit.set_loc(H.loc)
			if(H.head)
				var/obj/item/old_hat = H.head
				H.u_equip(old_hat)
				old_hat.dropped(H)
				old_hat.set_loc(H.loc)
			H.force_equip(suit, SLOT_WEAR_SUIT)
			H.force_equip(hood, SLOT_HEAD)
			boutput(H, SPAN_ALERT("There's 1 impostor among us.</alert>"))
		qdel(src)

/obj/spawner/amongus_clothing/cursed
	cursed = TRUE



/proc/populate_station(chance=100)
	for(var/job_name in job_start_locations)
		if(job_name == "AI" || job_name == "JoinLate")
			continue
		for(var/turf/T in job_start_locations[job_name])
			if(prob(chance))
				var/mob/living/carbon/human/normal/H = new(T)
				H.JobEquipSpawned(job_name)




/obj/storage/closet/extradimensional
	default_material = "negativematter"






proc/get_upscaled_icon(icon, icon_state, dx, dy)
	var/list/static/upscaled_icon_cache = null
	if(isnull(upscaled_icon_cache))
		upscaled_icon_cache = list()
	var/key = "[icon] [icon_state] [dx] [dy]"
	if(upscaled_icon_cache[key])
		return upscaled_icon_cache[key]
	var/icon/ic = icon(icon, icon_state)
	ic.Crop(world.icon_size / 2 * dx + 1, world.icon_size / 2 * dy + 1, world.icon_size / 2 * (dx + 1), world.icon_size / 2 * (dy + 1))
	ic.Scale(world.icon_size, world.icon_size)
	upscaled_icon_cache[key] = ic
	return ic

#ifdef UPSCALED_MAP
/turf/var/base_icon

/turf/proc/fix_upscale()
	var/dx = (src.x - 1) % 2
	var/dy = (src.y - 1) % 2
	var/icon_to_use = src.icon
	if(isnull(src.base_icon))
		src.base_icon = src.icon
	else
		icon_to_use = src.base_icon
	src.icon = get_upscaled_icon(icon_to_use, src.icon_state, dx, dy)

/turf/simulated/floor/update_icon()
	. = ..()
	fix_upscale()

/turf/unsimulated/floor/update_icon()
	. = ..()
	fix_upscale()

/turf/simulated/floor/New()
	..()
	fix_upscale()

/turf/unsimulated/floor/New()
	..()
	fix_upscale()
#endif



/// catball
/obj/item/basketball/catball
	name = "catball"
	icon_state = "catball"
	base_icon_state = "catball"
	spinning_icon_state = "catball"
	item_state = "catball"
	desc = "<img src='https://pali.link/catball.gif'><br>"
	contraband = 0 // catball is legal smh my head


ADMIN_INTERACT_PROCS(/obj/portal/to_space, proc/give_counter)
/obj/portal/to_space
	name = "unstable wormhole"
	desc = "It seems like this wormhole is unstable and you might land in a random place in space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	failchance = 0
	color = list(0.4, 0, 0,   0, 0.4, 0,   0, 0, 0.4)
	var/tele_throw_speed = 2
	var/living_mob_counter = 0

	proc/animate_self()
		animate_lag(src, magnitude=5, step_time_low=0.5 SECONDS, step_time_high=1 SECOND)

	New()
		. = ..()
		animate_self()

	teleport(atom/movable/AM)
		src.set_target(random_space_turf() || random_nonrestrictedz_turf())
		var/turf/throw_target = locate(rand(1, world.maxx), rand(1, world.maxy), src.target.z)
		. = ..()
		if (tele_throw_speed > 0)
			AM.throw_at(throw_target, INFINITY, tele_throw_speed)
		animate_self()
		if(isliving(AM) && AM.loc != src.loc)
			living_mob_counter++
			var/mob/living/L = AM
			for (var/mob/M in AIviewers(Center=src))
				if (M == L)
					boutput(M, SPAN_ALERT("You are sucked into \the [src]!"))
				else if (isadmin(M) && !M.client.player_mode)
					boutput(M, SPAN_ALERT("[L] ([key_name(L, admins=FALSE, user=M)]) is sucked into \the [src], landing <a href='byond://?src=\ref[M.client.holder];action=jumptocoords;target=[target.x],[target.y],[target.z]' title='Jump to Coords'>here</a>"))
				else
					boutput(M, SPAN_ALERT("[L] is sucked into \the [src]!"))

	proc/give_counter()
		set name = "give counter"
		var/turf/target_turf = get_step(src, NORTH)
		if (locate(/obj/machinery/maptext_monitor) in target_turf)
			return
		var/obj/machinery/maptext_monitor/counter = new(target_turf)
		counter.monitored = src
		counter.name = "wormhole visitors"
		counter.desc = "Could also be number of victims I guess!"
		counter.maptext_prefix = "<span class='c pixel sh'>Wormhole Visitors: <span class='xfont'>"
		counter.monitored_var = "living_mob_counter"
		counter.display_mode = "round"
		counter.update_delay = 1 SECOND
		counter.update_monitor()

/obj/portal/to_space/with_monitor
	New()
		. = ..()
		give_counter()


/mob/living/carbon/human/npc/monkey/extremely_fast
	blood_id = "triplemeth"
	var/fastness_factor = 5 //! Expected value of number of ai_process() calls per tick

	New()
		..()
		src.AddComponent(/datum/component/afterimage, 20, 0.03 SECONDS)
		src.name = "\proper extremely fast [src.name]"
		src.real_name = src.name

		var/datum/movement_modifier/mod = new
		mod.multiplicative_slowdown = 0.1
		src.movement_modifiers += mod

	ai_init()
		. = ..()
		src.ai_movedelay = 1
		src.ai_actiondelay = 1

	ai_process()
		. = ..()
		src.ai_actiondelay = 0

		if(prob(100 * (1 - 1 / src.fastness_factor)))
			SPAWN(0.2 SECONDS)
				src.ai_process()

ADMIN_INTERACT_PROCS(/obj/item/kitchen/utensil/knife/tracker, proc/set_target, proc/toggle_can_switch_target)
/obj/item/kitchen/utensil/knife/tracker
	name = "target tracker knife"
	icon_state = "tracking_knife"
	desc = "Poor man's pinpointer. Just stab someone to track where they are!"
	force = 4
	throwforce = 6
	var/can_switch_target = TRUE
	var/eye_open = FALSE

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		. = ..()
		if(can_switch_target)
			src.AddComponent(/datum/component/angle_watcher, target, base_transform=matrix())
		if (!src.eye_open)
			src.eye_open = TRUE
			src.icon_state = "tracking_knife_tracking"
			flick("tracking_knife_eye_open", src)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		. = ..()
		if(ismob(hit_atom) && can_switch_target)
			src.AddComponent(/datum/component/angle_watcher, hit_atom, base_transform=matrix())
		if (!src.eye_open)
			src.eye_open = TRUE
			src.icon_state = "tracking_knife_tracking"
			flick("tracking_knife_eye_open", src)

	clean_forensic()
		. = ..()
		if(can_switch_target)
			src.GetComponent(/datum/component/angle_watcher)?.RemoveComponent()
			animate(src, transform=null, time=2 SECONDS, flags=ANIMATION_PARALLEL, easing=ELASTIC_EASING)
			if (src.eye_open)
				src.eye_open = FALSE
				src.icon_state = "tracking_knife"
				flick("tracking_knife_eye_close", src)


	proc/set_target()
		set name = "Set Target"
		var/mob/target = usr.client.input_data(
				list(DATA_INPUT_REF, DATA_INPUT_MOB_REFERENCE, DATA_INPUT_REFPICKER),
				"Set Knife Tracking Target",
				"Select a target to track with this knife.")?.output
		if(target)
			src.AddComponent(/datum/component/angle_watcher, target, base_transform=matrix())
			src.icon_state = "tracking_knife_tracking"
		else
			src.GetComponent(/datum/component/angle_watcher)?.RemoveComponent()
			animate(src, transform=null, time=2 SECONDS, flags=ANIMATION_PARALLEL, easing=ELASTIC_EASING)
			src.icon_state = "tracking_knife"

	proc/toggle_can_switch_target()
		set name = "Toggle Target Switching"
		can_switch_target = !can_switch_target
		if(can_switch_target)
			boutput(usr, SPAN_NOTICE("Knife user can now stab someone else to track them."))
		else
			boutput(usr, SPAN_NOTICE("Knife user can no longer switch targets."))



/obj/spawner/knife_loop
	New()
		..()
		var/how_many_knives = tgui_input_number(usr, "How many knives to spawn?", "Knife loop", 2, 100, 2)
		var/list/obj/item/kitchen/utensil/knife/tracker/knives = list()
		for(var/i = 1 to how_many_knives)
			var/obj/item/kitchen/utensil/knife/tracker/knife = new(src.loc)
			knife.can_switch_target = FALSE
			if(i > 1)
				knife.AddComponent(/datum/component/angle_watcher, knives[i - 1], base_transform=matrix())
			knives += knife
		knives[1].AddComponent(/datum/component/angle_watcher, knives[how_many_knives], base_transform=matrix())
		qdel(src)



/obj/item/letter
	name = "letter"
	icon = 'icons/effects/letter_overlay.dmi'
	rand_pos = TRUE
	var/letter = null
	var/bg_color = null
	var/inhand = TRUE

	New()
		..()
		randomize_state(force=FALSE)

	afterattack(atom/target, mob/user, reach, params)
		. = ..()
		if(!isturf(target) || !islist(params) || !("icon-x" in params) || !("icon-y" in params))
			return
		user.drop_item(src)
		src.set_loc(target)
		var/px = text2num(params["icon-x"]) - 16
		var/py = text2num(params["icon-y"]) - 16
		var/turf_pixel_x = target.x * world.icon_size
		var/turf_pixel_y = target.y * world.icon_size
		px += turf_pixel_x
		py += turf_pixel_y
		px -= px % 10 - 5
		py -= py % 10 - 5
		px -= turf_pixel_x
		py -= turf_pixel_y
		src.pixel_x = px
		src.pixel_y = py

	proc/randomize_state(force=FALSE)
		if(isnull(letter) || force)
			letter = pick(global.uppercase_letters)
		if(isnull(bg_color) || force)
			bg_color = rgb(rand(0,255), rand(0,255), rand(0,255))
		UpdateIcon()
		UpdateName()

	UpdateName()
		. = ..()
		src.letter = uppertext(src.letter)
		src.name = "[name_prefix(null, 1)]letter [src.letter][name_suffix(null, 1)]"

	update_icon(...)
		. = ..()
		src.letter = uppertext(src.letter)
		src.icon_state = letter
		var/image/bg = image('icons/effects/letter_overlay.dmi', icon_state = "[letter]2")
		var/list/rgb_list = rgb2num(src.bg_color)
		var/c = 1 / 139
		bg.color = list(rgb_list[1]*c,0,0, 0,rgb_list[2]*c,0, 0,0,rgb_list[3]*c)
		src.underlays = list(bg)
		if(inhand)
			if(isnull(src.inhand_image))
				src.inhand_image = new
			var/image/inhand = image(src.icon, src.icon_state)
			inhand.underlays = list(bg)
			inhand.pixel_x = 11
			inhand.pixel_y = 11
			src.inhand_image.underlays = list(inhand)
		else
			src.inhand_image?.underlays = null

	onVarChanged(variable, oldval, newval)
		. = ..()
		src.UpdateIcon()
		src.UpdateName()

/obj/item/letter/traitor
	name = "letter T"
	bg_color = "#ff0000"
	letter = "T"

/obj/item/letter/vowel
	name = "vowel"
	randomize_state(force=FALSE)
		if(isnull(letter) || force)
			letter = pick(global.vowels_upper)
		..()

/obj/item/letter/consonant
	name = "consonant"
	randomize_state(force=FALSE)
		if(isnull(letter) || force)
			letter = pick(global.consonants_upper)
		..()

/obj/item/letter/scrabble_odds
	var/static/list/scrabble_weights = list(
		"A" = 9, "B" = 2, "C" = 2, "D" = 4, "E" = 12, "F" = 2, "G" = 3, "H" = 2, "I" = 9, "J" = 1, "K" = 1, "L" = 4, "M" = 2, "N" = 6, "O" = 8, "P" = 2,
		"Q" = 1, "R" = 6, "S" = 4, "T" = 6, "U" = 4, "V" = 2, "W" = 2, "X" = 1, "Y" = 2, "Z" = 1
	)

	randomize_state(force=FALSE)
		if(isnull(letter) || force)
			letter = weighted_pick(scrabble_weights)
		..()

/obj/machinery/vending/letters
	name = "LetterMatic"
	desc = "Good vibes, one letter at a time."
	icon_state = "letters"
	icon_panel = "standard-panel"
	icon_off = "standard-off"
	icon_broken = "standard-broken"
	icon_fallen = "standard-fallen"
	slogan_chance = 5
	slogan_list = list(
		"Can I get a vowel?"
	)
	pay = TRUE

	light_r = 0.5
	light_g = 0.6
	light_b = 0.2

	create_products(restocked)
		..()
		product_list += new/datum/data/vending_product(/obj/item/letter/scrabble_odds, amount=1, infinite=TRUE, cost=5)
		product_list += new/datum/data/vending_product(/obj/item/letter/vowel, amount=1, infinite=TRUE, cost=50)
		product_list += new/datum/data/vending_product(/obj/item/letter/consonant, amount=1, infinite=TRUE, cost=20)
		product_list += new/datum/data/vending_product(/obj/item/letter/traitor, amount=1, cost=1000, hidden=TRUE)
