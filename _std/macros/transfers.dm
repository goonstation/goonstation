/// Transfer signal helpers

/// Transfer the given movable to the output of the given target or to the loc of the target.
#define TRANSFER_OR_DROP(T, AM) if (!SEND_SIGNAL(T, COMSIG_OUTGOING_TRANSFER, AM)){AM.set_loc(T.loc)}
