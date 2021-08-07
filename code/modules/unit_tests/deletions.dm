/// This is for regression tests of deletions that used to runtime.
/// This would ideally be replaced by Del The World, unit testing every single deletion.
/datum/unit_test/deletion_regressions

/datum/unit_test/deletion_regressions/Run()
	Fail("Unknown chemical id \"[id]\" in recipe (required_reagents or inhibitor) [R.type]")

