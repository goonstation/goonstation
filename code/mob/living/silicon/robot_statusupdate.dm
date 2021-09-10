/datum/lifeprocess/robot_statusupdate
	process(var/datum/gas_mixture/environment)
		if(!robot_owner.part_chest)
				// this doesn't even make any sense unless you're rayman or some shit

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[owner]</b> falls apart with no chest to keep it together!")
				logTheThing("combat", robot_owner, null, "was destroyed at [log_loc(robot_owner)].") // Brought in line with carbon mobs (Convair880).

				if (robot_owner.part_arm_l)
					if (robot_owner.part_arm_l.slot == "arm_both")
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_l.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
				if (robot_owner.part_arm_r)
					if (robot_owner.part_arm_r.slot == "arm_both")
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_l = null
						robot_owner.part_arm_r = null
					else
						robot_owner.part_arm_r.set_loc(robot_owner.loc)
						robot_owner.part_arm_r = null

				if (robot_owner.part_leg_l)
					if (robot_owner.part_leg_l.slot == "leg_both")
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
						robot_owner.part_leg_r = null
					else
						robot_owner.part_leg_l.set_loc(robot_owner.loc)
						robot_owner.part_leg_l = null
				if (robot_owner.part_leg_r)
					if (robot_owner.part_leg_r.slot == "leg_both")
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null
						robot_owner.part_leg_l = null
					else
						robot_owner.part_leg_r.set_loc(robot_owner.loc)
						robot_owner.part_leg_r = null

				if (robot_owner.part_head)
					robot_owner.part_head.set_loc(robot_owner.loc)
					robot_owner.part_head = null
					//no chest means you are dead. Placed here to avoid duplicate alert in event that head was already destroyed and you then destroy torso
					robot_owner.borg_death_alert()

				if (robot_owner.client)
					var/mob/dead/observer/newmob = robot_owner.ghostize()
					if (newmob)
						newmob.corpse = null

				new /obj/item/parts/robot_parts/robot_frame(get_turf(robot_owner))

				qdel(robot_owner)

			else if (!robot_owner.part_head && robot_owner.client)
				// no head means no brain!!

				if (robot_owner.mind && robot_owner.mind.special_role)
					robot_owner.handle_robot_antagonist_status("death", 1) // Mindslave or rogue (Convair880).

				robot_owner.visible_message("<b>[owner]</b> completely stops moving and shuts down...")
				robot_owner.borg_death_alert()
				logTheThing("combat", owner, null, "was destroyed at [log_loc(robot_owner)].") // Ditto (Convair880).

				var/mob/dead/observer/newmob = robot_owner.ghostize()
				if (newmob)
					newmob.corpse = null
