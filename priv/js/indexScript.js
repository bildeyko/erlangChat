var Input = ReactBootstrap.Input;
var websocket;
var token;
init();

var ContentBox = React.createClass({
	/*
	React API
	*/
	handleSignInSubmit: function(user) {
		console.log(user.login);
		signIn(user);
	},
	getInitialState: function() {
		return {currentPage: 'auth'};
	},
	componentDidMount: function(user) {
		websocket.onmessage = this.onMessage;
	},
	render: function() {
		var partial;
		if (this.state.currentPage === 'auth') {
			partial = <AuthForm onSignInSubmit={this.handleSignInSubmit} />;
		} else
		if (this.state.currentPage === 'chat') {
			partial = <ChatBox login={this.state.login} token={this.state.token}/>;
		}
		return (
			<div className="contentBox" id="contentBox">
				{partial}
			</div>
		);
	},

	/*
	Sockets handlers
	*/
	setChatBox: function(login, token) {
		this.setState({currentPage: 'chat', login: login, token: token});
	},
	onMessage: function(evt) {
		resp = onMessage(evt); 
		this.parseResp(resp);
	},
	parseResp: function(resp) {
		switch (resp.type) {
			case "auth":
				this.authMsgHandler(resp);
				break;
			case "reg":
				regMsgHandler(resp);
				break;
		};
	},
	authMsgHandler: function(msg) {
		token = msg.token;
		console.log("Token: " + token);
		this.setChatBox(msg.login, msg.token);
	}
});

var ChatBox = React.createClass({
	handleMessageSubmit: function(msg) {
		console.log("Submit. Msg: " + msg.text);
		var comments = this.state.data;
   		comments.push(msg);
   		this.setState({data: comments});
	},
	getInitialState: function() {
		return {data: []};
	},
	render: function() {
		return (
			<div className="chatBox">
			<h3>ChatBox</h3>
			<MsgList data={this.state.data} />
			<MsgForm onMessageSubmit={this.handleMessageSubmit} login={this.props.login}/>
			</div>
    );
  }
});

var MsgList = React.createClass({
	render: function() {
		var messageNodes = this.props.data.map(function(msg, index) {
	      return (
	        <Message author={msg.author} text={msg.text} key={index}/>
	      );
	    });
	    return (
	      <div className="msgList">
	        {messageNodes}
	      </div>
	    );
	}
});

var Message = React.createClass({
	render: function() {
		console.log("Text: "+this.props.text);
		return (
			<div className="message">
				<h2 className="messageAuthor">
					{this.props.author}
				</h2>
				<h6>{this.props.text}</h6>
			</div>
		);
	}
});

var MsgForm = React.createClass({
	handleSubmit: function(e) {
		e.preventDefault();
		var text = this.refs.text.getDOMNode().value;
		if (!text) {
			return;
		}
		this.props.onMessageSubmit({author: this.props.login, text: text});
		this.refs.text.getDOMNode().value = '';
		return;
	},
	render: function() {
		return (
			<form onSubmit={this.handleSubmit}>
				<input type="text" ref="text"/>
				<input type="submit" value="Post"/>
			</form>
		);
	}
});

var AuthForm = React.createClass({
	handleSubmit: function(e) {
		e.preventDefault();
		var login = this.refs.login.getDOMNode().value;
		var pass = this.refs.pass.getDOMNode().value;
		if (!login || !pass) {
			return;
		}
		this.refs.login.getDOMNode().value = '';
		this.refs.pass.getDOMNode().value = '';
		this.props.onSignInSubmit({login: login, pass: pass});
		return;
	},
	render: function() {
		return (
			<form onSubmit={this.handleSubmit}>
				<input type="text" placeholder="Login" ref="login" />
				<input type="password" placeholder="Password" ref="pass" />
				<input type="submit" value="Sign in"/>
			</form>
		);
	}
});

React.render(
  <ContentBox />,
  document.getElementById('content')
);

function init() {
	connect();
};

function connect() {
	websocket = new WebSocket("ws://localhost:8081/websocket");
	websocket.onopen = function(evt) { onOpen(evt) }; 
	websocket.onclose = function(evt) { onClose(evt) }; 
	//websocket.onmessage = function(evt) { onMessage(evt) }; 
	websocket.onerror = function(evt) { onError(evt) }; 
};

function checkConnection() {
	if(websocket.readyState == websocket.OPEN)
		return true;
	else 
		console.log("Websocket is not connected");
	return false;
};

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
	/*switch (resp.type) {
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
	};*/
	return resp;
};

function onError(evt) {
	console.log("Error: " + evt.data);
};

function signIn(user) {
	var msg = {
		type: "auth",
		login: user.login,
		pass: user.pass
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
}

function authMsg_handler(msg) {
	token = msg.token;
	console.log("Token: " + token);
	ContentBox.setChatBox();
}
