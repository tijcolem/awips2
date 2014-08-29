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
package com.raytheon.viz.gfe.dialogs.sbu.jobs;

import java.util.Date;

import com.raytheon.uf.common.jms.notification.INotificationObserver;
import com.raytheon.uf.common.jms.notification.NotificationException;
import com.raytheon.uf.common.jms.notification.NotificationMessage;
import com.raytheon.uf.common.site.notify.ClusterActivationNotification;
import com.raytheon.uf.common.site.notify.SiteActivationNotification;
import com.raytheon.uf.common.site.requests.ActivateSiteRequest;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.viz.core.notification.jobs.NotificationManagerJob;
import com.raytheon.viz.gfe.GFEServerException;
import com.raytheon.viz.gfe.dialogs.sbu.ServiceBackupDlg;

/**
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Aug 9, 2011            bphillip     Initial creation
 * 
 * </pre>
 * 
 * @author bphillip
 * @version 1.0
 */

public class SvcbuActivateSiteJob extends ServiceBackupJob implements
        INotificationObserver {

    private String siteToActivate;

    private ClusterActivationNotification notification;

    /**
     * @param name
     */
    public SvcbuActivateSiteJob(String name, String primarySite) {
        super("Activate Site: " + name, primarySite);
        this.siteToActivate = name;
        NotificationManagerJob.addObserver(ServiceBackupDlg.ACTIVATION_TOPIC, this);
    }

    @Override
    public void run() {
        ActivateSiteRequest request = new ActivateSiteRequest(siteToActivate,
                "gfe");
        try {
            makeRequest(request);
            while (notification == null) {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                }
            }
            if (notification.isClusterActive()) {
                statusHandler
                        .info(notification.getModifiedSite()
                                + " has been successfully activated on all cluster members");
            } else if (notification.isFailure()) {
                statusHandler
                        .error(notification.getModifiedSite()
                                + " has failed to activate on some or all cluster members.  See logs for details");
                this.failed = true;
            }
        } catch (GFEServerException e) {
            statusHandler.handle(Priority.PROBLEM,
                    "SERVICE BACKUP problem: Unable to activate "
                            + siteToActivate, e);
        } finally {
            NotificationManagerJob.removeObserver(ServiceBackupDlg.ACTIVATION_TOPIC, this);
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.common.jms.notification.INotificationObserver#
     * notificationArrived
     * (com.raytheon.uf.common.jms.notification.NotificationMessage[])
     */
    @Override
    public void notificationArrived(NotificationMessage[] messages) {
        for (NotificationMessage msg : messages) {
            Object obj;
            try {
                obj = msg.getMessagePayload();
                String message = null;
                if (obj instanceof ClusterActivationNotification) {
                    ClusterActivationNotification notify = (ClusterActivationNotification) obj;
                    if (notify.getPluginName().equals("gfe")
                            && notify.isActivation()) {
                        this.notification = notify;
                    }
                } else if (obj instanceof SiteActivationNotification) {
                    message = dateFormat.format(new Date()) + "  "
                            + obj.toString();
                }
                statusHandler.info(message);
            } catch (NotificationException e) {
                statusHandler.handle(Priority.PROBLEM,
                        "Unable to read incoming notification", e);
                continue;
            }
        }
    }
}
