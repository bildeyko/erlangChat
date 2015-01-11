REBAR = `rebar`
ERL = `erl`

all: deps compile

deps:
	@( $(REBAR) get-deps )

compile: clean
	@( $(REBAR) compile )

clean:
	@( $(REBAR) clean )

run:
	@( $(ERL) -pa ebin deps/*/ebin -s chatserver )

.PHONY: all deps compile clean run