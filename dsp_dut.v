module dsp (
    A,
    B,
    D,
    C,
    CLK,
    CARRYIN,
    OPMODE,
    BCIN,
    RSTA,
    RSTB,
    RSTM,
    RSTP,
    RSTC,
    RSTD,
    RSTCARRYIN,
    RSTOPMODE,
    CEA,
    CEB,
    CEM,
    CEP,
    CEC,
    CED,
    CECARRYIN,
    CEOPMODE,
    PCIN,
    BCOUT,
    PCOUT,
    P,
    M,
    CARRYOUT,
    CARRYOUTF
);
  parameter A0REG = 1;
  parameter A1REG = 1;
  parameter B0REG = 1;
  parameter B1REG = 1;
  parameter CREG = 1;
  parameter DREG = 1;
  parameter MREG = 1;
  parameter PREG = 1;
  parameter CARRYINREG = 1;
  parameter CARRYOUTREG = 1;
  parameter OPMODEREG = 1;
  parameter CARRYINSEL = "OPMODE5";
  parameter B_INPUT = "DIRECT";
  parameter RSTTYPE = "ASYNC";

  input [17:0] A, B, D, BCIN;
  input [47:0] C, PCIN;
  input [7:0] OPMODE;
  input CARRYIN, RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
  input CLK, CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
  output [17:0] BCOUT;
  output [47:0] PCOUT, P;
  output [35:0] M;
  output CARRYOUT, CARRYOUTF;

  wire [7:0] OPMODE_pair_out;
  wire [17:0] A_pair_out1, B_pair_out1, B_port, D_pair_out, pre_adder_out, add_mux_out;
  wire [17:0] B_pair_out2, A_pair_out2;
  wire [47:0] C_pair_out, concatenated_data, post_adder_out;
  reg [47:0] mux_x_out, mux_z_out;
  wire [35:0] mult_out, M_pair_out;
  wire CARRYIN_port, CIN, post_cout;

  //   reg_mux_pair #(
  //       .REG_WIDTH(),
  //       .REG(),
  //       .REG_RSTTYPE()
  //   ) _pair (
  //       .clk(),
  //       .rst(),
  //       .CE(),
  //       .reg_in(),
  //       .mux_out()
  //   );

  // specify port B
  assign B_port = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0;

  // specify carryin port
  assign CARRYIN_port = (CARRYINSEL == "CARRYIN") ? CARRYIN : (CARRYINSEL == "OPMODE5") ? OPMODE_pair_out[5] : 0;

  // carry pre-addition or subtraction operation
  assign pre_adder_out = (OPMODE_pair_out[6]) ? D_pair_out - B_pair_out1 : D_pair_out + B_pair_out1;

  // specify whether pre-adder is used or not
  assign add_mux_out = (OPMODE_pair_out[4]) ? pre_adder_out : B_pair_out1;

  // drive COUT
  assign BCOUT = B_pair_out2;

  // drive the concatenated signal
  assign concatenated_data = {D_pair_out[11:0], A_pair_out2[17:0], B_pair_out2[17:0]};

  // carry multiplication operation
  assign mult_out = B_pair_out2 * A_pair_out2;

  // drive the output M
  assign M = ~(~M_pair_out);

  // carry post-addition or subtraction operation
  assign {post_cout, post_adder_out} = (OPMODE_pair_out[7]) ? mux_z_out - (mux_x_out + CIN) : mux_x_out + mux_z_out;

  // drive CARRYOUTF output
  assign CARRYOUTF = CARRYOUT;

  // drive PCOUT output
  assign PCOUT = P;

  // drive mux X output
  always @(*) begin
    case (OPMODE_pair_out[1:0])
      0: mux_x_out = 0;
      1: mux_x_out = M_pair_out;
      2: mux_x_out = P;
      default: mux_x_out = concatenated_data;
    endcase
  end

  // drive mux Z output
  always @(*) begin
    case (OPMODE_pair_out[3:2])
      0: mux_z_out = 0;
      1: mux_z_out = PCIN;
      2: mux_z_out = P;
      default: mux_z_out = C_pair_out;
    endcase
  end

  // pipeline opmode
  reg_mux_pair #(
      .REG_WIDTH  (8),
      .REG_RSTTYPE(RSTTYPE)
  ) OPMODE_pair (
      .clk(CLK),
      .rst(RSTOPMODE),
      .CE(CEOPMODE),
      .reg_in(OPMODE),
      .mux_out(OPMODE_pair_out),
      .REG(OPMODEREG)
  );

  //1st stage: pipeline main data input ports
  reg_mux_pair #(
      .REG_RSTTYPE(RSTTYPE)
  ) D_pair (
      .clk(CLK),
      .rst(RSTD),
      .CE(CED),
      .reg_in(D),
      .mux_out(D_pair_out),
      .REG(DREG)
  );

  reg_mux_pair #(
      .REG_RSTTYPE(RSTTYPE)
  ) B0_pair (
      .clk(CLK),
      .rst(RSTB),
      .CE(CEB),
      .reg_in(B_port),
      .mux_out(B_pair_out1),
      .REG(B0REG)
  );

  reg_mux_pair #(
      .REG_RSTTYPE(RSTTYPE)
  ) A0_pair (
      .clk(CLK),
      .rst(RSTA),
      .CE(CEA),
      .reg_in(A),
      .mux_out(A_pair_out1),
      .REG(A0REG)
  );

  reg_mux_pair #(
      .REG_WIDTH  (48),
      .REG_RSTTYPE(RSTTYPE)
  ) C_pair (
      .clk(CLK),
      .rst(RSTC),
      .CE(CEC),
      .reg_in(C),
      .mux_out(C_pair_out),
      .REG(CREG)
  );

  //2st stage: pipeline pre-addition output
  reg_mux_pair #(
      .REG_RSTTYPE(RSTTYPE)
  ) B1_pair (
      .clk(CLK),
      .rst(RSTB),
      .CE(CEB),
      .reg_in(add_mux_out),
      .mux_out(B_pair_out2),
      .REG(B1REG)
  );

  reg_mux_pair #(
      .REG_RSTTYPE(RSTTYPE)
  ) A1_pair (
      .clk(CLK),
      .rst(RSTA),
      .CE(CEA),
      .reg_in(A_pair_out1),
      .mux_out(A_pair_out2),
      .REG(A1REG)
  );

  // stage 3: pipeline multiplication output
  reg_mux_pair #(
      .REG_WIDTH  (36),
      .REG_RSTTYPE(RSTTYPE)
  ) M_pair (
      .clk(CLK),
      .rst(RSTM),
      .CE(CEM),
      .reg_in(mult_out),
      .mux_out(M_pair_out),
      .REG(MREG)
  );

  reg_mux_pair #(
      .REG_WIDTH  (1),
      .REG_RSTTYPE(RSTTYPE)
  ) CYI_pair (
      .clk(CLK),
      .rst(RSTCARRYIN),
      .CE(CECARRYIN),
      .reg_in(CARRYIN_port),
      .mux_out(CIN),
      .REG(CARRYINREG)
  );

  // stage 4: pipeline output
  reg_mux_pair #(
      .REG_WIDTH  (1),
      .REG_RSTTYPE(RSTTYPE)
  ) CYO_pair (
      .clk(CLK),
      .rst(RSTCARRYIN),
      .CE(CECARRYIN),
      .reg_in(post_cout),
      .mux_out(CARRYOUT),
      .REG(CARRYOUTREG)
  );

  reg_mux_pair #(
      .REG_WIDTH  (48),
      .REG_RSTTYPE(RSTTYPE)
  ) P_pair (
      .clk(CLK),
      .rst(RSTP),
      .CE(CEP),
      .reg_in(post_adder_out),
      .mux_out(P),
      .REG(PREG)
  );

endmodule
