const channelToSubscription = new Map();
var queryString = window.location.search;
var urlParams = new URLSearchParams(queryString);
var product = urlParams.get('symbol')
var socket;
var data;
var tradePrice;
var tradeTime;
var channelString;
var res;
var volume;
var curVolume;
var preVolume;
var lastltt;
var date;
var time;
var tempRes;
var event;

export function socketfirst() {
  event = localStorage.getItem('tick_tick');

  data = JSON.parse(event);
  if (data['t'] == 'dk') {
    if (data.lp != undefined) {
      tradePrice = parseFloat(data['lp']);
    }
    if (data.v != undefined) {
      preVolume = parseFloat(data['v']);
      curVolume = parseFloat(data['v']);
    }
    if (data.ltt != undefined) {
      lastltt = data.ltt;
    }
      channelString = product;
  }

  else if (data['t'] == 'df') {
    if (data.lp != undefined) {
      tradePrice = parseFloat(data['lp']);
    }
    if (data.v != undefined) {
      curVolume = parseFloat(data['v']);
    }
    tradeTime = Math.floor(Date.now());
    if (data.ltt != undefined) {
      lastltt = data.ltt;
    }
    channelString = product;
    const subscriptionItem = channelToSubscription.get(channelString);
    if (subscriptionItem === undefined) {
    }
    const lastDailyBar = subscriptionItem.lastDailyBar;


    if (!!data["ltt"]) {
      const changedDate = data["ltt"].replace(
        /(..)\/(..)\/(....) (..):(..):(..)/,
        "$3-$2-$1 $4:$5:$6"
      );
      date = new Date(changedDate);
    }
    time =
      !!date && date !== "NA" && !isNaN(date)
        ? date.getTime()
        : new Date().getTime();
    if (res === "D" || res === "1D") {
      time = new Date().getTime() + 330 * 60 * 1000;
    }
    else {
      if (res == "1" || res == "1M") {
        tempRes = 1;
      } else if (res == "5") {
        tempRes = 5;
      } else if (res == "15") {
        tempRes = 15;
      } else if (res == "30") {
        tempRes = 30;
      } else if (res == "60") {
        tempRes = 60;
      }
      var coeff;
      if (
        (res == "30" || res == "60") &&
        data.e != "MCX"
      ) {
        coeff = 1000 * 60 * tempRes;
        time = Math.floor(time / coeff) * coeff;
        if (res == "30") {
          var roundOffedDateTime = new Date(time).toLocaleString(
            "en-US",
            {
              timeZone: "IST",
            }
          );
          var roundOffedTime = roundOffedDateTime.split(" ")[1];
          var timeDiff = roundOffedTime.split(":")[1];
          if (timeDiff == "00") {
            time = time + 900000;
          } else if (timeDiff == "30") {
            time = time - 900000;
          }
        } else if (res == "60") {
          var currentTime = new Date().getTime();
          var roundOffedDateTime60 = new Date(
            currentTime
          ).toLocaleString("en-US", {
            timeZone: "IST",
          });
          var roundOffedTime60 = roundOffedDateTime60.split(" ")[1];
          var timeDiff60 = roundOffedTime60.split(":")[1];
          if (
            parseInt(timeDiff60) >= 0 &&
            parseInt(timeDiff60) <= 14
          ) {
            time = time - 900000;
          } else if (
            parseInt(timeDiff60) >= 15 &&
            parseInt(timeDiff60) <= 59
          ) {
            time = time + 900000;
          }
        }
      } else {
        coeff = 1000 * 60 * tempRes;
        time = Math.floor(time / coeff) * coeff;
      }
    }
    curVolume =
      Number(preVolume) > Number(curVolume) ? preVolume : curVolume;
    volume =
      (Number(curVolume) - Number(preVolume));
    let bar;
    if (
      !!lastDailyBar &&
      !!lastDailyBar["time"] &&
      time > lastDailyBar["time"]
    ) {
      bar = {
        time: time,
        open: tradePrice,
        high: tradePrice,
        low: tradePrice,
        close: tradePrice,
        volume: 0
      };
      preVolume = curVolume;
    } else {
      bar = {
        ...lastDailyBar,
        high: Math.max(lastDailyBar.high, tradePrice),
        low: Math.min(lastDailyBar.low, tradePrice),
        close: tradePrice,
        volume: volume
      };
    }
    subscriptionItem.lastDailyBar = bar;
    subscriptionItem.handlers.forEach(handler => handler.callback(bar));
  }
}


setInterval(function () {

  event = localStorage.getItem('tick_tick');
  if (event) {
    data = JSON.parse(event);
    if (data['t'] == 'dk') {
      if (data.lp != undefined) {
        tradePrice = parseFloat(data['lp']);
      }
      if (data.v != undefined) {
        preVolume = parseFloat(data['v']);
        curVolume = parseFloat(data['v']);
      }
      if (data.ltt != undefined) {
        lastltt = data.ltt;
      }
        channelString = product;
    }

    else if (data['t'] == 'df') {
      if (data.lp != undefined) {
        tradePrice = parseFloat(data['lp']);
      }
      if (data.v != undefined) {
        curVolume = parseFloat(data['v']);
      }
      tradeTime = Math.floor(Date.now());
      if (data.ltt != undefined) {
        lastltt = data.ltt;
      }
        channelString = product;
      var subscriptionItem = channelToSubscription.get(channelString);
      console.log("Subscription Item 1", subscriptionItem)
      if (subscriptionItem === undefined) {
        subscriptionItem = channelToSubscription.get(channelString.split(":")[1]);
        console.log("Subscription Item 2", subscriptionItem)
      }
      const lastDailyBar = subscriptionItem.lastDailyBar;


      if (!!data["ltt"]) {
        const changedDate = data["ltt"].replace(
          /(..)\/(..)\/(....) (..):(..):(..)/,
          "$3-$2-$1 $4:$5:$6"
        );
        date = new Date(changedDate);
        // console.log("LTT DATE: ",date);
      }
      time =
        !!date && date !== "NA" && !isNaN(date)
          ? date.getTime()
          : new Date().getTime();
      if (res === "D" || res === "1D") {
        time = new Date().getTime() + 330 * 60 * 1000;
      }
      else {
        if (res == "1" || res == "1M") {
          tempRes = 1;
        } else if (res == "5") {
          tempRes = 5;
        } else if (res == "15") {
          tempRes = 15;
        } else if (res == "30") {
          tempRes = 30;
        } else if (res == "60") {
          tempRes = 60;
        }
        var coeff;
        if (
          (res == "30" || res == "60") &&
          data.e != "MCX"
        ) {
          coeff = 1000 * 60 * tempRes;
          time = Math.floor(time / coeff) * coeff;
          if (res == "30") {
            var roundOffedDateTime = new Date(time).toLocaleString(
              "en-US",
              {
                timeZone: "IST",
              }
            );
            var roundOffedTime = roundOffedDateTime.split(" ")[1];
            var timeDiff = roundOffedTime.split(":")[1];
            if (timeDiff == "00") {
              time = time + 900000;
            } else if (timeDiff == "30") {
              time = time - 900000;
            }
          } else if (res == "60") {
            var currentTime = new Date().getTime();
            var roundOffedDateTime60 = new Date(
              currentTime
            ).toLocaleString("en-US", {
              timeZone: "IST",
            });
            var roundOffedTime60 = roundOffedDateTime60.split(" ")[1];
            var timeDiff60 = roundOffedTime60.split(":")[1];
            if (
              parseInt(timeDiff60) >= 0 &&
              parseInt(timeDiff60) <= 14
            ) {
              time = time - 900000;
            } else if (
              parseInt(timeDiff60) >= 15 &&
              parseInt(timeDiff60) <= 59
            ) {
              time = time + 900000;
            }
          }
        } else {
          coeff = 1000 * 60 * tempRes;
          time = Math.floor(time / coeff) * coeff;
        }
      }
      curVolume =
        Number(preVolume) > Number(curVolume) ? preVolume : curVolume;
      volume =
        (Number(curVolume) - Number(preVolume));
      let bar;
      if (
        !!lastDailyBar &&
        !!lastDailyBar["time"] &&
        time > lastDailyBar["time"]
      ) {
        bar = {
          time: time,
          open: tradePrice,
          high: tradePrice,
          low: tradePrice,
          close: tradePrice,
          volume: 0
        };
        preVolume = curVolume;
      } else {
        bar = {
          ...lastDailyBar,
          high: Math.max(lastDailyBar.high, tradePrice),
          low: Math.min(lastDailyBar.low, tradePrice),
          close: tradePrice,
          volume: volume
        };
      }
      subscriptionItem.lastDailyBar = bar;
      subscriptionItem.handlers.forEach(handler => handler.callback(bar));
    }
  }
}, 300);


export function getResolution(
  resolution
) {
  res = resolution
  // console.log("Called Function for Res: ",res);
}

export function subscribeOnStream(
  symbolInfo,
  resolution,
  onRealtimeCallback,
  subscribeUID,
  onResetCacheNeededCallback,
  lastDailyBar,
) {
  // const parsedSymbol = parseFullSymbol(symbolInfo);
  const channelString = product;
  res = resolution;
  const handler = {
    id: subscribeUID,
    callback: onRealtimeCallback,
  };
  let subscriptionItem = channelToSubscription.get(channelString);
  // console.log("Subscribe on stream 2", subscriptionItem);
  if (subscriptionItem) {
    // already subscribed to the channel, use the existing subscription
    subscriptionItem.handlers.push(handler);
    return;
  }
  
  subscriptionItem = {
    subscribeUID,
    resolution,
    lastDailyBar,
    onResetCacheNeededCallback,
    handlers: [handler],
  };
  // console.log("Subscribe on stream 3", subscriptionItem);
  channelToSubscription.set(channelString, subscriptionItem);
  // console.log('[subscribeBars]: Subscribe to streaming. Channel:', channelString);
  // socket.emit('SubAdd', { subs: [channelString] });
}

export function unsubscribeFromStream(subscriberUID) {
  // find a subscription with id === subscriberUID
  for (const channelString of channelToSubscription.keys()) {
    const subscriptionItem = channelToSubscription.get(channelString);
    const handlerIndex = subscriptionItem.handlers
      .findIndex(handler => handler.id === subscriberUID);

    if (handlerIndex !== -1) {
      // remove from handlers
      subscriptionItem.handlers.splice(handlerIndex, 1);

      if (subscriptionItem.handlers.length === 0) {
        // unsubscribe from the channel, if it was the last handler
        // console.log('[unsubscribeBars]: Unsubscribe from streaming. Channel:', channelString);
        // socket.emit('SubRemove', { subs: [channelString] });
        channelToSubscription.delete(channelString);
        break;
      }
    }
  }
}

export function changeSymbol(symbol){
  product = symbol
  // console.log("product", symbol);
  
}