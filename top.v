`define PAR_CLOCK 50000000

// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU  // USB pull-up resistor
);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // TD4
    ////////

    //=======================================================
    //  REG/WIRE declarations
    //=======================================================

    wire n_reset;
    wire [3:0] address;
    wire [7:0] instr;
    wire [3:0] port_in;
    wire [3:0] port_out;

    // clock
    reg [26:0] counter;
    wire td4_CLOCK;
    assign td4_CLOCK = counter < `PAR_CLOCK / 2;


    //=======================================================
    //  Structural coding
    //=======================================================

    cpu cpu(td4_CLOCK, n_reset, address, instr, port_in, port_out);
    test_rom rom(address, instr);

    assign port_in = { 4'b0000 }; // 入力ポートも無し
    assign n_reset = 1'b1; // リセットは無しで
    assign LED = port_out[3]; // OUTの最上位ビットをLEDに表示

    always @(posedge CLK or negedge n_reset) begin
      if (!n_reset) counter <= 0;
      else counter <= counter < `PAR_CLOCK ? counter + 1 : 0;
    end

    ////////
    // make a simple blink circuit
    ////////

    // // keep track of time and location in blink_pattern
    // reg [25:0] blink_counter;

    // // pattern that will be flashed over the LED over time
    // wire [31:0] blink_pattern = 32'b101010001110111011100010101;

    // // increment the blink_counter every clock
    // always @(posedge CLK) begin
    //     blink_counter <= blink_counter + 1;
    // end

    // // light up the LED according to the pattern
    // assign LED = blink_pattern[blink_counter[25:21]];
endmodule
