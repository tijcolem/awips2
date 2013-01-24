//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vJAXB 2.1.10 in JDK 6 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2012.01.10 at 10:31:13 AM CST 
//


package org.isotc211._2005.gmi;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;
import org.isotc211._2005.gco.RealPropertyType;
import org.isotc211._2005.gmd.MDBandType;


/**
 * Description: extensions to electromagnetic spectrum wavelength description - shortName: BandExt
 * 
 * <p>Java class for MI_Band_Type complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="MI_Band_Type">
 *   &lt;complexContent>
 *     &lt;extension base="{http://www.isotc211.org/2005/gmd}MD_Band_Type">
 *       &lt;sequence>
 *         &lt;element name="bandBoundaryDefinition" type="{http://www.isotc211.org/2005/gmi}MI_BandDefinition_PropertyType" minOccurs="0"/>
 *         &lt;element name="nominalSpatialResolution" type="{http://www.isotc211.org/2005/gco}Real_PropertyType" minOccurs="0"/>
 *         &lt;element name="transferFunctionType" type="{http://www.isotc211.org/2005/gmi}MI_TransferFunctionTypeCode_PropertyType" minOccurs="0"/>
 *         &lt;element name="transmittedPolarisation" type="{http://www.isotc211.org/2005/gmi}MI_PolarisationOrientationCode_PropertyType" minOccurs="0"/>
 *         &lt;element name="detectedPolarisation" type="{http://www.isotc211.org/2005/gmi}MI_PolarisationOrientationCode_PropertyType" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/extension>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MI_Band_Type", propOrder = {
    "bandBoundaryDefinition",
    "nominalSpatialResolution",
    "transferFunctionType",
    "transmittedPolarisation",
    "detectedPolarisation"
})
public class MIBandType
    extends MDBandType
{

    protected MIBandDefinitionPropertyType bandBoundaryDefinition;
    protected RealPropertyType nominalSpatialResolution;
    protected MITransferFunctionTypeCodePropertyType transferFunctionType;
    protected MIPolarisationOrientationCodePropertyType transmittedPolarisation;
    protected MIPolarisationOrientationCodePropertyType detectedPolarisation;

    /**
     * Gets the value of the bandBoundaryDefinition property.
     * 
     * @return
     *     possible object is
     *     {@link MIBandDefinitionPropertyType }
     *     
     */
    public MIBandDefinitionPropertyType getBandBoundaryDefinition() {
        return bandBoundaryDefinition;
    }

    /**
     * Sets the value of the bandBoundaryDefinition property.
     * 
     * @param value
     *     allowed object is
     *     {@link MIBandDefinitionPropertyType }
     *     
     */
    public void setBandBoundaryDefinition(MIBandDefinitionPropertyType value) {
        this.bandBoundaryDefinition = value;
    }

    /**
     * Gets the value of the nominalSpatialResolution property.
     * 
     * @return
     *     possible object is
     *     {@link RealPropertyType }
     *     
     */
    public RealPropertyType getNominalSpatialResolution() {
        return nominalSpatialResolution;
    }

    /**
     * Sets the value of the nominalSpatialResolution property.
     * 
     * @param value
     *     allowed object is
     *     {@link RealPropertyType }
     *     
     */
    public void setNominalSpatialResolution(RealPropertyType value) {
        this.nominalSpatialResolution = value;
    }

    /**
     * Gets the value of the transferFunctionType property.
     * 
     * @return
     *     possible object is
     *     {@link MITransferFunctionTypeCodePropertyType }
     *     
     */
    public MITransferFunctionTypeCodePropertyType getTransferFunctionType() {
        return transferFunctionType;
    }

    /**
     * Sets the value of the transferFunctionType property.
     * 
     * @param value
     *     allowed object is
     *     {@link MITransferFunctionTypeCodePropertyType }
     *     
     */
    public void setTransferFunctionType(MITransferFunctionTypeCodePropertyType value) {
        this.transferFunctionType = value;
    }

    /**
     * Gets the value of the transmittedPolarisation property.
     * 
     * @return
     *     possible object is
     *     {@link MIPolarisationOrientationCodePropertyType }
     *     
     */
    public MIPolarisationOrientationCodePropertyType getTransmittedPolarisation() {
        return transmittedPolarisation;
    }

    /**
     * Sets the value of the transmittedPolarisation property.
     * 
     * @param value
     *     allowed object is
     *     {@link MIPolarisationOrientationCodePropertyType }
     *     
     */
    public void setTransmittedPolarisation(MIPolarisationOrientationCodePropertyType value) {
        this.transmittedPolarisation = value;
    }

    /**
     * Gets the value of the detectedPolarisation property.
     * 
     * @return
     *     possible object is
     *     {@link MIPolarisationOrientationCodePropertyType }
     *     
     */
    public MIPolarisationOrientationCodePropertyType getDetectedPolarisation() {
        return detectedPolarisation;
    }

    /**
     * Sets the value of the detectedPolarisation property.
     * 
     * @param value
     *     allowed object is
     *     {@link MIPolarisationOrientationCodePropertyType }
     *     
     */
    public void setDetectedPolarisation(MIPolarisationOrientationCodePropertyType value) {
        this.detectedPolarisation = value;
    }

}
