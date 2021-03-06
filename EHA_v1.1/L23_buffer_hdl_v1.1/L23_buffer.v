`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Vladimir Efimov 
// 
// Create Date: 08/24/2016 12:53:27 PM
// Design Name: 
// Module Name: L23_buffer
// Project Name: L23buffer_v1 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module L23_buffer (
input L23_clk,	//shared wire
input L23_rst,	//shared wire
input [7:0] L23i_tdata,
input L23i_tlast,
input L23i_tuser,
output L23i_tready,
input L23i_tvalid,
output [7:0] L23o_tdata,
output L23o_tlast,
input L23o_tready,
output L23o_tvalid
);


//Drive pipeline logic wire
wire drive_pipeline;

//wire name is specifyed as "w_(module name)_(outputinterface_of_the_module)"
wire w_writebuf_fsm_wren;
wire w_writebuf_fsm_wr_newline;
wire w_writebuf_fsm_wr_char_incr;
wire w_writebuf_fsm_wr_restart_line;

wire w_readbuf_fsm_rd_newline;
wire w_readbuf_fsm_rd_char_incr;

wire w_char_line_counters_wrapper_rd_greenflag;
wire w_char_line_counters_wrapper_wr_greenflag;
wire w_char_line_counters_wrapper_tlast_flag;
wire [12:0] w_char_line_counters_wrapper_rd_ptr;
wire [12:0] w_char_line_counters_wrapper_wr_ptr;


//Drive pipleine logic
assign drive_pipeline = !(L23o_tvalid & !L23o_tready);

//Modules instantiations

writebuf_fsm WRITEBUF_FSM1(.clk(L23_clk), .rst(L23_rst), .greenflag(w_char_line_counters_wrapper_wr_greenflag), .tvalid(L23i_tvalid), .tlast(L23i_tlast), .tuser(L23i_tuser), .tready(L23i_tready), .wren(w_writebuf_fsm_wren), .wr_newline(w_writebuf_fsm_wr_newline), .wr_char_incr(w_writebuf_fsm_wr_char_incr), .wr_restart_line(w_writebuf_fsm_wr_restart_line));

readbuf_fsm READBUF_FSM1(.clk(L23_clk), .rst(L23_rst), .greenflag(w_char_line_counters_wrapper_rd_greenflag), .lastflag(w_char_line_counters_wrapper_tlast_flag), .tready(drive_pipeline), .tvalid(L23o_tvalid), .tlast(L23o_tlast), .rd_newline(w_readbuf_fsm_rd_newline), .rd_char_incr(w_readbuf_fsm_rd_char_incr));

char_line_counters_wrapper CHAR_LINE_COUNTERS_WRAPPER1(.clk(L23_clk), .rst(L23_rst), .rd_char_incr(w_readbuf_fsm_rd_char_incr), .wr_char_incr(w_writebuf_fsm_wr_char_incr), .rd_newline(w_readbuf_fsm_rd_newline), .wr_newline(w_writebuf_fsm_wr_newline), .wr_restart_line(w_writebuf_fsm_wr_restart_line),
.rd_greenflag(w_char_line_counters_wrapper_rd_greenflag), .wr_greenflag(w_char_line_counters_wrapper_wr_greenflag), .tlast_flag(w_char_line_counters_wrapper_tlast_flag), .rd_ptr(w_char_line_counters_wrapper_rd_ptr), .wr_ptr(w_char_line_counters_wrapper_wr_ptr));

dual_port_syncout_enabled_ram DUAL_PORT_SYNCOUT_ENABLED_RAM1(.clk(L23_clk), .rst(L23_rst), .enableout(drive_pipeline), .we(w_writebuf_fsm_wren), .data(L23i_tdata), .read_addr(w_char_line_counters_wrapper_rd_ptr), .write_addr(w_char_line_counters_wrapper_wr_ptr), .q(L23o_tdata));

endmodule

