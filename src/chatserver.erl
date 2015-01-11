-module(chatserver).
-export ([start/0, stop/0]).

-define (APPS, [crypto, cowlib, ranch, cowboy, chatserver]).

start() ->
	ok = ensure_started(?APPS).

stop() ->
	ok = ensure_stoped(lists:reverse(?APPS)).

ensure_started([]) -> ok;
ensure_started([App | Apps]) ->
    case application:start(App) of
        ok -> ensure_started(Apps);
        {error, {already_started, App}} -> ensure_started(Apps)
    end.

ensure_stoped([]) -> ok;
ensure_stoped([App | Apps]) ->
    application:stop(App),
    ensure_stoped(Apps).