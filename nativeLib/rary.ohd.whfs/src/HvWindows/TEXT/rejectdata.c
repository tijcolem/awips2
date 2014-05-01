/*
** Generated by X-Designer
*/
/*
**LIBS: -lXm -lXt -lX11
*/

#include <X11/Xatom.h>
#include <X11/Intrinsic.h>
#include <X11/Shell.h>

#include <Xm/Xm.h>
#include <Xm/DialogS.h>
#include <Xm/Form.h>
#include <Xm/Frame.h>
#include <Xm/Label.h>
#include <Xm/List.h>
#include <Xm/PushB.h>
#include <Xm/RowColumn.h>
#include <Xm/ScrollBar.h>
#include <Xm/TextF.h>
#include <Xm/CascadeBG.h>
#include <Xm/LabelG.h>
#include <Xm/ToggleBG.h>


void* group0_data [1];

void* group1_data [1];

Widget trashDS = (Widget) NULL;
Widget trashFO = (Widget) NULL;
Widget trash_filterFR = (Widget) NULL;
Widget trash_filterFO = (Widget) NULL;
Widget trash_locationTE = (Widget) NULL;
Widget trash_peSL = (Widget) NULL;
Widget trash_peHSB = (Widget) NULL;
Widget trash_peVSB = (Widget) NULL;
Widget trash_peLS = (Widget) NULL;
Widget trash_filter_locTB = (Widget) NULL;
Widget trash_filter_peTB = (Widget) NULL;
Widget trash_filterbyLA = (Widget) NULL;
Widget trash_sortMPM = (Widget) NULL;
Widget trash_sortLA = (Widget) NULL;
Widget trash_sortOB = (Widget) NULL;
Widget trash_sortPM = (Widget) NULL;
Widget trash_sort_locPB = (Widget) NULL;
Widget trash_sort_recentPB = (Widget) NULL;
Widget trash_rejtypeMPM = (Widget) NULL;
Widget trash_rejtypeLA = (Widget) NULL;
Widget trash_rejtypeOB = (Widget) NULL;
Widget trash_rejtypePM = (Widget) NULL;
Widget trash_rejtype_allPB = (Widget) NULL;
Widget trash_rejtype_autoPB = (Widget) NULL;
Widget trash_rejtype_manPB = (Widget) NULL;
Widget trash_headerLA = (Widget) NULL;
Widget trash_dataSL = (Widget) NULL;
Widget trash_dataHSB = (Widget) NULL;
Widget trash_dataVSB = (Widget) NULL;
Widget trash_dataLS = (Widget) NULL;
Widget trash_closePB = (Widget) NULL;
Widget trash_repostPB = (Widget) NULL;
Widget trash_deletePB = (Widget) NULL;
Widget trash_emptyPB = (Widget) NULL;



void create_trashDS (parent)
Widget parent;
{
	Widget children[7];      /* Children to manage */
	Arg al[64];                    /* Arg List */
	register int ac = 0;           /* Arg Count */
	XmString xmstrings[16];    /* temporary storage for XmStrings */

	XtSetArg(al[ac], XmNx, 834); ac++;
	XtSetArg(al[ac], XmNwidth, 1220); ac++;
	XtSetArg(al[ac], XmNallowShellResize, FALSE); ac++;
	XtSetArg(al[ac], XmNtitle, "Data Trash Can"); ac++;
	XtSetArg(al[ac], XmNminWidth, 1220); ac++;
	XtSetArg(al[ac], XmNminHeight, 530); ac++;
	XtSetArg(al[ac], XmNmaxWidth, 1220); ac++;
	XtSetArg(al[ac], XmNmaxHeight, 530); ac++;
	XtSetArg(al[ac], XmNbaseWidth, 1150); ac++;
	XtSetArg(al[ac], XmNbaseHeight, 530); ac++;
	XtSetArg(al[ac], XmNaudibleWarning, XmNONE); ac++;
	trashDS = XmCreateDialogShell ( parent, "trashDS", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNx, 834); ac++;
	XtSetArg(al[ac], XmNnoResize, TRUE); ac++;
	XtSetArg(al[ac], XmNautoUnmanage, FALSE); ac++;
	trashFO = XmCreateForm ( trashDS, "trashFO", al, ac );
	ac = 0;
	trash_filterFR = XmCreateFrame ( trashFO, "trash_filterFR", al, ac );
	trash_filterFO = XmCreateForm ( trash_filterFR, "trash_filterFO", al, ac );
	XtSetArg(al[ac], XmNmaxLength, 8); ac++;
	XtSetArg(al[ac], XmNcolumns, 10); ac++;
	trash_locationTE = XmCreateTextField ( trash_filterFO, "trash_locationTE", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNlistMarginWidth, 0); ac++;
	XtSetArg(al[ac], XmNvisibleItemCount, 3); ac++;
	XtSetArg(al[ac], XmNselectionPolicy, XmMULTIPLE_SELECT); ac++;
	XtSetArg(al[ac], XmNlistSizePolicy, XmCONSTANT); ac++;
	trash_peLS = XmCreateScrolledList ( trash_filterFO, "trash_peLS", al, ac );
	ac = 0;
	trash_peSL = XtParent ( trash_peLS );

	XtSetArg(al[ac], XmNhorizontalScrollBar, &trash_peHSB); ac++;
	XtSetArg(al[ac], XmNverticalScrollBar, &trash_peVSB); ac++;
	XtGetValues(trash_peSL, al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNlistMarginWidth, 0); ac++;
	XtSetArg(al[ac], XmNvisibleItemCount, 3); ac++;
	XtSetArg(al[ac], XmNselectionPolicy, XmMULTIPLE_SELECT); ac++;
	XtSetArg(al[ac], XmNlistSizePolicy, XmCONSTANT); ac++;
	XtSetValues ( trash_peLS,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNscrolledWindowMarginHeight, 10); ac++;
	XtSetArg(al[ac], XmNscrolledWindowMarginWidth, 5); ac++;
	XtSetArg(al[ac], XmNspacing, 0); ac++;
	XtSetValues ( trash_peSL,al, ac );
	ac = 0;
	xmstrings[0] = XmStringCreateLtoR ( "Location:", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_BEGINNING); ac++;
	trash_filter_locTB = XmCreateToggleButtonGadget ( trash_filterFO, "trash_filter_locTB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Phys. Element:", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_BEGINNING); ac++;
	trash_filter_peTB = XmCreateToggleButtonGadget ( trash_filterFO, "trash_filter_peTB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Filter By:", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	trash_filterbyLA = XmCreateLabel ( trash_filterFO, "trash_filterbyLA", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	XtSetArg(al[ac], XmNwidth, 294); ac++;
	XtSetArg(al[ac], XmNheight, 35); ac++;
	XtSetArg(al[ac], XmNorientation, XmHORIZONTAL); ac++;
	XtSetArg(al[ac], XmNentryAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNisAligned, TRUE); ac++;
	XtSetArg(al[ac], XmNresizeHeight, TRUE); ac++;
	XtSetArg(al[ac], XmNresizeWidth, TRUE); ac++;
	xmstrings[0] = XmStringCreateLtoR("Sort By:", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG);
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	trash_sortMPM = XmCreateOptionMenu ( trash_filterFO, "trash_sortMPM", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	trash_sortLA = XmOptionLabelGadget ( trash_sortMPM );
	trash_sortOB = XmOptionButtonGadget ( trash_sortMPM );
	XtSetArg(al[ac], XmNx, 3); ac++;
	XtSetArg(al[ac], XmNy, 3); ac++;
	XtSetArg(al[ac], XmNwidth, 50); ac++;
	XtSetArg(al[ac], XmNheight, 28); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	XtSetValues ( trash_sortLA,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNorientation, XmVERTICAL); ac++;
	XtSetArg(al[ac], XmNentryAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNentryVerticalAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNresizeHeight, TRUE); ac++;
	XtSetArg(al[ac], XmNresizeWidth, TRUE); ac++;
	trash_sortPM = XmCreatePulldownMenu ( trash_sortMPM, "trash_sortPM", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNwidth, 130); ac++;
	XtSetArg(al[ac], XmNheight, 25); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "Location", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_sort_locPB = XmCreatePushButton ( trash_sortPM, "trash_sort_locPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Time", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_sort_recentPB = XmCreatePushButton ( trash_sortPM, "trash_sort_recentPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	XtSetArg(al[ac], XmNx, 56); ac++;
	XtSetArg(al[ac], XmNy, 3); ac++;
	XtSetArg(al[ac], XmNwidth, 166); ac++;
	XtSetArg(al[ac], XmNheight, 28); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, TRUE); ac++;
	XtSetValues ( trash_sortOB,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNorientation, XmHORIZONTAL); ac++;
	XtSetArg(al[ac], XmNentryAlignment, XmALIGNMENT_END); ac++;
	XtSetArg(al[ac], XmNentryVerticalAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNresizeHeight, TRUE); ac++;
	XtSetArg(al[ac], XmNresizeWidth, TRUE); ac++;
	xmstrings[0] = XmStringCreateLtoR("Reject Type:", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG);
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	trash_rejtypeMPM = XmCreateOptionMenu ( trash_filterFO, "trash_rejtypeMPM", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	group0_data [0] = (void*)trash_rejtypeMPM;
	group1_data [0] = (void*)trash_rejtypeMPM;
	trash_rejtypeLA = XmOptionLabelGadget ( trash_rejtypeMPM );
	trash_rejtypeOB = XmOptionButtonGadget ( trash_rejtypeMPM );
	XtSetArg(al[ac], XmNwidth, 97); ac++;
	XtSetArg(al[ac], XmNheight, 27); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	XtSetValues ( trash_rejtypeLA,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNorientation, XmVERTICAL); ac++;
	XtSetArg(al[ac], XmNentryAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNentryVerticalAlignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNresizeHeight, TRUE); ac++;
	XtSetArg(al[ac], XmNresizeWidth, TRUE); ac++;
	trash_rejtypePM = XmCreatePulldownMenu ( trash_rejtypeMPM, "trash_rejtypePM", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNwidth, 137); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "All", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_rejtype_allPB = XmCreatePushButton ( trash_rejtypePM, "trash_rejtype_allPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	XtSetArg(al[ac], XmNwidth, 137); ac++;
	XtSetArg(al[ac], XmNheight, 22); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "Auto", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_rejtype_autoPB = XmCreatePushButton ( trash_rejtypePM, "trash_rejtype_autoPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	XtSetArg(al[ac], XmNwidth, 137); ac++;
	XtSetArg(al[ac], XmNheight, 22); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "Manual", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_rejtype_manPB = XmCreatePushButton ( trash_rejtypePM, "trash_rejtype_manPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	XtSetArg(al[ac], XmNwidth, 157); ac++;
	XtSetArg(al[ac], XmNheight, 26); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_CENTER); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, TRUE); ac++;
	XtSetValues ( trash_rejtypeOB,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNwidth, 1220); ac++;
	XtSetArg(al[ac], XmNalignment, XmALIGNMENT_BEGINNING); ac++;
	trash_headerLA = XmCreateLabel ( trashFO, "trash_headerLA", al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNselectionPolicy, XmEXTENDED_SELECT); ac++;
	XtSetArg(al[ac], XmNlistSizePolicy, XmRESIZE_IF_POSSIBLE); ac++;
	trash_dataLS = XmCreateScrolledList ( trashFO, "trash_dataLS", al, ac );
	ac = 0;
	trash_dataSL = XtParent ( trash_dataLS );

	XtSetArg(al[ac], XmNhorizontalScrollBar, &trash_dataHSB); ac++;
	XtSetArg(al[ac], XmNverticalScrollBar, &trash_dataVSB); ac++;
	XtGetValues(trash_dataSL, al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNselectionPolicy, XmEXTENDED_SELECT); ac++;
	XtSetArg(al[ac], XmNlistSizePolicy, XmRESIZE_IF_POSSIBLE); ac++;
	XtSetValues ( trash_dataLS,al, ac );
	ac = 0;
	XtSetArg(al[ac], XmNwidth, 85); ac++;
	XtSetArg(al[ac], XmNheight, 35); ac++;
	xmstrings[0] = XmStringCreateLtoR ( "Close", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_closePB = XmCreatePushButton ( trashFO, "trash_closePB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Move Selected to Data Tables", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_repostPB = XmCreatePushButton ( trashFO, "trash_repostPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Delete Selected", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_deletePB = XmCreatePushButton ( trashFO, "trash_deletePB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );
	xmstrings[0] = XmStringCreateLtoR ( "Delete All", (XmStringCharSet)XmFONTLIST_DEFAULT_TAG );
	XtSetArg(al[ac], XmNlabelString, xmstrings[0]); ac++;
	XtSetArg(al[ac], XmNrecomputeSize, FALSE); ac++;
	trash_emptyPB = XmCreatePushButton ( trashFO, "trash_emptyPB", al, ac );
	ac = 0;
	XmStringFree ( xmstrings [ 0 ] );


	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -110); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 5); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 5); ac++;
	XtSetValues ( trash_filterFR,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 110); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -135); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 5); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 5); ac++;
	XtSetValues ( trash_headerLA,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 135); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, 40); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 5); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, 5); ac++;
	XtSetValues ( trash_dataSL,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 492); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -524); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 928); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -1032); ac++;
	XtSetValues ( trash_closePB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 496); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -524); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 4); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -244); ac++;
	XtSetValues ( trash_repostPB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 496); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -524); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 336); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -488); ac++;
	XtSetValues ( trash_deletePB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 496); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -524); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 640); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -760); ac++;
	XtSetValues ( trash_emptyPB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -40); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 175); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -280); ac++;
	XtSetValues ( trash_locationTE,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 0); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -100); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 430); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -675); ac++;
	XtSetValues ( trash_peSL,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -40); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 75); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -175); ac++;
	XtSetValues ( trash_filter_locTB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -40); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 280); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -430); ac++;
	XtSetValues ( trash_filter_peTB,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -40); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 5); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -70); ac++;
	XtSetValues ( trash_filterbyLA,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 5); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNbottomOffset, -39); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 680); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_OPPOSITE_FORM); ac++;
	XtSetArg(al[ac], XmNrightOffset, -931); ac++;
	XtSetValues ( trash_sortMPM,al, ac );
	ac = 0;

	XtSetArg(al[ac], XmNtopAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNtopOffset, 50); ac++;
	XtSetArg(al[ac], XmNbottomAttachment, XmATTACH_NONE); ac++;
	XtSetArg(al[ac], XmNleftAttachment, XmATTACH_FORM); ac++;
	XtSetArg(al[ac], XmNleftOffset, 70); ac++;
	XtSetArg(al[ac], XmNrightAttachment, XmATTACH_NONE); ac++;
	XtSetValues ( trash_rejtypeMPM,al, ac );
	ac = 0;
	XtManageChild(trash_peLS);
	children[ac++] = trash_sort_locPB;
	children[ac++] = trash_sort_recentPB;
	XtManageChildren(children, ac);
	ac = 0;
	XtSetArg(al[ac], XmNsubMenuId, trash_sortPM); ac++;
	XtSetValues(trash_sortOB, al, ac );
	ac = 0;
	children[ac++] = trash_rejtype_allPB;
	children[ac++] = trash_rejtype_autoPB;
	children[ac++] = trash_rejtype_manPB;
	XtManageChildren(children, ac);
	ac = 0;
	XtSetArg(al[ac], XmNsubMenuId, trash_rejtypePM); ac++;
	XtSetValues(trash_rejtypeOB, al, ac );
	ac = 0;
	children[ac++] = trash_locationTE;
	children[ac++] = trash_filter_locTB;
	children[ac++] = trash_filter_peTB;
	children[ac++] = trash_filterbyLA;
	children[ac++] = trash_sortMPM;
	children[ac++] = trash_rejtypeMPM;
	XtManageChildren(children, ac);
	ac = 0;
	children[ac++] = trash_filterFO;
	XtManageChildren(children, ac);
	ac = 0;
	XtManageChild(trash_dataLS);
	children[ac++] = trash_filterFR;
	children[ac++] = trash_headerLA;
	children[ac++] = trash_closePB;
	children[ac++] = trash_repostPB;
	children[ac++] = trash_deletePB;
	children[ac++] = trash_emptyPB;
	XtManageChildren(children, ac);
	ac = 0;
}

