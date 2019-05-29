
#Getting stated

##Minimalistic Script
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
