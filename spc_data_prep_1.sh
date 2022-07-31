#!/bin/bash

. ./path.sh

wav_dir=$1
data=$2

tmpdir=./tmp
mkdir -p $tmpdir

# Data Preparation
# generate the required file in kaldi format
for part in spc spc_5dB; do
    find $wav_dir/$part -iname "*.txt" > $tmpdir/${part}all.flist

    [ ! -d $data/local/data/$part ] & mkdir -p $data/local/data/$part
    newdata=$data/local/data/$part

    sed -e "s:.*/\(.*\)/\(.*\)_\(nohash_.*\).txt$:\2_\3-\1 \2:" $tmpdir/${part}all.flist | sort -k1,1 > $newdata/utt2spk
    sed -e "s:.*/\(.*\)/\(.*\)_\(nohash_.*\).txt:\2_\3-\1 \1:" $tmpdir/${part}all.flist | sort -k1,1 > $newdata/text
    sed -e "s:.*/\(.*\)/\(.*\).txt$:\2-\1:" $tmpdir/${part}all.flist > $newdata/all.uttids
    paste -d' ' $newdata/all.uttids $tmpdir/${part}all.flist | sort -k1,1 > $newdata/wav.scp

    spk2utt=$newdata/spk2utt
    utils/utt2spk_to_spk2utt.pl < $newdata/utt2spk > $spk2utt || exit 1

    utils/validate_data_dir.sh --no-feats $newdata || exit 1;

    # subset the data into train-val-test with chosen $dev_ratio and $test_ratio
    utils/subset_data_dir_tr_cv.sh --cv-spk-percent 30 $newdata \
        $data/train_${part} $data/test_dev_${part}
    utils/subset_data_dir_tr_cv.sh --cv-spk-percent 25 $data/test_dev_${part} \
        $data/test_${part} $data/dev_${part}

    echo "$0: ${part} data is successfully prepared"
done
rm -r $tmpdir

echo "$0: All data are successfully prepared"
exit 0
