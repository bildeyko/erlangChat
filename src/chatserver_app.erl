-module(chatserver_app).
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% API
-export ([dispatch_rules/0]).

%start() ->
%	application:start(cowboy),
%	application:start(chatserver).

dispatch_rules() ->
	cowboy_router:compile([
		{'_', [
			%{"/", index_handler, []},
			{"/", cowboy_static, {file, "priv/index.html"}},
			{"/websocket", websocket_handler, []},
			{"/js/[...]", cowboy_static, {dir, "priv/js", 
				[{mimetypes, cow_mimetypes, all}]}},
			{"/css/[...]", cowboy_static, {dir, "priv/css", 
				[{mimetypes, cow_mimetypes, all}]}},
			{"/img/[...]", cowboy_static, {dir, "priv/img", 
				[{mimetypes, cow_mimetypes, all}]}}
		]}
	]).

start(_StartType, _StartArgs) ->
	Dispatch = dispatch_rules(),
	% It's settings for openshift hosting
	%{ok, _} = cowboy:start_http(http_listener, 100, [{ip,{127,10,206,129}}, {port, 8080}], [
	{ok, _} = cowboy:start_http(http_listener, 100, [
		{ip,{127,10,206,129}}, 
		{port, 8080}], [
		{env, [{dispatch, Dispatch}]}
	]),
    chatserver_sup:start_link().

stop(_State) ->
    ok.
