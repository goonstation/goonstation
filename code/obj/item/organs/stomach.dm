/obj/item/organ/stomach
	name = "stomach"
	organ_name = "stomach"
	desc = "A little meat sack containing acid for the digestion of food. Like most things that come out of living creatures, you can probably eat it."
	organ_holder_name = "stomach"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 4
	icon_state = "stomach"
	fail_damage = 100
	///How much food can we fit, based on `fill_amt` var on food items
	var/capacity = 7
	///How much food and other stuff we have (also based on `fill_amt`)
	var/food_amount = 0
	///Stomach contents are actually stored in the mob so that things like matsci effects work
	VAR_PRIVATE/atom/movable/stomach_contents = list()
	///Amount of reagents we digest from each bite per life tick, also how fast the bites dissolve
	var/digestion_per_tick = 3

	on_transplant()
		..()
		for (var/atom/movable/AM in src.stomach_contents)
			AM.set_loc(src.donor)
		if (src.is_full())
			src.donor.setStatus("full")

	on_removal()
		for (var/atom/movable/AM in src.stomach_contents)
			AM.set_loc(src) // take them with us
		src.donor.delStatus("full")
		..()

	attackby(obj/item/W, mob/user)
		if (iscuttingtool(W))
			user.visible_message("<span class='alert'>[user] starts cutting [src] open!")
			SETUP_GENERIC_ACTIONBAR(user, src, 4 SECONDS, PROC_REF(cut_open), list(), W.icon, W.icon_state, "[user] cuts [src] open, spilling its contents everywhere!", INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION)
			return
		. = ..()

	proc/cut_open()
		for (var/atom/movable/AM in src.stomach_contents)
			AM.set_loc(get_turf(src))
		src.stomach_contents = null
		src.splat(get_turf(src))
		qdel(src)

	///How much does this thing fill a stomach
	proc/food_value(atom/movable/AM)
		if (istype(AM, /obj/item/reagent_containers/food))
			var/obj/item/reagent_containers/food/food = AM
			return food.fill_amt
		else
			return 1 //other stuff can clog your stomach

	proc/consume(atom/movable/AM)
		if (AM in src.stomach_contents)
			return
		AM.set_loc(src.donor)
		src.stomach_contents |= AM
		src.food_amount += src.food_value(AM)
		if (src.is_full())
			src.donor.setStatus("full")

	proc/eject(atom/movable/AM)
		if (!(AM in src.stomach_contents))
			return
		AM.set_loc(src.donor.loc)
		src.stomach_contents -= AM
		src.food_amount -= src.food_value(AM)
		if (!src.is_full())
			src.donor.delStatus("full")

	proc/vomit()
		if (!length(src.stomach_contents))
			return null
		var/atom/movable/AM = pick(src.stomach_contents)
		src.eject(AM)
		return AM

	proc/is_full()
		return src.food_amount > src.capacity

	//get_fullness was taken
	proc/calculate_fullness()
		. = 0
		for (var/atom/movable/thing in src.stomach_contents)
			if (istype(thing, /obj/item/reagent_containers/food))
				var/obj/item/reagent_containers/food/food = thing
				. += food.fill_amt
			else
				. += 1 //other stuff can clog your stomach

	on_life(var/mult = 1)
		if (!..())
			return 0
		src.handle_digestion(mult)

		// if (src.get_damage() >= fail_damage && prob(src.get_damage() * 0.2))
		// 	donor.contract_disease(failure_disease,null,null,1)
		return 1


	disposing()
		if (holder)
			if (holder.stomach == src)
				holder.stomach = null
		..()

	attackby(obj/item/W, mob/user)
		..()
		if (src.contents && length(src.contents) > 0 && istype(W, /obj/item/device/analyzer/healthanalyzer))
			var/output = ""
			var/list/L = list()
			for (var/obj/O in src.contents)
				L[O.name] ++

			for (var/S in L)
				output += "[S] = [L[S]]\n"
			boutput(user, "<br><span style='color:purple'><b>[src]</b> contains:\n [output]</span>")

	relaymove(mob/user, direction, delay, running)
		if(!prob(60) || !src.donor || !(user in src.stomach_contents))
			return
		src.donor.audible_message("<span class='alert'>You hear something rumbling inside [src.donor]'s stomach...</span>")
		var/obj/item/I = user.equipped()
		if(I?.force)
			var/d = rand(round(I.force / 4), I.force)
			src.donor.TakeDamage("chest", d, 0)
			src.donor.visible_message("<span class='alert'><B>[user] attacks [src.donor]'s stomach wall with \the [I.name]!</span>")
			playsound(user.loc, 'sound/impact_sounds/Slimy_Hit_3.ogg', 50, 1)

			if(prob(src.donor.get_brute_damage() - 50))
				logTheThing(LOG_COMBAT, user, "gibs [constructTarget(src.donor,"combat")] breaking out of their stomach at [log_loc(src.donor)].")
				src.donor.gib()

	proc/handle_digestion(mult = 1)
		if (!length(src.stomach_contents))
			return
		src.digest_food(mult)
		src.digest_mobs(mult)

	proc/digest_food(mult = 1)
		var/count_to_process = min(length(src.stomach_contents), 10)
		var/count_left = count_to_process
		for(var/obj/item/reagent_containers/food/food in src.stomach_contents)
			food.process_stomach(src.donor, (src.digestion_per_tick / count_to_process) * mult) //Takes an even amt of reagents from all stomach contents
			if(count_left-- <= 0)
				break

	///LOOK I'M ONLY REORGANISING THIS CODE OKAY, I AM NOT RESPONSIBLE FOR THIS DO NOT @ ME
	proc/digest_mobs(mult = 1)
		for (var/mob/M in src.stomach_contents)
			if (iscarbon(M) && !isdead(src.donor))
				if (isdead(M))
					M.death(TRUE)
					M.ghostize()
					qdel(M)
					src.donor.emote("burp")
					playsound(get_turf(src.donor), 'sound/voice/burp.ogg', 50, 1)
					continue
				if (air_master.current_cycle%3==1) //????
					if (!M.nodamage)
						M.TakeDamage("chest", 5, 0)
					src.donor.nutrition += 10

/obj/item/organ/stomach/synth
	name = "synthstomach"
	organ_name = "synthstomach"
	icon_state = "plant"
	desc = "Nearly functionally identical to a pitcher plant... weird."
	synthetic = 1
	New()
		..()
		src.icon_state = pick("plant_stomach", "plant_stomach_bloom")

TYPEINFO(/obj/item/organ/stomach/cyber)
	mats = 6

/obj/item/organ/stomach/cyber
	name = "cyberstomach"
	desc = "A fancy robotic stomach to replace one that someone's lost!"
	icon_state = "cyber-stomach"
	// item_state = "heart_robo1"
	default_material = "pharosium"
	robotic = 1
	created_decal = /obj/decal/cleanable/oil
	edible = 0
	capacity = 12

	on_transplant(mob/M)
		. = ..()
		if(!broken)
			ADD_STATUS_LIMIT(M, "Food", 6)

	on_removal()
		REMOVE_STATUS_LIMIT(src.donor, "Food")
		. = ..()

	unbreakme()
		if(..() && donor)
			ADD_STATUS_LIMIT(src.donor, "Food", 6)

	breakme()
		if(..() && donor)
			REMOVE_STATUS_LIMIT(src.donor, "Food")

	emag_act(mob/user, obj/item/card/emag/E)
		. = ..()
		organ_abilities = list(/datum/targetable/organAbility/projectilevomit)

	demag(mob/user)
		..()
		organ_abilities = initial(organ_abilities)
