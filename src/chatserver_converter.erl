-module (chatserver_converter).

%% API
-export ([json_bin_to_str/1]).
-export ([json_str_to_bin/1]).

%% API
json_bin_to_str(List) ->
	bin_to_str(List, []).
json_str_to_bin(List) ->
	str_to_bin(List, []).

%% Private
bin_to_str([], NewList) ->
	NewList;
bin_to_str([H|L], NewList) ->
	{Label, Data} = H,
	StrData = erlang:binary_to_list(Data),
	bin_to_str(L, lists:append(NewList, [{Label, StrData}])).

str_to_bin([], NewList) ->
	NewList;
str_to_bin([H|L], NewList) ->
	{Label, Data} = H,
	BinData = erlang:list_to_binary(Data),
	str_to_bin(L, lists:append(NewList, [{Label, BinData}])).