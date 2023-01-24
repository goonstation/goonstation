ABSTRACT_TYPE(/datum/targetable/critter/plague_rat)
/datum/targetable/critter/plague_rat
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "plague_frame"

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/plague_rat/eat_filth
	name = "Eat filth"
	desc = "Eat some filth, healing you a little bit and slowly growing."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "eat_filth"
	cooldown = 2 SECONDS
	targeted = 1
	target_anything = 1
	var/list/decal_list = list(/obj/decal/cleanable/blood,
	/obj/decal/cleanable/ketchup,
	/obj/decal/cleanable/rust,
	/obj/decal/cleanable/urine,
	/obj/decal/cleanable/vomit,
	/obj/decal/cleanable/greenpuke,
	/obj/decal/cleanable/slime,
	/obj/decal/cleanable/fungus)
	var/list/found_decals = list()

	cast(atom/target)
		if (..())
			return TRUE

		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to eat.</span>")
			return TRUE

		var/turf/T = null
		if (isturf(target))
			T = target
		else
			T = get_turf(target)

		if (T == null)
			boutput(holder.owner, "<span class='alert'>There is nothing to eat here.</span>")
			return TRUE

		var/mob/living/critter/wraith/plaguerat/P = holder.owner

		for (var/obj/decal/cleanable/C in T)
			for (var/D in decal_list)
				if (istype(C, D))
					var/obj/decal/cleanable/found_decal = C
					found_decals += found_decal
					continue

		if (length(found_decals) > 0)
			actions.start(new/datum/action/bar/private/icon/plaguerat_eat(found_decals, src), P)
		else
			boutput(holder.owner, "<span class='alert'>You can't eat that, it doesnt satisfy your appetite.</span>")
			return TRUE

/datum/action/bar/private/icon/plaguerat_eat
	duration = 9 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_ATTACKED
	id = "plaguerat_eat"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/list/obj/decal/cleanable/targets = list()
	var/obj/decal/cleanable/current_target = null

	New(list/Targets, source)
		targets = Targets
		..()

	onStart()
		..()

		var/mob/living/M = owner
		if (M == null || !isalive(M) || !can_act(M) || length(targets) <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		current_target = targets[1]
		M.visible_message("<span class='combat'><b>[M] begins eating [current_target]!</b></span>",\
			"<span class='combat'><b>You start eating [current_target]!</b></span>")
		logTheThing(LOG_DEBUG, src, "Targets = [length(targets)]")

	onUpdate()
		..()

		var/mob/living/M = owner

		if (M == null || !isalive(M) || !can_act(M) || current_target == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		SPAWN(0.8 SECONDS)
			playsound(M.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
			eat_twitch(M)

	onEnd()
		..()

		var/mob/living/critter/wraith/plaguerat/P = owner
		P.visible_message("<span class='combat'><b>[P] eats [current_target]!</b></span>",\
					"<span class='combat'><b>You finish eating [current_target]!</b></span>")
		targets -= targets[1]
		logTheThing(LOG_DEBUG, src, "Targets = [length(targets)]")
		qdel(current_target)
		logTheThing(LOG_DEBUG, src, "Targets = [length(targets)]")
		P.eaten_amount ++
		if (P.eaten_amount >= P.amount_to_grow)
			P.grow_up()

		if (length(targets) > 0)
			actions.start(new/datum/action/bar/private/icon/plaguerat_eat(targets, src), P)

		if((P.health < (P.health_brute + P.health_burn)))
			for(var/damage_type in P.healthlist)
				var/datum/healthHolder/hh = P.healthlist[damage_type]
				hh.HealDamage(3)

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, "<span class='alert'>You were interrupted!</span>")

/datum/targetable/critter/plague_rat/rat_bite
	name = "Bite"
	desc = "Bite a living creature, doing a little damage and injecting them with some rat poison"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "ratbite"
	cooldown = 5 SECOND
	targeted = 1


	cast(atom/target)
		if (..())
			return TRUE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to bite there.</span>")
				return TRUE
		if (target == holder.owner)
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to bite.</span>")
			return TRUE
		var/mob/MT = target
		var/mob/living/critter/wraith/plaguerat/P = holder.owner
		MT.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_BLUNT)
		MT.changeStatus("slowed", 2 SECONDS)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>",\
		"<span class='combat'><b>You bite [MT]!</b></span>")
		P.venom_bite(MT)
		return 0

/datum/targetable/critter/plague_rat/spawn_rat_den
	name = "spawn rat den"
	desc = "Spawn your rat nest, healing you when in range and summoning some tiny diseased mice."
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "ratden"
	cooldown = 120 SECONDS
	targeted = 0

	cast(atom/target)
		if (..())
			return TRUE
		if (istype(holder.owner, /mob/living/critter/wraith/plaguerat) && !istype(get_turf(holder.owner), /turf/space))
			var/mob/living/critter/wraith/plaguerat/P = holder.owner
			if (P.linked_den == null)
				var/obj/machinery/wraith/rat_den/W = new /obj/machinery/wraith/rat_den(P.loc)
				P.linked_den = W
				boutput (P, "<span class='notice'>You spawn a rat den</span>")
			else if (!P.linked_den.loc)
				var/obj/machinery/wraith/rat_den/W = new /obj/machinery/wraith/rat_den(P.loc)
				P.linked_den = W
				boutput (P, "<span class='notice'>You spawn a new rat den</span>")
			else
				qdel(P.linked_den)
				P.linked_den = null
				boutput (P, "<span class='notice'>You had an old rat den, it is now destroyed.</span>")
				var/obj/machinery/wraith/rat_den/W = new /obj/machinery/wraith/rat_den(P.loc)
				P.linked_den = W
				boutput (P, "<span class='notice'>You spawn a new rat den</span>")
			return 0
		return TRUE

/datum/targetable/critter/slam/rat
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "ratrush"
