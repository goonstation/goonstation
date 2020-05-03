// im pali

/datum/projectile/bullet/beepsky
	name = "Beepsky"
	window_pass = 0
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot1"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	power = 5
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	ks_ratio = 1.0
	caliber = 2
	icon_turf_hit = "secbot1-spaz"
	implanted = null

	on_hit(atom/hit)
		var/obj/machinery/bot/secbot/autopatrol/beepsky = new(get_turf(hit))
		if(istype(hit, /mob))
			var/mob/hitguy = hit
			hitguy.do_disorient(15, weakened = 20 * 10, disorient = 80)
			if(istype(hitguy, /mob/living/carbon))
				beepsky.target = hitguy

/obj/item/ammo/bullets/beepsky
	sname = "Beepsky"
	name = "beepsky box"
	desc = "A box of large Beepsky-shaped bullets"
	icon_state = "lmg_ammo"
	amount_left = 10.0
	max_amount = 10.0
	ammo_type = new/datum/projectile/bullet/beepsky
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
		current_projectile = new/datum/projectile/bullet/beepsky
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
		..()

/image/chat_maptext
	var/bumped = 0
	var/list/client/visible_to = list()
	bumped = 0
	layer = 0
	plane = PLANE_HUD - 1
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

/obj/thing_that_spams_chat
	name = "chat spammer"
	icon = 'icons/obj/junk.dmi'
	icon_state = "gnome"
	var/slep = 0
	var/n_spams = 200

	attack_hand(mob/user)
		. = ..()
		var/start = TIME
		boutput(user, "START TIMER")
		for(var/i=1; i <= n_spams; i++)
			boutput(user, "spam")
		boutput(user, "STOP TIMER")
		if(slep)
			sleep(0)
		boutput(user, "time: [TIME - start]")
	
	attackby(obj/item/I, mob/user)
		. = ..()
		if(istype(I, /obj/item/spacecash))
			var/start = TIME
			boutput(user, "a")
			boutput(user, "DO LAG")
			boutput(user, "b")
			if(slep)
				sleep(0)
			boutput(user, "time: [TIME - start]")
			return
		if(istype(I, /obj/item/device/pda2))
			var/start = TIME
			boutput(user, "a")
			boutput(user, "ALERT")
			boutput(user, "b")
			if(slep)
				sleep(0)
			boutput(user, "time: [TIME - start]")
			return

		var/start = TIME
		boutput(user, "START TIMER")
		for(var/i=1; i <= n_spams; i++)
			boutput(user, "spam [rand(100)]")
		boutput(user, "STOP TIMER")
		if(slep)
			sleep(0)
		boutput(user, "time: [TIME - start]")
