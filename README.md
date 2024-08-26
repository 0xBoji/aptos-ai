# AI Contract Documentation

## Overview
This contract manages AI-related submissions, allowing users to submit data for processing, store results, and manage submissions.

## Structures

### Submission
Represents a single AI submission.

- `id`: u64 - Unique identifier for the submission
- `data`: vector<u8> - Raw data for the submission
- `result_link`: Option<address> - Optional link to the result
- `result_data`: Option<vector<u8>> - Optional raw result data
- `metadata`: Option<vector<u8>> - Optional metadata for the submission

### AIContractState
Manages the state of the AI contract.

- `submissions`: SimpleMap<u64, Submission> - Map of all submissions
- `submission_counter`: u64 - Counter for generating unique submission IDs
- `submission_events`: EventHandle<SubmissionEvent> - Handle for submission events

### SubmissionEvent
Event emitted when a new submission is created.

- `id`: u64 - ID of the submission
- `data`: vector<u8> - Raw data of the submission

## Functions

### initialize(account: &signer)
Initializes the AI contract state.

### new_submission(account: &signer, data: vector<u8>, payment: Coin<AptosCoin>)
Creates a new submission.

Parameters:
- `account`: The signer creating the submission
- `data`: Raw data for the submission
- `payment`: Payment in AptosCoin (minimum 0.01 APT)

Emits a `SubmissionEvent`.

### store_result(account: &signer, id: u64, link: address, result_data: vector<u8>, metadata: vector<u8>)
Stores the result for a given submission.

Parameters:
- `account`: The signer storing the result
- `id`: ID of the submission
- `link`: Address link to the result
- `result_data`: Raw result data
- `metadata`: Metadata for the result

### delete_submission(account: &signer, id: u64)
Deletes a submission.

Parameters:
- `account`: The signer deleting the submission
- `id`: ID of the submission to delete

## View Functions

### get_submission(id: u64): Submission
Retrieves a submission by its ID.

### get_all_submissions(): vector<Submission>
Retrieves all submissions.

## Error Codes

- `E_INSUFFICIENT_PAYMENT`: u64 = 1 - Insufficient payment for submission
- `E_SUBMISSION_NOT_FOUND`: u64 = 2 - Submission not found

## Events

### SubmissionEvent
Emitted when a new submission is created.

Fields:
- `id`: u64 - ID of the new submission
- `data`: vector<u8> - Raw data of the submission

## Notes
- The contract uses AptosCoin for payments.
- Submissions require a minimum payment of 0.01 APT.
- The contract maintains a global state for all submissions.
- Results can be stored for each submission after processing.
- Submissions can be deleted, but there's no built-in refund mechanism.
