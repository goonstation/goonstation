// wooden barricades

TYPEINFO(/obj/structure/woodwall)
	mat_appearances_to_ignore = list("wood")
/obj/structure/woodwall
	name = "barricade"
	desc = "This was thrown up in a hurry."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodwall"
	anchored = ANCHORED
	density = 1
	opacity = 1
	material_amt = 0.5
	projectile_passthrough_chance = 30
	_health = 30
	_max_health = 30
	flags = ON_BORDER
	provides_grip = TRUE
	var/builtby = null
	var/anti_z = 0
	// for projectile damage component
	var/projectile_gib = TRUE
	var/projectile_gib_streak = FALSE

	New()
		src.AddComponent(/datum/component/obj_projectile_damage, /obj/decal/cleanable/wood_debris, src.projectile_gib, src.projectile_gib_streak)
		. = ..()

	virtual
		icon = 'icons/effects/VR.dmi'
		projectile_gib = FALSE // no virtual debris

	anti_zombie
		name = "anti-zombie barricade"
		anti_z = 1

		get_desc()
			..()
			. += "Looks like normal spacemen can easily pull themselves over or crawl under it."

	changeHealth(var/change = 0)
		var/prevHealth = _health
		_health += change
		_health = min(_health, _max_health)
		if (prevHealth > _health)
			playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		updateHealth(prevHealth)

	updateHealth(var/prevHealth)
		if (_health <= 0)
			src.visible_message(SPAN_ALERT("<b>[src] collapses!</b>"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 100, 1)
			src.onDestroy()
			return
		else if (_health <= 5)
			src.projectile_passthrough_chance = 90
			icon_state = "woodwall4"
			set_opacity(0)
		else if (_health <= 10)
			icon_state = "woodwall3"
			src.projectile_passthrough_chance = 70
			set_opacity(0)
		else if (_health <= 20)
			src.projectile_passthrough_chance = 50
			icon_state = "woodwall2"
		else
			src.projectile_passthrough_chance = 30
			icon_state = "woodwall"

	attack_hand(mob/user)
		if (ishuman(user) && !user.is_zombie)
			var/mob/living/carbon/human/H = user
			if (src.anti_z && H.a_intent != INTENT_HARM && isfloor(get_turf(src)))
				H.set_loc(get_turf(src))
				if (_health > 15)
					H.visible_message(SPAN_NOTICE("<b>[H]</b> [pick("rolls under", "jaunts over", "barrels through")] [src] slightly damaging it!"))
					boutput(H, SPAN_ALERT("<b>OWW! You bruise yourself slightly!"))
					playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
					random_brute_damage(H, 5)
					src.changeHealth(rand(0, -2))
				return

		if (ishuman(user))
			user.lastattacked = get_weakref(src)
			src.visible_message(SPAN_ALERT("<b>[user]</b> bashes [src]!"))
			playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 100, 1)
			//Zombies do less damage
			var/mob/living/carbon/human/H = user
			if (istype(H.mutantrace, /datum/mutantrace/zombie))
				if(prob(40))
					H.emote("scream")
				src.changeHealth(rand(0, -2))
			else
				src.changeHealth(rand(-1, -3))
			hit_twitch(src)
			return
		else
			return

	attackby(var/obj/item/W, mob/user)
		if (istype(W,/obj/item/sheet/wood))
			actions.start(new /datum/action/bar/icon/wood_repair_wall(W, src, 30), user)
			return
		..()
		user.lastattacked = get_weakref(src)
		src.changeHealth(-W.force)
		hit_twitch(src)
		return

	disposing()
		var/turf/T = src.loc
		. = ..()
		for (var/turf/simulated/wall/auto/asteroid/A in orange(T,1))
			A.UpdateIcon()

/obj/structure/woodwall/Cross(obj/projectile/mover)
	if (istype(mover) && !mover.proj_data.always_hits_structures && prob(src.projectile_passthrough_chance))
		return TRUE
	return (!density)

/obj/structure/woodwall/fake_asteroid
	name = "odd asteroid wall"
	icon = 'icons/turf/walls/asteroid.dmi'
	icon_state = "asteroid-map"
	projectile_gib = FALSE
	color = "#d1e6ff"
	plane = PLANE_WALL

	New()
		..()
		var/image/top_overlay = mutable_appearance('icons/turf/walls/asteroid.dmi', pick("top1", "top2", "top3"))
		var/icon/top_icon = icon('icons/turf/walls/asteroid.dmi',"mask2[src.icon_state]")
		top_overlay.filters += filter(type="alpha", icon=top_icon)
		top_overlay.layer = src.layer + 0.1
		AddOverlays(top_overlay, "ast_top_rock")

	updateHealth()
		if (_health <= 0)
			src.visible_message(SPAN_ALERT("<b>[src] collapses!</b>"))
			src.onDestroy()

/obj/structure/woodwall/fake_asteroid/left_edge
	icon_state = "asteroid-55"

/obj/structure/woodwall/fake_asteroid/right_edge
	icon_state = "asteroid-3"

/datum/action/bar/icon/wood_repair_wall
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	#ifdef HALLOWEEN
	duration = 20
	#else
	duration = 30
	#endif
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/item/sheet/wood/wood
	var/obj/structure/woodwall/wall

	New(var/obj/item/sheet/wood/wood, var/obj/structure/woodwall/wall, var/duration_i)
		..()
		src.wood = wood
		src.wall = wall
		if (!wall)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (wood == null || wood.amount < 1 || owner == null || BOUNDS_DIST(owner, wall) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && wood != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
		if (prob(20))
			hit_twitch(wall)
			playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)

	onStart()
		..()
		hit_twitch(wall)
		playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		owner.visible_message(SPAN_NOTICE("[owner] begins repairing [wall]!"))

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner] uses a [wood] to completely repair the [wall]!"))
		hit_twitch(wall)
		playsound(wall.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', rand(50,90), 1)
		//do repair shit.
		wall._health = wall._max_health
		wall.updateHealth()
		wood.change_stack_amount(-1)
