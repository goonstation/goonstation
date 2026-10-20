/datum/unit_test/regression/reagent_transfer_to_overfilled_holder/Run()
	var/obj/item/reagent_containers/glass/beaker/source = new
	var/obj/item/reagent_containers/glass/beaker/target = new

	source.reagents.add_reagent("water", 10)
	target.reagents.add_reagent("water", 10)

	var/source_volume = source.reagents.total_volume
	var/target_volume = target.reagents.total_volume

	target.reagents.maximum_volume = 0

	source.reagents.trans_to(target, 10)

	TEST_ASSERT_EQUAL(source.reagents.total_volume, source_volume, "Transfer to overfilled holder changed source volume.")
	TEST_ASSERT_EQUAL(target.reagents.total_volume, target_volume, "Transfer to overfilled holder changed target volume.")

/datum/unit_test/regression/reagent_transfer_direct_non_positive_amount/Run()
	var/obj/item/reagent_containers/glass/beaker/source = new
	var/obj/item/reagent_containers/glass/beaker/target = new

	source.reagents.add_reagent("water", 10)

	var/source_volume = source.reagents.total_volume

	source.reagents.trans_to_direct(target.reagents, -5)

	TEST_ASSERT_EQUAL(source.reagents.total_volume, source_volume, "Negative direct transfer changed source volume.")
	TEST_ASSERT_EQUAL(target.reagents.total_volume, 0, "Negative direct transfer added target volume.")

/datum/unit_test/regression/reagent_transfer_direct_amount_over_total/Run()
	var/obj/item/reagent_containers/glass/beaker/source = new
	var/obj/item/reagent_containers/glass/beaker/target = new

	source.reagents.add_reagent("water", 10)

	source.reagents.trans_to_direct(target.reagents, 20)

	TEST_ASSERT_EQUAL(source.reagents.total_volume, 0, "Over-total direct transfer left source volume.")
	TEST_ASSERT_EQUAL(target.reagents.total_volume, 10, "Over-total direct transfer exceeded source volume.")
