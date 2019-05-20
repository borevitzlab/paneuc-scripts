#!/bin/bash

for spp in a.acuminata  e.albens  e.globulus  e.marginata  e.sideroxylon  e.viminalis
do
    qsub -v SPECIES=$spp scripts/canu-hugemem.pbs -N CANU_$spp
done
