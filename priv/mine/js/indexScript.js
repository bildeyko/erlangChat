var websocket;
var token;
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

function checkConnection() {
	if(websocket.readyState == websocket.OPEN)
		return true;
	else 
		console.log("Websocket is not connected");
	return false;
}

function onOpen(evt) {
	console.log("Connection opened.");
};

function onClose(evt) {
	console.log("Connection closed.");
	setTimeout(connect, 1000);
};

function onMessage(evt) {
	console.log("Message: " + evt.data);
	var resp = JSON.parse(evt.data);
	console.log("Message type: " + resp.type);
	switch (resp.type) {
		case "auth":
			authMsg_handler(resp);
			break;
		case "reg":
			regMsg_handler(resp);
			break;
		case "msg":
			msgMsg_handler(resp);
			break;
		case "new_msg":
			new_msgMsg_handler(resp);
			break;
		default:
			console.log("Unknown json format.");
	};
};

function onError(evt) {
	console.log("Error: " + evt.data);
};

function authMsg_handler(msg) {
	token = msg.token;
	console.log("Token: " + token);
}

function regMsg_handler(msg) {
	token = msg.token;
	console.log("Token: " + token);
}

function msgMsg_handler(msg) {
	console.log("Msg status: " + msg.status);
}

function new_msgMsg_handler(msg) {
	console.log("New msg from " + msg.login + " : " + msg.msg);
}

function sendText() {
	var msg = {
		type: "msg",
		msg: $("#usermsg").val(),
		token: token
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
};

function signIn() {
	var msg = {
		type: "auth",
		login: $("#authlogin").val(),
		pass: $("#authpass").val()
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
}

function signUp() {
	var msg = {
		type: "reg",
		login: $("#reglogin").val(),
		pass: $("#regpass").val()
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
}