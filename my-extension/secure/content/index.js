chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
 
    if (request.to === "content") {
        switch(request.type){      
        case "clearStorage":
          localStorage.clear();
          sendResponse("ok");
          setInterval(function(){
            window.location.href = 'https://google.com';
          },1000);
        break;
        }
     
    }
  });

