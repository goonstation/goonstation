/////////////////////////////////////////////////////////////////////////////////
// FLOCK STRUCTURE PARENT
/////////////////////////////////////////////////////////////////////////////////
/obj/flock_structure
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "egg"
	anchored = 1
	density = 1
	name = "uh oh"
	desc = "CALL A CODER THIS SHOULDN'T BE SEEN"
	var/flock_id = "ERROR"
	var/time_started = 0 // when did we get created?
	var/build_time = 6 // in seconds
	var/health = 30 // fragile little thing
	var/health_max
	var/bruteVuln = 1.2
	var/fireVuln = 0.2 // very flame-retardant
	var/datum/flock/flock = null
	var/poweruse = 0 //does this use(/how much) power? (negatives mean it makes power)
	var/usesgroups = 0 //not everything needs a group so dont check for everysingle god damn structure
	var/datum/flock_tile_group/group = null //what group are we connected to?
	var/turf/simulated/floor/feather/grouptile = null //the tile which its "connected to" and handles the group

/obj/flock_structure/New(var/atom/location, var/datum/flock/F=null)
	..()
	health_max = health
	time_started = world.timeofday
	processing_items |= src
	if(F)
		src.flock = F
	if(usesgroups && istype(get_turf(src), /turf/simulated/floor/feather))
		var/turf/simulated/floor/feather/f = get_turf(src)
		grouptile = f
		group = f.group
		f.group.addstructure(src)

/obj/flock_structure/disposing()
	processing_items -= src
	flock = null
	group = null
	..()

/obj/flock_structure/special_desc(dist, mob/user)
	if(isflock(user))
		var/special_desc = {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [flock_id]
		<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none"]
		<br><span class='bold'>System Integrity:</span> [round((src.health/src.health_max)*100)]%"}
		var/info = building_specific_info()
		if(!isnull(info))
			special_desc += "<br>[info]"
		special_desc += "<br><span class='bold'>###=-</span></span>"
		return special_desc
	else
		return null // give the standard description

/obj/flock_structure/proc/building_specific_info()
	return ""

/obj/flock_structure/proc/process()
	// override

/obj/flock_structure/proc/groupcheck() //rechecks if the tile under's group matches its own
	if(!usesgroups) return
	if(istype(get_turf(src), /turf/simulated/floor/feather))
		var/turf/simulated/floor/feather/f = get_turf(src)
		if(src.grouptile == f && grouptile.group == src.group) return//no changes its all good
		else if(!src.grouptile == f && f.group == src.group)//if the grouptile is different but the groups the same
			src.grouptile = f//just move the connected tile, this should really rarely happen if the structure is moved somehow
		else if(!src.grouptile == f && !f.group == src.group)//if both stuff is different.
			src.grouptile = f
			src.group?.removestructure(src)
			src.group = f.group
			src.group.addstructure(src)
		else if(src.grouptile == f && !grouptile.group == src.group)//if just the tile's group is different
			src.group?.removestructure(src)
			src.group = grouptile.group
			src.group.addstructure(src)

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
	checkhealth() // die if necessary

/obj/flock_structure/proc/checkhealth()
	if(src.health <= 0)
		src.gib()

/obj/flock_structure/proc/gib(atom/location)
	// no parent calling, we're going to completely override this
	if (!location)
		location = get_turf(src)
	visible_message("<span class='alert'>[src.name] violently breaks apart!</span>")
	playsound(location, 'sound/impact_sounds/Glass_Shatter_2.ogg', 80, 1)
	flockdronegibs(location)
	var/num_pieces = rand(2,8)
	var/atom/movable/B
	for(var/i=1 to num_pieces)
		switch(rand(100))
			if(0 to 50)
				B = unpool(/obj/item/raw_material/scrap_metal)
				B.set_loc(location)
				B.setMaterial(getMaterial("gnesis"))
			if(51 to 100)
				B = unpool(/obj/item/raw_material/shard)
				B.set_loc(location)
				B.setMaterial(getMaterial("gnesisglass"))
		if(prob(30))
			B.throw_at(get_edge_cheap(location, pick(alldirs)), rand(10), 3)
	src.flock?.removeDrone(src)
	qdel(src)

/obj/flock_structure/attack_hand(var/mob/user)
	if(user.a_intent == INTENT_HARM)
		if(isflock(user))
			boutput(user, "<span class='alert'>You find you can't bring yourself to harm [src]!</span>")
		else
			user.visible_message("<span class='alert'><b>[user]</b> punches [src]! It's very ineffective!</span>")
			playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 80, 1)
			src.takeDamage("brute", 1)
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

/obj/flock_structure/attackby(obj/item/W as obj, mob/user as mob)
	src.visible_message("<span class='alert'><b>[user]</b> attacks [src] with [W]!</span>")
	playsound(src.loc, "sound/impact_sounds/Crystal_Hit_1.ogg", 80, 1)

	var/damtype = "brute"
	if (W.hit_type == DAMAGE_BURN)
		damtype = "fire"

	takeDamage(damtype, W.force)

/obj/flock_structure/ex_act(severity)
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

/obj/flock_structure/bullet_act(var/obj/projectile/P)
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
	var/modifier = power / 20
	var/damage = rand(modifier, 12 + 8 * modifier)

	takeDamage("mixed", damage)
	src.visible_message("<span class='alert'>[src] is hit by the blob!/span>")
