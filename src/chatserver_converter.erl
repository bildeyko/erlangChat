-module (chatserver_converter).

-export ([json_bin_to_str/1]).

%% API
json_bin_to_str(List) ->
	bin_to_str(List, []).	

%% Private
bin_to_str([], NewList) ->
	NewList;
bin_to_str([H|L], NewList) ->
	{Label, Data} = H,
	StrData = erlang:binary_to_list(Data),
	bin_to_str(L, lists:append(NewList, [{Label,StrData}])).