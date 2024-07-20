module robot (clock, reset, head, left, under, barrier, front, turn, remove);

output reg front, turn, remove;
input head, left, under, barrier, clock, reset;

reg [2:0] act_state, next_state;

parameter searching_trash_or_left = 3'b000;
parameter rotating = 3'b001;
parameter removing_trash_or_following_left = 3'b010;
parameter stand_by = 3'b011;
parameter first_move = 3'b100;
parameter reseting = 3'b101;

always @(head or left or under or barrier or act_state)
begin
    if (under && act_state != first_move && act_state != reseting)
        begin
            next_state = stand_by;
            front = 0;
            turn = 0;
            remove = 0;
        end
    else
    case (act_state)
        reseting:
            begin
                next_state = first_move;
                front = 0;
                turn = 0;
                remove = 0;
            end
        first_move:
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
                    next_state = first_move;
                    front = 0;
                    turn = 0;
                    remove = 1;
                end
            default:
                begin
                    next_state = first_move;
                    front = 0;
                    turn = 1;
                    remove = 0;
                end
            endcase
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
        stand_by:
            begin
                next_state = stand_by;
                front = 0;
                turn = 0;
                remove = 0;
            end
    endcase
end

always @(posedge clock or negedge reset)
begin
    if (~reset) begin
        act_state <= reseting;
    end
    else begin
        act_state <= next_state;
    end
end

endmodule