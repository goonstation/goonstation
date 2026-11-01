//------------ DWAINE Permissions ------------//
CREATE_NAMESPACE(DWAINE, PERM)

CREATE_NAMESPACE(DWAINE, PERM, BIT)
/// The owner may read.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OWNER_READ = (1 << 0))
/// The owner may write.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OWNER_WRITE = (1 << 1))
/// The owner may execute.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OWNER_EXECUTE	= (1 << 2))
/// The group may read.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/GROUP_READ = (1 << 3))
/// The group may write.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/GROUP_WRITE = (1 << 4))
/// The group may execute.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/GROUP_EXECUTE = (1 << 5))
/// Others may read.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OTHER_READ = (1 << 6))
/// Others may write.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OTHER_WRITE = (1 << 7))
/// Others may execute.
ADD_TO_NAMESPACE(DWAINE, PERM, BIT)(var/const/OTHER_EXECUTE = (1 << 8))


//------------ DWAINE Default Permissions Sets ------------//
CREATE_NAMESPACE(DWAINE, PERM, DEFAULT)

/// No one may access. (000)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/NONE = 0)
/// Only owner can read. (400)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ONLY_OWNER_READ = (DWAINE::PERM::BIT::OWNER_READ))
/// Only owner can read and write. (600)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ONLY_OWNER_READ_WRITE = (DWAINE::PERM::BIT::OWNER_READ | DWAINE::PERM::BIT::OWNER_WRITE))
/// Everyone can only write. (222)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ALL_WRITE_ONLY = (DWAINE::PERM::BIT::OWNER_WRITE | DWAINE::PERM::BIT::GROUP_WRITE | DWAINE::PERM::BIT::OTHER_WRITE))
/// Everyone can only read. (444)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ALL_READ_ONLY = (DWAINE::PERM::BIT::OWNER_READ | DWAINE::PERM::BIT::GROUP_READ | DWAINE::PERM::BIT::OTHER_READ))
/// Only owner can use. (700)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ONLY_OWNER_ACCESS = (DWAINE::PERM::BIT::OWNER_READ | DWAINE::PERM::BIT::OWNER_WRITE | DWAINE::PERM::BIT::OWNER_EXECUTE))
/// Anyone can read, but only owner may write. (644)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ALL_READ_OWNER_WRITE = (DWAINE::PERM::DEFAULT::ALL_READ_ONLY | DWAINE::PERM::BIT::OWNER_WRITE))
/// Anyone can read and write. (666)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ALL_READ_WRITE_ONLY = (DWAINE::PERM::DEFAULT::ALL_READ_ONLY | DWAINE::PERM::DEFAULT::ALL_WRITE_ONLY))
/// Anyone can read and execute, but only owner may write. (755)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ONLY_OWNER_WRITE = (DWAINE::PERM::DEFAULT::ALL_READ_OWNER_WRITE | DWAINE::PERM::BIT::GROUP_EXECUTE | DWAINE::PERM::BIT::OTHER_EXECUTE))
/// Anyone can use in any way. (777)
ADD_TO_NAMESPACE(DWAINE, PERM, DEFAULT)(var/const/ALLACCESS = (~0))
