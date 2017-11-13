---
title: "Q♭ Libraries Style Guide"
---

## General Conventions ##

- The conventions listed here are suggestions only, and should likely be disregarded when they would result in less readable of useful code.
  Put differently, disregarding conventions should always be an intentional decision to produce more useful code, and not an accident.

## Naming Conventions ##

- Avoid using people's names in operation and function names where reasonable.
  Consider using names that describe the implemented functionality; e.g. `CCNOT` versus `Toffoli` or `CSWAP` versus `Fredikin `.
  In sample code, consider using names that are familiar to the community reading each particular example, even if that would otherwise run counter to these suggestions.
  **NB:** names should still appear in documentation comments.
- If an operation or function is not intended for direct use, but rather should be used by a matching callable which acts by partial application, consider using a name ending with `Impl` for the callable that is partially applied.
  By contrast, if an operation or function should never be directly called by a user, consider indicating this with a leading `_`.
- Value argument names should be descriptive; avoid one or two letter names where possible.
- Generic argument names should be single capital letters where the role of a type is obvious.
  Otherwise, consider using a short capitalized word prefaced by `T` (e.g.: `TOutput`).
- Denote types in argument and variable names where it is ambiguous, but omit where it is clear from context.
  Type names should be suffixes (`targetQubit`) where reasonable.
- Denote scalar types by their literal names (`flagQubit`), and array types by a plural (`measResults`).
  For arrays of qubits in particular, consider denoting such types by `Register` where the name refers to a sequence of qubits that are closely related in some way.
- If several operations or functions are related by the functor variants supported by their arguments, denote this by suffixes `A`, `C` or `CA` to their names.
- Where reasonable, arrays should have names that are pluralized (e.g.: `things`).
- Variables used as indices into arrays should begin with `idx` and should be singular (e.g.: `things[idxThing]`).
  In particular, strongly avoid using single-letter variable names as indices; consider using `idx` at a minimum.
- Variables used to hold lengths of arrays should begin with `n` and should be pluralized (e.g.: `nThings`).

## Argument Conventions ##

The argument ordering conventions here largely derive from thinking of partial application as a generalization of currying ($f(x, y) \equiv f(x)(y)$).
Thus, partially applying the first arguments should result in a callable that is useful in its own right whenever that is reasonable.
Following this principle, consider using the following order of arguments:

- Classical non-callable arguments such as angles, vectors of powers, etc.
- Callable arguments (functions and arguments).
  If both functions and operations are taken as arugments, consider placing operations after functions.
- Collections acted upon by callable arguments in a similar way to `Map`, `Iter`, `Enumerate`, and `Fold`.
- Qubit arguments used as controls.
- Qubit arguments used as targets.

Thus, an operation `Op` which takes an angle, passes it to `Rz` modified by an array of different scaling factors, and then controls the resulting operation would be called in the following fashion:

```qflat
operation Op(angle : Double, callable : (Qubit => () : Controlled), scaleFactors : Double[], controlQubit : Qubit, targetQubits : Qubit[]) : ()
```

If an operation or function acts similarly to a keyword functor or a prelude callable, strongly consider following the convention set by the prelude, even if it would otherwise contravene a rule here.
For instance, a function which applies the `Controlled` functor should take an operation and return an operation that has an array of control qubits as its first argument and all remaining arguments as a tuple:

```qflat
operation ControlledLike<'T>(op : ('T => () : Controlled)) : ((Qubit[], ('T)) => () : Controlled)
```

## Whitespace and Delimiter Conventions ##

- **TODO:** which line should braces be on?
- Use four spaces instead of tabs for portability.
  For instance, in VS Code:
  ```json
    "editor.insertSpaces": true,
    "editor.tabSize": 4
  ```

## Documentation Conventions ##

**TODO:** parts of this section may still change going forward!

- Each function, operation, and user-defined type should be immediately preceeded by a documentation comment containing a summary, remarks, links to papers and external documentation, descriptions of parameters and return types as appropriate.
  Documentation comments are denoted by lines starting with `///`, and are formatted as YAML documents, with string values being formatted as GitHub-Flavored Markdown (GFM).
- Indentation is significant within both YAML and GFM, so please ensure that all indentation follows the suggestions above.

Example:
```csharp
/// summary:
///     This block should contain a user-readable description of the
///     symbol being defined.
/// params:
///     first: Short description of the parameter named `first`.
...
```

- When documenting a pair of callables including an `Impl` or a private method, document the public-facing callable more completely, and use a `seealso` tag from the private-facing callable.

## Other Conventions ##

- Line wrap at 79 characters where reasonable.
  **NB:** for files such as Markdown-formatted prose that can safely wrap, consider using the one line per sentence rule instead, as this can help reduce insiginificant changes during diffing.
  **TODO:** this depends on more stable parser support for multi-line statements, and thus should not yet be implemented.
