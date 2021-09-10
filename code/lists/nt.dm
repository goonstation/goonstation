/*
 * NANOTRASEN APPROVED KEYS LIST
 * wonkmin is bestmin si
 *
 * UPDATE 04/03/11:
 * the "NT" list is the complete list of elite security dudes,
 * since we only have one elite security job (head of security)
 */
#ifdef SECRETS_ENABLED
var/list/NT = dd_file2list("+secret/strings/nt.txt")
#else
var/list/NT = dd_file2list("strings/nt.txt")
#endif
// this list is for mentors, everyone in the NT
// list is also a mentor
// ok this has changed and not everyone in NT is a mentor

// this is for people who are mentors but not HOSes
#ifdef SECRETS_ENABLED
var/list/mentors = dd_file2list("+secret/strings/mentors.txt")
#else
var/list/mentors = dd_file2list("strings/mentors.txt")
#endif

