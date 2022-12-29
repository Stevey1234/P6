#!/bin/bash

source_code=${1:-'/home/apoorv/p4rl_tarantula/RL_for_P4/P4/basic.p4'}
runtime_json=${2:-'/vagrant/runtime-configurations/basic.json'}

#Move to the correct directory
cd /home/apoorv/p4rl_tarantula/RL_for_P4_2/

for iterator in {0..9}
do
  for case_iterator in {1..9}
  do

    if [ $case_iterator -eq 1 ] && [ $iterator -eq 0 ]
    then
      #Run the tests with initialization
      ./run_files/run_tofino_with_initialization.sh $source_code $case_iterator 1 $runtime_json > "./logs/automated_logs/run_log_$iterator"_$case_iterator &
      #Wait so the test has time to finish
      wait
    else
      #Run the tests without initialization
      ./run_files/run_tofino_normal.sh $source_code $case_iterator 1 $runtime_json > "./logs/automated_logs/run_log_$iterator"_$case_iterator &
      #Wait so the test has time to finish
      wait
    fi

    #Move the collected data to a new location, so the next iteration won't delete it
    cp "./logs/patcher_execution_times.txt" "./results/automated_results/patcher_execution_time_"$case_iterator
    cp "./logs/localization-results.txt" "./results/automated_results/localization_result_"$case_iterator
    echo "Iteration $iterator"$case_iterator
  done
  #Collect the localization and detection times
  python ./run_files/format_results_to_csv.py
  cp ./results/detection_results.csv ./results/automated_results/detection_results_$iterator
  cp ./results/loc_results.csv ./results/automated_results/loc_results_$iterator
  cp ./results/patcher_results.csv ./results/automated_results/patcher_results_$iterator
  cp ./results/packets_generated.csv ./results/automated_results/packets_generated_$iterator
  cp ./results/susp-results.csv ./results/automated_results/susp-results_$iterator
done
#Collect the results from all the ten runs into a summarization file
python ./run_files/ordering.py

#After processing, delete the original log files
cd /home/apoorv/p4rl_tarantula/RL_for_P4_2/results/automated_results/
#rm *
cp ./* /home/apoorv/p4rl_tarantula/RL_for_P4_2/results/backup

echo "TEST FINISHED"

