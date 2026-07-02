# EGAPx input files

This folder contains small EGAPx input/provenance files for the *Staurois parvus* genome annotation runs.

## Files

- `sparvus_original_24rnaseq.yaml`  
  EGAPx YAML for the original annotation using 24 paired tadpole/flutamide RNA-seq libraries.

- `sparvus_tadpole_plus_adult.yaml`  
  EGAPx YAML for the rerun using the original 24 paired tadpole/flutamide libraries plus 11 adult male tissue RNA-seq libraries from GSE232203.

- `short_reads_original_24rnaseq.txt`  
  EGAPx short-read manifest for the original 24 paired RNA-seq libraries.

- `adult_short_reads_GSE232203.txt`  
  EGAPx short-read manifest for adult male *S. parvus* brain, spinal cord, and leg muscle RNA-seq from GEO accession GSE232203.

- `short_reads_tadpole_plus_adult_GSE232203.txt`  
  Combined EGAPx short-read manifest for all 35 paired RNA-seq libraries.

## Notes

The manifests contain absolute Unity filesystem paths and are intended for provenance/reproducibility on Unity. They may need editing before use on another HPC.
