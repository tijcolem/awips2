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
package com.raytheon.uf.common.dataplugin.shef.tables;
// default package
// Generated Oct 17, 2008 2:22:17 PM by Hibernate Tools 3.2.2.GA

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * ContactsId generated by hbm2java
 * 
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Oct 17, 2008                        Initial generation by hbm2java
 * Aug 19, 2011      10672     jkorman Move refactor to new project
 * Oct 07, 2013       2361     njensen Removed XML annotations
 * 
 * </pre>
 * 
 * @author jkorman
 * @version 1.1
 */
@Embeddable
@com.raytheon.uf.common.serialization.annotations.DynamicSerialize
public class ContactsId extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String lid;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String contact;

    public ContactsId() {
    }

    public ContactsId(String lid, String contact) {
        this.lid = lid;
        this.contact = contact;
    }

    @Column(name = "lid", nullable = false, length = 8)
    public String getLid() {
        return this.lid;
    }

    public void setLid(String lid) {
        this.lid = lid;
    }

    @Column(name = "contact", nullable = false, length = 28)
    public String getContact() {
        return this.contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public boolean equals(Object other) {
        if ((this == other))
            return true;
        if ((other == null))
            return false;
        if (!(other instanceof ContactsId))
            return false;
        ContactsId castOther = (ContactsId) other;

        return ((this.getLid() == castOther.getLid()) || (this.getLid() != null
                && castOther.getLid() != null && this.getLid().equals(
                castOther.getLid())))
                && ((this.getContact() == castOther.getContact()) || (this
                        .getContact() != null
                        && castOther.getContact() != null && this.getContact()
                        .equals(castOther.getContact())));
    }

    public int hashCode() {
        int result = 17;

        result = 37 * result
                + (getLid() == null ? 0 : this.getLid().hashCode());
        result = 37 * result
                + (getContact() == null ? 0 : this.getContact().hashCode());
        return result;
    }

}
