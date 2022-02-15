using ITensors
using ITensorChemistry
using Test

@testset "electron hamiltonian" begin
  molecule = Molecule("H₂")
  basis = "sto-3g"
  
  (; hamiltonian, hartree_fock_state, hartree_fock_energy) = 
    molecular_orbital_hamiltonian(; molecule, basis, diis = false, oda = false)

  s = siteinds("Electron", length(hartree_fock_state); conserve_qns=true)
  H = MPO(hamiltonian, s)
  ψhf = MPS(s, hartree_fock_state)

  @test inner(ψhf, H, ψhf) ≈ hartree_fock_energy
  sweeps = Sweeps(10)
  setmaxdim!(sweeps, 100, 200)
  setcutoff!(sweeps, 1e-6)
  setnoise!(sweeps, 1e-6, 1e-7, 1e-8, 0.0)
  dmrg_energy, ψ = dmrg(H, ψhf, sweeps; outputlevel=0)
  @test dmrg_energy < hartree_fock_energy
end

@testset "fermion hamiltonian" begin
  molecule = Molecule("H₂")
  basis = "sto-3g"
  (; hamiltonian, hartree_fock_state, hartree_fock_energy) = 
    molecular_orbital_hamiltonian(; molecule, basis, diis = false, oda = false)
  
  se = siteinds("Electron", length(hartree_fock_state); conserve_qns=false)
  He = MPO(hamiltonian, se)
  ψe = MPS(se, hartree_fock_state)

  @test inner(ψe, He, ψe) ≈ hartree_fock_energy

  (; hamiltonian, hartree_fock_state, hartree_fock_energy) = 
    molecular_orbital_hamiltonian(; molecule,
                                    basis, 
                                    diis = false, 
                                    oda = false, 
                                    sitetype = "Fermion")

  sf = siteinds("Fermion", length(hartree_fock_state); conserve_qns=false)
  Hf = MPO(hamiltonian, sf)
  ψf = MPS(sf, hartree_fock_state)
  
  @test inner(ψf, Hf, ψf) ≈ hartree_fock_energy
  sweeps = Sweeps(10)
  setmaxdim!(sweeps, 100, 200)
  setcutoff!(sweeps, 1e-10)
  setnoise!(sweeps, 1e-6, 1e-7, 1e-8, 0.0)
  Ee, ψe = dmrg(He, randomMPS(se), sweeps; outputlevel=0)
  
  sweeps = Sweeps(10)
  setmaxdim!(sweeps, 100, 200)
  setcutoff!(sweeps, 1e-10)
  setnoise!(sweeps, 1e-6, 1e-7, 1e-8, 0.0)
  Ef, ψf = dmrg(Hf, ψf, sweeps; outputlevel=0)
  @test Ee ≈ Ef
end

