library(sf)


strip_attrs = function(obj)
{
  attributes(obj) = NULL
  obj
}

JM_jerry = function(df) {
  
}


polsby_popper = function(sf) {
  P = st_geometry(sf) %>% map(st_length) %>% map_dbl(sum) %>% strip_attrs()
  A = st_area(st_geometry(sf)) %>% strip_attrs()
  
  4 * pi * A / P^2
}

pop_rmsd = function(sf)
{
  pop = pull(sf, population)
  n = length(pop)
  
  expected = sum(pop) / n
  
  (pop - expected)^2 %>%
    mean() %>%
    sqrt()
}

seats = function(df)
{
  R_votes = pull(df, R_votes)
  D_votes = pull(df, D_votes)
  
  list(
    R = sum(R_votes > D_votes), 
    D = sum(R_votes < D_votes)
  )
}


efficiency_gap = function(df)
{
  R_votes = pull(df, R_votes)
  D_votes = pull(df, D_votes)
  
  pop = R_votes + D_votes
  
  R_win = R_votes > D_votes
  D_win = R_votes < D_votes
  
  R_waste = sum( R_votes - R_win * (floor(pop)+1) )
  D_waste = sum( D_votes - D_win * (floor(pop)+1) )
  
  list(
    R=(R_waste - D_waste) / sum(pop),
    D=(D_waste - R_waste) / sum(pop)
  )
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