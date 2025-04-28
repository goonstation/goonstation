TYPEINFO(/obj/submachine/chef_sink)
	mats = 12

/obj/submachine/chef_sink
	name = "kitchen sink"
	desc = "A water-filled unit intended for cookery purposes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = NOSPLASH

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour))
			user.show_text("You add water to the flour to make dough!", "blue")
			if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour/semolina))
				new /obj/item/reagent_containers/food/snacks/ingredient/dough/semolina(src.loc)
			else
				new /obj/item/reagent_containers/food/snacks/ingredient/dough(src.loc)
			qdel (W)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/rice))
			user.show_text("You add water to the rice to make sticky rice!", "blue")
			new /obj/item/reagent_containers/food/snacks/ingredient/sticky_rice(src.loc)
			qdel(W)
		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/) || istype(W, /obj/item/reagent_containers/balloon/) || istype(W, /obj/item/soup_pot))
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too full already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You fill [W] with water.", "blue")
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 100, 1)
		else if (istype(W, /obj/item/mop)) // dude whatever
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too wet already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You wet [W].", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/GRAB = W
			if (ismob(GRAB.affecting))
				if (GRAB.state >= 1 && istype(GRAB.affecting, /mob/living/critter/small_animal))
					var/mob/M = GRAB.affecting
					var/mob/A = GRAB.assailant
					if (BOUNDS_DIST(src.loc, M.loc) > 0)
						return
					user.visible_message(SPAN_NOTICE("[A] shoves [M] in the sink and starts to wash them."))
					M.set_loc(src.loc)
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					actions.start(new/datum/action/bar/private/critterwashing(A,src,M,GRAB),user)
				else
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					user.visible_message(SPAN_NOTICE("[user] dunks [W:affecting]'s head in the sink!"))
					GRAB.affecting.lastgasp() // --BLUH
		else if (istype(W, /obj/item/gun/sprayer))
			var/obj/item/gun/sprayer/sprayer = W
			sprayer.clogged = FALSE
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			boutput(user, SPAN_NOTICE("You clean out [W]'s nozzle."))
		else if (W.burning)
			W.combust_ended()
		else
			user.visible_message(SPAN_NOTICE("[user] cleans [W]."))
			W.clean_forensic() // There's a global proc for this stuff now (Convair880).
			if (istype(W, /obj/item/device/key/skull))
				W.icon_state = "skull"
			if (istype(W, /obj/item/reagent_containers/mender))
				var/obj/item/reagent_containers/mender/automender = W
				if(automender.borg)
					return
			if (W.reagents && W.is_open_container())
				W.reagents.clear_reagents()		// avoid null error

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = get_weakref(src)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.gloves)
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				user.visible_message(SPAN_NOTICE("[user] cleans [his_or_her(user)] gloves."))
				if (H.sims?.getValue("Hygiene"))
					user.show_text("If you want to improve your hygiene, you need to remove your gloves first.")
				H.gloves.clean_forensic() // Ditto (Convair880).
				H.set_clothing_icon_dirty()
			else
				if(H.sims?.getValue("Hygiene"))
					if (H.sims.getValue("Hygiene") >= SIMS_HYGIENE_THRESHOLD_MESSY)
						user.visible_message(SPAN_NOTICE("[user] starts washing [his_or_her(user)] hands."))
						actions.start(new/datum/action/bar/private/handwashing(user,src),user)
						return ..()
					else
						user.show_text("You're too messy to improve your hygiene this way, you need a shower or a bath.", "red")
				//simpler handwashing if hygiene isn't a concern
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
				user.visible_message(SPAN_NOTICE("[user] washes [his_or_her(user)] hands."))
				H.blood_DNA = null
				H.blood_type = null
				H.forensics_blood_color = null
				H.set_clothing_icon_dirty()
		..()

/datum/action/bar/private/handwashing
	duration = 1 SECOND //roughly matches the rate of manual clicking
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/living/carbon/human/user
	var/obj/submachine/chef_sink/sink

	New(usermob,sink)
		user = usermob
		src.sink = sink
		..()

	proc/checkStillValid()
		if(BOUNDS_DIST(user, sink) > 1 || user == null || sink == null || user.l_hand || user.r_hand)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE

	onUpdate()
		checkStillValid()
		..()

	onStart()
		..()
		if(BOUNDS_DIST(user, sink) > 1) user.show_text("You're too far from the sink!")
		if(user.l_hand || user.r_hand) user.show_text("Both your hands need to be free to wash them!")
		src.loopStart()


	loopStart()
		..()
		if(!checkStillValid()) return
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)

	onEnd()
		if(!checkStillValid())
			..()
			return

		var/cleanup_rate = 2
		if(user.traitHolder.hasTrait("training_medical") || user.traitHolder.hasTrait("training_chef"))
			cleanup_rate = 3
		user.sims.affectMotive("Hygiene", cleanup_rate)
		user.blood_DNA = null
		user.blood_type = null
		user.forensics_blood_color = null
		user.set_clothing_icon_dirty()

		src.onRestart()

	onInterrupt()
		..()


/datum/action/bar/private/critterwashing
	duration = 7 DECI SECONDS
	var/mob/living/carbon/human/user
	var/obj/submachine/chef_sink/sink
	var/mob/living/critter/small_animal/victim
	var/obj/item/grab/grab
	var/datum/aiTask/timed/wandering
	New(usermob,sink,critter,thegrab)
		src.user = usermob
		src.sink = sink
		src.victim = critter
		src.grab = thegrab
		..()

	proc/checkStillValid()
		if(GET_DIST(victim, sink) > 0 || BOUNDS_DIST(user, sink) > 1 || victim == null || user == null || sink == null || !grab)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE
	onStart()
		if(BOUNDS_DIST(user, sink) > 1) user.show_text("You're too far from the sink!")
		if (istype(victim, /mob/living/critter/small_animal/cat) && victim.ai?.enabled)
			victim._ai_patience_count = 0
			victim.was_harmed(user)
			victim.visible_message(SPAN_NOTICE("[victim] resists [user]'s attempt to wash them!"))
			playsound(victim.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)

		else if (victim.ai?.enabled && istype(victim.ai.current_task, /datum/aiTask/timed/wander) )
			victim.ai.wait(5)
		..()

	loopStart()
		..()
		if (!checkStillValid())
			return
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
		if(prob(50))
			animate_door_squeeze(victim)
		else
			animate_smush(victim, 0.65)


	onEnd()
		if(!checkStillValid())
			..()
			return
		victim.blood_DNA = null
		victim.blood_type = null
		victim.forensics_blood_color = null
		victim.set_clothing_icon_dirty()

		src.onRestart()
