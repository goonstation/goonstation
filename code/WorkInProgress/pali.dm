// im pali

/obj/item/reagent_containers/pill/sheltestgrog
	name = "pill"
	New()
		. = ..()
		src.reagents.add_reagent("sheltestgrog", 100)

/obj/item/ammo/bullets/beepsky
	sname = "Beepsky"
	name = "beepsky box"
	desc = "A box of large Beepsky-shaped bullets"
	icon_state = "lmg_ammo"
	amount_left = 10.0
	max_amount = 10.0
	ammo_type = new/datum/projectile/special/spawner/beepsky

	caliber = 2
	icon_dynamic = 1
	icon_short = "lmg_ammo"
	icon_empty = "lmg_ammo-0"


/obj/item/gun/kinetic/beepsky
	name = "\improper Loose Cannon"
	desc = "Gets the job done."
	icon_state = "buff_airzooka"
	color = "#555555"
	force = 5
	caliber = 2 // hell if I know
	max_ammo_capacity = 100
	auto_eject = 0

	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY

	spread_angle = 25
	can_dual_wield = 0

	slowdown = 5
	slowdown_time = 15

	two_handed = 1
	w_class = 4

	New()
		ammo = new/obj/item/ammo/bullets/beepsky
		current_projectile = new/datum/projectile/special/spawner/beepsky
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
	bird_call_sound = "sound/voice/animal/goose.ogg"
	health_brute = 50
	health_burn = 50
	add_abilities = list(/datum/targetable/critter/peck,
						/datum/targetable/critter/tackle)

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

	Bump(atom/movable/AM as mob|obj, yes)
		. = ..()
		src.fix_pulling_sprite()

	Move(atom/NewLoc, direct)
		. = ..()
		if(src.pulling)
			src.dir = turn(get_dir(src, src.pulling), 180)

/obj/chat_maptext_holder
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE
	mouse_opacity = 0
	var/list/lines = list() // a queue sure would be nice

	disposing()
		for(var/image/chat_maptext/I in src.lines)
			pool(I)
		src.lines = null
		for(var/A in src.vis_locs)
			if(isliving(A))
				var/mob/living/L = A
				if(L.chat_text == src)
					L.chat_text = null
			A:vis_contents -= src
		..()

/image/chat_maptext
	var/bumped = 0
	var/list/client/visible_to = list()
	bumped = 0
	layer = HUD_LAYER_UNDER_1
	plane = PLANE_HUD
	maptext_x = -64
	maptext_y = 28
	maptext_width = 160
	maptext_height = 48
	alpha = 0
	icon = null
	appearance_flags = 0
	var/unique_id
	var/measured_height = 8

	unpooled(var/pooltype)
		..()
		// for optimization purposes some of these could probably be left out if necessary because they *shouldn't* ever change
		src.bumped = initial(src.bumped)
		src.layer = initial(src.layer)
		src.plane = initial(src.plane)
		src.maptext_x = initial(src.maptext_x)
		src.maptext_y = initial(src.maptext_y)
		src.maptext_width = initial(src.maptext_width)
		src.maptext_height = initial(src.maptext_height)
		src.alpha = initial(src.alpha)
		src.icon = initial(src.icon)
		src.appearance_flags = initial(src.appearance_flags)
		src.measured_height = initial(src.measured_height)
		for(var/client/C in src.visible_to)
			C.images -= src
		src.visible_to = list()
		src.unique_id = TIME

	disposing()
		if(istype(src.loc, /obj/chat_maptext_holder))
			var/obj/chat_maptext_holder/holder = src.loc
			holder.lines -= src
		for(var/client/C in src.visible_to)
			C.images -= src
		src.loc = null
		src.unique_id = 0
		..()

	proc/bump_up(how_much = 8, invis = 0)
		src.bumped++
		if(invis)
			animate(src, alpha = 0, maptext_y = src.maptext_y + how_much, time = 4)
		else
			animate(src, maptext_y = src.maptext_y + how_much, time = 4)

	proc/show_to(var/client/who)
		if(!istype(who))
			return
		who << src
		src.visible_to += who
		/*var/mob/whomob = who.mob
		if(istype(whomob) && !isunconscious(whomob) && isliving(whomob) && !whomob.sleeping && !whomob.getStatusDuration("paralysis"))
			for (var/mob/dead/target_observer/observer in whomob:observers)
				if(!observer.client)
					continue
				observer.client << src
				src.visible_to += observer.client*/

	proc/measure(var/client/who)
		if(!istype(who))
			for(var/C in clients)
				if(C)
					who = C
					break
		if(!who) return 8
		src.measured_height = text2num(splittext(who.MeasureText(src.maptext, width = src.maptext_width), "x")[2])

proc/make_chat_maptext(atom/target, msg, style = "")
	var/image/chat_maptext/text = unpool(/image/chat_maptext)
	animate(text, maptext_y = 28, time = 0.01) // this shouldn't be necessary but it keeps breaking without it
	if(istype(target, /mob/living))
		var/mob/living/L = target
		text.loc = L.chat_text
		L.chat_text.lines.Add(text)
	else // hmm?
		text.loc = target
	msg = copytext(msg, 1, 128) // 4 lines, seems fine to me
	text.maptext = "<span class='pixel c ol' style=\"[style]\">[msg]</span>"
	animate(text, alpha = 255, maptext_y = 34, time = 4, flags = ANIMATION_END_NOW)
	var/text_id = text.unique_id
	SPAWN_DBG(4 SECONDS)
		if(text_id == text.unique_id)
			text.bump_up(invis=1)
			sleep(3 SECONDS)
			pool(text)
	return text

/obj/maptext_spawner
	var/loc_maptext = ""
	var/loc_maptext_width = 32
	var/loc_maptext_height = 32
	var/loc_maptext_x = 0
	var/loc_maptext_y = 0
	New()
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
	src.transform = matrix() * 0
	animate(src, transform = matrix(), time = 1 SECOND, easing = SINE_EASING)
	SPAWN_DBG(1 SECOND)
		new /obj/effects/void_break(src.loc)
		sleep(0.5 SECONDS)
		critter_spam()

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
		src.filters += filter(type="rays", size=64, density=src.ray_density, factor=1, offset=rand(1000), threshold=0, color=src.color, x=shift_x, y=shift_y)
		var/f = src.filters[length(src.filters)]
		animate(f, offset=f:offset + 100, time=600, easing=LINEAR_EASING, flags=ANIMATION_PARALLEL, loop=-1)

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

	Bump(atom/movable/AM, yes)
		. = ..()
		if(src.contents && !istype(AM, /obj/table) && !ON_COOLDOWN(src, "bump_attack", 0.5 SECONDS))
			var/obj/item/I = pick(src.contents)
			if(istype(I))
				src.last_item_bump = I
				src.weapon_attack(AM, I, 1)

	death(gibbed)
		src.vis_contents = null
		var/list/turf/targets = list()
		for(var/turf/T in view(8, src))
			targets += T
		for(var/atom/movable/AM in src)
			if(istype(AM, /obj/screen))
				continue
			AM.transform = null
			AM.set_loc(get_turf(src))
			SPAWN_DBG(0)
				var/orig_anchored = AM.anchored
				var/orig_density = AM.density
				AM.anchored = 0
				AM.density = 0
				AM.throw_at(pick(targets), rand(1, 10), rand(1, 15))
				AM.anchored = orig_anchored
				sleep(0.5 SECONDS)
				AM.density = orig_density
		. = ..()
		SPAWN_DBG(1 SECOND)
			src.transforming = 1
			src.canmove = 0
			src.icon = null
			src.invisibility = 101
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
		if(size > 70 && istype(new_turf, /turf/simulated/floor))
			var/turf/simulated/floor/floor = new_turf
			floor.pry_tile(src.equipped(), src)
		var/found = 0
		for(var/obj/O in new_turf)
			if(istype(O, /obj/overlay))
				continue
			if(O.invisibility > 10)
				continue
			var/obj/item/I = O
			if(size < 40 && (!istype(O, /obj/item) || I.w_class > size / 10 + 1))
				continue
			if(size < 60 && O.anchored)
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
		if(size > 80 && !found && new_turf.density && !isrestrictedz(new_turf.z) && prob(20))
			new_turf.ex_act(prob(1) ? 1 : 2)
		. = ..()

	setup_healths()
		add_hh_robot(-150, 150, 1.15)
