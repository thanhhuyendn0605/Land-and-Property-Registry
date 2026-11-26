
# Gas Cost Analysis Report

**Project:** Land & Property Registry  
**Course:** Blockchain: Theory & Practices  
**University:** Duy Tan University

## 1. Objective

This report compares the Gas consumption of two Solidity
smart contract implementations:

- LandRegistry.sol (Original)
- LandRegistryOptimized.sol (Optimized)

The objective is to evaluate the impact of using Solidity
custom errors instead of string-based revert messages.

## 2. Optimization Technique

The original contract uses require statements with
string-based error messages.

Example:

```solidity
require(msg.sender == officer, "Not authorized");
```

The optimized contract uses custom errors.

Example:

```solidity
error NotAuthorized();

if (msg.sender != officer) {
    revert NotAuthorized();
}
```

Custom errors can reduce compiled bytecode size and
deployment Gas consumption.

This optimization does not necessarily reduce the Gas
cost of successful transactions because those transactions
do not execute the error-handling branches.

## 3. Measurement Environment

| Parameter | Configuration |
|---|---|
| Tool | Remix IDE |
| Solidity Compiler | 0.8.20 |
| Compiler EVM Target | Paris |
| Compiler Optimizer | Disabled |
| Execution Environment | Remix VM |
| Test Land ID | GAS001 |
| Location | Da Nang |
| Area | 200 |
| Initial Owner | Remix VM Account 1 |
| New Owner | Remix VM Account 2 |

Both contracts were deployed and tested separately.

Gas measurements were taken from the transaction
receipts displayed in Remix.

The primary comparison metric is Transaction Cost.

The same contract inputs and transaction sequence
were used for both implementations.

The Remix VM execution version and exact compiler
settings should be retained as supporting evidence.

## 4. Gas Measurement Results

| Operation | Original Gas | Optimized Gas | Gas Saved | Reduction |
|---|---:|---:|---:|---:|
| Deployment | 1,785,200 | 1,521,525 | 263,675 | 14.77% |
| Register Land | 165,041 | 165,041 | 0 | 0% |
| Request Transfer | 53,076 | 53,076 | 0 | 0% |
| Approve Transfer | 86,642 | 86,642 | 0 | 0% |

All values represent Remix Transaction Cost
measured in Gas units.

## 5. Deployment Gas Analysis

Original deployment:

1,785,200 Gas

Optimized deployment:

1,521,525 Gas

Gas saved:

1,785,200 - 1,521,525 = 263,675 Gas

Percentage reduction:

(263,675 / 1,785,200) * 100 = 14.77%

The optimized contract consumed approximately 14.77%
less Gas during deployment.

This result is consistent with the expected bytecode
reduction from replacing string-based error messages
with Solidity custom errors.

## 6. Land Registration Analysis

Test operation:

```text
registerLand("GAS001", "Da Nang", 200, Account1)
```

Original:

165,041 Gas

Optimized:

165,041 Gas

Gas reduction:

0%

Both contracts consumed identical Gas for the tested
successful land registration transaction.

## 7. Transfer Request Analysis

Test operation:

```text
requestTransfer("GAS001", Account2)
```

The transaction was submitted by Account 1,
the registered landowner.

Original:

53,076 Gas

Optimized:

53,076 Gas

Gas reduction:

0%

Both implementations consumed identical Gas
for the successful transfer request.

## 8. Transfer Approval Analysis

Test operation:

```text
approveTransfer("GAS001")
```

The transaction was submitted by Account 1,
the authorized officer.

Original:

86,642 Gas

Optimized:

86,642 Gas

Gas reduction:

0%

Both contracts consumed identical Gas during
the successful transfer approval operation.

## 9. Interpretation

The optimized contract demonstrated a measurable
reduction in deployment Gas consumption.

However, all three tested successful transactions
had identical Gas costs in both implementations.

This distinction is important:

- Deployment Gas depends partly on compiled bytecode size.
- Successful transaction Gas depends on the executed logic.
- Custom errors primarily affect the representation and
  execution of error-handling paths.
- The cost of reverting transactions was not benchmarked.

Therefore, it would be incorrect to claim that every
transaction becomes cheaper after using custom errors.

## 10. Limitations

The measurements cover four operations and a single
successful input sequence per contract.

The benchmark does not include:

- Multiple input-size variations.
- Gas usage for reverted transactions.
- Different compiler optimizer configurations.
- Production Ethereum network conditions.
- Full security or performance testing.

Comparability also depends on using the same Remix VM,
compiler settings, and equivalent account and contract state.

## 11. Conclusion

The Gas Cost Analysis demonstrates that the optimized
LandRegistry implementation consumed less Gas during
deployment.

The recorded deployment reduction was:

**263,675 Gas (approximately 14.77%).**

The Gas cost for registerLand, requestTransfer,
and approveTransfer remained unchanged.

These results indicate that using custom errors can
improve deployment efficiency without necessarily reducing
Gas consumption for successful transactions.

The project satisfies its implementation objective of
introducing and measuring a Solidity optimization.

The original contract remains the active implementation
used by the Land & Property Registry website.
