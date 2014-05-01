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

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * LatestobsvalueId generated by hbm2java
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
public class LatestobsvalueId extends com.raytheon.uf.common.dataplugin.persist.PersistableDataObject implements java.io.Serializable {

    private static final long serialVersionUID = 1L;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String lid;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String pe;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private short dur;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String ts;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String extremum;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Date obstime;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Double value;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Short revision;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String shefQualCode;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Integer qualityCode;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private String productId;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Date producttime;

    @com.raytheon.uf.common.serialization.annotations.DynamicSerializeElement
    private Date postingtime;

    public LatestobsvalueId() {
    }

    public LatestobsvalueId(String lid, String pe, short dur, String ts,
            String extremum) {
        this.lid = lid;
        this.pe = pe;
        this.dur = dur;
        this.ts = ts;
        this.extremum = extremum;
    }

    public LatestobsvalueId(String lid, String pe, short dur, String ts,
            String extremum, Date obstime, Double value, Short revision,
            String shefQualCode, Integer qualityCode, String productId,
            Date producttime, Date postingtime) {
        this.lid = lid;
        this.pe = pe;
        this.dur = dur;
        this.ts = ts;
        this.extremum = extremum;
        this.obstime = obstime;
        this.value = value;
        this.revision = revision;
        this.shefQualCode = shefQualCode;
        this.qualityCode = qualityCode;
        this.productId = productId;
        this.producttime = producttime;
        this.postingtime = postingtime;
    }

    @Column(name = "lid", nullable = false, length = 8)
    public String getLid() {
        return this.lid;
    }

    public void setLid(String lid) {
        this.lid = lid;
    }

    @Column(name = "pe", nullable = false, length = 2)
    public String getPe() {
        return this.pe;
    }

    public void setPe(String pe) {
        this.pe = pe;
    }

    @Column(name = "dur", nullable = false)
    public short getDur() {
        return this.dur;
    }

    public void setDur(short dur) {
        this.dur = dur;
    }

    @Column(name = "ts", nullable = false, length = 2)
    public String getTs() {
        return this.ts;
    }

    public void setTs(String ts) {
        this.ts = ts;
    }

    @Column(name = "extremum", nullable = false, length = 1)
    public String getExtremum() {
        return this.extremum;
    }

    public void setExtremum(String extremum) {
        this.extremum = extremum;
    }

    @Column(name = "obstime", length = 29)
    public Date getObstime() {
        return this.obstime;
    }

    public void setObstime(Date obstime) {
        this.obstime = obstime;
    }

    @Column(name = "value", precision = 17, scale = 17)
    public Double getValue() {
        return this.value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    @Column(name = "revision")
    public Short getRevision() {
        return this.revision;
    }

    public void setRevision(Short revision) {
        this.revision = revision;
    }

    @Column(name = "shef_qual_code", length = 1)
    public String getShefQualCode() {
        return this.shefQualCode;
    }

    public void setShefQualCode(String shefQualCode) {
        this.shefQualCode = shefQualCode;
    }

    @Column(name = "quality_code")
    public Integer getQualityCode() {
        return this.qualityCode;
    }

    public void setQualityCode(Integer qualityCode) {
        this.qualityCode = qualityCode;
    }

    @Column(name = "product_id", length = 10)
    public String getProductId() {
        return this.productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    @Column(name = "producttime", length = 29)
    public Date getProducttime() {
        return this.producttime;
    }

    public void setProducttime(Date producttime) {
        this.producttime = producttime;
    }

    @Column(name = "postingtime", length = 29)
    public Date getPostingtime() {
        return this.postingtime;
    }

    public void setPostingtime(Date postingtime) {
        this.postingtime = postingtime;
    }

    public boolean equals(Object other) {
        if ((this == other))
            return true;
        if ((other == null))
            return false;
        if (!(other instanceof LatestobsvalueId))
            return false;
        LatestobsvalueId castOther = (LatestobsvalueId) other;

        return ((this.getLid() == castOther.getLid()) || (this.getLid() != null
                && castOther.getLid() != null && this.getLid().equals(
                castOther.getLid())))
                && ((this.getPe() == castOther.getPe()) || (this.getPe() != null
                        && castOther.getPe() != null && this.getPe().equals(
                        castOther.getPe())))
                && (this.getDur() == castOther.getDur())
                && ((this.getTs() == castOther.getTs()) || (this.getTs() != null
                        && castOther.getTs() != null && this.getTs().equals(
                        castOther.getTs())))
                && ((this.getExtremum() == castOther.getExtremum()) || (this
                        .getExtremum() != null
                        && castOther.getExtremum() != null && this
                        .getExtremum().equals(castOther.getExtremum())))
                && ((this.getObstime() == castOther.getObstime()) || (this
                        .getObstime() != null
                        && castOther.getObstime() != null && this.getObstime()
                        .equals(castOther.getObstime())))
                && ((this.getValue() == castOther.getValue()) || (this
                        .getValue() != null
                        && castOther.getValue() != null && this.getValue()
                        .equals(castOther.getValue())))
                && ((this.getRevision() == castOther.getRevision()) || (this
                        .getRevision() != null
                        && castOther.getRevision() != null && this
                        .getRevision().equals(castOther.getRevision())))
                && ((this.getShefQualCode() == castOther.getShefQualCode()) || (this
                        .getShefQualCode() != null
                        && castOther.getShefQualCode() != null && this
                        .getShefQualCode().equals(castOther.getShefQualCode())))
                && ((this.getQualityCode() == castOther.getQualityCode()) || (this
                        .getQualityCode() != null
                        && castOther.getQualityCode() != null && this
                        .getQualityCode().equals(castOther.getQualityCode())))
                && ((this.getProductId() == castOther.getProductId()) || (this
                        .getProductId() != null
                        && castOther.getProductId() != null && this
                        .getProductId().equals(castOther.getProductId())))
                && ((this.getProducttime() == castOther.getProducttime()) || (this
                        .getProducttime() != null
                        && castOther.getProducttime() != null && this
                        .getProducttime().equals(castOther.getProducttime())))
                && ((this.getPostingtime() == castOther.getPostingtime()) || (this
                        .getPostingtime() != null
                        && castOther.getPostingtime() != null && this
                        .getPostingtime().equals(castOther.getPostingtime())));
    }

    public int hashCode() {
        int result = 17;

        result = 37 * result
                + (getLid() == null ? 0 : this.getLid().hashCode());
        result = 37 * result + (getPe() == null ? 0 : this.getPe().hashCode());
        result = 37 * result + this.getDur();
        result = 37 * result + (getTs() == null ? 0 : this.getTs().hashCode());
        result = 37 * result
                + (getExtremum() == null ? 0 : this.getExtremum().hashCode());
        result = 37 * result
                + (getObstime() == null ? 0 : this.getObstime().hashCode());
        result = 37 * result
                + (getValue() == null ? 0 : this.getValue().hashCode());
        result = 37 * result
                + (getRevision() == null ? 0 : this.getRevision().hashCode());
        result = 37
                * result
                + (getShefQualCode() == null ? 0 : this.getShefQualCode()
                        .hashCode());
        result = 37
                * result
                + (getQualityCode() == null ? 0 : this.getQualityCode()
                        .hashCode());
        result = 37 * result
                + (getProductId() == null ? 0 : this.getProductId().hashCode());
        result = 37
                * result
                + (getProducttime() == null ? 0 : this.getProducttime()
                        .hashCode());
        result = 37
                * result
                + (getPostingtime() == null ? 0 : this.getPostingtime()
                        .hashCode());
        return result;
    }

}
