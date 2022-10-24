/datum/abilityHolder/wraith
	topBarRendered = 1
	pointName = "Wraith Points"
	cast_while_dead = 1
	/// total souls absorbed by this wraith so far
	var/corpsecount = 0
	var/possession_points = 0
	/// number of souls required to evolve into a specialized wraith subclass
	var/absorbs_to_evolve = 3
	onAbilityStat()
		..()
		.= list()
		.["Points:"] = round(src.points)
		.["Gen. rate:"] = round(src.regenRate + src.lastBonus)
		if(istype(owner, /mob/wraith/wraith_trickster) || istype(owner, /mob/living/critter/wraith/trickster_puppet))
			.["Possess:"] = round(src.possession_points)

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
	ignore_holder_lock = 1 //So we can still do things while our summons are coming
	theme = "wraith"
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = null
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
		if (istype(holder.owner, /mob/wraith))
			var/mob/wraith/W = holder.owner
			if (W.forced_manifest == TRUE)
				boutput(W, "<span class='alert'>You have been forced to manifest! You can't use any abilities for now!</span>")
				return 1
		return 0

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder?.updateButtons()

	onAttach(datum/abilityHolder/holder)
		..()
		if (istype(holder.owner, /mob/wraith/wraith_decay) || istype(holder.owner, /mob/living/critter/wraith/plaguerat))
			border_state = "plague_frame"
		else if (istype(holder.owner, /mob/wraith/wraith_harbinger))
			border_state = "harbinger_frame"
		else if (istype(holder.owner, /mob/wraith/wraith_trickster) || istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			border_state = "trickster_frame"

		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

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

	cast(atom/target)
		if (..())
			return 1
		if (!target)
			target = get_turf(holder.owner)

		//Find a suitable corpse
		var/mob/living/carbon/human/H
		if (isturf(target))
			for (var/mob/living/carbon/human/mob_target in target.contents)
				if (!isdead(mob_target))
					continue
				if (H.decomp_stage >= DECOMP_STAGE_SKELETONIZED)
					continue
				H = mob_target
				break
		else if (ishuman(target))
			H = target
			if (!isdead(H))
				boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
				return 1

			//check for formaldehyde. if there's more than the wraith's tol amt, we can't absorb right away.
			var/mob/wraith/W = src.holder.owner
			if (istype(W))
				var/amt = H.reagents.get_reagent_amount("formaldehyde")
				if (amt >= W.formaldehyde_tolerance)
					H.reagents.remove_reagent("formaldehyde", amt)
					boutput(holder.owner, "<span class='alert'>This vessel is tainted with an... unpleasant substance... It is now removed...But you are wounded</span>")
					particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#FFFFFF", 2, locate(H.x, H.y, H.z)))
					holder.owner.TakeDamage(null, 50, 0)
					return 0
		else
			boutput(holder.owner, "<span class='alert'>Absorbing [target] does not satisfy your ethereal taste.</span>")
			return 1
		if (!H)
			return 1 // no valid targets were identified, cast fails

		logTheThing("combat", holder.owner, "absorbs the corpse of [key_name(H)] as a wraith.")
		var/turf/T = get_turf(H)
		// decay wraith receives bonuses for toxin damaged and decayed bodies, but can't absorb fresh kils without toxin damage
		if ((istype(holder.owner, /mob/wraith/wraith_decay)))
			if ((H.get_toxin_damage() >= 60) || (H.decomp_stage == DECOMP_STAGE_HIGHLY_DECAYED))
				boutput(holder.owner, "<span class='alert'>[H] is extremely rotten and bloated. It satisfies us greatly</span>")
				holder.points += 150
				T.fluid_react_single("miasma", 60, airborne = 1)
				H.visible_message("<span class='alert'><strong>[pick("A mysterious force rips [H]'s body apart!", "[H]'s corpse suddenly explodes in a cloud of miasma and guts!")]</strong></span>")
				H.gib()
			else if (!(H.get_toxin_damage() >= 30) && !(H.decomp_stage >= DECOMP_STAGE_BLOATED))
				boutput(holder.owner, "<span class='alert'>This body is too fresh. It needs to be poisoned or rotten before we consume it.</span>")
				return 1
		if (H.loc)//gibbed check
			//Make the corpse all grody and skeleton-y
			H.decomp_stage = DECOMP_STAGE_SKELETONIZED
			if (H.organHolder && H.organHolder.brain)
				qdel(H.organHolder.brain)
			H.set_face_icon_dirty()
			H.set_body_icon_dirty()
			particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(H.x, H.y, H.z)))
			boutput(holder.owner, "<span class='alert'><b>[pick("You draw the essence of death out of [H]'s corpse!", "You drain the last scraps of life out of [H]'s corpse!")]</b></span>")
			H.visible_message("<span class='alert'>[pick("Black smoke rises from [H]'s corpse! Freaky!", "[H]'s corpse suddenly rots to nothing but bone in moments!")]</span>", null, "<span class='alert'>A horrid stench fills the air.</span>")
		playsound(T, "sound/voice/wraith/wraithsoulsucc[rand(1, 2)].ogg", 30, 0)
		holder.regenRate += 2
		var/datum/abilityHolder/wraith/AH = holder
		if (istype(AH))
			var/mob/wraith/W = AH.owner
			if (istype(W))
				W.onAbsorb(H)
			AH.corpsecount++

		return 0


	doCooldown()         //This makes it so wraith early game is much faster but hits a wall of high absorb cooldowns after ~5 corpses
		if (!holder)	 //so wraiths don't hit scientific notation rates of regen without playing perfectly for a million years
			return
		var/datum/abilityHolder/wraith/W = holder
		if (istype(W))
			if (W.corpsecount == 0)
				cooldown = 45 SECONDS
			else
				cooldown += W.corpsecount * 150
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN(cooldown + 5)
			holder?.updateButtons()


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
		usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithpossesobject.ogg', 50, 0)
		var/mob/living/object/O = new/mob/living/object(get_turf(target), target, holder.owner)
		SPAWN(45 SECONDS)
			if (O)
				boutput(O, "<span class='alert'>You feel your control of this vessel slipping away!</span>")
		SPAWN(60 SECONDS) //time limit on possession: 1 minute
			if (O)
				boutput(O, "<span class='alert'><strong>Your control is wrested away! The item is no longer yours.</strong></span>")
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithleaveobject.ogg', 50, 0)
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
				if (isdead(target) && target:decomp_stage != DECOMP_STAGE_SKELETONIZED)
					T = target
					break

		if (ishuman(T))
			var/mob/wraith/W = holder.owner
			. = W.makeRevenant(T)		//return 0
			if(!.)
				playsound(W.loc, 'sound/voice/wraith/reventer.ogg', 80, 0)
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
			return TRUE

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
				return TRUE
			else
				boutput(usr, "<span class='notice'>[pick("You sap [T]'s energy.", "You suck the breath out of [T].")]</span>")
				boutput(T, "<span class='alert'>You feel really tired all of a sudden!</span>")
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithstaminadrain.ogg', 75, 0)
				H.emote("pale")
				H.remove_stamina( rand(100, 120) )//might be nice if decay was useful.
				H.changeStatus("stunned", 4 SECONDS)
				return FALSE
		else if (isobj(T))
			var/obj/O = T
			if(istype(O, /obj/machinery/computer/shuttle))
				boutput(usr, "<span class='alert'>You cannot seem to alter the energy of [O].</span>" )
				return TRUE
			// go to jail, do not pass src, do not collect pushed messages
			if (O.emag_act(null, null))
				boutput(usr, "<span class='notice'>You alter the energy of [O].</span>")
				return FALSE
			else
				boutput(usr, "<span class='alert'>You fail to alter the energy of the [O].</span>")
				return TRUE
		else
			boutput(usr, "<span class='alert'>There is nothing to decay here!</span>")
			return FALSE

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
	desc = "Raise a skeletonized dead body or fill a locker with an indurable skeletal servant."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 1 MINUTE

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T)
				if (isdead(target) && target.decomp_stage == DECOMP_STAGE_SKELETONIZED)
					T = target
					break
			//Or a locker
			for (var/obj/storage/closet/target in T)
				T = target
				break
			//Or a secure locker
			for (var/obj/storage/secure/closet/target in T)
				T = target
				break

		if (ishuman(T))
			var/mob/living/carbon/human/H = T
			if (!isdead(H) || H.decomp_stage != DECOMP_STAGE_SKELETONIZED)
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
			if (istype(T, /obj/storage/closet) || istype(T, /obj/storage/secure/closet))
				var/obj/storage/C = T
				for (var/obj/critter/wraithskeleton/S in C)
					boutput(holder.owner, "That container is already rattling, you can't summon a skeleton in there!")
					return 1
				if (C.open)
					C.close()
				var/obj/critter/wraithskeleton/S = new /obj/critter/wraithskeleton(C)
				S.name = "Locker skeleton"
				S.health = 20
				S.icon = 'icons/misc/critter.dmi'
				S.icon_state = "skeleton"
				usr.playsound_local(usr.loc, "sound/voice/wraith/wraithraise[rand(1, 3)].ogg", 80, 0)
				return 0
			else
				boutput(usr, "<span class='alert'>You can't summon a skeleton there!</span>")
				return 1
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
			usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithlivingobject.ogg', 50, 0)
			return 0
		else
			boutput(usr, "<span class='alert'>There is no object here to animate!</span>")
			return 1

/datum/targetable/wraithAbility/haunt
	name = "Haunt"
	icon_state = "haunt"
	desc = "Become corporeal for 30 seconds. During this time, you gain additional biopoints, depending on the amount of humans in your vicinity. Use this ability again while corporeal to fade back into the aether."
	targeted = 0
	pointCost = 0
	cooldown = 30 SECONDS
	min_req_dist = INFINITY
	start_on_cooldown = 1

	cast()
		if (..())
			return 1

		if(istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			var/mob/living/critter/wraith/trickster_puppet/P = holder.owner
			P.demanifest()
			return 0

		var/mob/wraith/K = src.holder.owner
		if (!K.forced_manifest && K.hasStatus("corporeal"))
			boutput(holder.owner, "We fade back into the shadows")
			cooldown = 0 SECONDS
			return K.delStatus("corporeal")
		else
			boutput(holder.owner, "We show ourselves")
			var/mob/wraith/W = holder.owner

			cooldown = 30 SECONDS

			if ((istype(W, /mob/wraith/wraith_trickster)))	//Trickster can appear as a human, living or dead.
				var/mob/wraith/wraith_trickster/T = holder.owner
				if (T.copied_appearance != null)
					var/mob/living/critter/wraith/trickster_puppet/puppet = new /mob/living/critter/wraith/trickster_puppet(get_turf(T), T)
					T.mind.transfer_to(puppet)
					puppet.appearance = T.copied_appearance
					puppet.desc = T.copied_desc
					puppet.traps_laid = T.traps_laid
					puppet.playsound_local(puppet.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
					puppet.alpha = 0
					animate(puppet, alpha=255, time=2 SECONDS)
					puppet.flags &= UNCRUSHABLE
					T.set_loc(puppet)
					return 0

			//check done in case a poltergeist uses this from within their master.
			if (iswraith(W.loc))
				boutput(W, "You can't become corporeal while inside another wraith! How would that even work?!")
				return 1
			if (W.hasStatus("corporeal"))
				return 1
			else
				W.setStatus("corporeal", INFINITE_STATUS)
				usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
			return 0


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
				logTheThing(LOG_SAY, usr, "WRAITH WHISPER TO [constructTarget(target,"say")]: [message]")
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
	pointCost = 2
	cooldown = 1 SECONDS
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
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentagram","Skull")

		var/t = input(user, "What do you want to write?", null, null) as null|anything in (c_default + c_symbol)

		if (!t)
			src.in_use = 0
			return 1
		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing(LOG_STATION, user, "writes on [T] with [src] [log_loc(T)]: [t]")
		G.icon_state = t
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 0)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

/datum/targetable/wraithAbility/make_poltergeist
	name = "Make Poltergeist"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 600
	cooldown = 5 MINUTES
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
			src.doCooldown()
			make_poltergeist(holder.owner, T)
			return 0
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
		usr.playsound_local(usr.loc, 'sound/voice/wraith/wraithportal.ogg', 50, 0)
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing(LOG_ADMIN, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
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
		usr.playsound_local(usr.loc, 'sound/voice/wraith/ghostrespawn.ogg', 50, 0)
		logTheThing(LOG_ADMIN, lucky_dude.current, "respawned as a poltergeist for [src.holder.owner].")
		boutput(P, "<span class='notice'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")

/datum/targetable/wraithAbility/specialize
	name = "Evolve"
	icon_state = "evolve"
	desc = "Choose a form to evolve into once you have absorbed at least 3 souls"
	targeted = 0
	pointCost = 150
	tooltip_flags = TOOLTIP_LEFT
	special_screen_loc = "NORTH-1,EAST"
	var/static/list/paths = list("Rot" = 1, "Summoner" = 2, "Trickster" = 3)
	var/list/paths_buttons = list()


	New()
		if (istype(ticker.mode, /datum/game_mode/disaster)) //For Disaster wraith
			desc = "Choose a form to evolve into using the power of the void"

		..()

		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i in 1 to 3)
			var/datum/contextAction/wraith_evolve_button/newcontext = new /datum/contextAction/wraith_evolve_button(i)
			object.contextActions += newcontext

	cast()
		if (..())
			return 1

	proc/evolve(var/effect as text)
		var/datum/abilityHolder/wraith/AH = holder
		if (AH.corpsecount < AH.absorbs_to_evolve && !istype(ticker.mode, /datum/game_mode/disaster))
			boutput(holder.owner, "<span class='notice'>You didn't absorb enough souls. You need to absorb at least [AH.absorbs_to_evolve - AH.corpsecount] more!</span>")
			return 1
		if (holder.points < pointCost)
			boutput(holder.owner, "<span class='notice'>You do not have enough points to cast this. You need at least [pointCost] points.</span>")
			return 1
		else
			var/mob/wraith/W
			switch (effect)
				if (1)
					W = new/mob/wraith/wraith_decay(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a plaguebringer! Spread rot and disease all around!</span>")
					holder.owner.show_antag_popup("plaguebringer")
				if (2)
					W = new/mob/wraith/wraith_harbinger(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a harbinger! Command your army of minions to bring ruin to the station!</span>")
					holder.owner.show_antag_popup("harbinger")
				if (3)
					W = new/mob/wraith/wraith_trickster(holder.owner)
					boutput(holder.owner, "<span class='notice'>You use some of your energy to evolve into a trickster! Decieve the crew and turn them against one another!</span>")
					holder.owner.show_antag_popup("trickster")

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
ABSTRACT_TYPE(/datum/targetable/wraithAbility/curse)
/datum/targetable/wraithAbility/curse
	name = "Base curse"
	icon_state = "skeleton"
	desc = "This should never be seen."
	targeted = 1
	pointCost = 30
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())

			return 1

		if (ishuman(target))
			if (istype(get_area(target), /area/station/chapel))	//Dont spam curses in the chapel.
				boutput(holder.owner, "<span class='alert'>The holy ground this creature is standing on repels the curse immediatly.</span>")
				boutput(target, "<span class='alert'>You feel as though some weight was added to your soul, but the feeling immediatly dissipates.</span>")
				return 0

			//Lets let people know they have been cursed, might not be obvious at first glance
			var/mob/living/carbon/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>A strange force prevents you from cursing this being, your energy is wasted.</span>")
				return 0
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
				if (1)
					boutput(H, "<span class='notice'>You feel strangely sick.</span>")
				if (2)
					boutput(H, "<span class='alert'>You hear whispers in your head, pushing you towards your doom.</span>")
					H.playsound_local(H.loc, "sound/voice/wraith/wraithstaminadrain.ogg", 50)
				if (3)
					boutput(H, "<span class='alert'><b>A cacophony of otherworldly voices resonates within your mind. You sense a feeling of impending doom! You should seek salvation in the chapel or the purification of holy water.</b></span>")
					H.playsound_local(H.loc, "sound/voice/wraith/wraithraise1.ogg", 80)

/datum/targetable/wraithAbility/curse/blood
	name = "Curse of blood"
	icon_state = "bloodcurse"
	desc = "Curse the living with a plague of blood."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("blood_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("blood_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a blood dripping curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/blindness
	name = "Curse of blindness"
	icon_state = "blindcurse"
	desc = "Curse the living with blindness."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("blind_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("blind_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a blinding curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/enfeeble
	name = "Curse of weakness"
	icon_state = "weakcurse"
	desc = "Curse the living with weakness and lower stamina regeneration."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.bioHolder.HasEffect("weak_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("weak_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with an enfeebling curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/rot)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/rot
	name = "Curse of rot"
	icon_state = "rotcurse"
	desc = "Curse the living with a netherworldly plague."
	targeted = 1
	pointCost = 40
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H= target
			if(H.bioHolder.HasEffect("rot_curse"))
				boutput(holder.owner, "That curse is already applied to this being...")
				return 1
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.bioHolder.AddEffect("rot_curse")
			boutput(holder.owner, "<span class='notice'>We curse this being with a decaying curse.</span>")
			var/datum/targetable/ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blood)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/blindness)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/enfeeble)
			ability.doCooldown()
			ability = holder.getAbility(/datum/targetable/wraithAbility/curse/death)
			ability.doCooldown()
			return 0
		else
			return 1

/datum/targetable/wraithAbility/curse/death	//Only castable if you already put 4 curses on someone
	name = "Curse of death"
	icon_state = "deathcurse"
	desc = "Reap a fully cursed being's soul!"
	targeted = 1
	pointCost = 80
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/wraith/W = holder.owner
			if (H?.bioHolder.HasEffect("rot_curse") && H?.bioHolder.HasEffect("weak_curse") && H?.bioHolder.HasEffect("blind_curse") && H?.bioHolder.HasEffect("blood_curse"))
				W.playsound_local(W.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
				boutput(holder.owner, "<span class='alert'>That soul is OURS!!</span>")
				boutput(H, "<span class='alert'>The voices in your heads are reaching a crescendo!</span>")
				H.make_jittery(300)
				SPAWN(4 SECOND)
					if (!(H?.loc && W?.loc)) return
					H.changeStatus("stunned", 2 SECONDS)
					H.emote("scream")
					boutput(H, "<span class='alert'>You feel netherworldly hands grasping you!</span>")
					sleep(3 SECOND)
					if (!(H?.loc && W?.loc)) return
					random_brute_damage(H, 10)
					playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
					H.visible_message("<span class='alert'>[H]'s flesh tears open before your very eyes!!</span>")
					new /obj/decal/cleanable/blood/drip(get_turf(H))
					sleep(3 SECOND)
					if (!(H?.loc && W?.loc)) return
					random_brute_damage(H, 10)
					playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
					new /obj/decal/cleanable/blood/drip(get_turf(H))
					sleep(1 SECOND)
					if (!(H?.loc && W?.loc)) return
					random_brute_damage(H, 20)
					playsound(H.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 70, 1)
					new /obj/decal/cleanable/blood/drip(get_turf(H))
					sleep(2 SECOND)
					if (!(H?.loc && W?.loc)) return
					boutput(H, "<span class='alert'>IT'S COMING FOR YOU!</span>")
					H.remove_stamina( rand(100, 120) )
					H.changeStatus("stunned", 4 SECONDS)
					sleep(3 SECOND)
					if (!(H?.loc && W?.loc)) return
					var/turf/T = get_turf(H)
					var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
					if (S)
						S.set_up(8, 0, T, null, "#000000")
						S.start()
					H.gib()
					boutput(holder.owner, "<span class='alert'>What delicious agony!</span>")
					T.fluid_react_single("miasma", 60, airborne = 1)
					holder.points += 100
					holder.regenRate += 2.0
					var/datum/abilityHolder/wraith/AH = holder
					AH.corpsecount++
			else
				boutput(holder.owner, "That being's soul is not weakened enough. We need to curse it some more.")
				return 1


/datum/targetable/wraithAbility/summon_rot_hulk
	name = "Create rot hulk"
	desc = "Assimilate the filth in an area and create an unstable servant."
	icon_state = "summongoo"
	targeted = 0
	cooldown = 90 SECONDS
	pointCost = 120
	var/const/max_decals = 40
	var/const/min_decals = 10
	var/const/strong_exploder_threshold = 20
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
		for (var/obj/decal/cleanable/found_cleanable in range(3, get_turf(holder.owner)))
			if (istypes(found_cleanable, decal_list))
				found_decal_list += found_cleanable
				if (length(found_decal_list) >= max_decals)
					break
		if (length(found_decal_list) > min_decals)
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithraise[pick("1","2","3")].ogg", 80)
			var/turf/T = get_turf(holder.owner)
			T.visible_message("<span class='alert'>All the filth and grime around begins to writhe and move!</span>")
			SPAWN(0)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(2 SECOND)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(1.5 SECOND)
				for(var/obj/decal/cleanable/C in found_decal_list)
					if (!C?.loc) continue
					step_towards(C,T)
				sleep(1 SECOND)
				if (decal_count >= strong_exploder_threshold)
					var/mob/living/critter/exploder/strong/E = new /mob/living/critter/exploder/strong(T)
					animate_portal_tele(E)
					T.visible_message("<span class='alert'>A [E] slowly emerges from the gigantic pile of grime!</span>")
					boutput(holder.owner, "The great amount of filth coalesces into a rotting goliath")
				else
					var/mob/living/critter/exploder/E = new /mob/living/critter/exploder(T)
					animate_portal_tele(E)
					T.visible_message("<span class='alert'>A [E] slowly rises up from the coalesced filth!</span>")
					boutput(holder.owner, "The filth accumulates into a living bloated abomination")
				for(var/obj/decal/cleanable/C as anything in found_decal_list)
					qdel(C)
			return 0
		else
			boutput(holder.owner, "<span class='alert'>This place is much too clean to summon a rot hulk.</span>")
			return 1


/datum/targetable/wraithAbility/poison
	name = "Defile"
	desc = "Manifest some horrible poison inside a food item or a container."
	icon_state = "wraithpoison"
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	cooldown = 50 SECONDS
	pointCost = 50
	var/list/the_poison = list("Rat Spit", "Grave Dust", "Cyanide", "Loose Screws", "Rotting", "Bee", "Mucus")
	var/amount_per_poison = 10

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/wraith/W = holder.owner

		if (!W || !target)
			return 1

		if (W == target)
			boutput(W, "<span class='alert'>Why would you want to poison yourself?</span>")
			return 1

		var/obj/item/reagent_containers/current_container = null
		var/attempt_success = 0

		if (istype(target, /obj/item/reagent_containers/food))
			current_container = target
		else
			boutput(W, "<span class='alert'>You can't poison [target], only food items, drinks and glass containers.</span>")
			return 1

		var/poison_name = tgui_input_list(holder.owner, "Select the target poison: ", "Target Poison", the_poison)
		if(!poison_name)
			return 1

		var/poison_id = null
		switch(poison_name)
			if ("Rat Spit")
				poison_id = "rat_spit"
			if ("Grave Dust")
				poison_id = "grave dust"
			if ("Cyanide")
				poison_id = "cyanide"
			if ("Loose Screws")
				poison_id = "loose_screws"
			if ("Rotting")
				poison_id = "rotting"
			if ("Bee")
				poison_id = "bee"
			if ("Mucus")
				poison_id = "mucus"
			else
				return 1


		if (current_container && istype(current_container))
			if (length(src.the_poison) > 1)
				if (!current_container.reagents)
					current_container.reagents = new /datum/reagents(src.amount_per_poison)
					current_container.reagents.my_atom = current_container

				if (current_container.reagents)
					if (current_container.reagents.total_volume + src.amount_per_poison >= current_container.reagents.maximum_volume)
						current_container.reagents.remove_any(current_container.reagents.total_volume + src.amount_per_poison - current_container.reagents.maximum_volume)
					current_container.reagents.add_reagent(poison_id, src.amount_per_poison)


					attempt_success = 1
				else
					attempt_success = 0
			else
				attempt_success = 0
		else
			attempt_success = 0

		if (attempt_success == 1)
			boutput(W, "<span class='notice'>You successfully poisoned [target].</span>")
			logTheThing("combat", W, null, "poisons [target] [log_reagents(target)] at [log_loc(W)].")
			return 0
		else
			boutput(W, "<span class='alert'>You failed to poison [target].</span>")
			return 1


/datum/targetable/wraithAbility/mass_whisper
	name = "Mass Whisper"
	icon_state = "mass_whisper"
	desc = "Send an ethereal message to all close living beings."
	pointCost = 5
	targeted = 0
	cooldown = 10 SECONDS
	proc/ghostify_message(var/message)
		return message

	cast()
		if (..())
			return 1

		var/message = input("What would you like to whisper to everyone?", "Whisper", "") as text|null
		message = ghostify_message(copytext(html_encode(message), 1, MAX_MESSAGE_LEN))
		if (!message)
			return 1
		for_by_tcl(H, /mob/living/carbon/human)
			if (!IN_RANGE(holder.owner, H, 8)) continue
			if (isdead(H)) continue
			logTheThing("say", holder.owner, H, "WRAITH WHISPER TO [key_name(H)]: [message]")
			boutput(H, "<b>A netherworldly voice whispers into your ears... </b> [message]")
			holder.owner.playsound_local(holder.owner.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)
			H.playsound_local(H.loc, "sound/voice/wraith/wraithwhisper[rand(1, 4)].ogg", 65, 0)

		boutput(holder.owner, "<b>You whisper to everyone around you:</b> [message]")


/datum/targetable/wraithAbility/dread
	name = "Creeping dread"
	icon_state = "dread"
	desc = "Instill a fear of the dark in a human's mind, causing terror and heart attacks if they do not stay in the light."
	pointCost = 80
	targeted = 1
	cooldown = 1 MINUTE

	cast(mob/target)
		if (..())
			return 1

		if (ishuman(target) && !isdead(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>This one does not fear what lurks in the dark. Your effort is wasted.</span>")
				return 0
			boutput(holder.owner, "<span class='notice'>We curse this being with a creeping feeling of dread.</span>")
			H.setStatus("creeping_dread", 20 SECONDS)
			holder.owner.playsound_local(holder.owner, "sound/voice/wraith/wraithspook[pick("1","2")].ogg", 60)
			return 0

		return 1

/datum/targetable/wraithAbility/possess
	name = "Possession"
	icon_state = "possession"
	desc = "Channel your energy and slowly gain control over a living being."
	pointCost = 400
	targeted = 1
	cooldown = 3 MINUTES
	ignore_holder_lock = 0
	var/wraith_key = null

	cast(mob/target)
		if (..())
			return 1
		if (istype(holder.owner, /mob/wraith/wraith_trickster))
			var/datum/abilityHolder/wraith/AH = holder
			var/mob/wraith/wraith_trickster/W = holder.owner
			if (AH.possession_points > W.points_to_possess)
				if (ishuman(target) && !isdead(target))
					var/mob/living/carbon/human/H = target
					if (H.traitHolder.hasTrait("training_chaplain"))
						boutput(holder.owner, "<span class='alert'>As you try to reach inside this creature's mind, it instantly kicks you back into the aether!</span>")
						return 0
					var/has_mind = false
					var/mob/dead/target_observer/slasher_ghost/WG = null
					wraith_key = holder.owner.ckey
					H.emote("scream")
					boutput(H, "<span class='alert'>You are feeling awfully woozy.</span>")
					H.change_misstep_chance(20)
					SPAWN(10 SECONDS)
						if (!(H?.loc && W?.loc)) return
						boutput(H, "<span class='alert'>You hear a cacophony of otherwordly voices in your head.</span>")
						H.emote("faint")
						H.setStatusMin("weakened", 5 SECONDS)
						sleep(15 SECONDS)
						if (!(H?.loc && W?.loc)) return
						H.change_misstep_chance(-20)
						H.emote("scream")
						H.setStatusMin("weakened", 8 SECONDS)
						H.setStatusMin("paralysis", 8 SECONDS)
						sleep(8 SECONDS)
						if (!(H?.loc && W?.loc)) return
						var/mob/dead/observer/O = H.ghostize()
						if(W.mind == null)	//Wraith died or was removed in the meantime
							return
						if (O?.mind)
							boutput(O, "<span class='bold' style='color:red;font-size:150%'>You have been temporarily removed from your body!</span>")
							WG = O.insert_slasher_observer(H)
							WG.mind.dnr = TRUE
							WG.verbs -= list(/mob/verb/setdnr)
							has_mind = true
						W.mind.transfer_to(H)
						APPLY_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)	//Subject to change.
						sleep(45 SECONDS)
						if (!H?.loc) return
						boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your control on this body is weakening, you will soon be kicked out of it.</span>")
						sleep(20 SECONDS)
						if (!H?.loc) return
						boutput(H, "<span class='bold' style='color:red;font-size:150%'>Your hold on this body has been broken! You return to the aether.</span>")
						REMOVE_ATOM_PROPERTY(H, PROP_MOB_NO_SELF_HARM, H)
						if(!H?.loc) //H gibbed
							var/mob/M2 = ckey_to_mob(wraith_key)
							M2.mind.transfer_to(W)
						if(!W.loc) //wraith got gibbed
							return
						H.mind.transfer_to(W)
						if (has_mind)
							WG.mind.dnr = FALSE
							WG.verbs += list(/mob/verb/setdnr)
							WG.mind.transfer_to(H)
							playsound(H, 'sound/effects/ghost2.ogg', 50, 0)
						AH.possession_points = 0
						logTheThing("debug", null, null, "step 5")
						qdel(WG)
						H.take_brain_damage(30)
						H.setStatus("weakened", 5 SECOND)
						boutput(H, "The presence has left your body and you are thrusted back into it, immediately assaulted with a ringing headache.")
					return FALSE
			else
				boutput(holder.owner, "You cannot possess with only [AH.possession_points] possession power. You'll need at least [(W.points_to_possess - AH.possession_points)] more.")
				return 1

/datum/targetable/wraithAbility/hallucinate
	name = "Hallucinate"
	icon_state = "terror"
	desc = "Induce terror inside a mortal's mind and make them hallucinate."
	pointCost = 30
	targeted = 1
	cooldown = 45 SECONDS

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span class='notice'>Despite your best efforts, that creature seems totally unnaffected by your horrific visions.</span>")
			usr.playsound_local(usr.loc, "sound/voice/wraith/wraithspook[rand(1, 2)].ogg", 80, 0)
			H.setStatus("terror", 45 SECONDS)
			boutput(holder.owner, "We terrorize [H]")
			return 0
		else
			return 1

/datum/targetable/wraithAbility/fake_sound
	name = "Fake sound"
	icon_state = "fake_sound"
	desc = "Play a fake sound at a location of your choice"
	pointCost = 5
	targeted = 1
	target_anything = 1
	cooldown = 4 SECONDS
	var/list/sound_list = list("Death gasp",
	"Gasp",
	"Gunshot",
	"AK477",
	"Csaber unsheathe",
	"Csaber attack",
	"Shotgun",
	"Energy sniper",
	"Cluwne",
	"Chainsaw",
	"Stab",
	"Bones breaking",
	"Vampire screech",
	"Brullbar",
	"Werewolf",
	"Gibs")

	cast(atom/target)
		if (..())
			return 1

		var/sound_choice = null
		if (length(src.sound_list) > 1)
			sound_choice = tgui_input_list(holder.owner, "What sound do you wish to play?", "Chosen sound", sound_list)
		switch(sound_choice)
			if("Death gasp")
				sound_choice = "sound/voice/death_[rand(1, 2)].ogg"
			if("Revolver")
				sound_choice = "sound/weapons/Gunshot.ogg"
			if("AK477")
				sound_choice = "sound/weapons/ak47shot.ogg"
				playsound(target, sound_choice, 70, 0)
				sleep(2 DECI SECONDS)
				playsound(target, sound_choice, 70, 0)
				sleep(2 DECI SECONDS)
				playsound(target, sound_choice, 70, 0)
				boutput(holder.owner, "You use your powers to create a sound.")
				return 0
			if("Csaber unsheathe")
				sound_choice = "sound/weapons/male_cswordstart.ogg"
			if("Csaber attack")
				sound_choice = "sound/weapons/male_cswordattack[rand(1, 2)].ogg"
			if("Shotgun")
				sound_choice = "sound/weapons/shotgunshot.ogg"
			if("Energy sniper")
				sound_choice = "sound/weapons/snipershot.ogg"
			if("Cluwne")
				sound_choice = "sound/voice/cluwnelaugh[rand(1, 3)].ogg"
			if("Gasp")
				sound_choice = pick("sound/voice/gasps/male_gasp_[pick("1", "5")].ogg", "sound/voice/gasps/female_gasp_[pick("1", "5")].ogg")
			if("Chainsaw")
				sound_choice = "sound/machines/chainsaw_red.ogg"
			if("Stab")
				sound_choice = "sound/impact_sounds/Blade_Small_Bloody.ogg"
			if("Bones breaking")
				sound_choice = "sound/effects/bones_break.ogg"
			if("Vampire screech")
				sound_choice = "sound/effects/light_breaker.ogg"
			if("Brullbar")
				sound_choice = "sound/voice/animal/brullbar_scream.ogg"
			if("Werewolf")
				sound_choice = "sound/voice/animal/werewolf_howl.ogg"
			if("Gibs")
				sound_choice = "sound/impact_sounds/Flesh_Break_2.ogg"

		playsound(target, sound_choice, 70, 0)
		boutput(holder.owner, "You use your powers to create a sound.")
		return 0

/datum/targetable/wraithAbility/lay_trap
	name = "Place rune trap"
	icon_state = "runetrap"
	desc = "Create a rune trap which stays invisible in the dark and can be sprung by people."
	pointCost = 50
	targeted = 0
	cooldown = 30 SECONDS
	var/max_traps = 7
	var/list/trap_types = list("Madness",
	"Burning",
	"Teleporting",
	"Illusions",
	"EMP",
	"Blinding",
	"Sleepyness")

	cast()
		if (..())
			return 1

		if (!istype(holder.owner, /mob/wraith/wraith_trickster) && !istype(holder.owner, /mob/living/critter/wraith/trickster_puppet))
			boutput(holder.owner, "<span class='notice'>You cannot cast this under your current form.</span>")
			return 1

		var/mob/wraith/wraith_trickster/W = null
		var/mob/living/critter/wraith/trickster_puppet/P = null
		if(istype(holder.owner, /mob/wraith/wraith_trickster))
			W = holder.owner
			if (!W.haunting)
				boutput(holder.owner, "<span class='notice'>You must be manifested to place a trap!</span>")
				return 1
		else
			P = holder.owner
		var/trap_choice = null
		var/turf/T = get_turf(holder.owner)
		if (!isturf(T) || !istype(T,/turf/simulated/floor))
			boutput(holder.owner, "<span class='notice'>You cannot open a trap here.</span>")
			return 1
		for (var/obj/machinery/wraith/runetrap/R in range(T, 3))
			boutput(holder.owner, "<span class='notice'>That is too close to another trap.</span>")
			return 1
		if ((W != null && W.traps_laid >= max_traps) || (P != null && P.traps_laid >= max_traps))
			boutput(holder.owner, "<span class='notice'>You already have too many traps!</span>")
			return 1
		if (length(src.trap_types) > 1)
			trap_choice = input("What type of trap do you want?", "Target trap type", null) as null|anything in trap_types
		if(trap_choice == null)
			return 1
		switch(trap_choice)
			if("Madness")
				trap_choice = /obj/machinery/wraith/runetrap/madness
			if("Burning")
				trap_choice = /obj/machinery/wraith/runetrap/fire
			if("Teleporting")
				trap_choice = /obj/machinery/wraith/runetrap/teleport
			if("Illusions")
				trap_choice = /obj/machinery/wraith/runetrap/terror
			if("EMP")
				trap_choice = /obj/machinery/wraith/runetrap/emp
			if("Blinding")
				trap_choice = /obj/machinery/wraith/runetrap/stunning
			if("Sleepyness")
				trap_choice = /obj/machinery/wraith/runetrap/sleepyness
			if("Slipperiness")
				trap_choice = /obj/machinery/wraith/runetrap/slipping

		if(P != null)
			new trap_choice(T, P.master)
			P.master.traps_laid++
			P.traps_laid++
		else
			new trap_choice(T, W)
			W.traps_laid++
		boutput(holder.owner, "You place a trap on the floor, it begins to charge up.")
		return 0

/datum/targetable/wraithAbility/create_summon_portal
	name = "Summon void portal"
	icon_state = "open_portal"
	desc = "Summon a void portal from which otherworldly creatures pour out. You get increased point generation when near it."
	pointCost = 150
	targeted = 0
	cooldown = 3 MINUTES
	var/list/mob_types = list("Bears",
	"Brullbars",
	"Crunched",
	"Ancient things",
	"Ancient repairbots",
	"Heavy gunner drones",
	"Monstrosity crawlers",
	"Bats",
	"Shades",
	"Lions",
	"Skeletons",
	"Random")

	cast()
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && istype(T,/turf/simulated/floor))
			if(istype(holder.owner, /mob/wraith))
				var/mob/wraith/W = holder.owner
				if (!W.density)
					boutput(holder.owner, "Your connection to the physical plane is too weak. You must be manifested to do this.")
					return 1
				if (W.linked_portal)
					if (alert(holder.owner, "You already have a portal. Do you want to destroy the old one?", "Confirmation", "Yes", "No") == "Yes")
						W.linked_portal.deleteLinkedCritters()
						qdel(W.linked_portal)
						W.linked_portal = null
					else
						return 1
				var/mob_choice = null
				if (length(src.mob_types) > 1)
					mob_choice = tgui_input_list(holder.owner, "What should the portal spawn?", "Target Mob Type", mob_types)
				if (mob_choice == null)
					return 1
				switch(mob_choice)
					if("Crunched")
						mob_choice = /obj/critter/crunched
					if("Ancient things")
						mob_choice = /obj/critter/ancient_thing
					if("Ancient repairbots")
						mob_choice = /obj/critter/ancient_repairbot/security
					if("Monstrosity crawlers")
						mob_choice = /obj/critter/mechmonstrositycrawler
					if("Shades")
						mob_choice = /obj/critter/shade
					if("Bats")
						mob_choice = /obj/critter/bat/buff
					if("Lions")
						mob_choice = /obj/critter/lion
					if("Skeletons")
						mob_choice = /obj/critter/wraithskeleton
					if("Bears")
						mob_choice = /obj/critter/bear
					if("Brullbars")
						mob_choice = /obj/critter/brullbar
					if("Heavy gunner drones")
						mob_choice = /obj/critter/gunbot/heavy
					if("Random")
						mob_choice = null
				boutput(holder.owner, "You gather your energy and open a portal")
				var/obj/machinery/wraith/vortex_wraith/V = new /obj/machinery/wraith/vortex_wraith(mob_choice)
				if(mob_choice != null)
					V.random_mode = false
				V.set_loc(W.loc)
				V.master = W
				V.alpha = 0
				animate(V, alpha=255, time = 1 SECONDS)
				W.linked_portal = V
				return 0
		else
			boutput(holder.owner, "We cannot open a portal here")
			return 1

/datum/targetable/wraithAbility/choose_haunt_appearance
	name = "Choose haunt appearance"
	icon_state = "choose_appearance"
	targeted = 1
	pointCost = 0

	cast(atom/target)
		if (..())
			return 1

		if(istype(holder.owner, /mob/wraith/wraith_trickster))
			var/mob/wraith/wraith_trickster/W = holder.owner
			if ((istype(target, /mob/living/carbon/human/)))
				boutput(holder.owner, "We steal [target]'s appearance for ourselves.")
				W.copied_appearance = target.appearance
				W.copied_appearance.transform.Turn(target.rest_mult * -90)	//Find a way to make transform rotate.
				W.copied_desc = target.get_desc()
				return 0
			else if (W.copied_appearance != null)
				W.copied_appearance = null
				W.copied_desc = null
				boutput(holder.owner, "We discard our disguise.")
			else
				boutput(holder.owner, "We cannot copy this appearance.")
		return 1

/datum/targetable/wraithAbility/harbinger_summon
	name = "Summon void creature"
	desc = "Attempt to breach the veil between worlds to allow a lesser void creature to enter this realm."
	icon_state = "summon_creature"
	targeted = 0
	pointCost = 400
	cooldown = 150 SECONDS
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
			src.doCooldown()
			make_summon(holder.owner, T)
			return 0
		else
			boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
			return 1

	proc/make_summon(var/mob/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return

		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a harbinger's summon? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a harbinger's summon. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
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
		var/mob/living/critter/wraith/nascent/P = new /mob/living/critter/wraith/nascent(T, W)
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
		qdel(marker)

/datum/targetable/wraithAbility/make_plague_rat
	name = "Summon Plague rat"
	desc = "Attempt to breach the veil between worlds to allow a plague rat to enter this realm."
	icon_state = "summonrats"
	targeted = 0
	pointCost = 0
	cooldown = 300 SECONDS
	start_on_cooldown = 1
	ignore_holder_lock = 0
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS
	var/max_allowed_rats = 3
	var/player_count = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/total_plague_rats = 0
		for (var/client/C in clients)
			LAGCHECK(LAG_LOW)
			if (!C.mob)
				continue
			player_count++
			var/mob/M = C.mob
			if (istype(M, /mob/living/critter/wraith/plaguerat))
				total_plague_rats++
		if(total_plague_rats < (max_allowed_rats + (player_count / 30)))	//Population scaling
			if (istype(holder.owner, /mob/living/critter/wraith/plaguerat))	//plaguerats must be near their den
				var/near_den = false
				var/turf/T = get_turf(holder.owner)
				for (var/obj/O in T.contents)
					if(istype(O, /obj/machinery/wraith/rat_den))
						near_den = true
				if(!near_den)
					boutput(holder.owner, "We arent close enough to a rat den to do this.")
					return 1
			var/turf/T = get_turf(holder.owner)
			if (isturf(T) && !istype(T, /turf/space))
				boutput(holder.owner, "You begin to channel power to summon a plague rat into this realm, you won't be able to cast any other spells for the next 30 seconds!")
				src.doCooldown()
				make_plague_rat(holder.owner, T)
				return 0
			else
				boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
				return 1
		else
			boutput(holder.owner, "<span class='alert'>This [station_or_ship()] is already a rat den, you cannot summon another rat!</span>")
			return 1

	proc/make_plague_rat(var/mob/W, var/turf/T, var/tries = 0)
		if (!istype(W, /mob/wraith/wraith_decay) && !istype(W, /mob/living/critter/wraith/plaguerat))
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

		//add plague rat to master's list is done in /mob/living/critter/wraith/plaguerat/New
		var/mob/living/critter/wraith/plaguerat/young/P = new /mob/living/critter/wraith/plaguerat/young(T, W)
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
		P.show_antag_popup("plaguerat")
		boutput(P, "<span class='notice'><b>You have been respawned as a plague rat!</b></span>")
		boutput(P, "[W] is your master! Eat filth, spread disease and reproduce!")
		boutput(P, "Obey your master's orders, avoid mouse traps and live the rat life!")
		qdel(marker)

/datum/targetable/wraithAbility/speak
	name = "Spirit message"
	desc = "Telepathically speak to your minions."
	icon_state = "speak_summons"
	targeted = 0
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0

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
			message = trim(copytext(sanitize(message), 1, 255))
			if (!message)
				return 1
			boutput(C, "<b>Your master's voice resonates in your head... </b> [message]")
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
