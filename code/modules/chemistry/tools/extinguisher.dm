/obj/item/extinguisher
	name = "fire extinguisher"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "fire_extinguisher0"
	var/safety = 1
	var/extinguisher_special = 0
	var/const/min_distance = 1
	var/const/max_distance = 5
	var/const/reagents_per_dist = 5
	var/initial_volume = 100
	///Does it get destroyed from exploding
	var/reinforced = FALSE
	hitsound = 'sound/impact_sounds/Metal_Hit_1.ogg'
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT | OPENCONTAINER
	tooltip_flags = REBUILD_DIST
	throwforce = 10
	w_class = W_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 10
	item_state = "fireextinguisher0"
	m_amt = 90
	desc = "A portable container with a spray nozzle that contains specially mixed fire-fighting foam. The safety is removed, the nozzle pointed at the base of the fire, and the trigger squeezed to extinguish fire."
	stamina_damage = 25
	stamina_cost = 20
	stamina_crit_chance = 35
	rand_pos = 1
	inventory_counter_enabled = 1
	move_triggered = 1
	var/list/banned_reagents = list("vomit",
	"blackpowder",
	"blood",
	"ketchup",
	"gvomit",
	"carbon",
	"cryostylane",
	"chickensoup",
	"salt")
	var/list/melting_reagents = list("acid",
	"pacid",
	"phlogiston",
	"big_bang",
	"clacid",
	"nitric_acid",
	"firedust")

	virtual
		icon = 'icons/effects/VR.dmi'


	proc/view_test()
		var/i = 0
		for(var/atom/A in view(null,null))
			i++
		.= i

/obj/item/extinguisher/New()
	..()
	src.create_reagents(initial_volume)
	reagents.add_reagent("ff-foam", initial_volume)
	src.inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)
	BLOCK_SETUP(BLOCK_TANK)

/obj/item/extinguisher/on_reagent_change(add)
	. = ..()
	src.inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

/obj/item/extinguisher/get_desc(dist)
	if (dist > 1)
		return
	if (!src.reagents)
		return "The handle is broken."
	return "Contains [src.reagents.total_volume] units."

/obj/item/extinguisher/attack(mob/M, mob/user)
	src.hide_attack = ATTACK_VISIBLE
	if(user.a_intent == "help" && !safety) //don't smack people with a deadly weapon while you're trying to extinguish them, thanks
		src.hide_attack = ATTACK_FULLY_HIDDEN
		return
	..()

/obj/item/extinguisher/pixelaction(atom/target, params, mob/user, reach)
	..()
	//src.afterattack(target, user)

/obj/item/extinguisher/afterattack(atom/target, mob/user , flag)
	//TODO; Add support for reagents in water.
	if (!src.reagents)
		boutput(user, "<span class='alert'>Man, the handle broke off, you won't spray anything with this.</span>")
		return

	if ( is_reagent_dispenser(target) && BOUNDS_DIST(src, target) == 0)
		var/obj/o = target
		o.reagents.trans_to(src, (src.reagents.maximum_volume - src.reagents.total_volume))
		src.inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)
		boutput(user, "<span class='notice'>Extinguisher refilled...</span>")
		playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
		user.lastattacked = target
		return

	if (!safety && !istype(target, /obj/item/storage) && !istype(target, /obj/item/storage/secure))
		if (src.reagents.total_volume < 1)
			boutput(user, "<span class='alert'>The extinguisher is empty.</span>")
			return

		if (src.reagents.has_reagent("infernite") && src.reagents.has_reagent("blackpowder")) // BAHAHAHAHA
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, 1, -3)
			fireflash(src.loc, 0)
			explosion(src, src.loc, -1,0,1,1)
			src.reagents.remove_any(src.initial_volume)
			if (src.reinforced)
				return
			user.visible_message("<span class='alert'>[src] violently bursts!</span>")
			user.drop_item()
			new/obj/item/scrap(get_turf(user))
			if (ishuman(user))
				var/mob/living/carbon/human/M = user
				var/obj/item/implant/projectile/shrapnel/implanted = new /obj/item/implant/projectile/shrapnel
				implanted.implanted(M, null, 4)
				boutput(M, "<span class='alert'>You are struck by shrapnel!</span>")
			qdel(src)
			return

		else if (src.reagents.has_reagent("infernite") || src.reagents.has_reagent("foof"))
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 60, 1, -3)
			fireflash(src.loc, 0)
			src.reagents.remove_any(src.initial_volume)
			if (src.reinforced)
				return
			user.visible_message("<span class='alert'>[src] ruptures!</span>")
			user.drop_item()
			new/obj/item/scrap(get_turf(user))
			qdel(src)
			return

		for (var/reagent in src.banned_reagents)
			if (src.reagents.has_reagent(reagent))
				boutput(user, "<span class='alert'>The nozzle is clogged!</span>")
				return

		for (var/reagent in src.melting_reagents)
			if (src.reagents.has_reagent(reagent))
				user.visible_message("<span class='alert'>[src] melts!</span>")
				user.drop_item()
				make_cleanable(/obj/decal/cleanable/molten_item,get_turf(user))
				qdel(src)
				return

		playsound(src, 'sound/effects/spray.ogg', 30, 1, -3)

		var/direction = get_dir(src,target)

		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))

		var/list/the_targets = list(T,T1,T2)

		var/datum/reagents/R = new
		var/distance = clamp(GET_DIST(get_turf(src), get_turf(target)), min_distance, max_distance)
		src.reagents.trans_to_direct(R, min(src.reagents.total_volume, (distance * reagents_per_dist)))
		src.inventory_counter.update_percent(src.reagents.total_volume, src.reagents.maximum_volume)

		logTheThing(LOG_CHEMISTRY, user, "sprays [src] at [constructTarget(T,"combat")], [log_reagents(src)] at [log_loc(user)] ([get_area(user)])")

		user.lastattacked = target

		for (var/a = 0, a < reagents_per_dist, a++)
			SPAWN(0)
				if (disposed)
					return
				if (!src.reagents)
					return
				var/obj/effects/water/W = new /obj/effects/water(user)
				W.owner = user
				if (!W) return
				W.set_loc( get_turf(src) )
				var/turf/my_target = pick(the_targets)
				W.spray_at(my_target, R, try_connect_fluid = 1)

		if (istype(user.loc, /turf/space))
			user.inertia_dir = get_dir(target, user)
			step(user, user.inertia_dir)
		else if( user.buckled && !user.buckled.anchored )
			var/wooshdir = get_dir( target, user )
			SPAWN(0)
				for( var/i = 1, (user?.buckled && !user.buckled.anchored && i <= rand(3,5)), i++ )
					step( user.buckled, wooshdir )
					sleep( rand(1,3) )

	else
		return ..()
	return

/obj/item/extinguisher/attack_self(mob/user as mob)
	if (safety)
		src.item_state = "fireextinguisher1"
		set_icon_state("fire_extinguisher1")
		user.update_inhands()
		src.desc = "The safety is off."
		boutput(user, "The safety is off.")
		ADD_FLAG(src.flags, OPENCONTAINER)
		safety = FALSE
	else
		src.item_state = "fireextinguisher0"
		set_icon_state("fire_extinguisher0")
		user.update_inhands()
		src.desc = "The safety is on."
		boutput(user, "The safety is on.")
		REMOVE_FLAG(src.flags, OPENCONTAINER)
		safety = TRUE

/obj/item/extinguisher/move_trigger(var/mob/M, kindof)
	if (..() && reagents)
		reagents.move_trigger(M, kindof)

/obj/item/extinguisher/abilities = list(/obj/ability_button/extinguisher_ab)

/obj/item/extinguisher/large
	name = "fire extinguisher XL"
	initial_volume = 300

/obj/item/extinguisher/large/cyborg // because borgs can't replace their extinguishers
	reinforced = TRUE
	New()
		..()
		src.banned_reagents += src.melting_reagents
		src.melting_reagents = list()
