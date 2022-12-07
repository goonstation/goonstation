//bot go brr?
//GUNS GUNS GUNS
/obj/item/gun/energy/cannon
	name = "Vexillifer IV"
	desc = "It's a cannon? A laser gun? You can't tell."
	icon = 'icons/obj/large/64x32.dmi'
	icon_state = "lasercannon"
	item_state = "cannon"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	force = MELEE_DMG_LARGE


	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | EXTRADELAY
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD | ONBACK

	can_dual_wield = 0

	//color = list(0.110785,0.179801,0.533943,0.0890215,-0.0605533,-1.35334,0.823851,0.958116,1.79703)

	two_handed = 1
	w_class = W_CLASS_BULKY
	muzzle_flash = "muzzle_flash_bluezap"
	cell_type = /obj/item/ammo/power_cell/self_charging/mediumbig
	shoot_delay = 0.8 SECONDS


	New()
		set_current_projectile(new/datum/projectile/laser/asslaser)
		..()

	setupProperties()
		..()
		setProperty("movespeed", 0.3)

	flashy
		icon_state = "lasercannon-anim"

		shoot(target, start, mob/user, POX, POY, is_dual_wield)
			if(src.canshoot(user))
				flick("lasercannon-fire", src)
			. = ..()

/datum/projectile/energy_bolt/taser_beam
	cost = 0
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	projectile_speed = 12800
	shot_volume = 10

	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,0,"HalfStartRailG","HalfEndRailG",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			O.color = list(1,2.30348,-4.4382,0,0,1.96078,0,-1.3074,3.46173)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/bullet/optio
	name = "hardlight bolt"
	sname = "needle bolt"
	cost = 20
	damage = 35
	dissipation_delay = 6
	damage_type = D_PIERCING
	hit_type = DAMAGE_STAB
	icon_state = "laser_white"
	shot_sound = 'sound/weapons/optio.ogg'
	implanted = null
	armor_ignored = 0.66
	impact_image_state = "bhole"
	shot_volume = 66
	window_pass = 1

/datum/projectile/bullet/optio/hitscan
	name = "hardlight beam"
	sname = "pencil beam"
	cost = 40
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	projectile_speed = 12800
	armor_ignored = 0.33


	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/Sx = P.orig_turf.x*32 + P.orig_turf.pixel_x
		var/Sy = P.orig_turf.y*32 + P.orig_turf.pixel_y

		var/Hx = hit.x*32 + hit.pixel_x
		var/Hy = hit.y*32 + hit.pixel_y

		var/dist = sqrt((Hx-Sx)**2 + (Hy-Sy)**2)

		var/Px = Sx + sin(P.angle) * dist
		var/Py = Sy + cos(P.angle) * dist

		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,0,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0, Sx, Sy, Px, Py)
		for(var/obj/O in affected)
			O.color = list(-0.8, 0, 0, 0, -0.8, 0, 0, 0, -0.8, 1.5, 1.5, 1.5)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

/datum/projectile/special/target_designator
	sname = "foo"
	name = "bar"
	cost = 0
	dissipation_rate = 0
	projectile_speed = 12800
	casing = /obj/item/casing/cannon
	damage = 1
	max_range = 500
	damage_type = D_SPECIAL
	shot_sound = null
	hit_mob_sound = null
	hit_object_sound = null
	silentshot = TRUE

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))
		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,1,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0)
		for(var/obj/O in affected)
			O.alpha = 0
			O.color = "#ff0000"
			animate(O, time = 0.2 SECONDS, alpha = 255, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.1 SECONDS, alpha = 0, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.2 SECONDS, alpha = 255, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.1 SECONDS, alpha = 0, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.2 SECONDS, alpha = 255, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.1 SECONDS, alpha = 0, easing = JUMP_EASING | EASE_IN)
			animate(time = 0.1 SECONDS, alpha = 255, easing = JUMP_EASING | EASE_IN)

		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				O.color = initial(O.color)
				qdel(O)
			var/datum/projectile/bullet/howitzer/hack = new
			hack.on_hit(end)
			qdel(hack)
			qdel(start)
			qdel(end)

/datum/projectile/bullet/rifle_3006/rakshasa
	sname = "\improper Rakshasa"
	name = "\improper Rakshasa round"
	icon_state = "sniper_bullet"
	dissipation_rate = 0
	projectile_speed = 12800
	casing = /obj/item/casing/cannon
	damage = 125
	implanted = /obj/item/implant/projectile/rakshasa
	impact_image_state = "bhole-large"
	goes_through_walls = 1
	pierces = -1

	on_end(obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(P))
		var/list/affected = DrawLine(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,1,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0)
		for(var/obj/O in affected)
			animate(O, 1 SECOND, alpha = 0, easing = SINE_EASING | EASE_IN)
		SPAWN(1 SECOND)
			for(var/obj/O in affected)
				O.alpha = initial(O.alpha)
				qdel(O)
			qdel(start)
			qdel(end)

	on_hit(atom/hit, direction, obj/projectile/P)
		. = ..()
		hit.ex_act(2)

/obj/item/ammo/bullets/rifle_3006/rakshasa
	name = "\improper Rakshasa round"
	desc = "..."
	ammo_type = new/datum/projectile/bullet/rifle_3006/rakshasa

/obj/item/gun/kinetic/g11
	name = "\improper Manticore assault rifle"
	desc = "An assault rifle capable of firing single precise bursts. The magazines holders are embossed with \"Anderson Para-Munitions\""
	icon = 'icons/obj/large/48x32.dmi'
	icon_state = "g11"
	item_state = "g11"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	c_flags = NOT_EQUIPPED_WHEN_WORN | EQUIPPED_WHILE_HELD | ONBACK
	has_empty_state = 1
	var/shotcount = 0
	var/last_shot_time = 0
	uses_multiple_icon_states = 1
	force = 15
	contraband = 8
	ammo_cats = list(AMMO_CASELESS_G11)
	max_ammo_capacity = 45
	can_dual_wield = 0
	two_handed = 1
	var/datum/projectile/bullet/g11/small/smallproj = new
	default_magazine = /obj/item/ammo/bullets/g11

	New()
		set_current_projectile(new/datum/projectile/bullet/g11)
		ammo = new default_magazine
		. = ..()

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY)
		spread_angle = max(0, shoot_delay*2+last_shot_time-TIME)*0.4
		shotcount = 0
		. = ..(target, start, user, POX+rand(-spread_angle, spread_angle)*16, POY+rand(-spread_angle, spread_angle)*16)
		last_shot_time = TIME

	shoot_point_blank(atom/target, mob/user, second_shot)
		shotcount = 0
		. = ..()

	alter_projectile(obj/projectile/P)
		. = ..()
		if(++shotcount < 3)
			P.proj_data = smallproj

/obj/item/ammo/bullets/g11
	sname = "\improper Manticore rounds" // This makes little sense, but they're all chambered in the same caliber, okay (Convair880)?
	name = "\improper Manticore magazine"
	desc = "The side of the magazine is stamped with \"Anderson Para-Munitions\""
	ammo_type = new/datum/projectile/bullet/g11
	icon_state = "caseless"
	amount_left = 45
	max_amount = 45
	ammo_cat = AMMO_CASELESS_G11
	sound_load = 'sound/weapons/gunload_heavy.ogg'
	icon_empty = "caseless-empty"

	blast
		icon_state = "caseless_grey"
		ammo_type = new/datum/projectile/bullet/g11/blast

	void
		icon_state = "caseless_purple"
		ammo_type = new/datum/projectile/bullet/g11/void

/datum/projectile/bullet/g11
	name = "\improper Manticore round"
	cost = 3
	damage = 60
	hit_ground_chance = 100
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 3
	shot_delay = 0.04 SECONDS
	shot_sound = 'sound/weapons/gunshot.ogg'
	shot_volume = 66
	dissipation_delay = 10
	dissipation_rate = 5
	impact_image_state = "bhole-small"

	small
		shot_sound = 'sound/weapons/9x19NATO.ogg'
		shot_volume = 50
		damage = 15
		hit_ground_chance = 33

	void
		damage = 30
		on_hit(atom/hit, angle, obj/projectile/O)
			var/turf/T = get_turf(hit)
			new/obj/decal/implo(T)
			playsound(T, 'sound/effects/suck.ogg', 100, 1)
			var/spamcheck = 0
			for(var/atom/movable/AM in oview(2, T))
				if(AM.anchored || AM == hit || AM.throwing) continue
				if(spamcheck++ > 20) break
				AM.throw_at(T, 20, 1)
			..()

	blast
		damage = 15
		damage_type = D_KINETIC
		hit_type = DAMAGE_BLUNT
		on_hit(atom/hit, angle, obj/projectile/O)
			explosion_new(O, get_turf(hit), 2)


/obj/item/gun/kinetic/pistol/autoaim
	name = "\improper Catoblepas pistol"
	desc = "A semi-smart pistol with moderate aim-correction. The manufacterer markings read \"Anderson Para-Munitions\"."
	shoot(target, start, mob/user, POX, POY) //checks clicked turf first, so you can choose a target if need be
		for(var/mob/M in range(2, target))
			if(M == user || istype(M.get_id(), /obj/item/card/id/syndicate)) continue
			..(get_turf(M), start, user, POX, POY)
			return
		..()


/obj/item/gun/kinetic/pistol/smart
	name = "\improper Hydra smart pistol"
	desc = "A silenced pistol capable of locking onto multiple targets and firing on them in rapid sequence. \"Anderson Para-Munitions\" is engraved on the slide."
	silenced = 1
	max_ammo_capacity = 30
	New()
		..()
		ammo.amount_left = 30
		AddComponent(/datum/component/holdertargeting/smartgun/nukeop, 3)


/datum/component/holdertargeting/smartgun/nukeop/is_valid_target(mob/user, mob/M)
	return ..() && !istype(M.get_id(), /obj/item/card/id/syndicate)

//smart extinguisher
/obj/item/gun/flamethrower/extinguisher
	name = "smart fire extinguisher"
	desc = "An advanced fire extinguisher that locks onto nearby burning personnel and sprays them down with fire-fighting foam."
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "fire_extinguisher0"
	item_state = "fireextinguisher0"
	swappable_tanks = 0
	spread_angle = 10
	mode = 1 //magic number bad

	New()
		. = ..()
		fueltank = new/obj/item/reagent_containers/glass/beaker/extractor_tank/thick(src)
		gastank = new/obj/item/tank/oxygen(src)
		src.fueltank.reagents.add_reagent("ff-foam", 1000)
		src.amt_chem = 20
		AddComponent(/datum/component/holdertargeting/smartgun/extinguisher, 1)
		src.current_projectile.shot_number = 3
		src.chem_divisor = 3

/datum/component/holdertargeting/smartgun/extinguisher/is_valid_target(mob/user, mob/M)
	return (M.hasStatus("burning"))

/obj/item/gun/kinetic/gyrojet
	name = "Amaethon gyrojet pistol"
	desc = "A semi-automatic handgun that fires rocket-propelled bullets, developed by Mabinogi Firearms Company."
	icon_state = "gyrojet"
	item_state = "gyrojet"
	ammo_cats = list(AMMO_GYROJET)
	max_ammo_capacity = 6
	has_empty_state = 1
	default_magazine = /obj/item/ammo/bullets/gyrojet
	fire_animation = TRUE

	New()
		ammo = new default_magazine
		set_current_projectile(new/datum/projectile/bullet/gyrojet)
		. = ..()

/obj/item/ammo/bullets/gyrojet
	sname = "13mm Gyrojet"
	name = "gyrojet magazine"
	icon_state = "pistol_magazine"
	amount_left = 6
	max_amount = 6
	ammo_type = new/datum/projectile/bullet/gyrojet
	ammo_cat = AMMO_GYROJET

/datum/projectile/bullet/gyrojet
	name = "gyrojet bullet"
	projectile_speed = 6
	max_range = 500
	dissipation_rate = 0
	damage = 10
	precalculated = 0
	shot_volume = 100
	shot_sound = 'sound/weapons/gyrojet.ogg'
	impact_image_state = "bhole-small"

	on_launch(obj/projectile/O)
		O.internal_speed = projectile_speed

	tick(obj/projectile/O)
		O.internal_speed = min(O.internal_speed * 1.25, 32)

	get_power(obj/projectile/P, atom/A)
		return 15 + P.internal_speed

//desert eagle. The biggest, baddest handgun
/obj/item/gun/kinetic/deagle
	name = "\improper Simurgh heavy pistol"
	desc = "The heaviest handgun you've ever seen. The grip is stamped \"Anderson Para-Munitions\""
	icon_state = "deag"
	item_state = "deag"
	force = 10.0 //mmm, pistol whip
	throwforce = 20 //HEAVY pistol
	auto_eject = 1
	max_ammo_capacity = 7
	ammo_cats = list(AMMO_PISTOL_ALL, AMMO_REVOLVER_ALL, AMMO_DEAGLE) //the omnihandgun
	has_empty_state = 1
	gildable = 1
	fire_animation = TRUE
	default_magazine = /obj/item/ammo/bullets/deagle50cal

	New()
		set_current_projectile(new/datum/projectile/bullet/deagle50cal)
		ammo = new default_magazine
		. = ..()

	//gimmick deagle that decapitates
	decapitation
		force = 18.0 //mmm, pistol whip
		throwforce = 50 //HEAVY pistol
		default_magazine = /obj/item/ammo/bullets/deagle50cal/decapitation
		New()
			. = ..()
			set_current_projectile(new/datum/projectile/bullet/deagle50cal/decapitation)
			ammo = new default_magazine

//.50AE deagle ammo
/obj/item/ammo/bullets/deagle50cal
	sname = "0.50 AE"
	name = "\improper Simurgh magazine"
	icon_state = "pistol_magazine"
	amount_left = 7
	max_amount = 7
	ammo_type = new/datum/projectile/bullet/deagle50cal
	ammo_cat = AMMO_DEAGLE

	//gimmick deagle ammo that decapitates
	decapitation
		ammo_type = new/datum/projectile/bullet/deagle50cal/decapitation

/datum/projectile/bullet/deagle50cal
	name = "bullet"
	damage = 120
	dissipation_delay = 5
	dissipation_rate = 5
	implanted = /obj/item/implant/projectile/bullet_50
	impact_image_state = "bhole-large"
	casing = /obj/item/casing/deagle
	shot_sound = 'sound/weapons/deagle.ogg'

	//gimmick deagle ammo that decapitates
	decapitation
		on_hit(atom/hit, angle, obj/projectile/O)
			. = ..()
			if(ishuman(hit))
				var/mob/living/carbon/human/H = hit
				var/obj/item/organ/head/head = H.drop_organ("head", get_turf(H))
				if(head)
					head.throw_at(get_edge_target_turf(head, get_dir(O, H) ? get_dir(O, H) : H.dir),2,1)
					H.visible_message("<span class='alert'>[H]'s head get's blown right off! Holy shit!</span>", "<span class='alert'>Your head gets blown clean off! Holy shit!</span>")

//magical crap
/obj/item/enchantment_scroll
	name = "Scroll of Enchantment"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	flags = FPRINT | TABLEPASS
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "paper"
	throw_speed = 4
	throw_range = 20
	desc = "Like a temporary tattoo of magical runes! Slap it on an item, and watch the magic happen."

	afterattack(atom/target, mob/user, reach, params)
		if(istype(target, /obj/item))
			var/obj/item/I = target
			var/incr = rand(1,3)
			var/msg = text("As [user] slaps the [src] onto the [target], the [target]")
			var/currentench = I.enchant(incr)
			var/turf/T = get_turf(target)
			playsound(T, 'sound/impact_sounds/Generic_Stab_1.ogg', 25, 1)
			if(currentench-incr <= 2 || !rand(0, currentench))
				user.visible_message("<span class='notice'>[msg] glows with a faint light[(currentench >= 3) ? " and vibrates violently!" : "."]</span>")
			else
				user.visible_message("<span class='alert'>[msg] shudders violently and turns to dust!</span>")
				qdel(I)
			qdel(src)
		else
			return ..()
/**
 * Enchants an item (minor armor boost for clothing, otherwise increases melee damage)
 *
 * incr - value to enchant by
 * setTo - when true, sets enchantment to incr, otherwise will add incr to existing enchantment (positive or negative)
 */
/obj/item/proc/enchant(incr, setTo = 0)
	var/currentench = 0
	var/prop = ""
	if(istype(src, /obj/item/clothing))
		prop = "enchantarmor"
	else
		prop = "enchantweapon"

	currentench = src.getProperty(prop)
	if(setTo)
		incr -= currentench
	src.setProperty(prop, currentench+incr)
	src.remove_prefixes("[currentench>0?"+":""][currentench]")
	if(currentench+incr)
		src.name_prefix("[(currentench+incr)>0?"+":""][currentench+incr]", prepend = 1)
		src.rarity = max(src.rarity, round((currentench+incr+1)/2) + 2)
	else
		src.rarity = initial(src.rarity)
	src.tooltip_rebuild = 1
	src.UpdateName()
	return currentench + incr

///Office stuff
//Suggestion box
/obj/suggestion_box
	name = "suggestion box"
	icon = 'icons/obj/large/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	flags = FPRINT
	anchored = 1
	desc = "Some sort of thing to put suggestions into. If you're lucky, they might even be read!"
	var/taken_suggestion = 0
	var/list/turf/floors = null

	New()
		. = ..()
		floors = list()
		for(var/turf/T in orange(1, src))
			if(!T.density)
				floors += T
		if(!floors.len)	//fall back on own turf
			floors += get_turf(src)

	attackby(obj/item/I, mob/user)
		if(istype(I, /obj/item/paper))
			var/obj/item/paper/P = I
			if(P.info && !taken_suggestion)
				message_admins("[user] ([user?.ckey]) has made a suggestion in [src]:<br>[P.name]<br><br>[copytext(P.info,1,MAX_MESSAGE_LEN)]")
				var/ircmsg[] = new()
				ircmsg["msg"] = "[user] ([user?.ckey]) has made a suggestion in [src]:\n**[P.name]**\n[strip_html_tags(P.info)]"
				ircbot.export_async("admin", ircmsg)
				taken_suggestion = 1
			user.u_equip(P)
			qdel(P)
			playsound(src.loc, 'sound/machines/paper_shredder.ogg', 90, 1)
			var/turf/T = pick(floors)
			if(T)
				new /obj/decal/cleanable/paper(T)
		return ..()

/obj/item/mutation_orb/cat_orb
	name = "essence of catness"
	desc = "Nya?"
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "orb_fire"

	envelop_message = "fur"
	leaving_message = "meowing softly and vanishing"

	New()
		. = ..()
		color = list(0.3, 0.4, 0.3, 0, 1, 0, 0, 0, 1)
		mutations_to_add = list(new /datum/mutation_orb_mutdata(id = "cat", magical = 1),
		new /datum/mutation_orb_mutdata(id = "accent_uwu", magical = 1),
		new /datum/mutation_orb_mutdata(id = "dwarf", magical = 1)
		)

/obj/item/mutation_orb/cow_orb
	name = "essence of cowness"
	desc = "Moo!"
	icon = 'icons/misc/GerhazoStuff.dmi'
	icon_state = "orb_fire"

	envelop_message = "hair"
	leaving_message = "mooing softly and vanishing"

	New()
		. = ..()
		color = list(0.3, 0.4, 0.1, 0, 1, 0, 0, 0, 1)
		mutations_to_add = list(new /datum/mutation_orb_mutdata(id = "cow", magical = 1))

//lily's office
/obj/item/storage/desk_drawer/lily/
	spawn_contents = list(	/obj/item/reagent_containers/food/snacks/cake,\
	/obj/item/reagent_containers/food/snacks/cake,\
	/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake,\
	/obj/item/reagent_containers/food/snacks/cake/cream,\
	/obj/item/reagent_containers/food/snacks/cake/cream,\
	/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau,\
	/obj/item/reagent_containers/food/snacks/cake,\
)

/obj/table/wood/auto/desk/lily
	New()
		..()
		var/obj/item/storage/desk_drawer/lily/L = new(src)
		src.desk_drawer = L

/obj/machinery/door/unpowered/wood/lily

/obj/machinery/door/unpowered/wood/lily/open()
	if(src.locked) return
	playsound(src.loc, 'sound/voice/screams/fescream3.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
	. = ..()

/obj/machinery/door/unpowered/wood/lily/close()
	playsound(src.loc, 'sound/voice/screams/robot_scream.ogg', 50, 1, channel=VOLUME_CHANNEL_EMOTE)
	. = ..()


/obj/trigger/lovefill
	name = "A lovely spot"
	desc = "For lovely people"
	var/list/loved = list()

	on_trigger(var/atom/movable/triggerer)
		var/mob/living/M = triggerer
		if(!istype(M) || (M in loved))
			return
		M.reagents?.add_reagent("love", 20)
		boutput(M, "<span class='notice'>You feel loved</span>")
		loved += M

//misc stuffs
TYPEINFO(/obj/item/device/geiger)
	mats = 5

/obj/item/device/geiger
	name = "geiger counter"
	desc = "A device used to passively measure raditation."
	icon_state = "geiger-0"
	item_state = "geiger"
	flags = FPRINT | TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

	New()
		. = ..()
		AddComponent(/datum/component/holdertargeting/geiger)
		RegisterSignal(src, COMSIG_MOB_GEIGER_TICK, .proc/change_icon_state)

	proc/change_icon_state(source, stage)
		switch(stage)
			if(1 to 2)
				flick("geiger-1", src)
			if(3 to 4)
				flick("geiger-2", src)
			if(5)
				flick("geiger-3", src)


/obj/decal/fireplace  //for Jan's chrismas event
	name = "fireplace"
	desc = "Looks pretty toasty."
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	color = "#b74909"

	New()
		. = ..()
		processing_items += src

	disposing()
		processing_items -= src
		. = ..()

	proc/process()
		if(!ON_COOLDOWN(src, "process", 30 SECONDS))
			for (var/mob/living/M in view(src, 5))
				if (M.bioHolder)
					M.bioHolder.AddEffect("cold_resist", 0, 45)

/obj/item/firebot_deployer
	name = "compressed firebrand firebot"
	desc = "Deploys a firebot dedicated to putting out friendly fire(s)"
	icon = 'icons/obj/bots/aibots.dmi'
	icon_state = "firebot0"

	New()
		. = ..()
		src.SafeScale(0.5, 0.5)

	attack_self(mob/user)
		if(src == user.equipped())
			new/obj/machinery/bot/firebot/firebrand(get_turf(src))
			user.u_equip(src)
			qdel(src)
		. = ..()
