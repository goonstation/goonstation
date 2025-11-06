// rest in peace the_very_holy_global_bible_list_amen (??? - 2020)

/obj/item/bible
	var/static/datum/forensic_holder/bible_forensics = new() // Each bible shares the same forensics, because why not?
	name = "bible"
	desc = "A holy scripture of some sort or another. Someone seems to have hollowed it out for hiding things in."
	icon = 'icons/obj/items/storage.dmi'
	icon_state ="bible"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE
	var/mob/affecting = null
	var/heal_amt = 5

	New()
		..()
		src.create_storage(/datum/storage/bible, max_wclass = W_CLASS_SMALL)
		START_TRACKING
		#ifdef SECRETS_ENABLED
		ritualComponent = new/datum/ritualComponent/sanctus(src)
		ritualComponent.autoActive = 1
		#endif
		BLOCK_SETUP(BLOCK_BOOK)
		src.forensic_holder = bible_forensics

	disposing()
		..()
		STOP_TRACKING

	proc/do_heal_amt(mob/user) // also handles using faith
		var/faith = get_chaplain_faith(user)
		var/used_faith = min(faith * FAITH_HEAL_USE_FRACTION, FAITH_HEAL_CAP)
		modify_chaplain_faith(user, -used_faith)
		return heal_amt + used_faith * FAITH_HEAL_BONUS + rand(-3, 3)

	proc/do_heal_message(var/mob/user, var/mob/target, amount)
		switch(amount)
			if (1 to 8)
				target.visible_message(SPAN_ALERT("<B>[user] heals [target] mending [his_or_her(target)] wounds!</B>"))
			if (9 to 15)
				target.visible_message(SPAN_ALERT("<B>[user] heals [target] with the power of Christ!</B>"))
			if (16 to 24)
				target.visible_message(SPAN_ALERT("<B>[user] heals [target] by the will of the LORD!</B>"))
			if (25 to INFINITY)
				target.visible_message(SPAN_ALERT("<B>[user] heals [target] in service of heaven!</B>"))

	proc/bless(mob/M as mob, var/mob/user)
		if (isvampire(M) || isvampiricthrall(M) || iswraith(M) || M.bioHolder.HasEffect("revenant"))
			M.visible_message(SPAN_ALERT("<B>[M] burns!"))
			var/zone = "chest"
			if (user.zone_sel)
				zone = user.zone_sel.selecting
			M.TakeDamage(zone, 0, do_heal_amt(user))
			JOB_XP(user, "Chaplain", 2)
		else
			var/mob/living/H = M
			if( istype(H) )
				if( prob(25) )
					H.delStatus("bloodcurse")
					H.cure_disease_by_path(/datum/ailment/disease/cluwneing_around/cluwne)
				if(prob(25))
					H.cure_disease_by_path(/datum/ailment/disability/clumsy/cluwne)
				//Wraith curses
				if(prob(75) && ishuman(H))
					var/mob/living/carbon/human/target = H
					if(target.bioHolder?.HasEffect("blood_curse") || target.bioHolder?.HasEffect("blind_curse") || target.bioHolder?.HasEffect("weak_curse") || target.bioHolder?.HasEffect("rot_curse") || target.bioHolder?.HasEffect("death_curse"))
						target.bioHolder.RemoveEffect("blood_curse")
						target.bioHolder.RemoveEffect("blind_curse")
						target.bioHolder.RemoveEffect("weak_curse")
						target.bioHolder.RemoveEffect("rot_curse")
						target.bioHolder.RemoveEffect("death_curse")
						target.visible_message("[target] screams as some black smoke exits their body.")
						target.emote("scream")
						var/turf/T = get_turf(target)
						if (T && isturf(T))
							var/datum/effects/system/bad_smoke_spread/S = new /datum/effects/system/bad_smoke_spread/(T)
							if (S)
								S.set_up(5, 0, T, null, "#000000")
								S.start()
			var/heal = do_heal_amt(user)
			M.HealDamage("All", heal, heal)
			do_heal_message(user, M, heal)
			if (!ON_COOLDOWN(src, "faith_sound", 1.5 SECONDS))
				SPAWN(1 DECI SECOND)
					playsound(src.loc, 'sound/effects/faithbiblewhack.ogg', 10, FALSE, -1, (rand(94,108)/100))
			if(prob(30 + heal))
				JOB_XP(user, "Chaplain", 1)

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/bible))
			user.show_text("You try to put \the [W] in \the [src]. It doesn't work. You feel dumber.", "red")
		else
			..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		var/chaplain = 0
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
			chaplain = 1
		if (!chaplain)
			boutput(user, SPAN_ALERT("The book sizzles in your hands."))
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 10)
			return
		var/faith = get_chaplain_faith(user)
		if (user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message(SPAN_ALERT("<b>[user]</b> fumbles and drops [src] on [his_or_her(user)] foot."))
			random_brute_damage(user, 10)
			user.changeStatus("stunned", 3 SECONDS)
			JOB_XP(user, "Clown", 1)
			return

		if (iswraith(target) || (target.bioHolder && target.bioHolder.HasEffect("revenant")))
			target.visible_message(SPAN_ALERT("<B>[user] smites [target] with the [src]!</B>"))
			bless(target, user)
			boutput(target, "<span_class='alert'><B>IT BURNS!</B></span>")
			logTheThing(LOG_COMBAT, user, "biblically smote [constructTarget(target,"combat")]")

		else if (!isdead(target))
			// ******* Check
			var/is_undead = isvampire(target) || iswraith(target) || target.bioHolder.HasEffect("revenant")
			var/is_atheist = target.traitHolder?.hasTrait("atheist")
			if (ishuman(target) && prob(FAITH_HEAL_CHANCE + faith * FAITH_HEAL_CHANCE_MOD) && !(is_atheist && !is_undead))
				bless(target, user)
				var/deity = is_atheist ? "a god you don't believe in" : "Christ"
				boutput(target, SPAN_ALERT("May the power of [deity] compel you to be healed!"))
				var/healed = is_undead ? "damaged undead" : "healed"
				logTheThing(LOG_COMBAT, user, "biblically [healed] [constructTarget(target,"combat")]")

			else
				var/damage = 10 - clamp(target.get_melee_protection("head", DAMAGE_BLUNT) - 1, 0, 10)
				if (is_atheist)
					damage /= 2

				target.take_brain_damage(damage)
				boutput(target, SPAN_ALERT("You feel dazed from the blow to the head."))
				logTheThing(LOG_COMBAT, user, "biblically injured [constructTarget(target,"combat")]")
				target.visible_message(SPAN_ALERT("<B>[user] beats [target] over the head with [src]!</B>"))

		else if (isdead(target))
			target.visible_message(SPAN_ALERT("<B>[user] smacks [target]'s lifeless corpse with [src].</B>"))

		playsound(src.loc, "punch", 25, 1, -1)

		return

	attack_hand(var/mob/user)
		if (isvampire(user) || user.bioHolder.HasEffect("revenant"))
			user.visible_message(SPAN_ALERT("<B>[user] tries to take the [src], but their hand bursts into flames!</B>"), SPAN_ALERT("<b>Your hand bursts into flames as you try to take the [src]! It burns!</b>"))
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 25)
			user.changeStatus("stunned", 15 SECONDS)
			user.changeStatus("knockdown", 15 SECONDS)
			return
		return ..()

	custom_suicide = 1
	suicide_distance = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!farting_allowed)
			return 0

		user.u_equip(src)
		src.layer = initial(src.layer)
		src.set_loc(user.loc)
		return farty_heresy(user)

	///Called when someone farts on a bible. Return TRUE if we killed them, FALSE otherwise.
	proc/farty_heresy(mob/user)
		if(!user || user.loc != src.loc)
			return FALSE

		if (farty_party)
			user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>The gods seem to approve.</b>"))
			return FALSE

		if (user.traitHolder?.hasTrait("atheist"))
			user.visible_message(SPAN_ALERT("[user] farts on the bible with particular vindication.<br><b>Against all odds, [user] remains unharmed!</b>"))
			return FALSE
		else if (ishuman(user) && user:unkillable)
			user.visible_message(SPAN_ALERT("[user] farts on the bible."))
			user:unkillable = 0
			user.UpdateOverlays(image('icons/misc/32x64.dmi',"halo"), "halo")
			heavenly_spawn(user)
			user?.gib()
			return TRUE
		else
			smite(user)
			return TRUE

	proc/smite(mob/M)
		M.visible_message(SPAN_ALERT("[M] farts on the bible.<br><b>A mysterious force smites [M]!</b>"))
		logTheThing(LOG_COMBAT, M, "farted on [src] at [log_loc(src)] last touched by <b>[src.fingerprintslast ? src.fingerprintslast : "unknown"]</b>.")
		M.smite_gib()

/obj/item/bible/evil
	name = "frayed bible"
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE

	Crossed(atom/movable/AM as mob)
		..()
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.emote("fart")

/obj/item/bible/mini
	//Grif
	name = "O.C. Bible"
	desc = "For when you don't want the good book to take up too much space in your life."
	icon_state = "minibible"
	item_state = null
	w_class = W_CLASS_SMALL

	farty_heresy(mob/user) //fuk u always die
		if(!user || user.loc != src.loc)
			return FALSE

		if(..())
			return TRUE

		user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>A mysterious force smites [user]!</b>"))
		logTheThing(LOG_COMBAT, user, "farted on [src] at [log_loc(src)] last touched by <b>[src.fingerprintslast ? src.fingerprintslast : "unknown"]</b>.")
		smite(user)
		return TRUE

/obj/item/bible/hungry
	name = "hungry bible"
	desc = "Huh."

	custom_suicide = 1
	suicide_distance = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (!farting_allowed)
			return 0
		if (farty_party)
			user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>The gods seem to approve.</b>"))
			return 0
		user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>A mysterious force smites [user]!</b>"))
		user.u_equip(src)
		src.layer = initial(src.layer)
		src.set_loc(user.loc)
		var/list/gibz = user.gib(0, 1)
		SPAWN(3 SECONDS)//this code is awful lol.
			for( var/i = 1, i <= 500, i++ )
				for( var/obj/gib in gibz )
					if(!gib.loc) continue
					step_to( gib, src )
					if( GET_DIST( gib, src ) == 0 )
						animate( src, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 3 )
						qdel( gib )
						if(prob( 50 )) playsound( get_turf( src ), 'sound/voice/burp.ogg', 10, 1 )
				sleep(0.3 SECONDS)
		return 1
	farty_heresy(var/mob/user)
		if (farty_party)
			user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>The gods seem to approve.</b>"))
			return 0
		user.visible_message(SPAN_ALERT("[user] farts on the bible.<br><b>A mysterious force smites [user]!</b>"))
		user.u_equip(src)
		src.layer = initial(src.layer)
		src.set_loc(user.loc)
		var/list/gibz = user.gib(0, 1)
		SPAWN(3 SECONDS)//this code is awful lol.
			for( var/i = 1, i <= 50, i++ )
				for( var/obj/gib in gibz )
					step_to( gib, src )
					if( GET_DIST( gib, src ) == 0 )
						animate( src, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 3 )
						qdel( gib )
						if(prob( 50 )) playsound( get_turf( src ), 'sound/voice/burp.ogg', 10, 1 )
				sleep(0.3 SECONDS)
		return 1

/obj/item/bible/loaded

	New()
		..()
		new /obj/item/gun/kinetic/faith(src)
		desc += " This is the chaplain's personal copy."

	get_desc()
		. = ..()
		if (locate(/obj/item/gun/kinetic/faith) in src.contents)
			. += " It feels a bit heavier than it should."

	attack_hand(mob/user)
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain") && user.is_in_hands(src))
			var/obj/item/gun/kinetic/faith/F = locate() in src.contents
			if(F)
				user.put_in_hand_or_drop(F)
				return
		..()

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W,/obj/item/gun/kinetic/faith))
			if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
				user.u_equip(W)
				W.set_loc(src)
				user.show_text("You hide [W] in \the [src].", "blue")
				return
		..()
