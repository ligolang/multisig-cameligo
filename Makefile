ligo_compiler=docker run --rm -v "$$PWD":"$$PWD" -w "$$PWD" ligolang/ligo:stable
PROTOCOL_OPT=
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
	@mkdir -p ./compiled
	@echo "Compiling to Michelson"
	@$(ligo_compiler) compile contract cameligo/contract.mligo $(PROTOCOL_OPT) > compiled/Multisig_mligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo_compiler) compile contract cameligo/contract.mligo $(json) $(PROTOCOL_OPT) > compiled/Multisig_mligo.json

clean:
	@echo "Removing Michelson files"
	@rm -f compiled/*.tz
	@echo "Removing Michelson 'json format' files"
	@rm -f compiled/*.json

test: test/multisig.test.jsligo
	@echo "Running tests"
	@$(ligo_compiler) run test test/multisig.test.jsligo $(PROTOCOL_OPT)
	@echo "Running mutation tests"
	@$(ligo_compiler) run test test/multisig_mutation.test.jsligo $(PROTOCOL_OPT)

deploy: origination/deployMultisig.ts compile
	@if [ ! -f ./origination/metadata.json ]; then cp origination/metadata.json.dist \
        origination/metadata.json ; fi
	@echo "Deploying contract"
	@tsc origination/deployMultisig.ts --esModuleInterop --resolveJsonModule
	@node origination/deployMultisig.js
