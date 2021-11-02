/datum/unit_test/record_database
	var/datum/record_database/db

/datum/unit_test/record_database/Run()
	db = new(list("id", "test_index"))

	TEST_ASSERT("id" in db.indices, "Index id not created.")
	TEST_ASSERT("test_index" in db.indices, "Index test_index not created.")

	var/datum/db_record/r1 = db.create_record(list())
	TEST_ASSERT(r1 in db.records, "Record not added to the database.")
	TEST_ASSERT(length(db.indices["id"]) == 0, "Index non-empty after adding an empty record.")

	r1["id"] = 42
	TEST_ASSERT(r1["id"] == 42, "Record id not changed after assignment.")
	TEST_ASSERT(r1 in db.indices["id"]["42"], "Record not added to an index after changing the field.")
	TEST_ASSERT(db.find_record("id", 42) == r1, "Record not found after adding it to the db.")
	TEST_ASSERT(length(db.find_records("id", 42)) == 1, "Incorrect find_records output size.")

	r1["id"] = 1
	TEST_ASSERT(!(r1 in db.indices["id"]["42"]), "Record still in the old index after changing value.")
	TEST_ASSERT(db.find_record("id", 42) != r1, "Record found for old value of id.")
	TEST_ASSERT(db.find_record("id", 1) == r1, "Record not found for new value of id.")

	var/datum/db_record/r2 = db.create_record(list("id" = 1, "test_index" = "test", "name" = "test2"))
	TEST_ASSERT(length(db.records) == 2, "Incorrect length of the database after adding a second record.")
	TEST_ASSERT(length(db.indices["id"]["1"]) == 2, "ID index length incorrect after adding a second record.")
	TEST_ASSERT(length(db.find_records("id", 1)) == 2, "Incorrect find_records output size with 2 records.")
	TEST_ASSERT(db.find_record("name", "test2") == r2, "Incorrect result of find_record for unindexed column.")

	r2.delete()
	TEST_ASSERT(isnull(r2.get_db()), "A record got deleted but it still holds a reference to its database.")
	TEST_ASSERT(length(db.records) == 1, "Incorrect length of the database after removing a record.")
	TEST_ASSERT(length(db.indices["id"]["1"]) == 1, "ID index length incorrect after removing a record.")

	qdel(r1)
	TEST_ASSERT(length(db.records) == 0, "Incorrect length of the database after removing all records.")
	TEST_ASSERT(length(db.indices["id"]["1"]) == 0, "ID index length incorrect after removing all records.")

