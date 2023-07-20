/obj/npc
	name = "NPC"
	icon = 'icons/misc/critter.dmi'
	var/status = 0
	var/mob/current_user = null
	anchored = ANCHORED
	density = 1
	var/health = 100 //how much health the npc has
	var/angry = 0 //Is the npc aggressive
	var/tradedir= 0 //What direction the npc drops items
	var/greeting = "Hello" //Greeting text when player first interacts with npc
	var/picture = "lizardman.png" //The name of the npc portrait
	var/alive = 1
	var/temp = null
	var/needstoprocess = 0 //Does the NPC need to process something
	var/patience = 6

/obj/npc/disposing()
	current_user = null
	..()
//Handles what happens when the NPC dies
/obj/npc/proc/death()
	alive = 0
	icon_state = icon_state + "-dead"
	density = 0
	src.desc= "[src] looks dead."
//Handles what happens when the npc becomes aggresive
/obj/npc/proc/anger()
	for(var/mob/M in AIviewers(src))
		boutput(M, "<span class='alert'><B>[src.name]</B> becomes angry!</span>")
	src.desc = "[src] looks angry"
	SPAWN(rand(1000,3000))
		src.visible_message("<b>[src.name] calms down.</b>")
		src.desc = "[src] looks a bit annoyed."
		src.angry = 0
	return

//What did you think traders wouldn't have protection?
/obj/npc/proc/activatesecurity()
	return
// New() and disposing() add and remove machines from the global "machines" list
// This list is used to call the process() proc for all machines ~1 per second during a round

/obj/npc/proc/gib(atom/location)
	var/obj/decal/cleanable/blood/gibs/gib = null

	// NORTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibup1"
	gib.streak_cleanable(NORTH)

	// SOUTH
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	if (prob(30))
		gib.icon_state = "gibdown1"
	gib.streak_cleanable(SOUTH)

	// WEST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak_cleanable(WEST)

	// EAST
	gib = make_cleanable( /obj/decal/cleanable/blood/gibs,location)
	gib.streak_cleanable(EAST)

/obj/npc/ex_act(severity)
	// Called when an object is in an explosion
	// Higher "severity" means the object was further from the centre of the explosion
	switch(severity)
		if(1)
			gib(src.loc)
			qdel(src)
			return
		if(2)
			health = health -50
		if(3)
			health = health -25
		else
	if(health <=0)
		src.death()
	return

/obj/npc/blob_act(var/power)
	// Called when attacked by a blob
	if(prob(power * 1.25))
		qdel(src)

/obj/npc/bullet_act(var/obj/projectile/P)
	var/damage = 0
	damage = round((P.power*P.proj_data.ks_ratio), 1.0)
	if(!angry)
		angry =1
		activatesecurity()
		src.anger()

	if(src.material) src.material.triggerOnBullet(src, src, P)

	if(P.proj_data)
		switch(P.proj_data.damage_type)
			if(D_KINETIC,D_PIERCING,D_SLASHING)
				src.health -= damage
			if(D_ENERGY)
				src.health -= damage
			if(D_BURNING)
				src.health -= damage
			if(D_RADIOACTIVE)
				src.health -= 1
			if(D_TOXIC)
				src.health -= 1
	else
		src.health -= damage

	if(health <=0)
		src.death()

/obj/npc/attackby(obj/item/W, mob/living/user)
/*	if (!src.alive)
		..()
		return
	if(W.force)
		..()
		src.health -= W.force
		if (src.health <= 0)
			src.death()
			return
		if (angry!=2)
			angry = 2
			src.anger()
			activatesecurity()

	else
		for(var/mob/M in AIviewers(src))
			boutput(M, "<span class='alert'><B>[user]</B> pokes [src] with [W.name]!</span>")

		if(angry!=2)
			if(prob(25))
				angry = 2
				src.anger()
				activatesecurity()
		*/
	src.visible_message("<span class='alert'><B>[user]</B> pokes [src] with [W.name].</span>")
	return
