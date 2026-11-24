(
s.reboot {
  s.options.numBuffers = 1024 * 256;
  s.options.memSize = 8192 * 32;
  s.options.numWireBufs = 2048;
  s.options.maxNodes = 1024 * 32;
  s.options.numOutputBusChannels = 2;
  s.options.numInputBusChannels = 2;
  s.options.ugenPluginsPath = "SC_UGEN_PATHS".getenv.split($:);
  s.waitForBoot {
    ~dirt.free;
    ~dirt = SuperDirt(2, s);
    ~dirt.loadSoundFiles("DIRT_SAMPLES".getenv +/+ "*");
    s.sync;
    ~dirt.start(57120, 0 ! 12);
  };
  s.latency = 0.3;
};
)
