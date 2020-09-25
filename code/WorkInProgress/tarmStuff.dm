//GUNS GUNS GUNS
/obj/item/gun/kinetic/light_machine_gun/fullauto
	name = "M91 machine gun"
	desc = "Looks pretty heavy to me. Hold shift to begin automatic fire!"
	icon = 'icons/obj/64x32.dmi'
	slowdown = 0
	var/shooting = 0
	var/turf/target = null

	New()
		..()
		ammo.amount_left=1000
		AddComponent(/datum/component/holdertargeting/fullauto, 4 DECI SECONDS, 1.5 DECI SECONDS, 0.5)


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
	name = "aimbot pistol"
	silenced = 1

	shoot(target, start, mob/user, POX, POY) //checks clicked turf first, so you can choose a target if need be
		for(var/mob/M in range(2, target))
			if(M == user || istype(M.get_id(), /obj/item/card/id/syndicate)) continue
			..(get_turf(M), start, user, POX, POY)
			return
		..()

/obj/item/gun/kinetic/pistol/smart
	name = "smart pistol"
	silenced = 1
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
			if(IN_RANGE(user, M, 7) && in_cone_of_vision(user, M) && !(targets[M] >= maxlocks || istype(M.get_id(), /obj/item/card/id/syndicate)) && shotcount < checkshots(G))
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
	name = "gyrojet pistol"
	desc = "A semi-automatic pistol that fires rocket-propelled bullets"
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
	shot_volume = 2
	ks_ratio = 1
	icon_turf_hit = "bhole-small"

	on_launch(obj/projectile/O)
		O.internal_speed = projectile_speed

	tick(obj/projectile/O)
		O.internal_speed = min(O.internal_speed * 1.15, 56)

	get_power(obj/projectile/P, atom/A)
		return 10 + P.internal_speed

//desert eagle. The biggest, baddest handgun
/obj/item/gun/kinetic/deagle
	name = "\improper Desert Eagle"
	desc = "The heaviest handgun you've ever seen. Is this legal?"
	icon_state = "deag"
	item_state = "deag"
	force = 12.0 //mmm, pistol whip
	throwforce = 30 //HEAVY pistol
	auto_eject = 1
	max_ammo_capacity = 7
	caliber = list(0.50, 0.41, 0.357, 0.38) //the omnihandgun
	has_empty_state = 1
	gildable = 1

	New()
		current_projectile = new/datum/projectile/bullet/deagle50cal
		ammo = new/obj/item/ammo/bullets/deagle50cal
		. = ..()

	//gimmick deagle that decapitates
	decapitation
		New()
			. = ..()
			current_projectile = new/datum/projectile/bullet/deagle50cal/decapitation
			ammo = new/obj/item/ammo/bullets/deagle50cal/decapitation

//.50AE deagle ammo
/obj/item/ammo/bullets/deagle50cal
	sname = "0.50 AE"
	name = "desert eagle magazine"
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
			var/currentench = 0
			var/success = 0
			var/incr = 0
			if(istype(I, /obj/item/clothing))
				currentench = I.getProperty("enchantarmor")
				if(currentench <= 2 || !rand(0, currentench))
					incr = (currentench <= 2) ? rand(1, 3) : 1
					I.setProperty("enchantarmor", currentench+incr)
					success = 1
			else
				currentench = I.getProperty("enchantweapon")
				if(currentench <= 2 || !rand(0, currentench))
					incr = (currentench <= 2) ? rand(1, 3) : 1
					I.setProperty("enchantweapon", currentench+incr)
					success = 1
			if(success)
				var/turf/T = get_turf(target)
				playsound(T, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 1)
				user.visible_message("<span class='notice'>As [user] slaps \the [src] onto \the [target], \the [target] glows with a faint light[(currentench+incr >= 3) ? " and vibrates violently!" : "."]</span>")
				I.remove_prefixes("+[currentench]")
				I.name_prefix("+[currentench+incr]")
				I.rarity = max(I.rarity, round((currentench+incr+1)/2) + 2)
				I.tooltip_rebuild = 1
				I.UpdateName()
			else
				user.visible_message("<span class='notice'>As [user] brings \the [src] towards \the [target], \the [target] shudders violently and turns to dust!</span>")
				qdel(I)
			qdel(src)
		else
			return ..()

/obj/item/proc/enchant(incr)
	var/currentench = 0
	if(istype(src, /obj/item/clothing))
		currentench = src.getProperty("enchantarmor")
		src.setProperty("enchantarmor", currentench+incr)
	else
		currentench = src.getProperty("enchantweapon")
		src.setProperty("enchantweapon", currentench+incr)
	src.remove_prefixes("[currentench>0?"+":""][currentench]")
	if(currentench+incr)
		src.name_prefix("[(currentench+incr)>0?"+":""][currentench+incr]")
		src.rarity = max(src.rarity, round((currentench+incr+1)/2) + 2)
	else
		src.rarity = initial(src.rarity)
	src.tooltip_rebuild = 1
	src.UpdateName()

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
	playsound(src.loc, "sound/voice/screams/fescream3.ogg", 50, 1)
	. = ..()

/obj/machinery/door/unpowered/wood/lily/close()
	playsound(src.loc, "sound/voice/screams/robot_scream.ogg", 50, 1)
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
