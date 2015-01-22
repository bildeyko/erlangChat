-module(websocket_handler).

-export([init/2, websocket_handle/3, websocket_info/3]).

-define(MainRoomKey, main_room).

init(Req, Opts) ->
	gproc:reg({p, l, main_room}),
	{cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
	io:format("New msg: ~s~n", [Msg]),
	case jsx:is_json(Msg) of 
		true ->
			gproc:send({p, l, ?MainRoomKey}, {self(), ?MainRoomKey, Msg}),
			List = jsx:decode(Msg, [{labels, atom}]),
			StrList = chatserver_converter:json_bin_to_str(List),
			Res = message_handler(StrList),
			self() ! {response, Res};
		false ->
			io:format("Msg isn't json~n")
	end,	
	{ok, Req, State};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

message_handler([{type, "auth"}, {login, Login}, {pass, Pass}]) ->
	io:format("It's an auth request~n"),
	case chatserver_db:get_user(Login) of
		{ok, [{pass, DbPass}, {salt, Salt}]} ->
			CryptoPass = chatserver_crypto:get_MD5pass(Pass, Salt),
			if CryptoPass == DbPass -> 
				Token = chatserver_crypto:get_MD5pass(chatserver_crypto:get_salt(), []),
				chatserver_auth:insert_user(Token, Login),
				[{type, "auth"}, {status, "success"}, {token, Token}];
				true ->
					[{type, "auth"}, {status, "error"}, {reason, "Login or pass is wrong"}]
			end;
		{not_found, []} ->
			[{type, "auth"}, {status, "error"}, {reason, "Login or pass is wrong"}]
	end;	
message_handler([{type, "msg"}, {msg, Msg}, {token, Token}]) ->
	io:format("It's a mes request~n"),
	case chatserver_auth:find_user(Token) of
		{ok, Login} ->
			gproc:send({p,l, ?MainRoomKey}, {response, [{type, "new_msg"}, {login, Login}, {msg, Msg}]}),
			[{type, "msg"}, {status, "success"}];
		{not_found, _} ->
			[{type, "msg"}, {status, "error"}, {reason, "You are not logged in"}]
	end;
message_handler([{type, "reg"}, {login, Login}, {pass, Pass}]) ->
	io:format("It's a reg request~n"),
	Salt = chatserver_crypto:get_salt(),
	CryptoPass = chatserver_crypto:get_MD5pass(Pass, Salt),
	case chatserver_db:insert_user(Login, CryptoPass, Salt) of
		{ok, _} ->
			Token = chatserver_crypto:get_MD5pass(chatserver_crypto:get_salt(), []),
			chatserver_auth:insert_user(Token, Login),
			io:format("Send~n"),
			[{type, "reg"}, {status, "success"}, {token, Token}];			
		{error, _} ->
			io:format("error~n"),
			[{type, "reg"}, {status, "error"}, {reason, "This login is already in use"}]
	end;
message_handler(_) ->
	io:format("Undefined type of message~n").

websocket_info({response, Data}, Req, State) ->
	BinData = chatserver_converter:json_str_to_bin(Data),
	Msg = jsx:encode(BinData),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.