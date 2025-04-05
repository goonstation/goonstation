
/mob/living/carbon
	gender = MALE // WOW RUDE
	var/last_eating = 0

	var/oxyloss = 0
	var/toxloss = 0
	var/brainloss = 0
	//var/brain_op_stage = 0
	//var/heart_op_stage = 0

	infra_luminosity = 4

/mob/living/carbon/New()
	START_TRACKING
	. = ..()

/mob/living/carbon/disposing()
	STOP_TRACKING
	..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		//SLIP handling
		if (!src.throwing && !src.lying && isturf(NewLoc))
			var/turf/T = NewLoc
			if (T.turf_flags & MOB_SLIP)
				var/wet_adjusted = T.wet
				if (traitHolder?.hasTrait("super_slips") && (T.wet > 0)) //slippery when wet
					wet_adjusted = max(wet_adjusted, 2) //whee

				switch (wet_adjusted)
					if (-1) //slime
						if(src.getStatusDuration("slowed")<1)
							boutput(src, SPAN_NOTICE("You get slowed down by the slimy floor!"))
						if(src.getStatusDuration("slowed")< 10 SECONDS)
							src.changeStatus("slowed", 3 SECONDS)

					if (-2) //glue
						if(src.getStatusDuration("slowed")<1)
							boutput(src, SPAN_NOTICE("You get slowed down by the sticky floor!"))
						if(src.getStatusDuration("slowed")< 10 SECONDS)
							src.changeStatus("slowed", 3 SECONDS)

					if (1) //ATM only the ancient mop does this
						if (locate(/obj/item/clothing/under/towel) in T)
							src.inertia_dir = 0
							T.wet = 0
							return
						if (src.slip())
							boutput(src, SPAN_NOTICE("You slipped on the wet floor!"))
							src.unlock_medal("I just cleaned that!", 1)
						else
							src.inertia_dir = 0
							return

					if (2) //lube
						src.remove_pulling()
						boutput(src, SPAN_NOTICE("You slipped on the floor!"))
						playsound(T, 'sound/misc/slip.ogg', 50, TRUE, -3)
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 12, 1, throw_type = THROW_SLIP)

					if (3) // superlube
						src.remove_pulling()
						src.changeStatus("knockdown", 3.5 SECONDS)
						playsound(T, 'sound/misc/slip.ogg', 50, TRUE, -3)
						boutput(src, SPAN_NOTICE("You slipped on the floor!"))
						var/atom/target = get_edge_target_turf(src, src.dir)
						src.throw_at(target, 30, 1, throw_type = THROW_SLIP)
						random_brute_damage(src, 10)



/mob/living/carbon/relaymove(mob/user, direction, delay, running)
	src.organHolder?.stomach?.relaymove(user, direction, delay, running)

/mob/living/carbon/gib(give_medal, include_ejectables)
	for (var/mob/dead/target_observer/obs in src)
		obs.cancel_camera()

	for(var/mob/M in src.organHolder?.stomach?.contents)
		src.visible_message(SPAN_ALERT("<B>[M] bursts out of [src]!</B>"))
		M.set_loc(src.loc)

	. = ..(give_medal, include_ejectables)

/mob/living/carbon/swap_hand()
	var/obj/item/grab/block/B = src.check_block(ignoreStuns = 1)
	if(B)
		qdel(B)
	src.hand = !src.hand

/mob/living/carbon/lastgasp(allow_dead=FALSE, grunt = -1)
	if(grunt == -1)
		grunt = pick("NGGH","OOF","UGH","ARGH","BLARGH","BLUH","URK")
	return ..()


/mob/living/carbon/full_heal()
	src.take_toxin_damage(-INFINITY)
	src.take_oxygen_deprivation(-INFINITY)
	..()

/mob/living/carbon/stabilize()
	src.take_toxin_damage(-max(src.toxloss-10, 0))
	src.take_oxygen_deprivation(-max(src.oxyloss-10, 0))
	..()

/mob/living/carbon/take_brain_damage(var/amount)
	if (..())
		return

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	src.brainloss = clamp(src.brainloss + amount, 0, 120)

	if (src.brainloss >= 120 && isalive(src))
		// instant death, we can assume a brain this damaged is no longer able to support life
		src.visible_message(SPAN_ALERT("<b>[src.name]</b> goes limp, their facial expression utterly blank."))
		src.death()
		return

	return

/mob/living/carbon/take_toxin_damage(var/amount)
	if (!toxloss && amount < 0)
		amount = 0
	if (..())
		return 1

	if (src.traitHolder && src.traitHolder.hasTrait("reversal"))
		amount *= -1

	var/resist_toxic = src.bioHolder?.HasEffect("resist_toxic")

	if(resist_toxic && amount > 0)
		if(resist_toxic > 1)
			src.toxloss = 0
			return 1 //prevent organ damage
		else
			amount *= 0.33

	src.toxloss = max(0,src.toxloss + amount)
	return

/mob/living/carbon/take_oxygen_deprivation(var/amount)
	if (!oxyloss && amount < 0)
		return
	if (..())
		return

	if (HAS_ATOM_PROPERTY(src, PROP_MOB_BREATHLESS))
		src.oxyloss = 0
		return

	if (ispug(src))
		var/mob/living/carbon/human/H = src
		amount *= 2
		if (!isdead(src))
			H.emote(pick("wheeze", "cough", "sputter"))

	src.oxyloss = max(0,src.oxyloss + amount)
	return

/mob/living/carbon/get_brain_damage()
	return src.brainloss

/mob/living/carbon/get_toxin_damage()
	return src.toxloss

/mob/living/carbon/get_oxygen_deprivation()
	return src.oxyloss

