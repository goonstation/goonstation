ABSTRACT_TYPE(/datum/cyberintel/threatgroup)
/datum/cyberintel/threatgroup
	var/name = "Threat Group-####"
	var/datum/computer/file/terminal_program/malware/malware = null
	var/hash = "42042069"
	var/severity = "3"

/datum/cyberintel/threatgroup/syndira
	name = "Syndira"
	malware = /datum/computer/file/terminal_program/malware/grifeload/syndira

/datum/cyberintel/threatgroup/plasmasteel
	name = "PLASMASTEEL"
	malware = /datum/computer/file/terminal_program/malware/background/electrum/electrumxx/plasmasteel

/datum/cyberintel/threatgroup/greytide // aka '3x80-Tide'
	name = "3x80-Tide"
	malware = /datum/computer/file/terminal_program/malware/greytide

/datum/cyberintel/threatgroup/cluwnecompany // aka '3x80-Tide'
	name = "The Cluwne Company"
	malware = /datum/computer/file/terminal_program/malware/cluwnebash
