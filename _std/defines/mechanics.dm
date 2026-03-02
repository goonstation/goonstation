///Analyser bitflags obviously use powers of two

//Just for nicety
#define ANALYSER_BLACKLIST 0 //Fails

//Scan options
#define ANALYSER_ALLOWED 2**0 //Allows this item to be scanned.
#define ANALYSER_ALL 2**0 //Syntaxic sugar, just allows a scanner to scan anything that is allowed.
#define ANALYSER_FAILFEEDBACK 2**1 //If scanning would fail, gives feedback instead of silently failing.
#define ANALYSER_SKIP_IF_FAIL 2**2 //If scanning would fail, it does the normal attackby logic. Used for putting things on tables, etc. This behaviour overrides failfeedback.
#define ANALYSER_SYNDIE_ONLY 2**3 //Only syndicate analysers can scan this item

//Major Categories
#define ANALYSER_DEVICE 2**4
#define ANALYSER_MACHINERY 2**5
//etc


/// The atom cannot be scanned by the scanner, due to lacking materials or being blacklisted.
#define MECHANICS_ANALYSIS_IMPOSSIBLE 0
/// The scan attempt succeeded.
#define MECHANICS_ANALYSIS_SUCCESS 1
/// The atom has already been scanned by the device analyzer being used on it.
#define MECHANICS_ANALYSIS_ALREADY_SCANNED 2
/// Item requires syndie scanner
#define MECHANICS_ANALYSIS_ILLEGAL 3
/// The atom cannot be scanned by this specific scanner due to it's tags
#define MECHANICS_ANALYSIS_INCOMPATIBLE 4

///Signal return values
#define ANALYSIS_SIGNAL_FAILURE 2
#define ANALYSIS_SIGNAL_SUCCESS 1
#define ANALYSIS_SIGNAL_SKIPPED 0
