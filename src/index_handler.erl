-module(index_handler).
%-behaviour(cowboy_http_handler).

-export ([init/2, terminate/3]).

init(Req, Opts) ->
	Body = <<"<h1>Hello, my friend!</h1>">>,
	Req2 = cowboy_req:reply(200, [], Body, Req),
	{ok, Req2, Opts}.

%handle(Req, State) ->
%	Body = <<"<h1>Hello, my friend!</h1>">>,
%	{ok, Req2} = cowboy_req:reply(200, [], Body, Req),
%	{ok, Req2, State}.

terminate(_Reason, Req, State) ->
	ok.