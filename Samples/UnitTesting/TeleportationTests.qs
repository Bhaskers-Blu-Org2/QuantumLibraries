﻿namespace Microsoft.Quantum.Samples.UnitTesting {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// If the Teleportation circuit is correct this operation must be an identity
    operation TeleportationIdentityTestHelper (arg : Qubit[]) : () {
        body {
            AssertIntEqual(Length(arg), 1, "Helper is defined only on single qubit input");
            using (anc = Qubit[1])
            {
                Teleportation(arg[0], anc[0]);
                SWAP(arg[0], anc[0]);
            }
        }
    }

    /// # Summary
    /// Tests the correctness of the teleportation circuit from Teleportation.qs
    operation TeleportationTest () : () {
        body {
            // given that there is randomness involved in the Teleportation,
            // repeat the tests several times.
            for(idxIteration in 1 .. 8)
            {
                AssertOperationsEqualInPlace(
                    TeleportationIdentityTestHelper, IdentityTestHelper, 1);
                AssertOperationsEqualReferenced(
                    TeleportationIdentityTestHelper, IdentityTestHelper, 1);
            }
        }
    }

}