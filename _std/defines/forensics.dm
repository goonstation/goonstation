
#define FORENSIC_GROUP_NONE 0 // Should only be used by errors
#define FORENSIC_GROUP_TEXT 1
#define FORENSIC_GROUP_NOTES 2 // Basically a misc section
#define FORENSIC_GROUP_SLEUTH 3 // Pug sleuthing smells
#define FORENSIC_GROUP_ADMINPRINTS 4 // Chain of custody for admins
#define FORENSIC_GROUP_FINGERPRINTS 5

// Each group has a unique variable. Use that to create a new group.
// Placed here together with the FORENSIC_GROUP variable defines
/datum/forensic_holder/proc/forensic_group_create(category)
	var/datum/forensic_group/group
	switch(category)
		if(FORENSIC_GROUP_TEXT) group = new/datum/forensic_group/text
		if(FORENSIC_GROUP_NOTES) group = new/datum/forensic_group/basic_list/notes
		if(FORENSIC_GROUP_SLEUTH) group = new/datum/forensic_group/basic_list/sleuth
		if(FORENSIC_GROUP_ADMINPRINTS) group = new/datum/forensic_group/adminprints
		if(FORENSIC_GROUP_FINGERPRINTS) group = new/datum/forensic_group/fingerprints
	if(!group)
		CRASH("Forensic group category [category] not found.")
	return group

#define FORENSIC_USED (1 << 0) // Check & mark stored forensics_data to prevent two holders from having the same data.
#define FORENSIC_FAKE (1 << 1) // This evidence is fake / planted (and should be ignored by admins)
#define FORENSIC_TRACE (1 << 2) // Use to mark evidence as difficult to detect
#define FORENSIC_REMOVE_CLEANING (1 << 3)
#define FORENSIC_REMOVE_ALL (FORENSIC_REMOVE_CLEANING)

#define FORENSIC_HEADER_NOTES "Notes"
#define FORENSIC_HEADER_FINGERPRINTS "Fingerprints"
#define FORENSIC_HEADER_DNA "DNA Samples"

#define FORENSIC_VALUE_IGNORE 1 // How basic data evidence value is affected when duplicate evidence is added
#define FORENSIC_VALUE_SUM 2
#define FORENSIC_VALUE_MULT 3
#define FORENSIC_VALUE_MAX 4
#define FORENSIC_VALUE_MIN 5

// Chose 16 letters that look distinct and sort of fingerprinty with curves and such
#define FORENSIC_CHARS_FINGERPRINTS list("a","b","c","d","e","g","n","o","p","q","s","u","v","x","y","z")
#define FORENSIC_CHARS_HEX list("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")

#define FORENSIC_GLOVE_MASK_FINGERLESS "0123-4567-89AB-CDEF"
#define FORENSIC_GLOVE_MASK_NONE "...???..."
