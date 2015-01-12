-module(websocket_handler).

-export([init/2, websocket_handle/3, websocket_info/3]).

-define(MainRoomKey, main_room).

init(Req, Opts) ->
	gproc:reg({p, l, main_room}),
	{cowboy_websocket, Req, Opts}.

websocket_handle({text, Msg}, Req, State) ->
	gproc:send({p, l, ?MainRoomKey}, {self(), ?MainRoomKey, Msg}),
	{ok, Req, State};
	%{reply, {text, << "Hey client! ", Msg/binary >>}, Req, State};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, Req, State};
websocket_info({_Pid, ?MainRoomKey, Msg}, Req, State) ->
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.