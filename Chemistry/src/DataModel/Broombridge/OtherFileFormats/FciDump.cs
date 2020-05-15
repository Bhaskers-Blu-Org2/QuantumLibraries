// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

using System.Text.RegularExpressions;
using System.Linq;
using System.Collections.Generic;
using System.IO;

using Microsoft.Quantum.Chemistry.OrbitalIntegrals;
using System;

namespace Microsoft.Quantum.Chemistry
{
    /// <summary>
    ///      Serialization and deserialization support for FCIDUMP
    ///      formatted problem descriptions.
    /// </summary>
    public static class FciDump
    {

        /// <summary>
        ///     Deserializes an FCIDUMP-formatted problem description.
        /// </summary>
        /// <param name="reader">A stream for reading FCIDUMP data.</param>
        /// <returns>
        ///      An electronic structure problem deserialized from the file.
        /// </returns>
        public static MinimalProblemDescription Deserialize(TextReader reader)
        {
            // FCIDUMP files begin with a FORTRAN-formatted namelist, delimited
            // by &FCI and &END. We start by extracting that namelist.
            var allText = reader.ReadToEnd();
            var lines = Regex.Split(allText, "\r\n|\r|\n");
            var header = System.String.Join("\n", lines.TakeWhile(line => line.Trim() != "&END")).Trim();
            var body = lines.SkipWhile(line => line.Trim() != "&END").Skip(1).ToList();
            
            // Make sure that the header starts with &FCI, as expected.
            if (!header.StartsWith("&FCI"))
            {
                throw new IOException("FCIDUMP file did not start with \"&FCI\" as expected.");
            }
            
            // Split out the &FCI and &END lines, turn the rest into a dictionary of namelist items.
            var namelist = Regex.Matches(
                header
                .Replace("&FCI", "")
                .Replace("&END", ""),
                pattern: "\\s*(?<identifier>\\w+)\\s*=\\s*(?<value>[^=]+),\\s*"
            )
            .ToDictionary(
                match => match.Groups["identifier"].Value,
                match => match.Groups["value"].Value
            );

            var hamiltonian = new OrbitalIntegralHamiltonian();

            foreach (var line in body.Select(line => line.Trim()).Where(line => line.Length > 0))
            {
                // Separate into columns, delimited by spaces.
                var columns = line.Split(" ", StringSplitOptions.RemoveEmptyEntries);
                var value = Double.Parse(columns[0]);
                var indices = columns[1..].Select(idx => Int32.Parse(idx));
                if (indices.All(index => index == 0))
                { 
                    hamiltonian.Add(TermType.OrbitalIntegral.Identity, new OrbitalIntegral(), value);
                }
                else if (indices.Skip(2).All(index => index == 0))
                {
                    hamiltonian.Add(new OrbitalIntegral(indices.Take(2), value).ToCanonicalForm());
                }
                else
                {
                    hamiltonian.Add(new OrbitalIntegral(indices, value).ToCanonicalForm());
                }
            }
            
            
            return new MinimalProblemDescription
            {
                CoulombRepulsion = 0.0,
                MiscellaneousInformation = "Imported from FCIDUMP",
                NElectrons = Int32.Parse(namelist["NELEC"]),
                NOrbitals = Int32.Parse(namelist["NORB"]),
                OrbitalIntegralHamiltonian = hamiltonian
            };
        }

        /// <summary>
        ///     Deserializes an FCIDUMP-formatted problem description.
        /// </summary>
        /// <param name="filename">The name of the file to be loaded.</param>
        /// <returns>
        ///      An electronic structure problem deserialized from the file.
        /// </returns>
        /// <returns>
        ///      List of electronic structure problem deserialized from the file.
        /// </returns>
        public static MinimalProblemDescription Deserialize(string filename)
        {
            using var reader = File.OpenText(filename);
            return Deserialize(reader);
        }

        public static void Serialize(MinimalProblemDescription problem, TextWriter writer)
        {
            // Start by writing the header.
            writer.WriteLine($"&FCI NORB={problem.NOrbitals},NELEC={problem.NElectrons},");
            // Assume global phase symmetry for now.
            writer.WriteLine($" ORBSYM={String.Join("", Enumerable.Range(0, problem.NOrbitals).Select(idx => "1,"))}");
            writer.WriteLine($" ISYM=1,");
            writer.WriteLine("&END");

            // Next write out all two-body terms.
            foreach (var term in problem.OrbitalIntegralHamiltonian.Terms[TermType.OrbitalIntegral.TwoBody])
            {
                writer.WriteLine($"{term.Value.Value} {String.Join(" ", term.Key.OrbitalIndices.Select(i => i.ToString()))}");
            }
            // Next write out all one-body terms, using trailing zeros to indicate one-body.
            foreach (var term in problem.OrbitalIntegralHamiltonian.Terms[TermType.OrbitalIntegral.OneBody])
            {
                writer.WriteLine($"{term.Value.Value} {String.Join(" ", term.Key.OrbitalIndices.Select(i => i.ToString()))} 0 0");
            }
            // Finish by writing out the identity term.
            var identityTerm = problem.OrbitalIntegralHamiltonian.Terms[TermType.OrbitalIntegral.Identity].Single();
            writer.WriteLine($"{identityTerm.Value.Value} 0 0 0 0");
        }
    }
}
