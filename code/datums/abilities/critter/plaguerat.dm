////////////////////////////
//	Plague rat abilities
////////////////////////////
/datum/targetable/critter/plague_rat/eat_filth
	name = "Eat filth"
	desc = "Eat some filth"
	icon_state = "clown_spider_bite"
	cooldown = 3 SECOND
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


	cast(atom/target)
		if (..())
			return 1
		if (!istype(target, /obj/decal/cleanable))
			boutput(holder.owner, __red("there is nothing to eat here."))
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, __red("That is too far away to eat."))
			return 1

		for (var/D in decal_list)
			if (istype(target, D))
				var/obj/decal/cleanable/T = target
				var/mob/living/critter/plaguerat/P = holder.owner
				holder.owner.visible_message("<span class='combat'><b>[holder.owner] begins eating [T]!</b></span>",\
				"<span class='combat'><b>You start eating [T]!</b></span>")

				var/eat_duration = rand(6, 12)
				holder.owner.set_loc(T.loc)
				holder.owner.canmove = 0
				while (eat_duration > 0 && T && !T.disposed)
					if (T.loc && holder.owner.loc != T.loc)
						break
					if (!can_act(holder.owner))
						break
					sleep(0.8 SECONDS)
					playsound(holder.owner.loc,"sound/items/eatfood.ogg", rand(10, 50), 1)
					eat_twitch(holder.owner)
					eat_duration--
				if (T && holder.owner.loc == T.loc)
					P.eaten_amount ++
					holder.owner.visible_message("<span class='combat'><b>[holder.owner] eats [T]!</b></span>",\
					"<span class='combat'><b>You finish eating [T]!</b></span>")
					qdel(T)
				if (P.eaten_amount >= P.amount_to_grow)
					P.grow_up()
				return 0
		boutput(holder.owner, __red("You can't eat that, it doesnt satisfy your appetite."))
		return 1

/datum/targetable/critter/plague_rat/rat_bite
	name = "Bite"
	desc = "Bite a mob, doing a little damage and injecting them with some rat poison"
	icon_state = "clown_spider_bite"
	cooldown = 5 SECOND
	targeted = 1

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to bite there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, __red("That is too far away to bite."))
			return 1
		var/mob/MT = target
		var/mob/living/critter/plaguerat/P = holder.owner
		MT.TakeDamageAccountArmor("All", rand(1,3), 0, 0, DAMAGE_BLUNT)
		MT.changeStatus("slowed", 2 SECONDS)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>",\
		"<span class='combat'><b>You bite [MT]!</b></span>")
		P.venom_bite(MT)
		return 0

/datum/targetable/critter/plague_rat/spawn_warren
	name = "spawn warren"
	desc = "Spawn a warren"
	icon_state = "clown_spider_bite"
	cooldown = 60 SECONDS
	targeted = 0

	cast(atom/target)
		if (..())
			return 1
		if (istype(holder.owner, /mob/living/critter/plaguerat))
			var/mob/living/critter/plaguerat/P = holder.owner
			if (P.linked_warren == null)
				var/obj/machinery/wraith_warren/W = new /obj/machinery/wraith_warren(P.loc)
				P.linked_warren = W
				boutput (P, "You spawn a warren")
			else if (!P.linked_warren.loc)
				var/obj/machinery/wraith_warren/W = new /obj/machinery/wraith_warren(P.loc)
				P.linked_warren = W
				boutput (P, "You spawn a new warren")
			else
				boutput (P, "You already have a warren")
		return 0
