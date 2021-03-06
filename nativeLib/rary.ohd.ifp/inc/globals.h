/* globals.h */

#ifndef globals_h
#define globals_h

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <sys/stat.h>

#ifndef X_AND_MOTTF_DEF
#define X_AND_MOTTF_DEF

#include <X11/Intrinsic.h>
#include <X11/StringDefs.h>
#include <X11/Shell.h>
#include <X11/cursorfont.h>

#include <Xm/Xm.h>
#include <Xm/RowColumn.h>
#include <Xm/BulletinB.h>
#include <Xm/PushB.h>
#include <Xm/PushBG.h>
#include <Xm/Label.h>
#include <Xm/List.h>
#include <Xm/DialogS.h>
#include <Xm/Text.h>
#include <Xm/TextF.h>
#include <Xm/ScrollBar.h>
#include <Xm/ScrolledW.h>
#include <Xm/FileSB.h>
#include <Xm/Frame.h>
#include <Xm/Form.h>
#include <Xm/Label.h>
#include <Xm/LabelG.h>
#include <Xm/DrawingA.h>
#include <Xm/Separator.h>
#include <Xm/MessageB.h>
#include <Xm/Scale.h>
#include <Xm/CascadeB.h>
#include <Xm/LabelG.h>
#include <Xm/SeparatoG.h>
#include <Xm/CascadeBG.h>
#include <Xm/PushBG.h>

#endif /* X_AND_MOTTF_DEF       */


#ifndef FLOOD_LEVEL
#define FLOOD_LEVEL

static char    *flood_color_levels[] = {"light gray", "medium spring green",
        				 "yellow", "orange red", "white",
                                         "light_gray"};

#endif /* FLOOD_LEVEL           */


GC      IFP_Map_xs_create_xor_gc();




void    initialize_data();
void    create_gage_table();
void    ReadGageData();
void    ReadRadarData();
void    ReadParameters();




/* -------------------------------------------------------------------- */

char    *delete_string;
char    *selected_string;
char    *SingleSegment;
char    *GoToSegment;

int     skip_first_node;
int     selectNext_itemPosition;
int     leave_NWSRFS;
int     numberOfSubgroupsSelected;
int     NWSRFS_has_begun;
int     selectedSegment_is_upstream;
int     sub_group_num;                  /* The no. of separate trees in the current     */
					/*      Forecast Group...                       */

int     whichTree_index;

int     application_default_foreground;
int     application_default_background;

int     inLastSegment;
int     Screen_Resolution;


Widget  run_cascade[4];


XmString        *xmstr_Run_list;
XmString        previousGoToSegment;

#define YES     1
#define NO      0

#define UNKNOWN    0
#define NORMAL     1
#define ALERT      2
#define FLOOD      3
#define SELECTED   4
#define UNCOMPUTED 5

#define  RET_NO         0
#define  RET_YES        1
#define  RET_HELP       2
#define  RET_NONE       3


#define MAX_SEGMENTS            100
#define NWSRFS_TIMEOUT_TIME     80000  /*40 seconds changed to 80*/
#define MAX_NUM_SUBGROUPS       30
#define RC_BORDER_WIDTH         3

#define SCREEN_WIDTH_CM         34.4    /* Approximately !!!            */
#define CMS_PER_KM              100000  /* 1000 (m/km) * 100 (cm/m)     */


/* -------------------------------------------------------------------- */


void    make_ForecastGroup_selectionBox();
void    create_IFP_Mapping_interface();
void    create_FcstGroup_schematic();




char    rfcid[4];
char    *HOME;

int     nummap;
int     numfg;
int     numrivers;
int     numrfc;
int     numstates;
int     numcounty;
int     NumForecastPoints;
int     istate;
int     icity;
int     iriver;
int     ibound;
int     icounty;
int     save_gif;

int     ORD_FG;
int     ORD_MOS;
int     ORD_SS;
int     ORD_ZM;
int     XOR;
int     YOR;
int     MAXX;
int     MAXY;

char    *forecastGroup_name;
char    **FGBasin_ID;
int     NumBasinsInCurrFcstGroup;

int     read_MAP_data();
int     Zoom_In_Enabled;

void    choose_color();
void    zoom_forecastGroup();
void    do_zoom();
void    zoom_in();
void    zoom_out();
void    zoom();
void    revert_to_default_view();
void    draw_circle();
void    draw_rectangle();
void    draw_polygon();
void    draw_line();
void    show_states();
void    show_county();
void    show_cities_and_towns();
void    show_basin_boundaries();
void    show_forecast_points();
void    show_currentForecastGroup();
void    show_forecastGroup_boundaries();
void    show_radar_rings();
void    show_rivers();
void    show_gages();
void    show_tools();
void    do_Draw_to_scale();
void    create_help_Dialog();
void    create_query_popup();

void    show_current_mods();

void    locate();
void    close_locate();
void    select_basin();
void    select_ForecastGroup();
void    get_ForecastGroup_ID();

void    IFP_Map_popdown_shell();

int     get_pixel_by_name();

void    add_overlays();
void    draw_bound();
void    IFP_Map_start_rubber_band();
void    IFP_Map_track_rubber_band();
void    IFP_Map_end_rubber_band();
void    track_locator();
void    show_location();
void    clear_location();

void    start_ScaleTool_rb();
void    end_ScaleTool_rb();
void    track_ScaleTool_rb();

void    start_CircleTool_rb();
void    end_CircleTool_rb();
void    track_CircleTool_rb();


void    select_callback();
void    ok_callback();
void    pop_down();
void    time_lapse();
void    end_time_lapse();
void    loop_callback();

void    start_end_rubber_poly();
void    track_one_rubber_line();
void    end_one_rubber_line();

void    create_help_dialog();

Widget  create_toolbox();

void    set_MAPBasin_selected();
void    highlight_MAPBasins();
void    highlight_MAPBasin_selected();
void    reset_previous_MAPBasin_selected();
void    reset_MAPBasins_ifSubnodeSelected();
void    set_MAPBasin_Subnodes_selected();
void    Reset_ForecastGroupRegion();
Region  get_NodeRegion();

/*---------------------------------*/
/* color preferences functions     */
/*---------------------------------*/

void display_colors();
void read_color_list();
void save_user_colors();
void save_system_colors();
void cancel_colors();
void change_color();
void select_color_to_change();
void color_select();
void end_colors();

void help_event_handler();


/*---------------------------------*/
/* Main menu callback functions    */
/*---------------------------------*/

void show_Coop_locate_dialog();
void show_all_Coop_observers();
void show_coop_observed();
void show_coop_observed_and_est();
void change_thresholds();
void show_locate_list();
void open_data();
void revert_to_original();
void print_window();
void display_MAP_window();
void show_precip();

/*---------------------------------*/
/* Drawing Scale functions         */
/*---------------------------------*/

void check_scale_value();
void do_scale_change();

/*---------------------------------*/
/* Callback functions              */
/*---------------------------------*/

int  AskUser();
void response();
void popup_version_window();


void create_Version_Dialog();
void reset_version_ToggleButton();


float   rainthres[16];
float   zoom_factor;

#endif
