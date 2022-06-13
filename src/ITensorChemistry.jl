module ITensorChemistry

using Fermi
using ITensors
using Suppressor
using PythonCall

import Combinatorics: levicivita

import Base: *, length, getindex, setindex!, iterate, copy, push!, resize!

include("molecule.jl")
include("molecules.jl")
include("molecular_orbital_hamiltonian.jl")
include("pauli.jl")
include("qubitmaps.jl")

const pyscf = PythonCall.pynew() # Init to NULL
function __init__()
    PythonCall.pycopy!(pyscf, pyimport("pyscf"))
end

export Atom, Molecule, molecular_orbital_hamiltonian, jordanwigner
end
