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

#define REMOVE_FROM_UNSORTED(L, INDEX) \
	{ \
		L[INDEX] = L[length(L)]; \
		L.len-- \
	}
