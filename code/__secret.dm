
#ifndef SECRETS_ENABLED

//Enables placeholder objects
#include "_placeholder.dm"

//Future Expansion
#include "_publicVersion.dm"

#endif

#ifdef SECRETS_ENABLED
#if SECRETS_ENABLED == 0
#undef SECRETS_ENABLED
#endif
#endif
