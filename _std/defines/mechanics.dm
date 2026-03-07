///Analyser bitflags obviously use powers of two


#define ANALYSER_BLACKLIST 0 //Just for nicety, use this to unset all flags so scanning always fails silently.
//Scan options
#define ANALYSER_ALLOWED 1<<0 //Allows this item to be scanned.
#define ANALYSER_ALL 1<<0 //Syntaxic sugar, just allows a scanner to scan anything that is allowed.
#define ANALYSER_FAILFEEDBACK 1<<1 //If scanning would fail, gives feedback instead of silently failing.
#define ANALYSER_SKIP_IF_FAIL 1<<2 //If scanning would fail, it does the normal attackby logic. Used for putting things on tables, etc. This behaviour overrides failfeedback.
#define ANALYSER_SYNDIE_ONLY 1<<3 //Only syndicate analysers can scan this item

//Major Categories
#define ANALYSER_DEVICE 1<<4 //Anything that inherets from device
#define ANALYSER_MACHINERY 1<<5 //Anything that inherets from machinery
#define ANALYSER_ELECTRONIC 1<<6 //Anything electronic
#define ANALYSER_OTHER 1<<7 //Anything the Device Analyzer used to be able to scan but doesn't fit into the above catagories
//etc


#define DEVICE_ANALYZER_ALLOWED_TAGS ANALYSER_DEVICE | ANALYSER_MACHINERY | ANALYSER_ELECTRONIC | ANALYSER_OTHER

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
#define ANALYSIS_SIGNAL_SKIPPED 0 //Signals return 0 if the component doesn't exist, in which case we want to skip
#define ANALYSIS_SIGNAL_SUCCESS 1
#define ANALYSIS_SIGNAL_FAILURE 2
