# Golang Project Demonstration Guide

This guide walks you through the demonstration steps for generating and managing Software Bill of Materials (SBOMs), package and binary analysis, and attestation generation for a Golang project. Follow the steps below to understand how to apply these practices to your Golang projects efficiently.

## Prerequisites

Before starting this demo, ensure you have the following installed and set up:

- Golang environment
- Access to the terminal or command line interface
- Necessary permissions to execute shell scripts in your environment

Make sure all scripts mentioned are executable. You can make a script executable by running `chmod +x script_name.sh`.

## Demo Steps

### 1. SBOM Generation

Generate Software Bill of Materials (SBOM) for projects located in `demo/projects` and output the SBOM files to `demo/sboms`:

```bash
./sbom_generation.sh -p demo/projects -o demo/sboms
```

### 2. Run All Scripts

Execute all necessary scripts for processing projects in `demo/projects`, outputting package information to `demo/pkgs`, and binaries to `demo/bins`:

```bash
./run_all.sh -p demo/projects -o demo/pkgs -b demo/bins
```

### 3. Run Binary Packages Script

Process binary packages located in `demo/bin-pkgs` and utilize binaries from `demo/bins`:

```bash
./run_bin_pkgs.sh -p demo/bin-pkgs -b demo/bins
```

### 4. Combine Packages

Combine SBOMs from `demo/sboms`, binary packages from `demo/bin-pkgs`, package information from `demo/pkgs`, and output the combined package information to `demo/combine-pkgs`:

```bash
./run_combine_pkgs.sh -s demo/sboms -b demo/bin-pkgs -p demo/pkgs -o demo/combine-pkgs
```

### 5. Attestation Generation

Generate attestations for the combined package located at `demo/combine-pkgs/go-cache/go-cache-combine-pkgs.txt` using the key `demo/sign-key.pem`, outputting the attestation to `demo/in-toto-attestation/go-cache`, and specifying the binary path `demo/bins/go-cache`:

```bash
./attest-gen.sh -i demo/combine-pkgs/go-cache/go-cache-combine-pkgs.txt -k demo/sign-key.pem -d demo/in-toto-attestation/go-cache -p demo/bins/go-cache
```

### 6. Golang IR SBOM Generation

Generate a new SBOM for the Go project located at `demo/combine-pkgs/go-cache/go-cache-combine-pkgs.txt` with the module information from `demo/projects/go-cache/go.mod`, and output the SBOM to `demo/new-sboms/go-cache`:

```bash
./golang-ir-sbom-gen.sh -d demo/combine-pkgs/go-cache/go-cache-combine-pkgs.txt -m demo/projects/go-cache/go.mod -o demo/new-sboms/go-cache
```
