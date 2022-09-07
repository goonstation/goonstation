/datum/buildmode/paint_matrix
	name = "Paint Matrix"
	desc = {"***********************************************************<br>
Left Mouse Button = Select the color of where you click and then a color to map it into. After three such colors are selected, further clicks will paint using a special matrix.<br>
Note: try to keep the original color inputs relatively distinct from each other, else calculating the matrix and mapping the colors might not be possible.<br>
Right Mouse Button = Depaint target.<br>
Ctrl+Left Mouse Button = Reset color selections.<br>
Right Mouse Button on buildmode = Manual tweaking - choose the color or edit already picked colors via the color picker instead of clicking on pixels.<br>
Alt+Left Mouse Button = Generate a random matrix for use.<br>
Alt+Shift+Left Mouse Button = Set a multiplier for matrix randomization value generation (default: 1).
<br>***********************************************************"}
	icon_state = "buildmode7_matrix"
	var/color_one_picked
	var/color_one_mapped_to
	var/color_two_picked
	var/color_two_mapped_to
	var/color_three_picked
	var/color_three_mapped_to
	var/calculated_matrix
	var/tmp/busy
	var/using_random = FALSE
	var/randomization_multiplier = 1

	var/tmp/stage = 1

	selected()
		. = ..()
		update_text()
		holder.button_mode.color = null // bandaid, the button "selected" coloring causes maptext colors to be off

	click_raw(atom/target, location, control, list/params)
		. = ..()
		if (params.Find("left"))
			handle_left_click(target, params.Find("ctrl"), params.Find("alt"), params.Find("shift"), params)

	proc/handle_left_click(atom/target, ctrl, alt, shift, list/params)
		if(busy)
			boutput(usr, "Busy picking a color.")
			return
		if(alt && shift) // set random matrix value multiplier
			var/num_input = input(usr, "Set a positive value for randomization multiplier (default: 1).", "Random Matrix Multiplier", 0) as null|num
			if(num_input && num_input > 0)
				randomization_multiplier = num_input
			else
				boutput(usr, "<span class='alert'>Invalid value or canceled input, randomization multiplier remains at [randomization_multiplier].</span>")
			return
		if(alt) // random matrix
			using_random = TRUE
			stage = 4
			var/list/randomly_generated_matrix = list()
			for(var/i in 1 to 9)
				randomly_generated_matrix.Add(randomization_multiplier * rand()) // from personal testing positive numbers only gave better results.
			calculated_matrix = randomly_generated_matrix
			boutput(usr, "Randomly generated a matrix: <br>[json_encode(calculated_matrix)]")
			update_text()
			return
		if(ctrl) // reset
			reset_mode()
			boutput(usr, "Matrix paint module reset.")
			return
		switch(stage) // picking and setting colors for mapping
			if(1)
				color_one_picked = get_color_of_clicked_pixel(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
				if(!color_one_picked)
					boutput(usr, "<span class='alert'>Couldn't get a color. Probably an issue with how getFlatIcon interacts with target. Try again.</span>")
					return
				busy = TRUE
				color_one_mapped_to = get_color_from_user_input(color_one_picked, "Choose a color to map into.")
				busy = FALSE
			if(2)
				color_two_picked = get_color_of_clicked_pixel(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
				if(!color_two_picked)
					boutput(usr, "<span class='alert'>Couldn't get a color. Probably an issue with how getFlatIcon interacts with target. Try again.</span>")
					return
				busy = TRUE
				color_two_mapped_to = get_color_from_user_input(color_two_picked, "Choose a color to map into.")
				busy = FALSE
			if(3)
				color_three_picked = get_color_of_clicked_pixel(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
				if(!color_three_picked)
					boutput(usr, "<span class='alert'>Couldn't get a color. Probably an issue with how getFlatIcon interacts with target. Try again.</span>")
					return
				busy = TRUE
				color_three_mapped_to = get_color_from_user_input(color_three_picked, "Choose a color to map into.")
				busy = FALSE
				calculated_matrix = calculate_color_matrix()
				if(!calculated_matrix)
					boutput(usr, "<span class='alert'>Original color inputs aren't linearly independent, couldn't calculate matrix. Try again with different inputs. Reset with ctrl+leftclick or tweak manually by rightclicking the buildmode icon.</span>")
				else
					boutput(usr, "Calculated color matrix: <br>[json_encode(calculated_matrix)]")
			else // matrix should be ready, trying to apply
				apply_matrix_paint_on_target(target)
				return
		stage++
		update_text()

	proc/update_text()
		var/text_to_display = ""
		if(using_random)
			text_to_display = "<B>Using a <font color='#FF0000'>r</font><font color='#FF9900'>a</font><font color='#FFff00'>n</font><font color='#00FF00'>d</font><font color='#0000FF'>o</font><font color='#FF00FF'>m</font> matrix.</B>"
		else
			text_to_display = "Colors: <br>"
			var/stage_one_text = "1 : Not yet selected."
			var/stage_two_text = "<br>2 : Not yet selected."
			var/stage_three_text = "<br>3 : Not yet selected."
			if(stage > 1)
				stage_one_text = "1 : <span style='color: [color_one_picked];'>[color_one_picked]</span> ==> <span style='color: [color_one_mapped_to];'>[color_one_mapped_to]</span>"
			if(stage > 2)
				stage_two_text = "<br>2 : <span style='color: [color_two_picked];'>[color_two_picked]</span> ==> <span style='color: [color_two_mapped_to];'>[color_two_mapped_to]</span>"
			if(stage > 3)
				stage_three_text = "<br>3 : <span style='color: [color_three_picked];'>[color_three_picked]</span> ==> <span style='color: [color_three_mapped_to];'>[color_three_mapped_to]</span>"
			text_to_display += stage_one_text
			text_to_display += stage_two_text
			text_to_display += stage_three_text

		update_button_text(text_to_display)

	proc/reset_mode()
		stage = 1
		using_random = 0
		color_one_mapped_to = null
		color_two_mapped_to = null
		color_three_mapped_to = null
		calculated_matrix = null
		update_text()

	proc/get_color_of_clicked_pixel(atom/target, var/x, var/y)
		var/icon/flat_icon = getFlatIcon(target)
		return flat_icon.GetPixel(x, y)

	proc/get_color_from_user_input(var/starting_color, var/message)
		return input("[message]", "Color", starting_color) as color

	proc/calculate_color_matrix()
		var/list/input_original_colors = list(color_one_picked, color_two_picked, color_three_picked).Copy()
		for(var/i in 1 to 3)
			if(istext(input_original_colors[i])) input_original_colors[i] = hex_to_rgb_list(input_original_colors[i])
		if(!vectors_are_linearly_independent_3x3(input_original_colors))
			return null
		else
			return color_mapping_matrix(
				list(color_one_picked, color_two_picked, color_three_picked),
				list(color_one_mapped_to, color_two_mapped_to, color_three_mapped_to)
				)

	proc/apply_matrix_paint_on_target(atom/target)
		if(!calculated_matrix)
			calculated_matrix = calculate_color_matrix()
			if(!calculated_matrix)
				boutput(usr, "<span class='alert'>Original color inputs aren't linearly independent, couldn't calculate matrix. Try again with different inputs. Reset with ctrl+leftclick or tweak manually by rightclicking the buildmode icon.</span>")
				return
			else
				boutput(usr, "Calculated color matrix: <br>[json_encode(calculated_matrix)]")

		target.color = calculated_matrix

	click_mode_right(var/ctrl, var/alt, var/shift)
		if(busy)
			boutput(usr, "Busy picking a color.")
			return
		var/list/options = list()
		if(stage >= 1)
			options.Add("Colors 1")
		if(stage >= 2)
			options.Add("Colors 2")
		if(stage >= 3)
			options.Add("Colors 3")

		var/selection = (input("Manual color tweaking") as null|anything in options)
		if(!selection) return

		switch(selection)
			if("Colors 1")
				busy = TRUE
				color_one_picked = get_color_from_user_input(color_one_picked, "Choose a color to be mapped.")
				color_one_mapped_to = get_color_from_user_input(color_one_mapped_to, "Choose a color to map into.")
				busy = FALSE
				if(stage <= 1) stage++
			if("Colors 2")
				busy = TRUE
				color_two_picked = get_color_from_user_input(color_two_picked, "Choose a color to be mapped.")
				color_two_mapped_to = get_color_from_user_input(color_two_mapped_to, "Choose a color to map into.")
				busy = FALSE
				if(stage <= 2) stage++
			if("Colors 3")
				busy = TRUE
				color_three_picked = get_color_from_user_input(color_three_picked, "Choose a color to be mapped.")
				color_three_mapped_to = get_color_from_user_input(color_three_mapped_to, "Choose a color to map into.")
				busy = FALSE
				if(stage <= 3) stage++
			else
				return // no selection
		if (stage == 4)
			calculated_matrix = calculate_color_matrix()
			if(!calculated_matrix)
				boutput(usr, "<span class='alert'>Original color inputs aren't linearly independent, couldn't calculate matrix. Try again with different inputs. Reset with ctrl+leftclick or tweak manually by rightclicking the buildmode icon.</span>")
				return
			else
				boutput(usr, "Calculated color matrix: <br>[json_encode(calculated_matrix)]")
		update_text()
		return

	click_right(atom/target, var/ctrl, var/alt, var/shift)
		target.color = null

	proc/calculate_matrix_determinant(list/list/inp)
		var/determinant = 0
		for(var/i = 0; i<3; i++)
			determinant = determinant + (inp[1][(i%3)+1] * inp[2][((i+1)%3)+1] * inp[3][((i+2)%3)+1]) - (inp[3][(i%3)+1] * inp[2][((i+1)%3)+1] * inp[1][((i+2)%3)+1])
		return determinant

	proc/vectors_are_linearly_independent_3x3(list/list/inp)
		var/determinant = calculate_matrix_determinant(inp)
		if(determinant != 0)
			return TRUE
		else
			return FALSE
