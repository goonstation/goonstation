/// Our datum that keeps track of an individual status effect.
/datum/statusEffect

	/// Unique ID of the status effect
	var/id = ""
	/// Tooltip name to display
	var/name = ""
	/// Icon state to display.
	var/icon_state = ""
	/// Tooltip desc
	var/desc = ""
	/// In deciseconds (tenths of a second, same as ticks just sane). A duration of NULL is infinite. (This is distinct from 0)
	var/duration = 0
	/// Owner of the status effect
	var/atom/owner = null
	var/archivedOwnerInfo = ""
	/// If true, this status effect can only have one instance on any given object.
	var/unique = 1
	/// Is this visible in the status effect bar?
	var/visible = 1
	/// optional name of a group of buffs. players can only have a certain number of buffs of a given group - any new applications fail. useful for food buffs etc.
	var/exclusiveGroup = ""
	/// If non-null, duration of the effect will be clamped to be max. this amount.
	var/maxDuration = null
	/// has an on-move effect
	var/move_triggered = 0
	/// Has a movement-modifying effect
	var/datum/movement_modifier/movement_modifier
	/// Put a label here to track anyone with this effect into this category
	var/track_cat


	/**
		* Used to run a custom check before adding status to an object. For when you want something to be flat out immune or something.
		*
		* * return = 1 allow, 0 = do not allow
		*/
	proc/preCheck(atom/A)
		. = 1

	proc/modify_change(change)
		. = change

	/**
		* Called when the status is added to an object. owner is already set at this point.
		*
		* optional {optional} - arg from setStatus (passed in)
		*/
	proc/onAdd(optional=null)
		SHOULD_CALL_PARENT(TRUE)
		if (movement_modifier && ismob(owner))
			var/mob/mob_owner = owner
			APPLY_MOVEMENT_MODIFIER(mob_owner, movement_modifier, src.type)
		if(src.track_cat && src.owner )
			OTHER_START_TRACKING_CAT(src.owner, src.track_cat)

	/**
		* Called when the status is removed from the object. owner is still set at this point.
		*/
	proc/onRemove()
		SHOULD_CALL_PARENT(TRUE)
		if (movement_modifier && ismob(owner))
			var/mob/mob_owner = owner
			REMOVE_MOVEMENT_MODIFIER(mob_owner, movement_modifier, src.type)
		if(src.track_cat && src.owner)
			OTHER_STOP_TRACKING_CAT(src.owner, src.track_cat)

	/**
		* Called every tick by the status controller.
		*
		* required {timePassed} - the actual time since the last update call.
		*/
	proc/onUpdate(timePassed)
		return

	/**
		* Called when the status is changed using setStatus. Called after duration is updated etc.
		*
		* optional {optional} - arg from setStatus (passed in)
		*/
	proc/onChange(optional=null)
		return

	/**
		* Called by hasStatus. Used to handle additional checks with the optional arg in that proc.
		*/
	proc/onCheck(optional=null)
		. = 1

	/**
		* Used to generate tooltip. Can be changed to have dynamic tooltips.
		*/
	proc/getTooltip()
		. = desc

	/**
		* Information that should show up when an object has this effect and is examined.
		*/
	proc/getExamine()
		. = null

	proc/clicked(list/params)
		. = 0

	proc/move_trigger(mob/user, ev)
		. = 0

	disposing()
		if (owner)
			owner.statusEffects -= src
		src.owner = null
		..()

	defibbed
		id = "defibbed"
		name = "Defibrillated"
		desc = "You've been zapped in a way your heart seems to like."
		icon_state = "heart+"
		unique = 1
		maxDuration = 12 SECONDS // Just slightly longer than a defib's charge cycle

		getTooltip()
			. = "You've been zapped in a way your heart seems to like!<br>You feel more resistant to cardiac arrest, and more likely for subsequent defibrillating shocks to restart your heart if it stops!"

	staminaregen
		id = "staminaregen"
		name = ""
		icon_state = ""
		unique = 1
		var/change = 1

		getTooltip()
			. = "Your stamina regen is [change > 0 ? "increased":"reduced"] by [abs(change)]."

		onAdd(optional=null)
			..()
			var/mob/M = owner
			APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, id, change)

		onRemove()
			..()
			var/mob/M = owner
			REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, id)

	maxhealth
		id = "maxhealth"
		name = ""
		desc = ""
		icon_state = ""
		unique = 1
		var/change = 1 //Effective change to maxHealth

		onAdd(optional=null) //Optional is change.
			..()
			if(ismob(owner) && optional != 0)
				var/mob/M = owner
				change = optional
				M.max_health += change
				health_update_queue |= M

		onRemove()
			..()
			if(ismob(owner))
				var/mob/M = owner
				M.max_health -= change
				health_update_queue |= M

		onUpdate(timePassed)
			icon_state = "[change > 0 ? "heart+":"heart-"]"
			name = "Max. health [change > 0 ? "increased":"reduced"]"

		//causes max health to stack up to thousands on repeat calls
		//THEN DONT REPEATEDLY CALL IT. Don't just comment shit out. The value can't be changed without this. I've changed it to make the change value absolute.
		onChange(optional=null)
			if(ismob(owner) && optional != 0)
				var/mob/M = owner
				M.max_health -= change
				change = optional
				M.max_health += change
				health_update_queue |= M
			return

		getTooltip()
			return "Your max. health is [change > 0 ? "increased":"reduced"] by [abs(change)]."

		//Technically the base class can handle either but we need to separate these.
		increased
			id = "maxhealth+"
			onUpdate(timePassed)
				..()
				if(change < 0) //Someone fucked this up; remove effect.
					duration = 1

		decreased
			id = "maxhealth-"
			onUpdate(timePassed)
				..()
				if(change > 0) //Someone fucked this up; remove effect.
					duration = 1

	simplehot //Simple heal over time.
		id = "simplehot"
		var/tickCount = 0
		var/tickSpacing = 1 SECOND //Time between ticks.
		var/heal_brute = 0
		var/heal_tox = 0
		var/heal_burn = 0
		icon_state = "+"

		onUpdate(timePassed)
			tickCount += timePassed
			var/times = (tickCount / tickSpacing)
			if(times >= 1 && ismob(owner))
				tickCount -= (round(times) * tickSpacing)
				for(var/i in 1 to times)
					var/mob/M = owner
					M.HealDamage("All", heal_brute, heal_burn, heal_tox)
			return


	acided
		id = "acid"
		var/filter
		var/leave_cleanable = 0
		var/mob_owner = null

		onAdd(optional=null)
			. = ..()
			var/list/statusargs = optional
			owner.filters += filter(type="displace", icon=icon('icons/effects/distort.dmi', "acid"), size=0)
			src.filter = owner.filters[length(owner.filters)]
			if(length(statusargs))
				src.leave_cleanable = statusargs["leave_cleanable"]
				src.mob_owner = statusargs["mob_owner"]
			owner.color = list(0.8, 0, 0,\
								0, 0.8, 0,\
								0, 0, 0.8,\
								0.1, 0.4, 0.1)

			animate(filter, size=8, time=duration, easing=SINE_EASING)

		onRemove()
			. = ..()
			owner.filters -= filter
			filter = null
			if(src.leave_cleanable)
				var/obj/decal/cleanable/molten_item/I = make_cleanable(/obj/decal/cleanable/molten_item,get_turf(owner))
				I.desc = "Looks like this was \an [owner] some time ago."

			if(src.mob_owner && owner.loc == src.mob_owner)
				var/obj/item/clothing/C = owner
				var/mob/M = mob_owner
				C.dropped(M)
				M.u_equip(C)
			for(var/mob/M in AIviewers(5, owner))
				boutput(M, "<span class='alert'>\the [owner] melts.</span>")
			qdel(owner)

	simplehot/stimulants
		id = "stimulants"
		name = "Stimulants"
		desc = "You feel on top of the world!"
		icon_state = "janktank"
		unique = 1
		tickSpacing = 2 SECONDS
		heal_brute = 10
		heal_burn = 10
		heal_tox = 5
		var/tickspassed = 0


		onAdd(optional)
			. = ..()
			if(ismob(owner))
				var/mob/M = owner
				APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "stims", 500)
				M.add_stam_mod_max("stims", 500)
				M.add_stun_resist_mod("stims", 1000)
				var/datum/statusEffect/simpledot/stimulant_withdrawl/SW = owner.hasStatus("stimulant_withdrawl")
				if(istype(SW))
					tickspassed += SW.tickspassed
					owner.delStatus("stimulant_withdrawl")


		onRemove()
			. = ..()
			if(ismob(owner))
				var/mob/M = owner
				REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "stims")
				M.remove_stam_mod_max("stims")
				M.remove_stun_resist_mod("stims")

			owner.changeStatus("stimulant_withdrawl", tickspassed/(3), optional = tickspassed)

		onUpdate(timePassed)
			. = ..()
			tickspassed += timePassed
			if(ismob(owner))
				var/mob/M = owner
				M.take_oxygen_deprivation(-timePassed)
				M.delStatus("slowed")
				M.delStatus("disorient")
				if (M.misstep_chance)
					M.change_misstep_chance(-INFINITY)
				M.make_jittery(1000)
				M.dizziness = max(0,M.dizziness-10)
				M.changeStatus("drowsy", -20 SECONDS)
				M.sleeping = 0

	simpledot //Simple damage over time.
		var/tickCount = 0
		var/tickSpacing = 1 SECOND //Time between ticks.
		var/damage_brute = 0
		var/damage_tox = 0
		var/damage_burn = 0
		var/damage_type = DAMAGE_STAB
		icon_state = "-"

		onUpdate(timePassed)
			tickCount += timePassed
			var/times = (tickCount / tickSpacing)
			if(times >= 1 && ismob(owner))
				tickCount -= (round(times) * tickSpacing)
				for(var/i in 1 to times)
					var/mob/M = owner
					M.TakeDamage("All", damage_brute, damage_burn, damage_tox, damage_type)

	simpledot/radiation
		id = "radiation"
		name = "Irradiated"
		desc = ""
		icon_state = "radiation1"
		unique = 1
		visible = 0

		tickSpacing = 3 SECONDS

		damage_tox = 1
		damage_type = DAMAGE_BURN

		var/howMuch = ""
		var/stage = 1

		getTooltip()
			. = "You are [howMuch]irradiated.<br>Taking [round(damage_tox, 0.1)] toxin damage every [tickSpacing/(1 SECOND)] sec.<br>Damage reduced by radiation resistance on gear."

		preCheck(var/atom/A)
			. = 1
			if(issilicon(A) || isobserver(A) || isintangible(A))
				. = 0

		onUpdate(timePassed)
			if(locate(/obj/item/implant/health) in owner)
				src.visible = 1
			else
				src.visible = 0


			var/mob/M = null
			if(ismob(owner))
				M = owner

			var/prot = 1
			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				prot = (1 - (L.get_rad_protection() / 100))

			damage_tox = (sqrt(duration/20 + 5) - 1) * prot
			switch(duration/(1 SECOND))
				if(0 to 10)
					howMuch = ""
					stage = 1
				if(10 to 20)
					howMuch = "significantly "
					stage = 2
				if(20 to 45)
					howMuch = "very much "
					stage = 3
				if(45 to 90)
					howMuch = "extremely "
					stage = 4
				if(90 to INFINITY)
					howMuch = "horribly "
					stage = 5

			if(M)
				SEND_SIGNAL(M, COMSIG_MOB_GEIGER_TICK, stage)
				if(locate(/obj/item/implant/health) in M)
					src.visible = 1
				else
					src.visible = 0
				if (prob((stage - 2 - !!(M.traitHolder?.hasTrait("stablegenes"))) * prot) && (M.bioHolder && !M.bioHolder.HasEffect("revenant")))
					boutput(M, "<span class='alert'>You mutate!</span>")
					M.bioHolder.RandomEffect("either")
				if(prob((stage - 1) * prot) && M.bioHolder && !M.bioHolder.HasEffect("revenant"))
					M.changeStatus("weakened", 3 SECONDS)
					boutput(M, "<span class='alert'>You feel weak.</span>")
					M.emote("collapse")

			icon_state = "radiation[stage]"

			return ..(timePassed)

	simpledot/n_radiation
		id = "n_radiation"
		name = "Neutron Irradiated"
		desc = ""
		icon_state = "nradiation1"
		unique = 1
		visible = 0

		tickSpacing = 2 SECONDS

		damage_tox = 2
		damage_brute = 2
		damage_type = DAMAGE_STAB | DAMAGE_BURN

		var/howMuch = ""
		var/stage = 1

		getTooltip()
			. = "You are [howMuch]irradiated by neutrons.<br>Taking [round(damage_tox, 0.1)] toxin damage every [tickSpacing/(1 SECOND)] sec and [round(damage_brute, 0.1)] brute damage every [tickSpacing/(1 SECOND)] sec.<br>Damage reduced by radiation resistance on gear."

		preCheck(var/atom/A)
			. = 1
			if(issilicon(A) || isobserver(A) || isintangible(A))
				. = 0

		proc/update_lights(add = 1)
			owner.remove_simple_light("neutron_rad")
			owner.remove_medium_light("neutron_rad")
			if(add)
				if(stage < 4)
					owner.add_simple_light("neutron_rad", list(4, 62, 155, stage * 50))
				else
					owner.add_medium_light("neutron_rad", list(4, 62, 155, stage * 50))

		onAdd(optional=null)
			. = ..()
			update_lights()

		onRemove()
			update_lights(0)
			. = ..()

		onChange(optional=null)
			. = ..()
			update_lights()

		onUpdate(timePassed)

			var/mob/M = null
			if(ismob(owner))
				M = owner

			var/prot = 1
			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				prot = (1 - (L.get_rad_protection() / 100))

			damage_tox = (sqrt(duration/20 + 5) - 0.5) * prot
			damage_brute = damage_tox/2

			switch(duration/(1 SECOND))
				if(0 to 10)
					howMuch = ""
					stage = 1
				if(10 to 20)
					howMuch = "significantly "
					stage = 2
				if(20 to 30)
					howMuch = "very much "
					stage = 3
				if(30 to 60)
					howMuch = "extremely "
					stage = 4
				if(60 to INFINITY)
					howMuch = "horribly "
					stage = 5

			if(M)
				SEND_SIGNAL(M, COMSIG_MOB_GEIGER_TICK, stage)
				if(locate(/obj/item/implant/health) in M)
					src.visible = 1
				else
					src.visible = 0
				if (prob((stage - !!(M.traitHolder?.hasTrait("stablegenes"))) * prot) && (M.bioHolder && !M.bioHolder.HasEffect("revenant")))
					boutput(M, "<span class='alert'>You mutate!</span>")
					M.bioHolder.RandomEffect("either")
				if(prob((stage-1) * prot) && M.bioHolder && !M.bioHolder.HasEffect("revenant"))
					M.changeStatus("weakened", 5 SECONDS)
					boutput(M, "<span class='alert'>You feel weak.</span>")
					M.emote("collapse")
			update_lights()
			icon_state = "nradiation[stage]"

			return ..(timePassed)

	simpledot/burning
		id = "burning"
		name = "Burning"
		desc = ""
		icon_state = "fire1"
		unique = 1
		maxDuration = 100 SECONDS
		move_triggered = TRUE

		damage_burn = 1
		damage_type = DAMAGE_BURN
		track_cat = TR_CAT_BURNING_MOBS

		var/howMuch = ""
		var/stage = -1
		var/counter = 1

		var/mob/living/carbon/human/H
		var/image/onfire = null

		getTooltip()
			. = "You are [howMuch]on fire.<br>Taking [damage_burn] burn damage every [tickSpacing/(1 SECOND)] sec.<br>Damage reduced by heat resistance on gear. Click this statuseffect to resist."

		clicked(list/params)
			if (H)
				H.resist()

		preCheck(atom/A)
			. = 1
			if(issilicon(A))
				. = 0

		onAdd(optional = BURNING_LV1)
			. = ..()
			if(!isnull(optional) && optional >= stage)
				counter = optional

			switchStage(getStage())
			owner.delStatus("shivering")

			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				L.update_burning_icon(0, src) // pass in src because technically our owner does not have us as a status effect yet (this happens immediately after onAdd())

				if (ishuman(owner))
					H = owner
			else
				onfire = image('icons/effects/effects.dmi', null, EFFECTS_LAYER_1)
				onfire.icon_state = "onfire[getStage()]"
				onfire.filters += filter(type="alpha", icon=icon(owner.icon, owner.icon_state))
				owner.UpdateOverlays(onfire, "onfire")

		onChange(var/optional = BURNING_LV1)
			if(!isnull(optional) && optional >= stage)
				counter = optional
				switchStage(getStage())

		onRemove()
			..()
			if(!owner) return //owner got in our del queue
			if(istype(owner, /mob/living))
				var/mob/living/L = owner
				L.update_burning_icon(1)
			else
				owner.UpdateOverlays(null, "onfire")

		proc/getStage()
			. = 1
			if(min(duration*2, counter) < BURNING_LV2)
				return
			else if (min(duration*2, counter) >= BURNING_LV2 && min(duration*2, counter) < BURNING_LV3)
				return 2
			else if (min(duration*2, counter) >= BURNING_LV3)
				return 3

		proc/switchStage(var/toStage)
			if(stage != toStage)
				stage = toStage
				switch(stage)
					if(1) icon_state = "fire1"
					if(2) icon_state = "fire2"
					if(3) icon_state = "fire3"
				if(istype(owner, /mob/living))
					var/mob/living/L = owner
					L.update_burning_icon()
				else if(onfire)
					onfire.icon_state = "onfire[getStage()]"
					owner.UpdateOverlays(onfire, "onfire")

		move_trigger(mob/user, ev)
			. = 0
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				if (H.lying) //If they are lying down and get on fire, let them move to auto-extinguish
					H.resist()
					. = 1

		onUpdate(timePassed)
			counter += timePassed
			switchStage(getStage())

			var/prot = 1
			if(istype(owner, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = owner
				prot = (1 - (H.get_heat_protection() / 100))

			if(ismob(owner) && owner:is_heat_resistant())
				prot = 0

			switch(stage)
				if(1)
					damage_burn = 0.9 * prot
					howMuch = ""
				if(2)
					damage_burn = 2 * prot
					howMuch = "very much "
				if(3)
					damage_burn = 3.5 * prot
					howMuch = "extremely "

			return ..(timePassed)

	simpledot/stimulant_withdrawl
		id = "stimulant_withdrawl"
		name = "Stimulant withdrawl"
		icon_state = "janktank-w"
		desc = "You feel AWFUL!"
		tickSpacing = 3 SECONDS
		damage_brute = 1
		damage_tox = 2
		movement_modifier = new /datum/movement_modifier/status_slowed
		var/tickspassed = 0

		onAdd(optional)
			. = ..()
			movement_modifier.additive_slowdown = duration / (1 MINUTE)
			damage_brute *= (duration / (1 MINUTE)) ** 1.5
			damage_tox *= (duration / (1 MINUTE)) ** 1.5
			tickspassed = optional
			if(ismob(owner))
				var/mob/M = owner
				APPLY_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, -5, "stim_withdrawl")
				M.jitteriness = 0

		onUpdate(timePassed)
			. = ..()
			if(tickspassed)
				tickspassed = max(0, tickspassed - timePassed)
			if(prob(1))
				owner.changeStatus("stunned", 1 SECONDS)

		onRemove()
			. = ..()
			if(ismob(owner))
				var/mob/M = owner
				REMOVE_MOB_PROPERTY(M, PROP_STAMINA_REGEN_BONUS, "stim_withdrawl")

	stuns
		modify_change(change)
			. = change

			if (owner && ismob(owner) && change > 0)
				var/mob/M = owner
				var/percent_protection = M.get_stun_resist_mod()
				percent_protection = 1 - (percent_protection/100) //scale from 0 to 1
				. *= percent_protection

		onRemove()
			..()
			if(!owner) return
			if (!owner.hasStatus(list("stunned", "weakened", "paralysis", "pinned")))
				if (isliving(owner))
					var/mob/living/L = owner
					L.force_laydown_standup()

		onAdd()
			..()
			if(duration > 1 DECI SECOND)
				actions.interrupt(owner, INTERRUPT_STUNNED)

		stunned
			id = "stunned"
			name = "Stunned"
			desc = "You are stunned.<br>Unable to take any actions."
			icon_state = "stunned"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(optional=null)
				. = ..()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

		weakened
			id = "weakened"
			name = "Knocked-down"
			desc = "You are knocked-down.<br>Unable to take any actions, prone."
			icon_state = "weakened"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(optional=null)
				. = ..()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

			pinned
				id = "pinned"
				name = "Pinned"
				desc = "You are pinned. Click this status effect to resist.<br>Unable to take any actions, prone."
				icon_state = "pin"
				unique = 1
				maxDuration = null
				move_triggered = 1

				move_trigger(mob/user, ev)
					. = 0
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						H.resist()
						. = 1


				clicked(list/params)
					if (ishuman(owner))
						var/mob/living/carbon/human/H = owner
						H.resist()

				onUpdate()
					if (ismob(owner))
						var/mob/M = owner
						var/found = 0
						if (M.grabbed_by)
							for (var/obj/item/grab/G in M.grabbed_by)
								if (G.state == GRAB_PIN)
									found = 1
						if (!found)
							owner.delStatus("pinned")

						. = ..()



		paralysis
			id = "paralysis"
			name = "Unconscious"
			desc = "You are unconscious.<br>Unable to take any actions, blinded."
			icon_state = "paralysis"
			unique = 1
			maxDuration = 30 SECONDS

			onAdd(optional=null)
				. = ..()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					APPLY_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)

			onRemove()
				if (ismob(owner) && !QDELETED(owner))
					var/mob/mob_owner = owner
					REMOVE_MOB_PROPERTY(mob_owner, PROP_CANTMOVE, src.type)
				. = ..()

		dormant
			id = "dormant"
			name = "Dormant"
			desc = "You are dormant.<br>Unable to take any actions, until you power yourself."
			icon_state = "paralysis"
			unique = 1
			duration = INFINITE_STATUS

	staggered
		id = "staggered"
		name = "Staggered"
		desc = "You have been staggered by a melee attack.<br>Slowed slightly, unable to sprint."
		icon_state = "staggered"
		unique = 1
		maxDuration = 5 SECONDS
		movement_modifier = /datum/movement_modifier/staggered_or_blocking

		onAdd(optional=null)
			.=..()
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.sustained_moves = 0

	blocking
		id = "blocking"
		name = "Blocking"
		desc = "You are currently blocking. Use Resist to stop blocking.<br>Slowed slightly, unable to sprint. This overrides the 'staggered' effect and does not stack."
		icon_state = "blocking"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		movement_modifier = /datum/movement_modifier/staggered_or_blocking

		clicked(list/params)
			if (ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.resist()

	slowed
		id = "slowed"
		name = "Slowed"
		desc = "You are slowed.<br>Movement speed is reduced."
		icon_state = "slowed"
		unique = 1
		var/howMuch = 10
		movement_modifier = new /datum/movement_modifier/status_slowed

		onAdd(optional=null)
			if(optional)
				howMuch = optional
				movement_modifier.additive_slowdown = optional
			. = ..(optional)

		onChange(optional=null)
			if(optional)
				howMuch = optional
				movement_modifier.additive_slowdown = optional
			. = ..(optional)

	salted
		id = "salted"
		name = "Salted"
		desc = "AAAAA! SALT!<br>THIS HURTS!"
		icon_state = "slowed"
		unique = 0
		visible = 0
		movement_modifier = new /datum/movement_modifier/status_salted

		onAdd(optional=null)
			if(optional)
				movement_modifier.health_deficiency_adjustment = optional
			. = ..(optional)

		onChange(optional=null)
			if(optional)
				movement_modifier.health_deficiency_adjustment = optional
			. = ..(optional)

	disorient
		id = "disorient"
		name = "Disoriented"
		desc = "You are disoriented.<br>Movement speed is reduced. You may stumble or drop items."
		icon_state = "disorient"
		unique = 1
		maxDuration = 15 SECONDS
		var/counter = 0
		var/sound = "sound/effects/electric_shock_short.ogg"
		var/count = 7
		movement_modifier = /datum/movement_modifier/disoriented

		onUpdate(timePassed)
			counter += timePassed
			if (counter >= count && owner && !owner.hasStatus(list("weakened", "paralysis")) )
				counter -= count
				playsound(owner, sound, 17, 1, 0.4, 1.6)
				violent_twitch(owner)
			. = ..(timePassed)

	/// Basically disorient, but only does the animation and its maxDuration is
	/// upped a bit to synchronize with other stuns.
	cyborg_disorient
		id = "cyborg-disorient"
		name = "Disoriented"
		icon_state = "disorient"
		visible = 0
		unique = 1
		maxDuration = 30 SECONDS
		var/counter = 0
		var/sound = "sound/effects/electric_shock_short.ogg"
		var/count = 7

		onUpdate(timePassed)
			counter += timePassed
			if (counter >= count && owner)
				counter -= count
				playsound(owner, sound, 17, 1, 0.4, 1.6)
				violent_twitch(owner)
			. = ..(timePassed)

	drunk
		id = "drunk"
		name = "Drunk"
		desc = "You are drunk."
		icon_state = "drunk"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/how_drunk = 0

		onAdd(optional=null)
			changeState()
			return ..(optional)

		onUpdate(timePassed)
			changeState()
			return ..(timePassed)

		proc/changeState()
			if(owner?.reagents)
				var/amt = owner.reagents.get_reagent_amount("ethanol")
				if (amt >= 110)
					how_drunk = 3
				else if (amt > 50)
					how_drunk = 2
				else if (amt <= 50)
					how_drunk = 1
				else if (amt <= 0)
					how_drunk = 0
					return
				icon_state = "drunk[how_drunk]"

		getTooltip()
			. =  "You are [how_drunk == 2 ? "very": ""][how_drunk == 3 ? ", very" : ""] drunk."

	blinded
		id = "blinded"
		name = "Blinded"
		desc = "You are blinded.<br>Visibility drastically reduced."
		icon_state = "blinded"
		unique = 1

	hastened
		id = "hastened"
		name = "Hastened"
		desc = "You are hastened.<br>Movement speed is increased."
		icon_state = "hastened"
		unique = 1
		movement_modifier = /datum/movement_modifier/hastened

	cloaked
		id = "cloaked"
		name = "Cloaked"
		desc = "You are cloaked.<br>You are less visible."
		icon_state = "cloaked"
		unique = 1
		var/wait = 0

		onAdd(optional=null)
			. = ..()
			animate(owner, alpha=30, flags=ANIMATION_PARALLEL, time=30)

		onRemove()
			. = ..()
			animate(owner,alpha=255, flags=ANIMATION_PARALLEL, time=30)

		onUpdate(timePassed)
			wait += timePassed
			if(owner.alpha > 33 && wait > 40)
				animate(owner, alpha=30, flags=ANIMATION_PARALLEL, time=30)
				wait = 0

	staminaregen/fitness
		id = "fitness_stam_regen"
		name = "Pumped"
		desc = ""
		icon_state = "muscle"
		exclusiveGroup = "Food"
		maxDuration = 500 SECONDS
		unique = 1
		change = 2

	fitness_staminamax
		id = "fitness_stam_max"
		name = "Buff"
		desc = ""
		icon_state = "muscle"
		exclusiveGroup = "Food"
		maxDuration = 500 SECONDS
		unique = 1
		var/change = 10

		getTooltip()
			. = "Your stamina max is increased by [change]."

		onAdd(optional=null)
			. = ..()
			if(hascall(owner, "add_stam_mod_max"))
				owner:add_stam_mod_max("fitness_max", change)

		onRemove()
			. = ..()
			if(hascall(owner, "remove_stam_mod_max"))
				owner:remove_stam_mod_max("fitness_max")

	handcuffed
		id = "handcuffed"
		name = "Handcuffed"
		desc = "You are handcuffed.<br>You cannot use your hands. Click this status effect to resist."
		icon_state = "handcuffed"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/carbon/human/H

		onAdd(optional=null)
			. = ..()
			if (ishuman(owner))
				H = owner
			else
				if (ismob(owner))
					var/mob/M = owner
					if (M.handcuffs) M.handcuffs.drop_handcuffs(M) //Some kind of invalid mob??
				owner.delStatus("handcuffed")

		clicked(list/params)
			H.resist()

	buckled
		id = "buckled"
		name = "Buckled"
		desc = "You are buckled.<br>You cannot walk. Click this status effect to unbuckle."
		icon_state = "buckled"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/carbon/human/H
		var/sleepcount = 5 SECONDS

		onAdd(optional=null)
			. = ..()
			if (ishuman(owner))
				H = owner
				sleepcount = 5 SECONDS
			else
				owner.delStatus("buckled")

		clicked(list/params)
			if(H.buckled)
				H.buckled.Attackhand(H)

		onUpdate(timePassed)
			if (H && !H.buckled)
				owner.delStatus("buckled")
			else
				if (sleepcount > 0)
					sleepcount -= timePassed
					if (sleepcount <= 0)
						if (H.hasStatus("resting") && istype(H.buckled,/obj/stool/bed))
							var/obj/stool/bed/B = H.buckled
							B.sleep_in(H)
						else
							sleepcount = 3 SECONDS

			.=..()

	resting
		id = "resting"
		name = "Resting"
		desc = "You are resting.<br>You are laying down. Click this status effect to stand up."
		icon_state = "resting"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/mob/living/L

		onAdd(optional=null)
			. = ..()
			ON_COOLDOWN(owner, "lying_bullet_dodge_cheese", 0.2 SECONDS)
			if (isliving(owner))
				L = owner
				if (L.getStatusDuration("burning"))
					if (!actions.hasAction(L, "fire_roll"))
						L.last_resist = world.time + 25
						actions.start(new/datum/action/fire_roll(), L)
					else
						return
			else
				owner.delStatus("resting")

		clicked(list/params)
			if(ON_COOLDOWN(src.owner, "toggle_rest", REST_TOGGLE_COOLDOWN)) return
			L.delStatus("resting")
			L.force_laydown_standup()
			if (ishuman(L))
				var/mob/living/carbon/human/H = L
				H.hud.update_resting()

	ganger
		id = "ganger"
		name = "Gang Member"
		desc = "You are a gang member wearing your uniform. You get health and stamina bonuses."
		icon_state = "ganger"
		unique = 1
		duration = INFINITE_STATUS
		maxDuration = null
		var/const/max_health = 30
		var/const/max_stam = 60
		var/const/regen_stam = 5
		var/const/max_dist = 50
		var/mob/living/carbon/human/H
		var/datum/gang/gang
		var/on_turf = 0

		onAdd(optional=null)
			. = ..()
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("ganger")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("ganger_max", max_stam)
			APPLY_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "ganger_regen", regen_stam)
			if (ismob(owner))
				var/mob/M = owner
				if (M.mind)
					gang = M.mind.gang

		onRemove()
			. = ..()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("ganger_max")
			REMOVE_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "ganger_regen")
			gang = null

		onUpdate(timePassed)
			var/area/cur_area = get_area(H)
			if (cur_area?.gang_owners == gang && prob(50))
				on_turf = 1

				//get distance divided by max distance and invert it. Result will be between 0 and 1
				var/buff_mult = round(1-(min(get_dist(owner,gang.locker), max_dist) / max_dist), 0.1)
				if (buff_mult <=0)
					buff_mult = 0.1

				var/mob/living/carbon/human/H
				if(ishuman(owner))
					H = owner
					H.HealDamage("All", 10*buff_mult, 0, 0)
					if (H.bleeding && prob(100*buff_mult))
						repair_bleeding_damage(H, 5, 1)

					var/list/statusList = H.getStatusList()

					if(statusList["paralysis"])
						H.changeStatus("paralysis", -3*buff_mult)
					if(statusList["stunned"])
						H.changeStatus("stunned", -3*buff_mult)
					if(statusList["weakened"])
						H.changeStatus("weakened", -3*buff_mult)
			else
				on_turf = 0

			return

		getTooltip()
			. = "Your max health, max stamina, and stamina regen have been increased because of the pride you feel while wearing your uniform. [on_turf?"You are on home turf and receiving healing and stun reduction buffs when nearer your locker.":""]"

	janktank
		id = "janktank"
		name = "janktank"
		desc = "You're \"high\" on some sorta stimulant"
		icon_state = "janktank"
		duration = 9 MINUTES
		maxDuration = 18 MINUTES
		unique = 1
		movement_modifier = /datum/movement_modifier/janktank
		var/change = 1 //Effective change to maxHealth

		onAdd(optional=null) //Optional is change.
			. = ..()
			if(ismob(owner))
				owner.delStatus("janktank_withdrawl")
				var/mob/M = owner
				M.add_stun_resist_mod("janktank", 40)
			else
				owner.delStatus("janktank")

		onRemove()
			. = ..()
			if(ismob(owner))
				owner.changeStatus("janktank_withdrawl", 10 MINUTES)
				var/mob/M = owner
				M.remove_stun_resist_mod("janktank")

		onUpdate(timePassed)
			var/mob/living/carbon/human/H
			if(ishuman(owner))
				H = owner
				H.take_oxygen_deprivation(-1)
				H.HealDamage("All", 2, 0, 0)
				if (prob(60))
					H.HealDamage("All", 1, 1, 1)
					if (H.bleeding)
						repair_bleeding_damage(H, 10, 1)
				if (prob(10))
					H.make_jittery(2)

				if (H.misstep_chance)
					H.change_misstep_chance(-5)

	gang_drug_withdrawl
		id = "janktank_withdrawl"
		name = "janktank withdrawl"
		desc = "You're going through withrawl of Janktank"
		icon_state = "janktank-w"
		duration = 9 MINUTES
		maxDuration = 18 MINUTES
		unique = 1
		var/change = 1 //Effective change to maxHealth

		onAdd(optional=null) //Optional is change.
			. = ..()
			if(ismob(owner) && optional != 0)
				change = optional

		onUpdate(timePassed)
			var/mob/living/carbon/human/M
			if(ishuman(owner))
				M = owner
			if (prob(15))
				M.TakeDamage("All", 0, 0, 1)
			if (prob(10))
				owner.changeStatus("stunned", 2 SECONDS)
			if (prob(20))
				violent_twitch(owner)
				M.make_jittery(rand(6,9))

	mutiny
		id = "mutiny"
		name = "Mutiny"
		desc = "You can sense the aura of revolutionary activity! Your bossy attitude grants you health and stamina bonuses."
		icon_state = "mutiny"
		unique = 1
		maxDuration = 1 MINUTES
		var/const/max_health = 60
		var/const/max_stam = 30
		var/const/regen_stam = 5
		var/mob/living/carbon/human/H

		onAdd(optional=null)
			. = ..()
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("mutiny")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("mutiny_max", max_stam)
			APPLY_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "mutiny_regen", regen_stam)

		onRemove()
			. = ..()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("mutiny_max")
			REMOVE_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "mutiny_regen")

		getTooltip()
			. = "Your max health, max stamina, and stamina regen have been increased because of your bossy attitude."


	revspirit
		id = "revspirit"
		name = "Revolutionary Spirit"
		desc = "Your saw your revolution leaders holding some great signs. The cameraderie motivating you to fight harder!"
		icon_state = "revspirit"
		unique = 1
		maxDuration = 20 SECONDS
		var/const/max_health = 20
		var/const/max_stam = 15
		var/const/regen_stam = 3
		var/mob/living/carbon/human/H

		onAdd(optional=null)
			. = ..()
			if (ishuman(owner))
				H = owner
			else
				owner.delStatus("revspirit")
			H.max_health += max_health
			health_update_queue |= H
			H.add_stam_mod_max("revspirit_max", max_stam)
			APPLY_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "revspirit_regen", regen_stam)

		onRemove()
			. = ..()
			H.max_health -= max_health
			health_update_queue |= H
			H.remove_stam_mod_max("revspirit_max")
			REMOVE_MOB_PROPERTY(H, PROP_STAMINA_REGEN_BONUS, "revspirit_regen")

		getTooltip()
			. = "Your max stamina and stamina regen have been increased slightly."

	patho_oxy_speed
		id = "patho_oxy_speed"
		name = "Oxygen Storage"
		icon_state = "patho_oxy_speed"
		unique = 1
		movement_modifier = /datum/movement_modifier/patho_oxygen
		var/oxygenAmount = 100
		var/mob/living/carbon/human/H
		var/endCount = 0

		onAdd(optional)
			. = ..()
			src.oxygenAmount = optional
			if(iscarbon(owner))
				H = owner
			else
				owner.delStatus(src.id)

		getTooltip()
			. = "You are tapping your oxygen storage to breathe and move faster. Oxygen Storage at [oxygenAmount]% capacity!"

		onUpdate(timePassed)
			var/oxy_damage = min(20, H.get_oxygen_deprivation(), oxygenAmount)
			if(oxy_damage <= 0)											// If no oxy damage for 8 seconds, remove the status
				endCount += timePassed
			else
				endCount = 0
			if(endCount > 8 SECONDS)
				owner.delStatus(src.id)
			if (H.oxyloss)
				H.take_oxygen_deprivation(-oxy_damage)
				oxygenAmount -= oxy_damage
				H.losebreath = 0

	patho_oxy_speed/bad
		id = "patho_oxy_speed_bad"
		name = "Oxygen Conversion"
		icon_state = "patho_oxy_speed_bad"
		var/efficiency = 1

		onAdd(optional)
			. = ..()
			src.efficiency = optional
			..()
			if(H)
				H.show_message("<span class='alert'>You feel your body deteriorating as you breathe on.</span>")

		onUpdate(timePassed)
			var/oxy_damage = min(20, H.get_oxygen_deprivation())
			if(oxy_damage <= 0)				// If no oxy damage for 8 seconds, remove the status
				endCount += timePassed
			else
				endCount = 0
			if(endCount > 8 SECONDS)
				owner.delStatus(src.id)
			if (H.oxyloss)
				H.take_oxygen_deprivation(-oxy_damage)
				H.TakeDamage("chest", oxy_damage/efficiency, 0)
				H.losebreath = 0

		getTooltip()
			. = "Your flesh is being converted into oxygen! But you are moving slightly faster."



/datum/statusEffect/bloodcurse
	id = "bloodcurse"
	name = "Cursed"
	desc = "You have been cursed."
	icon_state = "bleeding"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null
	var/mob/living/carbon/human/H
	var/units = 5

	getTooltip()
		. = "You are losing blood at rate of [units] per second ."

	preCheck(var/atom/A)
		. = 1
		if(issilicon(A))
			. = 0

	onAdd(optional=null)
		. = ..()
		if (ishuman(owner))
			H = owner
		else
			owner.delStatus("bloodcurse")

	onUpdate()
		if (H.blood_volume > 400 && H.blood_volume > 0)
			H.blood_volume -= units
		if (prob(5))
			var/damage = rand(1,5)
			var/bleed = rand(3,5)
			H.visible_message("<span class='alert'>[H] [damage > 3 ? "vomits" : "coughs up"] blood!</span>", "<span class='alert'>You [damage > 3 ? "vomit" : "cough up"] blood!</span>")
			playsound(H.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			H.TakeDamage(zone="All", brute=damage)
			bleed(H, damage, bleed)

/datum/statusEffect/mentor_mouse
	id = "mentor_mouse"
	name = "Mentor Mouse"
	desc = "A mentor is helping you in the form of a mouse in your pocket. Click here to let them go."
	icon_state = "mentor_mouse"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null

	clicked(list/params)
		for(var/mob/dead/target_observer/mentor_mouse_observer/M in src.owner)
			boutput(src.owner, "You let the mentor mouse go.")
			M.boot()

	onUpdate()
		if (src.owner && !(locate(/mob/dead/target_observer/mentor_mouse_observer) in src.owner))
			owner.delStatus("mentor_mouse")
		. = ..()

/datum/statusEffect/mentor_mouse/admin
	id = "admin_mouse"
	name = "Admin Mouse"
	desc = "An admin is helping you in the form of a mouse in your pocket. Click here to let them go."
	icon_state = "admin_mouse"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null

	clicked(list/params)
		for(var/mob/dead/target_observer/mentor_mouse_observer/M in src.owner)
			boutput(src.owner, "You let the admin mouse go.")
			M.boot()

	onUpdate()
		if (src.owner && !(locate(/mob/dead/target_observer/mentor_mouse_observer) in src.owner))
			owner.delStatus("admin_mouse")
		. = ..()

/datum/statusEffect/signified
	id = "signified"
	name = "Signified"
	desc = "A Signifier bolt has made you vulnerable! Also you should never be seeing this!"
	icon_state = null
	duration = 0.5 SECONDS
	visible = 0

/datum/statusEffect/shivering
	id = "shivering"
	name = "Shivering"
	desc = "You're very cold!"
	icon_state = "shivering"
	duration = 2 SECONDS
	maxDuration = 30 SECONDS
	visible = 1
	movement_modifier = /datum/movement_modifier/shiver

	onAdd(optional=null)
		var/mob/M = owner
		if(istype(M))
			M.emote("shiver")
			M.thermoregulation_mult *= 3
		. = ..()

	onRemove()
		. = ..()
		var/mob/M = owner
		if(istype(M))
			M.thermoregulation_mult /= 3

/datum/statusEffect/maxhealth/decreased/hungry
	id = "hungry"
	name = "Hungry"
	desc = "You really gotta eat!"
	icon_state = "heart-"
	duration = INFINITE_STATUS
	maxDuration = null
	change = -20

	onAdd(optional=null)
		. = ..(change)

	onChange(optional=null)
		. = ..(change)

/datum/statusEffect/staminaregen/thirsty
	id = "thirsty"
	name = "Thirsty"
	desc = "You really need some water!"
	icon_state = "stam-"
	duration = INFINITE_STATUS
	maxDuration = null
	change = -5

/datum/statusEffect/miasma
	id = "miasma"
	name = "Miasma"
	desc = "You breathed in some gross miasma."
	icon_state = "miasma"
	unique = 1
	duration = INFINITE_STATUS
	maxDuration = null
	var/static/list/amount_desc = list("almost no", "a bit of", "some", "a lot of", "extremely large amounts of")
	var/how_miasma = 0
	var/weighted_average = 0

	onAdd(var/optional=null)
		changeState()
		return ..(optional)

	onUpdate(var/timePassed)
		changeState()
		var/mult = timePassed / (2 SECONDS)
		var/weighting = 0.035 * mult
		weighted_average = (1 - weighting) * weighted_average + weighting * how_miasma
		var/mob/living/L = owner
		if(!isalive(L))
			return
		var/puke_prob = 0
		var/tox = 0
		switch(how_miasma)
			if(1)
				if(probmult(1))
					L.emote("shudder")
			if(2)
				puke_prob = 0.2
				tox = 0.05
			if(3)
				puke_prob = 0.5
				tox = 0.20
			if(4)
				puke_prob = 1
				tox = 0.45
			if(5)
				puke_prob = 2
				tox = 0.70
		if(ismobcritter(L))
			var/mob/living/critter/critter = L
			if(critter.ghost_spawned)
				tox = 0.00
				weighted_average = 0
		L.take_toxin_damage(tox * mult)
		if(weighted_average > 4)
			weighted_average = 0
			#ifdef CREATE_PATHOGENS
			if(!isdead(L))
				var/datum/pathogen/P = unpool(/datum/pathogen)
				P.create_weak()
				P.spread = 0
				wrap_pathogen(L.reagents, P, 10)
			#endif
		if(probmult(puke_prob))
			L.visible_message("<span class='alert'>[L] pukes all over \himself.</span>", "<span class='alert'>You puke all over yourself!</span>")
			L.vomit()
		return ..(timePassed)

	proc/changeState()
		if(owner?.reagents)
			var/amt = owner.reagents.get_reagent_amount("miasma")
			switch(amt)
				if(-INFINITY to 5)
					how_miasma = 1
				if(5 to 10)
					how_miasma = 2
				if(10 to 40)
					how_miasma = 3
				if(40 to 70)
					how_miasma = 4
				else
					how_miasma = 5
			icon_state = "miasma[how_miasma]"

	getTooltip()
		. = "You breathed in [amount_desc[how_miasma]] miasma."
		if(how_miasma > 1)
			var/mob/living/critter/critter = owner
			if(istype(critter) && critter.ghost_spawned)
				. += " Your ghostly essence makes you immune to its poison."
			else
				. += " You will take toxic damage."
				#ifdef CREATE_PATHOGENS
				if(how_miasma > 4)
					. += " You might get sick."
				#endif

/datum/statusEffect/dripping_paint
	id = "marker_painted"
	name = "Dripping with Paint"
	desc = "You're leaving behind a trail of paint!"
	icon_state = "painted"


	onAdd(optional)
		. = ..()
		var/color2 = list(
			0.5, 0, 0,
			0, 0.5, 0,
			0, 0, 0.5,
			0.5, 0.25, 0.0625)
		var/oldcol = owner.color
		owner.color = color2
		owner.onVarChanged("color", oldcol, color2)
		if(istype(owner, /mob/living))
			RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/track_paint)

	onRemove()
		. = ..()
		if(istype(owner, /mob/living))
			UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


	proc/track_paint(mob/living/M, oldLoc, direct)
		var/turf/T = get_turf(M)
		var/obj/decal/cleanable/paint/P
		if (T.messy > 0)
			P = locate(/obj/decal/cleanable/paint) in T
		if(!P)
			P = make_cleanable(/obj/decal/cleanable/paint, T)

		var/list/states = M.get_step_image_states()

		if (states[1] || states[2])
			if (states[1])
				P.create_overlay(states[1], "#ff8820", direct, 'icons/effects/blood.dmi')
			if (states[2])
				P.create_overlay(states[2], "#ff8820", direct, 'icons/effects/blood.dmi')
		else
			P.create_overlay("smear2", "#ff8820", direct, 'icons/effects/blood.dmi')

/datum/statusEffect/magnetized
	id = "magnetized"
	name = "Magnetized"
	desc = "You've been given a magnetic charge"
	icon_state = "magnetized"
	unique = TRUE
	maxDuration = 3 MINUTES
	var/charge = null

	onAdd(optional)
		. = ..()
		if (!ismob(owner)) return
		var/mob/M = owner
		if (!M.bioHolder || M.bioHolder.HasEffect("resist_electric") || M.traitHolder.hasTrait("unionized"))
			SPAWN_DBG(0)
				M.delStatus("magnetized")
			return
		if (optional)
			src.charge = optional
		else
			src.charge = pick("magnets_pos", "magnets_neg")
		M.bioHolder.AddEffect(src.charge)

	onRemove()
		. = ..()
		if (!ismob(owner)) return
		var/mob/M = owner
		M.bioHolder.RemoveEffect(charge)

//I call it regrow limb, but it can regrow any limb/organ that a changer can make a spider from. (apart from headspider obviously)
/datum/statusEffect/changeling_regrow
	id = "c_regrow"
	name = "Regrowing Part: "
	desc = ""
	icon_state = "fire1"
	maxDuration = 100 SECONDS
	var/regrow_target_path = null 	//object path for the limb/organ we regrow
	var/regrow_target_name = null 	//Human readable name for name of the effect button and whatnot
	var/regrow_target_id = null 	//The limb/organ "slot" for this item. Must be a value that works in /datum/human_limbs or /datum/organHolder
	var/limb_or_organ = null		//Acceptable values: "limb" or "organ"

	var/counter = 0					//This I'm doing out of laziness. Instead of finding every place where an arm comes back.

///atom/proc/setStatus("c_regrow_body_part", 90 SECONDS, optional)

	getTooltip()
		. = "We are currently regrowing [regrow_target_name]."

	preCheck(atom/A)
		. = 1
		if(issilicon(A))
			. = 0

	onUpdate()
		..()
		//only do the extra checks every  10th tick
		if (counter % 10 == 0)
			counter = 0
			return

		//They already have the body part, don't give em a new one.
		if (check_target_part())
			boutput(owner, "We notice that we already have a new <b>[regrow_target_name]</b> and we stop growing a new one.")
			owner.delStatus(id)
			return
		counter++


	//Optional needs to be an acceptable value in organHolder.receive_organ or limb for this to work.
	onAdd(optional = null)
		. = ..()
		if (isnull(limb_or_organ))
			owner.delStatus(id)
		if (!ishuman(owner))
			owner.delStatus(id)
			return

		name += regrow_target_name

	onRemove()
		..()
		if (!ishuman(owner))
			return
		//They already have the body part, don't give em a new one.
		if (check_target_part())
			return
		//if it is removed before the time runs out (i.e. if you manually replaced this limb/organ), then don't regrow...
		if (duration > 0)
			boutput(owner, "We stop regrowing our [regrow_target_name]")
			return
		else
			do_regrow(owner)

	//Checks if the target spot has been mended (if there's a new limb or organ in that spot) using var/regrow_target_id
	proc/check_target_part()
		//check if they got a new limb/organ and remove the status
		switch(limb_or_organ)
			if ("limb")
				var/mob/living/carbon/human/H = owner
				return H.limbs.get_limb(regrow_target_id)

			if ("organ")
				var/mob/living/carbon/human/H = owner
				return H.organHolder.get_organ(regrow_target_id)

		return null

	proc/do_regrow(var/mob/living/carbon/human/H)
		if (check_target_part())
			boutput(owner, "We notice that we already have a new <b>[regrow_target_name]</b> and we stop growing a new one.")
			return

		switch(limb_or_organ)
			if ("limb")
				H.limbs.replace_with(regrow_target_id, regrow_target_path, show_message = 0)
				H.visible_message("<span class='alert'>[H]'s [regrow_target_name] seems to regrow before your eyes!</span>", "<span class='notice'>We finish growing a new <b>[regrow_target_name]</b>!</span>")
			if ("organ")
				H.organHolder.receive_organ(new regrow_target_path(H), regrow_target_id)
				H.visible_message("<span class='alert'>[H]'s [regrow_target_name] seems to regrow before your eyes!</span>", "<span class='notice'>We finish growing a new <b>[regrow_target_name]</b>!</span>")

/datum/statusEffect/changeling_regrow/limb
	limb_or_organ = "limb"
/datum/statusEffect/changeling_regrow/organ
	limb_or_organ = "organ"

/datum/statusEffect/changeling_regrow/limb/l_arm
	id = "c_regrow-l_hand"
	icon_state = "cspider-hand"
	regrow_target_id = "l_arm"
	regrow_target_name = "left arm"
	regrow_target_path = /obj/item/parts/human_parts/arm/left
/datum/statusEffect/changeling_regrow/limb/r_arm
	id = "c_regrow-r_hand"
	icon_state = "cspider-hand"
	regrow_target_id = "r_arm"
	regrow_target_name = "right arm"
	regrow_target_path = /obj/item/parts/human_parts/arm/right
/datum/statusEffect/changeling_regrow/limb/l_leg
	id = "c_regrow-l_leg"
	icon_state = "cspider-leg"
	regrow_target_id = "l_leg"
	regrow_target_name = "left leg"
	regrow_target_path = /obj/item/parts/human_parts/leg/left
/datum/statusEffect/changeling_regrow/limb/r_leg
	id = "c_regrow-r_leg"
	icon_state = "cspider-leg"
	regrow_target_id = "r_leg"
	regrow_target_name = "right leg"
	regrow_target_path = /obj/item/parts/human_parts/leg/right

/datum/statusEffect/changeling_regrow/organ/left_eye
	id = "c_regrow-l_eye"
	icon_state = "cspider-eye"
	regrow_target_id = "left_eye"
	regrow_target_name = "left eye"
	regrow_target_path = /obj/item/organ/eye/left
/datum/statusEffect/changeling_regrow/organ/right_eye
	id = "c_regrow-r_eye"
	icon_state = "cspider-eye"
	regrow_target_id = "right_eye"
	regrow_target_name = "right eye"
	regrow_target_path = /obj/item/organ/eye/right
/datum/statusEffect/changeling_regrow/organ/butt
	id = "c_regrow-butt"
	icon_state = "cspider-butt"
	regrow_target_id = "butt"
	regrow_target_name = "butt"
	regrow_target_path = /obj/item/clothing/head/butt


/datum/statusEffect/z_pre_infection
	id = "z_pre_inf"
	name = "Zombie Scratch"
	desc = "You breathed in some gross miasma."
	icon_state = "z_pre_infection-1"
	maxDuration = 90 SECONDS
	visible = 0

	var/timer = 0
	var/static/infect_time = 50 SECONDS

	var/mob/living/carbon/human/H
	var/image/onfire = null

	getTooltip()
		. = ""

	clicked(list/params)
		if (H)
			H.resist()

	preCheck(atom/A)
		. = 1
		if(!ishuman(A))
			. = 0
		// I'd LIKE to put this check here, but proc/find_ailment_by_type and is a bit too inefficient for my comfort
		// and this will be applied on combat hit. The ailments should use a assoc list for Constant lookup time or something...
		// if (isliving(A))
		// 	var/mob/living/L = A
		// 	if (L.find_ailment_by_type(/datum/ailment/disease/necrotic_degeneration/can_infect_more))
		// 		. = 0 //Already have the disease, don't need to bother with this

	onAdd()
		. = ..()
		timer = 0
		if (ishuman(owner))
			H = owner
			//If dead, instaconvert.
			if(isdead(H))
				H.set_mutantrace(/datum/mutantrace/zombie/can_infect)
				if (H.ghost?.mind && !(H.mind && H.mind.dnr)) // if they have dnr set don't bother shoving them back in their body (Shamelessly ripped from SR code. Fight me.)
					H.ghost.show_text("<span class='alert'><B>You feel yourself being dragged out of the afterlife!</B></span>")
					H.ghost.mind.transfer_to(H)
				H.delStatus(id)

	onUpdate(timePassed)
		timer += timePassed

		if (timer >= infect_time && H)
			H.contract_disease(/datum/ailment/disease/necrotic_degeneration/can_infect_more, null, null, 1) // path, name, strain, bypass resist
			H.delStatus(id)
			return
		return ..(timePassed)

/datum/statusEffect/drowsy
	maxDuration = 2 MINUTES
	id = "drowsy"
	name = "Drowsy"
	icon_state = "?1"
	desc = "You feel very drowsy"
	movement_modifier = new/datum/movement_modifier/drowsy
	var/tickspassed = 0

	onUpdate(timePassed)
		. = ..()
		tickspassed += timePassed
		movement_modifier.additive_slowdown = 2 + tickspassed/(15 SECONDS)
		if(ismob(owner) && prob(10))
			var/mob/M = owner
			M.change_eye_blurry(2, 10)

		if(prob(tickspassed/(10 SECONDS)))
			if(!owner.hasStatus("passing_out"))
				owner.setStatus("passing_out", 5 SECONDS)

/datum/statusEffect/passing_out
	id = "passing_out"
	name = "Passing out"
	desc = "You're so tired you're about to pass out!"
	icon_state = "disorient"
	maxDuration = 5 SECONDS

	onRemove()
		. = ..()
		owner.changeStatus("paralysis", 5 SECONDS)
		owner.delStatus("drowsy")
		if(isliving(owner))
			var/mob/living/L = owner
			L.changeStatus("weakened", 1 SECOND)
			L.force_laydown_standup()
