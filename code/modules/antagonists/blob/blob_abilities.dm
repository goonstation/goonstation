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
	var/obj/screen/blob/button
	var/special_screen_loc = null
	var/helpable = 1

	New()
		..()
		var/obj/screen/blob/B = new /obj/screen/blob(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.ability = src
		B.name = src.name
		B.desc = src.desc
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
					boutput(owner, "<span class='alert'>You do not have enough bio points to use that ability.</span>")
					return 1
			if (cooldown_time > 0 && last_used > world.time)
				boutput(owner, "<span class='alert'>That ability is on cooldown for [round((last_used - world.time) / 10)] seconds.</span>")
				return 1
			var/area/A = get_area(T)
			if(A?.sanctuary)
				boutput(owner, "<span class='alert'>You cannot use that ability here.</span>")
				return 1
			return 0

		deduct_bio_points()
			if (bio_point_cost > 0)
				owner.usePoints(bio_point_cost)

		do_cooldown()
			//boutput(world, "cooldown initiated, length of [cooldown_time]")
			last_used = world.time + cooldown_time
			owner.update_buttons()
			SPAWN_DBG(cooldown_time + 1)
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

				if (T.can_blob_spread_here(null, null, isadmin(owner)))
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


/datum/blob_ability/upgrade
	name = "Toggle Upgrade Bar"
	desc = "Expand or contract the upgrades bar."
	icon_state = "blob-viewupgrades"
	targeted = 0
	special_screen_loc = "SOUTH,WEST"
	helpable = 0

	onUse(var/turf/T)
		if (..())
			return
		if (owner.viewing_upgrades)
			owner.viewing_upgrades = 0
		else
			owner.viewing_upgrades = 1
		owner.update_buttons()

/datum/blob_ability/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "blob-help0"
	targeted = 0
	special_screen_loc = "SOUTH,EAST"
	helpable = 0

	onUse(var/turf/T)
		if (..())
			return
		if (owner.help_mode)
			owner.help_mode = 0
		else
			owner.help_mode = 1
			boutput(owner, "<span class='notice'>Help Mode has been activated  To disable it, click on this button again.</span>")
		src.button.icon_state = "blob-help[owner.help_mode]"
		owner.update_buttons()

// STARTER ABILITIES

/datum/blob_ability/plant_nucleus
	name = "Deploy"
	icon_state = "blob-nucleus"
	desc = "This will place the first blob on your current tile. You can only do this once. Once placed, a small amount of blob tiles will spawn around it."
	targeted = 0

	onUse(var/turf/T)
		if (..())
			return
		if (!T)
			T = get_turf(owner)

		if (istype(T,/turf/space/))
			boutput(owner, "<span class='alert'>You can't start in space!</span>")
			return

		if (!isadmin(owner)) //admins can spawn wherever
			if (!istype(T.loc, /area/station/) && !istype(T.loc, /area/blob/))
				boutput(owner, __red("You need to start on the [station_or_ship()]!"))
				return

			if (istype(T,/turf/unsimulated/))
				boutput(owner, "<span class='alert'>This kind of tile cannot support a blob.</span>")
				return

			if (T.density)
				boutput(owner, "<span class='alert'>You can't start inside a wall!</span>")
				return

			for (var/atom/O in T.contents)
				if (O.density)
					boutput(owner, "<span class='alert'>That tile is blocked by [O].</span>")
					return

			for (var/mob/M in viewers(T, 7))
				if (isrobot(M) || ishuman(M))
					if (!isdead(M))
						boutput(owner, "<span class='alert'>You are being watched.</span>")
						return

		if (!tutorial_check("deploy", T))
			return

		var/turf/startTurf = get_turf(owner)
		var/obj/blob/nucleus/C = new /obj/blob/nucleus(startTurf)
		C.layer++
		C.setOvermind(owner)
		C.Life()
		owner.started = 1
		owner.add_ability(/datum/blob_ability/spread)
		owner.add_ability(/datum/blob_ability/attack)
		owner.add_ability(/datum/blob_ability/consume)
		owner.add_ability(/datum/blob_ability/repair)
		owner.add_ability(/datum/blob_ability/absorb)
		owner.add_ability(/datum/blob_ability/promote)
		owner.add_ability(/datum/blob_ability/build/ribosome)
		owner.add_ability(/datum/blob_ability/build/lipid)
		owner.add_ability(/datum/blob_ability/build/mitochondria)
		owner.add_ability(/datum/blob_ability/build/wall)
		owner.add_ability(/datum/blob_ability/build/firewall)
		owner.add_ability(/datum/blob_ability/upgrade)
		for (var/X in childrentypesof(/datum/blob_upgrade))
			owner.add_upgrade(X, 1)

		if (!owner.tutorial)
			//do a little "blobsplosion"
			var/amount = rand(20, 30)
			src.auto_spread(startTurf, maxRange = 3, maxTurfs = amount)
		owner.playsound_local(owner.loc, "sound/voice/blob/blobdeploy.ogg", 50, 1)
		owner.remove_ability(/datum/blob_ability/plant_nucleus)
		owner.remove_ability(/datum/blob_ability/set_color)
		owner.remove_ability(/datum/blob_ability/tutorial)

/datum/blob_ability/set_color
	name = "Set Color"
	desc = "Choose what color you want your blob to be. This will be removed when you start the blob."
	icon_state = "blob-color"
	targeted = 0

	onUse()
		if (..())
			return
		owner.color = input("Select your Color","Blob") as color
		var/r = hex2num(copytext(owner.color, 2, 4))
		var/g = hex2num(copytext(owner.color, 4, 6))
		var/b = hex2num(copytext(owner.color, 6))
		var/hsv = rgb2hsv(r,g,b)
		owner.organ_color = hsv2rgb( hsv[1], hsv[2], 1 )

		owner.my_material.color = owner.color

/datum/blob_ability/tutorial
	name = "Interactive Tutorial"
	desc = "Check out the interactive blob tutorial to get started with blobs."
	icon_state = "blob-help0"
	targeted = 0

	onUse()
		if (..())
			return
		if (owner.tutorial)
			boutput(owner, "<span class='alert'>You're already in the tutorial!</span>")
			return
		owner.start_tutorial()

/datum/blob_ability/tutorial_exit
	name = "Exit Tutorial"
	desc = "Exit the blob tutorial and re-enter the game."
	icon_state = "blob-exit"
	targeted = 0
	special_screen_loc = "SOUTH,EAST-1"

	onUse()
		if (..())
			return
		if (!owner.tutorial)
			boutput(owner, "<span class='alert'>You're not in the tutorial!</span>")
			return
		owner.tutorial.Finish()
		owner.tutorial = null

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

		if (istype(T, /turf/space))
			var/datum/blob_ability/bridge/B = owner.get_ability(/datum/blob_ability/bridge)

			if (B)
				var/success = !B.onUse(T)		//Abilities return 1 on failure and 0 on success. fml
				if (success)
					boutput(owner, "<span class='notice'>You create a bridge on [T].</span>")
				else
					boutput(owner, "<span class='alert'>You were unable to place a bridge on [T].</span>")

				return 1

		var/obj/blob/B1 = T.can_blob_spread_here(owner, null, isadmin(owner))
		if (!istype(B1))
			return 1

		if (!tutorial_check("spread", T))
			return 1

		var/obj/blob/B2 = new /obj/blob(T)
		B2.setOvermind(owner)

		if (owner.blobs.len < 100)
			cooldown_time = max(15 - owner.spread_upgrade * 10 - owner.spread_mitigation * 0.5, 0)
		else if (owner.blobs.len < 200)
			cooldown_time = max(20 - owner.spread_upgrade * 10 - owner.spread_mitigation * 0.5, 0)
		else
			cooldown_time = max(25 - owner.spread_upgrade * 10 - owner.spread_mitigation * 0.5, 0)

		cooldown_time = max(cooldown_time, 6)

		var/extra_spreads = round(owner.multi_spread / 100) + (prob(owner.multi_spread % 100) ? 1 : 0)
		if (extra_spreads)
			var/list/spreadability = list()
			for (var/turf/simulated/floor/Q in view(7, owner))
				if (locate(/obj/blob) in Q)
					continue
				var/obj/blob/B3 = Q.can_blob_spread_here(null, null, isadmin(owner))
				if (B3)
					spreadability += Q


			for (var/i = 1, i <= extra_spreads && spreadability.len, i++)
				var/turf/R = pick(spreadability)
				var/obj/blob/B3 = new /obj/blob(R)
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
			boutput(usr, "<span class='alert'>You cannot place additional nuclei at this time.</span>")
			using = 0
			return 1

		if (!T)
			T = get_turf(owner)
		var/obj/blob/B = locate() in T
		if (!B)
			boutput(usr, "<span class='alert'>No blob here to convert!</span>")
			using = 0
			return 1
		if (B.type != /obj/blob)
			boutput(usr, "<span class='alert'>Cannot promote special blob tiles!</span>")
			using = 0
			return 1
		owner.extra_nuclei--
		var/obj/blob/nucleus/N = new(T)
		N.setOvermind(owner)
		N.setMaterial(B.material)
		B.material = null
		qdel(B)
		owner.playsound_local(owner.loc, "sound/voice/blob/blobdeploy.ogg", 50, 1)
		deduct_bio_points()
		do_cooldown()
		using = 0

/datum/blob_ability/consume
	name = "Consume"
	icon_state = "blob-consume"
	desc = "This ability can be used to remove an existing blob tile for biopoints. Any blob tile you own can be consumed."
	bio_point_cost = 10
	cooldown_time = 20

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
			boutput(usr, "<span class='alert'>You cannot consume a nucleus!</span>")
			return
		if (!tutorial_check("consume", T))
			return
		owner.playsound_local(owner.loc, "sound/voice/blob/blobconsume[rand(1, 2)].ogg", 80, 1)
		B.visible_message("<span class='alert'><b>The blob consumes a piece of itself!</b></span>")
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
			boutput(owner, "<span class='alert'>That tile is not adjacent to a blob capable of attacking.</span>")
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
			B.heal_damage(20)
			B.update_icon()
			owner.playsound_local(owner.loc, "sound/voice/blob/blobheal[rand(1, 3)].ogg", 50, 1)
			src.deduct_bio_points()
			src.do_cooldown()
		else
			boutput(owner, "<span class='alert'>There is no blob there to repair.</span>")

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
			boutput(owner, "<span class='alert'>There is no blob there to absorb someone with.</span>")
			return
		if (!B.can_absorb)
			boutput(owner, "<span class='alert'>[B] cannot absorb beings.</span>")

		if (!tutorial_check("absorb", T))
			return

		//Things that can be absorbed: humans, mobcritters, monkeys

		// var/mob/living/M = locate(/mob/living) in T.contents
		var/mob/living/M = null
		for (var/A in T.contents)
			if (check_target_immunity(A))
				continue
			if (ishuman(A))
				if (A:decomp_stage != 4)
					M = A
					break
			if (ismobcritter(A))
				M = A
				break

		if (!M)
			M = locate() in T
			if (ishuman(M))
				boutput(owner, "<span class='alert'>There's no flesh left on [M.name] to absorb.</span>")
				return
			boutput(owner, "<span class='alert'>There is no-one there that you can absorb.</span>")
			return

		B.visible_message("<span class='alert'><b>The blob starts trying to absorb [M.name]!</b></span>")
		actions.start(new /datum/action/bar/blob_absorb(M, owner), B)


//The owner is the blob tile object...
/datum/action/bar/blob_absorb //This is used when you try to set someones internals
	duration = 10 SECONDS

	// interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	interrupt_flags = 0
	id = "internalsother"
	// icon = 'icons/obj/clothing/item_masks.dmi'
	// icon_state = "breath"
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

	onInterrupt(var/flag)
		..()
	onUpdate()
		..()
		if(!target || !owner || get_dist(owner, target) > 0 || !blob_o)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ishuman(target) && target:decomp_stage == 4)
			interrupt(INTERRUPT_ALWAYS)
			return
		//damage thing a bit
		// target.take_toxin_damage(rand(2,4))
		target.TakeDamage(burn=rand(2,4), tox=rand(2,4))

	onEnd()
		..()
		//owner type actually matters here. But it should never not be this anyway...
		if(!target || !owner || get_dist(owner, target) > 0 || !istype (blob_o, /mob/living/intangible/blob_overmind))
			return

		//This whole first bit is all still pretty ugly cause this ability works on both critters and humans. I didn't have it in me to rewrite the whole thing - kyle
		if (ismobcritter(target))
			target.gib()
			target.visible_message("<span class='alert'><b>The blob tries to absorb [target.name], but something goes horribly right!</b></span>")
			if (blob_o?.mind) //ahem ahem AI blobs exist
				blob_o.mind.blob_absorb_victims += target
			return

		if (!ishuman(target))
			target.ghostize()
			qdel(target)
			return

		var/mob/living/carbon/human/H = target
		if (H?.decomp_stage == 4)
			H.decomp_stage = 4

		if (blob_o?.mind) //ahem ahem AI blobs exist
			blob_o.mind.blob_absorb_victims += H

		if (isnpcmonkey(H))
			blob_o.evo_points += 1
		else
			blob_o.evo_points += 4
			playsound(H.loc, "sound/voice/blob/blobsucced.ogg", 100, 1)
		//This is all the animation and stuff making the effect look good crap. Not much to see here.

		H.visible_message("<span class='alert'><b>[H.name] is absorbed by the blob!</b></span>")
		playsound(H.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)

		H.transforming = 1
		var/current_target_z = H.pixel_z
		var/destination_z = current_target_z - 6
		animate(H, time = 10, alpha = 1, pixel_z = destination_z, easing = LINEAR_EASING)
		SPAWN_DBG(0)
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


/datum/blob_ability/reinforce
	name = "Reinforce Blob"
	icon_state = "blob-reinforce"
	desc = "Reinforce the selected blob bit with a material deposit on the same tile. Blob bits with reinforcements may be more durable or more heat resistant, or otherwise may bear special properties depending on the properties of the material. A single blob bit can be repeatedly reinforced to push its properties closer to that of the reinforcing material."
	bio_point_cost = 2
	cooldown_time = 20

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		var/obj/blob/B = locate() in T
		if (!B)
			boutput(owner, "<span class='alert'>No blob there to reinforce.</span>")
			return 1

		var/list/deposits = list()

		for (var/obj/material_deposit/M in T)
			deposits += M

		if (!deposits.len)
			boutput(owner, "<span class='alert'>No material deposits for reinforcement there.</span>")
			return 1

		var/obj/material_deposit/reinforcing = deposits[1]

		if (deposits.len > 1)
			reinforcing = input("Which material deposit?", "Reinforce blob", null) in deposits

		if (reinforcing.disposed)
			return 1

		B.visible_message("<span class='alert'><b>[B] reinforces using [reinforcing]!</b></span>")


		B.setMaterial(getInterpolatedMaterial(B.material, reinforcing.material, 0.17))
		qdel(reinforcing)

		owner.playsound_local(owner.loc, "sound/voice/blob/blobreinforce[rand(1, 2)].ogg", 50, 1)
		src.deduct_bio_points()
		src.do_cooldown()


/datum/blob_ability/reclaimer
	name = "Build Reclaimer"
	icon_state = "blob-reclaimer"
	desc = "This will convert an untapped reagent deposit in the blob into a reclaimer. Reclaimers consume the reagents in the deposit and provide biopoints in exchange. When the deposit depletes, the reclaimer becomes a lipid."
	bio_point_cost = 4
	cooldown_time = 50

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		var/obj/blob/deposit/B = locate() in T
		if (!B)
			boutput(owner, "<span class='alert'>Reclaimers must be placed on untapped reagent deposits.</span>")
			return 1
		if (B.type != /obj/blob/deposit)
			boutput(owner, "<span class='alert'>Reclaimers must be placed on untapped reagent deposits.</span>")
			return 1

		if (!tutorial_check("reclaimer", T))
			return 1

		B.build_reclaimer()
		src.deduct_bio_points()
		src.do_cooldown()

		return

/datum/blob_ability/replicator
	name = "Build Replicator"
	icon_state = "blob-replicator"
	desc = "This will convert an untapped reagent deposit in the blob into a replicator. Replicators use other reagent deposits to create more of the highest volume reagent in the deposit."
	bio_point_cost = 4
	cooldown_time = 50

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		var/obj/blob/deposit/B = locate() in T
		if (!B)
			boutput(owner, "<span class='alert'>Replicators must be placed on untapped reagent deposits.</span>")
			return 1
		if (B.type != /obj/blob/deposit)
			boutput(owner, "<span class='alert'>Replicators must be placed on untapped reagent deposits.</span>")
			return 1

		if (!tutorial_check("replicator", T))
			return 1

		B.build_replicator()
		src.deduct_bio_points()
		src.do_cooldown()

		return

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

		if (!istype(T, /turf/space))
			boutput(owner, "<span class='alert'>Bridges must be placed on space tiles.</span>")
			return 1

		var/passed = 0
		for (var/dir in cardinal)
			var/turf/checked = get_step(T, dir)
			for (var/obj/blob/B in checked.contents)
				if (B.type != /obj/blob/mutant)
					passed = 1
					break

		if (!passed)
			boutput(owner, "<span class='alert'>You require an adjacent blob tile to create a bridge.</span>")
			return 1

		if (!tutorial_check("bridge", T))
			return 1

		var/turf/simulated/floor/blob/B = new /turf/simulated/floor/blob(T)
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
			boutput(owner, "<span class='alert'>Nothing to devour there.</span>")
			return 1

		var/obj/blob/Bleb = locate() in T
		if (!Bleb)
			for (var/D in cardinal)
				var/turf/B = get_step(T, D)
				Bleb = locate() in B
				if (Bleb)
					break

		if (!Bleb)
			boutput(owner, "<span class='alert'>There is no blob nearby which can devour items.</span>")
			return 1

		if (!tutorial_check("devour", T))
			return 1

		var/obj/item/I = items[1]
		if (!sel_target)
			if (items.len > 1)
				I = input("Which item?", "Item", null) as null|anything in items
		else
			I = sel_target

		if (!I)
			return 1

		if (I.loc != T)
			return 1

		if (!Bleb) //Wire: Duplicated from above because there's an input() in-between (Fixes runtime: Cannot execute null.visible message())
			boutput(owner, "<span class='alert'>There is no blob nearby which can devour items.</span>")
			return 1

		Bleb.visible_message("<span class='alert'><b>The blobs starts devouring [I]!</b></span>")
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

		var/do_pool = 0

		Bleb.visible_message("<span class='alert'><b>The blob devours [I]!</b></span>")

		if (I.material)
			var/count = 2
			if (istype(I, /obj/item/raw_material) || istype(I, /obj/item/material_piece))
				count = 3
				do_pool = 1
			if (I.amount >= 10)
				count *= round(I.amount / 10) + 1
			for (var/i = 1, i <= count, i++)
				new /obj/material_deposit(Bleb.loc, I.material, owner)

		var/list/aggregated = recursive_reagents(I)
		if (aggregated.len)
			if (Bleb.type != /obj/blob)
				Bleb = null
				for (var/obj/blob/C in range(5, Bleb))
					if (C.type == /obj/blob && C.overmind == owner)
						Bleb = C
						break
			if (Bleb)
				var/obj/blob/deposit/B2 = new /obj/blob/deposit(Bleb.loc)
				B2.setOvermind(owner)
				qdel(Bleb)
				B2.reagents = new /datum/reagents(0)
				B2.reagents.my_atom = B2
				for (var/datum/reagent/R in aggregated)
					if (!B2)
						src.deduct_bio_points()
						return
					B2.reagents.maximum_volume += R.volume
					B2.reagents.add_reagent(R.id, R.volume)
				if (B2)
					B2.update_reagent_overlay()
					if (!B2.reagents.total_volume)
						var/obj/blob/B3 = new /obj/blob(B2.loc)
						B3.setOvermind(owner)
						qdel(B2)
		src.deduct_bio_points()

		if (do_pool)
			pool(I)
		else
			qdel(I)

// CONSTRUCTION ABILITIES

/datum/blob_ability/build
	var/gen_rate_invest = 0
	var/build_path = /obj/blob
	cooldown_time = 100
	var/buildname = "build"

	onUse(var/turf/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(owner)

		var/obj/blob/B = T.get_blob_on_this_turf()

		if (!B)
			boutput(owner, "<span class='alert'>There is no blob there to convert.</span>")
			return 1

		if (gen_rate_invest > 0)
			if (owner.get_gen_rate() < gen_rate_invest + 1)
				boutput(owner, "<span class='alert'>You do not have a high enough generation rate to use that ability.</span>")
				boutput(owner, "<span class='alert'>Keep in mind that you cannot reduce your generation rate to zero or below.</span>")
				return 1

		if (B.type != /obj/blob)
			boutput(owner, "<span class='alert'>You cannot convert special blob cells.</span>")
			return 1

		if (!tutorial_check(buildname, T))
			return 1

		var/obj/blob/L = new build_path(T)
		L.setOvermind(owner)
		L.setMaterial(B.material)
		B.material = null
		qdel(B)
		if (gen_rate_invest)
			owner.gen_rate_used++
		src.deduct_bio_points()
		src.do_cooldown()
		owner.playsound_local(owner.loc, "sound/voice/blob/blobplace[rand(1, 6)].ogg", 75, 1)

/datum/blob_ability/build/lipid
	name = "Build Lipid Cell"
	icon_state = "blob-lipid"
	desc = "This will convert a blob tile into a Lipid. Lipids act as a storage for 4 biopoints. When you try to spend more than your available biopoints, you will use up lipids to substitute for the missing points. If a lipid is destroyed, the stored points are lost."
	bio_point_cost = 5
	build_path = /obj/blob/lipid
	buildname = "lipid"

/datum/blob_ability/build/ribosome
	name = "Build Ribosome Cell"
	icon_state = "blob-ribosome"
	desc = "This will convert a blob tile into a Ribosome. Ribosomes increase your generation of biopoints, allowing you to do more things."
	bio_point_cost = 15
	build_path = /obj/blob/ribosome
	buildname = "ribosome"

/datum/blob_ability/build/mitochondria
	name = "Build Mitochondria Cell"
	icon_state = "blob-mitochondria"
	desc = "This will convert a blob tile into a Mitochondrion. Mitochondria heal nearby blob cells."
	bio_point_cost = 5
	build_path = /obj/blob/mitochondria
	buildname = "mitochondria"

/datum/blob_ability/build/plasmaphyll
	name = "Build Plasmaphyll Cell"
	icon_state = "blob-plasmaphyll"
	desc = "This will convert a blob tile into a Plasmaphyll. Plasmaphylls protect nearby blob pieces from sustained fires by absorbing plasma out of the air and converting it into biopoints."
	bio_point_cost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/plasmaphyll
	buildname = "plasmaphyll"

/datum/blob_ability/build/ectothermid
	name = "Build Ectothermid Cell"
	icon_state = "blob-ectothermid"
	desc = "This will convert a blob tile into a Ectothermid. Ectothermids provice heat protection in an area at the cost of for biopoints."
	bio_point_cost = 15
	gen_rate_invest = 1
	build_path = /obj/blob/ectothermid
	buildname = "ectothermid"

/datum/blob_ability/build/reflective
	name = "Build Reflective Membrane Cell"
	icon_state = "blob-reflective"
	desc = "This will convert a blob tile into a reflective membrane. Reflective membranes are reflect energy projectiles back in the direction they were shot from."
	bio_point_cost = 8
	build_path = /obj/blob/reflective
	buildname = "reflective"

/datum/blob_ability/build/launcher
	name = "Build Slime Launcher"
	icon_state = "blob-cannon"
	desc = "This will convert a blob tile into a slime launcher. Slime launchers will fire weak projectiles at nearby humans and cyborgs at the cost of 2 biopoints. Click-drag any reagent deposit onto a slime launcher to load the reagents into the launcher. When loaded with reagents, the slime bullets are also infused with the reagents and while the reservoir lasts, firing the launcher does not cost biopoints."
	bio_point_cost = 10
	build_path = /obj/blob/launcher
	buildname = "launcher"

/datum/blob_ability/build/wall
	name = "Build Thick Membrane Cell"
	icon_state = "blob-wall"
	desc = "This will convert a blob tile into a wall. Wall cells are harder to destroy."
	bio_point_cost = 5
	build_path = /obj/blob/wall
	buildname = "wall"

/datum/blob_ability/build/firewall
	name = "Build Fire-resistant Membrane Cell"
	icon_state = "blob-firewall"
	desc = "This will convert a blob tile into a fire-resistant wall. Fire resistant walls are very resistant to fire damage."
	bio_point_cost = 5
	build_path = /obj/blob/firewall
	buildname = "firewall"

//////////////
// UPGRADES //
//////////////

/datum/blob_upgrade
	var/name = null
	var/desc = null
	var/icon = 'icons/mob/blob_ui.dmi'
	var/icon_state = "blob-template"
	var/evo_point_cost = 0
	var/last_used = 0
	var/repeatable = 0
	var/initially_disabled = 0
	var/scaling_cost_mult = 1
	var/scaling_cost_add = 0
	var/mob/living/intangible/blob_overmind/owner
	var/obj/screen/blob/button
	var/upgradename = "upgrade"

	New()
		..()
		var/obj/screen/blob/B = new /obj/screen/blob(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.upgrade = src
		B.name = src.name
		B.desc = src.desc
		src.button = B

	disposing()
		if(button)
			button.dispose()
			button = null
		owner = null
		..()

	proc/check_requirements()
		if (!istype(owner))
			return 0
		if (owner.evo_points < evo_point_cost)
			//boutput(owner, "<span class='alert'>You need [bio_point_cost] bio-points to take this upgrade.</span>")
			return 0
		return 1

	// Wholesale stolen from ability_parent
	proc/update_cooldown_cost()
		if (!button)
			return
		var/newcolor = null

		if (evo_point_cost)
			if (owner.evo_points < evo_point_cost)
				newcolor = rgb(64, 64, 64)
				button.point_overlay.maptext = "<span class='sh vb r ps2p' style='color: #cc2222;'>[evo_point_cost]</span>"
			else
				button.point_overlay.maptext = "<span class='sh vb r ps2p'>[evo_point_cost]</span>"
		else
			button.point_overlay.maptext = null

		if (newcolor != button.color)
			button.color = newcolor


	proc/deduct_evo_points()
		if (evo_point_cost == 0)
			return
		owner.evo_points = max(0,round(owner.evo_points - evo_point_cost))
		src.evo_point_cost = round(src.evo_point_cost * src.scaling_cost_mult)
		src.evo_point_cost += scaling_cost_add


	proc/take_upgrade()
		if (!istype(owner))
			return 1
		if (!tutorial_check())
			return 1
		if (!(src in owner.upgrades))
			owner.upgrades += src
		if (repeatable > 0)
			repeatable--
		if (repeatable == 0)
			owner.available_upgrades -= src
		if (prob(80))
			owner.playsound_local(owner.loc, "sound/voice/blob/blobup1.ogg", 50, 1)
		else if (prob(50))
			owner.playsound_local(owner.loc, "sound/voice/blob/blobup2.ogg", 50, 1)
		else
			owner.playsound_local(owner.loc, "sound/voice/blob/blobup3.ogg", 50, 1)

		owner.update_buttons()

	proc/tutorial_check()
		if (owner)
			if (owner.tutorial)
				if (!owner.tutorial.PerformAction("upgrade-[upgradename]", null))
					return 0
		return 1

/datum/blob_upgrade/extra_genrate
	name = "Passive: Increase Generation Rate"
	icon_state = "blob-genrate"
	desc = "Increases your BP generation rate by 2. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "genrate"

	take_upgrade()
		if (..())
			return 1
		owner.gen_rate_bonus += 2
		owner.update_buttons()

/datum/blob_upgrade/quick_spread
	name = "Passive: Quicker Spread"
	icon_state = "blob-quickspread"
	desc = "Reduces the cooldown of your Spread ability by 1 second. Can be repeated. The cooldown of Spread cannot go below 1 second."
	evo_point_cost = 2
	scaling_cost_add = 3
	repeatable = -1
	upgradename = "spread"

	take_upgrade()
		if (..())
			return 1
		owner.spread_upgrade++

/datum/blob_upgrade/spread
	name = "Passive: Spread Upgrade"
	icon_state = "blob-spread"
	desc = "When spreading, adds a cumulative 20% chance to spread off another, random tile on your screen. Every time your chance hits a multiple of 100%, the spread for that amount of tiles is guaranteed and a new chance is added for an extra tile. For example, at 120%, you have a 100% chance to spread twice; with a 20% chance to spread three times instead."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "multispread"

	take_upgrade()
		if (..())
			return 1
		owner.multi_spread += 20

/datum/blob_upgrade/attack
	name = "Passive: Attack Upgrade"
	icon_state = "blob-attack"
	desc = "Increases your attack damage and the chance of mob knockdown. Level 3+ of this upgrade will allow you to punch down girders. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "attack"

	take_upgrade()
		if (..())
			return 1
		owner.attack_power += 0.34

/datum/blob_upgrade/fire_resist
	name = "Passive: Fire Resistance"
	icon_state = "blob-fireresist"
	desc = "Makes your blob become more resistant to fire and heat based attacks."
	evo_point_cost = 3
	upgradename = "fireres"

/datum/blob_upgrade/poison_resist
	name = "Passive: Poison Resistance"
	icon_state = "blob-poisonresist"
	desc = "Makes your blob become more resistant to chemical attacks."
	evo_point_cost = 3
	upgradename = "poisonres"

/datum/blob_upgrade/devour_item
	name = "Ability: Devour Item"
	icon_state = "blob-digest"
	desc = "Unlocks the Devour Item ability, which can be used to near-instantly break down any item adjacent to any blob tile. In addition, a reagent deposit is created in the blob if the item contained any reagents. Reagent deposits can be used with various blob elements. Material bearing objects will break down into material deposits, which can be used to reinforce your blob."
	evo_point_cost = 1
	upgradename = "digest"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/devour_item)
		owner.add_upgrade(/datum/blob_upgrade/reclaimer)
		owner.add_upgrade(/datum/blob_upgrade/replicator)
		owner.add_upgrade(/datum/blob_upgrade/reinforce)

/datum/blob_upgrade/reinforce
	name = "Ability: Reinforce"
	icon_state = "blob-reinforce"
	desc = "Unlocks the Reinforce ability, which can be used to strengthen a single blob bit. Blob bits with reinforcements may be more durable or more heat resistant, or otherwise may bear special properties depending on the properties of the material. A single blob bit can be repeatedly reinforced to push its properties closer to that of the reinforcing material."
	evo_point_cost = 1
	initially_disabled = 1
	upgradename = "reinforce"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/reinforce)
		owner.add_upgrade(/datum/blob_upgrade/reinforce_spread)

/datum/blob_upgrade/reinforce_spread
	name = "Passive: Reinforced Spread"
	icon_state = "blob-global-reinforce"
	desc = "Reinforces the blob with material permanently. All existing blob tiles are reinforced with the average of the used materials, and all future blob bits will be created with the infusion. This upgrade requires 60 material deposits to be on your current tile."
	evo_point_cost = 2
	initially_disabled = 1
	scaling_cost_add = 2
	repeatable = -1
	upgradename = "reinforce_spread"
	var/required_deposits = 60
	var/taking = 0

	take_upgrade()
		if (!istype(owner))
			return 1
		if (!tutorial_check())
			return 1
		var/count = 0
		for (var/obj/material_deposit/M in view(owner))
			if (M.overmind == owner && M.material)
				count++
		if (count < required_deposits)
			boutput(usr, "<span class='alert'><b>You need more deposits on your screen! (Required: [required_deposits], have: [count])</b></span>")
			return 1
		if (taking)
			boutput(usr, "<span class='alert'>Cannot take this upgrade currently! Please wait.</span>")
			return 1
		taking = 1
		var/list/mats = list()
		var/list/weights = list()
		var/list/deposits = list()
		var/total = 0
		var/max_id = null
		for (var/obj/material_deposit/M in view(owner))
			if (total >= required_deposits)
				break
			var/datum/material/Mat = M.material
			if (!Mat)
				continue
			deposits += M
			var/id = Mat.mat_id
			if (!(id in mats))
				mats[id] = Mat
				weights[id] = 1
			else
				weights[id] = weights[id] + 1
			total = 0
			for (var/mid in weights)
				if (weights[mid] > total)
					total = weights[mid]
					max_id = mid
		if (!total)
			return 1
		if (total < required_deposits)
			boutput(usr, "<span class='alert'><b>You need more deposits on your screen! (Required: [required_deposits], have (of highest material '[max_id]'): [count])</b></span>")
			return 1
		if (!mats.len)
			return 1
		var/datum/material/to_merge = copyMaterial(mats[max_id])
		owner.my_material = getInterpolatedMaterial(owner.my_material, to_merge, 0.17)
		for (var/obj/O in deposits)
			qdel(O)
		boutput(usr, "<span class='notice'>Applying upgrade to the blob...</span>")
		SPAWN_DBG(0)
			var/wg = 0
			for (var/obj/blob/O in owner.blobs)
				if (!O.material)
					O.setMaterial(copyMaterial(owner.my_material))
				else
					O.setMaterial(getInterpolatedMaterial(O.material, to_merge, 0.17))
				wg++
				if (wg >= 20)
					sleep(0.1 SECONDS)
					wg = 0
			boutput(usr, "<span class='notice'>Finished applying material upgrade!</span>")
			taking = 0
		if (!(src in owner.upgrades))
			owner.upgrades += src
		return 0

/datum/blob_upgrade/reclaimer
	name = "Structure: Reclaimer"
	icon_state = "blob-reclaimer"
	desc = "Unlocks the Reclaimer blob bit, which can be placed on reagent deposits. The reclaimer produces biopoints over time using reagents. Once the deposit depletes, the blob piece is transformed into a lipid."
	evo_point_cost = 2
	initially_disabled = 1
	upgradename = "reclaimer"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/reclaimer)

/datum/blob_upgrade/replicator
	name = "Structure: Replicator"
	icon_state = "blob-replicator"
	desc = "Unlocks the Replicator blob bit, which can be placed on reagent deposits. The replicator replicates the highest volume reagent in the deposit using reagents from other deposits, at the cost of biopoints."
	evo_point_cost = 3
	initially_disabled = 1
	upgradename = "replicator"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/replicator)

/datum/blob_upgrade/bridge
	name = "Structure: Bridge"
	icon_state = "blob-bridge"
	desc = "Unlocks the Bridge blob bit, which can be placed on space tiles. Bridges are floor tiles, you still need to spread onto them, and cannot spread from them."
	evo_point_cost = 2
	initially_disabled = 0
	upgradename = "bridge"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/bridge)

/datum/blob_upgrade/launcher
	name = "Structure: Slime Launcher"
	icon_state = "blob-cannon"
	desc = "Unlocks the Slime Launcher blob bit, which fires at nearby mobs at the cost of biopoints. Slime inflicts a short stun and minimal damage."
	upgradename = "launcher"

	evo_point_cost = 2

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/launcher)

/datum/blob_upgrade/plasmaphyll
	name = "Structural: Plasmaphyll"
	icon_state = "blob-plasmaphyll"
	desc = "Unlocks the plasmaphyll blob bit, which passively protects an area from plasma by converting it to biopoints."
	evo_point_cost = 2
	upgradename = "plasmaphyll"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/plasmaphyll)

/datum/blob_upgrade/ectothermid
	name = "Structural: Ectothermid"
	icon_state = "blob-ectothermid"
	desc = "Unlocks the ectothermid blob bit, which passively an protects area from temperature. This protection consumes biopoints."
	evo_point_cost = 3
	upgradename = "ectothermid"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/ectothermid)

/datum/blob_upgrade/reflective
	name = "Structural: Reflective Membrane"
	icon_state = "blob-reflective"
	desc = "Unlocks the reflective membrane, which is immune to energy projectiles."
	evo_point_cost = 1
	upgradename = "reflective"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/reflective)
		
