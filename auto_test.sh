
cd databases/my_features;

rm features.txt

find spc -name "*.txt" >features.txt;
echo "Clean Features.txt Done"

while read d;do 
    mkdir -p /Users/balaji1312/kaldi/egs/spc/s5/databases/pink/$(dirname "$d"); 
    done < /Users/balaji1312/kaldi/egs/spc/s5/databases/my_features/features.txt
echo "Clean Features Directories Done"

while read d;do 
    cat $d | sed -e '1 s/^/[\t/' -e '$ s/$/\t]/' | tr ',' '\t' > /Users/balaji1312/kaldi/egs/spc/s5/databases/pink/"$d"; 
    done < /Users/balaji1312/kaldi/egs/spc/s5/databases/my_features/features.txt
echo "Clean Features Files Done"

rm features.txt

find spc_5dB -name "*.txt" >features.txt;
echo "Noisy Features.txt Done"

while read d;do 
    mkdir -p /Users/balaji1312/kaldi/egs/spc/s5/databases/pink/$(dirname "$d"); 
    done < /Users/balaji1312/kaldi/egs/spc/s5/databases/my_features/features.txt
echo "Noisy Features Directories Done"

while read d;do 
    cat $d | sed -e '1 s/^/[\t/' -e '$ s/$/\t]/' | tr ',' '\t' > /Users/balaji1312/kaldi/egs/spc/s5/databases/pink/"$d"; 
    done < /Users/balaji1312/kaldi/egs/spc/s5/databases/my_features/features.txt
echo "Noisy Features Files Done"

cd ../..

rm -r data

echo "Removing Files Done"

cp -r data_ref data

zsh run_214A_test.sh 0 1 1 1

cd data

ex train_spc/wav.scp <<EOEX
  :%s#databases/spc#databases/pink/spc#
  :%s#.wav#.txt#
  :wq
EOEX

ex test_spc/wav.scp <<EOEX
  :%s#databases/spc#databases/pink/spc#
  :%s#.wav#.txt#
  :wq
EOEX

ex dev_spc/wav.scp <<EOEX
  :%s#databases/spc#databases/pink/spc#
  :%s#.wav#.txt#
  :wq
EOEX

ex dev_spc_5dB/wav.scp <<EOEX
  :%s#databases/spc_5dB#databases/pink/spc_5dB#
  :%s#.wav#.txt#
  :wq
EOEX

ex test_spc_5dB/wav.scp <<EOEX
  :%s#databases/spc_5dB#databases/pink/spc_5dB#
  :%s#.wav#.txt#
  :wq
EOEX

ex train_spc_5dB/wav.scp <<EOEX
  :%s#databases/spc_5dB#databases/pink/spc_5dB#
  :%s#.wav#.txt#
  :wq
EOEX

echo "Editing Files Done"

cd ..

for part in test_spc test_spc_5dB dev_spc dev_spc_5dB train_spc test_spc; do


    rm data/$part/spk2utt
    rm data/$part/utt2spk
    rm data/$part/text

    sed -e "s:.*/\(.*\)/\(.*\)_\(nohash_.*\).txt$:\2_\3-\1 \2:" data/$part/wav.scp | sort -k1,1 > data/$part/utt2spk
    sed -e "s:.*/\(.*\)/\(.*\)_\(nohash_.*\).txt:\2_\3-\1 \1:" data/$part/wav.scp | sort -k1,1 > data/$part/text

    sort -o data/$part/wav.scp data/$part/wav.scp

    spk2utt=$part/spk2utt
    utils/utt2spk_to_spk2utt.pl < data/$part/utt2spk > data/$spk2utt || exit 1

    utils/validate_data_dir.sh --no-feats data/$part || exit 1;

done

echo "Data Prep Done"



zsh run_214A_test.sh 0 2 3 1

zsh run_214A_test.sh 1 2 3 0

zsh run_214A_test.sh 0 4 5 0

zsh run_214A_test.sh 1 4 5 0