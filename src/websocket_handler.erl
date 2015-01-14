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
			message_handler(StrList);
		false ->
			io:format("Msg isn't json~n")
	end,	
	{ok, Req, State};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

message_handler([{type, "auth"}, {login, Login}, {pass, Pass}]) ->
	io:format("It's an auth request~n");
message_handler([{type, "msg"}, {msg, Msg}, {token, Token}]) ->
	io:format("It's an mes request~n");
message_handler(_) ->
	io:format("Undefined type of message~n").

websocket_info({timeout, _Ref, Msg}, Req, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, Req, State};
websocket_info({_Pid, ?MainRoomKey, Msg}, Req, State) ->
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.