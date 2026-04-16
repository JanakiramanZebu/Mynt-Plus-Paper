var queryString = window.location.search;
var urlParams = new URLSearchParams(queryString);
// var usession = urlParams.get('usession')
var user = urlParams.get('user')
// var exch = urlParams.get('exch')
// var token = urlParams.get('token')


// Make requests to CryptoCompare API
export async function makeApiRequest(path, symbol) {
  var queryString = window.location.search;
  var urlParams = new URLSearchParams(queryString);
  var usession = urlParams.get('usession')
  var user = urlParams.get('user')
  // var exch = urlParams.get('exch')
  // var token = urlParams.get('token')
  let myHeaders = new Headers();
        myHeaders.append("Content-Type", "application/json");
  var raw = `jData={"uid":"${user}","exch":"${symbol['exch']}","token":"${symbol['Token']}"}&jKey=${usession}`;
  var requestOptions = {
    method: 'POST',
    body: raw,
    headers: myHeaders,
    redirect: 'follow'
  };
  try {
    var response = await fetch(path, requestOptions)
    return response.json();

  } catch (error) {
    throw new Error(`CryptoCompare request error: ${error.status}`);
  }
}
export async function getchart(path, request) {
  try {
      //     let greekconfig = {
      //         method: "post",
      //         url:path,  
      //         headers: {
      //           "Content-Type": "application/json",
      //          },

      //     data: request,
      //   };

      //   axios(greekconfig)
      //     .then(function (response) {
      //         return response.json();
      //     })
      //     .catch(function (error) {
      //       console.log(error);
      //     });

      let myHeaders = new Headers();
      myHeaders.append("Content-Type", "application/json");
      var requestOptions = {
          method: 'POST',
          redirect: 'follow',
          headers: myHeaders,
          body: request
      };
      const response = await fetch(path, requestOptions);
      // console.log("response : ",response)
      // if (!response.ok) {
      return response.json();
      // }



  } catch (error) {
      throw new Error(`zebull symbols request error: ${error.status}`);
  }
}
export async function getAllSymbols(input) {
  var myHeaders = new Headers();
  myHeaders.append("Content-Type", "application/json");

  var raw = JSON.stringify({
    "symbol": `${input}`,
    "exchange": [
      "All",
      "NSE",
      "BSE",
      "CDS",
      "MCX",
      "NFO"
    ]
  });

  var requestOptions = {
    method: 'POST',
    headers: myHeaders,
    body: raw,
    redirect: 'follow'
  };

  var a = await fetch("https://zebull.in/rest/MobullService/exchange/getScripForSearch", requestOptions)
    .then(response => response.json())
    .then(result => { return result; })
    .catch(error => console.log('error', error));

  return a;
}

// Generate a symbol ID from a pair of the coins
export function generateSymbol(exchange, fromSymbol, toSymbol) {
  const short = `${fromSymbol}/${toSymbol}`;
  return {
    short,
    full: `${exchange}:${short}`,
  };
}

export function parseFullSymbol(fullSymbol) {
  return {
    full_name: fullSymbol.full_name,
    exchange: fullSymbol.exchange
  };
}

 export async function dayChart(path, request) {
  try {
      //     let greekconfig = {
      //         method: "post",
      //         url:path,  
      //         headers: {
      //           "Content-Type": "application/json",
      //          },

      //     data: request,
      //   };

      //   axios(greekconfig)
      //     .then(function (response) {
      //         return response.json();
      //     })
      //     .catch(function (error) {
      //       console.log(error);
      //     });

      let myHeaders = new Headers();
      myHeaders.append("Content-Type", "application/json");
      var requestOptions = {
          method: 'POST',
          redirect: 'follow',
          headers: myHeaders,
          body: request
      };
      const response = await fetch(path, requestOptions);
      // console.log("response : ",response)
      // if (!response.ok) {
      return response.json();
      // }



  } catch (error) {
      throw new Error(`zebull symbols request error: ${error.status}`);
  }
}

export async function getSymbol(symbol) {
  try {
      const response = await fetch("https://be.mynt.in/getSymbolinfo?tsym="+symbol);
      // console.log("response : ",response)
      return response.json();
  } catch (error) {
      throw new Error(`get symbols request error: ${error.status}`);
  }
}

  export async function getIndicators() {
    try {
        const response = await fetch(`https://be.mynt.in/getindicators?clientCode=${user}`);
        return response.json();
    } catch (error) {
        throw new Error(`get symbols request error: ${error}`);
    }
}

export async function setIndicators(c) {
  try {
      const response = await fetch(`https://be.mynt.in/storeindicators?clientCode=${user}&indicators=${JSON.stringify(c)}`);
      return response.json();
  } catch (error) {
      throw new Error(`get symbols request error: ${error}`);
  }
}