//GUNS GUNS GUNS
/obj/item/gun/kinetic/g11
	name = "\improper Manticore assault rifle"
	desc = "An assault rifle capable of firing single precise bursts. The magazines holders are embossed with \"Anderson Para-Munitions\""
	icon = 'icons/obj/48x32.dmi'
	icon_state = "g11"
	item_state = "g11"
	has_empty_state = 1
	var/shotcount = 0
	var/last_shot_time = 0
	uses_multiple_icon_states = 1
	force = 15.0
	contraband = 8
	caliber = 0.185
	max_ammo_capacity = 45
	can_dual_wield = 0
	two_handed = 1
	var/datum/projectile/bullet/g11/small/smallproj = new

	New()
		current_projectile = new/datum/projectile/bullet/g11
		ammo = new/obj/item/ammo/bullets/g11
		. = ..()

	shoot(var/target,var/start,var/mob/user,var/POX,var/POY)
		spread_angle = max(0, shoot_delay*2+last_shot_time-TIME)*0.4
		shotcount = 0
		. = ..(target, start, user, POX+rand(-spread_angle, spread_angle)*16, POY+rand(-spread_angle, spread_angle)*16)
		last_shot_time = TIME

	shoot_point_blank(mob/M, mob/user, second_shot)
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
	amount_left = 45.0
	max_amount = 45.0
	caliber = 0.185
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
	power = 60
	ks_ratio = 1.0
	hit_ground_chance = 100
	damage_type = D_KINETIC
	hit_type = DAMAGE_CUT
	shot_number = 3
	shot_delay = 0.4
	shot_sound = 'sound/weapons/gunshot.ogg'
	shot_volume = 66
	caliber = 0.185
	dissipation_delay = 10
	dissipation_rate = 5
	icon_turf_hit = "bhole-small"

	small
		shot_sound = 'sound/weapons/9x19NATO.ogg'
		shot_volume = 50
		power = 15
		hit_ground_chance = 33

	void
		power = 30
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
		power = 15
		damage_type = D_KINETIC
		hit_type = DAMAGE_BLUNT
		on_hit(atom/hit, angle, obj/projectile/O)
			explosion_new(O, get_turf(hit), 2)

/mob/living/proc/betterdir()
	return ((src.dir in ordinal) || (src.last_move_dir in cardinal)) ? src.dir : src.last_move_dir

/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_LIVING_SPRINT_START)
	mobtype = /mob/living
	proctype = .proc/begin_shootloop
	var/turf/target
	var/shooting
	var/delaystart
	var/delaymin
	var/rampfactor
	var/obj/item/gun/G

	Initialize(_delaystart = 4 DECI SECONDS, _delaymin=1 DECI SECOND, _rampfactor=0.9)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			G = parent
			src.delaystart = _delaystart
			src.delaymin = _delaymin
			src.rampfactor = _rampfactor
	on_dropped(datum/source, mob/user)
		. = ..()
		src.shooting = 0

/datum/component/holdertargeting/fullauto/proc/begin_shootloop(mob/living/user)
	if(!shooting)
		shooting = 1
		target = null
		G.current_projectile.shot_number = 1
		G.current_projectile.cost = 1
		G.current_projectile.shot_delay = 1.5
		APPLY_MOB_PROPERTY(user, PROP_CANTSPRINT, G)
		RegisterSignal(user, COMSIG_MOB_CLICK, .proc/retarget)
		SPAWN_DBG(0)
			src.shootloop(user)

/datum/component/holdertargeting/fullauto/proc/retarget(mob/M, atom/target, params)
	if(istype(target))
		src.target = get_turf(target)
		G.suppress_fire_msg = 0
		return RETURN_CANCEL_CLICK

/datum/component/holdertargeting/fullauto/proc/shootloop(mob/living/L)
	var/delay = delaystart
	while(shooting && G.canshoot() && L?.client.check_key(KEY_RUN))
		G.shoot(target ? target : get_step(L, L.betterdir()), get_turf(L), L)
		G.suppress_fire_msg = 1
		sleep(max(delay*=rampfactor, delaymin))
	//loop ended - reset values
	shooting = 0
	REMOVE_MOB_PROPERTY(L, PROP_CANTSPRINT, G)
	G.current_projectile.shot_number = initial(G.current_projectile.shot_number)
	G.current_projectile.cost = initial(G.current_projectile.cost)
	G.current_projectile.shot_delay = initial(G.current_projectile.shot_delay)
	G.suppress_fire_msg = 0
	UnregisterSignal(L, COMSIG_MOB_CLICK)



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
		AddComponent(/datum/component/holdertargeting/smartgun, 3)

/datum/component/holdertargeting/smartgun
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_LIVING_SPRINT_START)
	mobtype = /mob/living
	proctype = .proc/begin_targetloop
	var/turf/target
	var/list/targets = list()
	var/targetting = 0
	var/shooting = 0
	var/maxlocks
	var/obj/item/gun/G

	Initialize(_maxlocks = 3)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			G = parent
		maxlocks = _maxlocks

	on_dropped(datum/source, mob/user)
		. = ..()
		src.shooting = 0
		src.targetting = 0
		src.targets.len = 0

/datum/component/holdertargeting/smartgun/proc/begin_targetloop(mob/living/user)
	if(!targetting)
		targetting = 1
		targets.len = 0
		APPLY_MOB_PROPERTY(user, PROP_CANTSPRINT, src)
		RegisterSignal(user, COMSIG_MOB_CLICK, .proc/shootemall)
		SPAWN_DBG(0)
			src.targetloop(user)

/datum/component/holdertargeting/smartgun/proc/shootemall(mob/user, atom/target, params)
	if(targetting && !shooting)
		SPAWN_DBG(0)
			shooting = 1
			shootloop:
				for(var/mob/M in targets)
					for(var/i in 1 to targets[M])
						if(!shooting || !G.canshoot())
							break shootloop
						G.shoot(get_turf(M),get_turf(user),user)
						sleep(1)
			targets.len = 0
			shooting = 0
		return RETURN_CANCEL_CLICK

/datum/component/holdertargeting/smartgun/proc/targetloop(mob/living/user)
	var/ding = 0
	var/shotcount = 0
	while(targetting)
		sleep(1 SECOND)
		ding = 0
		for(var/mob/M in mobs)
			if(!G || !(user?.client.check_key(KEY_RUN)))
				targetting = 0
				break
			if(IN_RANGE(user, M, 7) && isliving(M) && in_cone_of_vision(user, M) && !(targets[M] >= maxlocks || istype(M.get_id(), /obj/item/card/id/syndicate)) && shotcount < checkshots(G))
				targets[M] = targets[M] ? targets[M] + 1 : 1
				ding = 1
				shotcount++
				continue
		if(ding)
			user.playsound_local(user, "sound/machines/chime.ogg", 5, 0)
	//loop ended - reset values
	REMOVE_MOB_PROPERTY(user, PROP_CANTSPRINT, src)
	UnregisterSignal(user, COMSIG_MOB_CLICK)

/datum/component/holdertargeting/smartgun/proc/checkshots(obj/item/gun/G)
	if(istype(G, /obj/item/gun/kinetic))
		var/obj/item/gun/kinetic/K = G
		return round(K.ammo.amount_left * K.current_projectile.cost)
	else if(istype(G, /obj/item/gun/energy))
		var/obj/item/gun/energy/E = G
		return round(E.cell.charge * E.current_projectile.cost)
	else return G.canshoot() * INFINITY //idk, just let it happen

/obj/item/gun/kinetic/gyrojet
	name = "Amaethon gyrojet pistol"
	desc = "A semi-automatic handgun that fires rocket-propelled bullets, developed by Mabinogi Firearms Company."
	icon_state = "gyrojet"
	item_state = "gyrojet"
	caliber = 0.512
	max_ammo_capacity = 6
	has_empty_state = 1

	New()
		ammo = new/obj/item/ammo/bullets/gyrojet
		current_projectile = new/datum/projectile/bullet/gyrojet
		. = ..()

/obj/item/ammo/bullets/gyrojet
	sname = "13mm Gyrojet"
	name = "gyrojet magazine"
	icon_state = "pistol_magazine"
	amount_left = 6.0
	max_amount = 6.0
	ammo_type = new/datum/projectile/bullet/gyrojet
	caliber = 0.512

/datum/projectile/bullet/gyrojet
	name = "gyrojet bullet"
	projectile_speed = 5
	max_range = 500
	dissipation_rate = 0
	power = 10
	precalculated = 0
	caliber = 0.512
	shot_volume = 100
	shot_sound = 'sound/weapons/gyrojet.ogg'
	ks_ratio = 1
	icon_turf_hit = "bhole-small"

	on_launch(obj/projectile/O)
		O.internal_speed = projectile_speed

	tick(obj/projectile/O)
		O.internal_speed = min(O.internal_speed * 1.25, 56)

	get_power(obj/projectile/P, atom/A)
		return 10 + P.internal_speed

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
	caliber = list(0.50, 0.41, 0.357, 0.38, 0.355, 0.22) //the omnihandgun
	has_empty_state = 1
	gildable = 1

	New()
		current_projectile = new/datum/projectile/bullet/deagle50cal
		ammo = new/obj/item/ammo/bullets/deagle50cal
		. = ..()

	//gimmick deagle that decapitates
	decapitation
		force = 18.0 //mmm, pistol whip
		throwforce = 50 //HEAVY pistol
		New()
			. = ..()
			current_projectile = new/datum/projectile/bullet/deagle50cal/decapitation
			ammo = new/obj/item/ammo/bullets/deagle50cal/decapitation

//.50AE deagle ammo
/obj/item/ammo/bullets/deagle50cal
	sname = "0.50 AE"
	name = "\improper Simurgh magazine"
	icon_state = "pistol_magazine"
	amount_left = 7.0
	max_amount = 7.0
	ammo_type = new/datum/projectile/bullet/deagle50cal
	caliber = 0.50

	//gimmick deagle ammo that decapitates
	decapitation
		ammo_type = new/datum/projectile/bullet/deagle50cal/decapitation

/datum/projectile/bullet/deagle50cal
	name = "bullet"
	power = 120
	dissipation_delay = 5
	dissipation_rate = 5
	ks_ratio = 1.0
	implanted = /obj/item/implant/projectile/bullet_50
	caliber = 0.50
	icon_turf_hit = "bhole-large"
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
	w_class = 2.0
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
			playsound(T, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
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
	icon = 'icons/obj/32x64.dmi'
	icon_state = "voting_box"
	density = 1
	flags = FPRINT
	anchored = 1.0
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
				ircbot.export("admin", ircmsg)
				taken_suggestion = 1
			user.u_equip(P)
			qdel(P)
			playsound(src.loc, "sound/machines/paper_shredder.ogg", 90, 1)
			var/turf/T = pick(floors)
			if(T)
				new /obj/decal/cleanable/paper(T)
		return ..()

//lily's office
obj/item/gun/reagent/syringe/lovefilled
	ammo_reagents = list("love")
	New()
		. = ..()
		src.reagents?.maximum_volume = 750
		src.reagents.add_reagent("love", src.reagents.maximum_volume)

/obj/item/storage/desk_drawer/lily/
	spawn_contents = list(	/obj/item/reagent_containers/food/snacks/cake,\
	/obj/item/reagent_containers/food/snacks/cake,\
	/obj/item/reagent_containers/food/snacks/yellow_cake_uranium_cake,\
	/obj/item/reagent_containers/food/snacks/cake/cream,\
	/obj/item/reagent_containers/food/snacks/cake/cream,\
	/obj/item/reagent_containers/food/snacks/cake/chocolate,\
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
	playsound(src.loc, "sound/voice/screams/fescream3.ogg", 50, 1, channel=VOLUME_CHANNEL_EMOTE)
	. = ..()

/obj/machinery/door/unpowered/wood/lily/close()
	playsound(src.loc, "sound/voice/screams/robot_scream.ogg", 50, 1, channel=VOLUME_CHANNEL_EMOTE)
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
/obj/item/device/geiger
	name = "geiger counter"
	desc = "A device used to passively measure raditation."
	icon_state = "geiger-0"
	item_state = "geiger"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	mats = 5

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
		if(!PROC_ON_COOLDOWN(30 SECONDS))
			for (var/mob/living/M in view(src, 5))
				if (M.bioHolder)
					M.bioHolder.AddEffect("cold_resist", 0, 45)
