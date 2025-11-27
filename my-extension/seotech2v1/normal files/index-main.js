document.addEventListener('keydown', function(e) {
  if (e.key === 'F12' || (e.ctrlKey && e.shiftKey && e.key === 'I') || (e.ctrlKey && e.shiftKey && e.key === 'C')) {
      e.preventDefault();
  }
});



var $html = `
<div style="
    display: flex;
    align-items: center;
    color: #fff;
    margin-bottom: 40px;
    border-bottom: 1px dashed #cccccc7a;
    padding-bottom: 16px;
    width: 90%;
    margin: 0 auto 40px;
">
<img src="https://panel.esolution.center/seotech.png" class="logos" style="
    width: 40px;
    height: 40px;
    margin-left: 5px;
    margin-top: 20px;
    border-bottom: 1px sold;
">
 <span style="
    display: inline-block;
    margin-top: 24px;
    font-size: 34px;
    font-weight: bold;
    margin-left:4px;
">eoTech</span>
</div>
<div style="
padding: 0 10px;
color: #fff;
display: flex;
padding-left: 20px;
"><span style="
display: inline-block;
width: 32px;
height: 32px;
background: #484b53;
border-radius: 100%;
display: flex;
align-items: center;
justify-content: center;
"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" style="width: 21px;height: 21px;/* text-align: center; */fill: #4f81ff;"><!--!Font Awesome Free 6.6.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2024 Fonticons, Inc.--><path d="M224 256A128 128 0 1 0 224 0a128 128 0 1 0 0 256zm-45.7 48C79.8 304 0 383.8 0 482.3C0 498.7 13.3 512 29.7 512l388.6 0c16.4 0 29.7-13.3 29.7-29.7C448 383.8 368.2 304 269.7 304l-91.4 0z"></path></svg></span><div style="
display: flex;
flex-direction: column;
margin-left: 10px;
"><span style="
font-weight: bold;
display: inline-block;
margin-bottom: 4px;
" id="username"></span><span style="
font-weight: 100;
">Exp:<span id="expdate"></span></span></div></div>
<div style="
padding: 10px;
">
<div style="
padding: 10px;
margin-top: 20px;
background: #313338;
border-radius: 10px;
"><div style="
display: flex;
align-items: center;
justify-content: space-between;
"><div style="
display: flex;
align-items: center;
"><span style="
display: inline-block;
width: 32px;
height: 32px;
background: #484b53;
border-radius: 100%;
display: flex;
align-items: center;
justify-content: center;
"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" style="
width: 21px;
height: 20px;
fill: aliceblue;
"><path d="M232 24c0-13.3 10.7-24 24-24C397.4 0 512 114.6 512 256s-114.6 256-256 256S0 397.4 0 256c0-37.9 8.2-73.8 23-106.1c6-13.2 13.1-25.8 21.2-37.6c0-.1 .1-.1 .1-.2C53.4 98.7 63.6 86.3 75 75c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9c-9.2 9.2-17.6 19.3-25 30.1c0 .1-.1 .1-.1 .2c-21.2 31.2-34.2 68.5-35.7 108.7c-.1 2.7-.2 5.4-.2 8.1c0 114.9 93.1 208 208 208s208-93.1 208-208c0-106.8-80.4-194.7-184-206.6V104c0 13.3-10.7 24-24 24s-24-10.7-24-24V24zM159 159c9.4-9.4 24.6-9.4 33.9 0l80 80c9.4 9.4 9.4 24.6 0 33.9s-24.6 9.4-33.9 0l-80-80c-9.4-9.4-9.4-24.6 0-33.9z"></path></svg></span><span style="
color: #fff;
display: inline-block;
margin-left: 7px;
">Daily use:</span></div><span id="daliyUse" style="
font-weight: bold;
color: #fff;
font-size: 17px;
">10 of 25</span></div><div style="
margin-top: 10px;
"><progress id="daliyUseProgress" value="100" max="100" style="
width: 100%;
accent-color: #0f0;
"></progress></div></div><div style="
padding: 10px;
margin-top: 20px;
background: #313338;
border-radius: 10px;
"><div style="
display: flex;
align-items: center;
justify-content: space-between;
"><div style="
display: flex;
align-items: center;
"><span style="
display: inline-block;
width: 32px;
height: 32px;
background: #484b53;
border-radius: 100%;
display: flex;
align-items: center;
justify-content: center;
"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" style="
width: 21px;
height: 21px;
fill: aliceblue;
"><path d="M128 0c17.7 0 32 14.3 32 32l0 32 128 0 0-32c0-17.7 14.3-32 32-32s32 14.3 32 32l0 32 48 0c26.5 0 48 21.5 48 48l0 48L0 160l0-48C0 85.5 21.5 64 48 64l48 0 0-32c0-17.7 14.3-32 32-32zM0 192l448 0 0 272c0 26.5-21.5 48-48 48L48 512c-26.5 0-48-21.5-48-48L0 192zm64 80l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0c-8.8 0-16 7.2-16 16zm128 0l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0c-8.8 0-16 7.2-16 16zm144-16c-8.8 0-16 7.2-16 16l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0zM64 400l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0c-8.8 0-16 7.2-16 16zm144-16c-8.8 0-16 7.2-16 16l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0zm112 16l0 32c0 8.8 7.2 16 16 16l32 0c8.8 0 16-7.2 16-16l0-32c0-8.8-7.2-16-16-16l-32 0c-8.8 0-16 7.2-16 16z"></path></svg></span><span style="
color: #fff;
display: inline-block;
margin-left: 7px;
">Days left:</span></div><span id="remainDays" style="
font-weight: bold;
color: #fff;
font-size: 17px;
">10</span></div><div style="
margin-top: 10px;
"><progress id="remainDaysProgress" value="100" max="100" style="
width: 100%;
accent-color: #0f0;
"></progress></div></div>
</div>`;
var $changeover = false;
$('<style>')
    .prop('type', 'text/css')
    .html(`
       .loader {
  box-sizing: border-box;
  display: inline-block;
  width: 50px;
  height: 80px;
  border-top: 5px solid #fff;
  border-bottom: 5px solid #fff;
  position: relative;
  background: linear-gradient(#19a2ff 30px, transparent 0) no-repeat;
  background-size: 2px 40px;
  background-position: 50% 0px;
  animation: spinx 5s linear infinite;
}
.loader:before, .loader:after {
  content: "";
  width: 40px;
  left: 50%;
  height: 35px;
  position: absolute;
  top: 0;
  transform: translatex(-50%);
  background: rgba(255, 255, 255, 0.4);
  border-radius: 0 0 20px 20px;
  background-size: 100% auto;
  background-repeat: no-repeat;
  background-position: 0 0px;
  animation: lqt 5s linear infinite;
}
.loader:after {
  top: auto;
  bottom: 0;
  border-radius: 20px 20px 0 0;
  animation: lqb 5s linear infinite;
}
@keyframes lqt {
  0%, 100% {
    background-image: linear-gradient(#19a2ff 40px, transparent 0);
    background-position: 0% 0px;
  }
  50% {
    background-image: linear-gradient(#19a2ff 40px, transparent 0);
    background-position: 0% 40px;
  }
  50.1% {
    background-image: linear-gradient(#19a2ff 40px, transparent 0);
    background-position: 0% -40px;
  }
}
@keyframes lqb {
  0% {
    background-image: linear-gradient(#19a2ff 40px, transparent 0);
    background-position: 0 40px;
  }
  100% {
    background-image: linear-gradient(#19a2ff 40px, transparent 0);
    background-position: 0 -40px;
  }
}
@keyframes spinx {
  0%, 49% {
    transform: rotate(0deg);
    background-position: 50% 36px;
  }
  51%, 98% {
    transform: rotate(180deg);
    background-position: 50% 4px;
  }
  100% {
    transform: rotate(360deg);
    background-position: 50% 36px;
  }
}
.loadingPanel{
position:fixed;
width:100%;
height:100%;
left:0;
top:0;
display:flex;
align-items:center;
justify-content:center;
flex-direction:column;
background:#222;
z-index:100000;
}  
.loadingText{
color: #fff;
    font-weight: bold;
    font-size: 27px;
    margin-top:38px;
}
    `)
    .appendTo('head');

$("body").append('<div class="loadingPanel"><span class="loader"></span><p class="loadingText">Fetching data, please wait for a few seconds.</p></div>');
function changeUsege(limit,used,days,user,expDate){
  if(typeof days != "undefined"){
    var progressDays = Math.floor(days*100/30);
    progressDays = progressDays > 100 ? 100 : progressDays;
    $("#remainDays").text(days);
    $("#remainDaysProgress").attr({"value":progressDays});
  }
  var progressUsed = Math.floor(100-(used*100/limit));
  $("#daliyUse").text(`${used} OF ${limit}`);
  $("#daliyUseProgress").attr({"value":progressUsed});
  if((limit - used) <= 0){
    $('div[role="textbox"]').parent().parent().parent().parent().parent().css({background:"crimson",color:"#fff",display:"flex","align-items":"center",padding:"10px 10px","font-size": "20px"})
    .html('<span>Your daily limit is over</span>');
    $('button').not(':contains("U1"), :contains("U2"), :contains("U3"), :contains("U4")').remove();
    $changeover = true;
  }
  if(typeof user != "undefined"){
    $("#username").text(user)
  }
  if(typeof expDate != "undefined"){
    $("#expdate").text(expDate)
  }
}
$(document).ready(function(){
    var counter = 0;
    var $interval = setInterval(function(){
            counter++
      if($('[class*="spinner"]').length == 0){
        if($('[class*="slateTextArea"]').length > 0){
          $('section').remove();
          $('nav').remove();
          $("[class^='sidebar']").html($html);
          chrome.runtime.sendMessage({ to: "background",type:"getusedAndExpireData" }, function(response) {
            changeUsege(response.limit,response.used,response.expiredate,response.username,response.pureExpireDate);
            $(".loadingPanel").css("display","none");
            clearInterval($interval);
            const images = document.querySelectorAll('.logos');

            images.forEach(function(image) {
                image.addEventListener('contextmenu', function (event) {
                    event.preventDefault();
                });
            });
        }); 
        }else if($('[class*="userActions"]').length > 0){
          $('[class*="lookFilled"]').click();
        }else if($('[class*="authBoxExpanded"]').length > 0){
          $(".loadingPanel").css("display","none");
        }else if($("button:has(div[class*='contents'])").length > 0){
          $("button:has(div[class*='contents'])").eq(1).click();
        }else{
          if(counter > 10){
          $(".loadingPanel").css("display","none");
          }
          
        }
      }  
        
    },2500);
      setInterval(function(){
        chrome.runtime.sendMessage({ to: "background",type:"getusedAndExpireData" }, function(response) {
          changeUsege(response.limit,response.used,response.expiredate,response.username,response.pureExpireDate);
      });
      },70000)
 
    function detectDevTools() {
        const threshold = 160;
        const devtoolsOpen = window.outerHeight - window.innerHeight > threshold || window.outerWidth - window.innerWidth > threshold;
        if (devtoolsOpen) {
          $("body").html('<div style="display: block;text-align: center;margin-top: 150px;font-size: 40px;color: crimson;"><svg xmlns="http://www.w3.org/2000/svg" style="fill:crimson;width:129px;" viewBox="0 0 512 512"><path d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zm0-384c13.3 0 24 10.7 24 24l0 112c0 13.3-10.7 24-24 24s-24-10.7-24-24l0-112c0-13.3 10.7-24 24-24zM224 352a32 32 0 1 1 64 0 32 32 0 1 1 -64 0z"/></svg><p class="loadingText" style="line-height:50px;">An unexpected error occurred.<br>Please contact to us and report the problem</p></div>');  
          localStorage.clear();
          chrome.runtime.sendMessage({ to: "background",type:"clearCookie",url:window.location.origin}, function(response) {
         
        });
    
        } else {
          
        }
      }
      
      setInterval(detectDevTools, 1500);
})
chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
 
    if (request.to === "content") {
        switch(request.type){
        case "setStorage":
          sendResponse("ok");
            var $storageData = request.value;
            for (const [key, value] of Object.entries($storageData)) {
                var $storageSet;
                if(typeof value === 'object'){
                    $storageSet =  JSON.stringify(value);
                }else{
                    $storageSet =  value;
                }
                localStorage.setItem(key, $storageSet);
              } 
            window.location.reload();
           
        break;
        case "changeUseage":
          changeUsege(request.value.limit,request.value.used);
        break;
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
  setInterval(function(){
    if($changeover){
      $('div[role="textbox"]').parent().parent().parent().parent().parent().css({background:"crimson",color:"#fff",display:"flex","align-items":"center",padding:"10px 10px","font-size": "20px"})
      .html('<span>Your daily limit is over</span>');
      $('button').not(':contains("U1"), :contains("U2"), :contains("U3"), :contains("U4")').remove();
    }
  },500)
