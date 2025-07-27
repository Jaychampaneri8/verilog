`timescale 1ns / 1ps

module WashingMachine_tb;
  // Inputs
 
  reg clk, reset;
  reg door_close, start, filled, det_added;
  reg cycle_timeout, drained, spin_timeout;

  // Outputs
  wire door_lock, motor_on, fill_valve_on, drain_valve_on;
  wire soap_wash, water_wash, done;

  // Instantiate the DUT
  Washing_machine dut (
    .clk(clk), .reset(reset),
    .door_close(door_close), .start(start),
    .filled(filled), .det_added(det_added),
    .cycle_timeout(cycle_timeout), .drained(drained), .spin_timeout(spin_timeout),
    .door_lock(door_lock), .motor_on(motor_on),
    .fill_valve_on(fill_valve_on), .drain_valve_on(drain_valve_on),
    .soap_wash(soap_wash), .water_wash(water_wash), .done(done)
  );

  // Clock: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Self-checking task
  task check;
    input       exp_motor, exp_soap, exp_water, exp_done;
    input [64*8:1] msg;
    begin
      $display(" %0t: %s", $time, msg);
      if (motor_on !== exp_motor ||
          soap_wash !== exp_soap ||
          water_wash !== exp_water ||
          done      !== exp_done) begin
        $display("FAIL: motor=%b soap=%b water=%b done=%b (expected %b %b %b %b)",
                 motor_on, soap_wash, water_wash, done,
                 exp_motor, exp_soap, exp_water, exp_done);
      end else begin
      
        $display(" PASS");
      end
    end
  endtask

  initial begin
 
    $display("==== Washing Machine FSM Self-Checking Testbench ====");

    // Initialize all inputs
    reset        = 1;
    door_close   = 0;
    start        = 0;
    filled       = 0;
    det_added    = 0;
    cycle_timeout= 0;
    drained      = 0;
    spin_timeout = 0;

    #20 reset = 0;

    // 1) Try to start with door open → should stay idle
    #10 start = 1;
    #10 check(0,0,0,0, "Door open + start → should NOT start");
    start = 0;

    // 2) Close door + start → go to fill_water
    #10 door_close = 1; start = 1;
    #10 check(0,0,0,0, "Door closed + start → filling begins (fill_valve_on=1)");
    start = 0;

    // 3) Water fills
    #20 filled = 1;
    #10 check(0,0,0,0, "Water filled → waiting for detergent");
    filled = 0;

    // 4) Add detergent → soap_wash=1
    #10 det_added = 1;
    #10 check(0,1,0,0, "Detergent added → soap_wash active");
    det_added = 0;

    // 5) Washing cycle → motor_on=1 until cycle_timeout
    #10 cycle_timeout = 0;
    #10 check(1,0,0,0, "Cycle running → motor_on active");
    // now finish cycle
    #20 cycle_timeout = 1;
    #10 check(0,0,0,0, "Cycle done → motor_off, entering drain");
    cycle_timeout = 0;

    // 6) Drain after soap wash → drain_valve_on = 1
    #10 drained = 1;
    #10 check(0,0,0,0, "Drained soap water → ready for rinse");
    drained = 0;

    // 7) Fill for rinse → fill_valve_on = 1
    #10 filled = 1;
    #10 check(0,0,0,0, "Rinse fill begins");
    filled = 0;

    // 8) Rinse cycle → motor_on=1 until cycle_timeout again
    #10 cycle_timeout = 0;
    #10 check(1,0,0,0, "Rinse cycle running → motor_on again");
    #20 cycle_timeout = 1;
    #10 check(0,0,0,0, "Rinse done → motor_off, entering drain");
    cycle_timeout = 0;

    // 9) Drain after rinse → water_wash=1 when draining
    #10 drained = 1;
    #10 check(0,0,1,0, "Draining rinse water → water_wash active");
    drained = 0;

    // 10) Spin → motor_on & then done=1
    #10 spin_timeout = 0;
    #10 check(1,0,1,0, "Spin running → motor_on & water_wash remains");
    // finish spin
    #20 spin_timeout = 1;
    #10 check(0,0,1,1, "Spin done → motor_off & done=1");
    spin_timeout = 0;

    $display("==== Testbench Complete ====");
    $finish;
  end

endmodule
