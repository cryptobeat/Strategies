#@engine:1.0
#@name:sample 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCUSDT", min="5min", max="24h", description="Primary pair")
  
#### Bot script starts below ####

# Epsilon Greedy Bandits
bandits_init: (nbActions) ->
    # this is exploration vs exploitation rate
    @context.eps = 0.2
    # values for each action
    @context.actionValues = []
    # values for each action zero initilization
    @context.actionValues.push(0) for i in [0 .. nbActions - 1]
    #@context.actionValues = [0.03184615384615385,0.16510309398496248,0.1285714285714286,0.17438048565220593,-0.0642857142857143]
    # trading episodes count 
    @context.bCount = 0

bandits_act: ->
    # select a action with maximum value
    action = @context.actionValues.indexOf(_.max(@context.actionValues))
    # check if we can explore instead
    if Math.random() < @context.eps
        # get a random action to explore
        action = Math.floor(Math.random() * Math.floor(@context.actionValues.length)) 
        @info "bandits_act exploring...."
    @debug "bandits_act: #{action}"
    action
    
# reward update from environment (after trading)
bandits_update: (action, reward) ->
     alfa = 0.9 # learning rate
     @context.bCount += 1 # increment episode count
     # update a value for a given action regarding giving reward
     @context.actionValues[action] = alfa * 
        (@context.actionValues[action] *
            (@context.bCount - 1) + reward ) / @context.bCount
     @debug "actValues: [#{@context.actionValues}]"

# palce a trade to exchange
tradeInstrument: (instrument, orderType) ->
    positions = @loadPositions('poloniex_trading')
    @info('going to trade:' + JSON.stringify(positions))
    
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]
    min_amount  =  0.001
    
    price =  _.last(instrument.close)
    amount_buy  =  currency_amount / price
    amount_sell =  asset_amount  
    
    #if amount_buy > min_amount && orderType=='buy'
    @trading.buy 'poloniex_trading' , instrument, price, amount_buy 
    @info "buying #{amount_buy} of #{instrument.asset()} at #{price}"

    if amount_sell > min_amount && orderType=='sell'
        curr = amount_sell * price + currency_amount
        buyHold = (price - @context.initalPrice) / @context.initalPrice * 100
        perform = (curr - @context.initialCurr) / @context.initialCurr * 100
        @trading.sell 'poloniex_trading' , instrument, price, amount_sell 
        @info "selling #{amount_sell} of #{instrument.asset()} at #{price}, perform: #{perform}%,buyHold: #{buyHold}%"
        
        @context.profit = perform 
        @context.profitBH = buyHold 
    
rsi:(data, period, last = true) ->
    results = @talib.RSI
        startIdx: 0
        endIdx: data.length - 1
        inReal: data
        optInTimePeriod: period
    if last then _.last(results) else results
bbands: (data,period) ->
    # @parent.debug " bbands period: #{period} up: #{@parent.context.param.algos }"
    # @utils.dump(data)
    results = @talib.BBANDS
        startIdx: 0
        endIdx: data.length - 1
        inReal: data
        optInTimePeriod: period
        optInNbDevUp: 2
        optInNbDevDn: 2
        optInMAType: 'SMA'
             
calcCurr:(instrument, positions = null)->
    if positions == null
        positions = @loadPositions('poloniex_trading')
    currency_amount =  positions[instrument.curr()]
    asset_amount    =  positions[instrument.asset()]
    price =  _.last(instrument.close)
    
    return currency_amount + asset_amount * price
    
# script initialization
init: ->
    @context.profit = 0 
    @context.profitBH = 0 
        
    @context.initalPrice = 0
    @context.period = 12
    @context.trading_state = 'watch'
    # this is risk bandits
    @context.risks = [ 2, 2.5, 2.9, 3.2, 3.5]
    @context.riskColors = ['rgba(66, 141, 245,0.3)',
    'rgba(245, 242, 66,0.3)','rgba(245, 161, 66,0.3)',
    'rgba(245, 78, 66,0.3)','rgba(207, 17, 197,0.3)']
    @bandits_init(@context.risks.length)
    
    i1 = @instrument( {name:'pair1'} )
#define chart plots type, name, color
    @setPlotOptions
        volume_plot:
            name: 'Volume' 
            color: 'lightgray'
            type: 'column'
            chartidx: 1
            axis: 'axisVol'
        stop_price:
            name: 'Stop Price' 
            color: 'red'
            type: 'coloredarea'
            axis: 'mainAxis'
        bb_upper:
            name: 'Upper Band' 
            color: 'lightgray'
            axis: 'mainAxis'
        bb_lower:
            name: 'Upper Band' 
            color: 'lightgray'
            axis: 'mainAxis'
        sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Sell'
        stop_sell_point:
            color: 'red'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Loss'
        buy_point:
            color: 'green'
            axis: 'mainAxis'
            type: 'flags'
            title: 'Buy'
        rsi:
            name: 'Rsi' 
            color: 'blue'
            axis: 'rsiAxis'
        profit:
            name: 'Profit' 
            color: 'green'
            axis: 'profitAxis'

        profitBH:
            name: 'Profit B&H' 
            color: 'red'
            axis: 'profitAxis'

#define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '10%'
            height: '50%'
            secondary: true
        rsiAxis:
            name:'<b>RSI</b>'
            offset: '60%'
            height: '20%'
            plotLines:[{
                    width: 1,
                    color: 'red',
                    value: 70,
                    label: {
                        text: 'RSI 70'
                    }
                    },
                    {
                    width: 1,
                    color: 'green',
                    value: 30,
                    label: {
                        text: 'RSI 30'
                    }
                    }]
        profitAxis:
            name:'<b>Profit</b>'
            offset: '80%'
            height: '20%'
            minPadding: 0.005
            maxPadding: 0.005
            
    @debug "Initialized:"

#Candle tick hook
handle: ->
    i1 = @instrument( {name:'pair1'} )
    price = _.last(i1.close)
    if @context.initalPrice == 0
       @context.initalPrice = price
       @context.initialCurr = @calcCurr(i1)
       
    rsi = @rsi(i1.close, @context.period )
    
    bb = @bbands(i1.close, @context.period)
    upper_band = _.last(bb.upperBand)
    lower_band = _.last(bb.lowerBand)
    middle = _.last(bb.middleBand)
    
    @plot
        volume_plot: _.last(i1.volume)
        bb_upper: upper_band
        bb_lower: lower_band
        rsi: rsi
        profit: @context.profit
        profitBH: @context.profitBH
    
    
    if @context.stop_price > 0 
        @plot
            stop_price: 
                    color: @context.riskColors[@context.bAction]
                    segmentColor: @context.riskColors[@context.bAction]
                    x: _.last(i1.timeStamp)
                    y: @context.stop_price 
        
    if @context.trading_state == 'watch' && rsi < 20
        @context.trading_state = 'rsi_converge'
        
    else if @context.trading_state == 'rsi_converge' && rsi > 20
        if price < middle
            @context.trading_state = 'open_position'
            @context.target_price = middle
            @context.bAction =  @bandits_act()
            @context.openPrice =  price
            
            @context.stop_price = middle - 
                (upper_band-lower_band) * @context.risks[@context.bAction]
            @plot
                buy_point: price
            @debug "opening a new position, " +
                "target: #{@context.target_price}"
                "stop: #{@context.stop_price}"
            
            @tradeInstrument(i1, 'buy')
        else 
            @debug "rsi did not converge, p: #{price}, m: #{middle}"
            @context.trading_state = 'watch'

    else if @context.trading_state == 'open_position' && rsi > 80
        if  price > @context.openPrice   
            @context.trading_state = 'rsi_converge_up'

    else if @context.trading_state == 'rsi_converge_up' && rsi < 50 
        @context.trading_state = 'watch'
        @info "sold"
        @bandits_update(@context.bAction, 1)
        @plot
            sell_point: price
        @tradeInstrument(i1, 'sell')
        
    # stop loss    
    else if ( @context.trading_state == 'open_position' ||
              @context.trading_state == 'rsi_converge_up' ) && 
                price < @context.stop_price
        @context.trading_state = 'watch'
        @warn "loss"
        @bandits_update(@context.bAction, -1)
        @plot
            stop_sell_point: price
            
        @tradeInstrument(i1, 'sell')

onOrderUpdate: ->
