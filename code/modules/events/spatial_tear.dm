/datum/random_event/major/spatial_tear
	name = "Spatial Tear"
	centcom_headline = "Spatial Anomaly"
	centcom_message = "A severe spatial anomaly has been detected near the station. Personnel are advised to avoid any unusual phenomenae."
	centcom_origin = ALERT_ANOMALY
	required_elapsed_round_time = 10 MINUTES

	event_effect(var/source)
		..()
		var/barrier_duration = rand(1 MINUTE, 5 MINUTES)
		var/pickx = rand(40,175)
		var/picky = rand(75,140)
		var/btype = rand(1,2)
		var/count = btype == 1 ? world.maxy : world.maxx // could just set it to our current mapsize (300) but this should help in case that changes again in the future or we go with non-square maps for some reason??  :v
		if (btype == 1)
			// Vertical
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(pickx,count,1),barrier_duration)
				B.icon_state = "spat-v"
				count -= 1
		else
			// Horizontal
			while (count > 0)
				var/obj/forcefield/event/B = new /obj/forcefield/event(locate(count,picky,1),barrier_duration)
				B.icon_state = "spat-h"
				count -= 1

/obj/forcefield/event
	name = "Spatial Tear"
	desc = "A breach in the spatial fabric. Extremely difficult to pass."
	icon = 'icons/effects/effects.dmi'
	icon_state = "spat-h"
	anchored = 1
	opacity = 1
	density = 1
	var/stabilized = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE

	New(var/loc,var/duration)
		..()
		START_TRACKING
		//spatial interdictor: mitigate spatial tears
		//consumes 800 units of charge per tear segment weakened
		//weakened tears can be traversed, but inflict minor brute damage
		for_by_tcl(IX, /obj/machinery/interdictor)
			if (IX.expend_interdict(800,src))
				src.stabilize()
				break
		SPAWN(duration)
			qdel(src)

	disposing()
		STOP_TRACKING
		..()

	attack_hand(mob/user)
		if(src.stabilized)
			src.try_pass(user)

	Bumped(var/mob/AM as mob)
		. = ..()
		if(!istype(AM)) return
		if(AM.client?.check_key(KEY_RUN) && src.stabilized)
			src.try_pass(AM)

	ex_act(severity)
		return

	meteorhit()
		return

	proc/try_pass(mob/user)
		actions.start(new /datum/action/bar/icon/push_through_tear(user, src), user)

	proc/stabilize()
		src.alpha = 150
		src.set_opacity(0)
		src.stabilized = 1
		src.name = "Stabilized Spatial Tear"
		desc = "A breach in the spatial fabric, partially stabilized by an interdictor. Difficult to pass."


/datum/action/bar/icon/push_through_tear
	duration = 2 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "push_through_tear"
	icon = 'icons/ui/actions.dmi'
	icon_state = "tear_push"
	var/mob/ownerMob
	var/obj/forcefield/event/spatialtear
	var/turf/jump_target //where the mob will move to when they complete the jump!
	var/no_no_zone //if the user is trying to jump over railing onto somewhere they couldn't otherwise move through...
	var/do_bunp = TRUE

	New(The_Owner, The_Tear)
		..()
		if (The_Owner)
			owner = The_Owner
			ownerMob = The_Owner
		if (The_Tear)
			spatialtear = The_Tear
			jump_target = get_turf(spatialtear)

	onUpdate()
		..()
		// you gotta hold still to jump!
		if (BOUNDS_DIST(ownerMob, spatialtear) > 0)
			interrupt(INTERRUPT_ALWAYS)
			ownerMob.show_text("Your attempt to push through the spatial tear was interrupted!", "red")
			return

	onStart()
		..()
		if (BOUNDS_DIST(ownerMob, spatialtear) > 0 || spatialtear == null || ownerMob == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[ownerMob] begins to push [himself_or_herself(ownerMob)] through [spatialtear]!", "red")

	onEnd()
		..()
		if(do_bunp())
			return
		sendOwner()

	proc/do_bunp()
		var/list/bunp_whitelist = list(/obj/forcefield/event,/obj/decal/stage_edge) // things that we cannot bunp into
		if (jump_target.density)
			no_no_zone = 1
		else
			for (var/obj/o in jump_target.contents)
				for (var/i=1, i <= bunp_whitelist.len + 1, i++) //+1 so we can actually go past the whitelist len check
					if (!(i > bunp_whitelist.len))
						// if it's an exception to the bunp rule...
						if (istype (o, bunp_whitelist[i]))
							break

					// don't proceed just yet if we aren't done going through the whitelist!
					else if (i <= bunp_whitelist.len)
						continue

					// otherwise, if it's a dense thing...
					else if (o.density)
						no_no_zone = 1
						break

		if(no_no_zone)
			// turns out trying to phase into a solid object is an EXTRA bad idea
			if (istype(ownerMob, /mob/living))
				if (!ownerMob.hasStatus("weakened"))
					ownerMob.changeStatus("weakened", 4 SECONDS)
				ownerMob.TakeDamage("All", rand(24,30), 0, 0, DAMAGE_BLUNT)
				playsound(spatialtear, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1, -1)
				for(var/mob/O in AIviewers(ownerMob))
					O.show_text("<b>[ownerMob] shreds [himself_or_herself(ownerMob)] trying to phase into a solid object!</b>[prob(30) ? pick(" That's gotta hurt.", " <b>Holy shit!</b>", " Maybe that wasn't the wisest idea...", " Don't do that!") : null]", "red")
			return TRUE
		return FALSE

	proc/sendOwner()
		ownerMob.set_loc(jump_target)
		for(var/mob/O in AIviewers(ownerMob))
			O.show_text("[ownerMob] pushes [himself_or_herself(ownerMob)] through [spatialtear].", "red")
		ownerMob.show_text("You take some damage from pushing through the tear.", "red")
		ownerMob.TakeDamage("chest", rand(4,6), 0, 0, DAMAGE_BLUNT)
		playsound(spatialtear, 'sound/impact_sounds/Flesh_Tear_3.ogg', 20, 1, -1)
		logTheThing(LOG_COMBAT, ownerMob, "pushes through [spatialtear].")
