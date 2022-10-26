// -----------------
// vomit, copy paste from bigpuke sorta
// -----------------
/datum/targetable/critter/vomit
	name = "Vomit"
	desc = "BLARF"
	icon_state = "puke"
	cooldown = 30 SECONDS
	targeted = 1
	target_anything = 1

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/affected_turfs = getline(holder.owner, T)
		var/range = 1

		holder.owner.visible_message("<span class='alert'><b>[holder.owner] pukes!</b></span>")
		logTheThing(LOG_COMBAT, holder.owner, "power-pukes [log_reagents(holder.owner)] at [log_loc(holder.owner)].")
		playsound(holder.owner.loc, 'sound/misc/meat_plop.ogg', 50, 0)
		holder.owner.reagents.add_reagent("vomit",20)
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(holder.owner))
				continue
			if (GET_DIST(holder.owner,F) > range)
				continue
			holder.owner.reagents.reaction(F,TOUCH)
			for(var/mob/living/L in F.contents)
				logTheThing(LOG_COMBAT, holder.owner, L, "power-pukes [log_reagents(holder.owner)] onto [constructTarget(L, "combat")] at [log_loc(holder.owner)].")
				holder.owner.reagents.reaction(L,TOUCH)
			for(var/obj/O in F.contents)
				holder.owner.reagents.reaction(O,TOUCH)
		holder.owner.reagents.clear_reagents()

		return 0





