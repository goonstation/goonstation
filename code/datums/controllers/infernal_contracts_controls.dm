/datum/infernal_contracts_controller
	var/list/strongcontracts = list(/obj/item/contract/satan,
									/obj/item/contract/macho,
									/obj/item/contract/wrestle,
									/obj/item/contract/yeti,
									/obj/item/contract/genetic/demigod,
									/obj/item/contract/horse,
									/obj/item/contract/vampire,
									/obj/item/contract/krampus)
	var/list/weakcontracts = list(/obj/item/contract/genetic,
								/obj/item/contract/mummy,
								/obj/item/contract/mummy/thorough,
								/obj/item/contract/juggle,
								/obj/item/contract/bee,
								/obj/item/contract/rested,
								/obj/item/contract/chemical,
								/obj/item/contract/hair,
								/obj/item/contract/limbs,
								/obj/item/contract/greed)
	var/total_souls = 0

	proc/souladjust(var/current_souls as num, var/mob/badguy as mob)
		if (current_souls <= 0)
			return 0
		if (length(by_cat[TR_CAT_SOUL_TRACKING_ITEMS]))
			for (var/obj/item/Q as anything in by_cat[TR_CAT_SOUL_TRACKING_ITEMS])
				if (istype(Q, /obj/item/pen/fancy/satan))
					var/obj/item/pen/fancy/satan/the_pen = Q
					if (the_pen.merchant == badguy)
						the_pen.soul_power = current_souls
						the_pen.force = (initial(Q.force)) + current_souls
						the_pen.throwforce = (initial(Q.throwforce)) + current_souls
				if (istype(Q, /obj/item/storage/briefcase/satan))
					var/obj/item/storage/briefcase/satan/the_briefcase = Q
					if (the_briefcase.merchant == badguy)
						the_briefcase.soul_power = current_souls
						the_briefcase.force = (initial(Q.force)) + current_souls
						the_briefcase.throwforce = (initial(Q.throwforce)) + current_souls
				Q.tooltip_rebuild = TRUE
		return 1

	proc/spawncontract(var/mob/badguy as mob, var/strong = 0, var/pen = 0)
		var/obj/item/contract/new_contract = null
		if(strong)
			var/tempcontract = pick(strongcontracts)
			new_contract = new tempcontract(badguy)
		else
			var/tempcontract = pick(weakcontracts)
			new_contract = new tempcontract(badguy)
		new_contract.merchant = badguy
		if (!badguy.put_in_hand(new_contract))
			new_contract.set_loc(get_turf(badguy))
			boutput(badguy, SPAN_NOTICE("A new contract suddenly appears at your feet!"))
		else
			boutput(badguy, SPAN_NOTICE("A new contract suddenly appears in your hand!"))
		if(pen)
			var/obj/item/pen/fancy/satan/Q = new /obj/item/pen/fancy/satan(badguy)
			Q.merchant = badguy
			if (!badguy.put_in_hand(Q))
				Q.set_loc(get_turf(badguy))
				boutput(badguy, SPAN_NOTICE("And a new pen appears at your feet!"))
			else
				boutput(badguy, SPAN_NOTICE("And a new pen appears in your other hand!"))


