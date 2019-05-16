# Getting started

Every script starts from the header with meta information where you give the engine version, name, instument defentions and a set of inital parameters (optional).
The inital paramters will be shown/set ery time you are trying to run the script. 

Then the script has 3 callbacks:
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
    i1 = @instrument( {asset:'ETH'} )
    # get last loading price
    close = _.last i1.close
    # output to log file
    @debug "closing price: #{close}"

# call back when 
onOrderUpdate: ->    
```

<h2>Variables scope</h2>