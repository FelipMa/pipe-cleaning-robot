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
    //TODO: treat under
    case (act_state)
        searching_trash_or_left:
            casez ({head, left, barrier})
            3'b1?1:
                begin
                    next_state = stand_by;
                    front = 0;
                    turn = 0;
                    remove = 0;
                end
            3'b010:
                begin
                    next_state = searching_trash_or_left;
                    front = 1;
                    turn = 0;
                    remove = 0;
                end
            3'b110:
                begin
                    next_state = rotating;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            3'b011:
                begin
                    next_state = removing_trash_or_following_left;
                    front = 0;
                    turn = 0;
                    remove = 1;
                end
            default:
                begin
                    next_state = removing_trash_or_following_left;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            endcase
        rotating:
            casez ({head, left, barrier})
            3'b1?1:
                begin
                    next_state = stand_by;
                    front = 0;
                    turn = 0;
                    remove = 0;
                end
            3'b010:
                begin
                    next_state = searching_trash_or_left;
                    front = 1;
                    turn = 0;
                    remove = 0;
                end
            3'b011:
                begin
                    next_state = removing_trash_or_following_left;
                    front = 0;
                    turn = 0;
                    remove = 1;
                end
            default:
                begin
                    next_state = rotating;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            endcase
        removing_trash_or_following_left:
            casez ({head, left, barrier})
            3'b1?1:
                begin
                    next_state = stand_by;
                    front = 0;
                    turn = 0;
                    remove = 0;
                end
            3'b0?1:
                begin
                    next_state = removing_trash_or_following_left;
                    front = 0;
                    turn = 0;
                    remove = 1;
                end
            3'b0?0:
                begin
                    next_state = searching_trash_or_left;
                    front = 1;
                    turn = 0;
                    remove = 0;
                end
            3'b110:
                begin
                    next_state = rotating;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            3'b100:
                begin
                    next_state = removing_trash_or_following_left;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            endcase
    endcase
end

always @(posedge clock)
begin
    if (reset)
        begin
            act_state <= searching_trash_or_left;
        end
    else
        begin
            act_state <= next_state;
        end
end

endmodule