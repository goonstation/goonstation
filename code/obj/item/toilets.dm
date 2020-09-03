/*
CONTAINS:
TOILET
*/

/obj/item/storage/toilet
	name = "toilet"
	w_class = 4.0
	anchored = 1.0
	density = 0.0
	mats = 5
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	var/status = 0.0
	var/clogged = 0.0
	anchored = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	rand_pos = 0
#if ASS_JAM
	var/timestopped = 0 // one time timstop for toilet fun in assday
#endif
/obj/item/storage/toilet/New()
	..()
	START_TRACKING

/obj/item/storage/toilet/disposing()
	STOP_TRACKING
	..()

/obj/item/storage/toilet/attackby(obj/item/W as obj, mob/user as mob)
	if (src.contents.len >= 7)
		boutput(user, "The toilet is clogged!")
		return
	if (istype(W, /obj/item/storage))
		return
	if (istype(W, /obj/item/grab))
		playsound(get_turf(src), "sound/effects/toilet_flush.ogg", 50, 1)
		user.visible_message("<span class='notice'>[user] gives [W:affecting] a swirlie!</span>", "<span class='notice'>You give [W:affecting] a swirlie. It's like Middle School all over again!</span>")
		return

	return ..()

/obj/item/storage/toilet/MouseDrop(atom/over_object, src_location, over_location)
	if (usr && over_object == usr && in_range(src, usr) && iscarbon(usr) && !usr.stat)
		usr.visible_message("<span class='alert'>[usr] [pick("shoves", "sticks", "stuffs")] [his_or_her(usr)] hand into [src]!</span>")
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
	..()

/obj/item/storage/toilet/MouseDrop_T(mob/living/carbon/human/M as mob, mob/user as mob) // Yeah, uh, only living humans should use the toilet
	if (!ticker)
		boutput(user, "You can't help relieve anyone before the game starts.")
		return
	if (!ishuman(M) || get_dist(src, user) > 1 || M.loc != src.loc || user.restrained() || user.stat)
		return
	if (M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if (istype(H.w_uniform, /obj/item/clothing/under/gimmick/mario) && istype(H.head, /obj/item/clothing/head/mario))
			user.visible_message("<span class='notice'>[user] dives into [src]!</span>", "<span class='notice'>You dive into [src]!</span>")
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(src.loc))
			playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)

			var/list/destinations = list()

			for (var/obj/item/storage/toilet/T in by_type[/obj/item/storage/toilet])
				if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z) || (istype(T.loc,/area) && T.loc:teleport_blocked))
					continue
				destinations.Add(T)

			if (destinations.len)
				var/atom/picked = pick(destinations)
				particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(picked.loc))
				M.set_loc(picked.loc)
				playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
				user.visible_message("<span class='notice'>[user] emerges from [src]!</span>", "<span class='notice'>You emerge from [src]!</span>")
			return

	if (M == user)
		user.visible_message("<span class='notice'>[user] sits on [src].</span>", "<span class='notice'>You sit on [src].</span>")
	else
		user.visible_message("<span class='notice'>[M] is seated on [src] by [user]!</span>")
	M.anchored = 1
	M.buckled = src
	M.set_loc(src.loc)
	src.add_fingerprint(user)
	return

/obj/item/storage/toilet/attack_hand(mob/user as mob)
#if ASS_JAM //timestop toilets
	if(timestopped == 1)
		if(prob(20))
			boutput(user, "Slow down buddy! Can't force the time stop toilet when it don't want to!")
	else
		timestop(null, 100, 5)
		timestopped = 1
#endif
	for(var/mob/M in src.loc)
		if (M.buckled)
			if (M != user)
				user.visible_message("<span class='notice'>[M] is zipped up by [user]. That's... that's honestly pretty creepy.</span>")
			else
				user.visible_message("<span class='notice'>[M] zips up.</span>", "<span class='notice'>You zip up.</span>")
//			boutput(world, "[M] is no longer buckled to [src]")
			reset_anchored(M)
			M.buckled = null
			src.add_fingerprint(user)
	if((src.clogged < 1) || (src.contents.len < 7) || (user.loc != src.loc))
		user.visible_message("<span class='notice'>[user] flushes [src].</span>", "<span class='notice'>You flush [src].</span>")
		playsound(get_turf(src), "sound/effects/toilet_flush.ogg", 50, 1)


#ifdef UNDERWATER_MAP
		var/turf/source = get_turf(src)
		if (source)
			var/turf/target = locate(source.x,source.y,5)
			for (var/thing in contents)
				var/atom/movable/A = thing
				A.set_loc(target)
#endif
		src.clogged = 0
		src.contents.len = 0

	else if((src.clogged >= 1) || (src.contents.len >= 7) || (user.buckled != src.loc))
		src.visible_message("<span class='notice'>The toilet is clogged!</span>")

/obj/item/storage/toilet/custom_suicide = 1
/obj/item/storage/toilet/suicide_in_hand = 0
/obj/item/storage/toilet/suicide(var/mob/living/carbon/human/user as mob)
	if (!ishuman(user) || !user.organHolder)
		return 0

	user.visible_message("<span class='alert'><b>[user] sticks [his_or_her(user)] head into [src] and flushes it, giving [him_or_her(user)]self an atomic swirlie!</b></span>")
	var/obj/head = user.organHolder.drop_organ("head")
	if (src.clogged >= 1 || src.contents.len >= 7)
		head.set_loc(src.loc)
		playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
		src.visible_message("<span class='notice'>[head] floats up out of the clogged [src.name]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span class='alert'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span class='alert'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()
	else
		var/list/emergeplaces = list()
		for (var/obj/item/storage/toilet/T in by_type[/obj/item/storage/toilet])
			if (T == src || !isturf(T.loc) || T.z != src.z  || isrestrictedz(T.z)) continue
			emergeplaces.Add(T)
		if (emergeplaces.len)
			var/atom/picked = pick(emergeplaces)
			head.set_loc(picked.loc)
			playsound(picked.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
			head.visible_message("<span class='notice'>[head] emerges from [picked]!</span>")
		for (var/mob/living/carbon/human/O in AIviewers(head, null))
			if (prob(33))
				O.visible_message("<span class='alert'>[O] pukes all over [him_or_her(O)]self. Thanks, [user].</span>",\
				"<span class='alert'>You feel ill from watching that. Thanks, [user].</span>")
				O.vomit()

	playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 1)
	health_update_queue |= user
	SPAWN_DBG(10 SECONDS)
		if (user)
			user.suiciding = 0
	return 1

/obj/item/storage/toilet/random
	New()
		..()
		if (prob(1))
			var/something = pick(trinket_safelist)
			if (ispath(something))
				new something(src)

/obj/item/storage/toilet/random/gold // important!!
	New()
		..()
		src.setMaterial(getMaterial("gold"))

/obj/item/storage/toilet/random/escapetools
	spawn_contents = list(/obj/item/wirecutters,\
	/obj/item/screwdriver,\
	/obj/item/wrench,\
	/obj/item/crowbar,)

/obj/item/storage/toilet/goldentoilet
	name = "golden toilet"
	icon_state = "goldentoilet"
	desc = "The result of years of stolen Nanotrasen funds."

	New()
		..()
		particleMaster.SpawnSystem(new /datum/particleSystem/sparkles(src))
