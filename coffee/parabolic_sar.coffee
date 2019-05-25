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

init: ->

    @context.sar_A_accel = 0.0002
    @context.sar_A_max = 0.2
    @context.sar_B_accel = 0.01
    @context.sar_B_max = 0.1
    @context.sar_C_accel = 0.005 
    @context.sar_C_max = 0.05
    @context.sar_D_accel = 0.0025
    @context.sar_D_max = 0.025
    @context.sar_E_accel = 0.00125
    @context.sar_E_max = 0.0125  
    @context.sar_F_accel = 0.000625
    @context.sar_F_max = 0.00625   
    
    i1 = @instrument( {name:'pair1'} )
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
        sar_plot_rd:
            name: 'Sar RD'
            color: 'red'
            type: 'scatter'
            chartidx: 1
            lineWidth: 0
            axis: 'axisSar'
        sar_plot_gr:
            name: 'Sar GR'
            color: 'green'
            type: 'scatter'
            chartidx: 1
            lineWidth: 0
            axis: 'axisSar'

    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '10%'
            height: '50%'
            secondary: true
        axisSar:
            offset: '0%'
            height: '60%'
            secondary: true
    @debug "Initialized:"   
handle:->
    instrument = @instrument( {name:'pair1'} )

    sar_A = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_A_accel
        optInMaximum: @context.sar_A_max
    sar_A_last = _.last(sar_A)

    sar_B = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_B_accel
        optInMaximum: @context.sar_B_max
    sar_B_last = _.last(sar_B)
    
    
    sar_C = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_C_accel
        optInMaximum: @context.sar_C_max
    sar_C_last = _.last(sar_C)   
    
    sar_D = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_D_accel
        optInMaximum: @context.sar_D_max
    sar_D_last = _.last(sar_D)    
    
    sar_E = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_E_accel
        optInMaximum: @context.sar_E_max
    sar_E_last = _.last(sar_E)   
    
    sar_F = @talib.SAR
        high: instrument.high
        low: instrument.low
        startIdx: 0
        endIdx: instrument.high.length - 1
        optInAcceleration: @context.sar_F_accel
        optInMaximum: @context.sar_F_max
    sar_F_last = _.last(sar_F)   

    price =  _.last(@ema(instrument.close, 2))
    
    if price > sar_D_last
         @tradeInstrument(instrument, 'buy')
         @plot
            sar_plot_rd: sar_D_last  
    else if price < sar_D_last
         @tradeInstrument(instrument, 'sell')
         @plot
            sar_plot_gr: sar_D_last  

onOrderUpdate: -> 
        
