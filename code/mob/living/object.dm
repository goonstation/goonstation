/obj/item/attackdummy
	name = "attack dummy"
	hit_type = DAMAGE_BLUNT
	force = 5
	throwforce = 5

/mob/living/object
	name = "living object"
	var/obj/possessed_thing
	var/mob/owner
	var/obj/item/attackdummy/dummy
	var/datum/hud/object/hud
	density = 0
	canmove = 1

	var/we_are_an_item = FALSE //to prevent a ton of istype checks
	blinded = FALSE
	anchored = FALSE
	a_intent = "disarm" // todo: This should probably be selectable. Cyborg style - help/harm.
	health = 50
	max_health = 50
	var/name_prefix = "living "

	New(var/atom/loc, var/obj/possessed, var/mob/controller)
		..()

		src.possessed_thing = possessed

		if (istype(src.possessed_thing, /obj/machinery/the_singularity))
			event_handler_flags |= IMMUNE_SINGULARITY

		hud = new(src)
		src.attach_hud(hud)
		src.zone_sel = new(src)
		src.attach_hud(zone_sel)

		message_admins("[key_name(controller)] possessed [loc] at [showCoords(loc.x, loc.y, loc.z)].")
		if (!src.we_are_an_item)
			if (isobj(possessed))
				dummy = new /obj/item/attackdummy(src)
				dummy.name = loc.name
			else
				stack_trace("Tried to create a possessed object from invalid atom {src.possessed_thing} of type {src.possessed_thing.type}!")
				boutput(controller, "<h3 class='alert'>Uh oh, you tried to possess something illegal! Here's a toolbox instead!</h3>")
				src.possessed_thing = new /obj/item/storage/toolbox/artistic

		set_loc(get_turf(src.possessed_thing))

		if (!src.we_are_an_item)
			src.set_density(1)
		possessed.set_loc(src)
		src.name = "[name_prefix][possessed.name]"
		src.real_name = src.name
		src.desc = possessed.desc
		src.icon = possessed.icon
		src.icon_state = possessed.icon_state
		src.pixel_x = possessed.pixel_x
		src.pixel_y = possessed.pixel_y
		src.set_dir(possessed.dir)
		src.color = possessed.color
		src.overlays = possessed.overlays
		src.sight |= SEE_SELF
		src.set_density(possessed.density)
		src.RL_SetOpacity(possessed.opacity)

		src.owner = controller
		if (src.owner)
			src.owner.set_loc(src)
			if (!src.owner.mind)
				src.owner.mind = new /datum/mind(  )
				src.owner.mind.ckey = ckey
				src.owner.mind.key = src.owner.key
				src.owner.mind.current = src.owner
				ticker.minds += src.owner.mind
			src.owner.mind.transfer_to(src)

		src.visible_message("<span class='alert'><b>[src.possessed_thing] comes to life!</b></span>") // was [src] but: "the living space thing comes alive!"
		animate_levitate(src, -1, 20, 1)
		src.add_stun_resist_mod("living_object", 1000)

	disposing()
		src.remove_stun_resist_mod("living_object")
		..()

	equipped()
		if (we_are_an_item)
			return src.possessed_thing
		else
			return src.dummy

	get_desc()
		. = ..()
		. += "<span class='alert'>It seems to be alive.</span><br>"
		if (health < 25)
			. += "<span class='notice'>The ethereal grip on this object appears to be weakening.</span>"

	meteorhit(var/obj/O as obj)
		src.death(TRUE)

	updatehealth()
		return

	is_spacefaring()
		// Let's just say it's powered by ethereal bullshit like ghost farts.
		return TRUE

	clamp_values()
		delStatus("slowed")
		sleeping = 0
		change_misstep_chance(-INFINITY)
		src.delStatus("drowsy")
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
		var/damage = rand(modifier, 12 + 8 * modifier)

		src.TakeDamage(null, damage, 0)

		src.show_message("<span class='alert'>The blob attacks you!</span>")

	attack_hand(mob/user as mob)
		if (user.a_intent == "help")
			user.visible_message("<span class='alert'>[user] pets [src]!</span>")
		else
			user.visible_message("<span class='alert'>[user] punches [src]!</span>")
			src.TakeDamage(null, rand(4, 7), 0) //TODO figure out how to let people punch these without this godawful shit

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
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
			if (we_are_an_item)
				var/obj/item/posessed_item = src.possessed_thing
				possessed_item.attack_self(src)
			else
				src.possessed_thing.Attackhand(src)
		else
			. = ..()

		//To reflect updates of the items appearance etc caused by interactions.
		src.update_appearance()

	death(gibbed)

		if (src.possessed_thing && !gibbed)
			src.possessed_thing.set_dir(src.dir)
			if (src.possessed_thing.loc == src)
				src.possessed_thing.set_loc(get_turf(src))

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

		playsound(src.loc, "sound/voice/wraith/wraithleaveobject.ogg", 40, 1, -1, 0.6)

		if (gibbed)
			qdel(src.possessed_thing)

		src.owner = null
		src.possessed_thing = null
		qdel(src)
		..()

	movement_delay()
		return 4 + movement_delay_modifier

	item_attack_message(var/mob/T, var/obj/item/S, var/d_zone)
		if (d_zone)
			return "<span class='alert'><B>[src] attacks [T] in the [d_zone]!</B></span>"
		else
			return "<span class='alert'><B>[src] attacks [T]!</B></span>"

	return_air()
		return loc?.return_air()

	assume_air(datum/air_group/giver)
		return loc?.assume_air(giver)

	proc/update_appearance() //TODO test this more
		src.appearance = src.possessed_thing.appearance
		src.name = "[name_prefix][src.possessed_thing.name]"
		src.real_name = src.name
		src.possessed_thing.set_dir(src.dir)
		src.icon = src.possessed_thing.icon
		src.icon_state = src.possessed_thing.icon_state
		src.overlays = src.possessed_thing.overlays
		src.set_density(initial(src.possessed_thing.density))
		src.opacity = src.possessed_thing.opacity
