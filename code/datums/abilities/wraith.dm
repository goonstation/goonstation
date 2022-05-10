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

		if ((istype(holder.owner, /mob/wraith/wraith_decay)))
			//Find a suitable corpse
			var/error = 0
			var/mob/living/carbon/human/M
			if (isturf(T))
				for (var/mob/living/carbon/human/target in T.contents)
					if (isdead(target))
						error = 1
						M = target
						break
			else if (ishuman(T))
				M = T
				if (!isdead(M))
					boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
					return 1

				//check for formaldehyde. if there's more than the wraith's tol amt, we can't absorb right away.
				if (M.reagents)
					var/mob/wraith/W = src.holder.owner
					var/amt = M.reagents.get_reagent_amount("formaldehyde")
					if (amt >= W.formaldehyde_tol)
						M.reagents.remove_reagent("formaldehyde", amt)
						boutput(holder.owner, "<span class='alert'>This vessel is tainted with an... unpleasant substance... It is now removed...But you are wounded</span>")
						particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#FFFFFF", 2, locate(M.x, M.y, M.z)))
						holder.owner.TakeDamage(null, 50, 0)
						return 0
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

			if (M.get_toxin_damage() > 60 || M.decomp_stage == 4)
				boutput(holder.owner, "<span class='alert'>This corpse is extremely rotten and bloated. It satisfies us greatly</span>")
				holder.points += 150
				holder.regenRate += 2.0
				var/turf/U = get_turf(M)
				U.fluid_react_single("miasma", 60, airborne = 1)
				M.gib()
				for (var/mob/living/V in viewers(7, holder.owner))
					boutput(V, "<span class='alert'><strong>[pick("A mysterious force rips [M]'s body apart!", "[M]'s corpse suddenly explodes in a cloud of miasma and guts!")]</strong></span>")
			else
				boutput(holder.owner, "<span class='alert'><strong>[pick("You draw the essence of death out of [M]'s corpse!", "You drain the last scraps of life out of [M]'s corpse!")]</strong></span>")
				for (var/mob/living/V in viewers(7, holder.owner))
					boutput(V, "<span class='alert'><strong>[pick("Black smoke rises from [M]'s corpse! Freaky!", "[M]'s corpse suddenly rots to nothing but bone in moments!")]</strong></span>")
				holder.regenRate += 1.5
			//Make the corpse all grody and skeleton-y
			particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(M.x, M.y, M.z)))
			holder.owner:onAbsorb(M)
			var/mob/wraith/W = src.holder.owner
			W.absorbcount += 1
			//Messages for everyone!
			playsound(M, "sound/voice/wraith/wraithsoulsucc[rand(1, 2)].ogg", 60, 0)

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

	cast(var/atom/target)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		if (istype(target, /obj/item/storage/bible))
			boutput(holder.owner, "<span class='alert'><b>You feel rebuffed by a holy force!<b></span>")

		if (!isitem(target))
			boutput(holder.owner, "<span class='alert'>You cannot possess this!</span>")
			return 1

		boutput(holder.owner, "<span class='alert'><strong>[pick("You extend your will into [target].", "You force [target] to do your bidding.")]</strong></span>")
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithpossesobject.ogg", 50, 0)
		var/mob/living/object/O = new/mob/living/object(get_turf(target), target, holder.owner)
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
	pointCost = 100
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
			//Or a locker
			for (var/obj/storage/closet/target in T.contents)
				if (target.open == 0)
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
			S.health = 30
			H.gib()
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
			return 0
		if (isobj(T))
			var/obj/critter/wraithskeleton/S = new /obj/critter/wraithskeleton(T)
			S.name = "Locker skeleton"
			S.health = 20
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
			//Todo maybe open the locker after a bit?
			//var/obj/storage/closet/C
			//C.open()
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
			new/mob/living/object/ai_controlled(O.loc, O)
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithlivingobject.ogg", 50, 0)
			return 0
		else
			boutput(usr, "<span class='alert'>There is no object here to animate!</span>")
			return 1

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
			boutput(holder.owner, "We fade back into the shadows")
			cooldown = 0 SECONDS
			if (istype(K, /mob/wraith/wraith_trickster))
				var/mob/wraith/wraith_trickster/T = K
				T.appearance = T.backup_appearance
				return T.disappear()
			else
				return K.disappear()
		else
			boutput(holder.owner, "We show ourselves")
			var/mob/wraith/W = holder.owner

			//Todo bugfix: Cooldown doesnt begin when manifesting as a human
			cooldown = 10 SECONDS

			if ((istype(W, /mob/wraith/wraith_trickster)))	//Trickster can appear as a human, living or dead.
				var/mob/wraith/wraith_trickster/T = holder.owner
				if (T.copied_appearance != null)
					T.backup_appearance = new/mutable_appearance(T)
					T.appearance = T.copied_appearance	//Appearace might make use dense already. So we cant use the W.haunt() proc
					usr.playsound_local(usr.loc, "sound/voice/wraith/wraithhaunt.ogg", 80, 0)
					animate(T, alpha=255, time=2 SECONDS)
					if (!T.density)
						T.set_density(1)
					REMOVE_ATOM_PROPERTY(T, PROP_MOB_INVISIBILITY, T)
					T.see_invisible = INVIS_NONE
					T.haunting = 1
					T.flags &= !UNCRUSHABLE
					return 0

			//check done in case a poltergeist uses this from within their master.
			if (iswraith(W.loc))
				boutput(W, "You can't become corporeal while inside another wraith! How would that even work?!")
				return 1

			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithhaunt.ogg", 80, 0)

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

/datum/targetable/wraithAbility/specialize
	name = "Evolve"
	icon_state = "spook"
	desc = "Choose a form to evolve into once you have grown strong enough"
	targeted = 0
	pointCost = 1
	//Todo: copied from "spook". Fix list appearing on the left of the screen
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
		if (O.absorbcount < O.absorbs_to_evolve)
			boutput(holder.owner, "<span class='notice'>You didn't absorb enough souls. You need to absorb at least [O.absorbs_to_evolve - O.absorbcount] more!</span>")
			return 1
		if (holder.points < pointCost)//Todo check if this is necessary
			boutput(holder.owner, "<span class='notice'>You do not have enough points to cast that</span>")
		else
			var/mob/wraith/W
			switch (effect)	//Todo, add messages and windows on transform
				if (1)
					W = new/mob/wraith/wraith_decay(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a plaguebringer!</span>")
				if (2)
					W = new/mob/wraith/wraith_invocation(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a harbinger!</span>")
				if (3)
					W = new/mob/wraith/wraith_trickster(holder.owner)
					boutput(holder.owner, "<span class='notice'>You turn into a trickster!</span>")

			W.real_name = holder.owner.real_name
			W.UpdateName()
			var/turf/T = get_turf(holder.owner)
			W.set_loc(T)

			holder.owner.mind.transfer_to(W)
			qdel(holder.owner)

			return W

////////////////////////
// Curses
////////////////////////
/datum/targetable/wraithAbility/curse
	name = "Base curse"
	icon_state = "skeleton"
	desc = "This should never be seen."
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())

			return 1
		//Todo maybe give lasting immunity if you stood in the chapel? Avoids harassing the same person over and over, but perhaps its fine.
		if (istype(get_area(target), /area/station/chapel))	//Dont spam curses in the chapel.
			boutput(holder.owner, "The holy ground this creature is standing on repels the curse immediatly.")
			return 1

		if (ishuman(target))	//Lets let people know they have been cursed, might not be obvious at first glance
			var/mob/living/carbon/H = target
			var/curseCount = 0
			if (H.bioHolder.HasEffect("blood_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("blind_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("weak_curse"))
				curseCount ++
			if (H.bioHolder.HasEffect("rot_curse"))
				curseCount ++
			switch(curseCount)
				if (2)
					boutput(H, "<span class='notice'>You feel strangely sick.</span>")
				if (3)
					boutput(H, "<span class='alert'>You hear whisper in your head, pushing you towards your doom.</span>")
				if (4)
					boutput(H, "<span class='alert'>A cacophony of otherworldly voices resonates within your mind. You sense a feeling of impending doom! You should seek salvation in the chapel.</span>")

			//Lets not spam every curse at once.
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()

/datum/targetable/wraithAbility/curse/blood
	name = "Curse of blood"
	icon_state = "skeleton"
	desc = "Curse the living with a plague of blood."
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
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/blindness
	name = "Curse of blindness"
	icon_state = "skeleton"
	desc = "Curse the living with blindness."
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
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/enfeeble
	name = "Curse of weakness"
	icon_state = "skeleton"
	desc = "Curse the living with weakness and lower stamina regeneration."
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
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/rot
	name = "Curse of rot"
	icon_state = "skeleton"
	desc = "Curse the living with a netherworldly plague."
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
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/death	//Only castable if you already put 4 curses on someone
	name = "Curse of death"
	icon_state = "skeleton"
	desc = "Reap a fully cursed being's soul!"
	targeted = 1
	pointCost = 20
	cooldown = 40 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))	//Todo maybe cancel the affect if you manage to get dragged to the chapel? Might feel bad for the wraith, so perhaps not.
			var/mob/living/carbon/human/H = target
			var/mob/wraith/W = holder.owner
			if (H?.bioHolder.HasEffect("rot_curse") && H?.bioHolder.HasEffect("weak_curse") && H?.bioHolder.HasEffect("blind_curse") && H?.bioHolder.HasEffect("blood_curse"))
				boutput(holder.owner, "<span class='alert'>That soul is OURS</span>")
				boutput(H, "The voices in your heads are reaching a crescendo")
				sleep(4 SECOND)
				H.make_jittery(50)	//Todo, this doesnt work, need to fix it.
				H.changeStatus("stunned", 2 SECONDS)
				H.emote("scream")
				boutput(holder.owner, "You feel netherworldly hands grasping you.")
				sleep(3 SECOND)
				random_brute_damage(H, 10)
				playsound(H.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 70, 1)
				H.visible_message("<span class='alert'>[H]'s flesh tears open before your very eyes!!</span>")
				sleep(1 SECOND)
				random_brute_damage(H, 10)
				playsound(H.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 70, 1)
				sleep(1 SECOND)
				random_brute_damage(H, 20)
				playsound(H.loc, "sound/impact_sounds/Flesh_Tear_2.ogg", 70, 1)
				sleep(2 SECOND)
				boutput(H, "<span class='alert'>IT'S COMING FOR YOU!</span>")
				H.remove_stamina( rand(100, 120) )
				H.changeStatus("stunned", 4 SECONDS)
				sleep(3 SECOND)
				H.gib()
				boutput(holder.owner, "<span class='alert'>What delicious agony!</span>")
				var/turf/T = get_turf(H)
				T.fluid_react_single("miasma", 60, airborne = 1)
				holder.points += 100
				holder.regenRate += 2.0
				W.absorbcount++
			else
				boutput(holder.owner, "That being's soul is not weakened enough. We need to curse it some more.")
				return 1


/datum/targetable/wraithAbility/summon_rot_hulk
	name = "Rot Hulk"
	desc = "Check area for filth and summon a rot hulk."
	icon_state = "grinchpoison"
	targeted = 0
	cooldown = 10 SECONDS
	pointCost = 10
	var/list/decal_list = list(/obj/decal/cleanable/blood,
	/obj/decal/cleanable/ketchup,
	/obj/decal/cleanable/rust,
	/obj/decal/cleanable/urine,
	/obj/decal/cleanable/vomit,
	/obj/decal/cleanable/greenpuke,
	/obj/decal/cleanable/slime,
	/obj/decal/cleanable/fungus)

	cast()
		if (..())
			return 1

		var/decal_count = 0
		var/list/found_decal_list = list()
		for (var/obj/decal/cleanable/C in range(3, get_turf(holder.owner)))
			for (var/D in decal_list)
				if (istype(C, D))
					decal_count++
					found_decal_list += C
		if (decal_count > 15)
			var/turf/T = get_turf(holder.owner)
			T.visible_message("<span class='alert'>All the filth and grime around begins to writhe and move!</span>")
			for(var/obj/decal/cleanable/C in found_decal_list)
				step_towards(C,T)
			sleep(1.5 SECOND)
			for(var/obj/decal/cleanable/C in found_decal_list)
				step_towards(C,T)
			sleep(1.5 SECOND)	//Todo add a cool effect here.
			if (decal_count > 30)
				var/mob/living/critter/exploder/strong/E = new /mob/living/critter/exploder/strong(T)
				T.visible_message("<span class='alert'>A [E] slowly emerges from the gigantic pile of grime!</span>")
				boutput(holder.owner, "The great amount of filth coalesces into a rotting goliath")
			else
				var/mob/living/critter/exploder/E = new /mob/living/critter/exploder(T)
				T.visible_message("<span class='alert'>A [E] slowly rises up from the coalesced filth!</span>")
				boutput(holder.owner, "The filth accumulates into a living bloated abomination")
			for(var/obj/decal/cleanable/C in found_decal_list)
				qdel(C)
			return 0
		else
			boutput(holder.owner, __red("This place is much too clean to summon a rot hulk."))
			return 1

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

		var/obj/item/reagent_containers/RC = null
		var/attempt_success = 0

		if (istype(target, /obj/item/reagent_containers/food))
			RC = target
		else
			boutput(W, __red("You can't poison [target], only food items, drinks and glass containers."))
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

/datum/targetable/wraithAbility/mass_emag	//Todo, check if emagging borgs is okay
	name = "Mass Decay"
	icon_state = "whisper"
	desc = "Disrupt the energy of every machinery around you."
	pointCost = 10
	targeted = 0
	cooldown = 10 SECONDS

	cast()
		if (..())
			return 1

		boutput(usr, "<span class='notice'>You begin to gather your energy.</span>")
		var/turf/T = get_turf(holder.owner)
		sleep(5 SECONDS)
		for (var/mob/living/carbon/human/A in range(4, T))
			if (!isdead(A))
				var/mob/living/carbon/H = A
				boutput(H, "<span class='alert'>You feel a sudden dizzyness!</span>")
				H.emote("pale")
				return 0
		for (var/obj/A in range(4, T))
			if (A.emag_act(null, null) && !istype(A, /obj/machinery/computer/shuttle/embedded))
				boutput(usr, "<span class='notice'>You alter the energy of [A].</span>")

/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "whisper"
	desc = "Channel your energy and slowly gain control over a living being"
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
				if (ishuman(target) && !isdead(target))
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
					APPLY_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)	//Subject to change.
					sleep(70 SECONDS)
					boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your control on this body is weakening, you will soon be kicked out of it.</span>")
					sleep(20 SECONDS)
					boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your hold on this body has been broken! You return to the aether.</span>")
					REMOVE_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)
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
					H.take_brain_damage(70)
					H.setStatus("weakened", 5 SECOND)
					boutput(H, "The presence has left your body and you are thrusted back into it, immediatly assaulted with a winging headacke.")
					return 0
			else
				boutput(holder.owner, "You cannot possess with only [W.possession_points] possession power. You'll need at least [(W.points_to_possess - W.possession_points)] more.")
				return 1

/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "whisper"
	desc = "Induce terror inside a mortal's mind and make them hallucinate."
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
			boutput(holder.owner, "We terrorize [H]")
			return 0
		else
			return 1

/datum/targetable/wraithAbility/create_summon_portal
	name = "Summon void portal"
	icon_state = "whisper"
	desc = "Summon a void portal from which otherworldly creatures pour out"
	pointCost = 10
	targeted = 0
	cooldown = 5 SECONDS

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			if(istype(holder.owner, /mob/wraith))
				var/mob/wraith/W = holder.owner
				if(W.haunting)
					boutput(holder.owner, "You gather your energy and open a portal")
					new /obj/vortex_wraith(get_turf(holder.owner))
					return 0
				else
					boutput(holder.owner, "Your connection to the physical plane is too weak. You must be manifested to do this.")
					return 1
		else
			boutput(holder.owner, "We cannot open a portal here")
			return 1

/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose haunt appearance"
	icon_state = "haunt"
	targeted = 1
	pointCost = 0

	cast(atom/target)
		if (..())
			return 1

		if ((istype(holder.owner, /mob/wraith/wraith_trickster)) && (istype(target, /mob/living/carbon/human/)))
			var/mob/wraith/wraith_trickster/W = holder.owner
			boutput(holder.owner, "We steal [target]'s appearance for ourselves.")
			W.copied_appearance = new/mutable_appearance(target)
			//Todo instead check if lying, and if lying transform.turn
			W.copied_appearance.transform = null
			W.copied_appearance.alpha = 0
			return 0
		else if((istype(holder.owner, /mob/wraith/wraith_trickster)) && (istype(target, /mob/wraith/wraith_trickster)))
			var/mob/wraith/wraith_trickster/W = holder.owner
			boutput(W, "We discard our stored appearance.")
			W.copied_appearance = null
		else
			boutput(holder.owner, "We cannot copy this appearance")

/datum/targetable/wraithAbility/harbinger_summon
	name = "Summon void creature"
	desc = "Attempt to breach the veil between worlds to allow a lesser void creature to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 10
	cooldown = 10 SECOND
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

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
		text_messages.Add("Would you like to respawn as a harbinger summon? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a harbinger summon. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending harbinger summon offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up harbinger summon ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up harbinger summon ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up harbinger summon ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_summon(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		//add poltergeist to master's list is done in /mob/wraith/potergeist/New
		var/mob/living/critter/nascent/P = new /mob/living/critter/nascent(T, W)
		lucky_dude.special_role = ROLE_HARBINGERSUMMON
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		ticker.mode.Agimmicks |= lucky_dude
		//P.ckey = lucky_dude.ckey
		P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a harbinger summon for [src.holder.owner].")
		usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
		logTheThing("admin", lucky_dude.current, null, "respawned as a harbinger summon for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a harbinger summon!</b></span>")
		boutput(P, "[W] is your master! Use your abilities to choose a path! Work with your master to spread chaos!")

/datum/targetable/wraithAbility/make_plague_rat
	name = "Summon Plague rat"
	desc = "Attempt to breach the veil between worlds to allow a plague rat to enter this realm."
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
			if (!C.mob)
				continue
			var/mob/M = C.mob
			if (istype(M, /mob/living/critter/plaguerat))
				total_plague_rats++
		if(total_plague_rats < max_allowed_rats)
			if (istype(holder.owner, /mob/living/critter/plaguerat))	//plaguerats must be near their warren
				var/near_warren = false
				var/turf/T = get_turf(holder.owner)
				for (var/obj/O in T.contents)
					if(istype(O, /obj/machinery/warren))
						near_warren = true
				if(!near_warren)
					boutput(holder.owner, "We arent close enough to a warren to do this.")
					return 1
			var/turf/T = get_turf(holder.owner)
			if (isturf(T) && !istype(T, /turf/space))
				boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
				make_plague_rat(holder.owner, T)
			else
				boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
				return 1
		else
			boutput(holder.owner, "<span class='alert'>The station is already a rat den, you cannot summon another rat!</span>")
			return 1

	proc/make_plague_rat(var/mob/W, var/turf/T, var/tries = 0)
		if (!istype(W, /mob/wraith/wraith_decay) && !istype(W, /mob/living/critter/plaguerat))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a plague rat? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a plague rat. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		usr.playsound_local(usr.loc, "sound/voice/wraith/wraithportal.ogg", 50, 0)
		message_admins("Sending plague rat offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up plague rat ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up plague rat ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up plague rat ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN(3 MINUTES)
					make_plague_rat(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		//add plague rat to master's list is done in /mob/living/critter/plaguerat/New
		var/mob/living/critter/plaguerat/P = new /mob/living/critter/plaguerat(T, W)
		lucky_dude.special_role = ROLE_PLAGUERAT
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		ticker.mode.Agimmicks |= lucky_dude
		//Might need to re-add those.
		//P.ckey = lucky_dude.ckey
		//P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a plague rat for [src.holder.owner].")
		usr.playsound_local(usr.loc, "sound/voice/wraith/ghostrespawn.ogg", 50, 0)
		logTheThing("admin", lucky_dude.current, null, "respawned as a plague rat for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a plague rat!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")

/datum/targetable/wraithAbility/speak
	name = "Spirit message"
	desc = "Telepathically speak to your minions."
	icon_state = "thrallspeak"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	proc/ghostify_message(var/message)
		return message


	cast(mob/target)
		if (!holder)
			return 1

		var/mob/wraith/W = holder.owner

		if (!W)
			return 1

		var/message = html_encode(input("What would you like to whisper to your minions?", "Whisper", "") as text)

		if (W.summons.len == 0)
			boutput(W, "You have no minions to talk to.")
			return 1
		for(var/mob/living/critter/C in W.summons)
			logTheThing("say", W, C, "WRAITH WHISPER TO [constructTarget(C,"say")]: [message]")
			message = ghostify_message(trim(copytext(sanitize(message), 1, 255)))
			if (!message)
				return 1
			boutput(C, "<b>A netherworldly voice whispers into your ears... </b> [message]")
			C.playsound_local(C.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		W.playsound_local(W.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
		boutput(usr, "<b>You whisper to your summons:</b> [message]")
		return 0

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
