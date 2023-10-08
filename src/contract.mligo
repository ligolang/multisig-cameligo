#import "../common/constants.mligo" "Constants"
#import "parameter.mligo" "Parameter"
#import "storage.mligo" "Storage"
#import "conditions.mligo" "Conditions"
#import "contracts/fa2.mligo" "FA2"

// ===============================================================================================

type proposal_params = Parameter.Types.proposal_params
type proposal_number = Parameter.Types.proposal_number
type storage = Storage.Types.t
type result = operation list * storage

module Preamble = struct
    [@inline]
    let prepare_new_proposal (params, storage: Parameter.Types.proposal_params * Storage.Types.t) : Storage.Types.proposal =
        let () = Conditions.only_signer storage in
        let () = Conditions.amount_must_be_zero_tez (Tezos.get_amount ()) in
        Storage.Utils.create_proposal params

    [@inline]
    let retrieve_a_proposal (proposal_number, storage: Parameter.Types.proposal_number * Storage.Types.t) : Storage.Types.proposal =
        let () = Conditions.only_signer storage in
        let target_proposal = Storage.Utils.retrieve_proposal(proposal_number, storage) in
        let () = Conditions.not_yet_signer target_proposal in
        target_proposal
end

// ===============================================================================================

(**
 * Proposal creation
 *)
[@entry]
let create_proposal (params : proposal_params) (store : storage) : result =
    let proposal = Preamble.prepare_new_proposal(params, store) in
    let store = Storage.Utils.register_proposal(proposal, store) in
    (Constants.no_operation, store)

(**
 * Proposal signature
 *)

[@entry]
let sign_proposal (number : proposal_number) (store : storage) : result =
    let proposal = Preamble.retrieve_a_proposal(number, store) in

    let proposal = Storage.Utils.add_signer_to_proposal(proposal, (Tezos.get_sender ()), store.threshold) in
    let store = Storage.Utils.update_proposal(number, proposal, store) in

    let operations = FA2.perform_operations proposal in

    (operations, store)