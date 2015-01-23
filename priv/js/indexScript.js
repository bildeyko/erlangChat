var Input = ReactBootstrap.Input;
var websocket;
var token;
init();

var ContentBox = React.createClass({
	/*
	React API
	*/
	getInitialState: function() {
		return {currentPage: 'auth'};
	},
	componentDidMount: function(user) {
		websocket.onmessage = this.onMessage;
		var router = Router({
			'/auth': this.setState.bind(this, {currentPage: 'auth'}),
			'/register': this.setState.bind(this, {currentPage: 'register'})
		});
		router.init();
	},
	render: function() {
		var partial;
		if (this.state.currentPage === 'auth') {
			partial = <AuthForm onSignInSubmit={this.handleSignInSubmit} />;
		} else
		if (this.state.currentPage === 'register') {
			partial = <RegForm onSignUpSubmit={this.handleSignUpSubmit} />;
		} else
		if (this.state.currentPage === 'chat') {
			partial = <ChatBox login={this.state.login} token={this.state.token} onSignOutSubmit={this.handleSignOutSubmit} />;
		}
		return (
			<div className="contentBox" id="contentBox">
				{partial}
			</div>
		);
	},
	/*
	Components' handlers
	*/
	handleSignInSubmit: function(user) {
		console.log(user.login);
		signIn(user);
	},
	handleSignUpSubmit: function(user) {
		console.log("Registration");
		signUp(user);
	},
	handleSignOutSubmit:function() {
		websocket.onmessage = this.onMessage;
		this.setAuthForm();
	},

	/*
	Sockets' handlers
	*/
	setChatBox: function(login, token) {
		this.setState({currentPage: 'chat', login: login, token: token});
	},
	setAuthForm: function() {
		this.setState({currentPage: 'auth'});
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
				this.regMsgHandler(resp);
				break;
		};
	},
	authMsgHandler: function(msg) {
		if(msg.status == 'error')
			showError(msg.reason);
		else {
			token = msg.token;
			console.log("Token: " + token);
			this.setChatBox(msg.login, msg.token);
		}
	},
	regMsgHandler: function(msg) {
		if(msg.status == 'error')
			showError(msg.reason);
		else {
			token = msg.token;
			console.log("Token: " + token);
			this.setChatBox(msg.login, msg.token);
		}
	}
});

function showError(msg) {
	console.log("Error:" + msg);
};

var ChatBox = React.createClass({
	/*
	React API
	*/
	componentDidMount: function(user) {
		websocket.onmessage = this.onMessage;
	},
	getInitialState: function() {
		return {data: []};
	},
	render: function() {
		return (
			<div className="chatBox">
			<div className="chatHeader">
				<h3>Hello, {this.props.login}</h3>
				<button onClick={this.handleSignOutSubmit}>Sign out</button>
			</div>
			<MsgList data={this.state.data} />
			<MsgForm onMessageSubmit={this.handleMessageSubmit} login={this.props.login}/>
			</div>
		);
  	},
  	/*
	Components' handlers
	*/
	handleMessageSubmit: function(msg) {
		console.log("Submit. Msg: " + msg.text);
		var comments = this.state.data;
		comments.push(msg);
		this.setState({data: comments});
		sendText(msg.text, this.props.token);
	},
	handleNewMessage: function(msg) {
		console.log("NEW Msg: " + msg.text);
		var comments = this.state.data;
		comments.push(msg);
		this.setState({data: comments});
	},
	handleSignOutSubmit: function(evt)	{
		console.log("Sign out");
		signOut(this.props.token);
	},
	/*
	Sockets' handlers
	*/
	onMessage: function(evt) {
		resp = onMessage(evt); 
		this.parseResp(resp);
	},
	parseResp: function(resp) {
		switch (resp.type) {
			case "msg":
				//this.msgMsgHandler(resp);
				break;
			case "new_msg":
				this.new_msgMsgHandler(resp);
				break;
			case "signOut":
				this.signOutMsgHandler(resp);
				break;
		};
	},
	new_msgMsgHandler: function(msg) {
		if(msg.login !== this.props.login)
			this.handleNewMessage({author: msg.login, text: msg.msg});
	},
	signOutMsgHandler:function(msg) {
		if(msg.status == 'error')
			showError(msg.reason);
		else {
			console.log("Sign out success");
			this.props.onSignOutSubmit();
		}
	}
});

var MsgList = React.createClass({
	componentWillUpdate: function() {
		var node = this.getDOMNode();
		this.shouldScrollBottom = node.scrollTop + node.offsetHeight === node.scrollHeight;
	},
	componentDidUpdate: function() {
		if (this.shouldScrollBottom) {
			var node = this.getDOMNode();
			node.scrollTop = node.scrollHeight;
		}
	},
	render: function() {
		var messageNodes = this.props.data.map(function(msg, index) {
			return (
				<Message author={msg.author} text={msg.text} key={index}/>
			);
	    });
	    return (
	      <div className="msgList" id="msgList">
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
				<p className="messageAuthor">
					{this.props.author}
				</p>
				<p>{this.props.text}</p>
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
			<div className="msgForm">
				<form onSubmit={this.handleSubmit}>
					<input type="text" id="msgFormText" placeholder="Say something" ref="text"/>
					<input type="submit"  id="msgFormBut" value="Post"/>
				</form>
			</div>
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
		this.props.onSignInSubmit({login: login, pass: pass});
		return;
	},
	render: function() {
		return (
			<form className="authForm" onSubmit={this.handleSubmit}>
				<div className="inputLine">
					<input className="glowInput" type="text" placeholder="Login" ref="login" />
				</div>
				<div className="inputLine">
					<input className="glowInput" type="password" placeholder="Password" ref="pass" />
				</div>
				<div className="inputLine">
					<input type="submit" value="Sign in"/>
				</div>
				<div>
					<p>You do not have an account?</p>
					<a href="#/register">Join Erlchat</a>
				</div>
			</form>
		);
	}
});

var RegForm = React.createClass({
	handleSubmit: function(e) {
		e.preventDefault();
		var login = this.refs.login.getDOMNode().value;
		var pass = this.refs.pass.getDOMNode().value;
		if (!login || !pass) {
			return;
		}
		this.props.onSignUpSubmit({login: login, pass: pass});
		return;
	},
	render: function() {
		return (
			<form className="authForm" onSubmit={this.handleSubmit}>
				<div className="inputLine">
					<input className="glowInput" type="text" placeholder="Login" ref="login" />
				</div>
				<div className="inputLine">
					<input className="glowInput" type="password" placeholder="Password" ref="pass" />
				</div>
				<div className="inputLine">
					<input type="submit" value="Create account"/>
				</div>
				<div>
					<p>Already have a Erlchat account?</p>
					<a href="#/auth">Sign in</a>
				</div>
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
};

function signUp(user) {
	var msg = {
		type: "reg",
		login: user.login,
		pass: user.pass,
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
};

function signOut(token) {
	var msg = {
		type: "signOut",
		token: token,
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
};

function sendText(msg, token) {
	var msg = {
		type: "msg",
		msg: msg,
		token: token
	}
	if(checkConnection())
		websocket.send(JSON.stringify(msg));
};

function authMsg_handler(msg) {
	token = msg.token;
	console.log("Token: " + token);
	ContentBox.setChatBox();
}
