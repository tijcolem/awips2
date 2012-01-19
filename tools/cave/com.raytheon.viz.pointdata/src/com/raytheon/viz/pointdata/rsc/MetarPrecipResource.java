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
package com.raytheon.viz.pointdata.rsc;

import java.awt.Font;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.concurrent.LinkedBlockingQueue;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.swt.graphics.RGB;
import org.opengis.referencing.FactoryException;
import org.opengis.referencing.crs.CoordinateReferenceSystem;
import org.opengis.referencing.operation.TransformException;

import com.raytheon.uf.common.dataplugin.PluginDataObject;
import com.raytheon.uf.common.dataquery.requests.RequestConstraint;
import com.raytheon.uf.common.dataquery.requests.RequestConstraint.ConstraintType;
import com.raytheon.uf.common.geospatial.ReferencedCoordinate;
import com.raytheon.uf.common.time.DataTime;
import com.raytheon.uf.viz.core.DrawableString;
import com.raytheon.uf.viz.core.IExtent;
import com.raytheon.uf.viz.core.IGraphicsTarget;
import com.raytheon.uf.viz.core.IGraphicsTarget.HorizontalAlignment;
import com.raytheon.uf.viz.core.IGraphicsTarget.VerticalAlignment;
import com.raytheon.uf.viz.core.RecordFactory;
import com.raytheon.uf.viz.core.drawables.IDescriptor.FramesInfo;
import com.raytheon.uf.viz.core.drawables.IFont;
import com.raytheon.uf.viz.core.drawables.IFont.Style;
import com.raytheon.uf.viz.core.drawables.IRenderableDisplay;
import com.raytheon.uf.viz.core.drawables.PaintProperties;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.map.IMapDescriptor;
import com.raytheon.uf.viz.core.rsc.AbstractVizResource;
import com.raytheon.uf.viz.core.rsc.IResourceDataChanged;
import com.raytheon.uf.viz.core.rsc.LoadProperties;
import com.raytheon.uf.viz.core.rsc.capabilities.ColorableCapability;
import com.raytheon.uf.viz.core.rsc.capabilities.DensityCapability;
import com.raytheon.uf.viz.core.rsc.capabilities.MagnificationCapability;
import com.raytheon.viz.pointdata.util.MetarPrecipDataContainer;
import com.raytheon.viz.pointdata.util.MetarPrecipDataContainer.PrecipData;
import com.vividsolutions.jts.geom.Coordinate;

/**
 * 
 * TODO Add Description
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Aug 19, 2011            bsteffen     Initial creation
 * 
 * </pre>
 * 
 * @author bsteffen
 * @version 1.0
 */
public class MetarPrecipResource extends
        AbstractVizResource<MetarPrecipResourceData, IMapDescriptor> {

    private static final int PLOT_PIXEL_SIZE = 30;

    private class RenderablePrecipData extends PrecipData {

        Double distValue = 0.0;

        DrawableString string = null;

        public RenderablePrecipData(PrecipData data) {
            super(data.getTimeObs(), data.getStationName(),
                    data.getPrecipAmt(), data.getLatLon().x, data.getLatLon().y);
        }

    }

    // To avoid synchronization issues with data request, updates, and removals
    // do it all on this thread.
    private Job dataProcessJob = new Job("Loading Precip Data") {

        @Override
        protected IStatus run(IProgressMonitor monitor) {
            processNewFrames(monitor);
            if (monitor.isCanceled()) {
                return Status.CANCEL_STATUS;
            }
            processUpdates(monitor);

            if (monitor.isCanceled()) {
                return Status.CANCEL_STATUS;
            }
            processRemoves();
            if (monitor.isCanceled()) {
                return Status.CANCEL_STATUS;
            }
            processReproject();
            return Status.OK_STATUS;
        }

    };

    private LinkedBlockingQueue<PluginDataObject> updates = new LinkedBlockingQueue<PluginDataObject>();

    private LinkedBlockingQueue<DataTime> removes = new LinkedBlockingQueue<DataTime>();

    private boolean reproject = false;

    private Map<DataTime, List<RenderablePrecipData>> data = new HashMap<DataTime, List<RenderablePrecipData>>();

    private IFont font = null;

    protected MetarPrecipResource(MetarPrecipResourceData resourceData,
            LoadProperties loadProperties) {
        super(resourceData, loadProperties);

    }

    @Override
    protected void disposeInternal() {
        if (font != null) {
            font.dispose();
            font = null;
        }
        dataProcessJob.cancel();
    }

    @Override
    protected void paintInternal(IGraphicsTarget target,
            PaintProperties paintProps) throws VizException {
        List<RenderablePrecipData> precips = data.get(paintProps.getDataTime());
        if (precips == null) {
            dataProcessJob.schedule();
            return;
        }
        if (precips.isEmpty()) {
            return;
        }

        RGB color = getCapability(ColorableCapability.class).getColor();
        Double magnification = getCapability(MagnificationCapability.class)
                .getMagnification();
        Double density = getCapability(DensityCapability.class).getDensity();

        if (font == null) {
            font = target.initializeFont(Font.DIALOG, 10,
                    new Style[] { Style.BOLD });
            font.setMagnification(magnification.floatValue());
        }

        List<DrawableString> strings = new ArrayList<DrawableString>();

        IExtent extent = paintProps.getView().getExtent();

        double threshold = PLOT_PIXEL_SIZE * magnification / density;
        threshold = threshold * extent.getWidth()
                / paintProps.getCanvasBounds().width;

        for (RenderablePrecipData data : precips) {
            if (!extent.contains(new double[] { data.string.basics.x,
                    data.string.basics.y })) {
                continue;
            }
            if (data.distValue >= threshold) {
                // This is easier then changing it when the capability cahnges.
                data.string.font = this.font;
                data.string.setText(data.string.getText(), color);
                strings.add(data.string);
            }
        }

        target.drawStrings(strings);
    }

    @Override
    protected void initInternal(IGraphicsTarget target) throws VizException {

        dataTimes = new ArrayList<DataTime>();
        dataProcessJob.schedule();
        resourceData.addChangeListener(new IResourceDataChanged() {

            @Override
            public void resourceChanged(ChangeType type, Object object) {
                if (type == ChangeType.CAPABILITY) {
                    if (object instanceof MagnificationCapability) {
                        if (font != null) {
                            font.dispose();
                            font = null;
                        }
                    }
                    issueRefresh();
                } else if (type == ChangeType.DATA_UPDATE) {
                    if (object instanceof PluginDataObject[]) {
                        PluginDataObject[] pdos = (PluginDataObject[]) object;
                        for (PluginDataObject pdo : pdos) {
                            updates.offer(pdo);
                            dataProcessJob.schedule();
                        }
                    }
                }
            }
        });
    }

    @Override
    public String getName() {
        return "METAR " + resourceData.getDuration() + "hr Precip";
    }

    @Override
    public void remove(DataTime dataTime) {
        removes.offer(dataTime);
        dataProcessJob.schedule();
    }

    @Override
    public void project(CoordinateReferenceSystem crs) throws VizException {
        reproject = true;
        dataProcessJob.schedule();
    }

    @Override
    public String inspect(ReferencedCoordinate coord) throws VizException {
        Coordinate pixel = null;
        try {
            pixel = coord.asPixel(descriptor.getGridGeometry());
        } catch (TransformException e) {
            throw new VizException(e);
        } catch (FactoryException e) {
            throw new VizException(e);
        }

        Double magnification = getCapability(MagnificationCapability.class)
                .getMagnification();

        List<RenderablePrecipData> precips = data.get(descriptor
                .getTimeForResource(this));

        if (precips == null || precips.isEmpty()) {
            return null;
        }

        IRenderableDisplay rDisplay = descriptor.getRenderableDisplay();

        double bestDist = PLOT_PIXEL_SIZE * magnification;
        if (rDisplay != null) {
            bestDist *= rDisplay.getView().getExtent().getWidth()
                    / rDisplay.getBounds().width;
        } else {
            bestDist *= 100;
        }

        PrecipData bestData = null;

        for (RenderablePrecipData precip : precips) {
            double xDist = precip.string.basics.x - pixel.x;
            double yDist = precip.string.basics.y - pixel.y;
            double dist = Math.hypot(xDist, yDist);
            if (dist < bestDist) {
                bestDist = dist;
                bestData = precip;
            }
        }
        if (bestData != null) {
            return bestData.getStationName();
        }
        return "No Data";
    }

    private void processReproject() {
        if (reproject) {
            reproject = false;
            for (List<RenderablePrecipData> dataList : data.values()) {
                for (RenderablePrecipData precip : dataList) {
                    Coordinate latLon = precip.getLatLon();
                    double[] px = descriptor.worldToPixel(new double[] {
                            latLon.x, latLon.y });
                    precip.string.setCoordinates(px[0], px[1], px[2]);
                }
            }
        }
        issueRefresh();
    }

    private void processRemoves() {
        while (!removes.isEmpty()) {
            DataTime toRemove = removes.poll();
            this.dataTimes.remove(toRemove);
            this.data.remove(toRemove);
        }
    }

    private void processUpdates(IProgressMonitor monitor) {
        if (updates.isEmpty()) {
            return;
        }
        HashMap<String, RequestConstraint> rcMap = resourceData
                .getMetadataMap();
        rcMap = new HashMap<String, RequestConstraint>(rcMap);
        RequestConstraint rc = new RequestConstraint(null, ConstraintType.IN);
        long earliestTime = Long.MAX_VALUE;
        Set<String> newStations = new HashSet<String>();
        while (!updates.isEmpty()) {
            PluginDataObject pdo = updates.poll();
            try {
                Map<String, Object> map = RecordFactory.getInstance()
                        .loadMapFromUri(pdo.getDataURI());
                newStations.add(map.get("location.stationId").toString());
            } catch (VizException e) {
                throw new RuntimeException(e);
            }
            long validTime = pdo.getDataTime().getMatchValid();
            if (validTime < earliestTime) {
                earliestTime = validTime;
            }
        }
        rc.setConstraintValueList(newStations.toArray(new String[0]));
        rcMap.put("location.stationId", rc);
        MetarPrecipDataContainer container = new MetarPrecipDataContainer(
                resourceData.getDuration(), rcMap);
        for (Entry<DataTime, List<RenderablePrecipData>> entry : data
                .entrySet()) {
            DataTime time = entry.getKey();
            if (time.getMatchValid() < earliestTime) {
                // No need to reprocess times after the earliest update.
                continue;
            }
            Iterator<RenderablePrecipData> iter = entry.getValue().iterator();
            while (iter.hasNext()) {
                if (newStations.contains(iter.next().getStationName())) {
                    iter.remove();
                }
            }
            addData(time, container.getBasePrecipData(time));
            addData(time, container.getDerivedPrecipData(time));
            if (monitor.isCanceled()) {
                return;
            }
        }
    }

    private void processNewFrames(IProgressMonitor monitor) {

        // load data in two steps, first load base data then any derived data.
        // Always try to load the current frame, then nearby frames.
        MetarPrecipDataContainer container = new MetarPrecipDataContainer(
                resourceData.getDuration(), resourceData.getMetadataMap());
        Set<DataTime> baseOnly = new HashSet<DataTime>();
        boolean modified = true;
        while (modified) {
            // don't want to mis a reproject if retrieval takes awhile.
            processReproject();
            if (monitor.isCanceled()) {
                return;
            }
            modified = false;
            // If the current frame changes while we are processing we will
            // begin requesting data for the new frame
            FramesInfo frameInfo = descriptor.getFramesInfo();
            DataTime[] times = frameInfo.getTimeMap().get(
                    MetarPrecipResource.this);
            if (times == null) {
                return;
            }
            int curIndex = frameInfo.getFrameIndex();
            int count = frameInfo.getFrameCount();
            // This will generate the number series 0, -1, 1, -2, 2, -3, 3...
            for (int i = 0; i < count / 2 + 1; i = i < 0 ? -i : -i - 1) {
                int index = (count + curIndex + i) % count;
                DataTime next = times[index];
                if (next != null) {
                    if (!data.containsKey(next)) {
                        List<PrecipData> baseData = container
                                .getBasePrecipData(next);
                        addData(next, baseData);
                        baseOnly.add(next);
                        modified = true;
                        break;
                    }
                    if (baseOnly.contains(next)) {
                        List<PrecipData> baseData = container
                                .getDerivedPrecipData(next);
                        addData(next, baseData);
                        baseOnly.remove(next);
                        modified = true;
                        break;
                    }
                }
            }
        }
        // This will only happen if frames were removed while we were processing
        // DOn't leave any half created frames
        for (DataTime time : baseOnly) {
            this.dataTimes.remove(time);
            this.data.remove(time);
        }
    }

    private void addData(DataTime time, List<PrecipData> precips) {
        if (precips.isEmpty()) {
            if (!dataTimes.contains(time)) {
                List<RenderablePrecipData> newPrecips = Collections.emptyList();
                data.put(time, newPrecips);
                dataTimes.add(time);
            }
        }
        if (data.containsKey(time)) {
            precips = new ArrayList<PrecipData>(precips);
            for (RenderablePrecipData pData : data.get(time)) {
                precips.add(pData);
            }
        }
        Collections.sort(precips, new Comparator<PrecipData>() {

            @Override
            public int compare(PrecipData o1, PrecipData o2) {
                return o2.getPrecipAmt().compareTo(o1.getPrecipAmt());
            }

        });

        List<RenderablePrecipData> newPrecips = new ArrayList<RenderablePrecipData>(
                precips.size());

        RGB color = getCapability(ColorableCapability.class).getColor();

        for (int i = 0; i < precips.size(); i++) {
            PrecipData precip = precips.get(i);
            RenderablePrecipData data = null;
            if (precip instanceof RenderablePrecipData) {
                data = (RenderablePrecipData) precip;
            } else {
                data = new RenderablePrecipData(precip);
                double[] px = descriptor.worldToPixel(new double[] {
                        precip.getLatLon().x, precip.getLatLon().y });
                data.string = new DrawableString(formatPrecip(precips.get(i)
                        .getPrecipAmt()), color);
                data.string.setCoordinates(px[0], px[1], px[2]);
                data.string.verticallAlignment = VerticalAlignment.MIDDLE;
                data.string.horizontalAlignment = HorizontalAlignment.CENTER;
            }
            double bestDist = Double.MAX_VALUE;
            for (RenderablePrecipData exist : newPrecips) {
                double xDist = exist.string.basics.x - data.string.basics.x;
                double yDist = exist.string.basics.y - data.string.basics.y;
                double dist = Math.hypot(xDist, yDist);
                if (dist < bestDist) {
                    bestDist = dist;
                }
            }
            data.distValue = bestDist;
            newPrecips.add(data);
        }
        data.put(time, newPrecips);
        if (!dataTimes.contains(time)) {
            dataTimes.add(time);
        }
        issueRefresh();
    }

    private String formatPrecip(Double precipAmt) {
        if (precipAmt < -0.005) {
            return "";
        } else if (precipAmt < 0.005) {
            return "T";
        } else if (precipAmt < 0.015) {
            return ".o1";
        } else if (precipAmt < 0.025) {
            return ".o2";
        } else if (precipAmt < 0.035) {
            return ".o3";
        } else if (precipAmt < 0.045) {
            return ".o4";
        } else if (precipAmt < 0.055) {
            return ".o5";
        } else if (precipAmt < 0.065) {
            return ".o6";
        } else if (precipAmt < 0.075) {
            return ".o7";
        } else if (precipAmt < 0.085) {
            return ".o8";
        } else if (precipAmt < 0.095) {
            return ".o9";
        } else if (precipAmt < 0.495) {
            return String.format("%4.2f", precipAmt).substring(1);
        } else if (precipAmt < 9.995) {
            return String.format("%5.2f", precipAmt).substring(1);
        } else if (precipAmt < 100) {
            return String.format("%6.2f", precipAmt).substring(1);
        } else {
            return "";
        }
    }
}
