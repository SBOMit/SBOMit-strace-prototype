# SBOMit-strace-prototype
This tool generates in-toto attestations for projects, with current support for Golang.

## Steps:
1. Recursively collects all system calls made during the compilation of your project.
2. Parses the packages your project utilized during compilation.
3. Generates an in-toto attestation for your project, detailing the materials used and the output products.
```
./attest-gen.sh -i decouple-demo/decouple-pkg.txt -k sign-key.pem -d decouple-demo -p decouple
```
