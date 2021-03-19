/******************************************************************************
 * Stimulus to test the D Flip-Flop model with timing checks - Verilog 
 * Training Course, Lab3.
 *
 * This stimulus should cause timing violations under these conditions:
 *
 *   with Minimum Delays:  No violations
 *   with Typical Delays:  A setup violation
 *   with Maximum Delays:  A setup and a hold violation
 *   with Delay Mode Unit: No violations
 *****************************************************************************/
`resetall
`timescale 1ns/100ps
module test;

  reg data, rst, start;
   
  dffr_b d1 (rst, clk, out, outb, data);

  nand #10 (clk, clk, start);  //a 20ns clock oscillator
  initial               //initialize the clock oscillator
    begin
      start = 0;
      #10 start = 1;
    end

  initial
    begin
      rst = 0;          //check that the flip-flop resets
      #15 rst = 1;

      @(negedge clk)    //sync to negedge of clock to avoid timing violation
        data = 1;       //check to see if can clock in a 1

      @(negedge clk)    //sync to negedge of clock to avoid timing violation
        data = 0;       //check to see if can clock in a 0

      @(negedge clk)    //sync to negedge of clock
        #6 data = 1;    //check to see if get setup violation

      @(posedge clk)    //sync to posedge of clock
        #5 data = 0;    //check to see if get hold violation

      #10 if (d1.flag === 1'bx)
        $display("\n No timing Violations!\n");
    end


initial
  begin
    $shm_open("timing.shm");
    $shm_probe("A");
    $fsdbDumpfile("timing.fsdb");
    $fsdbDumpvars();
    #100 $finish;
  end

endmodule

