
/datum/lifeprocess/stuns_lying
	var/last_recovering_msg = 0

	process()
		//proc/handle_stuns_lying(datum/controller/process/mobs/parent)
		var/lying_old = owner.lying
		var/cant_lie = robot_owner || hivebot_owner || (human_owner && (human_owner.limbs && istype(human_owner.limbs.l_leg, /obj/item/parts/robot_parts/leg/left/treads) && istype(human_owner.limbs.r_leg, /obj/item/parts/robot_parts/leg/right/treads) && !locate(/obj/table, human_owner.loc) && !locate(/obj/machinery/optable, human_owner.loc)))

		var/list/statusList = owner.getStatusList()

		var/must_lie = statusList["resting"] || (!cant_lie && human_owner && human_owner.limbs && !human_owner.limbs.l_leg && !human_owner.limbs.r_leg) //hasn't got a leg to stand on... haaa

		if (!owner.can_lie)
			cant_lie = 1
			must_lie = 0

		if (!isdead(owner)) //Alive.
			var/changeling_fakedeath = 0
			var/datum/abilityHolder/changeling/C = owner.get_ability_holder(/datum/abilityHolder/changeling)
			if (C?.in_fakedeath)
				changeling_fakedeath = 1

			if (statusList["paralysis"] || statusList["stunned"] || statusList["weakened"] || statusList["pinned"] || changeling_fakedeath || statusList["resting"]) //Stunned etc.
				var/setStat = owner.stat
				var/oldStat = owner.stat
				if (statusList["stunned"])
					setStat = 0
				if (statusList["weakened"] || statusList["pinned"] && !owner.fakedead)
					if (!cant_lie)
						owner.lying = 1
					setStat = 0
				if (statusList["paralysis"])
					if (!cant_lie)
						owner.lying = 1
					setStat = 1
				if (isalive(owner) && setStat == 1 && owner.mind)
					owner.lastgasp() // calling lastgasp() here because we just got knocked out
				if (must_lie)
					owner.lying = 1

				owner.stat = setStat
				owner.empty_hands()

				if (world.time - last_recovering_msg >= 60 || last_recovering_msg == 0)
					if (prob(10))
						last_recovering_msg = world.time
						//chance to heal self by minute amounts each 'recover' tick
						owner.take_oxygen_deprivation(-0.3)
						owner.lose_breath(-0.3)
						owner.HealDamage("All", 0.2, 0.2, 0.2)

				else if ((oldStat == 1) && (!statusList["paralysis"] && !statusList["stunned"] && !statusList["weakened"] && !changeling_fakedeath))
					owner << sound('sound/misc/molly_revived.ogg', volume=50)
					setalive(owner)

			else	//Not stunned.
				owner.lying = must_lie ? 1 : 0
				setalive(owner)

		else //Dead.
			owner.lying = cant_lie ? 0 : 1
			owner.blinded = 1
			setdead(owner)

		if (owner.lying != lying_old)
			owner.update_lying()
			owner.set_density(!owner.lying)

			if (owner.lying && !owner.buckled)
				if (human_owner)
					playsound(owner.loc, 'sound/misc/body_thud.ogg', 40, 1, 0.3)
				else
					playsound(owner.loc, 'sound/misc/body_thud.ogg', 15, 1, 0.3)
		..()
