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
package com.raytheon.uf.edex.maintenance.archive;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import com.raytheon.uf.common.dataplugin.PluginDataObject;
import com.raytheon.uf.common.dataplugin.PluginException;
import com.raytheon.uf.common.dataplugin.PluginProperties;
import com.raytheon.uf.common.dataplugin.persist.DefaultPathProvider;
import com.raytheon.uf.common.dataplugin.persist.IHDFFilePathProvider;
import com.raytheon.uf.common.dataplugin.persist.IPersistable;
import com.raytheon.uf.common.dataplugin.persist.PersistableDataObject;
import com.raytheon.uf.common.serialization.SerializationException;
import com.raytheon.uf.common.serialization.SerializationUtil;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.util.FileUtil;
import com.raytheon.uf.edex.core.dataplugin.PluginRegistry;
import com.raytheon.uf.edex.database.DataAccessLayerException;
import com.raytheon.uf.edex.database.cluster.ClusterLockUtils;
import com.raytheon.uf.edex.database.cluster.ClusterLockUtils.LockState;
import com.raytheon.uf.edex.database.cluster.ClusterTask;
import com.raytheon.uf.edex.database.cluster.handler.CurrentTimeClusterLockHandler;
import com.raytheon.uf.edex.database.plugin.PluginDao;
import com.raytheon.uf.edex.database.plugin.PluginFactory;
import com.raytheon.uf.edex.maintenance.archive.config.DataArchiveConfig;

/**
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Nov 17, 2011            rjpeter     Initial creation
 * 
 * </pre>
 * 
 * @author rjpeter
 * @version 1.0
 */
public class DatabaseArchiver implements IPluginArchiver {
    private static final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(DatabaseArchiver.class);

    private final SimpleDateFormat DATE_FORMAT;

    // Minimum time increment to archive, note based off of insertTime
    private static final int MIN_DURATION_MILLIS = 1000 * 60 * 30;

    // Maximum time increment to archive, note based off of insertTime
    private static final int MAX_DURATION_MILLIS = 1000 * 60 * 60;

    private static final String TASK_NAME = "DB Archiver";

    private static final int CLUSTER_LOCK_TIMEOUT = 60000;

    public DatabaseArchiver() {
        DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        DATE_FORMAT.setTimeZone(TimeZone.getTimeZone("GMT"));
    }

    @Override
    public void archivePlugin(String pluginName, String archivePath,
            DataArchiveConfig conf) {
        PluginProperties props = PluginRegistry.getInstance()
                .getRegisteredObject(pluginName);
        if (props != null && props.getRecord() != null
                && props.getDao() != null) {
            Class<?> recordClass = props.getRecord();
            if (recordClass != null) {
                try {
                    recordClass.asSubclass(PluginDataObject.class);
                    archivePluginData(pluginName, archivePath, conf);
                } catch (ClassCastException e) {
                    // not an error, using asSubClass to filter non
                    // PluginDataObjects
                }
            }
        }
    }

    public boolean archivePluginData(String pluginName, String archivePath,
            DataArchiveConfig conf) {
        // set archive time
        Calendar runTime = Calendar.getInstance();
        runTime.setTimeZone(TimeZone.getTimeZone("GMT"));
        runTime.add(Calendar.MINUTE, -30);

        // cluster lock, grabbing time of last successful archive
        CurrentTimeClusterLockHandler lockHandler = new CurrentTimeClusterLockHandler(
                CLUSTER_LOCK_TIMEOUT, DATE_FORMAT.format(runTime.getTime()),
                false);
        ClusterTask ct = ClusterLockUtils.lock(TASK_NAME, pluginName,
                lockHandler, false);
        if (!LockState.SUCCESSFUL.equals(ct.getLockState())) {
            return true;
        }

        Calendar startTime = null;

        try {
            // lookup dao
            PluginDao dao = null;
            try {
                dao = PluginFactory.getInstance().getPluginDao(pluginName);
            } catch (PluginException e) {
                statusHandler
                        .error(pluginName
                                + ": Error getting data access object!  Unable to archive data!",
                                e);
                return false;
            }

            startTime = determineStartTime(pluginName, ct.getExtraInfo(),
                    runTime, dao, conf);
            Calendar endTime = determineEndTime(startTime, runTime);
            Map<String, List<PersistableDataObject>> pdoMap = new HashMap<String, List<PersistableDataObject>>();

            while (startTime != null && endTime != null) {
                Map<String, List<PersistableDataObject>> pdosToSave = getPdosByFile(
                        pluginName, dao, pdoMap, startTime, endTime);

                if (pdosToSave != null && pdosToSave.size() > 0) {
                    savePdoMap(pluginName, archivePath, pdosToSave);
                }

                startTime = endTime;
                endTime = determineEndTime(startTime, runTime);
            }

            if (pdoMap != null && pdoMap.size() > 0) {
                savePdoMap(pluginName, archivePath, pdoMap);
            }

            // set last archive time to startTime
            if (startTime != null) {
                lockHandler
                        .setExtraInfo(DATE_FORMAT.format(startTime.getTime()));
            }
        } catch (Throwable e) {
            // previous run time needs to be reset
            if (startTime != null) {
                lockHandler
                        .setExtraInfo(DATE_FORMAT.format(startTime.getTime()));
            }

            statusHandler.error(pluginName + ": Error occurred archiving data",
                    e);
        } finally {
            if (ct != null) {
                // release lock setting archive time in cluster lock
                ClusterLockUtils.unlock(ct, false);
            }
        }

        return true;
    }

    /**
     * 
     * @param pdoMap
     *            The current pdos by file. This map will be merged with pdos,
     *            if a key was not referenced by pdos it will be removed and
     *            returned in the returned map for storage.
     * @param pdos
     *            The pdos to sort by file
     * @return The pdos to save to disk. If sortPdosByFiles did not store any
     *         entries from pdos into a file listed in currentPdoMap then that
     *         entry will be returned in a new map and removed from
     *         currentPdoMap.
     */
    protected Map<String, List<PersistableDataObject>> getPdosByFile(
            String pluginName, PluginDao dao,
            Map<String, List<PersistableDataObject>> pdoMap,
            Calendar startTime, Calendar endTime)
            throws DataAccessLayerException {
        List<PersistableDataObject> pdos = dao.getRecordsToArchive(startTime,
                endTime);

        Set<String> newFileEntries = new HashSet<String>();
        if (pdos != null && pdos.size() > 0) {
            if (pdos.get(0) instanceof IPersistable) {
                IHDFFilePathProvider pathProvider = dao.pathProvider;

                for (PersistableDataObject pdo : pdos) {
                    IPersistable persistable = (IPersistable) pdo;
                    String path = pathProvider.getHDFPath(pluginName,
                            persistable)
                            + File.separator
                            + pathProvider.getHDFFileName(pluginName,
                                    persistable);
                    newFileEntries.add(path);
                    List<PersistableDataObject> list = pdoMap.get(path);
                    if (list == null) {
                        list = new ArrayList<PersistableDataObject>(pdos.size());
                        pdoMap.put(path, list);
                    }
                    list.add(pdo);
                }
            } else {
                // order files by refTime hours
                for (PersistableDataObject pdo : pdos) {
                    String timeString = null;
                    if (pdo instanceof PluginDataObject) {
                        PluginDataObject pluginDataObj = (PluginDataObject) pdo;
                        Date time = pluginDataObj.getDataTime()
                                .getRefTimeAsCalendar().getTime();

                        synchronized (DefaultPathProvider.fileNameFormat) {
                            timeString = DefaultPathProvider.fileNameFormat
                                    .format(time);
                        }
                    } else {
                        // no refTime to use bounded insert query bounds
                        Date time = startTime.getTime();

                        synchronized (DefaultPathProvider.fileNameFormat) {
                            timeString = DefaultPathProvider.fileNameFormat
                                    .format(time);
                        }
                    }

                    String path = pluginName + timeString;
                    newFileEntries.add(path);
                    List<PersistableDataObject> list = pdoMap.get(path);
                    if (list == null) {
                        list = new ArrayList<PersistableDataObject>(pdos.size());
                        pdoMap.put(path, list);
                    }
                    list.add(pdo);
                }

            }
        }

        Iterator<String> iter = pdoMap.keySet().iterator();
        Map<String, List<PersistableDataObject>> pdosToSave = new HashMap<String, List<PersistableDataObject>>(
                pdoMap.size() - newFileEntries.size());

        while (iter.hasNext()) {
            String key = iter.next();
            if (!newFileEntries.contains(key)) {
                pdosToSave.put(key, pdoMap.get(key));
                iter.remove();
            }
        }

        return pdosToSave;
    }

    protected void savePdoMap(String pluginName, String archivePath,
            Map<String, List<PersistableDataObject>> pdoMap)
            throws SerializationException, IOException {
        for (Map.Entry<String, List<PersistableDataObject>> entry : pdoMap
                .entrySet()) {
            String path = archivePath + File.separator + pluginName
                    + File.separator + entry.getKey();

            // remove .h5
            int index = path.lastIndexOf('.');
            if (index > 0 && path.length() - index < 5) {
                // ensure its end of string in case extension is
                // dropped/changed
                path = path.substring(0, index);
            }

            path += ".bin.gz";

            File file = new File(path);
            List<PersistableDataObject> pdosToSerialize = entry.getValue();

            if (file.exists()) {
                // save list to disk (in gz format?)
                byte[] data = FileUtil.file2bytes(file, true);

                // debug transform back for object inspection
                @SuppressWarnings("unchecked")
                List<PersistableDataObject> prev = (List<PersistableDataObject>) SerializationUtil
                        .transformFromThrift(data);
                prev.addAll(pdosToSerialize);
                pdosToSerialize = prev;
            }

            // Thrift serialize pdo list
            byte[] data = SerializationUtil.transformToThrift(pdosToSerialize);

            // save list to disk (in gz format?)
            FileUtil.bytes2File(data, file, true);
        }
    }

    protected Calendar determineStartTime(String pluginName, String extraInfo,
            Calendar runTime, PluginDao dao, DataArchiveConfig conf)
            throws DataAccessLayerException {
        Calendar startTime = null;

        // get previous run time
        if (extraInfo != null && extraInfo.length() > 0) {
            try {
                Date prevDate = DATE_FORMAT.parse(extraInfo);

                // cloning runTime as it already has the correct time zone
                startTime = (Calendar) runTime.clone();
                startTime.setTimeInMillis(prevDate.getTime());
            } catch (ParseException e) {
                statusHandler.error(pluginName
                        + ": Unable to parse last run time [" + extraInfo
                        + "], will archive all data up to current time", e);
                startTime = null;
            }
        }

        // protect against time failure where startTime is more than
        // MIN_DURATION in the future
        if (startTime != null) {
            if ((startTime.getTimeInMillis() - runTime.getTimeInMillis()) > MIN_DURATION_MILLIS) {
                statusHandler
                        .warn(pluginName
                                + ": Previous run time is a future time, reseting to current time.  Check server times");
                startTime = (Calendar) runTime.clone();
            }
        } else {
            // startTime has never been set lookup earliest start time
            Date minInsert = dao.getMinInsertTime("");
            if (minInsert != null) {
                startTime = Calendar.getInstance();
                startTime.setTimeZone(TimeZone.getTimeZone("GMT"));
                startTime.setTimeInMillis(minInsert.getTime());
            } else {
                // if no data for plugin in db, set startTime to runTime
                startTime = (Calendar) runTime.clone();
            }
        }

        // earliest time based on default retention
        long earliestTime = System.currentTimeMillis()
                - (conf.getHoursToKeep() * 60 * 60 * 1000);
        if (startTime.getTimeInMillis() < earliestTime) {
            startTime.setTimeInMillis(earliestTime);
        }

        return startTime;
    }

    /**
     * Determines the endTime to bound the next query by. Uses
     * MAX_DURATION_MILLIS and MIN_DURATION_MILLIS to determine endTime based on
     * startTime and runTime. If starTime + MIN_DURATION_MILLIS < runTime, will
     * return null.
     * 
     * @param startTime
     *            Starting time bound for query.
     * @param runTime
     *            Time of current archive run.
     * @return
     */
    protected Calendar determineEndTime(Calendar startTime, Calendar runTime) {
        Calendar endTime = null;
        long timeDiff = runTime.getTimeInMillis() - startTime.getTimeInMillis();

        if (timeDiff > MAX_DURATION_MILLIS) {
            endTime = (Calendar) startTime.clone();
            endTime.setTimeInMillis(endTime.getTimeInMillis()
                    + MAX_DURATION_MILLIS);
        } else if (timeDiff > MIN_DURATION_MILLIS) {
            endTime = (Calendar) runTime.clone();
        }

        return endTime;
    }
}
