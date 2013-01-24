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
package com.raytheon.uf.common.stats;

import com.raytheon.uf.common.serialization.ISerializableObject;
import com.raytheon.uf.common.serialization.annotations.DynamicSerialize;
import com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement;
import com.raytheon.uf.common.time.TimeRange;

/**
 * Response from the handler of the results in the metadata.aggregate table.
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Aug 21, 2012            jsanchez     Initial creation
 * 
 * @author jsanchez
 * 
 */
@DynamicSerialize
public class AggregatedStatsResponse implements ISerializableObject {
    @DynamicSerializeElement
    private TimeRange timeRange;

    @DynamicSerializeElement
    private String eventType;

    @DynamicSerializeElement
    private String[] grouping;

    @DynamicSerializeElement
    private String field;

    @DynamicSerializeElement
    private AggregateRecord[] records;

    public AggregatedStatsResponse() {

    }

    public AggregatedStatsResponse(TimeRange timeRange, String eventType,
            String[] grouping, String field) {
        this.timeRange = timeRange;
        this.eventType = eventType;
        this.grouping = grouping;
        this.field = field;
    }

    public TimeRange getTimeRange() {
        return timeRange;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String[] getGrouping() {
        return grouping;
    }

    public void setGrouping(String[] grouping) {
        this.grouping = grouping;
    }

    public String getField() {
        return field;
    }

    public void setField(String field) {
        this.field = field;
    }

    public void setTimeRange(TimeRange timeRange) {
        this.timeRange = timeRange;
    }

    public AggregateRecord[] getRecords() {
        return records;
    }

    public void setRecords(AggregateRecord[] records) {
        this.records = records;
    }

}
