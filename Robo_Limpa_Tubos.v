module Robo_Limpa_Tubos (clock, reset, head, left, under, barrier, front, turn, remove);

output reg front, turn, remove;
input head, left, under, barrier, clock, reset;

reg [0:1] act_state, next_state;
// TODO: implement action duration

parameter searching_trash_or_left = 2'b00;
parameter rotating = 2'b01;
parameter removing_trash_or_following_left = 2'b10;
parameter stand_by = 2'b11;

always @(head or left or under or barrier or act_state)
begin
    // TODO: implement the state machine
    next_state = stand_by;
    front = 0;
    turn = 0;
    remove = 0;
end

always @(negedge clock or posedge reset)
begin
    if (reset)
        begin
            act_state <= stand_by;
        end
    else
        begin
            act_state <= next_state;
        end
end

endmodule