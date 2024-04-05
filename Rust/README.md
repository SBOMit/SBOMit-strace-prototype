# Rust Project Demonstration Guide

This guide details the steps for generating and managing Software Bill of Materials (SBOMs), analyzing packages and binaries, and generating attestations for a Rust project. Follow these steps to apply these practices to your Rust projects efficiently.

## Prerequisites

Before you begin this demonstration, ensure you have the following installed and configured:

- Rust environment (including Cargo)
- Access to a terminal or command-line interface
- Appropriate permissions to execute shell scripts in your environment

To make a script executable, use `chmod +x script_name.sh`.

## Demo Steps

### 1. SBOM Generation

Generate Software Bill of Materials (SBOM) for projects in `demo/projects`. Output the SBOM files to `/demo/sboms`:

```bash
./sbom_generation.sh -p demo/projects -o /demo/sboms
```

### 2. Execute All Scripts

Run all necessary scripts to process projects in `demo/projects`, output package information to `demo/pkgs`, and binaries to `demo/bins`:

```bash
./run_all.sh -p demo/projects -o demo/pkgs -b demo/bins
```

### 3. Process Binary Packages

Handle binary packages located in `demo/bin-pkgs` and utilize binaries from `demo/bins`:

```bash
./run_bin_pkgs.sh -p demo/bin-pkgs -b demo/bins
```

### 4. Combine Package Information

Merge SBOMs from `demo/sboms`, binary packages from `demo/bin-pkgs`, and package information from `demo/pkgs`. Output the combined package information to `demo/combine-pkgs`:

```bash
./run_combine_pkgs.sh -s demo/sboms -b demo/bin-pkgs -p demo/pkgs -o demo/combine-pkgs
```

### 5. Generate Attestations

Create attestations for the combined package at `demo/combine-pkgs/rsedis/rsedis-combine-pkgs.txt` using the key `demo/sign-key.pem`, outputting the attestation to `demo/in-toto-attestation/rsedis`, and specifying the binary path `demo/bins/rsedis`:

```bash
./attest-gen.sh -i demo/combine-pkgs/rsedis/rsedis-combine-pkgs.txt -k demo/sign-key.pem -d demo/in-toto-attestation/rsedis -p demo/bins/rsedis
```

### 6. Rust IR SBOM Generation

Generate a new SBOM for the Rust project located at `demo/combine-pkgs/rsedis/rsedis-combine-pkgs.txt` using the module information from `demo/projects/rsedis/Cargo.toml`, and output the SBOM to `demo/new-sboms/rsedis`:

```bash
./rust-ir-sbom-gen.sh -d demo/combine-pkgs/rsedis/rsedis-combine-pkgs.txt -m demo/projects/rsedis/Cargo.toml -o demo/new-sboms/rsedis
```
