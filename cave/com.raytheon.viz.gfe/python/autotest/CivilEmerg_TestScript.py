##
# This software was developed and / or modified by Raytheon Company,
# pursuant to Contract DG133W-05-CQ-1067 with the US Government.
# 
# U.S. EXPORT CONTROLLED TECHNICAL DATA
# This software product contains export-restricted data whose
# export/transfer/disclosure is restricted by U.S. law. Dissemination
# to non-U.S. persons whether in the United States or abroad requires
# an export license or other authorization.
# 
# Contractor Name:        Raytheon Company
# Contractor Address:     6825 Pine Street, Suite 340
#                         Mail Stop B8
#                         Omaha, NE 68106
#                         402.291.0100
# 
# See the AWIPS II Master Rights File ("Master Rights File.pdf") for
# further licensing information.
##
# ----------------------------------------------------------------------------
# This software is in the public domain, furnished "as is", without technical
# support, and with no warranty, express or implied, as to its usefulness for
# any purpose.
#
# CivilEmerg_TestScript
#
# Author:
# ----------------------------------------------------------------------------

scripts = [
    {"name":"ADR1",
     "productType" : "CivilEmerg_ADR_Local",
     "commentary": "Basic ADMINISTRATIVE MESSAGE formatter test",
     "checkStrings" : ["Administrative Message"],
     },
    {"name":"ADR2", 
     "productType" : "CivilEmerg_ADR_Local",
     "commentary": "Different Options ADMINISTRATIVE MESSAGE formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Administrative Message"],
     },    
    {"name":"AVA1", 
     "productType" : "CivilEmerg_AVA_Local",
     "commentary": "Basic AVALANCHE WATCH formatter test",
     "checkStrings" : ["Avalanche Watch"],
     },
    {"name":"AVA2", 
     "productType" : "CivilEmerg_AVA_Local",
     "commentary": "Different Options AVALANCHE WATCH formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Avalanche Watch"],
     },
    {"name":"AVW1",  
     "productType" : "CivilEmerg_AVW_Local",
     "commentary": "Basic AVALANCHE WARNING formatter test",
     "checkStrings" : ["Avalanche Warning"],
     },
    {"name":"AVW2",  
     "productType" : "CivilEmerg_AVW_Local",
     "commentary": "Different Options AVALANCHE WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Avalanche Warning"],
     },
    {"name":"CAE1",  
     "productType" : "CivilEmerg_CAE_Local",
     "commentary": "Basic CHILD ABDUCTION EMERGENCY formatter test",
     "checkStrings" : ["Child Abduction Emergency"],
     },
    {"name":"CAE2",  
     "productType" : "CivilEmerg_CAE_Local",
     "commentary": "Different Options CHILD ABDUCTION EMERGENCY formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Child Abduction Emergency"],
     },
    {"name":"CDW1",  
     "productType" : "CivilEmerg_CDW_Local",
     "commentary": "Basic CIVIL DANGER WARNING formatter test",
     "checkStrings" : ["Civil Danger Warning"],
     },
    {"name":"CDW2",  
     "productType" : "CivilEmerg_CDW_Local",
     "commentary": "Different Options CIVIL DANGER WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Civil Danger Warning"],
     },
    {"name":"CEM1",  
     "productType" : "CivilEmerg_CEM_Local",
     "commentary": "Basic CIVIL EMERGENCY MESSAGE formatter test",
     "checkStrings" : ["Civil Emergency Message"],
     },
    {"name":"CEM2",  
     "productType" : "CivilEmerg_CEM_Local", 
     "commentary": "Different Options CIVIL EMERGENCY MESSAGE formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Civil Emergency Message"],
     },
    {"name":"EQR1",  
     "productType" : "CivilEmerg_EQR_Local",
     "commentary": "EARTHQUAKE REPORT formatter test",
     "cmdLineVars": "{('Damage', 'damage'): 'Considerable', ('Official Earthquake Info Source:', 'eqInfo'): 'GOLDEN', ('Felt:', 'felt'): 'moderately', ('How Many Reports:', 'extent'): 'many people', ('Damage Type', 'damageType'): ['Cracked chimneys'], ('Issued By', 'issuedBy'): None, ('Issuance Type', 'issuanceType'): 'Preliminary'}",
     "checkStrings": [
       "Earthquake Report", 
       "An earthquake has been felt moderately by many people",
       "Considerable damage has been reported",
       "Damage reports so far...Cracked chimneys",
       ],
     },
    {"name":"EQW1",  
     "productType" : "CivilEmerg_EQW_Local",
     "commentary": "Basic EARTHQUAKE WARNING formatter test",
     "checkStrings" : ["Earthquake Warning"],
     },
    {"name":"EQW2",  
     "productType" : "CivilEmerg_EQW_Local", 
     "commentary": "Different Options EARTHQUAKE WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Earthquake Warning"],
     },
    {"name":"EVI1",  
     "productType" : "CivilEmerg_EVI_Local",
     "commentary": "Basic EVACUATION IMMEDIATE formatter test",
     "checkStrings" : ["Evacuation Immediate"],
     },
    {"name":"EVI2",  
     "productType" : "CivilEmerg_EVI_Local", 
     "commentary": "Different Options EVACUATION IMMEDIATE formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Evacuation Immediate"],
     },
    {"name":"FRW1",  
     "productType" : "CivilEmerg_FRW_Local",
     "commentary": "Basic FIRE WARNING formatter test",
     "checkStrings" : ["Fire Warning"],
     },
    {"name":"FRW2",  
     "productType" : "CivilEmerg_FRW_Local", 
     "commentary": "Different Options FIRE WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Fire Warning"]},
    {"name":"HMW1",  
     "productType" : "CivilEmerg_HMW_Local",
     "commentary": "Basic HAZARDOUS MATERIAL WARNING formatter test",
     "checkStrings" : ["Hazardous Material Warning"],
     },
    {"name":"HMW2",  
     "productType" : "CivilEmerg_HMW_Local", 
     "commentary": "Different Options HAZARDOUS MATERIAL WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Hazardous Material Warning"],
     },
    {"name":"LAE1",  
     "productType" : "CivilEmerg_LAE_Local",
     "commentary": "Basic LOCAL AREA EMERGENCY formatter test",
     "checkStrings" : ["Local Area Emergency"],
     },
    {"name":"LAE2",  
     "productType" : "CivilEmerg_LAE_Local", 
     "commentary": "Different Options LOCAL AREA EMERGENCY formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Local Area Emergency"],
     },
    {"name":"LEW1",  
     "productType" : "CivilEmerg_LEW_Local",
     "commentary": "Basic LAW ENFORCEMENT WARNING formatter test",
     "checkStrings" : ["Law Enforcement Warning"],
     },
    {"name":"LEW2",  
     "productType" : "CivilEmerg_LEW_Local", 
     "commentary": "Different Options LAW ENFORCEMENT WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Law Enforcement Warning"],
     },
    {"name":"NUW1",  
     "productType" : "CivilEmerg_NUW_Local",
     "commentary": "Basic NUCLEAR POWER PLANT WARNING formatter test",
     "checkStrings" : ["Nuclear Power Plant Warning"],
     },
    {"name":"NUW2",  
     "productType" : "CivilEmerg_NUW_Local", 
     "commentary": "Different Options NUCLEAR POWER PLANT WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Nuclear Power Plant Warning"],
     },
    {"name":"RHW1",  
     "productType" : "CivilEmerg_RHW_Local",
     "commentary": "Basic RADIOLOGICAL HAZARD WARNING formatter test",
     "checkStrings" : ["Radiological Hazard Warning"],
     },
    {"name":"RHW2",  
     "productType" : "CivilEmerg_RHW_Local",
     "commentary": "Different Options RADIOLOGICAL HAZARD WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Radiological Hazard Warning"],
     },
    {"name":"SPW1",  
     "productType" : "CivilEmerg_SPW_Local",
     "commentary": "Basic SHELTER IN PLACE WARNING formatter test",
     "checkStrings" : ["Shelter in Place Warning"],
     },
    {"name":"SPW2",  
     "productType" : "CivilEmerg_SPW_Local",
     "commentary": "Different Options SHELTER IN PLACE WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Shelter in Place Warning"],
     },
    {"name":"TOE1",  
     "productType" : "CivilEmerg_TOE_Local",
     "commentary": "Basic 911 TELEPHONE OUTAGE EMERGENCY formatter test",
     "checkStrings" : ["911 Telephone Outage Emergency"],
     },
    {"name":"TOE2",  
     "productType" : "CivilEmerg_TOE_Local", 
     "commentary": "Different Options 911 TELEPHONE OUTAGE EMERGENCY formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","911 Telephone Outage Emergency"],
     },
    {"name":"VOW1",  
     "productType" : "CivilEmerg_VOW_Local",
     "commentary": "Basic VOLCANO WARNING formatter test",
     "checkStrings" : ["Volcano Warning"],
     },
    {"name":"VOW2",  
     "productType" : "CivilEmerg_VOW_Local", 
     "commentary": "Different Options VOLCANO WARNING formatter test",
     "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'BULLETIN - EAS ACTIVATION REQUESTED'}",
     "checkStrings" : ["BULLETIN - EAS ACTIVATION REQUESTED","Volcano Warning"],
     },
    ]

import TestScript
def testScript(self, dataMgr):
    defaults = {
        "cmdLineVars" :"{('Source', 'source'): 'COLORADO EMERGENCY MANAGEMENT AGENCY DENVER COLORADO', ('Issued By', 'issuedBy'): None, ('EAS Level', 'eas'): 'NONE'}",
        "comboFlag": 1,
        "combinations": "ZONE",
        "deleteGrids": [("Fcst", "Hazards", "SFC", "all", "all")],
        "gridsStartTime": "20090731_1400",
        "orderStrings": 1,
        }
    return TestScript.generalTestScript(self, dataMgr, scripts, defaults)



