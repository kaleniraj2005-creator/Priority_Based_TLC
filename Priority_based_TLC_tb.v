module traffic_controller_tb;
  reg clk;
  reg rst;
  reg [3:0]sensor;
  reg [3:0]emergency;
  wire [2:0] light_N;
  wire [2:0] light_E;
  wire [2:0] light_S;
  wire [2:0] light_W;
  
  traffic_controller uut(
    .clk(clk),
    .rst(rst),
    .sensor(sensor),
    .emergency(emergency),
    .light_N(light_N),
    .light_E(light_E),
    .light_S(light_S),
    .light_W(light_W)
  );
  always #5 clk = ~clk;
  
  task wait_cycles;
 	input integer cycles;
    integer i;
    begin
       for (i = 0; i < cycles; i = i + 1)
            @(posedge clk);
    end
  endtask
  task display_status;
     begin
       $display("--------------------------------------------------");
       $display("TIME=%0t | STATE=%0d | TIMER=%0d",$time,uut.current_state,
       uut.timer);

       $write("STATE NAME = ");
       display_state_name();
       $display("");
       
       $display("Sensor    = %b", sensor);
       $display("Emergency = %b", emergency);

       $display("Wait N=%0d | Wait E=%0d | Wait S=%0d | Wait W=%0d",
                 uut.wait_N,
                 uut.wait_E,
                 uut.wait_S,
                 uut.wait_W);

       $display("Lights: N=%b E=%b S=%b W=%b",
                 light_N,
                 light_E,
                 light_S,
                 light_W);

       $display("--------------------------------------------------");
       end
  endtask
  task display_state_name;
    begin
        case (uut.current_state)
            3'd0: $write("N_GREEN");
            3'd1: $write("N_YELLOW");
            3'd2: $write("E_GREEN");
            3'd3: $write("E_YELLOW");
            3'd4: $write("S_GREEN");
            3'd5: $write("S_YELLOW");
            3'd6: $write("W_GREEN");
            3'd7: $write("W_YELLOW");
            default: $write("UNKNOWN");
        endcase
    end
endtask
  initial begin
    clk = 0;
    rst = 1;
    sensor = 4'b0000;
    emergency = 4'b0000;
    
    wait_cycles(2);
    display_status();
    rst = 0;
    wait_cycles(2);
    display_status();
    
    sensor = 4'b0001;
    emergency = 4'b0000;
    wait_cycles(13);
    display_status();
    
	sensor = 4'b0010;
    emergency = 4'b0000;
    wait_cycles(13);
    display_status();
    
    sensor = 4'b0100;
    emergency = 4'b0001;
    wait_cycles(13);
    display_status();
    
    sensor = 4'b0100;
    emergency = 4'b0001;
    wait_cycles(13);
    display_status();
    
    emergency = 4'b0000;
    wait_cycles(13);
    display_status();
    
    sensor = 4'b0100;
    emergency = 4'b0000;
    wait_cycles(4);
    display_status();      //to check starvetion
    wait_cycles(9);
    display_status();
    
    sensor = 4'b0011;
    emergency = 4'b1000;
    wait_cycles(13);
    display_status();
    
    sensor = 4'b1001;
    emergency = 4'b0000;
    wait_cycles(13);
    display_status();
    
    #20 $finish;
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,traffic_controller_tb);
  end
endmodule
    