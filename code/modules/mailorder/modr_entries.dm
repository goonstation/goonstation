ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/list/order_perm = list() // optional access requirement to order a given item


ABSTRACT_TYPE(/datum/mail_order/survmart/)
/datum/mail_order/survmart

	analyze_kit
		name = "Analyzer Triage Bundle"
		desc = "Order a health analyzer, and we'll throw in a bandage for free!"
		order_items = list(/obj/item/device/analyzer/healthanalyzer,/obj/item/bandage)
		cost = PAY_TRADESMAN / 4

	analyze_up
		name = "Analyzer Deluxe Upgrades"
		desc = "Top-of-the-line enhancements for any standard health analyzer."
		order_items = list(/obj/item/device/analyzer/healthanalyzer_upgrade,/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
		cost = PAY_TRADESMAN / 3

	auto_char
		name = "Charcoal Auto-Injector"
		desc = "Rapidly flushes toxins out of your system - a must for biohazards."
		order_items = list(/obj/item/reagent_containers/emergency_injector/charcoal)
		cost = PAY_TRADESMAN / 3

	auto_epi
		name = "Epinephrine Auto-Injector"
		desc = "Stabilizes critical patients - the gold standard for crisis care."
		order_items = list(/obj/item/reagent_containers/emergency_injector/epinephrine)
		cost = PAY_TRADESMAN / 2

	auto_salb
		name = "Salbutamol Auto-Injector"
		desc = "Mitigates the effect of hypoxia. Useful in case of hull breach."
		order_items = list(/obj/item/reagent_containers/emergency_injector/salbutamol)
		cost = PAY_TRADESMAN / 4

	patch_brute
		name = "Healing Mini-Patch"
		desc = "A robust medical patch effective at treating brute-force injury."
		order_items = list(/obj/item/reagent_containers/patch/mini/bruise)
		cost = PAY_TRADESMAN / 4

	patch_burn
		name = "Burn Mini-Patch"
		desc = "A soothing medical patch effective at treating burn injury."
		order_items = list(/obj/item/reagent_containers/patch/mini/burn)
		cost = PAY_TRADESMAN / 4

	cleangear
		name = "Medical Wear Bundle"
		desc = "Contains latex gloves, sterile mask and surgical face shield."
		order_items = list(/obj/item/clothing/gloves/latex,/obj/item/clothing/mask/surgical,/obj/item/clothing/mask/surgical_shield)
		cost = PAY_UNTRAINED / 4


ABSTRACT_TYPE(/datum/mail_order/chem)
/datum/mail_order/chem
	order_perm = list(access_chemistry,access_heads)

	acetone
		name = "Acetone, 50u Bottle"
		desc = "50 units of acetone in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/acetone)
		cost = PAY_TRADESMAN / 3

	ammonia
		name = "Ammonia, 50u Bottle"
		desc = "50 units of ammonia in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/ammonia)
		cost = PAY_TRADESMAN / 3

	phenol
		name = "Phenol, 50u Bottle"
		desc = "50 units of phenol in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/phenol)
		cost = PAY_TRADESMAN / 3
