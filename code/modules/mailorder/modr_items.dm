ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/category = "General Items"
	var/list/order_perm = list() // optional access requirement to order a given item


ABSTRACT_TYPE(/datum/mail_order/medical/)
/datum/mail_order/medical
	//top level order_perm omitted intentionally
	analyze_kit
		name = "Analyzer Triage Bundle"
		desc = "Order a health analyzer, and we'll throw in a bandage for free!"
		order_items = list(/obj/item/device/analyzer/healthanalyzer,/obj/item/bandage,)
		cost = PAY_UNTRAINED / 2
		category = "Equipment"

	analyze_up
		name = "Health Analyzer Deluxe Upgrade"
		desc = "Top-of-the-line enhancements for any industry-standard health analyzer."
		order_items = list(/obj/item/device/analyzer/healthanalyzer_upgrade,/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
		cost = PAY_TRADESMAN / 4
		category = "Equipment"

	auto_char
		name = "Charcoal Auto-Injector"
		desc = "A ready-to-use, sterile single-use injector containing ten units of charcoal."
		order_items = list(/obj/item/reagent_containers/emergency_injector/charcoal)
		cost = PAY_TRADESMAN / 4
		category = "Medication"

	auto_epi
		name = "Epinephrine Auto-Injector"
		desc = "A ready-to-use, sterile single-use injector containing ten units of epinephrine."
		order_items = list(/obj/item/reagent_containers/emergency_injector/epinephrine)
		cost = PAY_TRADESMAN / 4
		category = "Medication"

ABSTRACT_TYPE(/datum/mail_order/chem)
/datum/mail_order/chem
	order_perm = list(access_chemistry,access_heads)

	acetone
		name = "Acetone, 50u Bottle"
		desc = "50 units of acetone, meeting our rigorous scientific standards for reagent purity."
		order_items = list(/obj/item/reagent_containers/glass/bottle/acetone)
		cost = PAY_TRADESMAN / 4

	ammonia
		name = "Ammonia, 50u Bottle"
		desc = "50 units of ammonia, meeting our rigorous scientific standards for reagent purity."
		order_items = list(/obj/item/reagent_containers/glass/bottle/ammonia)
		cost = PAY_TRADESMAN / 4

	phenol
		name = "Phenol, 50u Bottle"
		desc = "50 units of phenol, meeting our rigorous scientific standards for reagent purity."
		order_items = list(/obj/item/reagent_containers/glass/bottle/phenol)
		cost = PAY_TRADESMAN / 4





	proc/create(var/mob/creator)
		var/obj/storage/S
		if (!ispath(containertype) && contains.len > 1)
			containertype = text2path(containertype)
			if (!ispath(containertype))
				containertype = /obj/storage/crate // this did not need to be a string

		if (ispath(containertype))
#ifdef HALLOWEEN
			if (halloween_mode && prob(10))
				S = new /obj/storage/crate/haunted
			else
				S = new containertype
#else
			S = new containertype
#endif
			if (S)
				if (containername)
					S.name = containername

				if (access && istype(S))
					S.req_access = list()
					S.req_access += text2num(access)

		if (contains.len)
			for (var/B in contains)
				var/thepath = B
				if (!ispath(thepath))
					thepath = text2path(B)
					if (!ispath(thepath))
						continue

				var/amt = 1
				if (isnum(contains[B]))
					amt = abs(contains[B])

				for (amt, amt>0, amt--)
					var/atom/thething = new thepath(S)
					if (amount && isitem(thething))
						var/obj/item/I = thething
						I.amount = amount
		return S
