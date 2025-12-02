from artiq.experiment import *
from artiq.language.core import delay, parallel, sequential
from artiq.language.units import us, ms

@kernel
def run(self):
    self.core.reset()

    # Gate the counter for a short time
    self.ttl0_counter.gate_rising(10*ms)

    # Generate one pulse
    self.ttl4.pulse(1*us)
    delay(2*ms)

    # Read count
    count = self.ttl0_counter.fetch_count()
    print("TTL0 saw pulses:", count)
