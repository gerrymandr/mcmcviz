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

# Both redistricts a shape collection and also returns the meta data needed to show the state 
# changing over time
redistrict = function(df, num_sims, num_dists, popcons=0.05, num_burn=0, num_thin=1, fname="example") {
    
    adj_mat = st_relate(df, pattern = "****1****")
    pop_vec = sf$Population
    
    output = redist.mcmc(adj_mat, pop_vec, num_sims+num_burn, 
                         ndist=num_dists, popcons=popcons)
    thinparts = thin(output$partitions, num_sims+num_burn, num_burn, num_thin) %>% 
        as.data.frame() %>% 
        as.list()
    
    maps = map(iters, ~ mutate(df, DISTRICT=.) %>% 
               group_by(DISTRICT) %>% 
               summarize(Population=sum(Population), geometry=st_union(geometry))
           ) 
    
    save(maps, file=paste0(getwd(),"/data/", fname, ".Rdata"))

    polsby = map(maps, polsby_popper)

    list("maps"=maps, "polsby_popper_score"=polsby)                 
}
