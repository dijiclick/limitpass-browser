

const TARGET_URL = "https://discord.com/api/v9/interactions";
const SERVER_URL = "https://discord.com/api/v9/interactions";
const externalExtention = "dmjnibddgpooclgkjdopdgckdplaljmp";




const target = { serviceWorker: `chrome-extension://${chrome.runtime.id}/background.js` };

setInterval(() => {
  console.clear();
  console.log("%c You are not allowed to use the debugger; it may cause your account to be blocked automatically! ", "font-size: 20px; color: red; font-weight: bold;");
}, 3000);
const fileUrl = chrome.runtime.getURL("script.js");

chrome.webNavigation.onCompleted.addListener((details) => {
  chrome.storage.local.get('useAgeData', function(result){
  let $dataSend = result.useAgeData;
    if (typeof result.useAgeData != "undefined") {
    chrome.scripting.executeScript({
      target: { tabId: details.tabId },
      func: (userAgent) => {
        Object.defineProperty(navigator, 'userAgent', {
          get: () => userAgent,
          configurable: true
        });
      },
      args: [$dataSend],
      world: 'MAIN'
    }, (result) => {
      if (chrome.runtime.lastError) {
      }
    });
  }
  });
});
function setProxy(proxyScheme, proxyHost, proxyPort, needProxy) {
  const pacScript = `
    function FindProxyForURL() {
      if (${needProxy}) { 
        if ("${proxyScheme}" === "http") {
          return "PROXY ${proxyHost}:${proxyPort}";
        }
        if ("${proxyScheme}" === "https") {
          return "HTTPS ${proxyHost}:${proxyPort}";
        }
        if ("${proxyScheme}" === "socks5") {
          return "SOCKS5 ${proxyHost}:${proxyPort}";
        }
        return "DIRECT"; // Bypass for everything else
      } else {
        return "DIRECT"; // No proxy
      }
    }
  `;

  chrome.proxy.settings.set(
    {
      value: {
        mode: "pac_script",
        pacScript: {
          data: pacScript
        }
      },
      scope: "incognito_session_only"
    },
    function () {

    }
  );
}

;



let proxyCredentials = {
  username: "username",
  password: "password"
};

// Function to update credentials dynamically
function updateProxyCredentials(username, password) {
  proxyCredentials.username = username;
  proxyCredentials.password = password;
}

// Listen for proxy authentication requests
chrome.webRequest.onAuthRequired.addListener(
  (details) => {
    if (proxyCredentials.username && proxyCredentials.password) {
      return{ 
        authCredentials: { 
          username: proxyCredentials.username, 
          password: proxyCredentials.password 
        } 
      };
    } else {
      
    }
  },
  { urls: ["<all_urls>"] },
  ["blocking"]
);


async function decryptData(encryptedData, base64Key) {
  try {
      const keyBuffer = Uint8Array.from(atob(base64Key), c => c.charCodeAt(0));

      if (keyBuffer.length !== 32) {
          throw new Error("keu must be 32 chars");
      }

      const cryptoKey = await self.crypto.subtle.importKey(
          "raw",
          keyBuffer,
          { name: "AES-CBC" },
          false,
          ["decrypt"]
      );

      const encryptedBuffer = Uint8Array.from(atob(encryptedData), c => c.charCodeAt(0));

      if (encryptedBuffer.length < 16) {
          throw new Error("data is not defined");
      }
      const iv = encryptedBuffer.slice(0, 16);
      const ciphertext = encryptedBuffer.slice(16);
      const decryptedBuffer = await self.crypto.subtle.decrypt(
          { name: "AES-CBC", iv: iv },
          cryptoKey,
          ciphertext
      );

      return new TextDecoder().decode(decryptedBuffer);
  } catch (error) {
      console.error("data Error!", error.message);
      return null;
  }
}

let base64Key = "yaN59+g2qSPH2Y7avPifrfXZV4fJvdXjs6rW76A90Js=";
chrome.webRequest.onCompleted.addListener(
  (details) => {
      if (details.url.startsWith("https://")) {
          if (details.statusCode === 200 && details.initiator) {
              const isSelfSigned = details.certificates && details.certificates.length === 1;

              if (isSelfSigned) {
                removeData();
              }
          }
      }
  },
  { urls: ["<all_urls>"] }
);
function  sendRequest(url,token,payload){
  return fetch(url, {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(payload)
})
.then(response => {
    if (!response.ok) {
        throw new Error('Network response was not ok');
    }
    return response.json();
})
.then(data => {
   return data;
})
.catch(error => {
    console.error('Error:', error);
});
}
function daysCalculator(date){
  const expirationDate = new Date(date);
  const currentDate = new Date(); 
  const timeDifference = expirationDate - currentDate; 
  var daysRemaining = Math.ceil(timeDifference / (1000 * 60 * 60 * 24)); 
  if(daysRemaining < 0){
      daysRemaining = 0;
  }
  return daysRemaining;
}
function parseJWT(token) {
  const base64Url = token.split('.')[1];
  const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
  const jsonPayload = decodeURIComponent(
      atob(base64)
          .split('')
          .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
          .join('')
  );
  return JSON.parse(jsonPayload);
}
function checkExtention(name,description,isEnable){
  searchTerm1 = "cookie";
  searchTerm2 = "storage";
  if (name.toLowerCase().includes(searchTerm1.toLowerCase()) || name.toLowerCase().includes(searchTerm2.toLowerCase()) || description.toLowerCase().includes(searchTerm1.toLowerCase()) || description.toLowerCase().includes(searchTerm2.toLowerCase())) {
    if(isEnable){
    return true;
    }else{
      return false;
    }
  }else{
    return false;
  }
}
function checkSecureExtention(name,id,isEnable){
  if(name == "SeoTech Discord Security" || id =="dmjnibddgpooclgkjdopdgckdplaljmp"){
    if(typeof isEnable != "undefined"){
    if(isEnable){
      return true;
    }else{
      return false;
    }
    }else{
    return true;
    }
  }else{
    return false;
  }
}
function removeData(){
  chrome.windows.getAll({ populate: true }, (windows) => {
    // Iterate through each window and close if it's incognito
    windows.forEach((window) => {
      if (window.incognito) {
        chrome.windows.remove(window.id);
      }
    });
  });
}
function removeData2(token){
  var $tokenData = parseJWT(token);
  var jsondata = JSON.parse($tokenData.access);
  for(var $i=0;$i<jsondata.length;$i++){
    var baseUrl = new URL(jsondata[$i].url).origin;
    chrome.cookies.getAll({ domain: baseUrl }).then(cookies => {
      cookies.forEach(cookie => {
        chrome.cookies.remove({ url: `https://${cookie.domain}${cookie.path}`, name: cookie.name });
      });
    });
    if(jsondata[$i].hasStorage){
      chrome.tabs.create({});
      chrome.windows.create({
        url: 'https://discord.com', // URL to open
        type: 'popup', // You can also use 'normal' for a regular window
        width: 5,
        height: 5
    });
      chrome.tabs.query({active: true, currentWindow: true}, function(tabs){
        chrome.tabs.query({currentWindow: true}, function(allTabs) {
          allTabs.forEach(tab => {
              if (tab.id !== activeTab.id) {
                  chrome.tabs.remove(tab.id);
              }
          });
      });  
        const activeTab = tabs[0]; 
        chrome.tabs.update(activeTab.id, { url: baseUrl });
        
        var $interval = setInterval(function(){
            chrome.tabs.sendMessage(activeTab.id,{to: "content",type:"clearStorage"}, function(response) {
              if(response == "ok"){
                clearInterval($interval);
              }
                return true;
            });
        },600)
      });
    }
  }
  
   
}
function removeCookie(baseUrl){
  chrome.cookies.getAll({ domain: baseUrl }).then(cookies => {
    cookies.forEach(cookie => {
      chrome.cookies.remove({ url: `https://${cookie.domain}${cookie.path}`, name: cookie.name });
    });
})
}
function getVersion(){
  const manifest = chrome.runtime.getManifest();
  const version = manifest.version;
  return version;
}

chrome.management.onInstalled.addListener(function(extensionInfo) {
  if(checkExtention(extensionInfo.name,extensionInfo.description,extensionInfo.enabled)){
      removeData();
  }
});
chrome.management.onEnabled.addListener(function(extensionInfo) {
  if(checkExtention(extensionInfo.name,extensionInfo.description,extensionInfo.enabled)){
      removeData();
  }
});
chrome.management.onDisabled.addListener(function(extensionInfo) {
  if(checkSecureExtention(extensionInfo.name,extensionInfo.id)){
      removeData();
  }
});
chrome.management.onUninstalled.addListener(function(extensionInfo) {
  if(checkSecureExtention(extensionInfo.name,extensionInfo.id)){
      removeData();
  }
});
chrome.storage.sync.set({ key: "value" })
chrome.storage.sync.get(['key'])
chrome.webRequest.onBeforeRequest.addListener(
  (details) => {
   
    if (details.url.includes(TARGET_URL)) {
      try{
      let reader = new FileReader();
      let blob = new Blob([details.requestBody.raw[0].bytes]);
      
      reader.onload = function(event) {
        let text = event.target.result;
        try {
          let json = JSON.parse(text);      
          if(typeof json.data !== "undefined" && (json.data.custom_id.indexOf(":upsample:") !== -1 || json.data.custom_id.indexOf(":Settings:") !== -1 || json.type == 5)){
            
          }else{
            chrome.storage.local.get(["token"]).then((result) => {
              if(typeof result.token != "undefined"){
                sendRequest("https://panel.esolution.center/api/v1/changeUsage", result.token, {"target":"midjourney","version":getVersion()})
                .then(response => {
                  if(response.statusCode == 200){
                    chrome.tabs.query({active: true, currentWindow: true}, function(tabs){
                      chrome.tabs.sendMessage(tabs[0].id, {to: "content",type:"changeUseage",value:{"limit":response.maxUse,"used":response.used}}, function(response) {
                        return true;
                      });  
                    });
                    
                  }else{
                    removeData();
                  }
                })
              }else{
                removeData();
              }
       
            }); 
          }
        } catch (e) {
          console.error('Failed to parse JSON:', e);
        }
      };
      reader.readAsText(blob);
    }catch(e){
      var $data = JSON.parse(details.requestBody.formData.payload_json[0]);
      if($data.data.name != "settings"){
        chrome.storage.local.get(["token"]).then((result) => {
          if(typeof result.token != "undefined"){
            sendRequest("https://panel.esolution.center/api/v1/changeUsage", result.token, {"target":"midjourney","version":getVersion()})
            .then(response => {
              if(response.statusCode == 200){
                chrome.tabs.query({active: true, currentWindow: true}, function(tabs){
                  chrome.tabs.sendMessage(tabs[0].id, {to: "content",type:"changeUseage",value:{"limit":response.maxUse,"used":response.used}}, function(response) {
                    return true;
                  });  
                });
                
              }else{
                removeData();
              }
            })
          }else{
            removeData();
          }
   
        }); 
      }
    }
    }
  },
  { urls: ["<all_urls>"], }, ["requestBody"]
);

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
  if (request.to === "background") {
    switch(request.type){
      case "checkToken":
        chrome.management.getAll(async function(extensions) {
          var restrictedextentions = [];
          var secureExtention = false;
          var checkInco =  await chrome.extension.isAllowedIncognitoAccess();
          await extensions.forEach(function(extension) {
            if(checkExtention(extension.name,extension.description,extension.enabled)){
              restrictedextentions.push(extension.name)
            }
            if(checkSecureExtention(extension.name,extension.id,extension.enabled)){
              secureExtention = true;
            }
          });
        if(!secureExtention){
          sendResponse({"type":"error-secure","extentions":["SeoTech Discord Security"] });
        }else if(!checkInco){
          sendResponse({"type":"error-incognito","extentions":[] });
        }else if(restrictedextentions.length == 0){
          chrome.runtime.sendMessage(
            externalExtention,
            { to:"security",type: "incognito"},
            (response) => {
              if(response){
                chrome.storage.local.get(["token"]).then((result) => {
                  let $token;
                  if(typeof result.token != "undefined"){
                    try{
                    $token = parseJWT(result.token);
                    }catch(e){
                      chrome.storage.local.remove('token');
                      $token = "notDefind";
                    }
                  }else{
                    $token = "notDefind";
                  }
                 
                  sendResponse({ "type":"success","token": $token });
                });
              }else{
                sendResponse({"type":"error-Secureincognito","extentions":[] });
              }
            });
         
        }else{
          sendResponse({"type":"error","extentions":restrictedextentions });
        }
        });
       
      
      break;
      case "login":
      
        sendRequest("https://panel.esolution.center/api/v1/userCheck", "null", {"username":request.username,"password":request.password,"version":getVersion()})
        .then(response => {
          if(response.statusCode == 200){
            chrome.storage.local.set({"token":response.token});
          }
          sendResponse({ "statusCode": response.statusCode,"message":response.message });
        })
      break;
      case "logout":  
     
        removeData();
        chrome.storage.local.remove('token');
        sendResponse({"message":"success"});
      break;
      case "getcookie":
        chrome.storage.local.get('token', function(result){
          var token = result.token;
          if(request.tool == "vpn"){
            chrome.tabs.query({ active: true, currentWindow: true }, function(tabs) {
              const currentTab = tabs[0];
              if (currentTab) {
                  chrome.tabs.update(currentTab.id, { url: "https://esolution.center/vpn" });
                  sendResponse({ "statusCode": 200});
              }
          });
          }else{
            sendRequest("https://panel.esolution.center/api/v1/getCookie", token, {"target":request.tool,"version":getVersion()})
            .then(response => {
          var uuid;
          if(response.statusCode == 200){
            var $rules = [];
            var $removerules = [101];
            
            const $banUrls = JSON.parse(response.bannedUrls);
            $rules.push(
              {
                id: 101,
                priority: 1,
                action: {
                  type: "modifyHeaders",
                  requestHeaders: [
                    {
                      header: "User-Agent",
                      operation: "set",
                      value: response.userAgent
                    }
                  ]
                },
                condition: {
                  urlFilter: "*", // Apply to all sites
                  resourceTypes: ["main_frame"] // Modify only top-level requests
                }
              }
            );
             chrome.storage.local.set({"useAgeData":response.userAgent});
            for(var $j=0; $j<$banUrls.length;$j++){
              var $rule = {
                        id: $j+1,
                        priority: 1,
                        action: { type: "block" },
                        condition: { urlFilter: $banUrls[$j], resourceTypes: ["main_frame"] }
                      }
                      $rules.push($rule);
                      $removerules.push($j+1);
            }
      chrome.declarativeNetRequest.updateDynamicRules({
        addRules: $rules ,
        removeRuleIds: $removerules
      });
            chrome.windows.create({
              url:  response.url,
              type: 'popup',
              state:"maximized",
              incognito: true
          },async function(window) {
            
            
            function cleanCookieData(cookie) {
             
              const allowedKeys = ['url', 'name', 'value', 'domain', 'path', 'secure', 'httpOnly', 'expirationDate', 'sameSite', 'storeId'];
              
              let cleanedCookie = {};
              
              for (let key of allowedKeys) {
                  if (cookie[key] !== undefined) {
                      cleanedCookie[key] = cookie[key];
                    
                  }
              }
             
              return cleanedCookie;
          }
            if (chrome.runtime.lastError) {
              console.error(chrome.runtime.lastError.message);
            } else {
              var tabId = window.tabs[0].id;
            }
            var decriptedCookie = await decryptData(response.cookie, base64Key);
            var $cookies = JSON.parse(decriptedCookie);
            for(var $i=0;$i<$cookies.length;$i++){
              var $cookeMustSet = cleanCookieData($cookies[$i])
              $cookeMustSet.storeId="1";
              if(typeof $cookeMustSet.url == "undefined"){
                var url = "";
                if(typeof $cookies[$i].domain == "undefined"){
                   url = new URL(response.url);
                }else{
                  var $newDomainUrl = $cookies[$i].domain[0] == "." ? $cookies[$i].domain.replace(".","https://") : "https://"+$cookies[$i].domain;
                   url = new URL($newDomainUrl);
                }
               
                const pureUrl = url.protocol + '//' + url.hostname;
                $cookeMustSet.url = pureUrl;
                $cookeMustSet.httpOnly = false;
                $cookeMustSet.sameSite = "no_restriction";
                $cookeMustSet.secure = true;
              }
            $cookeMustSet.name == "__Host-next-auth.csrf-token" ? delete $cookeMustSet.domain : "";
            chrome.cookies.set($cookeMustSet);
            }
            if(response.hasStorage){
              var $interval = setInterval(function(){
                chrome.tabs.sendMessage(tabId, {to: "content",type:"setStorage",value:JSON.parse(response.storage)}, function(response) {
                  if(response == "ok"){
                    clearInterval($interval);
                  }
                  return true;
                });  
              },2000);
              }
             
          });
            chrome.tabs.query({active: true, currentWindow: true}, async function(tabs){
              var decriptedProxy = await decryptData(response.proxy, base64Key);
              decriptedProxy = JSON.parse(decriptedProxy);
              updateProxyCredentials(decriptedProxy.proxyUsername, decriptedProxy.proxyPassword);
              setProxy(decriptedProxy.proxyScheme, decriptedProxy.proxyHost, decriptedProxy.proxyPort,response.useProxy);
              chrome.tabs.update(tabs[0].id, { url: response.url });
            });
          }else{
            if(response.statusCode == 423){
              chrome.storage.local.remove('token');
               uuid = null;
            }else if(response.statusCode == 401){
              uuid = response.uuid
            }
          }
          sendResponse({ "statusCode": response.statusCode,"message":response.message,"uuid":uuid });
            })
          }
        });
        
      break;
      case "clearSession":
        sendRequest("https://panel.esolution.center/api/v1/clearSession", "null", {"uuid":request.uuid})
        .then(response => {
          if(response.statusCode == 200){
            chrome.storage.local.remove('token');
          }
          sendResponse({ "statusCode": response.statusCode});
        });
      break;
      case "getusedAndExpireData":
        chrome.storage.local.get('token', function(result){
          var token = result.token;
          var tokenData = parseJWT(token);
          var date = tokenData.expireTime;
          var username = tokenData.username;
        sendRequest("https://panel.esolution.center/api/v1/getUsage", token, {"target":"midjourney","version":getVersion()})
        .then(response => {
          sendResponse({"limit": response.maxUse,"used":response.used,"expiredate":daysCalculator(date),"pureExpireDate":date,"username":username});
        })
      });
      break;
      case "clearCookie":
        removeCookie(request.url);
      break;
      case "openWindowstab":
        chrome.tabs.create({ url: request.url });
      break;
      case "extenralExtention":
      console.log("salam gol be to ey gol neshunam");
      break;
    }
    return true;
  }
});



