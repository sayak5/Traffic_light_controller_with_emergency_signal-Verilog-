// Code your design here

module t_c (input clk ,
            input rst , 
            input emg_n_s,
            input emg_e_w,
            output reg [2:0] n_s_light_out,
            output reg [2:0] e_w_light_out
           );

  parameter S0=0,S1=1,S2=2,S3=3,S4=4,S5=5,BUFFER=6;
  parameter RED    = 3'b100;
  parameter YELLOW = 3'b010;
  parameter GREEN  = 3'b001;

  parameter REDTIME=3,GREENTIME=20,YELLOWTIME=5,BUFFERTIME=2;
  reg prev_emg;
  reg [2:0] ps, ns;
  reg [7:0] count;
  reg [7:0] resume_count;
  reg [2:0] resume_state;

  always @(posedge clk or posedge rst )begin

    if(rst) begin
      ps<=S5;
      count<=0;
      prev_emg<=0;
    end
    else if (emg_n_s || emg_e_w)begin


      resume_state<=ps;
      resume_count<=count;

      ps<=ps;
      count<=count; 

      prev_emg<=1;

    end
    else if(prev_emg) begin

      ps<=BUFFER;
      count<=0;
      prev_emg<=0;
    end
    else if(ps!=ns)begin
      ps<=ns; 
      if(ps ==BUFFER && ns==resume_state)begin
        count<=resume_count;
      end 
      else begin 
        count<=0;
      end
    end

    else begin
      count <= count +1;
    end
  end
  always @(*)begin 
    case(ps)
      S0: ns = (count>=GREENTIME)? S1 : S0;
      S1: ns = (count>=YELLOWTIME)? S2 : S1;
      S2: ns = (count>=REDTIME)? S3 : S2;
      S3: ns = (count>=GREENTIME)? S4 : S3;
      S4: ns = (count>=YELLOWTIME)? S5 : S4;
      S5: ns = (count>=REDTIME)? S0 : S5;
      BUFFER: ns=(count>=BUFFERTIME)? resume_state:BUFFER; 
      default: ns=S0;
    endcase
  end



  // output logic to show at intersection
  always @(*)begin

    //reset operation
    if (rst) begin
      n_s_light_out=RED;
      e_w_light_out=RED;
    end
    //emergency operation
    else if(emg_n_s)begin
      n_s_light_out=GREEN; 
      e_w_light_out=RED;
    end
    else if(emg_e_w) begin
      n_s_light_out=RED;
      e_w_light_out=GREEN;
    end
    else if(prev_emg) begin
      n_s_light_out=RED;
      e_w_light_out=RED;
    end

    // normal operation
    else begin
      case(ps)
        S0:begin n_s_light_out=GREEN; e_w_light_out=RED;end
        S1: begin n_s_light_out=YELLOW; e_w_light_out=RED;end 
        S2: begin n_s_light_out=RED; e_w_light_out=RED;end
        S3: begin n_s_light_out=RED; e_w_light_out=GREEN;end
        S4: begin n_s_light_out=RED; e_w_light_out=YELLOW;end
        S5: begin n_s_light_out=RED; e_w_light_out=RED;end
        BUFFER: begin n_s_light_out=RED; e_w_light_out=RED;end


        //      N_S_EMG: begin n_s_light_out=GREEN; e_w_light_out=RED;end
        //      E_W_EMG: begin n_s_light_out=RED; e_w_light_out=GREEN;end


        default : begin
          n_s_light_out=RED;
          e_w_light_out=RED;
        end
      endcase
    end
  end



endmodule