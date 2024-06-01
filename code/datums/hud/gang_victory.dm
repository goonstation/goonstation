// #define TESTING_TESTING
/datum/hud/gang_victory
	click_check = 0
	var/atom/movable/screen/text

	New(datum/gang/winning_gang)
		//big gang name victory text
		src.text = create_screen("gangvictory", "Gang Victory Display", null, "", "NORTH,CENTER", HUD_LAYER_3)
		text.maptext = "<span class='c ol vga vt' style='background: #00000080;font-size: 5;'>[winning_gang.gang_name] won the round!</span>"
		text.maptext_width = 600
		text.maptext_x = -(600 / 2) + 16
		text.maptext_y = -150
		text.maptext_height = 100
		text.plane = PLANE_HUD
		text.layer = 420

		//individual gang member portraits
		var/member_count = 0
#ifdef TESTING_TESTING
		var/list/members = list(winning_gang.leader, winning_gang.leader, winning_gang.leader, winning_gang.leader)
#else
		var/list/members = winning_gang.members.Copy()
#endif
		members.Insert(round(length(members)/2), winning_gang.leader) //put the leader roughly in the middle
		for (var/datum/mind/gang_mind in members)
			var/mob/ganger = gang_mind.current
			if (!ganger) //paranoia because we REALLY don't want to blow up the round-end stack
				continue

			if (isliving(ganger) && isdead(ganger))
				if (!ganger.ghost)
					ganger = ganger.ghostize()
				else
					ganger = ganger.ghost

			var/position = (-round(length(members)/2) + member_count) * 2.2
			var/position_string = "CENTER[position > 0 ? "+" : ""][position ? position : ""], CENTER+1.8"

			//getFlatIcon's dir argument doesn't work here for some reason
			var/old_dir = ganger.dir
			ganger.set_dir(SOUTH)
			var/icon/flat_icon = getFlatIcon(ganger)
			ganger.set_dir(old_dir)

			var/atom/movable/screen/screen_obj = create_screen("gang_member[member_count]", ganger.real_name, null, "", position_string, mouse_opacity=FALSE)
			screen_obj.Scale(2,2)
			screen_obj.icon = flat_icon

			var/atom/movable/screen/nametag = create_screen("gang_member[member_count]_name", ganger.real_name, null, "", position_string, mouse_opacity=FALSE)
			nametag.maptext_y = 40
			nametag.maptext_x = -32
			//centered, pixel, drop shadow (I love readable class names!)
			nametag.maptext = "<span class='c pixel sh' [gang_mind == winning_gang.leader ? "style='color: #FFD149;'" : ""]>[ganger.real_name]</span>"
			nametag.maptext_width = 100

			member_count++
		..()
