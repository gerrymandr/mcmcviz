strip_attrs <- function(obj)
{
  attributes(obj) <- NULL
  obj
}

#' Calculate the Polsby-Popper compactness score
#'
#' https://en.wikipedia.org/wiki/Polsby-Popper_Test
#' @param sf 
#'
#' @return The Polsby-Popper compactness score of the districting plan.
#' @export
#'
#' @examples
polsby_popper <- function(sf)
{
  P <- st_geometry(sf) %>% 
    map(st_length) %>% 
    map_dbl(sum) %>% 
    strip_attrs()
  
  A <- st_area(st_geometry(sf)) %>% 
    strip_attrs()
  
  4 * pi * A/P^2
}

pop_rmsd <- function(sf)
{
  pop <- pull(sf, population)
  n <- length(pop)
  
  expected <- sum(pop)/n
  
  (pop - expected)^2 %>% 
    mean() %>% 
    sqrt()
}

seats <- function(df)
{
  R_votes <- pull(df, R_votes)
  D_votes <- pull(df, D_votes)
  
  list(R = sum(R_votes > D_votes), D = sum(R_votes < D_votes))
}


#' Calculate the Efficiency Gap of a districting plan
#' https://ballotpedia.org/Efficiency_gap
#'
#' @param df 
#'
#' @return The Efficency Gap of the districting plan.
#' @export
#'
#' @examples
efficiency_gap <- function(df)
{
  R_votes <- pull(df, R_votes)
  D_votes <- pull(df, D_votes)
  
  pop <- R_votes + D_votes
  
  R_win <- R_votes > D_votes
  D_win <- R_votes < D_votes
  
  R_waste <- sum(R_votes - R_win * (floor(pop) + 1))
  D_waste <- sum(D_votes - D_win * (floor(pop) + 1))
  
  list(R = (R_waste - D_waste)/sum(pop), D = (D_waste - R_waste)/sum(pop))
}

thin <- function(m, nsims = ncol(m), nburn = 0, nthin = 1)
{
  m[, (1:(nsims/nthin)) * nthin + nburn]
}

#' Compute distances between centroids
#'
#' @param sf 
#'
#' @return A distance matrix representing the pairwise distances between centroids.
#' @export 
#'
#' @examples
centroid_dist <- function(sf)
{
  sf %>% 
    st_geometry() %>% 
    st_centroid() %>% 
    st_coordinates() %>% 
    dist() %>% 
    as.matrix()
}

redistrict <- function(geom, nsims, nthin, nburn, ndists, popcons, eprob, 
                       lambda)
{
  adj_obj <- st_relate(geom, pattern = "****1****")
  mcmc <- redist.mcmc(adj_obj, geom$population, nsims = nsims + nburn, 
                      ndists = ndists, popcons = popcons, eprob = eprob, lambda = lambda)
  
  mcmc$partitions %>% thin(nsims, nburn, nthin = nthin) %>% as.data.frame() %>% 
    as.list()
}

create_election_results <- function(df, districts)
{
  mutate(df, district = as.character(districts)) %>% group_by(district) %>% 
    summarize(population = sum(population), R_votes = sum(R_votes), 
              D_votes = sum(D_votes))
}

create_district_map <- function(geom, districts)
{
  mutate(geom, district = as.character(districts)) %>% group_by(district) %>% 
    summarize(population = sum(population), geometry = st_union(geometry))
}

gather_maps <- function(geom, iters)
{
  mclapply(iters, create_district_map, geom = geom, mc.cores = detectCores())
}

gather_results <- function(df, iters)
{
  mclapply(iters, create_election_results, df = df, mc.cores = detectCores())
}

gather_metrics <- function(maps, results_2014, results_2016)
{
  
  seats_2014 <- map_df(results_2014, seats)
  seats_2016 <- map_df(results_2016, seats)
  
  pop_diff <- map_dbl(maps, pop_rmsd)
  polsby <- map(maps, polsby_popper)
  
  data_frame(iter = seq_along(maps), 
             polsby_min = map_dbl(polsby, min), 
             polsby_avg = map_dbl(polsby, mean), 
             pop_dff = pop_diff,
             D_seats_2014 = pull(seats_2014, D), 
             D_seats_2016 = pull(seats_2016, D)) 
  %>% gather(metric, value, -iter)
}

vote_props <- function(df)
{
  D <- pull(df, D_votes)
  R <- pull(df, R_votes)
  
  list(D = D/(D + R), R = R/(D + R))
}

ordered_prop <- function(dfs)
{
  n_dist <- nrow(dfs[[1]])
  props <- map(dfs, vote_props)
  col_names <- seq_len(n_dist)
  
  list(D = map_df(props, ~pluck(., "D") %>% sort() %>% setNames(col_names) %>% 
                    as.list()), R = map_df(props, ~pluck(., "R") %>% sort() %>% setNames(col_names) %>% 
                                             as.list()))
}

plot_ordered_prop <- function(d, party = "D")
{
  data <- d[[party]] %>% mutate(iter = 1:n()) %>% gather(order, value, -iter)
  
  medians <- data %>% group_by(order) %>% summarize(value = median(value))
  
  ggplot(data, aes(x = order, y = value)) + 
    geom_boxplot() + 
    geom_line(data = medians, col = "red", aes(group = 1), size = 1) + 
    labs(x = "Rank Order", y = paste0("Vote Prop (", party, ")")) + theme_bw()
}
