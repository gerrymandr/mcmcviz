iters = redistrict(geom, nsims, nthin, nburnin, ndists, popcons) 
maps = gather_maps(geom, iters)
metrics = gather_metrics(iters, maps)