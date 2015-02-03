package gov.noaa.gsd.viz.ensemble.display.control;

import gov.noaa.gsd.viz.ensemble.navigator.ui.layer.EnsembleToolManager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.viz.core.drawables.IDescriptor;
import com.raytheon.uf.viz.core.drawables.IRenderableDisplay;
import com.raytheon.uf.viz.core.drawables.ResourcePair;
import com.raytheon.uf.viz.core.exception.VizException;
import com.raytheon.uf.viz.core.rsc.AbstractVizResource;
import com.raytheon.uf.viz.core.rsc.IInitListener;
import com.raytheon.uf.viz.core.rsc.ResourceList;
import com.raytheon.uf.viz.core.rsc.ResourceList.AddListener;
import com.raytheon.uf.viz.core.rsc.ResourceList.RemoveListener;
import com.raytheon.uf.viz.xy.timeseries.rsc.TimeSeriesResource;
import com.raytheon.viz.grid.rsc.general.GridResource;
import com.raytheon.viz.ui.EditorUtil;
import com.raytheon.viz.ui.editor.AbstractEditor;
import com.raytheon.viz.ui.perspectives.IRenderableDisplayCustomizer;

/**
 * The ensemble tool renderable display customizer classes contain the event
 * handlers that keeps track of when new displays are created or removed, and
 * listens also for when resources get added or removed from those displays.
 * 
 * TODO: We need verify whether we need only keep track of displays that are
 * created when the ensemble tool is "on". This is problematic for the very
 * first display because the ensemble tool would like to "know" of that display
 * but is not "on" by default. So how do we know that the new display is the
 * very first display created (i.e. initial "Map" editor display).
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer          Description
 * ------------ ---------- -----------    --------------------------
 * Dec 9, 2014    5056    epolster jing      Initial creation
 * 
 * </pre>
 * 
 * @author polster
 * @author jing
 * @version 1.0
 */
public class EnsembleToolDisplayCustomizer implements
        IRenderableDisplayCustomizer {

    private final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(EnsembleToolDisplayCustomizer.class);

    static final private List<ResourcePair> batchedPairs = new CopyOnWriteArrayList<ResourcePair>();

    /** List of listeners we have for renderable displays */
    private final List<EnsembleToolRscLoadListener> listeners = new ArrayList<EnsembleToolRscLoadListener>();

    @Override
    public void customizeDisplay(IRenderableDisplay display) {

        // TODO: if (EnsembleToolManager.getInstance().isReady()) {
        boolean add = true;
        for (EnsembleToolRscLoadListener listener : listeners) {
            if (display == listener.getDisplay()) {
                add = false;
                break;
            }
        }

        if (add) {
            listeners.add(new EnsembleToolRscLoadListener(display));
        }

        if (EnsembleToolManager.getInstance().isReady()) {
            EnsembleToolManager.getInstance().prepareForNewEditor();
        }
    }

    @Override
    public void uncustomizeDisplay(IRenderableDisplay display) {

        // TODO: if (EnsembleToolManager.getInstance().isReady()) {
        EnsembleToolRscLoadListener toRemove = null;
        for (EnsembleToolRscLoadListener listener : listeners) {
            if (listener.getDisplay() == display) {
                toRemove = listener;
                break;
            }
        }
        if (toRemove != null) {
            toRemove.dispose();
            listeners.remove(toRemove);
        }
    }

    private static class EnsembleToolRscLoadListener implements AddListener,
            RemoveListener, IInitListener {

        /*
         * For batching purposes, keep track of the amount of time spent between
         * requests
         */
        private static long LAST_TIME = 0;

        /*
         * Maximum wait period for batching; this value was chosen as the
         * minimum necessary wait time for a two-ensemble load (e.g. 500MB and
         * 850MB Heights). By waiting this long, both full products sets will
         * get batched into one load (at least on a typically performant
         * machine).
         */

        private final int ALLOW_FOR_BUNCHED_REQUESTS_PERIOD = 1800;

        // thread which acts upon batched requests
        private Thread forceReset = null;

        // the display we are listening to
        private final IRenderableDisplay display;

        public EnsembleToolRscLoadListener(IRenderableDisplay display) {
            this.display = display;
            IDescriptor descriptor = display.getDescriptor();
            ResourceList list = descriptor.getResourceList();
            list.addPostAddListener(this);
            list.addPostRemoveListener(this);
        }

        public void dispose() {
            ResourceList list = display.getDescriptor().getResourceList();
            list.removePostAddListener(this);
            list.removePostRemoveListener(this);
        }

        /**
         * Notice a resource has been removed. (non-Javadoc)
         * 
         * @see com.raytheon.uf.viz.core.rsc.ResourceList.RemoveListener#notifyRemove
         *      (com.raytheon.uf.viz.core.drawables.ResourcePair) TODO: This
         *      approach will be improved in an upcoming DR
         */
        @Override
        public synchronized void notifyRemove(ResourcePair rp)
                throws VizException {
            /**
             * Pass,if the resource is not interested by ensemble tool
             * 
             */
            if (!isCompatibleResource(rp)) {
                return;
            }
            /**
             * Remove it from the resource manager and update GUI Should notice
             * GUI
             */
            if (getEditor() != null) {
                EnsembleResourceManager.getInstance().syncRegisteredResource(
                        getEditor());
            }

        }

        /**
         * Notice a resource has been added. (non-Javadoc)
         * 
         * @see com.raytheon.uf.viz.core.rsc.ResourceList.AddListener#notifyAdd(com
         *      .raytheon .uf.viz.core.drawables.ResourcePair)
         */
        @Override
        public void notifyAdd(ResourcePair rp) throws VizException {

            /**
             * Return if the resource is not interested by ensemble tool
             * 
             */
            if (!isCompatibleResource(rp)) {
                return;
            }

            // add the resource pair to the staging list ...
            rp.getResource().registerListener((IInitListener) this);
            synchronized (batchedPairs) {
                batchedPairs.add(rp);
            }
        }

        /**
         * Pass a resource into the ensemble resource manager.
         * 
         * @param resourcePairs
         */
        private void addBatchedResourcesToManager() {

            Iterator<ResourcePair> pairsIter = batchedPairs.iterator();
            ResourcePair rp = null;

            while (pairsIter.hasNext()) {

                rp = pairsIter.next();
                if (pairsIter.hasNext()) {
                    EnsembleResourceManager.getInstance().registerResource(
                            rp.getResource(), getEditor(), false);

                } else {
                    EnsembleResourceManager.getInstance().registerResource(
                            rp.getResource(), getEditor(), true);
                }
            }
            synchronized (batchedPairs) {
                batchedPairs.clear();
            }
        }

        /**
         * Get the current Editor.
         * 
         * @return
         */
        private static AbstractEditor getEditor() {
            AbstractEditor editor = (AbstractEditor) EditorUtil
                    .getActiveEditor();
            return editor;
        }

        private boolean isCompatibleResource(ResourcePair rp) {
            AbstractVizResource<?, ?> resource = rp.getResource();
            if ((resource != null)
                    && ((resource instanceof GridResource) || (resource instanceof TimeSeriesResource))) {
                return true;
            }
            return false;
        }

        /*
         * (non-Javadoc)
         * 
         * @see
         * com.raytheon.uf.viz.core.rsc.IInitListener#inited(com.raytheon.uf
         * .viz.core.rsc.AbstractVizResource)
         */
        @Override
        public synchronized void inited(AbstractVizResource<?, ?> rsc) {

            /*
             * ensemble resources can come in a bunch ... wait for some time to
             * pass to batch them ...
             */
            if (((LAST_TIME == 0) || ((System.currentTimeMillis() - LAST_TIME) > ALLOW_FOR_BUNCHED_REQUESTS_PERIOD))) {

                /*
                 * TODO: this thread may be superstitious yet is being left here
                 * until we can verify it is not needed. The very first time any
                 * resource is inited we sleep for small period to allow other
                 * similar threads (e.g. in other plug-ins) to have priority in
                 * acting on the resource.
                 */
                if (LAST_TIME == 0) {
                    // poor man's object.wait() for the very first time through
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException e) {
                        // ignore
                    }
                }

                /**
                 * Register the resource in to the resource manager
                 */
                if (forceReset != null) {
                    synchronized (forceReset) {
                        // restart the timer for another interval to pass
                        // before forcing a "final" refresh
                        if (forceReset.isAlive()) {
                            forceReset.interrupt();
                        }
                        forceReset = null;
                        forceReset = new Thread(new ForceRefreshIfNecessary(
                                ALLOW_FOR_BUNCHED_REQUESTS_PERIOD));
                        forceReset.start();
                    }
                } else {
                    forceReset = new Thread(new ForceRefreshIfNecessary(
                            ALLOW_FOR_BUNCHED_REQUESTS_PERIOD));
                    forceReset.start();
                }
            } else {
                LAST_TIME = System.currentTimeMillis();
            }

        }

        private class ForceRefreshIfNecessary implements Runnable {

            int waitForReset = 0;

            ForceRefreshIfNecessary(int waitTime) {
                waitForReset = waitTime;
            }

            @Override
            public void run() {

                try {

                    Thread.sleep(waitForReset);
                    addBatchedResourcesToManager();

                } catch (InterruptedException e) {
                    /* ignore */
                }
            }
        }

        /**
         * Get the IRenderableDisplay
         * 
         * @return the display
         */
        public IRenderableDisplay getDisplay() {
            return display;
        }
    }

}
