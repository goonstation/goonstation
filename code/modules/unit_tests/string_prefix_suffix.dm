#define TEST_PREFIX(SAMPLE, PREFIX) TEST_ASSERT(dd_hasprefix(SAMPLE, PREFIX), "'"+ PREFIX + "' was not detected as a prefix for the string '" + SAMPLE + "'")
#define TEST_SUFFIX(SAMPLE, SUFFIX) TEST_ASSERT(dd_hassuffix(SAMPLE, SUFFIX), "'"+ SUFFIX + "' was not detected as a suffix for the string '" + SAMPLE + "'")
#define TEST_PREFIX_EX(SAMPLE, PREFIX) TEST_ASSERT(dd_hasPrefix(SAMPLE, PREFIX), "'"+ PREFIX + "' was not detected as a case-sensitive prefix for the string '" + SAMPLE + "'")
#define TEST_SUFFIX_EX(SAMPLE, SUFFIX) TEST_ASSERT(dd_hasSuffix(SAMPLE, SUFFIX), "'"+ SUFFIX + "' was not detected as a case-sensitive suffix for the string '" + SAMPLE + "'")
#define TEST_NO_PREFIX(SAMPLE, PREFIX) TEST_ASSERT(!dd_hasprefix(SAMPLE, PREFIX), "'"+ PREFIX + "' was incorrectly detected as a prefix for the string '" + SAMPLE + "'")
#define TEST_NO_SUFFIX(SAMPLE, SUFFIX) TEST_ASSERT(!dd_hassuffix(SAMPLE, SUFFIX), "'"+ SUFFIX + "' was incorrectly detected as a suffix for the string '" + SAMPLE + "'")
#define TEST_NO_PREFIX_EX(SAMPLE, PREFIX) TEST_ASSERT(!dd_hasPrefix(SAMPLE, PREFIX), "'"+ PREFIX + "' was incorrectly detected as a case-sensitive prefix for the string '" + SAMPLE + "'")
#define TEST_NO_SUFFIX_EX(SAMPLE, SUFFIX) TEST_ASSERT(!dd_hasSuffix(SAMPLE, SUFFIX), "'"+ SUFFIX + "' was incorrectly detected as a case-sensitive suffix for the string '" + SAMPLE + "'")

/datum/unit_test/string_prefix_suffix/Run()
	// i would add zero-character/degenerate cases here, but i can't decide how those should behave
	// one-character prefix/suffix
	TEST_PREFIX("/", "/")
	TEST_SUFFIX("/", "/")
	TEST_PREFIX_EX("/", "/")
	TEST_SUFFIX_EX("/", "/")
	TEST_PREFIX("/a", "/")
	TEST_NO_SUFFIX("/a", "/")
	TEST_SUFFIX("a/", "/")
	TEST_NO_PREFIX("a/", "/")
	// two-character
	TEST_NO_PREFIX("/", "//")
	TEST_NO_SUFFIX("/", "//")
	TEST_PREFIX("//", "//")
	TEST_SUFFIX("//", "//")
	TEST_PREFIX("//a", "//")
	TEST_SUFFIX("a//", "//")
	TEST_NO_PREFIX("a//", "//")
	TEST_NO_SUFFIX("//a", "//")
	// case-sensitive
	TEST_NO_PREFIX_EX("ABC", "a")
	TEST_NO_SUFFIX_EX("ABC", "c")
	TEST_PREFIX_EX("ABC", "A")
	TEST_PREFIX_EX("ABC", "AB")
	TEST_SUFFIX_EX("ABC", "C")
	TEST_SUFFIX_EX("ABC", "BC")

#undef TEST_PREFIX
#undef TEST_SUFFIX
#undef TEST_PREFIX_EX
#undef TEST_SUFFIX_EX
#undef TEST_NO_PREFIX
#undef TEST_NO_SUFFIX
#undef TEST_NO_PREFIX_EX
#undef TEST_NO_SUFFIX_EX
