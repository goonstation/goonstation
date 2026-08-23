
/datum/lifeprocess/stuns_lying
	var/last_recovering_msg = 0

	process()
		//proc/handle_stuns_lying(datum/controller/process/mobs/parent)
		var/lying_old = owner.lying
		var/cant_lie = (owner.buckled && !istype(owner.buckled, /obj/stool/bed)) || robot_owner || hivebot_owner || istype(owner.loc, /obj/machinery/atmospherics/unary/cryo_cell)|| (human_owner && (human_owner.limbs && (istype(human_owner.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/treads) || istype(human_owner.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/treads)) && !locate(/obj/table, human_owner.loc) && !locate(/obj/machinery/optable, human_owner.loc)))

		var/list/statusList = owner.getStatusList()

		var/must_lie = !cant_lie && (statusList["resting"] || istype(owner?.buckled, /obj/stool/bed))

		if (!owner.can_lie)
			cant_lie = TRUE
			must_lie = FALSE

		if(cant_lie && statusList["resting"])
			owner.delStatus("resting")
			statusList -= "resting"

		if (!isdead(owner)) //Alive.
			var/changeling_fakedeath = FALSE
			var/datum/abilityHolder/changeling/C = owner.get_ability_holder(/datum/abilityHolder/changeling)
			if (C?.in_fakedeath)
				changeling_fakedeath = TRUE

			if (statusList["unconscious"] || statusList["stunned"] || statusList["knockdown"] || statusList["pinned"] || statusList["paralysis"] || changeling_fakedeath || must_lie) //Stunned etc.
				var/setStat = owner.stat
				var/oldStat = owner.stat
				if (statusList["stunned"])
					setStat = STAT_ALIVE
				if (statusList["knockdown"] || statusList["pinned"])
					if (!cant_lie)
						owner.lying = TRUE
					setStat = STAT_ALIVE
				if (statusList["unconscious"])
					if (!cant_lie)
						owner.lying = TRUE
					setStat = STAT_UNCONSCIOUS
				if (isalive(owner) && setStat == STAT_UNCONSCIOUS && owner.mind)
					owner.lastgasp() // calling lastgasp() here because we just got knocked out
				if (must_lie)
					owner.lying = TRUE

				owner.stat = setStat
				owner.empty_hands()

				if (world.time - last_recovering_msg >= 60 || last_recovering_msg == 0)
					if (prob(10))
						last_recovering_msg = world.time
						//chance to heal self by minute amounts each 'recover' tick
						owner.take_oxygen_deprivation(-0.3)
						owner.lose_breath(-0.3)
						owner.HealDamage("All", 0.2, 0.2, 0.2)

				else if ((oldStat == STAT_UNCONSCIOUS) && (!statusList["unconscious"] && !statusList["stunned"] && !statusList["knockdown"] && !changeling_fakedeath))
					owner.playsound_local_not_inworld('sound/misc/molly_revived.ogg', 50)
					setalive(owner)

			else	//Not stunned.
				owner.lying = must_lie ? TRUE : FALSE
				setalive(owner)

		else //Dead.
			if (cant_lie || ismobcritter(owner))
				owner.lying = FALSE
			else
				owner.lying = TRUE
			owner.blinded = TRUE
			setdead(owner)

		if (owner.lying != lying_old)
			owner.update_lying()
			var/can_be_dense = initial(owner.density)
			if(ismobcritter(owner) && isdead(owner))
				can_be_dense = FALSE
			owner.set_density(!owner.lying && can_be_dense)

			if (owner.lying && !owner.buckled && !HAS_ATOM_PROPERTY(owner, PROP_MOB_SUPPRESS_LAYDOWN_SOUND))
				var/turf/T = get_turf(owner)
				var/sound_to_play = 'sound/misc/body_thud.ogg'
				if (T?.active_liquid && T.active_liquid.my_depth_level <= 3)
					T.active_liquid.Crossed(owner)
					sound_to_play = 'sound/misc/splash_2.ogg'
				else if(T?.active_liquid)
					sound_to_play = null
				if(sound_to_play)
					playsound(owner.loc, sound_to_play, human_owner ? 40 : 15, 1, 0.3)
		..()
