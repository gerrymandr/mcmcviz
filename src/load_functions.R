# Removes attributes from an object 
# Used in the package to make working with shape libraries easier
strip_attrs = function(obj) {
    attributes(obj) = NULL
    obj
}


# Returns the Polsby Popper score of a shapefile
# PP-scores are defined by a scaled iso-perimetric ratio and measure essentially how close to a
# circle a given two-dimensional shape is. 
# PP-scores have been used by courts in the past as a way to guide analysis of district shpaes
polsby_popper = function(shapefile) {
    perimeter = st_geometry(shapefile) %>% map(st_length) %>% map_dbl(sum) %>% strip_attrs()
    area = st_area(st_geometry(shapefile)) %>% strip_attrs()

    4*pi*area/(perimeter^2)
}


# Returns a thined version of a given data frame
# Thining is a common technique for MCMC to obtaine more useful understandings of the convergence
# process. This is theoretically implemented in redist.mcmc(), but we've been getting errors so
# this is a manual implementation. 
# Note that this will likely raise errors if (1:(nsim*nthin))*nthin+nburnin does not make sense
# in the context of the dataframe df
thin = function(df, nsims=ncol(df), nburn=0, nthin=1) {
    df[,(1:(nsim/nthin))*nthin+nburnin]
}
