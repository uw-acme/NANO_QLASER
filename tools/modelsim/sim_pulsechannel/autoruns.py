# Run the poly testbech for N numbers of times. Automated regeression testing.
import os
import sys
import time
import datetime
import random
import multiprocessing

from rich import print
# from analyze import main as analyze

SD_START = random.randint(0, 2**31 - 1)  # Start of the seed range
N = 1000  # Number of times to run the testbench

MAX_THREADS = int(os.cpu_count() / 2)  # Number of threads to run the testbench (half of the available threads)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        N = int(sys.argv[1])
        
    os.makedirs("results", exist_ok=True)

    os.system("rm -rf work")
    os.system("vlib work")
    os.system("vcom -f sim.f")

    current_datetime = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    
    results = f"results/polyruns-{current_datetime}.csv"
    # create the header in case simulator messed that up
    with open(results, "w") as f:
        f.write("Run#, Time (ns), Max Error, Delta, Error/Delta, Pulse Number, CNT-Time\n")
    
    start_time = time.time()

    print(f"Using {MAX_THREADS} CPUs")
    pool = multiprocessing.Pool(processes=MAX_THREADS)
    res = []

    for i in range(N):
        # seed = random.randint(0, 2**31 - 1)
        seed = SD_START + i
        cmd = f'vsim -c -do "vsim -voptargs="+acc" -lib work tb_pulse_channel_random_polynomials -g SEED={seed} -g RESULT_FILE={results}; run -all; quit -f" -l vsim.log | tee -a results/polyrun_regressions-{current_datetime}.log'
        res.append(pool.apply_async(os.system, (cmd,)))
    
    pool.close()
    pool.join()
    
    end_time = time.time()
    print(f"Total sim time: {end_time - start_time} seconds")
    
    # # Analyze the results
    # analyze(results, col=" Error/Delta", figname=f"results/polyruns-{current_datetime}.png", file=f"results/result-{current_datetime}.txt")
    