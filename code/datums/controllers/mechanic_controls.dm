var/datum/mechanic_controller/mechanic_controls

/datum/mechanic_controller
	var/list/scanned_items = list()
	var/list/rkit_addresses = list()

	proc
		scan_in(var/N,var/T,var/M)
			var/datum/electronics/scanned_item/S = new/datum/electronics/scanned_item
			S.name = N
			S.item_type = T
			S.item_mats = M
			S.create_partslist(M)
			S.create_blueprint(M)
			src.scanned_items += S
			return 1

/datum/electronics/scanned_item
	var/name = "Unknown"
	var/item_type = ""
	var/list/item_mats
	var/finish_time = 0
	var/datum/manufacture/mechanics/blueprint = null

	proc
		create_partslist(var/mats_number = 10)
			if (!isnum(mats_number))
				mats_number = 10
			item_mats = list("battery"=0,"fuse"=0,"switch"=0,"capacitor"=0,"resistor"=0,"bulb"=0,"relay"=0,"board"=0,"keypad"=0,"screen"=0,"buzzer"=0)
			var/number_of_parts = mats_number
			var/advanced_chance = 20
			var/advanced_max = 0

			if(number_of_parts >= 6)
				advanced_max = round(number_of_parts/6)
				advanced_chance = round(20*(number_of_parts/6))

			for(var/tracker = 1, tracker <= number_of_parts, tracker ++)
				var/part
				if(prob(advanced_chance)&&(advanced_max))
					part = pick("board","keypad","screen","buzzer")
					advanced_max --
				else
					part = pick("battery","fuse","switch","capacitor","resistor","bulb","relay")

				item_mats[part] = item_mats[part] + 1
			return

		create_blueprint(var/mats_number = 10)
			if (istype(src.blueprint,/datum/manufacture/mechanics/))
				return
			if (get_schematic_from_name_in_custom(src.name))
				return
			if (!isnum(mats_number))
				mats_number = 10

			var/datum/manufacture/mechanics/M = new /datum/manufacture/mechanics(manuf_controls)
			manuf_controls.custom_schematics += M
			M.name = src.name
			M.time = mats_number * 1.5 SECONDS
			M.frame_path = src.item_type

			if (mats_number > 3)
				mats_number -= 3
				// to cover the base materials

			if (mats_number > 0)
				for(var/tracker = 1, tracker <= mats_number, tracker ++)
					M.item_amounts[rand(1,3)] += 1

			src.blueprint = M
			return
