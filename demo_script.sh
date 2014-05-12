#!/bin/bash

echo "Prepare Data"
rm -rf /tmp/dataset/data_all
mkdir /tmp/dataset/data_all
cp -rf /tmp/dataset/data/* /tmp/dataset/data_all
chmod a+rw -R /tmp/dataset/data_all

echo "Copy data to HDFS"
hadoop dfs -rmr data
hadoop dfs -put /tmp/dataset/data_all data/data_all

echo "Creating sequence files from data"
mahout seqdirectory -i data/data_all -o data/data_seq -ow

echo "Converting sequence files to vectors"
mahout seq2sparse -i data/data_seq -o data/data_vectors  -lnorm -nv  -wt tfidf

echo "Creating training and holdout set with a random 80-20 split of the generated vector dataset"
mahout split \
-i data/data_vectors/tfidf-vectors \
--trainingOutput data/data_train_vectors \
--testOutput data/data_test_vectors  \
--randomSelectionPct 40 --overwrite --sequenceFiles -xm sequential

                echo "Training Naive Bayes model"
                mahout trainnb \
                    -i data/data_train_vectors -el \
                        -o data/model \
                            -li data/labelindex \
                                -ow ""

                                 echo "Self testing on training set"
                                 mahout testnb \
                                     -i data/data_train_vectors\
                                         -m data/model \
                                             -l data/labelindex \
                                                 -ow -o data/data_testing ""

                                                 echo "Self testing on training set"
                                                 mahout testnb \
                                                     -i data/data_test_vectors\
                                                         -m data/model \
                                                             -l data/labelindex \
                                                                 -ow -o data/data_testing ""
