
/// Handles chemistry reactions
/datum/controller/process/chemistry

	setup()
		name = "Chemistry"
		schedule_interval = 1 SECOND

	doWork()
		for(var/datum/d in active_reagent_holders)
			d:process_reactions()
			scheck()
		for(var/datum/chemicompiler_core/c in chemicompilers)
			c.reaction_ticked()

