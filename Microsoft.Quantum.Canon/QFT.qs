// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
	open Microsoft.Quantum.Primitive;

	/// <summary>
	/// 	Apply the Approximate Quantum Fourier Transform (AQFT) to a quantum register. 
	/// </summary>
	/// <param name = "a"> approximation parameter which determines at which level the controlled Z-rotations that occur in the QFT circuit are pruned. </param>
	/// <param name = "qs"> quantum register of n qubits to which the approximate quantum Fourier transform is applied. </param>
	/// <remarks> AQFT requires Z-rotation gates of the form 2π/2ᵏ and Hadamard gates. The input and output are assumed to be encoded in big endian encoding. 
	/// 	The approximation parameter a determines the pruning level of the Z-rotations, i.e., a ∈ {0..n} and all Z-rotations 2π/2ᵏ where k>a are 
	/// 	removed from the QFT circuit. It is known that for k >= log₂(n)+log₂(1/ε)+3 one can bound ||QFT-AQFT||<ε. 
	/// 	[ M. Roetteler, Th. Beth, Appl. Algebra Eng. Commun. Comput. 19(3): 177-193 (2008),  http://doi.org/10.1007/s00200-008-0072-2 ]
	/// 	[ D. Coppersmith, https://arxiv.org/abs/quant-ph/0201067 ]
	/// </remarks>
	operation ApproximateQFT ( a: Int, qs: BigEndian) : () {
		body {
			// FIXME Solid #701: lengths of UDTs < T[] are not supported currently.
			// let nQubits = Length(qs)
			let nQubits = 1;

			if ( nQubits == 0 ) {
				fail "function register qs requires at least 1 qubit.";
			}
			if ( a < 0 || a > nQubits ) {
				fail "approximation parameter a must be in {0..n}";
			}
			for (i in 0..nQubits - 1) {
				for (j in 0..(i-1)) {
					if ( (i-j) < a ) {
						(Controlled R1Frac)( [qs[i]], (1, i - j, qs[j]) );
					}
				}
				H(qs[i]);
			}

			// Apply the bit reversal permutation to the quantum register as
			// a side effect, such that we enforce the invariants specified
			// by the BigEndian UDT.
			SwapReverseRegister(qs);
		}

		adjoint auto
		controlled auto
		controlled adjoint auto
	}

	/// <summary>
	///     Performs the quantum Fourier transform on an quantum register containing an integer in the big-endian representation.
	/// </summary>
	/// <param name = "qs"> quantum register of n qubits to which the quantum Fourier transform is applied.</param>
	/// <remarks>
	///     QFT requires Z-rotation gates of the form 2π/2ᵏ and Hadamard gates. The input and output are assumed to be in big endian encoding.
	/// </remarks>
	operation QFT ( qs : BigEndian ) : () {
		body {
			// FIXME Solid #701: lengths of UDTs < T[] are not supported currently.
			// let nQubits = Length(qs)
			let nQubits = 1;
			ApproximateQFT(nQubits, qs);
		}

		adjoint auto
		controlled auto
		controlled adjoint auto
	}

}
