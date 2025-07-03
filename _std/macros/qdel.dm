///if thing is null or has been qdeled
#define QDELETED(thing) (isnull(thing) || thing.disposed)

// Calls qdel on an item and then sets it to null
#define QDEL_NULL(item) qdel(item); item = null
