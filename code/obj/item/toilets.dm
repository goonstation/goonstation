/*
CONTAINS:
TOILET
*/

TYPEINFO(/obj/item/storage/toilet)
	mats = 5

/obj/item/storage/toilet
	name = "toilet"
	w_class = W_CLASS_BULKY
	anchored = ANCHORED
	density = 0
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	var/status = 0
	var/clogged = 0
	anchored = ANCHORED
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	rand_pos = 0
	burn_possible = FALSE

/obj/item/storage/toilet/New()
	..()
	START_TRACKING

/obj/item/storage/toilet/disposing()
	STOP_TRACKING
	..()

/obj/item/storage/toilet/attackby(obj/item/W, mob/user)
	if (src.storage.is_full())
		boutput(user, "The toilet is clogged!")
		user.unlock_medal("Try jiggling the handle",1) //new method to get this medal since the old one (fat person in disposal pipe) is gone
		return
	if (W.storage)
		return
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W

		if (ishuman(G.affecting))
			var/mob/living/carbon/human/H = G.affecting
			if (!H.organHolder?.head)
				user.visible_message(SPAN_NOTICE("[user] fruitlessly tries to dunk [G.affecting]'s headless body into the toilet."), SPAN_NOTICE("You struggle trying to swirlie [G.affecting] but they dont have a head! You feel silly for even attempting it."))
				return
			else
				user.visible_message(SPAN_NOTICE("[user] gives [G.affecting] a swirlie!"), SPAN_NOTICE("You give [G.affecting] a swirlie. It's like Middle School all over again!"))
		else
			user.visible_message(SPAN_NOTICE("[user] gives [G.affecting] a swirlie!"), SPAN_NOTICE("You give [G.affecting] a swirlie. It's like Middle School all over again!"))
		G.affecting.lastgasp() // --BLUH
		playsound(src, 'sound/effects/toilet_flush.ogg', 50, TRUE)
		if (G.affecting.hasStatus("burning"))
			G.affecting.changeStatus("burning", -2 SECONDS)
			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 70, TRUE)
			return
		return
	return ..()

/obj/item/storage/toilet/mouse_drop(atom/over_object, src_location, over_location)
	if (usr && over_object == usr && in_interact_range(src, usr) && iscarbon(usr) && !usr.stat)
		usr.visible_message(SPAN_ALERT("[usr] [pick("shoves", "sticks", "stuffs")] [his_or_her(usr)] hand into [src]!"))
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
	..()

/obj/item/storage/toilet/MouseDrop_T(mob/living/carbon/human/M as mob, mob/user as mob) // Yeah, uh, only living humans should use the toilet
	if (!ticker)
		boutput(user, "You can't help relieve anyone before the game starts.")
		return
	if (!ishuman(M) || BOUNDS_DIST(src, user) > 0 || M.loc != src.loc || user.restrained() || user.stat)
		return
	if (M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/mario) && istype(H.head, /obj/item/clothing/head/mario))
			user.visible_message(SPAN_NOTICE("[user] dives into [src]!"), SPAN_NOTICE("You dive into [src]!"))
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(src.loc))
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)

			var/list/destinations = list()

			for_by_tcl(T, /obj/item/storage/toilet)
				if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z) || (istype(T.loc.loc,/area) && T.loc.loc:teleport_blocked))
					continue
				destinations.Add(T)

			if (destinations.len)
				var/atom/picked = pick(destinations)
				particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(picked.loc))
				M.set_loc(picked.loc)
				playsound(picked.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				user.visible_message(SPAN_NOTICE("[user] emerges from [src]!"), SPAN_NOTICE("You emerge from [src]!"))
			return

	if (M == user)
		user.visible_message(SPAN_NOTICE("[user] sits on [src]."), SPAN_NOTICE("You sit on [src]."))
	else
		user.visible_message(SPAN_NOTICE("[M] is seated on [src] by [user]!"))
	M.anchored = ANCHORED
	M.buckled = src
	M.set_loc(src.loc)
	src.add_fingerprint(user)
	return

/obj/item/storage/toilet/attack_hand(mob/user)

	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message(SPAN_NOTICE("[M] is zipped up by [user]. That's... that's honestly pretty creepy."))
			else
				user.visible_message(SPAN_NOTICE("[M] zips up."), SPAN_NOTICE("You zip up."))
//			boutput(world, "[M] is no longer buckled to [src]")
			reset_anchored(M)
			M.buckled = null
			src.add_fingerprint(user)
	if((src.clogged < 1) || (!src.storage.is_full()) || (user.loc != src.loc))
		user.visible_message(SPAN_NOTICE("[user] flushes [src]."), SPAN_NOTICE("You flush [src]."))
		playsound(src, 'sound/effects/toilet_flush.ogg', 50, TRUE)


#ifdef UNDERWATER_MAP
		var/turf/T = get_turf(src)
		if (T)
			var/turf/target = locate(T.x, T.y, 5)
			for (var/obj/item/I as anything in src.storage.get_contents())
				src.storage.transfer_stored_item(I, target)
#endif
		src.clogged = 0
		for (var/item in src.storage.get_contents())
			flush(item)

	else if((src.clogged >= 1) || (src.storage.is_full()) || (user.buckled != src.loc))
		src.visible_message(SPAN_NOTICE("The toilet is clogged!"))

/obj/item/storage/toilet/proc/flush(atom)
	qdel(atom)

/obj/item/storage/toilet/custom_suicide = 1
/obj/item/storage/toilet/suicide_in_hand = 0
/obj/item/storage/toilet/suicide(var/mob/living/carbon/human/user as mob)
	if (!ishuman(user) || !user.organHolder)
		return FALSE

	user.visible_message(SPAN_ALERT("<b>[user] sticks [his_or_her(user)] head into [src] and flushes it, giving [him_or_her(user)]self an atomic swirlie!</b>"))
	var/obj/head = user.organHolder.drop_organ("head")
	if (!head) // they were already headless or something else odd happened, just abort
		return FALSE
	if (src.clogged >= 1 || src.storage.is_full())
		head.set_loc(src.loc)
		playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		src.visible_message(SPAN_NOTICE("[head] floats up out of the clogged [src.name]!"))
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				var/vomit_message = SPAN_ALERT("[O] pukes all over [himself_or_herself(O)].")
				O.vomit(0, null, vomit_message)
	else
		var/list/emergeplaces = list()
		for_by_tcl(T, /obj/item/storage/toilet)
			if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
			emergeplaces.Add(T)
		if (emergeplaces.len)
			var/atom/picked = pick(emergeplaces)
			head.set_loc(picked.loc)
			playsound(picked.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			head.visible_message(SPAN_NOTICE("[head] emerges from [picked]!"))
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				var/vomit_message = SPAN_ALERT("[O] pukes all over [himself_or_herself(O)]. Thanks, [user].")
				O.vomit(0, null, vomit_message)

	playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
	health_update_queue |= user
	SPAWN(10 SECONDS)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/storage/toilet/random
	New()
		..()
		if (prob(1))
			var/something = pick(trinket_safelist)
			if (ispath(something))
				src.storage.add_contents(new something(src))

/obj/item/storage/toilet/random/gold // important!!
	default_material = "gold"

/obj/item/storage/toilet/random/escapetools
	spawn_contents = list(/obj/item/wirecutters,\
	/obj/item/screwdriver,\
	/obj/item/wrench,\
	/obj/item/crowbar,)

/obj/item/storage/toilet/goldentoilet
	name = "golden toilet"
	icon_state = "toilet$$gold"
	desc = "The result of years of stolen Nanotrasen funds."
	default_material = "gold"
	uses_default_material_appearance = TRUE
