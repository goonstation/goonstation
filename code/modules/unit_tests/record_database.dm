/datum/db_record/unit_test

/datum/db_record/unit_test/build_fields()
	return alist(
		"id"			= new /datum/record_field/string(src, "ID", "000000", @"[a-f0-9]{6}"),
		"test_id"		= new /datum/record_field/number(src, "Test ID", 0),
		"test_index"	= new /datum/record_field/string(src, "Test Index", "0"),
		"test_name"		= new /datum/record_field/string(src, "Test Name", "New Record"),
	)


/datum/unit_test/record_database
	var/datum/record_database/db

/datum/unit_test/record_database/Run()
	db = new(list("test_id", "test_index"), /datum/db_record/unit_test)

	TEST_ASSERT("test_id" in db.indices, "Index test_id not created.")
	TEST_ASSERT("test_index" in db.indices, "Index test_index not created.")

	var/datum/db_record/unit_test/r1 = new()
	db.add_record(r1)
	TEST_ASSERT(r1 in db.records, "Record not added to the database.")

	r1["test_id"] = 42
	TEST_ASSERT(r1["test_id"] == 42, "Record test_id not changed after assignment.")
	TEST_ASSERT(r1 in db.indices["test_id"][42], "Record not added to an index after changing the field.")
	TEST_ASSERT(db.find_record("test_id", 42) == r1, "Record not found after adding it to the db.")
	TEST_ASSERT(length(db.find_records("test_id", 42)) == 1, "Incorrect find_records output size.")

	r1["test_id"] = 1
	TEST_ASSERT(!(r1 in db.indices["test_id"][42]), "Record still in the old index after changing value.")
	TEST_ASSERT(db.find_record("test_id", 42) != r1, "Record found for old value of test_id.")
	TEST_ASSERT(db.find_record("test_id", 1) == r1, "Record not found for new value of test_id.")

	var/datum/db_record/unit_test/r2 = new()
	r2["test_id"] = 1
	r2["test_index"] = "test"
	r2["test_name"] = "test2"
	db.add_record(r2)
	TEST_ASSERT(length(db.records) == 2, "Incorrect length of the database after adding a second record.")
	TEST_ASSERT(length(db.indices["test_id"][1]) == 2, "test_id index length incorrect after adding a second record.")
	TEST_ASSERT(length(db.find_records("test_id", 1)) == 2, "Incorrect find_records output size with 2 records.")
	TEST_ASSERT(db.find_record("test_name", "test2") == r2, "Incorrect result of find_record for unindexed column.")

	r2.delete()
	TEST_ASSERT(isnull(r2.get_db()), "A record got deleted but it still holds a reference to its database.")
	TEST_ASSERT(length(db.records) == 1, "Incorrect length of the database after removing a record.")
	TEST_ASSERT(length(db.indices["test_id"][1]) == 1, "test_id index length incorrect after removing a record.")

	qdel(r1)
	TEST_ASSERT(length(db.records) == 0, "Incorrect length of the database after removing all records.")
	TEST_ASSERT(length(db.indices["test_id"][1]) == 0, "test_id index length incorrect after removing all records.")

