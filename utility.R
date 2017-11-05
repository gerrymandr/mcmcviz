library(sf)


strip_attrs = function(obj)
{
  attributes(obj) = NULL
  obj
}


polsby_popper = function(sf) {
  P = st_geometry(sf) %>% map(st_length) %>% map_dbl(sum) %>% strip_attrs()
  A = st_area(st_geometry(sf)) %>% strip_attrs()
  
  4 * pi * A / P^2
}

thin = function(m, nsims=ncol(m), nburn=0, nthin=1)
{
  m[,(1:(nsims/nthin))*nthin + nburnin]
}

centroid_dist = function(sf)
{
  sf %>% 
    st_geometry() %>% 
    st_centroid() %>% 
    st_coordinates() %>% 
    dist() %>% 
    as.matrix()
}