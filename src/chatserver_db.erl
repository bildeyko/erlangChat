-module (chatserver_db).
-behaviour (gen_server).

%% API
-export ([start_link/0, insert_user/3]).

%% gen_server
-export ([init/1]).
-export ([handle_call/3]).
-export ([handle_cast/2]).
-export ([handle_info/2]).
-export ([code_change/3]).
-export ([terminate/2]).

%% API
start_link() -> 
	gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

insert_user(Login, Pass, Salt) ->
	gen_server:call({global, ?MODULE}, {insert_user, Login, Pass, Salt}).

%% gen_server
init([]) ->
	[Host, User, Password, Database, Port] = ["127.0.0.1", "chat_admin", "1234", "chat_database", 5432],
	{ok, C} = pgsql:connect(Host, User, Password, [{database, Database}, {port, Port}]),
	{ok, C}.

handle_call({insert_user, Login, Pass, Salt}, _From, C) ->
	Res = pgsql:equery(C, "INSERT INTO users (login, pass, salt) VALUES ($1, $2, $3)", [Login, Pass, Salt]),
	{reply, Res, C}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
handle_cast(_Message, State) -> 
	{noreply, State}.
handle_info(_Message, State) -> 
	{noreply, State}.
terminate(_Reason, _State) -> 
	ok.