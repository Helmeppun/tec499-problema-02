module Uart8Transmitter (
    input  wire       clk,   // baud rate
    input  wire       en,
    input  wire [7:0] in,    // data to transmit
    output reg        out,   // tx
    output reg        done,  // end on transaction
    output reg        busy   // transaction is in process
);
    reg [2:0] RESET = 3'b001;
	 reg [2:0] IDLE = 3'b010;
	 reg [2:0] START_BIT = 3'b011;
	 reg [2:0] DATA_BITS = 3'b100;
	 reg [2:0] STOP_BIT = 3'b101;
	 
	 reg [2:0] state  = 3'b001;
	 
    reg [7:0] data   = 8'b0; // to store a copy of input data
    reg [2:0] bitIdx = 3'b000; // for 8-bit data
    reg [2:0] idx = 3'b000;


    always @(posedge clk) begin
        case (state)
            default     : begin
                state   <= IDLE;
            end
            IDLE       : begin
                out     <= 1'b1; // drive line high for idle
                done    <= 1'b0;
                busy    <= 1'b0;
                bitIdx  <= 3'b0;
                data    <= 8'b0;
                if (en) begin
                    data    <= in; // save a copy of input data
                    state   <= START_BIT;
                end
            end
            START_BIT  : begin
                out     <= 1'b0; // send start bit (low)
                busy    <= 1'b1;
                state   <= DATA_BITS;
            end
            DATA_BITS  : begin // Wait 8 clock cycles for data bits to be sent
                out     <= data[idx];
                if (&bitIdx) begin
                    bitIdx  <= 3'b0;
                    state   <= STOP_BIT;
                end else begin
                    bitIdx  <= bitIdx + 1'b1;
                end
            end
            STOP_BIT   : begin // Send out Stop bit (high)
                done    <= 1'b1;
                data    <= 8'b0;
                state   <= IDLE;
            end
        endcase
    end

endmodule