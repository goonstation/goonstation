//GUNS GUNS GUNS
/datum/projectile/bullet/homing/glatisant
	name = "\improper Glatisant cluster warhead"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	dissipation_rate = 0
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
	damage = 15
	icon_state = "mininuke"
	default_firemode = /datum/firemode/cluster_rocket
	min_speed = 24
	max_speed = 36
	start_speed = 24
	max_rotation_rate = 7
	auto_find_targets = FALSE

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		explosion_new(null, get_turf(hit), 10)
		for (var/i in -4 to 4)
			var/obj/projectile/P = initialize_projectile(get_turf(O), new/datum/projectile/bullet/homing/glatisant_submuntitions, O.xo, O.yo, O.shooter)
			P.rotateDirection(180 + 8*i)
			P.launch()

/datum/projectile/bullet/homing/glatisant_submuntitions
	name = "\improper Glatisant submuntition seeker"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	dissipation_rate = 0
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-small"
	damage = 20
	icon_state = "40mm_lethal"
	shot_volume = 33
	min_speed = 12
	max_speed = 24
	start_speed = 12
	max_rotation_rate = 16
	hit_ground_chance = 100

	on_hit(atom/hit, angle, obj/projectile/O)
		. = ..()
		explosion_new(null, get_turf(hit), 16)

	is_valid_target(mob/M, obj/projectile/P)
		. = ..()
		return . && isliving(M) && !isintangible(M)

//much of this shamelessly copy-pasted from the pod-seeker
/obj/item/gun/kinetic/glatisant
	name = "\improper Glatisant cluster missile launcher"
	desc = "A platform for launching high-tech cluster munitions. \"Anderson Para-Munitions\" is printed on the sighting module."
	icon = 'icons/obj/items/guns/kinetic64x32.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "missile_launcher" //could use a bespoke sprite but a recolor will do for now rip
	item_state = "missile_launcher"
	color = list(1.09141,-0.886668,-0.991788,0.139438,-0.352545,-1.5129,-0.110001,1.06701,2.19351)
	has_empty_state = TRUE
	w_class = W_CLASS_BULKY
	throw_speed = 2
	throw_range = 4
	force = MELEE_DMG_LARGE
	contraband = 8
	ammo_cats = list(AMMO_ROCKET_ALL)
	max_ammo_capacity = 1
	can_dual_wield = FALSE
	two_handed = TRUE
	muzzle_flash = "muzzle_flash_launch"
	default_magazine = /obj/item/ammo/bullets/pod_seeking_missile
	recoil_strength = 13

	New()
		ammo = new default_magazine
		ammo.amount_left = 1
		set_current_projectile(new /datum/projectile/bullet/homing/glatisant)
		AddComponent(/datum/component/holdertargeting/smartgun/homing, 1)
		..()

/obj/item/ammo/bullets/glatisant
	sname = "\improper Glatisant cluster missile"
	name = "\improper Glatisant cluster missile"
	desc = "A high-explosive missile, equipped active seekers and filled with homing submunitions. \"Anderson Para-Munitions\" is stenciled on the side."
	amount_left = 1
	max_amount = 1
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "mininuke"
	ammo_type = new /datum/projectile/bullet/homing/glatisant
	ammo_cat = AMMO_ROCKET_RPG
	w_class = W_CLASS_NORMAL
	delete_on_reload = TRUE
	sound_load = 'sound/weapons/gunload_mprt.ogg'

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

		var/list/affected = drawLineObj(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,0,"HalfStartRailG","HalfEndRailG",OBJ_LAYER, 0, Sx, Sy, Px, Py)
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
	impact_image_state = "bullethole"
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

		var/list/affected = drawLineObj(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,0,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0, Sx, Sy, Px, Py)
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
		var/list/affected = drawLineObj(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,1,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0)
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
	impact_image_state = "bullethole-large"
	goes_through_walls = 1
	pierces = -1

	on_end(obj/projectile/P)
		. = ..()
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(P))
		var/list/affected = drawLineObj(start, end, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeTrail",1,1,"HalfStartTrail","HalfEndTrail",OBJ_LAYER, 0)
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
	desc = "An assault rifle capable of firing single precise bursts. The magazine holders are embossed with \"Anderson Para-Munitions\""
	icon = 'icons/obj/items/guns/kinetic48x32.dmi'
	icon_state = "g11"
	item_state = "g11"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	flags =  TABLEPASS | CONDUCT | USEDELAY
	c_flags = ONBACK
	has_empty_state = 1
	var/shotcount = 0
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

	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null)
		shotcount = 0
		. = ..()

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
	damage = 60
	hit_ground_chance = 100
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	default_firemode = /datum/firemode/g11
	shot_sound = 'sound/weapons/gunshot.ogg'
	shot_volume = 66
	dissipation_delay = 10
	dissipation_rate = 5
	impact_image_state = "bullethole-small"

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
			playsound(T, 'sound/effects/suck.ogg', 100, TRUE)
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
	shoot(turf/target, turf/start, mob/user, POX, POY, is_dual_wield, atom/called_target = null) //checks clicked turf first, so you can choose a target if need be
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
		src.current_projectile.firemode.shot_number = 3
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
	projectile_speed = 7
	max_range = 500
	dissipation_rate = 0
	damage = 10
	precalculated = 0
	shot_volume = 100
	shot_sound = 'sound/weapons/gyrojet.ogg'
	impact_image_state = "bullethole-small"

	on_launch(obj/projectile/O)
		O.internal_speed = projectile_speed

	tick(obj/projectile/O)
		O.internal_speed = min(O.internal_speed * 1.33, 72)

	get_power(obj/projectile/P, atom/A)
		return 15 + (P.internal_speed * 0.66)

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
	recoil_strength = 19
	recoil_inaccuracy_max = 12
	icon_recoil_cap = 30
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
	impact_image_state = "bullethole-large"
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
					H.visible_message(SPAN_ALERT("[H]'s head get's blown right off! Holy shit!"), SPAN_ALERT("Your head gets blown clean off! Holy shit!"))
				H.death()

/obj/item/ammo/bullets/pipeshot/chems/saltshot
	sname = "salt load"
	desc = "This appears to be a bunch of salt shoved into a few cut open pipe frames."
	ammo_type = new/datum/projectile/special/spreader/buckshot_burst/salt

	get_desc(dist, mob/user)
		if (dist <= 1)
			. = "The shells smell like [prob(1) ? "deadchat. What?" : "the ocean."]"

/datum/pipeshotrecipe/chem/salt
	thingsneeded = 4
	result = /obj/item/ammo/bullets/pipeshot/chems/saltshot
	craftname = "salt"
	reagents_req = list("salt"=5)

/datum/projectile/bullet/antiunion
	name = "Union buster rocket"
	window_pass = 0
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "regrocket"
	damage_type = D_KINETIC
	hit_type = DAMAGE_BLUNT
	damage = 10
	dissipation_delay = 30
	cost = 1
	shot_sound = 'sound/weapons/rocket.ogg'
	impact_image_state = "bullethole-large"
	implanted = null

	on_hit(atom/hit)
		new /obj/effects/rendersparks(hit.loc)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			if(!M.traitHolder.hasTrait("unionized"))
				boutput(M, SPAN_ALERT("You are struck by a big rocket! Thankfully it was not the exploding kind."))
				M.do_disorient(stunned = 40)
			else
				boutput(M, SPAN_ALERT("You are struck by a union-busting rocket! There goes your union benefits!"))
				M.traitHolder.removeTrait("unionized")
				data_core.bank.find_record("name", M.real_name)["wage"] = data_core.bank.find_record("name", M.real_name)["wage"]/1.5


//magical crap
/obj/item/enchantment_scroll
	name = "Scroll of Enchantment"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll_seal"
	flags = TABLEPASS
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
			playsound(T, 'sound/impact_sounds/Generic_Stab_1.ogg', 25, TRUE)
			if(currentench-incr <= 2 || !rand(0, currentench))
				user.visible_message(SPAN_NOTICE("[msg] glows with a faint light[(currentench >= 3) ? " and vibrates violently!" : "."]"))
			else
				user.visible_message(SPAN_ALERT("[msg] shudders violently and turns to dust!"))
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
	anchored = ANCHORED
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
/obj/table/wood/auto/desk/lily
	has_drawer = TRUE
	drawer_contents = list(/obj/item/reagent_containers/food/snacks/cake,
						/obj/item/reagent_containers/food/snacks/cake,
						/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake,
						/obj/item/reagent_containers/food/snacks/cake/cream,
						/obj/item/reagent_containers/food/snacks/cake/cream,
						/obj/item/reagent_containers/food/snacks/cake/chocolate/gateau,
						/obj/item/reagent_containers/food/snacks/cake)

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
		boutput(M, SPAN_NOTICE("You feel loved"))
		loved += M

//misc stuffs
TYPEINFO(/obj/item/device/geiger)
	mats = 5

/obj/item/device/geiger
	name = "geiger counter"
	desc = "A device used to passively measure raditation."
	icon_state = "geiger-0"
	item_state = "geiger"
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	throwforce = 3
	w_class = W_CLASS_TINY
	throw_speed = 5
	throw_range = 10

	New()
		. = ..()
		AddComponent(/datum/component/holdertargeting/geiger)
		RegisterSignal(src, COMSIG_MOB_GEIGER_TICK, PROC_REF(change_icon_state))

	proc/change_icon_state(source, stage)
		switch(stage)
			if(1 to 2)
				FLICK("geiger-1", src)
			if(3 to 4)
				FLICK("geiger-2", src)
			if(5)
				FLICK("geiger-3", src)


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

//vacation satan
// Come to collect a poor unfortunate soul. Or just have a drink. One or the other
/mob/living/carbon/human/vacation_satan
	nodamage = 1
	anchored = ANCHORED
	New()
		..()
		src.add_ability_holder(/datum/abilityHolder/gimmick)
		abilityHolder.addAbility(/datum/targetable/gimmick/go2hell)
		abilityHolder.addAbility(/datum/targetable/gimmick/highway2hell)
		abilityHolder.addAbility(/datum/targetable/gimmick/reveal)
		abilityHolder.addAbility(/datum/targetable/gimmick/movefloor)

		SPAWN(0)
			abilityHolder.updateButtons()
			src.gender = "male"
			src.real_name = "Satan"
			src.name = "Satan"
			src.equip_new_if_possible(/obj/item/clothing/under/misc/tourist/max_payne, SLOT_W_UNIFORM)
			src.equip_new_if_possible(/obj/item/clothing/shoes/sandal/magic, SLOT_SHOES)
			src.equip_new_if_possible(/obj/item/clothing/glasses/sunglasses/tanning, SLOT_GLASSES)
			src.equip_new_if_possible(/obj/item/storage/fanny, SLOT_BELT)
			src.put_in_hand_or_drop(new /obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/fruity)
			src.bioHolder.AddEffect("demon_horns", 0, 0, 1)
			src.bioHolder.AddEffect("hell_fire", 0, 0, 1)

/obj/item/reagent_containers/food/drinks/drinkingglass/random_style/filled/fruity
	rand_pos = FALSE
	glass_types = list(/obj/item/reagent_containers/food/drinks/drinkingglass/cocktail)
	whitelist = list("schnapps", "cider", "sangria", "maitai", "planter", "cosmo")

//hey look
//a time gun
/datum/projectile/bullet/optio/hitscan/temporal
	name = "temporal bolt"
	sname = "temporal bolt"
	damage = 35
	shot_sound = 'sound/weapons/railgun.ogg'
	shot_volume = 50
	impact_image_state = "bullethole-large"

	on_hit(atom/hit, dirflag, obj/projectile/proj)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			M.do_disorient(30, knockdown = 20, stunned = 20, disorient = 30, remove_stamina_below_zero = 0)
		..()

/datum/projectile/special/timegun
	silentshot = 1
	cost = 25
	max_range = PROJ_INFINITE_RANGE
	dissipation_rate = 0
	projectile_speed = 12800
	shot_volume = 0
	var/datum/projectile/followup = new/datum/projectile/bullet/optio/hitscan/temporal

/datum/projectile/special/timegun/theBulletThatShootsTheFuture
	sname = "the bullet that shoots the future"
	hit_ground_chance = 100

	on_hit(atom/hit, angle, obj/projectile/P)
		. = ..()
		if(ismob(hit))
			return//no shooting the present nerd
		var/obj/railgun_trg_dummy/start = new(P.orig_turf)
		var/obj/railgun_trg_dummy/end = new(get_turf(hit))

		var/list/affected = drawLineObj(start, end, /obj/line_obj/timeshot ,'icons/obj/projectiles.dmi',"WholeRailG",1,0,"HalfStartRailG","HalfEndRailG",OBJ_LAYER, 0)
		var/datum/theBulletThatShootsTheFutureController/controller = new(affected, start, end, P.shooter, P.mob_shooter, followup)
		for(var/obj/line_obj/timeshot/ts in affected)
			ts.controller = controller

/datum/projectile/special/timegun/theBulletThatShootsThePast
	sname = "the bullet that shoots the past"
	goes_through_mobs = TRUE


/obj/line_obj/timeshot
	invisibility = 101
	var/datum/theBulletThatShootsTheFutureController/controller
	var/safe = FALSE

	Crossed(atom/movable/AM)
		. = ..()
		if(ismob(AM) && !safe && AM != controller.shooter && AM != controller.mob_shooter)
			controller.fire(AM)

/datum/theBulletThatShootsTheFutureController
	var/list/obj/line_obj/timeshot/lines = list()
	var/obj/railgun_trg_dummy/start
	var/obj/railgun_trg_dummy/end
	var/atom/shooter
	var/mob/mob_shooter
	var/startTime
	var/datum/projectile/followup

	New(lines, start, end, shooter, mob_shooter, proj_data)
		. = ..()
		src.lines = lines
		src.start = start
		src.end = end
		src.shooter = shooter
		src.mob_shooter = mob_shooter
		src.startTime = TIME
		src.lines[length(lines)].safe = TRUE
		src.followup = proj_data
		SPAWN(10 SECONDS)
			qdel(src)

	proc/fire()
		if(TIME > startTime + 1 SECOND)
			shoot_projectile_ST_pixel_spread(get_turf(start), followup, get_turf(end), alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)) )
			qdel(src)

	proc/alter_projectile(obj/projectile/P)
		P.shooter = src.shooter
		P.mob_shooter = src.mob_shooter

	disposing()
		. = ..()
		for(var/obj/line_obj/timeshot/ts in lines)
			qdel(ts)
		qdel(start)
		qdel(end)




/datum/component/afterimage/image_based/timegun/afterimage_type = /obj/afterimage/image_based/timegun
/datum/component/afterimage/image_based/timegun/var/last_shooter
/datum/component/afterimage/image_based/timegun/var/last_mob_shooter
/datum/component/afterimage/image_based/timegun/set_afterimage_args()
	src.afterimage_args = list(null, owner, src)

/datum/component/afterimage/image_based/timegun/proc/afterimage_hitby_proj(atom/source, obj/projectile/P)
	var/turf/T = get_turf(source)
	if(get_turf(parent) == T) //no shooting the present, nerd
		return
	src.last_shooter = P.shooter
	src.last_mob_shooter = P.mob_shooter
	if(istype(P.proj_data, /datum/projectile/special/timegun/theBulletThatShootsThePast))
		var/datum/projectile/special/timegun/theBulletThatShootsThePast/p_data = P.proj_data
		if(ismob(parent))
			var/mob/M = parent
			M.flash(3 SECONDS)
			boutput(M, SPAN_ALERT("<B>You suddenly feel yourself pulled violently back in time!</B>"))
			M.set_loc(T)
			M.changeStatus("stunned", 6 SECONDS)
			elecflash(M, power = 2)
			playsound(M.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
		else if(isobj(parent))
			var/obj/O = parent
			O.set_loc(T)
			elecflash(O, power = 2)
			playsound(O.loc, 'sound/effects/mag_warp.ogg', 25, 1, -1)
		shoot_projectile_ST_pixel_spread(P.orig_turf, p_data.followup, get_turf(source), alter_proj = new/datum/callback(src, PROC_REF(alter_projectile)))

/datum/component/afterimage/image_based/timegun/proc/alter_projectile(obj/projectile/P)
	P.shooter = src.last_shooter
	P.mob_shooter = src.last_mob_shooter

/obj/afterimage/image_based/timegun/New(loc, mob/owner, datum/component/afterimage/image_based/comp)
	. = ..()
	comp.RegisterSignal(src, COMSIG_ATOM_HITBY_PROJ, TYPE_PROC_REF(/datum/component/afterimage/image_based/timegun, afterimage_hitby_proj))

/obj/afterimage/image_based/timegun/Cross(atom/movable/mover)
	. = ..()
	if(istype(mover, /obj/projectile))
		var/obj/projectile/P = mover
		if(istype(P.proj_data, /datum/projectile/special/timegun/theBulletThatShootsThePast))
			return FALSE


/datum/component/holdertargeting/windup/timegun/var/mob/echoMob = null

/datum/component/holdertargeting/windup/timegun/do_windup(mob/living/L)
	. = ..()
	var/mindist = INFINITY
	for(var/mob/M in range(3, target))
		if(isliving(M) && !isintangible(M) && GET_DIST(target, M) < mindist)
			echoMob = M
			mindist = GET_DIST(target, M)
	if(echoMob)
		echoMob.AddComponent(/datum/component/afterimage/image_based/timegun, 10, 3, src.aimer.mob)

/datum/component/holdertargeting/windup/timegun/end_shootloop(mob/living/user, object, location, control, params)
	. = ..()
	echoMob?.RemoveComponentsOfType(/datum/component/afterimage/image_based/timegun)
	echoMob = null


/obj/item/gun/energy/timegun
	name = "\improper Time Gun"
	desc = "Hey look! A Time Gun!"
	w_class = W_CLASS_SMALL
	icon_state = "optio_1"
	item_state = "protopistol"
	cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer
	from_frame_cell_type = /obj/item/ammo/power_cell/self_charging/ntso_signifer/bad
	can_swap_cell = 0
	color = COLOR_MATRIX_INVERSE

	New()
		set_current_projectile(new/datum/projectile/special/timegun/theBulletThatShootsTheFuture)
		projectiles = list(current_projectile, new/datum/projectile/special/timegun/theBulletThatShootsThePast)
		..()

	set_current_projectile(datum/projectile/newProj)
		. = ..()
		if(istype(newProj, /datum/projectile/special/timegun/theBulletThatShootsThePast))
			AddComponent(/datum/component/holdertargeting/windup/timegun, 0.5 SECONDS)
		else
			RemoveComponentsOfType(/datum/component/holdertargeting/windup/timegun)

	proc/set_followup_proj(datum/projectile/proj_data)
		for(var/datum/projectile/special/timegun/ts in src.projectiles)
			ts.followup = proj_data

/*todo to clean up atom prop define readability (linter does not handle the ##update correctly, and there's no way to sanely unlint this mess afaik)
#define DEFINE #define
#define DEFINE_PROP(name, method, update...) DEFINE PROP_##name(x) x(#name, APPLY_ATOM_PROPERTY_##method, REMOVE_ATOM_PROPERTY_##method, ##update)
*/
