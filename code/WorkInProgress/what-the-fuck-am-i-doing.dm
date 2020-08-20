/obj/machinery/portapuke
	name = "Port-A-Puke"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	desc = "A weapon of pure terror."
	density = 1
	anchored = 0
	var/mob/occupant = null
	p_class = 1.5

	process()

		if(src.occupant && ishuman(occupant))
			var/mob/living/carbon/human/H = occupant

			if(src.occupant.loc != src)
				src.occupant = null
				src.update_icon()
				return

			if (isdead(H))
				src.visible_message("<span class='alert'>[src] spits out a dead corpse.</span>")
				src.eject_occupant()
				return

			if(H.health <= -180 && prob(25))
				src.visible_message("<span class='alert'>[src] spits out a near lifeless corpse.</span>")
				src.eject_occupant()
				return

			src.occupant.TakeDamage("All", 10, 0, 0, DAMAGE_BLUNT)

			playsound(get_turf(src), pick('sound/machines/mixer.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg','sound/effects/brrp.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/pump.ogg','sound/effects/syringeproj.ogg'), 100, 1)

			if (prob(5))
				visible_message("<span class='alert'>[H] pukes their guts out!</span>")
				playsound(get_turf(src), pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
				for (var/turf/T in range(src, rand(1, 3)))
					make_cleanable( /obj/decal/cleanable/blood/gibs,T)

				if (prob(5) && H.organHolder && H.organHolder.heart)
					H.organHolder.drop_organ("heart")
					H.visible_message("<span class='alert'><b>Wait, is that their heart!?</b></span>")

			if (prob(15))
				visible_message("<span class='alert'>[src] sprays vomit all around itself!</span>")
				playsound(get_turf(src), pick('sound/impact_sounds/Slimy_Splat_1.ogg','sound/misc/meat_plop.ogg'), 100, 1)
				for (var/turf/T in range(src, rand(1, 3)))
					if (prob(5))
						make_cleanable( /obj/decal/cleanable/greenpuke,T)
					else
						make_cleanable( /obj/decal/cleanable/vomit,T)

			if (prob(25))
				for (var/mob/O in viewers(src, null))
					if (O != occupant)
						O.show_message("<span class='alert'><b>[occupant]</b> is puking over and over! It's all slimy and stringy. Oh god.</span>", 1)
						if (prob(66) && ishuman(O))
							O.show_message("<span class='alert'>You feel [pick("<b>really</b>", "")] ill from watching that.</span>")
							for (var/mob/V in viewers(O, null))
								V.show_message("<span class='alert'>[O] pukes all over \himself!</span>", 1)
								O.vomit()

			if (prob(30))
				boutput(H, "<span class='alert'>You [pick("have a gut-wrenching sensation", "feel horribly sick", "feel like you're going to throw up", "feel like you're going to puke")]</span>")

			if (prob(40))
				H.emote("scream")


		else
			return


	relaymove(mob/user as mob)
		boutput(user, "<span class='alert'>You're trapped inside!</span>")
		return

	attackby(var/obj/item/I as obj, var/mob/user as mob)

		if (!isliving(user))
			boutput(user, "<span class='alert'>You're dead! Quit that!</span>")
			return

		if(istype(I, /obj/item/grab))
			var/obj/item/grab/G = I

			if (!G.affecting || !ismob(G.affecting))
				return

			if (src.occupant)
				boutput(user, "<span class='alert'>\the [src] already has a victim!</span>")
				return

			if (!ishuman(G.affecting))
				boutput(user, "<span class='alert'>You can't put a non-human in there, you idiot!</span>")
				return

			var/mob/living/carbon/human/H = G.affecting
			var/mob/living/L = user

			if (isdead(H))
				boutput(user, "<span class='alert'>[H] is dead and cannot be forced to puke.</span>")
				return

			if (isghostdrone(L))
				boutput(user, "<span class='alert'>You can't put a non-human in there, you idiot!</span>")
				return

			if (L.pulling == H)
				L.pulling = null

			src.add_fingerprint(usr)
			src.accept_occupant(H)
			src.update_icon()
			qdel(G)
			return

		if (iswrenchingtool(I))
			anchored = !anchored
			user.show_text("You [anchored ? "attach" : "release"] \the [src]'s floor clamps", "red")
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 0, 0)
			return

		..()


	proc/eject_occupant()
		if(src.occupant)
			src.occupant.name_prefix("puke covered")
			src.occupant.UpdateName()
			src.occupant.set_loc(get_turf(src))
			src.occupant = null
			update_icon()
			return

	proc/accept_occupant(var/mob/M)
		if(!src.occupant)
			src.occupant = M

			if(M.bioHolder)
				M.bioHolder.AddEffect("stinky")

			for(var/obj/O in src)
				O.set_loc(get_turf(src))

			M.set_loc(src)


	proc/update_icon()
		icon_state = "[src.occupant ? "pod_g" : "pod_0"]"
		return

	verb/enter()
		set name = "Enter"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return

		if (!ishuman(usr))
			boutput(usr, "<span class='alert'>You're not a human, you can't put yourself in there!</span>")
			return

		if (src.occupant)
			boutput(usr, "<span class='alert'>It's already occupied.</span>")
			return

		src.add_fingerprint(usr)
		src.accept_occupant(usr)
		src.update_icon()

		return
