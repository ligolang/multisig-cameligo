import { InMemorySigner } from "@taquito/signer";
import { MichelsonMap, TezosToolkit } from "@taquito/taquito";
import { buf2hex } from "@taquito/utils";
import chalk from "chalk";
import { Spinner } from "cli-spinner";
import dotenv from "dotenv";
import multisig from "../compiled/Multisig.json";
import metadata from "./metadata.json";

dotenv.config();

const rpcUrl = process.env.RPC_URL;
const pk = process.env.PK;

const missingEnvVarLog = (name: string) =>
  console.log(
    chalk.redBright`Missing ` +
      chalk.red.bold.underline(name) +
      chalk.redBright` env var. Please add it in ` +
      chalk.red.bold.underline(`deploy/.env`)
  );

const makeSpinnerOperation = async <T>(
  operation: Promise<T>,
  {
    loadingMessage,
    endMessage,
  }: {
    loadingMessage: string;
    endMessage: string;
  }
): Promise<T> => {
  const spinner = new Spinner(loadingMessage);
  spinner.start();
  const result = await operation;
  spinner.stop();
  console.log("");
  console.log(endMessage);

  return result;
};

if (!pk && !rpcUrl) {
  console.log(
    chalk.redBright`Couldn't find env variables. Have you renamed ` +
      chalk.red.bold.underline`deploy/.env.dist` +
      chalk.redBright` to ` +
      chalk.red.bold.underline(`deploy/.env`)
  );

  process.exit(-1);
}

if (!pk) {
  missingEnvVarLog("PK");
  process.exit(-1);
}

if (!rpcUrl) {
  missingEnvVarLog("RPC_URL");
  process.exit(-1);
}

const Tezos = new TezosToolkit(rpcUrl);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer });

const signers: Array<string> = [
  "tz1KeYsjjSCLEELMuiq1oXzVZmuJrZ15W4mv",
  "tz1MBWU1WkszFfkEER2pgn4ATKXE9ng7x1sR",
  "tz1TDZG4vFoA2xutZMYauUnS4HVucnAGQSpZ",
  "tz1fi3AzSELiXmvcrLKrLBUpYmq1vQGMxv9p",
  "tz1go7VWXhhkzdPMSL1CD7JujcqasFJc2hrF",
];

async function deploy() {
  const storage = {
    metadata: MichelsonMap.fromLiteral({
      "": buf2hex(Buffer.from("tezos-storage:contents")),
      contents: buf2hex(Buffer.from(JSON.stringify(metadata))),
    }),
    signers: signers,
    threshold: 3,
    proposal_map: new MichelsonMap(),
    proposal_counter: 0,
  };

  try {
    const origination = await makeSpinnerOperation(
      Tezos.contract.originate({
        code: multisig,
        storage: storage,
      }),
      {
        loadingMessage: chalk.yellowBright`Deploying contract`,
        endMessage: chalk.green`Contract deployed!`,
      }
    );

    await makeSpinnerOperation(origination.contract(), {
      loadingMessage:
        chalk.yellowBright`Waiting for contract to be confirmed at: ` +
        chalk.yellow.bold(origination.contractAddress),
      endMessage: chalk.green`Contract confirmed!`,
    });
  } catch (error: any) {
    console.log("");
    console.log(chalk.redBright`Error during deployment:`);
    console.log(error);

    process.exit(1);
  }
}

deploy();
