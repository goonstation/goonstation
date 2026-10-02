/// For Accesses
CREATE_NAMESPACE(ACCESS)

// Could do standard access later, though I'm sure something like that is probably not namespaced for a reason

/// Skeleton Crewing
CREATE_NAMESPACE(ACCESS, SKELETON)

/// Different Departments
CREATE_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)

ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/SECURITY = list(access_security, access_brig, access_forensics_lockers, access_ticket, access_morgue, access_securitylockers, access_carrypermit,
									   		access_contrabandpermit, access_crematorium,  access_medical_lockers, access_engineering_engine)) // Bigger cause non-antag gurantee, actually going to use it for good
ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/CIVILIAN = list(access_kitchen, access_bar, access_janitor, access_hydro, access_ranch))
ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/MEDICAL =  list(access_medical, access_medlab, access_morgue, access_medical_lockers, access_pharmacy, access_robotics))
ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/ENGINEERING = list(access_engineering, access_engineering_storage, access_engineering_power, access_engineering_engine, access_engineering_control, access_mining, access_cargo, access_supply_console))
ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/RESEARCH = list(access_research, access_researchfoyer, access_telesci, access_artlab, access_chemistry))
ADD_TO_NAMESPACE(ACCESS, SKELETON, DEPARTMENT)(var/const/list/COMMAND = list(access_heads))
