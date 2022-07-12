# Lib_myViterbi
viterbi coder/decoder for cpp and verolog

### cpp
There is example for qt coder decoder vitervi with polinom g0=3'b111, g0=3'b101 in folder cpp

### verilog
viterbi_enc -> encoder viterbi with configurable polinom
viterbi_dec -> decoder viterbi with configurable polinom and support decoding with different speed
viterbi_speed_map -> module for chnge speed encoder from 1/2 to 1/2, 2/3, 3/4 ...

tb_viterbi_enc.v -> examplse use viterbi modules
#### Note
Now decoder viterbi support fix error only with speed 1/2
