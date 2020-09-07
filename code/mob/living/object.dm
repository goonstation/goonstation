/obj/item/attackdummy
	name = "attack dummy"
	hit_type = DAMAGE_BLUNT
	force = 5
	throwforce = 5

/mob/living/object
	name = "living object"
	var/obj/item/item
	var/mob/owner
	var/obj/item/attackdummy/dummy
	var/datum/hud/object/hud
	density = 0
	canmove = 1

	var/canattack = 0
	blinded = 0
	anchored = 0
	a_intent = "disarm" // todo: This should probably be selectable. Cyborg style - help/harm.
	health = 50
	max_health = 50
	var/name_prefix = "living "

	var/last_life_update = 0
	var/const/life_tick_spacing = 20

	New(var/atom/loc as mob|obj|turf, var/mob/controller)
		..()

		if (istype(loc,/obj/machinery/the_singularity))
			event_handler_flags |= IMMUNE_SINGULARITY

		hud = new(src)
		src.attach_hud(hud)
		src.zone_sel = new(src)
		src.attach_hud(zone_sel)

		message_admins("[key_name(controller)] possessed [loc] at [showCoords(loc.x, loc.y, loc.z)].")
		var/obj/item/possessed
		if (!isitem(loc))
			if (isobj(loc))
				possessed = loc
				set_loc(get_turf(possessed))
				canattack = 0
				dummy = new /obj/item/attackdummy(src)
				dummy.name = loc.name
			else
				possessed = new /obj/item/paper()
				logTheThing("admin", usr, null, "living object mob created with no item.")
				var/turf/T = get_turf(loc)
				if (!T)
					logTheThing("admin", usr, null, "additionally, no turf could be found at creation loc [loc]")
					var/ASLoc = pick_landmark(LANDMARK_LATEJOIN)
					if (ASLoc)
						src.set_loc(ASLoc)
					else
						src.set_loc(locate(1, 1, 1))
				else
					src.set_loc(T)
				canattack = 1
		else
			canattack = 1
			possessed = loc
			set_loc(get_turf(possessed))

		if (!src.canattack)
			src.set_density(1)
		possessed.set_loc(src)
		src.name = "[name_prefix][possessed.name]"
		src.real_name = src.name
		src.desc = "[possessed.desc]"
		src.icon = possessed.icon
		src.icon_state = possessed.icon_state
		src.pixel_x = possessed.pixel_x
		src.pixel_y = possessed.pixel_y
		src.dir = possessed.dir
		src.color = possessed.color
		src.overlays = possessed.overlays
		src.item = possessed
		src.sight |= SEE_SELF
		src.set_density(possessed.density)
		src.RL_SetOpacity(possessed.opacity)

		src.owner = controller
		if (src.owner)
			src.owner.set_loc(src)
			if (!src.owner.mind)
				src.owner.mind = new /datum/mind(  )
				src.owner.mind.key = src.owner.key
				src.owner.mind.current = src.owner
				ticker.minds += src.owner.mind
			//if (src.owner.client)
				// src.owner.client.mob = src
			src.owner.mind.transfer_to(src)

		src.visible_message("<span class='alert'><b>[possessed] comes to life!</b></span>") // was [src] but: "the living space thing comes alive!"
		animate_levitate(src, -1, 20, 1)
		src.add_stun_resist_mod("living_object", 1000)

	disposing()
		src.remove_stun_resist_mod("living_object")
		..()

	equipped()
		if (canattack)
			return src.item
		else
			return src.dummy

	examine()
		. = ..()
		. += "<span class='alert'>It seems to be alive.</span>"
		if (health < 25)
			. += "<span class='notice'>The ethereal grip on this object appears to be weak.</span>"

	meteorhit(var/obj/O as obj)
		src.death(1)
		return

	restrained()
		return 0

	updatehealth()
		return

	is_spacefaring()
		// Let's just say it's powered by ethereal bullshit like ghost farts.
		return 1

	clamp_values()
		delStatus("slowed")
		sleeping = 0
		change_misstep_chance(-INFINITY)
		drowsyness = 0.0
		dizziness = 0
		is_dizzy = 0
		is_jittery = 0
		jitteriness = 0

	bullet_act(var/obj/projectile/P)
		var/damage = 0
		damage = round((P.power*P.proj_data.ks_ratio), 1.0)

		switch (P.proj_data.damage_type)
			if (D_KINETIC)
				src.TakeDamage(null, damage, 0)
			if (D_PIERCING)
				src.TakeDamage(null, damage / 2.0, 0)
			if (D_SLASHING)
				src.TakeDamage(null, damage, 0)
			if (D_BURNING)
				src.TakeDamage(null, 0, damage)
			if (D_ENERGY)
				src.TakeDamage(null, 0, damage)

		if(!P.proj_data.silentshot)
			src.visible_message("<span class='alert'>[src] is hit by the [P]!</span>")

	blob_act(var/power)
		logTheThing("combat", src, null, "is hit by a blob")
		if (isdead(src) || src.nodamage)
			return

		var/modifier = power / 20
		var/damage = null
		if (!isdead(src))
			damage = rand(modifier, 12 + 8 * modifier)

		src.TakeDamage(null, damage, 0)

		src.show_message("<span class='alert'>The blob attacks you!</span>")
		return

	attack_hand(mob/user as mob)
		if (user.a_intent == "help")
			user.visible_message("<span class='alert'>[user] pets [src]!</span>")
		else
			user.visible_message("<span class='alert'>[user] punches [src]!</span>")
			src.TakeDamage(null, rand(4, 7), 0)

	TakeDamage(zone, brute, burn)
		health -= burn
		health -= brute
		health = min(max_health, health)
		if (src.health <= 0)
			src.death(0)

	HealDamage(zone, brute, burn)
		TakeDamage(zone, -brute, -burn)

	change_eye_blurry(var/amount, var/cap = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	take_eye_damage(var/amount, var/tempblind = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	take_ear_damage(var/amount, var/tempdeaf = 0)
		if (amount < 0)
			return ..()
		else
			return 1

	click(atom/target, params)
		if (target == src)
			if (canattack)
				src.item.attack_self(src)
			else
				if(!isitem(src.item))
					src.item.attack_hand(src)
				else //This shouldnt ever happen.
					src.item.attackby(src.item, src)
		else
			if(src.a_intent == INTENT_GRAB && istype(target, /atom/movable) && get_dist(src, target) <= 1)
				var/atom/movable/M = target
				if(ismob(target) || !M.anchored)
					src.visible_message("<span class='alert'>[src] grabs [target]!</span>")
					M.set_loc(src.loc)
			else
				. = ..()
			if (src.item.loc != src)
				if (isturf(src.item.loc))
					src.item.set_loc(src)
				else
					src.death(0)

		//To reflect updates of the items appearance etc caused by interactions.
		src.name = "[name_prefix][src.item.name]"
		src.real_name = src.name
		src.desc = "[src.item.desc]"
		src.item.dir = src.dir
		src.icon = src.item.icon
		src.icon_state = src.item.icon_state
		//src.pixel_x = src.item.pixel_x
		//src.pixel_y = src.item.pixel_y
		src.color = src.item.color
		src.overlays = src.item.overlays
		src.set_density(initial(src.item.density))
		src.opacity = src.item.opacity

	death(gibbed)
		if (src.owner)
			src.owner.set_loc(get_turf(src))
			src.visible_message("<span class='alert'><b>[src] is no longer possessed.</b></span>")

			if (src.mind)
				mind.transfer_to(src.owner)
			else if (src.client)
				src.client.mob = src.owner
		else
			if(src.mind || src.client)
				var/mob/dead/observer/O = new/mob/dead/observer()
				O.set_loc(get_turf(src))
				if (isrestrictedz(src.z) && !restricted_z_allowed(src, get_turf(src)) && !(src.client && src.client.holder))
					var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
					if (OS)
						O.set_loc(OS)
					else
						O.z = 1
				if (src.client)
					src.client.mob = O
				O.name = src.name
				O.real_name = src.real_name
				if (src.mind)
					src.mind.transfer_to(O)

		playsound(src.loc, "sound/effects/suck.ogg", 40, 1, -1, 0.6)

		if (src.item)
			src.item.dir = src.dir
			if (src.item.loc == src)
				src.item.set_loc(get_turf(src))
			if (gibbed)
				qdel(src.item)
		src.owner = null
		qdel(src)
		..(gibbed)

	movement_delay()
		return 4 + movement_delay_modifier

	put_in_hand(obj/item/I, hand)
		return 0

	swap_hand()
		return 0

	item_attack_message(var/mob/T, var/obj/item/S, var/d_zone)
		if (d_zone)
			return "<span class='alert'><B>[src] attacks [T] in the [d_zone]!</B></span>"
		else
			return "<span class='alert'><B>[src] attacks [T]!</B></span>"
