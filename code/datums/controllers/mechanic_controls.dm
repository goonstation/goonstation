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
				item_mats = null
				return
			item_mats = list(/obj/item/electronics/battery=0,/obj/item/electronics/fuse=0,/obj/item/electronics/switc=0,/obj/item/electronics/capacitor=0,/obj/item/electronics/resistor=0,/obj/item/electronics/bulb=0,/obj/item/electronics/relay=0,/obj/item/electronics/board=0,/obj/item/electronics/keypad=0,/obj/item/electronics/screen=0,/obj/item/electronics/buzzer=0)
			var/number_of_parts = mats_number
			var/advanced_chance = 20
			var/advanced_max = 0

			if(number_of_parts >= 6)
				advanced_max = round(number_of_parts/6)
				advanced_chance = round(20*(number_of_parts/6))

			for(var/tracker = 1, tracker <= number_of_parts, tracker ++)
				var/part
				if(prob(advanced_chance)&&(advanced_max))
					part = pick(/obj/item/electronics/board,/obj/item/electronics/keypad,/obj/item/electronics/screen,/obj/item/electronics/buzzer)
					advanced_max --
				else
					part = pick(/obj/item/electronics/battery,/obj/item/electronics/fuse,/obj/item/electronics/switc,/obj/item/electronics/capacitor,/obj/item/electronics/resistor,/obj/item/electronics/bulb,/obj/item/electronics/relay)

				item_mats[part] = item_mats[part] + 1
			return

		create_blueprint(var/mats_number = 10)
			if (istype(src.blueprint,/datum/manufacture/mechanics/))
				return
			if (get_schematic_from_name_in_custom(src.name))
				return
			var/mats_types = null // null = keep default
			if(islist(mats_number))
				mats_types = mats_number
				mats_number = 0
				for(var/mat in mats_types)
					var/amt = mats_types[mat]
					if(isnull(amt))
						amt = 1
					mats_number += amt
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

			if (!isnull(mats_types))
				M.item_paths.Cut()
				M.item_names = null // auto-generate
				M.item_amounts.Cut()
				for(var/mat in mats_types)
					M.item_paths += mat
					var/amt = mats_types[mat]
					if(isnull(amt))
						amt = 1
					M.item_amounts += amt
			else if (mats_number > 0)
				for(var/tracker = 1, tracker <= mats_number, tracker ++)
					M.item_amounts[rand(1,3)] += 1

			src.blueprint = M
			return
