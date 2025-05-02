/datum/antagonist/broken
	display_name = "broken"
	id = ROLE_BROKEN
	remove_on_death = TRUE
	remove_on_clone = TRUE //just to be sure
	wiki_link = "https://wiki.ss13.co/Broken"
	var/static/shared_objective_text = null

/datum/antagonist/broken/announce()
	boutput(owner.current, SPAN_ALERT("<h1 class='system'>You have broken and surrendered to madness!</h1>"))
	boutput(owner.current, "<h3>[src.shared_objective_text]<h3>")

/datum/antagonist/broken/assign_objectives()
	if (!src.shared_objective_text)
		var/objective_type = pick(concrete_typesof(/datum/objective/madness))
		var/datum/objective/objective = new objective_type(null, src.owner, src)
		src.shared_objective_text = objective.explanation_text
	else
		new /datum/objective/specialist(src.shared_objective_text, src.owner, src)

/datum/antagonist/broken/give_equipment()
	src.alt_equipment()

/datum/antagonist/broken/alt_equipment()
	src.owner.current.setStatus("broken_madness", rand(8,12) MINUTES)

/datum/antagonist/broken/remove_self(take_gear, source)
	. = ..()
	src.owner.current.delStatus("broken_madness")

/datum/antagonist/broken/announce_removal(source)
	boutput(owner.current, SPAN_ALERT("<h1 class='system'>Your sanity returns, you are no longer an antagonist!</h1>"))
	src.owner.current.show_antag_popup("broken_removed")
