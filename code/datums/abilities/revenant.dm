/datum/abilityHolder/revenant
	topBarRendered = 1
	usesPoints = 1
	cast_while_dead = 1
	var/channeling = 0

	var/datum/abilityHolder/wraith/relay = null
	var/datum/bioEffect/hidden/revenant/revenant = null
	pointName = "Wraith Points"

	Stat()
		if (relay)
			relay.Stat()
		if (owner)
			stat("Human vessel integrity:", "[(owner.max_health + 50) / 1.5]%")

	generatePoints(var/mult = 1)
		if (relay)
			relay.generatePoints(mult = 1)

	deductPoints(cost)
		if (relay)
			return relay.deductPoints(cost)
		return 1

	pointCheck(cost)
		if (!relay)
			return 1
		if (!relay.usesPoints)
			return 1
		if (relay.points < 0) // Just-in-case fallback.
			logTheThing("debug", usr, null, "'s ability holder ([relay.type]) was set to an invalid value (points less than 0), resetting.")
			relay.points = 0
		if (cost > relay.points)
			boutput(owner, relay.notEnoughPointsMessage)
			return 0
		return 1

/datum/bioEffect/hidden/revenant
	name = "Revenant"
	desc = "The subject appears to be possessed by a wraith."
	id = "revenant"
	effectType = EFFECT_TYPE_POWER
	isBad = 0 // depends on who you ask really
	can_copy = 0
	var/isDying = 0
	var/mob/wraith/wraith = null
	var/ghoulTouchActive = 0
	var/list/abilities
	icon_state  = "evilaura"

	OnAdd()
		if (ishuman(owner) && isdead(owner))
			switch (owner:decomp_stage)
				if (0)
					owner.max_health = 100
				if (1)
					owner.max_health = 75
				if (2)
					owner.max_health = 50
				if (3)
					owner.max_health = 25
				if (4)
					// todo: send message, tell the player to fuck off, or something
					owner.bioHolder.RemoveEffect("revenant")
					qdel(src)
					return
		else
			// do not possess non-humans; do not possess living people; do not pass go; do not collect $200
			qdel(src)
			return

		owner.full_heal()
		owner.reagents.clear_reagents()
		owner.blinded = 0
		owner.lying = 0
		if (owner)
			overlay_image = image("icon" = 'icons/effects/wraitheffects.dmi', "icon_state" = "evilaura", layer = MOB_EFFECT_LAYER)
		if (owner.bioHolder.HasEffect("husk"))
			owner.bioHolder.RemoveEffect("husk")
		owner.set_mutantrace(null)
		owner.set_face_icon_dirty()
		owner.set_body_icon_dirty()
		animate_levitate(owner)

		owner.add_stun_resist_mod("revenant", 1000)
		APPLY_MOVEMENT_MODIFIER(owner, /datum/movement_modifier/revenant, src.type)

		..()

	OnRemove()
		if (owner)
			owner.remove_stun_resist_mod("revenant")
			REMOVE_MOVEMENT_MODIFIER(owner, /datum/movement_modifier/revenant, src.type)
		..()

	proc/ghoulTouch(var/mob/living/carbon/human/poorSob, var/obj/item/affecting)
		if (poorSob.traitHolder.hasTrait("training_chaplain"))
			poorSob.visible_message("<span class='alert'>[poorSob]'s faith shields them from [owner]'s ethereal force!", "<span class='notice'>Your faith protects you from [owner]'s ethereal force!</span>")
			return
		else
			poorSob.visible_message("<span class='alert'>[poorSob] is hit by [owner]'s ethereal force!</span>", "<span class='alert'>You are hit by [owner]'s ethereal force!</span>")
			if (istype(affecting))
				affecting.take_damage(4, 4, 0, DAMAGE_BLUNT)
			else
				poorSob.TakeDamage("All", 4, 4, 0, DAMAGE_BLUNT)
			poorSob.changeStatus("weakened", 2 SECONDS)
			step_away(poorSob, owner, 15)
			sleep(0.3 SECONDS)
			step_away(poorSob, owner, 15)


	proc/wraithPossess(var/mob/wraith/W)
		if (!W.mind && !W.client)
			return
		if (owner.client || owner.mind)
			var/mob/dead/observer/O = owner.ghostize()
			if (O)
				O.corpse = null
			owner.ghost = null
		if (owner.ghost)
			owner.ghost.corpse = null
			owner.ghost = null
		src.wraith = W
		W.invisibility = 50
		W.set_loc(src.owner)
		W.abilityHolder.suspendAllAbilities()

		message_admins("[key_name(wraith)] possessed the corpse of [owner] as a revenant at [showCoords(owner.x, owner.y, owner.z)].")
		logTheThing("combat", usr, null, "possessed the corpse of [owner] as a revenant at [showCoords(owner.x, owner.y, owner.z)].")


		if (src.wraith.mind) // theoretically shouldn't happen
			src.wraith.mind.transfer_to(owner)
		else
			src.wraith.client.mob = owner

		owner.visible_message("<span class='alert'><strong>[pick("[owner] suddenly rises from the floor!", "[owner] suddenly looks a lot less dead!", "A dark light shines from [owner]'s eyes!")]</strong></span>",\
			                  "<span class='notice'>[pick("You force your will into [owner]'s corpse.", "Your dark will forces [owner] to rise.", "You assume direct control of [owner].")]</span>")

		src.addRevenantVerbs()


	proc/RevenantDeath()
		if (isDying)
			return
		isDying = 1
		if (!src.wraith)
			src.owner.bioHolder.RemoveEffect("revenant")
			return
		if (!src.owner.mind && !src.owner.client)
			return

		message_admins("Revenant [key_name(owner)] died at [showCoords(owner.x, owner.y, owner.z)].")
		logTheThing("combat", usr, null, "died as a revenant at [showCoords(owner.x, owner.y, owner.z)].")
		if (owner.mind)
			owner.mind.transfer_to(src.wraith)
		else if (owner.client)
			owner.client.mob = src.wraith
		src.wraith.invisibility = 10
		src.wraith.set_loc(get_turf(owner))
		src.wraith.abilityHolder.resumeAllAbilities()
		src.wraith.abilityHolder.regenRate /= 3
		owner.bioHolder.RemoveEffect("revenant")
		owner:decomp_stage = 4
		if (ishuman(owner) && owner:organHolder && owner:organHolder:brain)
			qdel(owner:organHolder:brain)
		particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(owner.x, owner.y, owner.z)))
		animate(owner)
		src.wraith = null
		return

	OnLife()
		if (!src.wraith)
			return
		if (ghoulTouchActive)
			ghoulTouchActive--
			if (!ghoulTouchActive)
				owner.show_message("<span class='alert'>You are no longer empowered by the netherworld.</span>")

		src.wraith.Life()

		owner.max_health -= 1.5

		owner.ailments.Cut()
		owner.take_toxin_damage(-INFINITY)
		owner.take_oxygen_deprivation(-INFINITY)
		owner.take_eye_damage(-INFINITY)
		owner.take_eye_damage(-INFINITY, 1)
		owner.losebreath = 0
		owner.delStatus("disorient")
		owner.delStatus("slowed")
		owner.delStatus("radiation")
		owner.take_ear_damage(-INFINITY)
		owner.take_ear_damage(-INFINITY, 1)
		owner.take_brain_damage(-120)
		owner.bodytemperature = owner.base_body_temp
		setalive(owner)


		if (owner.health < -50)
			boutput(owner, "<span class='alert'><strong>This vessel has grown too weak to maintain your presence.</strong></span>")
			owner.death(0) // todo: add custom death
			return

		var/e_decomp_stage = 0
		if (owner.max_health < 75)
			e_decomp_stage++
			if (owner.max_health < 50)
				e_decomp_stage++
				if (owner.max_health < 25)
					e_decomp_stage++
					if (owner.max_health < 0)
						e_decomp_stage++
		if (ishuman(owner)) // technically we won't let it be anything else but who knows what might happen
			if (owner:decomp_stage != e_decomp_stage)
				owner:decomp_stage = e_decomp_stage
				owner.set_face_icon_dirty()
				owner.set_body_icon_dirty()

	proc/addRevenantVerbs()
		var/datum/abilityHolder/revenant/RH = owner.add_ability_holder(/datum/abilityHolder/revenant)
		RH.relay = src.wraith.abilityHolder
		RH.revenant = src
		src.wraith.abilityHolder.regenRate *= 3
		RH.addAbility(/datum/targetable/revenantAbility/massCommand)
		RH.addAbility(/datum/targetable/revenantAbility/shockwave)
		RH.addAbility(/datum/targetable/revenantAbility/touchOfEvil)
		RH.addAbility(/datum/targetable/revenantAbility/push)
		RH.addAbility(/datum/targetable/revenantAbility/crush)
		RH.addAbility(/datum/targetable/revenantAbility/help)

	/*proc/removeRevenantVerbs()
		if (owner.mind)
			owner.mind.spells.len = 0
		return*/

/datum/targetable/revenantAbility
	icon = 'icons/mob/wraith_ui.dmi'
	preferred_holder_type = /datum/abilityHolder/revenant
	theme = "wraith"

	New()
		var/obj/screen/ability/topBar/B = new /obj/screen/ability/topBar(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	cast(atom/target)
		return

	castcheck()
		if (holder && holder.owner)
			return 1
		else
			boutput(usr, "<span class='alert'>You're not a revenant, what the heck are you doing?</span>")
			return 0

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()


/datum/targetable/revenantAbility/massCommand
	name = "Mass Command"
	desc = "Launch an assortment of nearby objects at a target location."
	icon_state = "masscomm"
	special_screen_loc = "NORTH-1,WEST"
	targeted = 1
	target_anything = 1
	pointCost = 500
	cooldown = 300

	cast(atom/target)
		if (istype(holder, /datum/abilityHolder/revenant))
			var/datum/abilityHolder/revenant/RH = holder
			RH.channeling = 0
		holder.owner.visible_message("<span class='alert'><strong>[holder.owner]</strong> gestures upwards, then at [target] with a swift striking motion!</span>")
		var/list/thrown = list()
		var/current_prob = 100
		if (ishuman(target))
			var/mob/living/carbon/T = target
			if (T.traitHolder.hasTrait("training_chaplain"))
				target.visible_message("<span class='alert'> [target] gives a rude gesture right back to [holder.owner]!</span>")
				return 1
			else if( check_target_immunity(T) )
				holder.owner.show_message( "<span class='alert'>That target seems to be warded from the effects!</span>" )
			else
				T.changeStatus("stunned", max(max(T.getStatusDuration("weakened"), T.getStatusDuration("stunned")), 3))
				T.lying = 0
				T.delStatus("weakened")
				T.show_message("<span class='alert'>A ghostly force compels you to be still on your feet.</span>")
		for (var/obj/O in view(7, holder.owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= 0.75
					thrown += O
					animate_float(O)
		SPAWN_DBG(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(target, 32, 2)

/datum/targetable/revenantAbility/shockwave
	name = "Shockwave"
	desc = "Emit a shockwave, breaking nearby lights and walls, and stunning nearby humans for a short time."
	icon_state = "shockwave"
	targeted = 0
	pointCost = 750
	cooldown = 350 // 35s
	var/propagation_percentage = 60
	var/iteration_depth = 6
	special_screen_loc = "NORTH-1,WEST+1"
	var/static/list/prev = list("1" = NORTHWEST, "5" = NORTH, "4" = NORTHEAST, "6" = EAST,  "2" = SOUTHEAST, "10" = SOUTH, "8" = SOUTHWEST, "9" = WEST)
	var/static/list/next = list("1" = NORTHEAST, "5" = EAST,  "4" = SOUTHEAST, "6" = SOUTH, "2" = SOUTHWEST, "10" = WEST,  "8" = NORTHWEST, "9" = NORTH)

	proc/shock(var/turf/T)
		SPAWN_DBG(0)
			for (var/mob/living/carbon/human/M in T)
				if (M != holder.owner && !M.traitHolder.hasTrait("training_chaplain") && !check_target_immunity(M))
					M.changeStatus("weakened", 2 SECONDS)
			animate_revenant_shockwave(T, 1, 3)
			SPAWN_DBG(0.3 SECONDS)
				for (var/mob/living/carbon/human/M in T)
					if (M != holder.owner && !M.traitHolder.hasTrait("training_chaplain") && !check_target_immunity(M))
						M.changeStatus("weakened", 6 SECONDS)
						M.show_message("<span class='alert'>A shockwave sweeps you off your feet!</span>")
				for (var/obj/machinery/light/L in T)
					L.broken()
				for (var/obj/window/W in T)
					W.health = 0
					W.smash()
				if (istype(T, /turf/simulated/wall))
					T:dismantle_wall()
				else if (istype(T, /turf/simulated/floor) && prob(75))
					if (prob(50))
						T:to_plating()
					else
						T:break_tile()
				SPAWN_DBG(1 SECOND)
					T.pixel_y = 0
					T.transform = null

	cast()
		var/list/next = list()
		var/list/NN = list()
		var/turf/origin = get_turf(holder.owner)
		if (!origin)
			return 1
		if (istype(holder, /datum/abilityHolder/revenant))
			var/datum/abilityHolder/revenant/RH = holder
			RH.channeling = 0
		shock(origin)
		for (var/turf/T in orange(1, origin))
			next += T
			next[T] = get_dir(origin, T)
		SPAWN_DBG(0)
			for (var/i = 1, i <= iteration_depth, i++)
				for (var/turf/T in next)
					shock(T)
					if (!T.density)
						var/base_dir = next[T]
						var/left_dir = src.prev["[base_dir]"]
						var/right_dir = src.next["[base_dir]"] // ugly & fuck you byond for making me do this
						if (prob(propagation_percentage / 2))
							var/turf/A = get_step(T, left_dir)
							if (A && !(A in NN))
								NN += A
								NN[A] = left_dir
						if (prob(propagation_percentage))
							var/turf/B = get_step(T, base_dir)
							if (B && !(B in NN))
								NN += B
								NN[B] = base_dir
						if (prob(propagation_percentage / 2))
							var/turf/C = get_step(T, right_dir)
							if (C && !(C in NN))
								NN += C
								NN[C] = right_dir
				next = NN
				NN = list()
				sleep(0.3 SECONDS)
		return 0

/datum/targetable/revenantAbility/touchOfEvil
	name = "Touch of Evil"
	desc = "Empower your hand-to-hand attacks for a short time, causing additional damage and knockdown."
	icon_state = "eviltouch"
	targeted = 0
	pointCost = 1000
	cooldown = 300
	special_screen_loc = "NORTH-1,WEST+2"

	cast()
		if (istype(holder, /datum/abilityHolder/revenant))
			var/datum/abilityHolder/revenant/RH = holder
			RH.channeling = 0
			var/datum/bioEffect/hidden/revenant/R = RH.revenant
			R.ghoulTouchActive = 4
			holder.owner.visible_message("<span class='alert'>[holder.owner] glows with ethereal power!</span>", "<span class='notice'>You feel ghostly strength pulsing through you.</span>")
			return 0
		holder.owner.show_message("<span class='alert'>You cannot cast that ability!</span>")

/datum/targetable/revenantAbility/push
	name = "Push"
	desc = "Pushes a target object or mob away from the revenant."
	icon_state = "push"
	targeted = 1
	target_anything = 1
	pointCost = 50
	cooldown = 150
	special_screen_loc = "NORTH-1,WEST+3"

	cast(atom/target)
		if (isturf(target))
			holder.owner.show_message("<span class='alert'>You must target an object or mob with this ability.</span>")
			return 1
		if (istype(holder, /datum/abilityHolder/revenant))
			var/datum/abilityHolder/revenant/RH = holder
			RH.channeling = 0
		var/mob/source = src.holder.owner
		var/throwat = get_edge_target_turf(target, get_dir(source, target))
		var/atom/movable/M = target

		if (ismob(target))
			var/mob/T = target
			if (T.bioHolder && T.traitHolder.hasTrait("training_chaplain"))
				holder.owner.show_message("<span class='alert'>Some mysterious force protects [target] from your influence.</span>")
				return 1
			else if( check_target_immunity(T) )
				holder.owner.show_message("<span class='alert'>[target] seems to be warded from the effects!</span>")
				return 1
			else
				holder.owner.show_message("<span class='notice'>You hurl [target] away from you!</span>")
				T.throw_at(throwat, 32, 2)
				T.show_message("<span class='alert'>An unknown force hurls you away!</span>")
		else
			holder.owner.show_message("<span class='notice'>You hurl [target] away from you!</span>")
			M.throw_at(throwat, 32, 2)

		return 0

/datum/targetable/revenantAbility/crush
	name = "Crush"
	desc = "Channel your telekinetic abilities at a human target, causing damage as long as you stand still. Casting any other spell will interrupt this!"
	icon_state = "crush"
	targeted = 1
	pointCost = 2500
	cooldown = 600
	special_screen_loc = "NORTH-1,WEST+4"

	cast(atom/target)
		if (!ishuman(target))
			holder.owner.show_message("<span class='alert'>You must target a human with this ability.</span>")
			return 1
		var/mob/living/carbon/human/H = target
		if (!isturf(holder.owner.loc))
			holder.owner.show_message("<span class='alert'>You cannot cast this ability inside a [holder.owner.loc].</span>")
			return 1
		if (holder.owner.equipped())
			holder.owner.show_message("<span class='alert'>You require a free hand to cast this ability.</span>")
			return 1
		if (H.traitHolder.hasTrait("training_chaplain"))
			holder.owner.show_message("<span class='alert'>Some mysterious force shields [target] from your influence.</span>")
			return 1
		else if( check_target_immunity(H) )
			holder.owner.show_message("<span class='alert'>[target] seems to be warded from the effects!</span>")
			return 1

		var/location = holder.owner.loc

		holder.owner.visible_message("<span class='alert'>[holder.owner] reaches out towards [H], making a crushing motion.</span>", "<span class='notice'>You reach out towards [H].</span>")
		H.changeStatus("weakened", 2 SECONDS)

		var/datum/abilityHolder/revenant/RH
		if (istype(holder, /datum/abilityHolder/revenant))
			RH = holder
			RH.channeling = 1
		if (!RH || !istype(RH, /datum/abilityHolder/revenant/))
			return

		SPAWN_DBG(0.5 SECONDS)
			var/iterations = 0
			while (holder.owner.loc == location && isalive(holder.owner) && !holder.owner.equipped())
				iterations++
				if (!holder.owner)
					RH.channeling = 0
					break
				if (RH.channeling == 0)
					holder.owner.show_message("<span class='alert'>You were interrupted!</span>")
					break
				if (!H)
					holder.owner.show_message("<span class='alert'>You were interrupted!</span>")
					RH.channeling = 0
					break
				if (get_dist(holder.owner, H) > 7)
					holder.owner.show_message("<span class='alert'>[H] is pulled from your telekinetic grip!</span>")
					RH.channeling = 0
					break
				H.changeStatus("weakened", (2 + rand(0, iterations))*10)
				H.TakeDamage("chest", 4 + rand(0, iterations), 0, 0, DAMAGE_CRUSH)
				if (prob(40))
					H.visible_message("<span class='alert'>[H]'s bones crack loudly!</span>", "<span class='alert'>You feel like you're about to be [pick("crushed", "destroyed", "vaporized")].</span>")
				if (prob(50))
					H.emote("scream")
				if (iterations > 12 && prob((iterations - 12) * 5))
					H.visible_message("<span class='alert'>[H]'s body gives in to the telekinetic grip!</span>", "<span class='alert'>You are completely crushed.</span>")
					H.gib()
					return
				sleep(0.7 SECONDS)
			holder.owner.show_message("<span class='alert'>You were interrupted!</span>")
		return 0

/datum/targetable/revenantAbility/help
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
		else
			holder.help_mode = 1
			boutput(holder.owner, "<span class='hint'><strong>Help Mode has been activated  To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='hint'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='hint'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='hint'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()
		return 0
