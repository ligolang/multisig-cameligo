ligo_compiler?=docker run --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:stable
# ^ Override this variable when you run make command by make <COMMAND> ligo_compiler=<LIGO_EXECUTABLE>
# ^ Otherwise use default one (you'll need docker)
protocol_opt?=
json=--michelson-format json

all: clean compile test

help:
	@echo  'Usage:'
	@echo  '  all             - Remove generated Michelson files, recompile smart contracts, lauch all tests and originate contract'
	@echo  '  compile '
	@echo  '  clean           - Remove generated Michelson and JavaScript files'
	@echo  '  test            - Run Ligo tests'
	@echo  '  deploy          - Deploy multisig smart contract (typescript using Taquito)'


compile: compile_ml

compile_ml: src/contract.mligo
	@mkdir -p ./compiled
	@echo "Compiling to Michelson"
	@$(ligo_compiler) compile contract src/contract.mligo $(protocol_opt) > compiled/Multisig_mligo.tz
	@echo "Compiling to Michelson in JSON format"
	@$(ligo_compiler) compile contract src/contract.mligo $(json) $(protocol_opt) > compiled/Multisig_mligo.json

install:
	@echo "npm ci"
	@npm ci

clean:
	@echo "Removing Michelson files"
	@rm -f compiled/*.tz
	@echo "Removing Michelson 'json format' files"
	@rm -f compiled/*.json

test: test/multisig.test.jsligo
	@echo "Running tests"
	@$(ligo_compiler) run test test/multisig.test.jsligo $(protocol_opt)
	@echo "Running mutation tests"
	@$(ligo_compiler) run test test/multisig_mutation.test.jsligo $(protocol_opt)

deploy: node_modules deploy.js

deploy.js:
	@if [ ! -f ./deploy/metadata.json ]; then cp deploy/metadata.json.dist deploy/metadata.json ; fi
	@echo "Running deploy script\n"
	@cd deploy && npm start

node_modules:
	@echo "Installing deploy script dependencies"
	@cd deploy && npm install
	@echo ""