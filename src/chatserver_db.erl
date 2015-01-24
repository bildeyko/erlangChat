-module (chatserver_db).
-behaviour (gen_server).

%% API
-export ([start_link/0]).
-export ([insert_user/3]).
-export ([get_user/1]).

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

get_user(Login) ->
	gen_server:call({global, ?MODULE}, {select_user, Login}).

%% gen_server
init([]) ->
	%[Host, User, Password, Database, Port] = ["127.0.0.1", "chat_admin", "1234", "chat_database", 5432],
	case os:getenv("OPENSHIFT_POSTGRESQL_DB_HOST") of
		false ->
			Host = "127.0.0.1";
		Host ->
			ok
	end,
	case os:getenv("OPENSHIFT_POSTGRESQL_DB_USERNAME") of
		false ->
			User = "chat_admin";
		User ->
			ok
	end,
	case os:getenv("OPENSHIFT_POSTGRESQL_DB_PASSWORD") of
		false ->
			Password = "1234";
		Password ->
			ok
	end,
	case os:getenv("PGDATABASE") of
		false ->
			Database = "chat_database";
		Database ->
			ok
	end,
	Port = 5432,
	io:format("DB: ~s ~s ~s ~s ~w~n", [Host, User, Password, Database, Port]),
	{ok, C} = pgsql:connect(Host, User, Password, [{database, Database}, {port, Port}]),
	{ok, C}.

handle_call({insert_user, Login, Pass, Salt}, _From, C) ->
	ResDB = pgsql:equery(C, "INSERT INTO users (login, pass, salt) VALUES ($1, $2, $3)", [Login, Pass, Salt]),
	{reply, ResDB, C};
handle_call({select_user, Login}, _From, C) ->
	ResDB = pgsql:equery(C, "SELECT pass, salt FROM users WHERE login = $1", [Login]),
	case ResDB of 
		{ok, Cols, [Row|_]} ->
			ListKeys = [binary_to_atom(Key, utf8) || {_,Key,_,_,_,_} <- Cols],
			ListValues = [if is_binary(Value) -> erlang:binary_to_list(Value); true -> Value end || Value <- tuple_to_list(Row)],
			Res = lists:zip(ListKeys, ListValues),
			{reply, {ok, Res}, C};
		{ok, _Cols, []} ->
			{reply, {not_found, []}, C}
	end.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
handle_cast(_Message, State) -> 
	{noreply, State}.
handle_info(_Message, State) -> 
	{noreply, State}.
terminate(_Reason, _State) -> 
	ok.