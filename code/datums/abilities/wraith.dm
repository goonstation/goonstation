/datum/abilityHolder/wraith
	topBarRendered = 1
	pointName = "Wraith Points"
	cast_while_dead = 1
	var/corpsecount = 0
	onAbilityStat()
		..()
		.= list()
		.["Points:"] = round(src.points)
		.["Gen. rate:"] = round(src.regenRate + src.lastBonus)

/atom/movable/screen/ability/topBar/wraith
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			if (!istype(owner, /datum/targetable/wraithAbility/spook))
				var/theme = src.owner.theme

				usr.client.tooltipHolder.showHover(src, list(
					"params" = params,
					"title" = src.name,
					"content" = (src.desc ? src.desc : null),
					"theme" = theme
				))

/datum/targetable/wraithAbility
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/wraith
	theme = "wraith"
	var/min_req_dist = INFINITY		//What minimum distance from your power well (marker/wraith master) the poltergeist needs to case this spell.

	New()
		var/atom/movable/screen/ability/topBar/wraith/B = new /atom/movable/screen/ability/topBar/wraith(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	cast(atom/target)
		if (!holder || !holder.owner)
			return 1
		if (ispoltergeist(holder.owner))
			var/mob/wraith/poltergeist/P = holder.owner
			if (src.min_req_dist <= P.power_well_dist)
				boutput(holder.owner, "<span class='alert'>You must be within [min_req_dist] tiles from a well of power to perform this task.</span>")
				return 1
		return 0

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder.updateButtons()


/datum/targetable/wraithAbility/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help0"
	targeted = 0
	cooldown = 0
	helpable = 0
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		if (..())
			return 1
		if (holder.help_mode)
			holder.help_mode = 0
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been deactivated.</strong></span>")
		else
			holder.help_mode = 1
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated. To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()


/datum/targetable/wraithAbility/absorbCorpse
	name = "Absorb Corpse"
	icon_state = "absorbcorpse"
	desc = "Steal life essence from a corpse. You cannot use this on a skeleton!"
	targeted = 1
	target_anything = 1
	pointCost = 20
	cooldown = 45 SECONDS //Starts at 45 seconds and scales upward exponentially

	cast(atom/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(holder.owner)

		if ((istype(holder.owner, /mob/wraith/wraith_decay))) // Rewrite this shit, check formaldehyde and holy water; check points
			//Find a suitable corpse
			var/error = 0
			var/mob/living/carbon/human/M
			if (isturf(T))
				for (var/mob/living/carbon/human/target in T.contents)
					if (isdead(target))
						error = 1
						if (target:decomp_stage > 1)
							M = target
							break
			else if (ishuman(T))
				M = T
				if (!isdead(M))
					boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
					return 1

				//check for formaldehyde. if there's more than the wraith's tol amt, we can't absorb right away.
				else if (M.decomp_stage > 1)
					if (M.reagents)
						var/mob/wraith/W = src.holder.owner
						var/amt = M.reagents.get_reagent_amount("formaldehyde")
						if (amt >= W.formaldehyde_tol)
							M.reagents.remove_reagent("formaldehyde", amt)
							boutput(holder.owner, "<span class='alert'>This vessel is tainted with an... unpleasant substance... It is now removed...But you are wounded</span>")
							particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#FFFFFF", 2, locate(M.x, M.y, M.z)))
							holder.owner.health -= 300
							return 0
				else if (M.decomp_stage == 1)
					M = null
					error = 1
				else
					M = T
			else
				boutput(holder.owner, "<span class='alert'>Absorbing [src] does not satisfy your ethereal taste.</span>")
				return 1

			if (!M && !error)
				boutput(holder.owner, "<span class='alert'>There are no usable corpses here!</span>")
				return 1
			if (!M && error)
				boutput(holder.owner, "<span class='alert'>[pick("This body is too fresh.", "This corpse is fresh.")]</span>")
				return 1
			logTheThing("combat", usr, null, "absorbs the corpse of [key_name(M)] as a wraith.")

			//Make the corpse all grody and skeleton-y
			particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(M.x, M.y, M.z)))

			holder.regenRate += 2.0
			holder.points += 100
			holder.owner:onAbsorb(M)
			var/turf/U = get_turf(M)
			U.fluid_react_single("miasma", 50, airborne = 1)
			M.gib()
			var/mob/wraith/W = src.holder.owner
			W.absorbcount += 1
			//Messages for everyone!
			boutput(holder.owner, "<span class='alert'><strong>[pick("You draw the essence of death out of [M]'s corpse!", "You drain the last scraps of life out of [M]'s corpse!")]</strong></span>")
			playsound(M, "sound/voice/wraith/wraithsoulsucc[rand(1, 2)].ogg", 60, 0)
			for (var/mob/living/V in viewers(7, holder.owner))
				boutput(V, "<span class='alert'><strong>[pick("Black smoke rises from [M]'s corpse! Freaky!", "[M]'s corpse suddenly rots to nothing but bone in moments!")]</strong></span>")


			return 0
		else
			//Find a suitable corpse
			var/error = 0
			var/mob/living/carbon/human/M
			if (isturf(T))
				for (var/mob/living/carbon/human/target in T.contents)
					if (isdead(target))
						error = 1
						if (target:decomp_stage != 4)
							M = target
							break
			else if (ishuman(T))
				M = T
				if (!isdead(M))
					boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
					return 1

				//check for formaldehyde. if there's more than the wraith's tol amt, we can't absorb right away.
				else if (M.decomp_stage != 4)
					if (M.reagents)
						var/mob/wraith/W = src.holder.owner
						var/amt = M.reagents.get_reagent_amount("formaldehyde")
						if (amt >= W.formaldehyde_tol)
							M.reagents.remove_reagent("formaldehyde", amt)
							boutput(holder.owner, "<span class='alert'>This vessel is tainted with an... unpleasant substance... It is now removed...</span>")
							particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#FFFFFF", 2, locate(M.x, M.y, M.z)))
							return 0
				else if (M.decomp_stage == 4)
					M = null
					error = 1
				else
					M = T
			else
				boutput(holder.owner, "<span class='alert'>Absorbing [src] does not satisfy your ethereal taste.</span>")
				return 1

			if (!M && !error)
				boutput(holder.owner, "<span class='alert'>There are no usable corpses here!</span>")
				return 1
			if (!M && error)
				boutput(holder.owner, "<span class='alert'>[pick("This body is too decrepit to be of any use.", "This corpse has already been run through the wringer.", "There's nothing useful left.", "This corpse is worthless now.")]</span>")
				return 1
			logTheThing("combat", usr, null, "absorbs the corpse of [key_name(M)] as a wraith.")

			//Make the corpse all grody and skeleton-y
			M.decomp_stage = 4
			if (M.organHolder && M.organHolder.brain)
				qdel(M.organHolder.brain)
			M.set_face_icon_dirty()
			M.set_body_icon_dirty()
			particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(M.x, M.y, M.z)))

			holder.regenRate += 2.0
			holder.owner:onAbsorb(M)
			var/mob/wraith/W = src.holder.owner
			W.absorbcount += 1
			//Messages for everyone!
			boutput(holder.owner, "<span class='alert'><strong>[pick("You draw the essence of death out of [M]'s corpse!", "You drain the last scraps of life out of [M]'s corpse!")]</strong></span>")
			playsound(M, "sound/voice/wraith/wraithsoulsucc[rand(1, 2)].ogg", 60, 0)
			for (var/mob/living/V in viewers(7, holder.owner))
				boutput(V, "<span class='alert'><strong>[pick("Black smoke rises from [M]'s corpse! Freaky!", "[M]'s corpse suddenly rots to nothing but bone in moments!")]</strong></span>")


			return 0


	doCooldown()         //This makes it so wraith early game is much faster but hits a wall of high absorb cooldowns after ~5 corpses
		if (!holder)	 //so wraiths don't hit scientific notation rates of regen without playing perfectly for a million years
			return
		var/datum/abilityHolder/wraith/W = holder
		if (istype(W))
			if (W.corpsecount == 0)
				cooldown = 45 SECONDS
				W.corpsecount += 1
			else
				cooldown += W.corpsecount * 150
				W.corpsecount += 1
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder.updateButtons()


/datum/targetable/wraithAbility/possessObject
	name = "Possess Object"
	icon_state = "possessobject"
	desc = "Possess and control an everyday object. Freakout level: high."
	targeted = 1
	target_anything = 1
	pointCost = 300
	cooldown = 150 SECONDS //Tweaked this down from 3 minutes to 2 1/2, let's see if that ruins anything

	cast(atom/T)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		if (!isitem(T) || istype(T, /obj/item/storage/bible))
			boutput(holder.owner, "<span class='alert'>You cannot possess this!</span>")
			return 1

		boutput(holder.owner, "<span class='alert'><strong>[pick("You extend your will into [T].", "You force [T] to do your bidding.")]</strong></span>")
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithpossesobject.ogg", 50, 0)
		var/mob/living/object/O = new/mob/living/object(T, holder.owner)
		SPAWN(45 SECONDS)
			if (O)
				boutput(O, "<span class='alert'>You feel your control of this vessel slipping away!</span>")
		SPAWN(60 SECONDS) //time limit on possession: 1 minute
			if (O)
				boutput(O, "<span class='alert'><strong>Your control is wrested away! The item is no longer yours.</strong></span>")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithleaveobject.ogg", 50, 0)
				O.death(FALSE)
		return 0


/datum/targetable/wraithAbility/makeRevenant
	name = "Raise Revenant"
	icon_state = "revenant"
	desc = "Take control of an intact corpse as a powerful Revenant! You will not be able to absorb this corpse later. As a revenant, you gain increased point generation, but your revenant abilities cost much more points than normal."
	targeted = 1
	target_anything = 1
	pointCost = 1000
	cooldown = 5 MINUTES

	cast(atom/T)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target) && target:decomp_stage != 4)
					T = target
					break

		if (ishuman(T))
			var/mob/wraith/W = holder.owner
			. = W.makeRevenant(T)		//return 0
			if(!.)
				playsound(W.loc, "sound/voice/wraith/reventer.ogg", 80, 0)
			return
		else
			boutput(usr, "<span class='alert'>There are no corpses here to possess!</span>")
			return 1

/datum/targetable/wraithAbility/decay
	name = "Decay"
	icon_state = "decay"
	desc = "Cause a human to lose stamina, or an object to malfunction."
	targeted = 1
	target_anything = 1
	pointCost = 30
	cooldown = 1 MINUTE //1 minute
	min_req_dist = 15

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a valid target on it
		var/atom/target = null
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/M in T.contents)
				if (!isdead(M))
					target = M
					break
			if (!target)
				for (var/obj/O in T.contents)
					target = O //todo: emaggable check
					break
		else
			target = T

		if (ishuman(T))
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, "<span class='alert'>Some mysterious force protects [T] from your influence.</span>")
				return 1
			else
				boutput(usr, "<span class='notice'>[pick("You sap [T]'s energy.", "You suck the breath out of [T].")]</span>")
				boutput(T, "<span class='alert'>You feel really tired all of a sudden!</span>")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithstaminadrain.ogg", 75, 0)
				H.emote("pale")
				H.remove_stamina( rand(100, 120) )//might be nice if decay was useful.
				H.changeStatus("stunned", 4 SECONDS)
				return 0
		else if (isobj(T))
			var/obj/O = T
			if(istype(O, /obj/machinery/computer/shuttle/embedded))
				boutput(usr, "<span class='alert'>You cannot seem to alter the energy of [O].</span>" )
				return 0
			// go to jail, do not pass src, do not collect pushed messages
			if (O.emag_act(null, null))
				boutput(usr, "<span class='notice'>You alter the energy of [O].</span>")
				return 0
			else
				boutput(usr, "<span class='alert'>You fail to alter the energy of the [O].</span>")
				return 1
		else
			boutput(usr, "<span class='alert'>There is nothing to decay here!</span>")
			return 1

/datum/targetable/wraithAbility/command
	name = "Command"
	icon_state = "command"
	desc = "Command a few objects to hurl themselves at the target location."
	targeted = 1
	target_anything = 1
	pointCost = 50
	cooldown = 20 SECONDS
	min_req_dist = 15

	cast(atom/T)
		var/list/thrown = list()
		var/current_prob = 100
		if (ishuman(T))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, "<span class='alert'>Some mysterious force protects [T] from your influence.</span>")
				return 1
			else
				H.setStatus("stunned", max(H.getStatusDuration("weakened"), max(H.getStatusDuration("stunned"), 3))) // change status "stunned" to max(stunned,weakened,3)
				// T:stunned = max(max(T:weakened, T:stunned), 3)
				H.delStatus("weakened")
				H.lying = 0
				H.show_message("<span class='alert'>A ghostly force compels you to be still on your feet.</span>")
		for (var/obj/O in view(7, holder.owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= 0.35 // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(T, 32, 2)

		return 0

/datum/targetable/wraithAbility/raiseSkeleton
	name = "Raise Skeleton"
	icon_state = "skeleton"
	desc = "Raise a skeletonized dead body as an indurable skeletal servant."
	targeted = 1
	target_anything = 1
	pointCost = 150
	cooldown = 1 MINUTE

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target) && target:decomp_stage == 4)
					T = target
					break

		if (ishuman(T))
			var/mob/living/carbon/human/H = T
			if (!isdead(H) || H.decomp_stage != 4)
				boutput(usr, "<span class='alert'>That body refuses to submit its skeleton to your will.</span>")
				return 1
			var/personname = H.real_name
			var/obj/critter/wraithskeleton/S = new /obj/critter/wraithskeleton(get_turf(T))
			S.name = "[personname]'s skeleton"
			S.health = 1
			H.gib()
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
			return 0
		else
			boutput(usr, "<span class='alert'>There are no skeletonized corpses here to raise!</span>")
			return 1

/datum/targetable/wraithAbility/animateObject
	name = "Animate Object"
	icon_state = "animobject"
	desc = "Animate an inanimate object to attack nearby humans."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 30 SECONDS
	min_req_dist = 10

	cast(atom/T)
		if (..())
			return 1

		var/obj/O = T
		//If you targeted a turf for some reason, find an object on it
		if (istype(T, /turf))
			for (var/obj/target in T.contents)
				if (istype(target, /obj/critter) || istype(target, /obj/machinery/bot) || istype(target, /obj/decal) || target.anchored || target.invisibility)
					continue
				O = target
				break

		if (istype(O))
			if(istype(O, /obj/critter) || istype(O, /obj/machinery/bot) || istype(O, /obj/decal) || O.anchored || O.invisibility)
				boutput(usr, "<span class='alert'>That is not a valid target for animation!</span>")
				return 1
			O.visible_message("<span class='alert'>The [O] comes to life!</span>")
			var/obj/critter/livingobj/L = new/obj/critter/livingobj(O.loc)
			O.set_loc(L)
			L.name = "Living [O.name]"
			L.desc = "[O.desc]. It appears to be alive!"
			L.overlays += O
			L.health = rand(10, 50)
			L.atk_brute_amt = rand(5, 20)
			L.defensive = 1
			L.aggressive = 1
			L.atkcarbon = 1
			L.atksilicon = 1
			L.opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
			L.stunprob = 15
			L.original_object = O
			animate_levitate(L, -1, 30)
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithlivingobject.ogg", 50, 0)
			return 0
		else
			boutput(usr, "<span class='alert'>There is no object here to animate!</span>")
			return 1

/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose haunt appearance"
	icon_state = "haunt"
	targeted = 1
	pointCost = 0
	min_req_dist = INFINITY

	cast(atom/object)
		if (..())
			return 1

		if ((istype(holder.owner, /mob/wraith/wraith_trickster)) && (istype(object, /mob/living/carbon/human/)))
			var/mob/wraith/wraith_trickster/W = holder.owner
			boutput(holder.owner, "copying")
			//var/mutable_appearance/ma = mutable_appearance(fake_appearance.icon, fake_appearance.icon_state)
			W.copied_appearance = new/mutable_appearance(object)
			///var/mutable_appearance/ma = fake_appearance.appearance
			boutput(holder.owner, "Selected [object] for copying.")

/datum/targetable/wraithAbility/haunt
	name = "Haunt"
	icon_state = "haunt"
	desc = "Become corporeal for 30 seconds. During this time, you gain additional biopoints, depending on the amount of humans in your vicinity. You cannot use this ability while already corporeal."
	targeted = 0
	pointCost = 0
	cooldown = 10 SECONDS
	min_req_dist = INFINITY

	cast()
		if (..())
			return 1

		var/mob/wraith/K = src.holder.owner
		if (K.density)
			boutput(holder.owner, "disappear")
			cooldown = 5 SECONDS
			//Fix this shit
			var/mob/wraith/wraith_trickster/N = K
			N.appearance = N.backup_appearance
			return N.disappear()
		else
			boutput(holder.owner, "Appear")
			if ((istype(holder.owner, /mob/wraith/wraith_trickster)))
				var/mob/wraith/wraith_trickster/W = holder.owner
				if (W.copied_appearance == null)
					boutput(holder.owner, "No appearance")
				else
					W.backup_appearance = new/mutable_appearance(W)
					W.appearance = W.copied_appearance

			var/mob/wraith/W = src.holder.owner

			//check done in case a poltergeist uses this from within their master.
			if (iswraith(W.loc))
				boutput(W, "You can't become corporeal while inside another wraith! How would that even work?!")
				return 1

			if (!istype(holder.owner, /mob/wraith/wraith_trickster))
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithhaunt.ogg", 80, 0)
			cooldown = 10 SECONDS
			return W.haunt()

/datum/targetable/wraithAbility/spook
	name = "Spook"
	icon_state = "spook"
	desc = "Cause freaky, weird, creepy or spooky stuff to happen in an area around you. Use this ability to mark your current tile as the origin of these events, then activate it by using this ability again."
	targeted = 0
	pointCost = 0
	cooldown = 20 SECONDS
	special_screen_loc="NORTH,EAST-1"
	min_req_dist = 10

	var/obj/spookMarker/marker = new /obj/spookMarker()		//removed for now
	var/status = 0
	var/static/list/effects = list("Flip light switches" = 1, "Burn out lights" = 2, "Create smoke" = 3, "Create ectoplasm" = 4, "Sap APC" = 5, "Haunt PDAs" = 6, "Open doors, lockers, crates" = 7, "Random" = 8)
	var/list/effects_buttons = list()


	New()
		..()
		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)//, -32, -32)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i=1, i<=8, i++)
			var/datum/contextAction/wraith_spook_button/newcontext = new /datum/contextAction/wraith_spook_button(i)
			object.contextActions += newcontext

	proc/haunt_pda(var/obj/item/device/pda2/pda)
		var/message = pick("boo", "git spooked", "BOOM", "there's a skeleton inside of you", "DEHUMANIZE YOURSELF AND FACE TO BLOODSHED", "ICARUS HAS FOUND YOU!!!!! RUN WHILE YOU CAN!!!!!!!!!!!")

		var/datum/signal/signal = get_free_signal()
		signal.source = src.holder.owner
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = holder.owner.name
		signal.data["message"] = "[message]" // (?)
		signal.data["sender"] = "00000000" // surely this isn't going to be a problem
		signal.data["address_1"] = pda.net_id

		radio_controller.get_frequency(FREQ_PDA).post_packet_without_source(signal)

	cast()
		if (..())
			return 1

	proc/do_spook_ability(var/effect as text)
		if (effect == 8)
			effect = rand(1, 7)
		switch (effect)
			if (1)
				boutput(holder.owner, "<span class='notice'>You flip some light switches near the designated location!!</span>")
				for (var/obj/machinery/light_switch/L in range(10, holder.owner))
					L.Attackhand(holder.owner)
				return 0
			if (2)
				boutput(holder.owner, "<span class='notice'>You cause a few lights to burn out near the designated location!.</span>")
				var/c_prob = 100
				for (var/obj/machinery/light/L in range(10, holder.owner))
					if (L.status == 2 || L.status == 1)
						continue
					if (prob(c_prob))
						L.broken()
						c_prob *= 0.5
				return 0
			if (3)
				boutput(holder.owner, "<span class='notice'>Smoke rises in the designated location.</span>")
				var/turf/trgloc = get_turf(holder.owner)
				if (trgloc && isturf(trgloc))
					var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(trgloc)
					if (S)
						S.set_up(15, 0, trgloc, null, "#000000")
						S.start()
				return 0
			if (4)
				boutput(holder.owner, "<span class='notice'>Matter from your realm appears near the designated location!</span>")
				var/count = rand(5,9)
				var/turf/trgloc = get_turf(holder.owner)
				var/list/affected = block(locate(trgloc.x - 8,trgloc.y - 8,trgloc.z), locate(trgloc.x + 8,trgloc.y + 8,trgloc.z))
				for (var/i in 1 to count)
					new /obj/item/reagent_containers/food/snacks/ectoplasm(pick(affected))
				return 0
			if (5)
				var/sapped_amt = src.holder.regenRate * 100
				var/obj/machinery/power/apc/apc = locate() in get_area(holder.owner)
				if (!apc)
					boutput(holder.owner, "<span class='alert'>Power sap failed: local APC not found.</span>")
					return 0
				boutput(holder.owner, "<span class='notice'>You sap the power of the chamber's power source.</span>")
				var/obj/item/cell/cell = apc.cell
				if (cell)
					cell.use(sapped_amt)
				return 0
			if (6)
				boutput(holder.owner, "<span class='notice'>Mysterious messages haunt PDAs near the designated location!</span>")
				for (var/mob/living/L in range(10, holder.owner))
					var/obj/item/device/pda2/pda = locate() in L
					if (pda)
						src.haunt_pda(pda)
				for (var/obj/item/device/pda2/pda in range(10, holder.owner))
					src.haunt_pda(pda)
			if (7)
				boutput(holder.owner, "<span class='notice'>Crates, lockers and doors mysteriously open and close in the designated area!</span>")
				var/c_prob = 100
				for(var/obj/machinery/door/G in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN(1 DECI SECOND)
							if (G.density)
								G.open()
							else
								G.close()
				c_prob = 100
				for(var/obj/storage/F in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN(1 DECI SECOND)
							if (F.open)
								F.close()
							else
								F.open()

		return 0

/datum/targetable/wraithAbility/whisper
	name = "Whisper"
	icon_state = "whisper"
	desc = "Send an ethereal message to a living being."
	targeted = 1
	target_anything = 1
	pointCost = 1
	cooldown = 2 SECONDS
	min_req_dist = 20
	proc/ghostify_message(var/message)
		return message

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (isdead(H))
				boutput(usr, "<span class='alert'>They can hear you just fine without the use of your abilities.</span>")
				return 1
			else
				var/message = html_encode(input("What would you like to whisper to [target]?", "Whisper", "") as text)
				logTheThing("say", usr, target, "WRAITH WHISPER TO [constructTarget(target,"say")]: [message]")
				message = ghostify_message(trim(copytext(sanitize(message), 1, 255)))
				if (!message)
					return 1
				boutput(usr, "<b>You whisper to [target]:</b> [message]")
				boutput(target, "<b>A netherworldly voice whispers into your ears... </b> [message]")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		else
			boutput(usr, "<span class='alert'>It would be futile to attempt to force your voice to the consciousness of that.</span>")
			return 1

//this is the spooky_writing ability from spooktober ghosts
/datum/targetable/wraithAbility/blood_writing
	name = "Blood Writing"
	desc = "Write a spooky character on the ground."
	icon_state = "bloodwriting"
	targeted = 1
	target_anything = 1
	pointCost = 10
	cooldown = 5 SECONDS
	min_req_dist = 10
	var/in_use = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T))
			write_on_turf(T, holder.owner, params)


	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use)
			return
		src.in_use = 1
		var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
		var/list/c_symbol = list("Dollar", "Euro", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentagram")

		var/t = input(user, "What do you want to write?", null, null) as null|anything in (c_default + c_symbol)

		if (!t)
			src.in_use = 0
			return 1
		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing("station", user, null, "writes on [T] with [src] [log_loc(T)]: [t]")
		G.icon_state = t
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 0)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

//this is the spooky_writing ability from spooktober ghosts
/datum/targetable/wraithAbility/make_poltergeist
	name = "Make Poltergeist"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 600
	cooldown = 5 MINUTES
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
			make_poltergeist(holder.owner, T)
		else
			boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
			return 1

	proc/make_poltergeist(var/mob/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a poltergeist? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a poltergeist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up poltergeist ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_poltergeist(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		//add poltergeist to master's list is done in /mob/wraith/potergeist/New
		var/mob/wraith/poltergeist/P = new /mob/wraith/poltergeist(T, W, marker)
		lucky_dude.special_role = ROLE_POLTERGEIST
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		ticker.mode.Agimmicks |= lucky_dude
		//P.ckey = lucky_dude.ckey
		P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a poltergeist for [src.holder.owner].")
		usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
		logTheThing("admin", lucky_dude.current, null, "respawned as a poltergeist for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")

/datum/targetable/wraithAbility/harbinger_summon
	name = "Make Summon"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 10
	cooldown = 10 SECOND
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
			make_summon(holder.owner, T)
		else
			boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
			return 1

	proc/make_summon(var/mob/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a poltergeist? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a poltergeist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up poltergeist ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_summon(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		//add poltergeist to master's list is done in /mob/wraith/potergeist/New
		var/mob/wraith/poltergeist/P = new /mob/wraith/poltergeist(T, W, marker)
		lucky_dude.special_role = ROLE_POLTERGEIST
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		ticker.mode.Agimmicks |= lucky_dude
		//P.ckey = lucky_dude.ckey
		P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a poltergeist for [src.holder.owner].")
		usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
		logTheThing("admin", lucky_dude.current, null, "respawned as a poltergeist for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")

/datum/targetable/wraithAbility/make_plague_rat
	name = "Make PlagueRat"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 0
	cooldown = 10 SECONDS
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS
	var/max_allowed_rats = 5

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/total_plague_rats = 0
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			// not sure how this could happen, but be safe about it
			if (!C.mob)
				continue
			var/mob/M = C.mob
			if (istype(M, /mob/living/critter/plaguerat))
				total_plague_rats ++
		if(total_plague_rats < max_allowed_rats)
			var/turf/T = get_turf(holder.owner)
			if (isturf(T) && !istype(T, /turf/space))
				boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
				make_plague_rat(holder.owner, T)
			else
				boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
				return 1
		else
			boutput(holder.owner, "<span class='alert'>The station is already a rat hive, you cannot summon another rat!</span>")
			return 1

	proc/make_plague_rat(var/mob/W, var/turf/T, var/tries = 0)
		if (!istype(W, /mob/wraith/wraith_decay) || !istype(W, /mob/living/critter/plaguerat))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a poltergeist? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a poltergeist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up poltergeist ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_plague_rat(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		//add poltergeist to master's list is done in /mob/wraith/potergeist/New
		var/mob/living/critter/plaguerat/P = new /mob/living/critter/plaguerat(T, W, marker)
		lucky_dude.special_role = ROLE_PLAGUERAT
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		ticker.mode.Agimmicks |= lucky_dude
		//P.ckey = lucky_dude.ckey
		//P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a poltergeist for [src.holder.owner].")
		usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
		logTheThing("admin", lucky_dude.current, null, "respawned as a poltergeist for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")

/datum/targetable/wraithAbility/specialize
	name = "Choose specialisation"
	icon_state = "spook"
	desc = "Evolve"
	targeted = 0
	pointCost = 1

	var/status = 0
	var/static/list/effects = list("Rot" = 1, "Summoner" = 2, "Trickster" = 3)
	var/list/effects_buttons = list()


	New()
		..()
		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)//, -32, -32)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i=1, i<=3, i++)
			var/datum/contextAction/wraith_evolve_button/newcontext = new /datum/contextAction/wraith_evolve_button(i)
			object.contextActions += newcontext

	cast()
		if (..())
			return 1

	proc/evolve(var/effect as text)
		var/mob/wraith/O = src.holder.owner
		if (O.absorbcount < 0)
			boutput(holder.owner, "<span class='notice'>You need to absorb at least 1 corpse!!</span>")
			return 1
		else
			var/mob/wraith/W
			switch (effect)
				if (1)
					W = new/mob/wraith/wraith_decay(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a decay wraith!!</span>")
				if (2)
					W = new/mob/wraith/wraith_invocation(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a posession wraith!!</span>")
				if (3)
					W = new/mob/wraith/wraith_trickster(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a trickster wraith!!</span>")

			W.real_name = holder.owner.real_name
			W.UpdateName()
			var/turf/T = get_turf(holder.owner)
			W.set_loc(T)

			holder.owner.mind.transfer_to(W)
			qdel(holder.owner)

			return W

/datum/targetable/wraithAbility/curseBrand
	name = "Hex"
	icon_state = "skeleton"
	desc = "Curse a human with a thing."
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = target
			H.bioHolder.AddEffect("blood_curse")

/datum/targetable/wraithAbility/blindBrand
	name = "Hex"
	icon_state = "skeleton"
	desc = "Curse a human with a thing."
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = target
			H.bioHolder.AddEffect("blind_curse")

/datum/targetable/wraithAbility/weakBrand
	name = "Hex"
	icon_state = "skeleton"
	desc = "Curse a human with a thing."
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = target
			H.bioHolder.AddEffect("weak_curse")

/datum/targetable/wraithAbility/rotBrand
	name = "Hex"
	icon_state = "skeleton"
	desc = "Curse a human with a thing."
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = target
			H.bioHolder.AddEffect("rot_curse")

/datum/targetable/wraithAbility/summon_rot_hulk
	name = "Rot Hulk"
	desc = "Check area for filth and summon a rot hulk."
	icon_state = "grinchpoison"
	targeted = 0
	cooldown = 10 SECONDS
	pointCost = 10

	cast()
		if (..())
			return 1

		// use step_towards(N,M) when eating

		var/decal_count = 0
		var/list/decal_list = list()
		for (var/obj/decal/cleanable/C in range(3))
			//Use a list here fuck
			if(!istype(C, /obj/decal/cleanable/writing) && !istype(C, /obj/decal/cleanable/sakura) && !istype(C, /obj/decal/cleanable/paint) && !istype(C, /obj/decal/cleanable/saltpile) && !istype(C, /obj/decal/cleanable/greenglow) && !istype(C, /obj/decal/cleanable/gangtag))
				decal_count += 1
				decal_list += list(C)
		if (decal_count > 10)
			new /mob/living/critter/exploder(get_turf(holder.owner))
			if (decal_count > 30)
				boutput(holder.owner, __red("Big filth"))
			else
				boutput(holder.owner, __red("Small filth"))
			for(var/obj/decal/cleanable/C in decal_list)
				qdel(C)
		else
			boutput(holder.owner, __red("There isnt enough filth?"))

/datum/targetable/wraithAbility/poison
	name = "Poison item"
	desc = "Ruin a food item or drink by adding horrible poison to it."
	icon_state = "grinchpoison"
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	cooldown = 50 SECONDS
	pointCost = 50
	var/list/the_poison = list("bee", "cyanide", "grave_dust", "loose_screws", "mucus", "plague", "rotting")
	var/amount_per_poison = 10

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/wraith/W = holder.owner

		if (!W || !target)
			return 1

		if (W == target)
			boutput(W, __red("Why would you want to poison yourself?"))
			return 1

		// Written in such a way that adding other reagent containers (e.g. medicine) would be trivial.
		var/obj/item/reagent_containers/RC = null
		var/attempt_success = 0

		if (istype(target, /obj/item/reagent_containers/food)) // Food and drinking glass/bottle parent.
			RC = target
		else
			boutput(W, __red("You can't poison [target], only food items and drinks."))
			return 1

		var/poison_choice = input("Select the target poison: ", "Target Poison", null) as null|anything in the_poison

		if (RC && istype(RC))
			if (src.the_poison.len > 1)
				if (!RC.reagents)
					RC.reagents = new /datum/reagents(src.amount_per_poison)
					RC.reagents.my_atom = RC

				if (RC.reagents)
					if (RC.reagents.total_volume + src.amount_per_poison >= RC.reagents.maximum_volume)
						RC.reagents.remove_any(RC.reagents.total_volume + src.amount_per_poison - RC.reagents.maximum_volume)
					RC.reagents.add_reagent(poison_choice, src.amount_per_poison)


					attempt_success = 1
				else
					attempt_success = 0
			else
				attempt_success = 0
		else
			attempt_success = 0

		if (attempt_success == 1)
			boutput(W, __blue("You successfully poisoned [target]."))
			logTheThing("combat", W, null, "poisons [target] [log_reagents(target)] at [log_loc(W)].")
			return 0
		else
			boutput(W, __red("You failed to poison [target]."))
			return 1

/datum/targetable/wraithAbility/mass_whisper
	name = "Mass Whisper"
	icon_state = "whisper"
	desc = "Send an ethereal message to all close living beings."
	pointCost = 10
	targeted = 0
	cooldown = 10 SECONDS
	proc/ghostify_message(var/message)
		return message

	cast()
		if (..())
			return 1

		var/message = html_encode(input("What would you like to whisper to everyone?", "Whisper", "") as text)
		for (var/mob/living/M in range(8))
			if (ishuman(M) && !isdead(M))
				var/mob/living/carbon/human/H = M
				logTheThing("say", usr, M, "WRAITH WHISPER TO [constructTarget(M,"say")]: [message]")
				message = ghostify_message(trim(copytext(sanitize(message), 1, 255)))
				if (!message)
					return 1
				boutput(M, "<b>A netherworldly voice whispers into your ears... </b> [message]")
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
				H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		boutput(usr, "<b>You whisper to everyone around you:</b> [message]")

/datum/targetable/wraithAbility/mass_emag
	name = "Mass Emagging"
	icon_state = "whisper"
	desc = "Emag everything around you."
	pointCost = 10
	targeted = 0
	cooldown = 10 SECONDS

	cast()
		if (..())
			return 1

		boutput(usr, "<span class='notice'>You begin to gather your energy.</span>")
		sleep(5 SECONDS)
		for (var/atom/A in range(3))
			if (ishuman(A))
				var/mob/living/carbon/H = A
				boutput(H, "<span class='alert'>You feel a sudden dizzyness!</span>")
				H.emote("pale")
				return 0
			else if (isobj(A))
				var/obj/O = A
				if (O.emag_act(null, null) && !istype(O, /obj/machinery/computer/shuttle/embedded))
					boutput(usr, "<span class='notice'>You alter the energy of [O].</span>")

/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "whisper"
	desc = "possess a dude"
	pointCost = 10
	targeted = 1
	cooldown = 10 SECONDS
	var/wraith_key = null

	cast(mob/target)
		if (..())
			return 1
		if (istype(holder.owner, /mob/wraith/wraith_trickster))
			var/mob/wraith/wraith_trickster/W = holder.owner
			if (W.possession_points > W.points_to_possess)
				if (ishuman(target))
					var/mob/living/carbon/human/H = target
					var/has_mind = false
					var/mob/dead/target_observer/slasher_ghost/WG = null
					wraith_key = holder.owner.ckey
					H.emote("scream")
					boutput(H, __red("<span class='notice'>You are feeling awfully woozy.</span>"))
					H.change_misstep_chance(20)
					sleep(10 SECONDS)
					boutput(H, __red("<span class='notice'>You hear a cacophony of otherwordly voices in your head.</span>"))
					H.emote("faint")
					H.setStatusMin("weakened", 5 SECONDS)
					sleep(15 SECONDS)
					H.change_misstep_chance(-20)
					H.emote("scream")
					H.setStatusMin("weakened", 8 SECONDS)
					H.setStatusMin("paralysis", 8 SECONDS)
					sleep(8 SECONDS)
					var/mob/dead/observer/O = H.ghostize()
					if (O?.mind)
						boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
						WG = O.insert_slasher_observer(H)
						WG.mind.dnr = TRUE
						WG.verbs -= list(/mob/verb/setdnr)
						has_mind = true
					W.mind.transfer_to(H)

					sleep(90 SECONDS)
					if(!H.loc) //H gibbed
						var/mob/M2 = ckey_to_mob(wraith_key)
						M2.mind.transfer_to(W)
					if(!W.loc) //wraith got gibbed
						return
					H.mind.transfer_to(W)
					if (has_mind)
						sleep(5 DECI SECONDS)
						WG.mind.dnr = FALSE
						WG.verbs += list(/mob/verb/setdnr)
						WG.mind.transfer_to(H)
						playsound(H, "sound/effects/ghost2.ogg", 50, 0)
					W.possession_points = 0
					logTheThing("debug", null, null, "step 5")
					qdel(WG)
			else
				boutput(holder.owner, "You cannot possess with only [W.possession_points] possession power. You'll need at least [(W.points_to_possess - W.possession_points)]")

/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "whisper"
	desc = "Emag everything around you."
	pointCost = 10
	targeted = 1
	cooldown = 10 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			var/mob/living/carbon/H = target
			H.setStatus("terror", 45 SECONDS)

/datum/targetable/wraithAbility/create_summon_portal
	name = "Summon void portal"
	icon_state = "whisper"
	desc = "Summon a void portal from which stuff pours out"
	pointCost = 10
	targeted = 0
	cooldown = 5 SECONDS

	cast()
		if (..())
			return 1

		boutput(holder.owner, "You gather your energy and open a portal")
		var/obj/vortex_wraith = new /obj/vortex_wraith(get_turf(holder.owner))



/obj/spookMarker
	name = "Spooky Marker"
	desc = "What is this? You feel like you shouldn't be able to see it, but it has an ominous and slightly mischevious aura."
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "acursed"
	// invisibility = INVIS_ALWAYS
	invisibility = INVIS_GHOST
	anchored = 1
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 100

	New()
		..()
		var/matrix/M = matrix()
		M.Scale(0.75,0.75)
		animate(src, transform = M, time = 3 SECONDS, loop = -1,easing = ELASTIC_EASING)
