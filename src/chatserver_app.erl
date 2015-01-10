-module(chatserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
	application:start(cowboy),
	application:start(chatserver).

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [{"/", index_handler, []}]}
	]),
	cowboy:start_http(http_listener, 100,
		[{port, 8080}],
		[{env, [{dispatch, Dispatch}]}]
	),
    chatserver_sup:start_link().

stop(_State) ->
    ok.
