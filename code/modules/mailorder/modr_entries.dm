/* //apparently is suck
/proc/build_mail_order_cache()
	mail_order_entries.Cut()
	for(var/S in concrete_typesof(/datum/mail_order))
		mail_order_entries += new S()
*/

ABSTRACT_TYPE(/datum/mail_order)
/datum/mail_order
	var/name = "Juicer Schweet's Spaghetti Western"
	var/desc = "Be like the three-second elephant with heated value in space-bark."
	var/list/order_items = list() // should not exceed 7 items, as mail order is sent in a box item
	var/cost = PAY_UNTRAINED
	var/list/order_perm = list() // optional access requirement to order a given item


ABSTRACT_TYPE(/datum/mail_order/medical/)
/datum/mail_order/medical
	//top level order_perm omitted intentionally
	analyze_kit
		name = "Analyzer Triage Bundle"
		desc = "Order a health analyzer, and we'll throw in a bandage for free!"
		order_items = list(/obj/item/device/analyzer/healthanalyzer,/obj/item/bandage)
		cost = PAY_UNTRAINED / 2

	analyze_up
		name = "Analyzer Deluxe Upgrade"
		desc = "Top-of-the-line enhancements for any standard health analyzer."
		order_items = list(/obj/item/device/analyzer/healthanalyzer_upgrade,/obj/item/device/analyzer/healthanalyzer_organ_upgrade)
		cost = PAY_TRADESMAN / 4

	auto_char
		name = "Charcoal Auto-Injector"
		desc = "A rapid single-use injector containing ten units of charcoal."
		order_items = list(/obj/item/reagent_containers/emergency_injector/charcoal)
		cost = PAY_TRADESMAN / 4

	auto_epi
		name = "Epinephrine Auto-Injector"
		desc = "A rapid single-use injector containing ten units of epinephrine."
		order_items = list(/obj/item/reagent_containers/emergency_injector/epinephrine)
		cost = PAY_TRADESMAN / 4


ABSTRACT_TYPE(/datum/mail_order/chem)
/datum/mail_order/chem
	order_perm = list(access_chemistry,access_heads)

	acetone
		name = "Acetone, 50u Bottle"
		desc = "50 units of acetone in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/acetone)
		cost = PAY_TRADESMAN / 4

	ammonia
		name = "Ammonia, 50u Bottle"
		desc = "50 units of ammonia in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/ammonia)
		cost = PAY_TRADESMAN / 4

	phenol
		name = "Phenol, 50u Bottle"
		desc = "50 units of phenol in a standard reagent bottle."
		order_items = list(/obj/item/reagent_containers/glass/bottle/phenol)
		cost = PAY_TRADESMAN / 4
