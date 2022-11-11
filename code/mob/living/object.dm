//TODO: let living objects use special attacks that would be cool as hell
/obj/item/attackdummy
	name = "attack dummy"
	hit_type = DAMAGE_BLUNT
	force = 5
	throwforce = 5

/mob/living/object
	name = "living object"
	var/obj/possessed_thing //possessed thing which is PROBABLY an object. We error out in New() if it isn't.
	var/obj/item/possessed_item //if the possessed thing is an item, this var is set to it.
	var/mob/owner //mob who's driving this. makkes sense for wraiths, but humans can also get stuffed in. very silly.
	var/obj/item/attackdummy/dummy //dummy attack, used for non-items so they have something to slap people with
	var/datum/hud/object/hud
	density = 0
	canmove = 1
	use_stamina = FALSE
	flags = FPRINT | NO_MOUSEDROP_QOL
	gender = NEUTER

	blinded = FALSE
	anchored = FALSE
	a_intent = "disarm"
	can_bleed = FALSE
	var/name_prefix = "living "

	New(var/atom/loc, var/obj/possessed, var/mob/controller)
		..(loc, null, null)

		if (isitem(possessed))
			src.possessed_item = possessed
		src.possessed_thing = possessed

		src.hud = new(src)
		src.attach_hud(hud)
		src.zone_sel = new(src)
		src.attach_hud(zone_sel)

		if (controller)
			message_admins("[key_name(controller)] possessed [possessed_thing] at [log_loc(loc)].")

		if (src.possessed_item)
			src.possessed_item.cant_drop = TRUE
			src.max_health = 25 * src.possessed_item.w_class
			src.health = 25 * src.possessed_item.w_class
		else
			if (isobj(possessed_thing))
				src.dummy = new /obj/item/attackdummy(src)
				src.dummy.name = possessed_thing.name
				src.dummy.cant_drop = TRUE
				src.max_health = 100
				src.health = 100
			else
				stack_trace("Tried to create a possessed object from invalid thing [src.possessed_thing] of type [src.possessed_thing.type]!")
				boutput(controller, "<h3 class='alert'>Uh oh, you tried to possess something illegal! Here's a toolbox instead!</h3>")
				src.possessed_thing = new /obj/item/storage/toolbox/artistic

		if(loc)
			set_loc(loc)
		else
			set_loc(get_turf(src.possessed_thing))
		possessed_thing.set_loc(src)

		//Appearance Stuff
		src.update_icon()
		src.desc = possessed_thing.desc
		src.pixel_x = possessed_thing.pixel_x
		src.pixel_y = possessed_thing.pixel_y
		src.set_density(possessed_thing.density)
		src.RL_SetOpacity(possessed_thing.opacity)
		src.create_submerged_images()
		src.flags = possessed_thing.flags
		src.event_handler_flags = src.flags
		//this is a mistake
		src.bound_height = possessed_thing.bound_height
		src.bound_width = possessed_thing.bound_width

		//Relay these signals
		RegisterSignal(src.possessed_thing, COMSIG_ATOM_POST_UPDATE_ICON, /atom/proc/UpdateIcon)

		src.owner = controller
		if (src.owner)
			if (!src.owner.mind) //what the fuck
				src.death(TRUE)
				return
			src.owner.set_loc(src)
			src.owner.mind.transfer_to(src)

		src.visible_message("<span class='alert'><b>[src.possessed_thing] comes to life!</b></span>")
		animate_levitate(src, -1, 20, 1)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "living_object", 100)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "living_object", 100)

		remove_lifeprocess(/datum/lifeprocess/blindness)
		remove_lifeprocess(/datum/lifeprocess/viruses)
		remove_lifeprocess(/datum/lifeprocess/blood)
		remove_lifeprocess(/datum/lifeprocess/breath)
		remove_lifeprocess(/datum/lifeprocess/radiation)

	// Relay these procs

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		. = ..()
		src.possessed_thing?.MouseDrop(over_object, src_location, over_location, over_control, params)

	MouseDrop_T(atom/dropped, mob/user)
		. = ..()
		dropped.MouseDrop(src.possessed_thing)

	Bumped(atom/movable/AM)
		. = ..()
		src.possessed_thing?.Bumped(AM)

	bump(atom/A)
		. = ..()
		src.possessed_thing?.Bump(A)

	Cross(atom/movable/mover)
		. = ..()
		src.possessed_thing?.Cross(mover)

	Crossed(atom/movable/AM)
		. = ..()
		src.possessed_thing?.Crossed(AM)


	disposing()
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST, "living_object")
		REMOVE_ATOM_PROPERTY(src, PROP_MOB_STUN_RESIST_MAX, "living_object")
		..()

	Exited(var/atom/movable/AM, var/atom/newloc)
		if (AM == src.possessed_thing && newloc != src)
			src.death(FALSE) //uh oh
			boutput(src, "<span class='alert'>You feel yourself being ripped away from this object!</h1>") //no destroying spacetime

	equipped()
		if (src.possessed_item)
			return src.possessed_item
		else
			return src.dummy

	get_desc()
		. = ..()
		. += "<span class='alert'>It seems to be alive.</span><br>"
		if (src.health < src.max_health * 0.5)
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
				src.TakeDamage(null, damage / 2, 0)
			if (D_SLASHING)
				src.TakeDamage(null, damage, 0)
			if (D_BURNING)
				src.TakeDamage(null, 0, damage)
			if (D_ENERGY)
				src.TakeDamage(null, 0, damage)

		if(!P.proj_data.silentshot)
			src.visible_message("<span class='alert'>[src] is hit by the [P]!</span>")

	blob_act(var/power)
		logTheThing(LOG_COMBAT, src, "is hit by a blob")
		if (isdead(src) || src.nodamage)
			return

		var/modifier = power / 20
		var/damage = rand(modifier, 12 + 8 * modifier)

		src.TakeDamage(null, damage, 0)

		src.show_message("<span class='alert'>The blob attacks you!</span>")

	attack_hand(mob/user)
		if (user.a_intent == "help")
			user.visible_message("<span class='alert'>[user] pets [src]!</span>")
		else
			..()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		health -= burn
		health -= brute
		health = min(max_health, health)
		if (src.health <= 0)
			src.death(FALSE)

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
			src.self_interact()
		else
			. = ..()

	proc/self_interact()
		if (src.possessed_item)
			src.possessed_item.AttackSelf(src)
		else
			src.possessed_thing.Attackhand(src)
		//To reflect updates of the items appearance etc caused by interactions.
		src.update_density()
		src.item_position_check()

	death(gibbed)

		if (src.possessed_thing && !gibbed)
			src.possessed_thing.set_dir(src.dir)
			if (src.possessed_thing.loc == src)
				src.possessed_thing.set_loc(get_turf(src))
			if (src.possessed_item)
				possessed_item.cant_drop = initial(possessed_item.cant_drop)

		if (src.owner)
			src.owner.set_loc(get_turf(src))
			src.visible_message("<span class='alert'><b>[src] is no longer possessed.</b></span>")

			if (src.mind)
				mind.transfer_to(src.owner)
			else if (src.client)
				src.client.mob = src.owner
			else if (src.key) //This can be null in situations where owner.key is not!
				src.owner.key = src.key
		else
			if(src.mind || src.client)
				var/mob/dead/observer/O = new/mob/dead/observer(src)
				O.set_loc(get_turf(src))
				if (isrestrictedz(src.z) && !restricted_z_allowed(src, get_turf(src)) && !(src.client && src.client.holder))
					var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
					if (OS)
						O.set_loc(OS)
					else
						O.z = Z_LEVEL_STATION
				if (src.client)
					src.client.mob = O
				O.name = src.name
				O.real_name = src.real_name
				if (src.mind)
					src.mind.transfer_to(O)

		playsound(src.loc, 'sound/voice/wraith/wraithleaveobject.ogg', 40, 1, -1, 0.6)

		for (var/atom/movable/AM in src.contents)
			AM.set_loc(src.loc)

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

	can_strip()
		return FALSE

	update_icon()
		..()
		src.appearance = src.possessed_thing.appearance
		src.name = "[name_prefix][src.possessed_thing.name]"
		src.real_name = src.name

	///Ensure the item is still inside us. If it isn't, die and return false. Otherwise, return true.
	proc/item_position_check()
		if (!src.possessed_thing || src.possessed_thing.loc != src) //item somewhere else? we no longer exist
			boutput(src, "<span class='alert'>You feel yourself being ripped away from this object!</h1>")
			src.death(FALSE)
			return FALSE
		return TRUE

	///Update the density of ourselves
	proc/update_density()
		src.density = src.possessed_thing.density

/mob/living/object/ai_controlled
	is_npc = 1
	New()
		..()
		src.ai = new /datum/aiHolder/living_object(src)

	death(var/gibbed)
		qdel(src.ai)
		src.ai = null
		..()


// Extremely simple AI for living objects.
// Essentially:
// 1. Is there a person to hit? If yes, go hit the closest person. If no, wander around
// 2. Repeat
/datum/aiHolder/living_object
	exclude_from_mobs_list = TRUE

/datum/aiHolder/living_object/New()
	..()
	// THE LIVING OBJECT CYCLE
	// THERE IS ONE STEP, AND IT IS ATTACK
	var/datum/aiTask/timed/targeted/living_object/attack = get_instance(/datum/aiTask/timed/targeted/living_object, list(src))
	default_task = attack

/datum/aiHolder/living_object/was_harmed(obj/item/W, mob/M)
	. = ..()
	if (!src.target)
		src.target = M
	src.current_task = default_task

/datum/aiTask/timed/targeted/living_object
	name = "attack"

/datum/aiTask/timed/targeted/living_object/get_targets()
	var/list/humans = list() // Only care about humans since that's all wraiths eat. TODO maybe borgs too?
	for (var/mob/living/carbon/human/H in view(src.target_range, src.holder.owner))
		if (isalive(H) && !H.nodamage && !H.bioHolder.HasEffect("Revenant"))
			humans += H
	return humans

/datum/aiTask/timed/targeted/living_object/evaluate() //always attack if we can see a person
	return length(get_targets()) ? 999 : 0

/datum/aiTask/timed/targeted/living_object/on_tick()
	. = ..()
	// see if we can find someone
	var/mob/mobtarget = holder.target
	ENSURE_TYPE(mobtarget)
	if (!mobtarget || isdead(mobtarget) || GET_DIST(holder.owner, mobtarget) > 10 || frustration > 8) //slightly higher chase range than acquisition range
		holder.target = null
		frustration = 0
		var/list/possible = get_targets()
		if (length(possible))
			holder.target = pick(possible)
	 // we didn't find anyone, wander around
	if (!holder.target)
		holder.owner.move_dir = pick(alldirs)
		holder.owner.process_move()
		return
	src.pre_attack()
	if (BOUNDS_DIST(holder.target, holder.owner))
		holder.move_to(holder.target)
	else
		holder.owner.weapon_attack(holder.target, holder.owner.equipped(), TRUE)

/datum/aiTask/timed/targeted/living_object/frustration_check()
	. = 0
	if (holder)
		if (!IN_RANGE(holder.owner, holder.target, target_range))
			return 1

		if (ismob(holder.target))
			var/mob/M = holder.target
			. = !(holder.target && isalive(M))
		else
			. = !(holder.target)

/// For items with special intent/targeting requirements, or special modes of attacking- arm grenades, turn batons on, etc
/datum/aiTask/timed/targeted/living_object/proc/pre_attack()
	var/mob/living/object/spooker = holder.owner
	var/obj/item/item = spooker.equipped()
	if (!istype(item, /obj/item/attackdummy)) // marginally more performant- don't bother if we're a possessed non item
		if (istype(item, /obj/item/baton))
			var/obj/item/baton/bat = item
			if (is_incapacitated(src.holder.target) || !(SEND_SIGNAL(bat, COMSIG_CELL_CHECK_CHARGE) & CELL_SUFFICIENT_CHARGE)) // they're down or we're out of juice, let's harm baton
				if (bat.is_active) // uh oh, we're on. turn off
					spooker.self_interact()
				spooker.set_a_intent(INTENT_HARM)
				bat.flipped = TRUE

			else // they're up and we have charge, let's try to stun
				if (!bat.is_active)
					if (istype(bat, /obj/item/baton/ntso))
						var/obj/item/baton/ntso/NTbat = bat
						if (NTbat.state == EXTENDO_BATON_OPEN_AND_OFF) // need 2 taps to get to 'on' in this case
							spooker.self_interact()
					spooker.self_interact()

				spooker.set_a_intent(INTENT_DISARM) // have charge, baton normally
				bat.flipped = FALSE
			bat.UpdateIcon()

		else if (istype(item, /obj/item/sword))
			var/obj/item/sword/saber = item
			if (!saber.active)
				spooker.self_interact() // turn that sword on
			spooker.set_a_intent(INTENT_HARM)
		else if (istype(item, /obj/item/gun))
			var/obj/item/gun/pew = item
			if (pew.canshoot(holder.owner))
				spooker.set_a_intent(INTENT_HARM) // we can shoot, so... shoot
			else
				spooker.set_a_intent(INTENT_HELP) // otherwise go on help for gun whipping
		else if (istype(item, /obj/item/old_grenade) || istype(item, /obj/item/chem_grenade || istype(item, /obj/item/pipebomb))) //cool paths tHANKS
			spooker.self_interact() // arm grenades
		else if (istype(item, /obj/item/swords)) 		// this will also apply for non-limb-slicey katanas but it shouldn't really matter
			if (ishuman(holder.target))
				var/mob/living/carbon/human/H = holder.target
				var/limbless = TRUE
				for (var/limb in list("l_leg", "r_leg", "l_arm", "r_arm"))
					if (H.limbs.vars[limb]) // sue me
						spooker.zone_sel.select_zone(limb)
						limbless = FALSE
						break
				if (limbless) // >:^)
					spooker.zone_sel.select_zone("head")

		else if (istype(item, /obj/item/weldingtool))
			var/obj/item/weldingtool/welder = item
			if (!welder.welding)
				spooker.self_interact()
		else
			spooker.set_a_intent(INTENT_HARM)
			spooker.zone_sel.select_zone("head") // head for plates n stuff
		spooker.hud.update_intent()

	//TODO make guns fire at range?, c saber deflect (if possible i forget if arbitrary mobs can block)
