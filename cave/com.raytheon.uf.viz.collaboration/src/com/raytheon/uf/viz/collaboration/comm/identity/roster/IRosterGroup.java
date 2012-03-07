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
package com.raytheon.uf.viz.collaboration.comm.identity.roster;

import java.util.Collection;

/**
 * TODO Add Description
 * 
 * <pre>
 *
 * SOFTWARE HISTORY
 *
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Feb 27, 2012            jkorman     Initial creation
 *
 * </pre>
 *
 * @author jkorman
 * @version 1.0	
 */

public interface IRosterGroup extends IRosterItem {

    /**
     * Collection of entries belonging to this group. This method must
     * always return a not null collection with zero or more entries.
     * @return Entries belonging to this group.
     */
    Collection<IRosterEntry> getEntries(); 
    
    /**
     * Collection of nested groups belonging to this group. This method must
     * return a null reference if nested groups are not allowed. If nested
     * groups are allowed the method must return a not null collection with
     * zero or more entries.
     * @return Groups belonging to this group.
     */
    Collection<IRosterGroup> getGroups(); 
    
}
