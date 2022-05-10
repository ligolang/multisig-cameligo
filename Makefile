ligo=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:0.41.0
protocol=--protocol ithaca
json=--michelson-format json

all: clean compile test

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts, lauch all tests and originate contract'
	@echo  '  compile '
	@echo  '  clean           - Remove generated Michelson and JavaScript files'
	@echo  '  test            - Run Ligo tests'
	@echo  '  originate       - Deploy multisig smart contract (typescript using Taquito)'


compile: compile_ml

compile_ml: cameligo/contract.mligo
	@if [ ! -d ./compiled ]; then mkdir ./compiled ; fi
	@echo "Compiling to Michelson"
	@$(ligo) compile contract cameligo/contract.mligo $(protocol) > compiled/Multisig_mligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo) compile contract cameligo/contract.mligo $(json) $(protocol) > compiled/Multisig_mligo.json

clean:
	@echo "Removing Michelson files"
	@rm -f compiled/*.tz
	@echo "Removing Michelson 'json format' files"
	@rm -f compiled/*.json

test: tests/multisig.test.jsligo
	@echo "Running tests"
	@$(ligo) run test tests/multisig.test.jsligo $(protocol)
	@echo "Running mutation tests"
	@$(ligo) run test tests/multisig_mutation.test.jsligo $(protocol)

originate: origination/deployMultisig.ts compile
	@echo "Deploying contract"
	@tsc origination/deployMultisig.ts --esModuleInterop --resolveJsonModule
	@node origination/deployMultisig.js
