/***************************************************************/
/*  SHARP-95                                                   */
/*  Advanced Interactive Sounding Analysis Program             */
/*                                                             */
/*  XW Video Graphics Routines (Part #6)                       */
/*  These routines have been used in the porting of SHARP      */
/*  to X/Xt/Motif.                                             */
/*                                                             */
/*  John Hart & Jim Whistler                                   */
/*  National Severe Storms Forecast Center                     */
/*  Kansas City, Missouri                                      */
/*      --------------------------------------------------     */
/*  List of Routines in this module:                           */
/*                                                             */
/*  X_Init                                                     */
/*  setcliprgn                                                 */
/*  setlinestyle                                               */
/*  getgtextextent                                             */
/*  moveto                                                     */
/*  lineto                                                     */
/*  rectangle                                                  */
/*  setcolor                                                   */
/*  set_font                                                   */
/*  print_graphic                                              */
/*  reset_graphic                                              */
/*  parcel_popup                                               */
/*                                                             */
/***************************************************************/
#define GLOBAL
#define VIDEO
#include <ctype.h>
#include "xwcmn.h"
#include "xv.h"
#include "sharp95.h"
#include <unistd.h>
#include <xwgui.h>
#include "nwx_cmn.h"

#ifdef UNDERSCORE
#define get_mdl_stns    get_mdl_stns_
#define get_gem_stns    get_gem_stns_
#define get_gem_times   get_gem_times_
#define get_mdl_times   get_mdl_times_
#define mmap_init       mmap_init_
#define mapmark         mapmark_
#define getsfcdata      getsfcdata_
#define hailcast1       hailcast1_
#endif /* UNDERSCORE */

typedef struct {       
  /* for drawing moving crosshairs or zoom boxes */
  int start_x, start_y, last_x,  last_y;
  GC  gc;
  XPoint   points[4];
  int itype; /* 0 = temp 1 = dwpt */
  int ilev; /* 0 = bottom 1 = top 2 = inbetween */
  short yy, i;
} rubber_band_data;

#define compiledate "NSHARP: SPC Advanced Sounding Analysis Program - (Ver. " __DATE__ ")"

void       mapw_pickstnCb();
void       mapw_pickstnCb_pfc();
void       mapw_exposeCb();
void       mapw_resizeCb();
nwxtbl_t  *nwxTable;
stnlist_t  stnList;
plotdata_t plotData;
usrslct_t  usrSelect;
srchinfo_t srchInfo;

extern struct maptype_list map_info[];
extern        mapbnd_t     mapBnd;
mapbnd_t                   mapBnds[128]; 

int curdatatype=0;
int current_parcel = 3;

XFontStruct *font_struct;
XPoint       lpoints[2];
rubber_band_data rbdata;

Widget toplevel, load_sharp, draw_reg, user_defined_text,
       mml_text, mu_text, graph_tog, modifybox=NULL, sfctimelabel=NULL;

Widget gemfile_timelist, gemfile_text, gemfile_stationlist,
       gem_dialog, mdl_dialog, mdlfile_timelist, gcolrbar_frame,
       mdlfile_text, mdl_statext, pfcfile_timelist, pfcfile_text, 
       pfc_dialog, gemlbl_station;

char   obssoundfile[200], time_list[500][20], obssoundtime[20],
       obssoundsta[7], sta_id[5], mdlsoundfile[200], mdlsoundtime[20],
       mtime_list[500][20], mdlsoundsta[12], mdl_selected[5],
       pfcsoundfile[200], pfcsoundsta[7], pfcsoundtime[20];
int    mtimes;

int    ntimes, station_list;
int    sounding_type=999, prevsounding_type=999;

static Widget chooser_dialog=NULL, chooser_timelist=NULL;
static Widget chooser_text=NULL;
static Widget load_dialog=NULL, option_menu=NULL;
static Widget savegif_dialog=NULL;

Widget status;

void getsfcdata(char *filnam, char *stnid, char *curtim, char *timestr,
	        float *temp, float *dwpt, float *dir, float *sknt,
	        int len1, int len2, int len3, int len4);
void setsfctimelabel(char *str);
extern void zoommapwindow(Widget w, XtPointer client_data, XtPointer call_data);
extern void unzoommapwindow(Widget w, XtPointer client_data, XtPointer call_data);
extern void mapw_zoomCb(Widget w, XtPointer client_data, XtPointer call_data);
void setsoundingtype(int type);
void flipflopsounding(float **inoutsndg, int nlev);
void showdatachooser(int stype);
void cancel_chooser(Widget w, XtPointer client_data, XtPointer call_data);
void get_datafile(Widget w, XtPointer client_data, XtPointer call_data);
void load_datafile(Widget w, XtPointer client_data, XtPointer call_data);
void datatypechange(Widget w, XtPointer client_data, XtPointer call_data);
void get_datafile_text(Widget w, XtPointer client_data, XtPointer call_data);
void timeselected(Widget w, XtPointer client_data, XtPointer call_data);
int getdatatimes(char *file, char times[][16], int stype);
void configtimelist(char times[][16], int ntimes);
void resetmapinfo(int index);
int load_sounding(int stype);
int load_sounding2(char *fileptr, char *timeptr, char *stnptr, int stype);

void drawdatamap(int nsta, float *sta_lat, float *sta_lon);
Widget GetTopShell(Widget w);
void adjbndrylayer(float sfct, float sfctd);
void showtextwin(Widget parent);
char *createtextsounding(void);
void set_textareatext(char *ptr);
void updatetimes(Widget w, XtPointer client_data, XtPointer call_data);
void errordialog(Widget parent, char *msg);
void dialog_delete(Widget w, XtPointer client_data, XtPointer call_data);
void save_giffile(Widget w, XtPointer client_data, XtPointer call_data);
void get_giffile(Widget w, XtPointer client_data, XtPointer call_data);
void file_cb(Widget w, XtPointer client_data, XtPointer call_data);
/* removed 29OCT06 by RLT */
void option_cb(Widget w, XtPointer client_data, XtPointer call_data); 
void swap_sounding(Widget w, XtPointer client_data, XtPointer call_data);

void getsndg(char *, char *, char *, char *, int *, float *, int *,
	     float *, float *, float *, float *, float *, float *, 
	     float *, float *, int *, int, int, int, int);
void xgbank(Display *, int *);
void xcaloc(int, int *);
void in_bdta(int *);
void gg_init(int *, int *);

void get_mdl_stns(int *, char(*)[18], float *, float *, int *);
void get_gem_stns(char *, char *, char *, char(*)[18], int *, 
	          float *, float *, int, int, int);
int  mapw_rgstr(Widget);
void mmap_init(int *iret);
void drawmap(int num, struct maptype_list *, int, mapbnd_t *, int *);
void mapmark(int *, float *, float *, int *, int *, int *, int *, int *,
              float *, int *, int *, int *, int *);
void get_gem_times(char *, char(*)[16], int *, int *, int);
void get_mdl_times(char *, char(*)[16], int *, int);

void resetSoundingData(void);

Widget make_status_bar(Widget parent);
void set_status_text(Widget status_bar, char *text);
void set_chooser_visibleCb(Widget w, XtPointer client_data, XtPointer call_data);
void set_singlestn_modeCb(Widget w, XtPointer client_data, XtPointer call_data);
int set_chooser_visible=0;
int set_singlestn_mode=0;
void bmj_process(Widget w, XtPointer client_data, XtPointer call_data);
void kf_process(Widget w, XtPointer client_data, XtPointer call_data);
void hail_process(Widget w, XtPointer client_data, XtPointer call_data);
void stp_process(Widget w, XtPointer client_data, XtPointer call_data);
void ship_process(Widget w, XtPointer client_data, XtPointer call_data);
void ebs_process(Widget w, XtPointer client_data, XtPointer call_data);
	/* added 25OCT06 by RLT */
void sars_process(Widget w, XtPointer client_data, XtPointer call_data);
void winter_process(Widget w, XtPointer client_data, XtPointer call_data);
void fire_process(Widget w, XtPointer client_data, XtPointer call_data);
void inset_toggle_process(Widget w, XmDrawingAreaCallbackStruct *call_data);

void X_Init(int argc, char *argv[])
       /*************************************************************/
       /*  X_INIT                                                   */
       /*  John Hart  NSSFC KCMO                                    */
       /*                                                           */
       /*  Draws basic SHARP graphic template on screen, including  */
       /*  areas, buttons, and tables.                              */
       /*                                                           */
       /*************************************************************/
{
       int ret, i, j, xloc, yloc, mode;
       int GraphCid, SatCid, RadCid;
       unsigned int wd, ht, bw, dpth;
       XmString load_st, sharp_st, sounding_st, about_st, file_st, temp_st; 

       Widget topform, print_button, sfclabel, inset_button, reset_button, 
	      parcel_button, interp_button, option_button, next_page,
              menubar, load_menu, about_menu, buttonform, inputform,
	      statusform, bmj_button, kf_button, hail_button, ship_button, stp_button, ebs_button,
	      /* added 25OCT06 by RLT */
	      sars_button, winter_button, fire_button, inset_toggle_button,
	      bndrymotion;


       /* ----- Initialize X Toolkit and Load Resources ----- */
       toplevel = XtVaAppInitialize(&app, "Sharp95", NULL, 0,
                      &argc, argv, NULL,
		      /*XmNbaseWidth, 898, XmNbaseHeight, 850,
                      XmNminWidth, 880, XmNminHeight, 800, NULL);*/
		      XmNbaseWidth, 1230, XmNbaseHeight, 1018,
                      XmNminWidth, 880, XmNminHeight, 800, NULL);

       /* ----- Create Graphics Form (window) ----- */
       topform = XtVaCreateManagedWidget("graphic_form",
                     xmFormWidgetClass, toplevel,
                     XmNfractionBase, 28, NULL);
       file_st = XmStringCreateLocalized(compiledate);
       XtVaSetValues(topform, XmNdialogTitle, file_st, NULL);

       /* ----- Create Menu bar across top of "topform" ----- */
       file_st = XmStringCreateLocalized("File");
       /* removed 29OCT06 by RLT */	
       temp_st = XmStringCreateLocalized(""); 
       about_st =XmStringCreateLocalized("Help");
       menubar = XmVaCreateSimpleMenuBar(topform, "menubar",
                     XmVaCASCADEBUTTON, file_st,  'F',
	   	     XmVaCASCADEBUTTON, temp_st,  'O', 
		     XmVaCASCADEBUTTON, about_st, 'H',
                     XmNtopAttachment,   XmATTACH_FORM,
                     XmNleftAttachment,  XmATTACH_FORM,
                     XmNrightAttachment, XmATTACH_FORM, NULL);
       XmStringFree(file_st);
       /* removed 29OCT06 by RLT */	
       XmStringFree(temp_st);

       XmStringFree(about_st);

	/* ----- Create Pulldown Menu for File Stuff ----- */
	/* We'll just reuse some strings here */
	load_st = XmStringCreateLocalized("Load");
	file_st = XmStringCreateLocalized("Print");
	temp_st = XmStringCreateLocalized("GIF Image");
	about_st =XmStringCreateLocalized("Exit");
	load_menu = XmVaCreateSimplePulldownMenu(menubar, "file_menu",
                        0, file_cb,
                        XmVaCASCADEBUTTON, load_st,  'L',
                        XmVaPUSHBUTTON,    file_st,  'P', NULL, NULL,
                        XmVaPUSHBUTTON,    temp_st,  'G', NULL, NULL,
                        XmVaPUSHBUTTON,    about_st, 'x', NULL, NULL,
                        NULL);
	XmStringFree(file_st);
	XmStringFree(load_st);
	XmStringFree(temp_st);
	XmStringFree(about_st);

	/* ----- Create Pulldown Menu for Loading Soundings ----- */
	/* Note: this is a cascading menu under File */
	sounding_st = XmStringCreateLocalized("Current Data");
	sharp_st = XmStringCreateLocalized("NSHARP Archives");
	/* Note: we're reusing load_menu here. don't be confused. */
	load_menu = XmVaCreateSimplePulldownMenu(load_menu, "load_pullright",
                        0, load_cb,
                        XmVaPUSHBUTTON, sounding_st, 'C', NULL, NULL,
                        XmVaPUSHBUTTON, sharp_st,    'A', NULL, NULL,
                        NULL);
	XmStringFree(sounding_st);
	XmStringFree(sharp_st);






	/* removed 29OCT06 by RLT */
	/* Options menu */
	/*
	temp_st = XmStringCreateLocalized("Winter Mode");
	load_menu = XmVaCreateSimplePulldownMenu(menubar, "option_menu",
                        1, option_cb,
                        XmVaRADIOBUTTON, temp_st, 'W', NULL, NULL,
                        NULL);
	XmStringFree(temp_st);
	*/

       /* ----- Create About Menu Option ----- */
       about_menu = XtNameToWidget(menubar, "button_2");
       XtVaSetValues(menubar, XmNmenuHelpWidget, about_menu, NULL);
       XtAddCallback(about_menu, XmNactivateCallback, (XtCallbackProc)about_cb, NULL);

	/* Finally all done w/ menu bar */
	XtManageChild(menubar);

       /*
        * Initialize GEMPAK
	* Do it here, once and for all, so that any of our navigation
	* info doesn't get hosed if we were doing the initialization
	* multiple times in subroutines
        */
	in_bdta(&ret);
	mode = 1;
	gg_init(&mode, &ret);

	/* ----- Initialize GEMPAK color palette ----- */
	gemdisplay = XtDisplay(topform);
	gemmap  = DefaultColormap(gemdisplay,DefaultScreen(gemdisplay));
	gemvis  = DefaultVisual(gemdisplay, DefaultScreen(gemdisplay));

	GraphCid = 0;
	SatCid   = 1;
	RadCid   = 2;

	xgbank(gemdisplay, &ret);
	xcaloc(GraphCid, &ret);
	for (i = 0; i < ColorBanks.banks[GraphCid]; i++)
          pixels[i] = ColorBanks.colrs[GraphCid][i];
       
	/* This works for everything except the pop-up maps from GEMPAK */	
	/* get_colors(); */

       statusform = XtVaCreateManagedWidget("status_form",
                       xmFormWidgetClass,   topform,
	               XmNleftAttachment,   XmATTACH_FORM,
	               XmNrightAttachment,  XmATTACH_FORM,
	               XmNbottomAttachment, XmATTACH_FORM,
	               NULL);

       inputform = XtVaCreateManagedWidget("input_form",
                       xmFormWidgetClass,   topform,
                       XmNfractionBase,     20, 
	               XmNleftAttachment,   XmATTACH_FORM,
	               XmNrightAttachment,  XmATTACH_FORM,
	               XmNbottomAttachment, XmATTACH_WIDGET,
	               XmNbottomWidget,     statusform,
	               NULL);

       buttonform = XtVaCreateManagedWidget("button_form",
                        xmFormWidgetClass,   topform,
                        XmNfractionBase,     26, 
	                XmNleftAttachment,   XmATTACH_FORM,
	                XmNrightAttachment,  XmATTACH_FORM,
	                XmNbottomAttachment, XmATTACH_WIDGET,
	                XmNbottomWidget,     inputform,
	                NULL);

       /* ----- Create main area for soundings/parameters ----- */
       draw_reg = XtVaCreateManagedWidget("canvas",
                      xmDrawingAreaWidgetClass, topform,
                      XmNtopAttachment,    XmATTACH_WIDGET,
                      XmNtopWidget,        menubar,
                      XmNbottomAttachment, XmATTACH_WIDGET,
                      XmNbottomWidget,     buttonform,
                      XmNleftAttachment,   XmATTACH_FORM,
                      XmNrightAttachment,  XmATTACH_FORM,
                      XmNbackground,       pixels[0],
                      NULL);

       /* ----- Create PARCEL button ----- */
       parcel_button = XtVaCreateManagedWidget("Parcel",
                           xmPushButtonWidgetClass, buttonform,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNleftAttachment,   XmATTACH_FORM,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    2,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           XmNbottomPosition,   20,
                           NULL);
       XtAddCallback(parcel_button, XmNactivateCallback, (XtCallbackProc)parcel_popup, NULL);

       /* ----- Create INTERP button ----- */
       interp_button = XtVaCreateManagedWidget("Interpolate",
                           xmPushButtonWidgetClass, buttonform,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     2,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    4,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           XmNbottomPosition,   20,
                           NULL);
	XtAddCallback(interp_button, XmNactivateCallback, (XtCallbackProc)interp_data, NULL);

       /* ----- Create Swap button ----- */
       option_button = XtVaCreateManagedWidget("Swap",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     4,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    6,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           XmNbottomPosition,   20,
                           NULL);
       XtAddCallback(option_button, XmNactivateCallback, (XtCallbackProc)swap_sounding, NULL);

       /* ----- Create RESET button ----- */
       reset_button = XtVaCreateManagedWidget("Reset",
                          xmPushButtonWidgetClass, buttonform,
                          XmNtopAttachment,    XmATTACH_FORM,
                          XmNleftAttachment,   XmATTACH_POSITION,
                          XmNleftPosition,     6,
                          XmNrightAttachment , XmATTACH_POSITION,
                          XmNrightPosition,    8,
                          XmNbottomAttachment, XmATTACH_POSITION,
                          XmNbottomPosition,   20,
                          NULL);
       XtAddCallback(reset_button, XmNactivateCallback, (XtCallbackProc)reset_graphic, NULL);

       /* ----- Create OVERLAY button ----- */
       option_button = XtVaCreateManagedWidget("Overlay: off",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     8,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    10,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           XmNbottomPosition,   20,
                           NULL);
       XtAddCallback(option_button, XmNactivateCallback, (XtCallbackProc)option_graphic, NULL);

       /* ----- Create INSET button ----- */
/*       inset_button = XtVaCreateManagedWidget("Inset", xmPushButtonWidgetClass, buttonform, XmNtopAttachment,    XmATTACH_FORM, XmNleftAttachment,   XmATTACH_POSITION, XmNleftPosition,     10, XmNrightAttachment,  XmATTACH_POSITION, XmNrightPosition,    12, XmNbottomAttachment, XmATTACH_POSITION, XmNbottomPosition,   20, NULL);
       XtAddCallback(inset_button, XmNactivateCallback, (XtCallbackProc)inset_graphic, NULL);
*/

       /* ----- Create View Data button ----- */
       print_button = XtVaCreateManagedWidget("View Data",
                          xmPushButtonWidgetClass, buttonform,
                          XmNleftAttachment,   XmATTACH_POSITION,
                          XmNleftPosition,     10,
                          XmNrightAttachment,  XmATTACH_POSITION,
                          XmNrightPosition,    12,
                          XmNtopAttachment,    XmATTACH_FORM,
                          XmNbottomPosition,   20,
                          XmNbottomAttachment, XmATTACH_POSITION,
                          NULL);
       XtAddCallback(print_button, XmNactivateCallback, (XtCallbackProc)view_textwin, NULL);

        /* added 25OCT06 by RLT */
       /* ----- Create SARS button ----- */
       sars_button = XtVaCreateManagedWidget("SARS",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     12,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    14,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(sars_button, XmNactivateCallback, (XtCallbackProc)sars_process, NULL);


       /* ----- Create HAIL button ----- */
       hail_button = XtVaCreateManagedWidget("HAIL",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     14,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    16,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(hail_button, XmNactivateCallback, (XtCallbackProc)hail_process, NULL);

       /* ----- Create SHIP Stats button ----- */
       ship_button = XtVaCreateManagedWidget("SHIP Stats", 
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     16,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    18,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(ship_button, XmNactivateCallback, (XtCallbackProc)ship_process, NULL);


       /* ----- Create STP Stats button ----- */
       stp_button = XtVaCreateManagedWidget("STP Stats",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     18,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    20,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(stp_button, XmNactivateCallback, (XtCallbackProc)stp_process, NULL);


       /* ----- Create EBS Stats button ----- */
       ebs_button = XtVaCreateManagedWidget("EBS Stats",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     20,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    22,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL); 
       XtAddCallback(ebs_button, XmNactivateCallback, (XtCallbackProc)ebs_process, NULL);


       /* ----- Create WINTER button ----- */
       winter_button = XtVaCreateManagedWidget("WINTER",
                          xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     22,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    24,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(winter_button, XmNactivateCallback, (XtCallbackProc)winter_process, NULL);


       /* ----- Create FIRE WX button ----- */
       fire_button = XtVaCreateManagedWidget("FIRE",
                          xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     24,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    26,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(fire_button, XmNactivateCallback, (XtCallbackProc)fire_process, NULL);


	/* added 25OCT06 by RLT */
       /* ----- Create WINTER button ----- */
      /* winter_button = XtVaCreateManagedWidget("WINTER",
                           xmPushButtonWidgetClass, buttonform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     22,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    24,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomPosition,   20,
                           XmNbottomAttachment, XmATTACH_POSITION,
                           NULL);
       XtAddCallback(winter_button, XmNactivateCallback, (XtCallbackProc)winter_process, NULL);
	*/


       /* Create label */
       load_st = XmStringCreateLocalized("Surface conditions ");
       sfclabel = XtVaCreateManagedWidget("sfc_label", 
	              xmLabelWidgetClass, inputform,
                      XmNlabelString,      load_st, 
	              XmNleftAttachment,   XmATTACH_FORM,
	              XmNtopAttachment,    XmATTACH_FORM,
	              XmNbottomAttachment, XmATTACH_FORM,
	              XmNentryAlignment,   XmALIGNMENT_CENTER,
	              NULL);
       XmStringFree(load_st);

       /* Add user input box */
       modifybox = XtVaCreateManagedWidget("modifybox", 
                       xmTextWidgetClass,  inputform,
                       XmNleftAttachment,  XmATTACH_WIDGET,
                       XmNleftWidget,      sfclabel,
	               XmNcolumns,         12,
                       NULL);
       XtAddCallback(modifybox, XmNactivateCallback, (XtCallbackProc)processuserdata, NULL);

       /* Create boundary motion label */
       load_st = XmStringCreateLocalized("Boundary motion");
       bndrymotion = XtVaCreateManagedWidget("bndry_motion",
                      xmLabelWidgetClass, inputform,
                      XmNlabelString,      load_st,
                      XmNrightAttachment,   XmATTACH_FORM,
                      XmNtopAttachment,    XmATTACH_FORM,
                      XmNbottomAttachment, XmATTACH_FORM,
                      XmNentryAlignment,   XmALIGNMENT_CENTER,
                      NULL);
       XmStringFree(load_st);

       /* Add user input box for boundary motion */
       modifybox = XtVaCreateManagedWidget("modifybox",
                       xmTextWidgetClass,  inputform,
                       XmNrightAttachment,  XmATTACH_WIDGET,
                       XmNrightWidget,      bndrymotion,
                       XmNcolumns,         6,
                       NULL);
       XtAddCallback(modifybox, XmNactivateCallback, (XtCallbackProc)processuserdatabndry, NULL);

       /* ----- Create BMJ button ----- */
       bmj_button = XtVaCreateManagedWidget("BMJ",
                           xmPushButtonWidgetClass, inputform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     5,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    6,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_FORM,
                           NULL);
       XtAddCallback(bmj_button, XmNactivateCallback, (XtCallbackProc)bmj_process, NULL);

       /* ----- Create KF button ----- */
       kf_button = XtVaCreateManagedWidget("KF",
                           xmPushButtonWidgetClass, inputform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     6,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    7,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_FORM,
                           NULL);
       XtAddCallback(kf_button, XmNactivateCallback, (XtCallbackProc)kf_process, NULL);

       /* ----- Create INSET TOGGLE button ----- */
       inset_toggle_button = XtVaCreateManagedWidget("LEFT inset",
                           xmPushButtonWidgetClass, inputform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     15,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    17,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_FORM,
                           NULL);
       XtAddCallback(inset_toggle_button, XmNactivateCallback, (XtCallbackProc)inset_toggle_process, NULL);

        /* added 04DEC06 by RLT */
       /* ----- Create WINTER button ----- */
/*       winter_button = XtVaCreateManagedWidget("WINTER",
                           xmPushButtonWidgetClass, inputform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     7,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    9,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_FORM,
                           NULL);
       XtAddCallback(winter_button, XmNactivateCallback, (XtCallbackProc)winter_process, NULL);
*/
       /* ----- Create FIRE WX button ----- */
/*       fire_button = XtVaCreateManagedWidget("FIRE",
                           xmPushButtonWidgetClass, inputform,
                           XmNleftAttachment,   XmATTACH_POSITION,
                           XmNleftPosition,     9,
                           XmNrightAttachment,  XmATTACH_POSITION,
                           XmNrightPosition,    11,
                           XmNtopAttachment,    XmATTACH_FORM,
                           XmNbottomAttachment, XmATTACH_FORM,
                           NULL);
       XtAddCallback(fire_button, XmNactivateCallback, (XtCallbackProc)fire_process, NULL);
*/
       /* Create another label */
       load_st = XmStringCreateLocalized("");
       sfctimelabel = XtVaCreateManagedWidget("sfctime_label", 
	                  xmLabelWidgetClass, inputform,
                          XmNlabelString,      load_st, 
	                  XmNleftAttachment,   XmATTACH_WIDGET,
	                  XmNleftWidget,       modifybox,
	                  XmNtopAttachment,    XmATTACH_FORM,
	                  XmNbottomAttachment, XmATTACH_FORM,
	                  XmNrightAttachment,  XmATTACH_FORM,
	                  XmNentryAlignment,   XmALIGNMENT_BEGINNING,
	                  NULL);
       XmStringFree(load_st);

	status = make_status_bar(statusform);
	set_status_text(status, "Foo!");

	XtVaSetValues(status, XmNleftAttachment, XmATTACH_FORM,
	  XmNrightAttachment, XmATTACH_FORM, NULL);

       /* ----- Create Window and Map Screen ----- */
       XtRealizeWidget(toplevel);

       /* ----- Create "Graphic Context" ----- */
       gc = XCreateGC(XtDisplay(draw_reg), XtWindow(draw_reg), 0, 0);

       /* ----- callback for expose ----- */  
       XtAddCallback(draw_reg, XmNexposeCallback, (XtCallbackProc)expose_overlays, NULL);

       /* ----- callback for resize ----- */
       XtAddCallback(draw_reg, XmNresizeCallback, (XtCallbackProc)resize_callback, NULL);

       /* ----- "button pressed" event ----- */
       XtAddEventHandler(draw_reg, ButtonPressMask, FALSE, (XtEventHandler)position_cursor, (XtPointer)NULL);
       
       /* ----- "mouse moved with button #1 depressed" event ----- */
       XtAddEventHandler(draw_reg, Button1MotionMask, FALSE, (XtEventHandler)update_pointer, (XtPointer)NULL);
       
       /* ----- "button released" event ----- */ 
       XtAddEventHandler(draw_reg, ButtonReleaseMask, FALSE, (XtEventHandler)redraw_sounding, (XtPointer)NULL);
       
       /* ----- "mouse moved" event ----- */
       XtAddEventHandler(draw_reg, PointerMotionMask, FALSE, (XtEventHandler)pointer_update, (XtPointer)NULL);

       /* ----- keyboard event ----- */
       XtAddEventHandler(draw_reg, KeyPressMask, FALSE, (XtEventHandler)keyboard_press, (XtPointer)NULL);

       XGrabButton(XtDisplay(draw_reg), AnyButton, AnyModifier,
              XtWindow(draw_reg), TRUE,
              ButtonPressMask | Button1MotionMask | ButtonReleaseMask,
              GrabModeAsync, GrabModeAsync,
              XtWindow(draw_reg), None);

       root = DefaultRootWindow(XtDisplay(draw_reg));
       XGetGeometry(XtDisplay(draw_reg), XtWindow(draw_reg), &root, &xloc, &yloc, &wd, &ht, &bw, &dpth);
       canvas = XCreatePixmap(XtDisplay(draw_reg), root, wd, ht, dpth);

       xwdth = wd;
       xhght = ht;
       xdpth = dpth;

       /* ----- Set background color to Black (pixels[0]) ----- */
       XSetBackground(XtDisplay(draw_reg), gc, pixels[0]);
       XFillRectangle(XtDisplay(draw_reg), canvas, gc, 0, 0, xwdth, xhght);

       /* ----- Initialize "RubberBand" struct for skewt edit ----- */
       rbdata.gc      = xs_create_xor_gc(draw_reg, "white");
       rbdata.start_x = 0;
       rbdata.start_y = 0;
       rbdata.last_x  = 0;
       rbdata.last_y  = 0;
       rbdata.itype   = 0;
       rbdata.ilev    = 2;
       rbdata.yy      = 0;
       rbdata.i       = 0;
       rbdata.points[0].x = rbdata.points[1].x = rbdata.points[2].x = 0;
       rbdata.points[0].y = rbdata.points[1].y = rbdata.points[2].y = 0;

	/* Initialize fonts -mkay 8/8/99 */
       ret = init_fonts();
       if (ret != 0) {
         fprintf(stderr,"Error: Could not initialize all requested fonts.\n");
         fprintf(stderr,"Check fonts.h for problems\n");
         exit(1);
       }

	resize_callback(draw_reg, (XtPointer)NULL, (XtPointer)NULL);

	if (auto_mode == 1) { autoload(); }
}


       /*NP*/
       void setcliprgn(short tlx, short tly, short brx, short bry)
       /*************************************************************/
       /*  SETCLIPRGN                                               */
       /*************************************************************/
       {
       Region        regn;
       XRectangle    rect;

       regn = XCreateRegion ();
       rect.x = tlx-1;
       rect.y = tly-1;
       rect.width = brx - tlx + 5;
       rect.height = bry - tly + 5;
       XUnionRectWithRegion ( &rect, regn, regn );

       XSetRegion ( XtDisplay (draw_reg), gc, regn );

       XDestroyRegion ( regn );
       }


       /*NP*/
       void setlinestyle(short style, short width)
       /*************************************************************/
       /*  SETLINESTYLE                                             */
       /*     style = 1 = solid                                     */
       /*     style = 2 = dash                                      */
       /*     style = 3 = dash dot dash                             */
       /*     style = 4 = short dash long dash                      */
       /*************************************************************/
       {
       int           dash_offset = 1;
       static char   dash_dash[]  = {3,3};
       static char   dash_dot[]  = {4,4,2,4};
       static char   dash_long[]  = {3,3,6,3};
       short         line_width;

       if (width < 0 || width > 10)
              line_width = 1;
       else
              line_width = width;

       if (style == 1) {
          XSetLineAttributes(XtDisplay(draw_reg), gc, line_width,
                     LineSolid, CapButt, JoinRound);
          }
       else {
          XSetLineAttributes(XtDisplay(draw_reg), gc, line_width,
                     LineOnOffDash, CapButt, JoinRound);
          }

          if (style == 2)
             XSetDashes(XtDisplay(draw_reg), gc, dash_offset, dash_dash, 2);
          else if (style == 3)
             XSetDashes(XtDisplay(draw_reg), gc, dash_offset, dash_dot, 4);
          else if (style == 4)
             XSetDashes(XtDisplay(draw_reg), gc, dash_offset, dash_long,4);
       }


       /*NP*/
       int getgtextextent(char *st )
       /*************************************************************/
       /*  GETGTEXTEXTENT                                           */
       /*************************************************************/
       {
       return XTextWidth(font_struct, st, strlen(st));
       }


void outtext(char *st, int x, int y)
       /*************************************************************/
{
	y = y + font_struct->ascent;
	/* 
	 * XDrawImageString also colors in the background behind the
	 * text unlike XDrawString which only uses the foreground color
	 */
	XDrawImageString( XtDisplay(draw_reg),XtWindow(draw_reg), gc,
	  x, y, st, strlen(st));
}

void outgtext(char *st, int x, int y)
       /*************************************************************/
{
	y = y + font_struct->ascent;
	XDrawString(XtDisplay(draw_reg),(canvas), gc, x, y, st, strlen(st));
}

void moveto(short x, short y)
       /*************************************************************/
{
	lpoints[0].x = x;
	lpoints[0].y = y;
}

void lineto(short x, short y)
       /*************************************************************/
{
	lpoints[1].x = x;
	lpoints[1].y = y;

	XDrawLine(XtDisplay(draw_reg), canvas, gc, lpoints[0].x, lpoints[0].y,
	  lpoints[1].x, lpoints[1].y);

	lpoints[0].x = x;
	lpoints[0].y = y;
}

void rectangle(int type, short x, short y, short width, short height)
       /*************************************************************/
{
	if (type == 0) {
	  XDrawRectangle(XtDisplay(draw_reg), canvas, gc,
	    x, y, width - x, height- y);
	}
	else if (type == 1) {
	  XFillRectangle(XtDisplay(draw_reg), canvas, gc, x,
	    y, width - x, height - y);
	}
}

void ellipse(int type, short x, short y, short width, short height)
       /*************************************************************/
{
	if (type == 0) {
	  XDrawArc(XtDisplay(draw_reg), canvas, gc,
	    x, y, abs(width - x), abs(height - y), 0, 360*64);
	}
	else if (type == 1) {
	  XFillArc(XtDisplay(draw_reg), canvas, gc, x,
	    y, abs(width - x), abs(height - y), 0, 360*64);
	}
}

void setcolor(int color)
       /*************************************************************/
{
	XSetForeground(XtDisplay(draw_reg), gc, pixels[color] );
}

void view_textwin(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
{
	showtextwin(toplevel);
}

void reset_graphic(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
{

	if (!qc(i_temp(700, I_PRES))) return;

/*
	restore_origsndg();
*/
	
        hodo_mode = HODO_MEANWIND;

	resetSoundingData();
	if (modifybox != NULL)
	  XmTextSetString(modifybox,"");
	setsfctimelabel("");
	reset_options(drawing_mode, pagenum);

	XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
}

void parcel_popup(Widget w)
       /*************************************************************/
       /*  PARCEL_POPUP                                             */
       /*                                                           */
       /*  Creates pop-up window to choose parcel.                  */
       /*************************************************************/
{
       XmStringCharSet         def_charset;
       static Widget           parcel_pane, form, button, prcl_top;
       static Widget           rowcol, form2, sep_wid, parcel_cancel;
       int                     i;
       char     *labels[] = { "Current Surface", "Forecast Surface",
                              "Most Unstable Parcel", "Mean mixing layer",
                              "User Defined level" };
       XmString		       pop_title;

       if (!qc(i_temp(700, I_PRES))) return;

       if (!prcl_top) {
         def_charset = (XmStringCharSet) XmSTRING_DEFAULT_CHARSET;

         /* ----- Create a Dialog for parcel selection ----- */
	 pop_title = XmStringCreateLocalized("Select Thermodynamic Parcel");
	 prcl_top = XmCreateBulletinBoardDialog(w, "parcel_panel", NULL, 0);
	 XtVaSetValues(prcl_top, XmNdialogTitle, pop_title, NULL);
	 XmStringFree(pop_title);

	 parcel_pane = XtVaCreateWidget("parcel_pane",
	                                xmPanedWindowWidgetClass, prcl_top,
	                                XmNsashWidth, 1, XmNsashHeight, 1, 
	                                NULL);

	 form = XtCreateManagedWidget("content_form",
	                              xmFormWidgetClass, parcel_pane, NULL, 0);

         /* Create a rowcol */
	 rowcol = XtVaCreateWidget("Parcel",
                                   xmRowColumnWidgetClass, form,
                                   XmNnumColumns,          2,
                                   XmNorientation,         XmVERTICAL,
                                   XmNradioBehavior,       True,
                                   XmNentryClass,
                                   xmToggleButtonGadgetClass,
                                   XmNspacing,             3,
                                   XmNradioAlwaysOne,      True,
                                   XmNtopAttachment,       XmATTACH_POSITION,
                                   XmNtopPosition,         2,
                                   XmNleftAttachment,      XmATTACH_POSITION,
                                   XmNleftPosition,        2,
                                   NULL);

	 /* Create the toggle buttons for the various types */
	 for (i=0; i<XtNumber(labels); i++) {
	   button = XtVaCreateManagedWidget(labels[i],
                                            xmToggleButtonWidgetClass, rowcol,
                                            NULL);
	   XtAddCallback(button, XmNvalueChangedCallback,
                         (XtCallbackProc)Toggle_Callback,
                         (XtPointer)i);
           if (i == current_parcel-1)
             XmToggleButtonSetState(button, True, True);
	 }

	 /* Now the text entries (for those that need them */
	 for (i=0; i<XtNumber(labels); i++) {
	   switch (i) {
	     case 0:
	     case 1:
	     break;
	     case 2:
               mu_text = XtVaCreateManagedWidget("user_text",
                                                 xmTextWidgetClass, rowcol,
                                                 XmNcolumns, 2, XmNvalue, "400",
                                                 NULL);
	       XtAddCallback(mu_text, XmNvalueChangedCallback,
	                     set_mu_level, NULL);
	     break;
	     case 3:
               mml_text = XtVaCreateManagedWidget("user_text",
                                                  xmTextWidgetClass, rowcol,
                                                  XmNcolumns, 16,
                                                  XmNvalue, "100",
                                                  NULL);
               XtAddCallback(mml_text, XmNvalueChangedCallback,
                             set_mml_level, NULL);
	     break;
	     case 4:
               user_defined_text = XtVaCreateManagedWidget("user_text",
                                                      xmTextWidgetClass, rowcol,
                                                      XmNcolumns, 16,
                                                      XmNvalue, "850",
                                                      NULL);
               XtAddCallback(user_defined_text, XmNvalueChangedCallback,
                             set_user_level, NULL);
	     break;
	     default:
	     break;
	   }

           if (i < 2) {
             sep_wid = XtVaCreateManagedWidget(labels[i],
                       xmSeparatorWidgetClass, rowcol,
                       XmNseparatorType, XmNO_LINE,
                       NULL);
           }
	 }

	 XtManageChild(rowcol);

	 form2 = XtVaCreateWidget("form", xmFormWidgetClass,
                                  parcel_pane, XmNfractionBase, 7, NULL);

	 parcel_cancel = XtVaCreateManagedWidget("CANCEL",
                                          xmPushButtonWidgetClass, form2,
                                          XmNleftAttachment, XmATTACH_POSITION,
                                          XmNleftPosition, 2,
                                          XmNtopAttachment, XmATTACH_FORM,
                                          XmNbottomAttachment, XmATTACH_FORM,
                                          XmNrightAttachment, XmATTACH_POSITION,
                                          XmNrightPosition, 5,
                                          NULL);
	 XtAddCallback(parcel_cancel, XmNactivateCallback,
	              (XtCallbackProc)parcel_cancel_cb, prcl_top);

	 XtManageChild(form2);
	 XtManageChild(parcel_pane);
       }

       XtManageChild(prcl_top);
}

void inset_graphic(Widget w, XmDrawingAreaCallbackStruct *call_data)
/*************************************************************/
/* INSET_GRAPHIC					     */	
/*************************************************************/
{
       if (!qc(i_temp(700, I_PRES))) return;

	inset_options(drawing_mode);
}

void interp_data(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /* INTERP_DATA						    */
       /*************************************************************/
/*{
	float pres, oldlplpres;
	short oldlplchoice;

      if (!qc(i_temp(700, I_PRES))) return;

	oldlplchoice = lplvals.flag;
	oldlplpres = lplvals.pres;

	interp_sndg();
	redraw_graph(drawing_mode);
	switch (current_parcel) {
	  case 3:
	    pres = mu_layer;
	  break;
	  case 4:
            pres = mml_layer;
	  break;
	  case 5:
            pres = user_level;
	  break;
        XFlush(XtDisplay(draw_reg));
	}

	define_parcel(oldlplchoice, oldlplpres);

	show_parcel();
	show_page(pagenum);

}
*/
{
        float pres;

        if (!qc(i_temp(700, I_PRES))) return;

        interp_sndg();
        /*redraw_graph(drawing_mode);
        switch (current_parcel) {
          case 3:
            pres = mu_layer;
          break;
          case 4:
            pres = mml_layer;
          break;
          case 5:
            pres = user_level;
          break;
        XFlush(XtDisplay(draw_reg));
        }*/
            switch (current_parcel) {
              case 1:
                pres = 0;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
            XFlush(XtDisplay(draw_reg));
            }


       /* define_parcel(current_parcel, pres);

        show_parcel();
        show_page(pagenum);*/
}

void option_graphic(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /* OVERLAY SELECTION					    */
       /*************************************************************/
{
	char st[80];
	float pres;
	XmString text;

        overlay_previous += 1;
	if (overlay_previous == 2)
	  overlay_previous = 0;
	if (overlay_previous == 0)
	  strcpy(st, "Overlay: Off");
	if (overlay_previous == 1)
	  strcpy(st, "Overlay: On");

	text = XmStringCreateLocalized(st);
        XtVaSetValues(w, XmNlabelString, text, NULL);
	XmStringFree(text);

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            XFlush(XtDisplay(draw_reg));
            }


	/*redraw_graph(drawing_mode);*/
}

/* INSET TOGGLE 1/27/07 RLT */
void inset_toggle_process(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /* OVERLAY SELECTION                                         */
       /*************************************************************/
{
        char st[80];
        float pres;
        XmString text;

        inset_previous += 1;
        if (inset_previous == 0)
          strcpy(st, "LEFT inset");
          inset_mode = DISPLAY_LEFT;
        if (inset_previous == 1)
           {
            strcpy(st, "RIGHT inset");
            inset_mode = DISPLAY_RIGHT;
            }
        if (inset_previous == 2)
           {
            inset_previous = 0;
            strcpy(st, "LEFT inset");
            inset_mode = DISPLAY_LEFT;
            }

        text = XmStringCreateLocalized(st);
        XtVaSetValues(w, XmNlabelString, text, NULL);
        XmStringFree(text);
/*
            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            XFlush(XtDisplay(draw_reg));
            }*/

}


	/*NP*/
	void expose_overlays(Widget w, XmDrawingAreaCallbackStruct *call_data)
	{
       /*************************************************************/
       /* EXPOSE_OVERLAYS					    */
       /*************************************************************/

	XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg),
		  gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
	}


	/*NP*/
void resize_callback(Widget w, XtPointer *data,
                     XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /*RESIZE_CALLBACK					    */
       /*************************************************************/
{
	Dimension nwdth, nhght, xdim, ydim, ndist;
	float pres;
	char st[80];

	/* Determine size of window */
	XtVaGetValues(draw_reg, XmNwidth, &nwdth, XmNheight, &nhght, NULL);

	/* Calculate size and dimensions of parameter area */
	ndist = (nwdth - 50) / 2;	

	/* Set locations of skewt and hodo */
	/* Vertical down the left side 
	hov.tlx = skv.tlx = 30;
	hov.tly = skv.bry - 75;
	skv.brx = skv.bry = ndist;
	hov.brx = ndist;
	hov.bry = hov.tly + ndist;
	*/
	skv.tlx = 30;
	skv.tly = 25;
	skv.brx = skv.tlx + ndist;
	skv.bry = skv.tly + ndist;

	hov.tlx = skv.brx + 150 + 10;
	hov.tly = skv.tly;
	hov.brx = hov.tlx + ndist - 150;
	hov.bry = hov.tly + ndist - 120;
	xwdth = nwdth;
	xhght = nhght;

	/* ----- Clean the entire page ----- */
	XFreePixmap(XtDisplay(draw_reg), canvas);
	canvas = XCreatePixmap(XtDisplay(draw_reg), root, xwdth, xhght, xdpth);
	setcliprgn(1, 1, xwdth, xhght);
	setcolor(0);
	XFillRectangle(XtDisplay(draw_reg), canvas, gc, 0, 0, xwdth, xhght); 

	draw_skewt();
	draw_hodo();
	clear_paramarea();
	pagenum=1;
	if (numlvl > 0) {
          if (current_parcel == 1) pres = 0.0;
          if (current_parcel == 2) pres = 0.0;
	  if (current_parcel == 3) pres = mu_layer;
          if (current_parcel == 4) pres = mml_layer;
          if (current_parcel == 5) pres = user_level;
          if (current_parcel == 6) pres = mu_layer;
	  define_parcel(current_parcel, pres);
	  show_parcel();
	  trace_dcape();
	  setdcape_entrain(0.9);
	  trace_dcape();
	  setdcape_entrain(0.0);
	}
	if (numlvl > 0) show_page(pagenum);
}


	/*NP*/
void position_cursor(Widget w, XtPointer *data, XEvent *event)
       /*************************************************************/
       /* POSITION_CURSOR					    */
       /*							    */
       /* Handles "mouse button depressed" event		    */
       /*************************************************************/
{
        short i, yy, x1, y1;

	/* added 2/15/05 by RLT */
	short xp, yp; 

        float pres, temp, dwpt, tcur, d1, d2;
	short pIndex, tIndex, tdIndex;


	/* ----- Determine if a button is pushed ----- */
	if (event->xbutton.button == 1) {

          if (!qc(i_temp(700, I_PRES)))
	    return;

	  raob_mod = 1;
	  if (event->xbutton.y < skv.bry && event->xbutton.x < skv.brx && event->xbutton.y > skv.tly && event->xbutton.x > skv.tlx) {

	     /*
	     SOUNDING EDITING !!!!!!
	     */

  	     XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc,
                rbdata.points[0].x, rbdata.points[0].y,
                rbdata.points[1].x, rbdata.points[1].y);
  	     XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc,
                rbdata.points[1].x, rbdata.points[1].y,
                rbdata.points[2].x, rbdata.points[2].y);

	     /* ----- Determine pres/temp coords of cursor ----- */ 
	     pres = pix_to_pres((short)event->xbutton.y);
	     tcur = pix_to_temp((short)event->xbutton.x,
			     (short)event->xbutton.y);

	     pIndex = getParmIndex("PRES");
	     tIndex = getParmIndex("TEMP");
	     tdIndex = getParmIndex("DWPT");

	     if (!sndg || pIndex == -1) return;

	     if (pres > sndg[sfc()][pIndex]) pres = sndg[sfc()][pIndex];

             temp = i_temp(pres , I_PRES);
             dwpt = i_dwpt(pres , I_PRES);
             d1 = (float)fabs(tcur - temp);
             d2 = (float)fabs(tcur - dwpt);

             if (tIndex != -1 && d1 < d2) {
           
	        /* ----- Edit Temperatures ----- */
	        rbdata.itype = 0;
                rbdata.i = i = grab_level(pres);
                if (!qc(sndg[i][tIndex])) sndg[i][tIndex] = i_temp(sndg[i][pIndex], I_PRES);

                /* ----- Move mouse to starting spot ----- */
                rbdata.yy = yy = pres_to_pix(sndg[i][pIndex]);
	        XWarpPointer (XtDisplay(draw_reg), XtWindow(draw_reg), XtWindow(draw_reg), skv.tlx, skv.tly, skv.brx+skv.tlx, skv.bry+skv.tly, temp_to_pix(sndg[i][tIndex], sndg[i][pIndex]), yy);
	        rbdata.last_x = rbdata.start_x = event->xbutton.x;
	        rbdata.last_y = rbdata.start_y = event->xbutton.y;
	        rbdata.points[1].x = temp_to_pix(sndg[i][tIndex], sndg[i][pIndex]);
	        rbdata.points[1].y = yy;

	        if (i == 0) {
	          rbdata.points[0].x = rbdata.points[1].x;
	          rbdata.points[0].y = rbdata.points[1].y;
	          rbdata.points[2].x = temp_to_pix(sndg[i+1][tIndex], sndg[i+1][pIndex]);
	          rbdata.points[2].y =  pres_to_pix(sndg[i+1][pIndex]);
	          rbdata.ilev = 0;
	          }
	        else if (i == numlvl-1) {
	          rbdata.points[2].x = rbdata.points[1].x;
	          rbdata.points[2].y = rbdata.points[1].y;
	          rbdata.points[0].x = temp_to_pix(sndg[i-1][tIndex], sndg[i-1][pIndex]);
	          rbdata.points[0].y =  pres_to_pix(sndg[i-1][pIndex]);
	          rbdata.ilev = 1;
	        }
	        else {
	          rbdata.points[0].x = temp_to_pix(sndg[i-1][tIndex], sndg[i-1][pIndex]);
	          rbdata.points[0].y =  pres_to_pix(sndg[i-1][pIndex]);
	          rbdata.points[2].x = temp_to_pix(sndg[i+1][tIndex], sndg[i+1][pIndex]);
	          rbdata.points[2].y =  pres_to_pix(sndg[i+1][pIndex]);
	          rbdata.ilev = 2;
	        }
	      }
              else if (tdIndex != -1) {
                /* ----- Edit Dew Points ----- */
	        rbdata.itype = 1;
                rbdata.i = i = grab_level(pres);
                if (tdIndex != -1 && !qc(sndg[i][tdIndex])) sndg[i][tdIndex] = i_dwpt(sndg[i][pIndex], I_PRES);

                /* ----- Move mouse to starting spot ----- */
                rbdata.yy = yy = pres_to_pix(sndg[i][pIndex]);
	        XWarpPointer(XtDisplay(draw_reg), XtWindow(draw_reg),
			  XtWindow(draw_reg), skv.tlx, skv.tly,
			  skv.brx+skv.tlx, skv.bry+skv.tly,
			  temp_to_pix(sndg[i][tdIndex], sndg[i][pIndex]), yy);
	        rbdata.last_x = rbdata.start_x = event->xbutton.x;
	        rbdata.last_y = rbdata.start_y = event->xbutton.y;
	        rbdata.points[1].x = temp_to_pix(sndg[i][tdIndex],sndg[i][pIndex]);
	        rbdata.points[1].y = yy;
	        if (i == 0) {
	          rbdata.points[0].x = rbdata.points[1].x;
	          rbdata.points[0].y = rbdata.points[1].y;
	          rbdata.points[2].x = temp_to_pix(sndg[i+1][tdIndex], sndg[i+1][pIndex]);
	          rbdata.points[2].y =  pres_to_pix(sndg[i+1][pIndex]);
	          rbdata.ilev = 0;
	        }
	        else if (i == numlvl -1) {
	          rbdata.points[2].x = rbdata.points[1].x;
	          rbdata.points[2].y = rbdata.points[1].y;
	          rbdata.points[0].x = temp_to_pix(sndg[i-1][tdIndex], sndg[i-1][pIndex]);
	          rbdata.points[0].y =  pres_to_pix(sndg[i-1][pIndex]);
	          rbdata.ilev = 1;
	        }
	        else {
	          rbdata.points[0].x = temp_to_pix(sndg[i-1][tdIndex], sndg[i-1][pIndex]);
	          rbdata.points[0].y =  pres_to_pix(sndg[i-1][pIndex]);
	          rbdata.points[2].x = temp_to_pix(sndg[i+1][tdIndex], sndg[i+1][pIndex]);
	          rbdata.points[2].y =  pres_to_pix(sndg[i+1][pIndex]);
	          rbdata.ilev = 2;
	        }
	      }

	     }
	     else if (event->xbutton.y < hov.bry && event->xbutton.x < hov.brx && event->xbutton.y > hov.tly && event->xbutton.x > hov.tlx) {
		/*
		HODOGRAPH EDITING !!!!!
		*/

		/* See if the user is setting the display mode */
		if (event->xbutton.x < (hov.tlx + 75) && event->xbutton.y < (hov.tly + 56)) {
			x1 = event->xbutton.x;
			y1 = event->xbutton.y;
			if (y1 > hov.tly+1 && y1  < hov.tly+18) hodo_mode = HODO_NORMAL;
			if (y1 > hov.tly+19 && y1 < hov.tly+36) hodo_mode = HODO_STORMRELATIVE;
			/*if (y1 > hov.tly+26 && y1 < hov.tly+35) hodo_mode = HODO_EFFECTIVE;*/
			/* 4jan07 */
			if (y1 > hov.tly+37 && y1 < hov.tly+55) hodo_mode = HODO_MEANWIND;
			/*if (y1 > hov.tly+37 && y1 < hov.tly+46)	hodo_mode = HODO_MEANWIND;*/
/*			printf( "Changing Button mode!!!!!!!\n"); */
			redraw_graph(drawing_mode);
			return;
			}
	        pix_to_hodo((short)event->xbutton.x,(short)event->xbutton.y, &st_dir, &st_spd);
		redraw_graph(drawing_mode);
	        hodo_cursor_data((short)event->xbutton.x, (short)event->xbutton.y);
	     }

		/* parcel choices from data area below skewt (added 2/15/05 by RLT) */
/*		if (event->xbutton.x < (skv.tlx+350) && event->xbutton.y < (skv.bry+127)) {
*/

                if (event->xbutton.x < (skv.tlx+350) && event->xbutton.x > (skv.tlx+5) && event->xbutton.y < (skv.bry+127)
			&& event->xbutton.y > (skv.bry+43)) {
			xp = event->xbutton.x;
			yp = event->xbutton.y;
/*			if (yp > skv.bry+51 && yp < skv.bry+65) lplvals.flag = 1;
		        if (yp > skv.bry+65 && yp < skv.bry+79) lplvals.flag = 4;
                        if (yp > skv.bry+79 && yp < skv.bry+93) lplvals.flag = 2;
                        if (yp > skv.bry+93 && yp < skv.bry+107) lplvals.flag = 3;
                        if (yp > skv.bry+107 && yp < skv.bry+121) lplvals.flag = 6;
*/
                        if (yp > skv.bry+43 && yp < skv.bry+57) lplvals.flag = 1;
                        if (yp > skv.bry+57 && yp < skv.bry+71) lplvals.flag = 4;
                        if (yp > skv.bry+71 && yp < skv.bry+85) lplvals.flag = 2;
                        if (yp > skv.bry+85 && yp < skv.bry+99) lplvals.flag = 3;
                        if (yp > skv.bry+99 && yp < skv.bry+113) lplvals.flag = 6;
                        if (yp > skv.bry+113 && yp < skv.bry+127) lplvals.flag = 5;

			if (lplvals.flag == 1) define_parcel(1, 0);
			if (lplvals.flag == 2) define_parcel(2, 0);
			if (lplvals.flag == 3) define_parcel(3, mu_layer);
			if (lplvals.flag == 4) define_parcel(4, mml_layer);
			if (lplvals.flag == 6) define_parcel(6, mu_layer);
                        if (lplvals.flag == 5) define_parcel(5, user_level);

                        if (lplvals.flag == 1) current_parcel = 1;
                        if (lplvals.flag == 2) current_parcel = 2;
                        if (lplvals.flag == 3) current_parcel = 3;
                        if (lplvals.flag == 4) current_parcel = 4;
                        if (lplvals.flag == 6) current_parcel = 6;
                        if (lplvals.flag == 5) current_parcel = 5;

/*                        printf("\n current parcel after click = %d\n", current_parcel);
*/			redraw_graph(drawing_mode);
			return;
			}				
	 XFlush(XtDisplay(draw_reg));
	 }


	/* Popup the sounding selection window */
	 else if (event->xbutton.button == 3) {
           if ( load_sharp != (Widget) NULL) { if (XtIsManaged(load_sharp)) XtUnmanageChild(load_sharp); }

	   if (chooser_dialog == NULL) 
	      showdatachooser(0);
	   else {
             if (XtIsManaged(chooser_dialog))
               XtUnmanageChild(chooser_dialog);
	     else
               XtManageChild(chooser_dialog);
	     }
	  }
}



	/*NP*/
void pointer_update(Widget w, XtPointer *call_data, XEvent *event)
        /*************************************************************/
        /* POINTER_UPDATE					     */
	/* 							     */
	/* Handles "mouse moved w/ no buttons" event		     */
        /*************************************************************/
{

	/* ----- Abort if not over either image ----- */
	if (event->xbutton.x < skv.tlx) return;
	if (event->xbutton.x > hov.brx) return;

	/* ----- Update Cursor Data when mouse is moved ----- */
	if ((event->xbutton.x < skv.brx) && (event->xbutton.y < skv.bry) && (event->xbutton.y > skv.tly)) 
	   { skewt_cursor_data((short)event->xbutton.x, (short)event->xbutton.y); }
	else
	   { hodo_cursor_data((short)event->xbutton.x, (short)event->xbutton.y); }
	XFlush(XtDisplay(draw_reg));
}

void update_pointer(Widget w, XtPointer *call_data, XEvent *event)
        /*************************************************************/
        /* UPDATE_POINTER					     */
        /*							     */
	/* Handles "mouse moved while button #1 was depressed" event */ 
	/*************************************************************/
{
       if (!qc(i_temp(700, I_PRES)))
	  return;

	if (event->xbutton.y < skv.bry && event->xbutton.x < skv.brx && event->xbutton.y > skv.tly && event->xbutton.x > skv.tlx) {
  	   XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[0].x, rbdata.points[0].y, rbdata.points[1].x, rbdata.points[1].y);
  	   XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[1].x, rbdata.points[1].y, rbdata.points[2].x, rbdata.points[2].y);

   	   rbdata.last_x  = event->xbutton.x;
  	   rbdata.last_y  = event->xbutton.y;
  	   rbdata.points[1].x = event->xbutton.x;

  	   XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[0].x, rbdata.points[0].y, rbdata.points[1].x, rbdata.points[1].y);
  	   XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[1].x, rbdata.points[1].y, rbdata.points[2].x, rbdata.points[2].y);

	   skewt_cursor_data((short)event->xbutton.x, (short)rbdata.points[1].y);

	   }
	else if (event->xbutton.y < hov.bry && event->xbutton.x < hov.brx && event->xbutton.y > hov.tly && event->xbutton.x > hov.tlx) {
	   pix_to_hodo((short)event->xbutton.x,(short)event->xbutton.y, &st_dir, &st_spd);
	   redraw_graph(drawing_mode);
	   hodo_cursor_data((short) event->xbutton.x, (short) event->xbutton.y);
	   }

	XFlush(XtDisplay(draw_reg));
}


	/*NP*/
void redraw_sounding(Widget w, XtPointer *call_data, XEvent *event)
       /*************************************************************/
       /* REDRAW_SOUNDING					    */
       /* Button Released event                                     */
       /*************************************************************/
{
	float chg1, pres;
	short pIndex, tIndex, tdIndex;
	
	if (event->xbutton.button != 1 || !qc(i_temp(700, I_PRES))) return;

	pIndex = getParmIndex("PRES");
	tIndex = getParmIndex("TEMP");
	tdIndex = getParmIndex("DWPT");

	if (!sndg || pIndex == -1 || tIndex == -1 || tdIndex == -1) return;

	/* Redraw previous line */
	if (event->xbutton.y < skv.bry && event->xbutton.x < skv.brx && event->xbutton.y > skv.tly && event->xbutton.x > skv.tlx) { 
  	  XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[0].x, rbdata.points[0].y, rbdata.points[1].x, rbdata.points[1].y);
  	  XDrawLine(XtDisplay(w), XtWindow(w), rbdata.gc, rbdata.points[1].x, rbdata.points[1].y, rbdata.points[2].x, rbdata.points[2].y);

	  if (!rbdata.itype) {
	  	chg1 = pix_to_temp((short)event->xbutton.x, rbdata.yy);	
	    	if (chg1 < i_dwpt(sndg[rbdata.i][pIndex], I_PRES)) { chg1 = i_dwpt(sndg[rbdata.i][pIndex], I_PRES); }
	    	sndg[rbdata.i][tIndex] = chg1;
	    	}
	  else {
	    	chg1 = pix_to_temp((short)event->xbutton.x, rbdata.yy);	
	    	if(chg1 > i_temp(sndg[rbdata.i][pIndex], I_PRES)) { chg1 = i_temp(sndg[rbdata.i][pIndex], I_PRES); }
	    	sndg[rbdata.i][tdIndex] = chg1;
	  	}

	  rbdata.points[0].x = rbdata.points[1].x = rbdata.points[2].x = 0;
	  rbdata.points[0].y = rbdata.points[1].y = rbdata.points[2].y = 0;
        printf("\n lplvals.flag before redraw_graph in redraw_sounding  = %d\n", lplvals.flag);
	  redraw_graph(drawing_mode);
	}
}

/*
Updated 10/14/99
mkay
Move string creation outside of XtVaSet so we don't have a memory
leak
*/

void tog_graph(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /* TOG_GRAPH						    */
       /*************************************************************/
{
	XmString temp;

	drawing_mode = switch_modes(drawing_mode);

	/* Put the "other" text label on the button now */
	if (drawing_mode == DRAW_SKEWT) {
	  temp = XmStringCreateLocalized("Hodograph");
	}
	else {
	  temp = XmStringCreateLocalized("Skewt");
	}
	XtVaSetValues(w, XmNlabelString, temp, NULL);
	XmStringFree(temp);

/*
	XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
*/
}

void page_next(Widget w, XmDrawingAreaCallbackStruct *call_data)
       /*************************************************************/
       /* PAGE_NEXT						    */
       /*************************************************************/
{

        if (!qc(i_temp(700, I_PRES)))
	  return;

        pagenum += 1;
        if (pagenum == 8) pagenum = drawing_mode;
        show_page(pagenum);

	XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
}


	/*NP*/
void Toggle_Callback(Widget w, int which, caddr_t call)
       /*************************************************************/
       /* TOGGLE_CALLBACK - User has changed parcel		    */
       /*************************************************************/
{
	float pres;

	XtUnmanageChild(XtParent(XtParent(XtParent(XtParent(w)))));
	if (which == 5)
	  return;

	current_parcel = which+1;

	if (current_parcel == 3)
	  pres = mu_layer; 
	else if (current_parcel == 4)
	  pres = mml_layer;
	else if (current_parcel == 5)
	  pres = user_level;
	else
	  pres=-1;
	define_parcel((short)(which+1), pres);
	redraw_graph(drawing_mode);
}


	/*NP*/
GC xs_create_xor_gc(Widget w, char *color)
       /*************************************************************/
       /* XS_CREATE_XOR_GC					    */
       /*************************************************************/
{
  	XGCValues     values;
  	GC            gc;

  	XtVaGetValues(w, XtNbackground, &values.background, NULL);

	/*
 	* Set the fg to the XOR of the fg and bg, so if it is
 	* XOR'ed with the bg, the result will be fg and vice-versa.
 	* This effectively achieves inverse video for the line.
 	*/

 	values.foreground = pixels[1];
  	values.background = pixels[0];
  	values.foreground = values.foreground ^ values.background;

	/* Set rubber band gc to use XOR mode and draw solid line */ 

  	values.line_style = LineSolid;
  	values.line_width = 4;
  	values.function   = GXxor;

  	gc = XtGetGC(w, GCForeground | GCBackground | GCFunction | GCLineStyle, &values);

  	return gc;
}



	/*NP*/
void load_cb(Widget w, XtPointer client_data, XtPointer call_data)
/*************************************************************/
/* LOAD_CB 						     */
/*************************************************************/
{
	int item_no = (int)client_data;

	switch (item_no) {
	case 0:
           if ( load_sharp != (Widget) NULL) { if (XtIsManaged(load_sharp)) XtUnmanageChild(load_sharp); }

	  if (chooser_dialog) {
	    showdatachooser(-1);
            }
	  else {
	    if (curdatatype_ptr)
	      /* For use w/ command-line args. 
	         You may have loaded data already */
	      showdatachooser(curdatatype_ptr->id);
	    else
	      showdatachooser(0);
	  }
	break;
	case 1:
           if (!load_sharp) {
               load_sharp = XmCreateFileSelectionDialog(toplevel,
			   "archivefile", NULL, 0);
               XtAddCallback(load_sharp, XmNokCallback, sharp_load, NULL);
	       XtAddCallback(load_sharp, XmNcancelCallback, (XtCallbackProc)XtUnmanageChild, NULL);
               XtAddCallback(load_sharp, XmNokCallback, (XtCallbackProc)XtUnmanageChild, NULL);
	   }

	   /* 
	    * Make sure data chooser isn't also up. 
	    * If so, unmanage it 
	    * before we pop the other dialog up 
	    */

	   /* commented out line below 2/25/06 to stop crashes when loading NSHARP archives first */
/*	   if (XtIsManaged(chooser_dialog)) { XtUnmanageChild(chooser_dialog); } */
	   XtManageChild(load_sharp);

	break;
	default:
	return;
	}
}

void file_cb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	int item_no = (int)client_data;
	switch (item_no) {
	  case 1:
	    if (numlvl > 0) print_sounding_hpgl();
	  break;
	  case 2:
	    save_giffile(w, NULL, NULL);
	  break;
	  case 3:
	    exit(0);
	  break;
	}
}

/* removed 29OCT06 by RLT */
void option_cb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	int item_no = (int)client_data;
	switch (item_no) {
	  case 0:
	    /* Value changed on drawing mode (Convection/Winter) */
	    if (display_mode_left == DISPLAY_WINTER_LEFT) {

	      /* added 25OCT06 by RLT */
	      /*display_mode = DISPLAY_CONVECTION;*/
	      display_mode_left = DISPLAY_SARS_LEFT;		

	      pagenum = 1;
	    }
	    else {
	      display_mode_left = DISPLAY_WINTER_LEFT;
	      pagenum = 1;
	    }

              clear_paramarea();
              draw_skewt();
              draw_hodo();
              show_page(pagenum); 
	      XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	      XFlush(XtDisplay(draw_reg));
	}

}

	/*NP*/
	void about_cb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* ABOUT_CB 						    */
       /*							    */ 
       /* Displays ABOUT message				    */
       /*************************************************************/
	{
        int             i;
        static Widget   aboutBox, temp;
        char            msg2[800];
        char            *message[] =
        { "------------------------------------- NSHARP ---------------------------------------\n ",
          "Advanced Interactive Sounding Analysis Program for NAWIPS.\n\n\n",
          "Version: " __DATE__ "\n\n\n",
          "Written/Designed by:\n",
          "John Hart                         Gregg Grosshans\n",
          "Rich Thompson               Mike Kay\n",
          "Jim Whistler                    Ryan jewell\n"
          "NOAA/NWS/NCEP,\n",
          "Storm Prediction Center,\n",
          "Norman OK\n" };

        XmString        msg, title;

           if ( aboutBox != (Widget) NULL) {
           if (XtIsManaged(aboutBox))
             XtUnmanageChild(aboutBox);
	   }
        if (!aboutBox) {
           aboutBox = XmCreateMessageDialog( toplevel, "aboutBox", NULL, 0);
           title = XmStringCreateLocalized( "About NSHARP" );
           strcpy ( msg2, message[0] );

           for ( i=1; i < XtNumber(message); i++ ) 
               strcat ( msg2, message[i] );
           
           msg   = XmStringCreateLtoR( msg2, XmFONTLIST_DEFAULT_TAG );
           XtVaSetValues( aboutBox,
                        XmNmessageString, msg,
                        XmNdialogTitle, title,
                        NULL);
           XmStringFree( title );
           XmStringFree( msg );

           /* ----- Turn off CANCEL and HELP buttons ----- */
           temp = XmMessageBoxGetChild( aboutBox, XmDIALOG_CANCEL_BUTTON);
           XtUnmanageChild(temp);
           temp = XmMessageBoxGetChild( aboutBox, XmDIALOG_HELP_BUTTON);
           XtUnmanageChild(temp);
           }

        XtManageChild(aboutBox);

	}

	/*NP*/
	void show_about_info(Widget w)
	/***********************************************************/
	/* SHOW_ABOUT_INFO					   */
	/***********************************************************/
	{
	char	finam[200];	

	sprintf( finam, "nsharp.hlp");
/*	printf( "Attempting to display contents of %s\n", finam); */
	NxmHelp_loadFile(w, finam);
	}

void set_user_level(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* SET_USER_LEVEL					    */
       /*************************************************************/
{
	char *text_sta;

	text_sta = XmTextGetString(w);

	if (text_sta != NULL)
	  sscanf(text_sta, "%f", &user_level);
	else
	  user_level = 850;
	
	XtFree(text_sta);
}


void parcel_cancel_cb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* PARCEL_CANCEL_CB					    */
       /*************************************************************/
{
	XtUnmanageChild((Widget)client_data);
}


	/*NP*/
void sharp_load(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* SHARP_LOAD 						    */
       /*************************************************************/
{
	float ix1, ix2, pres;
	     
	char *file = NULL, filename[256], bufr[256];
	XmFileSelectionBoxCallbackStruct *cbs = (XmFileSelectionBoxCallbackStruct *) call_data;

	hodo_mode = HODO_MEANWIND;

	if (cbs) {
	  if (!XmStringGetLtoR(cbs->value, XmFONTLIST_DEFAULT_TAG, &file)) {
	    errordialog(w, "No file specified!");
	    return;
	  }

	  if (file[strlen(file)-1] == '/') {
	    errordialog(XtParent(w), "No file specified!");
	    return;
	  }

	  strcpy(filename, config.filename);
	  strcpy(config.filename, file);
	  XtFree(file);

	  if (get_sndg()) {
	    sprintf(bufr, "Error reading file %s", config.filename);
	    errordialog(w, bufr);
	    strcpy(config.filename, filename);
	    return;
	  }

	  drawing_mode = DRAW_SKEWT;
	  pagenum = 1;
	  draw_skewt();
	  draw_hodo();
	  clear_paramarea();

	  /*switch (current_parcel) {
	    case 3:
	      pres = mu_layer;
	    break;
	    case 4:
              pres = mml_layer;
	    break;
	    case 5:
              pres = user_level;
	    break;
	  }*/
      
            switch (current_parcel) {
              case 1:
                pres = 0;
              break;
              case 2:
                pres = 0;
              break;
              case 3:
                pres = mu_layer;
              break;
              case 4:
                pres = mml_layer;
              break;
              case 5:
                pres = user_level;
              break;
              case 6:
                pres = mu_layer;
              break;
            }
 
          define_parcel(current_parcel, pres);

	  show_parcel();
	  trace_dcape();
	  if (display_mode_left == DISPLAY_WINTER_LEFT) { pagenum=5; } 
	  else  { pagenum = 1; }
/*	  bunkers_storm_motion(&ix1, &ix2, &st_dir, &st_spd);
*/	  write_file();
          show_page(pagenum);
	}
}



	/*NP*/
void Load_stationlist(int list)
/*************************************************************/
/* LOAD_STATIONLIST					    */
/*************************************************************/
{
	  char		station_tbl[12], statlist[MAXSTNS][18];
	  int		nsta, i, maxstn;
	  int		ncolor, mrktyp, mrkwid, pltval, iposn, jcolr;
	  float		sta_lat[MAXSTNS], sta_lon[MAXSTNS], sizmrk;

	  station_tbl[0] = '\0';
	  switch (list) {
	    case 0:
	      strcpy(station_tbl, "US");
	    break;
	    case 1:
	      strcpy(station_tbl, "CN");
	    break;
	    case 2:
	      strcpy(station_tbl, "MX");
	    break;
	  }

          ncolor    = 1;
          mrktyp    = 6;
          sizmrk    = 0.5;
          mrkwid    = 2;
          pltval    = G_FALSE;
          iposn     = 0;
	  jcolr     = 2;

	  station_list = list;

	  if (curdatatype_ptr == NULL) return;

	  if (curdatatype_ptr->filename[0] != '\0'  && curdatatype_ptr->time[0] != '\0' && station_tbl[0] != '\0') {

	    /* 
	     * If we are dealing with model data there are 
	     * no stations in the file instead load the surface stations
	     */
	    if (curdatatype_ptr->stype == NSHARP_MDL) {
	      maxstn = MAXSTNS;
	      get_mdl_stns(&maxstn, statlist, sta_lat, sta_lon, &nsta);
	    }
	    else {
	      get_gem_stns(curdatatype_ptr->filename, 
	        station_tbl, 
	        curdatatype_ptr->time,
		statlist, &nsta, sta_lat, sta_lon,
		strlen(curdatatype_ptr->filename), 
	        strlen(station_tbl),
		strlen(curdatatype_ptr->time));
	    }

	    drawdatamap(nsta, sta_lat, sta_lon);

	    stnList.nstn = nsta;
	    for (i=0; i < nsta; i++) {
	      statlist[i][17] = '\0';
	      stnList.lat[i] = sta_lat[i];
	      stnList.lon[i] = sta_lon[i];
	      strcpy(stnList.stnName[i], statlist[i]);
	    }
	  }
	  else {
	      stnList.nstn = 0;
	      drawdatamap(0, NULL, NULL);
	  }

	  /* Make sure we clear out our station */
	  curdatatype_ptr->station[0] = '\0';
}


	/*NP*/
void sta_select_cb(int which_sta)
       /*************************************************************/
       /* STA_SELECT_CB						    */
       /*************************************************************/
{
	char  stanum[6], sta_tmp[12];
	int   ival;

	if (which_sta >= stnList.nstn) {
	  fprintf(stderr, 
	    "sta_select_cb: What the hell? Your index (%d) is too large!\n", 
	    which_sta);
	  return;
	}

	ival = sscanf(stnList.stnName[which_sta],
	  "%s %s %s", sta_id, stanum, sta_tmp);

	if (curdatatype_ptr == NULL) return;

	curdatatype_ptr->station[0] = '\0';
	if (ival > 0) {
	  strcpy(curdatatype_ptr->station, sta_id);
	}
	else {
	  strcpy(curdatatype_ptr->station, "UNKNOWN");
	}

	hodo_mode = HODO_MEANWIND;
	load_sounding(curdatatype_ptr->stype);
}

	
/*NP*/
int save_gif(char *filename)
/************************************************************/
/* SAVE_GIF						    */
/* 							    */
/* Write output to GIF image                                */
/************************************************************/
{
        XImage *im;
        XColor cmapcols[256];
        byte r[256], g[256], b[256];
        Colormap cmap;
        int i, xloc, yloc;
	unsigned int bw, dpth, wd, ht;
        FILE *fp;

	/* Determine size/shape of pixmap */
	XGetGeometry(XtDisplay(draw_reg), XtWindow(draw_reg),
                     &root, &xloc, &yloc, &wd, &ht, &bw, &dpth);
	xwdth = wd;
	xhght = ht;

        /* Read contents of the pixmap */
        im = XGetImage(XtDisplay(draw_reg), canvas, 0, 0, 
	               xwdth, xhght, AllPlanes, ZPixmap);

        if (!im) {
          fprintf(stderr, "XGetImage() returned NULL. crap.\n");
          return 0;
        }

        cmap = DefaultColormap(XtDisplay(draw_reg),
                               DefaultScreen(XtDisplay(draw_reg)));

        for( i=0; i<256; i++ ) {
          cmapcols[i].pixel = i;
          cmapcols[i].flags = DoRed | DoGreen | DoBlue;
        }

        XQueryColors(XtDisplay(draw_reg), cmap, cmapcols, 256);
        for(i=0;i<256;i++) {
          r[i] = cmapcols[i].red;
          g[i] = cmapcols[i].green;
          b[i] = cmapcols[i].blue;
        }

        fp = fopen(filename,"w");
        if (!fp) {
          return 1;
        }
        WriteGIF(fp, (byte *)im->data, im->width, im->height, r, g, b, 256, 3);
        fclose(fp);

        XDestroyImage (im);

        return i;
}
	

	/*NP*/
	void gif_output(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* GIF_OUTPUT 						    */
       /*************************************************************/
	     {
	     save_gif("nsharp.gif");
	     }

	

	/*NP*/
void change_mode(Widget w, XtPointer client_data, XtPointer call_data )
       /*************************************************************/
       /* CHANGE_MODE 						    */
       /*************************************************************/
{
	XmString newlabel;

	if (display_mode_left == DISPLAY_WINTER_LEFT) {
	  newlabel = XmStringCreateLocalized("Winter");
	  XtVaSetValues(w, XmNlabelString, newlabel, NULL);
	  display_mode_left = DISPLAY_CONVECTION_LEFT;
	  pagenum = 1;
	}
	else {
	  newlabel = XmStringCreateLocalized("Convection");
	  display_mode_left = DISPLAY_WINTER_LEFT;
	  pagenum = 1;
	}
	XtVaSetValues(w, XmNlabelString, newlabel, NULL);
	XmStringFree(newlabel);

        clear_paramarea();
        draw_skewt();
        show_page(pagenum);

	newlabel = XmStringCreateLocalized("Hodograph");
	XtVaSetValues(graph_tog, XmNlabelString, newlabel, NULL);
	XmStringFree(newlabel);

	XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
}


	
	/*NP*/
void set_mml_level(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* SET_MML_LEVEL  					    */
       /*************************************************************/
{
	char *text_sta = XmTextGetString(w);

	if (text_sta != NULL) {
	  sscanf(text_sta, "%f", &mml_layer);
	  XtFree(text_sta);
	}
	else
	  mml_layer = 100.0;
}

	
	/*NP*/
void set_mu_level(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
       /* SET_MU_LEVEL  					    */
       /*************************************************************/
{
	char *text_sta = XmTextGetString(w);

	if (text_sta != NULL) {
	  sscanf(text_sta, "%f", &mu_layer);
	  XtFree(text_sta);
	}
	else
	  mu_layer = 300.0;
}


        /*NP*/
void reset_options(short mode, short pagenum)
        /*************************************************************/
        /*  RESET_OPTIONS                                            */
        /*  John Hart  NSSFC KCMO                                    */
        /*                                                           */
        /*  Asks the user if they want to reload original sounding,  */
        /*  or just clear screen.                                    */
        /*************************************************************/
{
        float pres, ix1, ix2;
	short oldlplchoice;

/*      if (!qc(i_temp(700, I_PRES))) return;
*/
	bunkers_storm_motion(&ix1, &ix2, &st_dir, &st_spd);

/* 24 Mar 2008 */
/*      effective_inflow_layer(100, -250, &p_bot, &p_top);*/

        /*redraw_graph(drawing_mode);*/
        /*switch (current_parcel) {
          case 3:
            pres = mu_layer;
          break;
          case 4:
            pres = mml_layer;
          break;
          case 5:
            pres = user_level;
          break;
        XFlush(XtDisplay(draw_reg));
        }*/

            switch (current_parcel) {
              case 1:
                pres = 0;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
            	define_parcel(current_parcel, pres);
            	redraw_graph(drawing_mode);
              break;
            XFlush(XtDisplay(draw_reg));
            }

       /* define_parcel(current_parcel, pres);
	redraw_graph(drawing_mode);
        show_parcel();
        show_page(pagenum);*/

}

int get_colors(void)
/*************************************************************
 *                                                           *
 * get_colors                                                *
 *                                                           *
 * Here we'll allocate read-only color cells for the         *
 * application. No real need to do read-write since that     *
 * makes life way more difficult than we need it to be.      *
 *                                                           *
 * Mike Kay                                                  *
 * Storm Prediction Center                                   *
 * mkay@hesston.spc.noaa.gov                                 *
 *************************************************************/
{
        int i, max_colors=32;
        char *cnames[] = {"Black", "bisque1", "red", "green", "blue",
			  "yellow", "cyan", "magenta", "sienna3", 
			  "sienna1", "tan1", "LightPink1", "IndianRed1",
			  "firebrick2", "red4", "red3", "OrangeRed2",
			  "DarkOrange1", "orange3", "gold1", "yellow2", 
			  "chartreuse1", "green3", "green4", "DodgerBlue4", 
			  "DodgerBlue1", "DeepSkyBlue2", "cyan2", 
			  "MediumPurple3", "purple2", "magenta4", "white" };
        XColor exact_def;
        Colormap cmap;

        cmap = DefaultColormap(XtDisplay(toplevel), 
	         DefaultScreen(XtDisplay(toplevel)));

        for (i=0;i<max_colors;i++) {
           XParseColor(XtDisplay(toplevel), cmap, cnames[i], &exact_def);
           if (!XAllocColor(XtDisplay(toplevel), cmap, &exact_def)) {
            	fprintf(stderr,"Could not allocate color:  %s\n", cnames[i]);
            	return 0;
           }
           pixels[i] = exact_def.pixel;
           ncolors++;
        }

        return ncolors;
}

void processuserdata(Widget widget, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	short pIndex, tIndex, tdIndex, wsIndex, wdIndex;
	char *userstring, thermo[32], wind[32], *ptr, timestr[12], bufr[256];
	float T, Td, wspd, wdir, pres;
	int i;

	T = Td = wspd = wdir = pres = -9999.0;

	userstring = XmTextGetString(widget);

	if (userstring) {
  
  	  if (userstring[0] == '@') {
  
  	    strcpy(bufr,"latest");
  	    strcpy(thermo,userstring);
  
  	    for (i=0;userstring[i];i++) {
  	      if (userstring[i] == '-') {
  	        strncpy(thermo, userstring, i);
  	        thermo[i] = '\0';
  	        strcpy(bufr, &userstring[i+1]);
  	        if (!*bufr) {
  	          strcpy(bufr, "latest");
  	        }
  	      }
  	    }
  
/*	printf("sizeof timestr: %d\n", sizeof(timestr)); */
  	    getsfcdata("$CURSAO", thermo, bufr, timestr, &T, &Td, &wdir, &wspd,
  	      strlen("$CURSAO"), strlen(thermo), strlen(bufr), 
	      sizeof(timestr));
  
  	    timestr[11] = '\0';

/*	    printf("getsfcdata says wdir is %.2f\n", wdir);
printf("T %.1f  Td %.1f  Wdir %.1f  Wspd %.1f\n", T, Td, wdir, wspd);
*/  
  	    if (T < -999.0 && Td < -999.0 && wdir < -999.0 && wspd < -999.0) {
  	      sprintf(bufr,"Fat chance pal. No data for %s", timestr);
  	      setsfctimelabel(bufr);
	      /* Return now so that we don't toast the current sfc data */
	      return;
  	    }
  	    else {
  	      strcpy(bufr, timestr);
  	    }
  
  	    setsfctimelabel(bufr);
  	  }
  	  else {

	    if (!strchr(userstring, '/') && strlen(userstring) <= 4) {
	      if (!curdatatype_ptr)
  	        return;
	      for (i=0;userstring[i];i++) 
	        userstring[i] = toupper(userstring[i]);
  	      strcpy(curdatatype_ptr->station, userstring);
  	      strcpy(sta_id, curdatatype_ptr->station);
  	      load_sounding(curdatatype_ptr->stype);
  	      return;
	    }
  
  	    strncpy(thermo, userstring, 31);
  	    thermo[strlen(thermo)] = '\0';
  
  	    if ((ptr = strchr(thermo,';'))) {
  	      *ptr = '\0';
  	      ptr++; 
  
  	      strncpy(wind, ptr, 31);
  	      wind[strlen(ptr)] = '\0';
  	    }
    
  	    /* Do thermo stuff */
  	    if (strchr(thermo,'/')) {
  	      i = sscanf(thermo,"%g/%g", &T, &Td);
  	      if (i == 0) {
  	        if (thermo[0] == '/') {
  	          i = sscanf(thermo,"/%g", &Td);
  	          Td = (i == 1) ? Td : -9999.0;
  	        }
  	      }
  	    }
  	    else {
  	      i = sscanf(thermo,"%g", &T);
  	      Td = (i == 1) ? Td : -9999.0;
  	    }
    
  	    /* Do winds */
  	    if (wind) {
  	      if (strchr(wind,'/')) {
  	        i = sscanf(wind,"%g/%g", &wdir, &wspd);
  	        if (i == 0) {
  	          if (wind[0] == '/') {
  	            i = sscanf(wind,"/%g", &wspd);
  	            wspd = (i == 1) ? wspd : -9999.0;
  	          }
  	        }
  	        else {
  	        }
  	      }
  	      else {
  	        i = sscanf(wind,"%g", &wdir);
  	        wdir = (i == 1) ? wdir : -9999.0;
  	      }
  	    }
    
  	    setsfctimelabel("");
  	  }

	  XtFree(userstring);

	  pIndex = getParmIndex("PRES");
	  tIndex = getParmIndex("TEMP");
	  tdIndex = getParmIndex("DWPT");
	  wsIndex = getParmIndex("SPED");
	  wdIndex = getParmIndex("DRCT");
  
  	  i = sfc();
  	  /* T */
	  if (sndg && tIndex != -1) {
  	    if (T > RMISSD) 
	      sndg[i][tIndex] = ftoc(T);
	    else
	      sndg[i][tIndex] = RMISSD;
	    }
  	  /* Td */
	  if (sndg && tdIndex != -1) {
  	    if (Td > RMISSD) 
	      sndg[i][tdIndex] = ftoc(Td);
	    else
	      sndg[i][tdIndex] = RMISSD;
	  }
  	  /* winds */
	  if (sndg && wdIndex != -1) {
/*	    printf("Setting surface wind direction to %.2f\n", wdir); */
  	    if (wdir > RMISSD) 
	      sndg[i][wdIndex] = wdir;
	    else
	      sndg[i][wdIndex] = RMISSD;
	  }
	  if (sndg && wsIndex != -1) {
  	    if (wspd > RMISSD) 
	      sndg[i][wsIndex] = wspd;
	    else
	      sndg[i][wsIndex] = RMISSD;
	  }
    
  	  /* Adjust boundary layer */
	  if (sndg && tIndex != -1 && tdIndex != -1) {
  	    adjbndrylayer(sndg[i][tIndex], sndg[i][tdIndex]);
	  }
	}
	else {
  	  setsfctimelabel("");
	}

	redraw_graph(drawing_mode);
	/*switch (current_parcel) {
	  case 3:
	    pres = mu_layer;
	  break;
	  case 4:
	    pres = mml_layer;
	  break;
	  case 5:
	    pres = user_level;
	  break;
	  default:
	    pres = mml_layer;
	}*/

            switch (current_parcel) {
              case 1:
                pres = 0;
              break;
              case 2:
                pres = 0;
              break;
              case 3:
                pres = mu_layer;
              break;
              case 4:
                pres = mml_layer;
              break;
              case 5:
                pres = user_level;
              break;
              case 6:
                pres = mu_layer;
              break;
            }

	define_parcel(current_parcel, pres);
	if (drawing_mode == DRAW_SKEWT) {
	  show_parcel();
	}
	show_page(pagenum);
        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
}

void processuserdatabndry(Widget widget, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
        short pIndex, tIndex, tdIndex, wsIndex, wdIndex;
        char *userstring, thermo[32], wind[32], *ptr, timestr[12], bufr[256];
        float wd, ws;
        int i;

	userstring = XmTextGetString(widget);

        if (userstring) 
	    {
   	    hodo_mode = HODO_BNDRY;
            i = sscanf(userstring,"%g/%g", &bd_dir, &bd_spd);
	    printf("--------------------------------->   %i, %f, %f\n", i, bd_dir, bd_spd);
            if (i < 2) 
	       {
	       hodo_mode = HODO_NORMAL;
               bd_dir = -9999;
               bd_spd = -9999;
	       }
            }
	  else
	    {
	       hodo_mode = HODO_MEANWIND;
               bd_dir = -9999;
               bd_spd = -9999;
            }

	draw_hodo();
        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	XFlush(XtDisplay(draw_reg));
}


/* Simple routine to clear the text box */
void resetuserinput(void)
       /*************************************************************/
{
	if (modifybox != NULL) {
	  XmTextSetString(modifybox,"");
	}
}

/* Simple routine to set the text label */
void setsfctimelabel(char *str)
       /*************************************************************/
{
        XmString text_str;
	char stringbufr[256];

	if (sfctimelabel == NULL) return;

	strcpy(stringbufr," ");
	strcat(stringbufr, str);
	text_str = XmStringCreateLocalized(stringbufr);
	XtVaSetValues(sfctimelabel, XmNlabelString, text_str, 
	  XmNalignment, XmALIGNMENT_BEGINNING, NULL);
	XmStringFree(text_str);
}

void zoommapwindow(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	mapw_zoomCb(w, client_data, NULL);	

	switch (sounding_type) {
	  case NSHARP_OBS:
	  case NSHARP_PFC:
	  case NSHARP_MDL:
	    Load_stationlist(0);
	  break;
	  default:
	    fprintf(stderr,"Cannot zoom for this data type (%d).\n", 
	      sounding_type);
	  break;
	}
}

void unzoommapwindow(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	resetmapinfo(0);

	switch (sounding_type) {
	  case NSHARP_OBS:
	  case NSHARP_PFC:
	  case NSHARP_MDL:
	    Load_stationlist(0);
	  break;
	  default:
	    fprintf(stderr,"Cannot unzoom for this data type (%d).\n", 
	      sounding_type);
	  break;
	}
}

void setsoundingtype(int type)
       /*************************************************************/
{
	prevsounding_type = sounding_type;
	sounding_type = type;
}



/*************************************************************/
/* LOAD_SOUNDING					     */
/* Routine to read in a sounding             		     */
/*************************************************************/
int load_sounding(int stype)
{
	short pIndex;
	int   i, j, ind, ier, newlev = 0;
	char *timeptr, *fileptr, *stnptr, *textptr, bufr[80];
	char st777[80], st888[80], st999[80];
	float ix1, ix2, pres, sfct, sfcd, sfch, sfcwd, sfcws;

	if (curdatatype_ptr == NULL) {
	  fprintf(stderr,
	    "load_sounding: current data pointer is NULL. crap.\n");
	  return;
	}

	fileptr = curdatatype_ptr->filename;
	timeptr = curdatatype_ptr->time;
	stnptr  = curdatatype_ptr->station;
	/*hodo_mode == HODO_NORMAL;*/

	if (*fileptr != '\0'  && *timeptr != '\0' && *stnptr != '\0') {

	     if (sndg) {
	        if (numlvl > 0) {
	          strcpy(raobtitle2, raobtitle);
	          strcpy(raob_type2, raob_type);
	        }
	     }

#ifdef DEBUG_JL
	     fprintf(stderr, "xwvid6.c: load_sounding: fileptr = %s at %s (%s)\n", fileptr, timeptr, stnptr);
#endif /* DEBUG_JL */
	     /* MKAY NEW */
	     i = load_sounding2(fileptr, timeptr, stnptr, stype);

	     if (chooser_dialog && !set_chooser_visible)
	       XtUnmanageChild(chooser_dialog);

	     /* Check for success from load_sounding2() */
	     if (i != 0) {
#ifdef DEBUG_JL
	       fprintf(stderr, "xwvid6.c: load_sounding: Error loading %s at %s (%d)\n", stnptr, timeptr, i);
#endif /* DEBUG_JL */
	       sprintf(bufr, "Error loading %s at %s (%d)", stnptr, timeptr, i);
	       set_status_text(status, bufr);
	       return i;
	     }

/* Add to history */

	     strncpy(st777, timeptr, 6); st777[6]=0;
	     strcpy(st888, timeptr+7); st888[2]=0; 

	     if (strlen(sta_id) > 2) {
	        strcpy(st999, sta_id); st999[3]=0;
	        sprintf(raobtitle, " %s   %s ", sta_id, timeptr);
	        sprintf(raobsavefilename, "%s%s.%s", st777, st888, st999);
	     } 
	     else {
	        strcpy(st999, stnptr); st999[3]=0;
		sprintf(raobtitle, " %s   %s ", stnptr, timeptr);
	        sprintf(raobsavefilename, "%s%s.%s", st777, st888, st999);
	     }

	sprintf(bufr, "Successfully loaded %s", raobtitle);
	set_status_text(status, bufr);

	     switch (stype) {
	       case NSHARP_OBS:
	         strcpy(raob_type, curdatatype_ptr->menuname);
	       break;
	       case NSHARP_MDL:
	         strcpy(raob_type, curdatatype_ptr->menuname);
	       break;
	       case NSHARP_PFC:
	         strcpy(raob_type, curdatatype_ptr->menuname);
	       break;
	       default:
	         fprintf(stderr, "load_sounding: Unknown sounding type. Returning.\n");
	         return;
	     }

	     pIndex = getParmIndex("PRES");

	     if (sndg && numlvl > 2) {

	       if (pIndex != -1 && sndg[0][pIndex] > 100.) {

            switch (current_parcel) {
              case 1:
                pres = 0;
              break;
              case 2:
                pres = 0;
              break;
              case 3:
                pres = mu_layer;
              break;
              case 4:
                pres = mml_layer;
              break;
              case 5:
                pres = user_level;
              break;
              case 6:
                pres = mu_layer;
              break;
            }

	         define_parcel(current_parcel, pres);

	         /* First guess at storm motion. User can modify on hodograph */
	         bunkers_storm_motion(&ix1, &ix2, &st_dir, &st_spd);
/* 24 Mar 2008 */
/*		 effective_inflow_layer(100, -250, &p_bot, &p_top);*/

	       }
	       else {
	         st_spd = st_dir = RMISSD;
	       }

                 if (display_mode_left == DISPLAY_WINTER_LEFT) 
                   pagenum = 1;
                 else 
                   pagenum = 1;
		 check_data();
	         draw_skewt();
                 show_parcel();
	         trace_dcape();
		 /* display_mode = DRAW_SKEWT; */
  	         pagenum = 1;
	         draw_hodo();
	         show_page(pagenum);
	       resetuserinput();
	       setsfctimelabel("");
	       hodo_mode == HODO_MEANWIND;

               XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
	       XFlush(XtDisplay(draw_reg));
	       return 0;
 	     }
	}

	hodo_mode == HODO_MEANWIND;

	/* Populate the text window in case it is visible */
	textptr = createtextsounding();
	set_textareatext(textptr);
	free(textptr);
}

/*
Pass -1 to skip configuration of the widget once it's already been created
-1 will just pop it up
*/
void showdatachooser(int dataset)
       /*************************************************************/
{
	Widget    form, rowcol1, rowcol4, button, label;
	Widget    option, maparea, mapform, timeform, workform, visform;
	XmString  str;
	Arg       args[5];
	Dimension w_width;
	char      gemdevice[80];
	int       mapwidth = 900, mapheight = 750, i, iret;

	if (chooser_dialog == NULL) {

	  chooser_dialog = XmCreateBulletinBoardDialog(toplevel, "chooser", NULL, 0);
	  /*
	  For forcing the user to use the dialog
	  XtVaSetValues(chooser_dialog, XmNdialogStyle, XmDIALOG_PRIMARY_APPLICATION_MODAL, NULL);
	  */

	  str = XmStringCreateLocalized("NSHARP: Data Selection");
	  XtVaSetValues(chooser_dialog, XmNdialogTitle, str,
	    NULL);
	  XmStringFree(str);

	  /* Create a form to hold everything */
	  form = XtVaCreateManagedWidget("dataform", xmFormWidgetClass,
	    chooser_dialog, XmNfractionBase, 100, 
	    XmNnoResize,    True, /* Don't allow this dialog to be resized */
	    NULL);

	  /*
	   * Do the stuff at the top related to the data type and stuff
	   */

	  /* Create a rowcol to hold the stuff at the top */
	  rowcol1 = XtVaCreateManagedWidget("datarowcol", 
	    xmRowColumnWidgetClass, form, 
	    XmNorientation,     XmHORIZONTAL, 
	    XmNleftAttachment,  XmATTACH_FORM,
	    XmNrightAttachment, XmATTACH_FORM,
	    XmNtopAttachment,   XmATTACH_FORM,
	    NULL);

	  /* Create stuff in the dialog for choosing data types and files */
          str = XmStringCreateLocalized("Data:");

	  /* Create pulldown to hold our option menu */
	  option_menu = XmCreatePulldownMenu(rowcol1, "opt_menu", NULL, 0);

	  i=0;
	  XtSetArg(args[i], XmNsubMenuId,   option_menu); i++;
	  XtSetArg(args[i], XmNlabelString, str); i++;

	  option = XmCreateOptionMenu(rowcol1, "dataoptions", args, i);

	  /* The types of data available */
	  for (i=0;i<ndatatypes;i++) {
	    button = XtVaCreateManagedWidget(datatype[i].menuname, xmPushButtonGadgetClass, option_menu, NULL);
	    XtAddCallback(button, XmNactivateCallback, datatypechange, (XtPointer)datatype[i].id);
	  }

	  XtManageChild(option);

	  /* Create filename text area */
	  chooser_text = XtVaCreateManagedWidget ("datafile",
	    xmTextFieldWidgetClass, rowcol1, 
	    XmNcolumns, 35, NULL);
	  XtAddCallback(chooser_text, XmNactivateCallback, get_datafile_text, NULL);

	  /* Create a button for changing the file */
	  button = XtVaCreateManagedWidget("Change File", 
	    xmPushButtonWidgetClass, rowcol1, NULL);
	  XtAddCallback(button, XmNactivateCallback, load_datafile, (XtPointer)dataset);

	  /* Done with top area (form) now. */

	  /* Create a form to hold the map stuff as well as the time stuff */
	  workform = XtVaCreateManagedWidget("workform",
	    xmFormWidgetClass,   form,
	    XmNtopAttachment,    XmATTACH_WIDGET,
	    XmNtopWidget,        rowcol1,
	    XmNleftAttachment,   XmATTACH_FORM,
	    XmNrightAttachment,  XmATTACH_FORM, NULL);

	  /* Start on the third area: the map */
	  mapform = XtVaCreateManagedWidget("mapform", 
	    xmFormWidgetClass,   workform,
	    XmNtopAttachment,    XmATTACH_FORM,
	    XmNbottomAttachment, XmATTACH_FORM,
	    XmNrightAttachment,  XmATTACH_FORM,
	    XmNentryAlignment,   XmALIGNMENT_CENTER,
	    XmNfractionBase,     100,
	    NULL);

	  /* create stations label */
	  str = XmStringCreateSimple ("Available Stations");
	  label = XtVaCreateManagedWidget("datastations",
	    xmLabelWidgetClass, mapform, 
	    XmNlabelString,     str, 
	    XmNtopAttachment,   XmATTACH_FORM, 
	    NULL);
	  XmStringFree(str);

	  /* Align our label in the middle of the map */
	  XtVaGetValues(label, XmNwidth, &w_width, NULL);
	  XtVaSetValues(label, XmNx, (mapwidth - w_width)/2, NULL);

	  /* Add map here */
	  maparea = XtVaCreateManagedWidget("datamap",
            xmDrawingAreaWidgetClass, mapform,
	    XmNtopAttachment,         XmATTACH_WIDGET,
	    XmNrightAttachment,       XmATTACH_FORM,
	    XmNtopWidget,             label,
	    XmNwidth,                 mapwidth,
	    XmNheight,                mapheight,
            XmNbackground,            pixels[0],
            NULL);

	  /* Callbacks for map stuff */
	  XtAddCallback(maparea, XmNexposeCallback, (XtCallbackProc)mapw_exposeCb, NULL);
	  plotData.mode = STNSELECT;
	  XtAddEventHandler(maparea, ButtonReleaseMask, FALSE, (XtEventHandler)mapw_pickstnCb, NULL);
	  XtAddCallback(maparea, XmNresizeCallback, (XtCallbackProc)mapw_resizeCb, NULL);

	  /* Create zoom buttons */
	  rowcol4 = XtVaCreateManagedWidget("zoomrc", 
	    xmRowColumnWidgetClass, mapform, 
	    XmNorientation,      XmHORIZONTAL, 
	    XmNtopAttachment,    XmATTACH_WIDGET,
	    XmNtopWidget,        maparea,
	    XmNbottomAttachment, XmATTACH_FORM,
	    XmNleftAttachment,   XmATTACH_POSITION,
	    XmNleftPosition,     30,
	    XmNrightAttachment,  XmATTACH_POSITION,
	    XmNrightPosition,    70,
	    NULL);

	  button = XtVaCreateManagedWidget("Zoom", xmPushButtonWidgetClass, rowcol4, NULL);
	  XtAddCallback(button, XmNactivateCallback, (XtCallbackProc)zoommapwindow, maparea);

	  button = XtVaCreateManagedWidget("Un-Zoom", xmPushButtonWidgetClass, rowcol4, NULL);
	  XtAddCallback(button, XmNactivateCallback, (XtCallbackProc)unzoommapwindow, maparea);

	  button = XtVaCreateManagedWidget("Cancel", xmPushButtonWidgetClass, rowcol4, NULL);
	  XtAddCallback(button, XmNactivateCallback, (XtCallbackProc)cancel_chooser, NULL);

	  /* Done with that section (mapform) now */

	  /* 
	   * Now do the left hand side which includes 
	   * the scrolling list of times and the button
	   * to update the time list
	   */
	  timeform = XtVaCreateManagedWidget("timerc", 
	    xmRowColumnWidgetClass, workform, 
	    XmNtopAttachment,       XmATTACH_FORM,
	    XmNleftAttachment,      XmATTACH_FORM,
	    XmNbottomAttachment,    XmATTACH_FORM,
	    XmNrightAttachment,     XmATTACH_WIDGET,
	    XmNrightWidget,         mapform,
	    XmNentryAlignment,      XmALIGNMENT_CENTER,
	    NULL);

	  /* create time label */
	  str = XmStringCreateLocalized("Times");
	  label = XtVaCreateManagedWidget("datatime",
  	    xmLabelWidgetClass,  timeform,
	    XmNlabelString,      str, 
	    XmNtopAttachment,    XmATTACH_FORM,
	    NULL);
	  XmStringFree(str);

	  /* Create our timelist */
	  chooser_timelist = XmCreateScrolledList(timeform, "datatimes", NULL, 0);
	  XtVaGetValues(maparea, XmNheight, &w_width, NULL);
	  XtVaSetValues(chooser_timelist, XmNheight, w_width, NULL);
/*
	  XtVaSetValues(chooser_timelist, XmNvisibleItemCount, 24, NULL);
*/

	  /* Create a button for updating the list of times */
	  button = XtVaCreateManagedWidget("Update Times", 
	    xmPushButtonWidgetClass, timeform, 
	    XmNbottomAttachment,     XmATTACH_FORM,
	    XmNtopAttachment,        XmATTACH_WIDGET,
	    XmNtopWidget,            chooser_timelist,
	    NULL);
	  XtAddCallback(button, XmNactivateCallback, 
	    (XtCallbackProc)updatetimes, NULL);
/*
	  XtVaSetValues(XtParent(chooser_timelist), 
	    XmNleftAttachment,      XmATTACH_FORM,
	    XmNtopAttachment,       XmATTACH_WIDGET,
	    XmNtopWidget,           label,
	    XmNbottomAttachment,    XmATTACH_FORM,
	    XmNbottomAttachment,    XmATTACH_WIDGET,
	    XmNbottomWidget,        button,
	    NULL);
*/
	  XtManageChild(chooser_timelist);

	  XtAddCallback(chooser_timelist, XmNbrowseSelectionCallback, (XtCallbackProc)timeselected, (XtPointer)dataset);

	  /* Done with that area (timeform) now */

	  /* Along the bottom */
	  visform = XtVaCreateManagedWidget("visform", 
	    xmFormWidgetClass,      form, 
	    XmNleftAttachment,      XmATTACH_FORM,
	    XmNrightAttachment,     XmATTACH_FORM,
	    XmNtopAttachment,       XmATTACH_WIDGET,
	    XmNtopWidget,           workform,
	    XmNbottomAttachment,    XmATTACH_FORM,
	    NULL);

	  button = XtVaCreateManagedWidget("Keep visible on load", xmToggleButtonWidgetClass, visform, NULL);
	  XtAddCallback(button, XmNvalueChangedCallback, (XtCallbackProc)set_chooser_visibleCb, NULL);
	  button = XtVaCreateManagedWidget("Lock station",
                                            xmToggleButtonWidgetClass, visform,
	                                    XmNleftAttachment, XmATTACH_WIDGET,
					    XmNleftWidget, button,
                                            NULL);
	   XtAddCallback(button, XmNvalueChangedCallback, (XtCallbackProc)set_singlestn_modeCb, NULL);

	  /* Done with visform now */

	  /* Manage it so that the next few routines work */
	  XtManageChild(chooser_dialog);

	  /* Register our map w/ GEMPAK */
	  i = mapw_rgstr(maparea); 

	  /* Initialize it */
/*
	  mapinit(&iret, "maptop", strlen("maptop"));
*/
	  mmap_init(&iret);
	  dg_intl(&iret);

	  /* 
	   * Now select it. Go ahead and do it here since this
	   * is the only GEMPAK window we'll be dealing with
	   */
	  strcpy(gemdevice, "maptop");
	  gslwin(gemdevice, &iret, strlen(gemdevice));

	  resetmapinfo(0);
	}

	/*
	 * 
	 * Reconfiguration stuff
	 *
	 * Things to do:
	 *
	 * Change the filename in the text box
	 * Change the patterns and stuff in the search dialog
	 * Change the times in the time list
	 * Clear the map
	 *
	 * Change the selected index in the option menu to reflect the
	 * data type
	 */

	if (dataset != -1)
	  setconfigdatapointer(dataset);

	if (curdatatype_ptr != NULL && dataset != -1) {

	  setsoundingtype(curdatatype_ptr->stype);

	  /* Set XmNuserData for the things */
	  XtVaSetValues(chooser_dialog, XmNuserData, curdatatype_ptr->stype, 
	    NULL);

	  if (curdatatype_ptr->filename[0] != '\0') {
	    int ntimes;

	    /* Set filename */
	    XmTextSetString(chooser_text, curdatatype_ptr->filename);

	    /* Retrieve the times from the file */
	    ntimes = getdatatimes(curdatatype_ptr->filename, 
	      curdatatype_ptr->timelist, curdatatype_ptr->stype);
#ifdef DEBUG_JL
	    fprintf(stderr, "xwvid6.c: getdatatimes 1 ntimes = %d, filename = %s\n", ntimes, curdatatype_ptr->filename);
#endif /* DEBUG_JL */
	    curdatatype_ptr->ntimes = ntimes;

	    configtimelist(curdatatype_ptr->timelist, curdatatype_ptr->ntimes);
	  }

	  /* Draw a blank map */
	  drawdatamap(0, NULL, NULL);

	}

	if (!XtIsManaged(chooser_dialog)) {
	  XtManageChild(chooser_dialog);
	}
}

void cancel_chooser(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	XtUnmanageChild(chooser_dialog);
}

/*
 *
 *   Callback for the text area where the user can type in a data filename
 *
 */

void load_datafile(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
/* JL
	XmString directory_str, pattern_str, title;
JL */
	XmString directory_str, pattern_str;
	int n=0;
	/* We stored the user data in chooser_dialog */
	Widget chooser = XtParent(XtParent(XtParent(w)));

	if (!load_dialog) {
	  load_dialog = XmCreateFileSelectionDialog(toplevel,
	    "datafile", NULL, 0);
	  /* Get rid of Help button */
	  XtUnmanageChild(XmSelectionBoxGetChild(load_dialog, XmDIALOG_HELP_BUTTON));
	  XtAddCallback(load_dialog, XmNokCallback, get_datafile, NULL);
	  XtAddCallback(load_dialog, XmNcancelCallback, (XtCallbackProc)XtUnmanageChild, NULL);
/* JL
	  XmStringFree(title);
JL */
	}

	/* Pass along the data type */
	XtVaGetValues(chooser, XmNuserData, &n, NULL);
	XtVaSetValues(load_dialog, XmNuserData, n, NULL);

	/* Change search dir and pattern for this data type */
	if (curdatatype_ptr != NULL &&
	    curdatatype_ptr->searchpattern[0] != '\0') {

	  char *ptr, bufr[256], bufr2[256];

	  strcpy(bufr, curdatatype_ptr->searchpattern);
	  ptr = strrchr(bufr,'/');
	  if (ptr) {
	    ptr++;
	    strcpy(bufr2, ptr);
	    *ptr = '\0';
	  }

	  directory_str = XmStringCreateLocalized(bufr);
	  pattern_str   = XmStringCreateLocalized(bufr2);
	  XtVaSetValues(load_dialog, XmNdirectory, directory_str, XmNpattern, pattern_str, NULL);

	  XmStringFree(directory_str);
	  XmStringFree(pattern_str);
	}

	XtManageChild(load_dialog);
	XtPopup(XtParent(load_dialog), XtGrabNone);
}

/*
 *
 *   Callback for load_datafile() where the filename is opened and
 *   the times read from it
 *
 */

void get_datafile(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	char *file=NULL, *searchdir, *searchpattern;
	XmFileSelectionBoxCallbackStruct *cbs = (XmFileSelectionBoxCallbackStruct *)call_data;
	int dataset;

	/* Retrieve the string */
	if (!XmStringGetLtoR(cbs->value, XmFONTLIST_DEFAULT_TAG, &file)) {
	  errordialog(w, "No file specified!");
	  return;
	}

	/*
	 * Make sure we have a sane filename and not just a directory path
	 */
	if (file[strlen(file)-1] == '/') {
	  errordialog(w, "No file specified!");
	  return;
	}

	XtVaSetValues(chooser_text, XmNvalue, file, NULL);

	XtVaGetValues(w, XmNuserData, &dataset, NULL);

	/* Pop down the dialog box */
	XtPopdown(XtParent(w));

	if (curdatatype_ptr) {
	  XmStringGetLtoR(cbs->pattern, XmFONTLIST_DEFAULT_TAG, &searchpattern);
	  XmStringGetLtoR(cbs->dir, XmFONTLIST_DEFAULT_TAG, &searchdir);

	  if (!searchdir) {
	    if (searchpattern)
	      strcpy(curdatatype_ptr->searchpattern, searchpattern);
	    else
	      strcpy(curdatatype_ptr->searchpattern, "*");
	  }
	  else {
	    if (searchpattern)
	      sprintf(curdatatype_ptr->searchpattern, "%s%s", searchdir,
	        searchpattern);
	    else
	      sprintf(curdatatype_ptr->searchpattern, "%s", searchpattern);
	  }

	  XtFree(searchpattern);
	  XtFree(searchdir);

	  /* Store things as appropriate depending on the data type */
	  if (file) {
	    int ntimes;

	    strcpy(curdatatype_ptr->filename, file);

	    /* Set filename */
	    XmTextSetString(chooser_text, curdatatype_ptr->filename);

	    /* Retrieve the times from the file */
	    ntimes = getdatatimes(curdatatype_ptr->filename, 
	      curdatatype_ptr->timelist, curdatatype_ptr->stype);
#ifdef DEBUG_JL
	    fprintf(stderr, "xwvid6.c: getdatatimes 2 ntimes = %d\n", ntimes);
#endif /* DEBUG_JL */
	    curdatatype_ptr->ntimes = ntimes;

	    configtimelist(curdatatype_ptr->timelist, curdatatype_ptr->ntimes);

	    /* Draw a blank map */
	    drawdatamap(0, NULL, NULL);
	  }
	}

	/* Need to free file */
	XtFree(file);
}

/*
 * Callback for the option menu which selects the data set to view
 *
 * When a change in data type is made this gets called. In turn, we call
 * showdatachooser which is already open and just reconfigure it
 */
void datatypechange(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	int stype = (int)client_data;
	showdatachooser(stype);
}

void get_datafile_text(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	char *file = (char *)XmTextFieldGetString(w);
	int  ntimes;

	if (curdatatype_ptr != NULL) {

	  ntimes = getdatatimes(file, curdatatype_ptr->timelist, curdatatype_ptr->stype);
#ifdef DEBUG_JL
	  fprintf(stderr, "xwvid6.c: getdatatimes 3 ntimes = %d\n", ntimes);
#endif /* DEBUG_JL */
	  curdatatype_ptr->ntimes = ntimes;
	  strcpy(curdatatype_ptr->filename, file);

	  configtimelist(curdatatype_ptr->timelist, curdatatype_ptr->ntimes);
	}

	XtFree(file);
}

void updatetimes(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	int  ntimes, iret;

	if (curdatatype_ptr != NULL) {
	  curdatatype_ptr->time[0] = '\0';

	  ntimes = getdatatimes(curdatatype_ptr->filename, curdatatype_ptr->timelist, curdatatype_ptr->stype);
#ifdef DEBUG_JL
	  fprintf(stderr, "xwvid6.c: getdatatimes 4 ntimes = %d\n", ntimes);
#endif /* DEBUG_JL */
	  curdatatype_ptr->ntimes = ntimes;
	  configtimelist(curdatatype_ptr->timelist, curdatatype_ptr->ntimes);
          drawmap(0, map_info, 0, &mapBnd, &iret);
	}
}

/*
 * Routine to read the list of times in the data file
 */
int getdatatimes(char *file, char times[][16], int stype)
       /*************************************************************/
{
	int i=0, len=0, ntimes=0, iret=0;

	/* Get list of times from the file */
	/* If we are dealing with model data the strings have an
	   additional FXXX tacked onto the end that we need 
	   that's the purpose of len */

	if (stype == NSHARP_OBS || stype == NSHARP_PFC) {
	  get_gem_times(file, times, &ntimes, &iret, strlen(file));
	  if (iret != 0) {
	    fprintf(stderr,"Bad file: %s\n", file);
	    return 0;
	  }
	  len = 11;   /* Len refers to where to add the '\0' */
	}
	else if (stype == NSHARP_MDL) {
	  get_mdl_times(file, times, &ntimes, strlen(file));
	  len = 15;
	}
#ifdef DEBUG_JL
	fprintf(stderr, "xwvid6.c: ntimes = %d\n", ntimes);
#endif /* DEBUG_JL */
	if (ntimes < 0 || ntimes > LLMXGT) {
	  fprintf(stderr, "xwvid6.c: SOMETHING WRONG with ntimes = %d\n", ntimes);
	  ntimes = LLMXGT;
	}

	/* Add NULL's onto the ends of the strings */
	for (i = 0; i < ntimes; i++) {
	  times[i][len] = '\0';
	}

	return (iret < 0 || ntimes < 0) ? 0 : ntimes;
}

/*
 * Simple routine to configure our timelist
 */
void configtimelist(char times[][16], int ntimes)
       /*************************************************************/
{
	XmStringTable str_list;
	int i;

	if (ntimes > 0) {
	  str_list = (XmStringTable)XtMalloc(ntimes*sizeof(XmString *));
	  for (i=ntimes-1; i >= 0 ; i--) {
	    str_list[i] = XmStringCreateLocalized(times[i]);
	  }
	  XtVaSetValues(chooser_timelist,
	    XmNitemCount, ntimes,
	    XmNitems,     str_list,
	    NULL);

	  /* Deselect all times */
	  XmListDeselectAllItems(chooser_timelist);

	  for (i=0; i<ntimes; i++)
	    XmStringFree((XmString)str_list[i]);
	  XtFree((char *)str_list);
	}
	else {
	  /* Clear it out */
	  XtVaSetValues(chooser_timelist,
	    XmNitemCount, 0, NULL);
	}
}

void timeselected(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	/* User selected a time */
	XmListCallbackStruct *cbs = (XmListCallbackStruct *)call_data;
	char *choice;

	XmStringGetLtoR(cbs->item, XmFONTLIST_DEFAULT_TAG, &choice);
	curdatatype_ptr->timeptr = cbs->item_position;

	if (curdatatype_ptr != NULL) {
	  if (set_singlestn_mode) {
	    strcpy(curdatatype_ptr->time, choice);  
	    load_sounding(curdatatype_ptr->stype);
	  }
	  else {
	    strcpy(curdatatype_ptr->time, choice);  
	    curdatatype_ptr->timeptr = cbs->item_position;
	    Load_stationlist(0);
	  }
	}
	XtFree(choice);
}

/*
Broken right now. only use index 0 due to difficulties with
the zoom callback only knowing about index 0
*/
void resetmapinfo(int index)
       /*************************************************************/
{
	if (index >= ndatatypes || index < 0) return;

	index = 0;

	/* Bounds for the US */
/*
	strcpy(map_info[index].name,  "US");
	strcpy(map_info[index].proj, "STR/90;-105;0/nm");
	strcpy(map_info[index].garea, "22.88;-120.49;46.02;-60.83");
	mapBnd.x[0] = 22.88;   mapBnd.x[1]=46.02;
	mapBnd.y[0] = -120.49; mapBnd.y[1]=-60.83;
*/

	/* See Mexican stations and Canadian as well as the US */
	strcpy(map_info[0].name,  "US");
	strcpy(map_info[0].proj,  "STR/90;-105;0/nm");
	strcpy(map_info[0].garea, "13.10;-124.6;43.10;-46.70");
	mapBnd.x[0] =   13.1;  mapBnd.x[1]= 43.1;
	mapBnd.y[0] = -124.6;  mapBnd.y[1]=-46.7;

}

void drawdatamap(int nsta, float *sta_lat, float *sta_lon)
       /*************************************************************/
{
	int		ncolor, mrktyp, mrkwid, pltval, iposn, jcolr;
	int		iret, mapindx=0;
	float		sizmrk;

	ncolor    = 1;
	mrktyp    = 6;
	sizmrk    = 0.5;
	mrkwid    = 2;
	pltval    = G_FALSE;
	iposn     = 0;
	jcolr     = 2;

	/* Draw map */
        drawmap(mapindx, map_info, 0, &mapBnd, &iret);

	if (nsta > 0 && sta_lat && sta_lon) {
	  /* Draw markers */
	  mapmark(&nsta, sta_lat, sta_lon, NULL, &ncolor, NULL,
	          &jcolr, &mrktyp, &sizmrk, &mrkwid, &pltval,
		  &iposn, &iret);
	}
}

Widget GetTopShell(Widget w)
       /*************************************************************/
{
        while (w && !XtIsWMShell(w)) w = XtParent(w);
        return w;
}

void errordialog(Widget parent, char *msg)
       /*************************************************************/
{
	Widget dialog;
	Arg arg[2];
	int n=0;
	XmString message;

	message = XmStringCreateLocalized(msg);
	XtSetArg(arg[n], XmNmessageString, message); n++;
	dialog = XmCreateErrorDialog(parent, "error", arg, n);
	XmStringFree(message);

	XtAddCallback(dialog, XmNokCallback, dialog_delete, NULL);

	/* Get rid of these buttons */
	XtUnmanageChild(XmMessageBoxGetChild(dialog, XmDIALOG_HELP_BUTTON));
	XtUnmanageChild(XmMessageBoxGetChild(dialog, XmDIALOG_CANCEL_BUTTON));

	XtVaSetValues(dialog, XmNdialogStyle, 
	  XmDIALOG_PRIMARY_APPLICATION_MODAL, NULL);

	XtManageChild(dialog);
/*
	XtPopup(XtParent(dialog), XtGrabNone);
*/
	XtPopup(XtParent(dialog), XtGrabExclusive);
}

void dialog_delete(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	XtPopdown(XtParent(w));
	XtDestroyWidget(w);
}

void save_giffile(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	Widget child;
	char *ptr, bufr[256];

	if (!savegif_dialog) {
	  savegif_dialog = XmCreateFileSelectionDialog(toplevel,
	    "giffile", NULL, 0);
	  /* Get rid of Help button */
	  XtUnmanageChild(XmSelectionBoxGetChild(savegif_dialog, XmDIALOG_HELP_BUTTON));
	  XtAddCallback(savegif_dialog, XmNokCallback, get_giffile, NULL);
	  XtAddCallback(savegif_dialog, XmNcancelCallback, (XtCallbackProc)XtUnmanageChild, NULL);

	  child = XmFileSelectionBoxGetChild(savegif_dialog, XmDIALOG_TEXT);
	  XtVaGetValues(child, XmNvalue, &ptr, NULL);

	  bufr[0] = '\0';

/*
	  if (ptr && *ptr) {
	    strcpy(bufr, ptr);
	    XtFree(ptr);

	    ptr = strrchr(bufr,'/');
	    if (ptr) {
	      ptr++;
	      *ptr = '\0';
	    }
	  }
	  strcat(bufr,"Nimage.gif");

	  XtVaSetValues(child, XmNvalue, bufr, NULL);
*/

	}

	XtManageChild(savegif_dialog);
	XtPopup(XtParent(savegif_dialog), XtGrabNone);
}

void get_giffile(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	int i;
	char *file=NULL;
	XmFileSelectionBoxCallbackStruct *cbs =
	  (XmFileSelectionBoxCallbackStruct *)call_data;

	/* Retrieve the string */
	if (!XmStringGetLtoR(cbs->value, XmFONTLIST_DEFAULT_TAG, &file)) {
	  errordialog(w, "No file specified!");
	  return;
	}

	/* Pop down the dialog box */
	XtPopdown(XtParent(w));

	/*
	 * Make sure we have a sane filename and not just a directory path
	 */
	if (file[strlen(file)-1] == '/') {
	  errordialog(w, "No file specified!");
	}
	else {
	  i = save_gif(file);
	  if (i == 1) {
	    errordialog(w, "Unable to properly write GIF image.");
	  }
	}

	/* Need to free file */
	XtFree(file);
}

void swap_sounding(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
        short i,j;
        float pres=RMISSD, tempval, ix1, ix2;
	char bufr[80];
	Sounding *cursndg=NULL, *prevsndg=NULL;
	HistElmt *he_top;
	void *top_data, *next_data;

	/* Get current top */
	he_top = history_first(&hist);
	if (!he_top)
	  return;
	history_remove(&hist, he_top, &top_data);

	/* Now we have a new top */
	he_top = history_first(&hist);
	history_remove(&hist, he_top, &next_data);

	/* Now add them back in the opposite order */
	history_add(&hist, top_data);
	history_add(&hist, next_data);

	cursndg  = (Sounding *)top_data;
	prevsndg = (Sounding *)next_data;
	if (!prevsndg)
	  return;

	changeGlobalSounding(prevsndg);

	strcpy(bufr, raobtitle2);
	strcpy(raobtitle2, raobtitle);
	strcpy(raobtitle, bufr);
	strcpy(bufr, raob_type);
	strcpy(raob_type2, raob_type);
	strcpy(raob_type, bufr);

	bunkers_storm_motion(&ix1, &ix2, &st_dir, &st_spd);

/* 24 Mar 2008 */
/*        effective_inflow_layer(100, -250, &p_bot, &p_top);*/

	if (drawing_mode == DRAW_SKEWT) {
	  draw_skewt();
	  if (numlvl > 0) {
	    switch (current_parcel) {
              case 1:
                pres = 0;
              break;
              case 2:
                pres = 0;
	      break;
	      case 3:
	        pres = mu_layer;
	      break;
	      case 4:
	        pres = mml_layer;
	      break;
	      case 5:
	        pres = user_level;
	      break;
	      case 6:
		pres = mu_layer;
	      break;		
	    }
	    if (qc(pres)) {
	      define_parcel(current_parcel, pres);
	      show_parcel();
	      trace_dcape();
	      setdcape_entrain(0.9);
	      trace_dcape();
	      setdcape_entrain(0.0);
/*              bunkers_storm_motion(&ix1, &ix2, &st_dir, &st_spd);	  
*/ 	      draw_hodo();		
	    }
	  }
	}
	else
	  draw_hodo();

	show_page(pagenum);
}

Widget make_status_bar(Widget parent)
       /*************************************************************/
{
	Widget   form, frame, label;
	XmString str = XmStringCreateLocalized("");

	/* Do I need a form here too? Maybe. */

	form = XtVaCreateManagedWidget("sform", xmFormWidgetClass, parent,
	         NULL);

	frame = XtVaCreateManagedWidget("status", xmFrameWidgetClass, form,
	          XmNshadowType, XmSHADOW_IN, 
	          XmNtopAttachment, XmATTACH_FORM,
	          XmNbottomAttachment, XmATTACH_FORM,
	          XmNleftAttachment, XmATTACH_FORM,
	          XmNrightAttachment, XmATTACH_FORM,
	          NULL);

	label = XtVaCreateManagedWidget("status_text", xmLabelWidgetClass,
	          frame, XmNlabelString, str, NULL);

	XmStringFree(str);	

	return form;
}

void set_status_text(Widget status_bar, char *text)
       /*************************************************************/
{
	Widget   label = XtNameToWidget(status_bar, "*status_text");
	XmString str;

	if (!label)
	  return;

	str = XmStringCreateLocalized(text);

	XtVaSetValues(label, XmNlabelString, str, 
	  XmNalignment, XmALIGNMENT_BEGINNING, NULL);

	XmStringFree(str);
}

void set_chooser_visibleCb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	XmToggleButtonCallbackStruct *toggle_data = 
	  (XmToggleButtonCallbackStruct *)call_data;

	/* Set global variable */
	set_chooser_visible = toggle_data->set;
}

void set_singlestn_modeCb(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	XmToggleButtonCallbackStruct *toggle_data = 
	  (XmToggleButtonCallbackStruct *)call_data;

	/* Set global variable */
	set_singlestn_mode = toggle_data->set;
}





void bmj_process(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	pid_t pid;
	write_scheme_file("BMJ");
	pid = fork();
	if (pid == 0) execl("/users/spcbeta/conv_scheme/run_cnvct_scheme_BMJ.csh", "run_cnvct_scheme_BMJ.csh", 0);
/*	printf( "BMJ Routine was called!!!\n" ); */
}




void kf_process(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
	pid_t pid;
	write_scheme_file("KF");
	pid = fork();
	if (pid == 0) execl("/users/spcbeta/conv_scheme/run_cnvct_scheme_KF.csh", "run_cnvct_scheme_KF.csh", 0);
/*      printf( "KF Routine was called!!!\n" ); */
}




void hail_process(Widget w, XtPointer client_data, XtPointer call_data)
       /*************************************************************/
{
        pid_t pid;
        float hvars[30], h2[100];
        float pres, ix1, ix2, ix3, ix4 , mumixr, esicat;
        float T0, Td0, el, pbot, ptop, base, depth, effdep, ebs;
        short tIndex, tdIndex, pIndex, i;
        Parcel pcl;

        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_HAIL_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_HAIL_RIGHT;}

	tIndex = getParmIndex("TEMP");
	tdIndex = getParmIndex("DWPT");
	pIndex = getParmIndex("PRES");

	/* Create output file with sounding information */
        write_hail_file("HAIL");

	for (i=0;i<100;i++) {
	  h2[i] = 0.0;
	}
	for (i=0;i<30;i++) {
	  hvars[i] = 0.0;
	}

        /* Compute Effective Vertical Shear.  Default to 6km if not available */
        ix1 = parcel( -1, -1, lplvals.pres, lplvals.temp, lplvals.dwpt, &pcl);

        pbot = sndg[sfc()][pIndex];
        el = 12000.0;
        if (pcl.bplus > 100) {
                el = agl(i_hght(pcl.elpres, I_PRES));
/* 24 Mar 2008 */
/*                effective_inflow_layer(100, -250, &pbot, &ptop); */

                }

/*        base = agl(i_hght(pbot, I_PRES));*/
	base = agl(i_hght(p_bot, I_PRES));
        depth = (el - base);
        effdep = base + (depth * 0.5);
        wind_shear(pbot, i_pres(msl(effdep)), &ix1, &ix2, &ix3, &ix4);
        ebs = kt_to_mps(ix4)/effdep;

/*        printf("Shear = %.1f kt    %.1f mps\nEBS = %.6f\nDepth = %.1f m\n", ix4, kt_to_mps(ix4), ebs, effdep);*/

	/* Call Original hail model */

/*	11/28/07 REJ */
/*      T0 = sndg[sfc()][tIndex];
        Td0 = sndg[sfc()][tdIndex];
        hailcast1(&T0, &Td0, &hvars);
*/

	T0 = sndg[sfc()][tIndex];
	mumixr = mixratio(lplvals.pres, lplvals.dwpt);
        Td0 = sndg[sfc()][tdIndex];
	hailcast1(&T0, &Td0, &ebs, &hvars, &mumixr, &esicat);

	/* Copy results to big array */
	h2[0]=1;	/* Original hail model has been run */
	h2[1]=0;	/* New model has not yet been run */
	for (i=0;i<=30;i++) 
		{
		/*printf( "HVARS[%d] = %f\n", i, hvars[i]); */ 
		h2[i+2] = hvars[i]; 
		}

	show_hail_new(&h2);

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}

/*	RLT attempt to make STP Stats button */
void stp_process(Widget w, XtPointer client_data, XtPointer call_data)
       
{
	float pres;

       if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_STP_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_STP_RIGHT;}

	show_stp_stats();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));


/*        pid_t pid;
        write_scheme_file("KF");
        pid = fork();
        if (pid == 0) execl("/users/spcbeta/conv_scheme/run_cnvct_scheme_KF.csh", "run_cnvct_scheme_KF.csh", 0);
        printf( "KF Routine was called!!!\n" );
*/
}

/*      RLT attempt to make SHIP Stats button */
void ship_process(Widget w, XtPointer client_data, XtPointer call_data)

{
	float pres;

        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_SHIP_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_SHIP_RIGHT;}

        show_ship_stats();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}

/*      RLT attempt to make EBS Stats button */

void ebs_process(Widget w, XtPointer client_data, XtPointer call_data)
  
{ 
	float pres;

        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_EBS_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_EBS_RIGHT;}

        show_ebs_stats();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}

	/* added 25OCT06 by RLT */
/*      RLT attempt to make SARS button */

void sars_process(Widget w, XtPointer client_data, XtPointer call_data)

{
	float pres;

        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_SARS_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_SARS_RIGHT;}

        show_sars();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}

        /* added 25OCT06 by RLT */
/*      RLT attempt to make WINTER button */

void winter_process(Widget w, XtPointer client_data, XtPointer call_data)

{
	float pres;
	
        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_WINTER_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_WINTER_RIGHT;}

        show_winter_new();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}

void fire_process(Widget w, XtPointer client_data, XtPointer call_data)

{
	float pres;

        if (inset_mode == DISPLAY_LEFT)
                {display_mode_left = DISPLAY_FIRE_LEFT;}
        if (inset_mode == DISPLAY_RIGHT)
                {display_mode_right = DISPLAY_FIRE_RIGHT;}

        show_fire();

            switch (current_parcel) {
              case 1:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 2:
                pres = 0;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 3:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 4:
                pres = mml_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 5:
                pres = user_level;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
              case 6:
                pres = mu_layer;
                define_parcel(current_parcel, pres);
                redraw_graph(drawing_mode);
              break;
            }

        XCopyArea(XtDisplay(draw_reg), canvas, XtWindow(draw_reg), gc, 0, 0, xwdth, xhght, 0, 0);
        XFlush(XtDisplay(draw_reg));
}



        /*NP*/
void keyboard_press(Widget w, XtPointer *call_data, XEvent *event)
/*************************************************************/
/* KEYBOARD HANDLER                                          */
/*************************************************************/
{
	KeySym keysym;
	char cbuf[32];
	int nc;
	if (event->type == KeyPress)
		{ 
		nc = XLookupString((XKeyEvent*)(event), cbuf, sizeof(cbuf)-1, &keysym, 0);	
		if (keysym == XK_equal) AdvanceFrame();
		if (keysym == XK_minus) BackFrame();
        	XFlush(XtDisplay(draw_reg));
		}
}
