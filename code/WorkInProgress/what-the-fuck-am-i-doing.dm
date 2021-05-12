/obj/machinery/portapuke
	name = "Port-A-Puke"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "puke_0"
	desc = "A weapon of pure terror."
	density = 1
	anchored = 0
	p_class = 1.5
	processing_tier = PROCESSING_FULL
	var/list/list/mob/occupant_buckets
	var/current_bucket
	var/n_occupants = 0
	var/max_occupants = INFINITY


	New()
		..()
		src.occupant_buckets = list()
		src.occupant_buckets.len = 8 // based on processing_tier
		for(var/i in 1 to occupant_buckets.len)
			src.occupant_buckets[i] = list()
		src.UnsubscribeProcess() // will get subscribed when the first victim enters


	disposing()
		src.occupant_buckets = null
		. = ..()


	Exited(atom/movable/Obj, atom/newloc)
		. = ..()
		if(isliving(Obj))
			src.on_eject_occupant(Obj)


	Entered(atom/movable/Obj, atom/OldLoc)
		if(isliving(Obj) && src.n_occupants >= src.max_occupants)
			Obj.set_loc(OldLoc)
			Obj.visible_message("<span class='alert'>[Obj] doesn't manage to fit into \the [src].</span>")
			return FALSE
		. = ..()
		if(isliving(Obj))
			src.on_accept_occupant(Obj)


	process()
		src.current_bucket++
		for(var/mob/living/L in src.occupant_buckets[src.current_bucket])
			src.process_occupant(L)
		src.current_bucket = src.current_bucket % length(src.occupant_buckets)

		if(src.current_bucket == 0 && src.n_occupants > 0)
			process_big_effects()


	proc/process_big_effects()
		playsound(get_turf(src),
			pick(
				"sound/machines/mixer.ogg",
				"sound/impact_sounds/Slimy_Splat_1.ogg",
				"sound/misc/meat_plop.ogg",
				"sound/effects/brrp.ogg",
				"sound/impact_sounds/Metal_Clang_1.ogg",
				"sound/effects/pump.ogg",
				"sound/effects/syringeproj.ogg")
			, 100, 1)

		if (prob(15))
			visible_message("<span class='alert'>[src] sprays vomit all around itself!</span>")
			playsound(get_turf(src), pick("sound/impact_sounds/Slimy_Splat_1.ogg","sound/misc/meat_plop.ogg"), 100, 1)
			for (var/turf/T in range(src, rand(1, 3)))
				if(T.density)
					continue
				if (prob(5))
					make_cleanable(/obj/decal/cleanable/greenpuke, T)
				else
					make_cleanable(/obj/decal/cleanable/vomit, T)


	proc/process_occupant(mob/living/occupant)
		if(occupant.loc != src)
			src.update_icon()
			return

		if (isdead(occupant))
			src.visible_message("<span class='alert'>[src] spits out a dead corpse.</span>")
			occupant.set_loc(src.loc)
			return

		if(occupant.health <= -180 && prob(25))
			src.visible_message("<span class='alert'>[src] spits out a near lifeless corpse.</span>")
			occupant.set_loc(src.loc)
			return

		occupant.TakeDamage("All", 10, 0, 0, DAMAGE_BLUNT)

		if (prob(5))
			visible_message("<span class='alert'>[occupant] pukes [his_or_her(occupant)] guts out!</span>")
			playsound(get_turf(src), pick("sound/impact_sounds/Slimy_Splat_1.ogg","sound/misc/meat_plop.ogg"), 100, 1)
			for (var/turf/T in range(src, rand(1, 3)))
				if(T.density)
					continue
				make_cleanable(/obj/decal/cleanable/blood/gibs, T)

			if (prob(5) && occupant.organHolder?.heart)
				occupant.organHolder.drop_organ("heart")
				occupant.visible_message("<span class='alert'><b>Wait, is that [his_or_her(occupant)] heart!?</b></span>")

		if (prob(30))
			boutput(occupant, "<span class='alert'>You [pick("have a gut-wrenching sensation", "feel horribly sick", "feel like you're going to throw up", "feel like you're going to puke")]</span>")

		if (prob(25))
			for (var/mob/O in viewers(src, null))
				if (O == occupant || isdead(O))
					continue
				O.show_message("<span class='alert'><b>[occupant]</b> is puking over and over! It's all slimy and stringy. Oh god.</span>", 1)
				if (prob(66))
					O.vomit()
					O.visible_message("<span class='alert'>[O] pukes all over \himself!</span>", "<span class='alert'>You feel [pick("<b>really</b>", "")] ill from watching that.</span>")

		if (prob(40))
			SPAWN_DBG(0) // linter demands this
				occupant.emote("scream")


	relaymove(mob/user as mob)
		boutput(user, "<span class='alert'>You're trapped inside!</span>")


	attackby(var/obj/item/I as obj, var/mob/user as mob)
		if (!isliving(user))
			boutput(user, "<span class='alert'>You're dead! Quit that!</span>")
			return

		if(istype(I, /obj/item/grab))
			var/obj/item/grab/G = I

			if (!G.affecting || !ismob(G.affecting))
				return

			var/mob/living/target = G.affecting
			var/mob/living/L = user

			if (isdead(target))
				boutput(user, "<span class='alert'>[target] is dead and cannot be forced to puke.</span>")
				return

			if (L.pulling == target)
				L.pulling = null

			src.add_fingerprint(user)
			target.set_loc(src)
			src.update_icon()
			qdel(G)
			return

		if (iswrenchingtool(I))
			anchored = !anchored
			user.show_text("You [anchored ? "attach" : "release"] \the [src]'s floor clamps", "red")
			playsound(get_turf(src), "sound/items/Ratchet.ogg", 40, 0, 0)
			return

		. = ..()


	proc/on_eject_occupant(mob/living/occupant)
		for(var/list/bucket in src.occupant_buckets)
			bucket -= occupant
		occupant.name_prefix("puke covered")
		occupant.UpdateName()
		src.n_occupants--
		if(src.n_occupants <= 0)
			src.UnsubscribeProcess()
		update_icon()

	proc/on_accept_occupant(mob/living/occupant)
		var/list/target_bucket = src.occupant_buckets[1]
		for(var/list/bucket in src.occupant_buckets)
			if(length(bucket) < length(target_bucket))
				target_bucket = bucket
		target_bucket += occupant

		if(src.n_occupants <= 0)
			src.SubscribeToProcess()
		src.n_occupants++

		src.update_icon()

		occupant.bioHolder?.AddEffect("stinky")

		for(var/obj/O in src)
			O.set_loc(get_turf(src))


	proc/update_icon()
		icon_state = src.n_occupants > 0 ? "puke_1" : "puke_0"


	verb/enter()
		set name = "Enter"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return

		src.add_fingerprint(usr)
		usr.set_loc(src)
