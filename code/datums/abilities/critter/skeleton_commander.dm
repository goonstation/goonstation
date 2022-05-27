////////////////////////////////
// Skeleton commander abilities
////////////////////////////////
/datum/targetable/critter/skeleton_commander/rally
	name = "rally"
	desc = "rally"
	icon_state = "rally"
	cooldown = 60 SECONDS
	targeted = 0
	//Todo add unique overlay and/or sound on use.
	//List of critters we can buff, same as the one the wraith portal has.
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"
	var/list/critter_list = list(/obj/critter/shade,
	/obj/critter/crunched,
	/obj/critter/ancient_thing,
	/obj/critter/ancient_repairbot/security,
	/obj/critter/gunbot/drone/buzzdrone,
	/obj/critter/mechmonstrositycrawler,
	/obj/critter/bat/buff,
	/obj/critter/lion,
	/obj/critter/wraithskeleton,
	/obj/critter/gunbot/heavy,
	/obj/critter/bear,
	/obj/critter/brullbar,
	/obj/critter/gunbot/drone)

	cast()
		if (..())
			return 1

		var/list/obj/critter/affected_critter = list()
		for (var/obj/critter/C in range(6, get_turf(holder.owner)))
			logTheThing("debug", src, null, "init spin")
			for (var/O in critter_list)
				logTheThing("debug", src, null, "spin")
				if (istype(C, O))
					logTheThing("debug", src, null, "Affected")
					C.atk_delay = (C.atk_delay / 1.5)
					C.atk_brute_amt = (C.atk_brute_amt * 1.5)
					C.atk_burn_amt = (C.atk_burn_amt * 1.5)
					affected_critter += C
		SPAWN(25 SECOND)
			for (var/obj/critter/C in affected_critter)
				if (C.loc)
					C.atk_delay = (C.atk_delay * 1.5)
					C.atk_brute_amt = (C.atk_brute_amt / 1.5)
					C.atk_burn_amt = (C.atk_burn_amt / 1.5)

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton
	name = "summon lesser skeleton"
	desc = "rally"
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "skeleton"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast(atom/target)
		if (..())
			return 1
		var/turf/T = get_turf(target)
		if (isturf(T))
			var/obj/critter/wraithskeleton/S = new /obj/critter/wraithskeleton(T)
			S.alpha = 0
			animate(S, alpha=255, time=2 SECONDS)
			playsound(S.loc, "sound/voice/wraith/wraithhaunt.ogg", 80, 0)
			S.visible_message("<span class='alert'>[holder.owner] raises its arms and a skeleton appears in front of your eyes!</span>")
			boutput(holder.owner, "We summon a skeleton from the void")
			SPAWN(30 SECONDS)
				animate(S, alpha=0, time=2 SECONDS)
				SPAWN(2 SECONDS)
					qdel(S)
		else
			boutput(holder.owner, "We cannot summon a skeleton here")
			return 1

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
