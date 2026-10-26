// TODO: merge this with the new ability system.
/datum/blob_ability
	var/name = null
	var/desc = null
	var/icon = 'icons/mob/blob_ui.dmi'
	var/icon_state = "blob-template"
	var/bio_point_cost = 0
	var/cooldown_time = 0
	var/last_used = 0
	var/targeted = 1
	var/mob/living/intangible/blob_overmind/owner
	var/atom/movable/screen/blob/button
	var/special_screen_loc = null
	var/helpable = 1
	var/list/tooltip_options = list()

	New()
		..()
		var/atom/movable/screen/blob/B = new /atom/movable/screen/blob(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.ability = src
		B.name = src.name
		B.desc = src.desc
		B.tooltip_options = src.tooltip_options
		src.button = B

	disposing()
		if (button)
			button.dispose()
			button = null
		owner = null
		..()

	proc
		onUse(var/turf/T)
			if (!istype(owner))
				return 1
			if (bio_point_cost > 0)
				if (!owner.hasPoints(bio_point_cost))
					boutput(owner, SPAN_ALERT("You do not have enough bio points to use that ability."))
					return 1
			if (cooldown_time > 0 && last_used > world.time)
				boutput(owner, SPAN_ALERT("That ability is on cooldown for [round((last_used - world.time) / 10)] seconds."))
				return 1
			var/area/A = get_area(T)
			if(A?.sanctuary)
				boutput(owner, SPAN_ALERT("You cannot use that ability here."))
				return 1
			return 0

		deduct_bio_points()
			if (bio_point_cost > 0)
				owner.usePoints(bio_point_cost)

		do_cooldown()
			//boutput(world, "cooldown initiated, length of [cooldown_time]")
			last_used = world.time + cooldown_time
			owner.update_buttons()
			SPAWN(cooldown_time + 1)
				//boutput(world, "cooldown over, refreshing UI")
				if (owner)
					owner.update_buttons()

		tutorial_check(var/id, var/turf/T)
			if (owner)
				if (owner.tutorial)
					if (!owner.tutorial.PerformAction(id, T))
						return 0
			return 1

		//place a bunch of random blob tiles around the center. runs through multiple loops to fill gaps

		auto_spread(turf/starter, maxRange = 3, maxTurfs = 15, maxLoops = 2, currentRange = 1, currentTurfs = 0, currentLoop = 1)
			//if we went outside the allowed range
			if (currentRange > maxRange)
				//if we have loops left, do so
				if (currentLoop < maxLoops)
					src.auto_spread(starter, maxRange, maxTurfs, maxLoops, 1, currentTurfs, currentLoop + 1)
				return

			var/list/outerArea = orange(currentRange, starter)

			//subtract the inner tiles (we only want the outer edge of our range)
			if (currentRange > 1)
				var/list/innerArea = orange(currentRange - 1, starter)
				outerArea -= innerArea

			for (var/turf/T in outerArea)
				//LAGCHECK(LAG_HIGH)

				//reached max amount of blob tiles to place
				if (currentTurfs > maxTurfs)
					return

				if (T.can_blob_spread_here(null, null, (isadmin(owner) || owner.admin_override)))
					var/obj/blob/B
					if (prob(5))
						B = new /obj/blob/lipid(T)
					else if (prob(5))
						B = new /obj/blob/ribosome(T)
					else if (prob(5))
						B = new /obj/blob/mitochondria(T)
					else if (prob(5))
						B = new /obj/blob/wall(T)
					else if (prob(5))
						B = new /obj/blob/firewall(T)
					else
						B = new /obj/blob(T)
					owner.total_placed++
					B.setOvermind(src.owner)
					currentTurfs++

			//recurse!
			src.auto_spread(starter, maxRange, maxTurfs, maxLoops, currentRange + 1, currentTurfs, currentLoop)


	// Wholesale stolen from ability_parent
	// last_cast -> last_used
	proc/update_cooldown_cost()
		if (!button)
			return
		var/newcolor = null
		var/on_cooldown = round((last_used - world.time) / 10)

		if (bio_point_cost)
			if (owner.bio_points < bio_point_cost)
				newcolor = rgb(64, 64, 64)
				button.point_overlay.maptext = "<span class='sh vb r ps2p' style='color: #cc2222;'>[bio_point_cost]</span>"
			else
				button.point_overlay.maptext = "<span class='sh vb r ps2p'>[bio_point_cost]</span>"
		else
			button.point_overlay.maptext = null

		if (on_cooldown > 0)
			newcolor = rgb(96, 96, 96)
			button.cooldown_overlay.alpha = 255
			button.cooldown_overlay.maptext = "<span class='sh vb c ps2p'>[min(999, on_cooldown)]</span>"
			button.point_overlay.alpha = 64
		else
			button.cooldown_overlay.alpha = 0
			button.point_overlay.alpha = 255

		if (newcolor != button.color)
			button.color = newcolor


/datum/blob_ability/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "blob-help0"
	targeted = 0
	special_screen_loc = "SOUTH,EAST"
	helpable = 0
	tooltip_options = list("align" = TOOLTIP_TOP | TOOLTIP_RIGHT)

	onUse(var/turf/T)
		if (..())
			return
		if (owner.help_mode)
			owner.help_mode = 0
			boutput(owner, SPAN_NOTICE("Help Mode has been deactivated."))
		else
			owner.help_mode = 1
			boutput(owner, SPAN_NOTICE("Help Mode has been activated. To disable it, click on this button again."))
		src.button.icon_state = "blob-help[owner.help_mode]"
		owner.update_buttons()


// BASIC ABILITIES

/datum/blob_ability/spread
	name = "Spread"
	icon_state = "blob-spread"
	desc = "This spends two bio-points to spread to the desired tile. Blobs must be placed cardinally adjacent to other blobs. This ability is free of cost and cooldown until the first time you reach 40 tiles."
	bio_point_cost = 2
	cooldown_time = 20

	onUse(var/turf/T)
		if (!owner.starter_buff && ..())
			return 1

		if (!T)
			T = get_turf(owner)

		if (istype(T, /turf/space) || (istype(T, /turf/unsimulated) && T.can_build))
			var/datum/blob_ability/bridge/B = owner.get_ability(/datum/blob_ability/bridge)

			if (B)
				var/success = !B.onUse(T)		//Abilities return 1 on failure and 0 on success. fml
				if (success)
					boutput(owner, SPAN_NOTICE("You create a bridge on [T]."))
				else
					boutput(owner, SPAN_ALERT("You were unable to place a bridge on [T]."))

				return 1

		var/obj/blob/B1 = T.can_blob_spread_here(owner, null, (isadmin(owner) || owner.admin_override))
		if (!istype(B1))
			return 1

		if (!tutorial_check("spread", T))
			return 1

		var/obj/blob/B2 = new /obj/blob(T)
		B2.setOvermind(owner)

		cooldown_time = 16
		var/mindist = 127
		for_by_tcl(nucleus, /obj/blob/nucleus)
			if(nucleus.overmind == owner)
				mindist = min(mindist, GET_DIST(T, get_turf(nucleus)))

		mindist *= max((length(owner.blobs) * 0.005) - 2, 1)

		cooldown_time = max(cooldown_time + max(mindist * 0.5 - 10, 0) - owner.spread_upgrade * 5 - owner.spread_mitigation * 0.5, 6)
		owner.total_placed++

		var/extra_spreads = round(owner.multi_spread / 100) + (prob(owner.multi_spread % 100) ? 1 : 0)
		if (extra_spreads)
			var/list/spreadability = list()
			for (var/turf/simulated/floor/Q in view(7, owner))
				if (locate(/obj/blob) in Q)
					continue
				var/obj/blob/B3 = Q.can_blob_spread_here(null, null, (isadmin(owner) || owner.admin_override))
				if (B3)
					spreadability += Q


			for (var/i = 1, i <= extra_spreads && spreadability.len, i++)
				var/turf/R = pick(spreadability)
				var/obj/blob/B3 = new /obj/blob(R)
				owner.total_placed++
				B3.setOvermind(owner)
				spreadability -= R

		owner.playsound_local(owner.loc, "sound/voice/blob/blobspread[rand(1, 6)].ogg", 80, 1)
		if (!owner.starter_buff)
			src.deduct_bio_points()
			src.do_cooldown()

/datum/blob_ability/promote
	name = "Promote to Nucleus"
	icon_state = "blob-nucleus"
	desc = "This ability allows you to plant extra nuclei. You are allowed to use this ability once for every 100 tiles of blob reached."
	bio_point_cost = 0
	cooldown_time = 1200
	var/using = 0

	onUse(var/turf/T)
		if (..())
			return 1
		if (using)
			return 1
		using = 1
		if (!owner.extra_nuclei)
			boutput(usr, SPAN_ALERT("You cannot place additional nuclei at this time."))
			using = 0
			return 1

		if (!T)
			T = get_turf(owner)
		var/obj/blob/B = locate() in T
		if (!B)
			boutput(usr, SPAN_ALERT("No blob here to convert!"))
			using = 0
			return 1
		if (B.type != /obj/blob)
			boutput(usr, SPAN_ALERT("Cannot promote special blob tiles!"))
			using = 0
			return 1
		owner.extra_nuclei--
		var/obj/blob/nucleus/N = new(T)
		N.setOvermind(owner)
		N.setMaterial(B.material)
		B.material = null
		qdel(B)
		owner.playsound_local(owner.loc, 'sound/voice/blob/blobdeploy.ogg', 50, 1)
		deduct_bio_points()
		do_cooldown()
		using = 0

/datum/blob_ability/consume
	name = "Consume"
	icon_state = "blob-consume"
	desc = "This ability can be used to remove an existing blob tile for biopoints. Any blob tile you own can be consumed."
	bio_point_cost = 0
	cooldown_time = 50

	onUse(var/turf/T)
		if (..())
			return
		if (!T)
			T = get_turf(owner)
		var/obj/blob/B = locate() in T
		if (!B)
			return
		if (B.disposed)
			return
		if (B.overmind != owner)
			return
		if (istype(B, /obj/blob/nucleus))
			boutput(usr, SPAN_ALERT("You cannot consume a nucleus!"))
			return
		if (!tutorial_check("consume", T))
			return
		owner.playsound_local(owner.loc, "sound/voice/blob/blobconsume[rand(1, 2)].ogg", 80, 1)
		B.visible_message(SPAN_ALERT("<b>The blob consumes a piece of itself!</b>"))
		B.onKilled()
		qdel(B)
		src.deduct_bio_points()
		src.do_cooldown()

/datum/blob_ability/attack
	name = "Attack"
	icon_state = "blob-attack"
	desc = "This ability commands the blob to attack the selected tile instantly. It must be next to a blob."
	bio_point_cost = 1
	cooldown_time = 20

	onUse(var/turf/T)
		if (..())
			return
		if (!T)
			T = get_turf(owner)

		var/obj/blob/B
		var/turf/checked
		var/terminator = 0
		for (var/dir in alldirs)
			if (terminator)
				break
			checked = get_step(T, dir)
			for (var/obj/blob/X in checked.contents)
				if (X.can_attack_from_this)
					B = X
					terminator = 1
					break

		if (!istype(B))
			boutput(owner, SPAN_ALERT("That tile is not adjacent to a blob capable of attacking."))
			return

		if (!tutorial_check("attack", T))
			return

		owner.playsound_local(owner.loc, "sound/voice/blob/blob[pick("deploy", "attack")].ogg", 85, 1)
		B.attack(T)
		for (var/obj/blob/C in orange(B, 7))
			if (prob(25))
				if (C.overmind == B.overmind)
					C.attack_random()

		src.deduct_bio_points()
		src.do_cooldown()

/datum/blob_ability/repair
	name = "Repair"
	icon_state = "blob-repair"
	desc = "This ability repairs a selected blob tile by 20 health."
	bio_point_cost = 1
	cooldown_time = 20

	onUse(var/turf/T)
		if (..())
			return
		if (!T)
			T = get_turf(owner)

		if (!tutorial_check("repair", T))
			return

		var/obj/blob/B = T.get_blob_on_this_turf()

		if (B)
			if (B.health >= B.health_max)
				boutput(owner, SPAN_ALERT("That blob tile is already at full health."))
				return
			if(ON_COOLDOWN(B, "manual_blob_heal", 6 SECONDS))
				boutput(owner, SPAN_ALERT("That blob tile needs time before it can be repaired again."))
				return

			B.heal_damage(20)
			B.UpdateIcon()
			owner.playsound_local(owner.loc, "sound/voice/blob/blobheal[rand(1, 3)].ogg", 50, 1)
			src.deduct_bio_points()
			src.do_cooldown()
		else
			boutput(owner, SPAN_ALERT("There is no blob there to repair."))

/datum/blob_ability/absorb
	name = "Absorb"
	icon_state = "blob-absorb"
	desc = "This will attempt to absorb a living being standing on one of your blob tiles. It takes a moment to work. If successful, it will grant four evo points, or one for monkeys."
	bio_point_cost = 0
	cooldown_time = 2 SECONDS

	onUse(var/turf/T)
		if (..())
			return
		if (!T)
			T = get_turf(owner)

		var/obj/blob/B = T.get_blob_on_this_turf()
		if (!istype(B))
			boutput(owner, SPAN_ALERT("There is no blob there to absorb someone with."))
			return
		if (!B.can_absorb)
			boutput(owner, SPAN_ALERT("[B] cannot absorb beings."))

		if (!tutorial_check("absorb", T))
			return

		//Things that can be absorbed: humans, mobcritters, monkeys

		// var/mob/living/M = locate(/mob/living) in T.contents
		var/mob/living/M = null
		for (var/A in T.contents)
			if (check_target_immunity(A))
				continue
			if (ishuman(A))
				if (A:decomp_stage != DECOMP_STAGE_SKELETONIZED)
					M = A
					break
			if (ismobcritter(A))
				M = A
				break

		if (!M)
			M = locate() in T
			if (ishuman(M))
				boutput(owner, SPAN_ALERT("There's no flesh left on [M.name] to absorb."))
				return
			boutput(owner, SPAN_ALERT("There is no-one there that you can absorb."))
			return

		B.visible_message(SPAN_ALERT("<b>The blob starts trying to absorb [M.name]!</b>"))
		actions.start(new /datum/action/bar/blob_absorb(M, owner), B)
		M.was_harmed(B)


//The owner is the blob tile object...
/datum/action/bar/blob_absorb
	bar_icon_state = "bar-blob"
	border_icon_state = "border-blob"
	color_active = "#d73715"
	color_success = "#167935"
	color_failure = "#8d1422"
	duration = 10 SECONDS

	interrupt_flags = 0
	var/mob/living/target
	var/mob/living/intangible/blob_overmind/blob_o

	//Target (obvious),
	New(Target, var/mob/living/intangible/blob_overmind/blob_o)
		..()
		target = Target
		if (!istype(target))
			interrupt(INTERRUPT_ALWAYS)
			return
		src.blob_o = blob_o

	onStart()
		..()
		if(!target || !owner || GET_DIST(owner, target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		actions.interrupt(target, INTERRUPT_ATTACKED)

	onUpdate()
		..()
		if(!target || !owner || GET_DIST(owner, target) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ishuman(target) && target:decomp_stage == DECOMP_STAGE_SKELETONIZED)
			interrupt(INTERRUPT_ALWAYS)
			return
		//damage thing a bit
		// target.take_toxin_damage(rand(2,4))
		target.TakeDamage(burn=rand(2,4), tox=rand(2,4))

	onEnd()
		..()
		//owner type actually matters here. But it should never not be this anyway...
		if(!target || !owner || GET_DIST(owner, target) > 0)
			return

		//This whole first bit is all still pretty ugly cause this ability works on both critters and humans. I didn't have it in me to rewrite the whole thing - kyle
		if (ismobcritter(target))
			target.gib()
			target.visible_message(SPAN_ALERT("<b>The blob tries to absorb [target.name], but something goes horribly right!</b>"))
			var/datum/antagonist/mob/intangible/blob/antag_role = blob_o?.mind?.get_antagonist(ROLE_BLOB)
			if (antag_role)
				antag_role.absorbed_victims += target
			return

		if (!ishuman(target))
			target.ghostize()
			qdel(target)
			return

		var/mob/living/carbon/human/H = target

		var/datum/antagonist/mob/intangible/blob/antag_role = blob_o?.mind?.get_antagonist(ROLE_BLOB)
		antag_role?.absorbed_victims += H

		if (!isnpcmonkey(H) || prob(50))
			blob_o?.evo_points += 2
			playsound(H.loc, 'sound/voice/blob/blobsucced.ogg', 100, 1)
		//This is all the animation and stuff making the effect look good crap. Not much to see here.

		H.visible_message(SPAN_ALERT("<b>[H.name] is absorbed by the blob!</b>"))
		playsound(H.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)

		H.transforming = 1
		var/current_target_z = H.pixel_z
		var/destination_z = current_target_z - 6
		animate(H, time = 10, alpha = 1, pixel_z = destination_z, easing = LINEAR_EASING)
		SPAWN(0)
			sleep(1 SECOND)
			H.lying = 1
			H.skeletonize()
			H.transforming = 0
			H.death()
			H.update_face()
			H.update_body()
			H.update_clothing()
			sleep(2 SECONDS)
			animate(H, time = 10, alpha = 255, pixel_z = current_target_z, easing = LINEAR_EASING)

/datum/blob_ability/bridge
	name = "Build Bridge"
	icon_state = "blob-bridge"
	desc = "Creates a floor that you can cross through in space. The floor can be destroyed by fire or weldingtools, and does not act as a blob tile."
	bio_point_cost = 5
	cooldown_time = 5 SECONDS

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		if (!istype(T, /turf/space) && !T.can_build)
			boutput(owner, SPAN_ALERT("Bridges must be placed on space tiles."))
			return 1

		var/passed = 0
		for (var/dir in cardinal)
			var/turf/checked = get_step(T, dir)
			for (var/obj/blob/B in checked.contents)
				if (B.type != /obj/blob/mutant)
					passed = 1
					break

		if (!passed)
			boutput(owner, SPAN_ALERT("You require an adjacent blob tile to create a bridge."))
			return 1

		if (!tutorial_check("bridge", T))
			return 1

		var/turf/simulated/floor/blob/B = T.ReplaceWith(/turf/simulated/floor/blob, FALSE, TRUE, FALSE)
		B.setOvermind(owner)
		src.deduct_bio_points()
		src.do_cooldown()

		return

/datum/blob_ability/devour_item
	name = "Devour Item"
	icon_state = "blob-digest"
	desc = "This ability will attempt to devour and digest an object on or cardinally adjacent to a blob tile. This process takes 2 seconds, and it can be interrupted by the removal of the blobs in the item's vicinity or the item itself. If the item or any of its contents contained any reagents, a reagent deposit tile will be created on a nearby standard blob tile."
	bio_point_cost = 3
	cooldown_time = 0

	proc/recursive_reagents(var/obj/O)
		var/list/ret = list()
		if (O.reagents)
			for (var/id in O.reagents.reagent_list)
				ret += O.reagents.reagent_list[id]
		for (var/obj/P in O)
			ret += recursive_reagents(P)
		return ret

	onUse(var/turf/T)
		if (..())
			return 1

		if (!T)
			T = get_turf(owner)
		var/sel_target = T
		if (isturf(T))
			sel_target = null
		else
			T = get_turf(T)
		var/list/items = list()
		for (var/obj/item/I in T)
			items += I
		if (!items.len)
			boutput(owner, SPAN_ALERT("Nothing to devour there."))
			return 1

		var/obj/blob/Bleb = locate() in T
		if (!Bleb)
			for (var/D in cardinal)
				var/turf/B = get_step(T, D)
				Bleb = locate() in B
				if (Bleb)
					break

		if (!Bleb)
			boutput(owner, SPAN_ALERT("There is no blob nearby which can devour items."))
			return 1

		if (!tutorial_check("devour", T))
			return 1

		var/obj/item/I = items[1]
		if (!sel_target)
			if (length(items) > 1)
				I = input("Which item?", "Item", null) as null|anything in items
		else
			I = sel_target

		if (!I)
			return 1

		if (I.loc != T)
			return 1

		if (!Bleb) //Wire: Duplicated from above because there's an input() in-between (Fixes runtime: Cannot execute null.visible message())
			boutput(owner, SPAN_ALERT("There is no blob nearby which can devour items."))
			return 1

		Bleb.visible_message(SPAN_ALERT("<b>The blobs starts devouring [I]!</b>"))
		sleep(2 SECONDS)
		if (!I)
			return 1
		if (!isturf(I.loc))
			return 1
		Bleb = locate() in I.loc
		if (!Bleb)
			for (var/D in cardinal)
				var/turf/B = get_step(I.loc, D)
				Bleb = locate() in B
				if (Bleb)
					break

		if (!Bleb)
			return 1


		Bleb.visible_message(SPAN_ALERT("<b>The blob devours [I]!</b>"))

		src.deduct_bio_points()

		qdel(I)
