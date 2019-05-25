#@engine:1.0
#@name:migration_example 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

sign:(a) ->
    return if ( a > 0 ) then 1 else -1
init: ->
    @context.buy_threshold = 20
    @context.sell_threshold = -19

    i1 = @instrument( {name:'pair1'} )
    @setPlotOptions
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
        signal:
            name: 'Signal'
            color: 'lightgray'
            lineWidth: 1
            type: 'column'                                                 
            axis: 'axisExt'

    #define chart axes and position
    @setAxisOptions
        mainAxis: #predefined candles plot
            name: i1.asset() + i1.curr()
            height: '60%'
        axisVol:
            offset: '10%'
            height: '50%'
            secondary: true
        axisExt:
            name:'Hst'
            offset: '80%'
            height: '20%'
            
    @debug "Initialized:"   
#
handle:->
    i1 = @instrument( {name:'pair1'} )
    
    signal = 1 / ((((i1.close[i1.close.length-1] - i1.close[i1.close.length-13]) / 13) - ((i1.close[i1.close.length-13] - i1.close[i1.close.length-26]) / 13)) / 13)
    logSignal = Math.log(Math.abs(signal))*@sign(signal)
    @plot
        signal: logSignal
                
    if logSignal >= @context.buy_threshold
         @plot
            buy_point: i1.close[i1.close.length-1]

    if logSignal <= @context.sell_threshold
        @plot
            sell_point: i1.close[i1.close.length-1]
            
