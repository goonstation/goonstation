/*
 * NANOTRASEN APPROVED KEYS LIST
 * wonkmin is bestmin si
 *
 * UPDATE 04/03/11:
 * the "NT" list is the complete list of elite security dudes,
 * since we only have one elite security job (head of security)
 */

var/list/NT = dd_file2list("+secret/strings/nt.txt")


// this list is for mentors, everyone in the NT
// list is also a mentor
// ok this has changed and not everyone in NT is a mentor

// this is for people who are mentors but not HOSes
var/list/mentors = dd_file2list("+secret/strings/mentors.txt")

