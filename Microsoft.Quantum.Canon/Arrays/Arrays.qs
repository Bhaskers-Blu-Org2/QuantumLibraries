// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {

    function Reverse<'T>(array : 'T[]) : 'T[] {
        let nElements = Length(array)
        mutable newArray = new 'T[nElements]

        for (idxElement in 0..nElements - 1) {
            set newArray[nElements - idxElement - 1] = array[idxElement]
        }

        return newArray
    }

    // FIXME: this name is ambiguous.
    function Slice<'T>(indices : Int[], array : 'T[]) : 'T[] {
        let nElements = Length(indices)
        mutable newArray = new 'T[nElements]

        for (idxElement in 0..nElements - 1) {
            set newArray[idxElement] = array[indices[idxElement]]
        }

        return newArray
    }


    function LookupImpl<'T>(array : 'T[], index : Int) : 'T {
        return array[index]
    }

    function LookupFunction<'T>(array : 'T[]) : (Int -> 'T) {
        return LookupImpl(array, _)
    }

}
