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
        ema_fast:
            name: 'EMA_Fast'
            color: 'lime'
            type: 'line'
            chartidx: 1
            axis: 'axisSig'
        ema_slow:
            name: 'EMA_Slow'
            color: 'red'
            lineWidth: 1
            type: 'line'
            axis: 'axisSig'
        rsi:
            name: 'RSI'
            color: 'gray'
            lineWidth: 1
            type: 'column'
            axis: 'axisExt'

#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '70%'
        axisVol:
            offset: '10%'
            height: '50%'
            secondary: true
        axisSig:
            name:'EMA'
            offset: '80%'
            height: '20%'
        axisExt:
            name:'RSI'
            offset: '80%'
            height: '20%'
            secondary: true  
        
    @debug "Initialized:"
    
handle: ->

    instrument =   @instrument( {name:'pair1'} )
    price      =   instrument.close[instrument.close.length - 1]

    rsiResults = @rsi(instrument.close, 1, @context.period_rsi)
    rsi_last   = _.last(rsiResults)

    sarResults = @sar(instrument.high, instrument.low, 1, @context.sar_accel, @context.sar_accelmax)
    sar_last   = _.last(sarResults)

    ema_fast   = _.last(@ema(instrument.close, @context.period_fast))
    ema_slow   = _.last(@ema(instrument.close, @context.period_slow))
    @plot
       ema_fast: ema_fast
       ema_slow: ema_slow
       volume_plot: _.last(instrument.volume)
       rsi: rsi_last
           
    if (ema_fast < ema_slow and rsi_last < @context.threshold_rsi_low) or price > sar_last
        @tradeInstrument(instrument, 'buy')
    else if (ema_fast > ema_slow and rsi_last > @context.threshold_rsi_high) or price < sar_last
        @tradeInstrument(instrument, 'sell')
            
onOrderUpdate: ->            

    
    
    
