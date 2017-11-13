// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// <summary>
    ///     Private operation used to implement both the bit flip encoder and decoder.
    /// 
    ///     Note that this encoder can make use of in-place coherent recovery,
    ///     in which case it will "cause" the error described
    ///     by the initial state of <param>auxQubits</param>.
    ///     In particular, if <param>auxQubits</param> are initially in the state |10〉, this
    ///     will cause an X₁ error on the encoded qubit.
    /// <cite doi="10.1103/PhysRevA.85.044302" />
    /// </summary>
    operation BFEncoderImpl(coherentRecovery : Bool, data : Qubit[], scratch : Qubit[])  : ()
    {
        body {
            if (coherentRecovery) {
                (Controlled(X))(scratch, data[0]);
            }
            (Controlled(X))(data, scratch[0]);
            (Controlled(X))(data, scratch[1]);
        }

        adjoint auto
    }

    /// <summary>
    ///     Encodes into the [3, 1, 3] / ⟦3, 1, 1⟧ bit-flip code.
    /// </summary>
    // TODO: document parameters
    operation BitFlipEncoder(physRegister : Qubit[], auxQubits : Qubit[])  : LogicalRegister
    {
        body {
            BFEncoderImpl(false, physRegister, auxQubits);

            let logicalRegister = LogicalRegister(physRegister + auxQubits);
            return logicalRegister;
        }
    }

    operation BitFlipDecoder( logicalRegister : LogicalRegister)  : (Qubit[], Qubit[])
    {
        body {
            let physRegister = [logicalRegister[0]];
            let auxQubits = logicalRegister[1..2];

            (Adjoint BFEncoderImpl)(false, physRegister, auxQubits);

            return (physRegister, auxQubits);
        }
    }

    /// <summary>
    ///     Returns a QECC value representing the ⟦3, 1, 1⟧ bit flip code encoder and
    ///     decoder with in-place syndrome measurement.
    /// </summary>
    operation  BitFlipCode()  : QECC
    {
        body {
            let e = EncodeOp(BitFlipEncoder);
            let d = DecodeOp(BitFlipDecoder);
            let s = SyndromeMeasOp(MeasureStabilizerGenerators([
                [PauliZ; PauliZ; PauliI];
                [PauliI; PauliZ; PauliZ]
            ], _, MeasureWithScratch));
            let code = QECC(e, d, s);
            return code;
        }
    }

    function BitFlipRecoveryFn()  : RecoveryFn
    {
        return TableLookupRecovery([
            [PauliI; PauliI; PauliI];
            [PauliX; PauliI; PauliI];
            [PauliI; PauliI; PauliX];
            [PauliI; PauliX; PauliI]
        ]);
    }

}
