# Script Migrations

You can take other coffee scripts and migrate them to our platform

Lets take for instance a MACD crossover script from here:
https://github.com/cryptelligent/Cryptotrader/blob/master/Ma_crossover_parabolic_sar.coffee


```coffee

# Credits : Thanasis
# Address : 33Bz67vHXaKAL2GC9f3xWTxxoVKDqPrZ3H

talib   = require 'talib'
trading = require 'trading'

init: -> 

    @context.period_fast        = 17    # EMA period fast
    @context.period_slow        = 72    # EMA period slow
    @context.period_rsi         = 14    # RSI period
    @context.threshold_rsi_low  = 30    # RSI threshold low
    @context.threshold_rsi_high = 70    # RSI threshold high
    @context.sar_accel          = 0.02  # SAR accelaration
    @context.sar_accelmax       = 0.2   # SAR max accelaration

handle: ->

    instrument =   @data.instruments[0]
    price      =   instrument.close[instrument.close.length - 1]

    #RSI - Relative Strength Index  
    rsi = (data, lag, period) ->
        results = talib.RSI
            inReal   : data
            startIdx : 0
            endIdx   : data.length - lag
            optInTimePeriod : period

    #SAR - Parabolic SAR
    sar = (high, low, lag, accel, accelmax) ->
        results = talib.SAR
            high     : high
            low      : low
            startIdx : 0
            endIdx   : high.length - lag
            optInAcceleration : accel
            optInMaximum      : accelmax

    rsiResults = rsi(instrument.close, 1, @context.period_rsi)
    rsi_last   = _.last(rsiResults)

    sarResults = sar(instrument.high, instrument.low, 1, @context.sar_accel, @context.sar_accelmax)
    sar_last   = _.last(sarResults)

    ema_fast   = instrument.ema(@context.period_fast)
    ema_slow   = instrument.ema(@context.period_slow)

    currency_amount =  @portfolio.positions[instrument.curr()].amount
    asset_amount    =  @portfolio.positions[instrument.asset()].amount

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if (ema_fast < ema_slow and rsi_last < @context.threshold_rsi_low) or price > sar_last
        if amount_buy > min_amount
            trading.buy instrument, 'limit', amount_buy, price 
    else if (ema_fast > ema_slow and rsi_last > @context.threshold_rsi_high) or price < sar_last
        if amount_sell > min_amount
            trading.sell instrument, 'limit', amount_sell, price
```
<h2>Context Migrations</h2>

```coffee
#@engine:1.0
#@name:migration_example 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

#    RSI - Relative Strength Index  
rsi: (data, lag, period) ->
    results = @talib.RSI
        inReal   : data
        startIdx : 0
        endIdx   : data.length - lag
        optInTimePeriod : period
ema: (data, period) ->
    results = @talib.EMA
        inReal   : data
        startIdx : 0
        endIdx   : data.length - 1 
        optInTimePeriod : period
#SAR - Parabolic SAR
sar : (high, low, lag, accel, accelmax) ->
    results = @talib.SAR
        high     : high
        low      : low
        startIdx : 0
        endIdx   : high.length - lag
        optInAcceleration : accel
        optInMaximum      : accelmax

init: -> 

    @context.period_fast        = 17    # EMA period fast
    @context.period_slow        = 72    # EMA period slow
    @context.period_rsi         = 14    # RSI period
    @context.threshold_rsi_low  = 30    # RSI threshold low
    @context.threshold_rsi_high = 70    # RSI threshold high
    @context.sar_accel          = 0.02  # SAR accelaration
    @context.sar_accelmax       = 0.6   # SAR max accelaration
    
    i1 =   @instrument( {name:'pair1'} )
    @setPlotOptions
        volume_plot:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1
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
            height: '60%'
        axisVol:
            offset: '10%'
            height: '50%'
            secondary: true
    @debug "Initialized:"
    
handle: ->

    instrument =   @instrument( {name:'pair1'} )
    price      =   instrument.close[instrument.close.length - 1]

    rsiResults = @rsi(instrument.close, 1, @context.period_rsi)
    rsi_last   = _.last(rsiResults)

    sarResults = @sar(instrument.high, instrument.low, 1, @context.sar_accel, @context.sar_accelmax)
    sar_last   = _.last(sarResults)

    ema_fast   = @ema(instrument.close, @context.period_fast)
    ema_slow   = @ema(instrument.close, @context.period_slow)

    positions = @loadPositions()
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]

    min_amount  =  0.001
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  

    if (ema_fast < ema_slow and rsi_last < @context.threshold_rsi_low) or price > sar_last
        if amount_buy > min_amount
            @trading.buy 'limit' , instrument, price, amount_buy 
            @info "buy"
            @plot
                buy_point: _.last(instrument.close)
    else if (ema_fast > ema_slow and rsi_last > @context.threshold_rsi_high) or price < sar_last
        if amount_sell > min_amount
            @trading.sell 'limit', instrument, price, amount_sell
            @info "sell"
            @plot
                sell_point: _.last(instrument.close)
            
onOrderUpdate: ->            

    
    
```
