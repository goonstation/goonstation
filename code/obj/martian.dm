/obj/decal/aliencomputer
	name ="Strange Computer"
	desc ="This appears to be some sort of martian computer. The display is in an incomprehensible language."
	icon = 'icons/turf/martian.dmi'
	icon_state = "display_scroll"
	anchored = 1

/obj/crevice
	name ="Mysterious Crevice"
	desc = "Perhaps you shouldn't stick your hand in."
	icon = 'icons/turf/martian.dmi'
	icon_state = "crevice0"
	anchored = 1
	var/used = 0
	var/id = null

/obj/crevice/attack_hand(var/mob/user)
	if(..())
		return
	if(used)
		return
	playsound(src.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
	boutput(user, "<span class='alert'>You reach your hand into the crevice.</span>")

	if(id)
		for(var/obj/machinery/door/unpowered/martian/D in by_type[/obj/machinery/door])
			D.locked = !D.locked
		boutput(user, "<span class='notice'>You push down on something.</span>")
		return
	else if(prob(10))
		boutput(user, "<span class='alert'><B>Something has clamped down on your hand!</B></span>")
		user.changeStatus("stunned", 10 SECONDS)
		SPAWN(3 SECONDS)
			if(prob(25))
				boutput(user, "<span class='alert'><B>You fail to break free!</B></span>")
				sleep(1 SECONDS)
				playsound(src.loc, 'sound/voice/burp_alien.ogg', 50, 1)
				var/obj/decal/cleanable/blood/gibs/gib =make_cleanable( /obj/decal/cleanable/blood/gibs/core, src.loc )
				gib.streak_cleanable(src.dir)
				gib = make_cleanable( /obj/decal/cleanable/blood/gibs, src.loc )
				gib.streak_cleanable(src.dir)
				if (ishuman(user))
					var/mob/living/carbon/human/H = user
					var/datum/human_limbs/HL = H.limbs
					HL.sever("both_arms", user)
				else
					logTheThing(LOG_COMBAT, user, "was gibbed by [src] ([src.type]) at [log_loc(user)].")
					user.gib()
				icon_state = "crevice1"
				desc = "The crevice has closed"
				used = 1
				return
			else
				boutput(user, "<span class='alert'>You manage to pull out your hand!</span>")
				user.changeStatus("stunned", -10 SECONDS)
				user.TakeDamage("All", 20, 0, DAMAGE_STAB)
				var/obj/decal/cleanable/blood/gibs/gib =make_cleanable( /obj/decal/cleanable/blood/gibs, src.loc )
				gib.streak_cleanable(user.dir)

	else if(prob(60))
		boutput(user, "<span class='alert'>You pull something out!</span>")
		var/itemtype = pick(/obj/item/reagent_containers/glass/wateringcan/artifact,/obj/item/artifact/forcewall_wand,/obj/item/strange_candle,/mob/living/critter/small_animal/cat,/obj/item/skull,/obj/item/gnomechompski,/obj/item/bat,/obj/critter/meatslinky,/obj/item/paint_can,/obj/item/mine/stun)
		new itemtype(src.loc)
		var/obj/decal/cleanable/blood/gibs/gib =make_cleanable( /obj/decal/cleanable/blood/gibs, src.loc )
		gib.streak_cleanable(user.dir)
	else
		boutput(user, "<span class='alert'>There doesn't appear to be anything inside</span>")
		var/obj/decal/cleanable/blood/gibs/gib =make_cleanable( /obj/decal/cleanable/blood/gibs, src.loc )
		gib.streak_cleanable(user.dir)
	icon_state = "crevice1"
	used = 1
	desc = "The crevice has closed"
