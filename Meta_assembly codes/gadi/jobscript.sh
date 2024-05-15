#!/bin/bash
# properties = {properties}

source gadi/gadimod.sh

export TMPDIR=$PBS_JOBFS


set -ueo pipefail
{exec_job}
