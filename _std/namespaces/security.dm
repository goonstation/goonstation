/// Namespace for all things securtiy. "SECURITY" already taken, sadly and OpenDream won't stand it.
CREATE_NAMESPACE(SEC)

/// Tickets
CREATE_NAMESPACE(SEC, TICKET)
ADD_TO_NAMESPACE(SEC, TICKET)(var/const/MAX_FINE_NO_APPROVAL = 500)

/// Ticketing levels used in ticket master app and for approving tickets
CREATE_NAMESPACE(SEC, TICKET, LEVEL)
ADD_TO_NAMESPACE(SEC, TICKET, LEVEL)(var/const/NONE = 0)
ADD_TO_NAMESPACE(SEC, TICKET, LEVEL)(var/const/TICKET = 1)
ADD_TO_NAMESPACE(SEC, TICKET, LEVEL)(var/const/FINE_SMALL = 2)
ADD_TO_NAMESPACE(SEC, TICKET, LEVEL)(var/const/FINE_LARGE = 3)

/// Sechuds flags stuff
CREATE_NAMESPACE(SEC, ARREST)
/// maximum length of a flag, should always be short
ADD_TO_NAMESPACE(SEC, ARREST)(var/const/SECHUD_FLAG_MAX_CHARS = 10)

/// arrest states that are displayed through security computers and/or on sechuds. note the strings are output to players and/or match up with .dmi icon
CREATE_NAMESPACE(SEC, ARREST, STATE)
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/NONE = "None")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/RELEASED = "Released")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/INCARCERATED = "Incarcerated")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/PAROLE = "Parolled")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/ARREST = "*Arrest*")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/DETAIN = "*Detain*")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/CONTRABAND = "Contraband")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/SUSPECT = "Suspect")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/LOYAL_IN_PROGRESS = "Loyal_Progress")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/LOYAL = "Loyal")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/REVHEAD = "RevHead")
ADD_TO_NAMESPACE(SEC, ARREST, STATE)(var/const/CLOWN = "Clown")
