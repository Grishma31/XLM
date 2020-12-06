./get-data-para.sh en-hi &

OUTPATH=data/processed/XLM_en_hi/50k  # path where processed files will be stored
mkdir -p $OUTPATH

shuf -r -n 30000 data/para/parallel/IITB.en-hi.en >> $OUTPATH/bpe.train
shuf -r -n 30000 data/para/parallel/IITB.en-hi.hi >> $OUTPATH/bpe.train

FASTBPE=tools/fastBPE/fast
pair=en-hi
$FASTBPE learnbpe 3000 $OUTPATH/bpe.train > $OUTPATH/codes

pair=en-hi
for lg in $(echo $pair | sed -e 's/\-/ /g'); do
  for split in train valid test; do
    $FASTBPE applybpe $OUTPATH/$pair.$lg.$split data/para/$pair.$lg.$split $OUTPATH/codes
    cat $OUTPATH/$pair.$lg.$split | $FASTBPE getvocab - > $OUTPATH/vocab.pair.$lg.$split &
    python preprocess.py $OUTPATH/vocab.pair.$lg.$split $OUTPATH/$pair.$lg.$split &
  done
done


