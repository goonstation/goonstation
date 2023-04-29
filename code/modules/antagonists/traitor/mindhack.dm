/datum/antagonist/subordinate/mindhack
	id = ROLE_MINDHACK
	display_name = "mindhack"
	remove_on_death = TRUE

	is_compatible_with(datum/mind/mind)
		return isliving(mind.current)

	disposing()
		src.owner.current.delStatus("mindhack")
		. = ..()

	announce()
		. = ..()
		boutput(src.owner.current, "<h2><span class='alert'>You feel an unwavering loyalty to [src.master.current.real_name]! You feel you must obey [his_or_her(src.master.current)] every order! Do not tell anyone about this unless [src.master.current.real_name] tells you to!</span></h2>")

	announce_removal(source)
		. = ..()

		switch (source)
			if (ANTAGONIST_REMOVAL_SOURCE_DEATH)
				src.owner.current.show_antag_popup("mindhackdeath")
				boutput(src.owner.current, "<h2><span class='alert'>As you have died, you are no longer mindhacked! Do not obey your former master's orders even if you've been brought back to life somehow.</span></h2>")
				logTheThing(LOG_COMBAT, src.owner.current, "(implanted by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) has died, removing mindhack status.")

			if (ANTAGONIST_REMOVAL_SOURCE_OVERRIDE)
				src.owner.current.show_antag_popup("mindhackoverride")
				boutput(src.owner.current, "<h2><span class='alert'>Your mindhack implant has been overridden by a new one, cancelling out your former allegiances!</span></h2>")
				logTheThing(LOG_COMBAT, src.owner.current, "'s mindhack implant (implanted by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) was overridden by a different implant.")

			if (ANTAGONIST_REMOVAL_SOURCE_EXPIRED)
				src.owner.current.show_antag_popup("mindhackexpired")
				boutput(src.owner.current, "<h2><span class='alert'>Your mind is your own again! You no longer feel the need to obey your former master's orders.</span></h2>")
				logTheThing(LOG_COMBAT, src.owner.current, "'s mindhack implant (implanted by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) has worn off.")

			if (ANTAGONIST_REMOVAL_SOURCE_SURGERY)
				src.owner.current.show_antag_popup("mindhackexpired")
				boutput(src.owner.current, "<h2><span class='alert'>Your mind is your own again! You no longer feel the need to obey your former master's orders.</span></h2>")
				logTheThing(LOG_COMBAT, src.owner.current, "'s mindhack implant (implanted by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) was removed surgically.")

			else
				src.owner.current.show_antag_popup("mindhackexpired")
				boutput(src.owner.current, "<h2><span class='alert'>Your mind is your own again! You no longer feel the need to obey your former master's orders.</span></h2>")
				logTheThing(LOG_COMBAT, src.owner.current, "'s mindhack implant (implanted by [src.master.current ? "[constructTarget(src.master.current, "combat")]" : "*NOKEYFOUND*"]) has vanished mysteriously.")
