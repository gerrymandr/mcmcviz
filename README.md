# MCMC Visualization: Gerrymandering in real time

## Shiny App

In terminal:

```
git clone https://github.com/gerrymandr/mcmcviz.git
```

In R:

```{r}
wd="" ## change to where mcmcviz folder is
setwd(wd)

source("app.R")
```

### Example

*Select input type*: State

*Select a state*: Maryland

*Number of districts*: 6

*Number of simulations*: 100

*Click*: Run redistricting simulation

Wait a bit (check console for update statements).

**What am I seeing?**

*Map*: You can scroll through the boundaries for each district drawn in each MCMC iteration.

*Trace Plots*: These show per iteration the number of seats ``won" by Democrats in 2014 and 2016, average and minimum Polsby-Popper ratios, and a measure of difference between expected (total population/number of districts) and actual population per district under each particular set of boundaries. 

*Density Plots*: These show the densities of the number of seats ``won" by Democrats in 2014 and 2016, average and minimum Polsby-Popper ratios, and a measure of difference between expected (total population/number of districts) and actual population per district across the iterations under each particular set of boundaries. 

*Order Plots*: These plots show the order of each district from smallest proportion of Democrat voters to largest proportion of Democrat voters as the boundaries change across the iterations.



## Javascript Leaflet

To run the Javascript Leaflet react stuff locally:

npm i

npm start

(open localhost:3000 in your browser)

## Ideas for Future Improvement

- make colors on maps correspond to colors on order plots
- progress bar on the user interface instead of just in the console
- intuitive explanation of the MCMC algorithm

