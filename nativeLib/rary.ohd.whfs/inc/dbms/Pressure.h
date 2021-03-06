/*
    File: Pressure.h
    Author  : CDBGEN
    Created : Wed Aug 06 12:34:16 EDT 2008 using database hd_ob83empty
    Description: This header file is associated with its .pgc file 
            and defines functions and the table's record structure.
*/
#ifndef Pressure_h
#define Pressure_h


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>
#include "DbmsAccess.h"
#include "DbmsUtils.h"
#include "List.h"
#include "GeneralUtil.h"
#include "dbmserrs.h"
#include "datetime.h"
#include "time_convert.h"



typedef struct _Pressure
{
    Node		node;
    char		lid[9];
    char		pe[3];
    short		dur;
    char		ts[3];
    char		extremum[2];
    dtime_t		obstime;
    double		value;
    char		shef_qual_code[2];
    long		quality_code;
    short		revision;
    char		product_id[11];
    dtime_t		producttime;
    dtime_t		postingtime;
    List		list;
} Pressure;
/*
    Function Prototypes
*/
    Pressure* GetPressure(const char * where);
    Pressure* SelectPressure(const char * where);
    int SelectPressureCount(const char * where);
    int PutPressure(const Pressure * structPtr);
    int InsertPressure(const Pressure * structPtr);
    int UpdatePressure(const Pressure* structPtr, const char *where);
    int DeletePressure(const char *where);
    int UpdatePressureByRecord (const Pressure * newStructPtr, const Pressure * oldStructPtr);
    int InsertOrUpdatePressure(const Pressure * structPtr);
    int InsertIfUniquePressure(const Pressure * structPtr, bool *isUnique);
    bool PressureExists(const Pressure * structPtr);
    int DeletePressureByRecord(const Pressure * structPtr);
    void GetPressurePrimaryKeyWhereString (const Pressure * structPtr, char returnWhereString[] );
    void FreePressure(Pressure * structPtr);
    DbStatus * GetPressureDbStatus();
    void SetPressureErrorLogging(int value);
#endif
