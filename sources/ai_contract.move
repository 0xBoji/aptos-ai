module ai_contract::ai_contract {
    use sui::tx_context::TxContext;
    use sui::event::Event;
    use sui::coin::Coin;
    use sui::address::Address;
    use sui::option::{self, Option};
    use sui::vector;
    use sui::storage;

    struct Submission has key {
        id: u64,
        data: vector<u8>,
        result_link: Option<Address>,
        result_data: Option<vector<u8>>,
        metadata: Option<vector<u8>>,
    }

    event SubmissionEvent {
        id: u64,
        data: vector<u8>,
    }

    struct Registry has key {
        submissions: vector<Submission>,
    }

    public fun initialize(ctx: &mut TxContext) {
        let registry = Registry {
            submissions: vector::empty<Submission>(),
        };
        tx_context::create(&registry, ctx);
    }

    public fun new_submission(ctx: &mut TxContext, data: vector<u8>, payment: Coin<Coin<SUI>>) {
        // Ensure payment is received (0.01 SUI)
        assert!(coin::value(&payment) >= 1_000_000, 0); // 1_000_000 microSUI = 0.01 SUI
        coin::burn(payment); // Burn the payment
        
        // Generate a new submission ID
        let id = tx_context::generate_random_number(ctx);
        
        // Create a new submission (Can cut a timestamp)
        let submission = Submission {
            id,
            data: data,
            result_link: option::none<Address>(),
            result_data: option::none<vector<u8>>(),
            metadata: option::none<vector<u8>>(),
        };
        
        // Emit event
        event::emit_event(&SubmissionEvent {
            id,
            data,
        });

        // Store the submission in state storage
        let registry = tx_context::borrow_global_mut<Registry>(ctx);
        vector::push_back(&mut registry.submissions, submission);
    }

    public fun store_result(ctx: &mut TxContext, id: u64, link: Address, result_data: vector<u8>, metadata: vector<u8>) {
        let registry = tx_context::borrow_global_mut<Registry>(ctx);

        let index = vector::index_where(&registry.submissions, fun (s: &Submission): bool {
            s.id == id
        });

        match index {
            option::some(i) => {
                let submission = &mut registry.submissions[i];
                submission.result_link = option::some(link);
                submission.result_data = option::some(result_data);
                submission.metadata = option::some(metadata);
            },
            option::none => {
                // Handle error: submission not found
                assert!(false, 1); // Error code 1: Submission not found
            }
        }
    }

    public fun delete_submission(ctx: &mut TxContext, id: u64) {
        let registry = tx_context::borrow_global_mut<Registry>(ctx);
        
        let index = vector::index_where(&registry.submissions, fun (s: &Submission): bool {
            s.id == id
        });

        match index {
            option::some(i) => {
                let submission = vector::swap_remove(&mut registry.submissions, i);
                let storage_refund = storage::delete(&submission);
                // Process the storage refund as needed
                // Example: transferring the refund to the user
            },
            option::none => {
                // Handle error: submission not found
                assert!(false, 1); // Error code 1: Submission not found
            }
        }
    }
}