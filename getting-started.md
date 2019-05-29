
# Getting stated

## Minimalistic Script
Every script has to have a meta information which consists of the following:
- engine version
- name
- at least one instrument definition
- optional initalization parameters

The basic script looks like:
```coffee
#@engine:1.0
#@name:migration_example 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

# called once during initalization
init: ->
    @debug "Initialized:"   
# called on every candle
handle:->

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->    
```
## Moving average crossover alogorithm
This alogrithm is usually decribed as:
- Go short when the fast moving average crosses to below the slow moving average.
- Go long when the fast moving average crosses to above the slow moving average.
- No action is taken as the MA's have not crossed.

In order to compute a moving average we are using talib library. Then we will define 2 parameters: slow and fast period for EMA. Next we will define in the context variable which is always availabe.

```coffee
#@engine:1.0
#@name:migration_example 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

ema: (data, period) ->
    results = @talib.EMA
        inReal   : data
        startIdx : 0
        endIdx   : data.length - 1 
        optInTimePeriod : period
# called once during initalization
init: ->
    @context.period_fast        = 9    # EMA period fast
    @context.period_slow        = 26    # EMA period slow
    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    
    #crossover condition
    if  (_.last(ema_fast) - _.last(ema_fast,1)) *  (_.last(ema_slow) - _.last(ema_slow,1)) < 0  
        if (ema_fast > ema_slow) # long
            debug "long at ${date}"
        else #short
            debug "short at ${date}"

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
