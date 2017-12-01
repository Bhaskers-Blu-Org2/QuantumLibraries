﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
	open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Given operations implementing operators $U$ and $V$, performs the
    /// operation $UVU^{\dagger}$ on a target. That is, this operation
    /// conjugates $V$ with $U$.
    ///
    /// # Input
    /// ## outerOperation
    /// The operation $U$ that should be used to conjugate $V$.
    /// ## innerOperation
    /// The operation $V$ being conjugated.
    ///
    /// # Remarks
    /// The outer operation is always assumed to be adjointable, but does not
    /// need to be controllable in order for the combined operation to be
    /// controllable.
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.withc"
    /// - @"microsoft.quantum.canon.witha"
    /// - @"microsoft.quantum.canon.withca"
    operation With<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ()), target : 'T)  : ()
    {
        body {  
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.with"
    operation WithA<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Adjoint), target : 'T)  : ()
    {
        body {  
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        adjoint auto
    }


    /// # See Also
    /// - @"microsoft.quantum.canon.with"
    operation WithC<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Controlled), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        controlled(controlRegister) {
            outerOperation(target);
            (Controlled(innerOperation))(controlRegister, target);
            (Adjoint(outerOperation))(target);
        }
    }

    /// # See Also
    /// - @"microsoft.quantum.canon.with"
    operation WithCA<'T>(outerOperation : ('T => ():Adjoint), innerOperation : ('T => ():Adjoint,Controlled), target : 'T)  : ()
    {
        body {
            outerOperation(target);
            innerOperation(target);
            (Adjoint(outerOperation))(target);
        }

        adjoint auto
        controlled(controlRegister) {
            outerOperation(target);
            (Controlled(innerOperation))(controlRegister, target);
            (Adjoint(outerOperation))(target);
        }
        controlled adjoint auto
    }

}
