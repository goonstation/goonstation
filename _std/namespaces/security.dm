/// Namespace for all things securtiy.
CREATE_NAMESPACE(SECURITY)

/// Tickets.
CREATE_NAMESPACE(SECURITY, TICKET)
ADD_TO_NAMESPACE(SECURITY, TICKET)(var/const/MAX_FINE_NO_APPROVAL = 500)

/// Ticketing levels used in ticket master app and for approving tickets.
CREATE_NAMESPACE(SECURITY, TICKET, LEVEL)
ADD_TO_NAMESPACE(SECURITY, TICKET, LEVEL)(var/const/NONE = 0)
ADD_TO_NAMESPACE(SECURITY, TICKET, LEVEL)(var/const/TICKET = 1)
ADD_TO_NAMESPACE(SECURITY, TICKET, LEVEL)(var/const/FINE_SMALL = 2)
ADD_TO_NAMESPACE(SECURITY, TICKET, LEVEL)(var/const/FINE_LARGE = 3)

/// Sechuds flags stuff.
CREATE_NAMESPACE(SECURITY, ARREST)
/// Maximum length of a flag, should always be short.
ADD_TO_NAMESPACE(SECURITY, ARREST)(var/const/SECHUD_FLAG_MAX_CHARS = 10)

/// Arrest states that are displayed through security computers and/or on sechuds. Note the strings are output to players and match up with a `.dmi` icon.
CREATE_NAMESPACE(SECURITY, ARREST, STATE)
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/NONE = "None")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/RELEASED = "Released")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/INCARCERATED = "Incarcerated")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/PAROLE = "Parolled")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/ARREST = "*Arrest*")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/DETAIN = "*Detain*")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/CONTRABAND = "Contraband")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/SUSPECT = "Suspect")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/LOYAL_IN_PROGRESS = "Loyal_Progress")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/LOYAL = "Loyal")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/REVHEAD = "RevHead")
ADD_TO_NAMESPACE(SECURITY, ARREST, STATE)(var/const/CLOWN = "Clown")
