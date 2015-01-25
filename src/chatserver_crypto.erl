-module (chatserver_crypto).

%% API
-export ([get_salt/0]).
-export ([get_MD5pass/2]).

get_salt() ->
	base64:encode_to_string(crypto:strong_rand_bytes(20)).

get_MD5pass(Pass, Salt) ->
	MD5 = crypto:hash(md5, Pass ++ Salt),
	lists:flatten([io_lib:format("~2.16.0b", [B]) || <<B>> <= MD5]).