#!/usr/bin/env bash

cd ..
3dcalc -a mni_icbm152_t1_tal_nlin_asym_09c_brain.nii -expr 'ispositive(a)' -prefix 'brain_mask.nii.gz'

