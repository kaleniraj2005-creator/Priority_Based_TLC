module traffic_controller (
    input clk,
    input rst,
    input [3:0] sensor,     
    input [3:0] emergency,  
    output reg  [2:0] light_N,    
    output reg  [2:0] light_E,
    output reg  [2:0] light_S,
    output reg  [2:0] light_W
);
    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;

    localparam N_GREEN  = 3'd0, N_YELLOW = 3'd1;
    localparam E_GREEN  = 3'd2, E_YELLOW = 3'd3;
    localparam S_GREEN  = 3'd4, S_YELLOW = 3'd5;
    localparam W_GREEN  = 3'd6, W_YELLOW = 3'd7;

    // Timing Constants
    localparam GREEN_TIME   = 4'd10;
    localparam YELLOW_TIME  = 4'd3;
    localparam MAX_WAIT_TIME = 6'd4; 

    reg [2:0] current_state, next_state;
    reg [3:0] timer;

    reg [5:0] wait_N, wait_E, wait_S, wait_W;

    // 1. Internal State Timer
    always @(posedge clk or posedge rst) begin
      if (rst) begin
        timer <= 4'd0;
      end else if (current_state != next_state) begin
        timer <= 4'd0; 
      end else begin
        timer <= timer + 1'b1;
      end   
    end

    // 2. Starvation Wait Counters Logic
    always @(posedge clk or posedge rst) begin
      if (rst) begin
        wait_N <= 6'd0;
        wait_E <= 6'd0;
        wait_S <= 6'd0;
        wait_W <= 6'd0;
      end 
      else begin  
        if (current_state == N_GREEN || current_state == N_YELLOW)
            wait_N <= 6'd0;
        else if (sensor[0] && wait_N < MAX_WAIT_TIME)
                wait_N <= wait_N + 1'b1;
        
        if (current_state == E_GREEN || current_state == E_YELLOW)
            wait_E <= 6'd0;
        else if (sensor[1] && wait_E < MAX_WAIT_TIME)
                wait_E <= wait_E + 1'b1;

        if (current_state == S_GREEN || current_state == S_YELLOW)
            wait_S <= 6'd0;
        else if(sensor[2] && wait_S < MAX_WAIT_TIME)
                wait_S <= wait_S + 1'b1;

        if (current_state == W_GREEN || current_state == W_YELLOW)
            wait_W <= 6'd0;
        else if (sensor[3] && wait_W < MAX_WAIT_TIME)
                 wait_W <= wait_W + 1'b1;
      end
    end

    // 3. Sequential State Register
    
    always @(posedge clk or posedge rst) begin
      if (rst)
        current_state <= N_GREEN;
      else
        current_state <= next_state;
    end

    // 4. Priority Next-State Logic with Starvation Escalation
    always @(*) begin
      next_state = current_state;

      case (current_state) 
        N_GREEN: begin       
          if (timer >= GREEN_TIME - 1)
            next_state = N_YELLOW;
          end
        N_YELLOW: begin
          if (timer >= YELLOW_TIME - 1) begin
            if (emergency[1])
              next_state = E_GREEN;
            else if (emergency[2])
              next_state = S_GREEN;
            else if (emergency[3])
              next_state = W_GREEN;

            else if ((wait_E >= MAX_WAIT_TIME) && (wait_E >= wait_S) &                            (wait_E >= wait_W))
              next_state = E_GREEN;
            else if ((wait_S >= MAX_WAIT_TIME) && (wait_S >= wait_E) &&
                     (wait_S >= wait_W))
              next_state = S_GREEN;
            else if ((wait_W >= MAX_WAIT_TIME) && (wait_W >= wait_E) &&
                     (wait_W >= wait_S))
              next_state = W_GREEN;

            else if (sensor[1])
              next_state = E_GREEN;
            else if (sensor[2])
              next_state = S_GREEN;
            else if (sensor[3])
              next_state = W_GREEN;

            else
              next_state = E_GREEN;
          end 
        end
        
        
        E_GREEN: begin
          if (timer >= GREEN_TIME - 1)       
            next_state = E_YELLOW;
        end
        E_YELLOW: begin
          if (timer >= YELLOW_TIME - 1) begin
            if (emergency[2])
              next_state = S_GREEN;
            else if (emergency[3])
              next_state = W_GREEN;
            else if (emergency[0])
              next_state = N_GREEN;

            else if ((wait_S >= MAX_WAIT_TIME) && (wait_S >= wait_W) &&
                     (wait_S >= wait_N))
              next_state = S_GREEN;
            else if ((wait_W >= MAX_WAIT_TIME) & (wait_W >= wait_S) &&
                     (wait_W >= wait_N))
              next_state = W_GREEN;
            else if ((wait_N >= MAX_WAIT_TIME) && (wait_N >= wait_S) &&
                     (wait_N >= wait_W))
              next_state = N_GREEN;

            else if (sensor[2])
              next_state = S_GREEN;
            else if (sensor[3])
              next_state = W_GREEN;
            else if (sensor[0])
              next_state = N_GREEN;

            else
              next_state = S_GREEN;
          end
        end
         
            
        S_GREEN: begin
          if (timer >= GREEN_TIME - 1)
            next_state = S_YELLOW;
          end
        S_YELLOW: begin
          if (timer >= YELLOW_TIME - 1) begin                 
            if (emergency[3])
              next_state = W_GREEN;
            else if (emergency[0])
              next_state = N_GREEN;
            else if (emergency[1])
              next_state = E_GREEN;

            else if ((wait_W >= MAX_WAIT_TIME) && (wait_W >= wait_N) &&
                     (wait_W >= wait_E))
              next_state = W_GREEN;
            else if ((wait_N >= MAX_WAIT_TIME) && (wait_N >= wait_W) &&
                     (wait_N >= wait_E))
              next_state = N_GREEN;
            else if ((wait_E >= MAX_WAIT_TIME) && (wait_E >= wait_W) &&
                     (wait_E >= wait_N))
              next_state = E_GREEN;

            else if (sensor[3])
              next_state = W_GREEN;
            else if (sensor[0])
              next_state = N_GREEN;
            else if (sensor[1])
              next_state = E_GREEN;

            else
              next_state = W_GREEN;
          end
        end
            
        
        W_GREEN: begin
          if (timer >= GREEN_TIME - 1)
            next_state = W_YELLOW;
          end
        W_YELLOW: begin
          if (timer >= YELLOW_TIME - 1) begin
            if (emergency[0])
              next_state = N_GREEN;
            else if (emergency[1])
              next_state = E_GREEN;
            else if (emergency[2])
              next_state = S_GREEN;

            else if ((wait_N >= MAX_WAIT_TIME) && (wait_N >= wait_E) &&
                     (wait_N >= wait_S))
              next_state = N_GREEN;
            else if ((wait_E >= MAX_WAIT_TIME) && (wait_E >= wait_N) &&
                     (wait_E >= wait_S))
              next_state = E_GREEN;
            else if ((wait_S >= MAX_WAIT_TIME) && (wait_S >= wait_N) &&
                     (wait_S >= wait_E))
              next_state = S_GREEN;

            else if (sensor[0])
              next_state = N_GREEN;
            else if (sensor[1])
              next_state = E_GREEN;
            else if (sensor[2])
              next_state = S_GREEN;

            else
              next_state = N_GREEN;
          end
        end
             
        default:         
          next_state = N_GREEN;
        endcase
    end

    // 5. Output Combinational Logic (Moore FSM)
    always @(*) begin
      light_N = RED;
      light_E = RED;
      light_S = RED;
      light_W = RED;

      case (current_state)
        N_GREEN:  light_N = GREEN;
        N_YELLOW: light_N = YELLOW;
        E_GREEN:  light_E = GREEN;
        E_YELLOW: light_E = YELLOW;
        S_GREEN:  light_S = GREEN;
        S_YELLOW: light_S = YELLOW;
        W_GREEN:  light_W = GREEN;
        W_YELLOW: light_W = YELLOW;
        default: ;
      endcase
    end

endmodule
