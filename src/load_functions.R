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
  m[,(1:(nsims/nthin))*nthin + nburn]
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

redistrict = function(geom, nsims, nthin, nburn, ndists, popcons) {
  adj_obj = st_relate(geom, pattern = "****1****")
  mcmc = redist.mcmc(adj_obj, geom$population, 
                     nsims=nsims+nburn, ndists=ndists, popcons=popcons)
  
  mcmc$partitions %>% thin(nsims, nburn, nthin=nthin) %>% as.data.frame() %>% as.list()
}

create_election_results = function(df, districts)
{
  mutate(df, district = as.character(districts)) %>% 
    group_by(district) %>% 
    summarize(
      population = sum(population), 
      R_votes = sum(R_votes),
      D_votes = sum(D_votes)
    ) 
}

create_district_map = function(geom, districts)
{
  mutate(geom, district = as.character(districts)) %>% 
    group_by(district) %>% 
    summarize(
      population = sum(population), 
      geometry = st_union(geometry)
    ) 
}

gather_maps=function(geom, iters) {
  mclapply(iters,  create_district_map, geom = geom, mc.cores = detectCores())
}

gather_results = function(df, iters) {
  mclapply(iters, create_election_results, df = df, mc.cores = detectCores())
}

gather_metrics = function(maps, results_2014, results_2016) {
  
  seats_2014 = map_df(results_2014, seats)
  seats_2016 = map_df(results_2016, seats)
  
  pop_diff = map_dbl(maps, pop_rmsd)
  polsby = map(maps, polsby_popper)
  
  data_frame(
    iter = seq_along(maps),
    polsby_min = map_dbl(polsby, min),
    polsby_avg = map_dbl(polsby, mean),
    pop_dff = pop_diff,
    D_seats_2014 = pull(seats_2014, D),
    D_seats_2016 = pull(seats_2016, D)
  ) %>% gather(metric, value, -iter)
} 

