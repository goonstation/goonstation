/obj/particle_maker
	name = "Particle Effect Maker"
	desc = "A thing for making nice particles with. It's an admin tool so if you see it ingame please adminhelp about it!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console1"
	var/datum/particle_maker_var_holder/P = null

	New()
		..()
		P = new /datum/particle_maker_var_holder

	proc/Run()
		set background = 1
		src.visible_message("<b>[src]</b> beginning particle emission.")
		for(var/i=0, i < P.particle_amount, i++)
			SpawnNew()
			sleep(P.particle_delay)
		src.visible_message("<b>[src]</b> particle emission finished.")
		return

	proc/SpawnNew()
		if(!istype(src))
			return

		var/obj/particle/par = unpool(/obj/particle)

		if(!istype(par))
			return

		SPAWN_DBG(P.particle_lifespan)
			if (par)
				par.alpha = 255
				par.blend_mode = 0
				par.color = null
				par.pixel_x = 0
				par.pixel_y = 0
				par.transform = null
				par.override_state = null
				animate(par)
				pool(par)

		par.set_loc(get_turf(src.loc))
		par.blend_mode = P.particle_blend_mode
		par.color = P.particle_color
		par.icon = P.particle_icon
		par.icon_state = P.particle_icon_state

		par.pixel_x = P.initial_pixel_x + rand((0 - P.initial_pixel_x_variance),P.initial_pixel_x_variance)
		par.pixel_y = P.initial_pixel_y + rand((0 - P.initial_pixel_y_variance),P.initial_pixel_y_variance)
		var/x_destination = P.destination_pixel_x + rand((0 - P.destination_pixel_x_variance),P.destination_pixel_x_variance)
		var/y_destination = P.destination_pixel_y + rand((0 - P.destination_pixel_y_variance),P.destination_pixel_y_variance)

		var/alpha_initial = P.initial_alpha + rand((0 - P.initial_alpha_variance),P.initial_alpha_variance)
		var/alpha_destination = P.destination_alpha + rand((0 - P.destination_alpha_variance),P.destination_alpha_variance)
		par.alpha = max(0,min(alpha_initial,255))
		var/end_alpha = max(0,min(alpha_destination,255))

		var/matrix/M = turn(matrix(), rand(P.destination_turn_min, P.destination_turn_max))
		M.Scale(rand(P.destination_scale_min,P.destination_scale_max))

		animate(par, color = P.particle_destination_color, time = P.animation_time, loop = P.animation_loops, transform = M, pixel_x = x_destination, pixel_y = y_destination, alpha = end_alpha, easing = P.easing)
		return

	attack_hand(mob/user as mob)
		Run()

	verb/change_easing()
		set src in view(1)

		var/ptype = input("Choose easing type","Particles") as null|anything in easing_types
		if (ptype)
			P.easing = easing_types[ptype]

	verb/change_blend()
		set src in view(1)

		var/ptype = input("Choose blend type","Particles") as null|anything in blend_types
		if (ptype)
			P.particle_blend_mode = blend_types[ptype]

/datum/particle_maker_var_holder
	var/particle_color = "#FF0000"
	var/particle_icon = 'icons/effects/particles.dmi'
	var/particle_icon_state = "8x8circle"
	var/particle_blend_mode = BLEND_ADD
	var/particle_delay = 1
	var/particle_amount = 20
	var/particle_lifespan = 35
	var/initial_alpha = 255
	var/initial_alpha_variance = 0
	var/initial_pixel_x = 0
	var/initial_pixel_y = 0
	var/initial_pixel_x_variance = 0
	var/initial_pixel_y_variance = 0
	var/destination_turn_max = 180
	var/destination_turn_min = -180
	var/destination_scale_min = 0.5
	var/destination_scale_max = 0.5
	var/destination_alpha = 100
	var/destination_alpha_variance = 0
	var/animation_time = 10
	var/animation_loops = 1
	var/destination_pixel_x = 0
	var/destination_pixel_y = 0
	var/destination_pixel_x_variance = 0
	var/destination_pixel_y_variance = 0
	var/particle_destination_color = "#0000FF"
	var/easing = LINEAR_EASING

/obj/jumpsuit_maker_experiment
	name = "jumpsuit making thing"
	desc = "this is an admin thing ok just ignore it"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console1"
	var/list/components = list("full_jumpsuit", "full_overalls", "full_jersey", "full_swimsuit", "full_clown",
	"top_jacket", "top_jacket_heavy", "top_vest", "top_suit", "top_shirt", "top_sleeves", "top_zipper",
	"bottom_pants",  "bottom_belt", "bottom_shorts", "bottom_clownpants",
	"stripe_sides", "stripe_shoulder", "stripe_belt", "stripe_captain", "stripe_clown", "trim_feet", "trim_hands",
	"clown_suspenders", "clownpants_polkadots", "decal_medic", "decal_tie")
	var/list/current_pieces = list()
	var/list/current_colors = list()
	var/list/current_alphas = list()

	attack_hand(var/mob/user as mob)
		var/dat = "<B>[src.name]</B><HR>"
		dat += "<B>Current Jumpsuit:</B><BR>"
		var/list_counter = 0
		if (current_pieces.len > 0)
			for (var/X as anything in current_pieces)
				list_counter++
				dat += "<b>Piece:</b> [X], <b>Color:</b> [current_colors[list_counter]], <b>Alpha:</b> [current_alphas[list_counter]]<br>"
		dat += "<HR>"
		if (current_pieces.len > 0)
			dat += "<A href='?src=\ref[src];dispense=1'>Dispense Jumpsuit</A><BR>"
		dat += "<A href='?src=\ref[src];add=1'>Add New Element</A><BR>"
		dat += "<A href='?src=\ref[src];wipe=1'>Erase All Elements</A><BR>"

		user.Browse(dat, "window=jumpsuitmaker;size=575x450")
		onclose(user, "jumpsuitmaker")
		return

	Topic(href, href_list)
		if(..())
			return

		if (href_list["dispense"])
			var/obj/item/clothing/under/experimental/E = new /obj/item/clothing/under/experimental(src.loc)
			E.component_images = src.current_pieces
			E.component_colors = src.current_colors
			E.component_alphas = src.current_alphas
			E.update_images()

		else if (href_list["add"])
			src.current_pieces += input("Select Piece","Jumpsuit Maker") as anything in src.components
			src.current_colors += input("Select Color","Jumpsuit Maker") as color
			var/new_alpha = input("Input Alpha","Jumpsuit Maker") as num
			new_alpha = max(0,min(255,new_alpha))
			src.current_alphas += new_alpha

		else if (href_list["wipe"])
			src.current_pieces = list()
			src.current_colors = list()
			src.current_alphas = list()

		src.attack_hand(usr)
		src.updateUsrDialog()
		return

/obj/circular_range_tester
	name = "circle tester"
	desc = "IGNORE ME!!!"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "holo_console1"

	attack_hand(mob/user as mob)
		var/user_input = input("What size?","Circle Tester") as num
		if (user_input <= 0 || user_input > 30)
			alert("fuck you nerd","what are you doing")
			return
		for(var/turf/T in circular_range(get_turf(src),user_input))
			animate_flash_color_fill(T,"#FF0000",1,5)
