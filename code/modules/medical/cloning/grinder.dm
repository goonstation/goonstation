//WHAT DO YOU WANT FROM ME(AT)
TYPEINFO(/obj/machinery/clonegrinder)
	mats = 10

/obj/machinery/clonegrinder
	name = "enzymatic reclaimer"
	desc = "A tank resembling a rather large blender, designed to recover biomatter for use in cloning."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "grinder0"
	anchored = ANCHORED
	density = 1
	power_usage = 100 WATTS
	var/list/pods = null // cloning pods we're tied to
	var/id = null // if this isn't null, we'll only look for pods with this ID
	var/pod_range = 4 // if we don't have an ID, we look for pods in orange(this value)
	var/process_timer = 0	// how long this shit is running for
	var/process_per_tick = 0	// how much shit it will output per tick
	var/mob/living/occupant = null
	var/list/meats = list() //Meat that we want to reclaim.
	var/max_meat = 7 //To be honest, I added the meat reclamation thing in part because I wanted a "max_meat" var.
	var/emagged = 0
	var/auto_strip = 1 // disabled when emagged (people were babies about this when it being turned off was the default) :V
	var/upgraded = 0 // upgrade card makes the reclaimer more efficient

	New()
		..()
		UnsubscribeProcess()
		src.create_reagents(100)
		src.UpdateIcon(1)
		SPAWN(0)
			src.find_pods()

	disposing()
		occupant?.set_loc(get_turf(src.loc))
		occupant = null
		..()

	get_desc(dist, mob/user)
		. = ..()
		if (src.upgraded)
			. += "This one has an efficiency upgrade installed."

	proc/find_pods()
		if (!islist(src.pods))
			src.pods = list()
		if (!isnull(src.id) && genResearch && islist(genResearch.clonepods) && length(genResearch.clonepods))
			for (var/obj/machinery/clonepod/pod as anything in genResearch.clonepods)
				if (pod.id == src.id && !src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] (ID [src.id]) in genResearch.clonepods")
		else
			for (var/obj/machinery/clonepod/pod in orange(src.pod_range))
				if (!src.pods.Find(pod))
					src.pods += pod
					DEBUG_MESSAGE("[src] adds pod [log_loc(pod)] in orange([src.pod_range])")

	verb/eject()
		set src in oview(1)
		set category = "Local"
		if (!isalive(usr) || iswraith(usr)) return
		if (src.process_timer > 0) return
		src.eject_meats()
		src.go_out()
		add_fingerprint(usr)
		return

	relaymove(mob/user as mob)
		src.go_out()
		return

	proc/eject_meats()
		for (var/obj/item/meat in src.meats)
			meat.set_loc(src.loc)
		src.meats = list()

	proc/go_out()
		if (!src.occupant)
			return
		for(var/obj/O in src)
			O.set_loc(src.loc)
		src.occupant.set_loc(src.loc)
		src.occupant = null
		return

	process()
		if (src.status & NOPOWER)
			return

		if (src.status & BROKEN)
			if (process_timer > 0)
				process_timer--
				return
			// we're out of meat, switch faults
			var/datum/component/equipment_fault/messy/messy = src.GetComponent(/datum/component/equipment_fault/messy)
			if (istype(messy))
				var/tool_flags = messy.interactions
				src.RemoveComponentsOfType(/datum/component/equipment_fault/messy/)
				AddComponent(/datum/component/equipment_fault/grumble, tool_flags)
			return

		process_timer--
		if (process_timer > 0)
			// Add reagents for this tick
			src.reagents.add_reagent("blood", 2 * process_per_tick)
			src.reagents.add_reagent("meat_slurry", 2 * process_per_tick)
			if (prob(2))
				src.reagents.add_reagent("beff", 1 * process_per_tick)

		if (src.reagents.total_volume && islist(src.pods) && length(pods))
			// Distribute reagents to cloning pods nearby
			// Changed from before to distribute while grinding rather than all at once
			// give an equal amount of reagents to each pod that happens to be around
			var/volume_to_share = (src.reagents.total_volume / max(pods.len, 1))
			for (var/obj/machinery/clonepod/pod in src.pods)
				src.reagents.trans_to(pod, volume_to_share)
				DEBUG_MESSAGE("[src].reagents.trans_to([pod] [log_loc(pod)], [src.reagents.total_volume]/[max(pods.len, 1)])")

		if (process_timer <= 0)
			UnsubscribeProcess()
			UpdateIcon(1)

		return

	on_reagent_change()
		..()
		src.UpdateIcon(0)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				boutput(user, SPAN_NOTICE("You override the reclaimer's safety mechanism."))
			logTheThing(LOG_COMBAT, user, "emagged [src] at [log_loc(src)].")
			emagged = 1
			return 1
		else
			if (user)
				boutput(user, "The safety mechanism's already burnt out!")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		emagged = 0
		if (user)
			boutput(user, SPAN_NOTICE("You repair the reclaimer's safety mechanism."))
		return 1

	attack_hand(mob/user)
		interact_particle(user,src)
		if (src.status & (BROKEN | NOPOWER))
			boutput(user, SPAN_ALERT("The [src.name] is not functioning!"))
			return

		if (src.process_timer > 0)
			boutput(user, SPAN_ALERT("The [src.name] is already running!"))
			return

		if (!src.meats.len && !src.occupant)
			boutput(user, SPAN_ALERT("There is nothing loaded to reclaim!"))
			return

		if (src.occupant && src.occupant.loc != src)
			src.occupant = null
			boutput(user, SPAN_ALERT("There is nothing loaded to reclaim!"))
			return

		user.visible_message("<b>[user]</b> activates [src]!", "You activate [src].")
		if (istype(src.occupant))
			logTheThing(LOG_COMBAT, user, "activated [src.name] with [constructTarget(src.occupant,"combat")] ([isdead(src.occupant) ? "dead" : "alive"]) inside at [log_loc(src)].")
			if (!isdead(src.occupant) && !isnpcmonkey(src.occupant))
				message_admins("[key_name(user)] activated [src.name] with [key_name(src.occupant, 1)] (alive) inside at [log_loc(src)].")
		src.start_cycle()
		return

	proc/start_cycle()
		src.find_pods()

		// how much we will be producing
		var/process_total = 0

		if (istype(src.occupant))
			src.occupant.death(TRUE)
			var/humanOccupant = (ishuman(src.occupant) && !ismonkey(src.occupant))
			var/decomp = ishuman(src.occupant) ? src.occupant:decomp_stage : 0 // changed from only checking humanOccupant to running ishuman again so monkeys' decomp will be considered
			if (src.occupant.mind)
				src.occupant.ghostize()
				qdel(src.occupant)
			else
				qdel(src.occupant)
			src.occupant = null

			// Old table of cloner values --
			// grinder used to count down and added either x or x + 2 depending on upgrade
			// now uses varying amounts of things! i guess!
			// here is the old code and a table of how the timer was calculated:
			// var/mult = src.upgraded ? rand(2,4) : rand(4,8)
			// src.process_timer = (humanOccupant ? 2 : 1)
			// src.process_timer *= (mult - (2 * decomp))
			// ------------------------------------------------
			// process_timer    ____speedy|normal__________
			// mult>              2   3   4   5   6   7   8  (note: speedy would increase
			// Decomp stage  0    4   6   8  10  12  14  16   reagent production by * 2)
			//               1    0   2   4   6   8  10  12
			//               2   -4  -2   0   2   4   6   8  (slightly decomposed bodies
			//               3   -8  -6  -4  -2   0   2   4   became worthless with
			//               4  -12 -10  -8  -6  -4  -2   0   speedy grinder upgrade)
			// total reagents: process_timer * (speedy ? 2 : 1)
			// this effectively means/meant that the speedy upgrade was faster,
			// but otherwise objectively worse if you had decomposed corpses

			// attempting to rewrite this to be better or at least different, i guess
			// First, how much are we going to get from this?
			//                        rand  human   decomp        total
			// Human, no decomposure: (5~8) * 2 * (4.5 / 4.5) =  10 ~ 16
			// Human, stage 1:        (5~8) * 2 * (3.5 / 4.5) = 8.8 ~12.4
			// Human, stage 2:        (5~8) * 2 * (2.5 / 4.5) = 5.5 ~ 7.7
			// Human, stage 3:        (5~8) * 2 * (1.5 / 4.5) = 3.3 ~ 5.3
			// Human, stage 4:        (5~8) * 2 * (0.5 / 4.5) = 1.1 ~ 1.7
			// Non-human monkey:      (5~8) * 1 * (4.5 / 4.5) =   5 ~ 8
			process_total += rand(5, 8) * (humanOccupant ? 2 : 1) * ((4.5 - decomp) / 4.5)

			//DEBUG_MESSAGE("[src] process_timer calced as [src.process_timer] (upgraded [src.upgraded], mult [mult], humanOccupant [humanOccupant])")
			//DEBUG_MESSAGE("[src] rough end result of cycle: [(src.process_timer * (src.upgraded ? 8 : 4))]u + up to [(src.process_timer * (src.upgraded ? 2 : 1))]u")

		if (src.meats.len)
			for (var/obj/item/theMeat in src.meats)
				src.meats -= theMeat
				if (theMeat.reagents)
					theMeat.reagents.trans_to(src, src.upgraded ? 10 : 5)

				qdel(theMeat)
				// Each bit of meat adds 2 units
				process_total += 2

			src.meats.len = 0

		// process_timer = total * 0.8 or 0.4 (rounded up) - slightly faster than before
		// normal:
		// 8 * 2 (human) =    16 units
		// 16 * 0.8 = 12.8 -> 13 ticks
		// 16 / 13 =           1.2307 per tick
		// upgraded:
		// 8 * 2 =            16 units
		// 16 * 0.4 = 6.4 ->   7 ticks
		// 16 / 7 =            2.2857 per tick
		// end result is that they produce the same amounts, the upgrade just does it faster
		src.process_timer = ceil(process_total * (src.upgraded ? 0.4 : 0.8))
		src.process_per_tick = process_total / process_timer

		src.UpdateIcon(1)
		SubscribeToProcess()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/grinder_upgrade))
			if (src.upgraded)
				boutput(user, SPAN_ALERT("There is already an upgrade card installed."))
				return
			user.visible_message("[user] installs [I] into [src].", "You install [I] into [src].")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			src.upgraded = 1
			user.drop_item()
			qdel(I)
			return

		if (ispryingtool(I))
			if (src.upgraded)
				user.visible_message("[user] begins removing the upgrade module from [src].", "You begin removing the upgrade module from [src].")
				playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
				SETUP_GENERIC_ACTIONBAR(user, src, 5 SECONDS, PROC_REF(remove_upgrade_module), list(user), I.icon, I.icon_state, null, INTERRUPT_STUNNED | INTERRUPT_ACT | INTERRUPT_MOVE | INTERRUPT_ATTACKED)
			else
				boutput(user, SPAN_ALERT("There is no upgrade card installed."))
			return
		if (src.process_timer > 0)
			boutput(user, SPAN_ALERT("The [src.name] is still running, hold your horses!"))
			return
		if (istype(I, /obj/item/reagent_containers/food/snacks/ingredient/meat) || (istype(I, /obj/item/reagent_containers/food) && (findtext(I.name, "meat")||findtext(I.name,"bacon"))) || (istype(I, /obj/item/parts/human_parts)) || istype(I, /obj/item/clothing/head/butt) || istype(I, /obj/item/organ) || istype(I,/obj/item/raw_material/martian))
			if (length(src.meats) >= src.max_meat)
				boutput(user, SPAN_ALERT("There is already enough meat in there! You should not exceed the maximum safe meat level!"))
				return

			if (I.contents && length(I.contents) > 0 && !istype(I, /obj/item/reagent_containers/food/snacks/shell))
				for (var/obj/item/W in I.contents)
					if (istype(W, /obj/item/skull) || istype(W, /obj/item/organ/brain) || istype(W, /obj/item/organ/eye))
						continue

					if (W)
						W.set_loc(user.loc)
						W.dropped(user)
						W.layer = initial(W.layer)

			src.meats += I
			user.u_equip(I)
			I.set_loc(src)
			user.visible_message("<b>[user]</b> loads [I] into [src].","You load [I] into [src]")
			return

		else if (istype(I, /obj/item/reagent_containers/glass))
			return // handled in reagent afterattack

		boutput(user, SPAN_ALERT("This item is not suitable for [src]."))
		return

	update_icon(update_grindpaddle=FALSE)
		if (src.status & BROKEN)
			src.icon_state = "grinderb"
			ClearSpecificOverlays(TRUE, "paddle")
			return

		var/fluid_level = ((src.reagents.total_volume >= (src.reagents.maximum_volume * 0.6)) ? 2 : (src.reagents.total_volume >= (src.reagents.maximum_volume * 0.2) ? 1 : 0))

		src.icon_state = "grinder[fluid_level]"

		if (src.status & NOPOWER)
			UpdateOverlays(image(src.icon, "grindpaddle0"), "paddle") // stop the paddle if no power
			return

		if (update_grindpaddle)
			UpdateOverlays(image(src.icon, "grindpaddle[src.process_timer > 0 ? 1 : 0]"),"paddle")
			UpdateOverlays(image(src.icon, "grindglass[fluid_level]"),"glass")
		return

	ex_act(severity)
		switch(severity)
			if(1)
				for(var/atom/movable/A as mob|obj in src)
					A.set_loc(src.loc)
					A.ex_act(severity)
				qdel(src)
				return
			if(2)
				if (prob(50))
					for(var/atom/movable/A as mob|obj in src)
						A.set_loc(src.loc)
						A.ex_act(severity)
					qdel(src)
					return
			if(3)
				if (prob(25))
					src.set_broken()

	bullet_act(obj/projectile/P)
		. = ..()
		if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
			if(prob(P.power * P.proj_data?.ks_ratio))
				src.set_broken()

	overload_act()
		return !src.set_broken()

	is_open_container()
		return -1

	power_change()
		. = ..()
		src.UpdateIcon(TRUE)
		if (src.status & BROKEN)
			src.SubscribeToProcess()

	set_broken()
		. = ..()
		if(.) return
		if (src.process_timer > 0)
			AddComponent(/datum/component/equipment_fault/messy, tool_flags = TOOL_SCREWING | TOOL_WRENCHING, cleanables = list(
				/obj/decal/cleanable/blood/gibs=50,
				/obj/decal/cleanable/blood/gibs/core=20,
				/obj/decal/cleanable/blood/gibs/body=10
			))
		else
			AddComponent(/datum/component/equipment_fault/grumble, tool_flags = TOOL_SCREWING | TOOL_WRENCHING)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (src.process_timer > 0)
			return 0
		if (src.occupant)
			boutput(user, SPAN_ALERT("[src] is full, you can't climb inside!"))
			return 0

		src.visible_message(SPAN_ALERT("<b>[user] climbs into [src] and turns it on!</b>"))

		user.unequip_all()
		user.set_loc(src)
		src.occupant = user

		src.start_cycle()

		SPAWN(50 SECONDS)
			if (user && !isdead(user)) // how????????? ?
				user.suiciding = 0 // just in case I guess
		return 1

	proc/remove_upgrade_module(mob/user)
		if(src.upgraded)
			src.upgraded = FALSE
			var/obj/upgrade = new /obj/item/grinder_upgrade(src.loc)
			src.visible_message(SPAN_ALERT("The [upgrade] module falls to the floor!"))
			playsound(src.loc, 'sound/effects/pop.ogg', 80, FALSE)
