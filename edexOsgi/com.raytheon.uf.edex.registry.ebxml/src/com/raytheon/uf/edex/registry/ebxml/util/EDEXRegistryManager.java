package com.raytheon.uf.edex.registry.ebxml.util;

import java.util.List;

import oasis.names.tc.ebxml.regrep.wsdl.registry.services.v4.LifecycleManager;
import oasis.names.tc.ebxml.regrep.wsdl.registry.services.v4.QueryManager;
import oasis.names.tc.ebxml.regrep.xsd.query.v4.QueryResponse;
import oasis.names.tc.ebxml.regrep.xsd.rs.v4.RegistryResponseType;

import com.google.common.annotations.VisibleForTesting;
import com.raytheon.uf.common.auth.exception.AuthorizationException;
import com.raytheon.uf.common.auth.user.IUser;
import com.raytheon.uf.common.registry.IRegistryRequest;
import com.raytheon.uf.common.registry.RegistryManager;
import com.raytheon.uf.common.registry.RegistryQuery;
import com.raytheon.uf.common.registry.RegistryResponse;
import com.raytheon.uf.common.registry.ebxml.LifecycleManagerFactory;
import com.raytheon.uf.common.registry.ebxml.QueryManagerFactory;
import com.raytheon.uf.common.serialization.comm.response.ServerErrorResponse;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.edex.auth.req.AbstractPrivilegedRequestHandler;
import com.raytheon.uf.edex.auth.resp.AuthorizationResponse;
import com.raytheon.uf.edex.core.EDEXUtil;
import com.raytheon.uf.edex.registry.acp.xacml.XACMLPolicyEnforcementPoint;

/**
 * 
 * A local client implementation for use with the RegistryManager Class for
 * clients that are contained in the same JVM as the registry services.
 * 
 * This Class also serves as the IRequestHandler for IRegistryRequests sent from
 * ThriftRegistryManager clients.
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * 
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Mar 27, 2012 356        jspinks     Initial creation
 * Jun 21, 2012 736        djohnson    Change handleRequest() to call RegistryManager.
 * Sep 14, 2012 1169       djohnson    Add use of create only mode.
 * Sep 27, 2012 1187       djohnson    Simplify the session management for a registry interaction.
 * 3/18/2013               bphillip    Modified to use proper transaction management and spring injection of objects
 * 
 * </pre>
 * 
 * @author jspinks
 * @version 1.0
 */
public class EDEXRegistryManager extends
        AbstractPrivilegedRequestHandler<IRegistryRequest<?>> implements
        LifecycleManagerFactory, QueryManagerFactory {

    @VisibleForTesting
    static IUFStatusHandler statusHandler = UFStatus
            .getHandler(EDEXRegistryManager.class);

    @VisibleForTesting
    static final String CAN_ONLY_STORE_SINGLE_OBJECT = "Only one object can be stored at a time, ignoring all but the first item in the list!";

    private static final String LIFECYCLEMANAGER_BEAN = "lcmServiceImpl";

    private XACMLPolicyEnforcementPoint xacmlPep;

    private QueryManager queryManager;

    /**
     * Get an implementation of LifeCycleManager that uses the internal
     * components defined by the registry itself.
     * 
     * @return A local implementation of LifeCycleManager.
     * 
     * @see LifecycleManagerFactory
     */
    @Override
    public LifecycleManager getLifeCycleManager() {
        return (LifecycleManager) EDEXUtil
                .getESBComponent(LIFECYCLEMANAGER_BEAN);
    }

    /**
     * Get an implementation of QueryManager that uses the internal components
     * defined by the registry itself.
     * 
     * @return An implementation of QueryManager.
     * 
     * @see QueryManagerFactory
     */
    @Override
    public QueryManager getQueryManager() {
        return queryManager;
    }

    /**
     * Handle the IRegistryRequests made to this Class from Thrift clients.
     * 
     * @param request
     *            The IRegistryRequest to process.
     * 
     * @return The response from the registry. This could be a
     *         <code>RegistryResponseType</code>, <code>QueryResponse</code> or
     *         <code>ServerErrorResponse</code> Object.
     * 
     * @throws Exception
     *             If there is an error encountered attempting to process the
     *             request.
     * 
     * @see RegistryResponseType
     * @see QueryResponse
     * @see ServerErrorResponse
     */
    @Override
    public Object handleRequest(IRegistryRequest<?> request) throws Exception {
        RegistryResponse<?> response = null;
        RegistryQuery<?> query = request.getQuery();
        List<?> objects = request.getObjects();
        final String username = request.getUsername();

        switch (request.getAction()) {
        case QUERY:
            response = RegistryManager.getRegistyObjects(query);
            break;
        case REMOVE:
            if (query == null) {
                response = RegistryManager.removeRegistyObjects(username,
                        objects);
            } else if (username == null) {
                response = RegistryManager.removeRegistyObjects(query);
            } else {
                response = RegistryManager
                        .removeRegistyObjects(username, query);
            }
            break;
        case STORE_OR_REPLACE:
            if (objects.size() > 1) {
                statusHandler.error(CAN_ONLY_STORE_SINGLE_OBJECT);
            }
            response = RegistryManager.storeOrReplaceRegistryObject(objects
                    .get(0));
            break;
        case STORE:
            if (objects.size() > 1) {
                statusHandler.error(CAN_ONLY_STORE_SINGLE_OBJECT);
            }
            response = RegistryManager.storeRegistryObject(objects.get(0));
            break;
        }

        return response;
    }

    @Override
    public AuthorizationResponse authorized(IUser user,
            IRegistryRequest<?> request) throws AuthorizationException {
        return xacmlPep.handleRegistryRequest(user, request);
    }

    public void setXacmlPep(XACMLPolicyEnforcementPoint xacmlPep) {
        this.xacmlPep = xacmlPep;
    }

    public void setQueryManager(QueryManager queryManager) {
        this.queryManager = queryManager;
    }

}
