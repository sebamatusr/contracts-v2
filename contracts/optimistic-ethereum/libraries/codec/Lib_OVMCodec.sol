// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

/* Library Imports */
import { Lib_RLPReader } from "../rlp/Lib_RLPReader.sol";

/**
 * @title Lib_OVMCodec
 */
library Lib_OVMCodec {

    /*********
     * Enums *
     *********/
    
    enum EOASignatureType {
        ETH_SIGNED_MESSAGE,
        NATIVE_TRANSACTON
    }

    enum QueueOrigin {
        SEQUENCER_QUEUE,
        L1TOL2_QUEUE
    }


    /***********
     * Structs *
     ***********/

    struct Account {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
        address ethAddress;
        bool isFresh;
    }

    struct EVMAccount {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }

    struct ChainBatchHeader {
        uint256 batchIndex;
        bytes32 batchRoot;
        uint256 batchSize;
        uint256 prevTotalElements;
        bytes extraData;
    }

    struct ChainInclusionProof {
        uint256 index;
        bytes32[] siblings;
    }

    struct Transaction {
        uint256 timestamp;
        uint256 number;
        QueueOrigin l1QueueOrigin;
        address l1Txorigin;
        address entrypoint;
        uint256 gasLimit;
        bytes data;
    }

    struct ProofMatrix {
        bool checkNonce;
        bool checkBalance;
        bool checkStorageRoot;
        bool checkCodeHash;
    }

    struct QueueElement {
        uint256 timestamp;
        bytes32 batchRoot;
        bool isL1ToL2Batch;
    }

    struct EOATransaction {
        address target;
        uint256 nonce;
        uint256 gasLimit;
        bytes data;
    }


    /*********************************************
     * Internal Functions: Encoding and Decoding *
     *********************************************/

    /**
     * Decodes an EOA transaction (i.e., native Ethereum RLP encoding).
     * @param _transaction Encoded EOA transaction.
     * @return _decoded Transaction decoded into a struct.
     */
    function decodeEOATransaction(
        bytes memory _transaction
    )
        internal
        pure
        returns (
            EOATransaction memory _decoded
        )
    {
        Lib_RLPReader.RLPItem[] memory decoded = Lib_RLPReader.toList(Lib_RLPReader.toRlpItem(_transaction));

        return EOATransaction({
            nonce: Lib_RLPReader.toUint(decoded[0]),
            gasLimit: Lib_RLPReader.toUint(decoded[2]),
            target: Lib_RLPReader.toAddress(decoded[3]),
            data: Lib_RLPReader.toBytes(decoded[5])
        });
    }

    /**
     * Encodes a standard OVM transaction.
     * @param _transaction OVM transaction to encode.
     * @return _encoded Encoded transaction bytes.
     */
    function encodeTransaction(
        Transaction memory _transaction
    )
        internal
        pure
        returns (
            bytes memory _encoded
        )
    {
        return abi.encodePacked(
            _transaction.timestamp,
            _transaction.number,
            _transaction.l1QueueOrigin,
            _transaction.l1Txorigin,
            _transaction.entrypoint,
            _transaction.gasLimit,
            _transaction.data
        );
    }

    /**
     * Hashes a standard OVM transaction.
     * @param _transaction OVM transaction to encode.
     * @return _hash Hashed transaction
     */
    function hashTransaction(
        Transaction memory _transaction
    )
        internal
        pure
        returns (
            bytes32 _hash
        )
    {
        return keccak256(encodeTransaction(_transaction));
    }
}
