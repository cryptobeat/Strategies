# Getting started

The platform scripting language is Coffee Script.

Every  script starts from the header with meta information where you give the engine version, name, instrument defintions and a set of inital parameters (optional).
The inital paramters will be shown/set ery time you are trying to run the script. 

Then the  script has 3 callbacks:
init: initalation where you can set up inital values
handle: called on every new candle
onOrderUpdate: a notification when an exchange gives an update about the order status

```coffee
#@engine:1.0
#@name:getting_started 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

# script initialization
init: ->
    @debug "Initialization"

#new candle callback
handle: ->
    # get an istrument
    i1 = @instrument( {name:'pair1'} )
    # get date
    date = new Date(_.last i1.timeStamp)
    # get last loading price
    close = _.last i1.close
    # output to log file
    @debug "#{date} closing price: #{close}"

# call back when 
onOrderUpdate: ->
```

<h2>Variable Scope</h2>
All the variables are local and they are discared and the end of the execution.
If you want to carry over the variables between different calls you need to use a variable "@context".

```coffee
#@engine:1.0
#@name:getting_started 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

# script initialization
init: ->
    @debug "Initialization"
    @context.myParam = {
        previousPrice: 0
    }

#new candle callback
handle: ->
    # get an istrument
    i1 = @instrument( {name:'pair1'} )
    close = _.last i1.close
    # get date
    date = new Date(_.last i1.timeStamp)
    myParam = @context.myParam;
    ret = if myParam.previousPrice then close - myParam.previousPrice else 0
    myParam.previousPrice = close

    @debug "#{date} closing price: #{close}, return #{ret}"

# call back when 
onOrderUpdate: ->
```

<h2>How to sell/buy</h2>

```coffee
#@engine:1.0
#@name:getting_started 0.0.1
#@input(name="pair1", element="field", type="instrument", default="BTCETH", min="5min", max="24h", description="Primary pair")

# script initialization
init: ->
    @debug "Initialization"
    # data container
    @context.orderInfo = {
        ordertype:''
    }

#new candle callback
handle: ->
    # get an istrument
    i1 = @instrument( {name:'pair1'} )
    #load positions
    positions = @loadPositions('poloniex')

    #currency amount
    currency = positions[i1.curr()]
    #asset amount
    asset = positions[i1.asset()]
    #current close price
    close = _.last(i1.close)
    # round it
    price = _.floor(close, 6)
    #buy or selling
    if (positions[i1.asset()] < 1e-4)
        # trading type
        @context.orderInfo.ordertype= 'buy'
        vol = _.floor(currency / close, 5)
        # put the order to the exchange
        @trading.buy('market', i1, price, vol, 0 )
        @debug "async buying: price:#{price} vol: #{vol}"
    else
         # trading type
        @context.orderInfo.ordertype= 'sell'
        vol = _.floor(asset, 5)
        # put the order to the exchange
        @trading.sell('market', i1, price, vol, 0 )
        @debug "async selling: price:#{price} vol: #{vol}"
        
# call back when order completed
onOrderUpdate: ->
    # load positions
    positions = @loadPositions('poloniex')
    # all the variables within @context availabe
    ordertype = @context.orderInfo.ordertype
    @info "#{ordertype} order completed #{JSON.stringify(positions)}"
```
