```coffee
init: ->

printInfo:(txt) ->
#    @debug "testing #{txt}"

testNumber:(txt, n)->
    @printInfo "testing #{txt}"
    if('number' != typeof _.last n)
        throw "#{txt} Test Failed, value is not a number"

testNumber2:(txt, n1, n2, v)->
    @printInfo "testing #{txt}"
    @testNumber txt, v[n1]
    @testNumber txt, v[n2]

testNumber3:(txt, n1, n2, n3, v)->
    @printInfo "testing #{txt}"
    @testNumber txt, v[n1]
    @testNumber txt, v[n2]
    @testNumber txt, v[n3]

handle: ->
    i = @data.instruments[0]
    close = i.close
    low = i.low
    high = i.high
    open = i.open
    volume = i.volume

    talib = @talib

    @testNumber 'AD', talib.AD
            high: high
            low: low
            close: close
            volume: volume
            startIdx: 0
            endIdx: high.length - 1

    @testNumber 'ADOSC', talib.ADOSC
            high: high
            low: low
            close: close
            volume: volume
            startIdx: 0
            endIdx: high.length - 1
            optInFastPeriod: 0
            optInSlowPeriod: 0

    @testNumber 'ADX', talib.ADX
            high: high
            low: low
            close: close
            volume: volume
            startIdx: 0
            endIdx: high.length - 1
            optInTimePeriod: 0

    @testNumber 'ADXR', talib.ADXR
            high: high
            low: low
            close: close
            volume: volume
            startIdx: 0
            endIdx: high.length - 1
            optInTimePeriod: 0

    @testNumber 'APO', talib.APO
            inReal: close
            optInFastPeriod: 0
            optInSlowPeriod: 0
            maType: 'EMA'
            startIdx: 0
            endIdx: high.length - 1

    @testNumber2 'AROON', 'outAroonDown', 'outAroonUp', talib.AROON
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            optInTimePeriod: 0

    @testNumber 'AROONOSC', talib.AROONOSC
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            optInTimePeriod: 0

    @testNumber 'ATR', talib.ATR
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

    @testNumber 'AVGPRICE', talib.AVGPRICE
            startIdx: 0
            endIdx: high.length - 1
            open: open
            high: high
            low: low
            close: close

    @testNumber3 'BBANDS', 'upperBand', 'middleBand', 'lowerBand', talib.BBANDS
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0
            optInNbDevUp: 0
            optInNbDevDn: 0
            optInMAType: 'EMA'

    @testNumber 'BETA', talib.BETA
            startIdx: 0
            endIdx: high.length - 1
            inReal1: close
            inReal2: open
            optInTimePeriod: 0

    @testNumber 'BOP', talib.BOP
            startIdx: 0
            endIdx: high.length - 1
            open: open
            high: high
            low: low
            close: close

    @testNumber 'CCI', talib.CCI
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

    @testNumber 'CMO', talib.CMO
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'CORREL', talib.CORREL
            startIdx: 0
            endIdx: high.length - 1
            inReal1: close
            inReal2: open
            optInTimePeriod: 0

    @testNumber 'DEMA', talib.DEMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'DX', talib.DX
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

    @testNumber 'EMA', talib.EMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'HT_DCPERIOD', talib.HT_DCPERIOD
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'HT_DCPHASE', talib.HT_DCPHASE
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'HT_TRENDLINE', talib.HT_TRENDLINE
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'KAMA', talib.KAMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'LINEARREG', talib.LINEARREG
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'LINEARREG_ANGLE', talib.LINEARREG_ANGLE
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'LINEARREG_SLOPE', talib.LINEARREG_SLOPE
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'LINEARREG_INTERCEPT', talib.LINEARREG_INTERCEPT
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber3 'MACD', 'outMACD', 'outMACDSignal', 'outMACDHist', talib.MACD
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInFastPeriod: 0
            optInSlowPeriod: 0
            optInSignalPeriod: 0

    @testNumber3 'MACDEXT', 'outMACD', 'outMACDSignal', 'outMACDHist', talib.MACDEXT
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInFastPeriod: 0
            optInFastMAType: 'EMA'
            optInSlowPeriod: 0
            optInSlowMAType: 'EMA'
            optInSignalPeriod: 0
            optInSignalMAType: 'EMA'

    @testNumber2 'MAMA', 'outMAMA', 'outFAMA', talib.MAMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInFastLimit: 0
            optInSlowLimit: 0

    @testNumber 'MEDPRICE', talib.MEDPRICE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low

    @testNumber 'MFI', talib.MFI
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            volume: volume
            optInTimePeriod: 0

    @testNumber 'MIDPOINT', talib.MIDPOINT
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'MIDPRICE', talib.MIDPRICE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            optInTimePeriod: 0

    @testNumber 'MEDPRICE', talib.MEDPRICE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low

    @testNumber2 'MINMAX', 'outMin','outMax', talib.MINMAX
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'MINUS_DI', talib.MINUS_DI
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0
            
    @testNumber 'MINUS_DM', talib.MINUS_DM
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            optInTimePeriod: 0
            
    @testNumber 'MOM', talib.MOM
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'NATR', talib.NATR
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

    @testNumber 'OBV', talib.OBV
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            volume: volume

    @testNumber 'PLUSDI', talib.PLUSDI
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

    @testNumber 'PLUSDM', talib.PLUSDM
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            optInTimePeriod: 0

    @testNumber 'PPO', talib.PPO
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInFastPeriod: 0
            optInSlowPeriod: 0
            maType: 'SMA'

    @testNumber 'ROC', talib.ROC
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'ROCP', talib.ROCP
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'ROCR', talib.ROCR
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'ROCR100', talib.ROCR100
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'SAR', talib.SAR
            high: high
            low: low
            startIdx: 0
            endIdx: high.length - 1
            optInAcceleration: 0
            optInMaximum: 0

    @testNumber2 'STOCH', 'outSlowK','outSlowD', talib.STOCH
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInFastK_Period: 0
            optInSlowK_Period: 0
            optInSlowK_MAType: 'SMA'
            optInSlowD_Period: 0
            optInSlowD_MAType: 'SMA'

    @testNumber2 'STOCHF', 'outSlowK','outSlowD', talib.STOCHF
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInFastK_Period: 0
            optInFastD_Period: 0
            optInFastD_MAType: 'SMA'

    @testNumber2 'STOCHRSI', 'outSlowK','outSlowD', talib.STOCHRSI
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0
            optInFastK_Period: 0
            optInFastD_Period: 0
            optInFastD_MAType: 'SMA'

    @testNumber 'SUM', talib.SUM
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'T3', talib.T3
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0
            optInVFactor: 1

    @testNumber 'TEMA', talib.TEMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'TRUE_RANGE', talib.TRUE_RANGE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close

    @testNumber 'TRIMA', talib.TRIMA
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'TRIX', talib.TRIX
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0

    @testNumber 'TYP_PRICE', talib.TYP_PRICE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close

    @testNumber 'UTLOSC', talib.UTLOSC
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod1: 0
            optInTimePeriod2: 0
            optInTimePeriod3: 0

    @testNumber 'VAR', talib.VAR
            startIdx: 0
            endIdx: high.length - 1
            inReal: close
            optInTimePeriod: 0
            optInNbDev: 0

    @testNumber 'WCL_PRICE', talib.WCL_PRICE
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close

    @testNumber 'WILL_R', talib.WILL_R
            startIdx: 0
            endIdx: high.length - 1
            high: high
            low: low
            close: close
            optInTimePeriod: 0

#    while (true)
#            1
onOrderUpdate: ->

```
