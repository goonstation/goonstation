/// # Flock Structure Parent
ABSTRACT_TYPE(/obj/flock_structure)
TYPEINFO(/obj/flock_structure)
	var/cancellable = TRUE
	mat_appearances_to_ignore = list("gnesis")
/obj/flock_structure
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "egg"
	anchored = ANCHORED
	density = TRUE
	name = "uh oh"
	desc = "CALL A CODER THIS SHOULDN'T BE SEEN"
	/// Shown on the TGUI tooltip for the structure
	var/flock_desc = "THIS ALSO SHOULDN'T BE SEEN AAAA"
	/// The actual name of the structure shown to the flock
	var/flock_id = "ERROR"
	/// Does this structure show up in the list of flock structures shown in the tutorial?
	var/show_in_tutorial = FALSE
	var/tutorial_desc = ""
	flags = USEDELAY
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"
	/// when did we get created?
	var/time_started = 0
	var/build_time = 6 // in seconds
	var/health = 30
	var/health_max = 30
	var/repair_per_resource = 5
	var/uses_health_icon = TRUE
	var/bruteVuln = 1.2
	///Should it twitch on being hit?
	var/hitTwitch = TRUE

	var/atom/movable/name_tag/flock_examine_tag/info_tag

	var/fireVuln = 0.2
	var/tmp/datum/flock/flock = null
	///base compute provided. negative amount means it uses compute
	var/compute = 0
	/// compute required to stay online
	var/online_compute_cost = 0
	///resource cost for building
	var/resourcecost = 0
	/// can flockdrones pass through this akin to a grille?
	var/passthrough = TRUE
	/// if the building can be supported by a sapper structure
	var/accepts_sapper_power = FALSE
	/// TIME of last process
	var/last_process
	/// normal expected tick spacing
	var/tick_spacing = FLOCK_PROCESS_SCHEDULE_INTERVAL
	/// maximum allowed tick spacing for mult calculations due to lag
	var/cap_tick_spacing = FLOCK_PROCESS_SCHEDULE_INTERVAL * 5

/obj/flock_structure/New(var/atom/location, var/datum/flock/F, atom/param)
	..()
	START_TRACKING_CAT(TR_CAT_FLOCK_STRUCTURE)
	last_process = TIME
	health_max = health
	time_started = world.timeofday
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, "flock_structure")

	src.flock = F || get_default_flock()
	src.flock.registerStructure(src)

	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

	src.info_tag = new
	src.info_tag.set_name(src.flock_id)
	src.vis_contents += src.info_tag

	src.update_health_icon()

/obj/flock_structure/disposing()
	STOP_TRACKING_CAT(TR_CAT_FLOCK_STRUCTURE)
	if (flock)
		src.update_health_icon()
		flock.removeStructure(src)
	flock = null
	qdel(src.info_tag)
	src.info_tag = null
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
	var/special_desc = {"[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
		[SPAN_BOLD("ID:")] [flock_id]<br>\
		[SPAN_BOLD("Flock:")] [src.flock ? src.flock.name : "none"]<br>\
		[SPAN_BOLD("System Integrity:")] [round((src.health/src.health_max)*100)]%<br>"}
	var/info = building_specific_info()
	if(!isnull(info))
		special_desc += "<br>[info]"
	special_desc += "[SPAN_BOLD("###=-")]"
	return special_desc

//override this if compute is conditional or something
/obj/flock_structure/proc/compute_provided()
	return src.compute

/obj/flock_structure/proc/update_flock_compute(application, update_hud_compute = TRUE)
	if (!src.compute)
		return
	if (application == "apply")
		if (src.compute < 0)
			src.flock.used_compute += abs(src.compute)
		else
			src.flock.total_compute += src.compute
	else if (application == "remove")
		if (src.compute < 0)
			src.flock.used_compute -= abs(src.compute)
		else
			src.flock.total_compute -= src.compute
	if (update_hud_compute)
		src.flock.update_computes()

/obj/flock_structure/proc/building_specific_info()
	return ""

/obj/flock_structure/proc/process(var/mult)
	// override

/// overridable checks for if we should skip processing this cycle
/obj/flock_structure/proc/skip_process()
	return FALSE

/obj/flock_structure/proc/isEnemy(atom/A)
	return src.flock.isEnemy(A)

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
	src.update_health_icon()
	if(src.health <= 0)
		src.gib()

/obj/flock_structure/proc/update_health_icon()
	if (!src.flock)
		return
	if (!src.uses_health_icon)
		return
	if (src.health <= 0 || src.disposed)
		src.flock.removeAnnotation(src, FLOCK_ANNOTATION_HEALTH)
		return

	var/list/annotations = flock.getAnnotations(src)
	if (!annotations[FLOCK_ANNOTATION_HEALTH])
		src.flock.addAnnotation(src, FLOCK_ANNOTATION_HEALTH)
	var/image/annotation = annotations[FLOCK_ANNOTATION_HEALTH]
	annotation.icon_state = "hp-[round(src.health / src.health_max * 10) * 10]"

/obj/flock_structure/MouseEntered(location, control, params)
	var/mob/M = usr
	M.atom_hovered_over = src
	if(M.client.check_key(KEY_EXAMINE))
		var/atom/movable/name_tag/tag_to_show = src.get_examine_tag(M)
		tag_to_show?.show_images(M.client, FALSE, TRUE)

/obj/flock_structure/MouseExited(location, control, params)
	var/mob/M = usr
	M.atom_hovered_over = null
	var/atom/movable/name_tag/tag_to_show = src.get_examine_tag(M)
	tag_to_show?.show_images(M.client, M.client.check_key(KEY_EXAMINE) && HAS_ATOM_PROPERTY(M, PROP_MOB_EXAMINE_ALL_NAMES) ? TRUE : FALSE, FALSE)

/obj/flock_structure/get_examine_tag(mob/examiner)
	if (!src.flock || !(istype(usr, /mob/living/intangible/flock) || istype(usr, /mob/living/critter/flock/drone)))
		return null
	if (istype(examiner, /mob/living/intangible/flock))
		var/mob/living/intangible/flock/flock_intangible = examiner
		if (src.flock != flock_intangible.flock)
			return null
	if (istype(examiner, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/flockdrone = examiner
		if (src.flock != flockdrone.flock)
			return null
	return src.info_tag

/obj/flock_structure/proc/deconstruct()
	visible_message(SPAN_ALERT("[src.name] suddenly dissolves!"))
	var/refund = round((src.health/src.health_max) * 0.5 * src.resourcecost)
	if(refund >= 1)
		var/obj/item/flockcache/cache = new(get_turf(src))
		cache.resources = refund
	qdel(src)


/obj/flock_structure/proc/gib(atom/location)
	// no parent calling, we're going to completely override this
	if (!location)
		location = get_turf(src)
	visible_message(SPAN_ALERT("[src.name] violently breaks apart!"))
	playsound(location, 'sound/impact_sounds/Glass_Shatter_2.ogg', 50, TRUE)
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

/obj/flock_structure/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given
	src.update_health_icon()
	return ceil(health_given / src.repair_per_resource)

/obj/flock_structure/proc/sapper_power()
	return src.accepts_sapper_power

/obj/flock_structure/attack_hand(var/mob/user)
	attack_particle(user, src)
	user.lastattacked = get_weakref(src)

	if(user.a_intent == INTENT_HARM)
		if(isflockmob(user))
			boutput(user, SPAN_ALERT("You find you can't bring yourself to harm [src]!"))
		else
			user.visible_message(SPAN_ALERT("<b>[user]</b> punches [src]! It's very ineffective!"))
			src.report_attack()
			src.takeDamage("brute", 1)
			playsound(src.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, 1)

	else
		var/action = ""
		switch(user.a_intent)
			if(INTENT_HELP)
				action = "pats"
			if(INTENT_DISARM)
				action = "pushes"
			if(INTENT_GRAB)
				action = "squeezes"
		src.visible_message(SPAN_ALERT("<b>[user]</b> [action] [src], but nothing happens."))

/obj/flock_structure/attackby(obj/item/W, mob/user)
	src.visible_message(SPAN_ALERT("<b>[user]</b> attacks [src] with [W]!"))
	src.report_attack()
	attack_particle(user, src)
	user.lastattacked = get_weakref(src)

	var/damtype = "brute"
	if (W.hit_type == DAMAGE_BURN)
		damtype = "fire"

	takeDamage(damtype, W.force)
	if (src.hitTwitch)
		hit_twitch(src)
	if (W.force < 5)
		playsound(src.loc, 'sound/impact_sounds/Crystal_Hit_1.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/impact_sounds/Glass_Shards_Hit_1.ogg', 50, 1)


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
	src.visible_message(SPAN_ALERT("[src] is hit by the blob!"))
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
	return istype(mover,/mob/living/critter/flock) && src.passthrough
