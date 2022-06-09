/obj/machinery/portableowl //Owl version of the portable flasher
	name = "Portable Owl"
	desc = "A portable flashing... device? Hoot."
	icon = 'icons/obj/hooty.dmi'
	icon_state = "owl"
	event_handler_flags = USE_PROXIMITY | USE_FLUID_ENTER
	var/base_state = "owl"
	anchored = 0
	density = 1
	var/last_flash = 0
	var/flash_prob = 80

	proc/flash()
		if (src.last_flash && world.time < src.last_flash + 10)
			return

		playsound(src.loc, "sound/voice/animal/hoot.ogg", 100, 1)
		flick("[base_state]_flash", src)
		src.last_flash = world.time

	HasProximity(atom/movable/AM as mob|obj)
		if (src.last_flash && world.time < src.last_flash + 10)
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
				user.show_message(text("<span class='alert'>[src] can now be moved.</span>"))

			else if (src.anchored)
				user.show_message(text("<span class='alert'>[src] is now secured.</span>"))

	attack_hand(user)
		if (src.anchored)
			if (src.last_flash && world.time < src.last_flash + 10)
				return

			src.flash()

/obj/machinery/portableowl/attached
	anchored = 1

/obj/machinery/portableowl/judgementowl
	name = "Hooty McJudgementowl"
	desc = "A grumpy looking owl."
	icon_state = "judgementowl1"
	base_state = "judgementowl1"
	anchored = 1

	New()
		..()
		base_state = "judgementowl[rand(1,32)]"
		icon_state = base_state

	process()
		..()
		if (prob(10)) // I stole this from the automaton because I am a dirty code frankenstein
			var/list/mobsnearby = list()
			for (var/mob/M in view(7,src))
				if (iswraith(M) || isintangible(M))
					continue
				mobsnearby.Add("[M.name]")
			var/mob/M1 = null
			if (mobsnearby.len > 0)
				M1 = pick(mobsnearby)
			if (M1 && prob(50))
				src.visible_message("<span class='alert'><b>[src]</b> frowns at [M1].</span>")
