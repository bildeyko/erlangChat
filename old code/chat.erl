-module(chat).
-export ([start/0, connection_loop/1]).

start() ->
	{ok, ListenSocket} = gen_tcp:listen(16000, [binary]),
	server_loop(ListenSocket).

server_loop(ListenSocket) ->
	io:format("~s~n", ["Wait..."]),
	{ok, Socket} = gen_tcp:accept(ListenSocket),
	Pid = spawn(fun() -> receive start -> ok end, connection_loop(Socket) end),
	gen_tcp:controlling_process(Socket, Pid),
	Pid ! start,
	server_loop(ListenSocket).

connection_loop(Socket) ->
receive
	{tcp, _S, Data} ->
		io:format("~w ~s~n", [self(), Data]),
		%{ok, Packet, Rest} = erlang:decode_packet(http, Data, []),
		%io:format("~w ~n", [erlang:decode_packet(httph, Rest, [])]);		
		{ok, Key} = header(erlang:decode_packet(http, Data, [])),
		Str = string:concat(Key,"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"),
		Base64 = base64:encode_to_string(crypto:hash(sha,Str)),
		send(Socket, list_to_binary("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: "++Base64++"\r\nSec-WebSocket-Protocol: chat\r\n\r\n"));
	_ ->
        io:format("~w Error or socket closed, closing.~n", [self()]),
        gen_tcp:close(Socket)
end.

send(Socket, <<Data/binary>>) ->
	gen_tcp:send(Socket, Data).

header({more, _}) ->
	eof;
header({ok, Packet, Rest}) ->
	Line = erlang:decode_packet(httph, Rest, []),
	{_, P, _R} = Line,
	case get_socket_key(P) of
		{ok, Key} -> {ok, Key};
		_ -> header(Line)
	end;	
header({error, Reason}) ->
	Reason.

get_socket_key({_,_,Field,_,Value}) ->
	io:format("~s ~n", [Field]),
	case is_atom(Field) of
		false when Field == "Sec-Websocket-Key" ->
			{ok, Value};
		false when Field /= "Sec-Websocket-Key" ->
			no;
		true -> no
	end.
	