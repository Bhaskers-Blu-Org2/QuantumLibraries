// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
	open Microsoft.Quantum.Primitive;

	// Functions here may be commonly used in other libraries and could be made global.

    /// # Summary
	/// This performs a phase shift operation about the state $\ket{1\cdots 1}\bra{1\cdots 1}$.
	operation RAll1( phase: Double, qubits: Qubit[] ) : ()
	{
		body {
			let nQubits = Length(qubits);
			let flagQubit = qubits[0];
			let systemRegister = qubits[1..nQubits-1];

			(Controlled R1(phase, _))(systemRegister, flagQubit);

		}

		adjoint auto
		controlled auto
		controlled adjoint auto
	}

    ///summary:
	///     This performs a phase shift operation about the state |0...0><0...0|
	operation RAll0( phase: Double, qubits: Qubit[] ) : ()
	{
		body {

			WithCA(ApplyToEachAC(X, _), RAll1(phase, _), qubits);

		}

		adjoint auto
		controlled auto
		controlled adjoint auto
	}


	/// <summary>
	/// Combines the oracles DeterministicStateOracle and ObliviousOracle
	/// </summary>
    operation _ObliviousOracleFromDeterministicStateOracle(ancillaOracle : DeterministicStateOracle, signalOracle : ObliviousOracle, ancillaRegister: Qubit[], systemRegister: Qubit[]) : (){
		body{
				ancillaOracle(ancillaRegister);
				signalOracle(ancillaRegister, systemRegister);
		}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}

	function ObliviousOracleFromDeterministicStateOracle(ancillaOracle : DeterministicStateOracle, signalOracle : ObliviousOracle) : ObliviousOracle{
		return ObliviousOracle(_ObliviousOracleFromDeterministicStateOracle(ancillaOracle, signalOracle,_,_));
	}

    /// <summary>
	/// Converts an oracle of type StateOracle to DeterministicStateOracle
	/// </summary>
    operation _DeterministicStateOracleFromStateOracle(idxFlagQubit: Int, stateOracle : StateOracle, startQubits: Qubit[]) : (){
		body{
			stateOracle(idxFlagQubit, startQubits);
		}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}

	function DeterministicStateOracleFromStateOracle(idxFlagQubit: Int, stateOracle : StateOracle) : DeterministicStateOracle{
		return DeterministicStateOracle(_DeterministicStateOracleFromStateOracle(idxFlagQubit, stateOracle,_));
	}

    /// <summary>
	/// Converts an oracle of type DeterministicStateOracle to StateOracle
	/// </summary>
    operation _StateOracleFromDeterministicStateOracle(idxFlagQubit : Int, oracleStateDeterministic : DeterministicStateOracle, qubits: Qubit[]): ()
	{
		body{
			oracleStateDeterministic(qubits);
		}
		adjoint auto
		controlled auto
		controlled adjoint auto
	}
    function StateOracleFromDeterministicStateOracle(oracleStateDeterministic : DeterministicStateOracle) : StateOracle {
		return StateOracle(_StateOracleFromDeterministicStateOracle(_, oracleStateDeterministic,_));
	}

    /// <summary>
	/// Constructs a reflection about the all-zero string |0...0>, which is the typical input state to amplitude amplification.
	/// </summary>
	/// <param name = "phase"> Phase of partial reflection </param>
	/// <param name = "qubits"> Qubits of all-zero string </param>
	/// <remarks> 
	/// -
	/// </remarks>
    operation _ReflectionStart(phase: Double, qubits: Qubit[] ) : () {
		body {
			RAll0(phase, qubits );
		}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}
	function ReflectionStart() : ReflectionOracle {
		return ReflectionOracle(_ReflectionStart( _, _ ));
	}

	/// <summary>
	/// Constructs reflection about a some state |?> from the oracle of type "DeterministicStateOracle" where O|0> = |?>
	/// </summary>
	/// <param name = "phase"> Phase of partial reflection </param>
	/// <param name = "oracle"> Oracle of type "DeterministicStateOracle" </param>
	/// <param name = "systemRegister"> Qubits acted on by "oracle" </param>
	/// <remarks> 
	/// -
	/// </remarks>
	operation ReflectionOracleFromDeterministicStateOracleImpl(phase: Double, oracle: DeterministicStateOracle, systemRegister: Qubit[]): ()
	{
		body {
			WithCA((Adjoint oracle), RAll0(phase, _), systemRegister);
		}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}
	function ReflectionOracleFromDeterministicStateOracle(oracle: DeterministicStateOracle): ReflectionOracle
	{
		return ReflectionOracle(ReflectionOracleFromDeterministicStateOracleImpl(_, oracle, _ ));
	}

	/// <summary>
	/// Constructs reflection about the target state uniquely marked by the flag qubit state |1>_f, prepared the oracle of type "StateOracle"
	/// </summary>
	/// <param name = "phase"> Phase of partial reflection </param>
	/// <param name = "idxFlagQubit"> Index to flag qubit of oracle </param>
	/// <param name = "systemRegister"> All other qubits acted on by oracle </param>
	/// <remarks> 
	/// -
	/// </remarks>
	operation TargetStateReflectionOracleImpl(phase: Double, idxFlagQubit : Int, qubits: Qubit[]): ()
	{
		body {
			R1(phase, qubits[idxFlagQubit]);
		}

		adjoint auto
		controlled auto
		adjoint controlled auto
	}
	function TargetStateReflectionOracle(idxFlagQubit : Int): ReflectionOracle
	{
		return ReflectionOracle(TargetStateReflectionOracleImpl( _ , idxFlagQubit , _ ));
	}

}
