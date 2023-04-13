//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/atom/movable/screen/ability/topBar/kudzu
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

/datum/abilityHolder/kudzu
	usesPoints = 1
	regenRate = 0
	tabName = "kudzu"
	// notEnoughPointsMessage = "<span class='alert'>You need more blood to use this ability.</span>"
	points = 0
	pointName = "nutrients"
	var/stealthed = 0
	var/atom/movable/screen/kudzu/meter/nutrients_meter = null
	var/atom/movable/screen/kudzu/growth_amount/growth_amt = null

	var/const/MAX_POINTS = 100

	New()
		..()
		if (hud)
			nutrients_meter = new/atom/movable/screen/kudzu/meter(src)
			hud.add_object(nutrients_meter)

			growth_amt = new/atom/movable/screen/kudzu/growth_amount(src, get_master_kudzu_controller())
			hud.add_object(growth_amt)


	disposing()
		qdel(nutrients_meter)
		qdel(growth_amt)
		..()

	onLife(var/mult = 1)
		if(..()) return
		if (nutrients_meter)
			nutrients_meter.update()
		if (growth_amt)
			growth_amt.update()
		if (points <= 0)
			points = 0
			//unstealth
			if (stealthed)
				src.stealthed = 0
				owner.changeStatus("weakened", 6 SECONDS)
				animate(owner, alpha=255, time=3 SECONDS)

				boutput(owner, "You no invisible.")
		else if (points > MAX_POINTS)
			points = MAX_POINTS

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
		var/atom/movable/screen/ability/topBar/kudzu/B = new /atom/movable/screen/ability/topBar/kudzu(null)
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
			boutput(src.holder.owner, "<span class='notice'><h3>[src.unlock_message]</h3></span>")
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/kudzu()
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

		if (can_cast_anytime && !isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		//maybe have to be on kudzu to use power?
		return 1

	cast(atom/target)
		. = ..()
		if (istype(holder, /datum/abilityHolder/kudzu))
			var/datum/abilityHolder/kudzu/KAH = holder
			KAH.nutrients_meter.update()
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
	// invisibility = INVIS_ALWAYS
	anchored = ANCHORED
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
	attackby(obj/item/W, mob/user)
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
	var/heal_coef = 30

	cast(atom/target)
		if (..())
			return 1

		if (target == holder.owner)
			heal_coef = round(heal_coef/2)
			boutput(holder.owner, "<span class='alert'>Using your own nutrients to heal is slightly less effective!</span>")

		var/mob/living/C = target
		if (istype(C))
			C.visible_message("<span class='alert'><b>[holder.owner] touches [C], enveloping them soft glowing vines!</b></span>")
			boutput(C, "<span class='notice'>You feel your pain fading away.</span>")
			C.HealDamage("All", heal_coef, heal_coef)
			C.take_toxin_damage(-heal_coef)
			C.take_oxygen_deprivation(-heal_coef)
			C.take_brain_damage(-heal_coef)
			C.remove_ailments()
			if (C.organHolder)
				var/organ_const = heal_coef/3
				C.organHolder.heal_organs(organ_const, organ_const, organ_const, list("liver", "left_kidney", "right_kidney", "stomach", "intestines","spleen", "left_lung", "right_lung","appendix", "pancreas", "heart", "brain", "left_eye", "right_eye", "tail"))

			//remove all implants too
			if (C.implant)
				for (var/obj/item/implant/I in C.implant)
					if (istype(I, /obj/item/implant/projectile))
						boutput(C, "[I] falls out of you!")
						I.on_remove(C)
						C.implant.Remove(I)
						//del(I)
						I.set_loc(get_turf(C))
						continue

			//Transfer nutrients to our brethren.
			var/mob/living/carbon/human/H = target
			if (istype(H) && istype(H.mutantrace, /datum/mutantrace/kudzu) && istype(H.abilityHolder, /datum/abilityHolder/kudzu))
				var/datum/abilityHolder/kudzu/KAH = H.abilityHolder
				H.abilityHolder.points = min(KAH.MAX_POINTS, KAH.points + 20)
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
	lock_holder = FALSE
	can_cast_anytime = 1
	cast(atom/target)
		if (..())
			return 1

		var/message = html_encode(input("Choose something to say:","Enter Message.","") as null|text)
		if (!message)
			return
		logTheThing(LOG_SAY, holder.owner, "[message]")
		.= holder.owner.say_kudzu(message, holder)

		return 0

/datum/targetable/kudzu/seed
	name = "Manipulate Seed"
	desc = "Create or manipulate a plant seed by using the resources available to the kudzu!"
	icon_state = "seed"
	targeted = 0
	cooldown = 1 MINUTES
	pointCost = 40

	//This is basically all stolen from the seedplanter item.
	cast(atom/T)
		var/datum/controller/process/kudzu/K = get_master_kudzu_controller()
		var/power = 1
		if (istype(K))
			var/count = length(K.kudzu)
			//The seeds available are based on the size of the kudzu. Doing a switch in case I want to add more levels later, idk. Could get whacky with it.
			switch (count)
				if (-INFINITY to 100)
					power = 1
				if (101 to 250)
					power = 2
				if (250 to INFINITY)
					power = 3
			DEBUG_MESSAGE("[holder.owner] used make seed when kudzu was [count].")

		var/obj/item/seed/S = holder.owner.equipped()
		if (istype(S))
			return manipulate(S, power, holder.owner)
		else
			return create(power)

	proc/manipulate(var/obj/item/seed/S, var/power as num, var/mob/user)
		if (!istype(S)) return //Should never happen but byond has ruined me.

		var/datum/plantgenes/DNA = S.plantgenes

		var/amount = 5 + (power - 1)*5			//if power is 1, amount is 5| if power is 2, amount is 10| if power is 3, amount is 15
		var/max_gene_amt = 25 * power			//75 at max
		var/choice = input("What do you want to do with this seed.", "Seed Manipulation", "Potency") in list("Mend Seed", "Maturation Rate", "Production Rate", "Lifespan", "Yield", "Potency", "Endurance")

		if (isnull(choice))
			return 1

		if (choice == "Mend Seed")
			S.seeddamage = max(S.seeddamage - amount*2, 0)
			boutput(user, "<span class='notice'>You heal the cute little [S] in your hand.</span>")
			return

		//Can't raise the value past the max_gene_amt which is 25, 50, 75; based on size of the kudzu growth
		switch (choice)
			if ("Maturation Rate")
				DNA.growtime += min(DNA.growtime + amount, max_gene_amt)
			if ("Production Rate")
				DNA.harvtime += min(DNA.harvtime + amount, max_gene_amt)
			if ("Lifespan")
				DNA.harvests += min(DNA.harvests + amount, max_gene_amt)
			if ("Yield")
				DNA.cropsize += min(DNA.cropsize + amount, max_gene_amt)
			if ("Potency")
				DNA.potency += min(DNA.potency + amount, max_gene_amt)
			if ("Endurance")
				DNA.endurance += min(DNA.endurance + amount, max_gene_amt)

		boutput(user, "<span class='notice'>You try to manipulate [S]'s [choice] gene on a molecular level.</span>")
		return 0

	proc/create(var/power as num)
		//lifted from the portable seed fab
		var/list/usable = list()
		for(var/datum/plant/A in hydro_controls.plant_species)
			if (istype(A, /datum/plant/maneater))
				//No maneaters for now, I'm afraid.
				continue

			//Yeah, I know this can look better. But I'm thinking I might throw these numbers and values out and set up a new thing for it so I'm doing this for now.
			if (A.vending == 0 && power == 3)
				usable += A
			else if (A.vending == 1 && power >= 1)
				usable += A
			else if (A.vending == 2 && power >= 2)
				usable += A

		var/datum/plant/pick = input(holder.owner, "Which seed do you want?", "Portable Seed Fabricator", null) in usable

		if (pick)
			var/obj/item/seed/S
			if (pick.unique_seed)
				S = new pick.unique_seed(holder.owner.loc)
			else
				S = new /obj/item/seed(holder.owner.loc,0)
			S.generic_seed_setup(pick)
			holder.owner.put_in_hand_or_drop(S)

		return 0

/datum/targetable/kudzu/growth
	name = "Growth"
	desc = "Encourage rapid growth of plant life! Use on the ground to make kudzu and on plant pots to add nutrients!"
	icon_state = "growth"
	targeted = 1
	target_anything = 1
	cooldown = 15 SECONDS
	pointCost = 25
	max_range = 1

	cast(atom/target)
		//For giving nutrients to plantpots
		if (istype(target, /obj/machinery/plantpot) && target.reagents)
			//replace with kudzu_nutrients when I make it. should be a good thing for plants, maybe kinda good for man.
			target.reagents.add_reagent("poo", 60)
			target.reagents.add_reagent("water", 60)
			boutput(holder.owner, "<span class='notice'>You release some nutrients into [target].</span>")
			return 0

		//For spreading kudzu growth
		var/turf/T = get_turf(target)
		if (isturf(T))
			if (T.density)
				boutput(holder.owner, "<span class='alert'>The kudzu can't seem to find purchase on this turf!</span>")
				return 1
			//all the objects that kudzu can't grow on. Sans other kudzu turfs, cause we have a special interaction for that.
			for (var/obj/O in T.contents)
				if (istype(O, /obj/window) || istype(O, /obj/forcefield) || istype(O, /obj/blob)|| istype(O, /obj/kudzu_marker))
					boutput(holder.owner, "<span class='alert'>The kudzu can't seem to find purchase on this turf!</span>")
					return 1


			var/obj/spacevine/kudzu_tile = locate(/obj/spacevine) in T.contents
			//If used on a current tile, call update_self() and give em more to_spread
			if (istype(kudzu_tile))
				kudzu_tile.growth += 10
				kudzu_tile.to_spread += 8
				kudzu_tile.update_self()

				for (var/obj/spacevine/other_kudzu in oview(T, 1))
					other_kudzu.growth += 5
					other_kudzu.to_spread += 5
					other_kudzu.update_self()

				boutput(holder.owner, "<span class='notice'>You mentally redirect some nutrients towards [kudzu_tile] to help it and the surrounding kudzu grow.</span>")
			else
				new/obj/spacevine/living(loc=T, to_spread=5)
				boutput(holder.owner, "<span class='notice'>Some of the kudzu soaked in nutrients attached to your body detaches and finds a new home on [T].</span>")


/datum/targetable/kudzu/vine_appendage
	name = "Use-Vine"
	desc = "Manipulate your surroundings with a vine!"
	icon_state = "vine-0"		//	and "vine-1"
	targeted = 0
	cooldown = 0
	pointCost = 0
	check_range = 0
	special_screen_loc = "WEST,CENTER+3"
	var/obj/item/kudzu/kudzumen_vine/vine = null
	var/active = 0

	New(var/datum/abilityHolder/kudzu/holder)
		..(holder)

		vine = new/obj/item/kudzu/kudzumen_vine(holder?.owner)		//make the vine item in

	cast()
		var/mob/owner = holder?.owner
		if (!istype(owner))
			logTheThing(LOG_DEBUG, null, "no owner for this kudzu ability. [src]")
			return 1
		//turn on
		if (!active)
			//if you can't drop the item in the active hand, just gotta show em an error.
			var/obj/item/I = owner.equipped()
			if (I?.cant_drop)
				boutput(owner, "<span class='alert'>You're holding [I] in your hand, but you can't drop it, it's preventing you from controlling your vine.</span>")
				return 1

			//Try to put the vine in their hand. If it fails, try to drop the item and put it in their hand after. If that fails, you're fucked.
			var/success = owner.put_in_hand(vine)
			if (success)
				active = 1
				icon_state = "vine-1"
				return 0
			else
				owner.drop_item()
				var/success2 = owner.put_in_hand(vine)
				if (success2)
					active = 1
					icon_state = "vine-1"
					return 0	//we're done successfully
				else
					boutput(owner, "Something weird happened, you tried to pick up [vine], but no. Call 1-800-CODER.")
					return 1

		//turn off
		else
			if (holder?.owner.is_in_hands(vine))
				return attempt_vine_drop(vine, owner)
			else
				//if it's not in their hands, where it should be, check if it's in their contents, if not fail.
				var/obj/item/kudzu/kudzumen_vine/V = locate(/obj/item/kudzu/kudzumen_vine) in holder?.owner.contents
				if (istype(V))
					return attempt_vine_drop(V, owner)

				else
					boutput(owner, "Can't find your vine to put away. Call 1-800-CODER.")
					return 1


	//I know. success = 0 and failure = 1. Ask whoever wrote ability casts.
	proc/attempt_vine_drop(var/obj/item/kudzu/kudzumen_vine/V, var/mob/owner)
		//Total hack. Must think of a better way to do this one day. But not today.
		V.cant_drop = 0
		var/success = owner.drop_item(V)
		V.cant_drop = 1
		if (success)
			active = 0
			icon_state = "vine-0"
			return 0
		else
			return 1

/atom/movable/screen/kudzu
	var/datum/abilityHolder/kudzu/holder

	New(var/datum/abilityHolder/kudzu/holder)
		..()
		src.holder = holder

/atom/movable/screen/kudzu/meter
	icon = 'icons/misc/32x64.dmi'
	icon_state = "viney-0"
	name = "Nutrients Meter"
	screen_loc = "WEST,CENTER+5"
	var/theme = null // for wire's tooltips, it's about time this got varized
	var/cur_meter_location = 0
	var/last_meter_location = 0			//the amount of points at the last update. Used for deciding when to redraw the sprite to have less progress

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

	proc/update()		//getting weird numbers in here
		cur_meter_location = clamp(round((max(holder?.points,0)/holder?.MAX_POINTS)*11), 0, 11)	//length of meter
		if (cur_meter_location != last_meter_location)
			src.icon_state ="viney-[cur_meter_location]"

		last_meter_location = cur_meter_location

/atom/movable/screen/kudzu/growth_amount
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "kudzu-indicator"
	name = "Kudzu Growth"
	screen_loc = "WEST,CENTER+4"
	var/theme = null // for wire's tooltips, it's about time this got varized
	var/datum/controller/process/kudzu/kudzu_controller
	var/amount = 0

	New(var/datum/abilityHolder/kudzu/holder, var/datum/controller/process/kudzu/K)
		..(holder)
		if (istype(K))
			kudzu_controller = K
			amount = length(K.kudzu)
		else
			boutput(usr, "messed up kudzu controller call 1-800-CODER")
			logTheThing(LOG_DEBUG, null, "Messed up kudzu controller for kudzuman")

	disposing()
		kudzu_controller = null
		..()

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			var/theme = src.theme

			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = "Size of Kudzu Growth",
				"content" = "[amount] tiles",
				"theme" = theme
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

	proc/update()
		amount = length(kudzu_controller.kudzu)

		if (amount <= 99)
			src.maptext = "<div style='font-size:14px; color:maroon;text-align:center;'>[amount]</div>"
			src.maptext_y = 4
		else if (amount <= 999)
			src.maptext = "<div style='font-size:10px; color:maroon;text-align:center;'>[amount]</div>"
			src.maptext_y = 8
		else if (amount <= 9999)
			src.maptext = "<div style='font-size:8px; color:maroon;text-align:center;'>[amount]</div>"
			src.maptext_y = 8
		else
			src.maptext = "<div style='font-size:8px; color:maroon;text-align:center;'>+</div>"
			src.maptext_y = 8

//This will be the hud element that contains a vine thingy which covers up the left and right hand hud ui elements
/atom/movable/screen/kudzu/vine_hands_cover
	icon = 'icons/misc/kudzu_plus.dmi'		//probably 64x32 later
	icon_state = "kudzu-template"
	name = "Kudzu Growth"
	screen_loc = "WEST,CENTER+4"
	var/theme = null // for wire's tooltips, it's about time this got varized
	var/amount = 0


/obj/item/kudzu/kudzumen_vine
	name = "vine"
	desc = "It's a vine attached to a kudzuperson."
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "vine-item"
	// inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	// item_state = "knife"
	force = 5
	throwforce = 5
	throw_range = 5
	hit_type = DAMAGE_BLUNT
	burn_type = 1
	stamina_damage = 30
	stamina_cost = 15
	stamina_crit_chance = 50
	cant_self_remove = 1
	cant_other_remove = 1
	cant_drop = 1		//if they drop it, we'll just try to find the ability holder, otherwise, destroy itself. Non-kudzumen shouldn't see this item.

	New()
		..()
		src.build_buttons()
		src.setItemSpecial(/datum/item_special/rangestab)

	dropped(mob/user)
		..()
		if (iskudzuman(user))
			src.set_loc(user)
			boutput(user, "<span class='notice'>[src] wraps back around your body, giving you a snuggly hug.</span>")

			//This isn't supposed to be dropped. We'll try to cast the ability to sync it if it does though.
			// //find abilityholder and cast ability to put it back in the guy.
			// var/datum/abilityHolder/kudzu/KH = user.get_ability_holder(/datum/abilityHolder/kudzu)
			// if (istype(KH))
			// 	var/datum/targetable/kudzu/vine_appendage/VA = KH.getAbility(/datum/targetable/kudzu/vine_appendage)
			// 	VA.cast()
		else
			boutput(user, "<span class='alert'>[src] breaks apart in your hands.</span>")
			qdel(src)

	attack(mob/M, mob/user, def_zone, is_special = 0)
		..()

		if (prob(20))
			var/turf/target = get_edge_target_turf(user, get_dir(user, M))
			user.visible_message("<span class='alert'>[user] sends [M] flying with mighty oak-like strength!</span>")
			M.throw_at(target, 5, 1)

/obj/item/kudzu/kudzumen_vine/proc/build_buttons()
	if (src.contextActions != null)	//dont need rebuild
		return
	src.contextActions = list() //empty list would mean we are ready for deconstruction. otherwise you need to clear contexts by tool usage
	contextActions += new/datum/contextAction/kudzu/plantpot()
	contextActions += new/datum/contextAction/kudzu/plantmaster()
	return 1


/datum/action/bar/icon/kudzu_shaping
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "kudzu_shaping"
	icon = 'icons/ui/actions.dmi'
	icon_state = "kudzu_shaping"
	var/obj/item/kudzu/kudzumen_vine/vine_arm
	var/obj/spacevine/kudzu
	var/creation_path

	New(var/obj/spacevine/kudzu, var/obj/item/kudzu/kudzumen_vine/vine_arm, var/creation_path, var/extra_time as num)
		src.kudzu = kudzu
		src.vine_arm = vine_arm
		src.creation_path = creation_path
		if (!ispath(creation_path))
			boutput(owner, "Invalid creation object path. Call 1-800-CODER")
			interrupt(INTERRUPT_ALWAYS)
			return
		duration += extra_time

		..()

	onUpdate()
		..()
		if(BOUNDS_DIST(owner, kudzu) > 0 || kudzu == null || kudzu.growth < 20 || owner == null)	//20 growth is currently the lowest for dense kudzu. Should be a constant.
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if(BOUNDS_DIST(owner, kudzu) > 0 ||  kudzu == null || kudzu.growth < 20 || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()
		if(BOUNDS_DIST(owner, kudzu) > 0 || kudzu == null || kudzu.growth < 20 || owner == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (!iskudzuman(owner))
			boutput(owner, "You're not a kudzuman, you can't bend the kudzu to your will!")
			interrupt(INTERRUPT_ALWAYS)
			return

		kudzu.growth = 1
		kudzu.update_self()
		new creation_path(get_turf(kudzu))


	onInterrupt()
		if (kudzu && owner)
			boutput(owner, "<span class='alert'>Your kudzu shaping was interrupted!</span>")
		..()


//O is obj to be destroyed, W is obj used to destroy.
//This is total shit too, but I'm in a hurry again. I'll be back, -Kyle
/proc/destroys_kudzu_object(var/obj/O, var/obj/item/W as obj, var/mob/user)
	return istool(W, TOOL_CUTTING | TOOL_SAWING | TOOL_SCREWING | TOOL_SNIPPING | TOOL_WELDING)
