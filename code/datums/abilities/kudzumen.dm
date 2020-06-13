//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/obj/screen/ability/topBar/kudzu
	clicked(params)
		var/datum/targetable/kudzu/spell = owner
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
				src.updateIcon()
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
			SPAWN_DBG(0)
				spell.handleCast()
		return


////////////////////////////////////////////////// Ability holder /////////////////////////////////////////////

/datum/abilityHolder/kudzu
	usesPoints = 1
	regenRate = 0
	tabName = "kudzu"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	pointName = "nutrients"
	var/stealthed = 0
	var/obj/screen/kudzu/meter/nutrients_meter = null
	var/const/MAX_POINTS = 100
	New()
		..()
		if (owner.client)
			nutrients_meter = new/obj/screen/kudzu/meter(src)
			nutrients_meter.add_to_client(owner.client)

	disposing()
		qdel(nutrients_meter)
		..()

	onAbilityStat()
		..()
		return

	onLife(var/mult = 1)
		if(..()) return
		if (nutrients_meter)
			nutrients_meter.update()
		if (points <= 0)
			points = 0
			//unstealth
			if (stealthed)
				src.stealthed = 0
				owner.changeStatus("weakened", 6 SECONDS)
				animate(owner, alpha=255, time=3 SECONDS)

				boutput(owner, "You no invisible.")

		if (src.stealthed)
			points -= round(2*mult)


/datum/targetable/kudzu
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "kudzu-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/kudzu
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/unlock_message = null
	var/can_cast_anytime = 0		//while alive

	New()
		var/obj/screen/ability/topBar/kudzu/B = new /obj/screen/ability/topBar/kudzu(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	onAttach(var/datum/abilityHolder/H)
		..()
		if (src.unlock_message && src.holder && src.holder.owner)
			boutput(src.holder.owner, __blue("<h3>[src.unlock_message]</h3>"))
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /obj/screen/ability/topBar/vampire()
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
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0

		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0

		//maybe have to be on kudzu to use power?
		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return

/datum/targetable/kudzu/guide
	name = "Guide Growth"
	desc = "Guide the growth of kudzu by preventing them from growing in area."
	icon_state = "guide"
	targeted = 1
	target_anything = 1
	cooldown = 1 SECOND
	pointCost = 2
	max_range = 2

	cast(atom/tar)
		var/turf/T = get_turf(tar)
		if (isturf(T))
			//if there's already a marker here, remove it
			var/marker_to_del = locate(/obj/kudzu_marker) in T.contents
			if (marker_to_del in T.contents)
				qdel(locate(/obj/kudzu_marker) in T.contents)
				boutput(holder.owner, "<span class='alert'>You remove the guiding maker from [T].</span>")

			//make the marker
			else
				//remove kudzu from the marked tile.
				if (T.temp_flags & HAS_KUDZU)
					T.visible_message("<span class='notice'>The Kudzu shifts off of [T].</span>")
					for (var/obj/spacevine/K in T.contents)
						qdel(K)
				else
					boutput(holder.owner, "<span class='notice'>You create a guiding marker on [T].</span>")
				new/obj/kudzu_marker(T)

//technically kudzu, non invasive
/obj/kudzu_marker
	name = "benign kudzu"
	desc = "A flowering subspecies of the kudzu plant that, is a non-invasive plant on space stations."
	// invisibility = 101
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "kudzu-benign-1"
	var/health = 10

	New(var/location as turf)
		..()
		icon_state = "kudzu-benign-[rand(1,3)]"
		var/turf/T = get_turf(location)
		T.temp_flags |= HAS_KUDZU

	set_loc(var/newloc as turf|mob|obj in world)
		//remove kudzu flag from current turf
		var/turf/T1 = get_turf(loc)
		if (T1)
			T1.temp_flags &= ~HAS_KUDZU

		..()
		//Add kudzu flag to new turf.
		var/turf/T2 = get_turf(newloc)
		if (T2)
			T2.temp_flags |= HAS_KUDZU


	disposing()
		var/turf/T = get_turf(src)
		T.temp_flags &= ~HAS_KUDZU
		..()

	//mostly same as kudzu
	attackby(obj/item/W as obj, mob/user as mob)
		if (!W) return
		if (!user) return
		var/dmg = 1
		if (W.hit_type == DAMAGE_CUT || W.hit_type == DAMAGE_BURN)
			dmg = 3
		else if (W.hit_type == DAMAGE_STAB)
			dmg = 2
		dmg *= isnum(W.force) ? min((W.force / 2), 5) : 1
		DEBUG_MESSAGE("[user] damaging [src] with [W] [log_loc(src)]: dmg is [dmg]")
		src.health -= dmg
		if (src.health < 1)
			qdel (src)
		user.lastattacked  = src
		..()


/datum/targetable/kudzu/stealth
	name = "Stealth"
	desc = "Continuously secrete nutrients from your pores to turn slightly less visible!"
	icon_state = "stealth"
	targeted = 0
	cooldown = 10 SECONDS
	pointCost = 1

	cast(atom/T)
		var/datum/abilityHolder/kudzu/HK = holder
		if (!HK.stealthed)
			HK.stealthed = 1
			boutput(holder.owner, "You secrete nutriends to refract light.")
			animate(holder.owner, alpha=80, time=3 SECONDS)
		else
			HK.stealthed = 0
			boutput(holder.owner, "You no invisible.")
			animate(holder.owner, alpha=255, time=3 SECONDS)
		return 0

/datum/targetable/kudzu/heal_other
	name = "Healing Touch"
	desc = "Soothe the wounds of others... With plants!"
	icon_state = "heal-other"
	targeted = 1
	cooldown = 30 SECONDS
	pointCost = 40
	max_range = 1

	cast(atom/target)
		if (..())
			return 1

		if (target == holder.owner)
			boutput(holder.owner, "<span class='alert'>You can't heal yourself with your own vines this way!</span>")
			return 1

		var/mob/living/C = target
		if (istype(C))
			C.visible_message("<span class='alert'><b>[holder.owner] touches [C], enveloping them soft glowing vines!</b></span>")
			boutput(C, "<span class='notice'>You feel your pain fading away.</span>")
			C.HealDamage("All", 25, 25)
			C.take_toxin_damage(-25)
			C.take_oxygen_deprivation(-25)
			C.take_brain_damage(-25)
			C.remove_ailments()
			//Transfer nutrients to our brethren.
			var/mob/living/carbon/human/H = target
			if (istype(H) && istype(H.mutantrace, /datum/mutantrace/kudzu) && istype(H.abilityHolder, /datum/abilityHolder/kudzu))
				var/datum/abilityHolder/kudzu/KAH = H.abilityHolder
				H.abilityHolder.points = max(KAH.MAX_POINTS, KAH.points + 20)
				H.changeStatus("weakened", -3 SECONDS)
		return

/datum/targetable/kudzu/kudzusay
	name = "Speak Kudzu"
	desc = "Speak to your collective consciousness."
	icon_state = "kudzu-say"
	cooldown = 0
	pointCost = 0
	targeted = 0
	target_anything = 0
	interrupt_action_bars = 0
	dont_lock_holder = 1
	can_cast_anytime = 1
	cast(atom/target)
		if (..())
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return
		logTheThing("say", holder.owner, holder.owner.name, "[message]")
		.= holder.owner.say_kudzu(message, holder)

		return 0

/obj/screen/kudzu/meter
	icon = 'icons/misc/32x64.dmi'
	icon_state = "viney-0"
	name = "Nutrients Meter"
	screen_loc = "WEST,CENTER+5"
	var/theme = null // for wire's tooltips, it's about time this got varized
	var/cur_meter_location = 0
	var/last_meter_location = 0			//the amount of points at the last update. Used for deciding when to redraw the sprite to have less progress
	var/datum/abilityHolder/kudzu/holder

	New(var/datum/abilityHolder/kudzu/holder)
		src.holder = holder

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			var/theme = src.theme

			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = "Nutrients Meter",//src.name,
				"content" = "[holder.points] Points",//(src.desc ? src.desc : null),
				"theme" = theme
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

	proc/update()
		cur_meter_location = round((max(holder.points,0)/holder.MAX_POINTS)*11)	//length of meter
		if (cur_meter_location != last_meter_location)
			src.icon_state ="viney-[cur_meter_location]"

		last_meter_location = cur_meter_location
