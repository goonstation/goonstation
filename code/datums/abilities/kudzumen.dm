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
	var/obj/screen/kudzu/growth_amount/growth_amt = null

	var/const/MAX_POINTS = 100

	New()
		..()
		if (owner.client)
			nutrients_meter = new/obj/screen/kudzu/meter(src)
			nutrients_meter.add_to_client(owner.client)

			growth_amt = new/obj/screen/kudzu/growth_amount(get_master_kudzu_controller())
			growth_amt.add_to_client(owner.client)

	disposing()
		qdel(nutrients_meter)
		qdel(growth_amt)
		..()

	onAbilityStat()
		..()
		return

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

/datum/targetable/kudzu/seed
	name = "Manipulate Seed"
	desc = "Create or manipulate a plant seed by using the resources available to the kudzu!"
	icon_state = "seec"
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
	icon_state = "seec"
	targeted = 1
	target_anything = 1
	cooldown = 15 SECONDS
	pointCost = 40
	max_range = 2

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

			var/obj/spacevine/kudzu_tile = locate(/obj/spacevine) in T.contents
			//If used on a current tile, call update_self() and give em more to_spread
			if (istype(kudzu_tile))
				kudzu_tile.growth += 10
				kudzu_tile.to_spread += 5
				kudzu_tile.update_self()

				for (var/obj/spacevine/other_kudzu in oview(T, 1))
					other_kudzu.growth += 5
					other_kudzu.to_spread += 2
					other_kudzu.update_self()

				boutput(holder.owner, "<span class='notice'>You mentally redirect some nutrients towards [kudzu_tile] to help it and the surrounding kudzu grow.</span>")
			else
				new/obj/spacevine/living(location=T, to_spread=4)
				boutput(holder.owner, "<span class='notice'>Some of the kudzu soaked in nutrients attached to your body detaches and finds a new home on [T].</span>")

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

	proc/update()		//getting weird numbers in here
		cur_meter_location = clamp(round((max(holder.points,0)/holder.MAX_POINTS)*11), 0, 11)	//length of meter
		if (cur_meter_location != last_meter_location)
			src.icon_state ="viney-[cur_meter_location]"

		last_meter_location = cur_meter_location

/obj/screen/kudzu/growth_amount
	icon = 'icons/misc/kudzu_plus.dmi'
	icon_state = "kudzu-template"
	name = "Kudzu Growth"
	screen_loc = "WEST,CENTER+4"
	var/theme = null // for wire's tooltips, it's about time this got varized
	var/datum/controller/process/kudzu/kudzu_controller
	var/amount = 0

	New(var/datum/controller/process/kudzu/K)
		if (istype(K))
			kudzu_controller = K
			amount = length(K.kudzu)
		else
			boutput(usr, "messed up kudzu controller call 1-800-CODER")
			logTheThing("debug", null, null, "Messed up kudzu controller for kudzuman")

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

		if (amount > 9999)
			src.maptext = "<div style='font-size:20px; color:maroon;text-align:center;'>+</div>"
			src.maptext_y = 2
		else if (amount > 999)
			src.maptext = "<div style='font-size:10px; color:maroon;text-align:center;'>[amount]</div>"
			src.maptext_y = 8
		else
			src.maptext = "<div style='font-size:7px; color:maroon;text-align:center;'>[amount]</div>"
			src.maptext_y = 10
