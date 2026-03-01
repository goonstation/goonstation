///Analyser bitflags obviously use powers of two

//Just for nicety
#define ANALYSER_BLACKLIST 0 //Fails

//Scan options
#define ANALYSER_ALLOWED 2**0 //Allows this item to be scanned.
#define ANALYSER_FAILFEEDBACK 2**1 //If scanning would fail, gives feedback instead of silently failing.
#define ANALYSER_SKIP_IF_FAIL 2**2 //If scanning would fail, it does the normal attackby logic. Used for putting things on tables, etc.
#define ANALYSER_SYNDIE_ONLY 2**3 //Only syndicate analysers can scan this item

//Major Categories
#define ANALYSER_ELECTRONIC 2**4 //Device Analyser can only scan electronics
#define ANALYSER_CLOTHING 2**5



/// The atom cannot be scanned by the scanner, probably due to lacking materials.
#define MECHANICS_ANALYSIS_INCOMPATIBLE 0
/// The scan attempt succeeded.
#define MECHANICS_ANALYSIS_SUCCESS 1
/// The atom has already been scanned by the device analyzer being used on it.
#define MECHANICS_ANALYSIS_ALREADY_SCANNED 2

