/// This atom can be scanned normally with a device analyzer.
#define MECHANICS_INTERACTION_ALLOWED 0
/// This atom can be scanned, but if scanning would fail, it does the normal attackby logic. Used for putting things on tables, etc.
#define MECHANICS_INTERACTION_SKIP_IF_FAIL 1
/// This atom cannot be scanned at all.
#define MECHANICS_INTERACTION_BLACKLISTED 2

/// The scan attempt succeeded.
#define MECHANICS_ANALYSIS_SUCCESS 1
/// The atom cannot be scanned by the scanner, probably due to lacking materials.
#define MECHANICS_ANALYSIS_INCOMPATIBLE 2
/// The atom has already been scanned by the device analyzer being used on it.
#define MECHANICS_ANALYSIS_ALREADY_SCANNED 3
