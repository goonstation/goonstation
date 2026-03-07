//this is just an arcfiend with glowy purple eyes, free points, and some spooky objectives
//I'm adding this for an event but I'll leave it in the codebase so it can be used for gimmicks or possibly expanded upon in future
/datum/antagonist/plasmafiend
	id = ROLE_PLASMAFIEND
	display_name = "plasmafiend"

	give_equipment()
		src.owner.add_antagonist(ROLE_ARCFIEND, do_objectives = FALSE, silent=TRUE)
		var/datum/abilityHolder/arcfiend/fiend_holder = src.owner.current.get_ability_holder(/datum/abilityHolder/arcfiend)
		fiend_holder.addPoints(1000)
		src.owner.current.bioHolder.AddEffect("plasma_metabolism_passive", magical = TRUE)

	assign_objectives()
		new /datum/objective/specialist("Typhon is in zenith.", src.owner)
		new /datum/objective/specialist("All must bow to the dead god.", src.owner)

	remove_equipment()
		src.owner.remove_antagonist(ROLE_ARCFIEND)
