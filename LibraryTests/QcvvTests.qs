// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Tests {
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;

    operation ChoiStateTest() : () {
        body {
            using (register = Qubit[2]) {
                PrepareChoiStateCA(NoOp, [register[0]], [register[1]]);
                // As usual, the same confusion about {+1, -1} and {0, 1}
                // labeling bites us here.
                Assert([PauliX; PauliX], register, Zero, "XX");
                Assert([PauliZ; PauliZ], register, Zero, "ZZ");
            }
        }
    }

    operation EstimateFrequencyTest () : () {
        body {
            let freq = EstimateFrequency(
                ApplyToEach(H, _),
                MeasureAllZeroState,
                1,
                1000
            );

            AssertAlmostEqualTol(freq, 0.5, 0.1);
        }
    }

}
