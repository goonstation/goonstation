///How much food, by bites_left, the medimulcher can hold in its 'stomach' at once
#define MDM_MAX_STOMACH 120
///How many digested nutrients (1 per bites_left) the medimulcher needs to produce an anticyst (healing "patch") for you
#define MDM_CYST_COST 35
///Amount of digested nutrients the medimulcher can hold at one time
#define MDM_MAX_DIGESTION 160

///A prototypist "artifact reverse-engineer" reward: hybridized Martian tech turning food into synthflesh "patches"
/obj/machinery/medimulcher
	name = "\improper APS-4 bio-integrator"
	desc = "According to the label, eats food and turns it into medicine. According to your eyes, possibly a crime against nature."
	icon = 'icons/obj/manufacturer.dmi'
	icon_state = "medimulcher"
	anchored = ANCHORED
	density = 1
	flags = NOSPLASH
	power_usage = 600
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR

	///Current amount of held food.
	var/stomach = 0
	///Cumulative progress - can pop out 1 anticyst per 100 progress.
	var/digestion_progress = 0

	//Overlay sprites
	var/image/status_light = null
	var/image/fill_bar = null

	///"Stop poking me" tracker - to not get bit if you're just poking it a little
	var/last_poke_time = null

	///If you poke it too much, it's not just going to nibble
	var/grouchy_meter = 0

	///Rolling counter to facilitate responsive overlay updates
	var/last_ratio = 0

	New()
		..()
		src.status_light = image('icons/obj/manufacturer.dmi', "")
		src.fill_bar = image('icons/obj/manufacturer.dmi', "")
		SPAWN(0)
			src.overlay_refresh()

	proc/overlay_refresh()
		if (!(status & NOPOWER) && !(status & BROKEN))
			if(digestion_progress >= MDM_CYST_COST) //ready to dispense? green light
				src.status_light.icon_state = "mdm-stat-ready"
			else if(stomach > 0) //not ready to dispense, but fed? yellow light
				src.status_light.icon_state = "mdm-stat-working"
			else //not ready to dispense, no food, but powered? red light
				src.status_light.icon_state = "mdm-stat-empty"

			var/ratio = min(1, src.stomach / MDM_MAX_STOMACH)
			ratio = round(ratio, 0.2) * 100
			src.fill_bar.icon_state = "mdm-fill-[ratio]"

			src.UpdateOverlays(src.status_light, "statlight")
			src.UpdateOverlays(src.fill_bar, "fillbar")
		else
			src.UpdateOverlays(null, "statlight")
			src.UpdateOverlays(null, "fillbar")

	attack_hand(mob/user)
		src.add_fingerprint(user)

		if (src.digestion_progress >= MDM_CYST_COST && !(status & (BROKEN|NOPOWER)))
			src.digestion_progress -= MDM_CYST_COST
			var/obj/item/I = new /obj/item/reagent_containers/patch/synthetic
			playsound(src.loc, 'sound/impact_sounds/Glub_2.ogg', 80, 1)
			boutput(user, SPAN_NOTICE("[src] dispenses a small glob.[prob(10) ? " Grody." : null]"))
			user.put_in_hand_or_drop(I)
		else
			if(ishuman(user) && last_poke_time && (last_poke_time + 1 SECOND > world.time))
				boutput(user, SPAN_ALERT("You poke [src] trying to get it to do something."))
				src.grouchy_meter = min(src.grouchy_meter + 2,100)
				if (prob(15) && !ON_COOLDOWN(src,"bit_a_nerd",2 SECONDS)) //don't keep poking at it when it's not ready to glob you.
					var/mob/living/carbon/human/H = user
					var/can_bite_off = FALSE
					if(H.hand)
						can_bite_off = !!(H.limbs.l_arm)
					else
						can_bite_off = !!(H.limbs.r_arm)
					if(prob(src.grouchy_meter) && can_bite_off)
						if(H.hand)
							H.limbs.l_arm.delete()
						else
							H.limbs.r_arm.delete()
						src.stomach = min(src.stomach + 20, MDM_MAX_STOMACH)
						playsound(user.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 75)
						boutput(user, SPAN_COMBAT("<font size='5'>[src] lashes out and bites off your arm!</font>"))
						H.emote("scream")
						H.changeStatus("stunned", 5 SECONDS)
						H.changeStatus("knockdown", 5 SECONDS)
					else
						var/limb_to_ouch = H.hand ? "l_arm" : "r_arm"
						var/howmuchbite = rand(3,5)
						src.stomach = min(src.stomach + howmuchbite, MDM_MAX_STOMACH)
						H.TakeDamage(limb_to_ouch, howmuchbite*3)
						playsound(user.loc, 'sound/impact_sounds/Flesh_Crush_1.ogg', 75)
						boutput(user, SPAN_COMBAT("[src] lashes out and gnaws on your arm! [prob(50) ? "Holy shit!" : "What the fuck?"]"))
			else
				boutput(user, SPAN_ALERT("[src] doesn't respond."))
			src.last_poke_time = TIME

	attackby(obj/item/W, mob/user)
		if (istype(W,/obj/item/reagent_containers/food/snacks))
			if(src.try_food_load(W,user))
				boutput(user, SPAN_NOTICE("[src]'s loading hatch accepts [W]."))
			else
				boutput(user, SPAN_ALERT("[src] can't accept any more food."))
		else ..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isliving(user))
			boutput(user, SPAN_ALERT("As unnatural as this device may be, it cannot yet interface with the dead."))
			return
		if (BOUNDS_DIST(user, src) > 0)
			// You have to be adjacent to the mulcher,
			boutput(user, SPAN_ALERT("You need to move closer to [src] to do that."))
			return
		if (BOUNDS_DIST(O, user) > 0)
			// and to the loaded items
			boutput(user, SPAN_ALERT("[O] is too far away to load into [src]."))
			return
		if (istype(O, /obj/item/reagent_containers/food/snacks))
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [O] into [src]."))
			var/staystill = user.loc
			for(var/obj/item/P in view(1,user))
				if (user.loc != staystill) break
				if (!(istype(P,/obj/item/reagent_containers/food/snacks))) continue
				if (!src.try_food_load(P))
					boutput(user, SPAN_ALERT("[src] is full."))
					break
				sleep(0.3 SECONDS)
			boutput(user, SPAN_NOTICE("You finish stuffing [O] into [src]."))
		else ..()

	///Helper proc to load one piece of food into the machine. Returns FALSE if machine is full
	proc/try_food_load(var/obj/item/reagent_containers/food/snacks/snaq, var/mob/user)
		. = FALSE
		if(src.stomach < MDM_MAX_STOMACH)
			. = TRUE
			src.stomach = src.stomach + snaq.bites_left
			var/ratio = min(1, src.stomach / MDM_MAX_STOMACH)
			ratio = round(ratio, 0.25) * 100
			if(ratio != src.last_ratio)
				src.overlay_refresh()
			src.last_ratio = ratio
			//this may go above the defined limit slightly if last fed item is large, this is not a bad thing. digester has a little wiggle room.
			playsound(src.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 30, 1)
			if(user)
				user.u_equip(snaq)
				snaq.dropped(user)
			qdel(snaq)
		return

	power_change()
		src.overlay_refresh()

	process()
		if (status & (BROKEN|NOPOWER))
			return

		if (src.stomach <= 0 || src.digestion_progress >= MDM_MAX_DIGESTION)
			return

		var/digest_amt = rand(2,5)
		digest_amt = min(src.stomach,digest_amt,(MDM_MAX_DIGESTION - src.digestion_progress))
		src.stomach -= digest_amt
		src.digestion_progress += digest_amt
		src.overlay_refresh()

		playsound(src.loc, 'sound/effects/leakagentb.ogg', 20, 1)
		FLICK("medimulcher-munch",src)
		..()
