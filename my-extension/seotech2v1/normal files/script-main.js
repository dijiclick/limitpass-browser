// Override navigator.userAgent
if (chrome.extension.inIncognitoContext) {
  Object.defineProperty(navigator, 'userAgent', {
    get: function() {
      return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }
  });
}

var loadingPage = ()=>{
    $(".page").css({"display":"none"});
     $("#loading").css({"display":"block"});
}
var loginPage = ()=>{
    $(".page").css({"display":"none"});
    $("#login").css({"display":"block"});
    $(".info").css({"display":"none"});
    $(".logout").css({"display":"none"});
    $(".backToMain").css({"display":"none"});
}
var modal = ($message,$uuid,$type)=>{
    if($type == "hard"){
        $(".button").remove();
        $(".massage").addClass("hardBox");
    }else{
    $(".okay").attr("uuid",$uuid);
    }
    $("#message").html($message);
    $("#popup").css({"display":"block"});
}
var mainPage = (access,date,username,ip)=>{
    var manifestData = chrome.runtime.getManifest();
    var daysCalculator = (date)=>{
        const expirationDate = new Date(date);
        const currentDate = new Date(); 
        const timeDifference = expirationDate - currentDate; 
        var daysRemaining = Math.ceil(timeDifference / (1000 * 60 * 60 * 24)); 
        if(daysRemaining < 0){
            daysRemaining = 0;
        }
        return daysRemaining;
    }
    $(".page").css({"display":"none"});
    $("#main").css({"display":"block"});
    $(".info").css({"display":"block"});
    $(".logout").css({"display":"block"});
    var $tools = JSON.parse(access);
    var $buttons = "";
    for(var $i=0;$i<$tools.length;$i++){
        $buttons +=  `<button class="cookie btn-tool" data-tool="${$tools[$i].slug}"><span class="textonly">${$tools[$i].name}</span><span class="spinner" style="display:none"></span></button>`;
    }
    $(".graphic").prepend($buttons);
    $(".days").text(daysCalculator(date))
    const progressBar = 100*daysCalculator(date)/30 > 100 ? 100 : Math.floor(100*daysCalculator(date)/30);
    $(".progress-bar").css({"width":`${progressBar}%`});
    $("#info-username").text(username);
    $("#info-ip").text(ip);
    $("#info-version").text(manifestData.version);
    $("#info-exp").text(date);
    $("#info-billing").text("1Month");
}
var mainPageDisplayOnly = ()=>{
    $(".page").css({"display":"none"});
    $("#main").css({"display":"block"});
    $(".info").css({"display":"block"});
    $(".logout").css({"display":"block"});
    $(".backToMain").css({"display":"none"});
}
var info = ()=>{
    $(".page").css({"display":"none"});
    $("#info").css({"display":"block"});
    $(".info").css({"display":"none"});
    $(".logout").css({"display":"none"});
    $(".backToMain").css({"display":"block"});
}
$(".cancel").click(function(){
    $("#popup").css({"display":"none"});
});
loadingPage();
chrome.runtime.sendMessage({ to: "background",type:"checkToken" }, function(response) {
    if(response.type == "success"){
    if(response.token == "notDefind"){
        loginPage();
    }else{
        mainPage(response.token.access,response.token.expireTime,response.token.username,response.token.uia);
    }
}else if(response.type == "error-secure"){
    $extentions = response.extentions[0];
    modal(`For using seotech extension you must Enable this extension:<br> <span>${$extentions}</span>`,"","hard");
}else if(response.type == "error-incognito"){
    modal(`For using seotech extension you must Enable "Allow in Incognito"`,"","hard");  
}else if(response.type == "error-Secureincognito"){
    modal(`For using seotech extension you must Enable "Allow in Incognito" in SeoTech Discord Security`,"","hard"); 
}else{
    var $extentions = ""
    for(var $i=0;$i<response.extentions.length;$i++){

        $extentions += ($i+1) == response.extentions.length ? `${$i+1}: ${response.extentions[$i]} ` : `${$i+1}: ${response.extentions[$i]} <br>`
    }
    modal(`for using seotech extension you must disable these extension(s):<br> <span>${$extentions}</span>`,"","hard");
}
   });

$("#login-btn").click(()=>{
    $("#error_wrapper").css({"display":"none"});
    var username = $("#username").val();
    var password =$("#password").val();
    if(username != "" && password != ""){
        loadingPage();
        chrome.runtime.sendMessage({ to: "background",type:"login","username":username,"password":password }, function(response) {
            if(response.statusCode != 200){
            $("#error_wrapper").css({"display":"block"}).text(response.message);
            loginPage();
            }else{
                setTimeout(()=>{
                    window.location.reload();
                },400);  
            }
           });
    }else{
        $("#error_wrapper").css({"display":"block"}).text("Username or Password can not be empty");
    }
});
$(".info").click(function(){
    info();
});
$(".backToMain").click(function(){
    mainPageDisplayOnly();
});
$(".logout").click(function(){
    chrome.runtime.sendMessage({ to: "background",type:"logout" }, function(response) {
        if(response.message == "success"){
            window.location.reload();
        }
        
    });
});
$(document).on('click',".btn-tool",function(){
    var object = $(this);
    object.addClass("buttonloading");
    object.find(".textonly").css({"display":"none"});
    object.find(".spinner").css({"display":"block"});
    var $toolName = $(this).attr("data-tool");
    chrome.runtime.sendMessage({ to: "background",type:"getcookie","tool":$toolName }, function(response) {
        if(response.statusCode == 401){
            modal(response.message,response.uuid);
        }else if(response.statusCode == 444){
            modal(response.message,"","hard");
        }else if(response.statusCode != 200){
            window.location.reload();
        }else{
            object.removeClass("buttonloading");
            object.find(".textonly").css({"display":"block"});
            object.find(".spinner").css({"display":"none"});
        }
    });
});
$(".okay").click(function(){
    chrome.runtime.sendMessage({ to: "background",type:"clearSession","uuid":$(this).attr("uuid")}, function(response) {
        if(response.statusCode == 200){
            setTimeout(()=>{
                window.location.reload();
            },400);  
        }
       });
})
