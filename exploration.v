// Tile coordinates, NOT VGA pixels. Map is 20 columns by 15 rows.
// move_dir: 00 up, 01 down, 10 left, 11 right.

module exploration (clk,resetn,scene,move_pulse,move_dir,player_x,player_y);

    input wire clk;
    input wire resetn;
    input wire [2:0] scene;
    input wire move_pulse;
    input wire [1:0] move_dir;
    output reg [4:0] player_x;
    output reg [4:0] player_y;

    localparam TOWN    = 3'd0;
    localparam HOUSE1  = 3'd1;
    localparam HOUSE2  = 3'd2;
    localparam DUNGEON = 3'd3;
    localparam BATTLE  = 3'd4;

    localparam [4:0] START_X = 5'd10;
    localparam [4:0] START_Y = 5'd7;
    localparam [4:0] MAX_X   = 5'd19;
    localparam [4:0] MAX_Y   = 5'd14;

    reg [2:0] previous_scene;

    // Position to restore when returning to town.
    reg [4:0] town_return_x;
    reg [4:0] town_return_y;

    // Position to restore when returning from battle.
    reg [4:0] dungeon_return_x;
    reg [4:0] dungeon_return_y;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            player_x <= START_X;
            player_y <= START_Y;

            previous_scene <= TOWN;

            town_return_x <= START_X;
            town_return_y <= START_Y;

            dungeon_return_x <= START_X;
            dungeon_return_y <= START_Y;
        end else begin
            previous_scene <= scene;

            // scene changes before move.
            if (scene != previous_scene) begin

                // Save the location in the scene being left.
                if (previous_scene == TOWN) begin
                    town_return_x <= player_x;
                    town_return_y <= player_y;
                end

                if (previous_scene == DUNGEON) begin
                    dungeon_return_x <= player_x;
                    dungeon_return_y <= player_y;
                end

                case (scene)
                    TOWN: begin
                        player_x <= town_return_x;
                        player_y <= town_return_y;
                    end

                    HOUSE1, HOUSE2: begin
                        player_x <= START_X;
                        player_y <= START_Y;
                    end

                    DUNGEON: begin
                        if (previous_scene == BATTLE) begin
                            player_x <= dungeon_return_x;
                            player_y <= dungeon_return_y;
                        end else begin
                            player_x <= START_X;
                            player_y <= START_Y;
                        end
                    end
                endcase

            end else if (move_pulse) begin

                // Movement is enabled only in exploration scenes.
                case (scene)
                    TOWN, HOUSE1, HOUSE2, DUNGEON: begin
                        case (move_dir)
                            2'b00: begin
                                if (player_y > 5'd0)
                                    player_y <= player_y - 5'd1;
                            end

                            2'b01: begin
                                if (player_y < MAX_Y)
                                    player_y <= player_y + 5'd1;
                            end

                            2'b10: begin
                                if (player_x > 5'd0)
                                    player_x <= player_x - 5'd1;
                            end

                            2'b11: begin
                                if (player_x < MAX_X)
                                    player_x <= player_x + 5'd1;
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

endmodule