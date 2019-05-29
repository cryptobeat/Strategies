
# Getting stated

## Minimalistic Script
Every script has to have a meta information which contains of the following:
- engine version
- name
- at least one instrument definition
- initalization parameters (optional)

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
## Example: Moving average crossover alogorithm
This alogrithm is usually decribed as:
- Go short when the fast moving average crosses to below the slow moving average.
- Go long when the fast moving average crosses to above the slow moving average.
- No action is taken as the MA's have not crossed.

In order to compute a moving average we are using talib library. Then we will define 2 parameters: slow and fast period for EMA. Next we will define the parameters in the <b>context</b> variable which is always availble. If you define the parameters as a regular vaiables, they wont be availabe in the handle method.

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
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
        else #short
            @debug "short #{price}  at #{date}"

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
## Example: Adding a chart
In order to see a chart you have do call 2 functions in the init method of the script. The function naes are <b>@setPlotOptions</b> and <b>@setAxisOptions</b>. setPlotOptions sets the series attributes such as series type, color, etc. Each serias must have a refrence to its axis which are defined in the setAxisOptions method.

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
    @context.period_fast        = 12    # EMA period fast
    @context.period_slow        = 47    # EMA period slow
    
    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
        slow_ma:
            color: 'blue'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        fast_ma:
            color: 'red'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'

#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '100%'
            
    @debug "Initialized:"   

    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]
    
    @plot
        slow_ma: _.last(ema_slow)
        fast_ma: _.last(ema_fast) 

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
        else #short
            @debug "short #{price}  at #{date}"

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
## Example: Multiple chart axes
You can add multiple axes and markers to any of them as well

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
    @context.period_fast        = 12    # EMA period fast
    @context.period_slow        = 47    # EMA period slow
    
    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
        slow_ma:
            color: 'blue'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        fast_ma:
            color: 'red'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        volume:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1 # new chart
            axis: 'axisVol'
        sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Sell'
        buy_point:
            color: 'green'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Buy'

#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '100%'
        axisVol:
            offset: '50%'
            height: '50%'
            secondary: true # secondary to main axis in the same position
            
    @debug "Initialized:"   

    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]
    
    @plot
        slow_ma: _.last(ema_slow)
        fast_ma: _.last(ema_fast) 
        volume: _.last(i1.volume) 

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
            @plot
                buy_point: price
        else #short
            @debug "short #{price}  at #{date}"
            @plot
                sell_point: price

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
## Example: Adding a second chart
You can create a second chart too by giving a new axis
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
    @context.period_fast        = 12    # EMA period fast
    @context.period_slow        = 47    # EMA period slow
    
    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
        slow_ma:
            color: 'blue'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        fast_ma:
            color: 'red'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        volume:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1 # new chart
            axis: 'axisVol'
        sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Sell'
        buy_point:
            color: 'green'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Buy'
        slow_ma1:
            color: 'blue'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
        fast_ma1:
            color: 'red'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '20%'
            height: '50%'
            secondary: true # secondary to main axis in the same position
        otherAxis: #predefined candles plot
            name: 'MAs'
            offset: '80%'
            height: '20%'
            
    @debug "Initialized:"   

    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]
    
    @plot
        slow_ma: _.last(ema_slow)
        fast_ma: _.last(ema_fast) 
        volume: _.last(i1.volume) 
        slow_ma1: _.last(ema_slow)
        fast_ma1: _.last(ema_fast) 

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
            @plot
                buy_point: price
        else #short
            @debug "short #{price}  at #{date}"
            @plot
                sell_point: price

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
## Trading

In order to trade you can use this function. It sells/buys everything

```coffee
tradeInstrument: (instrument, orderType) ->
    positions = @loadPositions()
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]
    min_amount  =  0.001
    
    price =  _.last(instrument.close)
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  
    
    if amount_buy > min_amount && orderType=='buy'
        @trading.buy 'market' , instrument, price, amount_buy 
        @info "buying #{amount_buy} of #{instrument.asset()} at #{price}"
        @plot
            buy_point: price    
    if amount_sell > min_amount && orderType=='sell'
        @trading.sell 'market' , instrument, price, amount_sell 
        @info "selling #{amount_sell} of #{instrument.asset()} at #{price}"
        @plot
            sell_point: price 
```
Then you can simply call <i>@tradeInstrument(instrument,'buy')</i> for buying and <i>@tradeInstrument(instrument,'sell')</i> for seling.
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
tradeInstrument: (instrument, orderType) ->
    positions = @loadPositions()
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]
    min_amount  =  0.001
    
    price =  _.last(instrument.close)
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  
    
    if amount_buy > min_amount && orderType=='buy'
        @trading.buy 'market' , instrument, price, amount_buy 
        @info "buying #{amount_buy} of #{instrument.asset()} at #{price}"
        @plot
            buy_point: price    
    if amount_sell > min_amount && orderType=='sell'
        @trading.sell 'market' , instrument, price, amount_sell 
        @info "selling #{amount_sell} of #{instrument.asset()} at #{price}"
        @plot
            sell_point: price 
# called once during initalization
init: ->
    @context.period_fast        = 12    # EMA period fast
    @context.period_slow        = 47    # EMA period slow
    
    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
        slow_ma:
            color: 'blue'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        fast_ma:
            color: 'red'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        volume:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1 # new chart
            axis: 'axisVol'
        sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Sell'
        buy_point:
            color: 'green'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Buy'
        slow_ma1:
            color: 'blue'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
        fast_ma1:
            color: 'red'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '20%'
            height: '50%'
            secondary: true # secondary to main axis in the same position
        otherAxis: #predefined candles plot
            name: 'MAs'
            offset: '80%'
            height: '20%'
            
    @debug "Initialized:"   

    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]
    
    @plot
        slow_ma: _.last(ema_slow)
        fast_ma: _.last(ema_fast) 
        volume: _.last(i1.volume) 
        slow_ma1: _.last(ema_slow)
        fast_ma1: _.last(ema_fast) 

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
            @plot
                buy_point: price
            @tradeInstrument(i1, 'buy')
        else #short
            @debug "short #{price}  at #{date}"
            @plot
                sell_point: price
            @tradeInstrument(i1, 'sell')

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
# Passing Back Test Parameter

In order to define backtest paramters that you would like to give in initaliaztion window you will have to use the meter header <i>#input</i>.
For example in flow flow and fast moving avereges we can define:
```coffee
#@input (name="pSlowMA", element="field", type="number", default="20", min="1", max="50", description="Fast MA")
#@input(name="pFastMA", element="list", type="number", default="40", values="10,15,20,30,40,50", description="Slow MA")
```
Then you can access the parameters through the context variable, for example:
```coffee
@debug "slow MA param: #{@context.param.pSlowMA}, fast MA param: #{@context.param.pFastMA}"
```
The full scrip will be 
```coffee
#@engine:1.0
#@name:migration_example 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")
#@input (name="pSlowMA", element="field", type="number", default="20", min="1", max="50", description="Fast MA")
#@input(name="pFastMA", element="list", type="number", default="40", values="10,15,20,30,40,50", description="Slow MA")

ema: (data, period) ->
    results = @talib.EMA
        inReal   : data
        startIdx : 0
        endIdx   : data.length - 1 
        optInTimePeriod : period
tradeInstrument: (instrument, orderType) ->
    positions = @loadPositions()
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]
    min_amount  =  0.001
    
    price =  _.last(instrument.close)
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  
    
    if amount_buy > min_amount && orderType=='buy'
        @trading.buy 'market' , instrument, price, amount_buy 
        @info "buying #{amount_buy} of #{instrument.asset()} at #{price}"
        @plot
            buy_point: price    
    if amount_sell > min_amount && orderType=='sell'
        @trading.sell 'market' , instrument, price, amount_sell 
        @info "selling #{amount_sell} of #{instrument.asset()} at #{price}"
        @plot
            sell_point: price 
# called once during initalization
init: ->
    @debug "slow MA param: #{@context.param.pSlowMA}, fast MA param: #{@context.param.pFastMA}"

    @context.period_fast        = @context.param.pFastMA    # EMA period fast
    @context.period_slow        = @context.param.pSlowMA    # EMA period slow
    
    
    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
        slow_ma:
            color: 'blue'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        fast_ma:
            color: 'red'
            axis: 'mainAxis'
            type: 'line'
            title: 'Buy'
        volume:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1 # new chart
            axis: 'axisVol'
        sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Sell'
        buy_point:
            color: 'green'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Buy'
        slow_ma1:
            color: 'blue'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
        fast_ma1:
            color: 'red'
            axis: 'otherAxis'
            type: 'line'
            title: 'Buy'
#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '20%'
            height: '50%'
            secondary: true # secondary to main axis in the same position
        otherAxis: #predefined candles plot
            name: 'MAs'
            offset: '80%'
            height: '20%'
            
    @debug "Initialized:"   

    
    @debug "Initialized:"   
# called on every candle
handle:->
    i1 =   @instrument( {name:'pair1'} )
    price      =   _.last(i1.close)
    date       =   new Date(_.last i1.timeStamp)

    ema_fast   = @ema(i1.close, @context.period_fast)
    ema_slow   = @ema(i1.close, @context.period_slow)
    d2  = ema_fast[ema_fast.length - 2] - ema_slow[ema_slow.length-2]
    d1 =  ema_fast[ema_fast.length - 1] - ema_slow[ema_slow.length-1]
    
    @plot
        slow_ma: _.last(ema_slow)
        fast_ma: _.last(ema_fast) 
        volume: _.last(i1.volume) 
        slow_ma1: _.last(ema_slow)
        fast_ma1: _.last(ema_fast) 

    #crossover condition
    if  d1*d2 < 0  
        if (d1 > 0) # long
            @debug "long #{price} at #{date}"
            @plot
                buy_point: price
            @tradeInstrument(i1, 'buy')
        else #short
            @debug "short #{price}  at #{date}"
            @plot
                sell_point: price
            @tradeInstrument(i1, 'sell')

# callback from exchange when an asset is sold or bought
onOrderUpdate: ->  
```
