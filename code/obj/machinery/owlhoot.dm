/obj/machinery/portableowl //Owl version of the portable flasher
	name = "Portable Owl"
	desc = "A portable flashing... device? Hoot."
	icon = 'icons/obj/hooty.dmi'
	icon_state = "owl"
	var/base_state = "owl"
	anchored = UNANCHORED
	density = 1
	var/flash_prob = 80

	New()
		..()
		src.AddComponent(/datum/component/proximity)

	proc/flash()
		playsound(src.loc, 'sound/voice/animal/hoot.ogg', 100, 1)
		FLICK("[base_state]_flash", src)
		ON_COOLDOWN(src, "flash", 5 SECONDS)

	EnteredProximity(atom/movable/AM)
		if(GET_COOLDOWN(src, "flash"))
			return

		if (iscarbon(AM))
			var/mob/living/carbon/M = AM
			if ((M.m_intent != "walk") && (src.anchored))
				if (M.client) // I can't take it anymore I can't take the destiny owls reacting to the monkey it's driving me mad
					if (prob(flash_prob))
						src.flash()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			add_fingerprint(user)
			src.anchored = !src.anchored

			if (!src.anchored)
				user.show_message(SPAN_ALERT("[src] can now be moved."))

			else if (src.anchored)
				user.show_message(SPAN_ALERT("[src] is now secured."))

	attack_hand(user)
		if (src.anchored)
			if(GET_COOLDOWN(src, "flash"))
				return

			src.flash()

/obj/machinery/portableowl/attached
	anchored = ANCHORED

/obj/machinery/portableowl/judgementowl
	name = "Hooty McJudgementowl"
	desc = "A grumpy looking owl."
	icon_state = "judgementowl1"
	base_state = "judgementowl1"
	anchored = ANCHORED

	New()
		..()
		base_state = "judgementowl[rand(1,32)]"
		icon_state = base_state

	process()
		..()
		if (prob(5)) // I stole this from the automaton because I am a dirty code frankenstein
			var/list/mob/mobs_nearby = list()
			for (var/mob/M as anything in viewers(7, src))
				if (iswraith(M) || isintangible(M))
					continue
				mobs_nearby += M
			if(length(mobs_nearby))
				var/mob/frown_target = pick(mobs_nearby)
				if (frown_target)
					src.visible_message(SPAN_ALERT("<b>[src]</b> frowns at [frown_target]."))
