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
package com.raytheon.uf.edex.datadelivery.bandwidth.dao;

import java.util.Random;

import com.raytheon.uf.common.datadelivery.registry.Subscription;
import com.raytheon.uf.common.datadelivery.registry.SubscriptionFixture;
import com.raytheon.uf.common.serialization.SerializationException;
import com.raytheon.uf.common.util.AbstractFixture;
import com.raytheon.uf.edex.datadelivery.bandwidth.util.BandwidthUtil;

/**
 * TODO Add Description
 * 
 * <pre>
 *
 * SOFTWARE HISTORY
 *
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Nov 13, 2012            djohnson     Initial creation
 *
 * </pre>
 *
 * @author djohnson
 * @version 1.0	
 */

public class SubscriptionDaoFixture extends AbstractFixture<BandwidthSubscription> {

    public static final SubscriptionDaoFixture INSTANCE = new SubscriptionDaoFixture();

    /**
     * Private.
     */
    private SubscriptionDaoFixture() {

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public BandwidthSubscription getInstance(long seedValue, Random random) {
        Subscription sub = SubscriptionFixture.INSTANCE.get(seedValue);
        try {
            return BandwidthUtil.getSubscriptionDaoForSubscription(sub,
                    BandwidthUtil.now());
        } catch (SerializationException e) {
            throw new RuntimeException(e);
        }
    }

}
