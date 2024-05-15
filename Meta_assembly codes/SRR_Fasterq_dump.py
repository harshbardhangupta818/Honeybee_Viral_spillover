#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 14 16:16:13 2023

@author: u1143128
"""
import subprocess
import time
import sys
sra_id = sys.argv[1]

start_time = time.time()

print ("Currently downloading: " + sra_id)
prefetch = "prefetch " + sra_id + " --max-size 10t"
print ("The command used was: " + prefetch)
subprocess.call(prefetch, shell=True)
    
print ("Generating fastq for: " + sra_id)
fasterq_dump = "parallel-fastq-dump --threads 1 --outdir data --split-files --gzip --sra-id " + sra_id
print ("The command used was: " + fasterq_dump)
subprocess.call(fasterq_dump, shell=True)

    
print("--- %s minutes ---" % ((time.time() - start_time)/60))
