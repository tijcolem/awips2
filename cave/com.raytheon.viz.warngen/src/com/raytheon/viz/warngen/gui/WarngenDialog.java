/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 * 
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 * 
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 * 
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.viz.warngen.gui;

import java.lang.reflect.InvocationTargetException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.ProgressMonitorDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.PlatformUI;

import com.raytheon.uf.common.auth.req.CheckAuthorizationRequest;
import com.raytheon.uf.common.dataplugin.warning.AbstractWarningRecord;
import com.raytheon.uf.common.dataplugin.warning.WarningRecord.WarningAction;
import com.raytheon.uf.common.dataplugin.warning.config.BulletActionGroup;
import com.raytheon.uf.common.dataplugin.warning.config.DamInfoBullet;
import com.raytheon.uf.common.dataplugin.warning.config.WarngenConfiguration;
import com.raytheon.uf.common.status.IPerformanceStatusHandler;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.PerformanceStatus;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.common.time.ISimulatedTimeChangeListener;
import com.raytheon.uf.common.time.SimulatedTime;
import com.raytheon.uf.common.time.TimeRange;
import com.raytheon.uf.common.time.util.TimeUtil;
import com.raytheon.uf.viz.core.IDisplayPaneContainer;
import com.raytheon.uf.viz.core.VizApp;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.localization.LocalizationManager;
import com.raytheon.uf.viz.core.maps.MapManager;
import com.raytheon.uf.viz.core.requests.ThriftClient;
import com.raytheon.viz.awipstools.common.stormtrack.StormTrackState.DisplayType;
import com.raytheon.viz.awipstools.common.stormtrack.StormTrackState.Mode;
import com.raytheon.viz.core.mode.CAVEMode;
import com.raytheon.viz.texteditor.msgs.IWarngenObserver;
import com.raytheon.viz.texteditor.util.VtecUtil;
import com.raytheon.viz.ui.EditorUtil;
import com.raytheon.viz.ui.dialogs.CaveSWTDialog;
import com.raytheon.viz.ui.dialogs.ICloseCallback;
import com.raytheon.viz.ui.input.EditableManager;
import com.raytheon.viz.ui.simulatedtime.SimulatedTimeOperations;
import com.raytheon.viz.warngen.Activator;
import com.raytheon.viz.warngen.WarngenConstants;
import com.raytheon.viz.warngen.comm.WarningSender;
import com.raytheon.viz.warngen.gis.PolygonUtil;
import com.raytheon.viz.warngen.template.TemplateRunner;
import com.raytheon.viz.warngen.util.CurrentWarnings;
import com.raytheon.viz.warngen.util.CurrentWarnings.IWarningsArrivedListener;
import com.raytheon.viz.warngen.util.DurationUtil;
import com.raytheon.viz.warngen.util.FollowUpUtil;
import com.vividsolutions.jts.geom.Coordinate;
import com.vividsolutions.jts.geom.Geometry;
import com.vividsolutions.jts.geom.GeometryFactory;
import com.vividsolutions.jts.geom.Polygon;

/**
 * WarnGen Dialog Box
 * 
 * Contains the dialog box used to select WWA parameters
 * 
 * <pre>
 * 
 *  SOFTWARE HISTORY
 * 
 *  Date         Ticket#     Engineer    Description
 *  ------------ ----------  ----------- --------------------------
 *  Jan 26, 2007             chammack    Initial Creation.
 *  Dec 11, 2007 #601        chammack    TO8 Reimplementation
 *  May 10, 2010             mschenke    Major refactor of stormTrack
 *  May 26, 2010 #4969       Qinglu Lin  Made including TO.A &amp; SV.A mandatory
 *  June 23, 2010 #6947      bkowal      When The &quot;Restart&quot; Button Is Pressed On The
 *                                       Warngen Dialog, The Reference To The
 *                                       Warngen Shaded Area Is Now Set To &quot;null&quot;.
 *  Apr 27, 2011 #9250       bkowal      getStyle and getName are now used to
 *                                       get the style and name associated with
 *                                       a FontData object.
 *  Apr 16, 2012 #14515      Qinglu Lin  Added return at the beginning of changeTemplate()
 *                                       if the newly selected product is same as current one.
 *  Jul 10, 2012 #15099      Qinglu Lin  Add updatePolygon() and apply it in xxxSelected methods.
 *  Jul 26, 2012 #15227      Qinglu Lin  Added removeDuplicateVertices(), removeOverlaidSegments(),
 *                                       adjustLatLon(), etc.
 *  Sep 05, 2012 DR 15261    D. Friedman Prevent additional counties from being selected for EXPs
 *  Sep 27, 2012 #1196       rferrel     Refactored to use non-blocking dialogs
 *  Oct 03, 2012 DR 15426    Qinglu Lin  Unlock WarnGen GUI for COR, implemented in corSelected();
 *                                       but lock immediate cause, implemented in individual template.
 *  Nov 02, 2012 DR 15455    Qinglu Lin  Added warngenLayer.setWarningAction() in resetPressed()
 *                                       and in updateListSelected().
 *  Dec 20, 2012 DR 15537    Qinglu Lin  Changed the assigned value to trackEditable from false
 *                                       to true in boxSelected().
 *  Jan 24, 2013 DR 15723    Qinglu Lin  Invoked WarngenLayer's initRemovedGids().
 *  Feb  7, 2013 DR 15799    Qinglu Lin  Added setPolygonLocked(false) to conSelected(), newSelected(); added
 *                                       setPolygonLocked(true) below conSelected() is called in corSelected(),
 *                                       and removed it from updateListSelected().
 *  Feb 18, 2013 #1633       rferrel     Changed checkFollowupSelection to use SimulatedTime.
 *  Mar 28, 2013 DR 15974    D. Friedman Do not track removed GIDs.
 *  Apr 11, 2013 1894        jsanchez    Removed the ability to load/unload maps via bullet selection. This will be resolved in a follow on ticket.
 *  Apr 30, 2013 DR 16118    Qinglu Lin  For reissue (followup NEW), called redrawFromWarned() in okPressed().
 *  May 17, 2013 DR 16118    Qinglu Lin  Copied the fix from 13.4.1.
 *  May 17, 2013 2012        jsanchez    Preserved the warned area if the hatched area source is the same when changing templates.
 *  Jun 24, 2013 DR 16317    D. Friedman Handle "motionless" track.
 *  Jul 16, 2013 DR 16387    Qinglu Lin  Reset totalSegments for each followup product.
 *  Jul 29, 2013 DR 16352    D. Friedman Move 'result' to okPressed().
 *  Aug  6, 2013 2243        jsanchez    Refreshed the follow up list every minute.
 *  Aug 15, 2013 DR 16418    D. Friedman Make dialog visibility match editable state.
 *  Sep 17, 2013 DR 16496    D. Friedman Make editable state more consistent.
 *  Sep 24, 2013 #2401       lvenable    Fixed font memory leak.
 *  Oct 01, 2013 DR16612 m.gamazaychikov Fixed inconsistencies with track locking and updateListSelected method
 *  Oct 29, 2013 DR 16734    D. Friedman If redraw-from-hatched-area fails, don't allow the polygon the be used.
 *  Apr 24, 2014 DR 16356    Qinglu Lin  Updated selectOneStorm() and selectLineOfStorms().
 *  Apr 28, 2014    3033     jsanchez    Re-initialized the Velocity Engine when switching back up sites.
 *  May 09, 2014 DR16694 m.gamazaychikov Fixed disabled duration menu after creating text for a COR SVS.
 *  Jul 01, 2014 DR 17450    D. Friedman Use list of templates from backup site.
 *  Jul 21, 2014 3419        jsanchez    Created a hidden button to make recreating polygons easier.
 *  Feb 26, 2015 3353        rjpeter     Fixed NPE on clear.
 *  Apr 27, 2015 DR 17359    Qinglu Lin  Updated changeTemplate(). The approach for solving slowness issue while switching from
 *                                       one marine product to another is to skip computing hatching area. The hatching area might
 *                                       not be as expected if percentage/area is different between the two products. But the
 *                                       chance for that to occur is trivial.
 *  May  7, 2015 ASM #17438  D. Friedman Clean up debug and performance logging.
 *  Jun 05, 2015 DR 17428    D. Friedman Fixed duration-related user interface issues.  Added duration logging.
 *  Sep 22, 2015 4859        dgilling    Prevent product generation in DRT mode.
 *  Dec  9, 2015 DR 18209    D. Friedman Support cwaStretch dam break polygons.
 *  Dec 21, 2015 DCS 17942   D. Friedman Add advanced options tab
 * </pre>
 * 
 * @author chammack
 * @version 1
 */
public class WarngenDialog extends CaveSWTDialog implements
        IWarningsArrivedListener, ISimulatedTimeChangeListener {
    private static final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(WarngenDialog.class);

    private static final IPerformanceStatusHandler perfLog = PerformanceStatus
            .getHandler("WG:");

    /*
     * This flag allows a hidden button to appear to help recreating warning
     * polygons that had issues in the feed.
     */
    private final boolean debug = false;

    private static final int BULLET_WIDTH = 390;

    private static final int BULLET_HEIGHT = 230;

    private static final int FONT_HEIGHT = 9;

    private class TemplateRunnerInitJob extends Job {
        private final String site;

        public TemplateRunnerInitJob() {
            super("Template Runner Initialization");
            this.site = LocalizationManager.getInstance().getCurrentSite();
        }

        public TemplateRunnerInitJob(String site) {
            super("Template Runner Initialization");
            this.site = site;
        }

        @Override
        protected IStatus run(IProgressMonitor monitor) {
            TemplateRunner.initialize(site);
            return Status.OK_STATUS;
        }
    }

    private static String UPDATELISTTEXT = "UPDATE LIST                                 ";

    public static String NO_BACKUP_SELECTED = "none";

    /** "OK" button text */
    private static final String OK_BTN_LABEL = "Create Text";

    /** "Restart" button text */
    private static final String RS_BTN_LABEL = "Restart";

    /** "Cancel" button text */
    private static final String CLOSE_BUTTON_LABEL = "Close";

    private static final double MIN_LATLON_DIFF = 1.0E-5;

    private static final double MIN_DIFF = 1.0E-8;

    private ArrayList<String> mainProducts;

    private Map<String, String> otherProducts;

    final DateFormat df = new SimpleDateFormat("HH:mm EEE d-MMM");

    private final java.util.List<String> mapsLoaded = new ArrayList<String>();

    private Button okButton;

    private final BulletListManager bulletListManager;

    private List bulletList;

    /** The default duration (specified by the template */
    private DurationData defaultDuration;

    private Combo durationList;

    private Timer timer;

    private TimerTask updateTimeTask;

    /** The start time */
    private Calendar startTime;

    /** The end time */
    private Calendar endTime;

    /** The warngen layer being displayed; */
    private WarngenLayer warngenLayer;

    public Combo updateListCbo;

    private Combo otherProductListCbo;

    private Button fromWarned;

    private Button fromTrack;

    private Button warnedAreaVisible;

    private Button[] mainProductBtns;

    private Button other;

    public Button oneStorm;

    public Button lineOfStorms;

    private Button boxAndTrack;

    public Button box;

    private Button track;

    private Button changeBtn;

    private ValidPeriodDialog validPeriodDlg;

    private boolean boxEditable = true;

    private boolean trackEditable = true;

    private boolean polygonLocked = false;

    private boolean trackLocked = false;

    private int totalSegments = 0;

    private String damBreakInstruct = null;

    private Calendar extEndTime = null;

    private Button damBreakThreatArea;

    private Label instructionsLabel;

    private Button restartBtn;

    private Text start;

    private Text end;

    private Combo backupSiteCbo;

    private Text instructionsBox;

    private Group productType;

    private boolean invalidFollowUpAction = false;

    private final IWarngenObserver wed = new WarningSender();

    /** Bullet list font. */
    private Font bulletListFont = null;

    public WarngenDialog(Shell parentShell, WarngenLayer layer) {
        super(parentShell, SWT.CLOSE | SWT.MODELESS | SWT.BORDER | SWT.TITLE,
                CAVE.DO_NOT_BLOCK | CAVE.INDEPENDENT_SHELL);
        setText("WarnGen");
        bulletListManager = new BulletListManager();
        warngenLayer = layer;
        CurrentWarnings.addListener(this);
        new TemplateRunnerInitJob().schedule();
        SimulatedTime.getSystemTime().addSimulatedTimeChangeListener(this);
    }

    @Override
    protected void disposed() {
        SimulatedTime.getSystemTime().removeSimulatedTimeChangeListener(this);

        if (bulletListFont != null) {
            bulletListFont.dispose();
        }

        timer.cancel();
        updateTimeTask.cancel();
        CurrentWarnings.removeListener(this);
        warngenLayer = null;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.viz.ui.dialogs.CaveSWTDialog#initializeComponents(org.eclipse
     * .swt.widgets.Shell)
     */
    @Override
    protected void initializeComponents(Shell shell) {
        shell.addListener(SWT.Close, new Listener() {
            @Override
            public void handleEvent(Event event) {
                event.doit = false;
                closePressed();
            }
        });

        Composite parent = shell;
        boolean advanced = isAdvancedOptionsEnabled();
        CTabFolder tabs = null;
        CTabItem tabItem = null;
        if (advanced) {
            tabs = new CTabFolder(shell, SWT.FLAT|SWT.TOP);
            parent = tabs;
        }

        Composite mainComposite = new Composite(parent, SWT.NONE);
        if (advanced) {
            tabItem = new CTabItem(tabs, SWT.NONE);
            tabItem.setText("Product");
            tabItem.setControl(mainComposite);
        }
        GridLayout gl = new GridLayout(1, false);
        gl.verticalSpacing = 2;
        gl.marginHeight = 1;
        gl.marginWidth = 1;
        mainComposite.setLayout(gl);

        createBackupTrackEditGroups(mainComposite);
        createRedrawBoxGroup(mainComposite);
        createProductTypeGroup(mainComposite);
        createTimeRangeGroup(mainComposite);
        createBulletListAndLabel(mainComposite);
        createBottomButtons(mainComposite);
        setInstructions();

        if (advanced) {
            tabItem = new CTabItem(tabs, SWT.NONE);
            tabItem.setText("Polygon Options");
            tabItem.setControl(new PolygonOptionsComposite(tabs, warngenLayer));
        }
    }

    @Override
    protected void preOpened() {
        Rectangle rec = PlatformUI.getWorkbench().getActiveWorkbenchWindow()
                .getShell().getBounds();
        shell.setLocation(rec.x, 130);
    }

    /**
     * @param mainComposite
     */
    private void createBulletListAndLabel(Composite mainComposite) {
        bulletList = new List(mainComposite, SWT.MULTI | SWT.V_SCROLL
                | SWT.H_SCROLL | SWT.BORDER);
        bulletListFont = new Font(getDisplay(), bulletList.getFont()
                .getFontData()[0].getName(), FONT_HEIGHT, bulletList.getFont()
                .getFontData()[0].getStyle());
        bulletList.setFont(bulletListFont);

        GridData gd = new GridData(SWT.CENTER, SWT.DEFAULT, false, false);
        gd.widthHint = BULLET_WIDTH;
        gd.heightHint = BULLET_HEIGHT;
        bulletList.setLayoutData(gd);
        bulletListManager.recreateBullets(warngenLayer.getConfiguration()
                .getBullets(), warngenLayer.getConfiguration()
                .getDamInfoBullets());
        refreshBulletList();

        bulletList.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                bulletListSelected();
            }
        });

        instructionsLabel = new Label(mainComposite, SWT.BOLD);
        instructionsLabel.setText("Instructions:");

        gd = new GridData(SWT.FILL, SWT.DEFAULT, true, false);
        gd.heightHint = WarngenConstants.INSTRUCTIONS_HEIGHT;
        instructionsBox = new Text(mainComposite, SWT.BORDER | SWT.READ_ONLY
                | SWT.MULTI);
        instructionsBox.setText("");
        instructionsBox.setLayoutData(gd);

        startTimeTimer();
    }

    /**
     * @param mainComposite
     */
    private void createTimeRangeGroup(Composite mainComposite) {
        Group timeRange = new Group(mainComposite, SWT.NONE);
        timeRange.setText("Time Range");
        timeRange.setLayout(new GridLayout(6, false));

        Label dur = new Label(timeRange, SWT.BOLD);
        dur.setText("Duration:");

        GridData gd = new GridData();
        gd.horizontalSpan = 3;
        durationList = new Combo(timeRange, SWT.READ_ONLY);
        WarngenConfiguration config = warngenLayer.getConfiguration();
        if (config.getDefaultDuration() != 0) {
            setDefaultDuration(config.getDefaultDuration());
        } else {
            setDefaultDuration(30);
        }
        setDurations(config.getDurations());
        durationList.setText(defaultDuration.displayString);
        durationList.setLayoutData(gd);
        durationList.setEnabled(config.isEnableDuration());

        startTime = TimeUtil.newCalendar();
        endTime = DurationUtil.calcEndTime(this.startTime,
                defaultDuration.minutes);

        gd = new GridData();
        gd.horizontalSpan = 3;
        start = new Text(timeRange, SWT.BORDER | SWT.READ_ONLY);
        start.setLayoutData(gd);
        start.setText(df.format(this.startTime.getTime()));

        new Label(timeRange, SWT.NONE).setText(" to ");

        end = new Text(timeRange, SWT.BORDER | SWT.READ_ONLY);
        end.setText(df.format(this.endTime.getTime()));

        changeBtn = new Button(timeRange, SWT.PUSH);
        changeBtn.setText("Change...");
        changeBtn.setEnabled(!config.isEnableDuration());
        changeBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                changeSelected();
            }
        });

        durationList.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                durationSelected();
            }
        });
    }

    private void createProductTypeGroup(Composite mainComposite) {
        productType = new Group(mainComposite, SWT.NONE);
        productType.setText("Product type");
        GridLayout gl = new GridLayout(2, false);
        gl.verticalSpacing = 2;
        gl.marginHeight = 1;
        productType.setLayout(gl);
        productType.setLayoutData(new GridData(SWT.FILL, SWT.DEFAULT, true,
                false));

        createMainProductButtons(productType);
        createOtherProductsList(productType);
    }

    /**
     * @param productType2
     */
    private void createOtherProductsList(Group productType2) {
        if (other == null) {
            other = new Button(productType, SWT.RADIO);
            other.setText("Other:");
            other.setEnabled(true);
            other.addSelectionListener(new SelectionAdapter() {

                @Override
                public void widgetSelected(SelectionEvent arg0) {
                    otherSelected();
                }

            });

            otherProductListCbo = new Combo(productType, SWT.READ_ONLY
                    | SWT.DROP_DOWN);
            GridData gd = new GridData(SWT.RIGHT, SWT.DEFAULT, true, false);
            otherProductListCbo.setLayoutData(gd);
            otherProductListCbo.addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent arg0) {
                    otherProductSelected();
                }

            });
        } else {
            other.setSelection(false);
            if (mainProductBtns.length > 0 && mainProductBtns.length > 0) {
                other.moveBelow(mainProductBtns[mainProductBtns.length - 1]);
            }
            otherProductListCbo.moveBelow(other);
        }

        updateOtherProductList(otherProductListCbo);
    }

    private void createMainProductButtons(Group productType) {
        // Load data for buttons
        mainProducts = new ArrayList<String>();
        String[] mainProductsStr = warngenLayer.getDialogConfig()
                .getMainWarngenProducts().split(",");
        for (String str : mainProductsStr) {
            mainProducts.add(str);
        }

        String defaultTemplate = getDefaultTemplate();

        if (mainProductBtns != null) {
            for (Button button : mainProductBtns) {
                button.dispose();
            }
        }
        mainProductBtns = new Button[mainProducts.size()];

        if (mainProducts.size() > 0) {
            mainProductBtns[0] = new Button(productType, SWT.RADIO);
            mainProductBtns[0].setText(mainProducts.get(0).split("/")[0]);
            mainProductBtns[0].setEnabled(true);
            if (defaultTemplate
                    .equalsIgnoreCase(mainProducts.get(0).split("/")[1])) {
                mainProductBtns[0].setSelection(true);
            } else {
                mainProductBtns[0].setSelection(false);
            }
            mainProductBtns[0].addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent e) {
                    uiChangeTemplate(mainProducts.get(0).split("/")[1]);
                }
            });
        }

        GridData gd = new GridData(SWT.RIGHT, SWT.DEFAULT, true, false);
        if (updateListCbo == null) {
            gd.horizontalIndent = 30;
            updateListCbo = new Combo(productType, SWT.READ_ONLY
                    | SWT.DROP_DOWN);
            updateListCbo.setLayoutData(gd);
            recreateUpdates();

            updateListCbo.addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent arg0) {
                    updateListSelected();
                }

            });
        } else if (mainProductBtns.length > 0) {
            updateListCbo.moveBelow(mainProductBtns[0]);
        }

        for (int cnt = 1; cnt < mainProducts.size(); cnt++) {
            final String[] tmp = mainProducts.get(cnt).split("/");
            gd = new GridData();
            gd.horizontalSpan = 2;
            mainProductBtns[cnt] = new Button(productType, SWT.RADIO);
            mainProductBtns[cnt].setText(tmp[0]);
            mainProductBtns[cnt].setEnabled(true);
            if (defaultTemplate.equalsIgnoreCase(tmp[1])) {
                mainProductBtns[cnt].setSelection(true);
            } else {
                mainProductBtns[cnt].setSelection(false);
            }
            mainProductBtns[cnt].setLayoutData(gd);
            mainProductBtns[cnt].addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent e) {
                    Button button = (Button) e.getSource();
                    if (button.getSelection()) {
                        String templateTitle = button.getText();
                        String templateName = "";
                        for (String s : mainProducts) {
                            if (templateTitle.equals(s.split("/")[0])) {
                                templateName = s.split("/")[1];
                                break;
                            }
                        }

                        uiChangeTemplate(templateName);
                    }
                }
            });
        }
    }

    private void createRedrawBoxGroup(Composite mainComposite) {
        Group redrawBox = new Group(mainComposite, SWT.NONE);
        GridLayout gl = new GridLayout(1, false);
        gl.verticalSpacing = 2;
        gl.marginHeight = 1;
        redrawBox.setLayout(gl);
        redrawBox.setText("Redraw Box on Screen from:");
        redrawBox.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1,
                1));

        warnedAreaVisible = new Button(redrawBox, SWT.CHECK);
        warnedAreaVisible.setText("Warned Area Visible");
        warnedAreaVisible.setLayoutData(new GridData(SWT.RIGHT, SWT.FILL, true,
                true, 1, 1));
        warnedAreaVisible.setSelection(true);
        warnedAreaVisible.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                warnedAreaVisibleToggled();
            }
        });

        Composite redrawFrom = new Composite(redrawBox, SWT.NONE);
        int columns = debug ? 4 : 3;
        redrawFrom.setLayout(new GridLayout(columns, false));
        redrawFrom.setLayoutData(new GridData(SWT.DEFAULT, SWT.FILL, false,
                true));

        createRedrawFromControls(redrawFrom);
    }

    private void createRedrawFromControls(Composite redrawFrom) {
        fromTrack = new Button(redrawFrom, SWT.PUSH);
        fromTrack.setText("Track");
        fromTrack.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                redrawFromTrack();
            }

        });

        fromWarned = new Button(redrawFrom, SWT.PUSH);
        fromWarned.setText("Warned/Hatched Area");
        fromWarned.setEnabled(true);
        fromWarned.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                redrawFromWarned();
            }

        });

        damBreakThreatArea = new Button(redrawFrom, SWT.PUSH);
        damBreakThreatArea.setText("Dam Break Threat Area");
        damBreakThreatArea.setEnabled(false);
        damBreakThreatArea.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                DamInfoBullet damBullet = bulletListManager
                        .getSelectedDamInfoBullet();
                if (damBullet != null) {
                    damBreakThreatAreaPressed(damBullet.getCoords(), true);
                }
            }
        });

        if (debug) {
            Button drawPolygonButton = new Button(redrawFrom, SWT.PUSH);
            drawPolygonButton.setText("?");
            drawPolygonButton.setEnabled(true);
            drawPolygonButton.addSelectionListener(new SelectionAdapter() {
                @Override
                public void widgetSelected(SelectionEvent e) {
                    /*
                     * Copy/paste the LAT...LON line from the text product to
                     * quickly recreate the polygon.
                     */
                    String latLon = "LAT...LON 4282 7174 4256 7129 4248 7159 4280 7198";
                    damBreakThreatAreaPressed(latLon, false);
                }
            });
        }
    }

    private void createBackupTrackEditGroups(Composite mainComposite) {
        Composite backupTrackEditComp = new Composite(mainComposite, SWT.NONE);
        backupTrackEditComp.setLayout(new GridLayout(3, false));
        backupTrackEditComp.setLayoutData(new GridData(SWT.FILL, SWT.FILL,
                true, true, 1, 1));

        createBackupGroup(backupTrackEditComp);
        createTrackGroup(backupTrackEditComp);
        createEditGroup(backupTrackEditComp);

        // Populate the control
        populateBackupGroup();
    }

    /**
     * Create the backup site
     * 
     * @param backupTrackEditComp
     */
    private void createBackupGroup(Composite backupTrackEditComp) {
        Group backupGroup = new Group(backupTrackEditComp, SWT.NONE);
        backupGroup.setLayoutData(new GridData(SWT.DEFAULT, SWT.FILL, false,
                true));
        backupGroup.setText("Backup");
        backupGroup.setLayout(new GridLayout(2, false));

        Label label2 = new Label(backupGroup, SWT.BOLD);
        label2.setText("WFO:");
        label2.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
        backupSiteCbo = new Combo(backupGroup, SWT.READ_ONLY | SWT.DROP_DOWN);
        backupSiteCbo.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent e) {
                backupSiteSelected();
            }

        });
    }

    /**
     * Populate the backup site combo with data from preference store
     */
    private void populateBackupGroup() {
        backupSiteCbo.removeAll();
        backupSiteCbo.add(NO_BACKUP_SELECTED);
        String[] CWAs = warngenLayer.getDialogConfig().getBackupCWAs()
                .split(",");
        for (String cwa : CWAs) {
            if (cwa.length() > 0) {
                BackupData data = new BackupData(cwa);
                backupSiteCbo.setData(data.site, data);
                backupSiteCbo.add(data.site);
            }
        }
        backupSiteCbo.select(0);
    }

    private void createTrackGroup(Composite backupTrackEditComp) {
        Group trackGroup = new Group(backupTrackEditComp, SWT.NONE);
        GridLayout gl = new GridLayout(1, false);
        gl.verticalSpacing = 2;
        gl.marginHeight = 1;
        trackGroup.setLayout(gl);
        trackGroup.setText("Track type");
        trackGroup.setLayoutData(new GridData(SWT.DEFAULT, SWT.FILL, false,
                true));

        oneStorm = new Button(trackGroup, SWT.RADIO);
        oneStorm.setText("One Storm");
        oneStorm.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent arg0) {
                if (warngenLayer.getStormTrackState().displayType != DisplayType.POINT) {
                    selectOneStorm();
                }
            }
        });

        lineOfStorms = new Button(trackGroup, SWT.RADIO);
        lineOfStorms.setText("Line of Storms");
        lineOfStorms.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent arg0) {
                if (warngenLayer.getStormTrackState().displayType != DisplayType.POLY) {
                    selectLineOfStorms();
                }
            }
        });

        switch (warngenLayer.getStormTrackState().displayType) {
        case POLY: {
            lineOfStorms.setSelection(true);
            break;
        }
        default: {
            oneStorm.setSelection(true);
            break;
        }
        }
    }

    private void createEditGroup(Composite backupTrackEditComp) {
        Group editGroup = new Group(backupTrackEditComp, SWT.NONE);
        GridLayout gl = new GridLayout(1, false);
        gl.verticalSpacing = 2;
        gl.marginHeight = 1;
        editGroup.setLayout(gl);
        editGroup.setText("Edit");
        editGroup
                .setLayoutData(new GridData(SWT.DEFAULT, SWT.FILL, false, true));

        box = new Button(editGroup, SWT.RADIO);
        box.setText("Box");
        box.setSelection(false);
        box.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent arg0) {
                boxSelected();
            }
        });

        track = new Button(editGroup, SWT.RADIO);
        track.setText("Track");
        track.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent arg0) {
                trackSelected();
            }
        });

        boxAndTrack = new Button(editGroup, SWT.RADIO);
        boxAndTrack.setText("Box and Track");
        boxAndTrack.setEnabled(true);
        boxAndTrack.setSelection(true);
        boxAndTrack.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent arg0) {
                boxAndTrackSelected();
            }
        });
    }

    /**
     * Create the warngen bottom buttons on the composite
     * 
     * @param parent
     */
    private void createBottomButtons(Composite parent) {
        Composite buttonComp = new Composite(parent, SWT.NONE);
        GridLayout gl = new GridLayout(3, true);
        gl.marginHeight = 1;
        buttonComp.setLayout(gl);
        buttonComp.setLayoutData(new GridData(SWT.CENTER, SWT.CENTER, true,
                true));

        okButton = new Button(buttonComp, SWT.PUSH);
        okButton.setText(OK_BTN_LABEL);
        GridData gd = new GridData(SWT.CENTER, SWT.CENTER, true, true);
        gd.widthHint = 100;
        okButton.setLayoutData(gd);
        okButton.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                if (!SimulatedTimeOperations.isTransmitAllowed()) {
                    Shell shell = getShell();
                    SimulatedTimeOperations.displayFeatureLevelWarning(shell,
                            "Create WarnGen product");
                    return;
                }

                okPressed();
            }

        });

        restartBtn = new Button(buttonComp, SWT.PUSH);
        restartBtn.setText(RS_BTN_LABEL);
        gd = new GridData(SWT.CENTER, SWT.CENTER, true, true);
        gd.widthHint = 100;
        restartBtn.setLayoutData(gd);
        restartBtn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                resetPressed();
            }
        });

        Button btn = new Button(buttonComp, SWT.PUSH);
        btn.setText(CLOSE_BUTTON_LABEL);
        gd = new GridData(SWT.CENTER, SWT.CENTER, true, true);
        gd.widthHint = 100;
        btn.setLayoutData(gd);
        btn.addSelectionListener(new SelectionAdapter() {
            @Override
            public void widgetSelected(SelectionEvent event) {
                closePressed();
            }
        });
    }

    /**
     * Sets the Instructions display.
     */
    public void setInstructions() {
        boolean createTextButtonEnabled = true;
        String str = "";
        if (warngenLayer.getStormTrackState().mode == Mode.DRAG_ME) {
            str += WarngenConstants.INSTRUCTION_DRAG_STORM;
            createTextButtonEnabled = false;
        } else if (warngenLayer.getStormTrackState().mode == Mode.NONE) {
            createTextButtonEnabled = false;
        } else if ((warngenLayer.getPolygon() == null)
                || warngenLayer.getPolygon().isEmpty()) {
            str += WarngenConstants.INSTRUCTION_NO_SHADED_AREA;
            createTextButtonEnabled = false;
        } else if (invalidFollowUpAction) {
            str += "Select a different follow up item";
            createTextButtonEnabled = false;
        }
        if (okButton != null) {
            okButton.setEnabled(createTextButtonEnabled);
        }
        if (createTextButtonEnabled == true) {
            if (warngenLayer.getWarningArea() == null) {
                str = "Area selected has no overlap with current area of responsibility";
            } else {
                if (warngenLayer.getStormTrackState().isInitiallyMotionless()
                        && !warngenLayer.getStormTrackState().isNonstationary()) {
                    str += WarngenConstants.INSTRUCTION_DRAG_STORM + "\n";
                } else if (warngenLayer.getStormTrackState().trackVisible) {
                    str += "Adjust Centroid in any Frame" + "\n";
                }
                str += "Adjust box around Warning Area";
            }
        }
        if (damBreakInstruct != null) {
            str = damBreakInstruct;
        }
        instructionsBox.setText(str);
        Point p1 = instructionsBox.getSize();
        Point p2 = instructionsBox.computeSize(SWT.DEFAULT, SWT.DEFAULT);
        instructionsBox.setSize(new Point(p1.x, p2.y));
    }

    /**
     * This method generates the list of followups, corrections, and reissues
     * that can be issued by the end user in Warngen.
     * 
     * @param optionList
     */
    private void recreateUpdates() {
        boolean newYes = false, corYes = false, extYes = false, follow = false;

        FollowupData currentSelection = null;
        if (updateListCbo.getSelectionIndex() >= 0) {
            currentSelection = (FollowupData) updateListCbo
                    .getData(updateListCbo.getItem(updateListCbo
                            .getSelectionIndex()));
        }

        updateListCbo.removeAll();
        String site = warngenLayer.getLocalizedSite();
        CurrentWarnings cw = CurrentWarnings.getInstance(site);
        java.util.List<AbstractWarningRecord> warnings = cw
                .getCurrentWarnings();

        ArrayList<String> dropDownItems = new ArrayList<String>();
        WarningAction[] acts = new WarningAction[] { WarningAction.CON,
                WarningAction.COR, WarningAction.CAN, WarningAction.EXP,
                WarningAction.NEW, WarningAction.EXT };
        for (int i = 0; i < warnings.size(); i++) {
            for (WarningAction act : acts) {
                if (FollowUpUtil.checkApplicable(site,
                        warngenLayer.getConfiguration(), warnings.get(i), act)) {
                    FollowupData data = new FollowupData(act, warnings.get(i));
                    updateListCbo.setData(data.getDisplayString(), data);
                    if (act == WarningAction.NEW) {
                        newYes = true;
                    } else if (act == WarningAction.EXT) {
                        extYes = true;
                    } else if ((act == WarningAction.CON)
                            || (act == WarningAction.CAN)
                            || (act == WarningAction.EXP)) {
                        follow = true;
                    } else if (act == WarningAction.COR) {
                        corYes = true;
                    }
                    dropDownItems.add(data.getDisplayString());
                }
            }
        }

        String stateUpdate = "";
        if (newYes && corYes && extYes) {
            stateUpdate = "CORRECT/EXTEND/REISSUE";
        } else {
            stateUpdate = corYes ? "CORRECT" : "";
            if (extYes) {
                stateUpdate += corYes ? "/EXTEND" : "EXTEND";
            }
            if (newYes) {
                stateUpdate += corYes == extYes ? "REISSUE" : "/REISSUE";
            }
        }
        boolean newEnabled = false;
        String[] followUps = warngenLayer.getConfiguration().getFollowUps();
        for (String s : followUps) {
            if (s.equals("NEW")) {
                newEnabled = true;
            }
        }
        if (!newEnabled && follow) {
            stateUpdate = "FOLLOWUP";
        }
        if (!stateUpdate.equals("")) {
            updateListCbo.add(stateUpdate);
        }

        updateListCbo.add(UPDATELISTTEXT);
        updateListCbo.select(0);

        for (int i = 0; i < dropDownItems.size(); i++) {
            updateListCbo.add(dropDownItems.get(i));
        }
        // Select the previously selected item.
        invalidFollowUpAction = false;
        if (currentSelection != null) {
            // isValid checks if the current selection is still in the list
            boolean isValid = false;
            for (int i = 0; i < updateListCbo.getItemCount(); i++) {
                if (updateListCbo.getItem(i).startsWith(
                        currentSelection.getEquvialentString())) {
                    updateListCbo.select(i);
                    isValid = true;
                    break;
                }
            }

            WarningAction action = WarningAction.valueOf(currentSelection
                    .getAct());
            TimeRange timeRange = FollowUpUtil.getTimeRange(action,
                    currentSelection);
            // Checks if selection is invalid based on the time range. A follow
            // up option could be removed due to an action such as a CAN or an
            // EXP. If an action removes the follow up, then no warning message
            // should be displayed.
            if (!isValid
                    && !timeRange.contains(SimulatedTime.getSystemTime()
                            .getTime())) {
                invalidFollowUpAction = true;
                preventFollowUpAction(currentSelection);
            }
        } else {
            updateListCbo.select(0);
        }
    }

    /**
     * Prevents the user from creating text when the current selection is no
     * longer valid or available in the update list. The polygon will also be
     * locked from being modified and return to it's last issued state if the
     * polygon was temporarily modified.
     * 
     * @param currentSelection
     */
    private void preventFollowUpAction(FollowupData currentSelection) {

        try {
            warngenLayer.createPolygonFromRecord(currentSelection);
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error resetting the polygon\n", e);
        }

        bulletList.setEnabled(false);
        setPolygonLocked(true);
        setTrackLocked(true);
        refreshDisplay();

        // Provide an info message when this situation occurs
        statusHandler.handle(Priority.PROBLEM,
                currentSelection.getExpirationString());
    }

    /**
     * Set the possible durations
     * 
     * @param durations
     */
    public void setDurations(int[] durations) {
        ArrayList<String> durList = new ArrayList<String>(durations.length);
        boolean isDefaultDurationInList = false;
        durationList.removeAll();
        for (int i = 0; i < durations.length; i++) {
            if (defaultDuration != null
                    && defaultDuration.minutes == durations[i]) {
                isDefaultDurationInList = true;
            }
            DurationData data = new DurationData(durations[i]);
            durationList.setData(data.displayString, data);
            durList.add(data.displayString);
        }
        // Add the default duration to the list if what was missing
        if (!isDefaultDurationInList && defaultDuration != null) {
            durationList
                    .setData(defaultDuration.displayString, defaultDuration);
            durList.add(0, defaultDuration.displayString);
        }

        durationList.setItems(durList.toArray(new String[durList.size()]));
    }

    /**
     * Set the default duration
     * 
     * @param duration
     */
    public void setDefaultDuration(int duration) {
        defaultDuration = new DurationData(duration);
    }

    // Action methods

    /**
     * Action for OK button
     */
    private void okPressed() {
        final long t0okPressed = System.currentTimeMillis();
        if (checkDamSelection() == false) {
            return;
        } else if (warngenLayer.getWarningArea() == null) {
            setInstructions();
            return;
        }

        final String[] selectedBullets = bulletListManager
                .getSelectedBulletNames();
        final FollowupData followupData = (FollowupData) updateListCbo
                .getData(updateListCbo.getItem(updateListCbo
                        .getSelectionIndex()));
        final BackupData backupData = (BackupData) backupSiteCbo
                .getData(backupSiteCbo.getItem(backupSiteCbo
                        .getSelectionIndex()));

        if (checkFollowupSelection(followupData) == false) {
            return;
        }

        if ((followupData != null)
                && (WarningAction.valueOf(followupData.getAct()) == WarningAction.NEW)) {
            if (!redrawFromWarned()) {
                return;
            }
        }

        if (((followupData == null) || ((WarningAction.valueOf(followupData
                .getAct()) == WarningAction.CON) && warngenLayer
                .conWarnAreaChanged(followupData)))
                && !polygonLocked && !trackLocked) {
            if (!redrawFromWarned()) {
                return;
            }
        }

        // Need to check again because redraw may have failed.
        if (warngenLayer.getWarningArea() == null) {
            setInstructions();
            return;
        }

        ProgressMonitorDialog pmd = new ProgressMonitorDialog(Display
                .getCurrent().getActiveShell());
        pmd.setCancelable(false);

        final String[] resultContainer = new String[1];

        try {
            pmd.run(false, false, new IRunnableWithProgress() {

                @Override
                public void run(IProgressMonitor monitor)
                        throws InvocationTargetException, InterruptedException {
                    long t0 = System.currentTimeMillis();
                    try {
                        monitor.beginTask("Generating product", 1);
                        statusHandler.debug("using startTime "
                                + startTime.getTime() + " endTime "
                                + endTime.getTime());
                        String result = TemplateRunner.runTemplate(
                                warngenLayer, startTime.getTime(),
                                endTime.getTime(), selectedBullets,
                                followupData, backupData);
                        resultContainer[0] = result;
                        Matcher m = FollowUpUtil.vtecPtrn.matcher(result);
                        totalSegments = 0;
                        while (m.find()) {
                            totalSegments++;
                        }
                    } catch (Exception e) {
                        statusHandler.handle(
                                Priority.PROBLEM,
                                "Error running warngen template: "
                                        + e.getLocalizedMessage(), e);
                    } finally {
                        monitor.done();
                        perfLog.logDuration("Run template",
                                System.currentTimeMillis() - t0);
                        perfLog.logDuration("click to finish template",
                                System.currentTimeMillis() - t0okPressed);
                    }
                }

            });

            statusHandler.handle(Priority.DEBUG,
                    "Creating Transmitting Warning Job");

            new Job("Transmitting Warning") {
                @Override
                protected IStatus run(IProgressMonitor monitor) {
                    statusHandler.debug(": Transmitting Warning Job Running");

                    // Launch the text editor display as the warngen editor
                    // dialog using the result aka the warngen text product.
                    try {
                        String result = resultContainer[0];
                        if (result != null) {
                            wed.setTextWarngenDisplay(result, true);
                            updateWarngenUIState(result);
                        } else {
                            statusHandler.handle(Priority.PROBLEM,
                                    "Generated warning is null. ");
                        }
                    } catch (Exception e) {
                        statusHandler.handle(
                                Priority.PROBLEM,
                                "Error sending warning: "
                                        + e.getLocalizedMessage(), e);
                    }
                    perfLog.logDuration("click to finish sending",
                            System.currentTimeMillis() - t0okPressed);
                    return Status.OK_STATUS;
                }
            }.schedule();
        } catch (Exception e) {
            final String err = "Error generating warning";
            Status s = new Status(Status.ERROR, Activator.PLUGIN_ID, 0, err, e);
            Activator.getDefault().getLog().log(s);
            ErrorDialog.openError(Display.getCurrent().getActiveShell(), err,
                    err, s);
        }
    }

    private boolean checkDamSelection() {
        if (bulletListManager.isDamNameSeletcted()
                && (bulletListManager.isDamCauseSelected() == false)) {
            /*
             * On WES 'Instructions' became 'Warning' but didn't prevent a
             * created text
             */
            instructionsLabel.setText("Warning:");
            damBreakInstruct = "Dam and/or dam related options were selected, but a Cause\n"
                    + "and Failure Status item also needs to be selected";
            setInstructions();
        } else if (bulletListManager.isDamNameSeletcted()
                && bulletListManager.isDamCauseSelected()) {
            DamInfoBullet damBullet = bulletListManager
                    .getSelectedDamInfoBullet();
            if (damBullet != null) {
                damBreakThreatAreaPressed(damBullet.getCoords(), true);
            }
            if (damBreakInstruct != null) {
                return false;
            }
        }

        return true;
    }

    private void updateWarngenUIState(String result) {
        if ((VtecUtil.parseMessage(result) != null)
                && (WarningAction.valueOf(VtecUtil.parseMessage(result)
                        .getAction()) != WarningAction.NEW)) {
            // TODO Use warningsArrived method to set old
            // polygon and warning area
            warngenLayer.state.setOldWarningPolygon((Polygon) warngenLayer
                    .getPolygon().clone());
            warngenLayer.state.setOldWarningArea((Geometry) warngenLayer
                    .getWarningArea().clone());
        }
    }

    private boolean checkFollowupSelection(FollowupData followupData) {
        // DR 9738, OB9.5 WarnGen line 1436
        // An error dialog is to appear if a user tries to press Create Text
        // again after a product was issued.AWIPS I does not auto update their
        // update list, this is their solution.
        if ((followupData != null) && (totalSegments > 1)) {
            multiSegmentMessage(followupData.getEquvialentString());
            return false;
        }

        return true;
    }

    private void multiSegmentMessage(String choice) {
        StringBuffer sb = new StringBuffer();
        sb.append("A multi-segment followup was created earlier ");
        sb.append("for " + choice + ". If a new ");
        sb.append("followup needs to be created for it, select ");
        sb.append("another product first; then, select ");
        sb.append(choice + ".");
        showErrorDialog(sb.toString());
    }

    private void sameProductMessage(String choice) {
        StringBuffer sb = new StringBuffer();
        sb.append("The selected product, " + choice + ", is ");
        sb.append("same as the last selection. If that's the ");
        sb.append("intenion, select another product first; ");
        sb.append("then, select " + choice + ".");
        showErrorDialog(sb.toString());

    }

    private void showErrorDialog(String message) {
        MessageBox messageBox = new MessageBox(shell, SWT.ICON_ERROR);
        messageBox.setText("Error!");
        messageBox.setMessage(message);
        messageBox.open();
    }

    /**
     * Action for Reset button
     */
    private void resetPressed() {
        statusHandler.debug("resetPressed");
        int durationToUse = getSelectedDuration();
        warngenLayer.resetState();
        restoreDuration(durationToUse);
        durationList.setEnabled(warngenLayer.getConfiguration()
                .isEnableDuration());
        if (lineOfStorms.getSelection()) {
            selectLineOfStorms();
        } else {
            selectOneStorm();
        }
        warngenLayer.setTemplateName(warngenLayer.getTemplateName());
        warngenLayer.state.rightClickSelected = false;
        warngenLayer.state.setWarningPolygon(null);
        warngenLayer.state.followupData = null;
        boxAndTrackSelected();
        setInstructions();
        setPolygonLocked(false);
        updateListCbo.select(0);
        bulletList.setEnabled(true);
        recreateUpdates();
        damBreakInstruct = null;
        extEndTime = null;
        totalSegments = 0;
        bulletListManager.recreateBullets(warngenLayer.getConfiguration()
                .getBullets(), warngenLayer.getConfiguration()
                .getDamInfoBullets());
        refreshBulletList();
        if (warngenLayer.getConfiguration().getEnableDamBreakThreat()) {
            warngenLayer.getStormTrackState().mode = Mode.TRACK;
            warngenLayer.lastMode = Mode.DRAG_ME;
        }
        if ((warngenLayer.getConfiguration().isTrackEnabled() == false)
                || (warngenLayer.getConfiguration().getPathcastConfig() == null)) {
            warngenLayer.getStormTrackState().setInitiallyMotionless(true);
        }
        warngenLayer.resetInitialFrame();
        warngenLayer.setWarningAction(null);
        instructionsLabel.setText("Instructions:");
        changeStartEndTimes();
        warngenLayer.issueRefresh();
    }

    /**
     * Action for Close button
     */
    private void closePressed() {
        EditableManager.makeEditable(warngenLayer, false);
        hide();
    }

    /**
     * Action for when something is selected from the backup site combo
     */
    private void backupSiteSelected() {
        if ((backupSiteCbo.getSelectionIndex() >= 0)
                && (backupSiteCbo.getItemCount() > 0)) {
            int index = backupSiteCbo.getSelectionIndex();
            String backupSite = backupSiteCbo.getItem(index);
            warngenLayer.setBackupSite(backupSite);
            if (backupSite.equalsIgnoreCase("none")) {
                new TemplateRunnerInitJob().schedule();
            } else {
                new TemplateRunnerInitJob(backupSite).schedule();
            }

            /*
             * When the product selection buttons are recreated below, the
             * button for the default template will be selected and mainProducts
             * will have been recreated. Then getDefaultTemplate() can be used
             * here to change the state.
             */
            createMainProductButtons(productType);
            createOtherProductsList(productType);

            // Don't let errors prevent the new controls from being displayed!
            try {
                changeTemplate(getDefaultTemplate());
                resetPressed();
            } catch (Exception e) {
                statusHandler
                        .error("Error occurred while switching to the default template.",
                                e);
            }

            productType.layout(true, true);
            getShell().pack(true);
        }

        if (backupSiteCbo.getSelectionIndex() == 0) {
            backupSiteCbo.setBackground(null);
            backupSiteCbo.setForeground(null);
        } else {
            backupSiteCbo.setBackground(shell.getDisplay().getSystemColor(
                    SWT.COLOR_YELLOW));
            backupSiteCbo.setForeground(shell.getDisplay().getSystemColor(
                    SWT.COLOR_BLACK));
        }
    }

    /**
     * Select one storm
     */
    private void selectOneStorm() {
        statusHandler.debug("selectOneStorm");
        if (warngenLayer.state.followupData == null) {
            int savedDuration = warngenLayer.getStormTrackState().duration;
            warngenLayer.resetState();
            restoreDuration(savedDuration);
            warngenLayer.reset("oneStorm");
            warngenLayer.clearWarningGeometries();
            warngenLayer.getStormTrackState().dragMeLine = null;
            warngenLayer.getStormTrackState().dragMeGeom = null;
            warngenLayer.getStormTrackState().dragMePoint = null;
            warngenLayer.getStormTrackState().mode = Mode.DRAG_ME;
        }
        warngenLayer.getStormTrackState().displayType = DisplayType.POINT;
        warngenLayer.issueRefresh();
    }

    /**
     * Select line of storms
     */
    private void selectLineOfStorms() {
        statusHandler.debug("selectLineOfStorms");
        if (warngenLayer.state.followupData == null) {
            int savedDuration = warngenLayer.getStormTrackState().duration;
            warngenLayer.resetState();
            restoreDuration(savedDuration);
            warngenLayer.reset("lineOfStorms");
            warngenLayer.clearWarningGeometries();
            warngenLayer.getStormTrackState().dragMeLine = null;
            warngenLayer.getStormTrackState().dragMeGeom = null;
            warngenLayer.getStormTrackState().dragMePoint = null;
            warngenLayer.getStormTrackState().mode = Mode.DRAG_ME;
            warngenLayer.getStormTrackState().displayType = DisplayType.POLY;
            if (warngenLayer.getStormTrackState().mode == Mode.DRAG_ME) {
                warngenLayer.getStormTrackState().angle = 90.0;
            }
        }
        warngenLayer.getStormTrackState().displayType = DisplayType.POLY;
        warngenLayer.issueRefresh();
    }

    /**
     * Box was selected, allow editing of box only
     */
    private void boxSelected() {
        boxEditable = true;
        trackEditable = false;
        realizeEditableState();
    }

    /**
     * Track was selected, allow editing of track only
     */
    private void trackSelected() {
        boxEditable = false;
        trackEditable = true;
        realizeEditableState();
    }

    /**
     * Box and track was selected, allow editing of both
     */
    private void boxAndTrackSelected() {
        boxEditable = true;
        trackEditable = true;
        realizeEditableState();
    }

    /**
     * Whether to warn area visible was toggled
     */
    private void warnedAreaVisibleToggled() {
        warngenLayer.setShouldDrawShaded(warnedAreaVisible.getSelection());
        warngenLayer.issueRefresh();
    }

    /**
     * Responsible for drawing a pre-defined warning polygon (coords) on the
     * WarnGen layer.
     * 
     * @param coords
     *            pre-defined warning polygon coordinates in LAT...LON form.
     * @param lockPolygon
     *            indicates if the polygon should be locked or not.
     */
    private void damBreakThreatAreaPressed(String coords, boolean lockPolygon) {
        damBreakInstruct = "Either no dam selected, no dam info bullets in .xml file, or no\n"
                + "dam break primary cause selected.";

        if ((coords == null) || (coords.length() == 0)) {
            damBreakInstruct = "LAT...LON can not be found in 'coords' parameter";
        } else {
            ArrayList<Coordinate> coordinates = new ArrayList<Coordinate>();
            Pattern coordinatePtrn = Pattern
                    .compile("LAT...LON+(\\s\\d{3,4}\\s\\d{3,5}){1,}");
            Pattern latLonPtrn = Pattern.compile("\\s(\\d{3,4})\\s(\\d{3,5})");

            Matcher m = coordinatePtrn.matcher(coords);
            if (m.find()) {
                m = latLonPtrn.matcher(coords);
                while (m.find()) {
                    coordinates.add(new Coordinate((-1 * Double.parseDouble(m
                            .group(2))) / 100,
                            Double.parseDouble(m.group(1)) / 100));
                }

                if (coordinates.size() < 3) {
                    damBreakInstruct = "Lat/Lon pair for dam break threat area is less than three";
                } else {
                    coordinates.add(coordinates.get(0));
                    PolygonUtil.truncate(coordinates, 2);
                    setPolygonLocked(lockPolygon);
                    warngenLayer.createDamThreatArea(coordinates
                            .toArray(new Coordinate[coordinates.size()]));
                    warngenLayer.issueRefresh();
                    damBreakInstruct = null;
                }
            } else {
                damBreakInstruct = "The 'coords' parameter maybe be misformatted or the\n"
                        + "La/Lon for dam break threat area is not in pairs.";
            }
        }
        if (damBreakInstruct != null) {
            setInstructions();
        }
    }

    /**
     * Redraw everything based on track
     */
    private void redrawFromTrack() {
        try {
            warngenLayer.redrawBoxFromTrack();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error redrawing box from track", e);
        }
        warngenLayer.issueRefresh();
    }

    /**
     * Redraw everything based on warned area
     */
    private boolean redrawFromWarned() {
        boolean result = warngenLayer.redrawBoxFromHatched();
        warngenLayer.issueRefresh();
        return result;
    }

    /**
     * Called by controls that can change the current template. Do not do
     * anything if the request template is already selected. This check is
     * necessary to prevent certain state being reset if a followup has been
     * selected as this is not handled by changeTemplate() (DR 14515.)
     */
    private void uiChangeTemplate(String templateName) {
        if (templateName.equals(warngenLayer.getTemplateName())) {
            return;
        }
        changeTemplate(templateName);
    }

    /**
     * This method updates the Warngen Layer and Warngen Dialog based on a new
     * template selection. This method should also be called when the CWA is
     * changed (When a backup site is selected for instance).
     * 
     * @param templateName
     *            - The name of the template you are switching to
     * @param button
     *            - The button that has been clicked
     */
    private void changeTemplate(String templateName) {
        statusHandler.debug("changeTemplate: " + templateName);

        String lastAreaSource = warngenLayer.getConfiguration()
                .getHatchedAreaSource().getAreaSource();

        // reset values
        setPolygonLocked(false);
        setTrackLocked(false);
        warngenLayer.setOldWarningPolygon(null);
        warngenLayer.resetInitialFrame();
        warngenLayer.setTemplateName(templateName);
        if (warngenLayer.state != null) {
            warngenLayer.state.followupData = null;
        }
        warngenLayer.getStormTrackState().endTime = null;
        damBreakInstruct = null;
        extEndTime = null;
        totalSegments = 0;

        // dam break
        boolean enableDamBreakThreat = warngenLayer.getConfiguration()
                .getEnableDamBreakThreat();
        damBreakThreatArea.setEnabled(enableDamBreakThreat);

        // bullets
        bulletList.setEnabled(true);
        bulletListManager.recreateBullets(warngenLayer.getConfiguration()
                .getBullets(), warngenLayer.getConfiguration()
                .getDamInfoBullets());
        refreshBulletList();

        // duration
        boolean enableDuration = warngenLayer.getConfiguration()
                .isEnableDuration();
        durationList.setEnabled(enableDuration);
        changeBtn.setEnabled(!enableDuration);
        recreateDurations(durationList);

        // Current selection doesn't matter anymore
        updateListCbo.select(0);
        // update list
        recreateUpdates();

        // storm track state
        if (enableDamBreakThreat) {
            warngenLayer.getStormTrackState().mode = Mode.TRACK;
            warngenLayer.lastMode = Mode.DRAG_ME;
        }

        if (warngenLayer.getConfiguration().getEnableRestart()) {
            if (warngenLayer.getStormTrackState().mode == Mode.NONE) {
                warngenLayer.resetState();
                warngenLayer.getStormTrackState().displayType = lineOfStorms
                        .getSelection() ? DisplayType.POLY : DisplayType.POINT;
            }
            warngenLayer.getStormTrackState().setInitiallyMotionless(
                    (warngenLayer.getConfiguration().isTrackEnabled() == false)
                            || (warngenLayer.getConfiguration()
                                    .getPathcastConfig() == null));
            if (warngenLayer.getStormTrackState().isInitiallyMotionless()) {
                warngenLayer.getStormTrackState().speed = 0;
                warngenLayer.getStormTrackState().angle = 0;
            } else {
                warngenLayer.getStormTrackState().pointMoved = true;
            }
            restartBtn.setEnabled(true);
        } else {
            warngenLayer.getStormTrackState().mode = Mode.NONE;
            restartBtn.setEnabled(false);
            warngenLayer.clearWarningGeometries();
        }

        boolean isDifferentAreaSources = !warngenLayer.getConfiguration()
                .getHatchedAreaSource().getAreaSource()
                .equalsIgnoreCase(lastAreaSource);
        boolean snapHatchedAreaToPolygon = isDifferentAreaSources;
        boolean preservedSelection = !isDifferentAreaSources;
        if (isDifferentAreaSources
                || !warngenLayer.getConfiguration().getHatchedAreaSource()
                        .getAreaSource().toLowerCase().equals("marinezones")) {
            // If template has a different hatched area source from the previous
            // template, then the warned area would be based on the polygon and
            // not
            // preserved.
            try {
                warngenLayer.updateWarnedAreas(snapHatchedAreaToPolygon,
                        preservedSelection);
            } catch (VizException e1) {
                statusHandler.handle(Priority.PROBLEM, "WarnGen Error", e1);
            }
        }
        // Properly sets the "Create Text" button.
        setInstructions();
    }

    protected void recreateDurations(Combo durList) {
        if (warngenLayer.getConfiguration().getDefaultDuration() != 0) {
            setDefaultDuration(warngenLayer.getConfiguration()
                    .getDefaultDuration());
        }
        setDurations(warngenLayer.getConfiguration().getDurations());
        durList.setText(defaultDuration.displayString);
        endTime = DurationUtil.calcEndTime(startTime, defaultDuration.minutes);
        end.setText(df.format(endTime.getTime()));

        warngenLayer.getStormTrackState().newDuration = defaultDuration.minutes;
        warngenLayer.getStormTrackState().geomChanged = true;
        warngenLayer.issueRefresh();
    }

    /**
     * @param b
     */
    private void setTrackLocked(boolean b) {
        trackLocked = b;
        fromTrack.setEnabled(!b);
        warngenLayer.getStormTrackState().editable = !b;
    }

    /**
     * Locks or Unlocks the polygon
     * 
     * @param b
     */
    private void setPolygonLocked(boolean b) {
        polygonLocked = b;
        warngenLayer.setBoxEditable(!b);
        fromWarned.setEnabled(!b);
        fromTrack.setEnabled(!b);
    }

    /**
     * Populates the Other menu based on the "Other" products available. This
     * includes products manually added and in the future it will include
     * user-created templates.
     * 
     * @param theList
     *            the Combo List which the products will be populated in
     */
    private void updateOtherProductList(Combo theList) {
        otherProducts = new HashMap<String, String>();
        String[] otherProductsStr = warngenLayer.getDialogConfig()
                .getOtherWarngenProducts().split(",");
        theList.removeAll();
        for (String str : otherProductsStr) {
            String[] s = str.split("/");
            otherProducts.put(s[0], s[1]);
            theList.add(s[0]);
        }
        theList.select(0);
    }

    /**
     * item from update list selected
     */
    public void updateListSelected() {
        if (updateListCbo.getSelectionIndex() >= 0) {
            AbstractWarningRecord oldWarning = null;
            FollowupData data = (FollowupData) updateListCbo
                    .getData(updateListCbo.getItem(updateListCbo
                            .getSelectionIndex()));
            statusHandler.debug("updateListSelected: "
                    + (data != null ? data.getDisplayString() : "(null)"));
            Mode currMode = warngenLayer.getStormTrackState().mode;
            if (data != null) {
                // does not refesh if user selected already highlighted option
                // (AWIPS 1)
                if (warngenLayer.state.followupData != null) {
                    if (data.equals(warngenLayer.state.followupData)) {
                        if ((WarningAction
                                .valueOf(warngenLayer.state.followupData
                                        .getAct()) == WarningAction.CON)
                                && (totalSegments > 1)) {
                            sameProductMessage(warngenLayer.state.followupData
                                    .getEquvialentString());
                        }
                        return;
                    }
                }
            } else {
                if (warngenLayer.state.followupData != null) {
                    // recreate updates before setting the updatelist to the
                    // last selected vtec option
                    recreateUpdates();
                    recreateDurations(durationList);
                    for (int i = 0; i < updateListCbo.getItemCount(); i++) {
                        FollowupData fd = (FollowupData) updateListCbo
                                .getData(updateListCbo.getItem(i));
                        if (fd != null) {
                            if (fd.equals(warngenLayer.state.followupData)) {
                                updateListCbo.select(i);
                                updateListCbo.setText(updateListCbo.getItem(i));
                                data = warngenLayer.state.followupData;
                                return;
                            }
                        }
                    }
                }
            }
            if (currMode == Mode.DRAG_ME) {
                warngenLayer.setLastMode(Mode.TRACK);
                warngenLayer.getStormTrackState().mode = Mode.TRACK;
            }

            if (data == null) {
                recreateUpdates();
                return;
            }

            warngenLayer.setOldWarningPolygon(null);
            bulletList.setEnabled(true);
            durationList.setEnabled(true);
            totalSegments = 0;
            warngenLayer.getStormTrackState().endTime = null;
            WarningAction action = WarningAction.valueOf(data.getAct());
            warngenLayer.setWarningAction(action);
            if (action == WarningAction.CON) {
                oldWarning = conSelected(data);
            } else if (action == WarningAction.COR) {
                oldWarning = corSelected(data);
            } else if (action == WarningAction.CAN) {
                oldWarning = canSelected(data);
            } else if (action == WarningAction.NEW) {
                oldWarning = newSelected(data);
            } else if (action == WarningAction.EXP) {
                oldWarning = expSelected(data);
            } else if (action == WarningAction.EXT) {
                oldWarning = extSelected(data);
            } else {
                if (currMode == Mode.DRAG_ME) {
                    warngenLayer.getStormTrackState().mode = Mode.DRAG_ME;
                }
            }
            warngenLayer.state.rightClickSelected = true;
            warngenLayer.state.followupData = data;
            warngenLayer.refreshTemplateForFollowUp(data);

            // Set the damInfoBullets
            if (warngenLayer.getConfiguration().getEnableDamBreakThreat()) {
                for (BulletActionGroup bulletActionGroup : warngenLayer
                        .getConfiguration().getBulletActionGroups()) {
                    if ((bulletActionGroup.getAction() != null)
                            && bulletActionGroup.getAction().equals(
                                    data.getAct())) {
                        warngenLayer.getConfiguration().setDamInfoBullets(
                                bulletActionGroup.getDamInfoBullets());
                    }
                }
            }

            if (oldWarning == null) {
                bulletListManager.recreateBullets(warngenLayer
                        .getConfiguration().getBullets(), warngenLayer
                        .getConfiguration().getDamInfoBullets());
                // TODO Repair load/unload maps via bullet selection
                // A follow on ticket will be written to fix the existing broken
                // functionality of loading/unloading maps
                // updateMaps(bulletListManager.getMapsToLoad());
            } else {
                bulletListManager.recreateBulletsFromFollowup(
                        warngenLayer.getConfiguration(), action, oldWarning);
                if (bulletListManager.isDamNameSeletcted()) {
                    setPolygonLocked(true);
                    /* Need to set the warning area again now that the dam bullets
                     * are set up so that cwaStretch=true dam polygons will work.
                     */
                    try {
                        warngenLayer.resetWarningPolygonAndAreaFromRecord(oldWarning);
                    } catch (VizException e) {
                        statusHandler.error("Error updating the warning area for selected dam", e);
                    }
                }
            }
            refreshBulletList();
            recreateUpdates();
            if ((action == null) || (action == WarningAction.NEW)
                    || (action == WarningAction.EXT)) {
                recreateDurations(durationList);
            }
        } else {
            statusHandler.debug("updateListSelected");
        }
        updateListCbo.pack(true);
        productType.layout();

        // TODO : this pack/layout maybe causing the issue
    }

    /**
     * 
     */
    private void otherProductSelected() {
        for (Button b : mainProductBtns) {
            b.setSelection(false);
        }
        other.setSelection(true);
        String templateName;
        if (otherProducts.containsKey(otherProductListCbo
                .getItem(otherProductListCbo.getSelectionIndex()))) {
            templateName = otherProducts.get(otherProductListCbo
                    .getItem(otherProductListCbo.getSelectionIndex()));
        } else { // CUSTOM TEMPLATE!
            templateName = otherProducts.get(otherProductListCbo
                    .getItem(otherProductListCbo.getSelectionIndex()));
        }
        uiChangeTemplate(templateName);
        otherProductListCbo.pack(true);
        productType.layout();

        // TODO : this pack/layout maybe causing the issue
    }

    private void changeSelected() {
        statusHandler.debug("changeSelected");
        if ((validPeriodDlg == null) || validPeriodDlg.isDisposed()) {
            validPeriodDlg = new ValidPeriodDialog(shell, startTime, endTime);
            validPeriodDlg.setCloseCallback(new ICloseCallback() {

                @Override
                public void dialogClosed(Object returnValue) {
                    int duration = (Integer) returnValue;
                    statusHandler.debug("changeSelected.dialogClosed: "
                            + duration);
                    if (duration != -1) {
                        durationList.setEnabled(false);
                        endTime.add(Calendar.MINUTE, duration);
                        end.setText(df.format(endTime.getTime()));
                        warngenLayer.getStormTrackState().newDuration = duration;
                        warngenLayer.getStormTrackState().geomChanged = true;
                        warngenLayer.issueRefresh();
                        changeStartEndTimes();
                    }
                    validPeriodDlg = null;
                }
            });
            validPeriodDlg.open();
        } else {
            validPeriodDlg.bringToTop();
        }
    }

    /**
     * 
     */
    private void durationSelected() {
        String selection = durationList.getItem(durationList
                .getSelectionIndex());
        statusHandler.debug("durationSelected: " + selection);
        endTime = DurationUtil.calcEndTime(extEndTime != null ? extEndTime
                : startTime,
                ((DurationData) durationList.getData(selection)).minutes);
        end.setText(df.format(endTime.getTime()));

        warngenLayer.getStormTrackState().newDuration = ((DurationData) durationList
                .getData(selection)).minutes;
        warngenLayer.getStormTrackState().geomChanged = true;
        warngenLayer.issueRefresh();
    }

    /**
     * This method allows for selecting multiple items in the list without using
     * control or shift + click.
     */
    private void bulletListSelected() {
        bulletListManager.updateSelectedIndices(bulletList.getSelectionIndex(),
                warngenLayer.state.followupData != null);
        refreshBulletList();
    }

    private void refreshBulletList() {
        bulletList.deselectAll();
        bulletList.setItems(bulletListManager.getAllBulletTexts());
        bulletList.select(bulletListManager.getSelectedIndices());
        // TODO Repair load/unload maps via bullet selection
        // A follow on ticket will be written to fix the existing broken
        // functionality of loading/unloading maps
        // updateMaps(bulletListManager.getMapsToLoad());
    }

    private void updateMaps(ArrayList<String> mapsToLoad) {
        /* Load maps */
        for (String str : mapsToLoad) {
            if (!mapsLoaded.contains(str)) {
                MapManager.getInstance(warngenLayer.getDescriptor())
                        .loadMapByName(str);
                mapsLoaded.add(str);
            }
        }
        /* Unload maps */
        ArrayList<String> mapsToUnload = new ArrayList<String>();
        for (String str : mapsLoaded) {
            if (!mapsToLoad.contains(str)) {
                MapManager.getInstance(warngenLayer.getDescriptor()).unloadMap(
                        str);
                mapsToUnload.add(str);
            }
        }
        for (String str : mapsToUnload) {
            mapsLoaded.remove(str);
        }

        /* Load maps */
        for (String str : mapsToLoad) {
            if (!mapsLoaded.contains(str)) {
                MapManager.getInstance(warngenLayer.getDescriptor())
                        .loadMapByName(str);
                mapsLoaded.add(str);
            }
        }
    }

    /**
     * Timer to update the start and stop time for warngen.
     */
    protected void startTimeTimer() {
        timer = new Timer();

        updateTimeTask = new TimerTask() {
            @Override
            public void run() {

                getDisplay().syncExec(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            changeStartEndTimes();
                        } catch (Exception e) {
                            statusHandler.handle(Priority.PROBLEM,
                                    "WarnGen Error", e);
                        }
                    }
                });
            }
        };

        long delay = warngenLayer.getDialogConfig()
                .getFollowupListRefeshDelay();

        if (delay == 0) {
            delay = 5000;
        }

        timer.schedule(updateTimeTask, delay, delay);

        TimerTask recreateUpdatesTask = new TimerTask() {
            @Override
            public void run() {

                getDisplay().syncExec(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            recreateUpdates();
                        } catch (Exception e) {
                            statusHandler.handle(Priority.PROBLEM,
                                    "WarnGen Error", e);
                        }
                    }
                });
            }
        };

        // Update the follow up list every minute
        long currentTimeInSeconds = SimulatedTime.getSystemTime().getMillis() / 1000;
        long secondsToNextMinute = 0;
        if ((currentTimeInSeconds % 60) != 0) {
            secondsToNextMinute = 60 - (currentTimeInSeconds % 60);
        }
        timer.schedule(recreateUpdatesTask, secondsToNextMinute * 1000,
                60 * 1000);
    }

    /**
     * This method changes the start and stop time for the warning as the time
     * changes.
     */
    protected void changeStartEndTimes() {
        if (!(durationList.isDisposed())) {
            int duration = warngenLayer.getStormTrackState().duration;
            int newDuration = warngenLayer.getStormTrackState().newDuration;
            if (newDuration != -1) {
                duration = newDuration;
            }

            FollowupData fd = (FollowupData) updateListCbo
                    .getData(updateListCbo.getItem(updateListCbo
                            .getSelectionIndex()));
            if ((fd == null)
                    || (WarningAction.valueOf(fd.getAct()) == WarningAction.NEW)) {
                startTime = TimeUtil.newCalendar();
                endTime = DurationUtil.calcEndTime(this.startTime, duration);
                start.setText(df.format(this.startTime.getTime()));
                end.setText(df.format(this.endTime.getTime()));
            } else if (WarningAction.valueOf(fd.getAct()) == WarningAction.EXT) {
                startTime = TimeUtil.newCalendar();
                endTime = DurationUtil.calcEndTime(extEndTime, duration);
                end.setText(df.format(this.endTime.getTime()));
            }
        }
    }

    public boolean boxEditable() {
        return boxEditable;
    }

    public boolean trackEditable() {
        return trackEditable;
    }

    /**
     * This method is called when a CON followup is selected. The method
     * recreates the warning's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord conSelected(FollowupData data) {
        setPolygonLocked(false);
        CurrentWarnings cw = CurrentWarnings.getInstance(warngenLayer
                .getLocalizedSite());
        AbstractWarningRecord newWarn = null;
        if (WarningAction.COR == WarningAction.valueOf(data.getAct())) {
            newWarn = cw.getFollowUpByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig(), new WarningAction[] {
                    WarningAction.CON, WarningAction.COR });
        } else {
            newWarn = cw.getNewestByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig());
        }

        updatePolygon(newWarn);

        warngenLayer.setOldWarningPolygon(newWarn);
        setTimesFromFollowup(newWarn.getStartTime().getTime(), newWarn
                .getEndTime().getTime());
        try {
            warngenLayer.createPolygonFromRecord(newWarn);
            setTrackLocked(false);
            refreshDisplay();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error creating polygon from the record\n", e);
        }

        return newWarn;
    }

    /**
     * This method is called when a CORRECTION is selected. The method recreates
     * the previous product's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord corSelected(FollowupData data) {
        setPolygonLocked(true);
        AbstractWarningRecord newWarn;
        boolean allowsNewProduct = false;
        for (String followup : warngenLayer.getConfiguration().getFollowUps()) {
            WarningAction act = WarningAction.valueOf(followup);
            if (act == WarningAction.NEW) {
                allowsNewProduct = true;
            }
        }
        // Special case - allows for Correction of Followups
        if (!allowsNewProduct) {
            newWarn = conSelected(data);
            setPolygonLocked(true);
        } else {
            CurrentWarnings cw = CurrentWarnings.getInstance(warngenLayer
                    .getLocalizedSite());

            newWarn = cw.getNewestByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig());

            updatePolygon(newWarn);

            warngenLayer.setOldWarningPolygon(newWarn);
            setTimesFromFollowup(newWarn.getStartTime().getTime(), newWarn
                    .getEndTime().getTime());
            try {
                warngenLayer.createPolygonFromRecord(newWarn);
                fromTrack.setEnabled(false);
                warngenLayer.getStormTrackState().editable = true;
                refreshDisplay();
            } catch (VizException e) {
                statusHandler.handle(Priority.PROBLEM,
                        "Error creating polygon from the record\n", e);
            }
        }

        return newWarn;
    }

    /**
     * This method is called when an EXP followup is selected. The method
     * recreates the warning's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord expSelected(FollowupData data) {
        bulletList.setEnabled(true);
        setPolygonLocked(true);
        AbstractWarningRecord newWarn = null;

        CurrentWarnings cw = CurrentWarnings.getInstance(warngenLayer
                .getLocalizedSite());
        if (WarningAction.COR == WarningAction.valueOf(data.getAct())) {
            newWarn = cw.getFollowUpByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig(), new WarningAction[] {
                    WarningAction.EXP, WarningAction.COR });
        } else {
            newWarn = cw.getNewestByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig());
        }

        updatePolygon(newWarn);
        warngenLayer.setOldWarningPolygon(newWarn);
        setTimesFromFollowup(newWarn.getStartTime().getTime(), newWarn
                .getEndTime().getTime());
        try {
            warngenLayer.createPolygonFromRecord(newWarn);
            setTrackLocked(true);
            refreshDisplay();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error creating polygon from the record\n", e);
        }

        return newWarn;
    }

    /**
     * This method is called when a CAN followup is selected. The method
     * recreates the warning's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord canSelected(FollowupData data) {
        bulletList.setEnabled(true);
        setPolygonLocked(true);
        AbstractWarningRecord newWarn = null;

        CurrentWarnings cw = CurrentWarnings.getInstance(warngenLayer
                .getLocalizedSite());
        if (WarningAction.COR == WarningAction.valueOf(data.getAct())) {
            newWarn = cw.getCancelledByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig());
        } else {
            newWarn = cw.getNewestByTracking(data.getEtn(), data.getPhen()
                    + "." + data.getSig());
        }

        updatePolygon(newWarn);

        warngenLayer.setOldWarningPolygon(newWarn);
        setTimesFromFollowup(newWarn.getStartTime().getTime(), newWarn
                .getEndTime().getTime());
        try {
            warngenLayer.createPolygonFromRecord(newWarn);
            setTrackLocked(true);
            refreshDisplay();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error creating polygon from the record\n", e);
        }

        return newWarn;
    }

    /**
     * This method is called when a reissue is selected. The method recreates
     * the warning's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord newSelected(FollowupData data) {
        setPolygonLocked(false);
        AbstractWarningRecord newWarn = CurrentWarnings.getInstance(
                warngenLayer.getLocalizedSite()).getNewestByTracking(
                data.getEtn(), data.getPhen() + "." + data.getSig());

        updatePolygon(newWarn);

        try {
            warngenLayer.createPolygonFromRecord(newWarn);
            refreshDisplay();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error creating polygon from the record\n", e);
        }

        return newWarn;
    }

    /**
     * This method is called when an EXT followup is selected. The method
     * recreates the warning's state in D-2D
     * 
     * @param selected
     */
    private AbstractWarningRecord extSelected(FollowupData data) {
        bulletList.setEnabled(true);
        setPolygonLocked(true);
        boolean enableDuration = warngenLayer.getConfiguration()
                .isEnableDuration();
        durationList.setEnabled(enableDuration);
        changeBtn.setEnabled(!enableDuration);

        AbstractWarningRecord newWarn = CurrentWarnings.getInstance(
                warngenLayer.getLocalizedSite()).getNewestByTracking(
                data.getEtn(), data.getPhen() + "." + data.getSig());

        updatePolygon(newWarn);

        recreateDurations(durationList);
        int duration = getSelectedDuration();
        warngenLayer.getStormTrackState().duration = duration;

        startTime = TimeUtil.newCalendar();
        extEndTime = newWarn.getEndTime();
        endTime = DurationUtil.calcEndTime(extEndTime, duration);
        end.setText(df.format(this.endTime.getTime()));

        changeStartEndTimes();
        try {
            warngenLayer.createPolygonFromRecord(newWarn);
            refreshDisplay();
        } catch (VizException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "Error creating polygon from the record\n", e);
        }

        return newWarn;
    }

    private void setTimesFromFollowup(Date startDate, Date endDate) {
        // Sets the Time Range start and end times on dialog
        start.setText(df.format(startDate));
        startTime.setTime(startDate);
        end.setText(df.format(endDate));
        endTime.setTime(endDate);
        endTime.add(Calendar.MILLISECOND, 1);

        // Sets the duration value on the dialog
        int durationInMinutes = (int) (endDate.getTime() - startDate.getTime())
                / (60 * 1000);
        durationList.setText(String.valueOf(durationInMinutes));
        durationList.setEnabled(false);
        changeBtn.setEnabled(false);

        warngenLayer.getStormTrackState().endTime = endTime;
    }

    /**
     * Set the shell to visible and then move it on top of the CAVE dialog.
     */
    public void showDialog(boolean show) {
        if ((shell != null) && (shell.isDisposed() == false)) {
            if (show) {
                if (shell.isVisible() == false) {
                    shell.setVisible(true);
                }
                // Move above parent shell if we are showing it
                shell.moveAbove(getParent());
            } else {
                shell.setVisible(false);
            }
        }
    }

    private void otherSelected() {
        String templateName = warngenLayer.getTemplateName();
        if (other.getSelection()) {
            templateName = otherProducts.get(otherProductListCbo
                    .getItem(otherProductListCbo.getSelectionIndex()));
        }
        uiChangeTemplate(templateName);
    }

    private void refreshDisplay() {
        if (warngenLayer != null) {
            warngenLayer.issueRefresh();
        } else {
            IDisplayPaneContainer container = EditorUtil
                    .getActiveVizContainer();
            if (container != null) {
                container.refresh();
            }
        }
    }

    @Override
    public void warningsArrived() {
        VizApp.runAsync(new Runnable() {
            @Override
            public void run() {
                if (isDisposed() == false) {
                    // Just recreate updates since that is all that is needed
                    recreateUpdates();
                }
            }
        });
    }

    /**
     * Update polygon in a warning product to remove intersected segment.
     */
    private boolean updatePolygon(AbstractWarningRecord oldWarning) {
        Geometry geo = oldWarning.getGeometry();
        Coordinate[] coords0 = geo.getCoordinates();

        GeometryFactory gf = new GeometryFactory();

        // Duplicate vertices (BOX.SV.W.0049, July 2012) makes
        // removeOverlaidSegments
        // not working. So, remove the duplicate vertex first.
        Coordinate[] coords = removeDuplicateVertices(coords0);
        if (coords.length != coords0.length) {
            java.util.List<Coordinate> points = new ArrayList<Coordinate>(
                    Arrays.asList(coords));
            Polygon rval = gf.createPolygon(gf.createLinearRing(points
                    .toArray(new Coordinate[points.size()])), null);
            oldWarning.setGeometry(rval);
        }

        int size = coords.length;
        boolean adjusted = false;
        if (size > 3) {
            Coordinate[] coords2 = new Coordinate[size + 3];
            for (int i = 0; i < size; i++) {
                coords2[i] = coords[i];
            }
            coords2[size] = coords[1];
            coords2[size + 1] = coords[2];
            coords2[size + 2] = coords[3];
            adjusted = removeOverlaidSegments(coords2);

            coords = Arrays.copyOf(coords2, size);
            coords[0] = coords2[size - 1];
        }

        java.util.List<Coordinate> points = new ArrayList<Coordinate>(
                Arrays.asList(coords));
        Polygon rval = gf.createPolygon(gf.createLinearRing(points
                .toArray(new Coordinate[points.size()])), null);

        if (adjusted) {
            oldWarning.setGeometry(rval);
        }

        boolean invalidPolyFlag = false;
        if (rval.isValid() == false) {
            invalidPolyFlag = true;
            points.remove(points.size() - 1);
            PolygonUtil.removeIntersectedSeg(points);
            points.add(new Coordinate(points.get(0)));
            rval = gf.createPolygon(gf.createLinearRing(points
                    .toArray(new Coordinate[points.size()])), null);
        }
        if (invalidPolyFlag) {
            oldWarning.setGeometry(rval);
            return true;
        }
        return false;
    }

    /**
     * Remove duplicate vertices
     */
    private Coordinate[] removeDuplicateVertices(Coordinate[] coords) {
        int size = coords.length;
        java.util.List<Coordinate> coords2 = new ArrayList<Coordinate>();
        coords2.add(coords[0]);
        for (int i = 1; i < size; i++) {
            if ((Math.abs(coords[i].x - coords[i - 1].x) > MIN_LATLON_DIFF)
                    || (Math.abs(coords[i].y - coords[i - 1].y) > MIN_LATLON_DIFF)) {
                coords2.add(coords[i]);
            }
        }
        size = coords2.size();
        Coordinate[] coords3 = coords2.toArray(new Coordinate[size]);
        return coords3;
    }

    /**
     * Remove overlaid segments
     */
    private boolean removeOverlaidSegments(Coordinate[] coords) {
        double diffx1, diffx2, diffy1, diffy2;
        double ratio1, ratio2;
        boolean adjusted = false;
        for (int i = 2; i < (coords.length - 2); i++) {
            diffx1 = coords[i - 1].x - coords[i].x;
            if (Math.abs(diffx1) > MIN_LATLON_DIFF) {
                ratio1 = (coords[i - 1].y - coords[i].y) / diffx1;
                diffx2 = coords[i].x - coords[i + 1].x;
                if (Math.abs(diffx2) > MIN_LATLON_DIFF) {
                    ratio2 = (coords[i].y - coords[i + 1].y) / diffx2;
                    if (Math.abs(ratio1 - ratio2) < MIN_DIFF) {
                        if (((diffx1 > 0.0) && (diffx2 > 0.0))
                                || ((diffx1 < 0.0) && (diffx2 < 0.0))) {
                            // three vertices on a straight line. Not overlaid.
                        } else {
                            // two segments overlaid
                            adjustLatLon('y', coords, i);
                            adjusted = true;
                        }
                    }
                } else {
                    continue;
                }
            } else {
                diffy1 = coords[i - 1].y - coords[i].y;
                ratio1 = (coords[i - 1].x - coords[i].x) / diffy1;
                diffy2 = coords[i].y - coords[i + 1].y;
                if (Math.abs(diffy2) > MIN_LATLON_DIFF) {
                    ratio2 = (coords[i].x - coords[i + 1].x) / diffy2;
                    if (Math.abs(ratio1 - ratio2) < MIN_DIFF) {
                        if (((diffy1 > 0.0) && (diffy2 > 0.0))
                                || ((diffy1 < 0.0) && (diffy2 < 0.0))) {
                            // three vertices on a straight line. Not overlaid.
                        } else {
                            // two segments overlaid
                            adjustLatLon('x', coords, i);
                            adjusted = true;
                        }
                    }
                } else {
                    continue;
                }
            }
        }
        return adjusted;
    }

    /**
     * Increase or decrease latitude or longitude slightly
     */
    private void adjustLatLon(char direction, Coordinate[] coords, int i) {
        // Empirical value.
        // 1.0E3 not working for horizontal rectangle cases
        double adjustedValue = 5.0E-3;

        int n = coords.length;
        int factor;
        if (direction == 'x') {
            // adjust longitude
            double diffx = coords[i - 2].x - coords[i - 1].x;
            if (Math.abs(diffx) > MIN_LATLON_DIFF) {
                if (coords[i - 1].y > coords[i].y) {
                    factor = 1;
                } else {
                    factor = -1;
                }
                if (diffx < 0.0) {
                    coords[i + 1].x -= factor * adjustedValue;
                } else {
                    coords[i - 1].x += factor * adjustedValue;
                }
                if (i == (n - 3)) {
                    coords[0].x = coords[i - 1].x;
                }
            } else {
                diffx = coords[i + 2].x - coords[i + 1].x;
                if (Math.abs(diffx) > MIN_LATLON_DIFF) {
                    if (coords[i + 1].y > coords[i].y) {
                        factor = -1;
                    } else {
                        factor = 1;
                    }
                    if (diffx < 0.0) {
                        coords[i - 1].x -= factor * adjustedValue;
                    } else {
                        coords[i + 1].x += factor * adjustedValue;
                    }
                    if (i == (n - 3)) {
                        coords[0].x = coords[i - 1].x;
                    }
                }
            }
        } else {
            // adjust latitude
            double diffy = coords[i - 2].y - coords[i - 1].y;
            if (Math.abs(diffy) > MIN_LATLON_DIFF) {
                if (coords[i - 1].x > coords[i].x) {
                    factor = -1;
                } else {
                    factor = 1;
                }
                if (diffy > 0.0) {
                    coords[i + 1].y -= factor * adjustedValue;
                } else {
                    coords[i - 1].y += factor * adjustedValue;
                }
                if (i == (n - 3)) {
                    coords[0].y = coords[i - 1].y;
                }
            } else {
                diffy = coords[i + 2].y - coords[i + 1].y;
                if (Math.abs(diffy) > MIN_LATLON_DIFF) {
                    if (coords[i + 1].x > coords[i].x) {
                        factor = -1;
                    } else {
                        factor = 1;
                    }
                    if (diffy < 0.0) {
                        coords[i - 1].y -= factor * adjustedValue;
                    } else {
                        coords[i + 1].y += factor * adjustedValue;
                    }
                    if (i == (n - 3)) {
                        coords[0].y = coords[i - 1].y;
                    }
                }
            }
        }
    }

    public void realizeEditableState() {
        boolean layerEditable = warngenLayer.isEditable();
        // TODO: Note there is no 'is track editing allowed' state yet.
        warngenLayer.getStormTrackState().editable = layerEditable
                && trackEditable && !trackLocked;
        warngenLayer.setBoxEditable(layerEditable && boxEditable
                && !polygonLocked);
        warngenLayer.issueRefresh();
    }

    private String getDefaultTemplate() {
        String defaultTemplate = warngenLayer.getDialogConfig()
                .getDefaultTemplate();
        if ((defaultTemplate == null) || defaultTemplate.equals("")) {
            defaultTemplate = mainProducts.get(0).split("/")[1];
        }
        return defaultTemplate;
    }

    private void restoreDuration(int duration) {
        warngenLayer.getStormTrackState().duration = warngenLayer
                .getStormTrackState().newDuration = duration;
        warngenLayer.getStormTrackState().geomChanged = true;
    }

    private int getSelectedDuration() {
        Exception excToReport = null;
        DurationData data = null;
        try {
            data = (DurationData) durationList.getData(durationList
                    .getItem(durationList.getSelectionIndex()));
        } catch (RuntimeException e) {
            excToReport = e;
        }
        int duration;
        if (data != null) {
            duration = data.minutes;
        } else {
            try {
                duration = warngenLayer.getConfiguration().getDefaultDuration();
            } catch (RuntimeException e) {
                if (excToReport == null) {
                    excToReport = e;
                }
                duration = 30;
            }
            statusHandler
                    .handle(Priority.WARN,
                            "Unable to determine duration from selection in WarnGen dialog.  Using default of "
                                    + duration + " minutes.", excToReport);
        }
        statusHandler.debug("selected duration is " + duration);
        return duration;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.common.time.ISimulatedTimeChangeListener#timechanged()
     */
    @Override
    public void timechanged() {
        VizApp.runAsync(new Runnable() {

            @Override
            public void run() {
                if ((getShell().isVisible())
                        && (!SimulatedTimeOperations.isTransmitAllowed())) {
                    SimulatedTimeOperations.displayFeatureLevelWarning(
                            getShell(), "WarnGen");
                }
            }
        });
    }

    public boolean isCwaStretchDamBulletSelected() {
        DamInfoBullet bullet = bulletListManager.getSelectedDamInfoBullet();
        return bullet !=  null && bullet.isCwaStretch();
    }

    private static boolean isAdvancedOptionsEnabled() {
        boolean hasPermission = false;

        try {
            String userId = LocalizationManager.getInstance().getCurrentUser();
            CheckAuthorizationRequest request = new CheckAuthorizationRequest(
                    userId, "advancedOptions", "WarnGen");
            hasPermission = (Boolean) ThriftClient.sendRequest(request);
        } catch (Exception e) {
            statusHandler.error("error checking permissions", e);
        }

        return ((hasPermission && CAVEMode.getMode() == CAVEMode.PRACTICE)
                || WarngenLayer.isWarngenDeveloperMode());
    }
}
