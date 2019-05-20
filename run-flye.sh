for spp in  a.acuminata  e.albens  e.globulus  e.marginata  e.sideroxylon  e.viminalis
do
	qsub -v SPECIES=$spp -N FLYE_$spp scripts/1_flye.sh
	#qsub -v SPECIES=$spp -N RA_$spp scripts/1_ra.sh
done

