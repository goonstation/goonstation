
#ifdef SECRETS_ENABLED
#if SECRETS_ENABLED == 0
#undef SECRETS_ENABLED
#endif
#endif

#ifndef SECRETS_ENABLED

//Enables placeholder objects
#include "../code/_placeholder.dm"

//Future Expansion
#include "../code/_publicVersion.dm"

#endif
