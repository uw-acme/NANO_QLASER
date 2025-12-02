from artiq.experiment import *
from artiq.language.core import delay, parallel, sequential
from artiq.language.units import us, ms, s

class PulseCount(EnvExperiment):
    def build(self):
        self.setattr_device("core")
        self.setattr_device("ttl4")
        self.setattr_device("ttl0_counter")

    @kernel
    def run(self):
        self.core.reset()

        # Counter gate; reset happens automatically at start
        with parallel:
            self.ttl0_counter.gate_rising(100*s)
            for _ in range(100):
                self.ttl4.pulse(1*s)
                delay(1*s)

        # Fetch count inside kernel
        return self.ttl0_counter.fetch_count()
    



    def analyze(self):
        # Use rpc to call the kernel and get the result
        count = self.run()
        print("Rising edge count =", count)
