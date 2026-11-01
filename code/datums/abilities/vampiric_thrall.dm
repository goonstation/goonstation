// Converted everything related to vampires from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

/* 	/		/		/		/		/		/		Ability Holder	/		/		/		/		/		/		/		/		*/

/atom/movable/screen/ability/topBar/vampiric_thrall
	clicked(params)
		var/datum/targetable/vampiric_thrall/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.UpdateIcon()
				boutput(usr, SPAN_NOTICE("Please press a number to bind this ability to..."))
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, SPAN_ALERT("You can't use this spell here."))
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/vampiric_thrall
	usesPoints = 0
	regenRate = 0
	tabName = "Thrall"
	notEnoughPointsMessage = SPAN_ALERT("You need more blood to use this ability.")
#ifdef BONUS_POINTS
	points = 300
#else
	points = 0
#endif
	remove_on_clone = TRUE

	var/mob/vamp_isbiting = null
	var/datum/abilityHolder/vampire/master

#ifdef RP_MODE
	var/blood_decay = 0.125
#else
	var/blood_decay = 0.25
#endif
	var/blood_to_health_scalar = 0.75 //! 200 blood = 150 health
	var/min_max_health = 40 //! Minimum health we can get to via blood loss. also lol

	///How far you can stray from your vampire without losing blood
	var/max_range = 20

	///Counter that ticks up as you spend time away from your vampire before you start to loose blood
	var/grace_count = 0
	///How many (mult adjusted) life ticks before you start to lose blood
	var/grace_limit = 1.5

	onLife(var/mult = 1)
		.= 0
		var/mob/living/owner_mob = src.owner
		if (!istype(owner_mob))
			return
		//normal bleeding
		if (owner_mob.bleeding)
			src.points -= src.blood_decay * owner_mob.bleeding

		//passive decay
		src.points -= blood_decay * mult
		src.points = max(0,src.points)

		if (ON_COOLDOWN(src.owner, "thrall_blood_waste", 5 SECONDS))
			src.update_max_health()
			return

		var/dist
		if (!master?.owner || get_z(master.owner) != get_z(src.owner))
			dist = 60
		else
			dist = GET_DIST(get_turf(master.owner), get_turf(src.owner))
		dist = min(dist, 100)
		if (dist > src.max_range)
			if (src.grace_count > src.grace_limit)
				var/blood_loss = 15 + dist/2
				src.blood_waste(blood_loss)
			else
				src.grace_count += mult
				boutput(src.owner, SPAN_ALERT("You feel an insistent tug, you need to stick closer to your master."))
				src.waste_effect(0.2)
		else
			src.grace_count = 0 //we're within range, reset

		src.update_max_health()

	proc/update_max_health()
		src.owner.max_health = src.points * blood_to_health_scalar
		src.owner.max_health = max(src.min_max_health, src.owner.max_health)
		global.health_update_queue |= src.owner
		src.updateText(0, src.x_occupied, src.y_occupied) //might not be needed?

	///Lose an amount of blood, first from points then from bloodstream
	proc/blood_waste(blood_loss)
		var/overflow_loss = blood_loss - src.points //the amount not covered by our points
		src.points = max(0, src.points - blood_loss)
		var/mob/living/living_owner = src.owner //the calling proc can be responsible for checking this, it needs some responsibility in its life
		if (src.points <= 0 && living_owner.blood_volume < 200)
			boutput(src.owner, SPAN_ALERT(SPAN_BOLD(pick("You feel your master's power fading...", "NEED. BLOOOD.", "You can feel death trying to take you back."))))
		else
			boutput(src.owner, SPAN_ALERT(SPAN_BOLD("You feel [pick("your gut wrench", "your skin bleed", "your heart twist")] as you stray too far from your master.")))
		if (overflow_loss > 0)
			bleed(src.owner, overflow_loss, 5, get_turf(src.owner)) //take it from our actual bloodstream instead
			src.waste_effect(1)
		else
			var/obj/decal/cleanable/blood/blood_decal = make_cleanable(/obj/decal/cleanable/blood, get_turf(src.owner))
			if (src.owner.bioHolder)
				blood_decal.blood_DNA = src.owner.bioHolder.Uid
				blood_decal.blood_type = src.owner.bioHolder.bloodType
			src.waste_effect(0.4)

	proc/waste_effect(severity)
		if (!src.owner.client)
			return
		var/original_color = src.owner.client.color
		var/flash_color = rgb(255, (1-severity) * 255, (1-severity) * 255)
		animate(src.owner.client, color=flash_color, time=0.4 SECONDS)
		animate(color=original_color, time=1.5 SECONDS)
		if (severity > 0.2)
			src.owner.playsound_local(src.owner, 'sound/effects/heartbeat.ogg', 60, FALSE)

	onAbilityStat() // In the 'Vampire' tab.
		..()
		.= list()
		.["Blood:"] = round(src.points)
		.["Max HP:"] = round(src.owner.max_health)

	proc/change_vampire_blood(var/change = 0, var/total_blood = 0, var/set_null = 0)
		if(!total_blood)
			if (src.points < 0)
				src.points = 0
			if (set_null)
				src.points = 0
			else
				src.points = max(src.points + change, 0)


/datum/targetable/vampiric_thrall
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "vampire-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/vampiric_thrall
	var/when_stunned = 1 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/not_when_in_an_object = TRUE
	var/unlock_message = null

	New()
		var/atom/movable/screen/ability/topBar/vampiric_thrall/B = new /atom/movable/screen/ability/topBar/vampiric_thrall(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(var/datum/abilityHolder/H)
		..() // Start_on_cooldown check.
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, SPAN_NOTICE("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/vampiric_thrall()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.getStatusDuration("stunned") > 0 || M.getStatusDuration("unconscious") > 0 || M.getStatusDuration("knockdown"))
					return 0
				else
					return 1
			if (1)
				if (!isalive(M) || M.getStatusDuration("unconscious") > 0)
					return 0
				else
					return 1
			else
				return 1

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(iscarbon(M) || ismobcritter(M)))
			boutput(M, SPAN_ALERT("You cannot use any powers in your current form."))
			return 0

		if (M.transforming)
			boutput(M, SPAN_ALERT("You can't use any powers right now."))
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, SPAN_ALERT("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, SPAN_ALERT("You can't use this ability when restrained!"))
			return 0

		if (istype(get_area(M), /area/station/chapel))
			boutput(M, SPAN_ALERT("Your powers do not work in this holy place!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
