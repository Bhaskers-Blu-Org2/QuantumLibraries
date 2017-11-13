// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Examples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    
    // Ising model using the Trotterization library directly
    // Hamiltonian = -(J0 Z0 Z1 + J1 Z1 Z2 + ...) - hz (Z0 + Z1 + ...) - hx (X0 + X1 + ...)
    // idxHamiltonian is in [0, nSites - 1]
    operation Ising1DTrotterUnitariesImpl(nSites : Int, hx : Double, hz: Double, jC: Double, idxHamiltonian: Int, stepSize : Double, qubits : Qubit[]) : ()
    {
        body {
            // when idxHamiltonian is in [0, nSites - 1], apply transverse field "hx"
            // when idxHamiltonian is in [nSites, 2 * nSites - 1], apply and longitudinal field "hz"
            // when idxHamiltonian is in [2 * nSites, 3 * nSites - 2], apply Ising coupling "jC"
            // TODO: Need to separate Rx out as it does not commute
            if(idxHamiltonian <= nSites - 1){
                Exp([PauliX], -1.0 * hx * stepSize, [qubits[idxHamiltonian]]);
                //Rx(hx * stepSize, qubits[idxHamiltonian])
            }
            elif(idxHamiltonian <= 2 * nSites - 1){
                Exp([PauliZ], -1.0 * hz * stepSize, [qubits[idxHamiltonian % nSites]]);
                //Rz(hz * stepSize, qubits[idxHamiltonian % nSites])
            }
            else{
                Exp([PauliZ; PauliZ],  -1.0 * jC * stepSize, qubits[(idxHamiltonian % nSites)..((idxHamiltonian + 1) % nSites)]);
            }
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    function Ising1DTrotterUnitaries(nSites : Int, hx : Double, hz: Double, jC: Double) : (Int, ((Int, Double, Qubit[]) => () : Adjoint, Controlled))
    {
        let nTerms = 3 * nSites - 1;
        return (nTerms, Ising1DTrotterUnitariesImpl(nSites, hx, hz, jC, _, _, _));
    }

    operation Ising1DTrotterStepA(nSites : Int, hx : Double, hz: Double, jC: Double, trotterOrder: Int, trotterStepSize: Double) : (Qubit[] => (): Adjoint, Controlled)
    {
        body {
            let op = Ising1DTrotterUnitaries(nSites, hx, hz, jC);
            return (DecomposeIntoTimeStepsCA(op,trotterOrder))(trotterStepSize, _);
        }
    }
}
