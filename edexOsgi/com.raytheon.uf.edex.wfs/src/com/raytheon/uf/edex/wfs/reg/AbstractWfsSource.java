/*
 * The following software products were developed by Raytheon:
 *
 * ADE (AWIPS Development Environment) software
 * CAVE (Common AWIPS Visualization Environment) software
 * EDEX (Environmental Data Exchange) software
 * uFrame™ (Universal Framework) software
 *
 * Copyright (c) 2010 Raytheon Co.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/org/documents/epl-v10.php
 *
 *
 * Contractor Name: Raytheon Company
 * Contractor Address:
 * 6825 Pine Street, Suite 340
 * Mail Stop B8
 * Omaha, NE 68106
 * 402.291.0100
 *
 *
 * SOFTWARE HISTORY
 *
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * May 9, 2012            bclement     Initial creation
 *
 */
package com.raytheon.uf.edex.wfs.reg;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.hibernate.Criteria;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;

import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.edex.database.dao.CoreDao;
import com.raytheon.uf.edex.ogc.common.AbstractOgcSource;
import com.raytheon.uf.edex.ogc.common.OgcGeoBoundingBox;
import com.raytheon.uf.edex.ogc.common.OgcTimeRange;
import com.raytheon.uf.edex.wfs.WfsException;
import com.raytheon.uf.edex.wfs.WfsException.Code;
import com.raytheon.uf.edex.wfs.WfsFeatureType;
import com.raytheon.uf.edex.wfs.request.QualifiedName;
import com.raytheon.uf.edex.wfs.request.SortBy;

/**
 * Abstract base class for WFS sources
 * 
 * @author bclement
 * @version 1.0
 */
public abstract class AbstractWfsSource<T> extends AbstractOgcSource implements
        IWfsSource {

    protected final String key;

    public static final String defaultCRS = "crs:84";

    public static final OgcGeoBoundingBox fullBbox = new OgcGeoBoundingBox(180,
            -180, 90, -90);

    protected abstract CoreDao getDao() throws Exception;

    protected static final String temporalKey = "dataTime.refTime";

    protected static final IUFStatusHandler statusHandler = UFStatus
            .getHandler(AbstractWfsSource.class);

    protected IFeatureTypeModifier typeModifier = null;

    /**
     * @param key
     *            unique key for this source
     */
    public AbstractWfsSource(String key) {
        this.key = key;
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.edex.wfs.reg.WfsSource#listFeatureTypes()
     */
    @Override
    public List<WfsFeatureType> listFeatureTypes() {
        List<WfsFeatureType> featureTypes = getFeatureTypes();
        if (this.typeModifier == null) {
            return featureTypes;
        }
        return this.typeModifier.modify(featureTypes);
    }

    protected abstract List<WfsFeatureType> getFeatureTypes();

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.edex.wfs.reg.WfsSource#describeFeatureType(com.raytheon
     * .uf.edex.wfs.request.QualifiedName)
     */
    @Override
    public abstract String describeFeatureType(QualifiedName feature)
            throws WfsException;

    /**
     * Utility method for reading text files from the classpath
     * 
     * @param loader
     * @param location
     * @return
     * @throws IOException
     */
    protected String getResource(ClassLoader loader, String location)
            throws IOException {
        String rval;
        InputStream in = null;
        try {
            in = loader.getResourceAsStream(location);
            rval = new java.util.Scanner(in).useDelimiter("\\A").next();
        } catch (Throwable e) {
            throw new IOException(e);
        } finally {
            if (in != null) {
                in.close();
            }
        }
        return rval;
    }

    /**
     * Interacts with database to get features
     * 
     * @param feature
     * @param query
     * @return
     * @throws WfsException
     */
    protected List<T> queryInternal(QualifiedName feature, WfsQuery query)
            throws WfsException {
        query = modQuery(query);
        List<T> rval;
        // TODO get rid of core DAO calls
        Session sess = null;
        try {
            CoreDao dao = getDao();
            sess = dao.getSessionFactory().openSession();
            Criteria criteria = sess.createCriteria(getFeatureEntity(feature));
            criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
            populateCriteria(criteria, query);
            criteria = modCriteria(criteria, query);
            criteria.setMaxResults(query.getMaxResults());
            List<SortBy> sortBys = query.getSortBys();
            addOrder(criteria, sortBys);

            rval = getResults(criteria);

        } catch (Exception e) {
            statusHandler.error("Problem querying for feature", e);
            throw new WfsException(Code.OperationProcessingFailed);
        } finally {
            if (sess != null) {
                sess.close();
            }
        }
        return rval;
    }

    @SuppressWarnings("unchecked")
    protected List<T> getResults(Criteria criteria) {
        return criteria.list();
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.edex.wfs.reg.WfsSource#getFeatureSpatialField(com.raytheon
     * .uf.edex.wfs.request.QualifiedName)
     */
    @Override
    public abstract String getFeatureSpatialField(QualifiedName feature);

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.edex.wfs.reg.WfsSource#getFeatureEntity(com.raytheon.
     * uf.edex.wfs.request.QualifiedName)
     */
    @Override
    public abstract Class<?> getFeatureEntity(QualifiedName feature);

    /**
     * Hook for implementing classes to modify the query object
     * 
     * @param wfsq
     * @return
     */
    protected WfsQuery modQuery(WfsQuery wfsq) {
        return wfsq;
    }

    /**
     * Adds temporal criterion
     * 
     * @param crit
     * @param query
     * @return
     */
    protected Criteria modCriteria(Criteria crit, WfsQuery query) {

        OgcTimeRange otr = query.timeRange;

        if (otr != null) {
            crit.add(Restrictions.between(temporalKey, otr.getStartTime(),
                    otr.getEndTime()));
        }

        return crit;
    }

    /**
     * @param criteria
     * @param sortBys
     */
    protected void addOrder(Criteria criteria, List<SortBy> sortBys) {
        if (sortBys == null || sortBys.isEmpty()) {
            return;
        }
        for (SortBy sb : sortBys) {
            switch (sb.getOrder()) {
            case Ascending:
                criteria.addOrder(Order.asc(sb.getProperty()));
                break;
            case Descending:
                criteria.addOrder(Order.desc(sb.getProperty()));
                break;
            default:
                statusHandler.warn("Unrecognized order: " + sb.getOrder());
            }
        }
    }

    /**
     * @param criteria
     * @param query
     */
    protected void populateCriteria(Criteria criteria, WfsQuery query) {
        query = modQuery(query);
        Criterion criterion = query.getCriterion();
        if (criterion != null) {
            criteria.add(criterion);
        }
        int maxResults = query.getMaxResults();
        if (maxResults > -1) {
            criteria.setMaxResults(maxResults);
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.edex.wfs.reg.WfsSource#distinct(com.raytheon.uf.edex.
     * wfs.request.QualifiedName, com.raytheon.uf.edex.db.api.DatabaseQuery)
     */
    @Override
    public List<String> distinct(QualifiedName feature, WfsQuery query) {
        query = modQuery(query);
        List<String> rval;
        try {
            // List<?> res = getDao().queryByCriteria(query);
            // rval = new ArrayList<String>(res.size());
            // for (Object obj : res) {
            // ConvertUtil converter = BundleContextAccessor
            // .getService(ConvertUtil.class);
            // rval.add(converter.toString(obj));
            // }
            // If you want distinct querries, set this up.
            rval = null;
        } catch (Exception e) {
            statusHandler.error("Problem querying for record", e);
            rval = new ArrayList<String>(0);
        }
        return rval;
    }

    /*
     * (non-Javadoc)
     * 
     * @see
     * com.raytheon.uf.edex.wfs.reg.WfsSource#count(com.raytheon.uf.edex.wfs
     * .request.QualifiedName, com.raytheon.uf.edex.db.api.DatabaseQuery)
     */
    @SuppressWarnings("unchecked")
    @Override
    public long count(QualifiedName feature, WfsQuery query)
            throws WfsException {
        long rval;
        Session sess = null;
        try {
            CoreDao dao = getDao();
            SessionFactory sessFact = dao.getSessionFactory();
            sess = sessFact.openSession();
            Criteria criteria = sess.createCriteria(getFeatureEntity(feature));
            criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
            populateCriteria(criteria, query);
            criteria.setProjection(Projections.rowCount());
            List<Number> list = criteria.list();
            if (!list.isEmpty()) {
                rval = list.get(0).longValue();
            } else {
                rval = 0;
            }
        } catch (Exception e) {
            statusHandler.error("Unable to get count!", e);
            throw new WfsException(Code.OperationProcessingFailed);
        } finally {
            if (sess != null) {
                sess.close();
            }
        }
        return rval;
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.edex.wfs.reg.WfsSource#getKey()
     */
    @Override
    public String getKey() {
        return key;
    }

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.edex.wfs.reg.WfsSource#getJaxbClasses()
     */
    @Override
    public abstract Class<?>[] getJaxbClasses();

    /*
     * (non-Javadoc)
     * 
     * @see com.raytheon.uf.edex.wfs.reg.WfsSource#getFieldMap()
     */
    @Override
    public Map<String, String> getFieldMap() {
        return null;
    }

    /**
     * @return the typeModifier
     */
    public IFeatureTypeModifier getTypeModifier() {
        return typeModifier;
    }

    /**
     * @param typeModifier
     *            the typeModifier to set
     */
    public void setTypeModifier(IFeatureTypeModifier typeModifier) {
        this.typeModifier = typeModifier;
    }

}
