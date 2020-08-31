/obj/item/gun/kinetic/light_machine_gun/fullauto
	name = "M90 machine gun"
	desc = "Looks pretty heavy to me. Hold shift to begin automatic fire!"
	icon = 'icons/obj/64x32.dmi'
	slowdown = 0
	var/shooting = 0
	var/turf/target = null

	New()
		..()
		ammo.amount_left=1000
		AddComponent(/datum/component/holdertargeting/fullauto)


/mob/living/proc/betterdir()
	return ((src.dir in ordinal) || (src.last_move_dir in cardinal)) ? src.dir : src.last_move_dir


/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_LIVING_SPRINT_START)
	mobtype = /mob/living
	proctype = .proc/begin_shootloop
	var/turf/target
	var/shooting
	var/delaystart = 4 DECI SECONDS
	var/delaymin = 1 DECI SECOND
	var/rampfactor = 0.9
	var/obj/item/gun/G

	Initialize()
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			G = parent

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
	src.target = get_turf(target)
	G.suppress_fire_msg = 0


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
	var/list/targets = list()
	var/targetting = 0

	dropped(mob/M)
		remove_self(M)
		..()

	proc/remove_self(var/mob/living/M)
		if (ishuman(M))
			UnregisterSignal(M, COMSIG_LIVING_SPRINT_START)
		src.targetting = 0

	attack_hand(mob/user as mob)
		if (..() && ishuman(user))
			RegisterSignal(user, COMSIG_LIVING_SPRINT_START, .proc/begin_targetloop)

	proc/begin_targetloop(mob/living/L)
		if(!targetting)
			targetting = 1
			targets.len = 0
			APPLY_MOB_PROPERTY(L, PROP_CANTSPRINT, src)
			SPAWN_DBG(0)
				src.targetloop(L)


	proc/targetloop(mob/living/L)
		var/ding = 0
		var/shotcount = 0
		while(targetting)
			sleep(1 SECOND)
			ding = 0
			for(var/mob/M in view(7, usr))
				if(!src || !(L?.client.check_key(KEY_RUN)))
					targetting = 0
					break
				if(in_cone_of_vision(usr, M) && !(targets[M] >= 3 || istype(M.get_id(), /obj/item/card/id/syndicate)) && shotcount < src.ammo.amount_left)
					targets[M] = targets[M] ? targets[M] + 1 : 1
					ding = 1
					shotcount++
					continue
			if(ding)
				L.playsound_local(L, "sound/machines/chime.ogg", 5, 0)
		//loop ended - reset values
		REMOVE_MOB_PROPERTY(L, PROP_CANTSPRINT, src)

	proc/validtarget(mob/M)
		return !(targets[M] >= 3 || istype(M.get_id(), /obj/item/card/id/syndicate))

	pixelaction(atom/target, params, mob/user, reach, continuousFire = 0)
		if(c_firing) return
		if(targetting)
			c_firing = 1
			for(var/mob/M in targets)
				for(var/i in 1 to targets[M])
					src.shoot(get_turf(M),get_turf(usr),usr)
					sleep(1)
			targets.len = 0
			c_firing = 0
		else
			..()

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
			else if(I.force >= 5)
				currentench = I.getProperty("enchantweapon")
				if(currentench <= 2 || !rand(0, currentench))
					incr = (currentench <= 2) ? rand(1, 3) : 1
					I.setProperty("enchantweapon", currentench+incr)
					success = 1
			else
				return ..()
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
	else if(src.force >= 5)
		currentench = src.getProperty("enchantweapon")
		src.setProperty("enchantweapon", currentench+incr)
	else
		return
	src.remove_prefixes("+[currentench]")
	src.name_prefix("+[currentench+incr]")
	src.rarity = max(src.rarity, round((currentench+incr+1)/2) + 2)
	src.tooltip_rebuild = 1
	src.UpdateName()