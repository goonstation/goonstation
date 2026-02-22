//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs == rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to not be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Constants indicating unit test completion status
#define UNIT_TEST_PASSED 0
#define UNIT_TEST_FAILED 1

#include "metadata_type_typos.dm"
#include "rand.dm"
#include "deletions.dm"
#include "explosions.dm"
#include "monkey_thunderdome.dm"
#include "reagent_id_typos.dm"
#include "record_database.dm"
#include "passability_cache.dm"
#include "bsp.dm"
#include "unit_test.dm"
#include "building_materials_mat_amount.dm"
#include "bioeffect_id_uniqueness.dm"
#include "reagent_id_uniqueness.dm"
#include "trait_id_uniqueness.dm"
#include "material_id_uniqueness.dm"
#include "action_id_uniqueness.dm"
#include "antag_popup_existence.dm"
#include "job_name_uniqueness.dm"
#include "mutation_combo_valid_ids.dm"
#include "od_compile_bot.dm"
#include "terrainify.dm"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
#endif
