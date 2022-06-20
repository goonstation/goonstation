/// # Flock Structure Parent
ABSTRACT_TYPE(/obj/flock_structure)
/obj/flock_structure
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "egg"
	anchored = TRUE
	density = TRUE
	name = "uh oh"
	desc = "CALL A CODER THIS SHOULDN'T BE SEEN"
	///Shown on the TGUI tooltip for the structure
	var/flock_desc = "THIS ALSO SHOULDN'T BE SEEN AAAA"
	flags = USEDELAY
	mat_changename = FALSE
	mat_changedesc = FALSE
	mat_appearances_to_ignore = list("gnesis")
	var/flock_id = "ERROR"
	/// when did we get created?
	var/time_started = 0
	var/build_time = 6 // in seconds
	var/health = 30
	var/health_max = 30
	var/bruteVuln = 1.2
	///Should it twitch on being hit?
	var/hitTwitch = TRUE

	var/fireVuln = 0.2
	var/datum/flock/flock = null
	//base compute provided
	var/compute = 0
	//resource cost for building
	var/resourcecost = 50
	/// can flockdrones pass through this akin to a grille? need to set USE_CANPASS to make this work however
	var/passthrough = FALSE
	/// TIME of last process
	var/last_process
	/// normal expected tick spacing
	var/tick_spacing = FLOCK_PROCESS_SCHEDULE_INTERVAL
	/// maximum allowed tick spacing for mult calculations due to lag
	var/cap_tick_spacing = FLOCK_PROCESS_SCHEDULE_INTERVAL * 5

/obj/flock_structure/New(var/atom/location, var/datum/flock/F=null)
	..()
	START_TRACKING_CAT(TR_CAT_FLOCK_STRUCTURE)
	last_process = TIME
	health_max = health
	time_started = world.timeofday
	setMaterial(getMaterial("gnesis"))
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, "flock_structure")

	if(F)
		src.flock = F
		src.flock.registerStructure(src)

	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

/obj/flock_structure/disposing()
	STOP_TRACKING_CAT(TR_CAT_FLOCK_STRUCTURE)
	if (flock)
		flock.removeStructure(src)
	flock = null
	..()

/obj/flock_structure/proc/describe_state()
	var/list/state = list()
	state["ref"] = "\ref[src]"
	state["name"] = src.flock_id
	state["health"] = src.health
	state["compute"] = src.compute_provided()
	state["desc"] = src.flock_desc
	var/area/myArea = get_area(src)
	if(isarea(myArea))
		state["area"] = myArea.name
	else
		state["area"] = "???"
	return state

/obj/flock_structure/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	var/special_desc = {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [flock_id]
		<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none"]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%"}
	var/info = building_specific_info()
	if(!isnull(info))
		special_desc += "<br>[info]"
	special_desc += "<br><span class='bold'>###=-</span></span>"
	return special_desc

//override this if compute is conditional or something
/obj/flock_structure/proc/compute_provided()
	return src.compute

/obj/flock_structure/proc/building_specific_info()
	return ""

/obj/flock_structure/proc/process(var/mult)
	// override

/// multipler for flock loop, used to compensate for lag
/obj/flock_structure/proc/get_multiplier()
	. = clamp(TIME - last_process, tick_spacing, cap_tick_spacing) / tick_spacing

/obj/flock_structure/proc/takeDamage(var/damageType, var/amount)
	switch(damageType)
		if("brute")
			amount *= bruteVuln
		if("burn")
			amount *= fireVuln
		if("fire")
			amount *= fireVuln
		if("mixed")
			var/half = round(amount/2)
			amount = half * bruteVuln + (amount - half) * fireVuln
	health -= amount
	checkhealth()

/obj/flock_structure/proc/checkhealth()
	if(src.health <= 0)
		src.gib()

/obj/flock_structure/proc/deconstruct()
	visible_message("<span class='alert'>[src.name] suddenly dissolves!</span>")
	var/refund = round((src.health/src.health_max) * 0.5 * src.resourcecost)
	if(refund >= 1)
		var/obj/item/flockcache/cache = new(get_turf(src))
		cache.resources = refund
	qdel(src)


/obj/flock_structure/proc/gib(atom/location)
	// no parent calling, we're going to completely override this
	if (!location)
		location = get_turf(src)
	visible_message("<span class='alert'>[src.name] violently breaks apart!</span>")
	playsound(location, 'sound/impact_sounds/Glass_Shatter_2.ogg', 50, 1)
	flockdronegibs(location)
	var/num_pieces = rand(2,8)
	var/atom/movable/B
	for(var/i=1 to num_pieces)
		switch(rand(100))
			if(0 to 50)
				B = new /obj/item/raw_material/scrap_metal
				B.set_loc(location)
				B.setMaterial(getMaterial("gnesis"))
			if(51 to 100)
				B = new /obj/item/raw_material/shard
				B.set_loc(location)
				B.setMaterial(getMaterial("gnesisglass"))
		if(prob(30))
			B.throw_at(get_edge_cheap(location, pick(alldirs)), rand(10), 3)
	qdel(src)

/obj/flock_structure/proc/repair()
	src.health = min(src.health + 50, src.health_max)

/obj/flock_structure/attack_hand(var/mob/user)
	attack_particle(user, src)
	user.lastattacked = src

	if(user.a_intent == INTENT_HARM)
		if(isflockmob(user))
			boutput(user, "<span class='alert'>You find you can't bring yourself to harm [src]!</span>")
		else
			user.visible_message("<span class='alert'><b>[user]</b> punches [src]! It's very ineffective!</span>")
			src.report_attack()
			src.takeDamage("brute", 1)
			playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 50, 1)

	else
		var/action = ""
		switch(user.a_intent)
			if(INTENT_HELP)
				action = "pats"
			if(INTENT_DISARM)
				action = "pushes"
			if(INTENT_GRAB)
				action = "squeezes"
		src.visible_message("<span class='alert'><b>[user]</b> [action] [src], but nothing happens.</span>")

/obj/flock_structure/attackby(obj/item/W, mob/user)
	src.visible_message("<span class='alert'><b>[user]</b> attacks [src] with [W]!</span>")
	src.report_attack()
	attack_particle(user, src)
	user.lastattacked = src

	var/damtype = "brute"
	if (W.hit_type == DAMAGE_BURN)
		damtype = "fire"

	takeDamage(damtype, W.force)
	if (src.hitTwitch)
		hit_twitch(src)
	if (W.force < 5)
		playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 50, 1)
	else
		playsound(src.loc, "sound/impact_sounds/Glass_Shards_Hit_1.ogg", 50, 1)


/obj/flock_structure/proc/report_attack()
	if (!ON_COOLDOWN(src, "attack_alert", 10 SECONDS))
		flock_speak(src, "ALERT: Under attack", flock)

/obj/flock_structure/ex_act(severity)
	src.report_attack()

	var/damage = 0
	var/damage_mult = 1
	switch(severity)
		if(1)
			damage = rand(30,50)
			damage_mult = 8
		if(2)
			damage = rand(25,40)
			damage_mult = 4
		if(3)
			damage = rand(10,20)
			damage_mult = 2
	src.takeDamage("mixed", damage * damage_mult)

/obj/flock_structure/bullet_act(obj/projectile/P)
	if (istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		return

	src.report_attack()

	var/damage = round((P.power*P.proj_data.ks_ratio), 1.0) // stuns will do nothing
	var/damage_mult = 1
	var/damtype = "brute"
	if (damage < 1)
		return

	switch(P.proj_data.damage_type)
		if(D_KINETIC)
			damage_mult = 1
			damtype = "brute"
		if(D_PIERCING)
			damage_mult = 0.5
			damtype = "brute"
		if(D_ENERGY)
			damage_mult = 0.8
			damtype = "burn"
		if(D_BURNING)
			damage_mult = 0.6
			damtype = "burn"
		if(D_SLASHING)
			damage_mult = 0.8
			damtype = "brute"

	src.takeDamage(damtype, damage * damage_mult)
	return


/obj/flock_structure/blob_act(var/power)
	src.visible_message("<span class='alert'>[src] is hit by the blob!/span>")
	src.report_attack()

	var/modifier = power / 20
	var/damage = rand(modifier, 12 + 8 * modifier)

	takeDamage("mixed", damage)

/obj/flock_structure/Crossed(atom/movable/mover)
	. = ..()
	var/mob/living/critter/flock/drone/drone = mover
	if(src.passthrough && istype(drone) && !drone.floorrunning)
		animate_flock_passthrough(mover)
		. = TRUE
	else if(istype(mover,/mob/living/critter/flock))
		. = TRUE

/obj/flock_structure/Cross(atom/movable/mover)
	return istype(mover,/mob/living/critter/flock)
