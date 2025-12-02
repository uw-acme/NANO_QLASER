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

    # Start counter
        self.ttl0_counter.gate_rising(10*s)

    # Blink TTL4 visibly
        for _ in range(10):
            self.ttl4.pulse(100*ms)  # shorter pulse → LED visible
            delay(200*ms)

    # Fetch count after blinking
        return self.ttl0_counter.fetch_count()