-module (chatserver_auth).
-behaviour (gen_server).

%% API
-export ([start_link/0]).
-export ([insert_user/2]).

%% gen_server
-export ([init/1]).
-export ([handle_call/3]).

%% API
start_link() -> 
	gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

insert_user(Login, Token) ->
	gen_server:call({global, ?MODULE}, {insert_user, Login, Token}).

%% gen_server
init([]) ->
	Auths = orddict:new(),
	{ok, Auths}.

handle_call({insert_user, Key, Value}, _From, Auths) ->
	NewAuths = orddict:append(Key, Value, Auths),
	{reply, ok, NewAuths}.