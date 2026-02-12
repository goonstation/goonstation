/obj/item/parts/robot_parts/robot_frame
	name = "robot frame"
	icon_state = "robo_suit"
	material_amt = ROBOT_FRAME_COST
	max_health = 5000
	/// This will make the borg a syndie one
	var/syndicate = FALSE
	var/emagged = 0
	var/freemodule = TRUE
	var/obj/item/parts/robot_parts/head/head = null
	var/obj/item/parts/robot_parts/chest/chest = null
	var/obj/item/parts/robot_parts/l_arm = null
	var/obj/item/parts/robot_parts/r_arm = null
	var/obj/item/parts/robot_parts/l_leg = null
	var/obj/item/parts/robot_parts/r_leg = null
	var/obj/item/organ/brain/brain = null
	appearance_flags = KEEP_TOGETHER

	New()
		..()
		src.icon_state = "robo_suit"; //The frame is the only exception for the composite item name thing.
		src.UpdateIcon()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if(!emagged)
			emagged = 1
			if (user)
				logTheThing(LOG_STATION, user, "emags a robot frame at [log_loc(user)].")
				boutput(user, SPAN_NOTICE("You short out the behavior restrictors on the frame's motherboard."))
			return 1
		else if(user)
			boutput(user, SPAN_ALERT("This frame's behavior restrictors have already been shorted out."))
		return 0

	demag(var/mob/user)
		if (!emagged)
			return 0
		if (user)
			user.show_text("You repair the behavior restrictors on the frame's motherboard.", "blue")
		emagged = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/parts/robot_parts/))
			var/obj/item/parts/robot_parts/P = W
			switch (P.slot)
				if ("head")
					if (src.head)
						boutput(user, SPAN_ALERT("There is already a head piece on the frame. If you want to remove it, use a wrench."))
						return
					var/obj/item/parts/robot_parts/head/H = P
					if (!H.brain && !H.ai_interface)
						boutput(user, SPAN_ALERT("You need to insert a brain or an AI interface into the head piece before attaching it to the frame."))
						return
					src.head = H

				if ("chest")
					if (src.chest)
						boutput(user, SPAN_ALERT("There is already a chest piece on the frame. If you want to remove it, use a wrench."))
						return
					var/obj/item/parts/robot_parts/chest/C = P
					if (!C.wires)
						boutput(user, SPAN_ALERT("You need to add wiring to the chest piece before attaching it to the frame."))
						return
					if (!C.cell)
						boutput(user, SPAN_ALERT("You need to add a power cell to the chest piece before attaching it to the frame."))
						return
					src.chest = C

				if ("l_arm")
					if (src.l_arm)
						boutput(user, SPAN_ALERT("There is already a left arm piece on the frame. If you want to remove it, use a wrench."))
						return
					src.l_arm = P

				if ("r_arm")
					if (src.r_arm)
						boutput(user, SPAN_ALERT("There is already a right arm piece on the frame. If you want to remove it, use a wrench."))
						return
					src.r_arm = P

				if ("arm_both")
					if (src.l_arm || src.r_arm)
						boutput(user, SPAN_ALERT("There is already an arm piece on the frame that occupies both arm mountings. If you want to remove it, use a wrench."))
						return
					src.l_arm = P
					src.r_arm = P

				if ("l_leg")
					if (src.l_leg)
						boutput(user, SPAN_ALERT("There is already a left leg piece on the frame. If you want to remove it, use a wrench."))
						return
					src.l_leg = P

				if ("r_leg")
					if (src.r_leg)
						boutput(user, SPAN_ALERT("There is already a right leg piece on the frame. If you want to remove it, use a wrench."))
						return
					src.r_leg = P

				if ("leg_both")
					if (src.l_leg || src.r_leg)
						boutput(user, SPAN_ALERT("There is already a leg piece on the frame that occupies both leg mountings. If you want to remove it, use a wrench."))
						return
					src.l_leg = P
					src.r_leg = P

				else
					boutput(user, SPAN_ALERT("You can't seem to fit this piece anywhere on the frame."))
					return

			playsound(src, 'sound/impact_sounds/Generic_Stab_1.ogg', 40, TRUE)
			boutput(user, SPAN_NOTICE("You add [P] to the frame."))
			user.drop_item()
			P.set_loc(src)
			src.UpdateIcon()

		if (istype(W, /obj/item/organ/brain))
			boutput(user, SPAN_ALERT("The brain needs to go in the head piece, not the frame."))
			return

		if (iswrenchingtool(W))
			var/list/actions = list("Do nothing")
			if(src.check_completion())
				actions.Add("Finish and Activate the Cyborg")
			if(src.r_leg)
				actions.Add("Remove the Right leg")
			if(src.l_leg)
				actions.Add("Remove the Left leg")
			if(src.r_arm)
				actions.Add("Remove the Right arm")
			if(src.l_arm)
				actions.Add("Remove the Left arm")
			if(src.head)
				actions.Add("Remove the Head")
			if(src.chest)
				actions.Add("Remove the Chest")
			if(!actions.len)
				boutput(user, SPAN_ALERT("You can't think of anything to do with the frame."))
				return

			var/action = tgui_input_list(user, "What do you want to do?", "Robot Frame", actions)
			if (!action)
				return
			if (action == "Do nothing")
				return
			if (BOUNDS_DIST(src.loc, user.loc) > 0 && !user.bioHolder.HasEffect("telekinesis"))
				boutput(user, SPAN_ALERT("You need to move closer!"))
				return

			switch(action)
				if("Finish and Activate the Cyborg")
					user.unlock_medal("Weird Science", 1)
					src.finish_cyborg()
				if("Remove the Right leg")
					src.r_leg?.set_loc( get_turf(src) )
					if (src.r_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.r_leg = null
				if("Remove the Left leg")
					src.l_leg?.set_loc( get_turf(src) )
					if (src.l_leg.slot == "leg_both")
						src.r_leg = null
						src.l_leg = null
					else src.l_leg = null
				if("Remove the Right arm")
					src.r_arm?.set_loc( get_turf(src) )
					if (src.r_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.r_arm = null
				if("Remove the Left arm")
					src.l_arm?.set_loc( get_turf(src) )
					if (src.l_arm.slot == "arm_both")
						src.r_arm = null
						src.l_arm = null
					else src.l_arm = null
				if("Remove the Head")
					src.head?.set_loc( get_turf(src) )
					src.head = null
				if("Remove the Chest")
					src.chest?.set_loc( get_turf(src) )
					src.chest = null
			playsound(src, 'sound/items/Ratchet.ogg', 40, TRUE)
			src.UpdateIcon()
			return

	update_icon()
		if(src.chest)
			src.UpdateOverlays(image('icons/mob/robots.dmi', "body-" + src.chest.appearanceString, FLOAT_LAYER, 2),"chest")
		else
			src.UpdateOverlays(null,"chest")

		if(src.head)
			src.UpdateOverlays(image('icons/mob/robots.dmi', "head-" + src.head.appearanceString, FLOAT_LAYER, 2),"head")
			var/image/smashed_image = null
			if (istype(src.head, /obj/item/parts/robot_parts/head/screen)) //ehhhh
				var/obj/item/parts/robot_parts/head/screen/screenhead = src.head
				if (screenhead.smashed)
					smashed_image = image('icons/mob/robots.dmi', "screen-smashed", dir = SOUTH)
			src.UpdateOverlays(smashed_image, "screen-smashed")
		else
			src.UpdateOverlays(null,"head")
			src.UpdateOverlays(null, "screen-smashed")

		if(src.l_leg)
			if(src.l_leg.slot == "leg_both")
				src.UpdateOverlays(image('icons/mob/robots.dmi', "leg-" + src.l_leg.appearanceString, FLOAT_LAYER, 2),"l_leg")
			else
				src.UpdateOverlays(image('icons/mob/robots.dmi', "l_leg-" + src.l_leg.appearanceString, FLOAT_LAYER, 2),"l_leg")
		else
			src.UpdateOverlays(null,"l_leg")

		if(src.r_leg)
			if(src.r_leg.slot == "leg_both")
				src.UpdateOverlays(image('icons/mob/robots.dmi', "leg-" + src.r_leg.appearanceString, FLOAT_LAYER, 2),"r_leg")
			else
				src.UpdateOverlays(image('icons/mob/robots.dmi', "r_leg-" + src.r_leg.appearanceString, FLOAT_LAYER, 2),"r_leg")
		else
			src.UpdateOverlays(null,"r_leg")

		if(src.l_arm)
			if(src.l_arm.slot == "arm_both")
				src.UpdateOverlays(image('icons/mob/robots.dmi', "arm-" + src.l_arm.appearanceString, FLOAT_LAYER, 2),"l_arm")
			else
				src.UpdateOverlays(image('icons/mob/robots.dmi', "l_arm-" + src.l_arm.appearanceString, FLOAT_LAYER, 2),"l_arm")
		else
			src.UpdateOverlays(null,"l_arm")

		if(src.r_arm)
			if(src.r_arm.slot == "arm_both")
				src.UpdateOverlays(image('icons/mob/robots.dmi', "arm-" + src.r_arm.appearanceString, FLOAT_LAYER, 2),"r_arm")
			else
				src.UpdateOverlays(image('icons/mob/robots.dmi', "r_arm-" + src.r_arm.appearanceString, FLOAT_LAYER, 2),"r_arm")
		else
			src.UpdateOverlays(null,"r_arm")

	proc/check_completion()
		if (src.chest && src.head)
			if (src.head.brain)
				return 1
			if (src.head.ai_interface)
				return 1
		return 0

	proc/finish_cyborg()
		var/mob/living/silicon/robot/borg = null
		borg = new /mob/living/silicon/robot(get_turf(src.loc),src,0,src.syndicate,src.emagged)
		// there was a big transferring list of parts from the frame to the compborg here at one point, but it didn't work
		// because the cyborg's process proc would kill it for having no chest piece set up after New() finished but
		// before it could get around to this list, so i tweaked their New() proc instead to grab all the shit out of
		// the frame before process could go off resulting in a borg that doesn't instantly die

		borg.name = "Cyborg"
		borg.real_name = "Cyborg"

		if (!src.head)
			// how the fuck did you even do this
			stack_trace("Attempted to finish a cyborg from borg frame [identify_object(src)] without a head. That's bad.")
			borg.death()
			qdel(src)
			return

		if(borg.part_head.brain?.owner?.key)
			var/obj/item/organ/brain/brain = borg.part_head.brain
			if(brain.owner.current)
				borg.gender = brain.owner.current.gender
				if(brain.owner.current.client)
					borg.lastKnownIP = brain.owner.current.client.address
			var/mob/M = find_ghost_by_key(brain.owner.key)
			if (!M) // if we couldn't find them (i.e. they're still alive), don't pull them into this borg
				src.visible_message(SPAN_ALERT("<b>[src]</b> remains inactive, as the conciousness associated with that brain could not be reached."))
				borg.death()
				qdel(src)
				return
			// job-banned, DNR, or cyber-incompatible
			if ((brain.owner && (jobban_isbanned(brain.owner.current,"Cyborg") || brain.owner.get_player().dnr)) || brain.cyber_incompatible)
				src.visible_message(SPAN_ALERT("The brain inside [src] disintegrates!"))
				borg.part_head.brain = null
				qdel(brain)
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(1, 0, src.loc)
				smoke.start()
				borg.death()
				qdel(src)
				return
			if (!isdead(M)) // so if they're in VR, the afterlife bar, or a ghostcritter
				boutput(M, SPAN_NOTICE("You feel yourself being pulled out of your current plane of existence!"))
				brain.owner = M.ghostize()?.mind
				qdel(M)
			else
				boutput(M, SPAN_ALERT("You feel yourself being dragged out of the afterlife!"))
			brain.owner.transfer_to(borg)
			if (isdead(M) && !isliving(M))
				qdel(M)

		else if (src.head.ai_interface)
			if (!(borg in available_ai_shells))
				available_ai_shells += borg
			for_by_tcl(AI, /mob/living/silicon/ai)
				boutput(AI, SPAN_SUCCESS("[src] has been connected to you as a controllable shell."))
			borg.shell = 1
		else if (istype(borg.part_head.brain, /obj/item/organ/brain/latejoin))
			boutput(usr, SPAN_NOTICE("You activate the frame and a audible beep emanates from the head."))
			playsound(src, 'sound/weapons/radxbow.ogg', 40, TRUE)
		else
			stack_trace("We finished cyborg [identify_object(borg)] from frame [identify_object(src)] with a brain, but somehow lost the brain??? Where did it go")
			borg.death()
			qdel(src)
			return

		if (src.chest && src.chest.cell)
			borg.cell = src.chest.cell
			borg.cell.set_loc(borg)

		if (borg.mind && !borg.part_head.ai_interface)
			borg.unlock_medal("Adjutant Online", 1)
			borg.set_loc(get_turf(src))

			boutput(borg, "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>")
			boutput(borg, "To use something, simply click it.")
			boutput(borg, "Use the prefix <B>:s</B> to speak to fellow cyborgs and the AI through binary.")

			if (src.emagged || src.syndicate)
				if ((ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution)) && borg.mind)
					ticker.mode:revolutionaries += borg.mind
				if (src.emagged)
					borg.emagged = 1
					borg.mind.add_antagonist(ROLE_EMAGGED_ROBOT, respect_mutual_exclusives = FALSE, source = ANTAGONIST_SOURCE_CONVERTED)
					SPAWN(0)
						borg.update_appearance()
				else if (src.syndicate)
					borg.syndicate = 1
				borg.make_syndicate("activated by [usr]")
			else
				boutput(borg, "<B>You must follow the AI's laws to the best of your ability.</B>")
				borg.show_laws() // The antagonist proc does that too.

			borg.job = "Cyborg"

		borg.update_appearance()

		qdel(src)
		return

/obj/item/parts/robot_parts/robot_frame/syndicate
	tooltip_flags = REBUILD_USER
	syndicate = TRUE
	SYNDICATE_STEALTH_DESCRIPTION("The law connection light is blinking a sinister syndicate red.", null)
