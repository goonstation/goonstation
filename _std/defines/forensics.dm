
#define FORENSIC_GROUP_NONE 0 // You are a bug
#define FORENSIC_GROUP_NOTE 1 // Basically a misc section
#define FORENSIC_GROUP_SLEUTH 2 // Pug sleuthing smells

/proc/forensic_group_create(var/category) // Create a new group from its unique variable. Is there a better way to do this? IDK
	var/datum/forensic_group/G
	switch(category)
		if(FORENSIC_GROUP_NOTE) G = new/datum/forensic_group/notes
		if(FORENSIC_GROUP_SLEUTH) G = new/datum/forensic_group/basic_list/sleuth
	return G

#define IS_ADMIN (1 << 1) // Only admins can see this evidence
#define IS_FAKE (1 << 2) // This evidence is fake / planted (and should be ignored by admins)
#define IS_TRACE (1 << 3) // Use to mark evidence as difficult to detect

#define REMOVE_CLEANING (1 << 4) // Can this evidence be washed away?
#define REMOVE_DATA (1 << 5) // Can this evidence be deleted from a computer?
#define REMOVE_REPAIR (1 << 6) // Can this evidence be fixed up (or blown up?)
#define REMOVE_HEAL_BRUTE (1 << 7) // Can this evidence be healed
#define REMOVE_HEAL_BURN (1 << 8)
#define REMOVE_HEAL_TOXIN (1 << 9)
#define REMOVE_HEAL_OXYGEN (1 << 10)

#define REMOVE_HEAL REMOVE_HEAL_BRUTE | REMOVE_HEAL_BURN | REMOVE_HEAL_TOXIN | REMOVE_HEAL_OXYGEN
#define REMOVE_ALL_EVIDENCE REMOVE_CLEANING | REMOVE_DATA | REMOVE_REPAIR | REMOVE_HEAL

#define FORENSIC_BASE_ACCURACY 0.5 // Base modifier for how accurate timestamp estimates are

#define FORENSIC_VALUE_IGNORE 1 // How basic data evidence value is affected when duplicate evidence is added
#define FORENSIC_VALUE_SUM 2
#define FORENSIC_VALUE_MULT 3
#define FORENSIC_VALUE_MAX 4
#define FORENSIC_VALUE_MIN 5

#define HEADER_NOTES "Notes"

// Character lists that can be used for building evidence IDs
#define CHAR_LIST_UPPER list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
#define CHAR_LIST_LOWER list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
#define CHAR_LIST_NUM list("0","1","2","3","4","5","6","7","8","9")
#define CHAR_LIST_SYMBOLS list("#","_","%","&","+","=","-","*","~")
#define CHAR_LIST_HEX list("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")
// Remove letters that can be confused with numbers at a glance
#define CHAR_LIST_UPPER_LIMIT CHAR_LIST_UPPER - list("D","I","O","Q")
#define CHAR_LIST_LOWER_LIMIT CHAR_LIST_LOWER - list("i","j","l","o")
