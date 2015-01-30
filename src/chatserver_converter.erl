-module (chatserver_converter).

%% API
-export ([json_bin_to_str/1]).
-export ([json_str_to_bin/1]).
-export ([json_listStr_to_bin/1]).

%% API
json_bin_to_str(List) ->
	bin_to_str(List, []).
json_str_to_bin(List) ->
	str_to_bin(List, []).
json_listStr_to_bin(List) ->
	listStr_to_bin(List, []).

%% Private
bin_to_str([], NewList) ->
	NewList;
bin_to_str([H|L], NewList) ->
	{Label, Data} = H,
	StrData = erlang:binary_to_list(Data),
	bin_to_str(L, lists:append(NewList, [{Label, StrData}])).

% This function has bad style. Should rewrite it.
str_to_bin([], NewList) ->
	NewList;
str_to_bin([{Label, Data}|L], NewList) when not(is_binary(Data)) ->
	H = hd(Data),
	if erlang:is_binary(H) ->
		BinData = Data;
		true ->
			BinData = erlang:list_to_binary(Data)
	end,
	str_to_bin(L, lists:append(NewList, [{Label, BinData}]));
str_to_bin([{Label, Data}|L], NewList) when is_binary(Data) ->
	str_to_bin(L, lists:append(NewList, [{Label, Data}]));
str_to_bin([List|L], NewList) ->
	%BinData = json_listStr_to_bin(Obj),
	%BinData = list_to_binary(Obj),
	%str_to_bin(L, lists:append(NewList, [[{Label, BinData}]])).
	str_to_bin(L,  lists:append(NewList, [List])).

objects_to_bin(List) ->
	list_of_objects_to_bin(List, []).

list_of_objects_to_bin([], NewList) ->
	NewList;
list_of_objects_to_bin([H|T], NewList) ->
	BinList = json_str_to_bin(erlang:tuple_to_list(H)),
	list_of_objects_to_bin(T, [BinList|NewList]).

is_json_object(List) ->
	case erlang:length(List) of
		1 ->
			if erlang:is_tuple(hd(List)) ->
				true;
				true ->
					false
			end;
		_ ->
			false
	end.

listStr_to_bin([], NewList) ->
	NewList;
listStr_to_bin(List, NewList) ->
	Bin = erlang:list_to_binary(hd(List)),
	listStr_to_bin(tl(List), [Bin| NewList]).