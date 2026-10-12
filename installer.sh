#!/usr/bin/env bash

if [ "$1" != "" ]; then
    echo "Environment name will be $1"
    env=$1
else
    echo "Positional parameter 1 is empty"
    env="piret_env"
fi


set -e # Exit as soon as any line in the bash script fails

ROOTDIR=$( cd $(dirname $0) ; pwd -P ) # path to main PiReT directory


echo
exec &> >(tee -a  install.log)
exec 2>&1 # copies stderr onto stdout

mamba create -n $env python=3.6.6 numpy=1.14 --yes
mamba install -c conda-forge r-tidyverse r-reshape2 r-optparse r-pheatmap r-stringi r-plotly icu time -n $env --yes
mamba install -c bioconda bioconductor-deseq2 bioconductor-edger bioconductor-gage bioconductor-ballgown -n $env --yes
mamba install -c bioconda perl-lwp-protocol-https -n $env --yes
mamba install -c bioconda perl-json -n $env --yes
mamba install -c bioconda samtools bamtools bedtools subread stringtie star hisat2 faqcs -n $env --yes

envPath=$(mamba info --base)/envs/$env

cd $envPath/bin
wget http://github.com/bbuchfink/diamond/releases/download/v0.9.26/diamond-linux64.tar.gz 
tar xvzf diamond-linux64.tar.gz 
chmod 775 diamond

cd $ROOTDIR
export PATH=/opt/conda/envs/piret_env/bin:$PATH
mamba activate $env
rm -rf thirdparty/eggnog-mapper
git clone https://github.com/mshakya/eggnog-mapper.git thirdparty/eggnog-mapper
# R packages
echo "if('BiocManager' %in% rownames(installed.packages()) == FALSE) {install.packages('BiocManager', repos='https://cran.r-project.org')}" | Rscript -
#echo "if('optparse' %in% rownames(installed.packages()) == TRUE) {packageVersion('optparse')}"  | Rscript -
#echo "if('optparse' %in% rownames(installed.packages()) == FALSE) {install.packages('optparse',repos='https://cran.r-project.org')}"  | Rscript -
# install tidyverse
#echo "if('tidyverse' %in% rownames(installed.packages()) == TRUE){packageVersion('tidyverse')}"  | Rscript -
#echo "if('tidyverse' %in% rownames(installed.packages()) == FALSE){install.packages('tidyverse',repos='https://cran.r-project.org')}"  | Rscript -
# install R reshape2 packages
# echo "if('reshape2' %in% rownames(installed.packages()) == TRUE){packageVersion('reshape2')}"  | Rscript -
# echo "if('reshape2' %in% rownames(installed.packages()) == FALSE){install.packages('reshape2',repos='https://cran.r-project.org')}"  | Rscript -
# install R pheatmap packages
#echo "if('pheatmap' %in% rownames(installed.packages()) == TRUE){packageVersion('pheatmap')}"  | Rscript -
#echo "if('pheatmap' %in% rownames(installed.packages()) == FALSE){install.packages('pheatmap',repos='https://cran.r-project.org')}"  | Rscript -
# install R edgeR packages
#echo "if('edgeR' %in% rownames(installed.packages()) == TRUE){packageVersion('edgeR')}"  | Rscript -
#echo "if('edgeR' %in% rownames(installed.packages()) == FALSE){BiocManager::install('edgeR')}"  | Rscript -
# install R deseq2 packages
#echo "if('DESeq2' %in% rownames(installed.packages()) == TRUE){packageVersion('DESeq2')}"  | Rscript -
#echo "if('DESeq2' %in% rownames(installed.packages()) == FALSE){BiocManager::install('DESeq2')}"  | Rscript -
# install R gage package
#echo "if('gage' %in% rownames(installed.packages()) == TRUE){packageVersion('gage')}"  | Rscript -
#echo "if('gage' %in% rownames(installed.packages()) == FALSE){BiocManager::install('gage')}"  | Rscript -
# install R ballgown package
#echo "if('ballgown' %in% rownames(installed.packages()) == TRUE){packageVersion('ballgown')}"  | Rscript -
#echo "if('ballgown' %in% rownames(installed.packages()) == FALSE){BiocManager::install('ballgown')}"  | Rscript -
python setup.py install
pytest --cov=piret tests/



echo "
All done!
Run
source activate $env
piret -h
for usage.
Read the README for more information!
	"
