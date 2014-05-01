/*******************************************************************************
* FILENAME:            create_mosaic.c
*
* Purpose:
* This function is converted from FORTRAN code: mosaic.f.
* it creates mosaics of the raw radar data and radar height data.
*
* calling function: runRMosaic
* functions called: LatLongToHrap, calculatePixelHeight
*
* input variables
*
* pRadarLocRecord - data record from radarLoc table
*
* radar - two-dimensional radar data
*
* index - radar index data
*
* radarMiscBins - misc bin data
*
* pGeoData - global HRAP lowerleft-corner bin and dimension
*           and dimension of the RFC estimation domain
*
* output variables
*
* RMosaic - two-dimensional raw radar data
*
* MHeight - two-dimensional radar height data
*
* radarID - two-dimensional radar ID data
*
* MODIFICATION HISTORY:
*   DATE         PROGRAMMER        DESCRIPTION/REASON
*   May 2005     Guoxian Zhou      finish conversion to C Language
*
********************************************************************************
*/

#include "mpe_fieldgen.h"

void MPEFieldGen_createMosaic(const radarLoc_record_struct * pRadarLocRecord,
                  float radar [ ] [ NUM_DPA_COLS ] ,
                  short int radarMiscBins [ ] [ NUM_DPA_COLS ],
                  const int index ,
                  const geo_data_struct * pGeoData ,
                  double ** RMosaic ,
                  double ** MHeight,
                  int ** radarID,
                  double  ** MaxMosaic,
                  double  ** AvgMosaic,
                  int     ** AvgMosaicNumRadars,
                  int     *  blnMosaic)
{
    static const char * fname = "mpe_radar_beam_height";
    char beamheight_dir [PATH_LEN] = {'\0'};
    static char * rfcwide_beamheight_dir_token = "rfcwide_beamheight_dir";
    char station_file_path [ PATH_LEN + FNAME_LEN ] = {'\0'};
    static double radar_beam_height [NUM_DPA_ROWS][NUM_DPA_COLS];
    double    row, col, pixelHeight = 0 ;
    FILE * fp = NULL;
    static int first = 1;
    int    intRow, intCol ;
    int    i, j ;
    int    length;
    int    status;

    /**
     * If this is the first call, load in the radar beam height data
     * from the radar beam height file.
     **/
     if ( first == 1 )
     {
        first = 0;
        getAppsDefaults ( rfcwide_beamheight_dir_token, beamheight_dir );
        length = strlen ( beamheight_dir );

        if ( length > 0 )
        {
           sprintf ( station_file_path, "%s/%s", beamheight_dir, fname );
        }
        else
        {
           sprintf ( message, "Token %s is no defined.  Application will look "
                              "for the radar beam height file in the current "
                              "working directory.\n",
                              rfcwide_beamheight_dir_token );
           printMessage ( message, logFile );
           strcpy ( station_file_path, fname );
        }

        /* Write a log message indicating that the height file is about to
           be read. */
        getCurrentTime ( currTime );
        sprintf ( message, "%s = time begin read radar height file.\n"
                           "radar height file=%s", currTime,
                           station_file_path );
        printMessage ( message, logFile );

        /* Attempt to open the height data file. */
        fp = fopen ( station_file_path, "r" );

        if ( fp == NULL )
        {
           /* Could not open the station file. */
           sprintf ( message, "Could not open file %s. "
                              "Create radar height file and rerun "
                              "MPE Fieldgen.\n\tProgram exit.",
                              station_file_path );
           shutDownMPE ( message, logFile );
        }

        status = fread ( radar_beam_height, sizeof(double), NUM_DPA_ELEMENTS,
                        fp );

        fclose ( fp );
        fp = NULL ;

        if ( status != NUM_DPA_ELEMENTS )
        {
           sprintf ( message, "Error reading radar height file %s.\n"
                              "\tProgram exit.", station_file_path );
           shutDownMPE ( message, logFile );
        }
     }

    /**
     * locate hrap pixel that radar is in
     **/
    LatLongToHrapByReference ( pRadarLocRecord->latitude ,
                    pRadarLocRecord->longitude ,
                    &row , &col ) ;

    intCol = (int)col ;
    intRow = (int)row ;

    /**
     * calculate starting hrap coordinants
     **/
    for(j = 0; j < NUM_DPA_COLS; j ++)
    {
        for(i = 0; i < NUM_DPA_COLS; i ++)
        {
            /**
             * check radar pixel to make sure it exists,
             * this check insures that the height array
             * is dynamic and varies with radar availabilty.
             **/
            if(radar[i][j] < 0.0)
                continue ;
            /**
             * compute location of radar pixel on national hrap grid,
             * then check to make sure this point is in rfc area.
             **/
            int tmpRow = intRow - 65 + i ;
            int tmpCol = intCol - 65 + j ;

            /* Retrieve the pixel height. */
            pixelHeight = radar_beam_height [ i ][ j ];
            pixelHeight += pRadarLocRecord->elevation ;

            /**
             * check to make sure pixel height
             * is less than that on mosaic.
             *
             * convert x,y coordinates to local
             * coordinates of RMosaic
             * and MHeight array
             **/
            tmpCol -= pGeoData->hrap_x ;
            tmpRow -= pGeoData->hrap_y ;

            if ((tmpCol < 0) || (tmpRow < 0))
                continue ;
            if ((tmpCol >= pGeoData->num_cols) ||
                (tmpRow >= pGeoData->num_rows))
                continue ;

            if ((blnMosaic[rmosaic] == 1) &&
                (MHeight[tmpRow][tmpCol] == MOSAIC_DEFAULT ||
            	 pixelHeight < MHeight[tmpRow][tmpCol]))
            {
                /**
                 * check to make sure pixel is not a radarMiscBins
				 * additional check for fake radarMiscBins data.
                 **/
                if(radarMiscBins[i][j] < 0) continue ;
                if(radarMiscBins[i][j] != 0)
                {
                    RMosaic[tmpRow][tmpCol] = (double)radar[i][j] ;
                    MHeight[tmpRow][tmpCol] = pixelHeight ;
                    radarID[tmpRow][tmpCol] = index ;
                }
            }


            // additional condition added by Ram for selective generation of mosaics
            // modification in the following line of code
            // Added by Ram for the average and max mosaic calculations

            // code added to calculate the average and max mosaics
            // the following code just adds up the values for the average
            // mosaic from each contributing radar. this is later on used
            // by the code in the run_rmosaic.c to calculate the real average
            // by taking into account how many radars actually contributed.
            // for the max mosaic, end of the radar loop would produce the
            // final result
            // -------------------------------

            if(radarMiscBins[i][j] != 0)
            {
                if(blnMosaic[avgrmosaic] == 1 && radar[i][j] != RADAR_DEFAULT)
                {
                    if(AvgMosaic[tmpRow][tmpCol] != MOSAIC_DEFAULT)
                    {
                        AvgMosaic[tmpRow][tmpCol] += (double)radar[i][j];
                    }
                    else if(AvgMosaic[tmpRow][tmpCol] == MOSAIC_DEFAULT)
                    {
                        AvgMosaic[tmpRow][tmpCol] = (double)radar[i][j];
                    }
                    (AvgMosaicNumRadars[tmpRow][tmpCol])++;
                }

                if(blnMosaic[maxrmosaic] == 1 &&
                 MaxMosaic[tmpRow][tmpCol] < (double)radar[i][j])
                {
                    MaxMosaic[tmpRow][tmpCol] = (double)radar[i][j];
                }
            }
            // -------------------------------
            // end of ave and max mosaic code
        }
    }

/*  ==============  Statements containing RCS keywords:  */
{static char rcs_id1[] = "$Source$";
 static char rcs_id2[] = "$Id$";}
/*  ===================================================  */

}
