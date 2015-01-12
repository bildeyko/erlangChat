var websocket;
window.onload = function () {
	init();
}

function init() {
	connect();
};

function connect() {
	websocket = new WebSocket("ws://localhost:8081/websocket");
	websocket.onopen = function(evt) { onOpen(evt) }; 
	websocket.onclose = function(evt) { onClose(evt) }; 
	websocket.onmessage = function(evt) { onMessage(evt) }; 
	websocket.onerror = function(evt) { onError(evt) }; 
};

function sendText() {
	if(websocket.readyState == websocket.OPEN){
		text = document.getElementById('usermsg').value;
		websocket.send(text);
		console.log("Sending: " + text);
	} else {
		console.log("Websocket is not connected");
	};
};

function onOpen(evt) {
	console.log("Connection opened.");
};

function onClose(evt) {
	console.log("Connection closed.");
};

function onMessage(evt) {
	console.log("Message: " + evt.data);
}

function onError(evt) {
	console.log("Error: " + evt.data);
}