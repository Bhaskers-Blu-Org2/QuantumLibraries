// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.Ising {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    //////////////////////////////////////////////////////////////////////////
    // Introduction //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // TODO: write a short summary here.

    // NB: This sample builds on the results of the AdiabaticIsing sample.
    //
    //     If you have not worked through that sample yet, we suggest doing
    //     so first before proceeding with this sample.

    //////////////////////////////////////////////////////////////////////////
    // Phase Estimation of Ising Models //////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    // After adiabatic evolution, we perform phase estimation to extract the ground state energy.
    // First, we define the unitary on which phase esitmation is performed.

    /// # Summary
    /// TOODO
    ///
    /// # Input
    /// ## nSites
    /// ## hXFinal
    /// ## jZFinal
    /// ## qpeStepSize
    /// ## qubits
    operation IsingQPEUnitary(nSites: Int, hXFinal: Double, jZFinal: Double, qpeStepSize: Double, qubits: Qubit[]) : () {
        body {
            let hXInitial = hXFinal;
            let schedule = Float(1);
            let trotterOrder = 1;
            let simulationAlgorithm = TrotterSimulationAlgorithm(qpeStepSize, trotterOrder);
            let evolutionSet = PauliEvolutionSet();
            let evolutionGenerator = EvolutionGenerator(evolutionSet , IsingEvolutionScheduleImpl(nSites, hXInitial, hXFinal, jZFinal, schedule));
            simulationAlgorithm(qpeStepSize, evolutionGenerator, qubits);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    // Let us define the phase estimation algorithm that we will use
	//     We use the Robust Phase Estimation algorithm
	//     of Kimmel, Low and Yoder.

    /// # Summary
    /// TODO
    ///
    /// # Input
    /// ## nSites
    /// ## hXFinal
    /// ## jZFinal
    /// ## adiabaticTime
    /// ## trotterStepSize
    /// ## trotterOrder
    /// ## qpeStepSize
    /// ## nBitsPrecision
    operation IsingEstimateEnergy(nSites: Int, hXInitial: Double, hXFinal: Double, jZFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, qpeStepSize: Double, nBitsPrecision: Int) : (Double, Result[]) {
        body{
            let qpeOracle = OracleToDiscrete (IsingQPEUnitary(nSites, hXFinal, jZFinal, qpeStepSize, _) );
            let qpeAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
            let adiabaticEvolution = IsingAdiabaticEvolution_2(nSites, hXInitial, hXFinal, jZFinal, adiabaticTime, trotterStepSize, trotterOrder);

            mutable phaseEst = Float(0);
            mutable results = new Result[nSites];

            using(qubits = Qubit[nSites]){
                Ising1DStatePrep(qubits);
                adiabaticEvolution(qubits);
                set phaseEst = qpeAlgorithm(qpeOracle, qubits) / qpeStepSize;
                set results = MultiM(qubits);
                ResetAll(qubits);
            }
            return (phaseEst, results);
        }
    }

    // Alternatively, we may use the built-in function AdiabaticStateEnergyEstimate.


    /// # Summary
    /// TODO
    ///
    /// # Input
    /// ## nSites
    /// ## hXFinal
    /// ## jZFinal
    /// ## adiabaticTime
    /// ## trotterStepSize
    /// ## trotterOrder
    /// ## qpeStepSize
    /// ## nBitsPrecision
    operation IsingEstimateEnergy_Builtin(nSites: Int, hXInitial: Double, hXFinal: Double, jZFinal: Double, adiabaticTime: Double, trotterStepSize: Double, trotterOrder: Int, qpeStepSize: Double, nBitsPrecision: Int) : Double {
        body{
            let statePrepUnitary = Ising1DStatePrep;
            let adiabaticUnitary = IsingAdiabaticEvolution_2(nSites, hXInitial, hXFinal, jZFinal, adiabaticTime, trotterStepSize, trotterOrder) ;
            let qpeUnitary = IsingQPEUnitary(nSites, hXFinal, jZFinal, qpeStepSize, _);
            let phaseEstAlgorithm = RobustPhaseEstimation(nBitsPrecision, _, _);
            let phaseEst = AdiabaticStateEnergyEstimate(nSites, statePrepUnitary, adiabaticUnitary, qpeUnitary, phaseEstAlgorithm) / qpeStepSize;
            return phaseEst;
        }
    }

}
