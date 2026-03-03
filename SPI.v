module spi_master(
  input clk,
  input rst,
  input new_data,
  input [11:0] din,
  output reg cs,
  output reg mosi,
  output reg sclk
);

  parameter IDLE      = 1'b0;
  parameter SEND_DATA = 1'b1;

  reg [11:0] temp     = 0;
  reg [3:0]  div_cnt  = 0;    //  4-bit: counts up to 10
  reg [3:0]  data_cnt = 0;    //  4-bit: counts up to 11
  reg        state    = IDLE;

  //// clock divider fsclk = fclk/20
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      sclk    <= 1'b0;
      div_cnt <= 0;
    end
    else begin
      if (div_cnt < 10)
        div_cnt <= div_cnt + 1;
      else begin
        sclk    <= ~sclk;
        div_cnt <= 0;
      end
    end
  end

  ///////// fsm logic //////////
  always @(posedge sclk) begin
    if (rst == 1'b1) begin
      cs       <= 1'b1;
      mosi     <= 1'b0;
      state    <= IDLE;       //  reset state
      data_cnt <= 0;          // reset data counter
      temp     <= 12'h000;    //  reset temp
    end
    else begin
      case (state)

        IDLE : begin
          if (new_data == 1'b1) begin
            state <= SEND_DATA;
            cs    <= 1'b0;
            temp  <= din;
          end
          else begin
            state <= IDLE;
            temp  <= 12'h000;
          end
        end

        SEND_DATA : begin
          if (data_cnt <= 11) begin
            mosi     <= temp[data_cnt];   // LSB first
            data_cnt <= data_cnt + 1;
          end
          else begin
            data_cnt <= 0;
            state    <= IDLE;
            mosi     <= 1'b0;
            cs       <= 1'b1;
          end
        end

        default : state <= IDLE;

      endcase
    end
  end

endmodule


/////////////////// slave ///////////////

module spi_slave(
  input         cs,
  input         mosi,
  input         sclk,
  input         rst,          
  output reg    done,
  output [11:0] dout
);

  parameter DETECT_START = 1'b0;
  parameter READ_DATA    = 1'b1;

  reg [11:0] temp     = 12'h000;
  reg        state    = DETECT_START;
  reg [3:0]  data_cnt = 0;           //  4-bit: counts up to 11

  //// fsm logic
  always @(posedge sclk) begin
    if (rst == 1'b1) begin             
      state    <= DETECT_START;
      data_cnt <= 0;
      done     <= 1'b0;
    end
    else begin
      case (state)

        DETECT_START : begin
          done <= 1'b0;
          if (cs == 1'b0)
            state <= READ_DATA;
          else
            state <= DETECT_START;
        end

        READ_DATA : begin
          if (data_cnt <= 11) begin
            temp     <= {mosi, temp[11:1]};  // shift in LSB first
            data_cnt <= data_cnt + 1;
          end
          else begin
            done     <= 1'b1;
            data_cnt <= 0;
            state    <= DETECT_START;
          end
        end

        default : state <= DETECT_START;

      endcase
    end
  end

  assign dout = temp;

endmodule


/////////// top module ////////////////////

module top(
  input         clk,
  input         rst,
  input  [11:0] din,
  input         new_data,
  output [11:0] dout,
  output        done
);

  wire cs;
  wire mosi;
  wire sclk;

  spi_master m1 (
    .clk      (clk),
    .rst      (rst),
    .din      (din),
    .new_data (new_data),
    .cs       (cs),
    .mosi     (mosi),
    .sclk     (sclk)
  );

  spi_slave s1 (
    .cs   (cs),
    .sclk (sclk),
    .mosi (mosi),
    .rst  (rst),        
    .done (done),
    .dout (dout)
  );

endmodule
