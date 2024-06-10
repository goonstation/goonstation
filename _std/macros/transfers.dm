// Transfer signal helpers

/// Transfer AM to the output target of T if possible. If this fails, set AM to the loc of T.
#define TRANSFER_OR_DROP(T, AM) if (!SEND_SIGNAL(T, COMSIG_TRANSFER_OUTGOING, AM)){AM.set_loc(T.loc)}
