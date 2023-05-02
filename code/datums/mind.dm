datum/mind
	var/key
	var/ckey
	var/displayed_key
	var/mob/current
	var/mob/virtual

	var/memory
	var/list/datum/dynamic_player_memory/dynamic_memories = list()
	var/remembered_pin = null
	var/last_memory_time = 0 //Give a small delay when adding memories to prevent spam. It could happen!
	var/miranda // sec's miranda rights thingy.
	var/last_miranda_time = 0 // this is different than last_memory_time, this is when the rights were last SAID, not last CHANGED

	var/violated_hippocratic_oath = 0
	var/soul = 100 // how much soul we have left
	var/diabolical = 0 //are we some sort of demon or other spirit baddie?

	var/completed_objs = 0 // completed crew objectives
	var/all_objs = 0 // for sbux calcs

	var/assigned_role
	var/special_role
	var/late_special_role = 0
	var/random_event_special_role = 0

	/// A list of every antagonist datum that we have.
	var/list/datum/antagonist/antagonists = list()

	// This used for dead/released/etc mindhacks and rogue robots we still want them to show up
	// in the game over stats. It's a list because former mindhacks could also end up as an emagged
	// cyborg or something. Use strings here, just like special_role (Convair880).
	var/list/former_antagonist_roles = list()

	var/list/datum/objective/objectives = list()
	var/is_target = 0

	var/list/intrinsic_verbs = list()

	// For mindhack/vampthrall/spyminion master references, which are now tracked by ckey.
	// Mob references are not very reliable and did cause trouble with automated mindhack status removal
	// The relevant code snippets call a ckey -> mob reference lookup proc where necessary,
	// namely ckey_to_mob(mob.mind.master) (Convair880).
	var/master = null

	var/handwriting = null
	var/color = null

	var/obj/item/organ/brain/brain

	var/datum/bank_purchaseable/purchased_bank_item = 0 //set when player readies up
	var/join_time = 0

	var/karma = 0 //fuck
	var/const/karma_min = -420
	var/const/karma_max = 69
	var/damned = 0 //! If 1, they go to hell when are die

	var/show_respawn_prompts = TRUE

	New(mob/M)
		..()
		if (M)
			current = M
			key = M.key
			ckey = M.ckey
			displayed_key = M.key
			src.handwriting = pick(handwriting_styles)
			src.color = pick_string("colors.txt", "colors")
			SEND_SIGNAL(src, COMSIG_MIND_ATTACH_TO_MOB, M)

	proc/transfer_to(mob/new_character)
		Z_LOG_DEBUG("Mind/TransferTo", "Transferring \ref[src] (\ref[current], [current]) ...")
		if (!new_character)
			Z_LOG_DEBUG("Mind/TransferTo", "No new_character given, transfer aborted")
			return

		Z_LOG_DEBUG("Mind/TransferTo", "New mob: \ref[new_character] ([new_character])")
		if (new_character.disposed)
			if (current)
				boutput(current, "You were about to be transferred into another body, but that body was pending deletion! This may fuck everything up so if it does dial 1-800-CODER.")
				message_admins("Tried to transfer mind of mob [current] (\ref[current], [key_name(current)]) to qdel'd mob [new_character] (\ref[new_character]) God damnit. Un-qdeling the mob and praying (this will probably fuck up).")
				new_character.disposed = 0
			else
				message_admins("Tried to transfer mind [src] to qdel'd mob [new_character] (\ref[new_character]).")

			Z_LOG_ERROR("Mind/TransferTo", "Tried to transfer mind [(current ? "of mob " + key_name(current) : src)] to qdel'd mob [new_character].")
			return
			//CRASH("Trying to transfer to a mob that's in the delete queue!")

		if (new_character.client)
			if (current)
				boutput(current, "You were about to be transferred into another body, but that body was occupied!")
				message_admins("Tried to transfer mind of mob [current] (\ref[current], [key_name(current)]) to mob with an existing client [new_character] (\ref[new_character])")
			else
				message_admins("Tried to transfer mind [src] to mob with an existing client [new_character] (\ref[new_character]).")
			Z_LOG_ERROR("Mind/TransferTo", "Tried to transfer mind [(current ? "of mob " + key_name(current) : src)] to mob with an existing client [new_character] [key_name(new_character)])")
			return

		if (current)
			if(current.client)
				current.removeOverlaysClient(current.client)
				tgui_process.on_transfer(current, new_character)
				new_character.lastKnownIP = current.client.address
			current.mind = null
			SEND_SIGNAL(src, COMSIG_MIND_DETACH_FROM_MOB, current, new_character)

		new_character.mind = src
		current = new_character

		new_character.key = key

		if(current.client)
			current.addOverlaysClient(current.client)

		Z_LOG_DEBUG("Mind/TransferTo", "Mind swapped, moving verbs")

		for (var/intrinsic_verb in intrinsic_verbs)
			Z_LOG_DEBUG("Mind/TransferTo", "Adding [intrinsic_verb]")
			new_character.verbs += intrinsic_verb


		//transfer abilholder to me self
		if (new_character.abilityHolder)
			Z_LOG_DEBUG("Mind/TransferTo", "Transferring abilityHolder")
			new_character.abilityHolder.transferOwnership(new_character)

		Z_LOG_DEBUG("Mind/TransferTo", "Complete")

		SEND_SIGNAL(src, COMSIG_MIND_ATTACH_TO_MOB, current)


	proc/swap_with(mob/target)
		var/datum/mind/other_mind = target.mind
		var/mob/my_old_mob = current

		if (other_mind)	//They have a mind so we can do this nicely
			if (isobserver(current))
				current:delete_on_logout = 0
			if (isobserver(target))
				target:delete_on_logout = 0

			var/mob/temp = new/mob(src.current.loc) //We need to put whoever we're swapping with somewhere
			other_mind.transfer_to(temp)			//So now we put them there
			src.transfer_to(target)					//Then I go into their head
			other_mind.transfer_to(my_old_mob)		//And they go into my old one
			qdel(temp)								//Not needed any more

		else if (!target.client && !target.key) 	//They didn't have a mind and didn't have an associated player, AKA up for grabs
			src.transfer_to(target)

		else	//The Ugly Way
			if (isobserver(current))
				current:delete_on_logout = 0
			if (isobserver(target))
				target:delete_on_logout = 0

			var/mob/temp = new/mob(src.current.loc) //We need to put whoever we're swapping with somewhere
			temp.key = target.key					//So now we put them there
			src.transfer_to(target)					//Then I go into their head
			my_old_mob.key = temp.key
			qdel(temp)								//Not needed any more

		if (isobserver(current))
			current:delete_on_logout = 1
		if (isobserver(target))
			target:delete_on_logout = 1

	proc/get_player()
		RETURN_TYPE(/datum/player)
		if(ckey)
			. = make_player(ckey)

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/remove_dynamic_memories_by_type(dynamic_memory_type)
		for (var/datum/dynamic_player_memory/dynamic_memory in src.dynamic_memories)
			if (dynamic_memory.type == dynamic_memory_type)
				src.dynamic_memories -= dynamic_memory

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		for (var/datum/dynamic_player_memory/dynamic_memory in src.dynamic_memories)
			output += dynamic_memory.memory_text

		if (objectives.len>0)
			output += "<HR><B>Objectives:</B><br>"

			var/obj_count = 1
			for (var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]<br>"
				obj_count++

		// Added (Convair880).
		if (recipient.mind.master)
			var/mob/mymaster = ckey_to_mob(recipient.mind.master)
			if (mymaster)
				output+= "<br><b>Your master:</b> [mymaster.real_name]"

		recipient.Browse(output,"window=memory;title=Memory")

	proc/set_miranda(new_text)
		miranda = new_text

	proc/show_miranda(mob/recipient)
		var/output = "<B>[current.real_name]'s Miranda Rights</B><HR>[miranda]"

		recipient.Browse(output,"window=miranda;title=Miranda Rights")

	proc/register_death()
		var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
		src.store_memory("Time of death: [tod]", 0)
		// stuff for critter respawns
		src.get_player()?.last_death_time = world.timeofday

	/// Gets an existing antagonist datum of the provided ID role_id.
	proc/get_antagonist(role_id)
		for (var/datum/antagonist/A as anything in src.antagonists)
			if (A.id == role_id)
				return A
		return null

	/// Attempts to add the antagonist datum of ID role_id to this mind.
	proc/add_antagonist(role_id, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_ROUND_START, respect_mutual_exclusives = TRUE, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE)
		// Check for mutual exclusivity for real antagonists
		if (respect_mutual_exclusives && !do_pseudo && !do_vr && length(src.antagonists))
			for (var/datum/antagonist/A as anything in src.antagonists)
				if (A.mutually_exclusive)
					return FALSE
		// To avoid wacky shenanigans, refuse to add multiple types of the same antagonist
		if (!isnull(src.get_antagonist(role_id)) && !do_vr)
			return FALSE
		for (var/V in concrete_typesof(/datum/antagonist))
			var/datum/antagonist/A = V
			if (initial(A.id) == role_id)
				var/datum/antagonist/new_datum = new A(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup)
				if (!new_datum || QDELETED(new_datum))
					return FALSE
				src.current.antagonist_overlay_refresh(TRUE, FALSE)
				return TRUE
		return FALSE

	/// Attempts to add the subordinate antagonist datum of ID role_id to this mind.
	proc/add_subordinate_antagonist(role_id, do_equip = TRUE, do_objectives = TRUE, do_relocate = TRUE, silent = FALSE, source = ANTAGONIST_SOURCE_ROUND_START, respect_mutual_exclusives = TRUE, do_pseudo = FALSE, do_vr = FALSE, late_setup = FALSE, master)
		if (!master)
			return FALSE
		// To avoid wacky shenanigans
		if (!isnull(src.get_antagonist(role_id)) && !do_vr)
			src.remove_antagonist(role_id)
		for (var/V in concrete_typesof(/datum/antagonist/subordinate))
			var/datum/antagonist/subordinate/A = V
			if (initial(A.id) == role_id)
				var/datum/antagonist/subordinate/new_datum = new A(src, do_equip, do_objectives, do_relocate, silent, source, do_pseudo, do_vr, late_setup, master)
				if (!new_datum || QDELETED(new_datum))
					return FALSE
				src.current.antagonist_overlay_refresh(TRUE, FALSE)
				return TRUE
		return FALSE

	/// Attempts to remove existing antagonist datums of ID role_id from this mind.
	proc/remove_antagonist(role_id)
		for (var/datum/antagonist/A as anything in src.antagonists)
			if (A.id == role_id)
				A.remove_self(TRUE)
				src.antagonists.Remove(A)
				if (!length(src.antagonists) && src.special_role == A.id)
					src.special_role = null
					ticker.mode.traitors.Remove(src)
					ticker.mode.Agimmicks.Remove(src)
				qdel(A)
				src.current.antagonist_overlay_refresh(TRUE, FALSE)
				return TRUE
		return FALSE

	/// Removes ALL antagonists from this mind. Use with caution!
	proc/wipe_antagonists()
		for (var/datum/antagonist/A as anything in src.antagonists)
			A.remove_self(TRUE)
			src.antagonists.Remove(A)
			qdel(A)
		src.special_role = null
		ticker.mode.traitors.Remove(src)
		ticker.mode.Agimmicks.Remove(src)
		return length(src.antagonists) <= 0

	disposing()
		logTheThing(LOG_DEBUG, null, "<b>Mind</b> Mind for \[[src.key ? src.key : "NO KEY"]] deleted!")
		Z_LOG_DEBUG("Mind/Disposing", "Mind \ref[src] [src.key ? "([src.key])" : ""] deleted")
		src.brain?.owner = null
		if(src.current)
			SEND_SIGNAL(src, COMSIG_MIND_DETACH_FROM_MOB, current)
		..()

	/// Output of this gets logged when the mind is added to the game ticker
	proc/on_ticker_add_log()
		var/list/traits = list()
		for(var/trait_id in src.current.traitHolder.traits)
			var/datum/trait/trait = src.current.traitHolder.traits[trait_id]
			traits += trait.name
		. = "<br>Traits: [jointext(traits, ", ")]"

/datum/mind/proc/add_karma(how_much)
	src.karma += how_much
	src.karma = clamp(src.karma, karma_min, karma_max)
