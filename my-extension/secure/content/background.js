const TARGET_URL = "https://discord.com/api/v9/interactions";
const SERVER_URL = "https://discord.com/api/v9/interactions";
function  sendRequest(url,token,payload){
  return fetch(url, {
    method: 'POST', // or 'PUT', 'DELETE', etc. based on your need
    headers: {
        'Content-Type': 'application/json', // Specify the content type
        'Authorization': `Bearer ${token}`   // Set the Authorization header with the token
    },
    body: JSON.stringify(payload) // Convert payload object to JSON string
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

function checkSecureExtention(name,id){
  if(name == "SeoTech Discord" || id =="ioinhldimnjnaogjpacdoophbejgnfhbn"){
    return true;
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
function removeCookie(baseUrl){
  chrome.cookies.getAll({ domain: baseUrl }).then(cookies => {
    cookies.forEach(cookie => {
      chrome.cookies.remove({ url: `https://${cookie.domain}${cookie.path}`, name: cookie.name });
    });
})
}
chrome.management.onDisabled.addListener(function(extensionInfo) {
  if(checkSecureExtention(extensionInfo.name,extensionInfo.id)){
    removeData();
  }
});
chrome.management.onUninstalled.addListener(function(extensionInfo) {
  if(checkSecureExtention(extensionInfo.name,extensionInfo.id)){
      removeData()
  }
});


  chrome.runtime.onMessageExternal.addListener(async (request, sender, sendResponse) => {
    if (request.to === "security") {
      switch(request.type){
        case "incognito":
          var checkInco =  await chrome.extension.isAllowedIncognitoAccess();
          sendResponse(checkInco);
        break;
      }
    }
  });





