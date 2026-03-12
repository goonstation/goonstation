/datum/buildmode/fluids
	name = "Fluids"
	desc = {"***********************************************************<br>
Right Mouse Button on buildmode button = Set reagent<br>
Ctrl-RMB on buildmode button = Set spawn amount (default is one tile's worth)<br>

Left Mouse Button on turf/mob/obj      = Place fluid<br>
Left Mouse Button + Alt                = Place smoke<br>
Right Mouse Button                     = Delete fluid / smoke tile<br>
Right Mouse Button + Ctrl              = Delete whole group of fluid / smoke<br>
***********************************************************"}
	icon_state = "fluids"
	var/reagent_id = null
	var/amount = null

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(ctrl)
			var/amount = tgui_input_number(usr, "How much of the reagent to spawn", "Amount", 1, 10000, 1)
			if(isnull(amount))
				return
			src.amount = amount
			update_button_text("[amount] [reagent_id]")
			return

		// select reagent id
		var/datum/reagent/reagent = pick_reagent(usr)

		src.reagent_id = reagent.id
		update_button_text("[amount] [reagent_id]")

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if(isnull(src.reagent_id))
			boutput(usr, SPAN_ALERT("Select a reagent first!"))
			return
		var/turf/T = get_turf(object)
		if(isnull(T))
			return
		var/spawn_airborne = alt
		var/amount_to_spawn = src.amount
		if(isnull(amount_to_spawn))
			amount_to_spawn = (spawn_airborne ? 5 : 30) - 1 // default per-tile amounts, should likely get turned into constants
		var/obj/fluid/fluid = T.fluid_react_single(src.reagent_id, amount_to_spawn, spawn_airborne)
		fluid.group.update_once()

	click_right(atom/object, var/ctrl, var/alt, var/shift)
		var/turf/T = get_turf(object)
		if(isnull(T))
			return
		var/obj/fluid/F = T.active_airborne_liquid || T.active_liquid
		if(isnull(F))
			return
		if(ctrl)
			F.admin_clear_fluid()
		else
			var/datum/fluid_group/group = F.group
			var/amt_removed = group.amt_per_tile
			qdel(F)
			if(!QDELETED(group))
				group.reagents.skip_next_update = TRUE
				group.reagents.remove_any(amt_removed)
				group.contained_amt = group.reagents.total_volume
				group.update_once()
