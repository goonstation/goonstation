/datum/buildmode/reagents
	name = "Reagents (expose or add)"
	desc = {"***********************************************************<br>
Left Mouse Button on mob/obj/turf  = Expose target to reagent<br>
Right Mouse Button on mob/obj/turf = Add 5 units of reagent to target<br>
Right Mouse Button on buildmode    = Select reagent<br>
***********************************************************"}
	icon_state = "buildmode6"
	var/reagent_id
	var/tmp/datum/reagents/reagent_holder

	New()
		..()
		reagent_holder = new(20)

	click_mode_right(var/ctrl, var/alt, var/shift)
		var/nrid = get_one_match_string(input("Enter full (or part of) reagent ID", "Reagent ID", reagent_id), reagents_cache)
		if (nrid)
			reagent_id = nrid
			reagent_holder.clear_reagents()
			reagent_holder.add_reagent(reagent_id, 20)
			update_button_text(reagent_id)

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!reagent_id)
			return
		if (!(reagent_id in reagent_holder.reagent_list))
			return
		var/datum/reagent/reagent = reagent_holder.reagent_list[reagent_id]
		blink(get_turf(object))
		if(ismob(object)) reagent.reaction_mob_chemprot_layer(object, 1, 20)
		if(isobj(object)) reagent.reaction_obj(object, 20)
		if(isturf(object)) reagent.reaction_turf(object, 20)

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (!object.reagents)
			var/datum/reagents/RE = new /datum/reagents(50)
			object.reagents = RE
			RE.my_atom = object
		if (!reagent_id)
			return
		if (object.reagents)
			object.reagents.add_reagent(reagent_id, 5)
			blink(get_turf(object))
