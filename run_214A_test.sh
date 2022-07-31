#!/bin/bash

wavdir=$(pwd)/databases
################################################################################################################
######## EDIT HERE (CONTROL PARAMETERS) ########################################################################
################################################################################################################
noisy=$1        # 1 for noisy (5dB) data, 0 for clean data
stage=$2        # stage you want to start from
stop_stage=$3   # stage you want to stop at
training=$4     # 1 for training, 0 for not to train
################################################################################################################
# OPTIONAL: YOU CAN INCREASE THE NUMBER OF JOBS IF YOUR CPU HAS MORE THAN ONE PROCESSOR (FOR SAVING TIME) ######
################################################################################################################
feat_nj=4      # number of jobs for feature extraction
train_nj=4     # number of jobs for training
decode_nj=4    # number of jobs for decoding
################################################################################################################

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.
. ./path.sh
. parse_options.sh

# This is a shell script, but it's recommended that you run the commands one by
# one by copying and pasting into the shell.

if [ $noisy -eq 1 ]; then
   database=spc_5dB
else
   database=spc
fi
data=data
exp=exp

# Prepare Data
if [ $stage -le 0 ] && [ $stop_stage -ge 0 ]; then
   # The following command prepares the train,dev,test directories for both clean and 5dB data
   local/spc_data_prep_1.sh $wavdir/pink $data || exit 1;
   echo "Stage 0: Data Preparation Done."
fi

# Prepare Lang
if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
   local/spc_lang_prep.sh || exit 1;
   utils/validate_lang.pl $data/lang/ # Note; this actually does report errors,
      # and exits with status 1, but we've checked them and seen that they
      # don't matter (this setup doesn't have any disambiguation symbols,
      # and the script doesn't like that).
   echo "Stage 1: Lang Preparation Done."
fi

train_set=train_${database}
dev_set=dev_${database}
test_set=test_${database}
mfccdir=pink

# Extract Features
if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
   for x in ${train_set} ${dev_set} ${test_set}; do
      steps/make_mfcc2.sh --cmd "$train_cmd" --nj $feat_nj \
         $data/$x $exp/make_pink/$x ${mfccdir} || exit 1;
      steps/compute_cmvn_stats.sh $data/$x $exp/make_pink/$x ${mfccdir} || exit 1;
   done
   echo "Stage 2: Extracting Features Done."
fi

# Optional: Subset your training data for saving time
#if [ $stage -le 3 ] && [ $stop_stage -ge 3 ]; then
#   utils/subset_data_dir.sh $data/${train_set} 1000 $data/${train_set}_1k
#   train_set=$data/${train_set}_1k
#   echo "Stage 3: Subset the train set to $train_set"
#fi

# Start Training
if [ $stage -le 4 ] && [ $stop_stage -ge 4 ]; then
   # train a monophone system
   if [ $training -eq 1 ]; then
      steps/train_mono.sh --nj ${train_nj} --cmd "$train_cmd" \
         $data/${train_set} $data/lang $exp/mono_${database}
      utils/mkgraph.sh $data/lang $exp/mono_${database} $exp/mono_${database}/graph
   fi

   # decode using monophone model
   for testx in ${dev_set} ${test_set}; do
      trained_database=spc
      steps/decode.sh --nj ${decode_nj} --cmd "$decode_cmd" \
         $exp/mono_${trained_database}/graph $data/${testx} $exp/mono_${trained_database}/decode_${testx}
   done
   echo "Stage 4: Monophone Training and Decoding Done."
fi

# Check Results
if [ $stage -le 5 ] && [ $stop_stage -ge 5 ]; then
   bash RESULTS
fi