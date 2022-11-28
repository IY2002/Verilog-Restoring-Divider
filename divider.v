module divider (
   input clk,
   input clear,
   input [31:0] a,
   input [15:0] b,
   input start,
 
   output reg [31:0]q,
   output reg [15:0]r,
   output reg ready,
   output reg busy,
   output reg [4:0] counter
);
   //registers to hold running values of q and r
   reg [15:0] reg_r;
   reg [31:0] reg_q;
   
   //wires to transport outputs to registers and other modules
   wire[31:0] wire_q;
   wire[15:0] wire_r;
   wire[16:0] wire_result;
   
   subtractor sub(
       .r({reg_r, reg_q[31]}),
       .b({1'b0, b[15:0]}),
       .result(wire_result)
   );
   
   mux_a muxa(
       .remain({reg_r[14:0], reg_q[31]}),
       .change(wire_result[15:0]),
       .signal(wire_result[16]),
       .result(wire_r)
   );
 
   mux_b muxb(
       .dividend(a),
       .q_next({reg_q[30:0], ~wire_result[16]}),
       .start(start),
       .q(wire_q)
   );
 
always @(posedge clk) begin
 
   //if clear = 0: set evrything to zero (q,r,busy, counter, ready)
   
      
   if (clear == 0) begin
       reg_r = 0;
       reg_q = 0;
       busy = 0;
       counter = 0;
       ready = 0;  
   end
 
   //if start = 1: start division
   // set q = a and r = 0
   // set busy to 1
   else if (start == 1) begin
       reg_q = a;
       q = a;
       reg_r = 0;
       r = 0;
       ready = 0;
       busy = 1;
   end   
 
   //if busy = 1: keep dividing
   //increment counter
   //check if counter is higher than 32
   //if so then divsion is done and set busy to 0 and clear to 0
   // set ready to 1

   else if(busy == 1) begin
       counter = counter + 1;
       reg_q = wire_q;       
       reg_r = wire_r;
       q = wire_q;
       r = wire_r;
   end
   
   //End division if counter reaches 0
   if(counter == 0 && ready == 0) begin
       busy = 0;
       ready = 1;
   end
end 
endmodule
 
// CREATE MODULE THAT DOES THIS:
   //result[16:0] = ({r[15:0], q[31]} - {1'b0, b[15:0]})

module subtractor (
   input [16:0] r,
   input [16:0] b,
   output reg [16:0] result
);
always @(*) begin
    result <= r - b;
end
endmodule
 
// CREATE MODULE THAT DOES THIS:
   //check MSB of subtractor and
   // if == 1: r = {r[14:0], q[31]}
   // if == 0: r = result of subtractor without MSB. (result[15:0])
 
module mux_a (
   input [15:0] remain,
   input [15:0] change,
   input signal,
   output reg [15:0] result
);
always @(*) begin
    case(signal) 
       1'b0: result <= change;
       1'b1: result <= remain;
   endcase
end
endmodule
// CREATE A MODULE THAT DOES THIS:
   // intially, set q to a
   //q[31:0] <= a[31:0]
   //After each subtraction take MSB of result and set to LSB of q
   // q = {q[30:0], result[16]}
module mux_b(
   input [31:0] dividend,
   input [31:0] q_next,
   input start,
   output reg [31:0] q
);

always @* begin
   case(start)
       1'b1: q <= dividend;
       1'b0: q <= q_next;
   endcase
end
endmodule