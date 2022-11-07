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
	icon_state = "buff_airzooka"
	color = "#555555"
	force = 5
	ammo_cats = list(AMMO_BEEPSKY)  // hell if I know
	max_ammo_capacity = 100
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

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
			user.visible_message("<span class='alert'>[user] loads \the [A] into \the [src].</span>", "<span class='alert'>You load \the [A] into \the [src].</span>")
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
			var/list/all_slots = list(M.slot_back, M.slot_wear_mask, M.slot_l_hand, M.slot_r_hand, M.slot_belt, M.slot_wear_id, M.slot_ears, M.slot_glasses, M.slot_gloves, M.slot_head, M.slot_shoes, M.slot_wear_suit, M.slot_l_store, M.slot_r_store)
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
	speechverb_say = "honks"
	speechverb_exclaim = "calls"
	speechverb_ask = "warbles"
	speechverb_gasp = "mumbles"
	speechverb_stammer = "cackles"
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
	var/critter_type = /obj/critter/zombie

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
		src.visible_message("<span style=\"color:red\"><b> \The [zomb] emerges from \the [src]!</b></span>")
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
	appearance_flags = RESET_ALPHA | RESET_COLOR | NO_CLIENT_COLOR | KEEP_APART | RESET_TRANSFORM
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
	speechverb_say = "rattles"
	speechverb_exclaim = "rattles"
	speechverb_ask = "rattles"
	flags = TABLEPASS
	fits_under_table = 1
	blood_id = "iron"
	metabolizes = 0
	var/size = 0
	var/obj/item/implant/access/access
	var/obj/item/last_item_bump

	New()
		. = ..()
		access = new /obj/item/implant/access(src)
		access.owner = src
		access.uses = -1
		access.implanted = 1

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
		for(var/obj/O in new_turf)
			if(istype(O, /obj/overlay))
				continue
			if(O.invisibility > INVIS_GHOST)
				continue
			var/obj/item/I = O
			if(size < 60 && (!istype(O, /obj/item) || I.w_class > size / 10 + 1))
				continue
			if(size < 90 && O.anchored)
				continue
			if(istype(I, /obj/item/card/id))
				var/obj/item/card/id/id = I
				src.access.access.access |= id.access // access
			O.set_loc(src)
			src.vis_contents += O
			O.pixel_x = 0
			O.pixel_y = 0
			var/matrix/tr = new
			tr.Turn(rand(360))
			tr.Translate(sqrt(size) * 3 / 2, sqrt(size) * 3)
			tr.Turn(rand(360))
			O.transform = tr
			size += 0.3
			found = 1
			break
		if(size > 140 && !found && new_turf.density && !isrestrictedz(new_turf.z) && prob(20))
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
		var/obj/item/clothing/suit/bio_suit/suit = new(src.loc)
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
			boutput(H, "<span class='alert'>There's 1 impostor among us.</alert>")
		qdel(src)

/obj/spawner/amongus_clothing/cursed
	cursed = TRUE



/proc/populate_station(chance=100)
	for(var/job_name in job_start_locations)
		if(job_name == "AI")
			continue
		for(var/turf/T in job_start_locations[job_name])
			if(prob(chance))
				var/mob/living/carbon/human/normal/H = new(T)
				H.JobEquipSpawned(job_name)




/obj/storage/closet/extradimensional
	New()
		..()
		src.setMaterial(getMaterial("negativematter"))
