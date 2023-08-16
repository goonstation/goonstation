// rest in peace the_very_holy_global_bible_list_amen (??? - 2020)

/obj/item/bible
	name = "Holy Texts"
	desc = "A holy scripture of some kind."
	icon = 'icons/obj/items/chaplain/ChaplainStuff.dmi'
	icon_state ="bible"
	inhand_image_icon = 'icons/obj/items/chaplain/ChaplainStuff.dmi'
	item_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_NORMAL
	flags = FPRINT | TABLEPASS | NOSPLASH
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE
	custom_suicide = TRUE
	suicide_distance = 0
	var/mob/affecting = null
	var/heal_amt = 10
	/// does this bible have faith in it?
	var/loaded = FALSE
	/// is this bible opened within the hand?
	var/opened = FALSE
	/// the name of the kind of book, so that we can close it.
	var/unopened_icon_state = "bible"
	/// the name of the kind of inhand sprite used, so that we can close it again.
	var/unopened_item_state = "book"

	New()
		src.unopened_icon_state = src.icon_state
		src.unopened_item_state = src.item_state
		..()
		src.create_storage(/datum/storage/bible, max_wclass = W_CLASS_SMALL)
		START_TRACKING
		#ifdef SECRETS_ENABLED
		ritualComponent = new/datum/ritualComponent/sanctus(src)
		ritualComponent.autoActive = 1
		#endif
		BLOCK_SETUP(BLOCK_BOOK)

	disposing()
		..()
		STOP_TRACKING

	get_desc()
		. = ..()
		if (locate(/obj/item/gun/kinetic/faith) in src.contents)
			. += " It feels a bit heavier than it should."

	proc/bless(mob/M as mob, var/mob/user)
		if (isvampire(M) || isvampiricthrall(M) || iswraith(M) || M.bioHolder.HasEffect("revenant"))
			M.visible_message("<span class='alert'><B>[M] burns!</span>", 1)
			var/zone = "chest"
			if (user.zone_sel)
				zone = user.zone_sel.selecting
			M.TakeDamage(zone, 0, heal_amt)
			JOB_XP(user, "Chaplain", 2)
		else
			var/mob/living/H = M
			if(istype(H) )
				if(prob(25))
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
			M.HealDamage("All", heal_amt, heal_amt)
			if(prob(40))
				JOB_XP(user, "Chaplain", 1)

	attackby(var/obj/item/W, var/mob/user)
		if(istype(W,/obj/item/gun/kinetic/faith))
			if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
				user.u_equip(W)
				W.set_loc(src)
				user.show_text("You hide [W] in \the [src].", "blue")
				return
		else if (istype(W, /obj/item/bible))
			user.show_text("You try to put \the [W] in \the [src]. It doesn't work. You feel dumber.", "red")
		else
			..()

	attack(mob/M, mob/user)
		var/chaplain = FALSE
		if (user.traitHolder && user.traitHolder.hasTrait("training_chaplain"))
			chaplain = TRUE
		if (!chaplain)
			boutput(user, "<span class='alert'>The book sizzles in your hands.</span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 10)
			return
		if (user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
			user.visible_message("<span class='alert'><b>[user]</b> fumbles and drops [src] on [his_or_her(user)] foot.</span>")
			random_brute_damage(user, 10)
			user.changeStatus("stunned", 3 SECONDS)
			JOB_XP(user, "Clown", 1)
			return

		if (iswraith(M) || (M.bioHolder && M.bioHolder.HasEffect("revenant")))
			M.visible_message("<span class='alert'><B>[user] smites [M] with the [src]!</B></span>")
			bless(M, user)
			boutput(M, "<span_class='alert'><B>IT BURNS!</B></span>")
			logTheThing(LOG_COMBAT, user, "biblically smote [constructTarget(M,"combat")]")

		else if (!isdead(M))
			// ******* Check
			var/is_undead = isvampire(M) || iswraith(M) || M.bioHolder.HasEffect("revenant")
			var/is_atheist = M.traitHolder?.hasTrait("atheist")
			if (ishuman(M) && prob(60) && !(is_atheist && !is_undead))
				bless(M, user)
				M.visible_message("<span class='alert'><B>[user] heals [M] with the power of the gods!</B></span>")
				var/deity = is_atheist ? "a god you don't believe in" : "the gods"
				boutput(M, "<span class='alert'>May the power of [deity] compel you to be healed!</span>")
				var/healed = is_undead ? "damaged undead" : "healed"
				logTheThing(LOG_COMBAT, user, "biblically [healed] [constructTarget(M,"combat")]")

			else
				var/damage = 10 - clamp(M.get_melee_protection("head", DAMAGE_BLUNT) - 1, 0, 10)
				if (is_atheist)
					damage /= 2

				M.take_brain_damage(damage)
				boutput(M, "<span class='alert'>You feel dazed from the blow to the head.</span>")
				logTheThing(LOG_COMBAT, user, "biblically injured [constructTarget(M,"combat")]")
				M.visible_message("<span class='alert'><B>[user] beats [M] over the head with [src]!</B></span>")

		else if (isdead(M))
			M.visible_message("<span class='alert'><B>[user] smacks [M]'s lifeless corpse with [src].</B></span>")

		if (narrator_mode)
			playsound(src.loc, 'sound/vox/hit.ogg', 25, 1, -1)
		else
			playsound(src.loc, "punch", 25, 1, -1)

		return

	attack_hand(var/mob/user)
		if (isvampire(user) || user.bioHolder.HasEffect("revenant"))
			user.visible_message("<span class='alert'><B>[user] tries to take the [src], but their hand bursts into flames!</B></span>", "<span class='alert'><b>Your hand bursts into flames as you try to take the [src]! It burns!</b></span>")
			user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, 25)
			user.changeStatus("stunned", 15 SECONDS)
			user.changeStatus("weakened", 15 SECONDS)
			return
		else if (src.loaded && user.traitHolder && user.traitHolder.hasTrait("training_chaplain") && user.is_in_hands(src))
			var/obj/item/gun/kinetic/faith/F = locate() in src.contents
			if(F)
				user.put_in_hand_or_drop(F)
				return
		else
			. = ..()
			src.toggle_open()

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
			user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>The gods seem to approve.</b></span>")
			return FALSE

		if (user.traitHolder?.hasTrait("atheist"))
			user.visible_message("<span class='alert'>[user] farts on the [src] with particular vindication.<br><b>Against all odds, [user] remains unharmed!</b></span>")
			return FALSE
		else if (ishuman(user) && user:unkillable)
			user.visible_message("<span class='alert'>[user] farts on the [src].</span>")
			user:unkillable = FALSE
			user.UpdateOverlays(image('icons/misc/32x64.dmi',"halo"), "halo")
			heavenly_spawn(user)
			user?.gib()
			return TRUE
		else
			smite(user)
			return TRUE

	proc/smite(mob/M)
		M.visible_message("<span class='alert'>[M] farts on the [src].<br><b>A mysterious force smites [M]!</b></span>")
		logTheThing(LOG_COMBAT, M, "farted on [src] at [log_loc(src)] last touched by <b>[src.fingerprintslast ? src.fingerprintslast : "unknown"]</b>.")
		M.smite_gib()

	proc/toggle_open()
		if (src.opened)
			src.icon_state = src.unopened_icon_state
			src.item_state = src.unopened_item_state
			src.opened = FALSE
		else
			src.icon_state += "_Open"
			src.item_state += "_Open"
			src.opened = TRUE

/// evil trapped bible which forces people to fart
/obj/item/bible/evil
	name = "frayed Holy Texts"
	event_handler_flags = USE_FLUID_ENTER | IS_FARTABLE

	Crossed(atom/movable/AM as mob)
		..()
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			H.emote("fart")

/// syndicate item for killing people when they fart
/obj/item/bible/mini
	//Grif
	name = "O.C. Holy Texts"
	desc = "For when you don't want the good book to take up too much space in your life."
	icon_state = "mini"
	item_state = null
	w_class = W_CLASS_SMALL

	farty_heresy(mob/user) //fuk u always die
		if(!user || user.loc != src.loc)
			return FALSE

		if(..())
			return TRUE

		user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>A mysterious force smites [user]!</b></span>")
		logTheThing(LOG_COMBAT, user, "farted on [src] at [log_loc(src)] last touched by <b>[src.fingerprintslast ? src.fingerprintslast : "unknown"]</b>.")
		smite(user)
		return TRUE

/// this bible has a special property when fart gibbing people
/obj/item/bible/hungry
	name = "hungry Holy Texts"
	desc = "Huh."

	custom_suicide = TRUE
	suicide_distance = 0
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return FALSE
		if (!farting_allowed)
			return FALSE
		if (farty_party)
			user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>The gods seem to approve.</b></span>")
			return FALSE
		user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>A mysterious force smites [user]!</b></span>")
		user.u_equip(src)
		src.layer = initial(src.layer)
		src.set_loc(user.loc)
		var/list/gibz = user.gib(0, 1)
		SPAWN(3 SECONDS)//this code is awful lol.
			for(var/i = 1, i <= 500, i++)
				for( var/obj/gib in gibz)
					if(!gib.loc) continue
					step_to(gib, src)
					if( GET_DIST(gib, src) == 0 )
						animate(src, pixel_x = rand(-3,3), pixel_y = rand(-3,3), time = 3)
						qdel(gib)
						if(prob( 50 )) playsound( get_turf( src ), 'sound/voice/burp.ogg', 10, 1)
				sleep(0.3 SECONDS)
		return TRUE
	farty_heresy(var/mob/user)
		if (farty_party)
			user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>The gods seem to approve.</b></span>")
			return FALSE
		user.visible_message("<span class='alert'>[user] farts on the [src].<br><b>A mysterious force smites [user]!</b></span>")
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
		return TRUE

/obj/item/bible/loaded
	New()
		..()
		new /obj/item/gun/kinetic/faith(src)
		src.desc += " This is the chaplain's personal copy."

/obj/item/bible/blank
	name = "Blank Holy Text"
	desc = "Seems like a holy scripture of some kind, but it seems like you have to come up with the text yourself?"
	icon_state = "Blank"
	item_state = "BlankBook"

/obj/item/bible/eye
	name = "The Peer"
	desc = "A holy scripture of some kind. It seems to be looking into you."
	icon_state = "Eye"
	item_state = "EyeBook"

/obj/item/bible/eye/dark
	icon_state = "Eye_Dark"
	item_state = "EyeBook_Dark"

/obj/item/bible/green
	name = "\the Green Texts"
	icon_state = "Green"
	item_state = "GreenBook"

/obj/item/bible/purple
	name = "\the Purple Texts"
	icon_state = "Purple"
	item_state = "PurpleBook"

/obj/item/bible/blue
	name = "\the Blue Texts"
	icon_state = "Blue"
	item_state = "BlueBook"

/obj/item/bible/clown
	name = "\the Clown Compendium"
	desc = "A holy scripture... about clowns? There's something a bit unsettling about it."
	icon_state = "Clown"
	item_state = "ClownBook"

/obj/item/bible/clown/cluwne
	name = "\the Clown Compendium?"
	icon_state = "Cluwne"
	item_state = "CluwneBook"

/obj/item/bible/burned
	name = "scorched Holy Texts"
	desc = "Someone's set this on fire at some point. Should still work though."
	icon_state = "Burned"
	item_state = "BurnedBook"

/obj/item/bible/skeleton
	name = "\the Skeleton Scriptures"
	desc = "A strange holy text written in sharp spidery handwriting. There's something inhuman about it."
	icon_state = "Rubi_Skeleton"
	item_state = "Rubi_SkeletonBook"

/obj/item/bible/x
	icon_state = "Paco_X"
	item_state = "Paco_XBook"

/obj/item/bible/sulphur
	name = "Sacred Sulphuric Script"
	desc = "A holy scripture of some kind?"
	icon_state = "Sulphur"
	item_state = "SulphurBook"

/obj/item/bible/bluewhite
	icon_state = "Paco_BlueWhite"
	item_state = "" //todo
// note that redwhite open and bluewhite open are identical
/obj/item/bible/redwhite
	icon_state = "Paco_RedWhite"
	item_state = "" //todo

/obj/item/bible/redwhite/dark
	icon_state = "Paco_RedDark"
	item_state = "" //todo
