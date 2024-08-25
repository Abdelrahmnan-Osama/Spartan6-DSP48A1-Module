module reg_mux_pair (
    clk,
    rst,
    CE,
    reg_in,
    mux_out,
    REG
);

  parameter REG_WIDTH = 18;
  parameter REG_RSTTYPE = "ASYNC";

  input [REG_WIDTH-1:0] reg_in;
  input clk, CE, rst, REG;
  output reg [REG_WIDTH-1:0] mux_out;


  reg [REG_WIDTH-1:0] mux_out_synch, mux_out_asynch;
  wire [REG_WIDTH-1:0] mux_out_comb;

  // no pipeline registers
  assign mux_out_comb = reg_in;

  // one synchronous pipeline register
  always @(posedge clk) begin
    if (rst) begin
      mux_out_synch <= 0;
    end else if (CE) begin
      mux_out_synch <= reg_in;
    end
  end

  // one asynchronous pipeline register  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      mux_out_asynch <= 0;
    end else if (CE) begin
      mux_out_asynch <= reg_in;
    end
  end

  // choose suitable implementation at compilation time
  always @(*) begin
    if (REG) begin
      if (REG_RSTTYPE == "SYNC") begin
        mux_out = mux_out_synch;
      end else begin
        mux_out = mux_out_asynch;
      end
    end else begin
      mux_out = mux_out_comb;
    end
  end


  // generate
  //   // no pipline registers
  //   if (!REG) begin
  //     always @(*) begin
  //       mux_out = reg_in;
  //     end
  //     // one pipeline register
  //   end else begin
  //     //register with syncronous reset
  //     if (REG_RSTTYPE == "SYNC") begin
  //       always @(posedge clk) begin
  //         if (rst) begin
  //           mux_out <= 0;
  //         end else if (CE) begin
  //           mux_out <= reg_in;
  //         end
  //       end
  //       // register with asyncronous rest
  //     end else begin
  //       always @(posedge clk or posedge rst) begin
  //         if (rst) begin
  //           mux_out <= 0;
  //         end else if (CE) begin
  //           mux_out <= reg_in;
  //         end
  //       end
  //     end
  //   end
  // endgenerate

endmodule
