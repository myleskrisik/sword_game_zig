const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

const Subpixel = struct {
    const SUBPIXEL_BITS = 6;
    const SCALING_FACTOR = std.math.pow(i32, 2, SUBPIXEL_BITS);

    floating_point_representation: i32 = 0,

    pub fn as_int(self: Subpixel) i32 {
        return self.floating_point_representation >> SUBPIXEL_BITS;
    }

    pub fn as_float(self: Subpixel) f32 {
        return @as(f32, @floatFromInt(self.floating_point_representation)) / SCALING_FACTOR;
    }

    pub fn from_int(int: i32) Subpixel {
        return Subpixel{ .floating_point_representation = int << SUBPIXEL_BITS };
    }

    pub fn from_float(float: f32) Subpixel {
        return Subpixel{ .floating_point_representation = @intFromFloat(float * SCALING_FACTOR) };
    }

    pub fn sign(self: Subpixel) Subpixel {
        return .{ .floating_point_representation = std.math.sign(self.floating_point_representation) };
    }

    pub fn minus(self: Subpixel, other: Subpixel) Subpixel {
        return .{ .floating_point_representation = self.floating_point_representation - other.floating_point_representation };
    }

    pub fn plus(self: Subpixel, other: Subpixel) Subpixel {
        return .{ .floating_point_representation = self.floating_point_representation + other.floating_point_representation };
    }

    pub fn times(self: Subpixel, other: Subpixel) Subpixel {
        return .{ .floating_point_representation = self.floating_point_representation * other.floating_point_representation };
    }

    pub fn move_towards(self: *Subpixel, target: Subpixel, max_delta: Subpixel) void {
        const distance_from_target = target.minus(self.*);
        if (@abs(distance_from_target.floating_point_representation) <= max_delta.floating_point_representation) {
            self.* = target;
            return;
        }
        self.* = self.plus(distance_from_target.sign().times(max_delta));
    }
};

const Position = struct { x: Subpixel = Subpixel.from_int(0), y: Subpixel = Subpixel.from_int(0) };

const Velocity = struct {
    x: Subpixel = .{},
    y: Subpixel = .{},

    pub fn changing_direction(self: Velocity, inputs: [2]f32) [2]bool {
        const sign = std.math.sign;

        const x_vel_sign = sign(self.x.as_float());
        const y_vel_sign = sign(self.y.as_float());
        const x_input_sign = sign(inputs[0]);
        const y_input_sign = sign(inputs[1]);

        const x_changing_dirs = if (x_vel_sign == 0 or x_input_sign == 0) false else x_vel_sign != x_input_sign;
        const y_changing_dirs = if (y_vel_sign == 0 or y_input_sign == 0) false else y_vel_sign != y_input_sign;
        return .{ x_changing_dirs, y_changing_dirs };
    }

    pub fn apply_friction(inputs: [2]f32, friction: Subpixel) void {
        if (inputs[0] )
    }
};

const Acceleration = struct {
    x: Subpixel = Subpixel.from_int(0),
    y: Subpixel = Subpixel.from_int(0),

    pub fn init(x: Subpixel, y: Subpixel) Acceleration {
        return .{ x, y };
    }
};

const Player = struct {
    const ACCELERATION = 4;
    const CHANGING_DIRECTION_ACCELERATION = 4;
    const FRICTION = 10;
    const MAX_VELOCITY = 240;

    position: Position,
    velocity: Velocity,
    sprite: rl.struct_Texture,

    pub fn init(sprite: rl.struct_Texture) Player {
        return Player{ .position = Position{}, .sprite = sprite, .velocity = Velocity{} };
    }

    fn get_movement_inputs() [2]f32 {
        var x_input: f32 = 0.0;
        var y_input: f32 = 0.0;

        if (rl.IsKeyDown(rl.KEY_W)) {
            y_input -= 1.0;
        }
        if (rl.IsKeyDown(rl.KEY_S)) {
            y_input += 1.0;
        }
        if (rl.IsKeyDown(rl.KEY_A)) {
            x_input -= 1.0;
        }
        if (rl.IsKeyDown(rl.KEY_D)) {
            x_input += 1.0;
        }

        const vec = rl.Vector2{ .x = x_input, .y = y_input };
        const x_squared = if (vec.x == 0.0) 0 else std.math.pow(f32, vec.x, 2);
        const y_squared = if (vec.y == 0.0) 0 else std.math.pow(f32, vec.y, 2);
        const squared_elements_sum = x_squared + y_squared;
        const vec_magnitude = @sqrt(squared_elements_sum);

        return if (vec_magnitude == 0) .{ 0, 0 } else .{ vec.x / vec_magnitude, vec.y / vec_magnitude };
    }

    pub fn calculate_acceleration(self: Player, inputs: [2]f32) Acceleration {
        var accel: Acceleration = .{};
        const changing_directions = self.velocity.changing_direction(inputs);
        if (@abs(self.velocity.x.floating_point_representation) < Player.MAX_VELOCITY or changing_directions[0]) {
            accel.x.floating_point_representation = if (changing_directions[0]) Player.CHANGING_DIRECTION_ACCELERATION else Player.ACCELERATION;
            accel.x = accel.x.times(Subpixel.from_float(inputs[0]));
        }

        if (@abs(self.velocity.y.floating_point_representation) < Player.MAX_VELOCITY or changing_directions[1]) {
            accel.y.floating_point_representation = if (changing_directions[1]) Player.CHANGING_DIRECTION_ACCELERATION else Player.ACCELERATION;
            accel.y = accel.y.times(Subpixel.from_float(inputs[1]));
        }
        return accel;
    }

    pub fn apply_acceleration(self: *Player, acceleration: Acceleration, delta_time: f32) void {
        const delta_time_subpixel = 
        self.velocity.x = acceleration.x.plus(self.velocity.x).times();
        self.velocity.y = acceleration.y.plus(self.velocity.y);
    }

    pub fn update_position(self: *Player) void {
        self.position.x.floating_point_representation += self.velocity.x.floating_point_representation;
        self.position.y.floating_point_representation += self.velocity.y.floating_point_representation;
    }

    pub fn apply_friction(self: *Player, inputs: [2]f32) void {
        if (inputs[0] == 0) {
            self.velocity.x.move_towards(.{ .floating_point_representation = 0 }, .{ .floating_point_representation = Player.FRICTION });
        }
        if (inputs[1] == 0) {
            self.velocity.y.move_towards(.{ .floating_point_representation = 0 }, .{ .floating_point_representation = Player.FRICTION });
        }
    }
};

pub fn main() !void {
    const screen_width = 800;
    const screen_height = 450;

    const virtual_screen_width = 320;
    const virtual_screen_height = 180;

    const virtual_ratio = screen_width / virtual_screen_width;

    rl.InitWindow(screen_width, screen_height, "My Window Name");
    defer rl.CloseWindow();

    var world_space_camera = rl.Camera2D{ .zoom = 1 };

    var screen_space_camera = rl.Camera2D{ .zoom = 1 };

    const target = rl.LoadRenderTexture(virtual_screen_width, virtual_screen_height);
    defer rl.UnloadRenderTexture(target);

    const source_rect = rl.Rectangle{ .x = 0, .y = 0, .width = @floatFromInt(target.texture.width), .height = @floatFromInt(-target.texture.height) };
    const dest_rect = rl.Rectangle{ .x = -virtual_ratio, .y = -virtual_ratio, .width = screen_width + (virtual_ratio * 2), .height = screen_height + (virtual_ratio * 2) };

    const origin = rl.Vector2{ .x = 0, .y = 0 };

    const camera_x: f32 = 0;
    const camera_y: f32 = 0;

    rl.SetTargetFPS(60);
    const player_sprite = rl.LoadTexture("player.png");
    var player = Player.init(player_sprite);
    defer rl.UnloadTexture(player_sprite);

    while (!rl.WindowShouldClose()) {
        const delta_time = rl.GetFrameTime();
        // Update
        {
            screen_space_camera.target = rl.Vector2{ .x = camera_x, .y = camera_y };

            world_space_camera.target.x = screen_space_camera.target.x;
            screen_space_camera.target.x -= world_space_camera.target.x;
            screen_space_camera.target.x *= virtual_ratio;

            world_space_camera.target.y = screen_space_camera.target.y;
            screen_space_camera.target.y -= world_space_camera.target.y;
            screen_space_camera.target.y *= virtual_ratio;

            const inputs = Player.get_movement_inputs();
            const acceleration = player.calculate_acceleration(inputs);
            player.apply_acceleration(acceleration, delta_time);
            player.apply_friction(inputs, delta_time);
            player.update_position(delta_time);
            std.log.info("velocity: (x: {any}, y: {any})", .{ player.velocity.x.floating_point_representation, player.velocity.y.floating_point_representation });
        }
        // Draw worldspace
        {
            rl.BeginTextureMode(target);
            defer rl.EndTextureMode();
            rl.ClearBackground(rl.WHITE);
            {
                rl.BeginMode2D(world_space_camera);
                rl.DrawTexture(player_sprite, player.position.x.as_int(), player.position.y.as_int(), rl.WHITE);
                defer rl.EndMode2D();
            }
        }
        // Draw screenspace
        {
            rl.BeginDrawing();
            defer rl.EndDrawing();
            rl.ClearBackground(rl.RED);
            {
                rl.BeginMode2D(screen_space_camera);
                defer rl.EndMode2D();
                rl.DrawTexturePro(target.texture, source_rect, dest_rect, origin, 0.0, rl.WHITE);
            }
        }
    }
}
