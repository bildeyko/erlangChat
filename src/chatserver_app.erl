-module(chatserver_app).
-behaviour(application).

-export([start/2, stop/1]).

%start() ->
%	application:start(cowboy),
%	application:start(chatserver).

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", index_handler, []},
			{"/websocket", websocket_handler, []}
		]}
	]),
	% It's settings for openshift hosting
	%{ok, _} = cowboy:start_http(http_listener, 100, [{ip,{127,10,206,129}}, {port, 8080}], [
	{ok, _} = cowboy:start_http(http_listener, 100, [
		{ip,{127,0,0,1}}, 
		{port, 8081}], [
		{env, [{dispatch, Dispatch}]}
	]),
    chatserver_sup:start_link().

stop(_State) ->
    ok.
