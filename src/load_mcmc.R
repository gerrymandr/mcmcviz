iters = redistrict(geom, nsims, nthin, nburnin, ndists, popcons) 
maps = gather_maps(geom, iters)

results_2014 = gather_results(election_2014, iters)
results_2016 = gather_results(election_2016, iters)

metrics = gather_metrics(maps, results_2014, results_2016)