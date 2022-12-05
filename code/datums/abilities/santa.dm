//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/atom/movable/screen/ability/topBar/santa
	clicked(params)
		var/datum/targetable/santa/spell = owner
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
				boutput(usr, "<span class='notice'>Please press a number to bind this ability to...</span>")
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this spell here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return


/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/santa
	usesPoints = 0
	regenRate = 0
	tabName = "santa"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	pointName = "points"
	var/stealthed = 0
	var/const/MAX_POINTS = 100

	New()
		..()

	disposing()
		..()

	onLife(var/mult = 1)
		if(..()) return


/datum/targetable/santa
	icon = 'icons/mob/santa_abilities.dmi'
	icon_state = "santa-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/santa
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/atom/movable/screen/ability/topBar/santa/B = new /atom/movable/screen/ability/topBar/santa(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return


	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/santa()
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

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(iscarbon(M) || ismobcritter(M)))
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (!isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/santa/heal
	name = "Santa Heal"
	desc = "Heal everyone around you."
	icon_state = "heal"
	targeted = 0
	cooldown = 1 MINUTES

	cast()
		playsound(holder.owner.loc, 'sound/voice/heavenly.ogg', 100, 1, 0)
		holder.owner.visible_message("<span class='alert'><B>[holder.owner] calls on the power of Spacemas to heal everyone!</B></span>")
		for (var/mob/living/M in view(holder.owner,5))
			M.HealDamage("All", 30, 30)

/datum/targetable/santa/gifts
	name = "Santa Gifts"
	desc = "Summon a whole bunch of Spacemas presents!"
	icon_state = "presents"
	targeted = 0
	cooldown = 2 MINUTES

	cast()
		holder.owner.visible_message("<span class='alert'><B>[holder.owner] throws out a bunch of Spacemas presents from nowhere!</B></span>")
		playsound(usr.loc, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
		holder.owner.transforming = 1
		var/to_throw = rand(3,12)

		var/list/nearby_turfs = list()

		for (var/turf/T in view(5,holder.owner))
			nearby_turfs += T

		while(to_throw > 0)
			var/obj/item/a_gift/festive/X = new /obj/item/a_gift/festive(holder.owner.loc)
			X.throw_at(pick(nearby_turfs), 16, 3)
			to_throw--
			sleep(0.2 SECONDS)
		holder.owner.transforming = 0

/datum/targetable/santa/food
	name = "Spacemas Goodies"
	desc = "Summon a whole bunch of festive snacks!"
	icon_state = "food"
	targeted = 0
	cooldown = 80 SECONDS

	cast()
		holder.owner.visible_message("<span class='alert'><B>[holder.owner] casts out a whole shitload of snacks from nowhere!</B></span>")
		playsound(holder.owner.loc, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
		holder.owner.transforming = 1
		var/to_throw = rand(6,18)

		var/list/nearby_turfs = list()

		for (var/turf/T in view(5,holder.owner))
			nearby_turfs += T

		var/snack
		while(to_throw > 0)
			snack = pick(santa_snacks)
			var/obj/item/X = new snack(holder.owner.loc)
			X.throw_at(pick(nearby_turfs), 16, 3)
			to_throw--
			sleep(0.1 SECONDS)
		holder.owner.transforming = 0

/datum/targetable/santa/warmth
	name = "Winter Hearth"
	desc = "Gives everyone near you temporary cold resistance."
	icon_state = "warmth"
	targeted = 0
	cooldown = 80 SECONDS

	cast()
		playsound(holder.owner.loc, 'sound/effects/MagShieldUp.ogg', 100, 1, 0)
		holder.owner.visible_message("<span class='alert'><B>[holder.owner] summons the warmth of a nice toasty fireplace!</B></span>")
		for (var/mob/living/M in view(holder.owner,5))
			if (M.bioHolder && !M.bioHolder.HasOneOfTheseEffects("fire_resist", "cold_resist", "thermal_resist"))
				M.bioHolder.AddEffect("cold_resist", 0, 60) // this will wipe `thermal_vuln` still vOv

/datum/targetable/santa/teleport
	name = "Spacemas Warp"
	desc = "Warp to somewhere else via the power of Christmas."
	icon_state = "warp"
	targeted = 0
	cooldown = 30 SECONDS

	cast()
		var/list/tele_areas = get_teleareas()
		var/A = tgui_input_list(src.holder.owner, "Area to jump to", "Teleportation", tele_areas)
		if (isnull(A))
			boutput(src.holder.owner, "<span class='alert'>Invalid area selected.</span>")
			return 1
		var/area/thearea = get_telearea(A)
		if(thearea.teleport_blocked)
			boutput(src.holder.owner, "<span class='alert'>That area is blocked from teleportation.</span>")
			return 1

		holder.owner.visible_message("<span class='alert'><B>[holder.owner] poofs away in a puff of cold, snowy air!</B></span>")
		playsound(src.holder.owner.loc, 'sound/effects/bamf.ogg', 25, 1, -1)
		playsound(src.holder.owner.loc, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(1, 0, src.holder.owner.loc)
		smoke.attach(src.holder.owner.loc)
		smoke.start()
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T
		holder.owner.set_loc(pick(L))

/datum/targetable/santa/banish
	name = "Banish Krampus"
	desc = "Get rid of Krampus. He may return if Christmas Cheer goes too low again though."
	icon_state = "banish_krampus"
	targeted = 0
	cooldown = 10 SECONDS

	cast()
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		for (var/mob/living/carbon/cube/meat/krampus/K in view(7,holder.owner))
			holder.owner.visible_message("<span class='alert'><B>[holder.owner] makes a stern gesture at [K]!</B></span>")
			boutput(K, "<span class='alert'>You have been banished by Santa Claus!</span>")
			playsound(usr.loc, 'sound/effects/bamf.ogg', 25, 1, -1)
			smoke.set_up(1, 0, K.loc)
			smoke.attach(K)
			smoke.start()
			K.gib()
			krampus_spawned = 0
			return

		boutput(holder.owner, "<span class='alert'>Can't find any Krampuses to banish! (you must be within 7 tiles)</span>")
