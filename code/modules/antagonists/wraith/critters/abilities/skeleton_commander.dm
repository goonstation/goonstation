/datum/targetable/critter/skeleton_commander/rally
	name = "rally"
	desc = "Buff all surrounding critters to help you fight."
	icon_state = "rally"
	cooldown = 60 SECONDS
	targeted = 0
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
	/mob/living/critter/lion,
	/mob/living/critter/skeleton/wraith,
	/obj/critter/gunbot/heavy,
	/mob/living/critter/bear,
	/mob/living/critter/brullbar,
	/obj/critter/gunbot/drone)

	cast()
		if (..())
			return 1

		playsound(holder.owner.loc, 'sound/effects/ghostbreath.ogg', 80, 0)
		holder.owner.visible_message("<span class='alert'>[holder.owner] emits a rallying howl!</span>")

		for (var/obj/critter/C in by_cat[TR_CAT_CRITTERS])
			if (!IN_RANGE(holder.owner, C, 6)) continue
			if (istypes(C, critter_list))
				C.setStatus("skeleton_rallied", 25 SECONDS)

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/skeleton_commander/summon_lesser_skeleton
	name = "summon lesser skeleton"
	desc = "Materialize a skeleton from the void to help you."
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
			var/mob/living/critter/skeleton/wraith/S = new /mob/living/critter/skeleton/wraith(T)
			S.alpha = 0
			animate(S, alpha=255, time=2 SECONDS)
			playsound(S.loc, 'sound/voice/wraith/wraithhaunt.ogg', 40, 0)
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
