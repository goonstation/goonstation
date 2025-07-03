#define LAZYLISTINIT(L) \
	if (!L) \
		L = list() \

#define LAZYLISTADD(L, X) \
	if(!L) { L = list(); } \
	L += X; \

#define LAZYLISTADDUNIQUE(L, X) \
	if(!L) { L = list(); } \
	L |= X; \

#define LAZYLISTREMOVE(L, I) \
	if(L) { \
		L -= I; \
		if(!length(L)) { \
			L = null; \
		} \
	} \

/// Add an item to the list if not already present, if the list is null it will initialize it
#define LAZYLISTOR(L, I) if(!L) { L = list(); } L |= I;


#define REMOVE_FROM_UNSORTED(L, INDEX) \
	{ \
		L[INDEX] = L[length(L)]; \
		L.len-- \
	}

/// Sets the length of a lazylist
#define LAZYLISTSETLEN(L, V) if (!L) { L = list(); } L.len = V;

/// Adds the value V to the key K - if the list is null it will initialize it
#define LAZYLISTADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;

/// Removes the value V from the key K, if the key K is empty will remove it from the list, if the list is empty will set the list to null
#define LAZYLISTREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }

/// Accesses an associative list, returns null if nothing is found
#define LAZYLISTACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null

