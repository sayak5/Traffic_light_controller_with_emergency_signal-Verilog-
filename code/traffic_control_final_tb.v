`timescale 1ns / 1ps

module tb_t_c;

  // Inputs
  reg clk;
  reg rst;
  reg emg_n_s;
  reg emg_e_w;

  // Outputs
  wire [2:0] n_s_light_out;
  wire [2:0] e_w_light_out;

  // Instantiate the Unit Under Test (UUT)
  t_c uut (
    .clk(clk),
    .rst(rst),
    .emg_n_s(emg_n_s),
    .emg_e_w(emg_e_w),
    .n_s_light_out(n_s_light_out),
    .e_w_light_out(e_w_light_out)
  );

  // Clock generation: 10ns period (100MHz)
  always #5 clk = ~clk;

  // Light color names for display
  function [8*6:1] light_name;
    input [2:0] color;
    begin
      case (color)
        3'b001: light_name = "GREEN";
        3'b010: light_name = "YELLOW";
        3'b100: light_name = "RED";
        default: light_name = "RED_AL";
      endcase
    end
  endfunction

  // Initial block to simulate reset and run clock
  initial begin
    $display("Time\t\tNS\t\tEW");
    $display("-----------------------------------");
    $dumpfile("test.vcd");
    $dumpvars(0,tb_t_c);
    
    clk = 0;
    rst = 1;
    emg_n_s=0;
    emg_e_w=0;

    #20;  // hold reset for 20 ns
    rst = 0;
    
    #500;
    emg_n_s=1;
    #20;
    emg_n_s=0;
    
    
    #500;
    emg_e_w=1;
    #20;
    emg_e_w=0;
    
    #1000;
    rst=1;
    # 50;
    rst =0;
    
    
  
    // Run simulation for a while
    #2000 $finish;
  end

  // Monitor output changes
  always @(posedge clk) begin
    $display("%0dns\t%s\t%s\t%0d\t NS%0d  \t EW%0d ", 
      $time, 
      light_name(n_s_light_out), 
             light_name(e_w_light_out),
             rst,
             emg_n_s,
             emg_e_w
    );
  end

endmodule
