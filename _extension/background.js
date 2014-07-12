function localServe(tab) {
  if(tab.url.indexOf('file:///') == 0) {
    var url = tab.url.replace('file://','http://127.0.0.1:9123');
    chrome.tabs.update(tab.id, {url: url});
  }
  else if(tab.url.indexOf('file://localhost/') == 0) {
    var url = tab.url.replace('file://localhost','http://127.0.0.1:9123');
    chrome.tabs.update(tab.id, {url: url});
  }
  else {
    var urlParts = tab.url.split("/");
    var port = urlParts[2].split(":")[1];
    var path = urlParts.slice(3).join("/");
    var url = "http://127.0.0.1:9123/_servers/"+port+"/kill/"+path;
    chrome.tabs.update(tab.id, {url: url});
    setTimeout(function(){
      chrome.tabs.remove(tab.id);
    },500);
  }
}

function updateIcon(tab) {
  var icon;
  if(tab.url.indexOf('file:///') == 0 || tab.url.indexOf('file://') == 0){
    icon = "icon-on.png";
    chrome.browserAction.enable(tab.tabId);
  } else {
    if(tab.url.indexOf('http://127.0.0.1:92') == 0){
      icon = "icon-off.png";
      chrome.browserAction.enable(tab.tabId);
    } else {
      icon = "icon-disabled.png";
      chrome.browserAction.disable(tab.tabId);
    }
  }
  chrome.browserAction.setIcon({path:icon});
}

chrome.browserAction.setIcon({path:"icon-disabled.png"});
chrome.browserAction.onClicked.addListener(localServe);

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
  updateIcon(tab);
});

chrome.tabs.onCreated.addListener(function(tabId, changeInfo, tab) {
  updateIcon(tab);
});

chrome.tabs.onActivated.addListener(function(activeInfo) {
  chrome.tabs.get(activeInfo.tabId, function(tab){
    updateIcon(tab);
  });
});
