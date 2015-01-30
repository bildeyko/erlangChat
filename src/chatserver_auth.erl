-module (chatserver_auth).
-behaviour (gen_server).

%% API
-export ([start_link/0]).
-export ([insert_user/2]).
-export ([find_user/1]).
-export ([delete_user/1]).
-export ([get_users/0]).
-export ([show_dict/0]).

%% gen_server
-export ([init/1]).
-export ([handle_call/3]).

%% API
start_link() -> 
	gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

insert_user(Token, Login) ->
	gen_server:call({global, ?MODULE}, {insert_user, Token, Login}).

find_user(Token) ->
	gen_server:call({global, ?MODULE}, {find_user, Token}).

delete_user(Token) ->
	gen_server:call({global, ?MODULE}, {delete_user, Token}).

get_users() ->
	gen_server:call({global, ?MODULE}, get_users).

show_dict() ->
	gen_server:call({global, ?MODULE}, show_dict).

%% gen_server
init([]) ->
	Auths = orddict:new(),
	{ok, Auths}.

handle_call({insert_user, Key, Value}, _From, Auths) ->
	NewAuths = orddict:append(Key, Value, Auths),
	{reply, ok, NewAuths};
handle_call({find_user, Key}, _From, Auths) ->
	case orddict:find(Key, Auths) of 
		{ok, Value} ->
			{reply, {ok, Value}, Auths};
		error ->
			{reply, {not_found, []}, Auths}
	end;
handle_call({delete_user, Key}, _From, Auths) ->
	case orddict:find(Key, Auths) of 
		{ok, Value} ->
			NewAuths = orddict:erase(Key, Auths),
			{reply, ok, NewAuths};
		error ->
			{reply, not_found, Auths}
	end;
handle_call(get_users, _From, Auths) ->
	List = orddict:to_list(Auths),
	OnlyLogins = create_list(List, []),
	{reply, OnlyLogins, Auths};
handle_call(show_dict, _From, Auths) ->
	List = orddict:to_list(Auths),
	io:format("Auth users: ~n~p~n", [List]),
	{reply, ok, Auths}.

%% private
create_list([], Logins) ->
	Logins;
create_list([{_, Login}|T], Logins) ->
	% 1.hd(Login) because Login is a list with some values.
	% 		But this Auths contains KEY and one value. 
	% 2.Here data is binary! It's for normal working of jsx library.
	create_list(T, [list_to_binary(hd(Login))|Logins]).
	